#!/bin/bash

# Session Lifecycle Hook - Consolidated
# Combines: session management, error recovery, user prompts, cleanup
# Native Claude Code simplified architecture

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
SESSION_LOG="$PROJECT_ROOT/.claude/logs/session-summary.log"
ERROR_LOG="$PROJECT_ROOT/.claude/logs/error-recovery.log"
USER_LOG="$PROJECT_ROOT/.claude/logs/user-interactions.log"
STATE_DIR="$PROJECT_ROOT/.claude/state"
ARCHIVE_DIR="$PROJECT_ROOT/.claude/archives/$(date +%Y%m)"

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"
mkdir -p "$STATE_DIR"
mkdir -p "$ARCHIVE_DIR"

# =============================================================================
# SESSION INITIALIZATION
# =============================================================================

init_session() {
    local session_id="${1:-$(date +%s)}"
    local session_type="${2:-development}"
    
    # Create session state file
    cat > "$STATE_DIR/session-state.json" <<EOF
{
    "session_id": "$session_id",
    "type": "$session_type",
    "start_time": "$(date -Iseconds)",
    "status": "active",
    "total_cost": 0,
    "operations": 0,
    "errors": 0,
    "checkpoints": []
}
EOF
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SESSION STARTED: $session_id ($session_type)" >> "$SESSION_LOG"
    
    # Initialize cost tracking for session
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] === NEW SESSION: $session_id ===" >> "$PROJECT_ROOT/.claude/logs/cost-tracking.log"
}

# =============================================================================
# ERROR RECOVERY
# =============================================================================

handle_error() {
    local error_code="${1:-1}"
    local error_msg="${2:-Unknown error}"
    local recovery_action="${3:-retry}"
    
    # Log error
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Code=$error_code, Message=$error_msg" >> "$ERROR_LOG"
    
    # Update session state
    if [[ -f "$STATE_DIR/session-state.json" ]]; then
        # Increment error count (simple approach, in production use jq)
        local error_count=$(grep -o '"errors"[[:space:]]*:[[:space:]]*[0-9]*' "$STATE_DIR/session-state.json" | awk -F: '{print $2}' | tr -d ' ')
        ((error_count++))
        sed -i.bak "s/\"errors\"[[:space:]]*:[[:space:]]*[0-9]*/\"errors\": $error_count/" "$STATE_DIR/session-state.json"
    fi
    
    # Determine recovery action
    case "$recovery_action" in
        "retry")
            echo "[RECOVERY] Retrying operation..." >&2
            return 0
            ;;
        "skip")
            echo "[RECOVERY] Skipping operation..." >&2
            return 1
            ;;
        "abort")
            echo "[RECOVERY] Aborting session..." >&2
            cleanup_session "error"
            exit 1
            ;;
        *)
            echo "[RECOVERY] Continuing with caution..." >&2
            return 0
            ;;
    esac
}

# =============================================================================
# USER PROMPT HANDLING
# =============================================================================

handle_user_prompt() {
    local prompt_type="${1:-info}"
    local message="${2:-Processing...}"
    
    # Log user interaction
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] USER_PROMPT: Type=$prompt_type, Message=$message" >> "$USER_LOG"
    
    case "$prompt_type" in
        "cost_warning")
            echo "[COST WARNING] $message" >&2
            echo "Continue? (y/n): " >&2
            # In production, would wait for user input
            ;;
        "quality_gate")
            echo "[QUALITY GATE] $message" >&2
            # Log quality gate status
            ;;
        "progress")
            echo "[PROGRESS] $message" >&2
            ;;
        *)
            echo "[INFO] $message" >&2
            ;;
    esac
}

# =============================================================================
# CHECKPOINT MANAGEMENT
# =============================================================================

create_checkpoint() {
    local checkpoint_name="${1:-checkpoint_$(date +%s)}"
    local checkpoint_data="${2:-{}}"
    
    # Save checkpoint
    local checkpoint_file="$STATE_DIR/checkpoints/${checkpoint_name}.json"
    mkdir -p "$STATE_DIR/checkpoints"
    
    echo "$checkpoint_data" > "$checkpoint_file"
    
    # Update session state with checkpoint
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CHECKPOINT: $checkpoint_name saved" >> "$SESSION_LOG"
    
    echo "$checkpoint_file"
}

