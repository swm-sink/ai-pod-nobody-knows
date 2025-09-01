"""
Brand Validator Node - LangGraph Compatible
Quality assurance agent with $0.25 budget allocation
"""

from core.node_wrapper import create_agent_node
from agents.brand_validator import BrandValidatorAgent


# Global node function storage - simple caching
_brand_validator_node = None


async def get_brand_validator_node():
    """
    Brand Validator node - lazy initialization
    HIGH: Quality assurance agent ($0.25) - brand consistency validation
    """
    global _brand_validator_node
    
    if _brand_validator_node is None:
        # Create with no special config - keep it simple
        _brand_validator_node = await create_agent_node(BrandValidatorAgent)
    
    return _brand_validator_node


# Export for use in workflows
__all__ = ['get_brand_validator_node']