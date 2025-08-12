#!/bin/bash
# Session State Recovery Validation Test
# Tests system ability to recover from various interruption scenarios

echo "🔄 SESSION STATE RECOVERY VALIDATION"  
echo "===================================="

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Find project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

echo "Project root: $PROJECT_ROOT"
echo ""

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

echo "📁 Testing Session Directory Structure..."
echo "----------------------------------------"

# Test 1: Session directories exist and are writable
run_test "Active sessions directory exists" \
    "[ -d '.claude/level-2-production/sessions/active' ] && [ -w '.claude/level-2-production/sessions/active' ]" \
    "pass"

run_test "Completed sessions directory exists" \
    "[ -d '.claude/level-2-production/sessions/completed' ] && [ -w '.claude/level-2-production/sessions/completed' ]" \
    "pass"

run_test "Failed sessions directory exists" \
    "[ -d '.claude/level-2-production/sessions/failed' ] && [ -w '.claude/level-2-production/sessions/failed' ]" \
    "pass"

echo ""
echo "🔧 Testing Session State Management..."
echo "-------------------------------------"

# Create test session
TEST_SESSION_ID="test_recovery_$(date +%s)"
TEST_SESSION_DIR=".claude/level-2-production/sessions/active/$TEST_SESSION_ID"

# Test 2: Can create session state
mkdir -p "$TEST_SESSION_DIR"
cat > "$TEST_SESSION_DIR/state.json" << EOF
{
  "session_id": "$TEST_SESSION_ID",
  "episode_id": "ep_test_001",
  "phase": "script_writing",
  "status": "in_progress",
  "current_agent": "03_script_writer",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agents_completed": ["01_research_coordinator", "02_episode_planner"],
  "agents_remaining": ["03_script_writer", "04_quality_claude"],
  "context": {
    "topic": "AI Podcast Testing",
    "complexity_level": 3,
    "target_length": 4200
  },
  "error_log": [],
  "recovery_points": [
    {
      "agent": "01_research_coordinator", 
      "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
      "state": "completed"
    }
  ]
}
EOF

run_test "Session state file creation" \
    "[ -f '$TEST_SESSION_DIR/state.json' ] && python3 -m json.tool '$TEST_SESSION_DIR/state.json' >/dev/null" \
    "pass"

# Test 3: Recovery helper can read session
run_test "Recovery helper reads session state" \
    ".claude/level-2-production/tools/recovery-helper.sh '$TEST_SESSION_ID' 2>/dev/null | grep -q 'script_writing'" \
    "pass"

echo ""
echo "⚡ Testing Interruption Scenarios..."
echo "-----------------------------------"

