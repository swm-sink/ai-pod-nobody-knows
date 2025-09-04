#!/usr/bin/env python3
"""
Production Validation Runner
===========================

Unified entry point for all production validation tasks.
Provides a simple interface for setup checking and production validation.

Usage:
  python validate.py                    # Quick setup check
  python validate.py --setup           # Detailed setup verification  
  python validate.py --dry-run         # Dry run validation (no costs)
  python validate.py --full            # Full production validation
  python validate.py --quick           # Quick critical tests only
"""

import sys
import subprocess
import argparse
from pathlib import Path


def run_setup_check():
    """Run the basic setup checker"""
    print("🔍 Running basic setup verification...")
    try:
        result = subprocess.run([sys.executable, "check_setup.py"], capture_output=False)
        return result.returncode == 0
    except Exception as e:
        print(f"Error running setup check: {e}")
        return False


def run_production_validation(args):
    """Run the comprehensive production validation"""
    cmd = [sys.executable, "validate_production_readiness.py"]
    
    if args.dry_run or args.quick:
        cmd.append("--dry-run")
    elif args.full:
        cmd.append("--comprehensive")
    
    if args.quick:
        cmd.append("--quick")
    
    if args.category:
        cmd.extend(["--category", args.category])
    
    if args.severity:
        cmd.extend(["--severity", args.severity])
    
    if args.quiet:
        cmd.append("--quiet")
    
    print(f"🚀 Running production validation: {' '.join(cmd[2:])}")
    
    try:
        result = subprocess.run(cmd, capture_output=False)
        return result.returncode == 0
    except Exception as e:
        print(f"Error running production validation: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="AI Podcast Production - Validation Runner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python validate.py                     # Basic setup check
  python validate.py --setup            # Detailed setup check
  python validate.py --dry-run          # Safe validation (no API costs)
  python validate.py --full             # Full validation (incurs costs)
  python validate.py --quick            # Quick critical tests only
  
Recommended workflow:
  1. python validate.py                 # Check basic setup
  2. python validate.py --dry-run       # Validate without costs
  3. python validate.py --full          # Final validation with APIs
        """
    )
    
    # Mode selection
    mode_group = parser.add_mutually_exclusive_group()
    mode_group.add_argument(
        "--setup", 
        action="store_true",
        help="Run setup verification only"
    )
    mode_group.add_argument(
        "--dry-run",
        action="store_true", 
        help="Run validation in dry-run mode (no API calls)"
    )
    mode_group.add_argument(
        "--full",
        action="store_true",
        help="Run full production validation (with API calls)"
    )
    mode_group.add_argument(
        "--quick",
        action="store_true",
        help="Run quick validation (critical tests only)"
    )
    
    # Filtering options
    parser.add_argument(
        "--category",
        choices=["environment", "api", "agents", "integration", "cost", "quality", "system", "security"],
        help="Run only specific category of tests"
    )
    
    parser.add_argument(
        "--severity", 
        choices=["critical", "high", "medium", "low"],
        help="Run only specific severity tests"
    )
    
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Minimal output"
    )
    
    args = parser.parse_args()
    
    # Check we're in the right directory
    if not Path("validate_production_readiness.py").exists():
        print("❌ Error: Must run from podcast_production directory")
        print("📁 Expected files not found. Are you in the right directory?")
        return 1
    
    # Determine what to run
    if args.setup:
        # Just run setup check
        success = run_setup_check()
        return 0 if success else 1
        
    elif args.dry_run or args.full or args.quick or args.category or args.severity:
        # Run production validation with specified options
        success = run_production_validation(args)
        return 0 if success else 1
        
    else:
        # Default: run setup check first, then suggest next steps
        print("""
╔══════════════════════════════════════════════════════════════════╗
║              🎯 AI Podcast Production Validation                 ║
║                      Welcome! Let's get started.                 ║
╚══════════════════════════════════════════════════════════════════╝

📋 Step 1: Checking basic setup requirements...
        """)
        
        setup_success = run_setup_check()
        
        if setup_success:
            print("""
🎉 Great! Basic setup looks good.

📋 Step 2 Recommendations:
   
   🔒 Safe validation (no costs):
      python validate.py --dry-run
   
   ⚡ Quick critical tests:
      python validate.py --quick
      
   🚀 Full validation (small cost ~$0.05):
      python validate.py --full

💡 Start with --dry-run to test everything safely!
            """)
            return 0
        else:
            print("""
⚠️  Setup issues detected. Please resolve them first.

🔧 Common solutions:
   • Check your .env file has all required API keys
   • Ensure you're in the podcast_production directory
   • Run: pip install -r requirements.txt
   
📖 For detailed help:
   See TROUBLESHOOTING_PRODUCTION_VALIDATION.md
            """)
            return 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n🛑 Validation interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 Validation error: {e}")
        sys.exit(1)