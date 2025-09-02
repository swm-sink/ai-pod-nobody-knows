# TODO: Consider wrapping critical async calls with self.retry_handler.execute_with_retry()
"""
Main workflow orchestration using LangGraph.

This module defines the complete podcast production workflow as a LangGraph
StateGraph, coordinating all agents and handling conditional routing.

Version: 1.0.0
Date: August 2025
"""

from config.voice_config import get_production_voice_id
from core.retry_handler import RetryHandler, RetryConfig, CircuitBreakerState

import logging
import os
from typing import Dict, Any, Literal, List, Optional, Union
from pathlib import Path
import json

try:
    from langgraph.graph import StateGraph, END
    from langgraph.checkpoint.memory import MemorySaver
    # Simplified: Using SQLite/Memory only (PostgreSQL archived)
    from langgraph.checkpoint.serde.jsonplus import JsonPlusSerializer
    CompiledGraph = object  # Type hint fallback
    CHECKPOINTER_AVAILABLE = True
except ImportError:
    # Fallback for environments without LangGraph
    print("Warning: LangGraph not installed. Using mock implementations.")
    CHECKPOINTER_AVAILABLE = False

    class StateGraph:
        def __init__(self, state_type): pass
        def add_node(self, name, func): pass
        def add_edge(self, from_node, to_node): pass
        def add_conditional_edges(self, node, condition, mapping): pass
        def set_entry_point(self, node): pass
        def compile(self, checkpointer=None): return MockCompiledGraph()

    class MockCompiledGraph:
        async def ainvoke(self, state, config=None): return state

    class MemorySaver: pass
    class JsonPlusSerializer: pass
    CompiledGraph = object  # Type hint
    END = "END"

from core.state import PodcastState, update_stage, add_error, update_cost, is_over_budget
from core.cost_tracker import CostTracker, BudgetExceededException, create_cost_tracker
from core.cost_tracker_manager import get_cost_tracker_manager
from core.checkpoint_manager import get_checkpoint_manager, create_workflow_checkpoint

# Import all production agents
from agents.research_discovery import ResearchDiscoveryAgent
from agents.research_deep_dive import ResearchDeepDiveAgent
from agents.research_validation import ResearchValidationAgent
from agents.research_synthesis import ResearchSynthesisAgent
from agents.question_generator import QuestionGeneratorAgent
from agents.episode_planner import EpisodePlannerAgent
from agents.script_writer import ScriptWriterAgent
from agents.brand_validator import BrandValidatorAgent


logger = logging.getLogger(__name__)


