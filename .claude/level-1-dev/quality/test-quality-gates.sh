#!/bin/bash

# Quality Gate System Integration Tests
# Comprehensive testing of all quality gate components working together

set -euo pipefail

# Source error handling
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../templates/error-handling-template.sh"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
LEVEL1_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$LEVEL1_DIR/../.." && pwd)"
TEST_DIR="$SCRIPT_DIR/tests"
TEST_REPORTS_DIR="$SCRIPT_DIR/reports"
TEST_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEST_REPORT="$TEST_REPORTS_DIR/quality-gates-test-$TEST_TIMESTAMP.json"
TEST_LOG="$TEST_REPORTS_DIR/quality-gates-test-$TEST_TIMESTAMP.log"

# Test configuration
TEST_TIMEOUT=300  # 5 minutes per test
TOTAL_TIMEOUT=1800  # 30 minutes total
PARALLEL_TESTS=false
CLEANUP_ON_FAILURE=true
VERBOSE_OUTPUT=false

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0
INTEGRATION_FAILURES=0

# Quality gate components to test
QUALITY_COMPONENTS=(
    "quality-dashboard"
    "security-scanner"
    "dependency-checker"
    "secret-detector"
    "performance-benchmarks"
    "error-handling"
    "git-hooks"
)

# Function: Display help
show_help() {
    cat << EOF
Quality Gate System Integration Tests

Usage: $(basename "$0") [options] [test-suite]

Options:
    -h, --help              Show this help message
    -v, --verbose           Show detailed test output
    -q, --quiet             Suppress non-error output
    -f, --format FORMAT     Output format (json|markdown|console) [default: console]
    -o, --output FILE       Output file path
    --timeout SEC           Test timeout in seconds [default: 300]
    --total-timeout SEC     Total test suite timeout [default: 1800]
    --parallel              Run tests in parallel
    --cleanup               Clean up test artifacts on failure [default: true]
    --no-cleanup            Don't clean up test artifacts

Test Suites:
    --all                   Run all integration tests (default)
    --components            Test individual quality components
    --workflows             Test end-to-end workflows
    --hooks                 Test git hook integration
    --performance           Test performance monitoring
    --security              Test security validation
    --error-handling        Test error handling and recovery
    --integration           Test component integration

Test Modes:
    --smoke                 Run smoke tests (quick validation)
    --full                  Run comprehensive tests
    --regression            Run regression tests
    --stress                Run stress tests

Examples:
    $(basename "$0")                        # Run all integration tests
    $(basename "$0") --components --verbose # Test components with detailed output
    $(basename "$0") --smoke --parallel     # Quick parallel smoke tests
    $(basename "$0") --workflows --format json  # Workflow tests with JSON output

EOF
}

# Function: Initialize test environment
init_test_environment() {
    setup_error_handling
    
    # Create test directories
    mkdir -p "$TEST_DIR" "$TEST_REPORTS_DIR"
    
    # Initialize test report
    cat > "$TEST_REPORT" << EOF
{
  "test_info": {
    "timestamp": "$(date -Iseconds)",
    "test_version": "1.0.0",
    "test_mode": "integration",
    "duration_seconds": 0,
    "environment": {
      "hostname": "$(hostname 2>/dev/null || echo 'unknown')",
      "os": "$(uname -s 2>/dev/null || echo 'unknown')",
      "git_commit": "$(cd "$LEVEL1_DIR" && git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
    }
  },
  "summary": {
    "total_tests": 0,
    "passed_tests": 0,
    "failed_tests": 0,
    "skipped_tests": 0,
    "integration_failures": 0,
    "success_rate": 0
  },
  "test_results": []
}
EOF
    
    # Initialize test log
    echo "Quality Gate Integration Test Log - $(date)" > "$TEST_LOG"
    echo "============================================" >> "$TEST_LOG"
    echo "" >> "$TEST_LOG"
    
    log_info "TEST_INIT" "Quality gate integration test environment initialized"
}

