#!/bin/bash

# Validation Suite - Unified Project Governance Hook
# Consolidates agent architecture, context limits, and DRY enforcement
# Implements CLAUDE.md compliance (12 hooks maximum)

set -euo pipefail

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

HOOK_NAME="validation-suite"
LOG_FILE=".claude/logs/validation-suite.log"
CONTEXT_DIR=".claude/context"
FILE_LIMIT=15
TOLERANCE_LEVEL=0

# Ensure log directory exists
mkdir -p ".claude/logs"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$HOOK_NAME] $1" | tee -a "$LOG_FILE"
}

# =============================================================================
# AGENT ARCHITECTURE VALIDATION
# =============================================================================

check_agent_modifications() {
    local modified_files="$1"
    if echo "$modified_files" | grep -qE "\\.claude/(agents|commands)/.*\\.md$"; then
        return 0  # Agent files being modified
    fi
    return 1  # No agent files being modified
}

validate_agent_patterns() {
    local file="$1"
    local errors=""

    # Check for incorrect Task tool delegation patterns
    if grep -q "Use Task tool.*delegate.*agent" "$file"; then
        errors+="❌ INCORRECT: Found Task tool delegation pattern in $file\n"
        errors+="   Use direct invocation: 'Use the [agent-name] agent to...'\n"
    fi

    # Check for agent YAML with restricted tools
    if [[ "$file" =~ \.claude/agents/.*\.md$ ]] && grep -q "^tools:" "$file"; then
        errors+="⚠️  WARNING: Agent $file has tools restriction - may block MCP inheritance\n"
        errors+="   Consider removing 'tools:' field for full MCP access\n"
    fi

    # Check for missing direct invocation patterns in commands
    if [[ "$file" =~ \.claude/commands/.*\.md$ ]] && ! grep -q "Use the .* agent to" "$file"; then
        errors+="⚠️  WARNING: Command $file may not use direct sub-agent invocation\n"
        errors+="   Ensure proper 'Use the [agent-name] agent to...' patterns\n"
    fi

    echo -e "$errors"
}

run_agent_architecture_validation() {
    local modified_files="${1:-}"
    local validation_errors=0

    if [ -z "$modified_files" ]; then
        return 0
    fi

    if check_agent_modifications "$modified_files"; then
        log "🚨 AGENT MODIFICATIONS DETECTED - Loading architecture context..."

        # Display critical architecture reminder
        cat << 'EOF'

🚨 CRITICAL ARCHITECTURE REMINDER 🚨

You are modifying agent or command files. MANDATORY requirements:

📖 REQUIRED READING: @.claude/context/sub-agent-architecture.md
🔧 MCP INTEGRATION: @.claude/context/mcp-tool-inheritance.md

✅ CORRECT PATTERN:
   Use the [agent-name] agent to [action]: "requirements"

❌ INCORRECT PATTERN:
   Use Task tool to delegate to [agent-name]

🔍 VALIDATION CHECKLIST:
- [ ] Uses direct sub-agent invocation (NOT Task tool)
- [ ] Agent YAML omits 'tools:' field for MCP inheritance
- [ ] Commands specify MCP tool requirements
- [ ] Expected result: >0 tool uses (not simulation)

EOF

        # Validate each modified agent/command file
        local file_validation_errors=""
        while IFS= read -r file; do
            if [[ "$file" =~ \\.claude/(agents|commands)/.*\\.md$ ]] && [[ -f "$file" ]]; then
                log "Validating: $file"
                local file_errors
                file_errors=$(validate_agent_patterns "$file")
                if [[ -n "$file_errors" ]]; then
                    file_validation_errors+="$file_errors"
                    validation_errors=1
                fi
            fi
        done <<< "$modified_files"

        # Report validation results
        if [[ -n "$file_validation_errors" ]]; then
            log "🚨 ARCHITECTURE VIOLATIONS DETECTED:"
            echo -e "$file_validation_errors"

            cat << 'EOF'

🔧 REQUIRED ACTIONS:
1. Load architecture context: @.claude/context/sub-agent-architecture.md
2. Fix identified pattern violations
3. Test with real sub-agent execution (verify >0 tool uses)
4. Ensure MCP tool inheritance is working

EOF
        else
            log "✅ Architecture patterns look compliant"
        fi

        # Always remind about the documentation
        echo ""
        echo "📚 Before proceeding, ensure you've reviewed:"
        echo "   @.claude/context/sub-agent-architecture.md"
        echo "   @.claude/context/mcp-tool-inheritance.md"
        echo ""
    else
        log "No agent modifications detected"
    fi

    return $validation_errors
}

