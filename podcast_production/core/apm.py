#!/usr/bin/env python3
"""
Enhanced APM Integration with Langfuse
Extends existing Langfuse observability with Prometheus metrics, Redis caching, and DataDog
Version: 2.0.0 - September 2025 Production Standards
"""

import os
import time
import asyncio
import logging
from typing import Dict, Any, Optional, Callable, TypeVar
from functools import wraps
from datetime import datetime
from contextlib import asynccontextmanager

import httpx
from langfuse import Langfuse
from langfuse.decorators import observe, langfuse_context
from datadog import initialize as dd_initialize, statsd
from prometheus_client import Counter, Histogram, Gauge, generate_latest
import redis

logger = logging.getLogger(__name__)

T = TypeVar('T')

# Prometheus metrics definitions
AGENT_LATENCY = Histogram(
    'agent_execution_duration_seconds',
    'Agent execution duration in seconds',
    ['agent_name', 'operation']
)

AGENT_ERRORS = Counter(
    'agent_errors_total',
    'Total number of agent errors',
    ['agent_name', 'error_type']
)

AGENT_SUCCESS = Counter(
    'agent_success_total',
    'Total number of successful agent executions',
    ['agent_name']
)

TOKEN_USAGE = Counter(
    'token_usage_total',
    'Total token usage',
    ['provider', 'model', 'operation']
)

COST_TRACKING = Gauge(
    'episode_cost_dollars',
    'Episode production cost in dollars',
    ['episode_id', 'stage']
)

ACTIVE_AGENTS = Gauge(
    'active_agents',
    'Number of currently active agents',
    ['agent_type']
)

QUALITY_SCORES = Gauge(
    'quality_scores',
    'Quality evaluation scores',
    ['episode_id', 'evaluator', 'dimension']
)


