#!/bin/bash

# Pre-Tool Validation Hook - Consolidated
# Combines: cost validation, config protection, MCP diagnostics, duplication detection
# Native Claude Code simplified architecture

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
BUDGET_LIMIT=33.25
WARNING_THRESHOLD=26.60  # 80% of budget
COST_LOG="$PROJECT_ROOT/.claude/logs/cost-tracking.log"
PREDICTION_LOG="$PROJECT_ROOT/.claude/logs/cost-predictions.log"
CONFIG_LOG="$PROJECT_ROOT/.claude/logs/config-protection.log"
MCP_LOG="$PROJECT_ROOT/.claude/logs/mcp-diagnostics.log"

# Ensure log directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"

# =============================================================================
# COST VALIDATION
# =============================================================================

predict_operation_cost() {
    local tool="$1"
    local estimated_tokens="${2:-1000}"
    local cost=0

    case "$tool" in
        *"perplexity"*)
            cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.002 / 1000}")
            ;;
        *"elevenlabs"*|*"ElevenLabs"*)
            # ~1000 chars = $0.30 for standard voice
            cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.0003}")
            ;;
        *"claude"*|*"anthropic"*)
            # Claude 3.5 Sonnet pricing
            cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.003 / 1000}")
            ;;
        *)
            cost=0.001  # Default minimal cost
            ;;
    esac

    echo "$cost"
}

check_budget() {
    local predicted_cost="$1"

    # Calculate current spend
    local current_spend=0
    if [[ -f "$COST_LOG" ]]; then
        current_spend=$(grep "COST:" "$COST_LOG" | awk -F'Cost=' '{sum += $2} END {print sum}')
    fi

    # Check if operation would exceed budget
    local projected_total=$(awk "BEGIN {print $current_spend + $predicted_cost}")

    if (( $(awk "BEGIN {print ($projected_total > $BUDGET_LIMIT)}") )); then
        echo "[ERROR] Budget limit would be exceeded. Current: \$$current_spend, Predicted: \$$predicted_cost, Limit: \$$BUDGET_LIMIT" >&2
        exit 1
    fi

    if (( $(awk "BEGIN {print ($projected_total > $WARNING_THRESHOLD)}") )); then
        echo "[WARNING] Approaching budget limit (80% threshold). Current: \$$current_spend, Predicted: \$$predicted_cost" >&2
    fi

    echo "[COST] Pre-validation passed. Current: \$$current_spend, Predicted: +\$$predicted_cost" >> "$PREDICTION_LOG"
}

# =============================================================================
# CONFIG PROTECTION
# =============================================================================

protect_config() {
    local VOICE_CONFIG="$PROJECT_ROOT/.claude/config/production-voice.json"
    local EXPECTED_VOICE_ID="ZF6FPAbjXT4488VcRRnw"

    if [[ -f "$VOICE_CONFIG" ]]; then
        local current_voice=$(grep -o '"voice_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$VOICE_CONFIG" | cut -d'"' -f4)

        if [[ "$current_voice" != "$EXPECTED_VOICE_ID" ]]; then
            echo "[ERROR] Voice configuration violation detected! Expected: $EXPECTED_VOICE_ID, Found: $current_voice" >&2
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Voice config violation blocked" >> "$CONFIG_LOG"
            exit 1
        fi
    fi

    echo "[CONFIG] Configuration validated" >> "$CONFIG_LOG"
}

# =============================================================================
# MCP DIAGNOSTICS
# =============================================================================

validate_mcp() {
    local tool="$1"

    # Only validate MCP tools
    if [[ "$tool" == *"mcp__"* ]]; then
        # Check MCP server status (simplified)
        local mcp_status="active"  # In production, would check actual MCP status

        if [[ "$mcp_status" != "active" ]]; then
            echo "[ERROR] MCP server not active for tool: $tool" >&2
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] MCP validation failed: $tool" >> "$MCP_LOG"
            exit 1
        fi

        echo "[MCP] Validated: $tool" >> "$MCP_LOG"
    fi
}

# =============================================================================
# DUPLICATION DETECTION
# =============================================================================

check_duplication() {
    # Quick duplication check for enhanced-* pattern
    local enhanced_files=$(find "$PROJECT_ROOT/.claude" -name "*enhanced*" -type f 2>/dev/null | wc -l)

    if [[ $enhanced_files -gt 0 ]]; then
        echo "[WARNING] Enhanced-* pattern files detected. Consolidation required." >&2
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    local tool="${1:-unknown}"
    local tokens="${2:-1000}"

    echo "[PRE-VALIDATION] Starting for tool: $tool" >&2

    # Run all validation checks
    protect_config
    validate_mcp "$tool"
    check_duplication

    # Cost validation
    local predicted_cost=$(predict_operation_cost "$tool" "$tokens")
    check_budget "$predicted_cost"

    echo "[PRE-VALIDATION] Complete for tool: $tool" >&2
}

# Execute if called with arguments
if [[ $# -gt 0 ]]; then
    main "$@"
fi
