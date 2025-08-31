"""
Research Pipeline Workflow using Modular Architecture

This workflow orchestrates the 4-stage research pipeline using
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
from ..agents.research_discovery_v2 import create_discovery_agent


logger = logging.getLogger(__name__)


class ResearchPipelineWorkflow:
    """
    Research pipeline workflow using modular architecture.

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
        self.workflow_id = "research_pipeline"

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

        logger.info(f"Research pipeline built using {self.orchestrator.provider_type.value}")
        return self.workflow

    def _create_workflow_definition(self) -> WorkflowDefinition:
        """Create provider-agnostic workflow definition."""
        return WorkflowDefinition(
            workflow_id=self.workflow_id,
            name="4-Stage Research Pipeline",
            description="Discovery → Deep-dive → Validation → Synthesis",
            nodes=[
                {
                    'id': 'discovery',
                    'name': 'Research Discovery',
                    'function': self._discovery_node
                },
                {
                    'id': 'deep_dive',
                    'name': 'Deep Dive Research',
                    'function': self._deep_dive_node
                },
                {
                    'id': 'validation',
                    'name': 'Fact Validation',
                    'function': self._validation_node
                },
                {
                    'id': 'synthesis',
                    'name': 'Research Synthesis',
                    'function': self._synthesis_node
                }
            ],
            edges=[
                {'from': 'discovery', 'to': 'deep_dive'},
                {'from': 'deep_dive', 'to': 'validation'},
                {'from': 'validation', 'to': 'synthesis'}
            ],
            config={
                'entry': 'discovery',
                'finish': 'synthesis',
                'max_cost': self.config.get('budget.research_budget', 2.50),
                'timeout': 300
            },
            metadata={
                'version': '1.0.0',
                'created_at': datetime.now().isoformat()
            }
        )

    def _add_workflow_nodes(self) -> None:
        """Add nodes to the workflow."""
        # Discovery node
        self.orchestrator.add_node(
            self.workflow,
            'discovery',
            self._discovery_node
        )

        # Deep dive node
        self.orchestrator.add_node(
            self.workflow,
            'deep_dive',
            self._deep_dive_node
        )

        # Validation node
        self.orchestrator.add_node(
            self.workflow,
            'validation',
            self._validation_node
        )

        # Synthesis node
        self.orchestrator.add_node(
            self.workflow,
            'synthesis',
            self._synthesis_node
        )

    def _add_workflow_edges(self) -> None:
        """Add edges between workflow nodes."""
        # Sequential flow
        self.orchestrator.add_edge(self.workflow, 'discovery', 'deep_dive')
        self.orchestrator.add_edge(self.workflow, 'deep_dive', 'validation')
        self.orchestrator.add_edge(self.workflow, 'validation', 'synthesis')

    def _discovery_node(self, state: AgentState) -> AgentState:
        """Execute discovery research."""
        logger.info("Executing discovery node")

        # Log to observability if available
        if self.observability:
            self.observability.log_execution(
                execution_id=state.data.get('execution_id', 'unknown'),
                workflow_id=self.workflow_id,
                state=state,
                stage='discovery_start'
            )

        # Create and execute discovery agent
        agent = create_discovery_agent()
        result_state = agent.execute(state)

        # Log completion
        if self.observability:
            self.observability.log_cost(
                execution_id=state.data.get('execution_id', 'unknown'),
                cost_type='discovery',
                amount=result_state.cost_tracking.get('discovery', 0),
                metadata={'stage': 'discovery'}
            )

        return result_state

    def _deep_dive_node(self, state: AgentState) -> AgentState:
        """Execute deep dive research."""
        logger.info("Executing deep dive node")

        # For now, mock the deep dive
        # In production, would create and execute deep_dive agent
        state.stage = 'deep_dive_complete'
        state.data['deep_dive'] = {
            'detailed_analysis': 'Comprehensive analysis would go here',
            'expert_quotes': [],
            'technical_details': {}
        }
        state.cost_tracking['deep_dive'] = 1.00

        if self.observability:
            self.observability.log_cost(
                execution_id=state.data.get('execution_id', 'unknown'),
                cost_type='deep_dive',
                amount=1.00,
                metadata={'stage': 'deep_dive'}
            )

        return state

    def _validation_node(self, state: AgentState) -> AgentState:
        """Execute fact validation."""
        logger.info("Executing validation node")

        # For now, mock validation
        # In production, would create and execute validation agent
        state.stage = 'validation_complete'
        state.data['validation'] = {
            'verified_facts': [],
            'disputed_claims': [],
            'confidence_scores': {}
        }
        state.cost_tracking['validation'] = 0.35

        if self.observability:
            self.observability.log_cost(
                execution_id=state.data.get('execution_id', 'unknown'),
                cost_type='validation',
                amount=0.35,
                metadata={'stage': 'validation'}
            )

        return state

    def _synthesis_node(self, state: AgentState) -> AgentState:
        """Execute research synthesis."""
        logger.info("Executing synthesis node")

        # For now, mock synthesis
        # In production, would create and execute synthesis agent
        state.stage = 'synthesis_complete'
        state.data['synthesis'] = {
            'narrative': 'Synthesized research narrative',
            'key_findings': [],
            'recommendations': []
        }
        state.cost_tracking['synthesis'] = 0.15

        # Calculate total cost
        total_cost = sum(state.cost_tracking.values())
        state.cost_tracking['total'] = total_cost

        if self.observability:
            self.observability.log_cost(
                execution_id=state.data.get('execution_id', 'unknown'),
                cost_type='total',
                amount=total_cost,
                metadata={'stage': 'complete', 'all_stages': state.cost_tracking}
            )

        logger.info(f"Research pipeline complete. Total cost: ${total_cost:.2f}")
        return state

    def execute(
        self,
        topic: str,
        focus_areas: Optional[str] = None,
        execution_id: Optional[str] = None
    ) -> AgentState:
        """
        Execute the research pipeline.

        Args:
            topic: Research topic
            focus_areas: Optional focus areas
            execution_id: Optional execution ID for tracking

        Returns:
            Final state with all research results
        """
        if not self.workflow:
            self.build()

        # Create initial state
        initial_state = AgentState(
            agent_id="research_pipeline",
            stage="discovery",
            data={
                'topic': topic,
                'focus_areas': focus_areas or 'comprehensive overview',
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


def create_research_pipeline() -> ResearchPipelineWorkflow:
    """
    Factory function to create research pipeline with proper dependencies.

    The orchestration provider is automatically injected based on
    configuration, making this work with any orchestrator.
    """
    container = get_container()

    # Dependencies will be automatically injected
    return ResearchPipelineWorkflow()


def run_research_pipeline(
    topic: str,
    provider: str = 'langgraph'
) -> Dict[str, Any]:
    """
    Run research pipeline with specified provider.

    Args:
        topic: Research topic
        provider: Orchestration provider to use

    Returns:
        Research results
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
    pipeline = create_research_pipeline()
    result = pipeline.execute(topic)

    # Return results as dictionary
    return {
        'topic': topic,
        'stage': result.stage,
        'results': result.data,
        'cost': result.cost_tracking,
        'error': result.error_state
    }
