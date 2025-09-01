#!/usr/bin/env python3
"""
Demonstration script for the comprehensive cost tracking system.

This script shows how the cost tracking system works in practice,
simulating a full episode production workflow with real-time
cost monitoring and budget enforcement.

Version: 1.0.0
Date: August 2025
"""

import asyncio
import json
from pathlib import Path
from src.core.cost_tracker import CostTracker, BudgetExceededException


async def simulate_episode_production():
    """Simulate a complete episode production workflow with cost tracking."""

    print("🎙️ Podcast Production Cost Tracking Demo")
    print("=" * 50)

    # Initialize cost tracker with $5.51 budget
    tracker = CostTracker(budget_limit=5.51, episode_id="demo_episode_001")
    print(f"📊 Budget initialized: ${tracker.budget_limit:.2f}")
    print()

    # Stage 1: Research Discovery
    print("🔍 Stage 1: Research Discovery")
    try:
        cost = tracker.track_cost(
            agent_name="research_discovery",
            provider="perplexity",
            model="llama-3.1-sonar-large-128k-online",
            input_tokens=2000,
            output_tokens=1500,
            operation="initial_research"
        )
        remaining = tracker.check_budget_remaining()
        print(f"   Cost: ${cost:.4f} | Remaining: ${remaining:.4f}")
    except BudgetExceededException as e:
        print(f"   ❌ Budget exceeded: {e}")
        return

    # Stage 2: Deep Dive Research
    print("🔬 Stage 2: Deep Dive Research")
    try:
        cost = tracker.track_cost(
            agent_name="research_deep_dive",
            provider="perplexity",
            model="llama-3.1-sonar-large-128k-online",
            input_tokens=3500,
            output_tokens=2000,
            operation="detailed_research"
        )
        remaining = tracker.check_budget_remaining()
        print(f"   Cost: ${cost:.4f} | Remaining: ${remaining:.4f}")
    except BudgetExceededException as e:
        print(f"   ❌ Budget exceeded: {e}")
        return

    # Stage 3: Research Validation
    print("✅ Stage 3: Research Validation")
    try:
        cost = tracker.track_cost(
            agent_name="research_validation",
            provider="anthropic",
            model="claude-3-haiku-20240307",  # Cheaper model for validation
            input_tokens=2500,
            output_tokens=1000,
            operation="fact_checking"
        )
        remaining = tracker.check_budget_remaining()
        print(f"   Cost: ${cost:.4f} | Remaining: ${remaining:.4f}")
    except BudgetExceededException as e:
        print(f"   ❌ Budget exceeded: {e}")
        return

    # Stage 4: Script Generation
    print("📝 Stage 4: Script Generation")
    try:
        # Check if we can afford premium model
        can_afford_premium = tracker.can_afford(
            'anthropic', 'claude-3-5-sonnet-20241022', 4000, 3000
        )

        if can_afford_premium:
            model = 'claude-3-5-sonnet-20241022'
            print("   Using premium model for script generation")
        else:
            model = 'claude-3-haiku-20240307'
            print("   ⚠️ Switching to cheaper model to stay within budget")

        cost = tracker.track_cost(
            agent_name="script_generator",
            provider="anthropic",
            model=model,
            input_tokens=4000,
            output_tokens=3000,
            operation="script_writing"
        )
        remaining = tracker.check_budget_remaining()
        print(f"   Cost: ${cost:.4f} | Remaining: ${remaining:.4f}")

        # Check budget warnings
        budget_used_percent = (tracker.total_cost / tracker.budget_limit) * 100
        if budget_used_percent >= 80:
            print(f"   ⚠️ WARNING: {budget_used_percent:.1f}% of budget used!")
            recommendations = tracker.get_model_recommendations()
            print(f"   💡 Recommended models: {recommendations}")

    except BudgetExceededException as e:
        print(f"   ❌ Budget exceeded: {e}")
        return

    # Stage 5: Audio Generation
    print("🎵 Stage 5: Audio Generation")
    try:
        # Estimate cost first
        script_length = 12000  # characters
        estimated_cost = tracker.estimate_cost(
            'elevenlabs', 'eleven_turbo_v2_5', characters=script_length
        )
        print(f"   Estimated cost: ${estimated_cost:.4f}")

        if not tracker.can_afford('elevenlabs', 'eleven_turbo_v2_5', characters=script_length):
            print("   ⚠️ Cannot afford full script, reducing length")
            script_length = 8000  # Reduce length

        cost = tracker.track_cost(
            agent_name="audio_generator",
            provider="elevenlabs",
            model="eleven_turbo_v2_5",
            characters=script_length,
            operation="text_to_speech"
        )
        remaining = tracker.check_budget_remaining()
        print(f"   Cost: ${cost:.4f} | Remaining: ${remaining:.4f}")

    except BudgetExceededException as e:
        print(f"   ❌ Budget exceeded: {e}")
        return

    # Final Results
    print("\n" + "=" * 50)
    print("📊 Final Cost Breakdown")
    print("=" * 50)

    breakdown = tracker.get_cost_breakdown()

    print(f"Total Cost: ${breakdown['total_cost']:.4f}")
    print(f"Budget Limit: ${breakdown['budget_limit']:.2f}")
    print(f"Budget Remaining: ${breakdown['budget_remaining']:.4f}")
    print(f"Budget Used: {breakdown['budget_used_percent']:.1f}%")

    print(f"\nCost by Agent:")
    for agent, cost in breakdown['cost_by_agent'].items():
        print(f"  - {agent}: ${cost:.4f}")

    print(f"\nCost by Provider:")
    for provider, cost in breakdown['cost_by_provider'].items():
        print(f"  - {provider}: ${cost:.4f}")

    print(f"\nTotal Operations: {breakdown['operation_count']}")
    print(f"Average Cost/Operation: ${breakdown['average_cost_per_operation']:.4f}")

    # Check if CSV logging worked
    csv_file = Path("logs/costs.csv")
    if csv_file.exists():
        print(f"\n✅ Cost data logged to: {csv_file}")

        # Count rows in CSV
        import csv
        with open(csv_file, 'r') as f:
            reader = csv.reader(f)
            row_count = sum(1 for row in reader) - 1  # Exclude header
        print(f"   📈 {row_count} operations logged")
    else:
        print(f"\n❌ CSV logging failed - file not found")

    # Generate text report
    print(f"\n📋 Generating detailed report...")
    text_report = tracker.export_report('text')

    # Save report to file
    output_dir = Path("output")
    output_dir.mkdir(exist_ok=True)
    report_path = output_dir / "demo_cost_report.txt"

    with open(report_path, 'w') as f:
        f.write(text_report)

    print(f"   ✅ Detailed report saved to: {report_path}")

    # Success indicator
    if breakdown['budget_remaining'] >= 0:
        print(f"\n🎉 Episode production completed within budget!")
        print(f"   Efficiency: {100 - breakdown['budget_used_percent']:.1f}% budget remaining")
    else:
        print(f"\n⚠️ Episode production exceeded budget by ${abs(breakdown['budget_remaining']):.4f}")

    return tracker


