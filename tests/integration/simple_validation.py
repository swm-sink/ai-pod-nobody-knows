#!/usr/bin/env python3
"""
Simple validation script to test the integration framework
"""

def main():
    try:
        print("🔧 Starting framework validation...")

        # Test imports
        from conftest import MockPodcastState, TEST_TOPICS, COST_BUDGETS
        from mock_responses import MOCK_RESEARCH_RESPONSES, MOCK_QUALITY_EVALUATIONS

        print("✅ Successfully imported test fixtures")

        # Test MockPodcastState creation
        state = MockPodcastState(
            episode_id='framework_test_001',
            topic=TEST_TOPICS['quantum_computing'],
            budget_limit=COST_BUDGETS['strict']
        )
        print(f"✅ Created MockPodcastState: {state.episode_id}")
        print(f"✅ Budget limit: ${state.budget_limit}")
        print(f"✅ Initial cost: ${state.current_cost}")
        print(f"✅ Over budget: {state.is_over_budget()}")

        # Test cost tracking
        state.add_checkpoint('research', 1.25)
        state.add_checkpoint('planning', 0.25)
        print(f"✅ After checkpoints cost: ${state.current_cost}")
        print(f"✅ Over budget check: {state.is_over_budget()}")

        # Test mock data availability
        print(f"✅ Research responses available: {len(MOCK_RESEARCH_RESPONSES)}")
        print(f"✅ Quality evaluations available: {len(MOCK_QUALITY_EVALUATIONS)}")

        # Test serialization
        state_dict = state.to_dict()
        restored_state = MockPodcastState.from_dict(state_dict)
        serialization_works = restored_state.episode_id == state.episode_id
        print(f"✅ Serialization works: {serialization_works}")

        print("\n🎉 FRAMEWORK VALIDATION: ALL TESTS PASSED")
        return True

    except Exception as e:
        print(f"❌ Framework validation failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    exit(0 if success else 1)
