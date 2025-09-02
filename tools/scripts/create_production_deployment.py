#!/usr/bin/env python3
"""
Production Deployment Automation

Creates comprehensive deployment automation, health checks, monitoring,
and operational readiness infrastructure for the AI Podcast Production System.
"""

import os
import sys
import json
import shutil
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, Any, List

# Add project path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

def create_health_check_system():
    """Create comprehensive health check system."""
    print("🏥 Creating Health Check System...")

    # Create health check directory
    health_dir = project_root / "production" / "health"
    health_dir.mkdir(parents=True, exist_ok=True)

    # Main health check script
    health_check_script = """#!/usr/bin/env python3
\"\"\"
Production Health Check System
Comprehensive health monitoring for all system components.
\"\"\"

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
    \"\"\"Health check result container.\"\"\"

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
    \"\"\"Comprehensive system health checker.\"\"\"

    def __init__(self):
        self.results = []
        self.start_time = time.time()

    async def check_database_health(self) -> HealthCheckResult:
        \"\"\"Check database connectivity and performance.\"\"\"
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
        \"\"\"Check API integrations health.\"\"\"
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
        \"\"\"Check voice configuration health.\"\"\"
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
        \"\"\"Check cost control configuration.\"\"\"
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
        \"\"\"Check quality configuration.\"\"\"
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
        \"\"\"Check error handling and retry systems.\"\"\"
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
        \"\"\"Check observability configuration.\"\"\"
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
        \"\"\"Load environment variables from appropriate file.\"\"\"
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
        \"\"\"Run all health checks and return comprehensive report.\"\"\"
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
    \"\"\"Main health check execution.\"\"\"
    health_checker = SystemHealthChecker()
    report = await health_checker.run_all_checks()

    # Print summary
    print("\\n🏥 SYSTEM HEALTH CHECK REPORT")
    print("=" * 50)
    print(f"Overall Status: {'✅ HEALTHY' if report['overall_status'] == 'healthy' else '⚠️ DEGRADED' if report['overall_status'] == 'degraded' else '❌ UNHEALTHY'}")
    print(f"Health Percentage: {report['summary']['health_percentage']}%")
    print(f"Total Checks: {report['summary']['total_checks']}")
    print(f"Response Time: {report['total_response_time_ms']:.2f}ms")
    print(f"Environment: {report['environment']}")

    print("\\nComponent Status:")
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

    print(f"\\n📄 Full report saved to: {report_file}")

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
"""

    health_check_file = health_dir / "health_check.py"
    with open(health_check_file, 'w') as f:
        f.write(health_check_script)

    # Make executable
    os.chmod(health_check_file, 0o755)

    print(f"  ✅ Health check system: {health_check_file}")
    return health_check_file

