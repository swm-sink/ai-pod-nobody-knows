#!/usr/bin/env python3
"""
Validation script for AgentOrchestrator system.
Tests cost tracking integration, budget enforcement, and core functionality.
"""

import asyncio
import sys
import os
from pathlib import Path
from datetime import datetime

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

from core.cost_tracker import CostTracker, BudgetExceededException
from core.agent_orchestrator import AgentOrchestrator, create_orchestrator, WorkflowPhase, ExecutionMode
from core.state import create_initial_state
from workflows.orchestrated_workflow import create_orchestrated_workflow


def test_cost_tracking():
    """Test cost tracking integration."""
    print("=== Testing Cost Tracking Integration ===")
    
    try:
        # Test basic cost tracking
        tracker = CostTracker(budget_limit=5.0, episode_id='test_001')
        
        # Test cost calculation
        cost = tracker.track_cost(
            agent_name='test_agent',
            provider='openai',
            model='gpt-4o',
            input_tokens=1000,
            output_tokens=500,
            operation='test_operation'
        )
        
        print(f"✓ Cost tracking working - Cost: ${cost:.4f}, Total: ${tracker.total_cost:.4f}")
        
        # Test budget enforcement
        print(f"Current budget remaining: ${tracker.budget_limit - tracker.total_cost:.4f}")
        
        # Calculate what the expensive operation would cost
        expensive_cost = tracker.estimate_cost(
            provider='anthropic',
            model='claude-3-opus-20240229',
            input_tokens=100000,  # Even larger to definitely exceed budget
            output_tokens=100000
        )
        print(f"Expensive operation would cost: ${expensive_cost:.4f}")
        print(f"Total would be: ${tracker.total_cost + expensive_cost:.4f} vs budget ${tracker.budget_limit:.2f}")
        
        try:
            # This should exceed budget (current + expensive > budget)
            tracker.track_cost(
                agent_name='expensive_agent',
                provider='anthropic',
                model='claude-3-opus-20240229',
                input_tokens=100000,
                output_tokens=100000,
                operation='expensive_test'
            )
            print("✗ Budget enforcement failed - should have raised exception")
            return False
        except BudgetExceededException as e:
            print(f"✓ Budget enforcement working: {e}")
        
        # Test serialization
        serialized = tracker.to_dict()
        restored = CostTracker.from_dict(serialized)
        print(f"✓ Serialization working - Original: ${tracker.total_cost:.4f}, Restored: ${restored.total_cost:.4f}")
        
        return True
        
    except Exception as e:
        print(f"✗ Cost tracking test failed: {e}")
        return False


def test_orchestrator_basic():
    """Test basic orchestrator functionality."""
    print("\n=== Testing Basic Orchestrator Functionality ===")
    
    try:
        # Create orchestrator
        orchestrator = create_orchestrator(budget_limit=10.0)
        print("✓ Orchestrator created successfully")
        
        # Test agent registration
        async def mock_agent(state, config=None):
            state['mock_executed'] = True
            return state
        
        orchestrator.register_agent("mock_agent", mock_agent)
        print("✓ Agent registration working")
        
        # Test workflow phase registration
        test_phase = WorkflowPhase(
            name="test_phase",
            agents=["mock_agent"],
            execution_mode=ExecutionMode.SEQUENTIAL,
            timeout_minutes=5
        )
        
        orchestrator.register_workflow_phase(test_phase)
        print("✓ Workflow phase registration working")
        
        # Test status reporting
        status = orchestrator.get_orchestrator_status()
        assert 'mock_agent' in status['registered_agents']
        assert 'test_phase' in status['workflow_phases']
        print("✓ Status reporting working")
        
        return True
        
    except Exception as e:
        print(f"✗ Orchestrator basic test failed: {e}")
        return False


