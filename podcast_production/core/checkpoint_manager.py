"""
Checkpoint Management for LangGraph Workflow Resumption - August 2025
Handles workflow interruption, recovery, and resumption with state persistence.
"""

import asyncio
import json
import logging
import os
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List, Tuple
from pathlib import Path
from dataclasses import dataclass, asdict
from enum import Enum

try:
    from langgraph.checkpoint import BaseCheckpointer
    from langgraph.checkpoint.memory import MemorySaver
    from langgraph.checkpoint.postgres import PostgresSaver
    from langgraph.checkpoint.serde.jsonplus import JsonPlusSerializer
    LANGGRAPH_AVAILABLE = True
except ImportError:
    LANGGRAPH_AVAILABLE = False
    BaseCheckpointer = object

from core.state import PodcastState

# Database config removed during archival - using SQLite for simplicity
def get_postgres_connection_string() -> Optional[str]:
    """Archived - PostgreSQL support removed for simplicity."""
    return None

def is_postgres_configured() -> bool:
    """Archived - PostgreSQL support removed for simplicity."""
    return False

logger = logging.getLogger(__name__)


class CheckpointState(Enum):
    """States of workflow checkpoints."""
    ACTIVE = "active"          # Currently running
    PAUSED = "paused"          # Manually paused
    INTERRUPTED = "interrupted"  # Failed/crashed
    COMPLETED = "completed"    # Successfully finished
    ABANDONED = "abandoned"    # Manually abandoned


@dataclass
class CheckpointMetadata:
    """Metadata for workflow checkpoints."""
    episode_id: str
    thread_id: str
    checkpoint_id: str
    state: CheckpointState
    created_at: datetime
    updated_at: datetime
    current_node: Optional[str] = None
    progress_percentage: float = 0.0
    cost_so_far: float = 0.0
    errors: List[str] = None
    recovery_attempts: int = 0
    max_recovery_attempts: int = 3
    
    def __post_init__(self):
        if self.errors is None:
            self.errors = []


