"""
Test Episode Planner Node - Validation Test
Tests the episode-planner agent works correctly with LangGraph node wrapper pattern.
"""

import asyncio
import sys
import os
from datetime import datetime
from pathlib import Path

# Add project path
sys.path.append(os.path.join(os.path.dirname(__file__), '.'))

from nodes.episode_planner_node import get_episode_planner_node
from core.state_manager import create_state_manager


async def test_episode_planner_node():
    """Test the episode-planner node function works correctly."""
    print("🧪 Testing Episode Planner Node...")
    
    try:
        # Create test state with research synthesis
        manager = create_state_manager(
            episode_id="planner_test_001",
            topic="AI-Powered Podcast Production Systems"
        )
        
        # Mock research synthesis for episode planning
        test_research_synthesis = {
            "synthesized_knowledge": {
                "thematic_threads": [
                    {
                        "theme_title": "Technical Innovation",
                        "concepts": ["LangGraph", "state management", "orchestration"],
                        "significance": "Core technology enabling automation"
                    },
                    {
                        "theme_title": "Economic Impact",
                        "concepts": ["cost reduction", "democratization", "accessibility"],  
                        "significance": "From $3500 to $5.51 per episode"
                    },
                    {
                        "theme_title": "Creative Collaboration",
                        "concepts": ["human-AI partnership", "creative workflows", "quality control"],
                        "significance": "New paradigm for content creation"
                    }
                ]
            },
            "episode_hooks": {
                "curiosity_moments": [
                    "How does AI maintain creative quality at such low cost?",
                    "What happens to human creativity in AI collaboration?"
                ],
                "wonder_points": [
                    "The mystery of emergent AI capabilities",
                    "Unexpected connections between automation and creativity"
                ]
            }
        }
        
        # Mock research questions  
        test_research_questions = [
            "What are the key technological components that enable sub-$6 podcast production?",
            "How do quality control mechanisms work in automated creative workflows?",
            "What are the implications for content creators and the creative economy?",
            "Where do we still have knowledge gaps in AI-human collaboration?",
            "How might this technology evolve in the next 5 years?"
        ]
        
        # Create state with planning data in the expected format
        flat_state = {
            "topic": "AI-Powered Podcast Production Systems", 
            "episode_id": "planner_test_001",
            "research_synthesis": test_research_synthesis,
            "research_questions": test_research_questions,
            "target_duration": 15,  # 15 minute episode
            "cost_breakdown": {}
        }
        
        # Get the episode planner node function
        print("📋 Creating episode planner node...")
        episode_planner_node = await get_episode_planner_node()
        
        # Execute the node function
        print("🗓️ Executing episode planning...")
        result_state = await episode_planner_node(flat_state)
        
        # Validate results
        print("✅ Validating results...")
        
        # Check that episode plan was added
        assert "episode_plan" in result_state
        episode_data = result_state["episode_plan"]
        
        # Validate episode plan structure
        assert "agent_metadata" in episode_data
        assert "cost_tracking" in episode_data
        assert "episode_plan" in episode_data
        assert "segment_breakdown" in episode_data
        assert "timing_analysis" in episode_data
        
        # Check agent metadata
        metadata = episode_data["agent_metadata"]
        assert metadata["agent_id"] == "episode-planner"
        assert "execution_timestamp" in metadata
        assert "episode_context" in metadata
        
        episode_context = metadata["episode_context"]
        assert episode_context["topic"] == "AI-Powered Podcast Production Systems"
        assert episode_context["target_duration_minutes"] == 15
        
        # Validate cost tracking
        cost_info = episode_data["cost_tracking"]
        assert "execution_cost" in cost_info
        assert "budget_allocated" in cost_info
        assert cost_info["budget_allocated"] == 0.20  # Episode planner budget
        
        # Validate episode plan structure
        plan_structure = episode_data["episode_plan"]
        assert "themes_integrated" in plan_structure
        assert "target_duration" in plan_structure
        assert plan_structure["target_duration"] == 15
        
        # Validate segment breakdown
        segment_breakdown = episode_data["segment_breakdown"]
        assert "segments" in segment_breakdown
        segments = segment_breakdown["segments"]
        assert len(segments) > 0, "Should have at least one segment"
        
        # Check segment structure
        for segment in segments:
            assert "segment_id" in segment
            assert "title" in segment
            assert "duration_minutes" in segment
            assert "key_points" in segment
            assert "talking_points" in segment
            assert isinstance(segment["key_points"], list)
            assert isinstance(segment["talking_points"], list)
        
        # Validate timing analysis
        timing_analysis = episode_data["timing_analysis"]
        assert "total_planned_duration" in timing_analysis
        assert "segment_durations" in timing_analysis
        assert "pacing_assessment" in timing_analysis
        
        total_duration = timing_analysis["total_planned_duration"]
        assert total_duration > 0, "Total duration should be positive"
        assert abs(total_duration - 15) < 3, f"Duration should be close to 15 minutes, got {total_duration}"
        
        # Validate quality metrics
        assert "quality_metrics" in episode_data
        quality_metrics = episode_data["quality_metrics"]
        expected_metrics = [
            "structure_coherence",
            "timing_accuracy", 
            "engagement_potential",
            "intellectual_humility_integration"
        ]
        
        for metric in expected_metrics:
            assert metric in quality_metrics, f"Missing quality metric: {metric}"
            score = quality_metrics[metric]
            assert 0.0 <= score <= 1.0, f"Invalid quality score for {metric}: {score}"
        
        # Check state updates for pipeline
        assert "episode_segments" in result_state, "episode_segments should be set for pipeline"
        assert "timing_breakdown" in result_state, "timing_breakdown should be set"
        
        # Validate cost breakdown was updated
        assert "cost_breakdown" in result_state
        assert "episode_planning" in result_state["cost_breakdown"]
        
        print(f"📊 Episode Planning Statistics:")
        print(f"   • Total Duration: {total_duration:.1f} minutes (Target: 15)")
        print(f"   • Number of Segments: {len(segments)}")
        print(f"   • Cost: ${cost_info['execution_cost']:.2f} (Budget: ${cost_info['budget_allocated']})")
        print(f"   • Pacing Assessment: {timing_analysis['pacing_assessment']}")
        
        # Print segment breakdown
        print(f"   • Segments:")
        for i, segment in enumerate(segments):
            duration = segment["duration_minutes"]
            title = segment["title"]
            print(f"     {i+1}. {title}: {duration:.1f} min")
        
        # Print quality scores
        print(f"   • Quality Scores:")
        for metric, score in quality_metrics.items():
            metric_name = metric.replace('_', ' ').title()
            print(f"     • {metric_name}: {score:.2f}")
        
        print("✅ Episode Planner Node Test PASSED!")
        print("   • Node wrapper pattern working correctly")
        print("   • Episode structure generation functional")
        print("   • Timing analysis operational")
        print("   • Cost tracking accurate")
        print("   • Segment planning complete")
        
        return True
        
    except Exception as e:
        print(f"❌ Episode Planner Node Test FAILED: {e}")
        import traceback
        print(traceback.format_exc())
        return False


async def main():
    """Run the test."""
    print("📚 Episode Planner Node Migration Test")
    print("=" * 50)
    
    success = await test_episode_planner_node()
    
    if success:
        print("\n🎉 EPISODE PLANNER MIGRATION COMPLETE!")
        print("   Ready for planning pipeline integration")
    else:
        print("\n💥 MIGRATION FAILED - requires debugging")
        
    return success


if __name__ == "__main__":
    # Run the test
    result = asyncio.run(main())
    sys.exit(0 if result else 1)