async def test_orchestrator_execution():
    """Test orchestrator execution with mock agents."""
    print("\n=== Testing Orchestrator Execution ===")
    
    try:
        # Create orchestrator
        orchestrator = create_orchestrator(budget_limit=5.0)
        
        # Register mock agents
        async def mock_research_agent(state, config=None):
            await asyncio.sleep(0.01)  # Simulate work
            state['research_data'] = {'mock': 'research_complete'}
            return state
        
        async def mock_planning_agent(state, config=None):
            await asyncio.sleep(0.01)
            state['episode_plan'] = {'mock': 'plan_complete'}
            return state
        
        orchestrator.register_agent("research_discovery", mock_research_agent)
        orchestrator.register_agent("episode_planner", mock_planning_agent)
        
        # Create initial state
        initial_state = create_initial_state(
            topic="Test Topic",
            budget=5.0
        )
        
        # Execute limited workflow
        async with orchestrator.workflow_context(
            episode_id=initial_state['episode_id'],
            topic=initial_state['topic'],
            budget=5.0
        ):
            # Execute just research phase for testing
            result_state = await orchestrator._execute_phase("research_pipeline", initial_state)
        
        print("✓ Orchestrator execution working")
        print(f"  - Research data: {bool(result_state.get('research_data'))}")
        
        return True
        
    except Exception as e:
        print(f"✗ Orchestrator execution test failed: {e}")
        return False


def test_workflow_creation():
    """Test orchestrated workflow creation."""
    print("\n=== Testing Orchestrated Workflow Creation ===")
    
    try:
        # Create orchestrated workflow
        workflow = create_orchestrated_workflow(
            budget_limit=5.0,
            max_parallel_agents=3
        )
        print("✓ Orchestrated workflow created successfully")
        
        # Verify components
        assert workflow.orchestrator is not None
        assert workflow.graph is not None
        print("✓ Workflow components initialized")
        
        # Test configuration loading
        config = workflow.config
        assert config['budget_limit'] == 5.0
        assert config['max_parallel_agents'] == 3
        print("✓ Configuration properly set")
        
        return True
        
    except Exception as e:
        print(f"✗ Workflow creation test failed: {e}")
        return False


async def test_state_consistency():
    """Test state consistency across agent handoffs."""
    print("\n=== Testing State Consistency ===")
    
    try:
        orchestrator = create_orchestrator(budget_limit=5.0)
        
        # Create agents that modify state
        async def agent1(state, config=None):
            state['agent1_data'] = 'processed_by_agent1'
            state['shared_counter'] = state.get('shared_counter', 0) + 1
            return state
        
        async def agent2(state, config=None):
            # Should see agent1's changes
            assert state.get('agent1_data') == 'processed_by_agent1'
            assert state.get('shared_counter') == 1
            
            state['agent2_data'] = 'processed_by_agent2'
            state['shared_counter'] += 1
            return state
        
        orchestrator.register_agent("agent1", agent1)
        orchestrator.register_agent("agent2", agent2)
        
        # Create sequential phase
        test_phase = WorkflowPhase(
            name="consistency_test",
            agents=["agent1", "agent2"],
            execution_mode=ExecutionMode.SEQUENTIAL
        )
        
        initial_state = create_initial_state(topic="State Test", budget=5.0)
        
        # Execute phase
        result_state = await orchestrator._execute_sequential(test_phase, initial_state)
        
        # Verify final state
        assert result_state.get('agent1_data') == 'processed_by_agent1'
        assert result_state.get('agent2_data') == 'processed_by_agent2'
        assert result_state.get('shared_counter') == 2
        
        print("✓ State consistency maintained across agents")
        
        return True
        
    except Exception as e:
        print(f"✗ State consistency test failed: {e}")
        return False


def main():
    """Run all validation tests."""
    print("AgentOrchestrator System Validation")
    print("=" * 50)
    
    tests = [
        test_cost_tracking,
        test_orchestrator_basic,
        test_workflow_creation
    ]
    
    async_tests = [
        test_orchestrator_execution,
        test_state_consistency
    ]
    
    # Run synchronous tests
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"Test {test.__name__} failed with exception: {e}")
            results.append(False)
    
    # Run asynchronous tests
    async def run_async_tests():
        async_results = []
        for test in async_tests:
            try:
                result = await test()
                async_results.append(result)
            except Exception as e:
                print(f"Async test {test.__name__} failed with exception: {e}")
                async_results.append(False)
        return async_results
    
    async_results = asyncio.run(run_async_tests())
    results.extend(async_results)
    
    # Summary
    print(f"\n=== Validation Summary ===")
    print(f"Tests run: {len(results)}")
    print(f"Passed: {sum(results)}")
    print(f"Failed: {len(results) - sum(results)}")
    
    if all(results):
        print("🎉 All tests passed! Orchestrator system is ready for production.")
        return 0
    else:
        print("❌ Some tests failed. Check the output above for details.")
        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)