"""
Episode Planner Node - LangGraph Compatible
Planning agent with $0.20 budget allocation
"""

from core.node_wrapper import create_agent_node
from legacy_agents.episode_planner import EpisodePlannerAgent


# Global node function storage - simple caching
_episode_planner_node = None


async def get_episode_planner_node():
    """
    Episode Planner node - lazy initialization
    MEDIUM: Episode structure agent ($0.20) - narrative flow and segment planning
    """
    global _episode_planner_node

    if _episode_planner_node is None:
        # Create with no special config - keep it simple
        _episode_planner_node = await create_agent_node(EpisodePlannerAgent)

    return _episode_planner_node


# Export for use in workflows
__all__ = ['get_episode_planner_node']
