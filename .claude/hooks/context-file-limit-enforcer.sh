#!/bin/bash

# Context File Limit Enforcer
# Prevents commits when context directory exceeds 15 files
# Part of CLAUDE.md governance enforcement

set -e

CONTEXT_DIR=".claude/context"
FILE_LIMIT=15
LOG_FILE=".claude/logs/context-enforcement.log"

# Ensure log directory exists
mkdir -p .claude/logs

# Function to log enforcement actions
log_enforcement() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to count context files
count_context_files() {
    if [[ -d "$CONTEXT_DIR" ]]; then
        find "$CONTEXT_DIR" -name "*.md" -type f | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Function to list context files
list_context_files() {
    if [[ -d "$CONTEXT_DIR" ]]; then
        find "$CONTEXT_DIR" -name "*.md" -type f | sort
    fi
}

# Function to detect topic duplication
detect_topic_duplication() {
    local duplicates_found=0
    local temp_file=$(mktemp)

    # Extract topics from filenames and content
    if [[ -d "$CONTEXT_DIR" ]]; then
        # Check for obvious filename duplication patterns
        find "$CONTEXT_DIR" -name "*.md" -type f -exec basename {} \; | \
        sed 's/[_-]unified\.md$//' | \
        sed 's/[_-]complete\.md$//' | \
        sed 's/^[0-9]*_//' | \
        sort | uniq -d > "$temp_file"

        if [[ -s "$temp_file" ]]; then
            echo "❌ DUPLICATE TOPIC DETECTED:"
            while read -r topic; do
                echo "  - Topic '$topic' appears in multiple files"
                duplicates_found=1
            done < "$temp_file"
        fi
    fi

    rm -f "$temp_file"
    return $duplicates_found
}

# Main enforcement logic
echo "🔍 Context File Limit Enforcement Check"

# Count current context files
CURRENT_COUNT=$(count_context_files)
echo "📊 Current context files: $CURRENT_COUNT/$FILE_LIMIT"

# Log current status
log_enforcement "Context file check: $CURRENT_COUNT/$FILE_LIMIT files"

# Check file limit
if [[ $CURRENT_COUNT -gt $FILE_LIMIT ]]; then
    echo ""
    echo "🚨 CONTEXT FILE LIMIT EXCEEDED!"
    echo "❌ Current files: $CURRENT_COUNT"
    echo "✅ Maximum allowed: $FILE_LIMIT"
    echo "📝 Excess files: $((CURRENT_COUNT - FILE_LIMIT))"
    echo ""
    echo "📋 Current context files:"
    list_context_files | sed 's/^/  - /'
    echo ""
    echo "🔧 REQUIRED ACTIONS:"
    echo "  1. Use /context-consolidate to merge related files"
    echo "  2. Remove redundant or outdated files"
    echo "  3. Ensure each topic is covered in exactly one file"
    echo ""
    echo "💡 Available consolidation commands:"
    echo "  - /context-consolidate all"
    echo "  - /context-health (diagnostic)"
    echo "  - /context-validate (compliance check)"

    log_enforcement "BLOCKED: File limit exceeded ($CURRENT_COUNT > $FILE_LIMIT)"
    exit 1
fi

# Check for topic duplication
echo ""
echo "🔍 Checking for topic duplication..."
if ! detect_topic_duplication; then
    echo ""
    echo "🚨 TOPIC DUPLICATION VIOLATION!"
    echo "❌ Multiple files covering the same topics detected"
    echo "✅ Required: Each topic in exactly ONE context file"
    echo ""
    echo "🔧 REQUIRED ACTIONS:"
    echo "  1. Identify duplicate content across files"
    echo "  2. Consolidate duplicate topics into single files"
    echo "  3. Update all references to point to consolidated files"
    echo "  4. Delete redundant files after consolidation"

    log_enforcement "BLOCKED: Topic duplication detected"
    exit 1
fi

# Success - within limits and no duplication
echo "✅ Context file governance: COMPLIANT"
echo "📊 Files: $CURRENT_COUNT/$FILE_LIMIT"
echo "🔒 No topic duplication detected"
echo ""

log_enforcement "PASSED: Context governance compliant ($CURRENT_COUNT/$FILE_LIMIT files)"

# Additional recommendations
if [[ $CURRENT_COUNT -gt $((FILE_LIMIT - 3)) ]]; then
    echo "⚠️  WARNING: Approaching file limit ($CURRENT_COUNT/$FILE_LIMIT)"
    echo "💡 Consider consolidating related files proactively"
    log_enforcement "WARNING: Approaching file limit ($CURRENT_COUNT/$FILE_LIMIT)"
fi

exit 0
