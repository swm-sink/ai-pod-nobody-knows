# TODO: Consider wrapping critical async calls with self.retry_handler.execute_with_retry()
"""
AgentOrchestrator - Centralized Workflow Coordination System
August 2025 Production Architecture

Provides centralized coordination for all agent interactions with proper state
management, cost tracking integration, error handling, and performance monitoring.
"""

import asyncio
import logging
import time
from contextlib import asynccontextmanager
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any, Optional, Callable, TypeVar, Generic, Union
from dataclasses import dataclass, field
from enum import Enum
import json
from core.retry_handler import RetryHandler, RetryConfig, CircuitBreakerState

# LangGraph integration
try:
    from langgraph.graph import StateGraph, END
    from langgraph.checkpoint.memory import MemorySaver
    from langchain_core.runnables import RunnableConfig
except ImportError:
    # Fallback for environments without LangGraph
    print("Warning: LangGraph not installed. Using mock implementations.")
    
    class StateGraph:
        def __init__(self, state_type): pass
        def add_node(self, name, func):
        # Initialize retry handler with circuit breaker
        self.retry_handler = RetryHandler(
            config=RetryConfig(
                max_attempts=3,
                failure_threshold=5,
                recovery_timeout=30.0
            ),
            name='stategraph'
        )
 pass
        def add_edge(self, from_node, to_node): pass
        def add_conditional_edges(self, node, condition, mapping): pass
        def set_entry_point(self, node): pass
        def compile(self, checkpointer=None): return MockCompiledGraph()
    
    class MockCompiledGraph:
        async def ainvoke(self, state, config=None): return state
    
    class MemorySaver: pass
    END = "END"

from core.state import PodcastState, update_stage, add_error, update_cost, is_over_budget
from core.cost_tracker import CostTracker, BudgetExceededException
from core.cost_tracker_manager import get_cost_tracker_manager
from core.state_manager import StateManager, create_state_manager

logger = logging.getLogger(__name__)

T = TypeVar('T')

class ExecutionMode(Enum):
    """Agent execution modes."""
    SEQUENTIAL = "sequential"
    PARALLEL = "parallel"
    CONDITIONAL = "conditional"
    PIPELINE = "pipeline"


class AgentPriority(Enum):
    """Agent execution priority levels."""
    CRITICAL = 1
    HIGH = 2
    MEDIUM = 3
    LOW = 4


@dataclass
class AgentMetrics:
    """Performance metrics for agent execution."""
    agent_name: str
    start_time: datetime
    end_time: Optional[datetime] = None
    execution_time_ms: Optional[int] = None
    cost: float = 0.0
    memory_usage_mb: Optional[float] = None
    tokens_consumed: int = 0
    success: bool = True
    error_count: int = 0
    retry_count: int = 0
    
    def mark_complete(self, success: bool = True, cost: float = 0.0):
        """Mark agent execution as complete."""
        self.end_time = datetime.now()
        self.execution_time_ms = int((self.end_time - self.start_time).total_seconds() * 1000)
        self.success = success
        self.cost = cost


@dataclass
class WorkflowPhase:
    """Definition of a workflow phase with its agents and coordination."""
    name: str
    agents: List[str]
    execution_mode: ExecutionMode
    timeout_minutes: int = 10
    retry_count: int = 2
    dependencies: List[str] = field(default_factory=list)
    cost_budget: float = 1.0
    parallel_limit: int = 3
    required_for_completion: bool = True


