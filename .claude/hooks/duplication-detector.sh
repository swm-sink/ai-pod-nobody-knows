#!/bin/bash

# Automated Duplication Detection - Zero Tolerance Enforcement
# Pre-commit hook that blocks ALL commits containing duplicate files
# Implements nuclear option DRY enforcement with no bypasses

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
VIOLATION_LOG="$PROJECT_ROOT/.claude/logs/dry-violations.log"
DETECTION_LOG="$PROJECT_ROOT/.claude/logs/duplication-detection.log"
TOLERANCE_LEVEL=0  # Zero tolerance - any duplication blocks commit

# Ensure log directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Generate detection correlation ID
generate_detection_id() {
    echo "detect_$(date +%s)_$(openssl rand -hex 3)" 2>/dev/null || echo "detect_$(date +%s)_fallback"
}

# Check for duplicate file content using checksums
detect_content_duplicates() {
    local detection_id=$(generate_detection_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local violations=()

    echo "$timestamp SCAN_START: ID=$detection_id Scanning for content duplicates" >> "$DETECTION_LOG"

    # Generate checksums for all non-binary files, excluding logs and git files
    local temp_checksums=$(mktemp)
    find . -type f \
        -not -path "./.git/*" \
        -not -path "./.claude/logs/*" \
        -not -path "./.claude/cache/*" \
        -not -path "./.claude/state/*" \
        -not -path "./node_modules/*" \
        -not -path "./.vscode/*" \
        -not -name "*.log" \
        -not -name "*.mp3" \
        -not -name "*.wav" \
        -not -name "*.json" \
        -exec sha256sum {} \; 2>/dev/null | sort > "$temp_checksums"

    # Find duplicate checksums
    local duplicates=$(awk '{print $1}' "$temp_checksums" | sort | uniq -d)

    if [[ -n "$duplicates" ]]; then
        echo "$timestamp VIOLATION_DETECTED: ID=$detection_id Found duplicate content" >> "$DETECTION_LOG"

        while IFS= read -r checksum; do
            local files=$(grep "^$checksum" "$temp_checksums" | awk '{print $2}' | tr '\n' ' ')
            violations+=("CONTENT_DUPLICATE: Files with identical content: $files")
            echo "$timestamp CONTENT_VIOLATION: Checksum=$checksum Files=$files" >> "$VIOLATION_LOG"
        done <<< "$duplicates"
    fi

    rm -f "$temp_checksums"
    echo "${violations[@]}"
}

# Check for similar file names that suggest duplication
detect_name_duplicates() {
    local detection_id=$(generate_detection_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local violations=()

    echo "$timestamp NAME_SCAN: ID=$detection_id Scanning for suspicious naming patterns" >> "$DETECTION_LOG"

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
            2>/dev/null)

        if [[ -n "$matches" ]]; then
            while IFS= read -r file; do
                violations+=("NAME_VIOLATION: Suspicious filename suggesting duplicate: $file")
                echo "$timestamp NAME_VIOLATION: Pattern=$pattern File=$file" >> "$VIOLATION_LOG"
            done <<< "$matches"
        fi
    done

    echo "${violations[@]}"
}

# Check for duplicate directory structures
detect_directory_duplicates() {
    local detection_id=$(generate_detection_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local violations=()

    echo "$timestamp DIR_SCAN: ID=$detection_id Scanning for duplicate directories" >> "$DETECTION_LOG"

    # Look for directory patterns that suggest duplication
    local suspicious_dirs=(
        "archive"
        "backup"
        "old"
        "legacy"
        "_test"
        "_temp"
    )

    for dir_pattern in "${suspicious_dirs[@]}"; do
        local matches=$(find . -type d -name "*${dir_pattern}*" \
            -not -path "./.git/*" \
            2>/dev/null)

        if [[ -n "$matches" ]]; then
            while IFS= read -r dir; do
                violations+=("DIR_VIOLATION: Suspicious directory name: $dir")
                echo "$timestamp DIR_VIOLATION: Pattern=$dir_pattern Directory=$dir" >> "$VIOLATION_LOG"
            done <<< "$matches"
        fi
    done

    echo "${violations[@]}"
}

# Check for duplicate hooks (multiple versions of same functionality)
detect_hook_duplicates() {
    local detection_id=$(generate_detection_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local violations=()

    echo "$timestamp HOOK_SCAN: ID=$detection_id Scanning for hook duplicates" >> "$DETECTION_LOG"

    # Define allowed hook patterns (exactly these files allowed)
    local allowed_hooks=(
        "enhanced-pre-tool-cost-validation.sh"
        "enhanced-post-tool-cost-tracking.sh"
        "mcp-reliability-monitor.sh"
        "baseline-metrics-capture.sh"
        "config-protection-system.sh"
        "automated-billing-reconciliation.sh"
        "realtime-cost-attribution.sh"
        "mcp-diagnostics-validator.sh"
        "shadow-mode-validation.sh"
        "session-cleanup.sh"
        "error-recovery-handler.sh"
        "user-prompt-submit.sh"
        "duplication-detector.sh"
    )

    # Count actual hook files
    local actual_hooks=$(find .claude/hooks -type f -name "*.sh" 2>/dev/null | wc -l)
    local allowed_count=${#allowed_hooks[@]}

    if [[ $actual_hooks -gt $allowed_count ]]; then
        violations+=("HOOK_VIOLATION: Too many hooks detected ($actual_hooks > $allowed_count)")
        echo "$timestamp HOOK_VIOLATION: Expected=$allowed_count Actual=$actual_hooks" >> "$VIOLATION_LOG"

        # List unauthorized hooks
        find .claude/hooks -type f -name "*.sh" 2>/dev/null | while read -r hook; do
            local hook_name=$(basename "$hook")
            local is_allowed=false

            for allowed in "${allowed_hooks[@]}"; do
                if [[ "$hook_name" == "$allowed" ]]; then
                    is_allowed=true
                    break
                fi
            done

            if [[ "$is_allowed" == "false" ]]; then
                violations+=("UNAUTHORIZED_HOOK: $hook not in approved list")
                echo "$timestamp UNAUTHORIZED_HOOK: File=$hook" >> "$VIOLATION_LOG"
            fi
        done
    fi

    echo "${violations[@]}"
}

# Main violation detection
detect_all_violations() {
    local detection_id=$(generate_detection_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local all_violations=()

    echo "$timestamp FULL_SCAN_START: ID=$detection_id Beginning comprehensive duplication scan" >> "$DETECTION_LOG"

    # Run all detection methods
    local content_violations=($(detect_content_duplicates))
    local name_violations=($(detect_name_duplicates))
    local directory_violations=($(detect_directory_duplicates))
    local hook_violations=($(detect_hook_duplicates))

    # Combine all violations
    all_violations+=("${content_violations[@]}")
    all_violations+=("${name_violations[@]}")
    all_violations+=("${directory_violations[@]}")
    all_violations+=("${hook_violations[@]}")

    local violation_count=${#all_violations[@]}

    echo "$timestamp SCAN_COMPLETE: ID=$detection_id Total_Violations=$violation_count" >> "$DETECTION_LOG"

    # Return violation count and details
    if [[ $violation_count -gt $TOLERANCE_LEVEL ]]; then
        echo "VIOLATIONS_DETECTED:$violation_count"
        printf '%s\n' "${all_violations[@]}"
        return 1
    else
        echo "CLEAN:$violation_count"
        return 0
    fi
}

# Generate violation report
generate_violation_report() {
    local violations=("$@")
    local report_file="$PROJECT_ROOT/.claude/logs/violation-report-$(date +%Y%m%d-%H%M%S).txt"

    cat > "$report_file" <<EOF
# DRY VIOLATION REPORT
Generated: $(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
Violation Count: ${#violations[@]}
Tolerance Level: $TOLERANCE_LEVEL (Zero Tolerance)

## VIOLATIONS DETECTED:

EOF

    local i=1
    for violation in "${violations[@]}"; do
        echo "$i. $violation" >> "$report_file"
        ((i++))
    done

    cat >> "$report_file" <<EOF

## RESOLUTION REQUIRED:

ALL violations must be resolved before any commit can proceed.
No bypasses, no exceptions, no warnings - ZERO TOLERANCE.

## REMEDIATION STEPS:

1. Identify the single-source-of-truth version for each duplicate
2. Delete all duplicate files/directories
3. Update all references to point to single source
4. Verify no functionality is lost
5. Re-run duplication detection to confirm clean state
6. Only then attempt commit again

## POLICY REFERENCE:

See CLAUDE.md - ZERO-TOLERANCE DRY ENFORCEMENT section
This is NON-NEGOTIABLE and ABSOLUTE.

EOF

    echo "Violation report generated: $report_file"
}

# Main execution
main() {
    local operation="${1:-detect}"

    case "$operation" in
        "detect"|"check")
            echo "🔍 ZERO-TOLERANCE DUPLICATION DETECTION"
            echo "========================================"

            local scan_result=$(detect_all_violations)
            local exit_code=$?

            if [[ $exit_code -eq 0 ]]; then
                echo "✅ CLEAN: No duplication violations detected"
                echo "   Project maintains single-source-of-truth compliance"
                return 0
            else
                echo "🚨 VIOLATIONS DETECTED - COMMIT BLOCKED"
                echo "========================================"
                echo

                # Extract violation details
                local lines=($scan_result)
                local header="${lines[0]}"
                local violation_count=$(echo "$header" | cut -d':' -f2)

                echo "Violation Count: $violation_count"
                echo "Tolerance Level: $TOLERANCE_LEVEL (ZERO)"
                echo
                echo "DETAILED VIOLATIONS:"
                echo "-------------------"

                # Show all violations except the header
                for ((i=1; i<${#lines[@]}; i++)); do
                    echo "$i. ${lines[i]}"
                done

                echo
                echo "🛑 COMMIT BLOCKED - ZERO TOLERANCE POLICY"
                echo "   ALL violations must be resolved before proceeding"
                echo "   See violation report in .claude/logs/ for details"

                # Generate detailed report
                generate_violation_report "${lines[@]:1}"

                return 1
            fi
            ;;
        *)
            echo "Usage: $0 {detect|check}" >&2
            echo "  detect/check: Run comprehensive duplication detection" >&2
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
