"""
Production Pipeline Workflow using Modular Architecture

This workflow orchestrates the 4-stage production pipeline using
provider-agnostic interfaces that work with any orchestration system.

Version: 1.0.0
Date: August 2025
"""

from typing import Dict, Any, Optional, List
from datetime import datetime
import logging

from ..core.interfaces.provider import (
    OrchestrationProvider,
    ObservabilityProvider,
    WorkflowDefinition,
    AgentState
)
from ..core.config.manager import get_config_manager
from ..core.di.container import get_container, inject
from ..agents.question_generator import QuestionGeneratorAgent
from ..agents.episode_planner import EpisodePlannerAgent
from ..agents.script_writer import ScriptWriterAgent
from ..agents.brand_validator import BrandValidatorAgent


logger = logging.getLogger(__name__)


class ProductionPipelineWorkflow:
    """
    Production pipeline workflow using modular architecture.

    This workflow can run on any orchestration provider:
    - LangGraph
    - Temporal
    - Prefect
    - Airflow
    - etc.
    """

    @inject
    def __init__(
        self,
        orchestrator: OrchestrationProvider,
        observability: Optional[ObservabilityProvider] = None
    ):
        """
        Initialize workflow with injected providers.

        Args:
            orchestrator: Orchestration provider (injected)
            observability: Observability provider (injected)
        """
        self.orchestrator = orchestrator
        self.observability = observability
        self.config = get_config_manager()
        self.workflow = None
        self.workflow_id = "production_pipeline"

    def build(self) -> Any:
        """
        Build the workflow using provider-agnostic definition.

        Returns:
            Provider-specific workflow object
        """
        # Create workflow definition (provider-agnostic)
        definition = self._create_workflow_definition()

        # Build workflow using orchestrator
        self.workflow = self.orchestrator.create_workflow(definition)

        # Add nodes
        self._add_workflow_nodes()

        # Add edges
        self._add_workflow_edges()

        logger.info(f"Production pipeline built using {self.orchestrator.provider_type.value}")
        return self.workflow

    def _create_workflow_definition(self) -> WorkflowDefinition:
        """Create provider-agnostic workflow definition."""
        return WorkflowDefinition(
            workflow_id=self.workflow_id,
            name="4-Stage Production Pipeline",
            description="Question Generation → Episode Planning → Script Writing → Brand Validation",
            nodes=[
                {
                    'id': 'question_generation',
                    'name': 'Question Generation',
                    'function': self._question_generation_node
                },
                {
                    'id': 'episode_planning',
                    'name': 'Episode Planning',
                    'function': self._episode_planning_node
                },
                {
                    'id': 'script_writing',
                    'name': 'Script Writing',
                    'function': self._script_writing_node
                },
                {
                    'id': 'brand_validation',
                    'name': 'Brand Validation',
                    'function': self._brand_validation_node
                }
            ],
            edges=[
                {'from': 'question_generation', 'to': 'episode_planning'},
                {'from': 'episode_planning', 'to': 'script_writing'},
                {'from': 'script_writing', 'to': 'brand_validation'}
            ],
            config={
                'entry': 'question_generation',
                'finish': 'brand_validation',
                'max_cost': self.config.get('budget.production_budget', 2.00),
                'timeout': 600
            },
            metadata={
                'version': '1.0.0',
                'created_at': datetime.now().isoformat()
            }
        )

    def _add_workflow_nodes(self) -> None:
        """Add nodes to the workflow."""
        # Question generation node
        self.orchestrator.add_node(
            self.workflow,
            'question_generation',
            self._question_generation_node
        )

        # Episode planning node
        self.orchestrator.add_node(
            self.workflow,
            'episode_planning',
            self._episode_planning_node
        )

        # Script writing node
        self.orchestrator.add_node(
            self.workflow,
            'script_writing',
            self._script_writing_node
        )

        # Brand validation node
        self.orchestrator.add_node(
            self.workflow,
            'brand_validation',
            self._brand_validation_node
        )

    def _add_workflow_edges(self) -> None:
        """Add edges between workflow nodes."""
        # Sequential flow
        self.orchestrator.add_edge(self.workflow, 'question_generation', 'episode_planning')
        self.orchestrator.add_edge(self.workflow, 'episode_planning', 'script_writing')
        self.orchestrator.add_edge(self.workflow, 'script_writing', 'brand_validation')

    async def _question_generation_node(self, state: AgentState) -> AgentState:
        """Execute question generation."""
        logger.info("Executing question generation node")

        # Log to observability if available
        if self.observability:
            self.observability.log_execution(
                execution_id=state.data.get('execution_id', 'unknown'),
                workflow_id=self.workflow_id,
                state=state,
                stage='question_generation_start'
            )

        # Create and execute question generator agent
        agent = QuestionGeneratorAgent()
        result_state = await agent.execute(state)

        # Log completion
        if self.observability:
            self.observability.log_cost(
                execution_id=result_state.data.get('execution_id', 'unknown'),
                cost_type='question_generation',
                amount=result_state.cost_tracking.get('question_generation', 0),
                metadata={'stage': 'question_generation'}
            )

        return result_state

    async def _episode_planning_node(self, state: AgentState) -> AgentState:
        """Execute episode planning."""
        logger.info("Executing episode planning node")

        # Log to observability if available
        if self.observability:
            self.observability.log_execution(
                execution_id=state.data.get('execution_id', 'unknown'),
                workflow_id=self.workflow_id,
                state=state,
                stage='episode_planning_start'
            )

        # Create and execute episode planner agent
        agent = EpisodePlannerAgent()
        result_state = await agent.execute(state)

        # Log completion
        if self.observability:
            self.observability.log_cost(
                execution_id=result_state.data.get('execution_id', 'unknown'),
                cost_type='episode_planning',
                amount=result_state.cost_tracking.get('episode_planning', 0),
                metadata={'stage': 'episode_planning'}
            )

        return result_state

    async def _script_writing_node(self, state: AgentState) -> AgentState:
        """Execute script writing."""
        logger.info("Executing script writing node")

        # Log to observability if available
        if self.observability:
            self.observability.log_execution(
                execution_id=state.data.get('execution_id', 'unknown'),
                workflow_id=self.workflow_id,
                state=state,
                stage='script_writing_start'
            )

        # Create and execute script writer agent
        agent = ScriptWriterAgent()
        result_state = await agent.execute(state)

        # Log completion
        if self.observability:
            self.observability.log_cost(
                execution_id=result_state.data.get('execution_id', 'unknown'),
                cost_type='script_writing',
                amount=result_state.cost_tracking.get('script_writing', 0),
                metadata={'stage': 'script_writing'}
            )

        return result_state

    async def _brand_validation_node(self, state: AgentState) -> AgentState:
        """Execute brand validation."""
        logger.info("Executing brand validation node")

        # Log to observability if available
        if self.observability:
            self.observability.log_execution(
                execution_id=state.data.get('execution_id', 'unknown'),
                workflow_id=self.workflow_id,
                state=state,
                stage='brand_validation_start'
            )

        # Create and execute brand validator agent
        agent = BrandValidatorAgent()
        result_state = await agent.execute(state)

        # Calculate total cost
        total_cost = sum(result_state.cost_tracking.values())
        result_state.cost_tracking['total'] = total_cost

        # Log completion
        if self.observability:
            self.observability.log_cost(
                execution_id=result_state.data.get('execution_id', 'unknown'),
                cost_type='total',
                amount=total_cost,
                metadata={'stage': 'complete', 'all_stages': result_state.cost_tracking}
            )

        logger.info(f"Production pipeline complete. Total cost: ${total_cost:.2f}")
        return result_state

    async def execute(
        self,
        topic: str,
        research_data: Dict[str, Any],
        focus_areas: Optional[str] = None,
        execution_id: Optional[str] = None
    ) -> AgentState:
        """
        Execute the production pipeline.

        Args:
            topic: Podcast episode topic
            research_data: Results from research pipeline
            focus_areas: Optional focus areas
            execution_id: Optional execution ID for tracking

        Returns:
            Final state with all production results
        """
        if not self.workflow:
            self.build()

        # Create initial state
        initial_state = AgentState(
            agent_id="production_pipeline",
            stage="question_generation",
            data={
                'topic': topic,
                'research_data': research_data,
                'focus_areas': focus_areas or 'comprehensive episode',
                'execution_id': execution_id or str(datetime.now().timestamp())
            },
            metadata={
                'started_at': datetime.now().isoformat(),
                'workflow_version': '1.0.0'
            },
            timestamp=datetime.now(),
            cost_tracking={}
        )

        # Log start
        if self.observability:
            self.observability.log_execution(
                execution_id=initial_state.data['execution_id'],
                workflow_id=self.workflow_id,
                state=initial_state,
                stage='start'
            )

        # Execute workflow
        try:
            final_state = self.orchestrator.execute_workflow(
                self.workflow,
                initial_state,
                thread_id=execution_id
            )

            # Log completion
            if self.observability:
                self.observability.log_execution(
                    execution_id=final_state.data['execution_id'],
                    workflow_id=self.workflow_id,
                    state=final_state,
                    stage='complete'
                )

            return final_state

        except Exception as e:
            logger.error(f"Workflow execution failed: {e}")

            # Create error state
            error_state = initial_state
            error_state.stage = 'error'
            error_state.error_state = {
                'error': str(e),
                'type': type(e).__name__,
                'timestamp': datetime.now().isoformat()
            }

            # Log error
            if self.observability:
                self.observability.log_execution(
                    execution_id=error_state.data['execution_id'],
                    workflow_id=self.workflow_id,
                    state=error_state,
                    stage='error'
                )

            return error_state