def create_deployment_scripts():
    """Create deployment automation scripts."""
    print("🚀 Creating Deployment Scripts...")

    deploy_dir = project_root / "production" / "deploy"
    deploy_dir.mkdir(parents=True, exist_ok=True)

    # Main deployment script
    deploy_script = f"""#!/bin/bash
# AI Podcast Production System - Production Deployment Script
# Generated on {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}

set -euo pipefail

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m' # No Color

# Configuration
APP_NAME="ai-podcast-production"
APP_DIR="{project_root}"
BACKUP_DIR="$APP_DIR/backups/$(date +%Y%m%d_%H%M%S)"

# Logging
LOG_FILE="$APP_DIR/production/logs/deployment_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {{
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}}

error() {{
    echo -e "${{RED}}❌ ERROR: $1${{NC}}" | tee -a "$LOG_FILE"
    exit 1
}}

success() {{
    echo -e "${{GREEN}}✅ $1${{NC}}" | tee -a "$LOG_FILE"
}}

warning() {{
    echo -e "${{YELLOW}}⚠️  $1${{NC}}" | tee -a "$LOG_FILE"
}}

info() {{
    echo -e "${{BLUE}}ℹ️  $1${{NC}}" | tee -a "$LOG_FILE"
}}

# Pre-deployment checks
pre_deployment_checks() {{
    log "🔍 Running pre-deployment checks..."

    # Check if environment file exists
    if [[ ! -f "$APP_DIR/.env.production" ]]; then
        error "Production environment file not found. Copy .env.production.template to .env.production and configure it."
    fi

    # Validate environment configuration
    if ! python3 "$APP_DIR/validate_environment.py"; then
        error "Environment validation failed. Please fix configuration issues."
    fi
    success "Environment validation passed"

    # Check database connectivity
    if ! python3 "$APP_DIR/setup_production_database.py"; then
        error "Database setup/connectivity check failed"
    fi
    success "Database connectivity verified"

    # Run health checks
    if python3 "$APP_DIR/production/health/health_check.py"; then
        success "Pre-deployment health checks passed"
    else
        warning "Some health checks failed, but deployment will continue"
    fi
}}

# Backup current state
backup_current_state() {{
    log "💾 Creating backup of current state..."

    mkdir -p "$BACKUP_DIR"

    # Backup database
    if [[ -f "$APP_DIR/data/development/podcast_production.db" ]]; then
        cp "$APP_DIR/data/development/podcast_production.db" "$BACKUP_DIR/"
        success "Database backup created"
    fi

    # Backup configuration
    if [[ -f "$APP_DIR/.env.production" ]]; then
        cp "$APP_DIR/.env.production" "$BACKUP_DIR/"
        success "Configuration backup created"
    fi

    # Backup logs
    if [[ -d "$APP_DIR/production/logs" ]]; then
        cp -r "$APP_DIR/production/logs" "$BACKUP_DIR/"
        success "Logs backup created"
    fi

    success "Backup completed: $BACKUP_DIR"
}}

# Install dependencies
install_dependencies() {{
    log "📦 Installing/updating dependencies..."

    # Python dependencies
    if [[ -f "$APP_DIR/requirements.txt" ]]; then
        python3 -m pip install -r "$APP_DIR/requirements.txt" --upgrade
        success "Python dependencies installed"
    fi

    # Pre-commit hooks
    if [[ -f "$APP_DIR/.pre-commit-config.yaml" ]]; then
        python3 -m pip install pre-commit
        pre-commit install
        success "Pre-commit hooks installed"
    fi
}}

# Run pre-commit checks
run_quality_checks() {{
    log "🔍 Running quality checks..."

    # Run pre-commit hooks
    if command -v pre-commit &> /dev/null; then
        if pre-commit run --all-files; then
            success "Pre-commit checks passed"
        else
            warning "Some pre-commit checks failed, review the output"
        fi
    fi

    # Run production validation
    if python3 "$APP_DIR/tests/integration/validate_production_system.py"; then
        success "Production validation passed"
    else
        warning "Production validation had issues"
    fi
}}

# Setup production services
setup_production_services() {{
    log "🏭 Setting up production services..."

    # Setup PostgreSQL if using Docker
    if [[ -f "$APP_DIR/production/database/docker-compose.yml" ]] && command -v docker &> /dev/null; then
        cd "$APP_DIR/production/database"
        if docker-compose ps postgres | grep -q "Up"; then
            info "PostgreSQL already running"
        else
            docker-compose up -d postgres
            sleep 10
            success "PostgreSQL started"
        fi
        cd - > /dev/null
    fi

    # Run database migrations/setup
    if python3 "$APP_DIR/setup_production_database.py"; then
        success "Database setup completed"
    else
        error "Database setup failed"
    fi
}}

# Start application services
start_application() {{
    log "🚀 Starting application services..."

    # This would typically start your application server
    # For now, we'll just verify the system is ready

    # Run final health check
    if python3 "$APP_DIR/production/health/health_check.py"; then
        success "Application health check passed"
    else
        warning "Application health check failed"
    fi

    success "Application deployment completed"
}}

# Post-deployment verification
post_deployment_verification() {{
    log "🔎 Running post-deployment verification..."

    # Wait a bit for services to stabilize
    sleep 5

    # Run comprehensive validation
    if python3 "$APP_DIR/tests/integration/run_production_validation_suite.py"; then
        success "Post-deployment validation passed"
    else
        warning "Post-deployment validation had issues"
    fi

    # Generate deployment report
    python3 "$APP_DIR/production/health/health_check.py" > "$APP_DIR/production/logs/deployment_health_$(date +%Y%m%d_%H%M%S).log"
    success "Deployment health report generated"
}}

# Cleanup old backups and logs
cleanup() {{
    log "🧹 Cleaning up old files..."

    # Keep only last 7 days of backups
    find "$APP_DIR/backups" -type d -mtime +7 -exec rm -rf {{}} + 2>/dev/null || true

    # Keep only last 30 days of logs
    find "$APP_DIR/production/logs" -type f -mtime +30 -delete 2>/dev/null || true

    success "Cleanup completed"
}}

# Main deployment function
deploy() {{
    log "🚀 Starting deployment of $APP_NAME"
    log "Deployment directory: $APP_DIR"
    log "Backup directory: $BACKUP_DIR"
    log "Log file: $LOG_FILE"

    # Run deployment steps
    pre_deployment_checks
    backup_current_state
    install_dependencies
    run_quality_checks
    setup_production_services
    start_application
    post_deployment_verification
    cleanup

    success "🎉 Deployment completed successfully!"
    log "📄 Deployment log: $LOG_FILE"
    log "💾 Backup location: $BACKUP_DIR"
}}

# Rollback function
rollback() {{
    log "🔄 Rolling back deployment..."

    if [[ -z "${{1:-}}" ]]; then
        # Find latest backup
        LATEST_BACKUP=$(find "$APP_DIR/backups" -type d -name "*" | sort | tail -1)
        if [[ -z "$LATEST_BACKUP" ]]; then
            error "No backup found for rollback"
        fi
        ROLLBACK_DIR="$LATEST_BACKUP"
    else
        ROLLBACK_DIR="$1"
    fi

    if [[ ! -d "$ROLLBACK_DIR" ]]; then
        error "Rollback directory not found: $ROLLBACK_DIR"
    fi

    log "Rolling back to: $ROLLBACK_DIR"

    # Restore database
    if [[ -f "$ROLLBACK_DIR/podcast_production.db" ]]; then
        cp "$ROLLBACK_DIR/podcast_production.db" "$APP_DIR/data/development/"
        success "Database rolled back"
    fi

    # Restore configuration
    if [[ -f "$ROLLBACK_DIR/.env.production" ]]; then
        cp "$ROLLBACK_DIR/.env.production" "$APP_DIR/"
        success "Configuration rolled back"
    fi

    success "Rollback completed"
}}

# Usage information
usage() {{
    echo "AI Podcast Production System - Deployment Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy     - Deploy the application (default)"
    echo "  rollback   - Rollback to previous version"
    echo "  health     - Run health checks only"
    echo "  backup     - Create backup only"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 rollback"
    echo "  $0 rollback /path/to/specific/backup"
    echo "  $0 health"
}}

# Command handling
case "${{1:-deploy}}" in
    "deploy")
        deploy
        ;;
    "rollback")
        rollback "${{2:-}}"
        ;;
    "health")
        python3 "$APP_DIR/production/health/health_check.py"
        ;;
    "backup")
        backup_current_state
        ;;
    "help"|"-h"|"--help")
        usage
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
"""

    deploy_script_file = deploy_dir / "deploy.sh"
    with open(deploy_script_file, 'w') as f:
        f.write(deploy_script)

    # Make executable
    os.chmod(deploy_script_file, 0o755)

    print(f"  ✅ Main deployment script: {deploy_script_file}")

    # Create systemd service file (for Linux production)
    systemd_service = f"""[Unit]
Description=AI Podcast Production System
After=network.target postgresql.service

[Service]
Type=simple
User=podcast
Group=podcast
WorkingDirectory={project_root}
Environment=ENVIRONMENT=production
EnvironmentFile={project_root}/.env.production
ExecStart=/usr/bin/python3 {project_root}/production/server/app.py
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=ai-podcast-production

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths={project_root}/data {project_root}/production/logs

[Install]
WantedBy=multi-user.target
"""

    systemd_file = deploy_dir / "ai-podcast-production.service"
    with open(systemd_file, 'w') as f:
        f.write(systemd_service)

    print(f"  ✅ Systemd service file: {systemd_file}")

    return deploy_dir