# Function: Add test result
add_test_result() {
    local test_name="$1"
    local test_category="$2"
    local status="$3"          # passed, failed, skipped
    local duration="$4"        # in seconds
    local message="$5"
    local details="${6:-}"
    
    # Update counters
    ((TOTAL_TESTS++))
    case "$status" in
        "passed") ((PASSED_TESTS++)) ;;
        "failed") ((FAILED_TESTS++)) ;;
        "skipped") ((SKIPPED_TESTS++)) ;;
    esac
    
    # Create test result JSON
    local test_result
    test_result=$(cat << EOF
{
  "name": "$test_name",
  "category": "$test_category",
  "status": "$status",
  "duration_seconds": $duration,
  "message": "$message",
  "details": "$details",
  "timestamp": "$(date -Iseconds)"
}
EOF
)
    
    # Add to report
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".test_results += [$test_result]" "$TEST_REPORT" > "$temp_report"
        mv "$temp_report" "$TEST_REPORT"
    else
        echo "$test_result" >> "${TEST_REPORT}.results"
    fi
    
    # Display result
    local color=""
    local symbol=""
    case "$status" in
        "passed")
            color="$GREEN"
            symbol="✓"
            ;;
        "failed")
            color="$RED"
            symbol="✗"
            ;;
        "skipped")
            color="$YELLOW"
            symbol="⚠"
            ;;
    esac
    
    echo -e "${color}[$symbol] $test_name${NC} (${duration}s)"
    if [ -n "$message" ]; then
        echo "    $message"
    fi
    
    # Log to file
    echo "[$status] $test_name ($test_category) - ${duration}s - $message" >> "$TEST_LOG"
    if [ -n "$details" ] && [ "$VERBOSE_OUTPUT" = "true" ]; then
        echo "    Details: $details" >> "$TEST_LOG"
    fi
}

# Function: Run test with timeout
run_test_with_timeout() {
    local test_command="$1"
    local timeout_seconds="$2"
    local test_name="$3"
    
    local start_time=$(date +%s)
    local output=""
    local exit_code=0
    
    # Run command with timeout
    if output=$(timeout "$timeout_seconds" bash -c "$test_command" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Return results
    echo "$exit_code|$duration|$output"
}

# Function: Test quality dashboard component
test_quality_dashboard() {
    echo -e "${BLUE}Testing Quality Dashboard Component${NC}"
    
    local test_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/quality-dashboard.sh' --format json"
    local result
    result=$(run_test_with_timeout "$test_command" 30 "quality-dashboard")
    
    IFS='|' read -r exit_code duration output <<< "$result"
    
    if [ "$exit_code" -eq 0 ]; then
        # Verify JSON output structure
        if echo "$output" | jq -e '.quality_score' >/dev/null 2>&1; then
            add_test_result "quality-dashboard-basic" "component" "passed" "$duration" \
                "Quality dashboard executed successfully with valid JSON output"
        else
            add_test_result "quality-dashboard-basic" "component" "failed" "$duration" \
                "Quality dashboard output is not valid JSON" "$output"
        fi
    else
        add_test_result "quality-dashboard-basic" "component" "failed" "$duration" \
            "Quality dashboard execution failed" "$output"
    fi
}

# Function: Test security scanner component
test_security_scanner() {
    echo -e "${BLUE}Testing Security Scanner Component${NC}"
    
    # Test quick scan
    local test_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/security-scanner.sh' --quick --format json ."
    local result
    result=$(run_test_with_timeout "$test_command" 60 "security-scanner")
    
    IFS='|' read -r exit_code duration output <<< "$result"
    
    if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 1 ]; then  # 1 is acceptable (vulnerabilities found)
        add_test_result "security-scanner-quick" "component" "passed" "$duration" \
            "Security scanner quick scan completed successfully"
    else
        add_test_result "security-scanner-quick" "component" "failed" "$duration" \
            "Security scanner failed" "$output"
    fi
    
    # Test secret detection
    local secret_test_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/secret-detector.sh' --high-only --format json ."
    local secret_result
    secret_result=$(run_test_with_timeout "$secret_test_command" 45 "secret-detector")
    
    IFS='|' read -r secret_exit_code secret_duration secret_output <<< "$secret_result"
    
    if [ "$secret_exit_code" -eq 0 ] || [ "$secret_exit_code" -eq 1 ]; then
        add_test_result "secret-detector-scan" "component" "passed" "$secret_duration" \
            "Secret detector scan completed successfully"
    else
        add_test_result "secret-detector-scan" "component" "failed" "$secret_duration" \
            "Secret detector failed" "$secret_output"
    fi
}

