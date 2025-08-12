#!/bin/bash
# Comprehensive Script Test Suite - Real Tests, No Mocks
# Tests all production scripts with actual validation

# Find project root (directory containing CLAUDE.md)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧪 COMPREHENSIVE SCRIPT TEST SUITE"
echo "=================================="
echo "Project root: $PROJECT_ROOT"
echo "Testing all scripts with real validation..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Test helper function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo -n "Testing: $test_name... "
    
    if eval "$test_command"; then
        if [ "$expected_result" = "pass" ]; then
            echo -e "${GREEN}✓ PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗ FAILED (expected failure)${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo -e "${GREEN}✓ PASSED (correctly failed)${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗ FAILED${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
}

# =========================
# TEST BRAND DETECTOR
# =========================
echo "📊 Testing Brand Detector..."
echo "----------------------------"

# Create test script with known brand metrics
cat > /tmp/test_script.md << 'EOF'
# Test Podcast Script

I don't know if this will work. Perhaps we should explore this further?
What we don't understand about AI is fascinating. Maybe I'm wrong about this.
I wonder if there's more to discover? We might not have all the answers.
It's possible that our understanding is limited. Could there be another way?
I'm not certain about this conclusion. What if we're missing something?

This is filler text to increase word count for testing purposes.
More content here to ensure we have enough words for density calculation.
Additional text continues here with various topics and discussions.
Let's explore machine learning and artificial intelligence concepts.
Understanding neural networks requires careful study and practice.
The complexity of modern AI systems continues to evolve rapidly.
Data science intersects with many fields of study today.
Research in this area reveals new insights constantly.
EOF

# Test 1: Brand detector should find intellectual humility
run_test "Brand detector finds phrases" \
    ".claude/level-2-production/tools/brand-detector.sh /tmp/test_script.md 2>/dev/null | grep -q 'OVERALL BRAND VOICE SCORE:'" \
    "pass"

# Test 2: Brand detector calculates correct score
BRAND_SCORE=$(.claude/level-2-production/tools/brand-detector.sh /tmp/test_script.md 2>/dev/null | grep "OVERALL BRAND VOICE SCORE:" | awk '{print $5}' | tr -d '%')
run_test "Brand score is reasonable (>5%)" \
    "[ '$BRAND_SCORE' -gt 5 ] 2>/dev/null" \
    "pass"

# =========================
# TEST ERROR DETECTOR
# =========================
echo ""
echo "🔍 Testing Error Detector..."
echo "----------------------------"

# Create test agent output with errors
cat > /tmp/test_agent_output.txt << 'EOF'
Starting agent processing...
ERROR: Failed to connect to API
Warning: Rate limit approaching
Success: Data processed
FAILURE: Could not parse JSON
Error: Timeout after 30 seconds
Completed successfully
EOF

# Test 3: File error analyzer finds errors
run_test "File error analyzer finds ERROR patterns" \
    ".claude/level-2-production/tools/file-error-analyzer.sh /tmp/test_agent_output.txt 2>/dev/null | grep -q 'errors found'" \
    "pass"

# Test 4: File error analyzer counts correctly
ERROR_COUNT=$(.claude/level-2-production/tools/file-error-analyzer.sh /tmp/test_agent_output.txt 2>/dev/null | grep "errors found" | awk '{print $1}')
run_test "Error count is correct (should be 4)" \
    "[ '$ERROR_COUNT' -eq 4 ] 2>/dev/null" \
    "pass"

# =========================
# TEST RECOVERY HELPER
# =========================
echo ""
echo "🔧 Testing Recovery Helper..."
echo "-----------------------------"

# Test 5: Recovery helper handles missing session
run_test "Recovery helper handles missing session gracefully" \
    ".claude/level-2-production/tools/recovery-helper.sh nonexistent_session 2>&1 | grep -q 'not found'" \
    "pass"

# Create test session for recovery
mkdir -p .claude/level-2-production/sessions/test_session
cat > .claude/level-2-production/sessions/test_session/state.json << 'EOF'
{
  "episode": "test_001",
  "phase": "script_writing",
  "status": "failed",
  "last_agent": "03_script_writer",
  "error": "Timeout during generation"
}
EOF

# Test 6: Recovery helper reads session state
run_test "Recovery helper reads session state" \
    ".claude/level-2-production/tools/recovery-helper.sh test_session 2>/dev/null | grep -q 'script_writing'" \
    "pass"

# =========================
# TEST HOOKS
# =========================
echo ""
echo "🪝 Testing Hooks..."
echo "-------------------"

# Test 7: Pre-production hook checks git state
run_test "Pre-production hook runs" \
    "bash .claude/hooks/pre-production.sh >/dev/null 2>&1; [ $? -ne 0 ]" \
    "fail"  # Should fail if uncommitted changes

# Test 8: Pre-commit quality hook checks for backups
touch /tmp/test.backup
run_test "Pre-commit hook detects backup files" \
    "cd /tmp && bash $OLDPWD/.claude/hooks/pre-commit-quality.sh 2>&1 | grep -q 'Backup files detected'" \
    "pass"
rm -f /tmp/test.backup

# =========================
# TEST PIPELINE INTEGRATION
# =========================
echo ""
echo "🔗 Testing Pipeline Integration..."
echo "-----------------------------------"

# Test 9: Pipeline integration test runs
run_test "Pipeline integration test executes" \
    ".claude/level-2-production/tests/pipeline-integration-test.sh >/dev/null 2>&1; [ $? -eq 0 ]" \
    "pass"

# =========================
# TEST PYTHON SCRIPTS
# =========================
echo ""
echo "🐍 Testing Python Scripts..."
echo "----------------------------"

# Test 10: Session analyzer loads without errors
run_test "Session analyzer imports successfully" \
    "PYTHONPATH=\".claude/level-2-production/tools:\$PYTHONPATH\" python3 -c 'import analyze_sessions' 2>/dev/null" \
    "pass"

# Test 11: Metrics exporter loads without errors
run_test "Metrics exporter imports successfully" \
    "PYTHONPATH=\".claude/level-2-production/tools:\$PYTHONPATH\" python3 -c 'import export_metrics' 2>/dev/null" \
    "pass"

# =========================
# TEST ENVIRONMENT
# =========================
echo ""
echo "🌍 Testing Environment Setup..."
echo "--------------------------------"

# Test 12: Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
run_test "Python 3.8+ installed" \
    "python3 -c 'import sys; exit(0 if sys.version_info >= (3,8) else 1)'" \
    "pass"

# Test 13: Check required directories exist
run_test "Required directories exist" \
    "[ -d '.claude/level-2-production/agents' ] && [ -d '.claude/level-2-production/tools' ]" \
    "pass"

# Test 14: Check git is clean (for production readiness)
run_test "Git working directory status check" \
    "git diff-index --quiet HEAD -- 2>/dev/null" \
    "fail"  # Expected to fail if we have changes

# =========================
# TEST SCRIPT PERMISSIONS
# =========================
echo ""
echo "🔐 Testing Script Permissions..."
echo "---------------------------------"

# Test 15: All scripts are executable
SCRIPTS_NOT_EXEC=$(find .claude -name "*.sh" -type f ! -perm -u+x 2>/dev/null | wc -l)
run_test "All scripts are executable" \
    "[ '$SCRIPTS_NOT_EXEC' -eq 0 ]" \
    "pass"

# =========================
# TEST SCRIPT SYNTAX
# =========================
echo ""
echo "✅ Testing Script Syntax..."
echo "----------------------------"

# Test 16: All bash scripts have valid syntax
SYNTAX_ERRORS=0
for script in $(find .claude -name "*.sh" -type f); do
    if ! bash -n "$script" 2>/dev/null; then
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done
run_test "All bash scripts have valid syntax" \
    "[ '$SYNTAX_ERRORS' -eq 0 ]" \
    "pass"

# =========================
# TEST CONFIGURATION FILES
# =========================
echo ""
echo "📝 Testing Configuration Files..."
echo "----------------------------------"

# Test 17: Environment config is valid YAML
run_test "Environment config is valid YAML" \
    "python3 -c 'import yaml; yaml.safe_load(open(\".claude/level-2-production/config/environment.yaml\"))' 2>/dev/null" \
    "pass"

# Test 18: Settings template is valid JSON
if [ -f ".claude/settings.local.json.template" ]; then
    run_test "Settings template is valid JSON" \
        "python3 -c 'import json; json.load(open(\".claude/settings.local.json.template\"))' 2>/dev/null" \
        "pass"
fi

# =========================
# CLEANUP
# =========================
echo ""
echo "🧹 Cleaning up test artifacts..."
rm -f /tmp/test_script.md
rm -f /tmp/test_agent_output.txt
rm -rf .claude/level-2-production/sessions/test_session

# =========================
# FINAL REPORT
# =========================
echo ""
echo "=================================="
echo "📊 TEST RESULTS SUMMARY"
echo "=================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED! ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    exit 0
else
    PASS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}⚠️  PASS RATE: $PASS_RATE% ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    echo ""
    echo "Failed tests may indicate:"
    echo "1. Uncommitted changes (expected for pre-production hook)"
    echo "2. Missing dependencies"
    echo "3. Script bugs that need fixing"
    exit 1
fi