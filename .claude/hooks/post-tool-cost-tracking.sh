#!/bin/bash

# Essential Hook 2: Post-Tool Cost Tracking
# Records actual costs after operations complete

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
COST_LOG="$PROJECT_ROOT/.claude/logs/cost-tracking.log"
DAILY_SUMMARY="$PROJECT_ROOT/.claude/logs/daily-cost-summary.log"

# Ensure log directory exists
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Calculate actual cost based on tool and usage
calculate_actual_cost() {
    local tool="$1"
    local tokens="${2:-0}"
    local cost=0

    case "$tool" in
        *"perplexity"*)
            # Perplexity: ~$0.001 per 1K tokens
            cost=$(awk "BEGIN {print $tokens * 0.001 / 1000}")
            ;;
        *"elevenlabs"*)
            # ElevenLabs: ~$0.30 per 1K characters
            cost=$(awk "BEGIN {print $tokens * 0.0003}")
            ;;
        *)
            # Default model costs
            cost=$(awk "BEGIN {print $tokens * 0.0001}")
            ;;
    esac

    echo "$cost"
}

# Update cost tracking
update_cost_tracking() {
    local tool="$1"
    local tokens="${2:-1000}"
    local cost=$(calculate_actual_cost "$tool" "$tokens")

    # Log the actual cost
    echo "$(date '+%Y-%m-%d %H:%M:%S') COST: Tool=$tool Tokens=$tokens Cost=$cost" >> "$COST_LOG"

    # Update daily summary
    local today=$(date '+%Y-%m-%d')
    local daily_total=$(grep "$today" "$COST_LOG" | grep "COST:" | \
                       awk -F'Cost=' '{sum += $2} END {print sum}')

    echo "$(date '+%Y-%m-%d %H:%M:%S') TOTAL: $daily_total" >> "$COST_LOG"

    # Alert if approaching budget
    if [[ $(awk "BEGIN {print ($daily_total > 30)}") == "1" ]]; then
        echo "WARNING: Approaching daily budget limit ($daily_total / 33.25)"
    fi
}

# Main execution
TOOL_NAME="${1:-unknown}"
TOKEN_COUNT="${2:-1000}"
update_cost_tracking "$TOOL_NAME" "$TOKEN_COUNT"

# Always continue
echo '{"continue": true}'
