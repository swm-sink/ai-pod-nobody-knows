"""
Provider abstraction interface for orchestration systems.

This module defines the abstract base classes and interfaces that all
orchestration providers must implement, ensuring provider independence
and easy swapping between different systems (LangGraph, Temporal, etc).

Version: 1.0.0
Date: August 2025
"""

from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional, TypeVar, Generic, Callable
from dataclasses import dataclass
from enum import Enum
import json
from datetime import datetime


class ProviderType(Enum):
    """Supported orchestration provider types."""
    LANGGRAPH = "langgraph"
    TEMPORAL = "temporal"
    PREFECT = "prefect"
    DAGSTER = "dagster"
    AIRFLOW = "airflow"
    CUSTOM = "custom"


@dataclass
class AgentState:
    """Provider-agnostic agent state representation."""
    agent_id: str
    stage: str
    data: Dict[str, Any]
    metadata: Dict[str, Any]
    timestamp: datetime
    cost_tracking: Dict[str, float]
    error_state: Optional[Dict[str, Any]] = None

    def to_json(self) -> str:
        """Serialize state to JSON."""
        return json.dumps({
            "agent_id": self.agent_id,
            "stage": self.stage,
            "data": self.data,
            "metadata": self.metadata,
            "timestamp": self.timestamp.isoformat(),
            "cost_tracking": self.cost_tracking,
            "error_state": self.error_state
        })

    @classmethod
    def from_json(cls, json_str: str) -> 'AgentState':
        """Deserialize state from JSON."""
        data = json.loads(json_str)
        data['timestamp'] = datetime.fromisoformat(data['timestamp'])
        return cls(**data)


@dataclass
class WorkflowDefinition:
    """Provider-agnostic workflow definition."""
    workflow_id: str
    name: str
    description: str
    nodes: List[Dict[str, Any]]
    edges: List[Dict[str, Any]]
    config: Dict[str, Any]
    metadata: Dict[str, Any]


T = TypeVar('T')


class OrchestrationProvider(ABC, Generic[T]):
    """
    Abstract base class for orchestration providers.

    All orchestration systems (LangGraph, Temporal, etc) must implement
    this interface to ensure modularity and provider independence.
    """

    def __init__(self, config: Dict[str, Any]):
        """Initialize provider with configuration."""
        self.config = config
        self.provider_type = ProviderType.CUSTOM
        self._validate_config()

    @abstractmethod
    def _validate_config(self) -> None:
        """Validate provider-specific configuration."""
        pass

    @abstractmethod
    def create_workflow(self, definition: WorkflowDefinition) -> T:
        """
        Create a workflow from definition.

        Args:
            definition: Provider-agnostic workflow definition

        Returns:
            Provider-specific workflow object
        """
        pass

    @abstractmethod
    def execute_workflow(
        self,
        workflow: T,
        initial_state: AgentState,
        **kwargs
    ) -> AgentState:
        """
        Execute a workflow with initial state.

        Args:
            workflow: Provider-specific workflow object
            initial_state: Initial agent state
            **kwargs: Provider-specific execution options

        Returns:
            Final agent state after execution
        """
        pass

    @abstractmethod
    def add_node(
        self,
        workflow: T,
        node_id: str,
        node_function: Callable,
        **kwargs
    ) -> None:
        """
        Add a node to the workflow.

        Args:
            workflow: Provider-specific workflow object
            node_id: Unique node identifier
            node_function: Function to execute at this node
            **kwargs: Provider-specific node options
        """
        pass

    @abstractmethod
    def add_edge(
        self,
        workflow: T,
        from_node: str,
        to_node: str,
        condition: Optional[Callable] = None,
        **kwargs
    ) -> None:
        """
        Add an edge between nodes.

        Args:
            workflow: Provider-specific workflow object
            from_node: Source node ID
            to_node: Target node ID
            condition: Optional condition function
            **kwargs: Provider-specific edge options
        """
        pass

    @abstractmethod
    def get_state(self, workflow: T, execution_id: str) -> AgentState:
        """
        Get current state of a workflow execution.

        Args:
            workflow: Provider-specific workflow object
            execution_id: Execution identifier

        Returns:
            Current agent state
        """
        pass

    @abstractmethod
    def list_executions(self, workflow: T, limit: int = 10) -> List[Dict[str, Any]]:
        """
        List recent workflow executions.

        Args:
            workflow: Provider-specific workflow object
            limit: Maximum number of executions to return

        Returns:
            List of execution metadata
        """
        pass

    @abstractmethod
    def stop_execution(self, workflow: T, execution_id: str) -> bool:
        """
        Stop a running workflow execution.

        Args:
            workflow: Provider-specific workflow object
            execution_id: Execution identifier

        Returns:
            True if successfully stopped
        """
        pass

    @abstractmethod
    def cleanup(self) -> None:
        """Clean up provider resources."""
        pass

    def get_provider_info(self) -> Dict[str, Any]:
        """Get provider information and capabilities."""
        return {
            "type": self.provider_type.value,
            "config": {k: v for k, v in self.config.items() if not k.startswith("_")},
            "capabilities": self._get_capabilities()
        }

    def _get_capabilities(self) -> Dict[str, bool]:
        """Get provider capabilities."""
        return {
            "async_execution": False,
            "state_persistence": False,
            "retry_policies": False,
            "distributed": False,
            "monitoring": False,
            "versioning": False
        }


