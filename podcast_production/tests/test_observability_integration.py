"""
Test script for LangFuse observability integration.
Verifies that all observability components work correctly.
Updated for August 2025 LangFuse 3.x/4.x patterns.

Usage:
    python -m pytest tests/test_observability_integration.py -v
    
Or for quick testing:
    python tests/test_observability_integration.py

Version: 2.0.0
Date: August 2025
"""

import asyncio
import os
import sys
from datetime import datetime
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from core.observability import (
    get_observability,
    observe_agent,
    track_workflow_metric,
    PodcastObservability
)
from core.state import create_initial_state

# August 2025: Additional imports for testing
try:
    from langfuse.client import get_client
    from langfuse.langchain import CallbackHandler
except ImportError:
    get_client = lambda: None
    CallbackHandler = None


async def test_observability_initialization():
    """Test that observability initializes correctly."""
    print("Testing observability initialization...")
    
    obs = get_observability()
    
    if not obs.enabled:
        print("⚠️  LangFuse is disabled. Set LANGFUSE_PUBLIC_KEY and LANGFUSE_SECRET_KEY to enable.")
        print("   Copy config/langfuse.example.env to .env and fill in your credentials.")
        return False
    
    print("✅ Observability initialized successfully")
    print(f"   LangFuse client: {obs.langfuse is not None}")
    print(f"   Callback handler: {obs.callback_handler is not None}")
    print(f"   Evaluation templates: {len(obs.evaluation_templates)}")
    
    # August 2025: Test singleton pattern
    if obs.enabled and get_client:
        client = get_client()
        print(f"   Singleton client: {client is not None}")
        
    # August 2025: Test CallbackHandler without args
    if obs.enabled and CallbackHandler:
        try:
            handler = CallbackHandler()
            print("   ✅ CallbackHandler created without constructor args")
        except Exception as e:
            print(f"   ❌ CallbackHandler creation failed: {e}")
    
    return True


async def test_workflow_tracing():
    """Test workflow-level tracing."""
    print("\nTesting workflow tracing...")
    
    obs = get_observability()
    if not obs.enabled:
        print("⚠️  Skipping - LangFuse disabled")
        return False
    
    # Create test trace
    episode_id = f"test_ep_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    async with obs.trace_workflow(
        episode_id=episode_id,
        topic="Test Topic",
        metadata={"test": True, "environment": "test"}
    ) as trace:
        print(f"✅ Created workflow trace: {episode_id}")
        
        # Simulate some work
        await asyncio.sleep(0.1)
        
        # Track an event
        obs.langfuse.event(
            name="test_event",
            metadata={"message": "Test event from integration test"}
        )
        
        # Track a metric
        track_workflow_metric("test_execution_time", 0.1, metadata={"test": True})
    
    # Ensure data is sent
    obs.flush()
    print("✅ Workflow trace completed and flushed")
    return True


@observe_agent("test_agent", "Agent")  # August 2025: Using semantic observation type
async def test_agent_function(state: dict) -> dict:
    """Test agent function with observability decorator."""
    # Simulate agent work
    await asyncio.sleep(0.05)
    
    # Update state
    state["test_result"] = "success"
    state["total_cost"] = state.get("total_cost", 0) + 0.01
    
    return state


async def test_agent_observability():
    """Test agent-level observability."""
    print("\nTesting agent observability...")
    
    obs = get_observability()
    if not obs.enabled:
        print("⚠️  Skipping - LangFuse disabled")
        return False
    
    # Create test state
    state = create_initial_state(
        topic="Test Agent Observability",
        budget=1.0,
        dry_run=True
    )
    
    # Execute decorated function
    result = await test_agent_function(state)
    
    print("✅ Agent function executed with observability")
    print(f"   Result: {result.get('test_result')}")
    
    # Flush to ensure data is sent
    obs.flush()
    return True


