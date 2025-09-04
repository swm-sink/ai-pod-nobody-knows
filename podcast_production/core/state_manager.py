"""
State Manager - August 2025 Best Practices Implementation
Handles validation, versioning, and persistent/transient state separation.

Based on LangGraph Platform GA patterns and enterprise-grade state management.
"""

from typing import Dict, Any, Optional, List, Tuple, TypeVar, Generic
from dataclasses import dataclass, field, asdict
from datetime import datetime
from enum import Enum
import json
import hashlib
from pathlib import Path
import logging

# Pydantic for validation (August 2025 standard)
from pydantic import BaseModel, Field, validator, ValidationError

# Version tracking
from packaging import version

logger = logging.getLogger(__name__)

# Current state schema version
CURRENT_STATE_VERSION = "2.0.0"

class StateCategory(Enum):
    """Categories for state classification."""
    PERSISTENT = "persistent"   # Conversation history, user metadata, outcomes
    TRANSIENT = "transient"     # Step-local computation, temp variables
    CHECKPOINT = "checkpoint"   # Recovery points
    ARCHIVE = "archive"         # Historical data for audit


class StateValidationError(Exception):
    """Raised when state validation fails."""
    pass


class StateMigrationError(Exception):
    """Raised when state migration fails."""
    pass


# Pydantic models for validation
class PersistentState(BaseModel):
    """Persistent state that survives across sessions."""
    episode_id: str
    topic: str
    budget_limit: float = Field(gt=0)
    created_at: datetime
    updated_at: datetime
    
    # Core persistent data
    research_data: Dict[str, Any] = {}
    script_content: Optional[str] = None
    audio_file_path: Optional[str] = None
    quality_scores: Dict[str, float] = {}
    cost_breakdown: Dict[str, float] = {}
    
    # Workflow status
    current_stage: str = "initialized"
    completed_stages: List[str] = []
    
    # Metadata
    metadata: Dict[str, Any] = {}
    
    @validator('episode_id')
    def validate_episode_id(cls, v):
        if not v or len(v) < 5:
            raise ValueError('Episode ID must be at least 5 characters')
        return v
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class TransientState(BaseModel):
    """Transient state for in-flight operations."""
    active_agent: Optional[str] = None
    retry_count: int = 0
    temp_results: Dict[str, Any] = {}
    error_context: List[Dict[str, Any]] = []
    cache_keys: List[str] = []
    
    # Performance metrics (not persisted)
    processing_time_ms: Optional[int] = None
    memory_usage_mb: Optional[float] = None
    
    class Config:
        arbitrary_types_allowed = True


@dataclass
class StateSnapshot:
    """Immutable snapshot of state at a point in time."""
    version: str
    timestamp: datetime
    persistent: Dict[str, Any]
    transient: Dict[str, Any]
    checksum: str
    
    def verify_integrity(self) -> bool:
        """Verify snapshot integrity via checksum."""
        computed = self._compute_checksum()
        return computed == self.checksum
    
    def _compute_checksum(self) -> str:
        """Compute SHA256 checksum of state data."""
        data = json.dumps({
            'version': self.version,
            'timestamp': self.timestamp.isoformat(),
            'persistent': self.persistent,
            'transient': self.transient
        }, sort_keys=True, default=self._json_serial)
        return hashlib.sha256(data.encode()).hexdigest()
    
    def _json_serial(self, obj):
        """JSON serializer for datetime objects."""
        if isinstance(obj, datetime):
            return obj.isoformat()
        raise TypeError(f"Type {type(obj)} not serializable")