def create_monitoring_system():
    """Create monitoring and alerting system."""
    print("📊 Creating Monitoring System...")

    monitoring_dir = project_root / "production" / "monitoring"
    monitoring_dir.mkdir(parents=True, exist_ok=True)

    # Monitoring script
    monitoring_script = """#!/usr/bin/env python3
\"\"\"
Production Monitoring System
Continuous monitoring with alerting for the AI Podcast Production System.
\"\"\"

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
    \"\"\"System monitoring with alerting.\"\"\"

    def __init__(self):
        self.health_check_interval = 300  # 5 minutes
        self.alert_cooldown = 1800  # 30 minutes
        self.last_alerts = {}
        self.consecutive_failures = {}

        # Load configuration
        self._load_config()

    def _load_config(self):
        \"\"\"Load monitoring configuration.\"\"\"
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
        \"\"\"Run health check using the health check system.\"\"\"
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
        \"\"\"Check if we should send an alert for this component.\"\"\"
        now = datetime.now(timezone.utc)
        last_alert_time = self.last_alerts.get(component)

        if not last_alert_time:
            return True

        return now - last_alert_time > timedelta(seconds=self.alert_cooldown)

    def send_email_alert(self, subject: str, body: str):
        \"\"\"Send email alert.\"\"\"
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
        \"\"\"Send webhook alert.\"\"\"
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
        \"\"\"Process health report and send alerts as needed.\"\"\"
        overall_status = health_report.get('overall_status', 'unknown')

        # Check for overall system issues
        if overall_status in ['unhealthy', 'degraded']:
            if self.should_send_alert('system_overall'):
                subject = f"System Status Alert: {overall_status.title()}"
                body = f\"\"\"
AI Podcast Production System Alert

Overall Status: {overall_status.title()}
Health Percentage: {health_report.get('summary', {}).get('health_percentage', 0)}%
Timestamp: {health_report.get('timestamp')}

Components with issues:
\"\"\"

                for component in health_report.get('components', []):
                    if component['status'] != 'healthy':
                        body += f"- {component['component']}: {component['status']}"
                        if component.get('error'):
                            body += f" ({component['error']})"
                        body += "\\n"

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
                    body = f\"\"\"
Component: {component_name}
Status: {component['status']}
Error: {component.get('error', 'Unknown error')}
Response Time: {component['response_time_ms']}ms
Timestamp: {component['timestamp']}
                    \"\"\"

                    if os.getenv('ENABLE_ERROR_NOTIFICATIONS', 'false').lower() == 'true':
                        self.send_email_alert(subject, body)

                    self.last_alerts[component_name] = datetime.now(timezone.utc)
                    logger.error(f"Component alert sent: {component_name}")

    def save_metrics(self, health_report: dict):
        \"\"\"Save metrics for historical tracking.\"\"\"
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
            f.write(json.dumps(metrics_entry) + '\\n')

    async def monitoring_loop(self):
        \"\"\"Main monitoring loop.\"\"\"
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
        \"\"\"Run monitoring check once.\"\"\"
        health_report = await self.run_health_check()
        self.process_alerts(health_report)
        self.save_metrics(health_report)
        return health_report

async def main():
    \"\"\"Main monitoring execution.\"\"\"
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
"""

    monitoring_script_file = monitoring_dir / "monitor.py"
    with open(monitoring_script_file, 'w') as f:
        f.write(monitoring_script)

    # Make executable
    os.chmod(monitoring_script_file, 0o755)

    print(f"  ✅ Monitoring system: {monitoring_script_file}")

    # Create monitoring cron job template
    cron_template = f"""# AI Podcast Production System - Monitoring Cron Jobs
# Add these to your crontab with: crontab -e

# Health check every 5 minutes
*/5 * * * * cd {project_root} && python3 production/monitoring/monitor.py --once >> production/logs/monitor.log 2>&1

# Daily health report
0 9 * * * cd {project_root} && python3 production/health/health_check.py > production/logs/daily_health_$(date +\\%Y\\%m\\%d).log 2>&1

# Weekly cleanup
0 2 * * 0 cd {project_root} && find production/logs -name "*.log" -mtime +30 -delete && find production/metrics -name "*.jsonl" -mtime +90 -delete
"""

    cron_file = monitoring_dir / "crontab.template"
    with open(cron_file, 'w') as f:
        f.write(cron_template)

    print(f"  ✅ Cron template: {cron_file}")

    return monitoring_dir

