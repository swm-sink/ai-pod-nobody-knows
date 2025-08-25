#!/bin/bash

# Fixed Pre-Tool Cost Validation
# Prevents budget overruns with corrected cost parsing

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
BUDGET_LIMIT=33.25
COST_LOG="$PROJECT_ROOT/.claude/logs/cost-tracking.log"
WARNING_THRESHOLD=0.8

# Ensure log directory exists
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Get current episode budget usage with improved parsing
get_current_usage() {
    if [[ -f "$COST_LOG" ]]; then
        # Get today's total - look for TOTAL: entries and get the last number
        local today=$(date '+%Y-%m-%d')
        local total=$(grep "$today" "$COST_LOG" 2>/dev/null | grep "TOTAL:" | tail -1 | awk '{print $NF}' | tr -d ' ')
        if [[ -n "$total" && "$total" =~ ^[0-9]+\.?[0-9]*$ ]]; then
            echo "$total"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Check if operation would exceed budget
check_budget() {
    local tool="$1"
    local estimated_cost=0

    case "$tool" in
        *"perplexity"*) estimated_cost=0.50 ;;
        *"elevenlabs"*) estimated_cost=1.00 ;;
        *"research"*) estimated_cost=0.75 ;;
        *) estimated_cost=0.10 ;;
    esac

    local current=$(get_current_usage)
    local projected=$(awk "BEGIN {printf \"%.2f\", $current + $estimated_cost}")

    # Only block if we're really over budget (not just parsing issues)
    if (( $(awk "BEGIN {print ($projected > $BUDGET_LIMIT)}") )); then
        echo "BUDGET_EXCEEDED: Operation would exceed $BUDGET_LIMIT limit (current: $current, projected: $projected)"
        echo '{"continue": false, "message": "Budget limit would be exceeded"}'
        exit 1
    fi

    # Log the validation with cleaner format
    echo "$(date '+%Y-%m-%d %H:%M:%S') PRE_VALIDATION: Tool=$tool Est=$estimated_cost Current=$current Projected=$projected" >> "$COST_LOG"
}

# Main execution
TOOL_NAME="${1:-unknown}"

# Only do budget checking for expensive operations
case "$TOOL_NAME" in
    *"perplexity"*|*"elevenlabs"*|*"research"*)
        check_budget "$TOOL_NAME"
        ;;
    *)
        # For cheap operations, just log and continue
        echo "$(date '+%Y-%m-%d %H:%M:%S') PRE_VALIDATION: Tool=$TOOL_NAME (low-cost, skipping budget check)" >> "$COST_LOG" 2>/dev/null || true
        ;;
esac

# Continue with operation
echo '{"continue": true}'
