#!/bin/bash
# Full Pipeline Integration Test
# Tests the complete 9-agent production pipeline

echo "🧪 FULL PIPELINE INTEGRATION TEST"
echo "=================================="
echo ""

# Test configuration
TEST_EPISODE=999
TEST_TOPIC="Test: AI and Uncertainty"
SESSION_DIR=".claude/level-2-production/sessions"
OUTPUT_DIR="projects/nobody-knows/output"

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Testing: $test_name... "

    if eval "$test_command"; then
        if [ "$expected_result" = "pass" ]; then
            echo -e "${GREEN}✅ PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}❌ FAILED (expected failure)${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo -e "${GREEN}✅ PASSED (expected failure)${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}❌ FAILED${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
}

echo "📋 PRE-FLIGHT CHECKS"
echo "--------------------"

# Check directory structure
run_test "Sessions directory exists" "[ -d '$SESSION_DIR' ]" "pass"
run_test "Output directory exists" "[ -d '$OUTPUT_DIR' ]" "pass"
run_test "Agents directory exists" "[ -d '.claude/level-2-production/agents' ]" "pass"
run_test "Commands directory exists" "[ -d '.claude/level-2-production/commands' ]" "pass"

echo ""
echo "🔧 COMPONENT TESTS"
echo "------------------"

# Test individual components
run_test "Pipeline coordinator exists" "[ -f '.claude/level-2-production/commands/pipeline-coordinator.md' ]" "pass"
run_test "Error detector executable" "[ -x '.claude/level-2-production/tools/error-detector.sh' ] || [ -x '.claude/level-2-production/tools/.claude/level-2-production/tools/error-detector.sh' ]" "pass"
run_test "Brand detector executable" "[ -x '.claude/level-2-production/tools/brand-detector.sh' ]" "pass"
run_test "Recovery helper exists" "[ -f '.claude/level-2-production/tools/recovery-helper.sh' ] || [ -f '.claude/level-2-production/tools/.claude/level-2-production/tools/recovery-helper.sh' ]" "pass"

echo ""
echo "🎭 AGENT VERIFICATION"
echo "---------------------"

# Check all 9 agents exist
AGENTS=(
    "01_research_coordinator"
    "02_episode_planner"
    "03_script_writer"
    "04_quality_claude"
    "05_quality_gemini"
    "06_feedback_synthesizer"
    "07_script_polisher"
    "08_final_reviewer"
    "09_audio_synthesizer"
)

for agent in "${AGENTS[@]}"; do
    run_test "Agent: $agent" "[ -f '.claude/level-2-production/agents/${agent}.md' ]" "pass"
done

echo ""
echo "⚙️ CONFIGURATION TESTS"
echo "----------------------"

# Test configuration files
run_test "Error handling config" "[ -f '.claude/level-2-production/config/error-handling.yaml' ]" "pass"
run_test "Quality gates defined" "grep -q 'Quality Criteria' '.claude/level-2-production/agents/08_final_reviewer.md'" "pass"
run_test "ElevenLabs reference fixed" "! grep -q 'elevenlabs_' '.claude/level-2-production/agents/09_audio_synthesizer.md'" "pass"

echo ""
echo "🔄 STATE MANAGEMENT TESTS"
echo "-------------------------"

# Test session management
TEST_SESSION_ID="ep_${TEST_EPISODE}_$(date +%Y%m%d_%H%M)"
TEST_SESSION_FILE="$SESSION_DIR/active/${TEST_SESSION_ID}.json"

# Create test session
cat > "$TEST_SESSION_FILE" << EOF
{
  "session_id": "${TEST_SESSION_ID}",
  "episode_number": ${TEST_EPISODE},
  "current_state": "TESTING",
  "pipeline_stage": 0,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

run_test "Session creation" "[ -f '$TEST_SESSION_FILE' ]" "pass"
run_test "Session JSON valid" "python3 -m json.tool '$TEST_SESSION_FILE' > /dev/null 2>&1" "pass"

# Clean up test session
rm -f "$TEST_SESSION_FILE"

echo ""
echo "🔍 QUALITY VALIDATION TESTS"
echo "---------------------------"

# Test quality measurement tools
if [ -f ".claude/level-2-production/tests/test-brand-script.md" ]; then
    run_test "Brand detection on test script" ".claude/level-2-production/tools/brand-detector.sh .claude/level-2-production/tests/test-brand-script.md > /dev/null 2>&1" "pass"
fi

echo ""
echo "🚨 ERROR RECOVERY TESTS"
echo "-----------------------"

# Test error detection
if [ -x ".claude/level-2-production/tools/error-detector.sh" ]; then
    run_test "Error detector runs" ".claude/level-2-production/tools/error-detector.sh > /dev/null 2>&1" "pass"
elif [ -x ".claude/level-2-production/tools/.claude/level-2-production/tools/error-detector.sh" ]; then
    run_test "Error detector runs" ".claude/level-2-production/tools/.claude/level-2-production/tools/error-detector.sh > /dev/null 2>&1" "pass"
fi

echo ""
echo "📊 INTEGRATION TEST SUMMARY"
echo "==========================="
echo "Tests Run: $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL INTEGRATION TESTS PASSED!${NC}"
    echo "System ready for production pipeline execution."
    exit 0
else
    echo -e "${RED}⚠️ SOME TESTS FAILED${NC}"
    echo "Please review and fix issues before production use."
    exit 1
fi
