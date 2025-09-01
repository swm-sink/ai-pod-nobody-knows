"""
Test Script Writer Node - Validation Test
Tests the script-writer agent works correctly with LangGraph node wrapper pattern.
"""

import asyncio
import sys
import os
from datetime import datetime
from pathlib import Path

# Add project path
sys.path.append(os.path.join(os.path.dirname(__file__), '.'))

from nodes.script_writer_node import get_script_writer_node
from core.state_manager import create_state_manager


async def test_script_writer_node():
    """Test the script-writer node function works correctly."""
    print("🧪 Testing Script Writer Node...")
    
    try:
        # Create test state
        manager = create_state_manager(
            episode_id="script_test_001",
            topic="AI-Powered Podcast Production Systems"
        )
        
        # Add required research synthesis data for script writing
        test_research_synthesis = {
            "narrative_structure": {
                "main_themes": [
                    {"title": "AI Automation Revolution", "concepts": ["automation", "efficiency", "scalability"]},
                    {"title": "Cost Optimization", "concepts": ["budget", "efficiency", "ROI"]}
                ],
                "story_arc": "discovery_to_implementation"
            },
            "episode_hooks": {
                "opening_hooks": [
                    "What if I told you that AI could produce a professional podcast for under $6?",
                    "The future of content creation is here, and it costs less than your coffee"
                ],
                "curiosity_moments": [
                    "How does this actually work behind the scenes?",
                    "What are the implications for creators everywhere?"
                ]
            },
            "synthesized_knowledge": {
                "thematic_threads": [
                    {
                        "title": "Technical Innovation",
                        "concepts": ["LangGraph", "state management", "orchestration"],
                        "hook": "The technology stack that makes this possible"
                    },
                    {
                        "title": "Economic Impact", 
                        "concepts": ["cost reduction", "democratization", "accessibility"],
                        "hook": "From $3500 to $5.51 - how AI changes everything"
                    }
                ]
            }
        }
        
        # Update state with research data and episode plan
        manager.update_persistent({
            "research_data": {
                "synthesis": test_research_synthesis
            }
        })
        
        # Note: episode_plan isn't part of PersistentState schema, so we'll add it to the flat state directly
        episode_plan = {
            "duration_minutes": 15,
            "target_audience": "AI developers and content creators"
        }
        
        state = manager.get_state()
        
        # The agent expects a flattened state, not the nested StateManager format
        # Convert to agent-compatible format
        flat_state = {
            "topic": state["persistent"]["topic"],
            "episode_id": state["persistent"]["episode_id"],
            "research_data": state["persistent"]["research_data"],
            "episode_plan": episode_plan,  # Use the local episode_plan
            "cost_breakdown": state["persistent"]["cost_breakdown"]
        }
        
        # Get the script writer node function
        print("📋 Creating script writer node...")
        script_writer_node = await get_script_writer_node()
        
        # Execute the node function
        print("✍️  Executing script writing...")
        result_state = await script_writer_node(flat_state)
        
        # Validate results
        print("✅ Validating results...")
        
        # Check that script content was added
        assert "research_data" in result_state
        assert "script_writing" in result_state["research_data"]
        script_data = result_state["research_data"]["script_writing"]
        
        # Validate script structure
        assert "script_content" in script_data
        assert "full_script" in script_data["script_content"]
        assert "tts_optimized" in script_data["script_content"]
        
        # Check script content has actual content
        full_script = script_data["script_content"]["full_script"]
        assert len(full_script) > 100, "Script should have substantial content"
        
        # Validate cost tracking
        assert "cost_tracking" in script_data
        cost_info = script_data["cost_tracking"]
        assert "execution_cost" in cost_info
        assert "budget_allocated" in cost_info
        assert cost_info["budget_allocated"] == 1.75  # Script writer budget
        
        # Validate quality metrics
        assert "quality_metrics" in script_data
        quality = script_data["quality_metrics"]
        assert "word_count" in quality
        assert "estimated_duration" in quality
        assert quality["word_count"] > 0
        
        # Validate brand voice integration
        assert "brand_voice_integration" in script_data
        brand_voice = script_data["brand_voice_integration"]
        assert "intellectual_humility_moments" in brand_voice
        assert "curiosity_building_elements" in brand_voice
        
        # Check TTS optimization was applied
        tts_optimized = script_data["script_content"]["tts_optimized"]
        assert len(tts_optimized) > 0
        
        # Validate output files would be created
        assert "agent_metadata" in script_data
        metadata = script_data["agent_metadata"]
        assert metadata["agent_id"] == "script-writer"
        assert "execution_timestamp" in metadata
        
        print(f"📊 Script Statistics:")
        print(f"   • Word Count: {quality['word_count']}")
        print(f"   • Estimated Duration: {quality['estimated_duration']:.1f} minutes")
        print(f"   • Cost: ${cost_info['execution_cost']:.2f} (Budget: ${cost_info['budget_allocated']})")
        print(f"   • Brand Voice Score: {quality.get('brand_voice_consistency', 'N/A')}")
        
        # Check state updates for pipeline
        assert "script_raw" in result_state, "script_raw should be set for pipeline"
        assert "tts_optimized_script" in result_state, "tts_optimized_script should be set"
        assert "audio_parameters" in result_state, "audio_parameters should be set"
        
        audio_params = result_state["audio_parameters"]
        assert "script_metadata" in audio_params
        script_meta = audio_params["script_metadata"]
        assert "word_count" in script_meta
        assert "estimated_duration" in script_meta
        assert "pronunciation_guides" in script_meta
        
        print("✅ Script Writer Node Test PASSED!")
        print("   • Node wrapper pattern working correctly")
        print("   • State management functional")
        print("   • Pipeline integration complete")
        print("   • Cost tracking operational")
        print("   • Brand voice integration validated")
        
        return True
        
    except Exception as e:
        print(f"❌ Script Writer Node Test FAILED: {e}")
        import traceback
        print(traceback.format_exc())
        return False


async def main():
    """Run the test."""
    print("🎬 Script Writer Node Migration Test")
    print("=" * 50)
    
    success = await test_script_writer_node()
    
    if success:
        print("\n🎉 SCRIPT WRITER MIGRATION COMPLETE!")
        print("   Ready for production pipeline integration")
    else:
        print("\n💥 MIGRATION FAILED - requires debugging")
        
    return success


if __name__ == "__main__":
    # Run the test
    result = asyncio.run(main())
    sys.exit(0 if result else 1)