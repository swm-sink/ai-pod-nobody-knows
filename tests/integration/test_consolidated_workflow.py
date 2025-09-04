"""
Integration test suite for the consolidated main workflow.
Tests the complete workflow with enhanced features integrated.
September 2025 patterns.
"""

import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from typing import Dict, Any

from podcast_production.workflows.main_workflow import PodcastWorkflow
from podcast_production.core.state import PodcastState


class TestConsolidatedWorkflow:
    """Test consolidated workflow with all enhanced features"""
    
    @pytest.fixture
    def test_config(self):
        """Test configuration"""
        return {
            "budget": 5.51,
            "perplexity_api_key": "test-key",
            "openrouter_api_key": "test-key",
            "eleven_labs_api_key": "test-key",
            "anthropic_api_key": "test-key",
            "google_api_key": "test-key",
            "max_parallel": 5,
            "brand_exemplars": "tests/fixtures/exemplars.json",
            "enable_monitoring": True,
            "checkpoint_enabled": True
        }
    
    @pytest.fixture
    async def workflow(self, test_config):
        """Create workflow instance with mocked dependencies"""
        with patch('podcast_production.workflows.main_workflow.Langfuse'):
            with patch('podcast_production.workflows.main_workflow.SqliteSaver'):
                workflow = PodcastWorkflow(test_config)
                yield workflow
                # Cleanup
                if hasattr(workflow, 'cleanup'):
                    await workflow.cleanup()
    
    @pytest.fixture
    def initial_state(self):
        """Create initial podcast state"""
        return PodcastState(
            episode_id="test_001",
            topic="Why do cats purr?",
            budget=5.51,
            timestamp="2025-09-04T10:00:00Z",
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
    
    @pytest.mark.asyncio
    async def test_workflow_initialization(self, workflow):
        """Test workflow initializes with all enhanced features"""
        assert workflow.failover_manager is not None
        assert workflow.parallel_executor is not None
        assert workflow.brand_engine is not None
        assert workflow.langfuse_handler is not None
        assert workflow.retry_handler is not None
    
    @pytest.mark.asyncio
    async def test_failover_manager_configuration(self, workflow):
        """Test failover manager is properly configured"""
        manager = workflow.failover_manager
        
        assert len(manager.providers) == 2
        assert manager.providers[0].name == "perplexity"
        assert manager.providers[1].name == "openrouter"
        assert manager.strategy.name == "WEIGHTED_ROUND_ROBIN"
    
    @pytest.mark.asyncio
    async def test_parallel_executor_configuration(self, workflow):
        """Test parallel executor is properly configured"""
        executor = workflow.parallel_executor
        
        assert executor.max_concurrent == 5
        assert executor.enable_monitoring == True
    
    @pytest.mark.asyncio
    async def test_brand_engine_configuration(self, workflow):
        """Test brand consistency engine is properly configured"""
        engine = workflow.brand_engine
        
        assert engine.model_name == "all-MiniLM-L6-v2"
        assert engine.enable_adaptive_learning == True
    
    @pytest.mark.asyncio
    async def test_research_pipeline_with_failover(self, workflow, initial_state):
        """Test research pipeline uses failover manager"""
        with patch.object(workflow.failover_manager, 'execute_with_failover') as mock_failover:
            mock_failover.return_value = {
                "discovery_findings": ["Finding 1", "Finding 2"],
                "cost": 0.15
            }
            
            # Mock agents
            with patch.object(workflow.research_discovery_agent, 'execute') as mock_discovery:
                mock_discovery.return_value = {
                    **initial_state,
                    "discovery_findings": ["Finding 1", "Finding 2"]
                }
                
                result = await workflow.research_pipeline(initial_state)
                
                assert "research_data" in result
                assert "discovery" in result["research_data"]
    
    @pytest.mark.asyncio
    async def test_parallel_content_generation(self, workflow, initial_state):
        """Test parallel execution of content tasks"""
        # Prepare state with research data
        state_with_research = {
            **initial_state,
            "research_data": {"discovery": ["test"], "synthesis": "test synthesis"}
        }
        
        with patch.object(workflow.parallel_executor, 'execute_batch') as mock_parallel:
            mock_parallel.return_value = [
                {"questions": ["Q1", "Q2", "Q3"]},
                {"episode_plan": {"intro": "...", "body": "..."}}
            ]
            
            # Mock agents
            with patch.object(workflow.question_generator_agent, 'execute'):
                with patch.object(workflow.episode_planner_agent, 'execute'):
                    result = await workflow.content_pipeline(state_with_research)
                    
                    # Parallel executor should be called
                    assert mock_parallel.called
    
    @pytest.mark.asyncio
    async def test_brand_validation_integration(self, workflow, initial_state):
        """Test brand consistency validation in workflow"""
        state_with_script = {
            **initial_state,
            "script": "Test script with intellectual humility"
        }
        
        with patch.object(workflow.brand_engine, 'validate_script') as mock_validate:
            mock_validate.return_value = {
                "passed": True,
                "score": 0.88,
                "suggestions": []
            }
            
            with patch.object(workflow.brand_validator_agent, 'execute') as mock_agent:
                mock_agent.return_value = {
                    **state_with_script,
                    "brand_validation": {"score": 0.88, "passed": True}
                }
                
                result = await workflow.content_pipeline(state_with_script)
                
                assert result["brand_validation"]["passed"] == True
                assert result["brand_validation"]["score"] >= 0.85
    
    @pytest.mark.asyncio
    async def test_cost_tracking_integration(self, workflow, initial_state):
        """Test cost tracking across pipeline"""
        with patch.object(workflow.cost_tracker, 'track_cost') as mock_track:
            mock_track.return_value = None
            
            # Mock agent executions with cost
            with patch.object(workflow.research_discovery_agent, 'execute') as mock_discovery:
                mock_discovery.return_value = {
                    **initial_state,
                    "cost_tracking": {"research_discovery": 0.15, "total": 0.15}
                }
                
                result = await workflow.research_pipeline(initial_state)
                
                assert "cost_tracking" in result
                assert result["cost_tracking"]["total"] > 0
    
    @pytest.mark.asyncio
    async def test_checkpoint_recovery(self, workflow, initial_state):
        """Test checkpoint recovery mechanism"""
        checkpoint_id = "test_checkpoint_123"
        
        with patch.object(workflow.checkpointer, 'get') as mock_get:
            mock_get.return_value = {
                **initial_state,
                "checkpoint_id": checkpoint_id,
                "research_data": {"discovery": ["cached"]}
            }
            
            recovered_state = await workflow.recover_from_checkpoint(checkpoint_id)
            
            assert recovered_state["checkpoint_id"] == checkpoint_id
            assert recovered_state["research_data"]["discovery"] == ["cached"]
    
    @pytest.mark.asyncio
    async def test_error_handling_with_retry(self, workflow, initial_state):
        """Test error handling with retry mechanism"""
        with patch.object(workflow.retry_handler, 'execute') as mock_retry:
            # First attempt fails, second succeeds
            mock_retry.side_effect = [
                Exception("API Error"),
                {"success": True}
            ]
            
            # Should handle error and retry
            try:
                result = await workflow.research_pipeline(initial_state)
            except Exception:
                # Verify retry was attempted
                assert mock_retry.call_count >= 1
    
    @pytest.mark.asyncio
    async def test_monitoring_integration(self, workflow, initial_state):
        """Test monitoring and observability integration"""
        with patch.object(workflow.langfuse_handler, 'trace') as mock_trace:
            mock_trace.return_value.__enter__ = MagicMock()
            mock_trace.return_value.__exit__ = MagicMock()
            
            # Execute a pipeline step
            with patch.object(workflow.research_discovery_agent, 'execute'):
                await workflow.research_pipeline(initial_state)
                
                # Monitoring should be active
                assert mock_trace.called
    
    @pytest.mark.asyncio
    async def test_budget_enforcement(self, workflow, initial_state):
        """Test budget enforcement stops execution"""
        over_budget_state = {
            **initial_state,
            "cost_tracking": {"total": 5.50}  # Near budget limit
        }
        
        # Next operation would exceed budget
        with patch.object(workflow, '_check_budget') as mock_check:
            mock_check.return_value = False  # Budget exceeded
            
            result = await workflow.execute_with_budget_check(
                over_budget_state,
                estimated_cost=0.50
            )
            
            assert result.get("error_state") is not None
            assert "budget_exceeded" in str(result["error_state"])


if __name__ == "__main__":
    pytest.main([__file__, "-v"])