"""
LangGraph Node Functions - Simple Wrapper Pattern
All agents converted to proper node functions using minimum viable complexity.

August 2025 compatible node functions.
"""

from .research_nodes import (
    get_research_discovery_node,
    get_research_deep_dive_node,
    get_research_validation_node,
    get_research_synthesis_node
)

from .audio_nodes import (
    get_audio_synthesizer_node,
    get_audio_validator_node
)

from .evaluation_nodes import (
    get_claude_evaluator_node,
    get_gemini_evaluator_node
)

from .planning_nodes import (
    get_question_generator_node,
    get_episode_planner_node,
    get_script_writer_node,
    get_brand_validator_node
)

# Simple registry pattern
NODE_REGISTRY = {
    # Research Pipeline
    'research_discovery': get_research_discovery_node,
    'research_deep_dive': get_research_deep_dive_node,
    'research_validation': get_research_validation_node,
    'research_synthesis': get_research_synthesis_node,
    
    # Planning Pipeline
    'question_generator': get_question_generator_node,
    'episode_planner': get_episode_planner_node,
    'script_writer': get_script_writer_node,
    'brand_validator': get_brand_validator_node,
    
    # Audio Pipeline
    'audio_synthesizer': get_audio_synthesizer_node,
    'audio_validator': get_audio_validator_node,
    
    # Evaluation Pipeline
    'claude_evaluator': get_claude_evaluator_node,
    'gemini_evaluator': get_gemini_evaluator_node,
}


async def get_node_function(node_name: str):
    """
    Get a node function by name.
    Simple registry lookup - no complex patterns needed.
    """
    if node_name not in NODE_REGISTRY:
        raise ValueError(f"Unknown node: {node_name}")
    
    getter_func = NODE_REGISTRY[node_name]
    return await getter_func()


__all__ = [
    'NODE_REGISTRY',
    'get_node_function',
    # Research
    'get_research_discovery_node',
    'get_research_deep_dive_node', 
    'get_research_validation_node',
    'get_research_synthesis_node',
    # Planning
    'get_question_generator_node',
    'get_episode_planner_node',
    'get_script_writer_node',
    'get_brand_validator_node',
    # Audio
    'get_audio_synthesizer_node',
    'get_audio_validator_node',
    # Evaluation
    'get_claude_evaluator_node',
    'get_gemini_evaluator_node',
]