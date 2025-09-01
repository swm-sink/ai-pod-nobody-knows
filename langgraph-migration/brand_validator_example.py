#!/usr/bin/env python3
"""
Brand Validator Agent Example
Demonstrates the Nobody Knows brand validation system
"""

import asyncio
import json
from datetime import datetime
from src.agents.brand_validator import BrandValidatorAgent

async def test_brand_validation():
    """Test the brand validator with example scripts"""

    # Initialize agent (with mock Langfuse for demo)
    class MockLangfuse:
        def trace(self, **kwargs):
            class MockTrace:
                def update(self, **kwargs):
                    pass
            return MockTrace()

    agent = BrandValidatorAgent(langfuse=MockLangfuse())

    # Example script that follows "Nobody Knows" philosophy
    good_script = """
    Welcome to Nobody Knows, where we celebrate the beautiful mystery of learning together!

    Today we're exploring quantum computing ethics, and honestly, this is fascinating
    territory where even the brightest experts admit they're still figuring things out.
    What's remarkable is how current research suggests some intriguing possibilities,
    though many fundamental questions remain beautifully open.

    As Dr. Sarah Chen recently shared with me, "The more we learn about quantum systems,
    the more we realize how much we don't yet understand about their ethical implications."
    And that's not a limitation - that's an invitation to wonder!

    Together, let's explore what we do know while celebrating the mysteries that continue
    to puzzle and inspire researchers around the world. Because sometimes, the most
    honest answer is also the most exciting: we're still learning, and that's exactly
    where the magic happens.
    """

    # Example script that violates brand guidelines
    bad_script = """
    Today I'm going to explain quantum computing ethics, which is obviously simple once
    you understand the basic principles. The science clearly proves that experts have
    figured everything out, and you need to know these definitive facts.

    This research conclusively shows absolute certainty in all areas. There are no
    remaining questions, and anyone who doesn't grasp these concepts immediately
    simply isn't paying attention. The data speaks for itself and leaves no room
    for doubt or alternative interpretations.

    As I've said before, this is straightforward stuff that everyone should master
    quickly. The experts have settled all debates, and further discussion is
    unnecessary.
    """

    print("=== Brand Validation Demo ===\n")

    # Test good script
    print("Testing HIGH-QUALITY script (follows Nobody Knows philosophy):")
    print("-" * 60)

    state1 = {
        "episode_id": "demo_good_script",
        "topic": "Quantum Computing Ethics",
        "script_polished": good_script,
        "cost_breakdown": {},
        "quality_scores": {}
    }

    try:
        result1 = await agent.execute(state1)
        validation_data1 = result1["brand_validation"]

        print(f"Overall Score: {validation_data1['overall_score']:.1f}/10")
        print(f"Passed: {'✅ YES' if validation_data1['passed'] else '❌ NO'}")
        print(f"Cost: ${result1['cost_breakdown']['brand_validation']:.3f}")
        print("\nBrand Scores:")
        for criterion, score in validation_data1["brand_scores"].items():
            status = "✅" if score >= 7.5 else "❌"
            print(f"  {status} {criterion}: {score:.1f}/10")

        if validation_data1["suggestions"]:
            print(f"\nSuggestions: {len(validation_data1['suggestions'])} items")
        if validation_data1["violations"]:
            print(f"Violations: {len(validation_data1['violations'])} items")
        if validation_data1["exemplary_sections"]:
            print(f"Exemplary Sections: {len(validation_data1['exemplary_sections'])} items")

    except Exception as e:
        print(f"Error: {e}")

    print("\n" + "=" * 80 + "\n")

    # Test bad script
    print("Testing LOW-QUALITY script (violates Nobody Knows philosophy):")
    print("-" * 60)

    state2 = {
        "episode_id": "demo_bad_script",
        "topic": "Quantum Computing Ethics",
        "script_polished": bad_script,
        "cost_breakdown": {},
        "quality_scores": {}
    }

    try:
        result2 = await agent.execute(state2)
        validation_data2 = result2["brand_validation"]

        print(f"Overall Score: {validation_data2['overall_score']:.1f}/10")
        print(f"Passed: {'✅ YES' if validation_data2['passed'] else '❌ NO'}")
        print(f"Cost: ${result2['cost_breakdown']['brand_validation']:.3f}")
        print("\nBrand Scores:")
        for criterion, score in validation_data2["brand_scores"].items():
            status = "✅" if score >= 7.5 else "❌"
            print(f"  {status} {criterion}: {score:.1f}/10")

        if validation_data2["suggestions"]:
            print(f"\nSuggestions ({len(validation_data2['suggestions'])} items):")
            for i, suggestion in enumerate(validation_data2["suggestions"][:3], 1):
                print(f"  {i}. {suggestion[:100]}...")

        if validation_data2["violations"]:
            print(f"\nViolations ({len(validation_data2['violations'])} items):")
            for i, violation in enumerate(validation_data2["violations"][:3], 1):
                v_data = violation if isinstance(violation, dict) else vars(violation)
                print(f"  {i}. {v_data.get('violation_type', 'Unknown')}: {v_data.get('explanation', 'No explanation')[:100]}...")

    except Exception as e:
        print(f"Error: {e}")

    print("\n" + "=" * 80 + "\n")
    print("✅ Brand Validator Demo Complete!")
    print("\nThe Nobody Knows brand validator ensures consistent intellectual")
    print("humility, curiosity, wonder, and accessible expertise across all episodes.")

if __name__ == "__main__":
    asyncio.run(test_brand_validation())
