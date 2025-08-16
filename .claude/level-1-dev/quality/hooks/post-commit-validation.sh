#!/bin/bash

# Post-commit Validation for Level-1-Dev
# Comprehensive quality validation after commit

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LEVEL1_DIR="$(cd "$QUALITY_DIR/.." && pwd)"
REPORTS_DIR="$QUALITY_DIR/reports"
METRICS_FILE="$QUALITY_DIR/metrics.yaml"
STANDARDS_FILE="$QUALITY_DIR/standards.yaml"

# Create reports directory
mkdir -p "$REPORTS_DIR"

# Timing and counters
START_TIME=$(date +%s)
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Current commit info
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_SHORT=$(git rev-parse --short HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B)
COMMIT_AUTHOR=$(git log -1 --pretty=%an)
COMMIT_DATE=$(git log -1 --pretty=%ai)

# Function: Log validation result
log_validation() {
    local category=$1
    local check=$2
    local status=$3
    local details=${4:-""}

    ((TOTAL_CHECKS++))

    case $status in
        "pass")
            ((PASSED_CHECKS++))
            echo -e "${GREEN}✓${NC} [$category] $check"
            ;;
        "fail")
            ((FAILED_CHECKS++))
            echo -e "${RED}✗${NC} [$category] $check"
            if [ -n "$details" ]; then
                echo -e "  ${RED}→ $details${NC}"
            fi
            ;;
        "warn")
            ((WARNINGS++))
            echo -e "${YELLOW}⚠${NC} [$category] $check"
            if [ -n "$details" ]; then
                echo -e "  ${YELLOW}→ $details${NC}"
            fi
            ;;
    esac
}

# Function: Calculate quality score
calculate_quality_score() {
    local reliability_score=${1:-80}
    local maintainability_score=${2:-80}
    local testability_score=${3:-80}
    local security_score=${4:-100}
    local performance_score=${5:-80}

    # Weighted average based on standards.yaml
    local score=$(echo "scale=2; ($reliability_score * 0.30) + ($maintainability_score * 0.25) + ($testability_score * 0.20) + ($security_score * 0.15) + ($performance_score * 0.10)" | bc)

    echo "$score"
}

# Validation 1: Test Suite Execution
run_test_suite() {
    echo -e "\n${BLUE}Running Full Test Suite...${NC}"

    local test_output="$REPORTS_DIR/test-results-$COMMIT_SHORT.txt"
    local tests_passed=0
    local tests_failed=0
    local tests_skipped=0

    # Run all tests
    if [ -x "$LEVEL1_DIR/tests/run-all-tests.sh" ]; then
        if "$LEVEL1_DIR/tests/run-all-tests.sh" > "$test_output" 2>&1; then
            tests_passed=$(grep -c "PASS" "$test_output" || echo 0)
            log_validation "Testing" "Full test suite" "pass" "$tests_passed tests passed"
        else
            tests_failed=$(grep -c "FAIL" "$test_output" || echo 0)
            log_validation "Testing" "Full test suite" "fail" "$tests_failed tests failed"
        fi
    else
        log_validation "Testing" "Test runner" "warn" "Test runner not found"
    fi

    # Calculate test pass rate
    local total_tests=$((tests_passed + tests_failed))
    if [ $total_tests -gt 0 ]; then
        local pass_rate=$((tests_passed * 100 / total_tests))
        echo "  Test pass rate: ${pass_rate}%"

        # Check against minimum threshold
        if [ $pass_rate -lt 90 ]; then
            log_validation "Testing" "Pass rate threshold" "fail" "Below 90% minimum"
        fi
    fi
}

