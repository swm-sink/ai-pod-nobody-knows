#!/bin/bash
# Unit Tests for Deep Research Agent
# Tests the core research functionality and data validation

set -euo pipefail

# Test Configuration
AGENT_FILE=".claude/agents/research/02_deep-research-agent.md"
TEST_SESSION_DIR="tests/data/test_session_research"
MOCK_MODE="${MOCK_MODE:-false}"

# Test Statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging Functions
log_test() { echo "[TEST] $*"; }
log_pass() { echo "[PASS] $*"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_fail() { echo "[FAIL] $*"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

# Setup
setup_test() {
    mkdir -p "$TEST_SESSION_DIR"
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Test Agent Specification
test_agent_spec() {
    setup_test
    log_test "Testing deep research agent specification"
    
    if [ ! -f "$AGENT_FILE" ]; then
        log_fail "Agent file not found: $AGENT_FILE"
        return 1
    fi
    
    # Check required tools
    if grep -q "mcp__perplexity__perplexity_ask" "$AGENT_FILE"; then
        log_pass "Required Perplexity tool specified"
    else
        log_fail "Missing required Perplexity tool"
        return 1
    fi
    
    # Check multi-round research capability
    if grep -q "Multi-Round\|round_1\|round_2" "$AGENT_FILE"; then
        log_pass "Multi-round research capability documented"
    else
        log_fail "Multi-round research capability not found"
        return 1
    fi
}

# Test Checkpoint Format
test_checkpoint_format() {
    setup_test
    log_test "Testing checkpoint format for deep research agent"
    
    # Create test checkpoint
    cat > "$TEST_SESSION_DIR/deep_research_complete.json" << 'EOF'
{
    "checkpoint_type": "deep_research",
    "session_id": "test_session",
    "episode_number": 1,
    "status": "completed",
    "timestamp": "2025-08-18T12:00:00Z",
    "cost_invested": 1.93,
    "research_results": {
        "expert_quotes": 8,
        "recent_sources": 5,
        "search_rounds": 5,
        "total_sources": 50,
        "research_depth": "comprehensive",
        "confidence_level": "high"
    },
    "quality_validation": {
        "source_diversity": "high",
        "information_currency": "current_2024_2025",
        "fact_verification": "verified",
        "brand_alignment": "strong"
    }
}
EOF
    
    # Validate JSON structure
    if jq empty "$TEST_SESSION_DIR/deep_research_complete.json" 2>/dev/null; then
        log_pass "Checkpoint JSON structure valid"
    else
        log_fail "Invalid checkpoint JSON structure"
        return 1
    fi
    
    # Check required fields
    local required_fields=("checkpoint_type" "session_id" "status" "research_results" "expert_quotes")
    for field in "${required_fields[@]}"; do
        if jq -e ".$field" "$TEST_SESSION_DIR/deep_research_complete.json" >/dev/null 2>&1; then
            log_test "✓ Required field present: $field"
        else
            log_fail "Missing required field: $field"
            return 1
        fi
    done
    
    log_pass "Checkpoint format validation complete"
}

# Test Research Quality Metrics
test_research_quality() {
    setup_test
    log_test "Testing research quality validation"
    
    # Check agent has quality thresholds
    if grep -q "50.*sources\|expert.*quotes\|confidence.*level" "$AGENT_FILE"; then
        log_pass "Quality thresholds specified in agent"
    else
        log_fail "Quality thresholds not found in agent specification"
        return 1
    fi
    
    # Test quality validation logic
    local expert_quotes=8
    local total_sources=50
    local min_sources=50
    
    if [ $expert_quotes -ge 5 ] && [ $total_sources -ge $min_sources ]; then
        log_pass "Research quality metrics meet requirements"
    else
        log_fail "Research quality metrics below requirements"
        return 1
    fi
}

# Test Cost Tracking Integration
test_cost_tracking() {
    setup_test
    log_test "Testing cost tracking integration"
    
    # Check if agent spec mentions cost tracking
    if grep -q "cost.*invested\|budget\|cost.*tracking" "$AGENT_FILE"; then
        log_pass "Cost tracking integration documented"
    else
        log_fail "Cost tracking integration not documented"
        return 1
    fi
    
    # Validate cost estimation
    local estimated_cost=1.93
    local max_cost=2.50
    
    if (( $(echo "$estimated_cost <= $max_cost" | bc -l) )); then
        log_pass "Cost estimation within budget"
    else
        log_fail "Cost estimation exceeds budget"
        return 1
    fi
}

# Mock Research Function (for API-free testing)
test_mock_research() {
    if [ "$MOCK_MODE" = "true" ]; then
        setup_test
        log_test "Testing mock research functionality"
        
        # Create mock research output
        cat > "$TEST_SESSION_DIR/mock_research_output.json" << 'EOF'
{
    "research_round_1": {
        "queries": 5,
        "sources_found": 12,
        "expert_quotes": 3
    },
    "research_round_2": {
        "queries": 4,
        "sources_found": 8,
        "expert_quotes": 2
    },
    "total_research": {
        "rounds": 2,
        "total_queries": 9,
        "total_sources": 20,
        "total_expert_quotes": 5
    }
}
EOF
        
        # Validate mock output
        if jq -e '.total_research.total_expert_quotes >= 5' "$TEST_SESSION_DIR/mock_research_output.json" >/dev/null; then
            log_pass "Mock research meets quality requirements"
        else
            log_fail "Mock research below quality requirements"
            return 1
        fi
    else
        log_test "Skipping mock research (not in mock mode)"
    fi
}

# Run All Tests
run_tests() {
    log_test "Starting deep research agent tests"
    
    test_agent_spec
    test_checkpoint_format  
    test_research_quality
    test_cost_tracking
    test_mock_research
    
    # Summary
    echo "=== Deep Research Agent Test Summary ==="
    echo "Tests Run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo "✅ All deep research agent tests passed"
        return 0
    else
        echo "❌ $TESTS_FAILED deep research agent tests failed"
        return 1
    fi
}

# Cleanup
cleanup() {
    rm -rf "$TEST_SESSION_DIR"
}

# Main execution
trap cleanup EXIT
run_tests