class ObservabilityProvider(ABC):
    """
    Abstract base class for observability providers.

    All observability systems (LangFuse, Weights & Biases, etc) must
    implement this interface.
    """

    def __init__(self, config: Dict[str, Any]):
        """Initialize observability provider."""
        self.config = config
        self._validate_config()

    @abstractmethod
    def _validate_config(self) -> None:
        """Validate provider-specific configuration."""
        pass

    @abstractmethod
    def log_execution(
        self,
        execution_id: str,
        workflow_id: str,
        state: AgentState,
        **kwargs
    ) -> None:
        """Log workflow execution details."""
        pass

    @abstractmethod
    def log_prompt(
        self,
        prompt_id: str,
        prompt_template: str,
        variables: Dict[str, Any],
        response: str,
        metadata: Dict[str, Any]
    ) -> None:
        """Log prompt execution."""
        pass

    @abstractmethod
    def log_metric(
        self,
        name: str,
        value: float,
        tags: Optional[Dict[str, str]] = None,
        timestamp: Optional[datetime] = None
    ) -> None:
        """Log a metric value."""
        pass

    @abstractmethod
    def log_cost(
        self,
        execution_id: str,
        cost_type: str,
        amount: float,
        metadata: Dict[str, Any]
    ) -> None:
        """Log cost information."""
        pass

    @abstractmethod
    def get_metrics(
        self,
        metric_names: List[str],
        start_time: datetime,
        end_time: datetime,
        tags: Optional[Dict[str, str]] = None
    ) -> Dict[str, List[float]]:
        """Retrieve metrics for analysis."""
        pass

    @abstractmethod
    def cleanup(self) -> None:
        """Clean up provider resources."""
        pass


class LLMProvider(ABC):
    """
    Abstract base class for LLM providers.

    All LLM systems (OpenAI, Anthropic, etc) must implement this interface.
    """

    def __init__(self, config: Dict[str, Any]):
        """Initialize LLM provider."""
        self.config = config
        self._validate_config()

    @abstractmethod
    def _validate_config(self) -> None:
        """Validate provider-specific configuration."""
        pass

    @abstractmethod
    def generate(
        self,
        prompt: str,
        max_tokens: int = 1000,
        temperature: float = 0.7,
        **kwargs
    ) -> str:
        """Generate text from prompt."""
        pass

    @abstractmethod
    def generate_with_template(
        self,
        template_id: str,
        variables: Dict[str, Any],
        **kwargs
    ) -> str:
        """Generate text using a template."""
        pass

    @abstractmethod
    def estimate_cost(
        self,
        prompt: str,
        max_tokens: int = 1000
    ) -> float:
        """Estimate generation cost."""
        pass

    @abstractmethod
    def cleanup(self) -> None:
        """Clean up provider resources."""
        pass
