#!/bin/bash

# Security Detection Test Suite
# Purpose: Test API key detection patterns without exposing real keys
# Version: 1.0.0

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Create temporary test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

echo -e "${CYAN}┌──────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│     🔬 SECURITY DETECTION TEST SUITE 🔬      │${NC}"
echo -e "${CYAN}└──────────────────────────────────────────────┘${NC}"
echo ""

# Function to run a test
run_test() {
    local test_name="$1"
    local test_file="$2"
    local content="$3"
    local should_detect="$4"  # true or false
    
    ((TESTS_RUN++))
    
    echo -e "${BLUE}Test $TESTS_RUN: $test_name${NC}"
    
    # Create test file
    echo "$content" > "$TEST_DIR/$test_file"
    
    # Stage the file
    cd "$TEST_DIR"
    git init -q 2>/dev/null || true
    git add "$test_file" 2>/dev/null
    
    # Run security check (capture output)
    set +e
    output=$(bash "$GIT_ROOT/.claude/security/pre-push-security-check.sh" 2>&1)
    result=$?
    set -e
    
    # Check result
    if [ "$should_detect" = "true" ]; then
        if [ $result -ne 0 ]; then
            echo -e "  ${GREEN}✓ PASSED${NC} - Correctly detected API key"
            ((TESTS_PASSED++))
        else
            echo -e "  ${RED}✗ FAILED${NC} - Should have detected API key but didn't"
            echo -e "  ${YELLOW}Output:${NC} $output"
            ((TESTS_FAILED++))
        fi
    else
        if [ $result -eq 0 ]; then
            echo -e "  ${GREEN}✓ PASSED${NC} - Correctly ignored safe pattern"
            ((TESTS_PASSED++))
        else
            echo -e "  ${RED}✗ FAILED${NC} - False positive detected"
            echo -e "  ${YELLOW}Output:${NC} $output"
            ((TESTS_FAILED++))
        fi
    fi
    
    # Cleanup
    rm -rf "$TEST_DIR/.git"
    rm -f "$TEST_DIR/$test_file"
    echo ""
}

# Get git root
GIT_ROOT=$(git rev-parse --show-toplevel)

echo -e "${CYAN}Running detection tests...${NC}"
echo ""

# Test 1: OpenAI API Key (should detect)
run_test "OpenAI API Key Detection" \
    "test_openai.py" \
    'OPENAI_KEY = "sk-proj-abcdef1234567890abcdef1234567890abcdef1234567890"' \
    "true"

# Test 2: Anthropic API Key (should detect)
run_test "Anthropic API Key Detection" \
    "test_anthropic.js" \
    'const API_KEY = "sk-ant-api01-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz567890abc123def456ghi789jkl012mno345pqr678";' \
    "true"

# Test 3: GitHub PAT (should detect)
run_test "GitHub PAT Detection" \
    "test_github.sh" \
    'export GITHUB_TOKEN="ghp_1234567890abcdef1234567890abcdef1234"' \
    "true"

# Test 4: AWS Access Key (should detect)
run_test "AWS Access Key Detection" \
    "test_aws.env" \
    'AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE' \
    "true"

# Test 5: Generic API Key Pattern (should detect)
run_test "Generic API Key Pattern" \
    "config.json" \
    '{"api_key": "super_secret_key_1234567890abcdefghij"}' \
    "true"

# Test 6: Documentation Example (should NOT detect - whitelisted)
run_test "Documentation Example Pattern" \
    "README.md" \
    'Set your API key: export OPENAI_KEY=your-api-key-here' \
    "false"

# Test 7: Environment Variable Reference (should NOT detect)
run_test "Environment Variable Reference" \
    "app.py" \
    'api_key = os.getenv("OPENAI_API_KEY")' \
    "false"

# Test 8: Example File (should NOT detect - whitelisted)
run_test "Example Environment File" \
    ".env.example" \
    'OPENAI_API_KEY=sk-1234567890abcdefghijklmnopqrstuvwxyz' \
    "false"

# Test 9: JWT Token (should detect)
run_test "JWT Token Detection" \
    "auth.js" \
    'const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";' \
    "true"

# Test 10: Base64 Encoded Secret (should detect if long enough)
run_test "Base64 Encoded Secret" \
    "secret.txt" \
    'SECRET_DATA="YXBpX2tleT1za18xMjM0NTY3ODkwYWJjZGVmZ2hpams="' \
    "true"

# Test 11: Perplexity API Key (should detect)
run_test "Perplexity API Key Detection" \
    "test_perplexity.py" \
    'PERPLEXITY_KEY = "pplx-1234567890abcdef1234567890abcdef1234567890abcdef"' \
    "true"

# Test 12: ElevenLabs API Key (should detect)
run_test "ElevenLabs API Key Detection" \
    "test_elevenlabs.js" \
    'const elevenLabsKey = "abcdef1234567890abcdef1234567890";' \
    "true"

# Test 13: Code Comment (should NOT detect - whitelisted)
run_test "Code Comment Pattern" \
    "main.py" \
    '# Set API_KEY environment variable before running' \
    "false"

# Test 14: Type Definition (should NOT detect)
run_test "Type Definition Pattern" \
    "types.ts" \
    'interface Config { api_key: string; }' \
    "false"

# Test 15: Multi-line Secret (should detect)
run_test "Multi-line Secret Pattern" \
    "config.sh" \
    'export SECRET_KEY="sk-proj-verylongkeythatspans\
multiplelines1234567890abcdefghijklmnop"' \
    "true"

echo -e "${CYAN}┌──────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│              TEST RESULTS                     │${NC}"
echo -e "${CYAN}└──────────────────────────────────────────────┘${NC}"
echo ""
echo -e "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo -e "Security detection is working correctly."
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo -e "Please review the failed tests above."
    exit 1
fi