#!/bin/bash

# Level-1-Dev Test Runner
# Main orchestrator for all tests in the level-1-dev framework
# Uses only Claude Code native capabilities

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/../../../.." && pwd)"
LEVEL1_DIR="$PROJECT_ROOT/.claude/level-1-dev"
REPORT_FILE="$TEST_DIR/reports/test-report-$(date +%Y%m%d-%H%M%S).md"

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "FAIL")
            echo -e "${RED}✗${NC} $message"
            ;;
        "SKIP")
            echo -e "${YELLOW}○${NC} $message"
            ;;
        "INFO")
            echo -e "${YELLOW}ℹ${NC} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Function to run a test file
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .sh)

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    print_status "INFO" "Running test: $test_name"

    if [ ! -f "$test_file" ]; then
        print_status "SKIP" "Test file not found: $test_file"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        return 1
    fi

    if [ ! -x "$test_file" ]; then
        chmod +x "$test_file"
    fi

    # Run the test and capture output
    if output=$("$test_file" 2>&1); then
        print_status "PASS" "$test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "### ✓ $test_name" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
        echo "$output" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        return 0
    else
        print_status "FAIL" "$test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "### ✗ $test_name" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
        echo "$output" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        return 1
    fi
}

# Main test execution
main() {
    echo "=========================================="
    echo "Level-1-Dev Test Framework"
    echo "=========================================="
    echo ""

    # Create report file
    mkdir -p "$TEST_DIR/reports"
    echo "# Test Report - $(date)" > "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "## Test Environment" >> "$REPORT_FILE"
    echo "- **Date**: $(date)" >> "$REPORT_FILE"
    echo "- **User**: $(whoami)" >> "$REPORT_FILE"
    echo "- **Directory**: $LEVEL1_DIR" >> "$REPORT_FILE"
    echo "- **Shell**: $SHELL" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Source test utilities if available
    if [ -f "$TEST_DIR/test-utils.sh" ]; then
        source "$TEST_DIR/test-utils.sh"
        print_status "INFO" "Loaded test utilities"
    fi

    echo "## Unit Tests" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Run unit tests
    print_status "INFO" "Running unit tests..."
    for test_file in "$TEST_DIR"/unit/*.sh; do
        if [ -f "$test_file" ]; then
            run_test "$test_file" || true  # Continue on failure
        fi
    done

    echo "## Integration Tests" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Run integration tests
    print_status "INFO" "Running integration tests..."
    for test_file in "$TEST_DIR"/integration/*.sh; do
        if [ -f "$test_file" ]; then
            run_test "$test_file" || true  # Continue on failure
        fi
    done

    # Summary
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="

    echo "## Summary" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    print_status "INFO" "Total tests: $TOTAL_TESTS"
    print_status "PASS" "Passed: $PASSED_TESTS"

    echo "- **Total Tests**: $TOTAL_TESTS" >> "$REPORT_FILE"
    echo "- **Passed**: $PASSED_TESTS" >> "$REPORT_FILE"

    if [ $FAILED_TESTS -gt 0 ]; then
        print_status "FAIL" "Failed: $FAILED_TESTS"
        echo "- **Failed**: $FAILED_TESTS" >> "$REPORT_FILE"
    fi

    if [ $SKIPPED_TESTS -gt 0 ]; then
        print_status "SKIP" "Skipped: $SKIPPED_TESTS"
        echo "- **Skipped**: $SKIPPED_TESTS" >> "$REPORT_FILE"
    fi

    # Success rate
    if [ $TOTAL_TESTS -gt 0 ]; then
        SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo "- **Success Rate**: ${SUCCESS_RATE}%" >> "$REPORT_FILE"
        print_status "INFO" "Success rate: ${SUCCESS_RATE}%"
    fi

    echo "" >> "$REPORT_FILE"
    echo "---" >> "$REPORT_FILE"
    echo "*Report generated at: $(date)*" >> "$REPORT_FILE"

    echo ""
    print_status "INFO" "Report saved to: $REPORT_FILE"

    # Exit with appropriate code
    if [ $FAILED_TESTS -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"
