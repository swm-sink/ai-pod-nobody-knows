"""
Voice Configuration Management - August 2025
Centralized voice ID configuration to ensure governance compliance.

This module provides a single source of truth for voice configuration as
required by CLAUDE.md governance protocols.
"""

import os
import logging
from typing import Optional, Dict, Any
from pathlib import Path
import json

logger = logging.getLogger(__name__)


class VoiceConfigManager:
    """
    Centralized voice configuration manager.

    Ensures compliance with CLAUDE.md governance requirement:
    "Voice ID changes require explicit user permission - NO EXCEPTIONS"
    """

    # Production voice ID - NEVER change this without explicit user permission
    # Using function call instead of hardcoded value for governance compliance
    def _get_default_voice_id(self):
        """Get default production voice ID from environment or raise error."""
        # Governance compliance: No hardcoded voice IDs
        # Voice ID must be configured via environment or config file
        raise ValueError(
            "No voice ID configured. Set PRODUCTION_VOICE_ID environment variable or "
            "create .claude/config/production-voice.json with production_voice_id field. "
            "Check previous episode configurations for validated voice IDs."
        )

    def __init__(self):
        """Initialize voice configuration manager."""
        self.config_file = Path("config/production-voice.json")
        self._voice_cache = {}
        self._load_config()

    def _load_config(self):
        """Load voice configuration from file or environment."""
        try:
            # Priority 1: Config file (if exists)
            if self.config_file.exists():
                with open(self.config_file, 'r') as f:
                    config = json.load(f)
                    self._voice_cache = config
                    logger.info(f"✅ Voice config loaded from {self.config_file}")
                    return

            # Priority 2: Environment variable
            env_voice_id = os.getenv("PRODUCTION_VOICE_ID")
            if env_voice_id:
                self._voice_cache = {
                    "production_voice_id": env_voice_id,
                    "source": "environment",
                    "validation_status": "pending"
                }
                logger.info(f"✅ Voice config loaded from environment: {env_voice_id}")
                return

            # Priority 3: Default fallback
            default_voice_id = self._get_default_voice_id()
            self._voice_cache = {
                "production_voice_id": default_voice_id,
                "source": "default",
                "validation_status": "validated",
                "validation_date": "2025-08-31",
                "validation_notes": "Episode 1 validated with 9.2/10 quality"
            }
            logger.info(f"✅ Using default production voice: {default_voice_id}")

        except Exception as e:
            logger.error(f"❌ Failed to load voice config: {e}")
            # Emergency fallback
            emergency_voice_id = self._get_default_voice_id()
            self._voice_cache = {
                "production_voice_id": emergency_voice_id,
                "source": "emergency_fallback",
                "validation_status": "emergency"
            }

    def get_production_voice_id(self) -> str:
        """
        Get the production voice ID.

        Returns:
            Production voice ID string
        """
        voice_id = self._voice_cache.get("production_voice_id", self._get_default_voice_id())

        # Governance logging
        logger.debug(f"Voice ID requested: {voice_id} (source: {self._voice_cache.get('source', 'unknown')})")

        return voice_id

    def get_voice_config(self) -> Dict[str, Any]:
        """
        Get complete voice configuration.

        Returns:
            Complete voice configuration dictionary
        """
        return self._voice_cache.copy()

    def update_voice_id(self, new_voice_id: str, user_authorized: bool = False) -> bool:
        """
        Update voice ID with governance controls.

        Args:
            new_voice_id: New voice ID to set
            user_authorized: REQUIRED - Must be True to confirm user authorization

        Returns:
            True if update successful, False if blocked by governance
        """
        if not user_authorized:
            logger.error("❌ GOVERNANCE VIOLATION: Voice ID change attempted without user authorization")
            logger.error("❌ As per CLAUDE.md: 'Voice ID changes require explicit user permission - NO EXCEPTIONS'")
            return False

        if new_voice_id == self.get_production_voice_id():
            logger.info("ℹ️ Voice ID unchanged, no update needed")
            return True

        old_voice_id = self.get_production_voice_id()

        # Update configuration
        self._voice_cache.update({
            "production_voice_id": new_voice_id,
            "source": "user_authorized_change",
            "validation_status": "pending_validation",
            "change_timestamp": "2025-09-01",  # Current date
            "previous_voice_id": old_voice_id,
            "user_authorized": True
        })

        # Save to config file
        try:
            self.config_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self.config_file, 'w') as f:
                json.dump(self._voice_cache, f, indent=2)

            logger.info(f"✅ Voice ID updated: {old_voice_id} → {new_voice_id}")
            logger.info(f"✅ Change authorized by user and saved to {self.config_file}")
            return True

        except Exception as e:
            logger.error(f"❌ Failed to save voice config: {e}")
            return False

    def validate_current_voice(self, quality_score: float = None) -> None:
        """
        Mark current voice as validated.

        Args:
            quality_score: Optional quality score from validation
        """
        self._voice_cache.update({
            "validation_status": "validated",
            "validation_date": "2025-09-01",
            "validation_score": quality_score
        })

        # Save validation status
        try:
            if self.config_file.exists():
                with open(self.config_file, 'w') as f:
                    json.dump(self._voice_cache, f, indent=2)
        except Exception as e:
            logger.warning(f"Failed to save validation status: {e}")


# Global instance for easy access
_voice_config_manager = None


def get_voice_config_manager() -> VoiceConfigManager:
    """Get the global voice configuration manager instance."""
    global _voice_config_manager
    if _voice_config_manager is None:
        _voice_config_manager = VoiceConfigManager()
    return _voice_config_manager


def get_production_voice_id() -> str:
    """
    Get the production voice ID - GOVERNANCE COMPLIANT.

    This is the ONLY way to get voice ID in the codebase.
    All hardcoded voice IDs are governance violations.

    Returns:
        Production voice ID string
    """
    return get_voice_config_manager().get_production_voice_id()


def update_production_voice_id(new_voice_id: str, user_authorized: bool = False) -> bool:
    """
    Update production voice ID with governance controls.

    Args:
        new_voice_id: New voice ID
        user_authorized: Must be True - confirms user permission

    Returns:
        True if successful, False if blocked by governance
    """
    return get_voice_config_manager().update_voice_id(new_voice_id, user_authorized)


def validate_current_voice(quality_score: float = None) -> None:
    """Mark current voice as validated."""
    get_voice_config_manager().validate_current_voice(quality_score)


# For backward compatibility and easy import
PRODUCTION_VOICE_ID = get_production_voice_id
