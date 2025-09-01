#!/usr/bin/env python3
"""
Production Monitoring System
============================

Real-time monitoring and alerting system for the AI Podcast Production System.
Provides comprehensive monitoring of costs, quality, performance, and system health.

Version: 1.0.0
Date: September 2025
Usage: python monitoring/production_monitor.py --mode=continuous
"""

import os
import sys
import json
import time
import logging
import asyncio
import threading
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, asdict
import yaml
import psutil
import requests
from collections import defaultdict, deque

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# Import project modules
try:
    from core.cost_tracker import CostTracker
    from core.logging_config import setup_logging
except ImportError as e:
    print(f"Error importing project modules: {e}")
    sys.exit(1)


@dataclass
class Metric:
    """Individual metric data point"""
    name: str
    value: float
    timestamp: datetime
    tags: Dict[str, str]
    unit: str = ""


@dataclass
class Alert:
    """Alert notification"""
    level: str  # 'info', 'warning', 'critical'
    title: str
    message: str
    timestamp: datetime
    component: str
    details: Dict[str, Any]
    resolved: bool = False


@dataclass
class SystemStatus:
    """Current system status snapshot"""
    timestamp: datetime
    overall_status: str  # 'healthy', 'warning', 'critical', 'down'
    episode_count_24h: int
    total_cost_24h: float
    average_quality_24h: float
    active_alerts: List[Alert]
    performance_metrics: Dict[str, float]


class MetricsCollector:
    """Collects various system metrics"""
    
    def __init__(self):
        self.cost_tracker = CostTracker()
        
    def collect_cost_metrics(self) -> List[Metric]:
        """Collect cost-related metrics"""
        metrics = []
        now = datetime.now()
        
        # Current total cost
        total_cost = self.cost_tracker.get_total_cost()
        metrics.append(Metric(
            name="total_cost",
            value=total_cost,
            timestamp=now,
            tags={"type": "cumulative"},
            unit="USD"
        ))
        
        # Cost by component (last 24h)
        cost_data = self._get_cost_breakdown_24h()
        for component, cost in cost_data.items():
            metrics.append(Metric(
                name="component_cost_24h",
                value=cost,
                timestamp=now,
                tags={"component": component, "period": "24h"},
                unit="USD"
            ))
        
        # Budget utilization
        max_episode_cost = float(os.getenv("MAX_EPISODE_COST", "5.51"))
        budget_utilization = (total_cost / max_episode_cost) * 100 if max_episode_cost > 0 else 0
        
        metrics.append(Metric(
            name="budget_utilization",
            value=budget_utilization,
            timestamp=now,
            tags={"type": "percentage"},
            unit="percent"
        ))
        
        return metrics
        
    def collect_performance_metrics(self) -> List[Metric]:
        """Collect system performance metrics"""
        metrics = []
        now = datetime.now()
        
        # System resource usage
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('.')
        
        metrics.extend([
            Metric("cpu_usage", cpu_percent, now, {"type": "system"}, "percent"),
            Metric("memory_usage", memory.percent, now, {"type": "system"}, "percent"),
            Metric("disk_usage", (disk.used / disk.total) * 100, now, {"type": "system"}, "percent"),
            Metric("memory_available", memory.available / (1024**3), now, {"type": "system"}, "GB"),
            Metric("disk_free", disk.free / (1024**3), now, {"type": "system"}, "GB"),
        ])
        
        # Episode production metrics
        episode_metrics = self._get_episode_metrics_24h()
        for metric_name, value in episode_metrics.items():
            metrics.append(Metric(
                name=metric_name,
                value=value,
                timestamp=now,
                tags={"period": "24h"},
                unit="count" if "count" in metric_name else "seconds"
            ))
        
        return metrics
        
    def collect_quality_metrics(self) -> List[Metric]:
        """Collect quality-related metrics"""
        metrics = []
        now = datetime.now()
        
        # Load recent quality data
        quality_data = self._get_quality_data_24h()
        
        if quality_data:
            avg_quality = sum(q["overall_score"] for q in quality_data) / len(quality_data)
            metrics.append(Metric(
                name="average_quality_24h",
                value=avg_quality,
                timestamp=now,
                tags={"period": "24h"},
                unit="score"
            ))
            
            # Quality by component
            for component in ["brand_alignment", "technical_accuracy", "engagement"]:
                if all(component in q for q in quality_data):
                    avg_score = sum(q[component] for q in quality_data) / len(quality_data)
                    metrics.append(Metric(
                        name=f"quality_{component}_24h",
                        value=avg_score,
                        timestamp=now,
                        tags={"component": component, "period": "24h"},
                        unit="score"
                    ))
        
        return metrics
        
    def _get_cost_breakdown_24h(self) -> Dict[str, float]:
        """Get cost breakdown for last 24 hours"""
        # This would integrate with actual cost tracking data
        # For now, return mock data structure
        return {
            "research": 0.0,
            "script_generation": 0.0,
            "audio_synthesis": 0.0,
            "validation": 0.0
        }
        
    def _get_episode_metrics_24h(self) -> Dict[str, float]:
        """Get episode production metrics for last 24 hours"""
        # This would analyze actual episode production logs
        return {
            "episode_count": 0,
            "successful_episodes": 0,
            "failed_episodes": 0,
            "average_duration": 0
        }
        
    def _get_quality_data_24h(self) -> List[Dict[str, Any]]:
        """Get quality data for last 24 hours"""
        # This would load from actual quality assessment data
        return []