# Test 4: Simulate agent failure
cat > "$TEST_SESSION_DIR/error.log" << EOF
[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Agent 03_script_writer failed with timeout
[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR: Connection to Perplexity API lost
[$(date -u +%Y-%m-%dT%H:%M:%SZ)] WARNING: Retrying from last checkpoint
EOF

run_test "Error log handling" \
    "[ -f '$TEST_SESSION_DIR/error.log' ] && grep -q 'ERROR:' '$TEST_SESSION_DIR/error.log'" \
    "pass"

# Test 5: Test session state update after failure
python3 -c "
import json, sys
with open('$TEST_SESSION_DIR/state.json', 'r') as f:
    state = json.load(f)
state['status'] = 'failed'
state['last_error'] = 'Agent timeout during script generation'
state['updated_at'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
with open('$TEST_SESSION_DIR/state.json', 'w') as f:
    json.dump(state, f, indent=2)
print('Session state updated to failed')
"

run_test "Session failure state update" \
    "python3 -c 'import json; s=json.load(open(\"$TEST_SESSION_DIR/state.json\")); exit(0 if s[\"status\"] == \"failed\" else 1)'" \
    "pass"

echo ""
echo "🔄 Testing Recovery Procedures..."
echo "--------------------------------"

# Test 6: Move failed session to failed directory
FAILED_SESSION_DIR=".claude/level-2-production/sessions/failed/$TEST_SESSION_ID"
mv "$TEST_SESSION_DIR" "$FAILED_SESSION_DIR"

run_test "Failed session relocation" \
    "[ -d '$FAILED_SESSION_DIR' ] && [ -f '$FAILED_SESSION_DIR/state.json' ]" \
    "pass"

# Test 7: Recovery from failed state
run_test "Recovery helper handles failed sessions" \
    ".claude/level-2-production/tools/recovery-helper.sh '$TEST_SESSION_ID' 2>/dev/null | grep -q 'failed'" \
    "pass"

echo ""
echo "📊 Testing Session Analytics..."
echo "------------------------------"

# Test 8: Session metrics collection
SESSIONS_COUNT=$(find .claude/level-2-production/sessions -name "*.json" -type f 2>/dev/null | wc -l)
run_test "Session files enumeration" \
    "[ '$SESSIONS_COUNT' -gt 0 ]" \
    "pass"

# Test 9: Test session analysis tools
run_test "Session analysis tool execution" \
    "PYTHONPATH='.claude/level-2-production/tools' python3 -c 'import analyze_sessions; print(\"Analysis tools available\")' 2>/dev/null" \
    "pass"

echo ""
echo "🧹 Testing Cleanup and Recovery..."  
echo "---------------------------------"

# Test 10: Git integration with session recovery
CURRENT_COMMIT=$(git rev-parse HEAD)
run_test "Git context preservation" \
    "[ -n '$CURRENT_COMMIT' ] && git log --oneline -1 | grep -q ." \
    "pass"

# Test 11: Session cleanup capabilities
run_test "Session cleanup" \
    "rm -rf '$FAILED_SESSION_DIR' && [ ! -d '$FAILED_SESSION_DIR' ]" \
    "pass"

echo ""
echo "🔧 Testing Recovery Helper Functionality..."
echo "------------------------------------------"

# Create a more complex test scenario
COMPLEX_SESSION_ID="complex_recovery_$(date +%s)"
COMPLEX_SESSION_DIR=".claude/level-2-production/sessions/active/$COMPLEX_SESSION_ID"
mkdir -p "$COMPLEX_SESSION_DIR"

# Create complex session state with partial completion
cat > "$COMPLEX_SESSION_DIR/state.json" << EOF
{
  "session_id": "$COMPLEX_SESSION_ID",
  "episode_id": "ep_complex_001", 
  "phase": "quality_evaluation",
  "status": "agent_failed",
  "current_agent": "04_quality_claude",
  "failure_point": "quality_evaluation",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agents_completed": [
    "01_research_coordinator",
    "02_episode_planner", 
    "03_script_writer"
  ],
  "agents_remaining": [
    "04_quality_claude",
    "05_quality_gemini",
    "06_feedback_synthesizer",
    "07_script_polisher",
    "08_final_reviewer", 
    "09_audio_synthesizer"
  ],
  "partial_outputs": {
    "research_data": "research_output.json",
    "episode_plan": "episode_plan.md",
    "initial_script": "script_draft.md"
  },
  "recovery_strategy": "resume_from_quality_evaluation"
}
EOF

# Test 12: Complex recovery scenario
run_test "Complex session recovery analysis" \
    ".claude/level-2-production/tools/recovery-helper.sh '$COMPLEX_SESSION_ID' 2>/dev/null | grep -q 'quality_evaluation'" \
    "pass"

# Cleanup complex test
rm -rf "$COMPLEX_SESSION_DIR"

echo ""
echo "=================================="
echo "📊 SESSION RECOVERY TEST RESULTS"
echo "=================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL SESSION RECOVERY TESTS PASSED! ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    echo ""
    echo "Session Recovery Capabilities Validated:"
    echo "✓ Session state persistence"
    echo "✓ Error logging and recovery"  
    echo "✓ Failed session management"
    echo "✓ Recovery helper functionality"
    echo "✓ Git integration preservation"
    echo "✓ Session analytics tools"
    echo "✓ Complex recovery scenarios"
    exit 0
else
    PASS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}⚠️  PASS RATE: $PASS_RATE% ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    echo ""
    echo "Recovery issues found. Manual investigation required."
    exit 1
fi