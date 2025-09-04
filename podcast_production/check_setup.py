#!/usr/bin/env python3
"""
Quick Setup Verification Script
==============================

A lightweight script to check basic setup requirements before running
the comprehensive production readiness validation.

This script performs basic checks without any API calls or costs.

Usage: python check_setup.py
"""

import os
import sys
import json
from pathlib import Path
from typing import List, Tuple

def check_python_version() -> Tuple[bool, str]:
    """Check Python version compatibility"""
    version = sys.version_info
    required_major, required_minor = 3, 11
    
    if version.major >= required_major and version.minor >= required_minor:
        return True, f"✅ Python {version.major}.{version.minor}.{version.micro} (OK)"
    else:
        return False, f"❌ Python {version.major}.{version.minor}.{version.micro} (requires 3.11+)"

def check_directory_structure() -> Tuple[bool, str]:
    """Check required directories exist"""
    required_dirs = [
        "config", "core", "agents", "workflows", "nodes", "monitoring"
    ]
    
    missing = []
    present = []
    
    for directory in required_dirs:
        if Path(directory).exists():
            present.append(directory)
        else:
            missing.append(directory)
    
    if missing:
        return False, f"❌ Missing directories: {', '.join(missing)}"
    else:
        return True, f"✅ All {len(present)} required directories present"

def check_config_files() -> Tuple[bool, str]:
    """Check basic config files"""
    config_files = [
        ("config/production_config.yaml", True),
        ("config/config.yaml", True), 
        ("config/providers.yaml", True),
        ("config/production-voice.json", True),
        (".env", True)
    ]
    
    missing = []
    present = []
    
    for file_path, required in config_files:
        if Path(file_path).exists():
            present.append(file_path)
        elif required:
            missing.append(file_path)
    
    if missing:
        return False, f"❌ Missing config files: {', '.join(missing)}"
    else:
        return True, f"✅ All {len(present)} config files present"

def check_environment_variables() -> Tuple[bool, str]:
    """Check critical environment variables"""
    required_vars = [
        "OPENROUTER_API_KEY",
        "ELEVENLABS_API_KEY", 
        "PRODUCTION_VOICE_ID",
        "MAX_EPISODE_COST"
    ]
    
    missing = []
    present = []
    
    for var in required_vars:
        if os.getenv(var):
            present.append(var)
        else:
            missing.append(var)
    
    if missing:
        return False, f"❌ Missing env vars: {', '.join(missing)}"
    else:
        return True, f"✅ All {len(present)} environment variables set"

def check_core_imports() -> Tuple[bool, str]:
    """Check core project imports"""
    try:
        # Test core imports
        from core.cost_tracker import CostTracker
        from core.state import PodcastState
        from core.state_manager import StateManager
        return True, "✅ Core modules import successfully"
    except ImportError as e:
        return False, f"❌ Import error: {str(e)}"
    except Exception as e:
        return False, f"❌ Core import error: {str(e)}"

def check_basic_dependencies() -> Tuple[bool, str]:
    """Check basic Python dependencies"""
    required_packages = [
        "yaml", "json", "requests", "pathlib", "datetime", "os"
    ]
    
    missing = []
    
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing.append(package)
    
    if missing:
        return False, f"❌ Missing basic packages: {', '.join(missing)}"
    else:
        return True, f"✅ Basic Python packages available"

def check_file_permissions() -> Tuple[bool, str]:
    """Check basic file permissions"""
    test_dirs = ["logs", "output"]
    
    issues = []
    created = []
    
    for directory in test_dirs:
        dir_path = Path(directory)
        
        # Create if doesn't exist
        if not dir_path.exists():
            try:
                dir_path.mkdir(parents=True, exist_ok=True)
                created.append(directory)
            except Exception as e:
                issues.append(f"Cannot create {directory}: {e}")
                continue
        
        # Test write permission
        try:
            test_file = dir_path / ".permission_test"
            test_file.write_text("test")
            test_file.unlink()
        except Exception as e:
            issues.append(f"Cannot write to {directory}: {e}")
    
    if issues:
        return False, f"❌ Permission issues: {'; '.join(issues)}"
    else:
        msg = f"✅ File permissions OK"
        if created:
            msg += f" (created: {', '.join(created)})"
        return True, msg

