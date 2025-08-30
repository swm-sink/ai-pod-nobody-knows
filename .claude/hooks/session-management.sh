#!/bin/bash

# Session Management Suite - Session Lifecycle and Error Recovery
# Consolidates session cleanup and error recovery handler
# Implements CLAUDE.md compliance (12 hooks maximum)

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
SESSION_LOG="$PROJECT_ROOT/.claude/logs/session-summary.log"
COST_LOG="$PROJECT_ROOT/.claude/logs/cost-tracking.log"
ERROR_LOG="$PROJECT_ROOT/.claude/logs/error-recovery.log"
STATE_DIR="$PROJECT_ROOT/.claude/state"

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"
mkdir -p "$PROJECT_ROOT/.claude/archives/$(date +%Y%m)"
mkdir -p "$STATE_DIR"

# =============================================================================
# SESSION CLEANUP FUNCTIONALITY
# =============================================================================

# Generate session summary
generate_session_summary() {
    echo "=== SESSION SUMMARY $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$SESSION_LOG"

    # Calculate session costs
    if [[ -f "$COST_LOG" ]]; then
        local total=$(grep "$(date '+%Y-%m-%d')" "$COST_LOG" | \
                     grep "COST:" | awk -F'Cost=' '{sum += $2} END {print sum}')
        echo "Total Cost: \$$total" >> "$SESSION_LOG"
        local remaining=$(awk "BEGIN {print 33.25 - $total}")
        echo "Budget Remaining: \$$remaining" >> "$SESSION_LOG"
    fi

    # Clean up old logs (keep last 7 days)
    find "$PROJECT_ROOT/.claude/logs" -name "*.log" -mtime +7 -delete 2>/dev/null || true

    # Archive session data
    cp "$SESSION_LOG" "$PROJECT_ROOT/.claude/archives/$(date +%Y%m)/session-$(date +%Y%m%d_%H%M%S).log" 2>/dev/null || true

    echo "Session cleanup completed" >> "$SESSION_LOG"
}

# =============================================================================
# ERROR RECOVERY FUNCTIONALITY
# =============================================================================

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
save_recovery_checkpoint() {
    local error_type="$1"
    local recovery_action="$2"
    local checkpoint_file="$STATE_DIR/recovery-checkpoint-$(date +%Y%m%d-%H%M%S).json"

    cat > "$checkpoint_file" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "error_type": "$error_type",
  "recovery_action": "$recovery_action",
  "session_state": "preserved"
}
EOF
}

# =============================================================================
# MAIN SESSION MANAGEMENT EXECUTION
# =============================================================================

main() {
    local operation="${1:-cleanup}"
    local error_type="${2:-unknown}"
    local error_msg="${3:-No message provided}"

    case "$operation" in
        "cleanup"|"session-end"|"stop")
            # Session cleanup operation
            generate_session_summary
            echo '{"continue": true, "message": "Session cleanup completed"}'
            ;;
        "error"|"recovery"|"error-recovery")
            # Error recovery operation
            local recovery_action=$(determine_recovery "$error_type")
            log_error "$error_type" "$error_msg" "$recovery_action"
            save_recovery_checkpoint "$error_type" "$recovery_action"
            echo "{\"continue\": true, \"recovery\": \"$recovery_action\"}"
            ;;
        "status"|"health-check")
            # Combined status check
            echo "Session Management Status:"
            echo "- Session logs: $(ls -la "$SESSION_LOG" 2>/dev/null | wc -l) entries"
            echo "- Error logs: $(ls -la "$ERROR_LOG" 2>/dev/null | wc -l) entries"
            echo "- Recovery checkpoints: $(ls "$STATE_DIR"/recovery-checkpoint-* 2>/dev/null | wc -l) saved"
            echo '{"continue": true, "status": "operational"}'
            ;;
        *)
            echo "Usage: $0 {cleanup|error|status} [error_type] [error_message]"
            echo "  cleanup: Run session cleanup and archival"
            echo "  error: Handle error recovery with specified type and message"
            echo "  status: Show session management health status"
            echo '{"continue": true, "message": "Help displayed"}'
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