# Validation 2: Code Coverage Analysis
check_code_coverage() {
    echo -e "\n${BLUE}Analyzing Code Coverage...${NC}"

    local coverage_report="$REPORTS_DIR/coverage-$COMMIT_SHORT.txt"
    local coverage_percent=0

    # Simple line-based coverage calculation
    local total_lines=0
    local tested_lines=0

    # Count lines in source files
    for file in "$LEVEL1_DIR/bin"/*.sh "$LEVEL1_DIR/quality/hooks"/*.sh; do
        if [ -f "$file" ]; then
            local lines=$(wc -l < "$file")
            total_lines=$((total_lines + lines))

            # Check if test exists for this file
            local basename=$(basename "$file" .sh)
            if [ -f "$LEVEL1_DIR/tests/test-${basename}.sh" ] || [ -f "$LEVEL1_DIR/tests/unit/test-${basename}.sh" ]; then
                tested_lines=$((tested_lines + lines))
            fi
        fi
    done

    if [ $total_lines -gt 0 ]; then
        coverage_percent=$((tested_lines * 100 / total_lines))
        echo "  Code coverage: ${coverage_percent}%"

        if [ $coverage_percent -ge 70 ]; then
            log_validation "Coverage" "Code coverage" "pass" "${coverage_percent}%"
        elif [ $coverage_percent -ge 50 ]; then
            log_validation "Coverage" "Code coverage" "warn" "${coverage_percent}% (target: 70%)"
        else
            log_validation "Coverage" "Code coverage" "fail" "${coverage_percent}% (minimum: 50%)"
        fi
    else
        log_validation "Coverage" "Coverage calculation" "warn" "No source files found"
    fi

    # Save coverage report
    echo "Coverage Report - Commit: $COMMIT_SHORT" > "$coverage_report"
    echo "Date: $(date)" >> "$coverage_report"
    echo "Total Lines: $total_lines" >> "$coverage_report"
    echo "Tested Lines: $tested_lines" >> "$coverage_report"
    echo "Coverage: ${coverage_percent}%" >> "$coverage_report"
}

# Validation 3: Security Scanning
security_scan() {
    echo -e "\n${BLUE}Performing Security Scan...${NC}"

    local security_report="$REPORTS_DIR/security-$COMMIT_SHORT.txt"
    local security_issues=0

    # Forbidden patterns from standards.yaml
    local patterns=(
        'eval \$'
        'rm -rf /'
        'curl .* \| bash'
        'password='
        'token='
        'api_key='
        'secret='
        'TODO.*security'
        'FIXME.*vulnerability'
    )

    echo "Security Scan Report - Commit: $COMMIT_SHORT" > "$security_report"
    echo "Date: $(date)" >> "$security_report"
    echo "" >> "$security_report"

    # Scan all files
    for file in $(find "$LEVEL1_DIR" -type f -name "*.sh" -o -name "*.yaml" -o -name "*.md" 2>/dev/null); do
        for pattern in "${patterns[@]}"; do
            if grep -n "$pattern" "$file" 2>/dev/null >> "$security_report"; then
                ((security_issues++))
                echo "  Found: $pattern in $(basename "$file")"
            fi
        done
    done

    if [ $security_issues -eq 0 ]; then
        log_validation "Security" "Pattern scan" "pass" "No security issues found"
    else
        log_validation "Security" "Pattern scan" "fail" "$security_issues security patterns detected"
    fi

    # Check file permissions
    local world_writable=$(find "$LEVEL1_DIR" -type f -perm -002 2>/dev/null | wc -l)
    if [ "$world_writable" -gt 0 ]; then
        log_validation "Security" "File permissions" "warn" "$world_writable world-writable files"
    else
        log_validation "Security" "File permissions" "pass"
    fi
}

# Validation 4: Documentation Check
check_documentation() {
    echo -e "\n${BLUE}Checking Documentation...${NC}"

    local doc_issues=0
    local undocumented_functions=0

    # Check for README files
    for dir in "$LEVEL1_DIR/bin" "$LEVEL1_DIR/quality" "$LEVEL1_DIR/tests"; do
        if [ -d "$dir" ] && [ ! -f "$dir/README.md" ]; then
            log_validation "Documentation" "$(basename "$dir") README" "warn" "Missing README.md"
            ((doc_issues++))
        fi
    done

    # Check function documentation in scripts
    for script in "$LEVEL1_DIR/bin"/*.sh; do
        if [ -f "$script" ]; then
            local functions=$(grep -c "^[[:space:]]*function\|^[[:alpha:]_][[:alnum:]_]*()[[:space:]]*{" "$script" || echo 0)
            local documented=$(grep -B1 "^[[:space:]]*function\|^[[:alpha:]_][[:alnum:]_]*()[[:space:]]*{" "$script" | grep -c "^#" || echo 0)

            if [ $functions -gt 0 ] && [ $documented -lt $functions ]; then
                local missing=$((functions - documented))
                undocumented_functions=$((undocumented_functions + missing))
            fi
        fi
    done

    if [ $undocumented_functions -eq 0 ]; then
        log_validation "Documentation" "Function documentation" "pass"
    else
        log_validation "Documentation" "Function documentation" "warn" "$undocumented_functions undocumented functions"
    fi
}

# Validation 5: Version Consistency
check_version_consistency() {
    echo -e "\n${BLUE}Checking Version Consistency...${NC}"

    # Run version validator if available
    if [ -x "$LEVEL1_DIR/bin/version-validator.sh" ]; then
        local validation_output=$("$LEVEL1_DIR/bin/version-validator.sh" --quiet 2>&1)
        local validation_status=$?

        if [ $validation_status -eq 0 ]; then
            log_validation "Versioning" "Version consistency" "pass"
        else
            local issues=$(echo "$validation_output" | grep -c "Error\|Warning" || echo 0)
            log_validation "Versioning" "Version consistency" "fail" "$issues version issues"
        fi
    else
        log_validation "Versioning" "Version validator" "warn" "Validator not available"
    fi
}

# Validation 6: Performance Metrics
check_performance() {
    echo -e "\n${BLUE}Measuring Performance...${NC}"

    local perf_report="$REPORTS_DIR/performance-$COMMIT_SHORT.txt"
    echo "Performance Report - Commit: $COMMIT_SHORT" > "$perf_report"

    # Test script execution times
    local slow_scripts=0
    for script in "$LEVEL1_DIR/bin"/*.sh; do
        if [ -x "$script" ]; then
            local script_name=$(basename "$script")

            # Time a help/version command (should be fast)
            local exec_time=$(
                TIMEFORMAT='%R'
                { time timeout 2 "$script" --help >/dev/null 2>&1; } 2>&1
            )

            # Convert to milliseconds
            local time_ms=$(echo "$exec_time * 1000" | bc 2>/dev/null || echo "0")

            echo "$script_name: ${time_ms}ms" >> "$perf_report"

            # Check against threshold (500ms)
            if [ "${time_ms%.*}" -gt 500 ]; then
                ((slow_scripts++))
            fi
        fi
    done

    if [ $slow_scripts -eq 0 ]; then
        log_validation "Performance" "Script startup time" "pass"
    else
        log_validation "Performance" "Script startup time" "warn" "$slow_scripts scripts exceed 500ms"
    fi
}

# Validation 7: Complexity Analysis
check_complexity() {
    echo -e "\n${BLUE}Analyzing Code Complexity...${NC}"

    local complex_functions=0

    for script in "$LEVEL1_DIR/bin"/*.sh "$LEVEL1_DIR/quality/hooks"/*.sh; do
        if [ -f "$script" ]; then
            # Count decision points (if, case, while, for, &&, ||)
            local complexity=$(grep -c "^\s*if\|^\s*case\|^\s*while\|^\s*for\|&&\|||\|" "$script" || echo 0)

            if [ $complexity -gt 20 ]; then
                ((complex_functions++))
                echo "  High complexity: $(basename "$script") (complexity: $complexity)"
            fi
        fi
    done

    if [ $complex_functions -eq 0 ]; then
        log_validation "Complexity" "Code complexity" "pass"
    elif [ $complex_functions -le 3 ]; then
        log_validation "Complexity" "Code complexity" "warn" "$complex_functions complex scripts"
    else
        log_validation "Complexity" "Code complexity" "fail" "$complex_functions overly complex scripts"
    fi
}

# Validation 8: Dependency Check
check_dependencies() {
    echo -e "\n${BLUE}Checking Dependencies...${NC}"

    # Check for required tools
    local required_tools=("git" "bash" "grep" "sed" "awk" "find")
    local missing_tools=0

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_validation "Dependencies" "$tool" "fail" "Required tool not found"
            ((missing_tools++))
        fi
    done

    if [ $missing_tools -eq 0 ]; then
        log_validation "Dependencies" "Required tools" "pass"
    fi

    # Check component dependencies
    if [ -x "$LEVEL1_DIR/bin/compatibility-checker.sh" ]; then
        local dep_check=$("$LEVEL1_DIR/bin/compatibility-checker.sh" validate 2>&1)
        if echo "$dep_check" | grep -q "All components are compatible"; then
            log_validation "Dependencies" "Component compatibility" "pass"
        else
            log_validation "Dependencies" "Component compatibility" "warn" "Some compatibility issues"
        fi
    fi
}

# Function: Generate quality report
generate_quality_report() {
    local report_file="$REPORTS_DIR/quality-report-$COMMIT_SHORT.json"
    local dashboard_file="$REPORTS_DIR/quality-dashboard.md"

    # Calculate dimension scores
    local reliability_score=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    local maintainability_score=85  # Placeholder
    local testability_score=75      # Placeholder
    local security_score=90         # Placeholder
    local performance_score=80      # Placeholder

    local overall_score=$(calculate_quality_score $reliability_score $maintainability_score $testability_score $security_score $performance_score)

    # Generate JSON report
    cat > "$report_file" << EOF
{
  "commit": "$COMMIT_HASH",
  "date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "author": "$COMMIT_AUTHOR",
  "message": "$COMMIT_MSG",
  "validation": {
    "total_checks": $TOTAL_CHECKS,
    "passed": $PASSED_CHECKS,
    "failed": $FAILED_CHECKS,
    "warnings": $WARNINGS
  },
  "scores": {
    "overall": $overall_score,
    "reliability": $reliability_score,
    "maintainability": $maintainability_score,
    "testability": $testability_score,
    "security": $security_score,
    "performance": $performance_score
  },
  "status": "$([ $FAILED_CHECKS -eq 0 ] && echo "passed" || echo "failed")"
}
EOF

    # Generate Markdown dashboard
    cat > "$dashboard_file" << EOF
# Quality Dashboard

**Last Updated:** $(date)
**Commit:** $COMMIT_SHORT
**Author:** $COMMIT_AUTHOR

## Overall Quality Score

### ${overall_score}/100

## Validation Summary

- **Total Checks:** $TOTAL_CHECKS
- **Passed:** $PASSED_CHECKS ✓
- **Failed:** $FAILED_CHECKS ✗
- **Warnings:** $WARNINGS ⚠

## Quality Dimensions

| Dimension | Score | Status |
|-----------|-------|--------|
| Reliability | ${reliability_score}% | $([ $reliability_score -ge 80 ] && echo "✓" || echo "⚠") |
| Maintainability | ${maintainability_score}% | $([ $maintainability_score -ge 80 ] && echo "✓" || echo "⚠") |
| Testability | ${testability_score}% | $([ $testability_score -ge 70 ] && echo "✓" || echo "⚠") |
| Security | ${security_score}% | $([ $security_score -ge 90 ] && echo "✓" || echo "⚠") |
| Performance | ${performance_score}% | $([ $performance_score -ge 70 ] && echo "✓" || echo "⚠") |

## Recent Commits

\`\`\`
$(git log --oneline -5)
\`\`\`

## Action Items

$([ $FAILED_CHECKS -gt 0 ] && echo "- Fix $FAILED_CHECKS failing checks")
$([ $WARNINGS -gt 0 ] && echo "- Address $WARNINGS warnings")
$([ $reliability_score -lt 80 ] && echo "- Improve test coverage and reliability")
$([ $security_score -lt 90 ] && echo "- Review security findings")

---
*Generated by post-commit validation*
EOF

    echo -e "\n${CYAN}Reports generated:${NC}"
    echo "  - JSON: $report_file"
    echo "  - Dashboard: $dashboard_file"
}

# Function: Send notifications (if configured)
send_notifications() {
    if [ $FAILED_CHECKS -gt 0 ]; then
        echo -e "\n${YELLOW}⚠ Quality issues detected in commit $COMMIT_SHORT${NC}"

        # Log to file for external monitoring
        echo "$(date): Commit $COMMIT_SHORT failed validation ($FAILED_CHECKS issues)" >> "$QUALITY_DIR/validation.log"

        # Could integrate with notification systems here
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo -e "${BLUE}Post-commit Quality Validation${NC}"
    echo "=========================================="
    echo "Commit: $COMMIT_SHORT"
    echo "Author: $COMMIT_AUTHOR"
    echo "Date: $COMMIT_DATE"
    echo ""

    # Run all validations
    run_test_suite
    check_code_coverage
    security_scan
    check_documentation
    check_version_consistency
    check_performance
    check_complexity
    check_dependencies

    # Generate reports
    generate_quality_report

    # Summary
    local elapsed=$(($(date +%s) - START_TIME))
    echo ""
    echo "=========================================="
    echo -e "${BLUE}Validation Summary${NC}"
    echo "=========================================="
    echo "Total Checks:  $TOTAL_CHECKS"
    echo -e "Passed:        ${GREEN}$PASSED_CHECKS${NC}"
    echo -e "Failed:        ${RED}$FAILED_CHECKS${NC}"
    echo -e "Warnings:      ${YELLOW}$WARNINGS${NC}"
    echo "Time:          ${elapsed}s"
    echo ""

    # Overall status
    if [ $FAILED_CHECKS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✓ All post-commit validations passed!${NC}"
        exit 0
    elif [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${YELLOW}⚠ Validation completed with warnings${NC}"
        send_notifications
        exit 0
    else
        echo -e "${RED}✗ Post-commit validation failed!${NC}"
        echo ""
        echo "Review the detailed reports in: $REPORTS_DIR"
        send_notifications
        exit 1
    fi
}

# Run if executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
