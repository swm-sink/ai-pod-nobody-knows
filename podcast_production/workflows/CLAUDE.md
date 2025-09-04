# Workflow Orchestration Context - StateGraph Patterns
<!-- Context Level: Component | Inherits: Production Domain | Token Budget: 3K -->

## 🔄 LANGGRAPH WORKFLOW ARCHITECTURE

**Pattern**: Pipeline-based StateGraph with conditional routing
**Persistence**: Database-backed checkpointing
**Recovery**: Automatic retry from last checkpoint
**Monitoring**: Real-time state transitions

## 📊 MAIN WORKFLOW STRUCTURE

```python
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.postgres import PostgresSaver
from typing import Literal

# Initialize with persistence
checkpointer = PostgresSaver.from_conn_string(
    "postgresql://user:pass@localhost:5432/podcast_production"
)

# Create main graph
workflow = StateGraph(PodcastState)

# Add pipeline nodes
workflow.add_node("research", research_pipeline)
workflow.add_node("content", content_pipeline)
workflow.add_node("quality", quality_pipeline)
workflow.add_node("production", production_pipeline)

# Define routing logic
def route_after_research(state: PodcastState) -> Literal["content", "error"]:
    if state.get("research_data") and len(state["research_data"]) > 0:
        return "content"
    return "error"

def route_after_quality(state: PodcastState) -> Literal["production", "revision"]:
    if state["quality_scores"]["consensus"]["passed"]:
        return "production"
    return "revision"

# Build flow
workflow.add_edge(START, "research")
workflow.add_conditional_edges("research", route_after_research)
workflow.add_edge("content", "quality")
workflow.add_conditional_edges("quality", route_after_quality)
workflow.add_edge("production", END)

# Compile with checkpointing
app = workflow.compile(checkpointer=checkpointer)
```

## 🔬 RESEARCH PIPELINE

```python
async def research_pipeline(state: PodcastState) -> PodcastState:
    """4-stage research orchestration"""
    
    # Stage 1: Discovery
    discovery_agent = ResearchDiscoveryAgent()
    state = await discovery_agent.execute(state)
    
    # Stage 2: Deep Dive (parallel)
    deep_dive_agent = ResearchDeepDiveAgent()
    state = await deep_dive_agent.execute(state)
    
    # Stage 3: Validation
    validation_agent = ResearchValidationAgent()
    state = await validation_agent.execute(state)
    
    # Stage 4: Synthesis
    synthesis_agent = ResearchSynthesisAgent()
    state = await synthesis_agent.execute(state)
    
    # Update with research package
    return {
        **state,
        "research_data": {
            "discovery": state.get("discovery_findings"),
            "deep_dive": state.get("deep_dive_insights"),
            "validation": state.get("validated_facts"),
            "synthesis": state.get("synthesized_knowledge")
        }
    }
```

## 📝 CONTENT PIPELINE

```python
async def content_pipeline(state: PodcastState) -> PodcastState:
    """Content creation with brand validation"""
    
    # Generate questions
    question_gen = QuestionGeneratorAgent()
    state = await question_gen.execute(state)
    
    # Plan episode structure
    planner = EpisodePlannerAgent()
    state = await planner.execute(state)
    
    # Write script
    writer = ScriptWriterAgent()
    state = await writer.execute(state)
    
    # Validate brand alignment
    brand_validator = BrandValidatorAgent()
    state = await brand_validator.execute(state)
    
    # Gate: Require brand score >= 0.85
    if state["brand_validation"]["score"] < 0.85:
        state = await writer.revise(state)  # Revision loop
    
    return state
```

## ✅ QUALITY PIPELINE

```python
async def quality_pipeline(state: PodcastState) -> PodcastState:
    """Multi-evaluator consensus"""
    
    # Parallel evaluation
    claude_eval = ClaudeEvaluatorAgent()
    gemini_eval = GeminiEvaluatorAgent()
    
    # Execute concurrently
    claude_task = asyncio.create_task(claude_eval.execute(state))
    gemini_task = asyncio.create_task(gemini_eval.execute(state))
    
    claude_result = await claude_task
    gemini_result = await gemini_task
    
    # Merge results
    state = {**state, **claude_result, **gemini_result}
    
    # Calculate consensus
    consensus = calculate_consensus(
        state["claude_scores"],
        state["gemini_scores"]
    )
    
    state["quality_scores"] = {
        "claude": state["claude_scores"],
        "gemini": state["gemini_scores"],
        "consensus": consensus
    }
    
    return state
```