async def test_cost_tracking():
    """Test cost tracking functionality."""
    print("\nTesting cost tracking...")
    
    obs = get_observability()
    if not obs.enabled:
        print("⚠️  Skipping - LangFuse disabled")
        return False
    
    # Track some costs
    obs.track_cost("test_component_1", 0.05)
    obs.track_cost("test_component_2", 0.10)
    obs.track_cost("test_total", 0.15)
    
    print("✅ Cost tracking completed")
    print("   Component 1: $0.05")
    print("   Component 2: $0.10")
    print("   Total: $0.15")
    
    obs.flush()
    return True


async def test_quality_evaluation():
    """Test quality evaluation tracking."""
    print("\nTesting quality evaluation...")
    
    obs = get_observability()
    if not obs.enabled:
        print("⚠️  Skipping - LangFuse disabled")
        return False
    
    # Track quality scores
    episode_id = f"test_quality_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    # August 2025: Use updated evaluate_quality with optional trace_id
    obs.evaluate_quality(
        episode_id=episode_id,
        evaluation_type="brand_alignment",
        scores={
            "overall": 8.5,
            "intellectual_humility": 9.0,
            "question_ratio": 8.0,
            "expert_diversity": 8.5
        },
        metadata={"test": True},
        trace_id=episode_id  # August 2025: Explicitly pass trace_id
    )
    
    print("✅ Quality evaluation tracked")
    print("   Brand alignment: 8.5")
    print("   Intellectual humility: 9.0")
    
    obs.flush()
    return True


async def test_error_tracking():
    """Test error tracking functionality."""
    print("\nTesting error tracking...")
    
    obs = get_observability()
    if not obs.enabled:
        print("⚠️  Skipping - LangFuse disabled")
        return False
    
    # Track a test error
    try:
        raise ValueError("Test error for observability")
    except Exception as e:
        obs.track_error(
            error=e,
            context="test_error_tracking",
            metadata={"test": True, "error_type": "intentional"}
        )
    
    print("✅ Error tracking completed")
    
    obs.flush()
    return True


async def test_performance_metrics():
    """Test performance metric tracking."""
    print("\nTesting performance metrics...")
    
    obs = get_observability()
    if not obs.enabled:
        print("⚠️  Skipping - LangFuse disabled")
        return False
    
    # Track various metrics
    obs.track_performance_metric("test_latency", 150, "milliseconds")
    obs.track_performance_metric("test_throughput", 100, "requests/second")
    obs.track_performance_metric("test_memory", 512, "MB")
    
    print("✅ Performance metrics tracked")
    print("   Latency: 150ms")
    print("   Throughput: 100 req/s")
    print("   Memory: 512MB")
    
    obs.flush()
    return True


async def run_all_tests():
    """Run all observability tests."""
    print("=" * 60)
    print("LangFuse Observability Integration Tests")
    print("=" * 60)
    
    tests = [
        test_observability_initialization,
        test_workflow_tracing,
        test_agent_observability,
        test_cost_tracking,
        test_quality_evaluation,
        test_error_tracking,
        test_performance_metrics
    ]
    
    results = []
    for test in tests:
        try:
            result = await test()
            results.append((test.__name__, result))
        except Exception as e:
            print(f"❌ {test.__name__} failed with error: {e}")
            results.append((test.__name__, False))
    
    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASSED" if result else "❌ FAILED"
        print(f"{test_name}: {status}")
    
    print(f"\nTotal: {passed}/{total} tests passed")
    
    # Cleanup
    obs = get_observability()
    if obs.enabled:
        obs.shutdown()
        print("\n✅ Observability shutdown complete")
    
    return passed == total


if __name__ == "__main__":
    # Check for environment variables
    if not os.getenv("LANGFUSE_PUBLIC_KEY"):
        print("⚠️  WARNING: LANGFUSE_PUBLIC_KEY not set")
        print("   Observability features will be disabled")
        print("   To enable, set environment variables:")
        print("   - LANGFUSE_PUBLIC_KEY")
        print("   - LANGFUSE_SECRET_KEY")
        print("   - LANGFUSE_HOST (optional)")
        print()
    
    # Run tests
    success = asyncio.run(run_all_tests())
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)
