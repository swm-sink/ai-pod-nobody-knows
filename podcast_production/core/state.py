"""
Core state management for LangGraph-based podcast production.

This module defines the central PodcastState TypedDict that flows through
the entire workflow, ensuring type safety and consistent data structure.

Version: 1.0.0
Date: August 2025
"""

from typing import Dict, List, Any, Optional, TypedDict
from datetime import datetime
import uuid
import logging

# Import security sanitization functions (August 2025 - integrated security)
try:
    from .security import sanitize_topic
    SECURITY_AVAILABLE = True
except ImportError:
    # Fallback if security module not available
    SECURITY_AVAILABLE = False
    logging.warning("Security module not available - topic sanitization disabled")
    
    def sanitize_topic(topic: str, max_length: int = 200) -> str:
        """Fallback sanitization - basic clean only."""
        return ' '.join(topic.split())[:max_length]


class PodcastState(TypedDict, total=False):
    """
    Central state structure for podcast production workflow.
    
    This TypedDict flows through all LangGraph nodes, accumulating
    data and tracking progress throughout the production pipeline.
    
    Version Tracking (August 2025):
    - schema_version: State structure version for migration support
    - created_at: Initial state creation timestamp  
    - updated_at: Last modification timestamp
    """
    
    # Version tracking (August 2025 - for state migration)
    schema_version: str
    created_at: str
    updated_at: str
    
    # Episode identification
    episode_id: str
    topic: str
    timestamp: str
    
    # Research data - 4-stage pipeline
    research_discovery: Dict[str, Any]
    research_deep_dive: Dict[str, Any] 
    research_validation: Dict[str, Any]
    research_synthesis: Dict[str, Any]
    research_questions: List[str]
    
    # Production data
    episode_plan: Dict[str, Any]
    script_raw: str
    script_polished: str
    
    # Audio data
    audio_config: Dict[str, Any]
    audio_file_path: str
    
    # Quality & Cost tracking (August 2025 - serializable only)
    quality_scores: Dict[str, Any]
    cost_data: Dict[str, Any]  # Serialized CostTracker data (from to_dict())
    total_cost: float
    
    # Workflow control
    current_stage: str
    errors: List[Dict[str, Any]]
    retry_count: int
    
    # Additional workflow data
    research_data: Dict[str, Any]
    research_sources: List[Dict[str, Any]]
    research_queries: List[str]
    cost_breakdown: Dict[str, float]
    error_log: List[str]
    
    # Configuration
    budget_limit: float
    output_directory: str
    dry_run: bool
    verbose: bool


def create_initial_state(
    topic: str,
    budget: float = 5.51,
    output_dir: str = "./output",
    dry_run: bool = False,
    verbose: bool = False
) -> PodcastState:
    """
    Create initial state for podcast production workflow with integrated security.
    
    Args:
        topic: The podcast episode topic (will be sanitized for security)
        budget: Maximum budget for production
        output_dir: Directory for output files
        dry_run: If True, don't make actual API calls
        verbose: Enable verbose logging
        
    Returns:
        Initialized PodcastState with version tracking and sanitized topic
        
    Raises:
        ValueError: If topic is invalid after sanitization
    """
    # Sanitize topic for security (August 2025 - integrated security)
    try:
        sanitized_topic = sanitize_topic(topic)
        if verbose:
            logging.info(f"Topic sanitized: '{topic}' -> '{sanitized_topic}'")
    except ValueError as e:
        # Topic is too short or invalid after sanitization
        raise ValueError(f"Invalid topic: {e}")
    
    episode_id = f"ep_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:8]}"
    timestamp = datetime.now().isoformat()
    
    return PodcastState(
        # Version tracking (August 2025)
        schema_version="1.1.0",  # Incremented for version tracking addition
        created_at=timestamp,
        updated_at=timestamp,
        
        # Episode identification  
        episode_id=episode_id,
        topic=sanitized_topic,  # Store sanitized topic for security
        timestamp=timestamp,
        
        # Research data - initialize empty
        research_discovery={},
        research_deep_dive={},
        research_validation={},
        research_synthesis={},
        research_questions=[],
        
        # Production data - initialize empty
        episode_plan={},
        script_raw="",
        script_polished="",
        
        # Audio data - initialize empty
        audio_config={},
        audio_file_path="",
        
        # Quality & Cost tracking
        quality_scores={},
        cost_data={},  # Will store serialized CostTracker data
        total_cost=0.0,
        
        # Workflow control
        current_stage="initialized",
        errors=[],
        retry_count=0,
        
        # Additional workflow data
        research_data={},
        research_sources=[],
        research_queries=[],
        cost_breakdown={},
        error_log=[],
        
        # Configuration
        budget_limit=budget,
        output_directory=output_dir,
        dry_run=dry_run,
        verbose=verbose
    )