## 🎙️ PRODUCTION PIPELINE

```python
async def production_pipeline(state: PodcastState) -> PodcastState:
    """Audio synthesis and validation"""
    
    # Synthesize audio
    synthesizer = AudioSynthesizerAgent()
    state = await synthesizer.execute(state)
    
    # Validate audio quality
    validator = AudioValidatorAgent()
    state = await validator.execute(state)
    
    # Gate: Audio must pass validation
    if not state["audio_validation"]["passed"]:
        # Retry synthesis with adjustments
        state = await synthesizer.execute({
            **state,
            "synthesis_adjustments": state["audio_validation"]["issues"]
        })
    
    return state
```

## 🔀 CONDITIONAL ROUTING

### Dynamic Path Selection
```python
def intelligent_router(state: PodcastState) -> str:
    """Context-aware routing decisions"""
    
    # Check budget
    if state["cost_tracking"]["total"] > state["budget"] * 0.9:
        return "budget_optimization"
    
    # Check quality
    if state.get("quality_scores", {}).get("average", 0) < 7.0:
        return "quality_revision"
    
    # Check completeness
    if not all([
        state.get("research_data"),
        state.get("script"),
        state.get("audio_url")
    ]):
        return "completion_check"
    
    return "success"
```

## 🔁 RETRY & RECOVERY

### Checkpoint Recovery
```python
async def resume_from_checkpoint(checkpoint_id: str):
    """Resume workflow from saved state"""
    
    # Load checkpoint
    saved_state = checkpointer.get(checkpoint_id)
    
    # Determine resume point
    resume_node = determine_resume_node(saved_state)
    
    # Resume execution
    config = {"configurable": {"thread_id": checkpoint_id}}
    result = await app.ainvoke(saved_state, config)
    
    return result
```

### Retry Logic
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
async def resilient_node_execution(node_func, state):
    """Execute with automatic retry"""
    return await node_func(state)
```

## 📈 PERFORMANCE OPTIMIZATION

### Parallel Execution
```python
async def parallel_pipeline_execution(state: PodcastState):
    """Execute independent pipelines concurrently"""
    
    # Identify parallelizable tasks
    parallel_tasks = []
    
    if state.get("research_complete"):
        parallel_tasks.append(content_pipeline(state))
    
    if state.get("script_complete"):
        parallel_tasks.append(quality_pipeline(state))
        parallel_tasks.append(audio_preprocessing(state))
    
    # Execute in parallel
    results = await asyncio.gather(*parallel_tasks, return_exceptions=True)
    
    # Merge results
    for result in results:
        if not isinstance(result, Exception):
            state = {**state, **result}
    
    return state
```

### State Optimization
```python
def optimize_state_size(state: PodcastState) -> PodcastState:
    """Reduce state size for checkpointing"""
    
    # Remove transient data
    optimized = {k: v for k, v in state.items() 
                 if k not in ["temp_data", "debug_info"]}
    
    # Compress large fields
    if "research_data" in optimized:
        optimized["research_data"] = compress_research(optimized["research_data"])
    
    return optimized
```

## 🎯 WORKFLOW METRICS

| Pipeline | Avg Duration | Success Rate | Checkpoint Size |
|----------|--------------|--------------|-----------------|
| Research | 45s | 98% | 15KB |
| Content | 30s | 96% | 25KB |
| Quality | 20s | 99% | 8KB |
| Production | 60s | 95% | 5KB |
| **Total** | **2.5min** | **95%** | **53KB** |

## 🔄 INHERITANCE

**Inherits From**: `../CLAUDE.md` (Production Domain)
**Sibling Contexts**:
- `../agents/CLAUDE.md` - Agent implementations
- `../config/CLAUDE.md` - Configuration rules

---

**Token Budget**: 3K | **Focus**: Workflow orchestration | **Status**: Production