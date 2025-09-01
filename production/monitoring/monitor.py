#!/usr/bin/env python3
"""
Production Monitoring System
Continuous monitoring with alerting for the AI Podcast Production System.
"""

import asyncio
import json
import time
import smtplib
import requests
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timezone, timedelta
from pathlib import Path
import logging
import os
import sys

# Add project paths
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

# Setup logging
log_dir = project_root / "production" / "logs"
log_dir.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_dir / "monitoring.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class SystemMonitor:
    """System monitoring with alerting."""

    def __init__(self):
        self.health_check_interval = 300  # 5 minutes
        self.alert_cooldown = 1800  # 30 minutes
        self.last_alerts = {}
        self.consecutive_failures = {}

        # Load configuration
        self._load_config()

    def _load_config(self):
        """Load monitoring configuration."""
        env_files = ['.env.production', '.env.development']

        for env_file in env_files:
            env_path = project_root / env_file
            if env_path.exists():
                with open(env_path, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith('#') and '=' in line:
                            key, value = line.split('=', 1)
                            os.environ.setdefault(key.strip(), value.strip())
                break

    async def run_health_check(self):
        """Run health check using the health check system."""
        try:
            # Import and run health checker
            sys.path.append(str(project_root / "production" / "health"))
            from health_check import SystemHealthChecker

            health_checker = SystemHealthChecker()
            report = await health_checker.run_all_checks()

            return report

        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return {
                'overall_status': 'unhealthy',
                'error': str(e),
                'timestamp': datetime.now(timezone.utc).isoformat()
            }

    def should_send_alert(self, component: str) -> bool:
        """Check if we should send an alert for this component."""
        now = datetime.now(timezone.utc)
        last_alert_time = self.last_alerts.get(component)

        if not last_alert_time:
            return True

        return now - last_alert_time > timedelta(seconds=self.alert_cooldown)

    def send_email_alert(self, subject: str, body: str):
        """Send email alert."""
        try:
            smtp_host = os.getenv('SMTP_HOST')
            smtp_port = int(os.getenv('SMTP_PORT', '587'))
            smtp_username = os.getenv('SMTP_USERNAME')
            smtp_password = os.getenv('SMTP_PASSWORD')
            smtp_tls = os.getenv('SMTP_TLS_ENABLED', 'true').lower() == 'true'

            if not all([smtp_host, smtp_username, smtp_password]):
                logger.warning("Email configuration incomplete, skipping email alert")
                return

            msg = MIMEMultipart()
            msg['From'] = smtp_username
            msg['To'] = smtp_username  # Send to self for now
            msg['Subject'] = f"[AI Podcast Production] {subject}"

            msg.attach(MIMEText(body, 'plain'))

            with smtplib.SMTP(smtp_host, smtp_port) as server:
                if smtp_tls:
                    server.starttls()
                server.login(smtp_username, smtp_password)
                server.send_message(msg)

            logger.info(f"Email alert sent: {subject}")

        except Exception as e:
            logger.error(f"Failed to send email alert: {e}")

    def send_webhook_alert(self, webhook_url: str, data: dict):
        """Send webhook alert."""
        try:
            response = requests.post(
                webhook_url,
                json=data,
                timeout=10,
                headers={'Content-Type': 'application/json'}
            )
            response.raise_for_status()
            logger.info(f"Webhook alert sent to {webhook_url}")

        except Exception as e:
            logger.error(f"Failed to send webhook alert to {webhook_url}: {e}")

    def process_alerts(self, health_report: dict):
        """Process health report and send alerts as needed."""
        overall_status = health_report.get('overall_status', 'unknown')

        # Check for overall system issues
        if overall_status in ['unhealthy', 'degraded']:
            if self.should_send_alert('system_overall'):
                subject = f"System Status Alert: {overall_status.title()}"
                body = f"""
AI Podcast Production System Alert

Overall Status: {overall_status.title()}
Health Percentage: {health_report.get('summary', {}).get('health_percentage', 0)}%
Timestamp: {health_report.get('timestamp')}

Components with issues:
"""

                for component in health_report.get('components', []):
                    if component['status'] != 'healthy':
                        body += f"- {component['component']}: {component['status']}"
                        if component.get('error'):
                            body += f" ({component['error']})"
                        body += "\n"

                # Send email alert
                if os.getenv('ENABLE_ERROR_NOTIFICATIONS', 'false').lower() == 'true':
                    self.send_email_alert(subject, body)

                # Send webhook alert
                error_webhook = os.getenv('WEBHOOK_ERROR_URL')
                if error_webhook:
                    webhook_data = {
                        'type': 'system_alert',
                        'status': overall_status,
                        'health_percentage': health_report.get('summary', {}).get('health_percentage', 0),
                        'timestamp': health_report.get('timestamp'),
                        'components': health_report.get('components', [])
                    }
                    self.send_webhook_alert(error_webhook, webhook_data)

                self.last_alerts['system_overall'] = datetime.now(timezone.utc)
                logger.warning(f"System alert sent: {overall_status}")

        # Check individual components
        for component in health_report.get('components', []):
            if component['status'] == 'unhealthy':
                component_name = component['component']
                if self.should_send_alert(component_name):
                    subject = f"Component Failure: {component_name}"
                    body = f"""
Component: {component_name}
Status: {component['status']}
Error: {component.get('error', 'Unknown error')}
Response Time: {component['response_time_ms']}ms
Timestamp: {component['timestamp']}
                    """

                    if os.getenv('ENABLE_ERROR_NOTIFICATIONS', 'false').lower() == 'true':
                        self.send_email_alert(subject, body)

                    self.last_alerts[component_name] = datetime.now(timezone.utc)
                    logger.error(f"Component alert sent: {component_name}")

    def save_metrics(self, health_report: dict):
        """Save metrics for historical tracking."""
        metrics_dir = project_root / "production" / "metrics"
        metrics_dir.mkdir(parents=True, exist_ok=True)

        # Save daily metrics
        today = datetime.now(timezone.utc).strftime('%Y-%m-%d')
        metrics_file = metrics_dir / f"metrics_{today}.jsonl"

        # Create metrics entry
        metrics_entry = {
            'timestamp': health_report.get('timestamp'),
            'overall_status': health_report.get('overall_status'),
            'health_percentage': health_report.get('summary', {}).get('health_percentage', 0),
            'total_checks': health_report.get('summary', {}).get('total_checks', 0),
            'healthy': health_report.get('summary', {}).get('healthy', 0),
            'degraded': health_report.get('summary', {}).get('degraded', 0),
            'unhealthy': health_report.get('summary', {}).get('unhealthy', 0),
            'response_time_ms': health_report.get('total_response_time_ms', 0)
        }

        # Append to daily metrics file
        with open(metrics_file, 'a') as f:
            f.write(json.dumps(metrics_entry) + '\n')

    async def monitoring_loop(self):
        """Main monitoring loop."""
        logger.info("🔍 Starting system monitoring...")

        while True:
            try:
                # Run health check
                health_report = await self.run_health_check()

                # Process alerts
                self.process_alerts(health_report)

                # Save metrics
                self.save_metrics(health_report)

                # Log status
                overall_status = health_report.get('overall_status', 'unknown')
                health_percentage = health_report.get('summary', {}).get('health_percentage', 0)
                logger.info(f"Health check completed: {overall_status} ({health_percentage}%)")

                # Wait for next check
                await asyncio.sleep(self.health_check_interval)

            except Exception as e:
                logger.error(f"Monitoring loop error: {e}")
                await asyncio.sleep(60)  # Wait 1 minute before retrying

    async def run_once(self):
        """Run monitoring check once."""
        health_report = await self.run_health_check()
        self.process_alerts(health_report)
        self.save_metrics(health_report)
        return health_report

async def main():
    """Main monitoring execution."""
    monitor = SystemMonitor()

    # Check if we should run once or continuously
    if len(sys.argv) > 1 and sys.argv[1] == '--once':
        report = await monitor.run_once()
        print(json.dumps(report, indent=2))
    else:
        # Run continuous monitoring
        await monitor.monitoring_loop()

if __name__ == "__main__":
    asyncio.run(main())
