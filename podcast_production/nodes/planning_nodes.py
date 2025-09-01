"""
Planning Pipeline Node Functions
Simple wrapper implementations - August 2025 pattern

Question generation, episode planning, script writing, and brand validation nodes.
"""

from core.node_wrapper import create_agent_node
from agents.question_generator import QuestionGeneratorAgent
from agents.episode_planner import EpisodePlannerAgent
from agents.script_writer import ScriptWriterAgent
from agents.brand_validator import BrandValidatorAgent


# Global node function storage - simple caching
_question_generator_node = None
_episode_planner_node = None
_script_writer_node = None
_brand_validator_node = None


async def get_question_generator_node():
    """Question Generator node - lazy initialization"""
    global _question_generator_node
    if _question_generator_node is None:
        _question_generator_node = await create_agent_node(QuestionGeneratorAgent)
    return _question_generator_node


async def get_episode_planner_node():
    """Episode Planner node - lazy initialization"""
    global _episode_planner_node
    if _episode_planner_node is None:
        _episode_planner_node = await create_agent_node(EpisodePlannerAgent)
    return _episode_planner_node


async def get_script_writer_node():
    """Script Writer node - lazy initialization"""
    global _script_writer_node
    if _script_writer_node is None:
        _script_writer_node = await create_agent_node(ScriptWriterAgent)
    return _script_writer_node


async def get_brand_validator_node():
    """Brand Validator node - lazy initialization"""
    global _brand_validator_node
    if _brand_validator_node is None:
        _brand_validator_node = await create_agent_node(BrandValidatorAgent)
    return _brand_validator_node


__all__ = [
    'get_question_generator_node',
    'get_episode_planner_node',
    'get_script_writer_node',
    'get_brand_validator_node'
]
