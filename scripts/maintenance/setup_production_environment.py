#!/usr/bin/env python3
"""
Production Environment Setup Script

Comprehensive environment configuration for AI Podcast Production System.
Creates production-ready environment files with proper API keys management,
security configurations, and deployment settings.
"""

import os
import sys
import json
import secrets
import string
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, Any, List, Optional

# Add project path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))
sys.path.insert(0, str(project_root / "podcast_production"))

def generate_secure_key(length: int = 32) -> str:
    """Generate a secure random key."""
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def create_production_env_template():
    """Create production environment template with all required variables."""
    print("🏭 Creating Production Environment Template...")

    template_content = f"""# AI Podcast Production System - Production Environment Configuration
# Generated on {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}
#
# SECURITY WARNING: Never commit this file to version control!
# Copy this file to .env.production and configure with your actual secrets.

# =============================================================================
# ENVIRONMENT CONFIGURATION
# =============================================================================

# Environment designation (CRITICAL - affects all behavior)
ENVIRONMENT=production

# Debug and logging settings
DEBUG=false
LOG_LEVEL=INFO
PRODUCTION_MODE=true

# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================

# PostgreSQL Configuration (Production - Required)
POSTGRES_URL=postgresql://podcast_app:YOUR_SECURE_PASSWORD@your-postgres-host:5432/podcast_production?sslmode=require

# Alternative: Individual PostgreSQL settings
# POSTGRES_HOST=your-postgres-host.com
# POSTGRES_PORT=5432
# POSTGRES_DB=podcast_production
# POSTGRES_USER=podcast_app
# POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD

# SSL Configuration (Production - Required)
POSTGRES_SSL_MODE=require
POSTGRES_SSL_REQUIRE=true

# Connection Pool Settings
POSTGRES_MIN_CONN=2
POSTGRES_MAX_CONN=20
POSTGRES_TIMEOUT=30

# LangGraph Database Settings
POSTGRES_SCHEMA=podcast_production
LANGGRAPH_TABLE_PREFIX=checkpoints

# =============================================================================
# AI API KEYS (REQUIRED FOR PRODUCTION)
# =============================================================================

# OpenAI API (Required for GPT models)
OPENAI_API_KEY=sk-proj-YOUR_OPENAI_KEY_HERE

# Anthropic API (Required for Claude models)
ANTHROPIC_API_KEY=sk-ant-YOUR_ANTHROPIC_KEY_HERE

# Perplexity API (Required for research)
PERPLEXITY_API_KEY=pplx-YOUR_PERPLEXITY_KEY_HERE

# OpenRouter API (Alternative AI provider)
OPENROUTER_API_KEY=sk-or-YOUR_OPENROUTER_KEY_HERE

# ElevenLabs API (Required for audio synthesis)
ELEVENLABS_API_KEY=YOUR_ELEVENLABS_KEY_HERE

# =============================================================================
# VOICE CONFIGURATION (GOVERNANCE CONTROLLED)
# =============================================================================

# Production voice ID (NEVER change without user permission)
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw

# Voice validation settings
VOICE_VALIDATION_REQUIRED=true
VOICE_QUALITY_THRESHOLD=8.0

# =============================================================================
# COST CONTROL CONFIGURATION
# =============================================================================

# Budget enforcement (CRITICAL - prevents cost overruns)
MAX_EPISODE_COST=5.51
COST_TRACKING_ENABLED=true
BUDGET_ENFORCEMENT_MODE=strict

# Per-operation cost limits
MAX_RESEARCH_COST=1.50
MAX_SCRIPT_COST=2.00
MAX_AUDIO_COST=2.00
MAX_EVALUATION_COST=0.50

# Cost monitoring
COST_ALERT_THRESHOLD=4.50
COST_NOTIFICATION_WEBHOOK=YOUR_WEBHOOK_URL_FOR_COST_ALERTS

# =============================================================================
# QUALITY ASSURANCE CONFIGURATION
# =============================================================================

# Quality thresholds (CRITICAL for production)
QUALITY_THRESHOLD=8.0
MINIMUM_QUALITY_THRESHOLD=6.0
QUALITY_VALIDATION_REQUIRED=true

# Evaluation settings
ENABLE_MULTI_EVALUATOR_CONSENSUS=true
CLAUDE_EVALUATOR_ENABLED=true
GEMINI_EVALUATOR_ENABLED=true
PERPLEXITY_VALIDATION_ENABLED=true

# Brand consistency requirements
BRAND_CONSISTENCY_THRESHOLD=8.0
INTELLECTUAL_HUMILITY_REQUIRED=true
HUMILITY_PHRASE_MIN_COUNT=20

# =============================================================================
# OBSERVABILITY AND MONITORING
# =============================================================================

# Langfuse Configuration (Production Observability)
LANGFUSE_PUBLIC_KEY=pk-lf-YOUR_PUBLIC_KEY_HERE
LANGFUSE_SECRET_KEY=sk-lf-YOUR_SECRET_KEY_HERE
LANGFUSE_HOST=https://cloud.langfuse.com
LANGFUSE_ENABLED=true

# Monitoring and alerting
ENABLE_PERFORMANCE_MONITORING=true
ENABLE_ERROR_TRACKING=true
ENABLE_COST_MONITORING=true
ENABLE_QUALITY_MONITORING=true

# Health check endpoints
HEALTH_CHECK_ENABLED=true
HEALTH_CHECK_PORT=8080
HEALTH_CHECK_PATH=/health

# =============================================================================
# PERFORMANCE CONFIGURATION
# =============================================================================

# Concurrency and rate limiting
MAX_CONCURRENT_EPISODES=3
MAX_CONCURRENT_API_CALLS=5
API_RATE_LIMIT_REQUESTS_PER_MINUTE=60

# Timeout settings (milliseconds)
DEFAULT_API_TIMEOUT=30000
RESEARCH_API_TIMEOUT=45000
AUDIO_SYNTHESIS_TIMEOUT=120000

# Retry configuration
MAX_RETRY_ATTEMPTS=3
RETRY_BASE_DELAY=1.0
RETRY_MAX_DELAY=60.0
CIRCUIT_BREAKER_ENABLED=true
CIRCUIT_BREAKER_FAILURE_THRESHOLD=5

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

# API security
API_KEY_ROTATION_ENABLED=true
API_KEY_VALIDATION_ENABLED=true
SECURE_HEADERS_ENABLED=true

# Session and authentication
SESSION_SECRET_KEY={generate_secure_key(64)}
JWT_SECRET_KEY={generate_secure_key(48)}

# Security headers and CORS
CORS_ENABLED=true
CORS_ALLOWED_ORIGINS=https://your-domain.com
CSRF_PROTECTION_ENABLED=true

# =============================================================================
# DEPLOYMENT CONFIGURATION
# =============================================================================

# Application settings
APP_NAME=ai-podcast-production
APP_VERSION=1.0.0
APP_PORT=8000
APP_HOST=0.0.0.0

# Worker configuration
WORKER_PROCESSES=auto
WORKER_CONNECTIONS=1000
WORKER_TIMEOUT=300

# File storage and processing
UPLOAD_MAX_SIZE=100MB
TEMP_DIR=/tmp/podcast_production
DATA_RETENTION_DAYS=90

# =============================================================================
# BACKUP AND DISASTER RECOVERY
# =============================================================================

# Database backup
BACKUP_ENABLED=true
BACKUP_SCHEDULE=0 2 * * *  # Daily at 2 AM
BACKUP_RETENTION_DAYS=30
BACKUP_STORAGE_PATH=/backups

# State persistence
CHECKPOINT_BACKUP_ENABLED=true
CHECKPOINT_CLEANUP_ENABLED=true
CHECKPOINT_RETENTION_HOURS=168  # 7 days

# =============================================================================
# NOTIFICATION CONFIGURATION
# =============================================================================

# Email notifications (optional)
SMTP_HOST=your-smtp-host.com
SMTP_PORT=587
SMTP_USERNAME=your-email@domain.com
SMTP_PASSWORD=YOUR_EMAIL_PASSWORD
SMTP_TLS_ENABLED=true

# Notification settings
ENABLE_SUCCESS_NOTIFICATIONS=false
ENABLE_ERROR_NOTIFICATIONS=true
ENABLE_COST_ALERTS=true
ENABLE_QUALITY_ALERTS=true

# Webhook notifications
WEBHOOK_SUCCESS_URL=https://your-webhook.com/success
WEBHOOK_ERROR_URL=https://your-webhook.com/error
WEBHOOK_COST_ALERT_URL=https://your-webhook.com/cost-alert

# =============================================================================
# DEVELOPMENT AND TESTING OVERRIDES
# =============================================================================

# Override for development/staging environments
# ENVIRONMENT=development
# DEBUG=true
# POSTGRES_URL=sqlite:///data/development/podcast_production.db

# Testing overrides
# ENABLE_MOCK_APIS=false
# MOCK_API_RESPONSES=false
# ENABLE_TEST_MODE=false

# =============================================================================
# CUSTOM CONFIGURATION
# =============================================================================

# Add your custom environment variables below this line
# CUSTOM_SETTING_1=value1
# CUSTOM_SETTING_2=value2
"""

    # Create production environment template
    env_template_file = project_root / ".env.production.template"
    with open(env_template_file, 'w') as f:
        f.write(template_content.strip())

    print(f"  ✅ Production template created: {env_template_file}")
    return env_template_file

