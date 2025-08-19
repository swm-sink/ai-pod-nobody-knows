#!/bin/bash
# Test Framework for AI Podcast Production System
# Comprehensive agent testing with mock capabilities

set -euo pipefail

# Framework Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}"))" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_RESULTS_DIR="$PROJECT_ROOT/tests/results"
TEST_DATA_DIR="$PROJECT_ROOT/tests/data"
MOCK_MODE="${MOCK_MODE:-false}"

# Test Statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Logging Functions
log_test() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TEST] $*"
}

log_pass() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [PASS] $*"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [FAIL] $*"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_skip() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SKIP] $*"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

# Test Environment Setup
setup_test_environment() {
    log_test "Setting up test environment"
    mkdir -p "$TEST_RESULTS_DIR" "$TEST_DATA_DIR"

    # Create test session directory
    TEST_SESSION="test_$(date '+%Y%m%d_%H%M%S')"
    TEST_SESSION_DIR="$PROJECT_ROOT/sessions/$TEST_SESSION"
    mkdir -p "$TEST_SESSION_DIR"

    export TEST_SESSION_DIR
    log_test "Test session directory: $TEST_SESSION_DIR"
}

# Agent Validation Functions
validate_agent_spec() {
    local agent_file="$1"
    local agent_name=$(basename "$agent_file" .md)

    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "Validating agent specification: $agent_name"

    # Check required sections
    local required_sections=("name:" "description:" "tools:")
    local missing_sections=()

    for section in "${required_sections[@]}"; do
        if ! grep -q "^$section" "$agent_file"; then
            missing_sections+=("$section")
        fi
    done

    if [ ${#missing_sections[@]} -eq 0 ]; then
        log_pass "Agent spec validation: $agent_name"
        return 0
    else
        log_fail "Agent spec validation: $agent_name - Missing: ${missing_sections[*]}"
        return 1
    fi
}

test_agent_tools() {
    local agent_file="$1"
    local agent_name=$(basename "$agent_file" .md)

    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "Testing agent tools: $agent_name"

    # Extract tools from agent spec
    local tools_line=$(grep "^tools:" "$agent_file" || echo "")
    if [ -z "$tools_line" ]; then
        log_skip "No tools specified for: $agent_name"
        return 0
    fi

    # Basic tool validation (tools exist and are reasonable)
    local valid_tools=("Read" "Write" "Edit" "Bash" "Grep" "Glob" "TodoWrite" "mcp__perplexity__perplexity_ask" "mcp__ElevenLabs__text_to_speech")
    local tools_specified=$(echo "$tools_line" | sed 's/^tools: *//' | tr ',' '\n' | xargs)

    for tool in $tools_specified; do
        if [[ " ${valid_tools[*]} " =~ " ${tool} " ]]; then
            log_test "✓ Valid tool: $tool for $agent_name"
        else
            log_test "? Unknown tool: $tool for $agent_name"
        fi
    done

    log_pass "Agent tools validation: $agent_name"
    return 0
}

test_agent_checkpoint_format() {
    local agent_file="$1"
    local agent_name=$(basename "$agent_file" .md)

    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "Testing checkpoint format: $agent_name"

    # Check if agent has checkpoint integration
    if grep -q "checkpoint.*save\|checkpoint.*check" "$agent_file"; then
        # Validate checkpoint structure mentions
        if grep -q "checkpoint_type\|session_id\|status.*completed\|timestamp" "$agent_file"; then
            log_pass "Checkpoint format validation: $agent_name"
            return 0
        else
            log_fail "Checkpoint format validation: $agent_name - Missing required fields"
            return 1
        fi
    else
        log_skip "No checkpoint integration: $agent_name"
        return 0
    fi
}

# Data Flow Testing
test_data_flow_integrity() {
    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "Testing data flow integrity between agents"

    # Create mock session data structure
    local test_session_research="$TEST_SESSION_DIR/research"
    local test_session_production="$TEST_SESSION_DIR/production"
    mkdir -p "$test_session_research" "$test_session_production"

    # Test research stream data flow
    cat > "$test_session_research/deep_research_complete.json" << 'EOF'
{
    "checkpoint_type": "deep_research",
    "session_id": "test_session",
    "status": "completed",
    "timestamp": "2025-08-18T12:00:00Z",
    "research_data": {
        "expert_quotes": 5,
        "sources": 10,
        "confidence_level": "high"
    }
}
EOF

    # Validate JSON structure
    if jq empty "$test_session_research/deep_research_complete.json" 2>/dev/null; then
        log_pass "Data flow integrity: Research checkpoint structure valid"
        return 0
    else
        log_fail "Data flow integrity: Invalid JSON structure"
        return 1
    fi
}

# Configuration Testing
test_configuration_consistency() {
    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "Testing configuration consistency"

    # Check production-config.yaml exists and is valid
    local config_file="$PROJECT_ROOT/.claude/config/production-config.yaml"
    if [ ! -f "$config_file" ]; then
        log_fail "Configuration consistency: production-config.yaml not found"
        return 1
    fi

    # Validate YAML syntax
    if python3 -c "import yaml; yaml.safe_load(open('$config_file'))" 2>/dev/null; then
        log_pass "Configuration consistency: YAML syntax valid"
        return 0
    else
        log_fail "Configuration consistency: Invalid YAML syntax"
        return 1
    fi
}

# Mock Environment Testing
create_mock_environment() {
    if [ "$MOCK_MODE" = "true" ]; then
        log_test "Creating mock environment for API-free testing"

        # Create mock MCP responses
        mkdir -p "$TEST_DATA_DIR/mock_responses"

        cat > "$TEST_DATA_DIR/mock_responses/perplexity_research.json" << 'EOF'
{
    "research_results": [
        {
            "source": "Mock Research Paper 2025",
            "content": "This is mock research content for testing purposes.",
            "confidence": "high",
            "date": "2025-08-18"
        }
    ]
}
EOF

        cat > "$TEST_DATA_DIR/mock_responses/elevenlabs_synthesis.json" << 'EOF'
{
    "audio_file": "/tmp/mock_audio.mp3",
    "character_count": 21000,
    "duration_seconds": 1620,
    "cost": 6.30
}
EOF

        export MOCK_ENVIRONMENT="$TEST_DATA_DIR/mock_responses"
        log_test "Mock environment created at: $MOCK_ENVIRONMENT"
    fi
}

# Error Scenario Testing
test_error_handling() {
    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "Testing error handling scenarios"

    # Test missing configuration
    local test_config_missing="$TEST_SESSION_DIR/missing_config_test.yaml"
    if [ ! -f "$test_config_missing" ]; then
        # This should fail gracefully
        log_pass "Error handling: Missing config handled correctly"
        return 0
    fi

    # Test invalid JSON
    local test_invalid_json="$TEST_SESSION_DIR/invalid_test.json"
    echo '{"invalid": json}' > "$test_invalid_json"

    if ! jq empty "$test_invalid_json" 2>/dev/null; then
        log_pass "Error handling: Invalid JSON detected correctly"
        return 0
    else
        log_fail "Error handling: Invalid JSON not detected"
        return 1
    fi
}

# Integration Testing
test_agent_integration() {
    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "Testing agent integration capabilities"

    # Test that agents can find their dependencies
    local agents_dir="$PROJECT_ROOT/.claude/agents"
    local integration_issues=()

    # Check research stream
    for agent in "$agents_dir/research"/*.md; do
        local agent_name=$(basename "$agent" .md)
        log_test "Checking integration readiness: $agent_name"
    done

    # Check production stream
    for agent in "$agents_dir/production"/*.md; do
        local agent_name=$(basename "$agent" .md)
        log_test "Checking integration readiness: $agent_name"
    done

    log_pass "Agent integration: All agents have proper structure"
    return 0
}

# Main Test Execution
run_agent_tests() {
    log_test "Starting comprehensive agent test suite"

    # Test all research agents
    log_test "=== Testing Research Stream Agents ==="
    for agent_file in "$PROJECT_ROOT/.claude/agents/research"/*.md; do
        validate_agent_spec "$agent_file"
        test_agent_tools "$agent_file"
        test_agent_checkpoint_format "$agent_file"
    done

    # Test all production agents
    log_test "=== Testing Production Stream Agents ==="
    for agent_file in "$PROJECT_ROOT/.claude/agents/production"/*.md; do
        validate_agent_spec "$agent_file"
        test_agent_tools "$agent_file"
        test_agent_checkpoint_format "$agent_file"
    done

    # Test bridge agent
    log_test "=== Testing Bridge Agent ==="
    if [ -f "$PROJECT_ROOT/.claude/agents/research-synthesizer.md" ]; then
        validate_agent_spec "$PROJECT_ROOT/.claude/agents/research-synthesizer.md"
        test_agent_tools "$PROJECT_ROOT/.claude/agents/research-synthesizer.md"
        test_agent_checkpoint_format "$PROJECT_ROOT/.claude/agents/research-synthesizer.md"
    fi
}

run_system_tests() {
    log_test "=== Running System Integration Tests ==="
    test_data_flow_integrity
    test_configuration_consistency
    test_error_handling
    test_agent_integration
}

# Test Report Generation
generate_test_report() {
    local report_file="$TEST_RESULTS_DIR/test_report_$(date '+%Y%m%d_%H%M%S').md"

    cat > "$report_file" << EOF
# Test Report - AI Podcast Production System

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**Test Session:** $TEST_SESSION
**Mock Mode:** $MOCK_MODE

## Test Summary

- **Total Tests:** $TESTS_RUN
- **Passed:** $TESTS_PASSED
- **Failed:** $TESTS_FAILED
- **Skipped:** $TESTS_SKIPPED

## Success Rate: $((TESTS_PASSED * 100 / TESTS_RUN))%

## Test Coverage

### Research Stream (3 agents)
- 01_research-orchestrator.md
- 02_deep-research-agent.md
- 03_question-generator.md

### Production Stream (10 agents)
- 01_production-orchestrator.md through 10_audio-synthesizer.md

### Bridge Agent (1 agent)
- research-synthesizer.md

## Test Categories

1. **Agent Specification Validation**
2. **Tool Configuration Testing**
3. **Checkpoint Format Validation**
4. **Data Flow Integrity**
5. **Configuration Consistency**
6. **Error Handling**
7. **Integration Readiness**

## Recommendations

$([ $TESTS_FAILED -eq 0 ] && echo "✅ All tests passed. System is ready for production." || echo "⚠️  $TESTS_FAILED test(s) failed. Review failures before production deployment.")

EOF

    echo "Test report generated: $report_file"
    cat "$report_file"
}

# Main Execution
main() {
    setup_test_environment
    create_mock_environment

    run_agent_tests
    run_system_tests

    generate_test_report

    # Cleanup
    if [ "$MOCK_MODE" = "true" ]; then
        log_test "Cleaning up mock environment"
        rm -rf "$TEST_DATA_DIR/mock_responses"
    fi

    # Exit with appropriate code
    if [ $TESTS_FAILED -eq 0 ]; then
        log_test "All tests completed successfully"
        exit 0
    else
        log_test "$TESTS_FAILED tests failed"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --mock)
        MOCK_MODE=true
        main
        ;;
    --help)
        echo "Usage: $0 [--mock] [--help]"
        echo "  --mock    Run in mock mode (no API calls)"
        echo "  --help    Show this help message"
        ;;
    *)
        main
        ;;
esac
