"""
Test suite for LangGraph Agent Nodes
Based on 2024 best practices: unit test routing logic with mock nodes
"""

import pytest
import asyncio
from unittest.mock import Mock, AsyncMock, patch, MagicMock
from typing import Dict, Any
from datetime import datetime

# Import our agents (these will be created in actual implementation)
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent / "src"))

from orchestrator import (
    PodcastState,
    ResearchDiscoveryNode,
    ScriptWriterNode,
    AudioSynthesizerNode,
    QualityValidatorNode,
    QualityScores
)


# ============================================================================
# Fixtures
# ============================================================================

@pytest.fixture
def mock_langfuse():
    """Mock LangFuse client for testing"""
    mock = MagicMock()
    mock.trace = MagicMock()
    mock.score = MagicMock()
    mock.get_prompt = MagicMock(return_value=MagicMock(compile=lambda: "test_prompt"))
    return mock


@pytest.fixture
def base_state() -> PodcastState:
    """Base podcast state for testing"""
    return PodcastState(
        episode_id="test_ep_001",
        topic="Test Topic",
        timestamp=datetime.now().isoformat(),
        research_queries=[],
        research_sources=[],
        research_data={},
        research_synthesis="",
        episode_structure={},
        script_draft="",
        script_final="",
        brand_validation={},
        tts_optimized_script="",
        audio_parameters={},
        audio_url="",
        audio_backup_urls=[],
        quality_scores=QualityScores(
            brand_alignment=0.0,
            technical_quality=0.0,
            engagement_potential=0.0,
            overall=0.0,
            confidence=0.0
        ),
        cost_breakdown={},
        total_cost=0.0,
        processing_time=0.0,
        current_phase="research",
        retry_count=0,
        error_log=[],
        ab_test_variant=None
    )


# ============================================================================
# Unit Tests for Agent Nodes
# ============================================================================

class TestResearchDiscoveryNode:
    """Test research discovery agent node"""

    @pytest.mark.asyncio
    async def test_execute_generates_queries(self, mock_langfuse, base_state):
        """Test that research discovery generates appropriate queries"""
        # Arrange
        node = ResearchDiscoveryNode("research_discovery", mock_langfuse)

        # Mock the internal methods
        node._generate_queries = AsyncMock(return_value=[
            "query1", "query2", "query3"
        ])
        node._search_sources = AsyncMock(return_value=[
            {"query": "test", "url": "http://example.com", "relevance": 0.9}
        ])

        # Act
        result = await node.execute(base_state)

        # Assert
        assert len(result["research_queries"]) == 3
        assert len(result["research_sources"]) > 0
        assert "research_discovery" in result["cost_breakdown"]
        mock_langfuse.trace.assert_called_once()

    @pytest.mark.asyncio
    async def test_cost_calculation(self, mock_langfuse, base_state):
        """Test that cost is calculated correctly"""
        # Arrange
        node = ResearchDiscoveryNode("research_discovery", mock_langfuse)
        node._generate_queries = AsyncMock(return_value=["q1", "q2"])
        node._search_sources = AsyncMock(return_value=[])

        # Act
        result = await node.execute(base_state)

        # Assert
        expected_cost = 2 * 0.02  # 2 queries * $0.02 per query
        assert result["cost_breakdown"]["research_discovery"] == expected_cost

    @pytest.mark.asyncio
    async def test_error_handling(self, mock_langfuse, base_state):
        """Test error handling in research discovery"""
        # Arrange
        node = ResearchDiscoveryNode("research_discovery", mock_langfuse)
        node._generate_queries = AsyncMock(side_effect=Exception("API Error"))

        # Act & Assert
        with pytest.raises(Exception) as exc_info:
            await node.execute(base_state)
        assert "API Error" in str(exc_info.value)


class TestScriptWriterNode:
    """Test script writer agent node"""

    @pytest.mark.asyncio
    async def test_execute_generates_script(self, mock_langfuse, base_state):
        """Test that script writer generates a script"""
        # Arrange
        node = ScriptWriterNode("script_writer", mock_langfuse)
        base_state["research_synthesis"] = "Test research"
        base_state["episode_structure"] = {"intro": "Test intro"}

        # Mock internal method
        node._generate_script = AsyncMock(return_value="Generated script content")

        # Act
        result = await node.execute(base_state)

        # Assert
        assert result["script_draft"] == "Generated script content"
        assert "script_writing" in result["cost_breakdown"]
        mock_langfuse.trace.assert_called_once()

    @pytest.mark.asyncio
    @pytest.mark.parametrize("episode_id,expected_variant", [
        ("test_even", "prod-a"),
        ("test_odd", "prod-b"),
    ])
    async def test_ab_testing_variants(self, mock_langfuse, base_state, episode_id, expected_variant):
        """Test A/B testing prompt variants"""
        # Arrange
        node = ScriptWriterNode("script_writer", mock_langfuse)
        base_state["episode_id"] = episode_id

        # Mock to check which variant is selected
        def get_prompt_side_effect(name, label):
            return MagicMock(compile=lambda: f"prompt_{label}")

        mock_langfuse.get_prompt.side_effect = get_prompt_side_effect
        node._generate_script = AsyncMock(return_value="Script")

        # Act
        await node.execute(base_state)

        # Assert
        # Check that correct variant was requested
        mock_langfuse.get_prompt.assert_called_with(
            name="script_writer_prompt",
            label=expected_variant
        )