# =============================================================================
# CONTEXT FILE LIMIT ENFORCEMENT
# =============================================================================

count_context_files() {
    if [[ -d "$CONTEXT_DIR" ]]; then
        find "$CONTEXT_DIR" -name "*.md" -type f | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

list_context_files() {
    if [[ -d "$CONTEXT_DIR" ]]; then
        find "$CONTEXT_DIR" -name "*.md" -type f | sort
    fi
}

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

run_context_file_enforcement() {
    local enforcement_errors=0

    echo "🔍 Context File Limit Enforcement Check"

    # Count current context files
    local current_count=$(count_context_files)
    echo "📊 Current context files: $current_count/$FILE_LIMIT"

    log "Context file check: $current_count/$FILE_LIMIT files"

    # Check file limit
    if [[ $current_count -gt $FILE_LIMIT ]]; then
        echo ""
        echo "🚨 CONTEXT FILE LIMIT EXCEEDED!"
        echo "❌ Current files: $current_count"
        echo "✅ Maximum allowed: $FILE_LIMIT"
        echo "📝 Excess files: $((current_count - FILE_LIMIT))"
        echo ""
        echo "📋 Current context files:"
        list_context_files | sed 's/^/  - /'
        echo ""
        echo "🔧 REQUIRED ACTIONS:"
        echo "  1. Use /context-consolidate to merge related files"
        echo "  2. Remove redundant or outdated files"
        echo "  3. Ensure each topic is covered in exactly one file"

        log "BLOCKED: File limit exceeded ($current_count > $FILE_LIMIT)"
        enforcement_errors=1
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

        log "BLOCKED: Topic duplication detected"
        enforcement_errors=1
    fi

    if [[ $enforcement_errors -eq 0 ]]; then
        echo "✅ Context file governance: COMPLIANT"
        echo "📊 Files: $current_count/$FILE_LIMIT"
        echo "🔒 No topic duplication detected"
        log "PASSED: Context governance compliant ($current_count/$FILE_LIMIT files)"

        # Additional recommendations
        if [[ $current_count -gt $((FILE_LIMIT - 3)) ]]; then
            echo "⚠️  WARNING: Approaching file limit ($current_count/$FILE_LIMIT)"
            echo "💡 Consider consolidating related files proactively"
            log "WARNING: Approaching file limit ($current_count/$FILE_LIMIT)"
        fi
    fi

    return $enforcement_errors
}

# =============================================================================
# DRY ENFORCEMENT / DUPLICATION DETECTION
# =============================================================================

generate_detection_id() {
    echo "detect_$(date +%s)_$(openssl rand -hex 3)" 2>/dev/null || echo "detect_$(date +%s)_fallback"
}

detect_content_duplicates() {
    local detection_id=$(generate_detection_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local violations=()
    violations=()

    # Generate checksums for all non-binary files, excluding logs, git files, and virtual environments
    local temp_checksums=$(mktemp)
    find . -type f \
        -not -path "./.git/*" \
        -not -path "./.claude/logs/*" \
        -not -path "./.claude/cache/*" \
        -not -path "./.claude/state/*" \
        -not -path "./node_modules/*" \
        -not -path "./.vscode/*" \
        -not -path "./.venv/*" \
        -not -path "./venv/*" \
        -not -path "./.env/*" \
        -not -path "./env/*" \
        -not -path "./__pycache__/*" \
        -not -path "./.pytest_cache/*" \
        -not -name "*.log" \
        -not -name "*.mp3" \
        -not -name "*.wav" \
        -not -name "*.json" \
        -exec sha256sum {} \; 2>/dev/null | sort > "$temp_checksums"

    # Find duplicate checksums
    local duplicates=$(awk '{print $1}' "$temp_checksums" | sort | uniq -d)

    if [[ -n "$duplicates" ]]; then
        while IFS= read -r checksum; do
            local files=$(grep "^$checksum" "$temp_checksums" | awk '{print $2}' | tr '\n' ' ')
            violations+=("CONTENT_DUPLICATE: Files with identical content: $files")
        done <<< "$duplicates"
    fi

    rm -f "$temp_checksums"
    if [[ ${#violations[@]} -gt 0 ]]; then
        printf '%s\n' "${violations[@]}"
    fi
}

detect_name_duplicates() {
    local violations=()
    violations=()

    # Look for files with suspicious patterns
    local suspicious_patterns=(
        "_backup"
        "_copy"
        "_old"
        "_legacy"
        "_v[0-9]"
        "_[0-9]$"
        "\\-backup"
        "\\-copy"
        "\\-old"
        "\\-v[0-9]"
    )

    for pattern in "${suspicious_patterns[@]}"; do
        local matches=$(find . -type f -name "*${pattern}*" \
            -not -path "./.git/*" \
            -not -path "./.claude/logs/*" \
            -not -path "./.venv/*" \
            -not -path "./venv/*" \
            -not -path "./node_modules/*" \
            2>/dev/null)

        if [[ -n "$matches" ]]; then
            while IFS= read -r file; do
                violations+=("NAME_VIOLATION: Suspicious filename suggesting duplicate: $file")
            done <<< "$matches"
        fi
    done

    if [[ ${#violations[@]} -gt 0 ]]; then
        printf '%s\n' "${violations[@]}"
    fi
}

run_dry_enforcement() {
    local dry_errors=0

    echo "🔍 ZERO-TOLERANCE DUPLICATION DETECTION"
    echo "========================================"

    # Collect all violations
    local content_violations=()
    local name_violations=()
    content_violations=($(detect_content_duplicates))
    name_violations=($(detect_name_duplicates))

    # Combine all violations
    local all_violations=()
    all_violations=()
    if [[ ${#content_violations[@]} -gt 0 ]]; then
        all_violations+=("${content_violations[@]}")
    fi
    if [[ ${#name_violations[@]} -gt 0 ]]; then
        all_violations+=("${name_violations[@]}")
    fi

    local violation_count=${#all_violations[@]}

    if [[ $violation_count -gt $TOLERANCE_LEVEL ]]; then
        echo "🚨 VIOLATIONS DETECTED - COMMIT BLOCKED"
        echo "========================================"
        echo
        echo "Violation Count: $violation_count"
        echo "Tolerance Level: $TOLERANCE_LEVEL (ZERO)"
        echo
        echo "DETAILED VIOLATIONS:"
        echo "-------------------"

        local i=1
        for violation in "${all_violations[@]}"; do
            echo "$i. $violation"
            ((i++))
        done

        echo
        echo "🛑 COMMIT BLOCKED - ZERO TOLERANCE POLICY"
        echo "   ALL violations must be resolved before proceeding"

        log "BLOCKED: $violation_count DRY violations detected"
        dry_errors=1
    else
        echo "✅ CLEAN: No duplication violations detected"
        echo "   Project maintains single-source-of-truth compliance"
        log "PASSED: No DRY violations detected"
    fi

    return $dry_errors
}

# =============================================================================
# MAIN VALIDATION SUITE EXECUTION
# =============================================================================

main() {
    local modified_files="${1:-}"
    local total_errors=0

    log "🚀 Starting unified validation suite..."

    echo "================================================================"
    echo "🛡️  VALIDATION SUITE - PROJECT GOVERNANCE ENFORCEMENT"
    echo "================================================================"
    echo

    # Run Agent Architecture Validation
    echo "1️⃣  AGENT ARCHITECTURE VALIDATION"
    echo "================================"
    if ! run_agent_architecture_validation "$modified_files"; then
        ((total_errors++))
        log "❌ Agent architecture validation failed"
    else
        log "✅ Agent architecture validation passed"
    fi
    echo

    # Run Context File Enforcement
    echo "2️⃣  CONTEXT FILE LIMIT ENFORCEMENT"
    echo "================================="
    if ! run_context_file_enforcement; then
        ((total_errors++))
        log "❌ Context file enforcement failed"
    else
        log "✅ Context file enforcement passed"
    fi
    echo

    # Run DRY Enforcement
    echo "3️⃣  DRY ENFORCEMENT / DUPLICATION DETECTION"
    echo "=========================================="
    if ! run_dry_enforcement; then
        ((total_errors++))
        log "❌ DRY enforcement failed"
    else
        log "✅ DRY enforcement passed"
    fi
    echo

    # Final validation summary
    echo "================================================================"
    if [[ $total_errors -eq 0 ]]; then
        echo "✅ VALIDATION SUITE: ALL CHECKS PASSED"
        echo "   Project governance compliance confirmed"
        log "🎉 All validations passed - project compliant"
    else
        echo "🚨 VALIDATION SUITE: $total_errors FAILURES DETECTED"
        echo "   Project governance violations must be resolved"
        log "💥 $total_errors validation failures - action required"
    fi
    echo "================================================================"

    return $total_errors
}

# Run the unified validation suite
main "$@"
