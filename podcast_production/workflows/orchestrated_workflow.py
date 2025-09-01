# TODO: Consider wrapping critical async calls with self.retry_handler.execute_with_retry()
"""
Orchestrated Workflow - LangGraph Implementation with AgentOrchestrator
August 2025 Production Architecture

Complete podcast production workflow implemented using LangGraph StateGraph
with centralized orchestration, proper state management, cost tracking,
and comprehensive error handling.
"""

import asyncio
import logging
from typing import Dict, A, Optionalny, Literal, Optional, List
from pathlib import Path
import json
from core.retry_handler import RetryHandler, RetryConfig, CircuitBreakerState

try:
    from langgraph.graph import StateGraph, END
    from langgraph.checkpoint.memory import MemorySaver
    from langchain_core.runnables import RunnableConfig
    CompiledGraph = object
except ImportError:
    print("Warning: LangGraph not installed. Using mock implementations.")
    
    class StateGraph:
        def __init__(self, state_type): 
            self.nodes = {}
            self.edges = {}
            self.conditional_edges = {}
            self.entry_point = None
            
        def add_node(self, name, func):
 
            self.nodes[name] = func
            
        def add_edge(self, from_node, to_node): 
            if from_node not in self.edges:
                self.edges[from_node] = []
            self.edges[from_node].append(to_node)
            
        def add_conditional_edges(self, node, condition, mapping): 
            self.conditional_edges[node] = (condition, mapping)
            
        def set_entry_point(self, node): 
            self.entry_point = node
            
        def compile(self, checkpointer=None): 
            return MockCompiledGraph(self.nodes, self.edges, self.conditional_edges, self.entry_point)

    class MockCompiledGraph:
        def __init__(self, nodes, edges, conditional_edges, entry_point):
            self.nodes = nodes
            self.edges = edges
            self.conditional_edges = conditional_edges
            self.entry_point = entry_point
            
        async def ainvoke(self, state, config=None): 
            # Simple mock execution
            current_node = self.entry_point
            current_state = state.copy()
            
            visited = set()
            while current_node and current_node != "END" and current_node not in visited:
                visited.add(current_node)
                
                if current_node in self.nodes:
                    # Execute node function
                    current_state = await self.nodes[current_node](current_state, config)
                
                # Determine next node
                if current_node in self.conditional_edges:
                    condition_func, mapping = self.conditional_edges[current_node]
                    next_key = condition_func(current_state)
                    current_node = mapping.get(next_key, "END")
                elif current_node in self.edges and self.edges[current_node]:
                    current_node = self.edges[current_node][0]
                else:
                    break
                    
            return current_state

    class MemorySaver: 
        def save_checkpoint(self, checkpoint): pass
        def load_checkpoint(self, checkpoint_id): return None
        
    CompiledGraph = object
    END = "END"

from core.state import PodcastState, update_stage, add_error, update_cost, is_over_budget, create_initial_state
from core.agent_orchestrator import AgentOrchestrator, create_orchestrator
from core.cost_tracker import BudgetExceededException
from core.node_wrapper import create_agent_node, create_sync_agent_node
from langgraph.types import InjectedState
from langgraph.store.base import InjectedStore

# Import all migrated agents (check availability)
agents_available = {}
try:
    from agents.research_discovery import ResearchDiscoveryAgent
    agents_available['research_discovery'] = ResearchDiscoveryAgent
except ImportError:
    pass

try:
    from agents.research_deep_dive import ResearchDeepDiveAgent
    agents_available['research_deep_dive'] = ResearchDeepDiveAgent
except ImportError:
    pass

try:
    from agents.research_validation import ResearchValidationAgent
    agents_available['research_validation'] = ResearchValidationAgent
except ImportError:
    pass

try:
    from agents.research_synthesis import ResearchSynthesisAgent
    agents_available['research_synthesis'] = ResearchSynthesisAgent
except ImportError:
    pass

try:
    from agents.question_generator import QuestionGeneratorAgent
    agents_available['question_generator'] = QuestionGeneratorAgent
except ImportError:
    pass

try:
    from agents.episode_planner import EpisodePlannerAgent  
    agents_available['episode_planner'] = EpisodePlannerAgent
except ImportError:
    pass

try:
    from agents.script_writer import ScriptWriterAgent
    agents_available['script_writer'] = ScriptWriterAgent
except ImportError:
    pass

try:
    from agents.brand_validator import BrandValidatorAgent
    agents_available['brand_validator'] = BrandValidatorAgent
except ImportError:
    pass

