#!/bin/bash
# Automated Stale File Archival System
# Prevents documentation accumulation and maintains project health

set -e

# Configuration
STALENESS_DAYS=30
ARCHIVE_BASE="./archive"
LOG_FILE="archival.log"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Help text
show_help() {
    echo "File Lifecycle Archival System"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --preview    Show what would be archived (dry run)"
    echo "  --force      Execute archival without confirmation"
    echo "  --days N     Set staleness threshold (default: 30)"
    echo "  --help       Show this help text"
    echo ""
    echo "Examples:"
    echo "  $0 --preview              # Show archival candidates"
    echo "  $0 --days 45 --force      # Archive files older than 45 days"
}

# Parse arguments
PREVIEW=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --preview)
            PREVIEW=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --days)
            STALENESS_DAYS="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Create archive directory
ARCHIVE_DIR="$ARCHIVE_BASE/$(date +%Y-%m-%d)"
if [ "$PREVIEW" = false ]; then
    mkdir -p "$ARCHIVE_DIR"
fi

echo -e "${BLUE}[ARCHIVAL]${NC} File lifecycle archival analysis..."
echo -e "${BLUE}[CONFIG]${NC} Staleness threshold: $STALENESS_DAYS days"

# Find stale files in processes directory
stale_count=0
current_time=$(date +%s)

# Check .claude/processes for stale files
if [ -d ".claude/processes" ]; then
    echo -e "${YELLOW}[SCANNING]${NC} .claude/processes directory..."

    find .claude/processes -name "*.md" -type f | while read file; do
        # Get last modification time from git
        last_modified=$(git log -1 --format=%ct -- "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo 0)
        days_old=$(( (current_time - last_modified) / 86400 ))

        if [ "$days_old" -gt "$STALENESS_DAYS" ]; then
            basename_file=$(basename "$file")

            if [ "$PREVIEW" = true ]; then
                echo -e "${RED}[STALE]${NC} $file (${days_old} days old)"
            else
                echo -e "${YELLOW}[ARCHIVING]${NC} $file → $ARCHIVE_DIR/"
                mv "$file" "$ARCHIVE_DIR/"
                echo "$(date '+%Y-%m-%d %H:%M:%S') - $file → $ARCHIVE_DIR/" >> "$LOG_FILE"
                stale_count=$((stale_count + 1))
            fi
        fi
    done
fi

# Check for zero-reference files in context directory
echo -e "${YELLOW}[SCANNING]${NC} Zero-reference analysis..."

if [ -d ".claude/context" ]; then
    find .claude/context -name "*.md" -type f | while read file; do
        basename_file=$(basename "$file")
        # Count references in other files
        ref_count=$(grep -r "@.*$basename_file" . --exclude-dir=.git --exclude-dir=archive 2>/dev/null | wc -l)

        if [ "$ref_count" -eq 0 ] && [ "$basename_file" != "INDEX.md" ]; then
            if [ "$PREVIEW" = true ]; then
                echo -e "${YELLOW}[UNREFERENCED]${NC} $file (0 references)"
            else
                echo -e "${YELLOW}[ARCHIVING]${NC} $file → $ARCHIVE_DIR/ (unreferenced)"
                mv "$file" "$ARCHIVE_DIR/"
                echo "$(date '+%Y-%m-%d %H:%M:%S') - $file → $ARCHIVE_DIR/ (unreferenced)" >> "$LOG_FILE"
            fi
        fi
    done
fi

# Summary
if [ "$PREVIEW" = true ]; then
    echo -e "${BLUE}[PREVIEW]${NC} Archival analysis complete"
    echo -e "${BLUE}[INFO]${NC} Run with --force to execute archival"
else
    if [ "$FORCE" = false ]; then
        echo -e "${YELLOW}[CONFIRM]${NC} This will archive stale files. Continue? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}[CANCELLED]${NC} Archival cancelled by user"
            exit 0
        fi
    fi

    echo -e "${GREEN}[COMPLETE]${NC} Archival process finished"
    echo -e "${GREEN}[LOG]${NC} Details logged to $LOG_FILE"

    # Update .claudeignore to exclude archived files
    if [ -f .claudeignore ]; then
        echo "archive/" >> .claudeignore
    fi
fi

# File count report
echo -e "${BLUE}[REPORT]${NC} Current file counts:"
for dir in ".claude/context" ".claude/processes" ".claude/agents"; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "*.md" -type f | wc -l)
        echo -e "${GREEN}[COUNT]${NC} $dir: $count files"
    fi
done