def check_voice_configuration() -> Tuple[bool, str]:
    """Check voice configuration specifically"""
    voice_id = os.getenv("PRODUCTION_VOICE_ID")
    expected_voice = "ZF6FPAbjXT4488VcRRnw"
    
    if not voice_id:
        return False, "❌ PRODUCTION_VOICE_ID not set"
    elif len(voice_id) != 20:
        return False, f"❌ Invalid voice ID format (length: {len(voice_id)}, expected: 20)"
    elif voice_id != expected_voice:
        return False, f"⚠️  Voice ID differs from production default: {voice_id}"
    else:
        return True, f"✅ Production voice ID configured correctly"

def check_budget_configuration() -> Tuple[bool, str]:
    """Check budget configuration"""
    budget_str = os.getenv("MAX_EPISODE_COST")
    target_budget = 5.51
    
    if not budget_str:
        return False, "❌ MAX_EPISODE_COST not set"
    
    try:
        budget = float(budget_str)
        if budget == target_budget:
            return True, f"✅ Budget configured correctly: ${budget}"
        else:
            return False, f"⚠️  Budget ${budget} differs from target ${target_budget}"
    except ValueError:
        return False, f"❌ Invalid budget value: {budget_str}"

def main():
    """Run all setup checks"""
    print("""
╔════════════════════════════════════════════════════════════════╗
║           🔍 AI Podcast Production - Setup Checker             ║
║                    Quick Verification v1.0                    ║
╚════════════════════════════════════════════════════════════════╝
    """)
    
    print("Running basic setup verification...\n")
    
    # Define all checks
    checks = [
        ("Python Version", check_python_version),
        ("Directory Structure", check_directory_structure),
        ("Config Files", check_config_files),
        ("Environment Variables", check_environment_variables),
        ("Voice Configuration", check_voice_configuration),
        ("Budget Configuration", check_budget_configuration),
        ("File Permissions", check_file_permissions),
        ("Basic Dependencies", check_basic_dependencies),
        ("Core Imports", check_core_imports),
    ]
    
    # Run checks
    results = []
    passed = 0
    
    for check_name, check_func in checks:
        try:
            success, message = check_func()
            results.append((check_name, success, message))
            if success:
                passed += 1
            print(f"{message}")
        except Exception as e:
            error_msg = f"❌ {check_name}: Error running check - {e}"
            results.append((check_name, False, error_msg))
            print(error_msg)
    
    # Summary
    total = len(checks)
    print(f"\n{'='*60}")
    print(f"📊 SETUP VERIFICATION SUMMARY")
    print(f"{'='*60}")
    print(f"✅ Passed: {passed}/{total}")
    print(f"❌ Failed: {total - passed}/{total}")
    print(f"📈 Success Rate: {(passed/total)*100:.1f}%")
    
    # Show failed checks
    failed_checks = [(name, msg) for name, success, msg in results if not success]
    if failed_checks:
        print(f"\n🔧 ISSUES TO RESOLVE:")
        print(f"{'-'*40}")
        for name, msg in failed_checks:
            print(f"• {name}: {msg.replace('❌ ', '').replace('⚠️  ', '')}")
    
    # Next steps
    print(f"\n🚀 NEXT STEPS:")
    print(f"{'-'*40}")
    
    if passed == total:
        print("🎉 All checks passed! You're ready for production validation.")
        print("\n📝 Run comprehensive validation:")
        print("   python validate_production_readiness.py --dry-run")
        print("\n💡 After dry-run passes, run full validation:")
        print("   python validate_production_readiness.py --comprehensive")
        return 0
    else:
        critical_failures = [
            name for name, success, msg in results 
            if not success and name in ["Python Version", "Directory Structure", "Config Files", "Environment Variables"]
        ]
        
        if critical_failures:
            print("🚨 Critical setup issues detected!")
            print("   Please resolve the issues above before proceeding.")
            print("\n📖 For detailed help:")
            print("   See TROUBLESHOOTING_PRODUCTION_VALIDATION.md")
        else:
            print("⚠️  Minor setup issues detected.")
            print("   You may proceed with caution, but resolving issues is recommended.")
            print("\n📝 Try dry-run validation:")
            print("   python validate_production_readiness.py --dry-run")
        
        return 1

if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n🛑 Setup check interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 Setup check error: {e}")
        sys.exit(1)