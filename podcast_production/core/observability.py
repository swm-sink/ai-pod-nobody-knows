"""
LangFuse observability integration for podcast production workflow.

This module provides comprehensive tracing, monitoring, and evaluation
capabilities for the LangGraph-based podcast production system.

Updated for LangFuse 3.x/4.x patterns and best practices.

Version: 2.0.0
Date: August 2025
"""

import os
import logging
from typing import Dict, Any, Optional, List, Callable, Union, Literal
from datetime import datetime
from functools import wraps
import asyncio
import json
from pathlib import Path

# LangFuse imports - August 2025 patterns
try:
    from langfuse import Langfuse
    from langfuse.langchain import CallbackHandler  # Updated import path
    from langfuse.client import (
        observe, 
        start_as_current_span,
        get_client  # Singleton pattern
    )
    LANGFUSE_AVAILABLE = True
except ImportError:
    LANGFUSE_AVAILABLE = False
    logging.warning("LangFuse not available - observability features disabled")
    
    # Mock decorators for development without LangFuse
    def observe(name=None, **kwargs):
        def decorator(func):
            return func
        return decorator
    
    def start_as_current_span(name=None):
        def decorator(func):
            return func
        return decorator
    
    class CallbackHandler:
        def __init__(self, *args, **kwargs):
            pass
    
    def get_client():
        return None

# Type hints
from core.state import PodcastState

logger = logging.getLogger(__name__)