class EnhancedAPMManager:
    """Enhanced APM management extending Langfuse with additional providers"""
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        self.config = config or {}
        self.langfuse = None
        self.redis_client = None
        self.metrics_cache = {}
        self._initialize()
    
    def _initialize(self):
        """Initialize APM providers with Langfuse as primary"""
        # Langfuse initialization (primary tracing)
        if all([
            os.getenv("LANGFUSE_PUBLIC_KEY"),
            os.getenv("LANGFUSE_SECRET_KEY"),
            os.getenv("LANGFUSE_HOST")
        ]):
            try:
                self.langfuse = Langfuse(
                    public_key=os.getenv("LANGFUSE_PUBLIC_KEY"),
                    secret_key=os.getenv("LANGFUSE_SECRET_KEY"),
                    host=os.getenv("LANGFUSE_HOST"),
                    flush_at=self.config.get("flush_at", 10),
                    flush_interval=self.config.get("flush_interval", 10),
                    max_retries=self.config.get("max_retries", 3),
                    timeout=self.config.get("timeout", 30)
                )
                logger.info("Langfuse APM enhanced successfully")
            except Exception as e:
                logger.warning(f"Langfuse initialization failed: {e}")
        
        # DataDog supplementary metrics
        if dd_api_key := os.getenv("DATADOG_API_KEY"):
            try:
                dd_initialize(
                    api_key=dd_api_key,
                    app_key=os.getenv("DATADOG_APP_KEY"),
                    statsd_host=os.getenv("DD_AGENT_HOST", "localhost"),
                    statsd_port=int(os.getenv("DD_DOGSTATSD_PORT", "8125"))
                )
                logger.info("DataDog supplementary metrics initialized")
            except Exception as e:
                logger.warning(f"DataDog initialization failed: {e}")
        
        # Redis for metrics caching and aggregation
        try:
            self.redis_client = redis.Redis(
                host=os.getenv("REDIS_HOST", "localhost"),
                port=int(os.getenv("REDIS_PORT", "6379")),
                decode_responses=True,
                socket_connect_timeout=5,
                socket_keepalive=True,
                socket_keepalive_options={
                    1: 1,  # TCP_KEEPIDLE
                    2: 1,  # TCP_KEEPINTVL
                    3: 5,  # TCP_KEEPCNT
                }
            )
            self.redis_client.ping()
            logger.info("Redis metrics cache initialized")
        except Exception as e:
            logger.warning(f"Redis initialization failed: {e}")
            self.redis_client = None
    
    @asynccontextmanager
    async def trace_agent(self, agent_name: str, metadata: Optional[Dict[str, Any]] = None):
        """Enhanced context manager for tracing agent execution with Langfuse"""
        start_time = time.time()
        trace_id = f"{agent_name}_{datetime.now().isoformat()}"
        
        # Increment active agents gauge
        ACTIVE_AGENTS.labels(agent_type=agent_name).inc()
        
        # Create Langfuse trace
        langfuse_trace = None
        if self.langfuse:
            langfuse_trace = self.langfuse.trace(
                name=agent_name,
                metadata={
                    "trace_id": trace_id,
                    "environment": os.getenv("ENVIRONMENT", "production"),
                    **(metadata or {})
                },
                tags=[agent_name, "production", "langgraph"]
            )
        
        # DataDog trace start
        statsd.increment(f"agent.{agent_name}.started")
        
        try:
            yield {
                "trace_id": trace_id,
                "agent_name": agent_name,
                "start_time": start_time,
                "langfuse_trace": langfuse_trace
            }
            
            # Success metrics
            duration = time.time() - start_time
            AGENT_LATENCY.labels(agent_name=agent_name, operation="complete").observe(duration)
            AGENT_SUCCESS.labels(agent_name=agent_name).inc()
            
            # DataDog metrics
            statsd.histogram(f"agent.{agent_name}.duration", duration)
            statsd.increment(f"agent.{agent_name}.success")
            
            # Langfuse update
            if langfuse_trace:
                langfuse_trace.update(
                    output={"duration": duration, "status": "success"},
                    level="INFO"
                )
                
                # Log performance score to Langfuse
                langfuse_trace.score(
                    name="performance",
                    value=1.0 if duration < 30 else 0.5,
                    comment=f"Execution completed in {duration:.2f}s"
                )
                
        except Exception as e:
            # Error metrics
            AGENT_ERRORS.labels(agent_name=agent_name, error_type=type(e).__name__).inc()
            statsd.increment(f"agent.{agent_name}.error")
            
            if langfuse_trace:
                langfuse_trace.update(
                    output={"error": str(e), "error_type": type(e).__name__},
                    level="ERROR"
                )
                
                # Log error score
                langfuse_trace.score(
                    name="success",
                    value=0.0,
                    comment=f"Failed with {type(e).__name__}"
                )
            raise
            
        finally:
            # Decrement active agents
            ACTIVE_AGENTS.labels(agent_type=agent_name).dec()
            
            # Flush Langfuse trace
            if self.langfuse:
                self.langfuse.flush()
    
    async def track_token_usage(self, provider: str, model: str, tokens: int, operation: str, cost: float = 0.0):
        """Track token usage with cost calculation"""
        TOKEN_USAGE.labels(provider=provider, model=model, operation=operation).inc(tokens)
        
        # DataDog tracking
        statsd.increment(f"tokens.{provider}.{model}", value=tokens)
        statsd.gauge(f"token_cost.{provider}.{model}", cost)
        
        # Langfuse generation tracking
        if self.langfuse:
            generation = self.langfuse.generation(
                name=f"{provider}_{operation}",
                model=model,
                usage={
                    "total_tokens": tokens,
                    "total_cost": cost
                },
                metadata={
                    "provider": provider,
                    "operation": operation
                }
            )
            generation.end()
        
        # Cache in Redis for cost aggregation
        if self.redis_client:
            key = f"tokens:{provider}:{model}:{datetime.now().strftime('%Y%m%d')}"
            self.redis_client.hincrby(key, operation, tokens)
            self.redis_client.hincrbyfloat(key, f"{operation}_cost", cost)
            self.redis_client.expire(key, 86400 * 7)  # 7 day retention
    
    async def track_cost(self, episode_id: str, stage: str, cost: float):
        """Track production costs with Langfuse integration"""
        COST_TRACKING.labels(episode_id=episode_id, stage=stage).set(cost)
        
        # DataDog tracking
        statsd.gauge(f"cost.{stage}", cost, tags=[f"episode:{episode_id}"])
        
        # Langfuse cost tracking
        if self.langfuse:
            self.langfuse.trace(
                name="cost_tracking",
                metadata={
                    "episode_id": episode_id,
                    "stage": stage,
                    "cost": cost
                }
            )
        
        # Cache cumulative cost in Redis
        if self.redis_client:
            key = f"cost:{episode_id}"
            self.redis_client.hincrbyfloat(key, stage, cost)
            total = sum(float(v) for v in self.redis_client.hgetall(key).values())
            self.redis_client.hset(key, "total", total)
            
            # Alert if over budget
            if total > 6.0:
                logger.warning(f"Episode {episode_id} over budget: ${total:.2f}")
                statsd.event(
                    title="Budget Alert",
                    text=f"Episode {episode_id} exceeded budget: ${total:.2f}",
                    alert_type="warning",
                    tags=[f"episode:{episode_id}"]
                )
    
    async def track_quality(self, episode_id: str, evaluator: str, scores: Dict[str, float]):
        """Track quality scores from evaluators"""
        for dimension, score in scores.items():
            QUALITY_SCORES.labels(
                episode_id=episode_id,
                evaluator=evaluator,
                dimension=dimension
            ).set(score)
            
            # Langfuse quality tracking
            if self.langfuse:
                self.langfuse.score(
                    name=f"{evaluator}_{dimension}",
                    value=score,
                    trace_id=episode_id,
                    comment=f"Quality evaluation by {evaluator}"
                )
        
        # Cache in Redis for analysis
        if self.redis_client:
            key = f"quality:{episode_id}:{evaluator}"
            for dimension, score in scores.items():
                self.redis_client.hset(key, dimension, score)
            self.redis_client.expire(key, 86400 * 30)  # 30 day retention
    
    async def get_metrics(self) -> Dict[str, Any]:
        """Get comprehensive metrics snapshot"""
        metrics = {
            "timestamp": datetime.now().isoformat(),
            "prometheus": generate_latest().decode('utf-8')
        }
        
        # Add Redis cached metrics
        if self.redis_client:
            try:
                # Get recent costs
                cost_keys = self.redis_client.keys("cost:*")
                costs = {}
                for key in cost_keys[:10]:  # Last 10 episodes
                    episode_id = key.split(":")[-1]
                    costs[episode_id] = self.redis_client.hgetall(key)
                metrics["recent_costs"] = costs
                
                # Get token usage
                token_keys = self.redis_client.keys("tokens:*")
                tokens = {}
                for key in token_keys[:5]:  # Recent 5 days
                    tokens[key] = self.redis_client.hgetall(key)
                metrics["token_usage"] = tokens
                
                # Get quality scores
                quality_keys = self.redis_client.keys("quality:*")
                quality = {}
                for key in quality_keys[:10]:  # Last 10 episodes
                    quality[key] = self.redis_client.hgetall(key)
                metrics["quality_scores"] = quality
                
            except Exception as e:
                logger.error(f"Failed to get Redis metrics: {e}")
        
        # Add Langfuse metrics if available
        if self.langfuse:
            try:
                # This would typically query Langfuse API for aggregated metrics
                metrics["langfuse_status"] = "connected"
            except Exception as e:
                metrics["langfuse_status"] = f"error: {e}"
        
        return metrics
    
    def shutdown(self):
        """Graceful shutdown of APM connections"""
        if self.langfuse:
            self.langfuse.flush()
            self.langfuse.shutdown()
        
        if self.redis_client:
            self.redis_client.close()
        
        logger.info("APM manager shutdown complete")