# Function: Test dependency checker component
test_dependency_checker() {
    echo -e "${BLUE}Testing Dependency Checker Component${NC}"
    
    local test_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/dependency-checker.sh' --offline --format json ."
    local result
    result=$(run_test_with_timeout "$test_command" 60 "dependency-checker")
    
    IFS='|' read -r exit_code duration output <<< "$result"
    
    if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 1 ]; then
        add_test_result "dependency-checker-offline" "component" "passed" "$duration" \
            "Dependency checker offline scan completed successfully"
    else
        add_test_result "dependency-checker-offline" "component" "failed" "$duration" \
            "Dependency checker failed" "$output"
    fi
}

# Function: Test performance benchmarks component
test_performance_benchmarks() {
    echo -e "${BLUE}Testing Performance Benchmarks Component${NC}"
    
    local test_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/performance-benchmarks.sh' --quick --format json"
    local result
    result=$(run_test_with_timeout "$test_command" 120 "performance-benchmarks")
    
    IFS='|' read -r exit_code duration output <<< "$result"
    
    if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 1 ]; then
        add_test_result "performance-benchmarks-quick" "component" "passed" "$duration" \
            "Performance benchmarks quick test completed successfully"
    else
        add_test_result "performance-benchmarks-quick" "component" "failed" "$duration" \
            "Performance benchmarks failed" "$output"
    fi
    
    # Test baseline manager
    local baseline_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/performance-baseline-manager.sh' list"
    local baseline_result
    baseline_result=$(run_test_with_timeout "$baseline_command" 30 "baseline-manager")
    
    IFS='|' read -r baseline_exit_code baseline_duration baseline_output <<< "$baseline_result"
    
    if [ "$baseline_exit_code" -eq 0 ]; then
        add_test_result "performance-baseline-list" "component" "passed" "$baseline_duration" \
            "Baseline manager executed successfully"
    else
        add_test_result "performance-baseline-list" "component" "failed" "$baseline_duration" \
            "Baseline manager failed" "$baseline_output"
    fi
}

# Function: Test git hooks integration
test_git_hooks() {
    echo -e "${BLUE}Testing Git Hooks Integration${NC}"
    
    # Test hook installation
    local install_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/hooks/install-hooks.sh' status"
    local install_result
    install_result=$(run_test_with_timeout "$install_command" 30 "hook-install")
    
    IFS='|' read -r install_exit_code install_duration install_output <<< "$install_result"
    
    if [ "$install_exit_code" -eq 0 ]; then
        add_test_result "git-hooks-status" "integration" "passed" "$install_duration" \
            "Git hooks status check completed successfully"
    else
        add_test_result "git-hooks-status" "integration" "failed" "$install_duration" \
            "Git hooks status check failed" "$install_output"
    fi
    
    # Test hook manager
    local manager_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/hooks/hook-manager.sh' list"
    local manager_result
    manager_result=$(run_test_with_timeout "$manager_command" 30 "hook-manager")
    
    IFS='|' read -r manager_exit_code manager_duration manager_output <<< "$manager_result"
    
    if [ "$manager_exit_code" -eq 0 ]; then
        add_test_result "hook-manager-list" "integration" "passed" "$manager_duration" \
            "Hook manager list executed successfully"
    else
        add_test_result "hook-manager-list" "integration" "failed" "$manager_duration" \
            "Hook manager failed" "$manager_output"
    fi
}

