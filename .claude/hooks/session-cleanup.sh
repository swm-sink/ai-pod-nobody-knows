#!/bin/bash

# Essential Hook 3: Session Cleanup
# Performs cleanup and generates summary when session ends

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
SESSION_LOG="$PROJECT_ROOT/.claude/logs/session-summary.log"
COST_LOG="$PROJECT_ROOT/.claude/logs/cost-tracking.log"

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"
mkdir -p "$PROJECT_ROOT/.claude/archives/$(date +%Y%m)"

# Generate session summary
generate_summary() {
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

# Main execution
generate_summary

# Always continue
echo '{"continue": true, "message": "Session cleanup completed"}'
