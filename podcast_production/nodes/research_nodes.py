"""
Research Pipeline Node Functions
Simple wrapper implementations - August 2025 pattern

All research agents converted to proper LangGraph nodes.
"""

from core.node_wrapper import create_agent_node
from agents.research_discovery import ResearchDiscoveryAgent
from agents.research_deep_dive import ResearchDeepDiveAgent
from agents.research_validation import ResearchValidationAgent
from agents.research_synthesis import ResearchSynthesisAgent


# Global node function storage - simple caching
_research_discovery_node = None
_research_deep_dive_node = None
_research_validation_node = None
_research_synthesis_node = None


async def get_research_discovery_node():
    """Research Discovery node - lazy initialization"""
    global _research_discovery_node
    if _research_discovery_node is None:
        _research_discovery_node = await create_agent_node(ResearchDiscoveryAgent)
    return _research_discovery_node


async def get_research_deep_dive_node():
    """Research Deep Dive node - lazy initialization"""
    global _research_deep_dive_node
    if _research_deep_dive_node is None:
        _research_deep_dive_node = await create_agent_node(ResearchDeepDiveAgent)
    return _research_deep_dive_node


async def get_research_validation_node():
    """Research Validation node - lazy initialization"""
    global _research_validation_node
    if _research_validation_node is None:
        _research_validation_node = await create_agent_node(ResearchValidationAgent)
    return _research_validation_node


async def get_research_synthesis_node():
    """Research Synthesis node - lazy initialization"""
    global _research_synthesis_node
    if _research_synthesis_node is None:
        _research_synthesis_node = await create_agent_node(ResearchSynthesisAgent)
    return _research_synthesis_node


__all__ = [
    'get_research_discovery_node',
    'get_research_deep_dive_node', 
    'get_research_validation_node',
    'get_research_synthesis_node'
]