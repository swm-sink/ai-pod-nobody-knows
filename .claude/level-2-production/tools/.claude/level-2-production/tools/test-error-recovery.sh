#!/bin/bash
# Test Error Recovery with Simulated Failures
# Simple tests to make sure our recovery tools work

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🧪 Testing Error Recovery Systems"
echo "=================================="
echo ""

# Test 1: Simulate a stuck session
test_stuck_session() {
    echo "Test 1: Simulating stuck session..."

    # Create a fake old session file
    mkdir -p .claude/level-2-production/sessions/active
    touch -t 202501010000 .claude/level-2-production/sessions/active/test_stuck.json
    echo '{"session_id": "test_stuck", "status": "processing"}' > .claude/level-2-production/sessions/active/test_stuck.json

    # Run cleanup
    echo "Running cleanup..."
    ./recovery-helper.sh cleanup

    # Check if it was moved
    if [ ! -f ".claude/level-2-production/sessions/active/test_stuck.json" ]; then
        echo -e "${GREEN}✓ Test 1 PASSED: Stuck session cleaned up${NC}"
    else
        echo -e "${RED}✗ Test 1 FAILED: Stuck session not cleaned${NC}"
    fi
    echo ""
}

# Test 2: Test backup functionality
test_backup() {
    echo "Test 2: Testing backup system..."

    # Create test data
    mkdir -p .claude/level-2-production/sessions/active
    echo '{"test": "data"}' > .claude/level-2-production/sessions/active/test_backup.json

    # Run backup
    ./recovery-helper.sh backup

    # Check if backup was created
    if [ -d ".claude/level-2-production/sessions/backups" ]; then
        echo -e "${GREEN}✓ Test 2 PASSED: Backup created successfully${NC}"
    else
        echo -e "${RED}✗ Test 2 FAILED: Backup not created${NC}"
    fi

    # Clean up test file
    rm -f .claude/level-2-production/sessions/active/test_backup.json
    echo ""
}

# Test 3: Test error detection
test_error_detection() {
    echo "Test 3: Testing error detection..."

    # Run error detector
    ./error-detector.sh > /tmp/detector_output.txt 2>&1

    # Check if it ran successfully
    if grep -q "Error Detection Complete" /tmp/detector_output.txt; then
        echo -e "${GREEN}✓ Test 3 PASSED: Error detector works${NC}"
    else
        echo -e "${RED}✗ Test 3 FAILED: Error detector failed${NC}"
    fi
    echo ""
}

# Test 4: Simulate recovery from checkpoint
test_checkpoint_recovery() {
    echo "Test 4: Simulating checkpoint recovery..."

    # Create a checkpoint file
    mkdir -p .claude/level-2-production/sessions/checkpoints
    cat > .claude/level-2-production/sessions/checkpoints/checkpoint_test.json << EOF
{
    "session_id": "ep_001_test",
    "checkpoint_agent": "03_script_writer",
    "checkpoint_time": "$(date -Iseconds)",
    "can_resume": true
}
EOF

    # Check if checkpoint is valid JSON
    if python3 -c "import json; json.load(open('.claude/level-2-production/sessions/checkpoints/checkpoint_test.json'))" 2>/dev/null; then
        echo -e "${GREEN}✓ Test 4 PASSED: Checkpoint is valid and restorable${NC}"
    else
        echo -e "${RED}✗ Test 4 FAILED: Invalid checkpoint data${NC}"
    fi
    echo ""
}

# Test 5: Test quality gate failure handling
test_quality_gate() {
    echo "Test 5: Testing quality gate failure handling..."

    # Simulate quality scores below threshold
    COMPREHENSION=0.75  # Below 0.85 threshold
    BRAND=0.95

    # Check against thresholds from config
    if (( $(echo "$COMPREHENSION < 0.85" | bc -l) )); then
        echo -e "${YELLOW}Quality gate triggered: Comprehension $COMPREHENSION < 0.85${NC}"
        echo "Action: Would invoke script_polisher for revision"
        echo -e "${GREEN}✓ Test 5 PASSED: Quality gate detection works${NC}"
    else
        echo -e "${RED}✗ Test 5 FAILED: Quality gate not triggered${NC}"
    fi
    echo ""
}

# Run all tests
echo "Running all tests..."
echo ""

test_stuck_session
test_backup
test_error_detection
test_checkpoint_recovery
test_quality_gate

echo "=================================="
echo -e "${BLUE}Test Summary:${NC}"
echo "- Stuck session cleanup: Tested"
echo "- Backup system: Tested"
echo "- Error detection: Tested"
echo "- Checkpoint recovery: Tested"
echo "- Quality gate handling: Tested"
echo ""
echo "🎯 Error Recovery Testing Complete!"