class PodcastObservability:
    """
    Central observability manager for podcast production workflow.
    
    Updated for August 2025 LangFuse 3.x/4.x patterns:
    - Uses singleton client pattern
    - New observation types (Agent, Tool, Chain, etc.)
    - OpenTelemetry backend support
    - Enhanced agent execution visualization
    
    Provides:
    - Workflow-level tracing
    - Agent execution monitoring with semantic labeling
    - Cost tracking integration
    - Quality evaluation tracking
    - Performance metrics
    - Error and debugging support
    """
    
    # August 2025: New observation type literals
    ObservationType = Literal["Agent", "Tool", "Chain", "Retriever", "Embedding", "Guardrail", "General"]
    
    def __init__(self, config: Dict[str, Any] = None):
        """
        Initialize observability with LangFuse configuration.
        
        Uses singleton pattern as per August 2025 best practices.
        
        Args:
            config: Optional configuration overrides
        """
        self.config = config or {}
        self.enabled = LANGFUSE_AVAILABLE and self._should_enable_observability()
        
        if self.enabled:
            try:
                # August 2025: Use singleton client pattern
                self.langfuse = get_client()
                
                if self.langfuse is None:
                    # Initialize if not already created
                    from langfuse import Langfuse as LangfuseClient
                    self.langfuse = LangfuseClient(
                        public_key=os.getenv("LANGFUSE_PUBLIC_KEY", self.config.get("public_key")),
                        secret_key=os.getenv("LANGFUSE_SECRET_KEY", self.config.get("secret_key")),
                        host=os.getenv("LANGFUSE_HOST", self.config.get("host", "https://cloud.langfuse.com")),
                        enabled=True,
                        # August 2025: Updated config parameters
                        flush_at=self.config.get("flush_at", 20),  # Increased for better batching
                        flush_interval=self.config.get("flush_interval", 2),
                        max_retries=self.config.get("max_retries", 3),
                        timeout=self.config.get("timeout", 10),
                    )
                
                # August 2025: Create default callback handler (no constructor args)
                self.callback_handler = CallbackHandler()
                
                logger.info("✅ LangFuse observability initialized (August 2025 patterns)")
                logger.info("   Using singleton client pattern")
                logger.info("   CallbackHandler created without constructor args")
                
                # Initialize evaluation templates
                self._initialize_evaluation_templates()
                
            except Exception as e:
                logger.error(f"Failed to initialize LangFuse: {e}")
                self.enabled = False
                self.langfuse = None
                self.callback_handler = None
        else:
            self.langfuse = None
            self.callback_handler = None
            logger.info("ℹ️ LangFuse observability disabled")
    
    def _should_enable_observability(self) -> bool:
        """Check if observability should be enabled based on environment."""
        # Check for explicit disable flag
        if os.getenv("DISABLE_LANGFUSE", "false").lower() == "true":
            return False
        
        # Check for required credentials
        has_credentials = (
            os.getenv("LANGFUSE_PUBLIC_KEY") or self.config.get("public_key")
        ) and (
            os.getenv("LANGFUSE_SECRET_KEY") or self.config.get("secret_key")
        )
        
        return has_credentials
    
    def _initialize_evaluation_templates(self):
        """Initialize evaluation templates for quality assessment."""
        if not self.enabled:
            return
        
        try:
            # Define evaluation templates for different quality aspects
            self.evaluation_templates = {
                "brand_alignment": {
                    "name": "brand_alignment_eval",
                    "description": "Evaluates podcast content for brand alignment and intellectual humility",
                    "scoring_criteria": {
                        "intellectual_humility": "Score 0-10 for acknowledging uncertainty and limitations",
                        "question_ratio": "Score based on question-to-answer ratio (target 60:40)",
                        "expert_diversity": "Score based on diverse expert perspectives included",
                        "uncertainty_acknowledgment": "Score for explicitly stating what we don't know"
                    }
                },
                "technical_accuracy": {
                    "name": "technical_accuracy_eval",
                    "description": "Evaluates technical accuracy and fact-checking",
                    "scoring_criteria": {
                        "fact_accuracy": "Score 0-10 for factual correctness",
                        "source_quality": "Score based on quality and credibility of sources",
                        "citation_completeness": "Score for proper attribution and citations",
                        "uncertainty_quantification": "Score for quantifying uncertainty levels"
                    }
                },
                "engagement_quality": {
                    "name": "engagement_quality_eval",
                    "description": "Evaluates audience engagement and narrative quality",
                    "scoring_criteria": {
                        "narrative_flow": "Score 0-10 for story structure and flow",
                        "clarity": "Score for explanation clarity and accessibility",
                        "curiosity_generation": "Score for sparking curiosity and wonder",
                        "learning_value": "Score for educational content value"
                    }
                },
                "audio_quality": {
                    "name": "audio_quality_eval",
                    "description": "Evaluates audio synthesis quality",
                    "scoring_criteria": {
                        "voice_consistency": "Score 0-10 for voice consistency",
                        "pacing": "Score for natural conversational pacing",
                        "pronunciation": "Score for correct pronunciation",
                        "emotional_range": "Score for appropriate emotional expression"
                    }
                }
            }
            
            logger.info(f"Initialized {len(self.evaluation_templates)} evaluation templates")
            
        except Exception as e:
            logger.warning(f"Failed to initialize evaluation templates: {e}")
    
    # Workflow-level tracing
    def trace_workflow(self, episode_id: str, topic: str, metadata: Dict[str, Any] = None):
        """
        Create a new workflow trace for an episode production.
        
        Updated for August 2025: Uses new trace API patterns.
        
        Args:
            episode_id: Unique episode identifier
            topic: Episode topic
            metadata: Additional workflow metadata
            
        Returns:
            Trace context manager
        """
        if not self.enabled:
            return DummyTraceContext()
        
        trace_metadata = {
            "episode_id": episode_id,
            "topic": topic,
            "workflow_version": "2.0.0",
            "langgraph_enabled": True,
            "observation_types_enabled": True,  # August 2025 feature
            "timestamp": datetime.now().isoformat(),
            "environment": os.getenv("ENVIRONMENT", "production"),
            **(metadata or {})
        }
        
        # August 2025: Create trace with updated API
        trace = self.langfuse.trace(
            name=f"podcast_production_{episode_id}",
            # August 2025: user_id now set via update_trace
            session_id=f"session_{datetime.now().strftime('%Y%m%d')}",
            metadata=trace_metadata,
            tags=["podcast", "production", "langgraph", "august-2025"],
            public=False  # Keep traces private by default
        )
        
        # August 2025: Set user_id via update method
        if hasattr(trace, 'update_trace'):
            trace.update_trace(user_id="podcast_system")
        
        return WorkflowTraceContext(trace, self)
    
    # Agent execution monitoring
    def observe_agent(self, agent_name: str, observation_type: ObservationType = "Agent"):
        """
        Decorator to observe agent execution with semantic labeling.
        
        Updated for August 2025: Uses new observation types for better visualization.
        
        Args:
            agent_name: Name of the agent
            observation_type: Semantic type (Agent, Tool, Chain, etc.)
        """
        def decorator(func):
            if not self.enabled:
                return func
            
            # August 2025: Use start_as_current_span for manual span control
            @wraps(func)
            async def async_wrapper(state: PodcastState, *args, **kwargs):
                # Create span with semantic observation type
                span_metadata = {
                    "agent_name": agent_name,
                    "observation_type": observation_type,  # August 2025: Semantic labeling
                    "stage": state.get("current_stage", "unknown"),
                    "episode_id": state.get("episode_id"),
                    "budget_remaining": state.get("budget_limit", 5.51) - state.get("total_cost", 0),
                    "timestamp": datetime.now().isoformat()
                }
                
                # August 2025: Updated span creation pattern
                with self.langfuse.span(
                    name=f"{observation_type.lower()}_{agent_name}",
                    metadata=span_metadata,
                    level="DEFAULT",
                    input={"topic": state.get("topic"), "stage": state.get("current_stage")},
                    # August 2025: Add observation type tag
                    tags=[observation_type, agent_name]
                ) as span:
                    try:
                        # Track start time for performance metrics
                        start_time = datetime.now()
                        
                        # Execute agent
                        result = await func(state, *args, **kwargs)
                        
                        # Calculate execution time
                        execution_time = (datetime.now() - start_time).total_seconds()
                        
                        # Track success metrics
                        span.update(
                            output={
                                "success": True,
                                "execution_time": execution_time,
                                "cost_incurred": result.get("total_cost", 0) - state.get("total_cost", 0)
                            },
                            level="DEFAULT" if execution_time < 30 else "WARNING"
                        )
                        
                        # August 2025: Enhanced performance tracking
                        if execution_time > 10:
                            span.event(
                                name="performance_warning",
                                metadata={
                                    "execution_time": execution_time,
                                    "threshold": 10,
                                    "agent": agent_name
                                }
                            )
                        
                        # Track cost if changed
                        new_cost = result.get("total_cost", 0) - state.get("total_cost", 0)
                        if new_cost > 0:
                            self.track_cost(agent_name, new_cost, getattr(span, 'id', None))
                        
                        return result
                        
                    except Exception as e:
                        # Track failure with detailed context
                        span.update(
                            output={
                                "success": False, 
                                "error": str(e),
                                "error_type": type(e).__name__,
                                "traceback": str(e.__traceback__) if hasattr(e, '__traceback__') else None
                            },
                            level="ERROR"
                        )
                        
                        # August 2025: Auto-set error status
                        if hasattr(span, 'set_status'):
                            span.set_status("error")
                        
                        raise
            
            @wraps(func)
            def sync_wrapper(state: PodcastState, *args, **kwargs):
                # Similar implementation for sync functions
                return asyncio.run(async_wrapper(state, *args, **kwargs))
            
            return async_wrapper if asyncio.iscoroutinefunction(func) else sync_wrapper
        
        return decorator
    
    # Cost tracking integration
    def track_cost(self, component: str, cost: float, parent_observation_id: Optional[str] = None):
        """
        Track cost for a specific component with LangFuse event.
        
        Args:
            component: Component that incurred the cost
            cost: Cost amount in dollars
            parent_observation_id: Parent observation to attach to
        """
        if not self.enabled:
            return
        
        try:
            event_data = {
                "component": component,
                "cost_usd": cost,
                "timestamp": datetime.now().isoformat()
            }
            
            if parent_observation_id:
                self.langfuse.event(
                    name="cost_incurred",
                    metadata=event_data,
                    parent_observation_id=parent_observation_id,
                    level="DEFAULT"
                )
            else:
                # Standalone cost event
                self.langfuse.event(
                    name="cost_incurred",
                    metadata=event_data,
                    level="DEFAULT"
                )
            
        except Exception as e:
            logger.warning(f"Failed to track cost in LangFuse: {e}")
    
    # Quality evaluation tracking
    def evaluate_quality(
        self,
        episode_id: str,
        evaluation_type: str,
        scores: Dict[str, float],
        metadata: Dict[str, Any] = None,
        trace_id: Optional[str] = None
    ):
        """
        Track quality evaluation results using August 2025 score_trace API.
        
        Args:
            episode_id: Episode being evaluated
            evaluation_type: Type of evaluation (brand_alignment, technical_accuracy, etc.)
            scores: Dictionary of scores
            metadata: Additional evaluation metadata
            trace_id: Optional trace ID (defaults to episode_id)
        """
        if not self.enabled:
            return
        
        try:
            # Get evaluation template
            template = self.evaluation_templates.get(evaluation_type, {})
            
            # Create evaluation score
            overall_score = sum(scores.values()) / len(scores) if scores else 0
            
            # August 2025: Use score_trace API
            self.langfuse.score_trace(
                trace_id=trace_id or episode_id,
                score=overall_score,
                metric=evaluation_type,
                comment=f"Automated {evaluation_type} evaluation",
                # August 2025: Additional context in metadata
                metadata={
                    "detailed_scores": scores,
                    "criteria": template.get("scoring_criteria", {}),
                    "evaluation_timestamp": datetime.now().isoformat(),
                    "evaluator": "automated_system",
                    **(metadata or {})
                }
            )
            
            # Log individual criteria scores
            for criterion, score_value in scores.items():
                self.langfuse.score_trace(
                    trace_id=trace_id or episode_id,
                    score=score_value,
                    metric=f"{evaluation_type}_{criterion}",
                    comment=f"Score for {criterion}"
                )
            
            # August 2025: Track evaluation as an event for better visibility
            if hasattr(self.langfuse, 'event'):
                self.langfuse.event(
                    name="quality_evaluation_completed",
                    metadata={
                        "episode_id": episode_id,
                        "evaluation_type": evaluation_type,
                        "overall_score": overall_score,
                        "score_count": len(scores),
                        "timestamp": datetime.now().isoformat()
                    }
                )
            
        except Exception as e:
            logger.warning(f"Failed to track quality evaluation: {e}")
    
    # Error and debugging support
    def track_error(
        self,
        error: Exception,
        context: str,
        state: Optional[PodcastState] = None,
        metadata: Dict[str, Any] = None
    ):
        """
        Track errors with full context for debugging.
        
        Args:
            error: Exception that occurred
            context: Context where error occurred
            state: Current workflow state
            metadata: Additional error metadata
        """
        if not self.enabled:
            return
        
        try:
            error_data = {
                "error_type": type(error).__name__,
                "error_message": str(error),
                "context": context,
                "timestamp": datetime.now().isoformat(),
                **(metadata or {})
            }
            
            if state:
                error_data.update({
                    "episode_id": state.get("episode_id"),
                    "current_stage": state.get("current_stage"),
                    "total_cost": state.get("total_cost", 0),
                    "errors_count": len(state.get("errors", []))
                })
            
            self.langfuse.event(
                name="error_occurred",
                metadata=error_data,
                level="ERROR"
            )
            
        except Exception as e:
            logger.warning(f"Failed to track error in LangFuse: {e}")
    
    # Performance monitoring
    def track_performance_metric(
        self,
        metric_name: str,
        value: float,
        unit: str = "seconds",
        metadata: Dict[str, Any] = None
    ):
        """
        Track performance metrics.
        
        Args:
            metric_name: Name of the metric
            value: Metric value
            unit: Unit of measurement
            metadata: Additional metric metadata
        """
        if not self.enabled:
            return
        
        try:
            self.langfuse.event(
                name="performance_metric",
                metadata={
                    "metric": metric_name,
                    "value": value,
                    "unit": unit,
                    "timestamp": datetime.now().isoformat(),
                    **(metadata or {})
                },
                level="DEFAULT"
            )
            
        except Exception as e:
            logger.warning(f"Failed to track performance metric: {e}")
    
    # Batch operations support
    def flush(self):
        """Force flush all pending observations to LangFuse."""
        if self.enabled and self.langfuse:
            try:
                self.langfuse.flush()
                logger.debug("Flushed observations to LangFuse")
            except Exception as e:
                logger.warning(f"Failed to flush to LangFuse: {e}")
    
    def shutdown(self):
        """Gracefully shutdown observability and flush remaining data."""
        if self.enabled and self.langfuse:
            try:
                self.langfuse.flush()
                # Note: LangFuse client doesn't have explicit shutdown in v2
                logger.info("LangFuse observability shutdown complete")
            except Exception as e:
                logger.warning(f"Error during LangFuse shutdown: {e}")


