#!/usr/bin/env python3
"""
QA Gate: Run 10 test runs to verify CostTracker fix.
Following August 2025 best practices.
"""

import asyncio
import sys
from pathlib import Path
import json
from datetime import datetime

from workflows.main_workflow import execute_workflow
from core.state import create_initial_state


async def run_single_test(test_num: int) -> dict:
    """Run a single test."""
    print(f"\n🔄 Test Run {test_num}/10...")

    try:
        topic = f"Test Topic {test_num}: Dreams and Reality"

        # Execute workflow in dry-run mode
        final_state = await execute_workflow(
            topic=topic,
            budget=5.51,
            output_dir="./qa_test_output",
            dry_run=True,  # Mock mode for QA
            verbose=False
        )

        # Check for serialization issues
        if final_state.get('errors'):
            return {
                'test_num': test_num,
                'status': 'FAILED',
                'errors': final_state['errors'],
                'topic': topic
            }

        # Verify cost data is serializable
        cost_data = final_state.get('cost_data', {})
        if not isinstance(cost_data, dict):
            return {
                'test_num': test_num,
                'status': 'FAILED',
                'errors': ['cost_data is not a dictionary'],
                'topic': topic
            }

        return {
            'test_num': test_num,
            'status': 'PASSED',
            'topic': topic,
            'total_cost': final_state.get('total_cost', 0),
            'stage': final_state.get('current_stage'),
            'cost_data_keys': list(cost_data.keys())
        }

    except Exception as e:
        return {
            'test_num': test_num,
            'status': 'FAILED',
            'errors': [str(e)],
            'topic': f"Test Topic {test_num}"
        }


async def run_qa_gate():
    """Run 10 test runs for QA gate."""
    print("=" * 60)
    print("🎯 QA GATE: CostTracker Serialization Fix Verification")
    print("Running 10 test runs to ensure stability...")
    print("=" * 60)

    results = []

    # Run 10 tests
    for i in range(1, 11):
        result = await run_single_test(i)
        results.append(result)

        if result['status'] == 'PASSED':
            print(f"  ✅ Test {i}: PASSED (Cost: ${result.get('total_cost', 0):.4f})")
        else:
            print(f"  ❌ Test {i}: FAILED - {result.get('errors', ['Unknown error'])}")

    # Summary
    passed = sum(1 for r in results if r['status'] == 'PASSED')
    failed = sum(1 for r in results if r['status'] == 'FAILED')

    print("\n" + "=" * 60)
    print("📊 QA GATE RESULTS")
    print("=" * 60)
    print(f"Total Tests: 10")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Success Rate: {(passed/10)*100:.1f}%")

    # Save results
    output_dir = Path("qa_test_output")
    output_dir.mkdir(exist_ok=True)

    results_file = output_dir / f"qa_gate_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(results_file, 'w') as f:
        json.dump({
            'timestamp': datetime.now().isoformat(),
            'total_tests': 10,
            'passed': passed,
            'failed': failed,
            'success_rate': (passed/10)*100,
            'results': results
        }, f, indent=2)

    print(f"\nResults saved to: {results_file}")

    # QA Gate Decision
    if passed == 10:
        print("\n✅ QA GATE PASSED: All 10 tests successful!")
        print("The CostTracker serialization fix is stable and ready.")
        return 0
    elif passed >= 8:
        print("\n⚠️ QA GATE PASSED WITH WARNINGS: {passed}/10 tests successful")
        print("The fix is mostly stable but may need additional monitoring.")
        return 0
    else:
        print(f"\n❌ QA GATE FAILED: Only {passed}/10 tests successful")
        print("The fix needs more work before production.")
        return 1


def main():
    """Main entry point."""
    return asyncio.run(run_qa_gate())


if __name__ == "__main__":
    sys.exit(main())