class AgentOrchestrator:
    """
    Centralized agent coordination system with comprehensive workflow management.
    
    Features:
    - Sequential and parallel agent execution patterns
    - Real-time cost tracking and budget enforcement
    - Error handling and recovery mechanisms
    - Performance monitoring and metrics collection
    - State consistency management across agent handoffs
    - Configurable timeout and retry policies
    """
    
    def __init__(
        self,
        state_manager: Optional[StateManager] = None,
        max_parallel_agents: int = 5,
        default_timeout_minutes: int = 10,
        cost_budget_limit: float = 5.51,
        enable_performance_monitoring: bool = True,
        checkpointing_enabled: bool = True
    ):
        """
        Initialize AgentOrchestrator.
        
        Args:
            state_manager: Optional StateManager instance
            max_parallel_agents: Maximum concurrent agent executions
            default_timeout_minutes: Default timeout for agent operations
            cost_budget_limit: Total cost budget limit
            enable_performance_monitoring: Enable performance metrics collection
            checkpointing_enabled: Enable workflow checkpointing
        """
        self.state_manager = state_manager
        self.max_parallel_agents = max_parallel_agents
        self.default_timeout_minutes = default_timeout_minutes
        self.cost_budget_limit = cost_budget_limit
        self.enable_performance_monitoring = enable_performance_monitoring
        self.checkpointing_enabled = checkpointing_enabled
        
        # Cost tracking integration
        self.cost_tracker_manager = get_cost_tracker_manager()
        self.cost_tracker: Optional[CostTracker] = None
        
        # Agent registry and metrics
        self.registered_agents: Dict[str, Callable] = {}
        self.agent_metrics: Dict[str, List[AgentMetrics]] = {}
        self.workflow_phases: Dict[str, WorkflowPhase] = {}
        
        # Execution control
        self.execution_semaphore = asyncio.Semaphore(max_parallel_agents)
        self.active_executions: Dict[str, asyncio.Task] = {}
        self.checkpoint_manager = MemorySaver() if checkpointing_enabled else None
        
        # Define standard workflow phases
        self._initialize_standard_phases()
        
        logger.info(f"AgentOrchestrator initialized - Budget: ${cost_budget_limit}, Parallel: {max_parallel_agents}")
    
    def _initialize_standard_phases(self):
        """Initialize standard podcast production workflow phases."""
        self.workflow_phases = {
            "research_pipeline": WorkflowPhase(
                name="research_pipeline",
                agents=["research_discovery", "research_deep_dive", "research_validation", "research_synthesis"],
                execution_mode=ExecutionMode.SEQUENTIAL,
                timeout_minutes=15,
                cost_budget=2.00,
                required_for_completion=True
            ),
            "planning_pipeline": WorkflowPhase(
                name="planning_pipeline", 
                agents=["question_generator", "episode_planner"],
                execution_mode=ExecutionMode.SEQUENTIAL,
                timeout_minutes=5,
                cost_budget=0.30,
                dependencies=["research_pipeline"],
                required_for_completion=True
            ),
            "production_pipeline": WorkflowPhase(
                name="production_pipeline",
                agents=["script_writer", "brand_validator"],
                execution_mode=ExecutionMode.SEQUENTIAL,
                timeout_minutes=12,
                cost_budget=2.00,
                dependencies=["planning_pipeline"],
                required_for_completion=True
            ),
            "quality_pipeline": WorkflowPhase(
                name="quality_pipeline",
                agents=["claude_evaluator", "gemini_evaluator"],
                execution_mode=ExecutionMode.PARALLEL,
                timeout_minutes=8,
                cost_budget=0.55,
                parallel_limit=2,
                dependencies=["production_pipeline"],
                required_for_completion=True
            ),
            "audio_pipeline": WorkflowPhase(
                name="audio_pipeline",
                agents=["audio_synthesizer", "audio_validator"],
                execution_mode=ExecutionMode.SEQUENTIAL,
                timeout_minutes=10,
                cost_budget=0.66,
                dependencies=["quality_pipeline"],
                required_for_completion=False  # Optional for cost savings
            )
        }
    
    def register_agent(self, name: str, agent_function: Callable, priority: AgentPriority = AgentPriority.MEDIUM):
        """
        Register an agent function with the orchestrator.
        
        Args:
            name: Agent identifier
            agent_function: Async function (state, config) -> state
            priority: Agent priority level
        """
        self.registered_agents[name] = {
            'function': agent_function,
            'priority': priority,
            'registered_at': datetime.now()
        }
        
        # Initialize metrics tracking
        if name not in self.agent_metrics:
            self.agent_metrics[name] = []
        
        logger.info(f"Agent registered: {name} (priority: {priority.name})")
    
    def register_workflow_phase(self, phase: WorkflowPhase):
        """Register a custom workflow phase."""
        self.workflow_phases[phase.name] = phase
        logger.info(f"Workflow phase registered: {phase.name}")
    
    async def execute_workflow(
        self,
        initial_state: PodcastState,
        phases_to_run: Optional[List[str]] = None,
        skip_optional: bool = False
    ) -> PodcastState:
        """
        Execute complete workflow with orchestrated agent coordination.
        
        Args:
            initial_state: Initial podcast state
            phases_to_run: Specific phases to execute (None = all)
            skip_optional: Skip optional phases to save cost
            
        Returns:
            Final state after workflow completion
        """
        logger.info(f"Starting orchestrated workflow for episode: {initial_state.get('episode_id')}")
        
        # Initialize cost tracking
        episode_id = initial_state.get('episode_id')
        budget_limit = initial_state.get('budget_limit', self.cost_budget_limit)
        
        self.cost_tracker = self.cost_tracker_manager.get_or_create_tracker(
            episode_id=episode_id,
            budget_limit=budget_limit
        )
        
        # Initialize state management if not provided
        if not self.state_manager and episode_id:
            self.state_manager = create_state_manager(
                episode_id=episode_id,
                topic=initial_state.get('topic', 'Unknown'),
                budget=budget_limit
            )
        
        # Determine phases to execute
        phases = phases_to_run or list(self.workflow_phases.keys())
        if skip_optional:
            phases = [p for p in phases if self.workflow_phases[p].required_for_completion]
        
        # Execute phases in dependency order
        execution_order = self._resolve_dependencies(phases)
        
        current_state = initial_state.copy()
        workflow_start_time = datetime.now()
        
        try:
            for phase_name in execution_order:
                logger.info(f"Executing workflow phase: {phase_name}")
                
                # Check budget before each phase
                if self.cost_tracker and not self._check_budget_for_phase(phase_name):
                    logger.warning(f"Insufficient budget for phase {phase_name}, skipping")
                    continue
                
                current_state = await self._execute_phase(phase_name, current_state)
                
                # Checkpoint after each phase
                if self.checkpointing_enabled and self.state_manager:
                    checkpoint_id = self.state_manager.checkpoint()
                    logger.info(f"Checkpoint created after {phase_name}: {checkpoint_id}")
            
            # Finalize workflow
            current_state = update_stage(current_state, "completed")
            workflow_duration = (datetime.now() - workflow_start_time).total_seconds()
            
            logger.info(f"Workflow completed in {workflow_duration:.1f}s - Total cost: ${self.cost_tracker.total_cost:.4f}")
            
            # Generate final metrics report
            if self.enable_performance_monitoring:
                self._generate_performance_report(current_state, workflow_duration)
            
            return current_state
            
        except BudgetExceededException as e:
            logger.error(f"Workflow stopped due to budget exceeded: {e}")
            return add_error(current_state, f"Budget exceeded: {e}", "orchestrator")
            
        except Exception as e:
            logger.error(f"Workflow execution failed: {e}")
            return add_error(current_state, f"Orchestrator failed: {e}", "orchestrator")
    
    async def _execute_phase(self, phase_name: str, state: PodcastState) -> PodcastState:
        """Execute a single workflow phase with its agents."""
        phase = self.workflow_phases[phase_name]
        phase_start_time = datetime.now()
        
        logger.info(f"Phase {phase_name}: {phase.execution_mode.value} execution of {len(phase.agents)} agents")
        
        try:
            if phase.execution_mode == ExecutionMode.SEQUENTIAL:
                state = await self._execute_sequential(phase, state)
            elif phase.execution_mode == ExecutionMode.PARALLEL:
                state = await self._execute_parallel(phase, state)
            elif phase.execution_mode == ExecutionMode.PIPELINE:
                state = await self._execute_pipeline(phase, state)
            else:
                raise ValueError(f"Unsupported execution mode: {phase.execution_mode}")
            
            phase_duration = (datetime.now() - phase_start_time).total_seconds()
            logger.info(f"Phase {phase_name} completed in {phase_duration:.1f}s")
            
            return update_stage(state, f"completed_{phase_name}")
            
        except Exception as e:
            logger.error(f"Phase {phase_name} failed: {e}")
            return add_error(state, f"Phase {phase_name} failed: {e}", phase_name)
    
    async def _execute_sequential(self, phase: WorkflowPhase, state: PodcastState) -> PodcastState:
        """Execute agents sequentially with proper handoffs."""
        current_state = state
        
        for agent_name in phase.agents:
            if agent_name not in self.registered_agents:
                logger.warning(f"Agent {agent_name} not registered, skipping")
                continue
            
            logger.info(f"Executing agent: {agent_name}")
            
            # Execute with timeout and error handling
            current_state = await self._execute_agent_with_monitoring(
                agent_name, current_state, phase.timeout_minutes
            )
            
            # Check for errors and handle accordingly
            if current_state.get("errors"):
                if phase.retry_count > 0:
                    logger.warning(f"Agent {agent_name} failed, attempting retry")
                    # Could implement retry logic here
                else:
                    logger.error(f"Agent {agent_name} failed, stopping phase")
                    break
        
        return current_state
    
    async def _execute_parallel(self, phase: WorkflowPhase, state: PodcastState) -> PodcastState:
        """Execute agents in parallel with concurrency control."""
        tasks = []
        
        # Create tasks for all agents in phase
        for agent_name in phase.agents:
            if agent_name not in self.registered_agents:
                logger.warning(f"Agent {agent_name} not registered, skipping")
                continue
            
            task = self._execute_agent_with_monitoring(
                agent_name, state.copy(), phase.timeout_minutes
            )
            tasks.append((agent_name, task))
        
        # Execute with concurrency limit
        semaphore = asyncio.Semaphore(phase.parallel_limit)
        
        async def bounded_execution(agent_name, task):
            async with semaphore:
                return agent_name, await task
        
        # Wait for all tasks to complete
        results = await asyncio.gather(
            *[bounded_execution(name, task) for name, task in tasks],
            return_exceptions=True
        )
        
        # Merge results from all agents
        final_state = state.copy()
        for result in results:
            if isinstance(result, Exception):
                logger.error(f"Parallel agent execution failed: {result}")
                add_error(final_state, str(result), "parallel_execution")
            else:
                agent_name, agent_state = result
                # Merge agent results into final state
                final_state = self._merge_agent_results(final_state, agent_state, agent_name)
        
        return final_state
    
    async def _execute_pipeline(self, phase: WorkflowPhase, state: PodcastState) -> PodcastState:
        """Execute agents in pipeline mode (streaming between agents)."""
        # For now, implement as sequential - could be enhanced for true streaming
        return await self._execute_sequential(phase, state)
    
    async def _execute_agent_with_monitoring(
        self,
        agent_name: str,
        state: PodcastState,
        timeout_minutes: int
    ) -> PodcastState:
        """Execute single agent with comprehensive monitoring and error handling."""
        
        if agent_name not in self.registered_agents:
            raise ValueError(f"Agent {agent_name} not registered")
        
        agent_info = self.registered_agents[agent_name]
        agent_function = agent_info['function']
        
        # Initialize metrics
        metrics = AgentMetrics(agent_name=agent_name, start_time=datetime.now())
        
        try:
            # Execute with timeout and monitoring
            async with self.execution_semaphore:
                async with asyncio.timeout(timeout_minutes * 60):
                    
                    # Pre-execution cost check
                    if self.cost_tracker:
                        remaining_budget = self.cost_tracker.check_budget_remaining()
                        if remaining_budget < 0.10:  # Minimum required buffer
                            raise BudgetExceededException(f"Insufficient budget for {agent_name}: ${remaining_budget:.4f}")
                    
                    # Execute agent
                    result_state = await agent_function(state, None)
                    
                    # Track successful execution
                    cost = self._extract_agent_cost(result_state, agent_name)
                    metrics.mark_complete(success=True, cost=cost)
                    
                    # Update state manager if available
                    if self.state_manager:
                        self.state_manager.update_transient({'active_agent': agent_name})
                    
                    logger.info(f"Agent {agent_name} executed successfully - Cost: ${cost:.4f}")
                    return result_state
        
        except asyncio.TimeoutError:
            error_msg = f"Agent {agent_name} timeout after {timeout_minutes} minutes"
            logger.error(error_msg)
            metrics.mark_complete(success=False)
            return add_error(state, error_msg, agent_name)
        
        except BudgetExceededException as e:
            logger.error(f"Budget exceeded in {agent_name}: {e}")
            metrics.mark_complete(success=False)
            return add_error(state, str(e), agent_name)
        
        except Exception as e:
            error_msg = f"Agent {agent_name} execution failed: {e}"
            logger.error(error_msg)
            metrics.mark_complete(success=False)
            return add_error(state, error_msg, agent_name)
        
        finally:
            # Record metrics
            if self.enable_performance_monitoring:
                self.agent_metrics[agent_name].append(metrics)
    
    def _merge_agent_results(self, base_state: PodcastState, agent_state: PodcastState, agent_name: str) -> PodcastState:
        """Merge results from parallel agent execution into base state."""
        merged = base_state.copy()
        
        # Merge specific fields based on agent type
        if agent_name.startswith('research_'):
            merged['research_data'] = {**merged.get('research_data', {}), **agent_state.get('research_data', {})}
        elif agent_name.endswith('_evaluator'):
            merged['quality_scores'] = {**merged.get('quality_scores', {}), **agent_state.get('quality_scores', {})}
        elif 'cost' in agent_state:
            # Accumulate costs
            merged['total_cost'] = merged.get('total_cost', 0.0) + agent_state.get('total_cost', 0.0)
        
        # Always merge errors
        base_errors = merged.get('errors', [])
        agent_errors = agent_state.get('errors', [])
        merged['errors'] = base_errors + agent_errors
        
        return merged
    
    def _extract_agent_cost(self, state: PodcastState, agent_name: str) -> float:
        """Extract cost information for specific agent from state."""
        cost_breakdown = state.get('cost_breakdown', {})
        return cost_breakdown.get(agent_name, 0.0)
    
    def _check_budget_for_phase(self, phase_name: str) -> bool:
        """Check if sufficient budget remains for phase execution."""
        if not self.cost_tracker:
            return True
        
        phase = self.workflow_phases.get(phase_name)
        if not phase:
            return True
        
        remaining_budget = self.cost_tracker.check_budget_remaining()
        return remaining_budget >= phase.cost_budget
    
    def _resolve_dependencies(self, phases: List[str]) -> List[str]:
        """Resolve phase dependencies and return execution order."""
        resolved = []
        remaining = set(phases)
        
        while remaining:
            # Find phases with no unresolved dependencies
            ready = []
            for phase in remaining:
                phase_deps = set(self.workflow_phases[phase].dependencies)
                if phase_deps.issubset(set(resolved)):
                    ready.append(phase)
            
            if not ready:
                # Circular dependency or missing dependency
                logger.warning(f"Could not resolve dependencies for phases: {remaining}")
                # Add remaining phases anyway to prevent infinite loop
                ready = list(remaining)
            
            # Sort by priority (phases with more dependents first)
            ready.sort()
            resolved.extend(ready)
            remaining -= set(ready)
        
        return resolved
    
    def _generate_performance_report(self, final_state: PodcastState, workflow_duration: float):
        """Generate comprehensive performance metrics report."""
        report = {
            'workflow_duration_seconds': workflow_duration,
            'total_cost': self.cost_tracker.total_cost if self.cost_tracker else 0.0,
            'episode_id': final_state.get('episode_id'),
            'timestamp': datetime.now().isoformat(),
            'agent_metrics': {},
            'phase_summary': {},
            'budget_utilization': self.cost_tracker.get_cost_breakdown() if self.cost_tracker else {}
        }
        
        # Agent performance metrics
        for agent_name, metrics_list in self.agent_metrics.items():
            if metrics_list:
                latest_metrics = metrics_list[-1]
                report['agent_metrics'][agent_name] = {
                    'execution_time_ms': latest_metrics.execution_time_ms,
                    'cost': latest_metrics.cost,
                    'success': latest_metrics.success,
                    'total_executions': len(metrics_list)
                }
        
        # Save report
        try:
            output_dir = Path(final_state.get('output_directory', './output'))
            output_dir.mkdir(parents=True, exist_ok=True)
            
            report_path = output_dir / f"{final_state.get('episode_id')}_orchestrator_metrics.json"
            with open(report_path, 'w') as f:
                json.dump(report, f, indent=2, default=str)
            
            logger.info(f"Performance report saved: {report_path}")
            
        except Exception as e:
            logger.error(f"Failed to save performance report: {e}")
    
    @asynccontextmanager
    async def workflow_context(self, episode_id: str, topic: str, budget: float = 5.51):
        """Context manager for workflow execution with cleanup."""
        # Setup
        logger.info(f"Starting workflow context for {episode_id}")
        self.cost_tracker = self.cost_tracker_manager.get_or_create_tracker(
            episode_id=episode_id,
            budget_limit=budget
        )
        
        try:
            yield self
        finally:
            # Cleanup
            logger.info(f"Cleaning up workflow context for {episode_id}")
            if self.active_executions:
                logger.info("Cancelling active executions...")
                for task in self.active_executions.values():
                    task.cancel()
                await asyncio.gather(*self.active_executions.values(), return_exceptions=True)
                self.active_executions.clear()
    
    def get_orchestrator_status(self) -> Dict[str, Any]:
        """Get current orchestrator status and metrics."""
        return {
            'registered_agents': list(self.registered_agents.keys()),
            'workflow_phases': list(self.workflow_phases.keys()),
            'active_executions': len(self.active_executions),
            'total_metrics_collected': sum(len(metrics) for metrics in self.agent_metrics.values()),
            'cost_tracker_active': self.cost_tracker is not None,
            'current_budget_remaining': self.cost_tracker.check_budget_remaining() if self.cost_tracker else 0.0,
            'checkpointing_enabled': self.checkpointing_enabled,
            'performance_monitoring': self.enable_performance_monitoring
        }


