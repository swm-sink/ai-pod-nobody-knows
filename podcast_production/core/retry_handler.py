"""
Production-Grade Retry Handler with Exponential Backoff - August 2025
Implements comprehensive retry logic with circuit breakers and failure recovery.
"""

import asyncio
import logging
import time
import random
from datetime import datetime, timedelta
from typing import Callable, Any, Optional, Dict, List, Union
from dataclasses import dataclass, field
from enum import Enum
import functools

logger = logging.getLogger(__name__)


class RetryStrategy(Enum):
    """Retry strategies for different failure types."""
    EXPONENTIAL = "exponential"
    LINEAR = "linear"
    FIXED = "fixed"
    IMMEDIATE = "immediate"


class CircuitBreakerState(Enum):
    """Circuit breaker states."""
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Failures exceeded, blocking calls
    HALF_OPEN = "half_open"  # Testing recovery


@dataclass
class RetryConfig:
    """Configuration for retry behavior."""
    max_attempts: int = 3
    base_delay: float = 1.0
    max_delay: float = 60.0
    strategy: RetryStrategy = RetryStrategy.EXPONENTIAL
    backoff_multiplier: float = 2.0
    jitter: bool = True
    jitter_range: float = 0.1
    
    # Circuit breaker settings
    failure_threshold: int = 5
    recovery_timeout: float = 30.0
    success_threshold: int = 2  # Consecutive successes needed to close circuit
    
    # Retry conditions
    retry_on_exceptions: List[type] = field(default_factory=lambda: [Exception])
    retry_on_status_codes: List[int] = field(default_factory=lambda: [429, 500, 502, 503, 504])
    
    # Logging
    log_retries: bool = True
    log_failures: bool = True


@dataclass
class AttemptResult:
    """Result of a single attempt."""
    attempt_number: int
    success: bool
    exception: Optional[Exception] = None
    duration: float = 0.0
    timestamp: datetime = field(default_factory=datetime.now)
    response_code: Optional[int] = None


@dataclass
class CircuitBreakerStats:
    """Circuit breaker statistics."""
    state: CircuitBreakerState = CircuitBreakerState.CLOSED
    failure_count: int = 0
    success_count: int = 0
    last_failure_time: Optional[datetime] = None
    last_success_time: Optional[datetime] = None
    total_calls: int = 0
    total_failures: int = 0


