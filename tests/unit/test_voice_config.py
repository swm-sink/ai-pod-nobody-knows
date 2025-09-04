#!/usr/bin/env python3
"""
Test suite for centralized voice configuration system.
Validates governance controls, environment variable support, and type safety.
"""

import pytest
import os
import tempfile
from unittest.mock import patch, MagicMock
from pathlib import Path

# Test imports will fail until implementation exists
try:
    from src.podcast_production.config.voice_config import VoiceConfig, VoiceManager
except ImportError:
    # Expected during RED phase
    VoiceConfig = None
    VoiceManager = None


class TestVoiceConfig:
    """Test the centralized voice configuration system."""

    def test_voice_config_initialization(self):
        """Test that VoiceConfig initializes with default production voice."""
        if VoiceConfig is None:
            pytest.skip("VoiceConfig not implemented yet")
            
        config = VoiceConfig()
        assert config.production_voice_id == "ZF6FPAbjXT4488VcRRnw"
        assert config.voice_quality == "high"
        assert config.speaking_rate == 1.0

    def test_voice_config_environment_variable_override(self):
        """Test that environment variables override default configuration."""
        if VoiceConfig is None:
            pytest.skip("VoiceConfig not implemented yet")
            
        with patch.dict(os.environ, {
            'PRODUCTION_VOICE_ID': 'ZF6FPAbjXT4488VcRRnw',  # Use approved voice ID
            'VOICE_QUALITY': 'ultra_high',
            'SPEAKING_RATE': '1.2'
        }):
            config = VoiceConfig()
            assert config.production_voice_id == 'ZF6FPAbjXT4488VcRRnw'
            assert config.voice_quality == 'ultra_high'
            assert config.speaking_rate == 1.2

    def test_voice_config_validation(self):
        """Test that voice configuration validates approved voice IDs."""
        if VoiceConfig is None:
            pytest.skip("VoiceConfig not implemented yet")
            
        # Should accept approved voice
        with patch.dict(os.environ, {'PRODUCTION_VOICE_ID': 'ZF6FPAbjXT4488VcRRnw'}):
            config = VoiceConfig()
            assert config.production_voice_id == 'ZF6FPAbjXT4488VcRRnw'
        
        # Should reject unapproved voice
        with patch.dict(os.environ, {'PRODUCTION_VOICE_ID': 'unauthorized_voice'}):
            with pytest.raises(ValueError, match="Production voice .* not approved"):
                VoiceConfig()

    def test_voice_config_type_validation(self):
        """Test that voice configuration validates parameter types."""
        if VoiceConfig is None:
            pytest.skip("VoiceConfig not implemented yet")
            
        # Should validate speaking rate range
        with patch.dict(os.environ, {'SPEAKING_RATE': '3.0'}):  # Out of range
            with pytest.raises(ValueError):
                VoiceConfig()
                
        with patch.dict(os.environ, {'SPEAKING_RATE': '0.05'}):  # Out of range
            with pytest.raises(ValueError):
                VoiceConfig()

    def test_voice_manager_initialization(self):
        """Test that VoiceManager initializes correctly."""
        if VoiceManager is None:
            pytest.skip("VoiceManager not implemented yet")
            
        manager = VoiceManager()
        assert manager is not None
        assert hasattr(manager, 'config')
        assert hasattr(manager, 'get_production_voice')

    def test_voice_manager_get_production_voice(self):
        """Test that VoiceManager returns correct production voice."""
        if VoiceManager is None:
            pytest.skip("VoiceManager not implemented yet")
            
        manager = VoiceManager()
        voice_id = manager.get_production_voice()
        assert voice_id == "ZF6FPAbjXT4488VcRRnw"
        assert isinstance(voice_id, str)

    def test_voice_manager_change_requires_approval(self):
        """Test that voice changes require explicit approval token."""
        if VoiceManager is None:
            pytest.skip("VoiceManager not implemented yet")
            
        manager = VoiceManager()
        
        # Should require approval token
        with pytest.raises(PermissionError, match="Voice ID changes require explicit user permission"):
            manager.request_voice_change("new_voice_id", "")
        
        # Should accept with valid approval token
        with patch.object(manager, '_log_voice_change_request'):
            manager.request_voice_change("ZF6FPAbjXT4488VcRRnw", "approval_token_123")
            assert manager.config.production_voice_id == "ZF6FPAbjXT4488VcRRnw"

    def test_voice_manager_audit_logging(self):
        """Test that voice changes are logged for audit purposes."""
        if VoiceManager is None:
            pytest.skip("VoiceManager not implemented yet")
            
        manager = VoiceManager()
        
        with patch.object(manager, '_log_voice_change_request') as mock_log:
            manager.request_voice_change("ZF6FPAbjXT4488VcRRnw", "approval_token_123")
            mock_log.assert_called_once_with("ZF6FPAbjXT4488VcRRnw", "approval_token_123")

    def test_voice_config_immutability_protection(self):
        """Test that voice configuration has immutability protection."""
        if VoiceManager is None:
            pytest.skip("VoiceManager not implemented yet")
            
        manager = VoiceManager()
        assert manager._voice_change_requires_approval == True

    def test_voice_config_with_config_file(self):
        """Test that voice configuration can load from configuration file."""
        if VoiceConfig is None:
            pytest.skip("VoiceConfig not implemented yet")
            
        # Create temporary config file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.env', delete=False) as f:
            f.write('PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw\n')
            f.write('VOICE_QUALITY=ultra_high\n')
            temp_file = f.name
        
        try:
            # Test loading from file
            config = VoiceConfig(_env_file=temp_file)
            assert config.production_voice_id == "ZF6FPAbjXT4488VcRRnw"
            assert config.voice_quality == "ultra_high"
        finally:
            Path(temp_file).unlink()

    def test_voice_inventory_management(self):
        """Test that voice inventory is properly managed."""
        if VoiceConfig is None:
            pytest.skip("VoiceConfig not implemented yet")
            
        config = VoiceConfig()
        assert hasattr(config, 'voice_inventory')
        assert 'primary' in config.voice_inventory
        assert 'backup' in config.voice_inventory
        assert 'testing' in config.voice_inventory
        assert config.voice_inventory['primary'] == "ZF6FPAbjXT4488VcRRnw"