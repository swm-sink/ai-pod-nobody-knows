#!/usr/bin/env python3
"""
Circuit Breaker Pattern Implementation
Provides resilience and error boundaries for all agents
Version: 1.0.0 - September 2025 Production Standards
"""

import asyncio
import time
import logging
from typing import Callable, Optional, Any, Dict, List, Type, Union
from dataclasses import dataclass, field
from enum import Enum
from functools import wraps
from collections import deque
from datetime import datetime, timedelta
from contextlib import asynccontextmanager

logger = logging.getLogger(__name__)


class CircuitState(Enum):
    """Circuit breaker states"""
    CLOSED = "closed"  # Normal operation
    OPEN = "open"  # Failures exceeded, blocking calls
    HALF_OPEN = "half_open"  # Testing if service recovered


@dataclass
class CircuitBreakerConfig:
    """Configuration for circuit breaker"""
    name: str
    failure_threshold: int = 5  # Failures before opening
    success_threshold: int = 3  # Successes in half-open before closing
    timeout: float = 60.0  # Seconds before trying half-open
    expected_exception: tuple = (Exception,)  # Exceptions to catch
    error_rate_threshold: float = 0.5  # Error rate to trigger open
    sliding_window_size: int = 20  # Size of sliding window for error rate
    fallback_function: Optional[Callable] = None  # Fallback when open
    on_open: Optional[Callable] = None  # Callback when opening
    on_close: Optional[Callable] = None  # Callback when closing


@dataclass
class CircuitBreakerMetrics:
    """Metrics for circuit breaker monitoring"""
    total_calls: int = 0
    successful_calls: int = 0
    failed_calls: int = 0
    calls_rejected: int = 0
    last_failure_time: Optional[datetime] = None
    last_success_time: Optional[datetime] = None
    state_changes: List[Dict[str, Any]] = field(default_factory=list)
    response_times: deque = field(default_factory=lambda: deque(maxlen=100))