class RetryHandler:
    """
    Production-grade retry handler with exponential backoff and circuit breaker.
    
    Features:
    - Multiple retry strategies
    - Circuit breaker pattern
    - Comprehensive failure tracking
    - Configurable jitter and delays
    - August 2025 best practices
    """
    
    def __init__(self, config: RetryConfig = None, name: str = "default"):
        """
        Initialize retry handler.
        
        Args:
            config: Retry configuration
            name: Handler name for logging and metrics
        """
        self.config = config or RetryConfig()
        self.name = name
        self.stats = CircuitBreakerStats()
        self.attempt_history: List[AttemptResult] = []
        
        # Rate limiting
        self.last_attempt_time: Optional[float] = None
        self.min_interval = 0.1  # Minimum time between attempts
        
        logger.info(f"🔄 RetryHandler '{name}' initialized with {self.config.strategy.value} strategy")
    
    async def execute_with_retry(
        self, 
        func: Callable[..., Any], 
        *args, 
        **kwargs
    ) -> Any:
        """
        Execute function with retry logic and circuit breaker.
        
        Args:
            func: Function to execute (can be sync or async)
            *args: Positional arguments for function
            **kwargs: Keyword arguments for function
            
        Returns:
            Function result
            
        Raises:
            Exception: After all retries exhausted or circuit breaker open
        """
        # Check circuit breaker state
        if not self._should_attempt():
            raise RuntimeError(f"Circuit breaker OPEN for {self.name} - calls blocked")
        
        last_exception = None
        
        for attempt in range(1, self.config.max_attempts + 1):
            # Rate limiting
            await self._respect_rate_limit()
            
            # Execute attempt
            start_time = time.time()
            try:
                # Handle both sync and async functions
                if asyncio.iscoroutinefunction(func):
                    result = await func(*args, **kwargs)
                else:
                    result = func(*args, **kwargs)
                
                # Success - record and return
                duration = time.time() - start_time
                self._record_success(attempt, duration)
                
                return result
                
            except Exception as e:
                duration = time.time() - start_time
                last_exception = e
                
                # Check if we should retry this exception
                if not self._should_retry_exception(e):
                    self._record_failure(attempt, e, duration, final=True)
                    raise e
                
                # Record failure
                self._record_failure(attempt, e, duration, final=(attempt == self.config.max_attempts))
                
                # If this was the last attempt, raise
                if attempt == self.config.max_attempts:
                    break
                
                # Calculate delay and wait
                delay = self._calculate_delay(attempt)
                if self.config.log_retries:
                    logger.warning(
                        f"🔄 {self.name} attempt {attempt}/{self.config.max_attempts} failed: {e}. "
                        f"Retrying in {delay:.2f}s"
                    )
                
                await asyncio.sleep(delay)
        
        # All attempts exhausted
        self._update_circuit_breaker_on_failure()
        if self.config.log_failures:
            logger.error(f"❌ {self.name} failed after {self.config.max_attempts} attempts")
        
        raise last_exception or RuntimeError("All retry attempts exhausted")
    
    def _should_attempt(self) -> bool:
        """Check if we should attempt based on circuit breaker state."""
        self.stats.total_calls += 1
        
        if self.stats.state == CircuitBreakerState.OPEN:
            # Check if recovery timeout has passed
            if (
                self.stats.last_failure_time and 
                datetime.now() - self.stats.last_failure_time > timedelta(seconds=self.config.recovery_timeout)
            ):
                self.stats.state = CircuitBreakerState.HALF_OPEN
                self.stats.success_count = 0  # Reset success count for half-open test
                logger.info(f"🔄 Circuit breaker {self.name} entering HALF_OPEN state")
                return True
            return False
        
        return True
    
    def _should_retry_exception(self, exception: Exception) -> bool:
        """Check if exception should trigger a retry."""
        # Check exception types
        for exc_type in self.config.retry_on_exceptions:
            if isinstance(exception, exc_type):
                return True
        
        # Check HTTP status codes if applicable
        if hasattr(exception, 'status_code'):
            return exception.status_code in self.config.retry_on_status_codes
        
        if hasattr(exception, 'response') and hasattr(exception.response, 'status_code'):
            return exception.response.status_code in self.config.retry_on_status_codes
        
        return False
    
    def _calculate_delay(self, attempt: int) -> float:
        """Calculate delay before next attempt."""
        if self.config.strategy == RetryStrategy.IMMEDIATE:
            delay = 0.0
        elif self.config.strategy == RetryStrategy.FIXED:
            delay = self.config.base_delay
        elif self.config.strategy == RetryStrategy.LINEAR:
            delay = self.config.base_delay * attempt
        elif self.config.strategy == RetryStrategy.EXPONENTIAL:
            delay = self.config.base_delay * (self.config.backoff_multiplier ** (attempt - 1))
        else:
            delay = self.config.base_delay
        
        # Apply maximum delay
        delay = min(delay, self.config.max_delay)
        
        # Add jitter if enabled
        if self.config.jitter:
            jitter_amount = delay * self.config.jitter_range
            jitter = random.uniform(-jitter_amount, jitter_amount)
            delay = max(0.0, delay + jitter)
        
        return delay
    
    async def _respect_rate_limit(self):
        """Ensure minimum interval between attempts."""
        if self.last_attempt_time:
            elapsed = time.time() - self.last_attempt_time
            if elapsed < self.min_interval:
                await asyncio.sleep(self.min_interval - elapsed)
        
        self.last_attempt_time = time.time()
    
    def _record_success(self, attempt: int, duration: float):
        """Record successful attempt."""
        result = AttemptResult(
            attempt_number=attempt,
            success=True,
            duration=duration
        )
        self.attempt_history.append(result)
        
        # Update circuit breaker
        self.stats.success_count += 1
        self.stats.last_success_time = datetime.now()
        
        if self.stats.state == CircuitBreakerState.HALF_OPEN:
            if self.stats.success_count >= self.config.success_threshold:
                self.stats.state = CircuitBreakerState.CLOSED
                self.stats.failure_count = 0
                logger.info(f"✅ Circuit breaker {self.name} CLOSED - recovered")
        elif self.stats.state == CircuitBreakerState.CLOSED:
            # Reset failure count on success
            self.stats.failure_count = 0
        
        if attempt > 1 and self.config.log_retries:
            logger.info(f"✅ {self.name} succeeded on attempt {attempt} after {duration:.2f}s")
    
    def _record_failure(self, attempt: int, exception: Exception, duration: float, final: bool):
        """Record failed attempt."""
        result = AttemptResult(
            attempt_number=attempt,
            success=False,
            exception=exception,
            duration=duration
        )
        self.attempt_history.append(result)
        
        self.stats.total_failures += 1
        
        if final:
            self.stats.failure_count += 1
            self.stats.last_failure_time = datetime.now()
    
    def _update_circuit_breaker_on_failure(self):
        """Update circuit breaker state after final failure."""
        if self.stats.failure_count >= self.config.failure_threshold:
            if self.stats.state != CircuitBreakerState.OPEN:
                self.stats.state = CircuitBreakerState.OPEN
                logger.error(f"🚨 Circuit breaker {self.name} OPEN - too many failures")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get comprehensive statistics."""
        recent_attempts = self.attempt_history[-10:]  # Last 10 attempts
        
        return {
            "name": self.name,
            "circuit_breaker": {
                "state": self.stats.state.value,
                "failure_count": self.stats.failure_count,
                "success_count": self.stats.success_count,
                "total_calls": self.stats.total_calls,
                "total_failures": self.stats.total_failures,
                "failure_rate": self.stats.total_failures / max(1, self.stats.total_calls),
                "last_failure": self.stats.last_failure_time.isoformat() if self.stats.last_failure_time else None,
                "last_success": self.stats.last_success_time.isoformat() if self.stats.last_success_time else None
            },
            "config": {
                "max_attempts": self.config.max_attempts,
                "strategy": self.config.strategy.value,
                "base_delay": self.config.base_delay,
                "max_delay": self.config.max_delay,
                "failure_threshold": self.config.failure_threshold,
                "recovery_timeout": self.config.recovery_timeout
            },
            "recent_attempts": [
                {
                    "attempt": r.attempt_number,
                    "success": r.success,
                    "duration": r.duration,
                    "timestamp": r.timestamp.isoformat(),
                    "error": str(r.exception) if r.exception else None
                }
                for r in recent_attempts
            ]
        }
    
    def reset(self):
        """Reset handler state (for testing or recovery)."""
        self.stats = CircuitBreakerStats()
        self.attempt_history.clear()
        self.last_attempt_time = None
        logger.info(f"🔄 RetryHandler {self.name} reset")


def with_retry(config: RetryConfig = None, name: str = None):
    """
    Decorator for adding retry logic to functions.
    
    Args:
        config: Retry configuration
        name: Handler name (defaults to function name)
        
    Returns:
        Decorated function with retry logic
    """
    def decorator(func):
        handler_name = name or func.__name__
        handler = RetryHandler(config, handler_name)
        
        @functools.wraps(func)
        async def async_wrapper(*args, **kwargs):
            return await handler.execute_with_retry(func, *args, **kwargs)
        
        @functools.wraps(func)
        def sync_wrapper(*args, **kwargs):
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            try:
                return loop.run_until_complete(handler.execute_with_retry(func, *args, **kwargs))
            finally:
                loop.close()
        
        # Return appropriate wrapper based on function type
        if asyncio.iscoroutinefunction(func):
            async_wrapper._retry_handler = handler
            return async_wrapper
        else:
            sync_wrapper._retry_handler = handler
            return sync_wrapper
    
    return decorator


# Common retry configurations for different use cases
API_RETRY_CONFIG = RetryConfig(
    max_attempts=3,
    base_delay=1.0,
    max_delay=30.0,
    strategy=RetryStrategy.EXPONENTIAL,
    backoff_multiplier=2.0,
    failure_threshold=5,
    recovery_timeout=60.0
)

DATABASE_RETRY_CONFIG = RetryConfig(
    max_attempts=5,
    base_delay=0.5,
    max_delay=10.0,
    strategy=RetryStrategy.EXPONENTIAL,
    backoff_multiplier=1.5,
    failure_threshold=3,
    recovery_timeout=30.0
)

NETWORK_RETRY_CONFIG = RetryConfig(
    max_attempts=4,
    base_delay=2.0,
    max_delay=60.0,
    strategy=RetryStrategy.EXPONENTIAL,
    backoff_multiplier=2.5,
    failure_threshold=8,
    recovery_timeout=120.0
)


# Global retry handlers for common use cases
_global_handlers: Dict[str, RetryHandler] = {}


def get_retry_handler(name: str, config: RetryConfig = None) -> RetryHandler:
    """Get or create a global retry handler."""
    if name not in _global_handlers:
        _global_handlers[name] = RetryHandler(config or API_RETRY_CONFIG, name)
    return _global_handlers[name]


async def execute_with_api_retry(func: Callable[..., Any], *args, **kwargs) -> Any:
    """Execute function with standard API retry logic."""
    handler = get_retry_handler("api_calls", API_RETRY_CONFIG)
    return await handler.execute_with_retry(func, *args, **kwargs)


async def execute_with_database_retry(func: Callable[..., Any], *args, **kwargs) -> Any:
    """Execute function with database retry logic."""
    handler = get_retry_handler("database", DATABASE_RETRY_CONFIG)
    return await handler.execute_with_retry(func, *args, **kwargs)


def get_all_retry_stats() -> Dict[str, Any]:
    """Get statistics for all global retry handlers."""
    return {name: handler.get_stats() for name, handler in _global_handlers.items()}