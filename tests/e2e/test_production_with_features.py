"""
End-to-end test suite for complete production with enhanced features.
Tests full episode production with all integrated components.
September 2025 patterns.
"""

import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch, mock_open
import json
from datetime import datetime

from podcast_production.workflows.main_workflow import PodcastWorkflow
from podcast_production.core.state import PodcastState


class TestEndToEndProduction:
    """Test complete production pipeline end-to-end"""
    
    @pytest.fixture
    def production_config(self):
        """Production-like configuration"""
        return {
            "budget": 5.51,
            "environment": "test",
            "perplexity_api_key": "test-pplx-key",
            "openrouter_api_key": "test-or-key",
            "eleven_labs_api_key": "test-el-key",
            "anthropic_api_key": "test-anth-key",
            "google_api_key": "test-google-key",
            "max_parallel": 5,
            "brand_exemplars": "tests/fixtures/exemplars.json",
            "enable_monitoring": True,
            "checkpoint_enabled": True,
            "production_voice_id": "ZF6FPAbjXT4488VcRRnw"
        }
    
    @pytest.fixture
    def mock_api_responses(self):
        """Mock API responses for testing"""
        return {
            "perplexity_research": {
                "status": "success",
                "data": {
                    "findings": [
                        "Cats purr at frequencies between 25-150 Hz",
                        "Purring may have healing properties",
                        "Not all purring indicates happiness"
                    ],
                    "sources": ["nature.com", "science.org", "vetmed.edu"]
                }
            },
            "claude_evaluation": {
                "scores": {
                    "content": 8.5,
                    "structure": 9.0,
                    "engagement": 8.0
                },
                "feedback": "Well-structured, engaging content"
            },
            "gemini_evaluation": {
                "scores": {
                    "technical": 8.0,
                    "flow": 8.5,
                    "accessibility": 9.0
                },
                "feedback": "Technically accurate and accessible"
            },
            "elevenlabs_audio": {
                "audio_url": "https://storage.elevenlabs.io/test_audio.mp3",
                "duration": 1620  # 27 minutes
            }
        }
    
    @pytest.mark.asyncio
    async def test_complete_episode_production(self, production_config, mock_api_responses):
        """Test complete episode production from topic to audio"""
        
        # Create workflow with mocked external dependencies
        with patch('podcast_production.workflows.main_workflow.httpx.AsyncClient') as mock_client:
            with patch('podcast_production.workflows.main_workflow.Langfuse'):
                with patch('podcast_production.workflows.main_workflow.SqliteSaver'):
                    
                    # Setup API mocks
                    mock_client.return_value.__aenter__.return_value.post = AsyncMock(
                        side_effect=[
                            MagicMock(json=lambda: mock_api_responses["perplexity_research"]),
                            MagicMock(json=lambda: mock_api_responses["elevenlabs_audio"])
                        ]
                    )
                    
                    workflow = PodcastWorkflow(production_config)
                    
                    # Initial state
                    state = PodcastState(
                        episode_id="e2e_test_001",
                        topic="Why do cats purr?",
                        budget=5.51,
                        timestamp=datetime.now().isoformat(),
                        research_data={},
                        questions=[],
                        episode_plan={},
                        script="",
                        audio_url=None,
                        cost_tracking={"total": 0},
                        quality_scores={},
                        brand_validation={},
                        consensus_scores={},
                        checkpoint_id=None,
                        error_state=None,
                        retry_count=0
                    )
                    
                    # Mock agent responses
                    with patch.object(workflow.research_discovery_agent, 'execute') as mock_discovery:
                        mock_discovery.return_value = {
                            **state,
                            "discovery_findings": mock_api_responses["perplexity_research"]["data"]["findings"],
                            "cost_tracking": {"research_discovery": 0.15, "total": 0.15}
                        }
                        
                        with patch.object(workflow.script_writer_agent, 'execute') as mock_writer:
                            mock_writer.return_value = {
                                **state,
                                "script": "A 35,000 character script about cat purring...",
                                "cost_tracking": {"script_writer": 1.20, "total": 1.35}
                            }
                            
                            with patch.object(workflow.audio_synthesizer_agent, 'execute') as mock_audio:
                                mock_audio.return_value = {
                                    **state,
                                    "audio_url": mock_api_responses["elevenlabs_audio"]["audio_url"],
                                    "cost_tracking": {"audio_synthesis": 2.50, "total": 3.85}
                                }
                                
                                # Execute complete workflow
                                result = await workflow.execute_complete_production(state)
                                
                                # Verify complete production
                                assert result["audio_url"] is not None
                                assert result["cost_tracking"]["total"] <= 5.51
                                assert len(result["script"]) > 30000
                                assert result["error_state"] is None
    
    @pytest.mark.asyncio
    async def test_production_with_failover(self, production_config, mock_api_responses):
        """Test production continues with provider failover"""
        
        with patch('podcast_production.workflows.main_workflow.Langfuse'):
            with patch('podcast_production.workflows.main_workflow.SqliteSaver'):
                
                workflow = PodcastWorkflow(production_config)
                
                # Simulate primary provider failure
                with patch.object(workflow.failover_manager, 'execute_with_failover') as mock_failover:
                    # First call fails, second succeeds with backup provider
                    mock_failover.side_effect = [
                        Exception("Primary provider failed"),
                        mock_api_responses["perplexity_research"]
                    ]
                    
                    state = PodcastState(
                        episode_id="failover_test",
                        topic="Test topic",
                        budget=5.51,
                        timestamp=datetime.now().isoformat(),
                        research_data={},
                        questions=[],
                        episode_plan={},
                        script="",
                        audio_url=None,
                        cost_tracking={"total": 0},
                        quality_scores={},
                        brand_validation={},
                        consensus_scores={},
                        checkpoint_id=None,
                        error_state=None,
                        retry_count=0
                    )
                    
                    # Should handle failover gracefully
                    try:
                        result = await workflow.research_pipeline(state)
                        # If we get here, failover worked
                        assert mock_failover.call_count >= 2
                    except Exception as e:
                        # Should not fail completely
                        pytest.fail(f"Failover did not handle error: {e}")
    
    @pytest.mark.asyncio
    async def test_production_with_quality_revision(self, production_config):
        """Test production with quality-driven revision loop"""
        
        with patch('podcast_production.workflows.main_workflow.Langfuse'):
            with patch('podcast_production.workflows.main_workflow.SqliteSaver'):
                
                workflow = PodcastWorkflow(production_config)
                
                state = PodcastState(
                    episode_id="revision_test",
                    topic="Test topic",
                    budget=5.51,
                    timestamp=datetime.now().isoformat(),
                    research_data={"synthesis": "test"},
                    questions=["Q1"],
                    episode_plan={"structure": "test"},
                    script="Initial script that needs revision",
                    audio_url=None,
                    cost_tracking={"total": 2.0},
                    quality_scores={},
                    brand_validation={},
                    consensus_scores={},
                    checkpoint_id=None,
                    error_state=None,
                    retry_count=0
                )
                
                # First validation fails
                with patch.object(workflow.brand_engine, 'validate_script') as mock_validate:
                    mock_validate.side_effect = [
                        {"passed": False, "score": 0.70, "suggestions": ["Add more humility"]},
                        {"passed": True, "score": 0.86, "suggestions": []}
                    ]
                    
                    with patch.object(workflow.script_writer_agent, 'revise') as mock_revise:
                        mock_revise.return_value = {
                            **state,
                            "script": "Revised script with more intellectual humility",
                            "cost_tracking": {"revision": 0.5, "total": 2.5}
                        }
                        
                        result = await workflow.content_pipeline(state)
                        
                        # Should have triggered revision
                        assert mock_revise.called
                        assert mock_validate.call_count == 2
                        assert result["brand_validation"]["passed"] == True
    
    @pytest.mark.asyncio
    async def test_production_budget_enforcement(self, production_config):
        """Test production stops when budget is exceeded"""
        
        with patch('podcast_production.workflows.main_workflow.Langfuse'):
            with patch('podcast_production.workflows.main_workflow.SqliteSaver'):
                
                workflow = PodcastWorkflow(production_config)
                
                # State near budget limit
                state = PodcastState(
                    episode_id="budget_test",
                    topic="Test topic",
                    budget=5.51,
                    timestamp=datetime.now().isoformat(),
                    research_data={"synthesis": "test"},
                    questions=["Q1"],
                    episode_plan={"structure": "test"},
                    script="Script",
                    audio_url=None,
                    cost_tracking={"total": 5.40},  # Near limit
                    quality_scores={},
                    brand_validation={"passed": True, "score": 0.87},
                    consensus_scores={},
                    checkpoint_id=None,
                    error_state=None,
                    retry_count=0
                )
                
                # Next operation would exceed budget
                with patch.object(workflow.audio_synthesizer_agent, 'execute') as mock_audio:
                    mock_audio.return_value = {
                        **state,
                        "cost_tracking": {"audio_synthesis": 2.50, "total": 7.90}  # Exceeds budget
                    }
                    
                    result = await workflow.production_pipeline(state)
                    
                    # Should stop due to budget
                    assert result["error_state"] is not None
                    assert "budget" in str(result["error_state"]).lower()
    
    @pytest.mark.asyncio
    async def test_production_checkpoint_recovery(self, production_config):
        """Test production can recover from checkpoint"""
        
        with patch('podcast_production.workflows.main_workflow.Langfuse'):
            with patch('podcast_production.workflows.main_workflow.SqliteSaver') as mock_saver:
                
                workflow = PodcastWorkflow(production_config)
                
                # Saved checkpoint state (partially complete)
                checkpoint_state = {
                    "episode_id": "checkpoint_test",
                    "topic": "Test topic",
                    "budget": 5.51,
                    "timestamp": datetime.now().isoformat(),
                    "research_data": {"synthesis": "Already completed research"},
                    "questions": ["Q1", "Q2", "Q3"],
                    "episode_plan": {"structure": "Completed plan"},
                    "script": "",  # Not yet written
                    "audio_url": None,
                    "cost_tracking": {"total": 1.5},
                    "quality_scores": {},
                    "brand_validation": {},
                    "consensus_scores": {},
                    "checkpoint_id": "ckpt_123",
                    "error_state": None,
                    "retry_count": 1
                }
                
                # Mock checkpoint retrieval
                mock_saver.return_value.get = MagicMock(return_value=checkpoint_state)
                
                # Resume from checkpoint
                resumed_state = await workflow.resume_from_checkpoint("ckpt_123")
                
                assert resumed_state["research_data"]["synthesis"] == "Already completed research"
                assert resumed_state["cost_tracking"]["total"] == 1.5
                assert resumed_state["retry_count"] == 1
                
                # Should continue from where it left off
                with patch.object(workflow.script_writer_agent, 'execute') as mock_writer:
                    mock_writer.return_value = {
                        **resumed_state,
                        "script": "Newly written script",
                        "cost_tracking": {"script_writer": 1.20, "total": 2.70}
                    }
                    
                    result = await workflow.content_pipeline(resumed_state)
                    
                    # Should have written script
                    assert result["script"] == "Newly written script"
                    assert result["cost_tracking"]["total"] == 2.70
    
    @pytest.mark.asyncio
    async def test_production_metrics_collection(self, production_config):
        """Test production metrics are properly collected"""
        
        with patch('podcast_production.workflows.main_workflow.Langfuse'):
            with patch('podcast_production.workflows.main_workflow.SqliteSaver'):
                
                workflow = PodcastWorkflow(production_config)
                
                # Track metrics
                metrics = {
                    "start_time": datetime.now(),
                    "operations": []
                }
                
                with patch.object(workflow, 'collect_metrics') as mock_metrics:
                    mock_metrics.return_value = metrics
                    
                    state = PodcastState(
                        episode_id="metrics_test",
                        topic="Test topic",
                        budget=5.51,
                        timestamp=datetime.now().isoformat(),
                        research_data={},
                        questions=[],
                        episode_plan={},
                        script="",
                        audio_url=None,
                        cost_tracking={"total": 0},
                        quality_scores={},
                        brand_validation={},
                        consensus_scores={},
                        checkpoint_id=None,
                        error_state=None,
                        retry_count=0
                    )
                    
                    # Execute with metrics collection
                    result = await workflow.execute_with_metrics(state)
                    
                    # Metrics should be collected
                    assert mock_metrics.called
                    
                    # Generate metrics report
                    report = workflow.generate_metrics_report()
                    
                    assert "total_cost" in report
                    assert "execution_time" in report
                    assert "success_rate" in report


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])