class CircuitBreaker:
    """
    Circuit breaker implementation for fault tolerance
    
    Prevents cascading failures by temporarily blocking calls to failing services
    """
    
    def __init__(self, config: CircuitBreakerConfig):
        self.config = config
        self.state = CircuitState.CLOSED
        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time = None
        self.last_state_change = datetime.now()
        self.call_history = deque(maxlen=config.sliding_window_size)
        self.metrics = CircuitBreakerMetrics()
        self._lock = asyncio.Lock()
    
    async def call(self, func: Callable, *args, **kwargs) -> Any:
        """
        Execute function with circuit breaker protection
        
        Args:
            func: Async function to execute
            *args: Function arguments
            **kwargs: Function keyword arguments
            
        Returns:
            Function result or fallback result if circuit is open
            
        Raises:
            Exception if circuit is open and no fallback provided
        """
        async with self._lock:
            # Check if we should transition from open to half-open
            if self.state == CircuitState.OPEN:
                if self._should_attempt_reset():
                    self.state = CircuitState.HALF_OPEN
                    self._log_state_change("OPEN", "HALF_OPEN", "Timeout expired")
                else:
                    # Circuit is open, use fallback or raise
                    return await self._handle_open_circuit(func, args, kwargs)
        
        # Try to execute the function
        start_time = time.time()
        try:
            if asyncio.iscoroutinefunction(func):
                result = await func(*args, **kwargs)
            else:
                result = func(*args, **kwargs)
            
            # Record success
            await self._on_success()
            
            # Track metrics
            response_time = time.time() - start_time
            self.metrics.response_times.append(response_time)
            
            return result
            
        except self.config.expected_exception as e:
            # Record failure
            await self._on_failure(e)
            
            # If circuit opened, use fallback
            if self.state == CircuitState.OPEN:
                return await self._handle_open_circuit(func, args, kwargs)
            
            raise
    
    async def _on_success(self):
        """Handle successful call"""
        async with self._lock:
            self.metrics.total_calls += 1
            self.metrics.successful_calls += 1
            self.metrics.last_success_time = datetime.now()
            self.call_history.append(True)
            
            if self.state == CircuitState.HALF_OPEN:
                self.success_count += 1
                if self.success_count >= self.config.success_threshold:
                    # Close the circuit
                    self.state = CircuitState.CLOSED
                    self.failure_count = 0
                    self.success_count = 0
                    self._log_state_change("HALF_OPEN", "CLOSED", "Success threshold reached")
                    
                    if self.config.on_close:
                        await self._call_callback(self.config.on_close)
            
            elif self.state == CircuitState.CLOSED:
                # Reset failure count on success in closed state
                self.failure_count = 0
    
    async def _on_failure(self, exception: Exception):
        """Handle failed call"""
        async with self._lock:
            self.metrics.total_calls += 1
            self.metrics.failed_calls += 1
            self.metrics.last_failure_time = datetime.now()
            self.last_failure_time = time.time()
            self.call_history.append(False)
            
            self.failure_count += 1
            
            # Check if we should open the circuit
            if self.state == CircuitState.CLOSED:
                if self._should_open():
                    self.state = CircuitState.OPEN
                    self._log_state_change("CLOSED", "OPEN", f"Failure threshold reached: {exception}")
                    
                    if self.config.on_open:
                        await self._call_callback(self.config.on_open, exception)
            
            elif self.state == CircuitState.HALF_OPEN:
                # Single failure in half-open reopens circuit
                self.state = CircuitState.OPEN
                self.success_count = 0
                self._log_state_change("HALF_OPEN", "OPEN", f"Failed in half-open: {exception}")
                
                if self.config.on_open:
                    await self._call_callback(self.config.on_open, exception)
    
    def _should_open(self) -> bool:
        """Determine if circuit should open based on failures and error rate"""
        # Check absolute failure threshold
        if self.failure_count >= self.config.failure_threshold:
            return True
        
        # Check error rate in sliding window
        if len(self.call_history) >= self.config.sliding_window_size:
            error_rate = self.call_history.count(False) / len(self.call_history)
            if error_rate >= self.config.error_rate_threshold:
                return True
        
        return False
    
    def _should_attempt_reset(self) -> bool:
        """Check if enough time has passed to attempt reset"""
        if not self.last_failure_time:
            return True
        
        return time.time() - self.last_failure_time >= self.config.timeout
    
    async def _handle_open_circuit(self, func: Callable, args: tuple, kwargs: dict) -> Any:
        """Handle call when circuit is open"""
        self.metrics.calls_rejected += 1
        
        if self.config.fallback_function:
            logger.info(f"Circuit {self.config.name} is OPEN - using fallback")
            if asyncio.iscoroutinefunction(self.config.fallback_function):
                return await self.config.fallback_function(*args, **kwargs)
            else:
                return self.config.fallback_function(*args, **kwargs)
        
        raise CircuitBreakerOpenException(
            f"Circuit breaker '{self.config.name}' is OPEN - service unavailable"
        )
    
    def _log_state_change(self, from_state: str, to_state: str, reason: str):
        """Log circuit state change"""
        logger.info(f"Circuit {self.config.name}: {from_state} -> {to_state} ({reason})")
        
        self.metrics.state_changes.append({
            "timestamp": datetime.now().isoformat(),
            "from": from_state,
            "to": to_state,
            "reason": reason
        })
        
        self.last_state_change = datetime.now()
    
    async def _call_callback(self, callback: Callable, *args):
        """Call callback function safely"""
        try:
            if asyncio.iscoroutinefunction(callback):
                await callback(*args)
            else:
                callback(*args)
        except Exception as e:
            logger.error(f"Error in circuit breaker callback: {e}")
    
    def get_state(self) -> Dict[str, Any]:
        """Get current circuit breaker state and metrics"""
        return {
            "name": self.config.name,
            "state": self.state.value,
            "failure_count": self.failure_count,
            "success_count": self.success_count,
            "metrics": {
                "total_calls": self.metrics.total_calls,
                "successful_calls": self.metrics.successful_calls,
                "failed_calls": self.metrics.failed_calls,
                "calls_rejected": self.metrics.calls_rejected,
                "error_rate": (
                    self.metrics.failed_calls / self.metrics.total_calls
                    if self.metrics.total_calls > 0 else 0
                ),
                "avg_response_time": (
                    sum(self.metrics.response_times) / len(self.metrics.response_times)
                    if self.metrics.response_times else 0
                )
            },
            "last_state_change": self.last_state_change.isoformat()
        }
    
    def reset(self):
        """Manually reset circuit breaker to closed state"""
        self.state = CircuitState.CLOSED
        self.failure_count = 0
        self.success_count = 0
        self.call_history.clear()
        self._log_state_change(self.state.value, "CLOSED", "Manual reset")