class PodcastWorkflow:
    """
    Main podcast production workflow using LangGraph.

    Orchestrates the complete pipeline from research to audio generation,
    with built-in cost control, quality gates, and error handling.
    """

    def __init__(self, config: Dict[str, Any] = None):
        """
        Initialize podcast workflow.

        Args:
            config: Optional configuration dictionary
        """
        self.config = config or {}
        self.checkpointer = self._create_production_checkpointer()
        self.cost_tracker_manager = get_cost_tracker_manager()  # August 2025 - outside state
        self.cost_tracker = None  # Will be managed by cost_tracker_manager
        self.checkpoint_manager = get_checkpoint_manager()  # For workflow resumption
        self.graph = self._build_graph()

        # Initialize all migrated agents
        self.research_discovery = ResearchDiscoveryAgent()
        self.research_deep_dive = ResearchDeepDiveAgent()
        self.research_validation = ResearchValidationAgent()
        self.research_synthesis = ResearchSynthesisAgent()
        self.question_generator = QuestionGeneratorAgent()
        self.episode_planner = EpisodePlannerAgent()
        self.script_writer = ScriptWriterAgent()
        self.brand_validator = BrandValidatorAgent()

        logger.info("Podcast workflow initialized")

    def _create_production_checkpointer(self):
        """
        Create simplified checkpointer for personal production use.

        Simplified August 2025 (PostgreSQL archived):
        - Use MemorySaver with enhanced serialization for all cases
        - SQLite database via DATABASE_URL for persistent storage (simpler than PostgreSQL)
        - JsonPlusSerializer with pickle fallback for complex objects

        Returns:
            Configured MemorySaver checkpointer instance
        """
        logger.info("🧠 Initializing simplified checkpointer (PostgreSQL archived)")

        # Use MemorySaver with enhanced serialization if available
        if CHECKPOINTER_AVAILABLE:
            try:
                # Create JsonPlusSerializer with pickle fallback (August 2025 best practice)
                serializer = JsonPlusSerializer(pickle_fallback=True)
                checkpointer = MemorySaver(serde=serializer)
                logger.info("✅ Enhanced MemorySaver initialized with JsonPlusSerializer")
                return checkpointer
            except Exception as e:
                logger.warning(f"Failed to create enhanced MemorySaver: {e}")
                logger.info("🔄 Using basic MemorySaver")

        # Final fallback to basic MemorySaver
        logger.info("🧠 Using basic MemorySaver checkpointer")
        return MemorySaver()

    def _build_graph(self):
        """Build the LangGraph workflow graph."""

        # Create workflow graph
        workflow = StateGraph(PodcastState)

        # Add all nodes
        workflow.add_node("discovery", self._discovery_node)
        workflow.add_node("deep_dive", self._deep_dive_node)
        workflow.add_node("validation", self._validation_node)
        workflow.add_node("synthesis", self._synthesis_node)
        workflow.add_node("question_generation", self._question_generation_node)
        workflow.add_node("planning", self._planning_node)
        workflow.add_node("writing", self._writing_node)
        workflow.add_node("polishing", self._polishing_node)
        workflow.add_node("audio_generation", self._audio_generation_node)
        workflow.add_node("quality_check", self._quality_check_node)
        workflow.add_node("cost_check", self._cost_check_node)
        workflow.add_node("error_handler", self._error_handler_node)

        # Define workflow edges with conditional routing
        workflow.set_entry_point("discovery")

        # Research pipeline
        workflow.add_edge("discovery", "cost_check")
        workflow.add_conditional_edges(
            "cost_check",
            self._should_continue_research,
            {
                "continue": "deep_dive",
                "over_budget": "error_handler",
                "complete": END
            }
        )

        workflow.add_edge("deep_dive", "validation")
        workflow.add_edge("validation", "synthesis")
        workflow.add_edge("synthesis", "question_generation")

        # Production pipeline
        workflow.add_edge("question_generation", "planning")
        workflow.add_edge("planning", "writing")
        workflow.add_edge("writing", "polishing")

        # Quality gate before audio
        workflow.add_conditional_edges(
            "polishing",
            self._should_generate_audio,
            {
                "generate": "audio_generation",
                "retry": "writing",
                "skip": "quality_check"
            }
        )

        workflow.add_edge("audio_generation", "quality_check")
        workflow.add_edge("quality_check", END)
        workflow.add_edge("error_handler", END)

        # Compile with checkpointer
        return workflow.compile(checkpointer=self.checkpointer)

    async def execute(self, initial_state: PodcastState) -> PodcastState:
        """
        Execute the complete podcast production workflow.

        Args:
            initial_state: Initial state with topic and configuration

        Returns:
            Final state with all results
        """
        try:
            logger.info(f"Starting podcast workflow for topic: {initial_state['topic']}")

            # Get or create cost tracker using manager (August 2025 pattern)
            episode_id = initial_state.get('episode_id')
            budget_limit = initial_state.get('budget_limit', 5.51)

            # Restore from state if available, or create new
            cost_data = initial_state.get('cost_data', {})
            self.cost_tracker = self.cost_tracker_manager.get_or_create_tracker(
                episode_id=episode_id,
                budget_limit=budget_limit,
                cost_data=cost_data if cost_data else None
            )

            # Store serialized cost data in state (not the tracker object)
            initial_state['cost_data'] = self.cost_tracker.to_dict()

            # Create initial checkpoint for resumption capability
            thread_id = initial_state["episode_id"]
            await create_workflow_checkpoint(
                thread_id=thread_id,
                state=initial_state,
                current_node="start",
                progress=0.0
            )

            # Execute workflow with checkpointing support
            try:
                final_state = await self.graph.ainvoke(
                    initial_state,
                    config={"configurable": {"thread_id": thread_id}}
                )

                # Create completion checkpoint
                await create_workflow_checkpoint(
                    thread_id=thread_id,
                    state=final_state,
                    current_node="completed",
                    progress=1.0
                )

            except Exception as e:
                # Mark workflow as interrupted for potential resumption
                self.checkpoint_manager.mark_interrupted(thread_id, str(e))
                logger.error(f"❌ Workflow interrupted: {e}")
                raise

            # Generate final cost report and update state
            cost_breakdown = self.cost_tracker.get_cost_breakdown()
            final_state['cost_data'] = self.cost_tracker.to_dict()  # Serialized for state
            final_state['total_cost'] = cost_breakdown['total_cost']

            # Save cost report
            try:
                from pathlib import Path
                output_dir = Path(initial_state.get("output_directory", "./output"))
                output_dir.mkdir(parents=True, exist_ok=True)

                cost_report_path = output_dir / f"{initial_state['episode_id']}_cost_report.json"
                with open(cost_report_path, 'w') as f:
                    json.dump(cost_breakdown, f, indent=2, default=str)

                logger.info(f"Cost report saved to: {cost_report_path}")
            except Exception as e:
                logger.warning(f"Failed to save cost report: {e}")

            logger.info(f"Workflow completed. Total cost: ${final_state.get('total_cost', 0):.4f}")
            return final_state

        except BudgetExceededException as e:
            logger.error(f"Budget exceeded during workflow: {e}")
            return add_error(initial_state, str(e), "budget")
        except Exception as e:
            logger.error(f"Workflow execution failed: {e}")
            return add_error(initial_state, f"Workflow execution failed: {e}", "workflow")

    async def resume_from_checkpoint(self, thread_id: str) -> PodcastState:
        """
        Resume workflow from checkpoint.

        Args:
            thread_id: Episode ID to resume

        Returns:
            Final state after resumption
        """
        logger.info(f"🔄 Attempting to resume workflow: {thread_id}")

        # Define workflow execution function for resumption
        async def workflow_executor(state: PodcastState, recovery_node: str = None) -> PodcastState:
            """Execute workflow from recovered state."""
            # Update cost tracker from recovered state
            cost_data = state.get('cost_data', {})
            budget_limit = state.get('budget_limit', 5.51)

            self.cost_tracker = self.cost_tracker_manager.get_or_create_tracker(
                episode_id=thread_id,
                budget_limit=budget_limit,
                cost_data=cost_data
            )

            # Execute from checkpoint
            config = {"configurable": {"thread_id": thread_id}}
            return await self.graph.ainvoke(state, config)

        # Resume using checkpoint manager
        return await self.checkpoint_manager.resume_workflow(
            thread_id=thread_id,
            workflow_executor=workflow_executor
        )

    def get_resumable_workflows(self) -> List[Dict[str, Any]]:
        """Get list of workflows that can be resumed."""
        recoverable = self.checkpoint_manager.get_recoverable_workflows()

        return [
            {
                "episode_id": metadata.episode_id,
                "thread_id": metadata.thread_id,
                "interrupted_at": metadata.updated_at.isoformat(),
                "current_node": metadata.current_node,
                "progress": metadata.progress_percentage,
                "cost_so_far": metadata.cost_so_far,
                "errors": metadata.errors,
                "recovery_attempts": metadata.recovery_attempts,
                "max_attempts": metadata.max_recovery_attempts
            }
            for metadata in recoverable
        ]

    # Node implementations
    async def _discovery_node(self, state: PodcastState) -> PodcastState:
        """Execute research discovery stage."""
        logger.info("Executing discovery stage")
        state = update_stage(state, "discovery")

        try:
            if not state.get("dry_run"):
                # Check budget before expensive operations
                if self.cost_tracker and not self.cost_tracker.can_afford('perplexity', 'llama-3.1-sonar-large-128k-online', 1000, 1000):
                    logger.warning("Insufficient budget for discovery stage, using cheaper model")

                updated_state = await self.research_discovery.execute(state)
                return updated_state
            else:
                # Mock execution for dry run
                state["research_discovery"] = {"mock": "discovery_data"}
                if "research_data" not in state:
                    state["research_data"] = {}
                state["research_data"]["discovery"] = {"mock": "discovery_data"}

                # Track mock cost
                if self.cost_tracker:
                    self.cost_tracker.track_cost(
                        agent_name="research_discovery",
                        provider="mock",
                        model="mock",
                        cost=0.0,
                        operation="mock_discovery"
                    )

                return update_cost(state, "discovery", 0.0)

        except BudgetExceededException as e:
            logger.error(f"Discovery stage budget exceeded: {e}")
            return add_error(state, str(e), "discovery")
        except Exception as e:
            logger.error(f"Discovery stage failed: {e}")
            return add_error(state, f"Discovery failed: {e}", "discovery")

    async def _deep_dive_node(self, state: PodcastState) -> PodcastState:
        """Execute research deep dive stage."""
        logger.info("Executing deep dive stage")
        state = update_stage(state, "deep_dive")

        try:
            if self.research_deep_dive and not state.get("dry_run"):
                updated_state = await self.research_deep_dive.execute(state)
                return updated_state
            else:
                # Mock or skip if agent not available
                state["research_deep_dive"] = {"mock": "deep_dive_data"}
                state["research_data"]["deep_dive"] = {"mock": "deep_dive_data"}
                return update_cost(state, "deep_dive", 0.0)

        except Exception as e:
            logger.error(f"Deep dive stage failed: {e}")
            return add_error(state, f"Deep dive failed: {e}", "deep_dive")

    async def _validation_node(self, state: PodcastState) -> PodcastState:
        """Execute research validation stage."""
        logger.info("Executing validation stage")
        state = update_stage(state, "validation")

        try:
            if self.research_validation and not state.get("dry_run"):
                updated_state = await self.research_validation.execute(state)
                return updated_state
            else:
                # Mock or skip if agent not available
                state["research_validation"] = {"mock": "validation_data"}
                state["research_data"]["validation"] = {"mock": "validation_data"}
                return update_cost(state, "validation", 0.0)

        except Exception as e:
            logger.error(f"Validation stage failed: {e}")
            return add_error(state, f"Validation failed: {e}", "validation")

    async def _synthesis_node(self, state: PodcastState) -> PodcastState:
        """Execute research synthesis stage."""
        logger.info("Executing synthesis stage")
        state = update_stage(state, "synthesis")

        try:
            if self.research_synthesis and not state.get("dry_run"):
                updated_state = await self.research_synthesis.execute(state)
                return updated_state
            else:
                # Mock or skip if agent not available
                state["research_synthesis"] = {"mock": "synthesis_data"}
                state["research_data"]["synthesis"] = {"mock": "synthesis_data"}
                return update_cost(state, "synthesis", 0.0)

        except Exception as e:
            logger.error(f"Synthesis stage failed: {e}")
            return add_error(state, f"Synthesis failed: {e}", "synthesis")

    async def _question_generation_node(self, state: PodcastState) -> PodcastState:
        """Execute question generation stage."""
        logger.info("Executing question generation stage")
        state = update_stage(state, "question_generation")

        try:
            if self.question_generator and not state.get("dry_run"):
                updated_state = await self.question_generator.execute(state)
                return updated_state
            else:
                # Mock execution or missing agent
                state["research_questions"] = ["What is the main concept?", "How does it work?", "What are the implications?"]
                state["research_data"]["question_generation"] = {"mock": "question_data"}
                return update_cost(state, "question_generation", 0.0)

        except Exception as e:
            logger.error(f"Question generation failed: {e}")
            return add_error(state, f"Question generation failed: {e}", "question_generation")

    async def _planning_node(self, state: PodcastState) -> PodcastState:
        """Execute episode planning stage."""
        logger.info("Executing planning stage")
        state = update_stage(state, "planning")

        try:
            if self.episode_planner and not state.get("dry_run"):
                updated_state = await self.episode_planner.execute(state)
                return updated_state
            else:
                # Mock planning for dry run
                state["episode_plan"] = {
                    "structure": "intro_main_conclusion",
                    "estimated_duration": 15,
                    "key_points": state.get("research_questions", [])[:3],
                    "mock": True
                }
                return update_cost(state, "planning", 0.0)

        except Exception as e:
            logger.error(f"Planning stage failed: {e}")
            return add_error(state, f"Planning failed: {e}", "planning")

    async def _writing_node(self, state: PodcastState) -> PodcastState:
        """Execute script writing stage."""
        logger.info("Executing writing stage")
        state = update_stage(state, "writing")

        try:
            if self.script_writer and not state.get("dry_run"):
                updated_state = await self.script_writer.execute(state)
                return updated_state
            else:
                # Mock writing for dry run
                topic = state.get("topic", "Unknown Topic")
                state["script_raw"] = f"""
# {topic}

Welcome to our exploration of {topic}. Today we'll examine the key insights
from our research and help you understand this fascinating subject.

## Main Discussion

Based on our research, here are the key points:
{chr(10).join(f"- {q}" for q in state.get("research_questions", [])[:3])}

## Conclusion

{topic} represents an important area of study with ongoing developments.
Thank you for joining us today!
                """.strip()

                return update_cost(state, "writing", 0.0)

        except Exception as e:
            logger.error(f"Writing stage failed: {e}")
            return add_error(state, f"Writing failed: {e}", "writing")

    async def _polishing_node(self, state: PodcastState) -> PodcastState:
        """Execute script polishing stage."""
        logger.info("Executing polishing stage")
        state = update_stage(state, "polishing")

        try:
            if self.brand_validator and not state.get("dry_run"):
                # Use brand validator to polish the script
                updated_state = await self.brand_validator.execute(state)
                # Copy the validated script as the polished version
                state["script_polished"] = state.get("script_raw", "")
                return updated_state
            else:
                # Mock polishing for dry run
                state["script_polished"] = state.get("script_raw", "")
                return update_cost(state, "polishing", 0.0)

        except Exception as e:
            logger.error(f"Polishing stage failed: {e}")
            return add_error(state, f"Polishing failed: {e}", "polishing")

    async def _audio_generation_node(self, state: PodcastState) -> PodcastState:
        """Execute audio generation stage."""
        logger.info("Executing audio generation stage")
        state = update_stage(state, "audio_generation")

        try:
            # Mock audio generation - would integrate with ElevenLabs
            output_dir = Path(state.get("output_directory", "./output"))
            output_dir.mkdir(parents=True, exist_ok=True)

            audio_path = output_dir / f"{state['episode_id']}_audio.mp3"
            state["audio_file_path"] = str(audio_path)
            state["audio_config"] = {
                "voice_id": get_production_voice_id(),  # Production voice
                "model": "eleven_turbo_v2_5",
                "mock": True
            }

            return update_cost(state, "audio_generation", 0.0)

        except Exception as e:
            logger.error(f"Audio generation failed: {e}")
            return add_error(state, f"Audio generation failed: {e}", "audio_generation")

    async def _quality_check_node(self, state: PodcastState) -> PodcastState:
        """Execute final quality check."""
        logger.info("Executing quality check stage")
        state = update_stage(state, "quality_check")

        try:
            # Mock quality scoring
            state["quality_scores"] = {
                "brand_alignment": 8.5,
                "technical_accuracy": 9.0,
                "engagement": 8.0,
                "overall": 8.5,
                "mock": True
            }

            # Mark as completed
            state = update_stage(state, "completed")
            return state

        except Exception as e:
            logger.error(f"Quality check failed: {e}")
            return add_error(state, f"Quality check failed: {e}", "quality_check")

    async def _cost_check_node(self, state: PodcastState) -> PodcastState:
        """Check cost limits and budget compliance."""
        logger.info("Executing cost check")

        if self.cost_tracker:
            # Get current cost from tracker
            current_cost = self.cost_tracker.total_cost
            budget_limit = self.cost_tracker.budget_limit
            remaining = self.cost_tracker.check_budget_remaining()

            # Update state with serialized cost data (August 2025)
            state["total_cost"] = current_cost
            state["cost_data"] = self.cost_tracker.to_dict()

            if current_cost > budget_limit:
                logger.warning(f"Budget exceeded: ${current_cost:.4f} > ${budget_limit:.2f}")
                return add_error(state, f"Budget exceeded: ${current_cost:.4f}", "cost_check")

            # Issue warnings based on budget usage
            budget_used_percent = (current_cost / budget_limit) * 100
            if budget_used_percent >= 80:
                logger.warning(f"High budget usage: {budget_used_percent:.1f}% (${remaining:.4f} remaining)")

                # Get model recommendations for remaining operations
                recommendations = self.cost_tracker.get_model_recommendations()
                state["model_recommendations"] = recommendations
                logger.info(f"Model recommendations: {recommendations}")

            logger.info(f"Budget check passed: ${current_cost:.4f} / ${budget_limit:.2f} (${remaining:.4f} remaining)")
        else:
            # Fallback to state-based checking
            total_cost = state.get("total_cost", 0.0)
            budget_limit = state.get("budget_limit", 5.51)

            if total_cost > budget_limit:
                logger.warning(f"Budget exceeded: ${total_cost:.2f} > ${budget_limit:.2f}")
                return add_error(state, f"Budget exceeded: ${total_cost:.2f}", "cost_check")

            logger.info(f"Budget check passed: ${total_cost:.2f} / ${budget_limit:.2f}")

        return state

    async def _error_handler_node(self, state: PodcastState) -> PodcastState:
        """Handle workflow errors and cleanup."""
        logger.info("Handling workflow errors")
        state = update_stage(state, "failed")

        # Log all errors
        for error in state.get("errors", []):
            logger.error(f"Workflow error: {error}")

        # Save error report
        try:
            output_dir = Path(state.get("output_directory", "./output"))
            output_dir.mkdir(parents=True, exist_ok=True)

            error_report = {
                "episode_id": state.get("episode_id"),
                "topic": state.get("topic"),
                "errors": state.get("errors", []),
                "cost_breakdown": state.get("cost_breakdown", {}),
                "total_cost": state.get("total_cost", 0.0),
                "stage_failed": state.get("current_stage")
            }

            error_path = output_dir / f"{state['episode_id']}_error_report.json"
            with open(error_path, 'w') as f:
                json.dump(error_report, f, indent=2, default=str)

            logger.info(f"Error report saved to: {error_path}")

        except Exception as e:
            logger.error(f"Failed to save error report: {e}")

        return state

    # Conditional routing functions
    def _should_continue_research(self, state: PodcastState) -> Literal["continue", "over_budget", "complete"]:
        """Determine if research should continue."""

        # Check budget
        if is_over_budget(state):
            return "over_budget"

        # Check if we have errors
        if state.get("errors"):
            return "over_budget"  # Route to error handler

        # Check current stage - continue if we're in discovery
        current_stage = state.get("current_stage", "")
        if current_stage == "discovery":
            return "continue"

        return "complete"

    def _should_generate_audio(self, state: PodcastState) -> Literal["generate", "retry", "skip"]:
        """Determine if audio generation should proceed."""

        # Check budget
        if is_over_budget(state):
            return "skip"

        # Check if script exists and is not empty
        script = state.get("script_polished", "").strip()
        if not script:
            retry_count = state.get("retry_count", 0)
            if retry_count < 2:
                state["retry_count"] = retry_count + 1
                return "retry"
            else:
                return "skip"

        # Check script quality (mock check)
        if len(script) < 100:  # Too short
            return "skip"

        return "generate"


def create_workflow(config: Dict[str, Any] = None) -> PodcastWorkflow:
    """
    Factory function to create podcast workflow.

    Args:
        config: Optional configuration

    Returns:
        Configured PodcastWorkflow instance
    """
    return PodcastWorkflow(config)


async def execute_workflow(
    topic: str,
    budget: float = 5.51,
    output_dir: str = "./output",
    dry_run: bool = False,
    verbose: bool = False,
    config: Dict[str, Any] = None
) -> PodcastState:
    """
    Execute complete podcast production workflow.

    Args:
        topic: Podcast episode topic
        budget: Maximum budget
        output_dir: Output directory
        dry_run: If True, mock all API calls
        verbose: Enable verbose logging
        config: Optional workflow configuration

    Returns:
        Final state with all results
    """
    from core.state import create_initial_state

    # Create initial state
    initial_state = create_initial_state(
        topic=topic,
        budget=budget,
        output_dir=output_dir,
        dry_run=dry_run,
        verbose=verbose
    )

    # Create and execute workflow
    workflow = create_workflow(config)
    final_state = await workflow.execute(initial_state)

    return final_state
