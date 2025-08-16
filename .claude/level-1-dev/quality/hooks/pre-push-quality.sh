#!/bin/bash

# Pre-push Quality Validation for Level-1-Dev
# Comprehensive quality checks before pushing to remote

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LEVEL1_DIR="$(cd "$QUALITY_DIR/.." && pwd)"
SKIP_MARKER=".skip-pre-push-checks"
MAX_DURATION=120  # Maximum seconds for pre-push checks

# Git hook parameters
remote="${1:-origin}"
url="${2:-unknown}"

# Check counters
CHECKS_RUN=0
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# Timing
START_TIME=$(date +%s)

# Function: Check if should skip
should_skip() {
    # Check for skip marker file
    if [ -f "$SKIP_MARKER" ]; then
        echo -e "${YELLOW}⚠ Pre-push checks skipped (marker file present)${NC}"
        rm "$SKIP_MARKER"
        return 0
    fi

    # Check for emergency bypass
    if [ "${EMERGENCY_PUSH:-}" = "true" ]; then
        echo -e "${YELLOW}⚠ Emergency push - skipping quality checks${NC}"
        return 0
    fi

    # Check for --no-verify (though it bypasses all hooks)
    if [ "${GIT_PARAMS:-}" = "--no-verify" ]; then
        echo -e "${YELLOW}⚠ Pre-push checks bypassed with --no-verify${NC}"
        return 0
    fi

    return 1
}

# Function: Log check result
log_check() {
    local check_name=$1
    local status=$2
    local message=${3:-""}

    ((CHECKS_RUN++))

    case $status in
        "pass")
            ((CHECKS_PASSED++))
            echo -e "  ${GREEN}✓${NC} $check_name"
            ;;
        "fail")
            ((CHECKS_FAILED++))
            echo -e "  ${RED}✗${NC} $check_name"
            if [ -n "$message" ]; then
                echo -e "    ${RED}$message${NC}"
            fi
            ;;
        "warn")
            ((CHECKS_WARNED++))
            echo -e "  ${YELLOW}⚠${NC} $check_name"
            if [ -n "$message" ]; then
                echo -e "    ${YELLOW}$message${NC}"
            fi
            ;;
    esac
}

# Function: Check execution time
check_time_limit() {
    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))

    if [ $elapsed -gt $MAX_DURATION ]; then
        echo -e "${YELLOW}⚠ Time limit exceeded, allowing push to continue${NC}"
        return 1
    fi
    return 0
}

# Function: Get commits being pushed
get_push_commits() {
    local range
    local local_ref
    local local_sha
    local remote_ref
    local remote_sha

    # Read from stdin the refs being pushed
    while read local_ref local_sha remote_ref remote_sha; do
        if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
            # Deleting branch, no validation needed
            continue
        fi

        if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
            # New branch, check all commits
            range="$local_sha"
        else
            # Existing branch, check new commits
            range="$remote_sha..$local_sha"
        fi

        echo "$range"
    done
}

# Check 1: Full test suite execution
run_comprehensive_tests() {
    if ! check_time_limit; then
        return 0
    fi

    echo -e "${BLUE}Running comprehensive test suite...${NC}"

    if [ -x "$LEVEL1_DIR/tests/run-all-tests.sh" ]; then
        local test_output
        local test_status

        test_output=$("$LEVEL1_DIR/tests/run-all-tests.sh" 2>&1)
        test_status=$?

        if [ $test_status -eq 0 ]; then
            local passed_tests=$(echo "$test_output" | grep -c "✓\|PASS" || echo 0)
            log_check "Comprehensive test suite" "pass" "$passed_tests tests passed"
        else
            local failed_tests=$(echo "$test_output" | grep -c "✗\|FAIL" || echo 0)
            log_check "Comprehensive test suite" "fail" "$failed_tests tests failed"
            echo "$test_output" | tail -10
            return 1
        fi
    else
        log_check "Test suite runner" "warn" "Test runner not found"
    fi
}

