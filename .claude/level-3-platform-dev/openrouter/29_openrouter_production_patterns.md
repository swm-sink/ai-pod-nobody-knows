# OpenRouter Production Patterns

## Production-Ready Implementation Patterns

This guide provides battle-tested patterns for implementing OpenRouter in a production podcast system, focusing on reliability, scalability, and maintainability.

## Core Production Architecture

### System Design
```python
class PodcastProductionSystem:
    """Main production system using OpenRouter"""
    
    def __init__(self):
        self.router = OpenRouterClient()
        self.monitor = ProductionMonitor()
        self.cache = ResponseCache()
        self.budget = BudgetManager()
        
    def produce_episode(self, topic):
        """Complete episode production pipeline"""
        
        try:
            # Phase 1: Research
            research = self.research_phase(topic)
            
            # Phase 2: Script Generation
            script = self.script_phase(research)
            
            # Phase 3: Quality Assurance
            validated = self.quality_phase(script)
            
            # Phase 4: Finalization
            episode = self.finalize_episode(validated)
            
            return episode
            
        except Exception as e:
            self.monitor.log_error(e)
            return self.handle_production_failure(e)
```

## Reliability Patterns

### 1. Circuit Breaker Pattern
```python
class CircuitBreaker:
    """Prevent cascading failures"""
    
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.last_failure_time = None
        self.state = "closed"  # closed, open, half-open
    
    def call(self, func, *args, **kwargs):
        """Execute function with circuit breaker protection"""
        
        if self.state == "open":
            if self.should_attempt_reset():
                self.state = "half-open"
            else:
                raise CircuitOpenException("Circuit breaker is open")
        
        try:
            result = func(*args, **kwargs)
            self.on_success()
            return result
        except Exception as e:
            self.on_failure()
            raise e
    
    def on_success(self):
        """Reset on successful call"""
        self.failure_count = 0
        self.state = "closed"
    
    def on_failure(self):
        """Track failures and open circuit if needed"""
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = "open"
```

### 2. Retry with Exponential Backoff
```python
class RetryManager:
    """Intelligent retry logic"""
    
    def __init__(self, max_retries=3, base_delay=1.0):
        self.max_retries = max_retries
        self.base_delay = base_delay
    
    async def execute_with_retry(self, func, *args, **kwargs):
        """Execute with exponential backoff retry"""
        
        for attempt in range(self.max_retries):
            try:
                return await func(*args, **kwargs)
            except RateLimitException as e:
                delay = self.base_delay * (2 ** attempt)
                await asyncio.sleep(delay)
            except ModelUnavailableException as e:
                # Try different model
                kwargs['model'] = self.get_fallback_model(kwargs.get('model'))
            except Exception as e:
                if attempt == self.max_retries - 1:
                    raise
                await asyncio.sleep(self.base_delay)
```

### 3. Graceful Degradation
```python
class GracefulDegradation:
    """Maintain service with reduced functionality"""
    
    def generate_with_degradation(self, prompt, preferred_model):
        """Attempt generation with fallback options"""
        
        try:
            # Try preferred model
            return self.generate(prompt, preferred_model)
        except Exception:
            try:
                # Try cheaper alternative
                return self.generate(prompt, self.get_budget_model())
            except Exception:
                try:
                    # Try cached similar response
                    return self.get_cached_similar(prompt)
                except Exception:
                    # Return template response
                    return self.get_template_response(prompt)
```

## Scalability Patterns

### 1. Connection Pooling
```python
class ConnectionPool:
    """Manage OpenRouter connections efficiently"""
    
    def __init__(self, pool_size=10):
        self.pool = []
        self.pool_size = pool_size
        self.available = threading.Semaphore(pool_size)
        
        # Initialize pool
        for _ in range(pool_size):
            self.pool.append(self.create_client())
    
    def create_client(self):
        """Create new OpenRouter client"""
        return OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=os.getenv("OPENROUTER_API_KEY")
        )
    
    def get_client(self):
        """Get available client from pool"""
        self.available.acquire()
        return self.pool.pop()
    
    def return_client(self, client):
        """Return client to pool"""
        self.pool.append(client)
        self.available.release()
```

