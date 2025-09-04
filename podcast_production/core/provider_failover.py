"""
Multi-Provider Failover Manager with Health Checks and Load Balancing

This module implements production-grade API failover, health monitoring, 
and intelligent load balancing across multiple providers.

Version: 1.0.0
Date: September 2025
"""

import asyncio
import logging
import time
from enum import Enum
from typing import Dict, Any, Optional, List, Callable, Union
from dataclasses import dataclass, field
from datetime import datetime, timedelta
import httpx
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from circuitbreaker import circuit

logger = logging.getLogger(__name__)


class ProviderStatus(Enum):
    """Provider health states"""
    HEALTHY = "healthy"
    DEGRADED = "degraded" 
    UNHEALTHY = "unhealthy"
    UNKNOWN = "unknown"


class LoadBalancingStrategy(Enum):
    """Load balancing strategies"""
    ROUND_ROBIN = "round_robin"
    WEIGHTED = "weighted"
    PRIORITY = "priority"
    LEAST_LATENCY = "least_latency"
    ADAPTIVE = "adaptive"


@dataclass
class ProviderMetrics:
    """Real-time provider metrics"""
    latency_ms: float = 0.0
    success_rate: float = 1.0
    error_count: int = 0
    request_count: int = 0
    last_error: Optional[str] = None
    last_check: datetime = field(default_factory=datetime.now)
    consecutive_failures: int = 0
    
    def calculate_health_score(self) -> float:
        """Calculate composite health score (0-1)"""
        # Weight factors for health calculation
        latency_weight = 0.3
        success_weight = 0.5
        recency_weight = 0.2
        
        # Normalize latency (lower is better, cap at 5000ms)
        latency_score = max(0, 1 - (self.latency_ms / 5000))
        
        # Success rate already 0-1
        success_score = self.success_rate
        
        # Recency score (penalize stale checks)
        minutes_since_check = (datetime.now() - self.last_check).seconds / 60
        recency_score = max(0, 1 - (minutes_since_check / 30))
        
        return (
            latency_score * latency_weight +
            success_score * success_weight +
            recency_score * recency_weight
        )


@dataclass
class ProviderConfig:
    """Provider configuration"""
    name: str
    base_url: str
    api_key: str
    priority: int = 1  # Lower is higher priority
    weight: float = 1.0  # For weighted distribution
    timeout: float = 30.0
    health_endpoint: str = "/health"
    models: List[str] = field(default_factory=list)
    max_retries: int = 3
    circuit_breaker_threshold: int = 5
    circuit_breaker_timeout: int = 60


