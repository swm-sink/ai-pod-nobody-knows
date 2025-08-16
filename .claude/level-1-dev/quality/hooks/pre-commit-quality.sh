#!/bin/bash

# Pre-commit Quality Checks for Level-1-Dev
# Fast, essential quality validations before commit

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LEVEL1_DIR="$(cd "$QUALITY_DIR/.." && pwd)"
SKIP_MARKER=".skip-quality-checks"

# Check counters
CHECKS_RUN=0
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# Timing
START_TIME=$(date +%s)
MAX_DURATION=10  # Maximum seconds for pre-commit checks

# Function: Check if should skip
should_skip() {
    # Check for skip marker file
    if [ -f "$SKIP_MARKER" ]; then
        echo -e "${YELLOW}⚠ Quality checks skipped (marker file present)${NC}"
        rm "$SKIP_MARKER"
        return 0
    fi

    # Check for --no-verify in git
    if [ "${GIT_PARAMS:-}" = "--no-verify" ]; then
        echo -e "${YELLOW}⚠ Quality checks bypassed with --no-verify${NC}"
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
        echo -e "${YELLOW}⚠ Time limit exceeded, skipping remaining checks${NC}"
        return 1
    fi
    return 0
}

# Check 1: Syntax validation for bash scripts
check_syntax() {
    echo -e "${BLUE}Checking script syntax...${NC}"

    local syntax_errors=0
    local files_checked=0

    # Get staged bash files
    for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(sh|bash)$' || true); do
        if [ -f "$file" ]; then
            ((files_checked++))
            if ! bash -n "$file" 2>/dev/null; then
                log_check "$(basename "$file")" "fail" "Syntax error"
                ((syntax_errors++))
            fi
        fi
    done

    if [ $files_checked -eq 0 ]; then
        log_check "No bash scripts to check" "pass"
    elif [ $syntax_errors -eq 0 ]; then
        log_check "Syntax validation" "pass" "$files_checked files OK"
    else
        log_check "Syntax validation" "fail" "$syntax_errors errors found"
        return 1
    fi
}

# Check 2: Security patterns
check_security_patterns() {
    echo -e "${BLUE}Checking for security issues...${NC}"

    local security_issues=0

    # Dangerous patterns to check
    local patterns=(
        'eval \$'
        'rm -rf /'
        'curl .* \| bash'
        'password='
        'token='
        'api_key='
        'secret='
    )

    # Check staged files
    for file in $(git diff --cached --name-only --diff-filter=ACM); do
        if [ -f "$file" ]; then
            for pattern in "${patterns[@]}"; do
                if grep -qE "$pattern" "$file" 2>/dev/null; then
                    log_check "$(basename "$file")" "fail" "Security pattern: $pattern"
                    ((security_issues++))
                fi
            done
        fi
    done

    if [ $security_issues -eq 0 ]; then
        log_check "Security patterns" "pass"
    else
        log_check "Security check" "fail" "$security_issues issues found"
        return 1
    fi
}

# Check 3: Version headers
check_version_headers() {
    echo -e "${BLUE}Checking version headers...${NC}"

    local missing_versions=0

    # Check staged markdown files in agents and commands
    for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E '(agents|commands)/.*\.md$' || true); do
        if [ -f "$file" ]; then
            if ! grep -q "^version:" "$file" 2>/dev/null; then
                log_check "$(basename "$file")" "warn" "Missing version header"
                ((missing_versions++))
            fi
        fi
    done

    if [ $missing_versions -eq 0 ]; then
        log_check "Version headers" "pass"
    else
        log_check "Version headers" "warn" "$missing_versions files need headers"
    fi
}

# Check 4: File size limits
check_file_sizes() {
    echo -e "${BLUE}Checking file sizes...${NC}"

    local large_files=0
    local max_size=$((1024 * 1024))  # 1MB limit

    for file in $(git diff --cached --name-only --diff-filter=ACM); do
        if [ -f "$file" ]; then
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
            if [ "$size" -gt "$max_size" ]; then
                local size_mb=$((size / 1024 / 1024))
                log_check "$(basename "$file")" "warn" "Large file: ${size_mb}MB"
                ((large_files++))
            fi
        fi
    done

    if [ $large_files -eq 0 ]; then
        log_check "File sizes" "pass"
    else
        log_check "File sizes" "warn" "$large_files large files"
    fi
}

