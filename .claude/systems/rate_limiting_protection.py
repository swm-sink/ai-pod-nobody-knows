#!/usr/bin/env python3
"""
Rate Limiting Protection System - Priority 1 Implementation
Comprehensive MCP API abuse prevention and throttling mechanisms

FEATURES:
- Intelligent rate limiting with exponential backoff
- Circuit breaker pattern for API protection  
- Usage monitoring with anomaly detection
- Cost-aware throttling and budget protection
- Graceful degradation and fallback mechanisms
- Real-time dashboards and alerting
"""

import time
import json
import threading
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Callable, Any
from dataclasses import dataclass, asdict
from pathlib import Path
import logging
from collections import deque, defaultdict
from enum import Enum
import subprocess

class ServiceStatus(Enum):
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    CIRCUIT_OPEN = "circuit_open"
    RATE_LIMITED = "rate_limited"
    EMERGENCY_STOP = "emergency_stop"

@dataclass
class RateLimitConfig:
    """Rate limiting configuration per service"""
    service_name: str
    requests_per_minute: int = 30
    requests_per_hour: int = 500
    burst_allowance: int = 5
    cost_per_request: float = 0.15
    max_hourly_cost: float = 75.0
    circuit_breaker_threshold: int = 5
    circuit_breaker_timeout: int = 300  # 5 minutes

@dataclass
class RequestMetrics:
    """Individual request tracking metrics"""
    timestamp: datetime
    service: str
    cost: float
    response_time: float
    success: bool
    error_type: Optional[str] = None

@dataclass
class ServiceHealth:
    """Service health status tracking"""
    service_name: str
    status: ServiceStatus
    error_count: int
    last_error: Optional[str]
    circuit_open_until: Optional[datetime]
    requests_this_minute: int
    requests_this_hour: int
    cost_this_hour: float
    avg_response_time: float