def create_production_pipeline() -> ProductionPipelineWorkflow:
    """
    Factory function to create production pipeline with proper dependencies.

    The orchestration provider is automatically injected based on
    configuration, making this work with any orchestrator.
    """
    container = get_container()

    # Dependencies will be automatically injected
    return ProductionPipelineWorkflow()


async def run_production_pipeline(
    topic: str,
    research_data: Dict[str, Any],
    provider: str = 'langgraph'
) -> Dict[str, Any]:
    """
    Run production pipeline with specified provider.

    Args:
        topic: Podcast episode topic
        research_data: Results from research pipeline
        provider: Orchestration provider to use

    Returns:
        Production results
    """
    from ..adapters.langgraph.provider import LangGraphProvider

    container = get_container()
    config = get_config_manager()

    # Register the desired orchestration provider
    if provider == 'langgraph':
        provider_config = config.get_provider_config('langgraph')
        container.override(
            OrchestrationProvider,
            LangGraphProvider(provider_config.extra_config if provider_config else {})
        )
    # elif provider == 'temporal':
    #     # Would register Temporal provider
    #     pass

    # Create and execute pipeline
    pipeline = create_production_pipeline()
    result = await pipeline.execute(topic, research_data)

    # Return results as dictionary
    return {
        'topic': topic,
        'stage': result.stage,
        'results': result.data,
        'cost': result.cost_tracking,
        'error': result.error_state
    }
