#!/usr/bin/env python3
"""
Test CostTracker serialization with msgpack.
Following August 2025 LangGraph best practices.

This tests that our CostTracker.to_dict() and from_dict() methods
work correctly with msgpack serialization.
"""

import sys
import msgpack
import json
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent))

from core.cost_tracker import CostTracker, create_cost_tracker
from core.cost_tracker_manager import CostTrackerManager, get_cost_tracker_manager
from core.state import PodcastState, create_initial_state


def test_cost_tracker_serialization():
    """Test that CostTracker can be serialized with msgpack."""
    print("Testing CostTracker serialization with msgpack...")

    # Create a CostTracker and add some costs
    tracker = create_cost_tracker(budget_limit=10.0, episode_id="test_ep_001")

    # Track some costs
    tracker.track_cost(
        agent_name="test_agent",
        provider="openai",
        model="gpt-4o",
        input_tokens=100,
        output_tokens=50,
        operation="test_operation"
    )

    # Test to_dict serialization
    print("\n1. Testing to_dict()...")
    tracker_dict = tracker.to_dict()
    print(f"   Serialized to dict with keys: {tracker_dict.keys()}")

    # Test msgpack serialization
    print("\n2. Testing msgpack serialization...")
    try:
        packed = msgpack.packb(tracker_dict)
        print(f"   ✅ Successfully packed to msgpack ({len(packed)} bytes)")
    except Exception as e:
        print(f"   ❌ Failed to pack with msgpack: {e}")
        return False

    # Test msgpack deserialization
    print("\n3. Testing msgpack deserialization...")
    try:
        unpacked = msgpack.unpackb(packed, raw=False)
        print(f"   ✅ Successfully unpacked from msgpack")
    except Exception as e:
        print(f"   ❌ Failed to unpack from msgpack: {e}")
        return False

    # Test from_dict reconstruction
    print("\n4. Testing from_dict() reconstruction...")
    try:
        reconstructed = CostTracker.from_dict(unpacked)
        print(f"   ✅ Successfully reconstructed CostTracker")
        print(f"   Total cost: ${reconstructed.total_cost:.4f}")
        print(f"   Budget limit: ${reconstructed.budget_limit:.2f}")
        print(f"   Episode ID: {reconstructed.episode_id}")
    except Exception as e:
        print(f"   ❌ Failed to reconstruct: {e}")
        return False

    # Verify data integrity
    print("\n5. Verifying data integrity...")
    if reconstructed.total_cost == tracker.total_cost:
        print(f"   ✅ Total cost matches: ${reconstructed.total_cost:.4f}")
    else:
        print(f"   ❌ Total cost mismatch: {reconstructed.total_cost} != {tracker.total_cost}")
        return False

    if reconstructed.budget_limit == tracker.budget_limit:
        print(f"   ✅ Budget limit matches: ${reconstructed.budget_limit:.2f}")
    else:
        print(f"   ❌ Budget limit mismatch")
        return False

    return True


def test_state_with_cost_data():
    """Test that PodcastState works with serialized cost data."""
    print("\n\nTesting PodcastState with serialized cost data...")

    # Create initial state
    state = create_initial_state(
        topic="Test Topic",
        budget=10.0
    )

    # Create and use a cost tracker
    tracker = create_cost_tracker(
        budget_limit=state['budget_limit'],
        episode_id=state['episode_id']
    )

    # Track some costs
    tracker.track_cost(
        agent_name="research",
        provider="perplexity",
        model="sonar-deep",
        input_tokens=500,
        output_tokens=200,
        operation="research"
    )

    # Store serialized cost data in state
    state['cost_data'] = tracker.to_dict()
    state['total_cost'] = tracker.total_cost

    print(f"\n1. State with cost_data created")
    print(f"   Episode ID: {state['episode_id']}")
    print(f"   Total cost: ${state['total_cost']:.4f}")

    # Test msgpack serialization of entire state
    print("\n2. Testing full state serialization...")
    try:
        # Convert state to dict (PodcastState is TypedDict)
        state_dict = dict(state)
        packed_state = msgpack.packb(state_dict, use_bin_type=True)
        print(f"   ✅ Successfully packed state to msgpack ({len(packed_state)} bytes)")
    except Exception as e:
        print(f"   ❌ Failed to pack state: {e}")
        return False

    # Test deserialization
    print("\n3. Testing state deserialization...")
    try:
        unpacked_state = msgpack.unpackb(packed_state, raw=False)
        print(f"   ✅ Successfully unpacked state from msgpack")
    except Exception as e:
        print(f"   ❌ Failed to unpack state: {e}")
        return False

    # Reconstruct cost tracker from state
    print("\n4. Reconstructing CostTracker from state...")
    try:
        reconstructed_tracker = CostTracker.from_dict(unpacked_state['cost_data'])
        print(f"   ✅ Successfully reconstructed CostTracker from state")
        print(f"   Reconstructed total cost: ${reconstructed_tracker.total_cost:.4f}")
    except Exception as e:
        print(f"   ❌ Failed to reconstruct from state: {e}")
        return False

    return True


def test_cost_tracker_manager():
    """Test CostTrackerManager with serialization."""
    print("\n\nTesting CostTrackerManager...")

    manager = CostTrackerManager()

    # Create tracker for episode 1
    print("\n1. Creating tracker for episode 1...")
    tracker1 = manager.get_or_create_tracker("ep_001", budget_limit=5.0)
    tracker1.track_cost(
        agent_name="agent1",
        provider="openai",
        model="gpt-4o",
        input_tokens=100,
        output_tokens=50,
        operation="test"
    )
    print(f"   Episode 1 cost: ${tracker1.total_cost:.4f}")

    # Serialize tracker1 data
    cost_data1 = tracker1.to_dict()

    # Clear manager and restore from serialized data
    print("\n2. Clearing manager and restoring from serialized data...")
    manager.clear_all()

    # Restore tracker from serialized data
    restored_tracker1 = manager.get_or_create_tracker(
        "ep_001",
        budget_limit=5.0,
        cost_data=cost_data1
    )

    print(f"   ✅ Restored tracker for episode 1")
    print(f"   Restored cost: ${restored_tracker1.total_cost:.4f}")

    if restored_tracker1.total_cost == tracker1.total_cost:
        print("   ✅ Cost data correctly restored")
        return True
    else:
        print("   ❌ Cost data mismatch after restore")
        return False


def main():
    """Run all tests."""
    print("=" * 60)
    print("CostTracker Serialization Tests")
    print("Following August 2025 LangGraph Best Practices")
    print("=" * 60)

    all_passed = True

    # Test 1: Basic serialization
    if not test_cost_tracker_serialization():
        all_passed = False
        print("\n❌ CostTracker serialization test FAILED")
    else:
        print("\n✅ CostTracker serialization test PASSED")

    # Test 2: State integration
    if not test_state_with_cost_data():
        all_passed = False
        print("\n❌ State integration test FAILED")
    else:
        print("\n✅ State integration test PASSED")

    # Test 3: Manager lifecycle
    if not test_cost_tracker_manager():
        all_passed = False
        print("\n❌ CostTrackerManager test FAILED")
    else:
        print("\n✅ CostTrackerManager test PASSED")

    # Summary
    print("\n" + "=" * 60)
    if all_passed:
        print("✅ ALL TESTS PASSED - CostTracker serialization fix successful!")
        print("The system is now compatible with LangGraph's msgpack serialization.")
    else:
        print("❌ SOME TESTS FAILED - Please review the errors above")
    print("=" * 60)

    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())
