#!/bin/bash
# Simple Recovery Helper for Common Pipeline Issues
# Provides easy fixes for typical problems

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo "🔧 Pipeline Recovery Helper"
    echo ""
    echo "Usage: ./recovery-helper.sh [action]"
    echo ""
    echo "Actions:"
    echo "  cleanup     - Clean up stuck sessions"
    echo "  reset       - Reset pipeline to clean state"
    echo "  backup      - Backup current state before recovery"
    echo "  retry       - Retry last failed agent"
    echo "  help        - Show this help message"
}

cleanup_stuck_sessions() {
    echo "🧹 Cleaning up stuck sessions..."

    # Find sessions older than 60 minutes
    OLD_SESSIONS=$(find .claude/level-2-production/sessions/active -name "*.json" -mmin +60 2>/dev/null)

    if [ -z "$OLD_SESSIONS" ]; then
        echo -e "${GREEN}No stuck sessions found${NC}"
        return
    fi

    # Move old sessions to failed directory
    for session in $OLD_SESSIONS; do
        filename=$(basename "$session")
        echo "Moving $filename to failed directory..."
        mv "$session" ".claude/level-2-production/sessions/failed/" 2>/dev/null || {
            echo -e "${RED}Failed to move $filename${NC}"
        }
    done

    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

reset_pipeline() {
    echo "🔄 Resetting pipeline to clean state..."

    # Backup current state first
    backup_state

    # Clear active sessions
    echo "Clearing active sessions..."
    mv .claude/level-2-production/sessions/active/*.json \
       .claude/level-2-production/sessions/completed/ 2>/dev/null

    # Reset any temporary files
    echo "Cleaning temporary files..."
    rm -f /tmp/pipeline_*.tmp 2>/dev/null

    echo -e "${GREEN}✓ Pipeline reset complete${NC}"
}

backup_state() {
    echo "💾 Creating backup..."

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR=".claude/level-2-production/sessions/backups/backup_$TIMESTAMP"

    mkdir -p "$BACKUP_DIR"

    # Copy active sessions
    if [ -d ".claude/level-2-production/sessions/active" ]; then
        cp -r .claude/level-2-production/sessions/active "$BACKUP_DIR/" 2>/dev/null
    fi

    echo -e "${GREEN}✓ Backup saved to: $BACKUP_DIR${NC}"
}

retry_last_failed() {
    echo "🔁 Finding last failed agent..."

    # Find the most recent session file
    LAST_SESSION=$(ls -t .claude/level-2-production/sessions/active/*.json 2>/dev/null | head -1)

    if [ -z "$LAST_SESSION" ]; then
        echo -e "${RED}No active sessions found${NC}"
        return
    fi

    # Extract agent name from session (simplified - would need jq in real implementation)
    echo "Found session: $(basename $LAST_SESSION)"
    echo ""
    echo "To retry, run:"
    echo -e "${BLUE}claude run pipeline-coordinator --retry --session $(basename $LAST_SESSION .json)${NC}"
}

# Main script logic
case "$1" in
    cleanup)
        cleanup_stuck_sessions
        ;;
    reset)
        reset_pipeline
        ;;
    backup)
        backup_state
        ;;
    retry)
        retry_last_failed
        ;;
    help|"")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown action: $1${NC}"
        show_help
        exit 1
        ;;
esac