# Check 5: Trailing whitespace
check_trailing_whitespace() {
    echo -e "${BLUE}Checking for trailing whitespace...${NC}"

    local whitespace_files=0

    for file in $(git diff --cached --name-only --diff-filter=ACM); do
        if [ -f "$file" ] && [[ ! "$file" =~ \.(jpg|jpeg|png|gif|pdf|zip)$ ]]; then
            if grep -q '[[:space:]]$' "$file" 2>/dev/null; then
                log_check "$(basename "$file")" "warn" "Has trailing whitespace"
                ((whitespace_files++))
            fi
        fi
    done

    if [ $whitespace_files -eq 0 ]; then
        log_check "Trailing whitespace" "pass"
    else
        log_check "Trailing whitespace" "warn" "$whitespace_files files need cleanup"
    fi
}

# Check 6: Commit message format (if available)
check_commit_message() {
    local commit_msg_file="${1:-}"

    if [ -n "$commit_msg_file" ] && [ -f "$commit_msg_file" ]; then
        echo -e "${BLUE}Checking commit message...${NC}"

        local msg=$(cat "$commit_msg_file")

        # Check format: type(scope): subject
        if [[ "$msg" =~ ^(feat|fix|docs|style|refactor|test|chore)(\([a-z-]+\))?: ]]; then
            log_check "Commit message format" "pass"
        else
            log_check "Commit message" "warn" "Should follow: type(scope): subject"
        fi
    fi
}

# Check 7: Quick test run (if tests exist for changed files)
check_quick_tests() {
    if ! check_time_limit; then
        return 0
    fi

    echo -e "${BLUE}Running quick tests...${NC}"

    local test_script="$LEVEL1_DIR/tests/run-quick-tests.sh"

    if [ -x "$test_script" ]; then
        if timeout 5 "$test_script" --staged-only >/dev/null 2>&1; then
            log_check "Quick tests" "pass"
        else
            log_check "Quick tests" "warn" "Some tests failed"
        fi
    else
        log_check "Quick tests" "pass" "No quick tests configured"
    fi
}

# Function: Generate summary
generate_summary() {
    local elapsed=$(($(date +%s) - START_TIME))

    echo ""
    echo "================================"
    echo -e "${BLUE}Pre-commit Quality Check Summary${NC}"
    echo "================================"
    echo "Checks Run:    $CHECKS_RUN"
    echo -e "Passed:        ${GREEN}$CHECKS_PASSED${NC}"
    echo -e "Failed:        ${RED}$CHECKS_FAILED${NC}"
    echo -e "Warnings:      ${YELLOW}$CHECKS_WARNED${NC}"
    echo "Time:          ${elapsed}s"
    echo ""

    if [ $CHECKS_FAILED -gt 0 ]; then
        echo -e "${RED}✗ Quality checks failed!${NC}"
        echo ""
        echo "To bypass (not recommended):"
        echo "  git commit --no-verify"
        echo ""
        echo "To fix issues:"
        echo "  Review the failures above and correct them"
        return 1
    elif [ $CHECKS_WARNED -gt 0 ]; then
        echo -e "${YELLOW}⚠ Quality checks passed with warnings${NC}"
        echo ""
        echo "Consider fixing warnings before commit."
        return 0
    else
        echo -e "${GREEN}✓ All quality checks passed!${NC}"
        return 0
    fi
}

# Main execution
main() {
    echo "================================"
    echo -e "${BLUE}Running Pre-commit Quality Checks${NC}"
    echo "================================"
    echo ""

    # Check if should skip
    if should_skip; then
        exit 0
    fi

    # Run checks
    check_syntax || true
    check_security_patterns || true
    check_version_headers || true
    check_file_sizes || true
    check_trailing_whitespace || true
    check_commit_message "$@" || true
    check_quick_tests || true

    # Generate summary and exit
    generate_summary
}

# Run main
main "$@"