restore_checkpoint() {
    local checkpoint_name="$1"
    
    local checkpoint_file="$STATE_DIR/checkpoints/${checkpoint_name}.json"
    
    if [[ -f "$checkpoint_file" ]]; then
        echo "[RESTORE] Loading checkpoint: $checkpoint_name" >&2
        cat "$checkpoint_file"
    else
        echo "[ERROR] Checkpoint not found: $checkpoint_name" >&2
        return 1
    fi
}

# =============================================================================
# SESSION CLEANUP
# =============================================================================

cleanup_session() {
    local exit_status="${1:-success}"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SESSION CLEANUP: Status=$exit_status" >> "$SESSION_LOG"
    
    # Generate session summary
    if [[ -f "$STATE_DIR/session-state.json" ]]; then
        local session_id=$(grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_DIR/session-state.json" | cut -d'"' -f4)
        local total_cost=$(grep -o '"total_cost"[[:space:]]*:[[:space:]]*[0-9.]*' "$STATE_DIR/session-state.json" | awk -F: '{print $2}' | tr -d ' ')
        local operations=$(grep -o '"operations"[[:space:]]*:[[:space:]]*[0-9]*' "$STATE_DIR/session-state.json" | awk -F: '{print $2}' | tr -d ' ')
        local errors=$(grep -o '"errors"[[:space:]]*:[[:space:]]*[0-9]*' "$STATE_DIR/session-state.json" | awk -F: '{print $2}' | tr -d ' ')
        
        cat >> "$SESSION_LOG" <<EOF
=== SESSION SUMMARY ===
Session ID: $session_id
Status: $exit_status
Total Cost: \$$total_cost
Operations: $operations
Errors: $errors
Budget Remaining: \$$(awk "BEGIN {print 33.25 - $total_cost}")
=======================
EOF
    fi
    
    # Archive session data
    if [[ -f "$STATE_DIR/session-state.json" ]]; then
        cp "$STATE_DIR/session-state.json" "$ARCHIVE_DIR/session-$(date +%Y%m%d_%H%M%S).json"
    fi
    
    # Clean up old logs (keep last 7 days)
    find "$PROJECT_ROOT/.claude/logs" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    # Clean up old checkpoints (keep last 3 days)
    find "$STATE_DIR/checkpoints" -name "*.json" -mtime +3 -delete 2>/dev/null || true
    
    echo "[CLEANUP] Session cleanup completed" >&2
}

# =============================================================================
# FILE LIFECYCLE ENFORCEMENT
# =============================================================================

enforce_file_lifecycle() {
    # Enforce file governance rules
    
    # Check for temporary files older than 24 hours
    find "$PROJECT_ROOT" -name "*.tmp" -mtime +1 -delete 2>/dev/null || true
    
    # Check for session files older than 30 days
    find "$ARCHIVE_DIR" -name "session-*.json" -mtime +30 -delete 2>/dev/null || true
    
    # Validate no enhanced-* files exist
    local enhanced_count=$(find "$PROJECT_ROOT/.claude" -name "*enhanced*" -type f 2>/dev/null | wc -l)
    if [[ $enhanced_count -gt 0 ]]; then
        echo "[WARNING] Found $enhanced_count enhanced-* files requiring consolidation" >&2
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    local action="${1:-status}"
    shift
    
    case "$action" in
        "init")
            init_session "$@"
            ;;
        "error")
            handle_error "$@"
            ;;
        "prompt")
            handle_user_prompt "$@"
            ;;
        "checkpoint")
            create_checkpoint "$@"
            ;;
        "restore")
            restore_checkpoint "$@"
            ;;
        "cleanup")
            cleanup_session "$@"
            ;;
        "enforce")
            enforce_file_lifecycle
            ;;
        "status")
            if [[ -f "$STATE_DIR/session-state.json" ]]; then
                cat "$STATE_DIR/session-state.json"
            else
                echo "No active session"
            fi
            ;;
        *)
            echo "Usage: $0 {init|error|prompt|checkpoint|restore|cleanup|enforce|status}" >&2
            ;;
    esac
}

# Execute if called with arguments
if [[ $# -gt 0 ]]; then
    main "$@"
fi