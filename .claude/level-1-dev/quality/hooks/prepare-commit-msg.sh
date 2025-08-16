#!/bin/bash

# Prepare Commit Message Hook for Level-1-Dev
# Formats and enhances commit messages for consistency

set -euo pipefail

# Hook parameters
COMMIT_MSG_FILE="$1"
COMMIT_SOURCE="${2:-}"
COMMIT_SHA="${3:-}"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LEVEL1_DIR="$(cd "$QUALITY_DIR/.." && pwd)"

# Function: Get commit type suggestions based on changed files
get_commit_type_suggestion() {
    local changed_files
    changed_files=$(git diff --cached --name-only 2>/dev/null || echo "")

    if [ -z "$changed_files" ]; then
        echo "chore"
        return
    fi

    # Analyze file patterns to suggest commit type
    if echo "$changed_files" | grep -q "test\|spec"; then
        echo "test"
    elif echo "$changed_files" | grep -q "\.md$\|README\|docs/"; then
        echo "docs"
    elif echo "$changed_files" | grep -q "fix\|bug"; then
        echo "fix"
    elif echo "$changed_files" | grep -q "\.sh$\|\.yaml$\|\.json$"; then
        if echo "$changed_files" | grep -q "new\|add"; then
            echo "feat"
        else
            echo "refactor"
        fi
    else
        echo "feat"
    fi
}

# Function: Get scope suggestion based on changed files
get_scope_suggestion() {
    local changed_files
    changed_files=$(git diff --cached --name-only 2>/dev/null || echo "")

    if [ -z "$changed_files" ]; then
        echo ""
        return
    fi

    # Analyze file paths to suggest scope
    if echo "$changed_files" | grep -q "quality/"; then
        echo "quality"
    elif echo "$changed_files" | grep -q "bin/"; then
        echo "tools"
    elif echo "$changed_files" | grep -q "tests/"; then
        echo "testing"
    elif echo "$changed_files" | grep -q "docs/"; then
        echo "docs"
    elif echo "$changed_files" | grep -q "agents/"; then
        echo "agents"
    elif echo "$changed_files" | grep -q "commands/"; then
        echo "commands"
    elif echo "$changed_files" | grep -q "templates/"; then
        echo "templates"
    elif echo "$changed_files" | grep -q "versions/"; then
        echo "versioning"
    elif echo "$changed_files" | grep -q "workflows/"; then
        echo "workflows"
    else
        echo "core"
    fi
}

