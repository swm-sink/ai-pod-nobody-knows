#!/bin/bash

# Post-Tool Tracking Hook - Consolidated
# Combines: cost tracking, metrics capture, billing reconciliation, shadow validation
# Native Claude Code simplified architecture

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
COST_LOG="$PROJECT_ROOT/.claude/logs/cost-tracking.log"
METRICS_LOG="$PROJECT_ROOT/.claude/logs/metrics.log"
BILLING_LOG="$PROJECT_ROOT/.claude/logs/billing-reconciliation.log"
SHADOW_LOG="$PROJECT_ROOT/.claude/logs/shadow-validation.log"
STATE_FILE="$PROJECT_ROOT/.claude/state/session-state.json"

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"
mkdir -p "$PROJECT_ROOT/.claude/state"

# =============================================================================
# COST TRACKING
# =============================================================================

track_cost() {
    local tool="$1"
    local actual_tokens="${2:-1000}"
    local operation_id="${3:-$(date +%s)}"
    local actual_cost=0

    # Calculate actual cost based on tool and tokens
    case "$tool" in
        *"perplexity"*)
            actual_cost=$(awk "BEGIN {printf \"%.4f\", $actual_tokens * 0.002 / 1000}")
            ;;
        *"elevenlabs"*|*"ElevenLabs"*)
            actual_cost=$(awk "BEGIN {printf \"%.4f\", $actual_tokens * 0.0003}")
            ;;
        *"claude"*|*"anthropic"*)
            actual_cost=$(awk "BEGIN {printf \"%.4f\", $actual_tokens * 0.003 / 1000}")
            ;;
        *)
            actual_cost=0.001
            ;;
    esac

    # Log cost with timestamp and operation ID
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] COST: Tool=$tool, Tokens=$actual_tokens, Cost=$actual_cost, OpID=$operation_id" >> "$COST_LOG"

    # Update session state
    update_session_cost "$actual_cost"

    echo "$actual_cost"
}

update_session_cost() {
    local cost="$1"

    if [[ -f "$STATE_FILE" ]]; then
        # Update existing session state
        local current_total=$(grep -o '"total_cost"[[:space:]]*:[[:space:]]*[0-9.]*' "$STATE_FILE" | awk -F: '{print $2}' | tr -d ' ')
        local new_total=$(awk "BEGIN {print $current_total + $cost}")

        # Simple JSON update (in production, use jq)
        sed -i.bak "s/\"total_cost\"[[:space:]]*:[[:space:]]*[0-9.]*/\"total_cost\": $new_total/" "$STATE_FILE"
    else
        # Create new session state
        cat > "$STATE_FILE" <<EOF
{
    "session_id": "$(date +%s)",
    "start_time": "$(date -Iseconds)",
    "total_cost": $cost,
    "operations": 1
}
EOF
    fi
}

# =============================================================================
# METRICS CAPTURE
# =============================================================================

capture_metrics() {
    local tool="$1"
    local duration="${2:-0}"
    local success="${3:-true}"

    # Capture baseline metrics
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local memory_usage=$(ps aux | grep -E "(claude|python)" | awk '{sum += $4} END {print sum}')

    # Log metrics
    cat >> "$METRICS_LOG" <<EOF
[$timestamp] METRICS:
  Tool: $tool
  Duration: ${duration}ms
  Success: $success
  Memory: ${memory_usage}%
  Session: $(grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" 2>/dev/null | cut -d'"' -f4 || echo "none")
EOF
}

# =============================================================================
# BILLING RECONCILIATION
# =============================================================================

reconcile_billing() {
    local daily_limit=4.00

    # Calculate today's spend
    local today=$(date '+%Y-%m-%d')
    local today_spend=0

    if [[ -f "$COST_LOG" ]]; then
        today_spend=$(grep "$today" "$COST_LOG" | grep "COST:" | awk -F'Cost=' '{sum += $2} END {print sum}')
    fi

    # Check against daily limit
    if (( $(awk "BEGIN {print ($today_spend > $daily_limit)}") )); then
        echo "[WARNING] Daily spending limit exceeded: \$$today_spend > \$$daily_limit" >&2
    fi

    # Log reconciliation
    echo "[$today] Daily Total: \$$today_spend (Limit: \$$daily_limit)" >> "$BILLING_LOG"
}

# =============================================================================
# SHADOW MODE VALIDATION
# =============================================================================

shadow_validate() {
    local tool="$1"
    local result="${2:-success}"

    # In shadow mode, we track what would have happened with different configurations
    # This helps validate changes before full deployment

    if [[ "$SHADOW_MODE" == "true" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SHADOW: Tool=$tool, Result=$result" >> "$SHADOW_LOG"

        # Compare shadow results with production
        # In a real system, this would do more sophisticated comparison
        echo "[SHADOW] Validation recorded for $tool" >&2
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    local tool="${1:-unknown}"
    local tokens="${2:-1000}"
    local duration="${3:-0}"
    local success="${4:-true}"

    echo "[POST-TRACKING] Starting for tool: $tool" >&2

    # Track cost
    local actual_cost=$(track_cost "$tool" "$tokens")
    echo "[COST] Tracked: \$$actual_cost for $tool" >&2

    # Capture metrics
    capture_metrics "$tool" "$duration" "$success"

    # Reconcile billing (run periodically)
    if [[ $(date +%M) == "00" ]] || [[ "$FORCE_RECONCILE" == "true" ]]; then
        reconcile_billing
    fi

    # Shadow validation if enabled
    shadow_validate "$tool" "$success"

    echo "[POST-TRACKING] Complete for tool: $tool" >&2
}

# Execute if called with arguments
if [[ $# -gt 0 ]]; then
    main "$@"
fi