def create_development_env_config():
    """Create development environment configuration."""
    print("🔧 Creating Development Environment Configuration...")

    # Read existing development config
    existing_dev_env = project_root / ".env.development"
    existing_config = {}

    if existing_dev_env.exists():
        with open(existing_dev_env, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    existing_config[key.strip()] = value.strip()

    # Enhanced development configuration
    dev_config = f"""# AI Podcast Production System - Development Environment
# Generated on {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}

# Environment designation
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=DEBUG

# Development database (SQLite)
DATABASE_URL=sqlite:///{project_root}/data/development/podcast_production.db
POSTGRES_URL=sqlite:///{project_root}/data/development/podcast_production.db

# LangGraph configuration for SQLite
POSTGRES_SCHEMA=main
LANGGRAPH_TABLE_PREFIX=checkpoints

# Voice configuration
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw

# Cost control (development budgets)
MAX_EPISODE_COST=8.00
COST_TRACKING_ENABLED=true
BUDGET_ENFORCEMENT_MODE=warning

# Quality thresholds (relaxed for development)
QUALITY_THRESHOLD=7.0
MINIMUM_QUALITY_THRESHOLD=5.0

# Development API settings (set your development keys)
# OPENAI_API_KEY=your-dev-openai-key
# ANTHROPIC_API_KEY=your-dev-anthropic-key
# PERPLEXITY_API_KEY=your-dev-perplexity-key
# ELEVENLABS_API_KEY=your-dev-elevenlabs-key

# Development observability
LANGFUSE_ENABLED=false
# LANGFUSE_PUBLIC_KEY=your-dev-langfuse-public-key
# LANGFUSE_SECRET_KEY=your-dev-langfuse-secret-key

# Development performance settings
MAX_CONCURRENT_EPISODES=1
MAX_CONCURRENT_API_CALLS=3
API_RATE_LIMIT_REQUESTS_PER_MINUTE=30

# Development timeouts (shorter for faster feedback)
DEFAULT_API_TIMEOUT=15000
RESEARCH_API_TIMEOUT=20000
AUDIO_SYNTHESIS_TIMEOUT=60000

# Development retry settings
MAX_RETRY_ATTEMPTS=2
RETRY_BASE_DELAY=0.5
RETRY_MAX_DELAY=10.0

# Mock settings for development
ENABLE_MOCK_APIS=false
MOCK_API_RESPONSES=false

# Security (development keys - not for production)
SESSION_SECRET_KEY=dev_session_key_not_secure
JWT_SECRET_KEY=dev_jwt_key_not_secure

# Notifications (disabled in development)
ENABLE_SUCCESS_NOTIFICATIONS=false
ENABLE_ERROR_NOTIFICATIONS=false
ENABLE_COST_ALERTS=false
"""

    # Preserve existing database URL if set
    if 'DATABASE_URL' in existing_config:
        dev_config = dev_config.replace(
            f"DATABASE_URL=sqlite:///{project_root}/data/development/podcast_production.db",
            f"DATABASE_URL={existing_config['DATABASE_URL']}"
        )

    if 'POSTGRES_URL' in existing_config:
        dev_config = dev_config.replace(
            f"POSTGRES_URL=sqlite:///{project_root}/data/development/podcast_production.db",
            f"POSTGRES_URL={existing_config['POSTGRES_URL']}"
        )

    # Write enhanced development config
    with open(existing_dev_env, 'w') as f:
        f.write(dev_config.strip())

    print(f"  ✅ Development config updated: {existing_dev_env}")
    return existing_dev_env

def create_env_validation_script():
    """Create environment validation script."""
    print("🔍 Creating Environment Validation Script...")

    validation_script = """#!/usr/bin/env python3
\"\"\"
Environment Validation Script
Validates that all required environment variables are properly configured.
\"\"\"

import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

def validate_required_vars(env_vars: Dict[str, str], required: List[str]) -> Tuple[List[str], List[str]]:
    \"\"\"Validate required environment variables.\"\"\"
    missing = []
    present = []

    for var in required:
        if var in env_vars and env_vars[var] and env_vars[var] != "YOUR_KEY_HERE":
            present.append(var)
        else:
            missing.append(var)

    return present, missing

def validate_database_config(env_vars: Dict[str, str]) -> bool:
    \"\"\"Validate database configuration.\"\"\"
    print("\\n📊 Database Configuration:")

    if "POSTGRES_URL" in env_vars or "DATABASE_URL" in env_vars:
        db_url = env_vars.get("POSTGRES_URL") or env_vars.get("DATABASE_URL")
        if db_url:
            if db_url.startswith("postgresql://"):
                print("  ✅ PostgreSQL configuration detected")
                return True
            elif db_url.startswith("sqlite://"):
                print("  ✅ SQLite configuration detected (development)")
                return True
            else:
                print("  ❌ Invalid database URL format")
                return False

    print("  ❌ No database configuration found")
    return False

def validate_api_keys(env_vars: Dict[str, str]) -> Dict[str, bool]:
    \"\"\"Validate API key configurations.\"\"\"
    print("\\n🔑 API Key Configuration:")

    api_keys = {
        "OpenAI": "OPENAI_API_KEY",
        "Anthropic": "ANTHROPIC_API_KEY",
        "Perplexity": "PERPLEXITY_API_KEY",
        "ElevenLabs": "ELEVENLABS_API_KEY"
    }

    results = {}
    for service, key_name in api_keys.items():
        if key_name in env_vars and env_vars[key_name] and not env_vars[key_name].startswith("your-"):
            print(f"  ✅ {service}: Configured")
            results[service] = True
        else:
            print(f"  ⚠️  {service}: Not configured")
            results[service] = False

    return results

def validate_cost_controls(env_vars: Dict[str, str]) -> bool:
    \"\"\"Validate cost control configuration.\"\"\"
    print("\\n💰 Cost Control Configuration:")

    try:
        max_cost = float(env_vars.get("MAX_EPISODE_COST", "0"))
        if max_cost > 0:
            print(f"  ✅ Max episode cost: ${max_cost:.2f}")

            if max_cost <= 5.51:
                print("  ✅ Cost within production target")
            else:
                print("  ⚠️  Cost above production target ($5.51)")

            return True
        else:
            print("  ❌ Max episode cost not set")
            return False
    except ValueError:
        print("  ❌ Invalid max episode cost format")
        return False

def validate_quality_settings(env_vars: Dict[str, str]) -> bool:
    \"\"\"Validate quality configuration.\"\"\"
    print("\\n⭐ Quality Configuration:")

    try:
        quality_threshold = float(env_vars.get("QUALITY_THRESHOLD", "0"))
        if quality_threshold >= 6.0:
            print(f"  ✅ Quality threshold: {quality_threshold}")

            if quality_threshold >= 8.0:
                print("  ✅ Production quality standard")
            else:
                print("  ⚠️  Below production quality standard (8.0)")

            return True
        else:
            print("  ❌ Quality threshold too low or not set")
            return False
    except ValueError:
        print("  ❌ Invalid quality threshold format")
        return False

def validate_observability(env_vars: Dict[str, str]) -> bool:
    \"\"\"Validate observability configuration.\"\"\"
    print("\\n📈 Observability Configuration:")

    langfuse_enabled = env_vars.get("LANGFUSE_ENABLED", "false").lower() == "true"
    langfuse_public = "LANGFUSE_PUBLIC_KEY" in env_vars and env_vars["LANGFUSE_PUBLIC_KEY"]
    langfuse_secret = "LANGFUSE_SECRET_KEY" in env_vars and env_vars["LANGFUSE_SECRET_KEY"]

    if langfuse_enabled:
        if langfuse_public and langfuse_secret:
            print("  ✅ Langfuse fully configured")
            return True
        else:
            print("  ⚠️  Langfuse enabled but keys missing")
            return False
    else:
        print("  ⚠️  Langfuse disabled (observability limited)")
        return False

def main():
    \"\"\"Main validation execution.\"\"\"
    print("🔍 AI Podcast Production System - Environment Validation")
    print("=" * 65)

    # Load environment from .env.production if it exists
    env_file = Path(".env.production")
    if not env_file.exists():
        env_file = Path(".env.development")

    if not env_file.exists():
        print("❌ No environment file found (.env.production or .env.development)")
        return 1

    print(f"📁 Loading environment from: {env_file}")

    # Parse environment file
    env_vars = {}
    with open(env_file, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                env_vars[key.strip()] = value.strip()

    print(f"📊 Loaded {len(env_vars)} environment variables")

    # Run validation checks
    validation_results = {
        'database': validate_database_config(env_vars),
        'api_keys': validate_api_keys(env_vars),
        'cost_controls': validate_cost_controls(env_vars),
        'quality': validate_quality_settings(env_vars),
        'observability': validate_observability(env_vars)
    }

    # Environment-specific validations
    environment = env_vars.get("ENVIRONMENT", "development")
    print(f"\\n🏭 Environment: {environment}")

    if environment == "production":
        print("\\n🔒 Production Environment Validation:")
        production_required = [
            "POSTGRES_URL", "OPENAI_API_KEY", "ANTHROPIC_API_KEY",
            "PERPLEXITY_API_KEY", "ELEVENLABS_API_KEY", "PRODUCTION_VOICE_ID"
        ]
        present, missing = validate_required_vars(env_vars, production_required)

        if missing:
            print(f"  ❌ Missing required variables: {', '.join(missing)}")
            validation_results['production_required'] = False
        else:
            print("  ✅ All required production variables present")
            validation_results['production_required'] = True

    # Calculate overall score
    total_checks = len(validation_results)
    passed_checks = sum(1 for result in validation_results.values() if result)
    score = int((passed_checks / total_checks) * 100)

    print("\\n" + "=" * 65)
    print(f"📊 VALIDATION SUMMARY:")
    print(f"  • Environment: {environment}")
    print(f"  • Validation Score: {score}%")
    print(f"  • Checks Passed: {passed_checks}/{total_checks}")

    for check_name, result in validation_results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  • {check_name.replace('_', ' ').title()}: {status}")

    if score >= 90:
        print("\\n🎉 EXCELLENT: Environment ready for production!")
        exit_code = 0
    elif score >= 70:
        print("\\n⚠️  GOOD: Environment mostly ready, minor issues to address")
        exit_code = 0
    else:
        print("\\n❌ NEEDS WORK: Environment requires significant configuration")
        exit_code = 1

    print("=" * 65)
    return exit_code

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
"""

    validation_script_file = project_root / "validate_environment.py"
    with open(validation_script_file, 'w') as f:
        f.write(validation_script)

    # Make executable
    os.chmod(validation_script_file, 0o755)

    print(f"  ✅ Environment validation script: {validation_script_file}")
    return validation_script_file

def create_env_setup_guide():
    """Create environment setup guide."""
    print("📚 Creating Environment Setup Guide...")

    guide_content = f"""# Environment Setup Guide

## Quick Start

1. **Copy the template:**
   ```bash
   cp .env.production.template .env.production
   ```

2. **Configure your API keys:**
   Edit `.env.production` and replace all `YOUR_*_KEY_HERE` placeholders with your actual API keys.

3. **Validate configuration:**
   ```bash
   python3 validate_environment.py
   ```

4. **Test the system:**
   ```bash
   python3 setup_production_database.py
   python3 -c "from tests.integration import validate_production_system; validate_production_system.main()"
   ```

## Required API Keys

### OpenAI API Key
- Sign up at: https://platform.openai.com/
- Create API key in dashboard
- Set `OPENAI_API_KEY=sk-proj-your-key-here`

### Anthropic API Key
- Sign up at: https://console.anthropic.com/
- Generate API key
- Set `ANTHROPIC_API_KEY=sk-ant-your-key-here`

### Perplexity API Key
- Sign up at: https://www.perplexity.ai/
- Get API access
- Set `PERPLEXITY_API_KEY=pplx-your-key-here`

### ElevenLabs API Key
- Sign up at: https://elevenlabs.io/
- Get API key from profile
- Set `ELEVENLABS_API_KEY=your-key-here`

### Langfuse (Optional - for observability)
- Sign up at: https://langfuse.com/
- Create project and get keys
- Set `LANGFUSE_PUBLIC_KEY` and `LANGFUSE_SECRET_KEY`

## Database Setup

### Development (SQLite - No setup required)
The system will automatically create a SQLite database for development.

### Production (PostgreSQL - Required)
1. **Using Docker (Recommended):**
   ```bash
   cd production/database
   ./setup.sh
   ```

2. **Using existing PostgreSQL:**
   Configure `POSTGRES_URL` in `.env.production`

## Security Best Practices

1. **Never commit .env files to version control**
2. **Use strong passwords for database connections**
3. **Enable SSL for production database connections**
4. **Rotate API keys regularly**
5. **Use environment-specific configurations**

## Environment Files

- `.env.production` - Production configuration (never commit!)
- `.env.development` - Development configuration (git-ignored)
- `.env.production.template` - Template with all variables (can commit)

## Validation

Run the validation script to ensure your environment is properly configured:

```bash
python3 validate_environment.py
```

This will check:
- Database connectivity
- API key presence
- Cost control settings
- Quality thresholds
- Observability configuration

## Troubleshooting

### Database Connection Issues
1. Check `POSTGRES_URL` format
2. Verify database server is running
3. Ensure SSL settings match your server
4. Test with: `python3 setup_production_database.py`

### API Key Issues
1. Verify keys are not expired
2. Check API quotas and billing
3. Ensure keys have required permissions
4. Test individual APIs if needed

### Cost Control Issues
1. Set `MAX_EPISODE_COST=5.51` for production
2. Enable `COST_TRACKING_ENABLED=true`
3. Set `BUDGET_ENFORCEMENT_MODE=strict`

### Quality Issues
1. Set `QUALITY_THRESHOLD=8.0` for production
2. Enable `QUALITY_VALIDATION_REQUIRED=true`
3. Ensure evaluators are configured

## Production Checklist

Before deploying to production:

- [ ] All API keys configured and tested
- [ ] PostgreSQL database setup and accessible
- [ ] Cost controls enabled and tested
- [ ] Quality thresholds set appropriately
- [ ] Observability configured (Langfuse)
- [ ] Environment validation passes (90%+)
- [ ] Voice ID configured and validated
- [ ] Backup and monitoring configured
- [ ] Security settings reviewed

## Support

If you encounter issues:
1. Run `python3 validate_environment.py` for diagnostics
2. Check the troubleshooting section above
3. Review logs for specific error messages
4. Consult the main CLAUDE.md documentation

Generated on {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}
"""

    guide_file = project_root / "ENVIRONMENT_SETUP.md"
    with open(guide_file, 'w') as f:
        f.write(guide_content.strip())

    print(f"  ✅ Environment setup guide: {guide_file}")
    return guide_file

def validate_current_environment():
    """Validate the current environment configuration."""
    print("🔍 Validating Current Environment Configuration...")

    # Check for existing environment files
    env_files = {
        'production_template': project_root / ".env.production.template",
        'production': project_root / ".env.production",
        'development': project_root / ".env.development"
    }

    file_status = {}
    for name, path in env_files.items():
        file_status[name] = path.exists()
        status = "✅ Present" if path.exists() else "❌ Missing"
        print(f"  • {name.replace('_', ' ').title()}: {status}")

    # Load development environment for testing
    if file_status['development']:
        env_vars = {}
        with open(env_files['development'], 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()

        # Test basic configuration
        config_tests = {
            'environment_set': 'ENVIRONMENT' in env_vars,
            'database_configured': 'DATABASE_URL' in env_vars or 'POSTGRES_URL' in env_vars,
            'voice_configured': 'PRODUCTION_VOICE_ID' in env_vars,
            'cost_limit_set': 'MAX_EPISODE_COST' in env_vars
        }

        print("\n  Configuration Tests:")
        for test_name, result in config_tests.items():
            status = "✅ Pass" if result else "❌ Fail"
            print(f"    • {test_name.replace('_', ' ').title()}: {status}")

        # Calculate score
        total_files = len(file_status)
        present_files = sum(file_status.values())

        total_configs = len(config_tests)
        passed_configs = sum(config_tests.values())

        overall_score = int(((present_files / total_files) + (passed_configs / total_configs)) / 2 * 100)

        print(f"\n  📊 Environment Configuration Score: {overall_score}%")

        return overall_score >= 80

    else:
        print("\n  ⚠️  Cannot validate - development environment file missing")
        return False

def main():
    """Main environment setup execution."""
    print("🚀 AI Podcast Production System - Environment Setup")
    print("="*65)

    success_steps = 0
    total_steps = 5

    # Step 1: Create production template
    print("Step 1/5: Creating Production Environment Template...")
    try:
        create_production_env_template()
        success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Step 2: Create/update development config
    print("\nStep 2/5: Creating Development Environment Configuration...")
    try:
        create_development_env_config()
        success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Step 3: Create validation script
    print("\nStep 3/5: Creating Environment Validation Script...")
    try:
        create_env_validation_script()
        success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Step 4: Create setup guide
    print("\nStep 4/5: Creating Environment Setup Guide...")
    try:
        create_env_setup_guide()
        success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Step 5: Validate current environment
    print("\nStep 5/5: Validating Current Environment...")
    try:
        if validate_current_environment():
            success_steps += 1
    except Exception as e:
        print(f"  ❌ Error: {e}")

    # Final summary
    print("\n" + "="*65)
    print(f"📊 ENVIRONMENT SETUP SUMMARY: {success_steps}/{total_steps} steps completed")

    if success_steps >= 4:
        print("✅ Environment setup successful!")
        print("\n🎯 NEXT STEPS:")
        print("1. Copy .env.production.template to .env.production")
        print("2. Configure your API keys in .env.production")
        print("3. Run: python3 validate_environment.py")
        print("4. Test the system with your configuration")
        return 0
    else:
        print("⚠️  Environment setup needs attention")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
