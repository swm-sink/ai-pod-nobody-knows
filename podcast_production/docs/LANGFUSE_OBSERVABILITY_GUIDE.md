# LangFuse Observability Integration Guide

## Overview

This guide covers the comprehensive LangFuse observability integration for the AI Podcast Production system. The integration provides end-to-end tracing, cost tracking, quality evaluation, and performance monitoring for the entire LangGraph workflow.

**Version:** 3.0.0  
**Date:** August 2025  
**Integration Pattern:** LangGraph + LangFuse 3.x/4.x with Semantic Observation Types

## Key Changes in August 2025

1. **Singleton Client Pattern**: Use `get_client()` instead of multiple instances
2. **No Constructor Args**: `CallbackHandler()` created without arguments
3. **Semantic Observation Types**: Agent, Tool, Chain, Retriever, Embedding, Guardrail
4. **Compile-time Callbacks**: Configure with `.with_config()` at graph compilation
5. **New score_trace() API**: Updated quality evaluation methods
6. **Removed RunnablePassthrough**: No longer needed for metadata propagation

## Table of Contents

1. [Setup and Configuration](#setup-and-configuration)
2. [Architecture Overview](#architecture-overview)
3. [Workflow-Level Observability](#workflow-level-observability)
4. [Agent-Level Observability](#agent-level-observability)
5. [Cost Tracking](#cost-tracking)
6. [Quality Evaluation](#quality-evaluation)
7. [Performance Monitoring](#performance-monitoring)
8. [Dashboard Usage](#dashboard-usage)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Setup and Configuration

### 1. Environment Variables

Set up the following environment variables for LangFuse:

```bash
# Required for LangFuse connection
export LANGFUSE_PUBLIC_KEY="your-public-key"
export LANGFUSE_SECRET_KEY="your-secret-key"
export LANGFUSE_HOST="https://cloud.langfuse.com"  # or your self-hosted URL

# Optional configuration
export ENVIRONMENT="production"  # or "development", "staging"
export DEPLOYMENT_VERSION="2.0.0"
export DISABLE_LANGFUSE="false"  # Set to "true" to disable observability
```

### 2. Installation

Ensure LangFuse is installed with the required dependencies:

```bash
pip install langfuse>=2.0.0
pip install langchain-core  # For RunnablePassthrough
```

### 3. Configuration in Code

Initialize observability in your workflow using August 2025 patterns:

```python
from podcast_production.core.observability import get_observability
from langfuse.client import get_client
from langfuse.langchain import CallbackHandler

# Initialize with custom config
observability_config = {
    "flush_at": 20,  # Increased batch size for better performance
    "flush_interval": 2,  # Seconds between flushes
    "max_retries": 3,
    "timeout": 10
}

# Get singleton observability instance
observability = get_observability(observability_config)

# August 2025: Create callback handler without constructor args
langfuse_handler = CallbackHandler()

# August 2025: Get singleton client if needed
langfuse_client = get_client()
```

## Architecture Overview

The observability system integrates at three levels:

### 1. **Workflow Level** (main_workflow.py)
- Creates root traces for entire episode production
- Tracks workflow state transitions
- Monitors checkpointing and resumption
- Aggregates costs and quality metrics

### 2. **Agent Level** (individual agents)
- Uses @observe decorators for automatic tracing
- Creates spans for sub-operations
- Tracks agent-specific metrics
- Reports costs at point of incurrence

### 3. **Core Level** (observability.py)
- Provides centralized observability management
- Handles LangFuse client lifecycle
- Offers convenience methods for common patterns
- Manages evaluation templates

## Workflow-Level Observability

### Trace Structure

Each podcast episode creates a hierarchical trace:

```
podcast_workflow_ep_20250114_123456
├── workflow_started
├── agent_research_discovery
│   ├── content_analysis
│   ├── research_execution
│   └── cost_incurred ($0.45)
├── agent_script_writer
│   ├── script_generation
│   ├── quality_evaluation
│   └── cost_incurred ($1.75)
├── checkpoint_saved
├── workflow_completed
└── quality_scores
```

### Implementation Example (August 2025)

```python
# In main_workflow.py
class PodcastWorkflow:
    def __init__(self):
        # August 2025: Initialize with singleton pattern
        self.observability = get_observability()
        self.langfuse_handler = CallbackHandler()  # No constructor args
        
    def _build_graph(self):
        # Build your graph
        workflow = StateGraph(PodcastState)
        # ... add nodes and edges ...
        
        # August 2025: Compile with callbacks attached
        compiled_graph = workflow.compile(checkpointer=self.checkpointer)
        
        if self.langfuse_handler:
            compiled_graph = compiled_graph.with_config({
                "callbacks": [self.langfuse_handler]
            })
            
        return compiled_graph
        
    async def execute(self, initial_state: PodcastState) -> PodcastState:
        # Create workflow trace
        workflow_trace = self.observability.trace_workflow(
            episode_id=episode_id,
            topic=topic,
            metadata={
                "budget_limit": initial_state.get('budget_limit', 5.51),
                "environment": os.getenv("ENVIRONMENT", "production"),
                "observation_types_enabled": True  # August 2025 feature
            }
        )
        
        # August 2025: Simplified execution - callbacks already configured
        config = {
            "configurable": {"thread_id": episode_id},
            "metadata": {"episode_id": episode_id}
        }
        
        # Execute graph - no RunnablePassthrough needed
        final_state = await self.graph.ainvoke(initial_state, config)
```

## Agent-Level Observability

### Using @observe Decorator (August 2025)

The `@observe` decorator automatically traces agent methods with semantic labeling:

```python
from langfuse.client import observe, start_as_current_span
from core.observability import observe_agent, PodcastObservability

class ResearchAgent:
    # August 2025: Use semantic observation types
    @observe_agent("research_discovery", "Agent")
    async def execute(self, state: PodcastState) -> PodcastState:
        # Metadata is now passed via decorator configuration
        # No need for langfuse_context updates
        
        # Execute agent logic
        result = await self._perform_research(state)
        
        # Span updates handled automatically by decorator
        return result
    
    # For custom sub-operations
    @observe(name="fetch_sources")
    async def _fetch_sources(self, query: str):
        # Automatic tracing of sub-operations
        sources = await self._search_api(query)
        return sources
```

### Using Semantic Observation Types

August 2025 introduces semantic labeling for better visualization:

```python
# Available observation types
ObservationType = Literal["Agent", "Tool", "Chain", "Retriever", "Embedding", "Guardrail"]

# Examples
@observe_agent("script_writer", "Agent")
@observe_agent("web_search", "Tool")
@observe_agent("validation_chain", "Chain")
@observe_agent("vector_search", "Retriever")
```

### Creating Manual Spans

For detailed sub-operation tracking:

```python
def _create_span(self, name: str):
    if self.observability.enabled:
        return self.langfuse.span(
            name=f"{self.agent_name}_{name}",
            metadata=self.agent_metadata
        )
    return DummySpanContext()

async def complex_operation(self, data):
    with self._create_span("preprocessing") as span:
        processed = await self._preprocess(data)
        span.update(output={"items_processed": len(processed)})
    
    with self._create_span("main_processing") as span:
        result = await self._process(processed)
        span.update(output={"success": True, "result_size": len(result)})
    
    return result
```

## Cost Tracking

### Tracking Costs at Point of Incurrence

```python
# In agent implementation
generation_cost = calculate_llm_cost(tokens_used, model)
if self.observability.enabled:
    self.observability.track_cost(
        component="script_writer",
        cost=generation_cost,
        parent_observation_id=langfuse_context.get_current_observation_id()
    )
```

### Aggregating Workflow Costs

```python
# In workflow completion
cost_breakdown = self.cost_tracker.get_cost_breakdown()

# Track total and by component
self.observability.track_cost("workflow_total", cost_breakdown['total_cost'])
for component, cost in cost_breakdown.get('by_agent', {}).items():
    self.observability.track_cost(component, cost)
```

## Quality Evaluation

### Defining Evaluation Templates

The system includes predefined evaluation templates:

```python
evaluation_templates = {
    "brand_alignment": {
        "intellectual_humility": "Score 0-10",
        "question_ratio": "Questions vs answers ratio",
        "expert_diversity": "Variety of perspectives",
        "uncertainty_acknowledgment": "Explicit unknowns"
    },
    "technical_accuracy": {
        "fact_accuracy": "Correctness of facts",
        "source_quality": "Credibility of sources",
        "citation_completeness": "Proper attribution"
    }
}
```

### Tracking Quality Scores (August 2025)

```python
# After script generation
quality_scores = {
    "overall": 8.5,
    "brand_alignment": 9.0,
    "intellectual_humility": 8.8,
    "narrative_flow": 8.2
}

# August 2025: Updated evaluate_quality with trace_id parameter
self.observability.evaluate_quality(
    episode_id=episode_id,
    evaluation_type="script_quality",
    scores=quality_scores,
    metadata={
        "evaluator": "gpt-4-turbo",
        "word_count": len(script.split())
    },
    trace_id=trace_id  # Links to the workflow trace
)

# Alternative: Direct score_trace API usage
langfuse_client.score_trace(
    trace_id=trace_id,
    score=8.5,
    metric="script_quality",
    comment="Automated evaluation",
    metadata={"detailed_scores": quality_scores}
)
```

## Performance Monitoring

### Tracking Execution Times

```python
start_time = datetime.now()

# ... execute operation ...

execution_time = (datetime.now() - start_time).total_seconds()
self.observability.track_performance_metric(
    metric_name="agent_execution_time",
    value=execution_time,
    unit="seconds",
    metadata={
        "agent": "script_writer",
        "episode_id": episode_id
    }
)
```

### Setting Performance Alerts

In LangFuse dashboard, configure alerts for:
- Agent execution time > 30 seconds
- Workflow duration > 35 minutes
- Cost per episode > $5.51
- Quality scores < 8.0

## Dashboard Usage

### Key Views

1. **Traces View**
   - Filter by `episode_id` to see complete workflow
   - Use Agent Graph view for visual workflow representation
   - Check state transitions and conditional routing

2. **Sessions View**
   - Group episodes by production date
   - Compare costs across episodes
   - Track quality trends

3. **Metrics View**
   - Monitor average execution times
   - Track cost per component
   - Analyze quality score distributions

4. **Evaluations View**
   - Review automated quality assessments
   - Compare evaluator agreement
   - Identify quality improvement areas

### Useful Filters

```
# Find expensive episodes
metadata.total_cost > 5.0

# Find low quality episodes
scores.overall < 8.0

# Find failed workflows
output.success = false

# Find specific agent executions
name = "agent_script_writer"
```

## Best Practices (August 2025)

### 1. Singleton Client Pattern

Always use the singleton pattern:
```python
# Correct
from langfuse.client import get_client
langfuse = get_client()

# Incorrect (deprecated)
langfuse = Langfuse()  # Multiple instances
```

### 2. CallbackHandler Without Args

```python
# Correct (August 2025)
handler = CallbackHandler()

# Incorrect (deprecated)
handler = CallbackHandler(
    root=trace,
    sample_rate=0.5  # Constructor args no longer supported
)
```

### 3. Metadata Strategy

Include observation types and essential context:
```python
metadata = {
    "episode_id": episode_id,
    "agent_name": agent_name,
    "workflow_version": "3.0.0",
    "environment": os.getenv("ENVIRONMENT"),
    "budget_remaining": budget_limit - current_cost,
    "observation_type": "Agent"  # August 2025: Semantic labeling
}
```

### 4. Error Tracking

Comprehensive error context with status updates:
```python
try:
    result = await operation()
except Exception as e:
    # Update span status (August 2025)
    if span:
        span.set_status("error")
    
    self.observability.track_error(
        error=e,
        context="operation_name",
        state=current_state,
        metadata={
            "retry_count": retry_count,
            "fallback_available": has_fallback
        }
    )
    raise
```

### 5. Cost Control

Check budget before expensive operations:
```python
if self.observability.enabled:
    remaining_budget = state.get("budget_limit") - state.get("total_cost")
    if remaining_budget < expected_cost:
        self.observability.langfuse.event(
            name="budget_warning",
            metadata={
                "remaining": remaining_budget,
                "required": expected_cost
            }
        )
```

### 6. Batch Operations

Flush observations for real-time monitoring:
```python
# After critical operations
if self.observability.enabled:
    self.observability.flush()
```

### 7. Compile-Time Callback Configuration

August 2025 best practice - configure at compile time:
```python
# Correct - attach callbacks when compiling graph
graph = workflow.compile(checkpointer=checkpointer)
if langfuse_handler:
    graph = graph.with_config({"callbacks": [langfuse_handler]})

# Incorrect - adding callbacks per invocation
await graph.ainvoke(state, {"callbacks": [handler]})  # Deprecated pattern
```

## Troubleshooting

### Common Issues (August 2025)

1. **CallbackHandler Constructor Error**
   - Problem: `TypeError: CallbackHandler() takes no arguments`
   - Solution: Remove all constructor arguments
   ```python
   # Correct
   handler = CallbackHandler()
   
   # Incorrect (old pattern)
   handler = CallbackHandler(root=trace, user_id="123")
   ```

2. **Observations Not Appearing**
   - Check environment variables are set
   - Verify `flush()` is called
   - Check network connectivity to LangFuse

3. **High Latency**
   - Adjust flush settings:
   ```python
   config = {
       "flush_at": 20,  # Increase batch size
       "flush_interval": 5  # Reduce frequency
   }
   ```

4. **Cost Tracking Mismatch**
   - Ensure costs are tracked at point of incurrence
   - Verify all agents report costs
   - Check cost aggregation logic

### Debug Mode

Enable detailed logging:
```python
import logging
logging.getLogger("langfuse").setLevel(logging.DEBUG)
```

### Health Check

Verify observability is working:
```python
# In health check endpoint
def check_observability_health():
    obs = get_observability()
    return {
        "enabled": obs.enabled,
        "langfuse_connected": obs.langfuse is not None,
        "environment": os.getenv("ENVIRONMENT"),
        "version": "2.0.0"
    }
```

## Conclusion

The August 2025 LangFuse integration provides enhanced observability for the AI Podcast Production system with:

### Key Benefits
- **Complete Workflow Visibility**: Track every step with semantic observation types
- **Enhanced Agent Visualization**: New Agent Graph views for multi-agent workflows
- **Simplified Integration**: Singleton pattern and compile-time callback configuration
- **Cost Control**: Monitor and enforce budget limits in real-time
- **Quality Assurance**: Automated evaluation with score_trace API
- **Performance Optimization**: Identify bottlenecks with semantic labeling
- **Debugging Support**: Detailed traces with observation type filtering

### Migration Summary (January → August 2025)
1. Replace multiple client instances with `get_client()` singleton
2. Remove CallbackHandler constructor arguments
3. Configure callbacks at graph compile time with `.with_config()`
4. Use semantic observation types (Agent, Tool, Chain, etc.)
5. Update to `score_trace()` API for evaluations
6. Remove RunnablePassthrough pattern (no longer needed)

For additional support, consult the LangFuse documentation at https://langfuse.com/docs or the project maintainers.

**Last Updated**: August 2025  
**LangFuse Version**: 3.x/4.x  
**LangGraph Compatibility**: Full support with enhanced features
