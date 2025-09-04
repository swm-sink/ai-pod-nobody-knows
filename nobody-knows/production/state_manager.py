#!/usr/bin/env python3
"""
Production State Manager - Core state management for AI Podcast System
Implements session tracking, checkpoint/recovery, and episode lifecycle management.

Zero Training Data Policy: This system only works with current, verified information.
"""

import json
import os
from datetime import datetime
from typing import Dict, Any, Optional, List
import glob
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ProductionStateManager:
    """
    Manages state for the AI Podcast Production System
    
    Features:
    - Episode session lifecycle management
    - Checkpoint/recovery system
    - Cost tracking per episode and globally
    - Phase status management (research, script, audio)
    """
    
    def __init__(self, state_file: str = "nobody-knows/production/state.json"):
        self.state_file = state_file
        self.state = {}
        self.load_state()
        
    def load_state(self):
        """Load global state from JSON file"""
        try:
            if os.path.exists(self.state_file):
                with open(self.state_file, 'r') as f:
                    self.state = json.load(f)
                    logger.info(f"Loaded state: {len(self.state.get('active_episodes', {}))} active episodes")
            else:
                # Initialize with default state
                self.state = {
                    "version": "3.0.0",
                    "active_episodes": {},
                    "completed_episodes": {},
                    "total_cost": 0.0,
                    "last_updated": datetime.now().isoformat()
                }
                self.save_state()
                logger.info("Initialized new state file")
        except Exception as e:
            logger.error(f"Failed to load state: {e}")
            raise
            
    def save_state(self):
        """Save global state to JSON file"""
        try:
            self.state["last_updated"] = datetime.now().isoformat()
            with open(self.state_file, 'w') as f:
                json.dump(self.state, f, indent=2)
            logger.info("State saved successfully")
        except Exception as e:
            logger.error(f"Failed to save state: {e}")
            raise
            
    def create_episode_session(self, episode_num: int, topic: str) -> str:
        """
        Create a new episode session with complete directory structure
        
        Args:
            episode_num: Episode number (e.g., 1, 2, 3)
            topic: Episode topic/title
            
        Returns:
            session_id: Unique session identifier
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        session_id = f"ep_{episode_num:03d}_{timestamp}"
        session_dir = f"nobody-knows/production/{session_id}"
        
        try:
            # Create directory structure
            os.makedirs(f"{session_dir}/research", exist_ok=True)
            os.makedirs(f"{session_dir}/script", exist_ok=True)
            os.makedirs(f"{session_dir}/audio", exist_ok=True)
            
            # Initialize episode state
            episode_state = {
                "episode_number": episode_num,
                "topic": topic,
                "session_id": session_id,
                "status": "initialized",
                "phases": {
                    "research": {"status": "pending", "cost": 0.0, "start_time": None, "end_time": None},
                    "script": {"status": "pending", "cost": 0.0, "start_time": None, "end_time": None},
                    "audio": {"status": "pending", "cost": 0.0, "start_time": None, "end_time": None}
                },
                "total_cost": 0.0,
                "quality_scores": {},
                "created_at": datetime.now().isoformat(),
                "checkpoints": [],
                "errors": []
            }
            
            # Save episode state
            episode_state_file = f"{session_dir}/state.json"
            with open(episode_state_file, 'w') as f:
                json.dump(episode_state, f, indent=2)
            
            # Update global state
            self.state["active_episodes"][str(episode_num)] = session_id
            self.save_state()
            
            logger.info(f"Created episode session: {session_id} for topic: {topic}")
            return session_id
            
        except Exception as e:
            logger.error(f"Failed to create episode session: {e}")
            raise
            
    def update_phase_status(self, session_id: str, phase: str, status: str, 
                           cost: Optional[float] = None, data: Optional[Dict] = None):
        """
        Update phase status for an episode
        
        Args:
            session_id: Episode session ID
            phase: Phase name (research, script, audio)
            status: New status (pending, active, completed, failed)
            cost: Optional cost to add
            data: Optional additional data to store
        """
        try:
            episode_state_file = f"nobody-knows/production/{session_id}/state.json"
            
            if not os.path.exists(episode_state_file):
                raise FileNotFoundError(f"Episode state file not found: {episode_state_file}")
            
            # Load episode state
            with open(episode_state_file, 'r') as f:
                episode_state = json.load(f)
            
            # Update phase
            if phase not in episode_state["phases"]:
                raise ValueError(f"Unknown phase: {phase}")
                
            episode_state["phases"][phase]["status"] = status
            
            if status == "active" and episode_state["phases"][phase]["start_time"] is None:
                episode_state["phases"][phase]["start_time"] = datetime.now().isoformat()
                
            if status in ["completed", "failed"]:
                episode_state["phases"][phase]["end_time"] = datetime.now().isoformat()
            
            if cost is not None:
                episode_state["phases"][phase]["cost"] += cost
                episode_state["total_cost"] += cost
                self.state["total_cost"] += cost
            
            if data:
                episode_state["phases"][phase]["data"] = data
            
            episode_state["last_updated"] = datetime.now().isoformat()
            
            # Save episode state
            with open(episode_state_file, 'w') as f:
                json.dump(episode_state, f, indent=2)
            
            # Save global state
            self.save_state()
            
            logger.info(f"Updated {session_id} phase {phase} to {status}")
            
        except Exception as e:
            logger.error(f"Failed to update phase status: {e}")
            raise
            
    def save_checkpoint(self, session_id: str, phase: str, data: Dict[str, Any]):
        """
        Save a checkpoint for recovery purposes
        
        Args:
            session_id: Episode session ID
            phase: Current phase
            data: Data to checkpoint
        """
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            checkpoint_file = f"nobody-knows/production/{session_id}/checkpoint_{phase}_{timestamp}.json"
            
            checkpoint = {
                "timestamp": datetime.now().isoformat(),
                "phase": phase,
                "session_id": session_id,
                "data": data
            }
            
            with open(checkpoint_file, 'w') as f:
                json.dump(checkpoint, f, indent=2)
            
            # Update episode state with checkpoint reference
            episode_state_file = f"nobody-knows/production/{session_id}/state.json"
            if os.path.exists(episode_state_file):
                with open(episode_state_file, 'r') as f:
                    episode_state = json.load(f)
                
                episode_state["checkpoints"].append({
                    "file": checkpoint_file,
                    "phase": phase,
                    "timestamp": datetime.now().isoformat()
                })
                
                with open(episode_state_file, 'w') as f:
                    json.dump(episode_state, f, indent=2)
            
            logger.info(f"Checkpoint saved: {checkpoint_file}")
            
        except Exception as e:
            logger.error(f"Failed to save checkpoint: {e}")
            raise
            
    def recover_from_checkpoint(self, session_id: str, phase: str) -> Optional[Dict[str, Any]]:
        """
        Recover from the latest checkpoint for a given phase
        
        Args:
            session_id: Episode session ID
            phase: Phase to recover
            
        Returns:
            Checkpoint data if found, None otherwise
        """
        try:
            # Find latest checkpoint for phase
            checkpoint_pattern = f"nobody-knows/production/{session_id}/checkpoint_{phase}_*.json"
            checkpoints = glob.glob(checkpoint_pattern)
            
            if not checkpoints:
                logger.warning(f"No checkpoints found for {session_id} phase {phase}")
                return None
            
            # Get the most recent checkpoint
            latest_checkpoint = sorted(checkpoints)[-1]
            
            with open(latest_checkpoint, 'r') as f:
                checkpoint_data = json.load(f)
            
            logger.info(f"Recovered from checkpoint: {latest_checkpoint}")
            return checkpoint_data["data"]
            
        except Exception as e:
            logger.error(f"Failed to recover from checkpoint: {e}")
            return None
            
    def complete_episode(self, session_id: str, final_outputs: Dict[str, Any]):
        """
        Mark episode as completed and move to completed_episodes
        
        Args:
            session_id: Episode session ID
            final_outputs: Final episode outputs (MP3 file, metrics, etc.)
        """
        try:
            episode_state_file = f"nobody-knows/production/{session_id}/state.json"
            
            if not os.path.exists(episode_state_file):
                raise FileNotFoundError(f"Episode state file not found: {episode_state_file}")
            
            # Load episode state
            with open(episode_state_file, 'r') as f:
                episode_state = json.load(f)
            
            episode_num = str(episode_state["episode_number"])
            
            # Update episode state
            episode_state["status"] = "completed"
            episode_state["completed_at"] = datetime.now().isoformat()
            episode_state["final_outputs"] = final_outputs
            
            # Save final episode state
            with open(episode_state_file, 'w') as f:
                json.dump(episode_state, f, indent=2)
            
            # Move from active to completed in global state
            if episode_num in self.state["active_episodes"]:
                del self.state["active_episodes"][episode_num]
                
            self.state["completed_episodes"][episode_num] = {
                "session_id": session_id,
                "completed_at": datetime.now().isoformat(),
                "cost": episode_state["total_cost"],
                "topic": episode_state["topic"]
            }
            
            self.save_state()
            logger.info(f"Episode {episode_num} completed successfully")
            
        except Exception as e:
            logger.error(f"Failed to complete episode: {e}")
            raise
            
    def get_episode_status(self, episode_num: int) -> Optional[Dict[str, Any]]:
        """
        Get current status of an episode
        
        Args:
            episode_num: Episode number
            
        Returns:
            Episode status information or None if not found
        """
        episode_key = str(episode_num)
        
        # Check active episodes
        if episode_key in self.state["active_episodes"]:
            session_id = self.state["active_episodes"][episode_key]
            episode_state_file = f"nobody-knows/production/{session_id}/state.json"
            
            if os.path.exists(episode_state_file):
                with open(episode_state_file, 'r') as f:
                    return json.load(f)
        
        # Check completed episodes
        if episode_key in self.state["completed_episodes"]:
            return self.state["completed_episodes"][episode_key]
            
        return None
        
    def list_active_episodes(self) -> List[Dict[str, Any]]:
        """List all active episodes with their status"""
        active = []
        
        for episode_num, session_id in self.state["active_episodes"].items():
            episode_state = self.get_episode_status(int(episode_num))
            if episode_state:
                active.append({
                    "episode_number": int(episode_num),
                    "session_id": session_id,
                    "topic": episode_state.get("topic", "Unknown"),
                    "status": episode_state.get("status", "Unknown"),
                    "cost": episode_state.get("total_cost", 0.0)
                })
        
        return active
        
    def get_dashboard_summary(self) -> Dict[str, Any]:
        """Get summary for production dashboard"""
        active_episodes = self.list_active_episodes()
        
        return {
            "timestamp": datetime.now().isoformat(),
            "active_episodes": len(active_episodes),
            "completed_episodes": len(self.state["completed_episodes"]),
            "total_cost": self.state["total_cost"],
            "active_details": active_episodes
        }


# Example usage and testing
if __name__ == "__main__":
    # Test the state manager
    print("🧪 Testing ProductionStateManager...")
    
    state_manager = ProductionStateManager()
    
    # Test creating an episode
    session_id = state_manager.create_episode_session(1, "The Science of Sleep and Dreams")
    print(f"✅ Created session: {session_id}")
    
    # Test updating phase status
    state_manager.update_phase_status(session_id, "research", "active")
    state_manager.update_phase_status(session_id, "research", "completed", cost=1.25)
    print("✅ Updated phase status")
    
    # Test checkpoint
    test_data = {"sources_found": 15, "experts_contacted": 8}
    state_manager.save_checkpoint(session_id, "research", test_data)
    print("✅ Saved checkpoint")
    
    # Test recovery
    recovered = state_manager.recover_from_checkpoint(session_id, "research")
    print(f"✅ Recovered checkpoint: {recovered}")
    
    # Test dashboard
    dashboard = state_manager.get_dashboard_summary()
    print("✅ Dashboard summary:")
    print(f"   Active: {dashboard['active_episodes']}")
    print(f"   Completed: {dashboard['completed_episodes']}")
    print(f"   Total Cost: ${dashboard['total_cost']:.2f}")
    
    print("\n🎉 State manager tests completed successfully!")
