#!/bin/bash

# Essential Hook 1: Pre-Tool Cost Validation
# Prevents budget overruns by validating costs before expensive operations

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
BUDGET_LIMIT=33.25
COST_LOG="$PROJECT_ROOT/.claude/logs/cost-tracking.log"
WARNING_THRESHOLD=0.8

# Ensure log directory exists
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Get current episode budget usage
get_current_usage() {
    if [[ -f "$COST_LOG" ]]; then
        grep "$(date '+%Y-%m-%d')" "$COST_LOG" 2>/dev/null | \
        grep "TOTAL:" | tail -1 | awk -F: '{print $2}' || echo "0"
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
    local projected=$(awk "BEGIN {print $current + $estimated_cost}")

    if [[ $(awk "BEGIN {print ($projected > $BUDGET_LIMIT)}") == "1" ]]; then
        echo "BUDGET_EXCEEDED: Operation would exceed $BUDGET_LIMIT limit"
        echo '{"continue": false, "message": "Budget limit would be exceeded"}'
        exit 1
    fi

    # Log the validation
    echo "$(date '+%Y-%m-%d %H:%M:%S') PRE_VALIDATION: Tool=$tool Est=$estimated_cost Current=$current" >> "$COST_LOG"
}

# Main execution
TOOL_NAME="${1:-unknown}"
check_budget "$TOOL_NAME"

# Continue with operation
echo '{"continue": true}'
