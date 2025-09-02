#!/bin/bash

# Simplified Architecture Validation Suite
# Tests the native Claude Code simplified architecture (Phase 5)
# Date: 2025-09-01

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SIMPLIFIED_DIR="$PROJECT_ROOT/.claude"
TEST_RESULTS="$PROJECT_ROOT/tests/results/simplified-validation-$(date +%Y%m%d-%H%M%S).log"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_test() {
    echo -e "${YELLOW}[TEST]${NC} $*" | tee -a "$TEST_RESULTS"
    ((TESTS_RUN++))
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $*" | tee -a "$TEST_RESULTS"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $*" | tee -a "$TEST_RESULTS"
    ((TESTS_FAILED++))
}

# Initialize test environment
initialize_tests() {
    mkdir -p "$(dirname "$TEST_RESULTS")"
    echo "=== Simplified Architecture Validation Suite ===" > "$TEST_RESULTS"
    echo "Date: $(date)" >> "$TEST_RESULTS"
    echo "Project: $PROJECT_ROOT" >> "$TEST_RESULTS"
    echo "" >> "$TEST_RESULTS"
}

# ============================================================================
# UNIT TESTS - Individual Component Validation
# ============================================================================

test_agent_files() {
    log_test "Testing simplified agent files existence"

    local agents=(
        "researcher.md"
        "fact-checker.md"
        "synthesizer.md"
        "writer.md"
        "polisher.md"
        "judge.md"
        "audio-producer.md"
        "audio-validator.md"
        "batch-processor.md"
        "cost-monitor.md"
    )

    local all_exist=true
    for agent in "${agents[@]}"; do
        if [[ -f "$SIMPLIFIED_DIR/agents/simplified/$agent" ]]; then
            echo "  ✓ Agent: $agent" >> "$TEST_RESULTS"
        else
            echo "  ✗ Missing agent: $agent" >> "$TEST_RESULTS"
            all_exist=false
        fi
    done

    if $all_exist; then
        log_pass "All 10 simplified agents exist"
    else
        log_fail "Some agents missing"
        return 1
    fi
}

test_command_files() {
    log_test "Testing simplified command files existence"

    local commands=(
        "research-workflow.md"
        "production-workflow.md"
        "audio-workflow.md"
        "podcast-workflow.md"
        "meta-chain.md"
    )

    local all_exist=true
    for command in "${commands[@]}"; do
        if [[ -f "$SIMPLIFIED_DIR/commands/simplified/$command" ]]; then
            echo "  ✓ Command: $command" >> "$TEST_RESULTS"
        else
            echo "  ✗ Missing command: $command" >> "$TEST_RESULTS"
            all_exist=false
        fi
    done

    if $all_exist; then
        log_pass "All 5 simplified commands exist"
    else
        log_fail "Some commands missing"
        return 1
    fi
}

test_hook_files() {
    log_test "Testing simplified hook files existence"

    local hooks=(
        "pre-tool-validation.sh"
        "post-tool-tracking.sh"
        "session-lifecycle.sh"
    )

    local all_exist=true
    for hook in "${hooks[@]}"; do
        if [[ -f "$SIMPLIFIED_DIR/hooks/simplified/$hook" ]]; then
            # Check if executable
            if [[ -x "$SIMPLIFIED_DIR/hooks/simplified/$hook" ]]; then
                echo "  ✓ Hook: $hook (executable)" >> "$TEST_RESULTS"
            else
                echo "  ⚠ Hook: $hook (not executable)" >> "$TEST_RESULTS"
                chmod +x "$SIMPLIFIED_DIR/hooks/simplified/$hook"
            fi
        else
            echo "  ✗ Missing hook: $hook" >> "$TEST_RESULTS"
            all_exist=false
        fi
    done

    if $all_exist; then
        log_pass "All 3 simplified hooks exist and are executable"
    else
        log_fail "Some hooks missing"
        return 1
    fi
}

test_context_files() {
    log_test "Testing simplified context files existence"

    local contexts=(
        "workflow.md"
        "agents.md"
        "quality.md"
        "troubleshooting.md"
        "CONTEXT_INDEX.md"
    )

    local all_exist=true
    for context in "${contexts[@]}"; do
        if [[ -f "$SIMPLIFIED_DIR/context/simplified/$context" ]]; then
            echo "  ✓ Context: $context" >> "$TEST_RESULTS"
        else
            echo "  ✗ Missing context: $context" >> "$TEST_RESULTS"
            all_exist=false
        fi
    done

    if $all_exist; then
        log_pass "All 5 simplified contexts exist"
    else
        log_fail "Some contexts missing"
        return 1
    fi
}

# ============================================================================
# INTEGRATION TESTS - Component Interaction Validation
# ============================================================================

test_hook_functionality() {
    log_test "Testing hook basic functionality"

    # Test session lifecycle
    local session_status=$("$SIMPLIFIED_DIR/hooks/simplified/session-lifecycle.sh" status 2>&1)
    if [[ "$session_status" == *"No active session"* ]] || [[ "$session_status" == *"session_id"* ]]; then
        log_pass "Session lifecycle hook functional"
    else
        log_fail "Session lifecycle hook error: $session_status"
        return 1
    fi

    # Test pre-tool validation (mock test)
    if "$SIMPLIFIED_DIR/hooks/simplified/pre-tool-validation.sh" "test_tool" 1000 2>&1 | grep -q "PRE-VALIDATION.*Complete"; then
        log_pass "Pre-tool validation hook functional"
    else
        log_fail "Pre-tool validation hook not working"
        return 1
    fi
}