try:
    from agents.claude_evaluator import ClaudeEvaluatorAgent
    agents_available['claude_evaluator'] = ClaudeEvaluatorAgent
except ImportError:
    pass

try:
    from agents.gemini_evaluator import GeminiEvaluatorAgent
    agents_available['gemini_evaluator'] = GeminiEvaluatorAgent
except ImportError:
    pass

try:
    from agents.audio_synthesizer import AudioSynthesizerAgent
    agents_available['audio_synthesizer'] = AudioSynthesizerAgent
except ImportError:
    pass

try:
    from agents.audio_validator import AudioValidatorAgent
    agents_available['audio_validator'] = AudioValidatorAgent
except ImportError:
    pass

logger = logging.getLogger(__name__)


class OrchestratedPodcastWorkflow:
    """
    LangGraph-based podcast workflow with centralized orchestration.
    
    Provides production-ready podcast creation with:
    - Centralized agent coordination
    - Real-time cost tracking and enforcement
    - Comprehensive error handling and recovery
    - Performance monitoring and metrics
    - State consistency across agent handoffs
    - Configurable workflow phases and routing
    """
    
    def __init__(
        self,
        orchestrator: Optional[AgentOrchestrator] = None,
        config: Dict[str, Any] = None
    ):
        """
        Initialize orchestrated workflow.
        
        Args:
            orchestrator: Optional AgentOrchestrator instance
            config: Workflow configuration
        """
        self.config = config or {}
        self.orchestrator = orchestrator or create_orchestrator(
            budget_limit=self.config.get('budget_limit', 5.51),
            max_parallel=self.config.get('max_parallel_agents', 5),
            timeout_minutes=self.config.get('timeout_minutes', 10)
        )
        
        self.checkpointer = MemorySaver()
        self.graph = None
        
        # Note: Agent registration and graph building moved to async_init()
        logger.info("Orchestrated podcast workflow created (call async_init() to complete setup)")
    
    async def async_init(self):
        """Complete async initialization."""
        # Register available agents
        await self._register_available_agents()
        
        # Build workflow graph
        self._build_workflow_graph()
        
        logger.info("Orchestrated podcast workflow fully initialized")
    
    async def _register_available_agents(self):
        """Register all available agents with the orchestrator."""
        for agent_name, agent_class in agents_available.items():
            try:
                # Create agent node function - use async wrapper for async agents
                agent_node = await create_agent_node(agent_class)
                self.orchestrator.register_agent(agent_name, agent_node)
                logger.info(f"Registered agent: {agent_name}")
            except Exception as e:
                logger.warning(f"Failed to register agent {agent_name}: {e}")
    
    def _build_workflow_graph(self):
        """Build the complete LangGraph workflow with orchestration."""
        # Create workflow graph
        workflow = StateGraph(PodcastState)
        
        # Add orchestration nodes
        workflow.add_node("initialize", self._initialize_node)
        workflow.add_node("research_phase", self._research_phase_node)
        workflow.add_node("planning_phase", self._planning_phase_node)
        workflow.add_node("production_phase", self._production_phase_node)
        workflow.add_node("quality_phase", self._quality_phase_node)
        workflow.add_node("audio_phase", self._audio_phase_node)
        workflow.add_node("finalize", self._finalize_node)
        workflow.add_node("error_handler", self._error_handler_node)
        workflow.add_node("budget_check", self._budget_check_node)
        
        # Define workflow routing
        workflow.set_entry_point("initialize")
        
        # Main workflow path
        workflow.add_edge("initialize", "budget_check")
        workflow.add_conditional_edges(
            "budget_check",
            self._should_continue_workflow,
            {
                "continue": "research_phase",
                "insufficient_budget": "error_handler", 
                "error": "error_handler"
            }
        )
        
        # Phase transitions with budget checks
        workflow.add_conditional_edges(
            "research_phase",
            self._should_continue_after_research,
            {
                "continue": "planning_phase",
                "retry": "research_phase",
                "error": "error_handler"
            }
        )
        
        workflow.add_conditional_edges(
            "planning_phase", 
            self._should_continue_after_planning,
            {
                "continue": "production_phase",
                "error": "error_handler"
            }
        )
        
        workflow.add_conditional_edges(
            "production_phase",
            self._should_continue_after_production,
            {
                "continue": "quality_phase",
                "error": "error_handler"
            }
        )
        
        workflow.add_conditional_edges(
            "quality_phase",
            self._should_continue_after_quality,
            {
                "continue": "audio_phase",
                "skip_audio": "finalize",
                "error": "error_handler"
            }
        )
        
        workflow.add_edge("audio_phase", "finalize")
        workflow.add_edge("finalize", END)
        workflow.add_edge("error_handler", END)
        
        # Compile with checkpointer
        self.graph = workflow.compile(checkpointer=self.checkpointer)
        
        logger.info("Workflow graph compiled successfully")
    
    async def execute(self, initial_state: PodcastState) -> PodcastState:
        """
        Execute the complete orchestrated workflow.
        
        Args:
            initial_state: Initial state with topic and configuration
            
        Returns:
            Final state with all results
        """
        try:
            logger.info(f"Starting orchestrated workflow for: {initial_state.get('topic')}")
            
            # Execute workflow through LangGraph
            final_state = await self.graph.ainvoke(
                initial_state,
                config={"configurable": {"thread_id": initial_state.get("episode_id", "default")}}
            )
            
            # Generate final metrics and reports
            await self._generate_final_reports(final_state)
            
            logger.info(f"Orchestrated workflow completed - Cost: ${final_state.get('total_cost', 0):.4f}")
            return final_state
            
        except Exception as e:
            logger.error(f"Orchestrated workflow execution failed: {e}")
            return add_error(initial_state, f"Orchestrated workflow failed: {e}", "orchestrator")
    
    # Node Implementations
    async def _initialize_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Initialize workflow with orchestrator setup."""
        logger.info("Initializing orchestrated workflow")
        state = update_stage(state, "initializing")
        
        try:
            # Set up orchestrator context
            episode_id = state.get('episode_id')
            budget = state.get('budget_limit', 5.51)
            
            if episode_id and budget:
                # Initialize cost tracking through orchestrator
                self.orchestrator.cost_tracker = self.orchestrator.cost_tracker_manager.get_or_create_tracker(
                    episode_id=episode_id,
                    budget_limit=budget
                )
                
                # Update state with orchestrator information
                state['orchestrator_status'] = self.orchestrator.get_orchestrator_status()
            
            return update_stage(state, "initialized")
            
        except Exception as e:
            logger.error(f"Workflow initialization failed: {e}")
            return add_error(state, f"Initialization failed: {e}", "initialize")
    
    async def _research_phase_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Execute research phase using orchestrator."""
        logger.info("Executing research phase")
        state = update_stage(state, "research_phase")
        
        try:
            # Execute research pipeline through orchestrator
            research_state = await self.orchestrator._execute_phase("research_pipeline", state)
            return research_state
            
        except BudgetExceededException as e:
            logger.error(f"Research phase budget exceeded: {e}")
            return add_error(state, str(e), "research_phase")
        except Exception as e:
            logger.error(f"Research phase failed: {e}")
            return add_error(state, f"Research phase failed: {e}", "research_phase")
    
    async def _planning_phase_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Execute planning phase using orchestrator."""
        logger.info("Executing planning phase")
        state = update_stage(state, "planning_phase")
        
        try:
            planning_state = await self.orchestrator._execute_phase("planning_pipeline", state)
            return planning_state
            
        except Exception as e:
            logger.error(f"Planning phase failed: {e}")
            return add_error(state, f"Planning phase failed: {e}", "planning_phase")
    
    async def _production_phase_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Execute production phase using orchestrator."""
        logger.info("Executing production phase")
        state = update_stage(state, "production_phase")
        
        try:
            production_state = await self.orchestrator._execute_phase("production_pipeline", state)
            return production_state
            
        except Exception as e:
            logger.error(f"Production phase failed: {e}")
            return add_error(state, f"Production phase failed: {e}", "production_phase")
    
    async def _quality_phase_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Execute quality assurance phase using orchestrator."""
        logger.info("Executing quality phase")
        state = update_stage(state, "quality_phase")
        
        try:
            quality_state = await self.orchestrator._execute_phase("quality_pipeline", state)
            return quality_state
            
        except Exception as e:
            logger.error(f"Quality phase failed: {e}")
            return add_error(state, f"Quality phase failed: {e}", "quality_phase")
    
    async def _audio_phase_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Execute audio generation phase using orchestrator."""
        logger.info("Executing audio phase")
        state = update_stage(state, "audio_phase")
        
        try:
            audio_state = await self.orchestrator._execute_phase("audio_pipeline", state)
            return audio_state
            
        except Exception as e:
            logger.error(f"Audio phase failed: {e}")
            return add_error(state, f"Audio phase failed: {e}", "audio_phase")
    
    async def _budget_check_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Check budget status and update cost information."""
        logger.info("Performing budget check")
        
        if self.orchestrator.cost_tracker:
            current_cost = self.orchestrator.cost_tracker.total_cost
            budget_limit = self.orchestrator.cost_tracker.budget_limit
            remaining = self.orchestrator.cost_tracker.check_budget_remaining()
            
            # Update state with current cost information
            state['total_cost'] = current_cost
            state['budget_remaining'] = remaining
            state['cost_data'] = self.orchestrator.cost_tracker.to_dict()
            
            if current_cost > budget_limit:
                logger.error(f"Budget exceeded: ${current_cost:.4f} > ${budget_limit:.2f}")
                return add_error(state, f"Budget exceeded: ${current_cost:.4f}", "budget_check")
            
            logger.info(f"Budget check passed: ${current_cost:.4f} / ${budget_limit:.2f}")
        
        return state
    
    async def _finalize_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Finalize workflow and generate reports."""
        logger.info("Finalizing orchestrated workflow")
        state = update_stage(state, "finalizing")
        
        try:
            # Update final cost information
            if self.orchestrator.cost_tracker:
                final_cost = self.orchestrator.cost_tracker.total_cost
                cost_breakdown = self.orchestrator.cost_tracker.get_cost_breakdown()
                
                state['total_cost'] = final_cost
                state['cost_breakdown'] = cost_breakdown
                state['cost_data'] = self.orchestrator.cost_tracker.to_dict()
            
            # Add orchestrator metrics
            state['orchestrator_metrics'] = self.orchestrator.get_orchestrator_status()
            
            # Mark as completed
            return update_stage(state, "completed")
            
        except Exception as e:
            logger.error(f"Workflow finalization failed: {e}")
            return add_error(state, f"Finalization failed: {e}", "finalize")
    
    async def _error_handler_node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:
        """Handle workflow errors and cleanup."""
        logger.info("Handling workflow errors")
        state = update_stage(state, "error_handling")
        
        # Log all errors
        errors = state.get("errors", [])
        for error in errors:
            logger.error(f"Workflow error: {error}")
        
        # Save error report
        await self._save_error_report(state)
        
        return update_stage(state, "failed")
    
    # Conditional routing functions
    def _should_continue_workflow(self, state: PodcastState) -> Literal["continue", "insufficient_budget", "error"]:
        """Determine if workflow should continue after initialization."""
        if state.get("errors"):
            return "error"
        
        if is_over_budget(state):
            return "insufficient_budget"
        
        return "continue"
    
    def _should_continue_after_research(self, state: PodcastState) -> Literal["continue", "retry", "error"]:
        """Determine if workflow should continue after research phase."""
        if state.get("errors"):
            retry_count = state.get("retry_count", 0)
            if retry_count < 2:  # Allow up to 2 retries
                state["retry_count"] = retry_count + 1
                return "retry"
            return "error"
        
        # Check if research data is sufficient
        research_data = state.get("research_data", {})
        if not research_data or len(research_data) < 2:
            return "error"
        
        return "continue"
    
    def _should_continue_after_planning(self, state: PodcastState) -> Literal["continue", "error"]:
        """Determine if workflow should continue after planning phase."""
        if state.get("errors"):
            return "error"
        
        # Check if planning is complete
        episode_plan = state.get("episode_plan", {})
        if not episode_plan:
            return "error"
        
        return "continue"
    
    def _should_continue_after_production(self, state: PodcastState) -> Literal["continue", "error"]:
        """Determine if workflow should continue after production phase."""
        if state.get("errors"):
            return "error"
        
        # Check if script was generated
        script = state.get("script_raw", "").strip()
        if not script or len(script) < 100:
            return "error"
        
        return "continue"
    
    def _should_continue_after_quality(self, state: PodcastState) -> Literal["continue", "skip_audio", "error"]:
        """Determine if workflow should continue after quality phase."""
        if state.get("errors"):
            return "error"
        
        # Check budget for audio generation
        if is_over_budget(state) or (self.orchestrator.cost_tracker and 
                                    self.orchestrator.cost_tracker.check_budget_remaining() < 0.50):
            logger.info("Skipping audio generation due to budget constraints")
            return "skip_audio"
        
        return "continue"
    
    async def _generate_final_reports(self, state: PodcastState):
        """Generate comprehensive final reports."""
        try:
            output_dir = Path(state.get("output_directory", "./output"))
            output_dir.mkdir(parents=True, exist_ok=True)
            
            episode_id = state.get("episode_id", "unknown")
            
            # Orchestration summary report
            orchestration_report = {
                "episode_id": episode_id,
                "workflow_type": "orchestrated",
                "timestamp": state.get("timestamp"),
                "total_cost": state.get("total_cost", 0.0),
                "budget_limit": state.get("budget_limit", 5.51),
                "phases_completed": self._get_completed_phases(state),
                "orchestrator_metrics": state.get("orchestrator_metrics", {}),
                "quality_scores": state.get("quality_scores", {}),
                "errors": state.get("errors", []),
                "final_stage": state.get("current_stage")
            }
            
            report_path = output_dir / f"{episode_id}_orchestration_report.json"
            with open(report_path, 'w') as f:
                json.dump(orchestration_report, f, indent=2, default=str)
            
            logger.info(f"Final orchestration report saved: {report_path}")
            
        except Exception as e:
            logger.error(f"Failed to generate final reports: {e}")
    
    async def _save_error_report(self, state: PodcastState):
        """Save detailed error report."""
        try:
            output_dir = Path(state.get("output_directory", "./output"))
            output_dir.mkdir(parents=True, exist_ok=True)
            
            episode_id = state.get("episode_id", "unknown")
            error_report = {
                "episode_id": episode_id,
                "workflow_type": "orchestrated",
                "failure_timestamp": state.get("timestamp"),
                "failed_stage": state.get("current_stage"),
                "errors": state.get("errors", []),
                "cost_at_failure": state.get("total_cost", 0.0),
                "orchestrator_status": self.orchestrator.get_orchestrator_status()
            }
            
            error_path = output_dir / f"{episode_id}_orchestration_error.json"
            with open(error_path, 'w') as f:
                json.dump(error_report, f, indent=2, default=str)
            
            logger.info(f"Error report saved: {error_path}")
            
        except Exception as e:
            logger.error(f"Failed to save error report: {e}")
    
    def _get_completed_phases(self, state: PodcastState) -> List[str]:
        """Get list of completed workflow phases."""
        completed = []
        current_stage = state.get("current_stage", "")
        
        phase_order = [
            "initialized", "research_phase", "planning_phase", 
            "production_phase", "quality_phase", "audio_phase", "completed"
        ]
        
        for phase in phase_order:
            if phase in current_stage or (phase == "completed" and current_stage == "completed"):
                completed.append(phase)
            else:
                break
        
        return completed


