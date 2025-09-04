"""
Cost Tracker Manager for lifecycle management.

This module manages CostTracker instances outside of LangGraph state,
following August 2025 best practices for state serialization.

Version: 1.0.0
Date: August 2025
"""

from typing import Dict, Optional, Any
from .cost_tracker import CostTracker, create_cost_tracker
import logging

logger = logging.getLogger(__name__)


class CostTrackerManager:
    """
    Manages CostTracker instances for episodes.
    Keeps trackers outside of serialized state to avoid msgpack issues.
    Following MANDATORY SIMPLICITY ENFORCEMENT from CLAUDE.md.
    """
    
    def __init__(self):
        """Initialize the manager with empty tracker storage."""
        self._trackers: Dict[str, CostTracker] = {}
        logger.info("CostTrackerManager initialized")
    
    def get_or_create_tracker(
        self, 
        episode_id: str, 
        budget_limit: float = 5.51,
        cost_data: Dict[str, Any] = None
    ) -> CostTracker:
        """
        Get existing tracker or create new one.
        
        Args:
            episode_id: Episode identifier
            budget_limit: Budget limit for new trackers
            cost_data: Optional serialized cost data to restore from
            
        Returns:
            CostTracker instance
        """
        if episode_id not in self._trackers:
            if cost_data:
                # Restore from serialized data
                self._trackers[episode_id] = CostTracker.from_dict(cost_data)
                logger.info(f"Restored CostTracker for episode {episode_id}")
            else:
                # Create new tracker
                self._trackers[episode_id] = create_cost_tracker(
                    budget_limit=budget_limit,
                    episode_id=episode_id
                )
                logger.info(f"Created new CostTracker for episode {episode_id}")
        
        return self._trackers[episode_id]
    
    def remove_tracker(self, episode_id: str):
        """
        Remove tracker when episode is complete.
        
        Args:
            episode_id: Episode identifier
        """
        if episode_id in self._trackers:
            del self._trackers[episode_id]
            logger.info(f"Removed CostTracker for episode {episode_id}")
    
    def get_tracker(self, episode_id: str) -> Optional[CostTracker]:
        """
        Get existing tracker without creating.
        
        Args:
            episode_id: Episode identifier
            
        Returns:
            CostTracker instance or None
        """
        return self._trackers.get(episode_id)
    
    def clear_all(self):
        """Clear all trackers."""
        self._trackers.clear()
        logger.info("Cleared all CostTrackers")


# Global instance for simple access
_manager = CostTrackerManager()


def get_cost_tracker_manager() -> CostTrackerManager:
    """Get the global CostTrackerManager instance."""
    return _manager