class ProviderFailoverManager:
    """
    Manages multi-provider failover with health checks and load balancing.
    
    Features:
    - Automatic health monitoring
    - Circuit breaker pattern
    - Multiple load balancing strategies
    - Real-time provider selection
    - Graceful degradation
    """
    
    def __init__(
        self,
        providers: List[ProviderConfig],
        strategy: LoadBalancingStrategy = LoadBalancingStrategy.ADAPTIVE,
        health_check_interval: int = 60,
        enable_health_checks: bool = True
    ):
        """
        Initialize failover manager.
        
        Args:
            providers: List of provider configurations
            strategy: Load balancing strategy
            health_check_interval: Seconds between health checks
            enable_health_checks: Whether to run automatic health monitoring
        """
        self.providers = {p.name: p for p in providers}
        self.strategy = strategy
        self.health_check_interval = health_check_interval
        self.enable_health_checks = enable_health_checks
        
        # Provider metrics and state
        self.metrics: Dict[str, ProviderMetrics] = {
            name: ProviderMetrics() for name in self.providers
        }
        self.provider_status: Dict[str, ProviderStatus] = {
            name: ProviderStatus.UNKNOWN for name in self.providers
        }
        
        # Circuit breakers per provider
        self.circuit_breakers: Dict[str, Callable] = {}
        self._initialize_circuit_breakers()
        
        # Round-robin counter
        self.round_robin_index = 0
        
        # Health check task
        self.health_check_task: Optional[asyncio.Task] = None
        
        logger.info(f"Initialized ProviderFailoverManager with {len(providers)} providers")
    
    def _initialize_circuit_breakers(self):
        """Create circuit breakers for each provider"""
        for name, config in self.providers.items():
            @circuit(
                failure_threshold=config.circuit_breaker_threshold,
                recovery_timeout=config.circuit_breaker_timeout,
                expected_exception=Exception
            )
            async def make_request(url: str, **kwargs):
                async with httpx.AsyncClient(timeout=config.timeout) as client:
                    response = await client.request(method="POST", url=url, **kwargs)
                    response.raise_for_status()
                    return response
            
            self.circuit_breakers[name] = make_request
    
    async def start(self):
        """Start health monitoring"""
        if self.enable_health_checks:
            self.health_check_task = asyncio.create_task(self._health_check_loop())
            logger.info("Started provider health monitoring")
    
    async def stop(self):
        """Stop health monitoring"""
        if self.health_check_task:
            self.health_check_task.cancel()
            try:
                await self.health_check_task
            except asyncio.CancelledError:
                pass
            logger.info("Stopped provider health monitoring")
    
    async def _health_check_loop(self):
        """Continuous health monitoring loop"""
        while True:
            try:
                await self._check_all_providers()
                await asyncio.sleep(self.health_check_interval)
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Health check error: {e}")
                await asyncio.sleep(10)  # Brief pause before retry
    
    async def _check_all_providers(self):
        """Check health of all providers concurrently"""
        tasks = [
            self._check_provider_health(name)
            for name in self.providers
        ]
        await asyncio.gather(*tasks, return_exceptions=True)
    
    async def _check_provider_health(self, provider_name: str) -> bool:
        """
        Check individual provider health.
        
        Returns:
            True if healthy, False otherwise
        """
        config = self.providers[provider_name]
        metrics = self.metrics[provider_name]
        
        try:
            start_time = time.time()
            
            # Make health check request
            async with httpx.AsyncClient(timeout=httpx.Timeout(5.0)) as client:
                response = await client.get(
                    f"{config.base_url}{config.health_endpoint}",
                    headers={"Authorization": f"Bearer {config.api_key}"}
                )
                response.raise_for_status()
            
            # Update metrics
            metrics.latency_ms = (time.time() - start_time) * 1000
            metrics.last_check = datetime.now()
            metrics.consecutive_failures = 0
            
            # Update status
            if metrics.latency_ms < 1000:
                self.provider_status[provider_name] = ProviderStatus.HEALTHY
            elif metrics.latency_ms < 3000:
                self.provider_status[provider_name] = ProviderStatus.DEGRADED
            else:
                self.provider_status[provider_name] = ProviderStatus.UNHEALTHY
            
            return True
            
        except Exception as e:
            # Update failure metrics
            metrics.error_count += 1
            metrics.consecutive_failures += 1
            metrics.last_error = str(e)
            metrics.last_check = datetime.now()
            
            # Update status based on consecutive failures
            if metrics.consecutive_failures >= 3:
                self.provider_status[provider_name] = ProviderStatus.UNHEALTHY
            else:
                self.provider_status[provider_name] = ProviderStatus.DEGRADED
            
            logger.warning(f"Health check failed for {provider_name}: {e}")
            return False
    
    def select_provider(self, model: Optional[str] = None) -> Optional[str]:
        """
        Select best provider based on strategy and health.
        
        Args:
            model: Optional model requirement
            
        Returns:
            Provider name or None if all unhealthy
        """
        # Filter available providers
        available = self._get_available_providers(model)
        
        if not available:
            logger.error("No healthy providers available")
            return None
        
        # Select based on strategy
        if self.strategy == LoadBalancingStrategy.ROUND_ROBIN:
            return self._select_round_robin(available)
        elif self.strategy == LoadBalancingStrategy.WEIGHTED:
            return self._select_weighted(available)
        elif self.strategy == LoadBalancingStrategy.PRIORITY:
            return self._select_priority(available)
        elif self.strategy == LoadBalancingStrategy.LEAST_LATENCY:
            return self._select_least_latency(available)
        elif self.strategy == LoadBalancingStrategy.ADAPTIVE:
            return self._select_adaptive(available)
        else:
            return available[0]
    
    def _get_available_providers(self, model: Optional[str] = None) -> List[str]:
        """Get list of available providers"""
        available = []
        
        for name, config in self.providers.items():
            # Check health
            if self.provider_status[name] == ProviderStatus.UNHEALTHY:
                continue
            
            # Check model support
            if model and model not in config.models:
                continue
            
            available.append(name)
        
        return available
    
    def _select_round_robin(self, providers: List[str]) -> str:
        """Round-robin selection"""
        selected = providers[self.round_robin_index % len(providers)]
        self.round_robin_index += 1
        return selected
    
    def _select_weighted(self, providers: List[str]) -> str:
        """Weighted random selection"""
        import random
        
        weights = [self.providers[p].weight for p in providers]
        return random.choices(providers, weights=weights)[0]
    
    def _select_priority(self, providers: List[str]) -> str:
        """Priority-based selection"""
        return min(providers, key=lambda p: self.providers[p].priority)
    
    def _select_least_latency(self, providers: List[str]) -> str:
        """Select provider with lowest latency"""
        return min(providers, key=lambda p: self.metrics[p].latency_ms)
    
    def _select_adaptive(self, providers: List[str]) -> str:
        """Adaptive selection based on composite health score"""
        scores = {
            p: self.metrics[p].calculate_health_score()
            for p in providers
        }
        return max(scores, key=scores.get)
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=2, max=10),
        retry=retry_if_exception_type(httpx.HTTPError)
    )
    async def execute_with_failover(
        self,
        operation: str,
        payload: Dict[str, Any],
        model: Optional[str] = None,
        fallback: Optional[Callable] = None
    ) -> Dict[str, Any]:
        """
        Execute operation with automatic failover.
        
        Args:
            operation: API operation to execute
            payload: Request payload
            model: Optional model requirement
            fallback: Optional fallback function
            
        Returns:
            API response or fallback result
        """
        attempted_providers = []
        last_error = None
        
        # Try providers in order of selection
        for _ in range(len(self.providers)):
            provider_name = self.select_provider(model)
            
            if not provider_name or provider_name in attempted_providers:
                continue
            
            attempted_providers.append(provider_name)
            config = self.providers[provider_name]
            metrics = self.metrics[provider_name]
            
            try:
                # Track request
                start_time = time.time()
                metrics.request_count += 1
                
                # Execute with circuit breaker
                circuit_breaker = self.circuit_breakers[provider_name]
                response = await circuit_breaker(
                    url=f"{config.base_url}/{operation}",
                    json=payload,
                    headers={"Authorization": f"Bearer {config.api_key}"}
                )
                
                # Update success metrics
                elapsed_ms = (time.time() - start_time) * 1000
                metrics.latency_ms = (metrics.latency_ms * 0.9) + (elapsed_ms * 0.1)  # EMA
                metrics.success_rate = (
                    (metrics.success_rate * (metrics.request_count - 1) + 1) /
                    metrics.request_count
                )
                
                logger.info(f"Successfully executed {operation} with {provider_name}")
                return response.json()
                
            except Exception as e:
                # Update failure metrics
                metrics.error_count += 1
                metrics.success_rate = (
                    (metrics.success_rate * (metrics.request_count - 1)) /
                    metrics.request_count
                )
                metrics.last_error = str(e)
                last_error = e
                
                logger.warning(f"Provider {provider_name} failed: {e}")
                continue
        
        # All providers failed - use fallback if available
        if fallback:
            logger.warning(f"All providers failed for {operation}, using fallback")
            return await fallback(payload)
        
        # No fallback available
        raise Exception(
            f"All providers failed for {operation}. "
            f"Attempted: {attempted_providers}. "
            f"Last error: {last_error}"
        )
    
    def get_provider_stats(self) -> Dict[str, Any]:
        """Get current provider statistics"""
        stats = {}
        
        for name in self.providers:
            metrics = self.metrics[name]
            stats[name] = {
                "status": self.provider_status[name].value,
                "health_score": metrics.calculate_health_score(),
                "latency_ms": round(metrics.latency_ms, 2),
                "success_rate": round(metrics.success_rate, 3),
                "error_count": metrics.error_count,
                "request_count": metrics.request_count,
                "last_error": metrics.last_error,
                "last_check": metrics.last_check.isoformat() if metrics.last_check else None
            }
        
        return stats