class StateManager:
    """
    Centralized state management following August 2025 best practices.
    
    Features:
    - Schema validation with Pydantic
    - Version tracking and migration
    - Persistent vs transient separation
    - Checkpointing and recovery
    - State size monitoring
    - Audit trail
    """
    
    def __init__(
        self,
        initial_state: Optional[Dict[str, Any]] = None,
        version: str = CURRENT_STATE_VERSION,
        max_state_size_mb: float = 10.0,
        enable_checkpointing: bool = True,
        checkpoint_dir: Optional[Path] = None
    ):
        """Initialize StateManager with optional initial state."""
        self.version = version
        self.max_state_size_mb = max_state_size_mb
        self.enable_checkpointing = enable_checkpointing
        self.checkpoint_dir = checkpoint_dir or Path("./checkpoints")
        
        # Initialize states
        self.persistent_state: Optional[PersistentState] = None
        self.transient_state: TransientState = TransientState()
        
        # State history for audit
        self.state_history: List[StateSnapshot] = []
        self.max_history_size = 100
        
        # Migration handlers
        self.migration_handlers = {
            "1.0.0": self._migrate_v1_to_v2,
            # Add more migration handlers as needed
        }
        
        if initial_state:
            self.load_state(initial_state)
        
        logger.info(f"StateManager initialized with version {self.version}")
    
    def load_state(self, state_dict: Dict[str, Any]) -> None:
        """Load and validate state from dictionary."""
        try:
            # Check version and migrate if needed
            state_version = state_dict.get('version', '1.0.0')
            if state_version != self.version:
                state_dict = self._migrate_state(state_dict, state_version)
            
            # Separate persistent and transient
            persistent_data = state_dict.get('persistent', {})
            transient_data = state_dict.get('transient', {})
            
            # Validate and load persistent state
            self.persistent_state = PersistentState(**persistent_data)
            
            # Load transient state (less strict validation)
            self.transient_state = TransientState(**transient_data)
            
            # Check state size
            self._check_state_size()
            
            # Create snapshot
            if self.enable_checkpointing:
                self._create_snapshot()
            
            logger.info(f"State loaded successfully for episode {self.persistent_state.episode_id}")
            
        except ValidationError as e:
            logger.error(f"State validation failed: {e}")
            raise StateValidationError(f"Invalid state: {e}")
        except Exception as e:
            logger.error(f"State loading failed: {e}")
            raise
    
    def get_state(self, include_transient: bool = True) -> Dict[str, Any]:
        """Get current state as dictionary."""
        if not self.persistent_state:
            raise ValueError("No state loaded")
        
        state = {
            'version': self.version,
            'persistent': self.persistent_state.model_dump()
        }
        
        if include_transient:
            state['transient'] = self.transient_state.model_dump()
        
        return state
    
    def update_persistent(self, updates: Dict[str, Any]) -> None:
        """Update persistent state with validation."""
        if not self.persistent_state:
            raise ValueError("No state loaded")
        
        try:
            # Create updated state
            current_data = self.persistent_state.model_dump()
            current_data.update(updates)
            current_data['updated_at'] = datetime.now()
            
            # Validate
            self.persistent_state = PersistentState(**current_data)
            
            # Check size
            self._check_state_size()
            
            # Checkpoint if enabled
            if self.enable_checkpointing:
                self._create_snapshot()
            
            logger.debug(f"Persistent state updated: {list(updates.keys())}")
            
        except ValidationError as e:
            logger.error(f"Update validation failed: {e}")
            raise StateValidationError(f"Invalid update: {e}")
    
    def update_transient(self, updates: Dict[str, Any]) -> None:
        """Update transient state (no persistence)."""
        try:
            current_data = self.transient_state.model_dump()
            current_data.update(updates)
            self.transient_state = TransientState(**current_data)
            logger.debug(f"Transient state updated: {list(updates.keys())}")
        except ValidationError as e:
            logger.error(f"Transient update failed: {e}")
            raise StateValidationError(f"Invalid transient update: {e}")
    
    def clear_transient(self) -> None:
        """Clear all transient state."""
        self.transient_state = TransientState()
        logger.debug("Transient state cleared")
    
    def checkpoint(self) -> str:
        """Create a checkpoint and return checkpoint ID."""
        if not self.persistent_state:
            raise ValueError("No state to checkpoint")
        
        snapshot = self._create_snapshot()
        checkpoint_id = f"checkpoint_{snapshot.timestamp.isoformat()}"
        
        # Save to disk
        checkpoint_path = self.checkpoint_dir / f"{checkpoint_id}.json"
        checkpoint_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(checkpoint_path, 'w') as f:
            json.dump({
                'version': snapshot.version,
                'timestamp': snapshot.timestamp.isoformat(),
                'persistent': snapshot.persistent,
                'transient': snapshot.transient,
                'checksum': snapshot.checksum
            }, f, indent=2)
        
        logger.info(f"Checkpoint created: {checkpoint_id}")
        return checkpoint_id
    
    def restore_checkpoint(self, checkpoint_id: str) -> None:
        """Restore state from checkpoint."""
        checkpoint_path = self.checkpoint_dir / f"{checkpoint_id}.json"
        
        if not checkpoint_path.exists():
            raise FileNotFoundError(f"Checkpoint not found: {checkpoint_id}")
        
        with open(checkpoint_path, 'r') as f:
            checkpoint_data = json.load(f)
        
        # Verify integrity
        snapshot = StateSnapshot(
            version=checkpoint_data['version'],
            timestamp=datetime.fromisoformat(checkpoint_data['timestamp']),
            persistent=checkpoint_data['persistent'],
            transient=checkpoint_data['transient'],
            checksum=checkpoint_data['checksum']
        )
        
        if not snapshot.verify_integrity():
            raise StateMigrationError(f"Checkpoint integrity check failed: {checkpoint_id}")
        
        # Restore state
        self.load_state({
            'version': snapshot.version,
            'persistent': snapshot.persistent,
            'transient': snapshot.transient
        })
        
        logger.info(f"State restored from checkpoint: {checkpoint_id}")
    
    def get_state_size_mb(self) -> float:
        """Get current state size in MB."""
        # Use model_dump for Pydantic v2 compatibility and handle datetime serialization
        state_dict = {
            'version': self.version,
            'persistent': self.persistent_state.model_dump() if self.persistent_state else {},
            'transient': self.transient_state.model_dump()
        }
        
        # Convert datetime objects for JSON serialization
        state_json = json.dumps(state_dict, default=self._json_serial)
        size_bytes = len(state_json.encode('utf-8'))
        return size_bytes / (1024 * 1024)
    
    def _json_serial(self, obj):
        """JSON serializer for datetime objects."""
        if isinstance(obj, datetime):
            return obj.isoformat()
        raise TypeError(f"Type {type(obj)} not serializable")
    
    def prune_history(self, keep_last: int = 50) -> None:
        """Prune state history to prevent memory bloat."""
        if len(self.state_history) > keep_last:
            self.state_history = self.state_history[-keep_last:]
            logger.info(f"State history pruned to last {keep_last} entries")
    
    def _check_state_size(self) -> None:
        """Check if state size exceeds limits."""
        size_mb = self.get_state_size_mb()
        if size_mb > self.max_state_size_mb:
            logger.warning(f"State size ({size_mb:.2f}MB) exceeds limit ({self.max_state_size_mb}MB)")
            # Could trigger archival or pruning here
    
    def _create_snapshot(self) -> StateSnapshot:
        """Create immutable snapshot of current state."""
        if not self.persistent_state:
            raise ValueError("No state to snapshot")
        
        snapshot = StateSnapshot(
            version=self.version,
            timestamp=datetime.now(),
            persistent=self.persistent_state.model_dump(),
            transient=self.transient_state.model_dump(),
            checksum=""  # Will be computed
        )
        snapshot.checksum = snapshot._compute_checksum()
        
        # Add to history
        self.state_history.append(snapshot)
        
        # Prune if needed
        if len(self.state_history) > self.max_history_size:
            self.prune_history()
        
        return snapshot
    
    def _migrate_state(self, state_dict: Dict[str, Any], from_version: str) -> Dict[str, Any]:
        """Migrate state from older version to current."""
        logger.info(f"Migrating state from v{from_version} to v{self.version}")
        
        current = from_version
        target = self.version
        
        # Apply migrations sequentially
        while current != target:
            if current in self.migration_handlers:
                state_dict = self.migration_handlers[current](state_dict)
                # Update version after migration
                current = state_dict.get('version', current)
            else:
                raise StateMigrationError(f"No migration path from {current} to {target}")
        
        return state_dict
    
    def _migrate_v1_to_v2(self, state_dict: Dict[str, Any]) -> Dict[str, Any]:
        """Migrate from v1.0.0 to v2.0.0 format."""
        # Example migration: restructure state into persistent/transient
        migrated = {
            'version': '2.0.0',
            'persistent': {},
            'transient': {}
        }
        
        # Map old fields to new structure
        persistent_fields = [
            'episode_id', 'topic', 'budget_limit', 'research_data',
            'script_content', 'audio_file_path', 'quality_scores',
            'cost_breakdown', 'current_stage', 'completed_stages'
        ]
        
        transient_fields = [
            'active_agent', 'retry_count', 'temp_results', 'error_context'
        ]
        
        for field in persistent_fields:
            if field in state_dict:
                migrated['persistent'][field] = state_dict[field]
        
        for field in transient_fields:
            if field in state_dict:
                migrated['transient'][field] = state_dict[field]
        
        # Add required new fields
        migrated['persistent']['created_at'] = state_dict.get('created_at', datetime.now())
        migrated['persistent']['updated_at'] = datetime.now()
        migrated['persistent']['metadata'] = state_dict.get('metadata', {})
        
        logger.info("Migration v1.0.0 -> v2.0.0 completed")
        return migrated


# Factory function
def create_state_manager(
    episode_id: str,
    topic: str,
    budget: float = 5.51,
    **kwargs
) -> StateManager:
    """Create a new StateManager with initial state."""
    initial_state = {
        'version': CURRENT_STATE_VERSION,
        'persistent': {
            'episode_id': episode_id,
            'topic': topic,
            'budget_limit': budget,
            'created_at': datetime.now(),
            'updated_at': datetime.now(),
            'current_stage': 'initialized',
            'completed_stages': [],
            'research_data': {},
            'cost_breakdown': {},
            'quality_scores': {},
            'metadata': kwargs
        },
        'transient': {
            'active_agent': None,
            'retry_count': 0,
            'temp_results': {},
            'error_context': []
        }
    }
    
    return StateManager(initial_state=initial_state)