def update_stage(state: PodcastState, stage: str, data: Dict[str, Any] = None) -> PodcastState:
    """
    Update workflow stage and optionally merge additional data.
    
    Args:
        state: Current podcast state
        stage: New stage name
        data: Optional additional data to merge
        
    Returns:
        Updated state with timestamp
    """
    state["current_stage"] = stage
    state["updated_at"] = datetime.now().isoformat()  # Version tracking update
    
    if data:
        # Merge additional data into state
        for key, value in data.items():
            if key in state:
                if isinstance(state[key], dict) and isinstance(value, dict):
                    state[key].update(value)
                else:
                    state[key] = value
            else:
                state[key] = value
    
    return state


def add_error(state: PodcastState, error: str, stage: str = None) -> PodcastState:
    """
    Add error to state tracking.
    
    Args:
        state: Current podcast state
        error: Error message
        stage: Optional stage where error occurred
        
    Returns:
        Updated state with error logged and timestamp
    """
    error_entry = {
        "timestamp": datetime.now().isoformat(),
        "stage": stage or state.get("current_stage", "unknown"),
        "error": error
    }
    
    state["errors"].append(error_entry)
    state["error_log"].append(f"[{stage or 'unknown'}] {error}")
    state["updated_at"] = datetime.now().isoformat()  # Version tracking update
    
    return state


def update_cost(state: PodcastState, stage: str, cost: float) -> PodcastState:
    """
    Update cost tracking for a specific stage.
    
    Args:
        state: Current podcast state
        stage: Stage that incurred the cost
        cost: Cost amount
        
    Returns:
        Updated state with cost information and timestamp
    """
    if "cost_breakdown" not in state:
        state["cost_breakdown"] = {}
    
    state["cost_breakdown"][stage] = cost
    state["total_cost"] = sum(state["cost_breakdown"].values())
    
    # Update cost data with metadata (August 2025 - serializable)
    state["cost_data"]["last_updated"] = datetime.now().isoformat()
    state["cost_data"]["budget_remaining"] = state.get("budget_limit", 5.51) - state["total_cost"]
    state["cost_data"]["budget_used_percent"] = (state["total_cost"] / state.get("budget_limit", 5.51)) * 100
    
    state["updated_at"] = datetime.now().isoformat()  # Version tracking update
    
    return state


def is_over_budget(state: PodcastState) -> bool:
    """
    Check if current costs exceed budget limit.
    
    Args:
        state: Current podcast state
        
    Returns:
        True if over budget
    """
    return state["total_cost"] > state.get("budget_limit", 5.51)


def get_stage_data(state: PodcastState, stage: str) -> Dict[str, Any]:
    """
    Get data for a specific workflow stage.
    
    Args:
        state: Current podcast state
        stage: Stage name to retrieve data for
        
    Returns:
        Stage-specific data or empty dict if not found
    """
    stage_mapping = {
        "discovery": "research_discovery",
        "deep_dive": "research_deep_dive", 
        "validation": "research_validation",
        "synthesis": "research_synthesis",
        "planning": "episode_plan",
        "writing": "script_raw",
        "polishing": "script_polished",
        "audio": "audio_config"
    }
    
    field = stage_mapping.get(stage)
    if field and field in state:
        return state[field]
    
    return {}


