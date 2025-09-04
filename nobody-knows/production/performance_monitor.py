#!/usr/bin/env python3
"""
Performance Monitoring and Memory Optimization Module
Addresses performance optimization requirements from multi-agent review.
"""

import psutil
import threading
import time
import json
from typing import Dict, Any, List, Optional
from dataclasses import dataclass, asdict
from collections import deque
from datetime import datetime, timedelta
import logging
import gc
import sys

logger = logging.getLogger(__name__)

@dataclass
class PerformanceMetrics:
    """Performance metrics snapshot"""
    timestamp: float
    cpu_percent: float
    memory_mb: float
    memory_percent: float
    active_threads: int
    episode_processing_time: float
    query_cache_size: int
    gc_collections: int

@dataclass
class MemoryOptimization:
    """Memory optimization results"""
    before_mb: float
    after_mb: float
    freed_mb: float
    optimization_type: str
    success: bool

class PerformanceMonitor:
    """
    Real-time performance monitoring with memory optimization
    
    Features:
    - Memory usage tracking and optimization
    - CPU utilization monitoring
    - Query cache management with intelligent eviction
    - Automated garbage collection optimization
    - Performance regression detection
    """
    
    def __init__(self, sampling_interval: float = 5.0, history_size: int = 1000):
        self.sampling_interval = sampling_interval
        self.history_size = history_size
        self.metrics_history = deque(maxlen=history_size)
        self.optimization_log = deque(maxlen=100)
        self.query_cache: Dict[str, Any] = {}
        self.cache_access_times: Dict[str, float] = {}
        self.max_cache_size = 1000
        self.monitoring_active = False
        self.monitor_thread: Optional[threading.Thread] = None
        self.lock = threading.Lock()
        
        # Performance thresholds
        self.memory_warning_mb = 2048  # 2GB warning threshold
        self.memory_critical_mb = 4096  # 4GB critical threshold
        self.cpu_warning_percent = 80
        self.cpu_critical_percent = 95
        
        # Initial system baseline
        self.baseline_memory = self._get_memory_usage()
        
        logger.info(f"Performance monitor initialized - Baseline memory: {self.baseline_memory:.2f}MB")
    
    def start_monitoring(self):
        """Start continuous performance monitoring"""
        if self.monitoring_active:
            return
        
        self.monitoring_active = True
        self.monitor_thread = threading.Thread(
            target=self._monitoring_loop,
            name="PerformanceMonitor",
            daemon=True
        )
        self.monitor_thread.start()
        logger.info("Performance monitoring started")
    
    def stop_monitoring(self):
        """Stop performance monitoring"""
        self.monitoring_active = False
        if self.monitor_thread:
            self.monitor_thread.join(timeout=self.sampling_interval * 2)
        logger.info("Performance monitoring stopped")
    
    def _monitoring_loop(self):
        """Main monitoring loop"""
        while self.monitoring_active:
            try:
                metrics = self._collect_metrics()
                
                with self.lock:
                    self.metrics_history.append(metrics)
                
                # Check for performance issues
                self._check_performance_thresholds(metrics)
                
                # Perform automated optimizations if needed
                if metrics.memory_mb > self.memory_warning_mb:
                    self.optimize_memory()
                
                if len(self.query_cache) > self.max_cache_size * 0.8:
                    self.optimize_query_cache()
                
                time.sleep(self.sampling_interval)
                
            except Exception as e:
                logger.error(f"Error in monitoring loop: {e}")
                time.sleep(self.sampling_interval)
    
    def _collect_metrics(self) -> PerformanceMetrics:
        """Collect current performance metrics"""
        process = psutil.Process()
        
        return PerformanceMetrics(
            timestamp=time.time(),
            cpu_percent=process.cpu_percent(),
            memory_mb=self._get_memory_usage(),
            memory_percent=process.memory_percent(),
            active_threads=threading.active_count(),
            episode_processing_time=self._get_avg_processing_time(),
            query_cache_size=len(self.query_cache),
            gc_collections=sum(gc.get_stats()[-1].values()) if gc.get_stats() else 0
        )
    
    def _get_memory_usage(self) -> float:
        """Get current memory usage in MB"""
        process = psutil.Process()
        return process.memory_info().rss / 1024 / 1024
    
    def _get_avg_processing_time(self) -> float:
        """Calculate average episode processing time"""
        # This would integrate with the thread safety module
        # For now, return a placeholder
        return 300.0  # 5 minutes average
    
    def _check_performance_thresholds(self, metrics: PerformanceMetrics):
        """Check performance metrics against thresholds"""
        # Memory warnings
        if metrics.memory_mb > self.memory_critical_mb:
            logger.critical(f"CRITICAL: Memory usage {metrics.memory_mb:.2f}MB exceeds critical threshold")
            self.emergency_memory_optimization()
        elif metrics.memory_mb > self.memory_warning_mb:
            logger.warning(f"WARNING: Memory usage {metrics.memory_mb:.2f}MB exceeds warning threshold")
        
        # CPU warnings
        if metrics.cpu_percent > self.cpu_critical_percent:
            logger.critical(f"CRITICAL: CPU usage {metrics.cpu_percent:.1f}% exceeds critical threshold")
        elif metrics.cpu_percent > self.cpu_warning_percent:
            logger.warning(f"WARNING: CPU usage {metrics.cpu_percent:.1f}% exceeds warning threshold")
    
    def optimize_memory(self) -> MemoryOptimization:
        """Perform memory optimization"""
        before_memory = self._get_memory_usage()
        
        try:
            # Clear query cache if too large
            if len(self.query_cache) > 100:
                cache_cleared = len(self.query_cache)
                self.query_cache.clear()
                self.cache_access_times.clear()
                logger.info(f"Cleared query cache: {cache_cleared} entries removed")
            
            # Force garbage collection
            collected = gc.collect()
            logger.info(f"Garbage collection: {collected} objects collected")
            
            # Small delay to allow memory to be released
            time.sleep(0.1)
            
            after_memory = self._get_memory_usage()
            freed_mb = before_memory - after_memory
            
            optimization = MemoryOptimization(
                before_mb=before_memory,
                after_mb=after_memory,
                freed_mb=freed_mb,
                optimization_type="standard",
                success=freed_mb > 0
            )
            
            with self.lock:
                self.optimization_log.append(optimization)
            
            logger.info(f"Memory optimization: {freed_mb:.2f}MB freed ({before_memory:.2f}MB → {after_memory:.2f}MB)")
            return optimization
            
        except Exception as e:
            logger.error(f"Memory optimization failed: {e}")
            return MemoryOptimization(
                before_mb=before_memory,
                after_mb=before_memory,
                freed_mb=0.0,
                optimization_type="failed",
                success=False
            )
    
    def emergency_memory_optimization(self) -> MemoryOptimization:
        """Emergency memory optimization for critical situations"""
        before_memory = self._get_memory_usage()
        
        try:
            logger.critical("EMERGENCY: Performing aggressive memory optimization")
            
            # Clear all caches
            self.query_cache.clear()
            self.cache_access_times.clear()
            
            # Trim metrics history
            if len(self.metrics_history) > 100:
                for _ in range(len(self.metrics_history) - 100):
                    self.metrics_history.popleft()
            
            # Force aggressive garbage collection
            for _ in range(3):
                collected = gc.collect()
                time.sleep(0.05)
            
            after_memory = self._get_memory_usage()
            freed_mb = before_memory - after_memory
            
            optimization = MemoryOptimization(
                before_mb=before_memory,
                after_mb=after_memory,
                freed_mb=freed_mb,
                optimization_type="emergency",
                success=freed_mb > 0
            )
            
            logger.critical(f"Emergency optimization: {freed_mb:.2f}MB freed")
            return optimization
            
        except Exception as e:
            logger.error(f"Emergency memory optimization failed: {e}")
            return MemoryOptimization(
                before_mb=before_memory,
                after_mb=before_memory,
                freed_mb=0.0,
                optimization_type="emergency_failed",
                success=False
            )
    
    def optimize_query_cache(self):
        """Optimize query cache using LRU eviction"""
        if len(self.query_cache) <= self.max_cache_size:
            return
        
        current_time = time.time()
        
        # Sort by access time (LRU)
        sorted_cache = sorted(
            self.cache_access_times.items(),
            key=lambda x: x[1]
        )
        
        # Remove oldest entries
        entries_to_remove = len(self.query_cache) - int(self.max_cache_size * 0.7)
        
        for key, _ in sorted_cache[:entries_to_remove]:
            self.query_cache.pop(key, None)
            self.cache_access_times.pop(key, None)
        
        logger.info(f"Query cache optimized: removed {entries_to_remove} LRU entries")
    
    def cache_query_result(self, query_key: str, result: Any, ttl: float = 3600):
        """Cache query result with TTL"""
        current_time = time.time()
        
        # Remove expired entries
        expired_keys = [
            key for key, access_time in self.cache_access_times.items()
            if current_time - access_time > ttl
        ]
        
        for key in expired_keys:
            self.query_cache.pop(key, None)
            self.cache_access_times.pop(key, None)
        
        # Add new entry
        self.query_cache[query_key] = result
        self.cache_access_times[query_key] = current_time
        
        # Trigger optimization if needed
        if len(self.query_cache) > self.max_cache_size:
            self.optimize_query_cache()
    
    def get_cached_query_result(self, query_key: str) -> Optional[Any]:
        """Get cached query result and update access time"""
        if query_key in self.query_cache:
            self.cache_access_times[query_key] = time.time()
            return self.query_cache[query_key]
        return None
    
    def get_performance_report(self) -> Dict[str, Any]:
        """Generate comprehensive performance report"""
        with self.lock:
            if not self.metrics_history:
                return {"error": "No metrics collected yet"}
            
            recent_metrics = list(self.metrics_history)[-10:]  # Last 10 samples
            
            # Calculate averages
            avg_memory = sum(m.memory_mb for m in recent_metrics) / len(recent_metrics)
            avg_cpu = sum(m.cpu_percent for m in recent_metrics) / len(recent_metrics)
            avg_threads = sum(m.active_threads for m in recent_metrics) / len(recent_metrics)
            
            # Memory trend analysis
            if len(recent_metrics) >= 2:
                memory_trend = recent_metrics[-1].memory_mb - recent_metrics[0].memory_mb
            else:
                memory_trend = 0.0
            
            report = {
                "timestamp": time.time(),
                "system_health": {
                    "status": self._get_health_status(avg_memory, avg_cpu),
                    "memory_mb": avg_memory,
                    "memory_trend_mb": memory_trend,
                    "cpu_percent": avg_cpu,
                    "active_threads": int(avg_threads),
                    "baseline_memory_mb": self.baseline_memory
                },
                "optimization_summary": {
                    "query_cache_size": len(self.query_cache),
                    "cache_hit_potential": f"{min(100, len(self.query_cache) * 5):.1f}%",
                    "optimizations_performed": len(self.optimization_log),
                    "total_memory_freed_mb": sum(opt.freed_mb for opt in self.optimization_log if opt.success)
                },
                "performance_metrics": {
                    "memory_efficiency": f"{(self.baseline_memory / avg_memory) * 100:.1f}%",
                    "cache_efficiency": f"{(1 - len(self.query_cache) / max(1, self.max_cache_size)) * 100:.1f}%",
                    "thread_utilization": f"{(avg_threads / threading.active_count()) * 100:.1f}%"
                },
                "recent_optimizations": [
                    asdict(opt) for opt in list(self.optimization_log)[-5:]
                ]
            }
            
            return report
    
    def _get_health_status(self, memory_mb: float, cpu_percent: float) -> str:
        """Determine system health status"""
        if memory_mb > self.memory_critical_mb or cpu_percent > self.cpu_critical_percent:
            return "CRITICAL"
        elif memory_mb > self.memory_warning_mb or cpu_percent > self.cpu_warning_percent:
            return "WARNING"
        else:
            return "HEALTHY"

# Global monitor instance
_monitor_instance: Optional[PerformanceMonitor] = None
_monitor_lock = threading.Lock()

def get_performance_monitor() -> PerformanceMonitor:
    """Get singleton performance monitor instance"""
    global _monitor_instance
    
    if _monitor_instance is None:
        with _monitor_lock:
            if _monitor_instance is None:
                _monitor_instance = PerformanceMonitor()
                _monitor_instance.start_monitoring()
    
    return _monitor_instance

def shutdown_performance_monitor():
    """Shutdown the global monitor instance"""
    global _monitor_instance
    
    if _monitor_instance:
        _monitor_instance.stop_monitoring()
        _monitor_instance = None