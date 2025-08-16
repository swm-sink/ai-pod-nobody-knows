#!/bin/bash

# Simple Integration Test for Version Management System
# Tests core functionality of all components

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVEL1_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN_DIR="$LEVEL1_DIR/bin"
TEST_COMPONENT="test-component-$$"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Test function
run_test() {
    local test_name=$1
    local command=$2

    ((TESTS_RUN++))
    echo -e "${BLUE}Testing: $test_name${NC}"

    if eval "$command" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Passed${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}✗ Failed${NC}"
        return 1
    fi
}

# Cleanup
cleanup() {
    rm -f "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml" 2>/dev/null || true
    rm -f "$LEVEL1_DIR/agents/${TEST_COMPONENT}.md" 2>/dev/null || true
}
trap cleanup EXIT

echo "======================================"
echo "Version Management System Test"
echo "======================================"
echo ""

# Test 1: Version Manager exists and runs
run_test "Version Manager Script" "[ -x '$BIN_DIR/version-manager.sh' ]"

# Test 2: Changelog Generator exists and runs
run_test "Changelog Generator Script" "[ -x '$BIN_DIR/changelog-generator.sh' ]"

# Test 3: Compatibility Checker exists and runs
run_test "Compatibility Checker Script" "[ -x '$BIN_DIR/compatibility-checker.sh' ]"

# Test 4: Migration Runner exists and runs
run_test "Migration Runner Script" "[ -x '$BIN_DIR/migration-runner.sh' ]"

# Test 5: Version Validator exists and runs
run_test "Version Validator Script" "[ -x '$BIN_DIR/version-validator.sh' ]"

# Test 6: Rollback Manager exists and runs
run_test "Rollback Manager Script" "[ -x '$BIN_DIR/rollback-manager.sh' ]"

# Test 7: Version schema exists
run_test "Version Schema File" "[ -f '$LEVEL1_DIR/versions/schema.yaml' ]"

# Test 8: Compatibility matrix exists
run_test "Compatibility Matrix File" "[ -f '$LEVEL1_DIR/versions/compatibility-matrix.yaml' ]"

# Test 9: Migration template exists
run_test "Migration Template" "[ -f '$LEVEL1_DIR/versions/migrations/migration-template.sh' ]"

# Test 10: Version manifests directory exists
run_test "Manifests Directory" "[ -d '$LEVEL1_DIR/versions/manifests' ]"

# Test 11: Can list components
run_test "List Components" "'$BIN_DIR/version-manager.sh' list"

# Test 12: Can show compatibility matrix
run_test "Show Compatibility Matrix" "'$BIN_DIR/compatibility-checker.sh' matrix"

# Test 13: Can show migration status
run_test "Show Migration Status" "'$BIN_DIR/migration-runner.sh' status"

# Test 14: Can show system status
run_test "Show System Status" "'$BIN_DIR/rollback-manager.sh' status"

# Test 15: Create and init test component
echo -e "\n${BLUE}Integration Test: Component Lifecycle${NC}"

# Create test agent
cat > "$LEVEL1_DIR/agents/${TEST_COMPONENT}.md" << EOF
---
name: ${TEST_COMPONENT}
version: 0.1.0
description: Test agent
tools: Read
model: haiku
color: blue
---
Test agent content
EOF

# Initialize version tracking
if run_test "Initialize Component" "'$BIN_DIR/version-manager.sh' init '$TEST_COMPONENT' agent"; then
    # Test version operations
    run_test "Bump Version" "'$BIN_DIR/version-manager.sh' bump '$TEST_COMPONENT' patch"
    run_test "Show History" "'$BIN_DIR/version-manager.sh' history '$TEST_COMPONENT'"
    run_test "Generate Changelog" "'$BIN_DIR/changelog-generator.sh' generate '$TEST_COMPONENT'"
    run_test "Check Compatibility" "'$BIN_DIR/compatibility-checker.sh' check '$TEST_COMPONENT'"
fi

# Summary
echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "Tests Run: $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    echo "The version management system is working correctly."
    exit 0
else
    echo -e "\n${YELLOW}⚠ Some tests failed${NC}"
    echo "Review the failed tests above for details."
    exit 1
fi