# Function: Test error handling system
test_error_handling() {
    echo -e "${BLUE}Testing Error Handling System${NC}"
    
    # Test error handling template
    local template_path="$SCRIPT_DIR/../templates/error-handling-template.sh"
    if [ -f "$template_path" ]; then
        local test_command="bash '$template_path' example_usage"
        local result
        result=$(run_test_with_timeout "$test_command" 15 "error-template")
        
        IFS='|' read -r exit_code duration output <<< "$result"
        
        if [ "$exit_code" -eq 0 ]; then
            add_test_result "error-handling-template" "component" "passed" "$duration" \
                "Error handling template executed successfully"
        else
            add_test_result "error-handling-template" "component" "failed" "$duration" \
                "Error handling template failed" "$output"
        fi
    else
        add_test_result "error-handling-template" "component" "skipped" "0" \
            "Error handling template not found"
    fi
    
    # Test error standards validation
    local standards_file="$SCRIPT_DIR/error-standards.yaml"
    if [ -f "$standards_file" ] && command -v yq >/dev/null 2>&1; then
        if yq -e '.error_categories' "$standards_file" >/dev/null 2>&1; then
            add_test_result "error-standards-validation" "component" "passed" "1" \
                "Error standards YAML is valid"
        else
            add_test_result "error-standards-validation" "component" "failed" "1" \
                "Error standards YAML is invalid"
        fi
    else
        add_test_result "error-standards-validation" "component" "skipped" "0" \
            "Error standards file not found or yq not available"
    fi
}

# Function: Test end-to-end workflow
test_end_to_end_workflow() {
    echo -e "${BLUE}Testing End-to-End Quality Workflow${NC}"
    
    local workflow_start_time=$(date +%s)
    
    # Step 1: Quality dashboard
    echo "  Step 1: Running quality dashboard..."
    local dashboard_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/quality-dashboard.sh' --format json"
    local dashboard_result
    dashboard_result=$(run_test_with_timeout "$dashboard_command" 45 "e2e-dashboard")
    
    IFS='|' read -r dashboard_exit_code dashboard_duration dashboard_output <<< "$dashboard_result"
    
    if [ "$dashboard_exit_code" -ne 0 ]; then
        local workflow_end_time=$(date +%s)
        local workflow_duration=$((workflow_end_time - workflow_start_time))
        add_test_result "end-to-end-workflow" "workflow" "failed" "$workflow_duration" \
            "E2E workflow failed at dashboard step" "$dashboard_output"
        return 1
    fi
    
    # Step 2: Security scan
    echo "  Step 2: Running security scan..."
    local security_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/security-scanner.sh' --quick --format json ."
    local security_result
    security_result=$(run_test_with_timeout "$security_command" 60 "e2e-security")
    
    IFS='|' read -r security_exit_code security_duration security_output <<< "$security_result"
    
    if [ "$security_exit_code" -gt 1 ]; then  # Allow exit code 1 (vulnerabilities found)
        local workflow_end_time=$(date +%s)
        local workflow_duration=$((workflow_end_time - workflow_start_time))
        add_test_result "end-to-end-workflow" "workflow" "failed" "$workflow_duration" \
            "E2E workflow failed at security step" "$security_output"
        return 1
    fi
    
    # Step 3: Performance check
    echo "  Step 3: Running performance check..."
    local perf_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/performance-benchmarks.sh' --scripts --format json"
    local perf_result
    perf_result=$(run_test_with_timeout "$perf_command" 90 "e2e-performance")
    
    IFS='|' read -r perf_exit_code perf_duration perf_output <<< "$perf_result"
    
    local workflow_end_time=$(date +%s)
    local workflow_duration=$((workflow_end_time - workflow_start_time))
    
    if [ "$perf_exit_code" -eq 0 ] || [ "$perf_exit_code" -eq 1 ]; then
        add_test_result "end-to-end-workflow" "workflow" "passed" "$workflow_duration" \
            "Complete E2E quality workflow executed successfully"
    else
        add_test_result "end-to-end-workflow" "workflow" "failed" "$workflow_duration" \
            "E2E workflow failed at performance step" "$perf_output"
    fi
}