### 2. Async Batch Processing
```python
class AsyncBatchProcessor:
    """Process multiple requests concurrently"""
    
    async def process_batch(self, requests):
        """Process batch of requests asynchronously"""
        
        tasks = []
        for request in requests:
            task = asyncio.create_task(
                self.process_single(request)
            )
            tasks.append(task)
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Handle partial failures
        successful = []
        failed = []
        
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                failed.append((requests[i], result))
            else:
                successful.append(result)
        
        # Retry failed requests with different models
        if failed:
            retry_results = await self.retry_failed(failed)
            successful.extend(retry_results)
        
        return successful
```

### 3. Queue-Based Processing
```python
class QueueProcessor:
    """Queue-based request processing"""
    
    def __init__(self):
        self.queue = asyncio.Queue()
        self.workers = []
        self.num_workers = 5
    
    async def start(self):
        """Start queue workers"""
        for i in range(self.num_workers):
            worker = asyncio.create_task(self.worker(f"worker-{i}"))
            self.workers.append(worker)
    
    async def worker(self, name):
        """Process items from queue"""
        while True:
            item = await self.queue.get()
            try:
                result = await self.process_item(item)
                await self.store_result(item['id'], result)
            except Exception as e:
                await self.handle_error(item, e)
            finally:
                self.queue.task_done()
```

## Monitoring Patterns

### 1. Health Check System
```python
class HealthChecker:
    """Monitor system health"""
    
    def __init__(self):
        self.checks = {
            "openrouter_api": self.check_openrouter,
            "cache_system": self.check_cache,
            "budget_remaining": self.check_budget,
            "error_rate": self.check_errors
        }
    
    async def run_health_checks(self):
        """Run all health checks"""
        
        results = {}
        for name, check in self.checks.items():
            try:
                status = await check()
                results[name] = {
                    "status": "healthy" if status else "unhealthy",
                    "timestamp": datetime.now().isoformat()
                }
            except Exception as e:
                results[name] = {
                    "status": "error",
                    "error": str(e),
                    "timestamp": datetime.now().isoformat()
                }
        
        return results
```

### 2. Performance Metrics
```python
class MetricsCollector:
    """Collect and report metrics"""
    
    def __init__(self):
        self.metrics = {
            "requests": Counter(),
            "latency": Histogram(),
            "errors": Counter(),
            "costs": Gauge()
        }
    
    def record_request(self, model, latency, cost, success):
        """Record request metrics"""
        
        self.metrics["requests"].inc()
        self.metrics["latency"].observe(latency)
        self.metrics["costs"].set(cost)
        
        if not success:
            self.metrics["errors"].inc()
        
        # Log to monitoring service
        self.send_to_monitoring({
            "model": model,
            "latency": latency,
            "cost": cost,
            "success": success,
            "timestamp": time.time()
        })
```

### 3. Alerting System
```python
class AlertManager:
    """Manage production alerts"""
    
    def __init__(self):
        self.alert_rules = {
            "high_cost": lambda m: m["cost_per_hour"] > 10,
            "high_error_rate": lambda m: m["error_rate"] > 0.05,
            "slow_response": lambda m: m["p95_latency"] > 5000,
            "budget_depleted": lambda m: m["budget_remaining"] < 10
        }
    
    def check_alerts(self, metrics):
        """Check metrics against alert rules"""
        
        triggered = []
        for name, rule in self.alert_rules.items():
            if rule(metrics):
                triggered.append(self.create_alert(name, metrics))
        
        if triggered:
            self.send_alerts(triggered)
```

## Security Patterns

### 1. API Key Rotation
```python
class KeyRotation:
    """Automatic API key rotation"""
    
    def __init__(self):
        self.primary_key = None
        self.secondary_key = None
        self.rotation_interval = 30 * 24 * 3600  # 30 days
    
    def get_current_key(self):
        """Get current active key"""
        
        if self.should_rotate():
            self.rotate_keys()
        
        return self.primary_key
    
    def rotate_keys(self):
        """Rotate API keys"""
        
        # Generate new key
        new_key = self.generate_new_key()
        
        # Update keys
        self.secondary_key = self.primary_key
        self.primary_key = new_key
        
        # Schedule old key deletion
        self.schedule_key_deletion(self.secondary_key)
```

