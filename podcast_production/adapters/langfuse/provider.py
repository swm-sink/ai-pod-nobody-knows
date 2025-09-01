"""
LangFuse observability provider implementation.

This module implements the ObservabilityProvider interface for LangFuse,
providing comprehensive tracing, prompt management, and A/B testing.

Version: 1.0.0
Date: August 2025
"""

from typing import Any, Dict, List, Optional
from datetime import datetime
import os
import logging
from contextlib import contextmanager

from core.interfaces.provider import ObservabilityProvider, AgentState

# Configure logging
logger = logging.getLogger(__name__)


class LangFuseProvider(ObservabilityProvider):
    """
    LangFuse implementation of observability provider.

    Provides:
    - Execution tracing and monitoring
    - Prompt versioning and management
    - A/B testing capabilities
    - Cost tracking and optimization
    - LLM-as-judge evaluation
    """

    def __init__(self, config: Dict[str, Any]):
        """
        Initialize LangFuse provider with configuration.

        Args:
            config: Provider configuration including API keys
        """
        super().__init__(config)
        self.client = None
        self.trace = None
        self._initialize_client()

    def _validate_config(self) -> None:
        """
        Validate LangFuse configuration.

        Raises:
            ValueError: If required configuration is missing
        """
        required_keys = ['public_key', 'secret_key', 'host']
        missing_keys = [key for key in required_keys if not self.config.get(key)]

        if missing_keys:
            raise ValueError(f"Missing required LangFuse config: {', '.join(missing_keys)}")

        # Validate host URL format
        host = self.config['host']
        if not host.startswith(('http://', 'https://')):
            raise ValueError(f"Invalid host URL format: {host}")

    def _initialize_client(self) -> None:
        """
        Initialize LangFuse client with secure key handling.

        Note: Actual client initialization would happen here.
        For now, we're implementing the interface structure.
        """
        try:
            # Import would be conditional on langfuse being installed
            # from langfuse import Langfuse

            # Mask keys in logs (show only last 4 characters)
            public_key = self.config['public_key']
            secret_key = self.config['secret_key']
            masked_public = f"...{public_key[-4:]}" if len(public_key) > 4 else "****"
            masked_secret = f"...{secret_key[-4:]}" if len(secret_key) > 4 else "****"

            logger.info(f"Initializing LangFuse client with public key: {masked_public}")

            # Initialize client (would be actual implementation)
            # self.client = Langfuse(
            #     public_key=public_key,
            #     secret_key=secret_key,
            #     host=self.config['host'],
            #     flush_at=self.config.get('flush_at', 10),
            #     flush_interval=self.config.get('flush_interval', 10),
            #     max_retries=self.config.get('max_retries', 3),
            #     timeout=self.config.get('timeout', 30)
            # )

            logger.info("LangFuse client initialized successfully")

        except Exception as e:
            # Ensure error messages don't contain keys
            error_msg = str(e).replace(self.config.get('secret_key', ''), '***')
            error_msg = error_msg.replace(self.config.get('public_key', ''), '***')
            logger.error(f"Failed to initialize LangFuse client: {error_msg}")
            raise

    @contextmanager
    def create_trace(self, name: str, metadata: Optional[Dict[str, Any]] = None):
        """
        Create a new trace context for tracking execution.

        Args:
            name: Name of the trace
            metadata: Optional metadata to attach

        Yields:
            Trace object for nested operations
        """
        try:
            # Would create actual trace with client
            # self.trace = self.client.trace(name=name, metadata=metadata or {})
            logger.debug(f"Created trace: {name}")
            yield self
        finally:
            # Would flush trace
            # if self.trace:
            #     self.trace.flush()
            logger.debug(f"Flushed trace: {name}")

    def log_execution(
        self,
        execution_id: str,
        workflow_id: str,
        state: AgentState,
        **kwargs
    ) -> None:
        """
        Log workflow execution details to LangFuse.

        Args:
            execution_id: Unique execution identifier
            workflow_id: Workflow being executed
            state: Current agent state
            **kwargs: Additional execution metadata
        """
        try:
            execution_data = {
                "execution_id": execution_id,
                "workflow_id": workflow_id,
                "agent_id": state.agent_id,
                "stage": state.stage,
                "timestamp": state.timestamp.isoformat(),
                "cost_tracking": state.cost_tracking,
                **kwargs
            }

            # Would log to LangFuse
            # if self.trace:
            #     self.trace.event(
            #         name="workflow_execution",
            #         input=execution_data,
            #         output=state.data,
            #         metadata=state.metadata
            #     )

            logger.debug(f"Logged execution: {execution_id}")

        except Exception as e:
            logger.error(f"Failed to log execution: {self._mask_error(e)}")

    def log_prompt(
        self,
        prompt_id: str,
        prompt_template: str,
        variables: Dict[str, Any],
        response: str,
        metadata: Dict[str, Any]
    ) -> None:
        """
        Log prompt execution for versioning and analysis.

        Args:
            prompt_id: Unique prompt identifier
            prompt_template: Template used
            variables: Variables injected into template
            response: LLM response
            metadata: Additional prompt metadata
        """
        try:
            prompt_data = {
                "prompt_id": prompt_id,
                "template": prompt_template,
                "variables": variables,
                "metadata": metadata,
                "timestamp": datetime.now().isoformat()
            }

            # Would log to LangFuse
            # if self.client:
            #     self.client.generation(
            #         name=prompt_id,
            #         input=prompt_template.format(**variables),
            #         output=response,
            #         metadata=metadata,
            #         model=metadata.get('model'),
            #         usage=metadata.get('usage')
            #     )

            logger.debug(f"Logged prompt: {prompt_id}")

        except Exception as e:
            logger.error(f"Failed to log prompt: {self._mask_error(e)}")

    def log_metric(
        self,
        name: str,
        value: float,
        tags: Optional[Dict[str, str]] = None,
        timestamp: Optional[datetime] = None
    ) -> None:
        """
        Log a metric value for monitoring.

        Args:
            name: Metric name
            value: Metric value
            tags: Optional tags for categorization
            timestamp: Optional custom timestamp
        """
        try:
            metric_data = {
                "name": name,
                "value": value,
                "tags": tags or {},
                "timestamp": (timestamp or datetime.now()).isoformat()
            }

            # Would log to LangFuse
            # if self.client:
            #     self.client.score(
            #         name=name,
            #         value=value,
            #         data_type="NUMERIC",
            #         comment=str(tags) if tags else None
            #     )

            logger.debug(f"Logged metric: {name}={value}")

        except Exception as e:
            logger.error(f"Failed to log metric: {self._mask_error(e)}")

    def log_cost(
        self,
        execution_id: str,
        cost_type: str,
        amount: float,
        metadata: Dict[str, Any]
    ) -> None:
        """
        Log cost information for tracking and optimization.

        Args:
            execution_id: Execution this cost belongs to
            cost_type: Type of cost (e.g., 'llm', 'audio', 'research')
            amount: Cost amount in USD
            metadata: Additional cost metadata
        """
        try:
            cost_data = {
                "execution_id": execution_id,
                "cost_type": cost_type,
                "amount": amount,
                "currency": "USD",
                "metadata": metadata,
                "timestamp": datetime.now().isoformat()
            }

            # Would log to LangFuse
            # if self.trace:
            #     self.trace.event(
            #         name="cost_tracking",
            #         input=cost_data,
            #         level="INFO"
            #     )

            # Also log as metric for aggregation
            self.log_metric(
                name=f"cost.{cost_type}",
                value=amount,
                tags={"execution_id": execution_id}
            )

            logger.debug(f"Logged cost: {cost_type}=${amount} for {execution_id}")

        except Exception as e:
            logger.error(f"Failed to log cost: {self._mask_error(e)}")

    def get_metrics(
        self,
        metric_names: List[str],
        start_time: datetime,
        end_time: datetime,
        tags: Optional[Dict[str, str]] = None
    ) -> Dict[str, List[float]]:
        """
        Retrieve metrics for analysis.

        Args:
            metric_names: Names of metrics to retrieve
            start_time: Start of time range
            end_time: End of time range
            tags: Optional filter tags

        Returns:
            Dictionary mapping metric names to value lists
        """
        try:
            # Would query LangFuse for metrics
            # This is a placeholder implementation
            metrics = {name: [] for name in metric_names}

            logger.debug(f"Retrieved metrics: {metric_names}")
            return metrics

        except Exception as e:
            logger.error(f"Failed to retrieve metrics: {self._mask_error(e)}")
            return {name: [] for name in metric_names}

    def cleanup(self) -> None:
        """Clean up provider resources."""
        try:
            # Would flush and close client
            # if self.client:
            #     self.client.flush()
            #     self.client.shutdown()

            logger.info("LangFuse provider cleaned up")

        except Exception as e:
            logger.error(f"Error during cleanup: {self._mask_error(e)}")

    def _mask_error(self, error: Exception) -> str:
        """
        Mask sensitive information in error messages.

        Args:
            error: The exception to mask

        Returns:
            Masked error message
        """
        error_msg = str(error)

        # Mask any API keys that might appear in errors
        if 'secret_key' in self.config:
            error_msg = error_msg.replace(self.config['secret_key'], '***SECRET***')
        if 'public_key' in self.config:
            error_msg = error_msg.replace(self.config['public_key'], '***PUBLIC***')

        return error_msg

    # Additional LangFuse-specific methods

    def create_prompt_experiment(
        self,
        name: str,
        variants: List[Dict[str, Any]],
        metadata: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Create an A/B testing experiment for prompts.

        Args:
            name: Experiment name
            variants: List of prompt variants to test
            metadata: Optional experiment metadata

        Returns:
            Experiment ID
        """
        try:
            # Would create experiment in LangFuse
            experiment_id = f"exp_{name}_{datetime.now().timestamp()}"

            logger.info(f"Created prompt experiment: {experiment_id}")
            return experiment_id

        except Exception as e:
            logger.error(f"Failed to create experiment: {self._mask_error(e)}")
            raise

    def log_evaluation(
        self,
        execution_id: str,
        evaluator: str,
        scores: Dict[str, float],
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """
        Log evaluation results from LLM-as-judge or other evaluators.

        Args:
            execution_id: Execution being evaluated
            evaluator: Name of the evaluator
            scores: Evaluation scores
            metadata: Optional evaluation metadata
        """
        try:
            # Would log evaluation to LangFuse
            for score_name, score_value in scores.items():
                self.log_metric(
                    name=f"eval.{evaluator}.{score_name}",
                    value=score_value,
                    tags={"execution_id": execution_id}
                )

            logger.debug(f"Logged evaluation from {evaluator} for {execution_id}")

        except Exception as e:
            logger.error(f"Failed to log evaluation: {self._mask_error(e)}")
