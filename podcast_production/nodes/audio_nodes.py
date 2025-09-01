"""
Audio Pipeline Node Functions
Simple wrapper implementations - August 2025 pattern

Audio synthesis and validation nodes.
"""

from core.node_wrapper import create_agent_node
from agents.audio_synthesizer import AudioSynthesizerAgent
from agents.audio_validator import AudioValidatorAgent


# Global node function storage - simple caching
_audio_synthesizer_node = None
_audio_validator_node = None


async def get_audio_synthesizer_node():
    """Audio Synthesizer node - lazy initialization"""
    global _audio_synthesizer_node
    if _audio_synthesizer_node is None:
        _audio_synthesizer_node = await create_agent_node(AudioSynthesizerAgent)
    return _audio_synthesizer_node


async def get_audio_validator_node():
    """Audio Validator node - lazy initialization"""
    global _audio_validator_node
    if _audio_validator_node is None:
        _audio_validator_node = await create_agent_node(AudioValidatorAgent)
    return _audio_validator_node


__all__ = [
    'get_audio_synthesizer_node',
    'get_audio_validator_node'
]