test_agent_structure() {
    log_test "Testing agent structure and patterns"

    # Check for proper invocation pattern in agents
    local agent_file="$SIMPLIFIED_DIR/agents/simplified/researcher.md"

    if grep -q "## Purpose" "$agent_file" && \
       grep -q "## Core Capabilities" "$agent_file" && \
       grep -q "name: researcher" "$agent_file"; then
        log_pass "Agent structure follows correct pattern"
    else
        log_fail "Agent structure missing required sections"
        return 1
    fi
}

test_command_orchestration() {
    log_test "Testing command orchestration patterns"

    # Check podcast-workflow chains other commands
    local workflow_file="$SIMPLIFIED_DIR/commands/simplified/podcast-workflow.md"

    if grep -q "research-workflow" "$workflow_file" && \
       grep -q "production-workflow" "$workflow_file" && \
       grep -q "audio-workflow" "$workflow_file"; then
        log_pass "Command orchestration pattern correct"
    else
        log_fail "Command orchestration missing workflow chains"
        return 1
    fi
}

# ============================================================================
# QUALITY VALIDATION - Architecture Quality Checks
# ============================================================================

test_cost_configuration() {
    log_test "Testing cost optimization configuration"

    # Check quality.md for cost targets
    local quality_file="$SIMPLIFIED_DIR/context/simplified/quality.md"

    if grep -q "\$2.80" "$quality_file" && \
       grep -q "\$4.00" "$quality_file"; then
        log_pass "Cost targets properly configured"
    else
        log_fail "Cost targets not found in quality context"
        return 1
    fi
}

test_voice_configuration() {
    log_test "Testing voice configuration governance"

    # Check for Amelia voice ID
    local voice_id="ZF6FPAbjXT4488VcRRnw"
    local config_file="$SIMPLIFIED_DIR/config/production-voice.json"

    if [[ -f "$config_file" ]]; then
        if grep -q "$voice_id" "$config_file"; then
            log_pass "Voice configuration correct (Amelia)"
        else
            log_fail "Wrong voice ID in configuration"
            return 1
        fi
    else
        log_fail "Voice configuration file missing"
        return 1
    fi
}

test_quality_gates() {
    log_test "Testing quality gate configuration"

    # Check quality gates YAML
    local gates_file="$SIMPLIFIED_DIR/config/quality_gates.yaml"

    if [[ -f "$gates_file" ]]; then
        if grep -q "brand_consistency:" "$gates_file" && \
           grep -q "minimum: 0.90" "$gates_file"; then
            log_pass "Quality gates properly configured"
        else
            log_fail "Quality gates misconfigured"
            return 1
        fi
    else
        log_fail "Quality gates file missing"
        return 1
    fi
}

# ============================================================================
# REDUCTION VALIDATION - Verify Simplification Achieved
# ============================================================================

test_reduction_metrics() {
    log_test "Testing reduction metrics achievement"

    # Count files in simplified directories
    local agent_count=$(ls "$SIMPLIFIED_DIR/agents/simplified/"*.md 2>/dev/null | wc -l)
    local command_count=$(ls "$SIMPLIFIED_DIR/commands/simplified/"*.md 2>/dev/null | wc -l)
    local hook_count=$(ls "$SIMPLIFIED_DIR/hooks/simplified/"*.sh 2>/dev/null | wc -l)
    local context_count=$(ls "$SIMPLIFIED_DIR/context/simplified/"*.md 2>/dev/null | wc -l)

    echo "  Agents: $agent_count (target: 10)" >> "$TEST_RESULTS"
    echo "  Commands: $command_count (target: 5)" >> "$TEST_RESULTS"
    echo "  Hooks: $hook_count (target: 3)" >> "$TEST_RESULTS"
    echo "  Contexts: $context_count (target: 5)" >> "$TEST_RESULTS"

    if [[ $agent_count -eq 10 ]] && \
       [[ $command_count -eq 5 ]] && \
       [[ $hook_count -eq 3 ]] && \
       [[ $context_count -eq 5 ]]; then
        log_pass "All reduction targets achieved"
    else
        log_fail "Reduction targets not met"
        return 1
    fi
}

# ============================================================================
# MAIN TEST EXECUTION
# ============================================================================

main() {
    initialize_tests

    echo ""
    echo "===== UNIT TESTS =====" | tee -a "$TEST_RESULTS"
    test_agent_files || true
    test_command_files || true
    test_hook_files || true
    test_context_files || true

    echo ""
    echo "===== INTEGRATION TESTS =====" | tee -a "$TEST_RESULTS"
    test_hook_functionality || true
    test_agent_structure || true
    test_command_orchestration || true

    echo ""
    echo "===== QUALITY VALIDATION =====" | tee -a "$TEST_RESULTS"
    test_cost_configuration || true
    test_voice_configuration || true
    test_quality_gates || true

    echo ""
    echo "===== REDUCTION VALIDATION =====" | tee -a "$TEST_RESULTS"
    test_reduction_metrics || true

    echo ""
    echo "===== TEST SUMMARY =====" | tee -a "$TEST_RESULTS"
    echo "Tests Run: $TESTS_RUN" | tee -a "$TEST_RESULTS"
    echo "Tests Passed: $TESTS_PASSED" | tee -a "$TEST_RESULTS"
    echo "Tests Failed: $TESTS_FAILED" | tee -a "$TEST_RESULTS"

    local pass_rate=$((TESTS_PASSED * 100 / TESTS_RUN))
    echo "Pass Rate: ${pass_rate}%" | tee -a "$TEST_RESULTS"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed!${NC}" | tee -a "$TEST_RESULTS"
        exit 0
    else
        echo -e "${RED}✗ Some tests failed. Review results in: $TEST_RESULTS${NC}"
        exit 1
    fi
}

# Run tests
main "$@"