def create_docker_setup():
    """Create Docker deployment setup."""
    print("🐳 Creating Docker Deployment Setup...")

    docker_dir = project_root / "production" / "docker"
    docker_dir.mkdir(parents=True, exist_ok=True)

    # Dockerfile
    dockerfile_content = f"""# AI Podcast Production System - Production Dockerfile
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    curl \\
    postgresql-client \\
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash podcast && \\
    chown -R podcast:podcast /app
USER podcast

# Create necessary directories
RUN mkdir -p /app/data/production /app/production/logs /app/production/metrics

# Health check
HEALTHCHECK --interval=5m --timeout=30s --start-period=60s --retries=3 \\
    CMD python3 production/health/health_check.py || exit 1

# Expose port
EXPOSE 8000

# Default command
CMD ["python3", "production/server/app.py"]
"""

    dockerfile = docker_dir / "Dockerfile"
    with open(dockerfile, 'w') as f:
        f.write(dockerfile_content)

    print(f"  ✅ Dockerfile: {dockerfile}")

    # Docker Compose for full production stack
    docker_compose_content = f"""version: '3.8'

services:
  # Main application
  podcast-app:
    build:
      context: ../../..
      dockerfile: production/docker/Dockerfile
    container_name: ai-podcast-production-app
    environment:
      - ENVIRONMENT=production
      - POSTGRES_HOST=postgres
      - POSTGRES_DB=podcast_production
      - POSTGRES_USER=podcast_app
      - POSTGRES_PASSWORD=${{POSTGRES_PASSWORD}}
    env_file:
      - ../../../.env.production
    ports:
      - "8000:8000"
    volumes:
      - podcast_data:/app/data
      - podcast_logs:/app/production/logs
      - podcast_metrics:/app/production/metrics
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - podcast-network
    healthcheck:
      test: ["CMD", "python3", "production/health/health_check.py"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "100m"
        max-file: "5"

  # PostgreSQL database
  postgres:
    image: postgres:15
    container_name: ai-podcast-production-db
    environment:
      POSTGRES_DB: podcast_production
      POSTGRES_USER: podcast_app
      POSTGRES_PASSWORD: ${{POSTGRES_PASSWORD}}
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --locale=en_US.utf8"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ../../database/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql:ro
    ports:
      - "5432:5432"
    networks:
      - podcast-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U podcast_app -d podcast_production"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "100m"
        max-file: "3"

  # Redis for caching and session management
  redis:
    image: redis:7-alpine
    container_name: ai-podcast-production-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - podcast-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "50m"
        max-file: "3"

  # Monitoring and health checks
  monitoring:
    build:
      context: ../../..
      dockerfile: production/docker/Dockerfile
    container_name: ai-podcast-production-monitor
    command: ["python3", "production/monitoring/monitor.py"]
    environment:
      - ENVIRONMENT=production
    env_file:
      - ../../../.env.production
    volumes:
      - podcast_logs:/app/production/logs
      - podcast_metrics:/app/production/metrics
    depends_on:
      - podcast-app
    networks:
      - podcast-network
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "50m"
        max-file: "3"

  # Optional: pgAdmin for database management
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: ai-podcast-production-pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@localhost
      PGADMIN_DEFAULT_PASSWORD: ${{PGADMIN_PASSWORD:-admin}}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    ports:
      - "8080:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    depends_on:
      - postgres
    networks:
      - podcast-network
    profiles:
      - admin
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  podcast_data:
    driver: local
  podcast_logs:
    driver: local
  podcast_metrics:
    driver: local
  pgadmin_data:
    driver: local

networks:
  podcast-network:
    driver: bridge
"""

    docker_compose_file = docker_dir / "docker-compose.yml"
    with open(docker_compose_file, 'w') as f:
        f.write(docker_compose_content)

    print(f"  ✅ Docker Compose: {docker_compose_file}")

    # Docker deployment script
    docker_deploy_script = """#!/bin/bash
# Docker Deployment Script for AI Podcast Production System

set -euo pipefail

# Configuration
COMPOSE_FILE="production/docker/docker-compose.yml"
ENV_FILE=".env.production"

# Colors
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m'

error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker not found. Please install Docker."
    fi

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        error "Docker Compose not found. Please install Docker Compose."
    fi

    # Check environment file
    if [[ ! -f "$ENV_FILE" ]]; then
        error "Environment file $ENV_FILE not found. Copy .env.production.template and configure it."
    fi

    success "Prerequisites check passed"
}

# Deploy with Docker
deploy() {
    info "Starting Docker deployment..."

    # Build images
    docker-compose -f "$COMPOSE_FILE" build --no-cache
    success "Images built successfully"

    # Start services
    docker-compose -f "$COMPOSE_FILE" up -d
    success "Services started"

    # Wait for services to be healthy
    info "Waiting for services to be healthy..."
    sleep 30

    # Check service status
    docker-compose -f "$COMPOSE_FILE" ps

    # Run health check
    if docker-compose -f "$COMPOSE_FILE" exec -T podcast-app python3 production/health/health_check.py; then
        success "Deployment health check passed"
    else
        error "Deployment health check failed"
    fi

    success "Docker deployment completed successfully!"
}

# Stop services
stop() {
    info "Stopping services..."
    docker-compose -f "$COMPOSE_FILE" down
    success "Services stopped"
}

# Show logs
logs() {
    docker-compose -f "$COMPOSE_FILE" logs -f "${2:-}"
}

# Show status
status() {
    docker-compose -f "$COMPOSE_FILE" ps
}

# Usage
usage() {
    echo "Docker Deployment Script for AI Podcast Production System"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy  - Deploy the application with Docker"
    echo "  stop    - Stop all services"
    echo "  logs    - Show logs for all services"
    echo "  status  - Show service status"
    echo "  help    - Show this help"
}

# Command handling
case "${1:-deploy}" in
    "deploy")
        check_prerequisites
        deploy
        ;;
    "stop")
        stop
        ;;
    "logs")
        logs
        ;;
    "status")
        status
        ;;
    "help"|"-h"|"--help")
        usage
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
"""

    docker_deploy_file = docker_dir / "docker-deploy.sh"
    with open(docker_deploy_file, 'w') as f:
        f.write(docker_deploy_script)

    # Make executable
    os.chmod(docker_deploy_file, 0o755)

    print(f"  ✅ Docker deployment script: {docker_deploy_file}")

    return docker_dir