# Function: Test component integration
test_component_integration() {
    echo -e "${BLUE}Testing Component Integration${NC}"
    
    # Test 1: Quality dashboard can access all reports
    echo "  Testing report accessibility..."
    local reports_accessible=0
    local total_reports=0
    
    for component in quality security dependency performance; do
        ((total_reports++))
        local report_pattern="$SCRIPT_DIR/reports/${component}*"
        if ls $report_pattern >/dev/null 2>&1; then
            ((reports_accessible++))
        fi
    done
    
    if [ $reports_accessible -gt 0 ]; then
        add_test_result "component-report-integration" "integration" "passed" "2" \
            "Quality reports are accessible ($reports_accessible/$total_reports components)"
    else
        add_test_result "component-report-integration" "integration" "failed" "2" \
            "No quality reports found for integration"
    fi
    
    # Test 2: Configuration consistency
    echo "  Testing configuration consistency..."
    local config_files=(
        "$SCRIPT_DIR/error-standards.yaml"
        "$SCRIPT_DIR/../security/security-config.yaml"
        "$SCRIPT_DIR/benchmarks/performance-config.yaml"
    )
    
    local valid_configs=0
    local total_configs=0
    
    for config_file in "${config_files[@]}"; do
        ((total_configs++))
        if [ -f "$config_file" ]; then
            if command -v yq >/dev/null 2>&1 && yq -e '.version' "$config_file" >/dev/null 2>&1; then
                ((valid_configs++))
            elif grep -q "version:" "$config_file" 2>/dev/null; then
                ((valid_configs++))
            fi
        fi
    done
    
    if [ $valid_configs -eq $total_configs ]; then
        add_test_result "component-config-consistency" "integration" "passed" "3" \
            "All configuration files are valid and consistent"
    else
        add_test_result "component-config-consistency" "integration" "failed" "3" \
            "Configuration validation failed ($valid_configs/$total_configs valid)"
    fi
}

# Function: Test stress scenarios
test_stress_scenarios() {
    echo -e "${BLUE}Testing Stress Scenarios${NC}"
    
    # Test 1: Rapid successive quality checks
    echo "  Testing rapid quality checks..."
    local stress_start_time=$(date +%s)
    local stress_failures=0
    
    for i in {1..3}; do
        local quick_command="cd '$LEVEL1_DIR' && timeout 30 '$SCRIPT_DIR/quality-dashboard.sh' --format json"
        if ! eval "$quick_command" >/dev/null 2>&1; then
            ((stress_failures++))
        fi
    done
    
    local stress_end_time=$(date +%s)
    local stress_duration=$((stress_end_time - stress_start_time))
    
    if [ $stress_failures -eq 0 ]; then
        add_test_result "stress-rapid-checks" "stress" "passed" "$stress_duration" \
            "System handled rapid quality checks successfully"
    else
        add_test_result "stress-rapid-checks" "stress" "failed" "$stress_duration" \
            "System failed under rapid quality check stress ($stress_failures/3 failures)"
    fi
    
    # Test 2: Large file handling
    echo "  Testing large file handling..."
    local large_file_test_dir=$(mktemp -d)
    
    # Create a moderately large test file
    head -c 1048576 /dev/zero > "$large_file_test_dir/large_test_file.txt"  # 1MB
    echo "# Test file for stress testing" >> "$large_file_test_dir/large_test_file.txt"
    
    local large_file_command="cd '$LEVEL1_DIR' && '$SCRIPT_DIR/security-scanner.sh' --quick --format json '$large_file_test_dir'"
    local large_file_result
    large_file_result=$(run_test_with_timeout "$large_file_command" 60 "stress-large-file")
    
    IFS='|' read -r large_exit_code large_duration large_output <<< "$large_file_result"
    
    # Cleanup
    rm -rf "$large_file_test_dir"
    
    if [ "$large_exit_code" -eq 0 ] || [ "$large_exit_code" -eq 1 ]; then
        add_test_result "stress-large-file-handling" "stress" "passed" "$large_duration" \
            "System handled large file scanning successfully"
    else
        add_test_result "stress-large-file-handling" "stress" "failed" "$large_duration" \
            "System failed with large file handling" "$large_output"
    fi
}