class WorkflowTraceContext:
    """Context manager for workflow-level tracing."""
    
    def __init__(self, trace, observability: PodcastObservability):
        self.trace = trace
        self.observability = observability
        self.start_time = datetime.now()
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        # Calculate total duration
        duration = (datetime.now() - self.start_time).total_seconds()
        
        # Update trace with final metadata
        if self.trace:
            self.trace.update(
                output={
                    "duration_seconds": duration,
                    "success": exc_type is None,
                    "error": str(exc_val) if exc_val else None
                }
            )
        
        # Ensure data is sent
        self.observability.flush()
        
        return False  # Don't suppress exceptions
    
    async def __aenter__(self):
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        return self.__exit__(exc_type, exc_val, exc_tb)


class DummyTraceContext:
    """Dummy context for when LangFuse is disabled."""
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        return False
    
    async def __aenter__(self):
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        return False


# Global singleton instance
_observability_instance: Optional[PodcastObservability] = None


def get_observability(config: Dict[str, Any] = None) -> PodcastObservability:
    """
    Get or create the global observability instance.
    
    Args:
        config: Optional configuration for initialization
        
    Returns:
        PodcastObservability singleton instance
    """
    global _observability_instance
    
    if _observability_instance is None:
        _observability_instance = PodcastObservability(config)
    
    return _observability_instance


# Convenience decorators - August 2025 patterns
def observe_agent(agent_name: str, observation_type: PodcastObservability.ObservationType = "Agent"):
    """
    Convenience decorator for agent observation with semantic labeling.
    
    Args:
        agent_name: Name of the agent
        observation_type: Semantic type (Agent, Tool, Chain, etc.)
    """
    obs = get_observability()
    return obs.observe_agent(agent_name, observation_type)


def track_workflow_metric(metric_name: str, value: float, unit: str = "seconds", metadata: Dict[str, Any] = None):
    """Convenience function for tracking metrics."""
    obs = get_observability()
    obs.track_performance_metric(metric_name, value, unit, metadata)


# Export key components
__all__ = [
    "PodcastObservability",
    "get_observability",
    "observe_agent",
    "track_workflow_metric",
    "WorkflowTraceContext",
]
