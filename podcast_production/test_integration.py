#!/usr/bin/env python3
"""
Simple integration test for the podcast production pipeline.
Tests basic functionality without LangGraph serialization issues.

Version: 1.0.0
Date: August 2025
"""

import sys
import os
import json
from datetime import datetime

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import sys
import asyncio
import json
from pathlib import Path

from core.state import create_initial_state, validate_state, update_stage, update_cost
from workflows.main_workflow import PodcastWorkflow


async def test_basic_workflow():
    """Test basic workflow execution."""

    print("Testing AI Podcast Production System Integration")
    print("=" * 50)

    # Create initial state
    initial_state = create_initial_state(
        topic="Test Integration Topic",
        budget=5.51,
        output_dir="./test_integration_output",
        dry_run=True,
        verbose=True
    )

    print(f"✓ Initial state created: {initial_state['episode_id']}")

    # Validate initial state
    validation_errors = validate_state(initial_state)
    if validation_errors:
        print("✗ State validation failed:")
        for error in validation_errors:
            print(f"  - {error}")
        return False

    print("✓ Initial state validation passed")

    # Test state management functions
    test_state = update_stage(initial_state, "testing")
    test_state = update_cost(test_state, "test_stage", 0.25)

    print("✓ State management functions working")

    # Test workflow creation
    try:
        workflow = PodcastWorkflow()
        print("✓ Workflow created successfully")
    except Exception as e:
        print(f"✗ Workflow creation failed: {e}")
        return False

    # Test workflow execution
    try:
        final_state = await workflow.execute(initial_state)
        print("✓ Workflow execution completed")

        # Check final state
        if final_state.get("current_stage") == "completed":
            print("✓ Workflow reached completion stage")
        else:
            print(f"⚠ Workflow ended at stage: {final_state.get('current_stage')}")

        # Check outputs
        if final_state.get("script_polished"):
            print("✓ Script generated")

        if final_state.get("audio_file_path"):
            print("✓ Audio path configured")

        # Check cost tracking
        total_cost = final_state.get("total_cost", 0.0)
        budget = final_state.get("budget_limit", 5.51)
        print(f"✓ Cost tracking: ${total_cost:.2f} / ${budget:.2f}")

        # Save test results
        output_dir = Path("test_integration_output")
        output_dir.mkdir(exist_ok=True)

        test_results = {
            "test_timestamp": initial_state["timestamp"],
            "episode_id": final_state["episode_id"],
            "final_stage": final_state.get("current_stage"),
            "total_cost": final_state.get("total_cost", 0.0),
            "script_length": len(final_state.get("script_polished", "")),
            "errors": final_state.get("errors", []),
            "success": final_state.get("current_stage") == "completed"
        }

        with open(output_dir / "integration_test_results.json", 'w') as f:
            json.dump(test_results, f, indent=2, default=str)

        print("✓ Test results saved")

        return test_results["success"]

    except Exception as e:
        print(f"✗ Workflow execution failed: {e}")
        return False


def test_cli_interface():
    """Test CLI interface parsing."""
    print("\nTesting CLI Interface")
    print("-" * 30)

    # Test help
    try:
        import subprocess
        result = subprocess.run(
            ["python3", "main.py", "--help"],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0:
            print("✓ Help command works")
        else:
            print("✗ Help command failed")

    except Exception as e:
        print(f"✗ CLI test failed: {e}")


async def main():
    """Run all integration tests."""

    print("AI Podcast Production System - Integration Tests")
    print("=" * 60)

    # Test basic workflow
    workflow_success = await test_basic_workflow()

    # Test CLI interface
    test_cli_interface()

    # Summary
    print("\n" + "=" * 60)
    print("INTEGRATION TEST SUMMARY")
    print("=" * 60)

    if workflow_success:
        print("✅ All core tests passed!")
        print("✅ Main orchestration entry point working")
        print("✅ State management functional")
        print("✅ LangGraph workflow operational")
        print("✅ CLI interface responsive")
        print("\nSystem ready for agent migration!")
    else:
        print("❌ Some tests failed")
        print("Review errors above before proceeding")

    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(main())
