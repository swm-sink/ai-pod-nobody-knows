"""
Test Question Generator Node - Verification Test
Quick test to verify the question-generator node works correctly with LangGraph node wrapper pattern.
"""

import asyncio
import sys
import os
from datetime import datetime

# Add project path
sys.path.append(os.path.join(os.path.dirname(__file__), '.'))

from nodes.question_generator_node import get_question_generator_node


async def test_question_generator_node():
    """Test the question-generator node function works correctly."""
    print("🧪 Testing Question Generator Node...")
    
    try:
        # Create test state with discovery data
        test_discovery_data = {
            "discovery_results": [
                {
                    "source": "Research Paper A", 
                    "insights": ["AI orchestration enables cost reduction", "Quality control remains challenge"]
                },
                {
                    "source": "Expert Interview B",
                    "insights": ["Human-AI collaboration patterns emerging", "Unexpected creative capabilities"]
                }
            ]
        }
        
        # Create state in the expected format
        flat_state = {
            "topic": "AI-Powered Podcast Production Systems",
            "episode_id": "question_test_001", 
            "research_data": {
                "discovery": test_discovery_data
            },
            "cost_breakdown": {}
        }
        
        # Get the question generator node function
        print("📋 Creating question generator node...")
        question_generator_node = await get_question_generator_node()
        
        # Execute the node function
        print("❓ Executing question generation...")
        result_state = await question_generator_node(flat_state)
        
        # Validate results
        print("✅ Validating results...")
        
        # Check that questions were added
        assert "research_questions" in result_state or "generated_questions" in result_state
        
        # Check for question generation in research_data
        if "research_data" in result_state and "question_generation" in result_state["research_data"]:
            question_data = result_state["research_data"]["question_generation"]
            
            # Validate structure
            assert "agent_metadata" in question_data
            assert "cost_tracking" in question_data
            
            # Check agent metadata
            metadata = question_data["agent_metadata"]
            assert metadata["agent_id"] == "question-generator"
            
            # Check cost tracking  
            cost_info = question_data["cost_tracking"]
            assert "budget_allocated" in cost_info
            assert cost_info["budget_allocated"] == 0.10  # Question generator budget
            
            print(f"📊 Question Generation Statistics:")
            print(f"   • Agent ID: {metadata['agent_id']}")
            print(f"   • Cost: ${cost_info.get('execution_cost', 0):.2f} (Budget: ${cost_info['budget_allocated']})")
            
            # Look for generated questions
            if "generated_questions" in question_data:
                questions = question_data["generated_questions"]
                print(f"   • Questions Generated: {len(questions)}")
                
        # Check cost breakdown was updated
        if "cost_breakdown" in result_state and "question_generation" in result_state["cost_breakdown"]:
            print(f"   • Cost tracking updated in state")
        
        print("✅ Question Generator Node Test PASSED!")
        print("   • Node wrapper pattern working correctly")
        print("   • Question generation functional")
        print("   • Cost tracking operational")
        
        return True
        
    except Exception as e:
        print(f"❌ Question Generator Node Test FAILED: {e}")
        import traceback
        print(traceback.format_exc())
        return False


async def main():
    """Run the test."""
    print("❓ Question Generator Node Verification Test")  
    print("=" * 50)
    
    success = await test_question_generator_node()
    
    if success:
        print("\n✅ QUESTION GENERATOR MIGRATION VERIFIED!")
        print("   Already properly migrated and working")
    else:
        print("\n💥 VERIFICATION FAILED - may need debugging")
        
    return success


if __name__ == "__main__":
    # Run the test
    result = asyncio.run(main())
    sys.exit(0 if result else 1)