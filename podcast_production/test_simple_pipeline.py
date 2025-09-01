#!/usr/bin/env python3
"""
Simple Pipeline Test

Direct test of the agents without the complex provider system.
"""

import asyncio
import sys
from datetime import datetime
from pathlib import Path

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from agents.research_discovery import ResearchDiscoveryAgent
from agents.research_deep_dive import ResearchDeepDiveAgent
from agents.research_validation import ResearchValidationAgent
from agents.research_synthesis import ResearchSynthesisAgent
from agents.question_generator import QuestionGeneratorAgent
from agents.episode_planner import EpisodePlannerAgent
from agents.script_writer import ScriptWriterAgent
from agents.brand_validator import BrandValidatorAgent


async def test_research_agents():
    """Test research agents in sequence."""
    print("🔬 Testing Research Agents")
    print("=" * 50)

    # Create test state
    state = {
        "topic": "quantum computing",
        "episode_id": f"test_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        "research_data": {},
        "cost_breakdown": {},
        "error_log": []
    }

    try:
        # Test Discovery Agent
        print("1. Testing Research Discovery Agent...")
        discovery_agent = ResearchDiscoveryAgent()
        state = await discovery_agent.execute(state)
        print(f"   ✅ Discovery completed. Sources found: {len(state.get('research_sources', []))}")

        # Test Deep Dive Agent
        print("2. Testing Research Deep Dive Agent...")
        deep_dive_agent = ResearchDeepDiveAgent()
        state = await deep_dive_agent.execute(state)
        print(f"   ✅ Deep dive completed.")

        # Test Validation Agent
        print("3. Testing Research Validation Agent...")
        validation_agent = ResearchValidationAgent()
        state = await validation_agent.execute(state)
        print(f"   ✅ Validation completed.")

        # Test Synthesis Agent
        print("4. Testing Research Synthesis Agent...")
        synthesis_agent = ResearchSynthesisAgent()
        state = await synthesis_agent.execute(state)
        print(f"   ✅ Synthesis completed.")

        total_cost = sum(state.get("cost_breakdown", {}).values())
        print(f"\n💰 Total Research Cost: ${total_cost:.4f}")

        return state

    except Exception as e:
        print(f"❌ Research agents test failed: {e}")
        import traceback
        traceback.print_exc()
        return None


async def test_production_agents(research_state):
    """Test production agents in sequence."""
    print("\n🏭 Testing Production Agents")
    print("=" * 50)

    try:
        # Test Question Generator
        print("1. Testing Question Generator Agent...")
        question_agent = QuestionGeneratorAgent()
        state = await question_agent.execute(research_state)
        questions_count = len(state.get("research_questions", []))
        print(f"   ✅ Question generation completed. Generated {questions_count} questions.")

        # Test Episode Planner
        print("2. Testing Episode Planner Agent...")
        planner_agent = EpisodePlannerAgent()
        state = await planner_agent.execute(state)
        print(f"   ✅ Episode planning completed.")

        # Test Script Writer
        print("3. Testing Script Writer Agent...")
        writer_agent = ScriptWriterAgent()
        state = await writer_agent.execute(state)
        script_length = len(state.get("script_raw", ""))
        print(f"   ✅ Script writing completed. Script length: {script_length} characters.")

        # Test Brand Validator
        print("4. Testing Brand Validator Agent...")
        brand_agent = BrandValidatorAgent()
        state = await brand_agent.execute(state)
        overall_score = state.get("quality_scores", {}).get("overall", 0)
        print(f"   ✅ Brand validation completed. Overall score: {overall_score}/10.")

        total_cost = sum(state.get("cost_breakdown", {}).values())
        print(f"\n💰 Total Production Cost: ${total_cost:.4f}")

        return state

    except Exception as e:
        print(f"❌ Production agents test failed: {e}")
        import traceback
        traceback.print_exc()
        return None


async def main():
    """Main test function."""
    print("🧪 Simple Pipeline Integration Test")
    print("=" * 60)

    try:
        # Test research pipeline
        research_state = await test_research_agents()
        if not research_state:
            print("❌ Research pipeline test failed!")
            return False

        # Test production pipeline
        final_state = await test_production_agents(research_state)
        if not final_state:
            print("❌ Production pipeline test failed!")
            return False

        # Overall summary
        total_cost = sum(final_state.get("cost_breakdown", {}).values())

        print("\n🎉 PIPELINE INTEGRATION TEST SUCCESSFUL!")
        print("=" * 60)
        print(f"Topic: {final_state.get('topic')}")
        print(f"Total Cost: ${total_cost:.4f}")
        print(f"Final Stage: {final_state.get('current_stage', 'completed')}")

        # Save test results
        import json
        output_dir = Path("./pipeline_output")
        output_dir.mkdir(parents=True, exist_ok=True)

        result_file = output_dir / f"simple_test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(result_file, 'w') as f:
            json.dump(final_state, f, indent=2, default=str)

        print(f"Results saved to: {result_file}")
        return True

    except Exception as e:
        print(f"💥 Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    success = asyncio.run(main())
    sys.exit(0 if success else 1)
