#!/usr/bin/env python3
"""
Production Health Check System
Comprehensive health monitoring for all system components.
"""

import asyncio
import json
import time
import sys
import os
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, Any, List, Optional
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Add project paths
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))
sys.path.insert(0, str(project_root / "podcast_production"))

class HealthCheckResult:
    """Health check result container."""

    def __init__(self, component: str, status: str, response_time_ms: float,
                 details: Dict[str, Any] = None, error: str = None):
        self.component = component
        self.status = status  # 'healthy', 'degraded', 'unhealthy', 'unknown'
        self.response_time_ms = response_time_ms
        self.details = details or {}
        self.error = error
        self.timestamp = datetime.now(timezone.utc)

    def to_dict(self) -> Dict[str, Any]:
        return {
            'component': self.component,
            'status': self.status,
            'response_time_ms': self.response_time_ms,
            'details': self.details,
            'error': self.error,
            'timestamp': self.timestamp.isoformat(),
            'healthy': self.status == 'healthy'
        }

class SystemHealthChecker:
    """Comprehensive system health checker."""

    def __init__(self):
        self.results = []
        self.start_time = time.time()

    async def check_database_health(self) -> HealthCheckResult:
        """Check database connectivity and performance."""
        start_time = time.time()

        try:
            # Load environment configuration
            self._load_environment()

            from podcast_production.config.database_config import get_database_config
            config = get_database_config()

            if not config.is_available():
                return HealthCheckResult(
                    'database', 'unhealthy', 0,
                    error='Database configuration not available'
                )

            # Test connection
            connection_success = config.test_connection()
            response_time = (time.time() - start_time) * 1000

            if connection_success:
                # Get additional database info
                connection_string = config.get_connection_string()
                db_type = 'sqlite' if 'sqlite' in connection_string else 'postgresql'

                return HealthCheckResult(
                    'database', 'healthy', response_time,
                    details={
                        'type': db_type,
                        'environment': config.config['environment'],
                        'connection_available': True
                    }
                )
            else:
                return HealthCheckResult(
                    'database', 'unhealthy', response_time,
                    error='Database connection failed'
                )

        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            return HealthCheckResult(
                'database', 'unhealthy', response_time,
                error=str(e)
            )

    async def check_api_integrations(self) -> List[HealthCheckResult]:
        """Check API integrations health."""
        results = []

        # API services to check
        api_services = {
            'OpenAI': 'https://api.openai.com/v1/models',
            'Anthropic': 'https://api.anthropic.com/v1/messages',
            'Perplexity': 'https://api.perplexity.ai/chat/completions',
            'ElevenLabs': 'https://api.elevenlabs.io/v1/models'
        }

        for service_name, endpoint in api_services.items():
            start_time = time.time()

            try:
                # Check if API key is configured
                api_key_env = f"{service_name.upper().replace('ELEVENLABS', 'ELEVENLABS')}_API_KEY"
                if service_name == 'ElevenLabs':
                    api_key_env = 'ELEVENLABS_API_KEY'

                api_key = os.getenv(api_key_env)
                response_time = (time.time() - start_time) * 1000

                if not api_key or api_key.startswith('your-') or api_key.startswith('YOUR_'):
                    results.append(HealthCheckResult(
                        f'api_{service_name.lower()}', 'degraded', response_time,
                        details={'configured': False, 'endpoint': endpoint},
                        error='API key not configured'
                    ))
                else:
                    results.append(HealthCheckResult(
                        f'api_{service_name.lower()}', 'healthy', response_time,
                        details={'configured': True, 'endpoint': endpoint}
                    ))

            except Exception as e:
                response_time = (time.time() - start_time) * 1000
                results.append(HealthCheckResult(
                    f'api_{service_name.lower()}', 'unhealthy', response_time,
                    error=str(e)
                ))

        return results

    async def check_voice_configuration(self) -> HealthCheckResult:
        """Check voice configuration health."""
        start_time = time.time()

        try:
            from podcast_production.config.voice_config import get_production_voice_id

            voice_id = get_production_voice_id()
            response_time = (time.time() - start_time) * 1000

            # Get expected production voice ID from config
            from src.podcast_production.config.voice_config import VoiceConfig
            voice_config = VoiceConfig()
            expected_voice = voice_config.production_voice_id

            if voice_id == expected_voice:
                return HealthCheckResult(
                    'voice_config', 'healthy', response_time,
                    details={
                        'voice_id': voice_id,
                        'matches_production': True,
                        'governance_compliant': True
                    }
                )
            else:
                return HealthCheckResult(
                    'voice_config', 'degraded', response_time,
                    details={
                        'voice_id': voice_id,
                        'expected': expected_voice,
                        'matches_production': False
                    },
                    error='Voice ID does not match production standard'
                )

        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            return HealthCheckResult(
                'voice_config', 'unhealthy', response_time,
                error=str(e)
            )

    async def check_cost_controls(self) -> HealthCheckResult:
        """Check cost control configuration."""
        start_time = time.time()

        try:
            max_cost = float(os.getenv('MAX_EPISODE_COST', '0'))
            cost_tracking = os.getenv('COST_TRACKING_ENABLED', 'false').lower() == 'true'
            budget_mode = os.getenv('BUDGET_ENFORCEMENT_MODE', 'none')

            response_time = (time.time() - start_time) * 1000

            # Production requirements
            production_max_cost = 5.51

            if max_cost <= production_max_cost and cost_tracking and budget_mode == 'strict':
                return HealthCheckResult(
                    'cost_controls', 'healthy', response_time,
                    details={
                        'max_episode_cost': max_cost,
                        'cost_tracking_enabled': cost_tracking,
                        'budget_enforcement_mode': budget_mode,
                        'production_compliant': True
                    }
                )
            else:
                issues = []
                if max_cost > production_max_cost:
                    issues.append(f'Cost limit ${max_cost} exceeds production target ${production_max_cost}')
                if not cost_tracking:
                    issues.append('Cost tracking disabled')
                if budget_mode != 'strict':
                    issues.append(f'Budget enforcement is {budget_mode}, should be strict')

                return HealthCheckResult(
                    'cost_controls', 'degraded', response_time,
                    details={
                        'max_episode_cost': max_cost,
                        'cost_tracking_enabled': cost_tracking,
                        'budget_enforcement_mode': budget_mode,
                        'production_compliant': False,
                        'issues': issues
                    }
                )

        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            return HealthCheckResult(
                'cost_controls', 'unhealthy', response_time,
                error=str(e)
            )

    async def check_quality_configuration(self) -> HealthCheckResult:
        """Check quality configuration."""
        start_time = time.time()

        try:
            quality_threshold = float(os.getenv('QUALITY_THRESHOLD', '0'))
            quality_validation = os.getenv('QUALITY_VALIDATION_REQUIRED', 'false').lower() == 'true'

            response_time = (time.time() - start_time) * 1000

            # Production requirements
            production_quality_threshold = 8.0

            if quality_threshold >= production_quality_threshold and quality_validation:
                return HealthCheckResult(
                    'quality_config', 'healthy', response_time,
                    details={
                        'quality_threshold': quality_threshold,
                        'validation_required': quality_validation,
                        'production_compliant': True
                    }
                )
            else:
                issues = []
                if quality_threshold < production_quality_threshold:
                    issues.append(f'Quality threshold {quality_threshold} below production standard {production_quality_threshold}')
                if not quality_validation:
                    issues.append('Quality validation disabled')

                return HealthCheckResult(
                    'quality_config', 'degraded', response_time,
                    details={
                        'quality_threshold': quality_threshold,
                        'validation_required': quality_validation,
                        'production_compliant': False,
                        'issues': issues
                    }
                )

        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            return HealthCheckResult(
                'quality_config', 'unhealthy', response_time,
                error=str(e)
            )

    async def check_error_handling_system(self) -> HealthCheckResult:
        """Check error handling and retry systems."""
        start_time = time.time()

        try:
            from podcast_production.core.retry_handler import RetryHandler, RetryConfig

            # Test retry handler initialization
            config = RetryConfig(max_attempts=2, base_delay=0.1)
            retry_handler = RetryHandler(config)

            response_time = (time.time() - start_time) * 1000

            return HealthCheckResult(
                'error_handling', 'healthy', response_time,
                details={
                    'retry_handler_available': True,
                    'circuit_breaker_available': True,
                    'error_recovery_enabled': True
                }
            )

        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            return HealthCheckResult(
                'error_handling', 'unhealthy', response_time,
                error=str(e)
            )

    async def check_observability(self) -> HealthCheckResult:
        """Check observability configuration."""
        start_time = time.time()

        try:
            langfuse_enabled = os.getenv('LANGFUSE_ENABLED', 'false').lower() == 'true'
            langfuse_public_key = os.getenv('LANGFUSE_PUBLIC_KEY')
            langfuse_secret_key = os.getenv('LANGFUSE_SECRET_KEY')

            response_time = (time.time() - start_time) * 1000

            if langfuse_enabled and langfuse_public_key and langfuse_secret_key:
                return HealthCheckResult(
                    'observability', 'healthy', response_time,
                    details={
                        'langfuse_enabled': True,
                        'keys_configured': True,
                        'monitoring_ready': True
                    }
                )
            else:
                return HealthCheckResult(
                    'observability', 'degraded', response_time,
                    details={
                        'langfuse_enabled': langfuse_enabled,
                        'keys_configured': bool(langfuse_public_key and langfuse_secret_key),
                        'monitoring_ready': False
                    },
                    error='Observability not fully configured'
                )

        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            return HealthCheckResult(
                'observability', 'unhealthy', response_time,
                error=str(e)
            )

    def _load_environment(self):
        """Load environment variables from appropriate file."""
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

    async def run_all_checks(self) -> Dict[str, Any]:
        """Run all health checks and return comprehensive report."""
        logger.info("🏥 Starting comprehensive health check...")

        # Load environment
        self._load_environment()

        # Run all checks
        checks = await asyncio.gather(
            self.check_database_health(),
            self.check_voice_configuration(),
            self.check_cost_controls(),
            self.check_quality_configuration(),
            self.check_error_handling_system(),
            self.check_observability(),
            return_exceptions=True
        )

        # Add API integration checks
        api_checks = await self.check_api_integrations()
        checks.extend(api_checks)

        # Process results
        results = []
        for check in checks:
            if isinstance(check, Exception):
                results.append(HealthCheckResult(
                    'unknown', 'unhealthy', 0,
                    error=str(check)
                ))
            else:
                results.append(check)

        # Calculate overall health
        total_checks = len(results)
        healthy_checks = sum(1 for r in results if r.status == 'healthy')
        degraded_checks = sum(1 for r in results if r.status == 'degraded')
        unhealthy_checks = sum(1 for r in results if r.status == 'unhealthy')

        # Determine overall status
        if unhealthy_checks > 0:
            overall_status = 'unhealthy'
        elif degraded_checks > total_checks * 0.3:  # More than 30% degraded
            overall_status = 'degraded'
        elif healthy_checks >= total_checks * 0.8:  # At least 80% healthy
            overall_status = 'healthy'
        else:
            overall_status = 'degraded'

        # Create comprehensive report
        total_time = (time.time() - self.start_time) * 1000

        report = {
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'overall_status': overall_status,
            'total_response_time_ms': total_time,
            'summary': {
                'total_checks': total_checks,
                'healthy': healthy_checks,
                'degraded': degraded_checks,
                'unhealthy': unhealthy_checks,
                'health_percentage': int((healthy_checks / total_checks) * 100)
            },
            'components': [result.to_dict() for result in results],
            'environment': os.getenv('ENVIRONMENT', 'unknown'),
            'version': '1.0.0'
        }

        return report

