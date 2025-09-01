#!/usr/bin/env python3
"""
Simple validation test to identify and fix the orchestration issues.
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

async def test_simple_agent():
    """Test a single agent execution."""
    print("🧪 Testing single agent execution...")
    
    try:
        from agents.research_discovery import ResearchDiscoveryAgent
        from core.state import create_initial_state
        
        # Create initial state
        state = create_initial_state(
            topic="Test Topic for Agent Validation",
            budget=5.51,
            output_dir="./test_output",
            dry_run=True  # Use dry run to avoid API costs
        )
        
        # Initialize agent
        agent = ResearchDiscoveryAgent()
        
        # Test execute method
        print("⚡ Executing agent...")
        result = await agent.execute(dict(state))
        
        print(f"✅ Agent executed successfully")
        print(f"   Result type: {type(result)}")
        print(f"   Result keys: {list(result.keys()) if isinstance(result, dict) else 'Not a dict'}")
        
        return True
        
    except Exception as e:
        print(f"❌ Agent test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

async def test_node_wrapper():
    """Test the node wrapper functionality."""
    print("\n🔧 Testing node wrapper...")
    
    try:
        from agents.research_discovery import ResearchDiscoveryAgent
        from core.node_wrapper import create_agent_node
        from core.state import create_initial_state
        
        # Create test state
        state = create_initial_state(
            topic="Test Topic for Node Wrapper",
            budget=5.51,
            output_dir="./test_output",
            dry_run=True
        )
        
        # Create node function using async wrapper
        node_func = await create_agent_node(ResearchDiscoveryAgent)
        
        # Test node function
        print("⚡ Executing node function...")
        result = await node_func(state)
        
        print(f"✅ Node function executed successfully")
        print(f"   Result type: {type(result)}")
        print(f"   Result keys: {list(result.keys()) if isinstance(result, dict) else 'Not a dict'}")
        
        return True
        
    except Exception as e:
        print(f"❌ Node wrapper test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

async def main():
    """Main test function."""
    print("🚀 Simple Validation Test")
    print("=" * 50)
    
    # Load environment
    if not load_env_file():
        print("❌ Environment setup failed")
        return False
    
    # Test individual agent
    agent_success = await test_simple_agent()
    
    # Test node wrapper
    wrapper_success = await test_node_wrapper()
    
    # Summary
    print("\n" + "=" * 50)
    print("TEST SUMMARY")
    print("=" * 50)
    print(f"Agent Execution: {'✅ PASS' if agent_success else '❌ FAIL'}")
    print(f"Node Wrapper: {'✅ PASS' if wrapper_success else '❌ FAIL'}")
    
    overall_success = agent_success and wrapper_success
    print(f"Overall: {'✅ SUCCESS' if overall_success else '❌ FAILED'}")
    
    return overall_success

if __name__ == "__main__":
    success = asyncio.run(main())
    sys.exit(0 if success else 1)