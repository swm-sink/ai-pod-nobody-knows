#!/bin/bash

echo "Fixing and restoring Claude Code hooks..."

HOOKS_DIR=".claude/hooks"
BACKUP_DIR=".claude/hooks_broken_backup"
PROJECT_ROOT="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows"

# List of critical hooks to restore
CRITICAL_HOOKS=(
    "pre-tool-enhanced-cost-tracking.sh"
    "post-tool-enhanced-cost-analytics.sh"
    "post-tool-coordination-cleanup.sh"
    "post-evaluation-quality-metrics.sh"
    "post-write-quality-check.sh"
    "post-task-checkpoint.sh"
    "post-research-cost-tracking.sh"
    "post-audio-cost-tracking.sh"
    "session-cleanup.sh"
    "user-prompt-analysis.sh"
    "notification-handler.sh"
    "subagent-completion.sh"
)

# Function to fix common path issues in a file
fix_hook_file() {
    local file="$1"
    local temp_file=$(mktemp)

    # Read the file and apply fixes
    cat "$file" | \
    # Fix broken mkdir commands with multiple directories
    sed 's|mkdir -p "${PROJECT_ROOT}/\.claude/logs \.claude/state|mkdir -p "${PROJECT_ROOT}/.claude/logs" "${PROJECT_ROOT}/.claude/state"|g' | \
    sed 's|mkdir -p "${PROJECT_ROOT}/\.claude/logs \.claude/checkpoints|mkdir -p "${PROJECT_ROOT}/.claude/logs" "${PROJECT_ROOT}/.claude/checkpoints"|g' | \
    sed 's|mkdir -p "${PROJECT_ROOT}/\.claude/state \.claude/tools|mkdir -p "${PROJECT_ROOT}/.claude/state" "${PROJECT_ROOT}/.claude/tools"|g' | \
    sed 's|mkdir -p "${PROJECT_ROOT}/episodes episodes/production|mkdir -p "${PROJECT_ROOT}/episodes" "${PROJECT_ROOT}/episodes/production"|g' | \
    sed 's|mkdir -p "${PROJECT_ROOT}/sessions sessions/|mkdir -p "${PROJECT_ROOT}/sessions"|g' | \
    # Fix any unclosed quotes in mkdir commands
    sed 's|mkdir -p "${PROJECT_ROOT}/\([^"]*\)$|mkdir -p "${PROJECT_ROOT}/\1"|g' \
    > "$temp_file"

    mv "$temp_file" "$file"
}

# Process each critical hook
for hook in "${CRITICAL_HOOKS[@]}"; do
    if [[ -f "$BACKUP_DIR/$hook" ]]; then
        echo "Processing $hook..."

        # Copy to hooks directory
        cp "$BACKUP_DIR/$hook" "$HOOKS_DIR/$hook"

        # Fix common issues
        fix_hook_file "$HOOKS_DIR/$hook"

        # Make executable
        chmod +x "$HOOKS_DIR/$hook"

        # Test syntax
        if bash -n "$HOOKS_DIR/$hook" 2>/dev/null; then
            echo "  ✓ $hook restored and verified"
        else
            echo "  ✗ $hook has syntax errors:"
            bash -n "$HOOKS_DIR/$hook" 2>&1 | head -2
        fi
    else
        echo "  ⚠ $hook not found in backup"
    fi
done

# Copy any remaining hooks that weren't in the critical list
echo ""
echo "Restoring remaining hooks..."
for hook in "$BACKUP_DIR"/*.sh; do
    basename=$(basename "$hook")
    if [[ ! -f "$HOOKS_DIR/$basename" ]]; then
        echo "  Restoring $basename..."
        cp "$hook" "$HOOKS_DIR/$basename"
        fix_hook_file "$HOOKS_DIR/$basename"
        chmod +x "$HOOKS_DIR/$basename"
    fi
done

echo ""
echo "Hook restoration complete!"
echo ""
echo "Summary:"
echo "  Total hooks: $(ls -1 $HOOKS_DIR/*.sh 2>/dev/null | wc -l)"
echo "  Location: $HOOKS_DIR"
echo ""
echo "Testing a sample hook..."
if bash "$HOOKS_DIR/pre-tool-cost-validation.sh" "TestTool" "TestArgs" 2>&1 | grep -q "continue"; then
    echo "  ✓ Hooks appear to be working!"
else
    echo "  ⚠ Hook test had issues"
fi