class RateLimiter:
    """Individual service rate limiter with circuit breaker"""
    
    def __init__(self, config: RateLimitConfig):
        self.config = config
        self.request_history = deque(maxlen=1000)
        self.minute_requests = deque(maxlen=60)
        self.hour_requests = deque(maxlen=3600)
        self.error_count = 0
        self.circuit_open_until = None
        self.lock = threading.RLock()
        
    def can_make_request(self) -> tuple[bool, str]:
        """Check if request can be made within rate limits"""
        with self.lock:
            now = datetime.now()
            
            # Clean old requests
            self._cleanup_old_requests(now)
            
            # Check circuit breaker
            if self.circuit_open_until and now < self.circuit_open_until:
                return False, f"Circuit breaker open until {self.circuit_open_until}"
            elif self.circuit_open_until and now >= self.circuit_open_until:
                # Circuit breaker timeout expired, reset
                self.circuit_open_until = None
                self.error_count = 0
            
            # Check minute rate limit
            minute_count = len([r for r in self.minute_requests 
                               if (now - r).seconds < 60])
            if minute_count >= self.config.requests_per_minute:
                return False, f"Minute rate limit exceeded: {minute_count}/{self.config.requests_per_minute}"
            
            # Check hour rate limit
            hour_count = len([r for r in self.hour_requests 
                             if (now - r).seconds < 3600])
            if hour_count >= self.config.requests_per_hour:
                return False, f"Hour rate limit exceeded: {hour_count}/{self.config.requests_per_hour}"
            
            # Check hourly cost limit
            hour_cost = sum(r.cost for r in self.request_history 
                           if (now - r.timestamp).seconds < 3600)
            estimated_cost = hour_cost + self.config.cost_per_request
            if estimated_cost > self.config.max_hourly_cost:
                return False, f"Hourly cost limit exceeded: ${estimated_cost:.2f}/${self.config.max_hourly_cost:.2f}"
            
            return True, "Request allowed"
    
    def record_request(self, success: bool, cost: float, response_time: float, 
                      error_type: Optional[str] = None):
        """Record request results and update metrics"""
        with self.lock:
            now = datetime.now()
            
            # Record request
            metrics = RequestMetrics(
                timestamp=now,
                service=self.config.service_name,
                cost=cost,
                response_time=response_time,
                success=success,
                error_type=error_type
            )
            
            self.request_history.append(metrics)
            self.minute_requests.append(now)
            self.hour_requests.append(now)
            
            # Update error tracking
            if not success:
                self.error_count += 1
                if self.error_count >= self.config.circuit_breaker_threshold:
                    self.circuit_open_until = now + timedelta(seconds=self.config.circuit_breaker_timeout)
            else:
                # Reset error count on success
                self.error_count = max(0, self.error_count - 1)
    
    def get_health_status(self) -> ServiceHealth:
        """Get current service health status"""
        with self.lock:
            now = datetime.now()
            self._cleanup_old_requests(now)
            
            # Calculate metrics
            minute_requests = len([r for r in self.minute_requests 
                                 if (now - r).seconds < 60])
            hour_requests = len([r for r in self.hour_requests 
                               if (now - r).seconds < 3600])
            hour_cost = sum(r.cost for r in self.request_history 
                           if (now - r.timestamp).seconds < 3600)
            
            recent_requests = [r for r in self.request_history 
                             if (now - r.timestamp).seconds < 300]  # Last 5 minutes
            avg_response_time = (sum(r.response_time for r in recent_requests) / 
                               len(recent_requests)) if recent_requests else 0
            
            # Determine status
            status = ServiceStatus.HEALTHY
            if self.circuit_open_until and now < self.circuit_open_until:
                status = ServiceStatus.CIRCUIT_OPEN
            elif minute_requests > self.config.requests_per_minute * 0.9:
                status = ServiceStatus.RATE_LIMITED
            elif hour_cost > self.config.max_hourly_cost * 0.9:
                status = ServiceStatus.EMERGENCY_STOP
            elif self.error_count > 2:
                status = ServiceStatus.DEGRADED
            
            return ServiceHealth(
                service_name=self.config.service_name,
                status=status,
                error_count=self.error_count,
                last_error=None,  # Would need to track this separately
                circuit_open_until=self.circuit_open_until,
                requests_this_minute=minute_requests,
                requests_this_hour=hour_requests,
                cost_this_hour=hour_cost,
                avg_response_time=avg_response_time
            )
    
    def _cleanup_old_requests(self, now: datetime):
        """Clean up old request records"""
        # Keep only last hour of detailed metrics
        cutoff = now - timedelta(hours=1)
        while (self.request_history and 
               self.request_history[0].timestamp < cutoff):
            self.request_history.popleft()

