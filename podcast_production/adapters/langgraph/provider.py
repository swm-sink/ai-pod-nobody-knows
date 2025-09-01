"""
LangGraph orchestration provider adapter.

This module implements the OrchestrationProvider interface for LangGraph,
allowing it to be swapped with other orchestration systems.

Version: 1.0.0
Date: August 2025
"""

from typing import Any, Callable, Dict, List, Optional
from datetime import datetime
import logging
import json

from langgraph.graph import StateGraph
from langgraph.checkpoint.memory import MemorySaver
from langchain_core.runnables import RunnableConfig

from core.interfaces.provider import (
    OrchestrationProvider,
    WorkflowDefinition,
    AgentState,
    ProviderType
)


logger = logging.getLogger(__name__)


class LangGraphProvider(OrchestrationProvider[StateGraph]):
    """
    LangGraph implementation of OrchestrationProvider.

    Adapts LangGraph to work with our provider-agnostic interface.
    """

    def __init__(self, config: Dict[str, Any]):
        """
        Initialize LangGraph provider.

        Args:
            config: Provider configuration including:
                - checkpointer: Type of checkpointer (memory, sqlite, etc)
                - max_iterations: Maximum workflow iterations
                - recursion_limit: Maximum recursion depth
        """
        super().__init__(config)
        self.provider_type = ProviderType.LANGGRAPH
        self._checkpointer = self._setup_checkpointer()
        self._workflows: Dict[str, StateGraph] = {}
        self._executions: Dict[str, Dict[str, Any]] = {}

    def _validate_config(self) -> None:
        """Validate LangGraph-specific configuration."""
        required = ['max_iterations']
        missing = [key for key in required if key not in self.config]
        if missing:
            raise ValueError(f"Missing required config: {missing}")

        # Set defaults
        self.config.setdefault('checkpointer', 'memory')
        self.config.setdefault('recursion_limit', 25)
        self.config.setdefault('debug', False)

    def _setup_checkpointer(self):
        """Set up LangGraph checkpointer based on config."""
        checkpointer_type = self.config.get('checkpointer', 'memory')

        if checkpointer_type == 'memory':
            return MemorySaver()
        elif checkpointer_type == 'sqlite':
            # Would import and use SqliteSaver here
            logger.warning("SQLite checkpointer not implemented, using memory")
            return MemorySaver()
        else:
            logger.warning(f"Unknown checkpointer type: {checkpointer_type}")
            return MemorySaver()

    def create_workflow(self, definition: WorkflowDefinition) -> StateGraph:
        """
        Create a LangGraph workflow from definition.

        Args:
            definition: Provider-agnostic workflow definition

        Returns:
            LangGraph StateGraph instance
        """
        # Convert our AgentState to LangGraph state schema
        state_schema = self._create_state_schema(definition)

        # Create StateGraph
        workflow = StateGraph(state_schema)

        # Add nodes from definition
        for node in definition.nodes:
            node_id = node['id']
            node_func = self._wrap_node_function(node.get('function'))
            workflow.add_node(node_id, node_func)

        # Add edges from definition
        for edge in definition.edges:
            if edge.get('condition'):
                workflow.add_conditional_edges(
                    edge['from'],
                    self._wrap_condition_function(edge['condition']),
                    edge.get('routing', {})
                )
            else:
                workflow.add_edge(edge['from'], edge['to'])

        # Set entry point
        if 'entry' in definition.config:
            workflow.set_entry_point(definition.config['entry'])

        # Set finish point
        if 'finish' in definition.config:
            workflow.set_finish_point(definition.config['finish'])

        # Store workflow
        self._workflows[definition.workflow_id] = workflow

        return workflow

    def _create_state_schema(self, definition: WorkflowDefinition) -> type:
        """Create LangGraph state schema from definition."""
        from typing import TypedDict

        # Dynamic state class creation based on definition
        fields = {
            'agent_id': str,
            'stage': str,
            'data': dict,
            'metadata': dict,
            'cost_tracking': dict,
            'error_state': Optional[dict],
            'messages': list  # LangGraph often uses messages
        }

        # Add any custom fields from definition
        if 'state_fields' in definition.config:
            fields.update(definition.config['state_fields'])

        # Create TypedDict dynamically
        StateSchema = TypedDict('StateSchema', fields)
        return StateSchema

    def _wrap_node_function(self, func: Optional[Callable]) -> Callable:
        """Wrap node function to work with LangGraph."""
        if not func:
            # Return a no-op function
            return lambda state: state

        def wrapped(state: dict) -> dict:
            # Convert LangGraph state to our AgentState
            agent_state = self._langgraph_to_agent_state(state)

            # Execute original function
            result = func(agent_state)

            # Convert back to LangGraph state
            return self._agent_state_to_langgraph(result)

        return wrapped

    def _wrap_condition_function(self, func: Callable) -> Callable:
        """Wrap condition function for LangGraph conditional edges."""
        def wrapped(state: dict) -> str:
            agent_state = self._langgraph_to_agent_state(state)
            return func(agent_state)

        return wrapped

    def execute_workflow(
        self,
        workflow: StateGraph,
        initial_state: AgentState,
        **kwargs
    ) -> AgentState:
        """
        Execute a LangGraph workflow.

        Args:
            workflow: LangGraph StateGraph
            initial_state: Initial agent state
            **kwargs: LangGraph-specific options

        Returns:
            Final agent state after execution
        """
        # Compile the workflow
        app = workflow.compile(checkpointer=self._checkpointer)

        # Convert initial state to LangGraph format
        langgraph_state = self._agent_state_to_langgraph(initial_state)

        # Create config
        config = RunnableConfig(
            recursion_limit=self.config.get('recursion_limit', 25),
            configurable={
                "thread_id": kwargs.get('thread_id', 'default'),
                "checkpoint_id": kwargs.get('checkpoint_id'),
            }
        )

        # Execute workflow
        try:
            result = app.invoke(langgraph_state, config)

            # Store execution info
            execution_id = kwargs.get('execution_id', str(datetime.now().timestamp()))
            self._executions[execution_id] = {
                'workflow': workflow,
                'initial_state': initial_state,
                'final_state': result,
                'config': config,
                'timestamp': datetime.now()
            }

            # Convert result back to AgentState
            return self._langgraph_to_agent_state(result)

        except Exception as e:
            logger.error(f"Workflow execution failed: {e}")
            # Return error state
            return AgentState(
                agent_id=initial_state.agent_id,
                stage="error",
                data={},
                metadata={"error": str(e)},
                timestamp=datetime.now(),
                cost_tracking={},
                error_state={"error": str(e), "type": type(e).__name__}
            )

    def add_node(
        self,
        workflow: StateGraph,
        node_id: str,
        node_function: Callable,
        **kwargs
    ) -> None:
        """Add a node to the LangGraph workflow."""
        wrapped_func = self._wrap_node_function(node_function)
        workflow.add_node(node_id, wrapped_func)

    def add_edge(
        self,
        workflow: StateGraph,
        from_node: str,
        to_node: str,
        condition: Optional[Callable] = None,
        **kwargs
    ) -> None:
        """Add an edge to the LangGraph workflow."""
        if condition:
            wrapped_condition = self._wrap_condition_function(condition)
            routing = kwargs.get('routing', {to_node: to_node})
            workflow.add_conditional_edges(from_node, wrapped_condition, routing)
        else:
            workflow.add_edge(from_node, to_node)

    def get_state(self, workflow: StateGraph, execution_id: str) -> AgentState:
        """Get current state of a workflow execution."""
        if execution_id in self._executions:
            execution = self._executions[execution_id]
            # In a real implementation, would query checkpointer
            return self._langgraph_to_agent_state(execution.get('final_state', {}))

        # Return empty state if not found
        return AgentState(
            agent_id="unknown",
            stage="not_found",
            data={},
            metadata={},
            timestamp=datetime.now(),
            cost_tracking={}
        )

    def list_executions(self, workflow: StateGraph, limit: int = 10) -> List[Dict[str, Any]]:
        """List recent workflow executions."""
        executions = []

        for exec_id, exec_data in list(self._executions.items())[:limit]:
            if exec_data.get('workflow') == workflow:
                executions.append({
                    'execution_id': exec_id,
                    'timestamp': exec_data['timestamp'].isoformat(),
                    'initial_stage': exec_data['initial_state'].stage,
                    'final_stage': self._langgraph_to_agent_state(
                        exec_data.get('final_state', {})
                    ).stage
                })

        return executions

    def stop_execution(self, workflow: StateGraph, execution_id: str) -> bool:
        """Stop a running workflow execution."""
        # LangGraph doesn't have built-in stop mechanism
        # Would need to implement via interrupts or flags
        logger.warning("Stop execution not implemented for LangGraph")
        return False

    def cleanup(self) -> None:
        """Clean up LangGraph resources."""
        self._workflows.clear()
        self._executions.clear()
        if hasattr(self._checkpointer, 'close'):
            self._checkpointer.close()

    def _agent_state_to_langgraph(self, state: AgentState) -> dict:
        """Convert AgentState to LangGraph state dict."""
        return {
            'agent_id': state.agent_id,
            'stage': state.stage,
            'data': state.data,
            'metadata': state.metadata,
            'cost_tracking': state.cost_tracking,
            'error_state': state.error_state,
            'messages': state.data.get('messages', [])
        }

    def _langgraph_to_agent_state(self, state: dict) -> AgentState:
        """Convert LangGraph state dict to AgentState."""
        return AgentState(
            agent_id=state.get('agent_id', 'unknown'),
            stage=state.get('stage', 'unknown'),
            data=state.get('data', {}),
            metadata=state.get('metadata', {}),
            timestamp=datetime.now(),
            cost_tracking=state.get('cost_tracking', {}),
            error_state=state.get('error_state')
        )

    def _get_capabilities(self) -> Dict[str, bool]:
        """Get LangGraph provider capabilities."""
        return {
            "async_execution": True,
            "state_persistence": True,
            "retry_policies": True,
            "distributed": False,
            "monitoring": True,
            "versioning": True
        }
