#!/usr/bin/env python3
"""
Environment Validation Script
Validates that all required environment variables are properly configured.
"""

import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

def validate_required_vars(env_vars: Dict[str, str], required: List[str]) -> Tuple[List[str], List[str]]:
    """Validate required environment variables."""
    missing = []
    present = []

    for var in required:
        if var in env_vars and env_vars[var] and env_vars[var] != "YOUR_KEY_HERE":
            present.append(var)
        else:
            missing.append(var)

    return present, missing

def validate_database_config(env_vars: Dict[str, str]) -> bool:
    """Validate database configuration."""
    print("\n📊 Database Configuration:")

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
    """Validate API key configurations."""
    print("\n🔑 API Key Configuration:")

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
    """Validate cost control configuration."""
    print("\n💰 Cost Control Configuration:")

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
    """Validate quality configuration."""
    print("\n⭐ Quality Configuration:")

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
    """Validate observability configuration."""
    print("\n📈 Observability Configuration:")

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
    """Main validation execution."""
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
    print(f"\n🏭 Environment: {environment}")

    if environment == "production":
        print("\n🔒 Production Environment Validation:")
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

    print("\n" + "=" * 65)
    print(f"📊 VALIDATION SUMMARY:")
    print(f"  • Environment: {environment}")
    print(f"  • Validation Score: {score}%")
    print(f"  • Checks Passed: {passed_checks}/{total_checks}")

    for check_name, result in validation_results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  • {check_name.replace('_', ' ').title()}: {status}")

    if score >= 90:
        print("\n🎉 EXCELLENT: Environment ready for production!")
        exit_code = 0
    elif score >= 70:
        print("\n⚠️  GOOD: Environment mostly ready, minor issues to address")
        exit_code = 0
    else:
        print("\n❌ NEEDS WORK: Environment requires significant configuration")
        exit_code = 1

    print("=" * 65)
    return exit_code

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
