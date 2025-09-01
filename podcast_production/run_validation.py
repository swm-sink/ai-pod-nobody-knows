#!/usr/bin/env python3
"""
Production Validation Episode Runner
Loads environment variables and executes comprehensive validation
"""

import os
import sys
import asyncio
from pathlib import Path
import subprocess

# Add current directory to Python path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

def load_env_file():
    """Load environment variables from .env file."""
    env_file = current_dir / ".env"
    if not env_file.exists():
        print("❌ .env file not found!")
        return False
    
    env_vars = {}
    with open(env_file) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                env_vars[key] = value
                os.environ[key] = value
    
    print(f"✅ Loaded {len(env_vars)} environment variables from .env")
    
    # Verify critical variables are loaded
    required_vars = ["PERPLEXITY_API_KEY", "LANGFUSE_PUBLIC_KEY", "LANGFUSE_SECRET_KEY", "ELEVENLABS_API_KEY"]
    missing = []
    for var in required_vars:
        if not os.getenv(var):
            missing.append(var)
    
    if missing:
        print(f"⚠️  Missing required variables: {missing}")
        return False
    
    print("✅ All required API keys are available")
    return True

async def main():
    """Main execution function."""
    print("🚀 Production Validation Episode Runner")
    print("=" * 60)
    
    # Load environment variables
    if not load_env_file():
        print("❌ Environment setup failed")
        sys.exit(1)
    
    # Import and run validation after env is loaded
    try:
        from validation_episodes.episode_validation_001 import run_production_validation
        
        print("🔧 Starting production validation...")
        results = await run_production_validation()
        
        # Exit with appropriate code
        success = results.get("success", False)
        exit_code = 0 if success else 1
        
        print(f"\n{'🎉' if success else '❌'} Validation completed: {'SUCCESS' if success else 'FAILED'}")
        sys.exit(exit_code)
        
    except Exception as e:
        print(f"💥 Validation runner failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())