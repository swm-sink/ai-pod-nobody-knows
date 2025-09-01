"""
Comprehensive test suite for AgentOrchestrator system.
August 2025 Production Testing Standards

Tests centralized workflow coordination, cost tracking integration,
error handling, performance monitoring, and state management.
"""

import pytest
import asyncio
import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Any
from unittest.mock import Mock, AsyncMock, patch, MagicMock

# Import system under test
from core.agent_orchestrator import (
    AgentOrchestrator, create_orchestrator, ExecutionMode, AgentPriority,
    AgentMetrics, WorkflowPhase, execute_orchestrated_workflow
)
from workflows.orchestrated_workflow import (
    OrchestratedPodcastWorkflow, create_orchestrated_workflow,
    execute_orchestrated_workflow as execute_full_workflow
)
from core.state import PodcastState, create_initial_state
from core.cost_tracker import CostTracker, BudgetExceededException


class TestAgentOrchestrator:
    """Test suite for AgentOrchestrator core functionality."""
    
    @pytest.fixture
    def orchestrator(self):
        """Create orchestrator for testing."""
        return create_orchestrator(
            budget_limit=10.0,  # Higher budget for testing
            max_parallel=3,
            timeout_minutes=5
        )
    
    @pytest.fixture
    def sample_state(self):
        """Create sample podcast state for testing."""
        return create_initial_state(
            topic="Test Topic",
            budget=10.0,
            output_dir="./test_output"
        )
    
    @pytest.fixture
    def mock_agent_function(self):
        """Create mock agent function for testing."""
        async def mock_agent(state: PodcastState, config=None) -> PodcastState:
            # Simulate agent work
            await asyncio.sleep(0.1)  # Simulate processing time
            state['mock_result'] = True
            state['test_data'] = f"processed_by_mock_agent_{datetime.now().isoformat()}"
            return state
        return mock_agent
    
    @pytest.fixture
    def mock_expensive_agent(self):
        """Create mock agent that consumes budget."""
        async def expensive_agent(state: PodcastState, config=None) -> PodcastState:
            await asyncio.sleep(0.1)
            # Add significant cost
            state['cost_breakdown'] = state.get('cost_breakdown', {})
            state['cost_breakdown']['expensive_agent'] = 2.5
            state['total_cost'] = state.get('total_cost', 0.0) + 2.5
            return state
        return expensive_agent
    
    def test_orchestrator_initialization(self):
        """Test orchestrator initialization with various configurations."""
        # Test default initialization
        orchestrator = AgentOrchestrator()
        assert orchestrator.cost_budget_limit == 5.51
        assert orchestrator.max_parallel_agents == 5
        assert orchestrator.default_timeout_minutes == 10
        
        # Test custom initialization
        custom_orchestrator = AgentOrchestrator(
            max_parallel_agents=10,
            cost_budget_limit=20.0,
            default_timeout_minutes=15
        )
        assert custom_orchestrator.max_parallel_agents == 10
        assert custom_orchestrator.cost_budget_limit == 20.0
        assert custom_orchestrator.default_timeout_minutes == 15
    
    def test_standard_phases_initialization(self, orchestrator):
        """Test that standard workflow phases are properly initialized."""
        expected_phases = [
            "research_pipeline", "planning_pipeline", "production_pipeline",
            "quality_pipeline", "audio_pipeline"
        ]
        
        for phase in expected_phases:
            assert phase in orchestrator.workflow_phases
            phase_obj = orchestrator.workflow_phases[phase]
            assert isinstance(phase_obj, WorkflowPhase)
            assert phase_obj.name == phase
            assert isinstance(phase_obj.execution_mode, ExecutionMode)
    
    def test_agent_registration(self, orchestrator, mock_agent_function):
        """Test agent registration functionality."""
        # Register agent
        orchestrator.register_agent("test_agent", mock_agent_function, AgentPriority.HIGH)
        
        # Verify registration
        assert "test_agent" in orchestrator.registered_agents
        agent_info = orchestrator.registered_agents["test_agent"]
        assert agent_info['function'] == mock_agent_function
        assert agent_info['priority'] == AgentPriority.HIGH
        assert 'registered_at' in agent_info
        
        # Verify metrics tracking initialized
        assert "test_agent" in orchestrator.agent_metrics
        assert isinstance(orchestrator.agent_metrics["test_agent"], list)
    
    def test_workflow_phase_registration(self, orchestrator):
        """Test custom workflow phase registration."""
        custom_phase = WorkflowPhase(
            name="test_phase",
            agents=["agent1", "agent2"],
            execution_mode=ExecutionMode.PARALLEL,
            timeout_minutes=8,
            cost_budget=1.5
        )
        
        orchestrator.register_workflow_phase(custom_phase)
        
        assert "test_phase" in orchestrator.workflow_phases
        assert orchestrator.workflow_phases["test_phase"] == custom_phase
    
    @pytest.mark.asyncio
    async def test_single_agent_execution_monitoring(self, orchestrator, sample_state, mock_agent_function):
        """Test single agent execution with monitoring."""
        # Register agent
        orchestrator.register_agent("test_agent", mock_agent_function)
        
        # Mock cost tracker
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.check_budget_remaining.return_value = 5.0
        mock_cost_tracker.total_cost = 0.0
        orchestrator.cost_tracker = mock_cost_tracker
        
        # Execute agent
        result_state = await orchestrator._execute_agent_with_monitoring(
            "test_agent", sample_state, timeout_minutes=1
        )
        
        # Verify execution
        assert result_state['mock_result'] is True
        assert 'test_data' in result_state
        
        # Verify metrics were collected
        assert len(orchestrator.agent_metrics["test_agent"]) == 1
        metrics = orchestrator.agent_metrics["test_agent"][0]
        assert isinstance(metrics, AgentMetrics)
        assert metrics.agent_name == "test_agent"
        assert metrics.success is True
        assert metrics.execution_time_ms is not None
    
    @pytest.mark.asyncio
    async def test_agent_timeout_handling(self, orchestrator, sample_state):
        """Test agent timeout handling."""
        # Create slow agent that exceeds timeout
        async def slow_agent(state: PodcastState, config=None) -> PodcastState:
            await asyncio.sleep(10)  # Sleep longer than timeout
            return state
        
        orchestrator.register_agent("slow_agent", slow_agent)
        
        # Mock cost tracker
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.check_budget_remaining.return_value = 5.0
        orchestrator.cost_tracker = mock_cost_tracker
        
        # Execute with short timeout
        result_state = await orchestrator._execute_agent_with_monitoring(
            "slow_agent", sample_state, timeout_minutes=0.01  # Very short timeout
        )
        
        # Verify timeout was handled
        errors = result_state.get('errors', [])
        assert len(errors) > 0
        error_found = any('timeout' in str(error).lower() for error in errors)
        assert error_found
        
        # Verify metrics show failure
        metrics = orchestrator.agent_metrics["slow_agent"][-1]
        assert metrics.success is False
    
    @pytest.mark.asyncio
    async def test_budget_exceeded_handling(self, orchestrator, sample_state, mock_expensive_agent):
        """Test budget exceeded exception handling."""
        # Register expensive agent
        orchestrator.register_agent("expensive_agent", mock_expensive_agent)
        
        # Mock cost tracker with insufficient budget
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.check_budget_remaining.return_value = 0.05  # Very low budget
        orchestrator.cost_tracker = mock_cost_tracker
        
        # Execute agent
        result_state = await orchestrator._execute_agent_with_monitoring(
            "expensive_agent", sample_state, timeout_minutes=1
        )
        
        # Verify budget exceeded was handled
        errors = result_state.get('errors', [])
        assert len(errors) > 0
        error_found = any('budget' in str(error).lower() for error in errors)
        assert error_found
    
    @pytest.mark.asyncio
    async def test_sequential_execution(self, orchestrator, sample_state):
        """Test sequential agent execution."""
        # Create test agents
        async def agent1(state, config=None):
            state['agent1_executed'] = True
            return state
        
        async def agent2(state, config=None):
            state['agent2_executed'] = True
            # Should see agent1's result
            assert state.get('agent1_executed') is True
            return state
        
        # Register agents
        orchestrator.register_agent("agent1", agent1)
        orchestrator.register_agent("agent2", agent2)
        
        # Mock cost tracker
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.check_budget_remaining.return_value = 5.0
        orchestrator.cost_tracker = mock_cost_tracker
        
        # Create sequential phase
        test_phase = WorkflowPhase(
            name="test_sequential",
            agents=["agent1", "agent2"],
            execution_mode=ExecutionMode.SEQUENTIAL,
            timeout_minutes=5
        )
        
        # Execute phase
        result_state = await orchestrator._execute_sequential(test_phase, sample_state)
        
        # Verify both agents executed in order
        assert result_state.get('agent1_executed') is True
        assert result_state.get('agent2_executed') is True
    
    @pytest.mark.asyncio
    async def test_parallel_execution(self, orchestrator, sample_state):
        """Test parallel agent execution."""
        execution_order = []
        
        async def agent1(state, config=None):
            execution_order.append('agent1_start')
            await asyncio.sleep(0.2)
            execution_order.append('agent1_end')
            state['agent1_executed'] = True
            return state
        
        async def agent2(state, config=None):
            execution_order.append('agent2_start')
            await asyncio.sleep(0.1)
            execution_order.append('agent2_end')
            state['agent2_executed'] = True
            return state
        
        # Register agents
        orchestrator.register_agent("agent1", agent1)
        orchestrator.register_agent("agent2", agent2)
        
        # Mock cost tracker
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.check_budget_remaining.return_value = 5.0
        orchestrator.cost_tracker = mock_cost_tracker
        
        # Create parallel phase
        test_phase = WorkflowPhase(
            name="test_parallel",
            agents=["agent1", "agent2"],
            execution_mode=ExecutionMode.PARALLEL,
            parallel_limit=2,
            timeout_minutes=5
        )
        
        # Execute phase
        result_state = await orchestrator._execute_parallel(test_phase, sample_state)
        
        # Verify both agents executed
        assert result_state.get('agent1_executed') is True
        assert result_state.get('agent2_executed') is True
        
        # Verify they ran in parallel (both should start before either ends)
        agent1_start_idx = execution_order.index('agent1_start')
        agent2_start_idx = execution_order.index('agent2_start') 
        agent2_end_idx = execution_order.index('agent2_end')
        
        # agent2 should finish before agent1 (due to sleep times)
        assert agent2_end_idx < len(execution_order) - 1  # agent2 ends before final event
    
    def test_dependency_resolution(self, orchestrator):
        """Test workflow phase dependency resolution."""
        # Create phases with dependencies
        phase_a = WorkflowPhase("phase_a", ["agent1"], ExecutionMode.SEQUENTIAL)
        phase_b = WorkflowPhase("phase_b", ["agent2"], ExecutionMode.SEQUENTIAL, dependencies=["phase_a"])
        phase_c = WorkflowPhase("phase_c", ["agent3"], ExecutionMode.SEQUENTIAL, dependencies=["phase_b"])
        
        orchestrator.register_workflow_phase(phase_a)
        orchestrator.register_workflow_phase(phase_b)
        orchestrator.register_workflow_phase(phase_c)
        
        # Resolve dependencies
        execution_order = orchestrator._resolve_dependencies(["phase_c", "phase_a", "phase_b"])
        
        # Verify correct order
        assert execution_order == ["phase_a", "phase_b", "phase_c"]
    
    def test_orchestrator_status(self, orchestrator, mock_agent_function):
        """Test orchestrator status reporting."""
        # Register some agents
        orchestrator.register_agent("test_agent", mock_agent_function)
        
        # Mock cost tracker
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.check_budget_remaining.return_value = 3.5
        orchestrator.cost_tracker = mock_cost_tracker
        
        # Get status
        status = orchestrator.get_orchestrator_status()
        
        # Verify status structure
        expected_keys = [
            'registered_agents', 'workflow_phases', 'active_executions',
            'total_metrics_collected', 'cost_tracker_active',
            'current_budget_remaining', 'checkpointing_enabled',
            'performance_monitoring'
        ]
        
        for key in expected_keys:
            assert key in status
        
        assert 'test_agent' in status['registered_agents']
        assert status['cost_tracker_active'] is True
        assert status['current_budget_remaining'] == 3.5