# Global APM instance
apm = EnhancedAPMManager()


def trace_langfuse_async(name: Optional[str] = None, **kwargs):
    """Decorator for tracing async functions with Langfuse + enhanced metrics"""
    def decorator(func: Callable) -> Callable:
        agent_name = name or func.__name__
        
        @wraps(func)
        @observe(name=agent_name, as_type="generation", **kwargs)  # Langfuse decorator
        async def wrapper(*args, **func_kwargs):
            async with apm.trace_agent(agent_name, metadata=func_kwargs):
                return await func(*args, **func_kwargs)
        
        return wrapper
    return decorator


def trace_langfuse_sync(name: Optional[str] = None, **kwargs):
    """Decorator for tracing sync functions with Langfuse + enhanced metrics"""
    def decorator(func: Callable) -> Callable:
        agent_name = name or func.__name__
        
        @wraps(func)
        @observe(name=agent_name, as_type="generation", **kwargs)  # Langfuse decorator
        def wrapper(*args, **func_kwargs):
            start_time = time.time()
            
            # Metrics tracking
            ACTIVE_AGENTS.labels(agent_type=agent_name).inc()
            statsd.increment(f"agent.{agent_name}.started")
            
            try:
                result = func(*args, **func_kwargs)
                
                # Success metrics
                duration = time.time() - start_time
                AGENT_LATENCY.labels(agent_name=agent_name, operation="complete").observe(duration)
                AGENT_SUCCESS.labels(agent_name=agent_name).inc()
                statsd.histogram(f"agent.{agent_name}.duration", duration)
                
                # Add to Langfuse context
                langfuse_context.score(
                    name="performance",
                    value=1.0 if duration < 30 else 0.5
                )
                
                return result
                
            except Exception as e:
                AGENT_ERRORS.labels(agent_name=agent_name, error_type=type(e).__name__).inc()
                statsd.increment(f"agent.{agent_name}.error")
                
                # Log error to Langfuse
                langfuse_context.score(
                    name="success",
                    value=0.0
                )
                raise
                
            finally:
                ACTIVE_AGENTS.labels(agent_type=agent_name).dec()
        
        return wrapper
    return decorator


class MetricsEndpoint:
    """FastAPI/Flask compatible metrics endpoint"""
    
    @staticmethod
    async def get_prometheus_metrics():
        """Return Prometheus metrics in text format"""
        return generate_latest()
    
    @staticmethod
    async def get_json_metrics():
        """Return comprehensive metrics as JSON"""
        return await apm.get_metrics()
    
    @staticmethod
    async def get_health():
        """Health check endpoint"""
        health = {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "services": {
                "langfuse": "connected" if apm.langfuse else "disconnected",
                "redis": "connected" if apm.redis_client else "disconnected",
                "datadog": "connected" if statsd else "disconnected"
            }
        }
        return health


# Aliases for backward compatibility
trace_async = trace_langfuse_async
trace_sync = trace_langfuse_sync


# Export main components
__all__ = [
    'apm',
    'EnhancedAPMManager',
    'trace_langfuse_async',
    'trace_langfuse_sync',
    'trace_async',  # Backward compatibility
    'trace_sync',   # Backward compatibility
    'MetricsEndpoint',
    'AGENT_LATENCY',
    'AGENT_ERRORS',
    'AGENT_SUCCESS',
    'TOKEN_USAGE',
    'COST_TRACKING',
    'QUALITY_SCORES',
    'ACTIVE_AGENTS'
]