# Check 2: Version consistency validation
validate_versions() {
    if ! check_time_limit; then
        return 0
    fi

    echo -e "${BLUE}Validating version consistency...${NC}"

    if [ -x "$LEVEL1_DIR/bin/version-validator.sh" ]; then
        local validation_output
        local validation_status

        validation_output=$("$LEVEL1_DIR/bin/version-validator.sh" --quiet 2>&1)
        validation_status=$?

        if [ $validation_status -eq 0 ]; then
            log_check "Version consistency" "pass"
        else
            local issues=$(echo "$validation_output" | grep -c "Error\|Failed" || echo 0)
            log_check "Version consistency" "fail" "$issues version issues"
            return 1
        fi
    else
        log_check "Version validator" "warn" "Validator not available"
    fi
}

# Check 3: Security scan
security_validation() {
    if ! check_time_limit; then
        return 0
    fi

    echo -e "${BLUE}Running security validation...${NC}"

    local security_issues=0

    # Check for dangerous patterns in new commits
    local commit_ranges=$(get_push_commits)

    if [ -n "$commit_ranges" ]; then
        for range in $commit_ranges; do
            local dangerous_patterns=(
                'password\s*=\s*["\047][^"\047]*["\047]'
                'api_key\s*=\s*["\047][^"\047]*["\047]'
                'secret\s*=\s*["\047][^"\047]*["\047]'
                'token\s*=\s*["\047][^"\047]*["\047]'
                'eval\s+\$'
                'rm\s+-rf\s+/'
                'curl\s+.*\|\s*bash'
            )

            for pattern in "${dangerous_patterns[@]}"; do
                if git diff --name-only "$range" | xargs grep -l "$pattern" >/dev/null 2>&1; then
                    ((security_issues++))
                fi
            done
        done
    fi

    if [ $security_issues -eq 0 ]; then
        log_check "Security scan" "pass"
    else
        log_check "Security scan" "fail" "$security_issues security issues in pushed commits"
        return 1
    fi
}

# Check 4: Quality metrics validation
validate_quality_metrics() {
    if ! check_time_limit; then
        return 0
    fi

    echo -e "${BLUE}Validating quality metrics...${NC}"

    # Run quality dashboard to get current metrics
    if [ -x "$QUALITY_DIR/quality-dashboard.sh" ]; then
        local dashboard_output
        dashboard_output=$("$QUALITY_DIR/quality-dashboard.sh" 2>&1 || true)

        # Check for critical quality failures
        if echo "$dashboard_output" | grep -q "Security.*Issues Found"; then
            log_check "Quality metrics" "fail" "Security issues detected"
            return 1
        fi

        if echo "$dashboard_output" | grep -q "Failed.*[5-9][0-9]\|Failed.*[1-9][0-9][0-9]"; then
            log_check "Quality metrics" "fail" "Too many test failures"
            return 1
        fi

        log_check "Quality metrics" "pass"
    else
        log_check "Quality dashboard" "warn" "Dashboard not available"
    fi
}

# Check 5: Compatibility validation
validate_compatibility() {
    if ! check_time_limit; then
        return 0
    fi

    echo -e "${BLUE}Validating component compatibility...${NC}"

    if [ -x "$LEVEL1_DIR/bin/compatibility-checker.sh" ]; then
        local compat_output
        local compat_status

        compat_output=$("$LEVEL1_DIR/bin/compatibility-checker.sh" validate 2>&1)
        compat_status=$?

        if [ $compat_status -eq 0 ]; then
            log_check "Component compatibility" "pass"
        else
            local conflicts=$(echo "$compat_output" | grep -c "Conflict\|Error" || echo 0)
            log_check "Component compatibility" "fail" "$conflicts compatibility issues"
            return 1
        fi
    else
        log_check "Compatibility checker" "warn" "Checker not available"
    fi
}

# Check 6: Documentation validation
validate_documentation() {
    if ! check_time_limit; then
        return 0
    fi

    echo -e "${BLUE}Validating documentation...${NC}"

    local doc_issues=0

    # Check that new components have documentation
    local commit_ranges=$(get_push_commits)

    if [ -n "$commit_ranges" ]; then
        for range in $commit_ranges; do
            # Check for new .md files in agents or commands
            local new_components=$(git diff --name-only --diff-filter=A "$range" | grep -E "(agents|commands)/.*\.md$" || true)

            for component in $new_components; do
                if [ -f "$component" ]; then
                    # Check if it has required sections
                    if ! grep -q "^##\|^#.*Description\|^#.*Usage" "$component"; then
                        ((doc_issues++))
                    fi
                fi
            done
        done
    fi

    if [ $doc_issues -eq 0 ]; then
        log_check "Documentation validation" "pass"
    else
        log_check "Documentation validation" "warn" "$doc_issues components need better documentation"
    fi
}

