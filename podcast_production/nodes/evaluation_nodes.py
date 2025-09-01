"""
Evaluation Pipeline Node Functions
Simple wrapper implementations - August 2025 pattern

Claude and Gemini evaluator nodes for quality assessment.
"""

from core.node_wrapper import create_agent_node
from legacy_agents.claude_evaluator import ClaudeEvaluatorAgent
from legacy_agents.gemini_evaluator import GeminiEvaluatorAgent


# Global node function storage - simple caching
_claude_evaluator_node = None
_gemini_evaluator_node = None


async def get_claude_evaluator_node():
    """Claude Evaluator node - lazy initialization"""
    global _claude_evaluator_node
    if _claude_evaluator_node is None:
        _claude_evaluator_node = await create_agent_node(ClaudeEvaluatorAgent)
    return _claude_evaluator_node


async def get_gemini_evaluator_node():
    """Gemini Evaluator node - lazy initialization"""
    global _gemini_evaluator_node
    if _gemini_evaluator_node is None:
        _gemini_evaluator_node = await create_agent_node(GeminiEvaluatorAgent)
    return _gemini_evaluator_node


__all__ = [
    'get_claude_evaluator_node',
    'get_gemini_evaluator_node'
]