class TestOrchestratedWorkflow:
    """Test suite for OrchestratedPodcastWorkflow."""
    
    @pytest.fixture
    def workflow(self):
        """Create orchestrated workflow for testing."""
        return create_orchestrated_workflow(
            budget_limit=10.0,
            max_parallel_agents=3
        )
    
    @pytest.fixture
    def sample_state(self):
        """Create sample state for workflow testing."""
        return create_initial_state(
            topic="Test Podcast Topic",
            budget=10.0,
            output_dir="./test_output"
        )
    
    def test_workflow_initialization(self, workflow):
        """Test orchestrated workflow initialization."""
        assert workflow.orchestrator is not None
        assert isinstance(workflow.orchestrator, AgentOrchestrator)
        assert workflow.config is not None
        assert workflow.graph is not None
    
    @pytest.mark.asyncio
    async def test_initialize_node(self, workflow, sample_state):
        """Test workflow initialization node."""
        result_state = await workflow._initialize_node(sample_state, None)
        
        assert result_state.get('current_stage') == 'initialized'
        assert 'orchestrator_status' in result_state
    
    @pytest.mark.asyncio
    async def test_budget_check_node(self, workflow, sample_state):
        """Test budget check node functionality."""
        # Mock cost tracker
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.total_cost = 2.5
        mock_cost_tracker.budget_limit = 10.0
        mock_cost_tracker.check_budget_remaining.return_value = 7.5
        mock_cost_tracker.to_dict.return_value = {'total_cost': 2.5, 'budget_limit': 10.0}
        
        workflow.orchestrator.cost_tracker = mock_cost_tracker
        
        result_state = await workflow._budget_check_node(sample_state, None)
        
        assert result_state.get('total_cost') == 2.5
        assert result_state.get('budget_remaining') == 7.5
        assert 'cost_data' in result_state
    
    @pytest.mark.asyncio
    async def test_error_handler_node(self, workflow, sample_state):
        """Test error handler node."""
        # Add errors to state
        sample_state['errors'] = [
            {'stage': 'test', 'error': 'test error', 'timestamp': datetime.now().isoformat()}
        ]
        
        result_state = await workflow._error_handler_node(sample_state, None)
        
        assert result_state.get('current_stage') == 'failed'
    
    def test_conditional_routing_functions(self, workflow, sample_state):
        """Test conditional routing functions."""
        # Test should_continue_workflow
        assert workflow._should_continue_workflow(sample_state) == "continue"
        
        # Test with errors
        error_state = sample_state.copy()
        error_state['errors'] = ['test error']
        assert workflow._should_continue_workflow(error_state) == "error"
        
        # Test with budget exceeded
        budget_state = sample_state.copy()
        budget_state['total_cost'] = 20.0
        budget_state['budget_limit'] = 10.0
        assert workflow._should_continue_workflow(budget_state) == "insufficient_budget"
    
    @pytest.mark.asyncio
    @patch('workflows.orchestrated_workflow.Path')
    async def test_generate_final_reports(self, mock_path, workflow, sample_state):
        """Test final report generation."""
        # Mock file operations
        mock_output_dir = Mock()
        mock_path.return_value = mock_output_dir
        mock_output_dir.mkdir.return_value = None
        
        mock_file = Mock()
        mock_output_dir.__truediv__.return_value.open.return_value.__enter__ = Mock(return_value=mock_file)
        mock_output_dir.__truediv__.return_value.open.return_value.__exit__ = Mock(return_value=None)
        
        # Add test data to state
        sample_state['episode_id'] = 'test_episode_123'
        sample_state['total_cost'] = 3.45
        sample_state['quality_scores'] = {'overall': 8.5}
        
        # Call function
        await workflow._generate_final_reports(sample_state)
        
        # Verify directory creation was attempted
        mock_output_dir.mkdir.assert_called_once()