def validate_state(state: PodcastState) -> List[str]:
    """
    Validate state integrity and completeness including version tracking.
    
    Args:
        state: State to validate
        
    Returns:
        List of validation errors (empty if valid)
    """
    errors = []
    
    # Required fields (including version tracking)
    required_fields = ["episode_id", "topic", "timestamp", "schema_version", "created_at", "updated_at"]
    for field in required_fields:
        if field not in state or not state[field]:
            errors.append(f"Missing required field: {field}")
    
    # Version validation (August 2025)
    schema_version = state.get("schema_version")
    if schema_version:
        try:
            # Basic semantic version validation (e.g., "1.1.0")
            parts = schema_version.split('.')
            if len(parts) != 3 or not all(part.isdigit() for part in parts):
                errors.append(f"Invalid schema version format: {schema_version}")
        except Exception:
            errors.append(f"Invalid schema version: {schema_version}")
    
    # Timestamp validation
    timestamp_fields = ["created_at", "updated_at", "timestamp"]
    for field in timestamp_fields:
        if field in state and state[field]:
            try:
                datetime.fromisoformat(state[field].replace('Z', '+00:00'))
            except ValueError:
                errors.append(f"Invalid timestamp format for {field}: {state[field]}")
    
    # Logical timestamp validation
    if "created_at" in state and "updated_at" in state and state["created_at"] and state["updated_at"]:
        try:
            created = datetime.fromisoformat(state["created_at"].replace('Z', '+00:00'))
            updated = datetime.fromisoformat(state["updated_at"].replace('Z', '+00:00'))
            if updated < created:
                errors.append("updated_at cannot be earlier than created_at")
        except ValueError:
            pass  # Already caught by timestamp format validation
    
    # Budget validation
    if state.get("total_cost", 0) < 0:
        errors.append("Total cost cannot be negative")
    
    if state.get("budget_limit", 0) <= 0:
        errors.append("Budget limit must be positive")
    
    # Stage validation
    valid_stages = [
        "initialized", "discovery", "deep_dive", "validation", 
        "synthesis", "planning", "writing", "polishing", 
        "audio_generation", "quality_check", "completed", "failed"
    ]
    
    current_stage = state.get("current_stage")
    if current_stage and current_stage not in valid_stages:
        errors.append(f"Invalid stage: {current_stage}")
    
    return errors


def migrate_state(state: PodcastState) -> PodcastState:
    """
    Migrate state to current schema version with backward compatibility.
    
    Args:
        state: State to migrate (may be older version)
        
    Returns:
        Migrated state with current schema version
        
    Note:
        This function ensures backward compatibility when state structure changes.
        Migration is idempotent - running it multiple times is safe.
    """
    current_version = "1.1.0"
    state_version = state.get("schema_version", "1.0.0")  # Default to 1.0.0 if missing
    
    # If already current version, no migration needed
    if state_version == current_version:
        return state
    
    # Migration from 1.0.0 to 1.1.0 (added version tracking)
    if state_version == "1.0.0":
        timestamp = datetime.now().isoformat()
        
        # Add missing version tracking fields
        if "schema_version" not in state:
            state["schema_version"] = current_version
        if "created_at" not in state:
            # Use existing timestamp if available, otherwise use current time
            state["created_at"] = state.get("timestamp", timestamp)
        if "updated_at" not in state:
            state["updated_at"] = timestamp
            
        logging.info(f"Migrated state from {state_version} to {current_version}")
        return state
    
    # Handle unknown versions
    if state_version != current_version:
        logging.warning(f"Unknown state version {state_version}, updating to {current_version}")
        state["schema_version"] = current_version
        state["updated_at"] = datetime.now().isoformat()
        
        # Ensure required version fields exist
        if "created_at" not in state:
            state["created_at"] = state.get("timestamp", datetime.now().isoformat())
    
    return state


def get_state_version(state: PodcastState) -> str:
    """
    Get the schema version of a state.
    
    Args:
        state: State to check
        
    Returns:
        Schema version string, defaults to "1.0.0" if not found
    """
    return state.get("schema_version", "1.0.0")


def is_state_current(state: PodcastState) -> bool:
    """
    Check if state is at current schema version.
    
    Args:
        state: State to check
        
    Returns:
        True if state is at current version
    """
    return get_state_version(state) == "1.1.0"