class AlertManager:
    """Manages alerts and notifications"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.active_alerts: List[Alert] = []
        self.alert_history: deque = deque(maxlen=1000)
        self.logger = logging.getLogger(__name__)
        
    def check_cost_thresholds(self, metrics: List[Metric]) -> List[Alert]:
        """Check for cost-related threshold violations"""
        alerts = []
        
        # Find budget utilization metric
        budget_metric = next((m for m in metrics if m.name == "budget_utilization"), None)
        if not budget_metric:
            return alerts
            
        utilization = budget_metric.value
        
        # Check thresholds
        if utilization >= 100:
            alerts.append(Alert(
                level="critical",
                title="Budget Exceeded",
                message=f"Episode budget exceeded: {utilization:.1f}% used",
                timestamp=datetime.now(),
                component="cost_control",
                details={"utilization": utilization, "threshold": 100}
            ))
        elif utilization >= 90:
            alerts.append(Alert(
                level="warning",
                title="Budget Warning",
                message=f"Episode budget warning: {utilization:.1f}% used",
                timestamp=datetime.now(),
                component="cost_control",
                details={"utilization": utilization, "threshold": 90}
            ))
        elif utilization >= 75:
            alerts.append(Alert(
                level="info",
                title="Budget Alert",
                message=f"Episode budget alert: {utilization:.1f}% used",
                timestamp=datetime.now(),
                component="cost_control",
                details={"utilization": utilization, "threshold": 75}
            ))
        
        return alerts
        
    def check_quality_thresholds(self, metrics: List[Metric]) -> List[Alert]:
        """Check for quality threshold violations"""
        alerts = []
        
        # Check average quality
        quality_metric = next((m for m in metrics if m.name == "average_quality_24h"), None)
        if quality_metric and quality_metric.value < 8.0:
            alerts.append(Alert(
                level="warning",
                title="Quality Degradation",
                message=f"Average quality below threshold: {quality_metric.value:.1f}",
                timestamp=datetime.now(),
                component="quality_control",
                details={"current_score": quality_metric.value, "threshold": 8.0}
            ))
        
        return alerts
        
    def check_performance_thresholds(self, metrics: List[Metric]) -> List[Alert]:
        """Check for performance issues"""
        alerts = []
        
        # Check system resources
        for metric in metrics:
            if metric.name == "cpu_usage" and metric.value > 90:
                alerts.append(Alert(
                    level="warning",
                    title="High CPU Usage",
                    message=f"CPU usage: {metric.value:.1f}%",
                    timestamp=datetime.now(),
                    component="system_performance",
                    details={"cpu_usage": metric.value}
                ))
            elif metric.name == "memory_usage" and metric.value > 90:
                alerts.append(Alert(
                    level="warning",
                    title="High Memory Usage",
                    message=f"Memory usage: {metric.value:.1f}%",
                    timestamp=datetime.now(),
                    component="system_performance",
                    details={"memory_usage": metric.value}
                ))
            elif metric.name == "disk_usage" and metric.value > 90:
                alerts.append(Alert(
                    level="critical",
                    title="Low Disk Space",
                    message=f"Disk usage: {metric.value:.1f}%",
                    timestamp=datetime.now(),
                    component="system_performance",
                    details={"disk_usage": metric.value}
                ))
        
        return alerts
        
    def process_alerts(self, new_alerts: List[Alert]) -> None:
        """Process new alerts and send notifications"""
        for alert in new_alerts:
            # Check if alert is already active
            if not self._is_duplicate_alert(alert):
                self.active_alerts.append(alert)
                self.alert_history.append(alert)
                self._send_notification(alert)
                
    def _is_duplicate_alert(self, alert: Alert) -> bool:
        """Check if alert is a duplicate of an existing active alert"""
        for active_alert in self.active_alerts:
            if (active_alert.title == alert.title and 
                active_alert.component == alert.component and
                not active_alert.resolved):
                return True
        return False
        
    def _send_notification(self, alert: Alert) -> None:
        """Send alert notification via configured channels"""
        self.logger.info(f"Alert: {alert.level.upper()} - {alert.title}: {alert.message}")
        
        # Email notification
        if self.config.get("alerts", {}).get("channels", {}).get("email", {}).get("enabled"):
            self._send_email_alert(alert)
        
        # Slack notification
        if self.config.get("alerts", {}).get("channels", {}).get("slack", {}).get("enabled"):
            self._send_slack_alert(alert)
        
        # Discord notification
        if self.config.get("alerts", {}).get("channels", {}).get("discord", {}).get("enabled"):
            self._send_discord_alert(alert)
            
    def _send_email_alert(self, alert: Alert) -> None:
        """Send email alert notification"""
        # Implementation would use SMTP to send email
        self.logger.debug(f"Would send email alert: {alert.title}")
        
    def _send_slack_alert(self, alert: Alert) -> None:
        """Send Slack alert notification"""
        webhook_url = os.getenv("SLACK_WEBHOOK")
        if not webhook_url:
            return
            
        color = {"info": "good", "warning": "warning", "critical": "danger"}.get(alert.level, "good")
        
        payload = {
            "attachments": [{
                "color": color,
                "title": f"🎧 Podcast Production Alert: {alert.title}",
                "text": alert.message,
                "fields": [
                    {"title": "Level", "value": alert.level.upper(), "short": True},
                    {"title": "Component", "value": alert.component, "short": True},
                    {"title": "Time", "value": alert.timestamp.strftime("%Y-%m-%d %H:%M:%S"), "short": True}
                ]
            }]
        }
        
        try:
            response = requests.post(webhook_url, json=payload, timeout=10)
            if response.status_code == 200:
                self.logger.debug("Slack alert sent successfully")
            else:
                self.logger.error(f"Failed to send Slack alert: {response.status_code}")
        except Exception as e:
            self.logger.error(f"Error sending Slack alert: {e}")
            
    def _send_discord_alert(self, alert: Alert) -> None:
        """Send Discord alert notification"""
        webhook_url = os.getenv("DISCORD_WEBHOOK")
        if not webhook_url:
            return
            
        color = {"info": 0x00ff00, "warning": 0xffaa00, "critical": 0xff0000}.get(alert.level, 0x00ff00)
        
        payload = {
            "embeds": [{
                "title": f"🎧 Podcast Production Alert",
                "description": alert.message,
                "color": color,
                "fields": [
                    {"name": "Alert", "value": alert.title, "inline": True},
                    {"name": "Level", "value": alert.level.upper(), "inline": True},
                    {"name": "Component", "value": alert.component, "inline": True}
                ],
                "timestamp": alert.timestamp.isoformat()
            }]
        }
        
        try:
            response = requests.post(webhook_url, json=payload, timeout=10)
            if response.status_code in [200, 204]:
                self.logger.debug("Discord alert sent successfully")
            else:
                self.logger.error(f"Failed to send Discord alert: {response.status_code}")
        except Exception as e:
            self.logger.error(f"Error sending Discord alert: {e}")


class ProductionMonitor:
    """Main production monitoring system"""
    
    def __init__(self, config_path: str = "config/production_config.yaml"):
        self.config = self._load_config(config_path)
        self.logger = self._setup_logging()
        
        # Initialize components
        self.metrics_collector = MetricsCollector()
        self.alert_manager = AlertManager(self.config)
        
        # Monitoring state
        self.running = False
        self.metrics_history: deque = deque(maxlen=10000)
        self.last_health_check = None
        
        # Monitoring intervals (seconds)
        self.intervals = {
            "fast_metrics": 30,
            "slow_metrics": 300,
            "health_check": 60,
            "alert_check": 15
        }
        
    def _load_config(self, config_path: str) -> Dict[str, Any]:
        """Load monitoring configuration"""
        try:
            with open(config_path, 'r') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"Error loading config: {e}")
            return {}
            
    def _setup_logging(self) -> logging.Logger:
        """Setup logging for monitoring system"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('logs/production_monitor.log'),
                logging.StreamHandler()
            ]
        )
        return logging.getLogger(__name__)
        
    async def collect_fast_metrics(self) -> List[Metric]:
        """Collect fast-updating metrics"""
        metrics = []
        
        # System performance metrics
        metrics.extend(self.metrics_collector.collect_performance_metrics())
        
        return metrics
        
    async def collect_slow_metrics(self) -> List[Metric]:
        """Collect slow-updating metrics"""
        metrics = []
        
        # Cost metrics
        metrics.extend(self.metrics_collector.collect_cost_metrics())
        
        # Quality metrics
        metrics.extend(self.metrics_collector.collect_quality_metrics())
        
        return metrics
        
    async def health_check(self) -> SystemStatus:
        """Perform comprehensive system health check"""
        now = datetime.now()
        
        # Collect current metrics
        all_metrics = []
        all_metrics.extend(await self.collect_fast_metrics())
        all_metrics.extend(await self.collect_slow_metrics())
        
        # Store metrics
        self.metrics_history.extend(all_metrics)
        
        # Check for alerts
        cost_alerts = self.alert_manager.check_cost_thresholds(all_metrics)
        quality_alerts = self.alert_manager.check_quality_thresholds(all_metrics)
        performance_alerts = self.alert_manager.check_performance_thresholds(all_metrics)
        
        all_alerts = cost_alerts + quality_alerts + performance_alerts
        self.alert_manager.process_alerts(all_alerts)
        
        # Determine overall status
        critical_alerts = [a for a in self.alert_manager.active_alerts if a.level == "critical" and not a.resolved]
        warning_alerts = [a for a in self.alert_manager.active_alerts if a.level == "warning" and not a.resolved]
        
        if critical_alerts:
            overall_status = "critical"
        elif warning_alerts:
            overall_status = "warning"
        else:
            overall_status = "healthy"
        
        # Extract key metrics
        episode_count = next((m.value for m in all_metrics if m.name == "episode_count"), 0)
        total_cost = next((m.value for m in all_metrics if m.name == "total_cost"), 0)
        avg_quality = next((m.value for m in all_metrics if m.name == "average_quality_24h"), 0)
        
        # Performance metrics summary
        performance_metrics = {}
        for metric in all_metrics:
            if metric.tags.get("type") == "system":
                performance_metrics[metric.name] = metric.value
        
        status = SystemStatus(
            timestamp=now,
            overall_status=overall_status,
            episode_count_24h=int(episode_count),
            total_cost_24h=total_cost,
            average_quality_24h=avg_quality,
            active_alerts=[a for a in self.alert_manager.active_alerts if not a.resolved],
            performance_metrics=performance_metrics
        )
        
        self.last_health_check = status
        return status
        
    def save_health_report(self, status: SystemStatus) -> str:
        """Save health check report to file"""
        timestamp = status.timestamp.strftime("%Y%m%d_%H%M%S")
        report_path = f"logs/health_checks/health_{timestamp}.json"
        
        # Ensure directory exists
        Path("logs/health_checks").mkdir(parents=True, exist_ok=True)
        
        # Convert to JSON-serializable format
        status_dict = asdict(status)
        status_dict["timestamp"] = status.timestamp.isoformat()
        for alert in status_dict["active_alerts"]:
            alert["timestamp"] = alert["timestamp"].isoformat()
        
        with open(report_path, 'w') as f:
            json.dump(status_dict, f, indent=2)
        
        return report_path
        
    async def monitoring_loop(self) -> None:
        """Main monitoring loop"""
        self.logger.info("Starting monitoring loop...")
        
        last_fast_check = 0
        last_slow_check = 0
        last_health_check = 0
        last_alert_check = 0
        
        while self.running:
            current_time = time.time()
            
            try:
                # Fast metrics collection
                if current_time - last_fast_check >= self.intervals["fast_metrics"]:
                    fast_metrics = await self.collect_fast_metrics()
                    self.metrics_history.extend(fast_metrics)
                    last_fast_check = current_time
                
                # Slow metrics collection
                if current_time - last_slow_check >= self.intervals["slow_metrics"]:
                    slow_metrics = await self.collect_slow_metrics()
                    self.metrics_history.extend(slow_metrics)
                    last_slow_check = current_time
                
                # Health check
                if current_time - last_health_check >= self.intervals["health_check"]:
                    status = await self.health_check()
                    report_path = self.save_health_report(status)
                    self.logger.info(f"Health check complete: {status.overall_status} (saved to {report_path})")
                    last_health_check = current_time
                
                # Alert processing
                if current_time - last_alert_check >= self.intervals["alert_check"]:
                    # Process any pending alerts
                    last_alert_check = current_time
                
            except Exception as e:
                self.logger.error(f"Error in monitoring loop: {e}")
            
            # Sleep briefly to avoid busy waiting
            await asyncio.sleep(1)
            
    def start_monitoring(self, mode: str = "continuous") -> None:
        """Start the monitoring system"""
        self.running = True
        self.logger.info(f"Starting production monitoring in {mode} mode...")
        
        if mode == "continuous":
            asyncio.run(self.monitoring_loop())
        elif mode == "once":
            asyncio.run(self._run_once())
        else:
            raise ValueError(f"Unknown monitoring mode: {mode}")
            
    async def _run_once(self) -> None:
        """Run monitoring once and exit"""
        status = await self.health_check()
        report_path = self.save_health_report(status)
        
        print(f"\n{'='*60}")
        print("PRODUCTION SYSTEM HEALTH CHECK")
        print(f"{'='*60}")
        print(f"Timestamp: {status.timestamp.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Status: {status.overall_status.upper()}")
        print(f"Episodes (24h): {status.episode_count_24h}")
        print(f"Cost (24h): ${status.total_cost_24h:.4f}")
        print(f"Quality (24h): {status.average_quality_24h:.1f}")
        print(f"Active Alerts: {len(status.active_alerts)}")
        
        if status.active_alerts:
            print(f"\nALERTS:")
            for alert in status.active_alerts:
                print(f"  {alert.level.upper()}: {alert.title} - {alert.message}")
        
        print(f"\nPerformance:")
        for metric_name, value in status.performance_metrics.items():
            unit = "%" if "usage" in metric_name else "GB"
            print(f"  {metric_name}: {value:.1f}{unit}")
        
        print(f"\nDetailed report: {report_path}")
        print(f"{'='*60}\n")
        
    def stop_monitoring(self) -> None:
        """Stop the monitoring system"""
        self.running = False
        self.logger.info("Monitoring system stopped")
        
    def get_current_status(self) -> Optional[SystemStatus]:
        """Get current system status"""
        return self.last_health_check