### 2. Request Validation
```python
class RequestValidator:
    """Validate requests before sending"""
    
    def validate(self, request):
        """Validate request parameters"""
        
        # Check prompt injection
        if self.detect_injection(request["prompt"]):
            raise SecurityException("Potential prompt injection")
        
        # Validate model name
        if request["model"] not in self.allowed_models:
            raise ValidationException("Invalid model")
        
        # Check token limits
        if request.get("max_tokens", 0) > self.max_allowed_tokens:
            raise ValidationException("Token limit exceeded")
        
        # Validate temperature
        if not 0 <= request.get("temperature", 0.7) <= 2:
            raise ValidationException("Invalid temperature")
```

## Deployment Patterns

### 1. Blue-Green Deployment
```python
class BlueGreenDeployment:
    """Zero-downtime deployment"""
    
    def __init__(self):
        self.blue = ProductionSystem("blue")
        self.green = ProductionSystem("green")
        self.active = "blue"
    
    def deploy_new_version(self, version):
        """Deploy new version with zero downtime"""
        
        # Deploy to inactive environment
        inactive = "green" if self.active == "blue" else "blue"
        self.deploy_to_environment(inactive, version)
        
        # Run smoke tests
        if self.run_smoke_tests(inactive):
            # Switch traffic
            self.switch_traffic(inactive)
            self.active = inactive
        else:
            # Rollback
            self.rollback(inactive)
```

### 2. Canary Deployment
```python
class CanaryDeployment:
    """Gradual rollout with monitoring"""
    
    def __init__(self):
        self.canary_percentage = 5
        self.stable_version = "v1.0"
        self.canary_version = None
    
    def route_request(self, request_id):
        """Route request to stable or canary"""
        
        if self.canary_version and random.random() < self.canary_percentage / 100:
            return self.canary_version
        return self.stable_version
    
    def monitor_canary(self):
        """Monitor canary performance"""
        
        canary_metrics = self.get_metrics(self.canary_version)
        stable_metrics = self.get_metrics(self.stable_version)
        
        if self.is_canary_healthy(canary_metrics, stable_metrics):
            self.increase_canary_traffic()
        else:
            self.rollback_canary()
```

## Testing Patterns

### 1. Contract Testing
```python
class ContractTest:
    """Test OpenRouter API contracts"""
    
    def test_model_availability(self):
        """Test that expected models are available"""
        
        required_models = [
            "anthropic/claude-3-opus",
            "openai/gpt-4-turbo",
            "mistralai/mixtral-8x7b"
        ]
        
        available = self.get_available_models()
        for model in required_models:
            assert model in available, f"Required model {model} not available"
    
    def test_response_format(self):
        """Test response format consistency"""
        
        response = self.make_test_request()
        
        assert "choices" in response
        assert len(response["choices"]) > 0
        assert "message" in response["choices"][0]
        assert "content" in response["choices"][0]["message"]
```

### 2. Load Testing
```python
class LoadTester:
    """Test system under load"""
    
    async def run_load_test(self, requests_per_second=10, duration=60):
        """Run load test"""
        
        start_time = time.time()
        results = []
        
        while time.time() - start_time < duration:
            # Send requests at specified rate
            tasks = []
            for _ in range(requests_per_second):
                task = asyncio.create_task(self.send_test_request())
                tasks.append(task)
            
            batch_results = await asyncio.gather(*tasks)
            results.extend(batch_results)
            
            # Wait for next second
            await asyncio.sleep(1)
        
        return self.analyze_results(results)
```

## Best Practices Summary

1. **Always use connection pooling** for better resource utilization
2. **Implement circuit breakers** to prevent cascading failures
3. **Monitor everything** - costs, latency, errors, quality
4. **Use async processing** for better throughput
5. **Implement proper retry logic** with exponential backoff
6. **Cache aggressively** but invalidate intelligently
7. **Validate all inputs** before sending to API
8. **Plan for graceful degradation** when services fail
9. **Rotate API keys regularly** for security
10. **Test continuously** - unit, integration, load, and contract tests