def demonstrate_analysis():
    """Demonstrate the cost analysis capabilities."""
    print(f"\n" + "=" * 50)
    print("📊 Cost Analysis Demo")
    print("=" * 50)

    csv_file = Path("logs/costs.csv")
    if not csv_file.exists():
        print("❌ No cost data found. Run the episode production demo first.")
        return

    print("Running cost analysis on logged data...")

    # Import analyze_costs module
    import subprocess
    import sys

    # Run the analysis script
    try:
        result = subprocess.run([
            sys.executable, "analyze_costs.py", "--format", "text"
        ], capture_output=True, text=True, timeout=30)

        if result.returncode == 0:
            print("✅ Analysis completed successfully")
            print("\nAnalysis Output:")
            print("-" * 40)
            print(result.stdout)
        else:
            print(f"❌ Analysis failed with error: {result.stderr}")

    except subprocess.TimeoutExpired:
        print("❌ Analysis timed out")
    except Exception as e:
        print(f"❌ Analysis error: {e}")


if __name__ == "__main__":
    print("Starting Cost Tracking System Demo...")
    print("This demonstrates real-time budget monitoring and enforcement.\n")

    # Run the main demonstration
    tracker = asyncio.run(simulate_episode_production())

    if tracker:
        # Demonstrate analysis capabilities
        demonstrate_analysis()

        print(f"\n" + "=" * 50)
        print("🏁 Demo Complete!")
        print("=" * 50)
        print("\nKey Features Demonstrated:")
        print("✅ Real-time cost tracking per agent and provider")
        print("✅ Budget enforcement with automatic model recommendations")
        print("✅ CSV logging for historical analysis")
        print("✅ Comprehensive cost breakdown and reporting")
        print("✅ Token and character-based cost estimation")
        print("✅ Integration with workflow orchestration")

        print(f"\nFiles Generated:")
        print("📁 logs/costs.csv - Raw cost tracking data")
        print("📁 output/demo_cost_report.txt - Detailed cost report")

        print(f"\nNext Steps:")
        print("🔧 Integrate with your agents using CostTrackingMixin")
        print("📊 Use analyze_costs.py for ongoing cost analysis")
        print("💰 Monitor costs in real-time during production")

    else:
        print("\n❌ Demo failed - see errors above")
