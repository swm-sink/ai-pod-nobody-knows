#!/usr/bin/env python3
"""Test LangGraph installation and basic functionality."""

from typing import TypedDict, Annotated, List
from langgraph.graph import StateGraph, END
from langgraph.checkpoint.memory import MemorySaver

print("✓ LangGraph imports successful")

# Define a simple state
class SimpleState(TypedDict):
    messages: List[str]
    count: int

print("✓ TypedDict state definition works")

# Create a simple graph
def increment_node(state: SimpleState) -> SimpleState:
    """Simple node that increments count."""
    current_messages = state.get("messages", [])
    return {
        "count": state.get("count", 0) + 1,
        "messages": current_messages + ["Incremented"]
    }

def check_node(state: SimpleState) -> str:
    """Router node that checks count."""
    if state.get("count", 0) >= 2:
        return "end"
    return "increment"

# Build the graph
graph = StateGraph(SimpleState)
graph.add_node("increment", increment_node)
graph.add_conditional_edges(
    "increment",
    check_node,
    {
        "increment": "increment",
        "end": END
    }
)
graph.set_entry_point("increment")

print("✓ Graph construction successful")

# Compile with memory
memory = MemorySaver()
app = graph.compile(checkpointer=memory)

print("✓ Graph compilation with memory successful")

# Test execution with thread config
config = {"configurable": {"thread_id": "test-thread-1"}}
result = app.invoke({"count": 0, "messages": []}, config=config)
print(f"✓ Graph execution successful: count={result['count']}")

# Verify result
assert result["count"] == 2, f"Expected count=2, got {result['count']}"
assert len(result["messages"]) == 2, f"Expected 2 messages, got {len(result['messages'])}"

print("✓ All assertions passed")
print("✓ LangGraph is fully operational!")
print(f"  Version: 0.5.4")
print(f"  StateGraph: Working")
print(f"  MemorySaver: Working")
print(f"  Graph execution: Working")
