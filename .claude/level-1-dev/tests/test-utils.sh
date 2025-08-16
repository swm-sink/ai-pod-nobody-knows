#!/bin/bash

# Test Utilities Library for Level-1-Dev
# Common functions for test assertions and validation
# Uses only Claude Code native capabilities

# Colors for output (if not already defined)
if [ -z "$RED" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
fi

# Test context
TEST_CONTEXT=""
ASSERTION_COUNT=0
ASSERTION_FAILURES=0

# Set test context
set_test_context() {
    TEST_CONTEXT="$1"
    echo "Testing: $TEST_CONTEXT"
}

# Assert file exists
assert_file_exists() {
    local file_path="$1"
    local description="${2:-File should exist}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ -f "$file_path" ]; then
        echo -e "  ${GREEN}✓${NC} $description: $file_path"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description: $file_path (NOT FOUND)"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir_path="$1"
    local description="${2:-Directory should exist}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ -d "$dir_path" ]; then
        echo -e "  ${GREEN}✓${NC} $description: $dir_path"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description: $dir_path (NOT FOUND)"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Assert file contains pattern
assert_contains() {
    local file_path="$1"
    local pattern="$2"
    local description="${3:-File should contain pattern}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ ! -f "$file_path" ]; then
        echo -e "  ${RED}✗${NC} $description: File not found: $file_path"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi

    if grep -q "$pattern" "$file_path" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $description: '$pattern'"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description: '$pattern' NOT FOUND in $file_path"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Assert file does not contain pattern
assert_not_contains() {
    local file_path="$1"
    local pattern="$2"
    local description="${3:-File should not contain pattern}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ ! -f "$file_path" ]; then
        echo -e "  ${GREEN}✓${NC} $description: File not found (expected)"
        return 0
    fi

    if grep -q "$pattern" "$file_path" 2>/dev/null; then
        echo -e "  ${RED}✗${NC} $description: '$pattern' FOUND (should not exist)"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    else
        echo -e "  ${GREEN}✓${NC} $description: '$pattern' not found"
        return 0
    fi
}

# Assert command succeeds
assert_command_succeeds() {
    local command="$1"
    local description="${2:-Command should succeed}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if eval "$command" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $description: $command"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description: $command (FAILED)"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Assert command fails
assert_command_fails() {
    local command="$1"
    local description="${2:-Command should fail}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if eval "$command" >/dev/null 2>&1; then
        echo -e "  ${RED}✗${NC} $description: $command (SUCCEEDED, expected failure)"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    else
        echo -e "  ${GREEN}✓${NC} $description: $command (failed as expected)"
        return 0
    fi
}

# Assert YAML is valid
assert_yaml_valid() {
    local file_path="$1"
    local description="${2:-YAML should be valid}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ ! -f "$file_path" ]; then
        echo -e "  ${RED}✗${NC} $description: File not found: $file_path"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi

    # Basic YAML validation using grep patterns
    # Check for basic YAML structure
    local has_yaml_structure=false

    if grep -E "^[a-zA-Z_][a-zA-Z0-9_]*:" "$file_path" >/dev/null 2>&1; then
        has_yaml_structure=true
    fi

    # Check for invalid YAML patterns
    local has_invalid_patterns=false

    # Check for tabs (YAML doesn't allow tabs for indentation)
    if grep -P "\t" "$file_path" >/dev/null 2>&1; then
        has_invalid_patterns=true
        echo -e "    ${YELLOW}⚠${NC} Contains tabs (YAML requires spaces)"
    fi

    # Check for unclosed quotes
    if grep -E "^[^#]*['\"][^'\"]*$" "$file_path" >/dev/null 2>&1; then
        has_invalid_patterns=true
        echo -e "    ${YELLOW}⚠${NC} May contain unclosed quotes"
    fi

    if [ "$has_yaml_structure" = true ] && [ "$has_invalid_patterns" = false ]; then
        echo -e "  ${GREEN}✓${NC} $description: $file_path"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description: $file_path"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Assert JSON is valid
assert_json_valid() {
    local file_path="$1"
    local description="${2:-JSON should be valid}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ ! -f "$file_path" ]; then
        echo -e "  ${RED}✗${NC} $description: File not found: $file_path"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi

    # Basic JSON validation using python if available, otherwise basic checks
    if command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool "$file_path" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $description: $file_path"
            return 0
        else
            echo -e "  ${RED}✗${NC} $description: $file_path (invalid JSON)"
            ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
            return 1
        fi
    else
        # Fallback: basic bracket matching
        local open_braces=$(grep -o '{' "$file_path" | wc -l)
        local close_braces=$(grep -o '}' "$file_path" | wc -l)
        local open_brackets=$(grep -o '\[' "$file_path" | wc -l)
        local close_brackets=$(grep -o '\]' "$file_path" | wc -l)

        if [ "$open_braces" -eq "$close_braces" ] && [ "$open_brackets" -eq "$close_brackets" ]; then
            echo -e "  ${GREEN}✓${NC} $description: $file_path (basic validation)"
            return 0
        else
            echo -e "  ${RED}✗${NC} $description: $file_path (mismatched brackets/braces)"
            ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
            return 1
        fi
    fi
}

# Assert strings are equal
assert_equals() {
    local actual="$1"
    local expected="$2"
    local description="${3:-Values should be equal}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo "      Expected: '$expected'"
        echo "      Actual:   '$actual'"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Assert strings are not equal
assert_not_equals() {
    local actual="$1"
    local not_expected="$2"
    local description="${3:-Values should not be equal}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ "$actual" != "$not_expected" ]; then
        echo -e "  ${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description"
        echo "      Value: '$actual' (should not equal this)"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Assert file is executable
assert_executable() {
    local file_path="$1"
    local description="${2:-File should be executable}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ -x "$file_path" ]; then
        echo -e "  ${GREEN}✓${NC} $description: $file_path"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description: $file_path (not executable)"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Assert file has specific permissions
assert_permissions() {
    local file_path="$1"
    local expected_perms="$2"
    local description="${3:-File should have specific permissions}"

    ASSERTION_COUNT=$((ASSERTION_COUNT + 1))

    if [ ! -e "$file_path" ]; then
        echo -e "  ${RED}✗${NC} $description: File not found: $file_path"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi

    local actual_perms=$(stat -f "%Lp" "$file_path" 2>/dev/null || stat -c "%a" "$file_path" 2>/dev/null)

    if [ "$actual_perms" = "$expected_perms" ]; then
        echo -e "  ${GREEN}✓${NC} $description: $expected_perms"
        return 0
    else
        echo -e "  ${RED}✗${NC} $description: Expected $expected_perms, got $actual_perms"
        ASSERTION_FAILURES=$((ASSERTION_FAILURES + 1))
        return 1
    fi
}

# Summary function
test_summary() {
    echo ""
    echo "Test Summary for: $TEST_CONTEXT"
    echo "  Assertions: $ASSERTION_COUNT"
    echo "  Failures: $ASSERTION_FAILURES"

    if [ $ASSERTION_FAILURES -eq 0 ]; then
        echo -e "  Result: ${GREEN}PASSED${NC}"
        return 0
    else
        echo -e "  Result: ${RED}FAILED${NC}"
        return 1
    fi
}

# Reset test state
reset_test_state() {
    TEST_CONTEXT=""
    ASSERTION_COUNT=0
    ASSERTION_FAILURES=0
}

# Utility: Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Utility: Create temporary test file
create_temp_file() {
    local prefix="${1:-test}"
    local temp_file="/tmp/${prefix}_$$_$(date +%s).tmp"
    touch "$temp_file"
    echo "$temp_file"
}

# Utility: Clean up temporary files
cleanup_temp_files() {
    rm -f /tmp/test_$$_*.tmp 2>/dev/null
}

# Export all functions
export -f set_test_context
export -f assert_file_exists
export -f assert_dir_exists
export -f assert_contains
export -f assert_not_contains
export -f assert_command_succeeds
export -f assert_command_fails
export -f assert_yaml_valid
export -f assert_json_valid
export -f assert_equals
export -f assert_not_equals
export -f assert_executable
export -f assert_permissions
export -f test_summary
export -f reset_test_state
export -f command_exists
export -f create_temp_file
export -f cleanup_temp_files
