#!/bin/bash

# Essential Hook 4: Error Recovery Handler
# Handles failures gracefully and helps recover from errors

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
ERROR_LOG="$PROJECT_ROOT/.claude/logs/error-recovery.log"
STATE_DIR="$PROJECT_ROOT/.claude/state"

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"
mkdir -p "$STATE_DIR"

# Log error details
log_error() {
    local error_type="$1"
    local error_message="$2"
    local recovery_action="$3"

    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Type=$error_type Message=$error_message" >> "$ERROR_LOG"
    echo "$(date '+%Y-%m-%d %H:%M:%S') RECOVERY: $recovery_action" >> "$ERROR_LOG"
}

# Determine recovery action
determine_recovery() {
    local error_type="$1"

    case "$error_type" in
        "timeout")
            echo "Retry with increased timeout"
            ;;
        "permission")
            echo "Check file permissions and retry"
            ;;
        "not_found")
            echo "Verify path and create if necessary"
            ;;
        "budget_exceeded")
            echo "Halt expensive operations, review costs"
            ;;
        *)
            echo "Log error and continue with caution"
            ;;
    esac
}

# Save recovery checkpoint
save_checkpoint() {
    local checkpoint_file="$STATE_DIR/recovery-checkpoint-$(date +%Y%m%d-%H%M%S).json"

    cat > "$checkpoint_file" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "error_type": "$1",
  "recovery_action": "$2",
  "session_state": "preserved"
}
EOF
}

# Main execution
ERROR_TYPE="${1:-unknown}"
ERROR_MSG="${2:-No message provided}"

RECOVERY_ACTION=$(determine_recovery "$ERROR_TYPE")
log_error "$ERROR_TYPE" "$ERROR_MSG" "$RECOVERY_ACTION"
save_checkpoint "$ERROR_TYPE" "$RECOVERY_ACTION"

# Return recovery guidance
echo "{\"continue\": true, \"recovery\": \"$RECOVERY_ACTION\"}"