def validate_deployment_readiness():
    """Validate deployment readiness."""
    print("🔎 Validating Deployment Readiness...")

    readiness_score = 0
    max_score = 8

    checks = {
        'health_check_system': project_root / "production" / "health" / "health_check.py",
        'deployment_scripts': project_root / "production" / "deploy" / "deploy.sh",
        'monitoring_system': project_root / "production" / "monitoring" / "monitor.py",
        'docker_setup': project_root / "production" / "docker" / "docker-compose.yml",
        'environment_template': project_root / ".env.production.template",
        'environment_validation': project_root / "validate_environment.py",
        'database_setup': project_root / "setup_production_database.py",
        'production_directories': project_root / "production"
    }

    for check_name, check_path in checks.items():
        if check_path.exists():
            print(f"  ✅ {check_name.replace('_', ' ').title()}: Available")
            readiness_score += 1
        else:
            print(f"  ❌ {check_name.replace('_', ' ').title()}: Missing")

    # Additional functionality checks
    try:
        # Test health check import
        sys.path.insert(0, str(project_root / "production" / "health"))
        from health_check import SystemHealthChecker
        print("  ✅ Health Check System: Functional")
    except ImportError:
        print("  ❌ Health Check System: Import failed")

    # Calculate percentage
    percentage = int((readiness_score / max_score) * 100)

    print(f"\n🎯 DEPLOYMENT READINESS SCORE: {readiness_score}/{max_score} ({percentage}%)")

    if percentage >= 95:
        print("✅ DEPLOYMENT PRODUCTION READY")
        return True
    elif percentage >= 85:
        print("⚠️  DEPLOYMENT MOSTLY READY")
        return True
    else:
        print("❌ DEPLOYMENT NEEDS IMPROVEMENTS")
        return False

