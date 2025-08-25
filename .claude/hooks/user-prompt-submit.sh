#!/bin/bash

# Essential Hook 5: User Prompt Submit
# Simple input validation and cost estimation for user requests

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
PROMPT_LOG="$PROJECT_ROOT/.claude/logs/prompt-analysis.log"

# Ensure log directory exists
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Analyze prompt for cost implications
analyze_prompt() {
    local prompt="$1"
    local cost_risk="LOW"

    # Check for expensive operations
    if echo "$prompt" | grep -qi "research\|perplexity\|comprehensive"; then
        cost_risk="MEDIUM"
    fi

    if echo "$prompt" | grep -qi "audio\|elevenlabs\|speech\|episode"; then
        cost_risk="HIGH"
    fi

    if echo "$prompt" | grep -qi "multiple\|all\|batch\|bulk"; then
        cost_risk="HIGH"
    fi

    echo "$cost_risk"
}

# Log prompt analysis
log_prompt() {
    local prompt="$1"
    local risk="$2"

    echo "$(date '+%Y-%m-%d %H:%M:%S') PROMPT: Risk=$risk Length=${#prompt}" >> "$PROMPT_LOG"
}

# Main execution
USER_PROMPT="${1:-}"
COST_RISK=$(analyze_prompt "$USER_PROMPT")

log_prompt "$USER_PROMPT" "$COST_RISK"

# Provide cost warning if high risk
if [[ "$COST_RISK" == "HIGH" ]]; then
    echo "{\"continue\": true, \"warning\": \"This operation may incur significant costs\"}"
else
    echo '{"continue": true}'
fi