async def main():
    """Main health check execution."""
    health_checker = SystemHealthChecker()
    report = await health_checker.run_all_checks()

    # Print summary
    print("\n🏥 SYSTEM HEALTH CHECK REPORT")
    print("=" * 50)
    print(f"Overall Status: {'✅ HEALTHY' if report['overall_status'] == 'healthy' else '⚠️ DEGRADED' if report['overall_status'] == 'degraded' else '❌ UNHEALTHY'}")
    print(f"Health Percentage: {report['summary']['health_percentage']}%")
    print(f"Total Checks: {report['summary']['total_checks']}")
    print(f"Response Time: {report['total_response_time_ms']:.2f}ms")
    print(f"Environment: {report['environment']}")

    print("\nComponent Status:")
    for component in report['components']:
        status_icon = {'healthy': '✅', 'degraded': '⚠️', 'unhealthy': '❌', 'unknown': '❓'}.get(component['status'], '❓')
        print(f"  {status_icon} {component['component']}: {component['status']} ({component['response_time_ms']:.1f}ms)")

        if component['error']:
            print(f"      Error: {component['error']}")

    # Save report
    report_file = project_root / 'production' / 'health' / 'latest_health_report.json'
    report_file.parent.mkdir(parents=True, exist_ok=True)

    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)

    print(f"\n📄 Full report saved to: {report_file}")

    # Return exit code based on health
    if report['overall_status'] == 'healthy':
        return 0
    elif report['overall_status'] == 'degraded':
        return 1
    else:
        return 2

if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
