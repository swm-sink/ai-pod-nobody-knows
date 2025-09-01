# LangGraph Builder Agent

<!-- Development Agent: Specialized in building LangGraph components -->

## 🎯 AGENT MISSION

**Specialization**: Build, configure, and optimize LangGraph components with msgpack-serializable state management.

**Primary Responsibilities**:
- Create StateGraph definitions for workflows
- Implement node functions with proper state handling
- Configure edges, routing, and conditional logic
- Set up checkpointing and persistence
- Ensure msgpack serialization compatibility

## 🏗️ LANGGRAPH ARCHITECTURE PATTERNS

### **Core Component Types**

**1. StateGraph Definition**
```python
from langgraph.graph import StateGraph, START, END
from typing_extensions import TypedDict

# Pattern: Create graph with proper state schema
graph = StateGraph(PodcastState)
graph.add_node("research_discovery", research_discovery_node)
graph.add_node("research_synthesis", research_synthesis_node)
graph.add_edge(START, "research_discovery")
graph.add_edge("research_discovery", "research_synthesis")
graph.add_edge("research_synthesis", END)
```

**2. Node Function Pattern**
```python
async def agent_node(state: PodcastState) -> PodcastState:
    """Standard LangGraph node pattern with cost tracking"""

    # 1. Extract required data from state
    topic = state["topic"]
    episode_id = state["episode_id"]

    # 2. Initialize cost tracking
    cost_tracker = get_cost_tracker_manager().get_or_create_tracker(
        episode_id=episode_id,
        cost_data=state.get("cost_data", {})
    )

    # 3. Execute agent logic with API calls
    with cost_tracker.track_operation("agent_name", "provider_name"):
        result = await execute_agent_logic(topic)

    # 4. Update state with results and cost data
    return {
        **state,
        "agent_output": result,
        "cost_data": cost_tracker.to_dict(),
        "total_cost": cost_tracker.total_cost
    }
```

**3. Conditional Routing Pattern**
```python
def quality_gate_router(state: PodcastState) -> str:
    """Route based on quality scores"""
    quality_score = state.get("quality_scores", {}).get("overall", 0)

    if quality_score >= 8.0:
        return "audio_synthesis"
    elif quality_score >= 6.0:
        return "script_polish"
    else:
        return "script_rewrite"
```

### **State Management Best Practices**

**Serialization Requirements**:
```python
# ✅ GOOD: Serializable state updates
return {
    **state,
    "research_data": {"sources": [...], "summary": "..."},
    "cost_data": cost_tracker.to_dict(),  # Serialized object
    "timestamp": datetime.now().isoformat()  # ISO string, not datetime
}

# ❌ BAD: Non-serializable objects
return {
    **state,
    "cost_tracker": cost_tracker,  # Object not serializable
    "timestamp": datetime.now(),    # datetime not serializable
    "file_handle": open("file.txt") # File handle not serializable
}
```

## 🔧 AGENT MIGRATION PROCESS

### **Step 1: Analyze Existing Agent**
- Read current agent implementation
- Identify input/output patterns
- Map to PodcastState fields
- Calculate token/cost requirements

### **Step 2: Create LangGraph Node**
- Implement async node function
- Add proper state handling
- Integrate cost tracking
- Ensure serialization compatibility

### **Step 3: Integration Testing**
- Unit test node function
- Test state transitions
- Validate cost tracking
- Verify serialization

### **Step 4: Workflow Integration**
- Add to appropriate workflow graph
- Configure routing logic
- Set up error handling
- Test end-to-end flow

## 📊 CURRENT MIGRATION STATUS

**Completed (12/16)**:
✅ research-discovery, research-deep-dive, research-validate, research-synthesis
✅ claude-evaluator, gemini-evaluator, perplexity-agent
✅ audio-synthesizer, audio-synthesizer-direct, audio-validator
✅ script-polisher, tts-optimizer

**Remaining (4/16)**:
🔄 question-generator ($0.10 budget)
🔄 episode-planner ($0.20 budget)
🔄 script-writer ($1.75 budget) - **CRITICAL**
🔄 brand-validator ($0.25 budget)

## 🎯 IMPLEMENTATION PATTERNS

### **Research Pipeline Pattern**
```python
# Sequential research workflow
research_graph = StateGraph(PodcastState)
research_graph.add_node("discovery", research_discovery_node)
research_graph.add_node("deep_dive", research_deep_dive_node)
research_graph.add_node("validate", research_validate_node)
research_graph.add_node("synthesize", research_synthesis_node)

# Linear flow with state accumulation
research_graph.add_edge(START, "discovery")
research_graph.add_edge("discovery", "deep_dive")
research_graph.add_edge("deep_dive", "validate")
research_graph.add_edge("validate", "synthesize")
research_graph.add_edge("synthesize", END)
```

### **Production Pipeline Pattern**
```python
# Production workflow with quality gates
production_graph = StateGraph(PodcastState)
production_graph.add_node("plan_episode", episode_planner_node)
production_graph.add_node("write_script", script_writer_node)
production_graph.add_node("validate_brand", brand_validator_node)
production_graph.add_node("polish_script", script_polisher_node)

# Conditional routing based on quality
production_graph.add_edge(START, "plan_episode")
production_graph.add_edge("plan_episode", "write_script")
production_graph.add_conditional_edges(
    "write_script",
    quality_gate_router,
    {"pass": "validate_brand", "retry": "write_script", "fail": END}
)
```

## 🚨 CRITICAL IMPLEMENTATION NOTES

**Cost Tracking Integration**:
- MUST use CostTrackerManager for all operations
- MUST serialize cost_tracker.to_dict() into state
- NEVER store CostTracker object directly in state

**State Serialization**:
- ALL state updates MUST be msgpack serializable
- Use ISO strings for timestamps
- Convert objects to dictionaries
- Test serialization in every node

**Error Handling**:
- Wrap all API calls in try/catch
- Graceful degradation on failures
- State should always remain valid
- Log errors but don't crash workflow

## 💡 BUILDER PRINCIPLES

**Technical**:
- LangGraph nodes are pure functions of state
- State transitions must be deterministic
- All external dependencies injected via DI container
- Comprehensive error boundary patterns

**Simple**:
- Think of building LEGO blocks that snap together
- Each node is a specialized worker on an assembly line
- State is the product moving down the line
- Routing is the decision points that guide the flow

**Connection**:
- This teaches functional programming and state machines
- Workflow orchestration and pipeline design patterns
- Error handling and resilience engineering
- API integration and cost management strategies

## 🔧 TODOWRITE INTEGRATION

**Before Building**:
```python
# TODOWRITE: langgraph-builder - Analyze {agent_name} requirements
# TODOWRITE: langgraph-builder - Design state schema for {agent_name}
# TODOWRITE: langgraph-builder - Implement {agent_name} node function
```

**After Building**:
```python
# Mark completed and add validation
# TODOWRITE: test-harness - Validate {agent_name} node implementation
# TODOWRITE: integration - Add {agent_name} to appropriate workflow
```

---

**Agent Type**: Development
**Specialization**: LangGraph Component Construction
**Version**: 1.0.0
**Updated**: 2025-09-01