def create_orchestrator(
    budget_limit: float = 5.51,
    max_parallel: int = 5,
    timeout_minutes: int = 10
) -> AgentOrchestrator:
    """Factory function to create configured AgentOrchestrator."""
    return AgentOrchestrator(
        max_parallel_agents=max_parallel,
        default_timeout_minutes=timeout_minutes,
        cost_budget_limit=budget_limit,
        enable_performance_monitoring=True,
        checkpointing_enabled=True
    )


# Convenience function for workflow execution
async def execute_orchestrated_workflow(
    topic: str,
    episode_id: Optional[str] = None,
    budget: float = 5.51,
    skip_optional: bool = False,
    agents_to_register: Optional[Dict[str, Callable]] = None
) -> PodcastState:
    """
    Execute complete orchestrated workflow with default configuration.
    
    Args:
        topic: Podcast episode topic
        episode_id: Optional episode identifier
        budget: Budget limit
        skip_optional: Skip optional phases
        agents_to_register: Dict of agent_name -> agent_function
        
    Returns:
        Final podcast state
    """
    from core.state import create_initial_state
    
    # Create orchestrator
    orchestrator = create_orchestrator(budget_limit=budget)
    
    # Register provided agents
    if agents_to_register:
        for name, func in agents_to_register.items():
            orchestrator.register_agent(name, func)
    
    # Create initial state
    initial_state = create_initial_state(
        topic=topic,
        budget=budget
    )
    
    if episode_id:
        initial_state['episode_id'] = episode_id
    
    # Execute workflow
    async with orchestrator.workflow_context(
        episode_id=initial_state['episode_id'],
        topic=topic,
        budget=budget
    ):
        final_state = await orchestrator.execute_workflow(
            initial_state=initial_state,
            skip_optional=skip_optional
        )
    
    return final_state