# Check 7: Performance validation
validate_performance() {
    if ! check_time_limit; then
        return 0
    fi

    echo -e "${BLUE}Validating performance...${NC}"

    # Quick performance check of critical scripts
    local slow_scripts=0

    for script in "$LEVEL1_DIR/bin"/*.sh; do
        if [ -x "$script" ]; then
            local start_time=$(date +%s%N)

            # Test help command (should be fast)
            if timeout 3 "$script" --help >/dev/null 2>&1; then
                local end_time=$(date +%s%N)
                local duration_ms=$(( (end_time - start_time) / 1000000 ))

                # Flag if script takes more than 1 second for help
                if [ $duration_ms -gt 1000 ]; then
                    ((slow_scripts++))
                fi
            fi
        fi
    done

    if [ $slow_scripts -eq 0 ]; then
        log_check "Performance validation" "pass"
    else
        log_check "Performance validation" "warn" "$slow_scripts scripts are slow"
    fi
}

# Check 8: Commit message validation
validate_commit_messages() {
    echo -e "${BLUE}Validating commit messages...${NC}"

    local bad_commits=0
    local commit_ranges=$(get_push_commits)

    if [ -n "$commit_ranges" ]; then
        for range in $commit_ranges; do
            # Get commit messages in range
            local commits=$(git log --format="%H %s" "$range" 2>/dev/null || true)

            while IFS= read -r commit_line; do
                if [ -n "$commit_line" ]; then
                    local commit_msg=$(echo "$commit_line" | cut -d' ' -f2-)

                    # Check format: type(scope): subject
                    if ! [[ "$commit_msg" =~ ^(feat|fix|docs|style|refactor|test|chore)(\([a-z-]+\))?: ]]; then
                        ((bad_commits++))
                    fi
                fi
            done <<< "$commits"
        done
    fi

    if [ $bad_commits -eq 0 ]; then
        log_check "Commit message format" "pass"
    else
        log_check "Commit message format" "warn" "$bad_commits commits don't follow format"
    fi
}

# Function: Generate summary
generate_summary() {
    local elapsed=$(($(date +%s) - START_TIME))

    echo ""
    echo "======================================"
    echo -e "${BLUE}Pre-push Quality Check Summary${NC}"
    echo "======================================"
    echo "Remote: $remote"
    echo "URL: $url"
    echo "Checks Run:    $CHECKS_RUN"
    echo -e "Passed:        ${GREEN}$CHECKS_PASSED${NC}"
    echo -e "Failed:        ${RED}$CHECKS_FAILED${NC}"
    echo -e "Warnings:      ${YELLOW}$CHECKS_WARNED${NC}"
    echo "Time:          ${elapsed}s"
    echo ""

    if [ $CHECKS_FAILED -gt 0 ]; then
        echo -e "${RED}✗ Pre-push quality checks failed!${NC}"
        echo ""
        echo "Push rejected. Please fix the issues above and try again."
        echo ""
        echo "To bypass (NOT RECOMMENDED):"
        echo "  touch .skip-pre-push-checks && git push"
        echo "  EMERGENCY_PUSH=true git push"
        echo ""
        return 1
    elif [ $CHECKS_WARNED -gt 0 ]; then
        echo -e "${YELLOW}⚠ Pre-push checks passed with warnings${NC}"
        echo ""
        echo "Consider addressing the warnings before pushing."
        return 0
    else
        echo -e "${GREEN}✓ All pre-push quality checks passed!${NC}"
        return 0
    fi
}

# Main execution
main() {
    # Handle dry-run mode for testing
    if [ "${1:-}" = "--dry-run" ]; then
        echo "Pre-push validation (dry-run mode)"
        exit 0
    fi

    echo "======================================"
    echo -e "${BLUE}Running Pre-push Quality Checks${NC}"
    echo "======================================"
    echo ""

    # Check if should skip
    if should_skip; then
        exit 0
    fi

    # Run all checks
    run_comprehensive_tests || true
    validate_versions || true
    security_validation || true
    validate_quality_metrics || true
    validate_compatibility || true
    validate_documentation || true
    validate_performance || true
    validate_commit_messages || true

    # Generate summary and exit
    generate_summary
}

# Run main
main "$@"