async def create_orchestrated_workflow(
    budget_limit: float = 5.51,
    max_parallel_agents: int = 5,
    timeout_minutes: int = 10,
    config: Dict[str, Any] = None
) -> OrchestratedPodcastWorkflow:
    """
    Async factory function to create orchestrated workflow.
    
    Args:
        budget_limit: Cost budget limit
        max_parallel_agents: Maximum parallel executions
        timeout_minutes: Timeout for agent operations
        config: Additional configuration
        
    Returns:
        Fully initialized OrchestratedPodcastWorkflow
    """
    # Create orchestrator with specified parameters
    orchestrator = create_orchestrator(
        budget_limit=budget_limit,
        max_parallel=max_parallel_agents,
        timeout_minutes=timeout_minutes
    )
    
    # Merge configuration
    full_config = {
        "budget_limit": budget_limit,
        "max_parallel_agents": max_parallel_agents, 
        "timeout_minutes": timeout_minutes
    }
    if config:
        full_config.update(config)
    
    # Create and initialize workflow
    workflow = OrchestratedPodcastWorkflow(orchestrator=orchestrator, config=full_config)
    await workflow.async_init()
    
    return workflow


async def execute_orchestrated_workflow(
    topic: str,
    budget: float = 5.51,
    output_dir: str = "./output",
    dry_run: bool = False,
    verbose: bool = False,
    skip_optional: bool = False,
    config: Dict[str, Any] = None
) -> PodcastState:
    """
    Execute complete orchestrated podcast production workflow.
    
    Args:
        topic: Podcast episode topic
        budget: Maximum budget
        output_dir: Output directory
        dry_run: If True, mock all API calls
        verbose: Enable verbose logging
        skip_optional: Skip optional phases for cost savings
        config: Additional configuration
        
    Returns:
        Final state with all results
    """
    # Create initial state
    initial_state = create_initial_state(
        topic=topic,
        budget=budget,
        output_dir=output_dir,
        dry_run=dry_run,
        verbose=verbose
    )
    
    # Create orchestrated workflow
    workflow = await create_orchestrated_workflow(
        budget_limit=budget,
        config=config
    )
    
    # Execute workflow
    final_state = await workflow.execute(initial_state)
    
    return final_state