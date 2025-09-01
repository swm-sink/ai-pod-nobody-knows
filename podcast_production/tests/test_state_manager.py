"""
Comprehensive StateManager Tests - August 2025 Best Practices
Tests all StateManager functionality including validation, versioning, 
migration, checkpointing, and error handling.
"""

import pytest
import tempfile
import json
import shutil
from pathlib import Path
from datetime import datetime, timedelta
from unittest.mock import patch, MagicMock

# Add project path
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from core.state_manager import (
    StateManager,
    PersistentState,
    TransientState,
    StateSnapshot,
    StateValidationError,
    StateMigrationError,
    create_state_manager,
    CURRENT_STATE_VERSION
)


class TestStateManager:
    """Comprehensive test suite for StateManager."""

    def setup_method(self):
        """Set up test environment."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.checkpoint_dir = self.temp_dir / "checkpoints"
        
        # Test data
        self.valid_episode_id = "test_episode_001"
        self.valid_topic = "Test Topic: AI State Management"
        self.valid_budget = 5.51

    def teardown_method(self):
        """Clean up test environment."""
        if self.temp_dir.exists():
            shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_create_state_manager_factory(self):
        """Test factory function creates valid StateManager."""
        # Act
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic,
            budget=self.valid_budget
        )
        
        # Assert
        assert manager is not None
        assert manager.persistent_state.episode_id == self.valid_episode_id
        assert manager.persistent_state.topic == self.valid_topic
        assert manager.persistent_state.budget_limit == self.valid_budget
        assert manager.version == CURRENT_STATE_VERSION

    def test_state_validation_success(self):
        """Test state validation with valid data."""
        # Arrange
        valid_state = {
            'version': CURRENT_STATE_VERSION,
            'persistent': {
                'episode_id': self.valid_episode_id,
                'topic': self.valid_topic,
                'budget_limit': self.valid_budget,
                'created_at': datetime.now(),
                'updated_at': datetime.now(),
                'current_stage': 'initialized',
                'completed_stages': []
            },
            'transient': {
                'retry_count': 0,
                'temp_results': {}
            }
        }
        
        # Act & Assert - should not raise
        manager = StateManager()
        manager.load_state(valid_state)
        
        assert manager.persistent_state.episode_id == self.valid_episode_id

    def test_state_validation_failure(self):
        """Test state validation with invalid data."""
        # Arrange - invalid episode_id (too short)
        invalid_state = {
            'version': CURRENT_STATE_VERSION,
            'persistent': {
                'episode_id': 'bad',  # Too short
                'topic': self.valid_topic,
                'budget_limit': self.valid_budget,
                'created_at': datetime.now(),
                'updated_at': datetime.now()
            }
        }
        
        # Act & Assert
        manager = StateManager()
        with pytest.raises(StateValidationError):
            manager.load_state(invalid_state)

    def test_persistent_state_update(self):
        """Test persistent state updates with validation."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        
        # Act
        updates = {
            'current_stage': 'research',
            'research_data': {'discovery': 'test data'}
        }
        manager.update_persistent(updates)
        
        # Assert
        state = manager.get_state()
        assert state['persistent']['current_stage'] == 'research'
        assert state['persistent']['research_data']['discovery'] == 'test data'
        
        # Check updated_at was set
        updated_at = datetime.fromisoformat(state['persistent']['updated_at'])
        assert updated_at > datetime.now() - timedelta(seconds=1)

    def test_transient_state_update(self):
        """Test transient state updates."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        
        # Act
        updates = {
            'active_agent': 'research-discovery',
            'temp_results': {'status': 'processing'}
        }
        manager.update_transient(updates)
        
        # Assert
        state = manager.get_state()
        assert state['transient']['active_agent'] == 'research-discovery'
        assert state['transient']['temp_results']['status'] == 'processing'

    def test_clear_transient_state(self):
        """Test clearing transient state."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        manager.update_transient({'temp_results': {'data': 'test'}})
        
        # Act
        manager.clear_transient()
        
        # Assert
        state = manager.get_state()
        assert state['transient']['temp_results'] == {}

    def test_checkpointing(self):
        """Test checkpoint creation and restoration."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        manager.checkpoint_dir = self.checkpoint_dir
        
        # Update state
        manager.update_persistent({'current_stage': 'research'})
        
        # Act - Create checkpoint
        checkpoint_id = manager.checkpoint()
        
        # Assert - Checkpoint file created
        checkpoint_files = list(self.checkpoint_dir.glob("*.json"))
        assert len(checkpoint_files) == 1
        assert checkpoint_id in checkpoint_files[0].name
        
        # Modify state
        manager.update_persistent({'current_stage': 'planning'})
        
        # Restore checkpoint
        manager.restore_checkpoint(checkpoint_id)
        
        # Assert state restored
        state = manager.get_state()
        assert state['persistent']['current_stage'] == 'research'

    def test_checkpoint_integrity_verification(self):
        """Test checkpoint integrity verification."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        manager.checkpoint_dir = self.checkpoint_dir
        
        # Create checkpoint
        checkpoint_id = manager.checkpoint()
        
        # Corrupt checkpoint file
        checkpoint_file = self.checkpoint_dir / f"{checkpoint_id}.json"
        with open(checkpoint_file, 'r') as f:
            data = json.load(f)
        
        # Change checksum to invalid value
        data['checksum'] = 'invalid_checksum'
        
        with open(checkpoint_file, 'w') as f:
            json.dump(data, f)
        
        # Act & Assert - Should fail integrity check
        with pytest.raises(StateMigrationError, match="integrity check failed"):
            manager.restore_checkpoint(checkpoint_id)

    def test_state_size_monitoring(self):
        """Test state size monitoring and limits."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        
        # Act
        size_mb = manager.get_state_size_mb()
        
        # Assert
        assert isinstance(size_mb, float)
        assert size_mb > 0
        assert size_mb < 1.0  # Should be small for test data

    def test_state_size_warning(self):
        """Test warning when state size exceeds limits."""
        # Arrange - Create manager with very small limit
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        manager.max_state_size_mb = 0.001  # Very small limit
        
        # Act & Assert - Should log warning but not fail
        with patch('core.state_manager.logger') as mock_logger:
            large_data = {'large_field': 'x' * 10000}  # Large data
            manager.update_persistent({'research_data': large_data})
            
            # Check warning was logged
            mock_logger.warning.assert_called_once()
            assert "exceeds limit" in str(mock_logger.warning.call_args)

    def test_migration_v1_to_v2(self):
        """Test migration from v1.0.0 to v2.0.0 format."""
        # Arrange - Create v1 format state
        v1_state = {
            'version': '1.0.0',
            'episode_id': self.valid_episode_id,
            'topic': self.valid_topic,
            'budget_limit': self.valid_budget,
            'current_stage': 'research',
            'active_agent': 'research-discovery',
            'retry_count': 1
        }
        
        # Act
        manager = StateManager()
        manager.load_state(v1_state)
        
        # Assert - Should be migrated to v2 format
        state = manager.get_state()
        assert state['version'] == CURRENT_STATE_VERSION
        assert state['persistent']['episode_id'] == self.valid_episode_id
        assert state['persistent']['current_stage'] == 'research'
        assert state['transient']['active_agent'] == 'research-discovery'
        assert state['transient']['retry_count'] == 1

    def test_migration_unknown_version_fails(self):
        """Test migration fails for unknown version."""
        # Arrange
        unknown_version_state = {
            'version': '999.0.0',  # Unknown version
            'episode_id': self.valid_episode_id
        }
        
        # Act & Assert
        manager = StateManager()
        with pytest.raises(StateMigrationError, match="No migration path"):
            manager.load_state(unknown_version_state)

    def test_state_snapshot_creation(self):
        """Test StateSnapshot creation and verification."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        
        # Act - Snapshot created automatically on updates
        manager.update_persistent({'current_stage': 'research'})
        
        # Assert
        assert len(manager.state_history) > 0
        snapshot = manager.state_history[-1]
        
        assert isinstance(snapshot, StateSnapshot)
        assert snapshot.version == CURRENT_STATE_VERSION
        assert snapshot.verify_integrity()  # Checksum should be valid

    def test_state_history_pruning(self):
        """Test state history pruning to prevent memory bloat."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        manager.max_history_size = 5  # Small limit for testing
        
        # Act - Create more snapshots than limit
        for i in range(10):
            manager.update_persistent({'current_stage': f'stage_{i}'})
        
        # Assert - History should be pruned
        assert len(manager.state_history) <= manager.max_history_size

    def test_error_context_tracking(self):
        """Test error context is properly tracked in transient state."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        
        # Act
        error_info = {
            'error_type': 'ValidationError',
            'message': 'Test error',
            'timestamp': datetime.now().isoformat()
        }
        manager.update_transient({'error_context': [error_info]})
        
        # Assert
        state = manager.get_state()
        assert len(state['transient']['error_context']) == 1
        assert state['transient']['error_context'][0]['error_type'] == 'ValidationError'

    def test_metadata_storage(self):
        """Test metadata can be stored and retrieved."""
        # Arrange & Act
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic,
            custom_field="test_value",
            environment="testing"
        )
        
        # Assert
        state = manager.get_state()
        assert state['persistent']['metadata']['custom_field'] == 'test_value'
        assert state['persistent']['metadata']['environment'] == 'testing'

    def test_get_state_exclude_transient(self):
        """Test getting state without transient data."""
        # Arrange
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        manager.update_transient({'temp_data': 'should_be_excluded'})
        
        # Act
        state_without_transient = manager.get_state(include_transient=False)
        
        # Assert
        assert 'transient' not in state_without_transient
        assert 'persistent' in state_without_transient
        assert state_without_transient['version'] == CURRENT_STATE_VERSION

    @patch('core.state_manager.logger')
    def test_logging_on_operations(self, mock_logger):
        """Test proper logging occurs during operations."""
        # Arrange & Act
        manager = create_state_manager(
            episode_id=self.valid_episode_id,
            topic=self.valid_topic
        )
        
        # Assert initialization logged
        mock_logger.info.assert_called_with(
            f"StateManager initialized with version {CURRENT_STATE_VERSION}"
        )
        
        # Test update logging
        manager.update_persistent({'current_stage': 'test'})
        mock_logger.debug.assert_called_with("Persistent state updated: ['current_stage']")


@pytest.mark.asyncio
class TestStateManagerAsync:
    """Tests for future async operations (August 2025 pattern)."""
    
    async def test_async_state_operations_pattern(self):
        """Test pattern for future async state operations."""
        # This test documents the pattern for when async operations are added
        # Currently StateManager is sync, but August 2025 best practices recommend async
        
        # Arrange
        manager = create_state_manager(
            episode_id="async_test_001",
            topic="Async State Test"
        )
        
        # Act - Simulate what async operations would look like
        # These would be: await manager.async_load_state(), etc.
        state = manager.get_state()
        
        # Assert
        assert state is not None
        
        # Document expected future async methods:
        # - async_load_state()
        # - async_checkpoint()
        # - async_restore_checkpoint()
        # - async_migrate_state()


if __name__ == "__main__":
    # Run tests with pytest
    pytest.main([__file__, "-v"])