# Function: Get current task number from plan
get_current_task() {
    local plan_file="$LEVEL1_DIR/level-1-dev-plan.md"

    if [ -f "$plan_file" ]; then
        # Look for current task or in-progress task
        local task_num=$(grep -E "Task [0-9]+.*in_progress\|Current Task.*[0-9]+" "$plan_file" 2>/dev/null | grep -o "[0-9]\+" | head -1 || echo "")
        if [ -n "$task_num" ]; then
            echo "$task_num"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Function: Generate commit message template
generate_template() {
    local suggested_type
    local suggested_scope
    local current_task

    suggested_type=$(get_commit_type_suggestion)
    suggested_scope=$(get_scope_suggestion)
    current_task=$(get_current_task)

    cat << EOF
$suggested_type$([ -n "$suggested_scope" ] && echo "($suggested_scope)")$([ -n "$current_task" ] && echo ": Task $current_task/75 - "):

# Commit Message Format: type(scope): subject
#
# Types:
#   feat     - New feature or enhancement
#   fix      - Bug fix
#   docs     - Documentation changes
#   style    - Code style/formatting changes
#   refactor - Code refactoring
#   test     - Adding or updating tests
#   chore    - Maintenance tasks
#
# Scopes (optional but recommended):
#   quality    - Quality system changes
#   tools      - Development tools
#   testing    - Test infrastructure
#   docs       - Documentation
#   agents     - Agent-related changes
#   commands   - Command-related changes
#   templates  - Template changes
#   versioning - Version management
#   workflows  - Workflow changes
#   core       - Core system changes
#
# Subject Guidelines:
#   - Use imperative mood ("add", not "added" or "adding")
#   - Keep under 50 characters
#   - Don't end with a period
#   - Be clear and descriptive
#
# Examples:
#   feat(agents): add template validation system
#   fix(quality): correct test coverage calculation
#   docs(api): update agent builder documentation
#   test(integration): add end-to-end workflow tests
#   refactor(tools): optimize version manager performance
$([ -n "$current_task" ] && echo "#   chore(workflow): Task $current_task/75 - implement quality gates")
#
# Current suggestion based on staged files:
#   Type: $suggested_type
$([ -n "$suggested_scope" ] && echo "#   Scope: $suggested_scope")
$([ -n "$current_task" ] && echo "#   Task: $current_task/75")
#
# Files being committed:
$(git diff --cached --name-only 2>/dev/null | sed 's/^/#   /' || echo "#   (no files staged)")
EOF
}

# Function: Process existing commit message
process_existing_message() {
    local msg_file="$1"
    local original_msg

    original_msg=$(cat "$msg_file")

    # If message is empty or just whitespace, generate template
    if [ -z "$(echo "$original_msg" | tr -d '[:space:]')" ]; then
        generate_template > "$msg_file"
        return
    fi

    # If message doesn't start with a comment and looks incomplete, enhance it
    if ! echo "$original_msg" | grep -q "^#" && ! echo "$original_msg" | grep -q ":"; then
        local enhanced_msg
        local suggested_type
        local suggested_scope
        local current_task

        suggested_type=$(get_commit_type_suggestion)
        suggested_scope=$(get_scope_suggestion)
        current_task=$(get_current_task)

        # Try to enhance the message with format
        enhanced_msg="$suggested_type$([ -n "$suggested_scope" ] && echo "($suggested_scope)")$([ -n "$current_task" ] && echo ": Task $current_task/75 - ")$original_msg"

        echo "$enhanced_msg" > "$msg_file"

        # Add helpful comments
        cat << EOF >> "$msg_file"

# Message was enhanced with suggested format
# Original: $original_msg
#
# You can edit the type and scope above if needed
# Remove this comment section before committing
EOF
    fi
}

# Function: Validate commit message format
validate_message() {
    local msg_file="$1"
    local commit_msg

    # Get first line (actual commit message, excluding comments)
    commit_msg=$(grep -v "^#" "$msg_file" | head -1 | tr -d '\n\r')

    if [ -z "$commit_msg" ]; then
        return 0  # Empty message, will be handled by git
    fi

    # Check if message follows format
    if [[ "$commit_msg" =~ ^(feat|fix|docs|style|refactor|test|chore)(\([a-z-]+\))?: ]]; then
        # Check length
        if [ ${#commit_msg} -gt 72 ]; then
            cat << EOF >> "$msg_file"

# WARNING: Commit message is ${#commit_msg} characters (recommended: <72)
# Consider making it more concise
EOF
        fi

        # Check if it ends with period
        if [[ "$commit_msg" =~ \.$  ]]; then
            cat << EOF >> "$msg_file"

# NOTE: Commit subject should not end with a period
# Consider removing the trailing period
EOF
        fi
    else
        cat << EOF >> "$msg_file"

# WARNING: Commit message doesn't follow conventional format
# Expected: type(scope): subject
# Example: feat(quality): add automated testing
#
# Types: feat, fix, docs, style, refactor, test, chore
EOF
    fi
}

# Function: Add task tracking information
add_task_tracking() {
    local msg_file="$1"
    local current_task

    current_task=$(get_current_task)

    if [ -n "$current_task" ]; then
        cat << EOF >> "$msg_file"

# Task Tracking:
#   Current Task: $current_task/75
#   Phase: $(grep -A5 "Task $current_task" "$LEVEL1_DIR/level-1-dev-plan.md" 2>/dev/null | grep "Phase" | head -1 | sed 's/.*Phase/Phase/' || echo "Unknown")
#
#   This commit contributes to the Level-1-Dev platform development
EOF
    fi
}

# Function: Add quality information
add_quality_info() {
    local msg_file="$1"

    # Check if quality tools are available and add relevant info
    if [ -x "$QUALITY_DIR/quality-dashboard.sh" ]; then
        local quality_score
        quality_score=$("$QUALITY_DIR/quality-dashboard.sh" 2>/dev/null | grep -o "[0-9]\+/100" | head -1 || echo "Unknown")

        if [ -n "$quality_score" ] && [ "$quality_score" != "Unknown" ]; then
            cat << EOF >> "$msg_file"

# Quality Status:
#   Current Quality Score: $quality_score
#   Run './quality/quality-dashboard.sh' for detailed metrics
EOF
        fi
    fi
}

# Main execution
main() {
    # Skip processing for certain commit sources
    case "${COMMIT_SOURCE:-}" in
        "merge"|"squash"|"template")
            # Don't modify merge commits, squash commits, or template commits
            exit 0
            ;;
        "message"|"commit")
            # These are user-provided messages via -m or -F
            # We can enhance them but should be careful
            ;;
        "")
            # Default case - interactive commit or no source specified
            ;;
    esac

    # Process the commit message
    process_existing_message "$COMMIT_MSG_FILE"

    # Add validation warnings
    validate_message "$COMMIT_MSG_FILE"

    # Add task tracking information
    add_task_tracking "$COMMIT_MSG_FILE"

    # Add quality information
    add_quality_info "$COMMIT_MSG_FILE"

    # Add final separator
    cat << EOF >> "$COMMIT_MSG_FILE"

# ─────────────────────────────────────────────────────────────────────
# Level-1-Dev Quality System - Commit Message Enhancement
# Remove all comment lines starting with # before committing
EOF
}

# Run main function
main "$@"