class CheckpointManager:
    """
    Manages workflow checkpoints for resumption and recovery.
    
    Features:
    - Automatic checkpoint saving at key workflow stages
    - Workflow interruption detection and recovery
    - Progress tracking and resumption from any point
    - Error handling with configurable retry policies
    - Production-grade persistence with PostgreSQL
    """
    
    def __init__(self, config: Dict[str, Any] = None):
        """
        Initialize checkpoint manager.
        
        Args:
            config: Configuration dictionary with checkpoint settings
        """
        self.config = config or self._get_default_config()
        self.checkpointer = self._create_checkpointer()
        self.metadata_store: Dict[str, CheckpointMetadata] = {}
        self.recovery_callbacks: Dict[str, callable] = {}
        
        # Local checkpoint directory for fallback
        self.local_checkpoint_dir = Path(self.config.get("local_dir", "checkpoints"))
        self.local_checkpoint_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"✅ CheckpointManager initialized with {type(self.checkpointer).__name__}")
    
    def _get_default_config(self) -> Dict[str, Any]:
        """Get default checkpoint configuration."""
        return {
            "auto_save_interval": 60,  # seconds
            "max_checkpoint_age": 86400,  # 24 hours
            "cleanup_old_checkpoints": True,
            "compression_enabled": True,
            "local_dir": "checkpoints",
            "recovery_timeout": 300,  # 5 minutes
            "enable_progress_tracking": True
        }
    
    def _create_checkpointer(self) -> BaseCheckpointer:
        """Create appropriate checkpointer for environment."""
        if not LANGGRAPH_AVAILABLE:
            logger.warning("⚠️ LangGraph not available - checkpoint management disabled")
            return None
        
        # Try PostgreSQL for production
        postgres_url = get_postgres_connection_string()
        if postgres_url and is_postgres_configured():
            try:
                serializer = JsonPlusSerializer(pickle_fallback=True)
                checkpointer = PostgresSaver(
                    connection_string=postgres_url,
                    serde=serializer
                )
                logger.info("🗄️ Using PostgreSQL checkpointer for production persistence")
                return checkpointer
            except Exception as e:
                logger.error(f"❌ Failed to create PostgreSQL checkpointer: {e}")
        
        # Fallback to MemorySaver with enhanced serialization
        try:
            serializer = JsonPlusSerializer(pickle_fallback=True)
            checkpointer = MemorySaver(serde=serializer)
            logger.info("🧠 Using MemorySaver checkpointer for development")
            return checkpointer
        except Exception as e:
            logger.error(f"❌ Failed to create MemorySaver: {e}")
            return None
    
    async def save_checkpoint(
        self, 
        thread_id: str,
        state: PodcastState,
        current_node: str = None,
        progress: float = 0.0
    ) -> str:
        """
        Save workflow checkpoint.
        
        Args:
            thread_id: Thread identifier for the workflow
            state: Current workflow state
            current_node: Currently executing node
            progress: Progress percentage (0.0-1.0)
            
        Returns:
            Checkpoint ID
        """
        if not self.checkpointer:
            logger.warning("⚠️ No checkpointer available - cannot save checkpoint")
            return None
        
        try:
            checkpoint_id = f"cp_{datetime.now().strftime('%Y%m%d_%H%M%S_%f')}"
            
            # Create metadata
            metadata = CheckpointMetadata(
                episode_id=state.get("episode_id", thread_id),
                thread_id=thread_id,
                checkpoint_id=checkpoint_id,
                state=CheckpointState.ACTIVE,
                created_at=datetime.now(),
                updated_at=datetime.now(),
                current_node=current_node,
                progress_percentage=progress,
                cost_so_far=state.get("total_cost", 0.0)
            )
            
            # Store metadata
            self.metadata_store[checkpoint_id] = metadata
            
            # Save to checkpointer
            config = {"configurable": {"thread_id": thread_id}}
            await self._save_with_fallback(thread_id, state, metadata, config)
            
            logger.info(f"💾 Checkpoint saved: {checkpoint_id} (progress: {progress:.1%})")
            return checkpoint_id
            
        except Exception as e:
            logger.error(f"❌ Failed to save checkpoint: {e}")
            return None
    
    async def _save_with_fallback(
        self, 
        thread_id: str, 
        state: PodcastState, 
        metadata: CheckpointMetadata,
        config: Dict[str, Any]
    ):
        """Save checkpoint with local fallback."""
        try:
            # Try primary checkpointer
            if hasattr(self.checkpointer, 'aput'):
                await self.checkpointer.aput(config, {}, state)
            else:
                self.checkpointer.put(config, {}, state)
            
        except Exception as e:
            logger.warning(f"⚠️ Primary checkpoint save failed: {e}. Using local fallback.")
            
            # Local fallback
            local_file = self.local_checkpoint_dir / f"{thread_id}_checkpoint.json"
            checkpoint_data = {
                "metadata": asdict(metadata),
                "state": dict(state),
                "saved_at": datetime.now().isoformat()
            }
            
            with open(local_file, 'w') as f:
                json.dump(checkpoint_data, f, indent=2, default=str)
            
            logger.info(f"💾 Checkpoint saved locally: {local_file}")
    
    async def load_checkpoint(
        self, 
        thread_id: str,
        checkpoint_id: str = None
    ) -> Tuple[Optional[PodcastState], Optional[CheckpointMetadata]]:
        """
        Load workflow checkpoint.
        
        Args:
            thread_id: Thread identifier
            checkpoint_id: Specific checkpoint ID (latest if None)
            
        Returns:
            Tuple of (state, metadata) or (None, None) if not found
        """
        if not self.checkpointer:
            logger.warning("⚠️ No checkpointer available - cannot load checkpoint")
            return await self._load_local_fallback(thread_id)
        
        try:
            config = {"configurable": {"thread_id": thread_id}}
            
            # Load from checkpointer
            if hasattr(self.checkpointer, 'aget'):
                checkpoint = await self.checkpointer.aget(config)
            else:
                checkpoint = self.checkpointer.get(config)
            
            if checkpoint:
                state = checkpoint.checkpoint
                # Look for metadata in our store
                metadata = None
                for cp_id, cp_meta in self.metadata_store.items():
                    if cp_meta.thread_id == thread_id:
                        if checkpoint_id is None or cp_id == checkpoint_id:
                            metadata = cp_meta
                            break
                
                logger.info(f"📂 Checkpoint loaded: {thread_id}")
                return state, metadata
            
        except Exception as e:
            logger.warning(f"⚠️ Primary checkpoint load failed: {e}. Trying local fallback.")
        
        # Try local fallback
        return await self._load_local_fallback(thread_id)
    
    async def _load_local_fallback(self, thread_id: str) -> Tuple[Optional[PodcastState], Optional[CheckpointMetadata]]:
        """Load checkpoint from local fallback."""
        local_file = self.local_checkpoint_dir / f"{thread_id}_checkpoint.json"
        
        if not local_file.exists():
            logger.info(f"📂 No checkpoint found for thread: {thread_id}")
            return None, None
        
        try:
            with open(local_file, 'r') as f:
                checkpoint_data = json.load(f)
            
            state = checkpoint_data["state"]
            metadata_dict = checkpoint_data["metadata"]
            
            # Reconstruct metadata object
            metadata_dict["created_at"] = datetime.fromisoformat(metadata_dict["created_at"])
            metadata_dict["updated_at"] = datetime.fromisoformat(metadata_dict["updated_at"])
            metadata_dict["state"] = CheckpointState(metadata_dict["state"])
            
            metadata = CheckpointMetadata(**metadata_dict)
            
            logger.info(f"📂 Local checkpoint loaded: {thread_id}")
            return state, metadata
            
        except Exception as e:
            logger.error(f"❌ Failed to load local checkpoint: {e}")
            return None, None
    
    async def resume_workflow(
        self, 
        thread_id: str,
        workflow_executor: callable,
        recovery_node: str = None
    ) -> Any:
        """
        Resume workflow from checkpoint.
        
        Args:
            thread_id: Thread identifier
            workflow_executor: Callable that can execute workflow from state
            recovery_node: Specific node to resume from (if known)
            
        Returns:
            Workflow execution result
        """
        state, metadata = await self.load_checkpoint(thread_id)
        
        if not state:
            raise ValueError(f"No checkpoint found for thread: {thread_id}")
        
        if not metadata:
            logger.warning("⚠️ No metadata found - creating default recovery metadata")
            metadata = CheckpointMetadata(
                episode_id=state.get("episode_id", thread_id),
                thread_id=thread_id,
                checkpoint_id=f"recovery_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
                state=CheckpointState.INTERRUPTED,
                created_at=datetime.now(),
                updated_at=datetime.now()
            )
        
        # Update metadata for resumption
        metadata.state = CheckpointState.ACTIVE
        metadata.recovery_attempts += 1
        metadata.updated_at = datetime.now()
        
        if metadata.recovery_attempts > metadata.max_recovery_attempts:
            logger.error(f"❌ Maximum recovery attempts exceeded for {thread_id}")
            metadata.state = CheckpointState.ABANDONED
            return None
        
        logger.info(
            f"🔄 Resuming workflow {thread_id} from {metadata.current_node or 'unknown'} "
            f"(attempt {metadata.recovery_attempts}/{metadata.max_recovery_attempts})"
        )
        
        try:
            # Execute recovery callback if available
            if thread_id in self.recovery_callbacks:
                await self.recovery_callbacks[thread_id](state, metadata)
            
            # Resume workflow execution
            result = await workflow_executor(state, recovery_node or metadata.current_node)
            
            # Mark as completed
            metadata.state = CheckpointState.COMPLETED
            metadata.updated_at = datetime.now()
            metadata.progress_percentage = 1.0
            
            # Save final checkpoint
            await self.save_checkpoint(thread_id, state, "COMPLETED", 1.0)
            
            logger.info(f"✅ Workflow {thread_id} resumed and completed successfully")
            return result
            
        except Exception as e:
            logger.error(f"❌ Workflow resumption failed: {e}")
            metadata.state = CheckpointState.INTERRUPTED
            metadata.errors.append(str(e))
            metadata.updated_at = datetime.now()
            raise
    
    def register_recovery_callback(self, thread_id: str, callback: callable):
        """
        Register recovery callback for workflow.
        
        Args:
            thread_id: Thread identifier
            callback: Async function to call before resuming
        """
        self.recovery_callbacks[thread_id] = callback
        logger.info(f"🔧 Recovery callback registered for {thread_id}")
    
    def mark_interrupted(self, thread_id: str, error: str):
        """Mark workflow as interrupted."""
        for checkpoint_id, metadata in self.metadata_store.items():
            if metadata.thread_id == thread_id and metadata.state == CheckpointState.ACTIVE:
                metadata.state = CheckpointState.INTERRUPTED
                metadata.errors.append(error)
                metadata.updated_at = datetime.now()
                logger.warning(f"⚠️ Workflow {thread_id} marked as interrupted: {error}")
                break
    
    def get_active_workflows(self) -> List[CheckpointMetadata]:
        """Get list of active workflows."""
        return [
            metadata for metadata in self.metadata_store.values()
            if metadata.state in [CheckpointState.ACTIVE, CheckpointState.PAUSED, CheckpointState.INTERRUPTED]
        ]
    
    def get_recoverable_workflows(self) -> List[CheckpointMetadata]:
        """Get list of workflows that can be recovered."""
        cutoff_time = datetime.now() - timedelta(hours=24)  # Only recent interruptions
        
        return [
            metadata for metadata in self.metadata_store.values()
            if (
                metadata.state == CheckpointState.INTERRUPTED and
                metadata.recovery_attempts < metadata.max_recovery_attempts and
                metadata.updated_at > cutoff_time
            )
        ]
    
    async def cleanup_old_checkpoints(self):
        """Clean up old checkpoints beyond retention period."""
        if not self.config.get("cleanup_old_checkpoints", True):
            return
        
        cutoff_time = datetime.now() - timedelta(seconds=self.config["max_checkpoint_age"])
        cleaned_count = 0
        
        # Clean metadata store
        to_remove = [
            cp_id for cp_id, metadata in self.metadata_store.items()
            if (
                metadata.updated_at < cutoff_time and
                metadata.state in [CheckpointState.COMPLETED, CheckpointState.ABANDONED]
            )
        ]
        
        for cp_id in to_remove:
            del self.metadata_store[cp_id]
            cleaned_count += 1
        
        # Clean local files
        for local_file in self.local_checkpoint_dir.glob("*_checkpoint.json"):
            if local_file.stat().st_mtime < cutoff_time.timestamp():
                local_file.unlink()
                cleaned_count += 1
        
        if cleaned_count > 0:
            logger.info(f"🧹 Cleaned up {cleaned_count} old checkpoints")
    
    def get_checkpoint_stats(self) -> Dict[str, Any]:
        """Get checkpoint statistics."""
        active_count = len([m for m in self.metadata_store.values() if m.state == CheckpointState.ACTIVE])
        interrupted_count = len([m for m in self.metadata_store.values() if m.state == CheckpointState.INTERRUPTED])
        completed_count = len([m for m in self.metadata_store.values() if m.state == CheckpointState.COMPLETED])
        
        return {
            "total_checkpoints": len(self.metadata_store),
            "active_workflows": active_count,
            "interrupted_workflows": interrupted_count,
            "completed_workflows": completed_count,
            "recoverable_workflows": len(self.get_recoverable_workflows()),
            "checkpointer_type": type(self.checkpointer).__name__ if self.checkpointer else "None",
            "local_checkpoint_dir": str(self.local_checkpoint_dir),
            "config": self.config
        }


# Global checkpoint manager instance
_global_checkpoint_manager = None


def get_checkpoint_manager(config: Dict[str, Any] = None) -> CheckpointManager:
    """Get global checkpoint manager instance."""
    global _global_checkpoint_manager
    if _global_checkpoint_manager is None:
        _global_checkpoint_manager = CheckpointManager(config)
    return _global_checkpoint_manager


async def create_workflow_checkpoint(
    thread_id: str,
    state: PodcastState,
    current_node: str = None,
    progress: float = 0.0
) -> str:
    """Convenience function to create checkpoint."""
    manager = get_checkpoint_manager()
    return await manager.save_checkpoint(thread_id, state, current_node, progress)


async def resume_workflow_from_checkpoint(
    thread_id: str,
    workflow_executor: callable,
    recovery_node: str = None
) -> Any:
    """Convenience function to resume workflow."""
    manager = get_checkpoint_manager()
    return await manager.resume_workflow(thread_id, workflow_executor, recovery_node)