"""
Observable Agent Example - Demonstrating LangFuse Integration Patterns
Shows best practices for agent-level observability in production systems
Updated for August 2025 LangFuse 3.x/4.x patterns
Version: 2.0.0
Date: August 2025
"""

import asyncio
import json
import os
from datetime import datetime
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
import logging

# LangFuse imports for agent-level observability (August 2025)
from langfuse import Langfuse
from langfuse.client import observe, start_as_current_span, get_client
from langfuse.langchain import CallbackHandler

# Core imports
from core.state import PodcastState
from core.observability import get_observability, PodcastObservability

logger = logging.getLogger(__name__)


class ObservableScriptWriterAgent:
    """
    Example of a production agent with comprehensive observability.
    
    This demonstrates the patterns for:
    - Agent-level tracing with @observe decorators
    - Cost tracking integration
    - Performance monitoring
    - Quality evaluation
    - Error tracking with context
    """
    
    def __init__(self, config: Dict[str, Any] = None):
        """Initialize agent with observability configuration."""
        self.config = config or {}
        self.observability = get_observability()
        
        # Agent metadata for tracing
        self.agent_metadata = {
            "agent_name": "script_writer",
            "agent_version": "2.0.0",
            "agent_type": "production",
            "capabilities": ["script_generation", "brand_alignment", "narrative_structure"]
        }
        
        # August 2025: Use singleton client pattern
        self.langfuse = None
        if self.observability.enabled:
            try:
                self.langfuse = get_client()
                if self.langfuse is None:
                    # Initialize if not already created
                    self.langfuse = Langfuse()
                logger.info("✅ Agent using LangFuse singleton client (August 2025)")
            except Exception as e:
                logger.warning(f"Failed to get LangFuse client: {e}")
    
    @observe(name="script_writer_execute", capture_input=True, capture_output=True)
    async def execute(self, state: PodcastState) -> PodcastState:
        """
        Execute script writing with comprehensive observability.
        
        This method demonstrates:
        - Automatic tracing with @observe decorator
        - Manual span creation for sub-operations
        - Cost tracking integration
        - Performance monitoring
        - Quality evaluation tracking
        """
        start_time = datetime.now()
        episode_id = state.get("episode_id")
        
        # August 2025: Use span metadata instead of langfuse_context
        span_metadata = {
            **self.agent_metadata,
            "episode_id": episode_id,
            "has_research": bool(state.get("research_synthesis")),
            "has_plan": bool(state.get("episode_plan")),
            "budget_remaining": state.get("budget_limit", 5.51) - state.get("total_cost", 0),
            "observation_type": "Agent"  # August 2025: Semantic labeling
        }
        
        try:
            # Phase 1: Content Analysis (with dedicated span)
            with self._create_span("content_analysis") as analysis_span:
                analysis_result = await self._analyze_content(state)
                
                if analysis_span and self.observability.enabled:
                    analysis_span.update(
                        output={
                            "key_themes": len(analysis_result.get("themes", [])),
                            "complexity_score": analysis_result.get("complexity_score", 0)
                        }
                    )
            
            # Phase 2: Script Generation (with cost tracking)
            with self._create_span("script_generation") as generation_span:
                # Generate script with LLM
                script_result = await self._generate_script(
                    analysis_result,
                    state.get("episode_plan", {})
                )
                
                # Track generation cost
                generation_cost = script_result.get("cost", 0)
                if self.observability.enabled and generation_cost > 0:
                    self.observability.track_cost(
                        "script_writer_generation",
                        generation_cost,
                        parent_observation_id=langfuse_context.get_current_observation_id()
                    )
                
                if generation_span and self.observability.enabled:
                    generation_span.update(
                        output={
                            "word_count": len(script_result.get("script", "").split()),
                            "cost_usd": generation_cost,
                            "model_used": script_result.get("model", "unknown")
                        }
                    )
            
            # Phase 3: Quality Evaluation
            with self._create_span("quality_evaluation") as eval_span:
                quality_scores = await self._evaluate_script_quality(
                    script_result.get("script", ""),
                    state
                )
                
                # Track quality metrics
                if self.observability.enabled:
                    self.observability.evaluate_quality(
                        episode_id=episode_id,
                        evaluation_type="script_quality",
                        scores=quality_scores,
                        metadata={
                            "agent": "script_writer",
                            "word_count": len(script_result.get("script", "").split())
                        }
                    )
                
                if eval_span and self.observability.enabled:
                    eval_span.update(output={"quality_scores": quality_scores})
            
            # Update state with results
            state["script_raw"] = script_result.get("script", "")
            state["script_metadata"] = {
                "generation_time": (datetime.now() - start_time).total_seconds(),
                "quality_scores": quality_scores,
                "cost": generation_cost,
                "model": script_result.get("model", "unknown")
            }
            
            # Track overall performance
            if self.observability.enabled:
                execution_time = (datetime.now() - start_time).total_seconds()
                self.observability.track_performance_metric(
                    "script_writer_execution_time",
                    execution_time,
                    metadata={
                        "episode_id": episode_id,
                        "script_length": len(state["script_raw"]),
                        "quality_score": quality_scores.get("overall", 0)
                    }
                )
                
                # August 2025: Track execution completion
                if hasattr(self, '_current_span') and self._current_span:
                    self._current_span.update(
                        output={
                            "success": True,
                            "execution_time": execution_time,
                            "script_length": len(state["script_raw"]),
                            "quality_scores": quality_scores
                        }
                    )
            
            return state
            
        except Exception as e:
            # Comprehensive error tracking
            error_context = {
                "agent": "script_writer",
                "episode_id": episode_id,
                "phase": "unknown",
                "has_research": bool(state.get("research_synthesis")),
                "has_plan": bool(state.get("episode_plan"))
            }
            
            if self.observability.enabled:
                self.observability.track_error(e, "script_generation_failed", state, error_context)
                
                # August 2025: Update span with error if available
                if hasattr(self, '_current_span') and self._current_span:
                    self._current_span.update(
                        output={
                            "success": False,
                            "error": str(e),
                            "error_type": type(e).__name__
                        },
                        level="ERROR"
                    )
                    if hasattr(self._current_span, 'set_status'):
                        self._current_span.set_status("error")
            
            logger.error(f"Script generation failed: {e}", exc_info=True)
            raise
    
    def _create_span(self, name: str):
        """Create a LangFuse span for sub-operations."""
        if self.observability.enabled and self.langfuse:
            return self.langfuse.span(
                name=f"script_writer_{name}",
                metadata=self.agent_metadata
            )
        return DummySpanContext()
    
    @observe(name="analyze_content", capture_input=False)  # Don't capture large inputs
    async def _analyze_content(self, state: PodcastState) -> Dict[str, Any]:
        """Analyze research content for script generation."""
        # Implementation would analyze themes, complexity, etc.
        return {
            "themes": ["theme1", "theme2", "theme3"],
            "complexity_score": 7.5,
            "key_insights": ["insight1", "insight2"],
            "narrative_structure": "problem_exploration_solution"
        }
    
    @observe(name="generate_script")
    async def _generate_script(
        self,
        analysis: Dict[str, Any],
        episode_plan: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Generate the actual script content."""
        # Implementation would call LLM for script generation
        # This is a mock implementation
        
        script = """
# Understanding Quantum Computing: Separating Reality from Hype

Welcome to another episode where we explore what we know, what we don't know, 
and what we think we know but might be wrong about. Today, we're diving into 
the fascinating and often misunderstood world of quantum computing.

## The Mystery at the Heart of Computing

You've probably heard the buzz about quantum computers being millions of times 
faster than regular computers, or that they'll break all encryption, or even 
that they'll solve climate change. But here's what's fascinating: even the 
experts building these machines don't fully understand why they work the way 
they do...
        """.strip()
        
        return {
            "script": script,
            "cost": 0.0234,  # Mock cost
            "model": "gpt-4-turbo",
            "tokens_used": {"input": 1500, "output": 800}
        }
    
    @observe(name="evaluate_script_quality")
    async def _evaluate_script_quality(
        self,
        script: str,
        state: PodcastState
    ) -> Dict[str, float]:
        """Evaluate script quality across multiple dimensions."""
        # Mock quality evaluation
        # Real implementation would use LLM-based evaluation
        
        quality_scores = {
            "overall": 8.5,
            "brand_alignment": 9.0,
            "intellectual_humility": 8.8,
            "narrative_flow": 8.2,
            "technical_accuracy": 8.3,
            "engagement_potential": 8.6
        }
        
        # August 2025: Track individual quality dimensions using score_trace
        if self.observability.enabled and self.langfuse:
            episode_id = state.get("episode_id")
            for dimension, score in quality_scores.items():
                self.langfuse.score_trace(
                    trace_id=episode_id,
                    score=score,
                    metric=f"script_{dimension}",
                    comment=f"Script quality - {dimension}"
                )
        
        return quality_scores


class DummySpanContext:
    """Dummy context manager for when observability is disabled."""
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        return False
    
    def update(self, **kwargs):
        pass


# Usage example showing integration with LangGraph workflow
async def example_usage():
    """Example of how to use the observable agent in a workflow."""
    
    # Initialize agent
    agent = ObservableScriptWriterAgent({
        "model": "gpt-4-turbo",
        "temperature": 0.7,
        "max_retries": 3
    })
    
    # Create mock state
    state = {
        "episode_id": "ep_20250114_example",
        "topic": "Quantum Computing Myths",
        "research_synthesis": {"content": "Research data here..."},
        "episode_plan": {"structure": "intro_main_conclusion"},
        "budget_limit": 5.51,
        "total_cost": 2.34
    }
    
    # Execute with full observability
    result = await agent.execute(state)
    
    print(f"Script generated: {len(result['script_raw'])} characters")
    print(f"Quality scores: {result['script_metadata']['quality_scores']}")


# August 2025 Best Practices Summary:
# 1. Use @observe decorator for automatic tracing of methods
# 2. Use singleton client pattern with get_client()
# 3. No constructor args for CallbackHandler
# 4. Semantic observation types (Agent, Tool, Chain, etc.)
# 5. Use score_trace() API for quality evaluations
# 6. Configure callbacks at graph compile time with .with_config()
# 7. Track costs at the point of incurrence
# 8. Comprehensive error tracking with set_status("error")
# 9. Don't capture large inputs/outputs unless necessary
# 10. Use metadata for agent context and observation types
# 11. Flush observations when needed for real-time monitoring
