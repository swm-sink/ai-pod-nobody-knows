"""
Test Brand Validator Node - Validation Test
Tests the brand-validator agent works correctly with LangGraph node wrapper pattern.
"""

import asyncio
import sys
import os
from datetime import datetime
from pathlib import Path

# Add project path
sys.path.append(os.path.join(os.path.dirname(__file__), '.'))

from nodes.brand_validator_node import get_brand_validator_node
from core.state_manager import create_state_manager


async def test_brand_validator_node():
    """Test the brand-validator node function works correctly."""
    print("🧪 Testing Brand Validator Node...")
    
    try:
        # Create test state with script content
        manager = create_state_manager(
            episode_id="brand_test_001",
            topic="AI-Powered Podcast Production Systems"
        )
        
        # Mock script content for brand validation
        test_script_content = """
        What if I told you that AI could produce a professional podcast for under $6?
        
        Now, I'm not claiming we know everything about this technology - far from it! But what 
        we're discovering is absolutely fascinating, and I think you're going to find this journey 
        as exciting as I do.
        
        Here's what's remarkable: current evidence suggests that AI orchestration systems can 
        automate complex creative workflows while maintaining quality that would traditionally 
        cost thousands of dollars. But here's the thing - we're still learning about the 
        implications and possibilities.
        
        The experts working on this are the first to say "we don't have all the answers yet."
        Dr. Sarah Chen from Stanford recently told me, "Every breakthrough opens up three new 
        questions we never thought to ask." And isn't that wonderful?
        
        What we don't yet know might be even more intriguing than what we do know. The mystery
        of how consciousness emerges from computation, the unexplored possibilities of 
        human-AI collaboration - these aren't limitations, they're invitations to wonder.
        
        Think of it like exploring a vast new continent. We can see the coastline clearly now,
        but the interior holds secrets and wonders we're just beginning to glimpse.
        
        So let's explore this together, shall we? Because the next time you create something,
        you might be working alongside AI in ways that seemed impossible just years ago.
        
        The future is here, and it's full of beautiful questions waiting to be discovered.
        """
        
        # Create state with script content in the expected format
        flat_state = {
            "topic": "AI-Powered Podcast Production Systems",
            "episode_id": "brand_test_001",
            "script_raw": test_script_content,  # Primary script field
            "script_polished": test_script_content,  # Alternative script field
            "cost_breakdown": {}
        }
        
        # Get the brand validator node function
        print("📋 Creating brand validator node...")
        brand_validator_node = await get_brand_validator_node()
        
        # Execute the node function
        print("🔍 Executing brand validation...")
        result_state = await brand_validator_node(flat_state)
        
        # Validate results
        print("✅ Validating results...")
        
        # Check that brand validation was added
        assert "brand_validation" in result_state
        brand_data = result_state["brand_validation"]
        
        # Validate brand validation structure
        assert "agent_metadata" in brand_data
        assert "cost_tracking" in brand_data
        assert "brand_scores" in brand_data
        assert "overall_score" in brand_data
        assert "passed" in brand_data
        
        # Check agent metadata
        metadata = brand_data["agent_metadata"]
        assert metadata["agent_id"] == "brand-validator"
        assert "execution_timestamp" in metadata
        assert "validation_criteria" in metadata
        
        # Validate cost tracking
        cost_info = brand_data["cost_tracking"]
        assert "execution_cost" in cost_info
        assert "budget_allocated" in cost_info
        assert cost_info["budget_allocated"] == 0.25  # Brand validator budget
        
        # Validate brand scores
        brand_scores = brand_data["brand_scores"]
        expected_guidelines = [
            "intellectual_humility",
            "curiosity_expression", 
            "mystery_celebration",
            "accessibility",
            "voice_consistency"
        ]
        
        for guideline in expected_guidelines:
            assert guideline in brand_scores, f"Missing guideline: {guideline}"
            score = brand_scores[guideline]
            assert 0.0 <= score <= 10.0, f"Invalid score for {guideline}: {score}"
        
        # Validate overall score calculation
        overall_score = brand_data["overall_score"]
        assert 0.0 <= overall_score <= 10.0, f"Invalid overall score: {overall_score}"
        
        # Check if validation passed/failed
        passed = brand_data["passed"]
        assert isinstance(passed, bool)
        
        # Validate suggestions and violations exist
        assert "suggestions" in brand_data
        assert "violations" in brand_data
        assert "exemplary_sections" in brand_data
        
        # Check quality scores were updated in state
        assert "quality_scores" in result_state
        assert "brand_alignment" in result_state["quality_scores"]
        brand_alignment_score = result_state["quality_scores"]["brand_alignment"]
        assert 0.0 <= brand_alignment_score <= 1.0, f"Invalid brand alignment score: {brand_alignment_score}"
        
        # Validate cost breakdown was updated
        assert "cost_breakdown" in result_state
        assert "brand_validation" in result_state["cost_breakdown"]
        
        print(f"📊 Brand Validation Statistics:")
        print(f"   • Overall Score: {overall_score:.1f}/10.0")
        print(f"   • Passed: {'✅' if passed else '❌'}")
        print(f"   • Cost: ${cost_info['execution_cost']:.2f} (Budget: ${cost_info['budget_allocated']})")
        print(f"   • Guidelines Checked: {len(brand_scores)}")
        
        # Print individual guideline scores
        for guideline, score in brand_scores.items():
            print(f"   • {guideline.replace('_', ' ').title()}: {score:.1f}/10.0")
        
        # Print suggestions if any
        if brand_data["suggestions"]:
            print(f"   • Suggestions: {len(brand_data['suggestions'])}")
            for i, suggestion in enumerate(brand_data["suggestions"][:2], 1):
                print(f"     {i}. {suggestion[:80]}...")
        
        # Print violations if any
        if brand_data["violations"]:
            print(f"   • Violations: {len(brand_data['violations'])}")
        
        print("✅ Brand Validator Node Test PASSED!")
        print("   • Node wrapper pattern working correctly")
        print("   • Brand validation functional")
        print("   • Quality scoring operational")
        print("   • Cost tracking accurate")
        print("   • All brand guidelines evaluated")
        
        return True
        
    except Exception as e:
        print(f"❌ Brand Validator Node Test FAILED: {e}")
        import traceback
        print(traceback.format_exc())
        return False


async def main():
    """Run the test."""
    print("🎭 Brand Validator Node Migration Test")
    print("=" * 50)
    
    success = await test_brand_validator_node()
    
    if success:
        print("\n🎉 BRAND VALIDATOR MIGRATION COMPLETE!")
        print("   Ready for quality pipeline integration")
    else:
        print("\n💥 MIGRATION FAILED - requires debugging")
        
    return success


if __name__ == "__main__":
    # Run the test
    result = asyncio.run(main())
    sys.exit(0 if result else 1)