class TestIntegration:
    """Integration tests for complete orchestrator system."""
    
    @pytest.mark.asyncio
    async def test_complete_workflow_execution_mock(self):
        """Test complete workflow execution with mocked agents."""
        # Create mock agent functions
        async def mock_research_agent(state, config=None):
            await asyncio.sleep(0.1)
            state['research_data'] = {'discovery': True, 'synthesis': True}
            return state
        
        async def mock_planning_agent(state, config=None):
            await asyncio.sleep(0.05)
            state['episode_plan'] = {'structure': 'complete', 'duration': 15}
            return state
        
        async def mock_script_agent(state, config=None):
            await asyncio.sleep(0.1)
            state['script_raw'] = "This is a test script with sufficient length to pass validation checks."
            return state
        
        # Create orchestrator and register agents
        orchestrator = create_orchestrator(budget_limit=5.0)
        orchestrator.register_agent("research_discovery", mock_research_agent)
        orchestrator.register_agent("episode_planner", mock_planning_agent)
        orchestrator.register_agent("script_writer", mock_script_agent)
        
        # Create initial state
        initial_state = create_initial_state(
            topic="Integration Test Topic",
            budget=5.0
        )
        
        # Execute simplified workflow (just a few phases)
        phases_to_run = ["research_pipeline", "planning_pipeline"]
        
        # Use workflow context
        async with orchestrator.workflow_context(
            episode_id=initial_state['episode_id'],
            topic=initial_state['topic'],
            budget=5.0
        ):
            final_state = await orchestrator.execute_workflow(
                initial_state=initial_state,
                phases_to_run=phases_to_run
            )
        
        # Verify execution results
        assert final_state is not None
        assert 'research_data' in final_state
        assert 'episode_plan' in final_state
        
        # Verify cost tracking
        assert final_state.get('total_cost', 0.0) >= 0.0
    
    @pytest.mark.asyncio
    async def test_budget_enforcement_integration(self):
        """Test budget enforcement across workflow execution."""
        # Create expensive mock agent
        async def expensive_agent(state, config=None):
            await asyncio.sleep(0.1)
            # Consume most of budget
            state['cost_breakdown'] = state.get('cost_breakdown', {})
            state['cost_breakdown']['expensive_agent'] = 4.0
            state['total_cost'] = state.get('total_cost', 0.0) + 4.0
            return state
        
        async def another_expensive_agent(state, config=None):
            # This should fail due to budget
            state['cost_breakdown'] = state.get('cost_breakdown', {})
            state['cost_breakdown']['another_expensive'] = 3.0
            state['total_cost'] = state.get('total_cost', 0.0) + 3.0
            return state
        
        # Create orchestrator with small budget
        orchestrator = create_orchestrator(budget_limit=5.0)
        orchestrator.register_agent("expensive_agent", expensive_agent)
        orchestrator.register_agent("another_expensive_agent", another_expensive_agent)
        
        # Mock cost tracker to simulate budget tracking
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.budget_limit = 5.0
        mock_cost_tracker.total_cost = 0.0
        
        def check_budget_side_effect():
            return max(0, mock_cost_tracker.budget_limit - mock_cost_tracker.total_cost)
        
        def track_cost_side_effect(agent_name, provider, model, **kwargs):
            cost = kwargs.get('cost', 0.0)
            mock_cost_tracker.total_cost += cost
            if mock_cost_tracker.total_cost > mock_cost_tracker.budget_limit:
                raise BudgetExceededException(f"Budget exceeded: {mock_cost_tracker.total_cost}")
            return cost
        
        mock_cost_tracker.check_budget_remaining.side_effect = check_budget_side_effect
        mock_cost_tracker.track_cost.side_effect = track_cost_side_effect
        orchestrator.cost_tracker = mock_cost_tracker
        
        # Create test state
        initial_state = create_initial_state(topic="Budget Test", budget=5.0)
        
        # Execute first expensive agent (should succeed)
        result1 = await orchestrator._execute_agent_with_monitoring(
            "expensive_agent", initial_state, timeout_minutes=1
        )
        
        # Update mock cost tracker
        mock_cost_tracker.total_cost = 4.0
        
        # Execute second expensive agent (should fail due to budget)
        result2 = await orchestrator._execute_agent_with_monitoring(
            "another_expensive_agent", result1, timeout_minutes=1
        )
        
        # Verify budget enforcement
        errors = result2.get('errors', [])
        budget_error_found = any('budget' in str(error).lower() for error in errors)
        assert budget_error_found
    
    def test_performance_metrics_collection(self):
        """Test that performance metrics are collected properly."""
        orchestrator = create_orchestrator()
        
        # Create mock agent with metrics
        async def measured_agent(state, config=None):
            await asyncio.sleep(0.1)
            return state
        
        orchestrator.register_agent("measured_agent", measured_agent)
        
        # Verify metrics tracking is initialized
        assert "measured_agent" in orchestrator.agent_metrics
        assert isinstance(orchestrator.agent_metrics["measured_agent"], list)
        
        # Verify orchestrator has performance monitoring enabled
        assert orchestrator.enable_performance_monitoring is True
    
    @pytest.mark.asyncio
    async def test_error_recovery_and_reporting(self):
        """Test error recovery mechanisms and reporting."""
        # Create failing agent
        async def failing_agent(state, config=None):
            raise ValueError("Simulated agent failure")
        
        orchestrator = create_orchestrator()
        orchestrator.register_agent("failing_agent", failing_agent)
        
        # Mock cost tracker
        mock_cost_tracker = Mock(spec=CostTracker)
        mock_cost_tracker.check_budget_remaining.return_value = 5.0
        orchestrator.cost_tracker = mock_cost_tracker
        
        initial_state = create_initial_state(topic="Error Test", budget=5.0)
        
        # Execute failing agent
        result_state = await orchestrator._execute_agent_with_monitoring(
            "failing_agent", initial_state, timeout_minutes=1
        )
        
        # Verify error was caught and reported
        assert 'errors' in result_state
        errors = result_state['errors']
        assert len(errors) > 0
        
        error_found = any('agent failure' in str(error).lower() for error in errors)
        assert error_found
        
        # Verify metrics recorded failure
        metrics = orchestrator.agent_metrics["failing_agent"]
        assert len(metrics) > 0
        assert metrics[-1].success is False


# Pytest fixtures for test configuration
@pytest.fixture(scope="session")
def test_output_dir():
    """Create test output directory."""
    output_dir = Path("./test_output")
    output_dir.mkdir(exist_ok=True)
    return output_dir


@pytest.fixture(autouse=True)
def cleanup_test_files(test_output_dir):
    """Clean up test files after each test."""
    yield
    # Cleanup code can be added here if needed
    pass


# Pytest configuration for async tests
@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for async tests."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


if __name__ == "__main__":
    # Run tests directly if script is executed
    pytest.main([__file__, "-v", "--asyncio-mode=auto"])