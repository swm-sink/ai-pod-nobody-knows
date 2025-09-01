"""
Script Writer Node - LangGraph Compatible
High-value agent with $1.75 budget allocation
"""

from core.node_wrapper import create_agent_node
from legacy_agents.script_writer import ScriptWriterAgent


# Global node function storage - simple caching
_script_writer_node = None


async def get_script_writer_node():
    """
    Script Writer node - lazy initialization
    CRITICAL: Highest budget agent ($1.75) - core content creation
    """
    global _script_writer_node

    if _script_writer_node is None:
        # Create with no special config - keep it simple
        _script_writer_node = await create_agent_node(ScriptWriterAgent)

    return _script_writer_node


# Export for use in workflows
__all__ = ['get_script_writer_node']