def main():
    """Main entry point for production monitor"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="AI Podcast Production - Production Monitoring System"
    )
    parser.add_argument(
        "--mode",
        choices=["continuous", "once", "daemon"],
        default="once",
        help="Monitoring mode"
    )
    parser.add_argument(
        "--config",
        default="config/production_config.yaml",
        help="Path to configuration file"
    )
    parser.add_argument(
        "--interval",
        type=int,
        default=60,
        help="Monitoring interval in seconds"
    )
    
    args = parser.parse_args()
    
    # Initialize monitor
    monitor = ProductionMonitor(args.config)
    
    print(f"""
    ╔══════════════════════════════════════════════════════════════╗
    ║                 AI PODCAST PRODUCTION SYSTEM                ║
    ║                Production Monitoring v1.0.0                 ║
    ╠══════════════════════════════════════════════════════════════╣
    ║ Mode: {args.mode:<15} Config: {args.config:<25} ║
    ║ Interval: {args.interval:<10} seconds                              ║
    ╚══════════════════════════════════════════════════════════════╝
    """)
    
    try:
        monitor.start_monitoring(args.mode)
    except KeyboardInterrupt:
        monitor.stop_monitoring()
        print("\nMonitoring stopped by user")
    except Exception as e:
        print(f"Monitoring error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()