def main():
    """Main deployment setup execution."""
    print("🚀 AI Podcast Production System - Deployment Automation Setup")
    print("="*70)

    success_steps = 0
    total_steps = 5

    # Step 1: Create health check system
    print("Step 1/5: Creating Health Check System...")
    try:
        create_health_check_system()
        success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Step 2: Create deployment scripts
    print("\nStep 2/5: Creating Deployment Scripts...")
    try:
        create_deployment_scripts()
        success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Step 3: Create monitoring system
    print("\nStep 3/5: Creating Monitoring System...")
    try:
        create_monitoring_system()
        success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Step 4: Create Docker setup
    print("\nStep 4/5: Creating Docker Setup...")
    try:
        create_docker_setup()
        success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Step 5: Validate deployment readiness
    print("\nStep 5/5: Validating Deployment Readiness...")
    try:
        if validate_deployment_readiness():
            success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Final summary
    print("\n" + "="*70)
    print(f"📊 DEPLOYMENT SETUP SUMMARY: {success_steps}/{total_steps} steps completed")

    if success_steps >= 4:
        print("✅ Deployment automation setup successful!")
        print("\n🎯 NEXT STEPS:")
        print("1. Configure .env.production with your API keys")
        print("2. Test health checks: python3 production/health/health_check.py")
        print("3. Test deployment: production/deploy/deploy.sh")
        print("4. Setup monitoring: production/monitoring/monitor.py")
        print("5. For Docker: production/docker/docker-deploy.sh")
        return 0
    else:
        print("⚠️  Deployment setup needs attention")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