class TestAudioSynthesizerNode:
    """Test audio synthesizer agent node"""

    @pytest.mark.asyncio
    async def test_execute_synthesizes_audio(self, mock_langfuse, base_state):
        """Test audio synthesis execution"""
        # Arrange
        node = AudioSynthesizerNode("audio_synthesizer", mock_langfuse)
        base_state["tts_optimized_script"] = "Test script"
        base_state["audio_parameters"] = {"voice": "test_voice"}

        # Mock internal method
        node._synthesize_audio = AsyncMock(
            return_value="https://audio.example.com/test.mp3"
        )

        # Act
        result = await node.execute(base_state)

        # Assert
        assert result["audio_url"] == "https://audio.example.com/test.mp3"
        assert len(result["audio_backup_urls"]) > 0
        assert "audio_synthesis" in result["cost_breakdown"]

    @pytest.mark.asyncio
    async def test_cost_per_character(self, mock_langfuse, base_state):
        """Test that cost is calculated per character"""
        # Arrange
        node = AudioSynthesizerNode("audio_synthesizer", mock_langfuse)
        test_script = "A" * 1000  # 1000 characters
        base_state["tts_optimized_script"] = test_script

        node._synthesize_audio = AsyncMock(return_value="url")

        # Act
        result = await node.execute(base_state)

        # Assert
        expected_cost = 1000 * 0.00001  # 1000 chars * $0.00001 per char
        assert result["cost_breakdown"]["audio_synthesis"] == expected_cost


class TestQualityValidatorNode:
    """Test quality validator agent node"""

    @pytest.mark.asyncio
    async def test_execute_evaluates_quality(self, mock_langfuse, base_state):
        """Test quality evaluation execution"""
        # Arrange
        node = QualityValidatorNode("quality_validator", mock_langfuse)

        # Mock evaluation methods
        node._evaluate_brand_alignment = AsyncMock(return_value=0.92)
        node._evaluate_technical_quality = AsyncMock(return_value=0.88)
        node._evaluate_engagement = AsyncMock(return_value=0.90)

        # Act
        result = await node.execute(base_state)

        # Assert
        scores = result["quality_scores"]
        assert scores["brand_alignment"] == 0.92
        assert scores["technical_quality"] == 0.88
        assert scores["engagement_potential"] == 0.90

        # Check overall calculation (0.92*0.4 + 0.88*0.3 + 0.90*0.3)
        expected_overall = 0.368 + 0.264 + 0.27
        assert abs(scores["overall"] - expected_overall) < 0.01

        # Check LangFuse score was logged
        mock_langfuse.score.assert_called_once()

    @pytest.mark.asyncio
    async def test_confidence_scoring(self, mock_langfuse, base_state):
        """Test confidence score assignment"""
        # Arrange
        node = QualityValidatorNode("quality_validator", mock_langfuse)
        node._evaluate_brand_alignment = AsyncMock(return_value=0.95)
        node._evaluate_technical_quality = AsyncMock(return_value=0.95)
        node._evaluate_engagement = AsyncMock(return_value=0.95)

        # Act
        result = await node.execute(base_state)

        # Assert
        assert result["quality_scores"]["confidence"] == 0.95


# ============================================================================
# Integration Tests with Mocked Workflow
# ============================================================================

class TestWorkflowIntegration:
    """Test workflow integration with mocked components"""

    @pytest.mark.asyncio
    async def test_full_workflow_execution(self, mock_langfuse, base_state):
        """Test full workflow execution with all nodes"""
        # This would test the full orchestrator workflow
        # For now, we're testing individual nodes
        pass

    @pytest.mark.asyncio
    async def test_quality_gate_routing(self, mock_langfuse, base_state):
        """Test quality gate decision routing"""
        # Test different quality scores lead to correct routing decisions
        pass


# ============================================================================
# Parametrized Tests
# ============================================================================

@pytest.mark.parametrize("topic,expected_queries", [
    ("AI Safety", ["latest developments AI Safety", "expert opinions AI Safety"]),
    ("Climate Tech", ["latest developments Climate Tech", "expert opinions Climate Tech"]),
])
@pytest.mark.asyncio
async def test_topic_based_queries(mock_langfuse, base_state, topic, expected_queries):
    """Test that different topics generate appropriate queries"""
    # Arrange
    node = ResearchDiscoveryNode("research_discovery", mock_langfuse)
    base_state["topic"] = topic

    # Mock to return topic-specific queries
    async def mock_generate(t):
        return [q.replace("Topic", t) for q in expected_queries]

    node._generate_queries = mock_generate
    node._search_sources = AsyncMock(return_value=[])

    # Act
    result = await node.execute(base_state)

    # Assert
    for expected in expected_queries:
        assert any(expected in q for q in result["research_queries"])


# ============================================================================
# Performance Tests
# ============================================================================

@pytest.mark.asyncio
@pytest.mark.timeout(5)  # Ensure execution completes within 5 seconds
async def test_node_performance(mock_langfuse, base_state):
    """Test that nodes execute within acceptable time limits"""
    node = ResearchDiscoveryNode("research_discovery", mock_langfuse)
    node._generate_queries = AsyncMock(return_value=["q1"])
    node._search_sources = AsyncMock(return_value=[])

    # Should complete quickly
    await node.execute(base_state)


# ============================================================================
# Error Scenarios
# ============================================================================

@pytest.mark.asyncio
async def test_retry_mechanism(mock_langfuse, base_state):
    """Test retry mechanism on failures"""
    # Test that nodes properly handle and retry on transient failures
    pass


@pytest.mark.asyncio
async def test_cost_limit_enforcement(mock_langfuse, base_state):
    """Test that cost limits are enforced"""
    # Test that workflow stops if cost exceeds limit
    pass


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
