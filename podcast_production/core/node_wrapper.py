"""
Simple Node Wrapper for LangGraph Agent Conversion
Minimum Viable Complexity - August 2025 Pattern

Converts existing agents with execute() methods to proper node functions.
Updated for August 2025 LangGraph requirements with InjectedStore and InjectedState.
"""

import asyncio
import logging
from typing import Dict, Any, Callable, Optional
from langchain_core.runnables import RunnableConfig
from core.state import PodcastState

# Import August 2025 dependency injection patterns
try:
    from langgraph.prebuilt import InjectedStore, InjectedState
    LANGGRAPH_INJECTION_AVAILABLE = True
except ImportError:
    # Fallback for development/testing
    InjectedStore = Dict[str, Any]
    InjectedState = Dict[str, Any]
    LANGGRAPH_INJECTION_AVAILABLE = False
    logging.warning("LangGraph InjectedStore/InjectedState not available, using fallback types")

logger = logging.getLogger(__name__)


# Simple concurrency control - elegant solution
_agent_semaphore = asyncio.Semaphore(5)  # Max 5 concurrent agent operations


async def create_agent_node(
    agent_class, 
    store_key: Optional[str] = None,
    **agent_kwargs
) -> Callable:
    """
    Create a LangGraph node function from an existing agent class.
    Updated for August 2025 with InjectedStore and InjectedState support.
    
    This is the SIMPLEST way to convert existing agents to proper node functions.
    No complex refactoring needed - just wrap and go.
    
    Args:
        agent_class: The existing agent class
        store_key: Optional key for store access (for future store-based features)
        **agent_kwargs: Keyword arguments for agent initialization
        
    Returns:
        Async node function compatible with August 2025 LangGraph patterns
    """
    
    async def node_function(
        state: InjectedState, 
        *, 
        store: InjectedStore,
        config: Optional[RunnableConfig] = None
    ) -> PodcastState:
        """
        LangGraph node function - August 2025 pattern with dependency injection
        
        Args:
            state: InjectedState from LangGraph (August 2025 requirement)
            store: InjectedStore for persistent data access (August 2025 requirement)
            config: Optional configuration
            
        Returns:
            Updated PodcastState
        """
        
        # Log dependency injection status for debugging
        if LANGGRAPH_INJECTION_AVAILABLE:
            logger.debug(f"Node {agent_class.__name__} executing with proper injection")
        else:
            logger.warning(f"Node {agent_class.__name__} executing with fallback types")
        
        # Concurrency control - prevent API overload
        async with _agent_semaphore:
            
            # Initialize the agent with store access if needed
            init_kwargs = agent_kwargs.copy()
            if store_key and LANGGRAPH_INJECTION_AVAILABLE:
                init_kwargs['store'] = store
            
            agent = agent_class(**init_kwargs)
            
            # Convert InjectedState to dict for existing agent compatibility
            state_dict = dict(state) if hasattr(state, 'items') else state
            
            # Execute using existing method - no refactoring needed!
            result = await agent.execute(state_dict)
            
            # Store any results in the injected store if configured
            if store_key and LANGGRAPH_INJECTION_AVAILABLE and result:
                try:
                    await store.aput((store_key, agent_class.__name__), result)
                except Exception as e:
                    logger.warning(f"Failed to store result in InjectedStore: {e}")
            
            # Return merged state
            return {**state_dict, **result}
    
    return node_function


def create_sync_agent_node(
    agent_class, 
    store_key: Optional[str] = None,
    **agent_kwargs
) -> Callable:
    """
    Create a LangGraph node function from a synchronous agent class.
    Updated for August 2025 with dependency injection support.
    
    Args:
        agent_class: The existing sync agent class
        store_key: Optional key for store access
        **agent_kwargs: Keyword arguments for agent initialization
        
    Returns:
        Sync node function compatible with August 2025 LangGraph patterns
    """
    
    def node_function(
        state: InjectedState, 
        *, 
        store: InjectedStore,
        config: Optional[RunnableConfig] = None
    ) -> PodcastState:
        """
        LangGraph sync node function - August 2025 pattern
        
        Args:
            state: InjectedState from LangGraph
            store: InjectedStore for persistent data access
            config: Optional configuration
        """
        
        # Log dependency injection status
        if LANGGRAPH_INJECTION_AVAILABLE:
            logger.debug(f"Sync node {agent_class.__name__} executing with proper injection")
        else:
            logger.warning(f"Sync node {agent_class.__name__} executing with fallback types")
        
        # Initialize the agent with store access if needed
        init_kwargs = agent_kwargs.copy()
        if store_key and LANGGRAPH_INJECTION_AVAILABLE:
            init_kwargs['store'] = store
        
        agent = agent_class(**init_kwargs)
        
        # Convert InjectedState to dict for compatibility
        state_dict = dict(state) if hasattr(state, 'items') else state
        
        # Execute using existing method
        result = agent.execute(state_dict)
        
        # Store results if configured
        if store_key and LANGGRAPH_INJECTION_AVAILABLE and result:
            try:
                # Note: sync store operation - might need async wrapper in future
                logger.info(f"Would store result for {agent_class.__name__} (sync store not yet implemented)")
            except Exception as e:
                logger.warning(f"Failed to store sync result: {e}")
        
        # Return merged state
        return {**state_dict, **result}
    
    return node_function


# Example usage - August 2025 pattern
"""
from agents.question_generator import QuestionGeneratorAgent

# Create the node function with August 2025 patterns
question_generator_node = await create_agent_node(
    QuestionGeneratorAgent,
    store_key="question_generation"  # For persistent storage
)

# Use in LangGraph - now with proper dependency injection
graph.add_node("question_generator", question_generator_node)

# The node will automatically receive InjectedState and InjectedStore
# when executed by LangGraph's August 2025 runtime
"""

# Backward compatibility helper for gradual migration
async def create_legacy_agent_node(agent_class, **agent_kwargs) -> Callable:
    """
    DEPRECATED: Legacy node wrapper for backward compatibility.
    Use create_agent_node() for new implementations.
    """
    logger.warning(f"Using deprecated legacy wrapper for {agent_class.__name__}. "
                  f"Please migrate to create_agent_node() with August 2025 patterns.")
    
    async def legacy_node_function(
        state: PodcastState, 
        config: RunnableConfig = None
    ) -> PodcastState:
        async with _agent_semaphore:
            agent = agent_class(**agent_kwargs)
            result = await agent.execute(dict(state))
            return {**state, **result}
    
    return legacy_node_function