class CircuitBreakerOpenException(Exception):
    """Exception raised when circuit breaker is open"""
    pass


class ErrorBoundary:
    """
    Error boundary for graceful degradation
    
    Provides structured error handling with fallbacks and recovery
    """
    
    def __init__(self, 
                 name: str,
                 fallback_result: Any = None,
                 max_retries: int = 3,
                 retry_delay: float = 1.0,
                 log_errors: bool = True):
        self.name = name
        self.fallback_result = fallback_result
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self.log_errors = log_errors
        self.error_count = 0
        self.last_error = None
    
    @asynccontextmanager
    async def guard(self):
        """Context manager for error boundary protection"""
        try:
            yield self
        except Exception as e:
            self.error_count += 1
            self.last_error = e
            
            if self.log_errors:
                logger.error(f"Error boundary {self.name} caught: {e}")
            
            # Return fallback result instead of raising
            if self.fallback_result is not None:
                return self.fallback_result
            
            raise
    
    async def retry_with_boundary(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with retry logic and error boundary"""
        last_exception = None
        
        for attempt in range(self.max_retries):
            try:
                if asyncio.iscoroutinefunction(func):
                    return await func(*args, **kwargs)
                else:
                    return func(*args, **kwargs)
            
            except Exception as e:
                last_exception = e
                self.error_count += 1
                
                if self.log_errors:
                    logger.warning(
                        f"Error boundary {self.name} - Attempt {attempt + 1}/{self.max_retries}: {e}"
                    )
                
                if attempt < self.max_retries - 1:
                    await asyncio.sleep(self.retry_delay * (attempt + 1))
        
        # All retries failed
        if self.fallback_result is not None:
            logger.info(f"Error boundary {self.name} - Using fallback after {self.max_retries} failures")
            return self.fallback_result
        
        raise last_exception


def with_circuit_breaker(config: CircuitBreakerConfig):
    """Decorator to add circuit breaker to a function"""
    circuit_breaker = CircuitBreaker(config)
    
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def async_wrapper(*args, **kwargs):
            return await circuit_breaker.call(func, *args, **kwargs)
        
        @wraps(func)
        def sync_wrapper(*args, **kwargs):
            # For sync functions, run in event loop
            loop = asyncio.get_event_loop()
            return loop.run_until_complete(
                circuit_breaker.call(func, *args, **kwargs)
            )
        
        if asyncio.iscoroutinefunction(func):
            return async_wrapper
        else:
            return sync_wrapper
    
    return decorator


def with_error_boundary(name: str, 
                       fallback: Any = None,
                       max_retries: int = 3):
    """Decorator to add error boundary to a function"""
    boundary = ErrorBoundary(name, fallback, max_retries)
    
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def async_wrapper(*args, **kwargs):
            return await boundary.retry_with_boundary(func, *args, **kwargs)
        
        @wraps(func)
        def sync_wrapper(*args, **kwargs):
            # For sync functions, adapt to async
            async def async_func(*a, **kw):
                return func(*a, **kw)
            
            loop = asyncio.get_event_loop()
            return loop.run_until_complete(
                boundary.retry_with_boundary(async_func, *args, **kwargs)
            )
        
        if asyncio.iscoroutinefunction(func):
            return async_wrapper
        else:
            return sync_wrapper
    
    return decorator


# Global circuit breaker registry
circuit_breakers: Dict[str, CircuitBreaker] = {}


def get_or_create_circuit_breaker(name: str, config: Optional[CircuitBreakerConfig] = None) -> CircuitBreaker:
    """Get existing circuit breaker or create new one"""
    if name not in circuit_breakers:
        if not config:
            config = CircuitBreakerConfig(name=name)
        circuit_breakers[name] = CircuitBreaker(config)
    
    return circuit_breakers[name]


def get_all_circuit_states() -> Dict[str, Dict[str, Any]]:
    """Get state of all circuit breakers"""
    return {name: cb.get_state() for name, cb in circuit_breakers.items()}


# Export main components
__all__ = [
    'CircuitBreaker',
    'CircuitBreakerConfig',
    'CircuitState',
    'CircuitBreakerOpenException',
    'ErrorBoundary',
    'with_circuit_breaker',
    'with_error_boundary',
    'get_or_create_circuit_breaker',
    'get_all_circuit_states'
]