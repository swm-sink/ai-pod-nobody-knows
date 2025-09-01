#!/usr/bin/env python3
"""
Example usage of the Episode Planner Agent
Demonstrates how to use the agent to structure episode flow and segments
"""

import asyncio
import json
from src.agents.episode_planner import EpisodePlannerAgent
from langfuse import Langfuse

async def main():
    """Demonstrate episode planner agent functionality"""

    # Initialize LangFuse (mock for demo)
    langfuse = Langfuse()

    # Create episode planner agent
    planner = EpisodePlannerAgent(langfuse)

    # Example state from previous research stages
    test_state = {
        "episode_id": "demo_episode_001",
        "topic": "Quantum Computing's Commercial Reality",
        "research_synthesis": {
            "synthesized_knowledge": {
                "thematic_threads": [
                    {
                        "theme_title": "From Lab to Market",
                        "description": "Commercial quantum computing development"
                    },
                    {
                        "theme_title": "Current Limitations",
                        "description": "Technical barriers and challenges"
                    },
                    {
                        "theme_title": "Industry Applications",
                        "description": "Where quantum computing shows promise"
                    },
                    {
                        "theme_title": "The Reality Gap",
                        "description": "Hype vs. actual capabilities"
                    }
                ]
            },
            "episode_hooks": {
                "curiosity_moments": [
                    "IBM's quantum computer can solve certain problems 1000x faster",
                    "Google achieved quantum supremacy in just 200 seconds"
                ],
                "wonder_points": [
                    "We're building machines that exploit quantum weirdness for computation"
                ]
            }
        },
        "research_questions": [
            "How close are we to practical quantum computing?",
            "What problems can quantum computers actually solve today?",
            "Why haven't quantum computers replaced traditional computers?",
            "What are the biggest technical hurdles remaining?"
        ],
        "target_duration": 15,
        "cost_breakdown": {}
    }

    print("🎙️ Episode Planner Agent Demo")
    print(f"Topic: {test_state['topic']}")
    print(f"Target Duration: {test_state['target_duration']} minutes")
    print(f"Research Questions: {len(test_state['research_questions'])} questions")
    print(f"Budget: ${planner.budget}")
    print("\n" + "="*50 + "\n")

    try:
        # Execute episode planning
        print("📋 Planning episode structure...")
        result = await planner.execute(test_state)

        # Display results
        print("✅ Episode plan created successfully!")
        print(f"💰 Cost: ${planner.total_cost:.3f} (Budget: ${planner.budget})")

        print("\n📊 Episode Structure:")
        episode_plan = result["episode_plan"]
        print(f"- Total Duration: {episode_plan['timing_analysis']['total_planned_duration']:.1f} minutes")
        print(f"- Number of Segments: {len(result['episode_segments'])}")

        print("\n🎯 Segments Breakdown:")
        for i, segment in enumerate(result["episode_segments"], 1):
            print(f"{i}. {segment['title']} ({segment['duration_minutes']:.1f} min)")
            print(f"   Key Points: {len(segment['key_points'])} points")
            if segment.get('nobody_knows_elements'):
                print(f"   🤔 'Nobody Knows' Elements: {len(segment['nobody_knows_elements'])}")
            print()

        print("⏱️ Timing Breakdown:")
        timing = result["timing_breakdown"]
        for segment_id, duration in timing.items():
            print(f"- {segment_id}: {duration:.1f} minutes")

        print(f"\n📈 Quality Metrics:")
        quality = episode_plan["quality_metrics"]
        for metric, score in quality.items():
            print(f"- {metric.replace('_', ' ').title()}: {score:.2f}")

        # Save detailed plan to file
        output_file = "demo_episode_plan.json"
        with open(output_file, 'w') as f:
            json.dump(result["episode_plan"], f, indent=2, default=str)
        print(f"\n💾 Detailed plan saved to: {output_file}")

    except Exception as e:
        print(f"❌ Error during episode planning: {str(e)}")
        return

    print("\n" + "="*50)
    print("✨ Episode Planner Demo Complete!")
    print(f"🎯 Ready to proceed to script writing with structured episode plan")

if __name__ == "__main__":
    asyncio.run(main())