class MCPRateLimitManager:
    """Main rate limiting manager for all MCP services"""
    
    def __init__(self, config_file: str = ".claude/config/rate_limits.json"):
        self.config_file = config_file
        self.services: Dict[str, RateLimiter] = {}
        self.global_metrics = []
        self.alerts = deque(maxlen=100)
        self.lock = threading.RLock()
        
        # Default configurations
        default_configs = {
            "perplexity-ask": RateLimitConfig(
                service_name="perplexity-ask",
                requests_per_minute=20,
                requests_per_hour=300,
                cost_per_request=0.15,
                max_hourly_cost=45.0,
                circuit_breaker_threshold=5
            ),
            "elevenlabs": RateLimitConfig(
                service_name="elevenlabs",
                requests_per_minute=10,
                requests_per_hour=100,
                cost_per_request=0.25,
                max_hourly_cost=25.0,
                circuit_breaker_threshold=3
            )
        }
        
        self._load_config(default_configs)
        self._setup_logging()
    
    def _load_config(self, defaults: Dict[str, RateLimitConfig]):
        """Load rate limiting configuration"""
        try:
            if Path(self.config_file).exists():
                with open(self.config_file, 'r') as f:
                    config_data = json.load(f)
                    
                for service_name, config in config_data.items():
                    rate_config = RateLimitConfig(
                        service_name=service_name,
                        **config
                    )
                    self.services[service_name] = RateLimiter(rate_config)
            else:
                # Use defaults
                for service_name, config in defaults.items():
                    self.services[service_name] = RateLimiter(config)
                
                # Save default config
                self._save_config()
        except Exception as e:
            logging.error(f"Error loading rate limit config: {e}")
            # Fallback to defaults
            for service_name, config in defaults.items():
                self.services[service_name] = RateLimiter(config)
    
    def _save_config(self):
        """Save current configuration"""
        config_data = {}
        for service_name, limiter in self.services.items():
            config_data[service_name] = asdict(limiter.config)
        
        os.makedirs(Path(self.config_file).parent, exist_ok=True)
        with open(self.config_file, 'w') as f:
            json.dump(config_data, f, indent=2)
    
    def _setup_logging(self):
        """Setup logging for rate limiting events"""
        log_dir = Path(".claude/logs")
        log_dir.mkdir(parents=True, exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_dir / "rate_limiting.log"),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger("MCPRateLimiter")
    
    def check_rate_limit(self, service: str) -> tuple[bool, str]:
        """Check if request can be made for service"""
        if service not in self.services:
            return False, f"Unknown service: {service}"
        
        return self.services[service].can_make_request()
    
    def record_request(self, service: str, success: bool, cost: float = None, 
                      response_time: float = 0, error_type: str = None):
        """Record request results"""
        if service not in self.services:
            self.logger.warning(f"Recording request for unknown service: {service}")
            return
        
        # Use default cost if not provided
        if cost is None:
            cost = self.services[service].config.cost_per_request
        
        self.services[service].record_request(success, cost, response_time, error_type)
        
        # Log significant events
        if not success:
            self.logger.warning(f"Request failed for {service}: {error_type}")
        
        # Check for alerts
        self._check_alerts(service)
    
    def _check_alerts(self, service: str):
        """Check for alerting conditions"""
        health = self.services[service].get_health_status()
        
        alert_conditions = [
            (health.status == ServiceStatus.CIRCUIT_OPEN, 
             f"Circuit breaker open for {service}"),
            (health.cost_this_hour > health.service_name in self.services and 
             self.services[service].config.max_hourly_cost * 0.8,
             f"High cost usage for {service}: ${health.cost_this_hour:.2f}"),
            (health.requests_this_minute > self.services[service].config.requests_per_minute * 0.8,
             f"High request rate for {service}: {health.requests_this_minute}/min")
        ]
        
        for condition, message in alert_conditions:
            if condition:
                self._create_alert(message)
    
    def _create_alert(self, message: str):
        """Create rate limiting alert"""
        alert = {
            "timestamp": datetime.now().isoformat(),
            "message": message,
            "severity": "warning"
        }
        
        self.alerts.append(alert)
        self.logger.warning(f"ALERT: {message}")
    
    def get_system_status(self) -> Dict[str, Any]:
        """Get comprehensive system status"""
        status = {
            "timestamp": datetime.now().isoformat(),
            "services": {},
            "global_metrics": {
                "total_requests_last_hour": 0,
                "total_cost_last_hour": 0,
                "average_response_time": 0,
                "error_rate": 0
            },
            "alerts": list(self.alerts)
        }
        
        total_requests = 0
        total_cost = 0
        total_response_time = 0
        error_count = 0
        
        for service_name, limiter in self.services.items():
            health = limiter.get_health_status()
            status["services"][service_name] = asdict(health)
            
            total_requests += health.requests_this_hour
            total_cost += health.cost_this_hour
            total_response_time += health.avg_response_time
            error_count += health.error_count
        
        if len(self.services) > 0:
            status["global_metrics"]["total_requests_last_hour"] = total_requests
            status["global_metrics"]["total_cost_last_hour"] = total_cost
            status["global_metrics"]["average_response_time"] = total_response_time / len(self.services)
            status["global_metrics"]["error_rate"] = error_count / max(total_requests, 1)
        
        return status
    
    def wait_for_rate_limit(self, service: str, max_wait: int = 60) -> bool:
        """Wait for rate limit to allow request"""
        start_time = time.time()
        
        while time.time() - start_time < max_wait:
            can_proceed, reason = self.check_rate_limit(service)
            if can_proceed:
                return True
            
            # Exponential backoff
            wait_time = min(2 ** min((time.time() - start_time) // 10, 5), 10)
            self.logger.info(f"Rate limited for {service}: {reason}. Waiting {wait_time}s")
            time.sleep(wait_time)
        
        return False
    
    def safe_mcp_call(self, service: str, mcp_function: Callable, *args, **kwargs) -> Any:
        """Safely execute MCP call with rate limiting"""
        # Check rate limits
        can_proceed, reason = self.check_rate_limit(service)
        if not can_proceed:
            if not self.wait_for_rate_limit(service, max_wait=30):
                raise Exception(f"Rate limit exceeded for {service}: {reason}")
        
        # Execute with monitoring
        start_time = time.time()
        success = False
        error_type = None
        result = None
        
        try:
            result = mcp_function(*args, **kwargs)
            success = True
            return result
        except Exception as e:
            error_type = type(e).__name__
            raise
        finally:
            response_time = time.time() - start_time
            self.record_request(service, success, response_time=response_time, 
                              error_type=error_type)
    
    def create_dashboard_report(self) -> str:
        """Create dashboard-friendly status report"""
        status = self.get_system_status()
        
        report = f"""
# MCP Rate Limiting Dashboard
**Updated:** {status['timestamp']}

## System Overview
- **Total Requests (Last Hour):** {status['global_metrics']['total_requests_last_hour']}
- **Total Cost (Last Hour):** ${status['global_metrics']['total_cost_last_hour']:.2f}
- **Average Response Time:** {status['global_metrics']['average_response_time']:.2f}s
- **Error Rate:** {status['global_metrics']['error_rate']:.2%}

## Service Status
"""
        
        for service_name, health in status['services'].items():
            status_emoji = {
                "healthy": "✅",
                "degraded": "⚠️",
                "circuit_open": "🔴",
                "rate_limited": "⏱️",
                "emergency_stop": "🚨"
            }.get(health['status'], "❓")
            
            report += f"""
### {service_name} {status_emoji}
- **Status:** {health['status']}
- **Requests:** {health['requests_this_minute']}/min, {health['requests_this_hour']}/hour
- **Cost:** ${health['cost_this_hour']:.2f}/hour
- **Response Time:** {health['avg_response_time']:.2f}s
- **Errors:** {health['error_count']}
"""

        if status['alerts']:
            report += "\n## Recent Alerts\n"
            for alert in list(status['alerts'])[-5:]:  # Last 5 alerts
                report += f"- **{alert['timestamp']}:** {alert['message']}\n"
        
        return report

# Global rate limiter instance
rate_limiter = MCPRateLimitManager()

def protected_mcp_call(service: str):
    """Decorator for MCP calls with rate limiting protection"""
    def decorator(func: Callable):
        def wrapper(*args, **kwargs):
            return rate_limiter.safe_mcp_call(service, func, *args, **kwargs)
        return wrapper
    return decorator

# CLI interface
def main():
    """CLI interface for rate limiting management"""
    import argparse
    
    parser = argparse.ArgumentParser(description="MCP Rate Limiting Manager")
    parser.add_argument("--status", action="store_true", help="Show system status")
    parser.add_argument("--dashboard", action="store_true", help="Show dashboard report")
    parser.add_argument("--test", choices=["perplexity-ask", "elevenlabs"], 
                       help="Test rate limiting for service")
    
    args = parser.parse_args()
    
    if args.status:
        status = rate_limiter.get_system_status()
        print(json.dumps(status, indent=2, default=str))
    
    elif args.dashboard:
        print(rate_limiter.create_dashboard_report())
    
    elif args.test:
        def test_call():
            time.sleep(0.1)  # Simulate API call
            return "test_result"
        
        try:
            result = rate_limiter.safe_mcp_call(args.test, test_call)
            print(f"Test successful for {args.test}: {result}")
        except Exception as e:
            print(f"Test failed for {args.test}: {e}")
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()