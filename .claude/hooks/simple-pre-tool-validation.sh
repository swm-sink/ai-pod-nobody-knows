#!/bin/bash
# Simple Pre-Tool Validation Hook
# Minimal validation with maximum reliability

TOOL_NAME="${1:-unknown}"

# Basic logging (fail silently if not possible)
LOG_DIR="$HOME/Documents/GitHub/ai-podcasts-nobody-knows/.claude/logs"
mkdir -p "$LOG_DIR" 2>/dev/null || true
echo "$(date) Pre-tool validation: $TOOL_NAME" >> "$LOG_DIR/simple-hooks.log" 2>/dev/null || true

# Always continue - just log
echo '{"continue": true}' 2>/dev/null || echo "continue"
