"""
Question Generator Node - LangGraph Compatible
Simple wrapper implementation - August 2025 pattern

Demonstrates minimum viable complexity approach.
"""

from core.node_wrapper import create_agent_node
from legacy_agents.question_generator import QuestionGeneratorAgent


# Create the node function - ONE LINE solution!
question_generator_node = None  # Will be initialized async


async def get_question_generator_node():
    """
    Get the question generator node function.
    Simple lazy initialization pattern.
    """
    global question_generator_node

    if question_generator_node is None:
        # Create with no special config - keep it simple
        question_generator_node = await create_agent_node(QuestionGeneratorAgent)

    return question_generator_node


# Export for use in workflows - dead simple
__all__ = ['get_question_generator_node']
