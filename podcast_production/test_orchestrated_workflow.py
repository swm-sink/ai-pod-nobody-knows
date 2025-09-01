#!/usr/bin/env python3
"""
Test the orchestrated workflow with the corrected async agent registration.
"""

import asyncio
import os
import sys
from pathlib import Path

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
    
    print(f"✅ Loaded {len(env_vars)} environment variables")
    return True

async def test_orchestrated_workflow():
    """Test the orchestrated workflow creation and execution."""
    print("🧪 Testing orchestrated workflow...")
    
    try:
        from workflows.orchestrated_workflow import execute_orchestrated_workflow
        from core.state import create_initial_state
        
        print("⚡ Executing orchestrated workflow...")
        
        # Execute with a simple topic and dry_run mode
        final_state = await execute_orchestrated_workflow(
            topic="Test Topic for Orchestrated Workflow",
            budget=5.51,
            output_dir="./test_output",
            dry_run=True,  # Use dry run to avoid API costs and test architecture
            verbose=True
        )
        
        print(f"✅ Orchestrated workflow executed successfully")
        print(f"   Final stage: {final_state.get('current_stage', 'unknown')}")
        print(f"   Total cost: ${final_state.get('total_cost', 0.0):.4f}")
        print(f"   Errors: {len(final_state.get('errors', []))}")
        
        # Check if we have some basic results
        has_research = bool(final_state.get('research_data', {}))
        has_cost_tracking = final_state.get('total_cost', 0.0) >= 0
        
        print(f"   Has research data: {'✅' if has_research else '❌'}")
        print(f"   Has cost tracking: {'✅' if has_cost_tracking else '❌'}")
        
        return True
        
    except Exception as e:
        print(f"❌ Orchestrated workflow test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

async def main():
    """Main test function."""
    print("🚀 Orchestrated Workflow Test")
    print("=" * 50)
    
    # Load environment
    if not load_env_file():
        print("❌ Environment setup failed")
        return False
    
    # Test orchestrated workflow
    workflow_success = await test_orchestrated_workflow()
    
    # Summary
    print("\n" + "=" * 50)
    print("TEST SUMMARY")
    print("=" * 50)
    print(f"Orchestrated Workflow: {'✅ PASS' if workflow_success else '❌ FAIL'}")
    
    return workflow_success

if __name__ == "__main__":
    success = asyncio.run(main())
    sys.exit(0 if success else 1)