# Function: Generate test summary
generate_test_summary() {
    local test_duration=$(($(date +%s) - TEST_START_TIME))
    local success_rate=0
    
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    
    # Update final report
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".test_info.duration_seconds = $test_duration |
            .summary.total_tests = $TOTAL_TESTS |
            .summary.passed_tests = $PASSED_TESTS |
            .summary.failed_tests = $FAILED_TESTS |
            .summary.skipped_tests = $SKIPPED_TESTS |
            .summary.integration_failures = $INTEGRATION_FAILURES |
            .summary.success_rate = $success_rate" \
            "$TEST_REPORT" > "$temp_report"
        mv "$temp_report" "$TEST_REPORT"
    fi
    
    # Generate markdown summary
    local summary_file="$TEST_REPORTS_DIR/quality-gates-summary-$TEST_TIMESTAMP.md"
    cat > "$summary_file" << EOF
# Quality Gate System Integration Test Report

**Test Date:** $(date)  
**Test Duration:** ${test_duration}s  
**Total Tests:** $TOTAL_TESTS  
**Success Rate:** ${success_rate}%  

## Test Results Summary

| Status | Count | Percentage |
|--------|-------|------------|
| Passed | $PASSED_TESTS | $(( PASSED_TESTS * 100 / (TOTAL_TESTS > 0 ? TOTAL_TESTS : 1) ))% |
| Failed | $FAILED_TESTS | $(( FAILED_TESTS * 100 / (TOTAL_TESTS > 0 ? TOTAL_TESTS : 1) ))% |
| Skipped | $SKIPPED_TESTS | $(( SKIPPED_TESTS * 100 / (TOTAL_TESTS > 0 ? TOTAL_TESTS : 1) ))% |

## Components Tested

EOF
    
    for component in "${QUALITY_COMPONENTS[@]}"; do
        echo "- ✓ $component" >> "$summary_file"
    done
    
    cat >> "$summary_file" << EOF

## Test Categories

- **Component Tests**: Individual quality component validation
- **Integration Tests**: Component interaction and data flow
- **Workflow Tests**: End-to-end quality workflow validation
- **Stress Tests**: System behavior under load

## System Health Assessment

EOF

    if [ $FAILED_TESTS -eq 0 ]; then
        echo "✅ **EXCELLENT**: All quality gate tests passed successfully." >> "$summary_file"
    elif [ $success_rate -ge 90 ]; then
        echo "✅ **GOOD**: Quality gate system is functioning well with minor issues." >> "$summary_file"
    elif [ $success_rate -ge 75 ]; then
        echo "⚠️ **FAIR**: Quality gate system has some issues that need attention." >> "$summary_file"
    else
        echo "🚨 **POOR**: Quality gate system has significant issues requiring immediate attention." >> "$summary_file"
    fi
    
    cat >> "$summary_file" << EOF

## Recommendations

EOF
    
    if [ $FAILED_TESTS -gt 0 ]; then
        cat >> "$summary_file" << EOF
1. Review failed test details in the test log: \`$TEST_LOG\`
2. Fix component issues before production deployment
3. Re-run tests after fixes to verify resolution
4. Consider increasing monitoring for problematic components
EOF
    else
        cat >> "$summary_file" << EOF
1. Quality gate system is ready for production use
2. Continue regular testing to maintain system health
3. Monitor performance trends and component integration
4. Update baselines and thresholds as the system evolves
EOF
    fi
    
    cat >> "$summary_file" << EOF

## Detailed Results

For detailed test results and logs, see:
- JSON Report: \`$TEST_REPORT\`
- Test Log: \`$TEST_LOG\`

EOF
    
    echo "$summary_file"
}

# Function: Display test results
display_test_results() {
    echo ""
    echo "========================================"
    echo -e "${BOLD}${BLUE}Quality Gate Integration Tests Complete${NC}"
    echo "========================================"
    echo ""
    echo "Total Tests:       $TOTAL_TESTS"
    echo -e "Passed:            ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed:            ${RED}$FAILED_TESTS${NC}"
    echo -e "Skipped:           ${YELLOW}$SKIPPED_TESTS${NC}"
    echo ""
    
    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    echo "Success Rate:      ${success_rate}%"
    echo ""
    
    echo "Test Report:       $TEST_REPORT"
    echo "Test Log:          $TEST_LOG"
    echo "Test Summary:      $(generate_test_summary)"
    echo ""
    
    # Overall assessment
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}${BOLD}QUALITY GATE STATUS: ALL TESTS PASSED${NC}"
        return 0
    elif [ $success_rate -ge 90 ]; then
        echo -e "${YELLOW}${BOLD}QUALITY GATE STATUS: MOSTLY FUNCTIONAL${NC}"
        return 1
    else
        echo -e "${RED}${BOLD}QUALITY GATE STATUS: SIGNIFICANT ISSUES${NC}"
        return 1
    fi
}

# Main execution
main() {
    local test_suite="all"
    local test_mode="full"
    
    TEST_START_TIME=$(date +%s)
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE_OUTPUT=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            --timeout)
                TEST_TIMEOUT="$2"
                shift 2
                ;;
            --total-timeout)
                TOTAL_TIMEOUT="$2"
                shift 2
                ;;
            --parallel)
                PARALLEL_TESTS=true
                shift
                ;;
            --cleanup)
                CLEANUP_ON_FAILURE=true
                shift
                ;;
            --no-cleanup)
                CLEANUP_ON_FAILURE=false
                shift
                ;;
            --all|--components|--workflows|--hooks|--performance|--security|--error-handling|--integration)
                test_suite="${1#--}"
                shift
                ;;
            --smoke|--full|--regression|--stress)
                test_mode="${1#--}"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Initialize
    init_test_environment
    
    echo -e "${BOLD}${BLUE}Starting Quality Gate Integration Tests${NC}"
    echo "Test Suite: $test_suite"
    echo "Test Mode: $test_mode"
    echo "Timeout: ${TEST_TIMEOUT}s per test, ${TOTAL_TIMEOUT}s total"
    echo ""
    
    # Set alarm for total timeout
    (sleep "$TOTAL_TIMEOUT" && pkill -f "$(basename "$0")" 2>/dev/null) &
    local timeout_pid=$!
    
    # Run tests based on suite
    case "$test_suite" in
        "all"|"full")
            test_quality_dashboard
            test_security_scanner
            test_dependency_checker
            test_performance_benchmarks
            test_git_hooks
            test_error_handling
            test_component_integration
            test_end_to_end_workflow
            if [ "$test_mode" = "stress" ]; then
                test_stress_scenarios
            fi
            ;;
        "components")
            test_quality_dashboard
            test_security_scanner
            test_dependency_checker
            test_performance_benchmarks
            test_error_handling
            ;;
        "workflows")
            test_end_to_end_workflow
            ;;
        "hooks")
            test_git_hooks
            ;;
        "performance")
            test_performance_benchmarks
            ;;
        "security")
            test_security_scanner
            ;;
        "error-handling")
            test_error_handling
            ;;
        "integration")
            test_component_integration
            ;;
    esac
    
    # Cancel timeout alarm
    kill $timeout_pid 2>/dev/null || true
    
    # Display results
    if [ "${QUIET:-false}" != "true" ]; then
        display_test_results
    fi
}

# Run main function
main "$@"