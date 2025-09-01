#!/usr/bin/env python3
"""
Monitoring module for podcast production system.

Provides simple, pragmatic monitoring for first-time LangGraph/Langfuse users.
Focuses on minimum viable complexity while delivering production-grade insights.
"""

import time
import psutil
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from contextlib import contextmanager

logger = logging.getLogger(__name__)

@dataclass
class PerformanceMetrics:
    """Performance metrics for podcast production stages."""
    
    # Timing metrics
    stage_name: str
    start_time: float
    end_time: Optional[float] = None
    duration_seconds: Optional[float] = None
    
    # Resource metrics  
    memory_start_mb: Optional[float] = None
    memory_end_mb: Optional[float] = None
    memory_peak_mb: Optional[float] = None
    cpu_percent_avg: Optional[float] = None
    
    # Production metrics
    cost_dollars: Optional[float] = None
    tokens_used: Optional[int] = None
    api_calls: Optional[int] = None
    
    # Quality metrics
    success: bool = True
    error_message: Optional[str] = None
    warnings: List[str] = None
    
    def __post_init__(self):
        """Initialize default values."""
        if self.warnings is None:
            self.warnings = []
    
    def finish(self, cost: Optional[float] = None, 
              tokens: Optional[int] = None, 
              api_calls: Optional[int] = None,
              success: bool = True, 
              error: Optional[str] = None) -> 'PerformanceMetrics':
        """Complete the metrics collection."""
        self.end_time = time.time()
        self.duration_seconds = self.end_time - self.start_time
        
        # Update resource metrics
        try:
            process = psutil.Process()
            memory_info = process.memory_info()
            self.memory_end_mb = memory_info.rss / 1024 / 1024
            self.cpu_percent_avg = process.cpu_percent()
        except Exception as e:
            logger.warning(f"Failed to collect resource metrics: {e}")
        
        # Update production metrics
        self.cost_dollars = cost
        self.tokens_used = tokens
        self.api_calls = api_calls
        self.success = success
        self.error_message = error
        
        return self
    
    def add_warning(self, warning: str):
        """Add a warning message."""
        self.warnings.append(warning)
        logger.warning(f"[{self.stage_name}] {warning}")
    
    def is_slow(self, threshold_seconds: float = 30.0) -> bool:
        """Check if stage is running slower than expected."""
        return self.duration_seconds and self.duration_seconds > threshold_seconds
    
    def is_expensive(self, threshold_dollars: float = 1.0) -> bool:
        """Check if stage cost exceeds threshold."""
        return self.cost_dollars and self.cost_dollars > threshold_dollars
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization."""
        return asdict(self)

class SimpleMonitor:
    """Simple monitoring system for podcast production."""
    
    def __init__(self, budget_limit: float = 5.51):
        self.metrics: List[PerformanceMetrics] = []
        self.budget_limit = budget_limit
        self.total_cost = 0.0
        self._current_stage: Optional[str] = None
        self._stage_start: Optional[float] = None
        
    def start_stage(self, stage_name: str) -> PerformanceMetrics:
        """Start monitoring a production stage."""
        if self._current_stage:
            logger.warning(f"Starting '{stage_name}' while '{self._current_stage}' is still active")
        
        self._current_stage = stage_name
        self._stage_start = time.time()
        
        # Collect initial resource metrics
        memory_start = None
        try:
            process = psutil.Process()
            memory_info = process.memory_info()
            memory_start = memory_info.rss / 1024 / 1024
        except Exception as e:
            logger.warning(f"Failed to collect initial metrics: {e}")
        
        metrics = PerformanceMetrics(
            stage_name=stage_name,
            start_time=self._stage_start,
            memory_start_mb=memory_start
        )
        
        self.metrics.append(metrics)
        logger.info(f"📊 Started monitoring stage: {stage_name}")
        return metrics
    
    def finish_stage(self, cost: Optional[float] = None, 
                    tokens: Optional[int] = None,
                    api_calls: Optional[int] = None,
                    success: bool = True, 
                    error: Optional[str] = None) -> Optional[PerformanceMetrics]:
        """Finish monitoring current stage."""
        if not self._current_stage or not self.metrics:
            logger.error("No active stage to finish")
            return None
        
        current_metrics = self.metrics[-1]
        current_metrics.finish(cost=cost, tokens=tokens, api_calls=api_calls, 
                             success=success, error=error)
        
        # Update total cost
        if cost:
            self.total_cost += cost
            
        # Check thresholds
        self._check_stage_thresholds(current_metrics)
        
        logger.info(f"📊 Finished monitoring stage: {self._current_stage} "
                   f"({current_metrics.duration_seconds:.2f}s, ${cost or 0:.4f})")
        
        self._current_stage = None
        self._stage_start = None
        
        return current_metrics
    
    def _check_stage_thresholds(self, metrics: PerformanceMetrics):
        """Check if stage metrics exceed thresholds."""
        
        # Check timing
        if metrics.is_slow(threshold_seconds=60.0):
            metrics.add_warning(f"Stage took {metrics.duration_seconds:.1f}s (>60s threshold)")
        
        # Check cost
        if metrics.is_expensive(threshold_dollars=2.0):
            metrics.add_warning(f"Stage cost ${metrics.cost_dollars:.4f} (>$2.00 threshold)")
        
        # Check budget
        if self.total_cost > self.budget_limit:
            metrics.add_warning(f"Total cost ${self.total_cost:.4f} exceeds budget ${self.budget_limit}")
        
        # Check memory (>500MB is concerning for our use case)
        if metrics.memory_end_mb and metrics.memory_end_mb > 500:
            metrics.add_warning(f"High memory usage: {metrics.memory_end_mb:.1f}MB")
    
    @contextmanager
    def monitor_stage(self, stage_name: str, expected_cost: Optional[float] = None):
        """Context manager for monitoring a stage."""
        metrics = self.start_stage(stage_name)
        start_time = time.time()
        
        try:
            yield metrics
            # Success - finish with timing only
            duration = time.time() - start_time
            self.finish_stage(success=True)
            
        except Exception as e:
            # Error - finish with error info
            self.finish_stage(success=False, error=str(e))
            logger.error(f"Stage {stage_name} failed: {e}")
            raise
    
    def get_summary(self) -> Dict[str, Any]:
        """Get monitoring summary."""
        if not self.metrics:
            return {"status": "no_data", "total_stages": 0}
        
        successful_stages = sum(1 for m in self.metrics if m.success)
        total_duration = sum(m.duration_seconds or 0 for m in self.metrics)
        total_warnings = sum(len(m.warnings) for m in self.metrics)
        
        return {
            "status": "success" if successful_stages == len(self.metrics) else "partial_failure",
            "total_stages": len(self.metrics),
            "successful_stages": successful_stages,
            "failed_stages": len(self.metrics) - successful_stages,
            "total_duration_seconds": total_duration,
            "total_cost_dollars": self.total_cost,
            "budget_limit": self.budget_limit,
            "budget_remaining": max(0, self.budget_limit - self.total_cost),
            "budget_utilization_percent": min(100, (self.total_cost / self.budget_limit) * 100),
            "total_warnings": total_warnings,
            "stages": [m.to_dict() for m in self.metrics]
        }
    
    def check_budget_threshold(self, threshold_percent: float = 80.0) -> bool:
        """Check if budget utilization exceeds threshold."""
        utilization = (self.total_cost / self.budget_limit) * 100
        return utilization > threshold_percent
    
    def get_cost_breakdown(self) -> Dict[str, float]:
        """Get cost breakdown by stage."""
        breakdown = {}
        for metrics in self.metrics:
            if metrics.cost_dollars:
                breakdown[metrics.stage_name] = breakdown.get(metrics.stage_name, 0) + metrics.cost_dollars
        return breakdown
    
    def get_performance_alerts(self) -> List[Dict[str, Any]]:
        """Get performance alerts for dashboard/monitoring."""
        alerts = []
        
        # Budget alerts
        if self.check_budget_threshold(80.0):
            alerts.append({
                "type": "budget_warning",
                "message": f"Budget utilization at {(self.total_cost/self.budget_limit)*100:.1f}%",
                "severity": "warning" if self.total_cost < self.budget_limit else "error"
            })
        
        # Performance alerts
        for metrics in self.metrics:
            if metrics.is_slow():
                alerts.append({
                    "type": "performance_warning", 
                    "stage": metrics.stage_name,
                    "message": f"Stage took {metrics.duration_seconds:.1f}s",
                    "severity": "warning"
                })
            
            if metrics.warnings:
                for warning in metrics.warnings:
                    alerts.append({
                        "type": "stage_warning",
                        "stage": metrics.stage_name,
                        "message": warning,
                        "severity": "warning"
                    })
        
        return alerts

def create_simple_monitor(budget_limit: float = 5.51) -> SimpleMonitor:
    """Create a simple monitor instance."""
    return SimpleMonitor(budget_limit=budget_limit)

# Example usage for documentation
def example_usage():
    """Example of how to use the monitoring system."""
    monitor = create_simple_monitor(budget_limit=5.51)
    
    # Method 1: Manual start/finish
    metrics = monitor.start_stage("research_discovery")
    # ... do work ...
    monitor.finish_stage(cost=1.25, tokens=1500, api_calls=3, success=True)
    
    # Method 2: Context manager (recommended)
    with monitor.monitor_stage("script_writing") as metrics:
        # ... do work ...
        # Automatically finished on exit
        pass
    
    # Get summary
    summary = monitor.get_summary()
    alerts = monitor.get_performance_alerts()
    
    return summary, alerts

if __name__ == "__main__":
    # Quick test
    monitor = create_simple_monitor()
    
    with monitor.monitor_stage("test_stage") as metrics:
        time.sleep(0.1)  # Simulate work
        metrics.add_warning("This is a test warning")
    
    print("Monitoring Summary:")
    summary = monitor.get_summary()
    for key, value in summary.items():
        if key != "stages":
            print(f"  {key}: {value}")
    
    print(f"\nPerformance Alerts: {len(monitor.get_performance_alerts())}")
    for alert in monitor.get_performance_alerts():
        print(f"  - {alert['type']}: {alert['message']}")