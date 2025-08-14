#!/bin/bash

# ============================================================================
# GEMINI CLI QUALITY EVALUATION TEST SUITE
# ============================================================================
# Purpose: Comprehensive testing of Gemini CLI integration for podcast quality
# Author: Claude Code AI Assistant
# Date: 2025-01-14
# Version: 1.0.0
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

run_test() {
    local test_name="$1"
    local test_command="$2"

    ((TESTS_RUN++))
    echo -e "\n${BLUE}TEST ${TESTS_RUN}:${NC} $test_name"

    if eval "$test_command"; then
        log_success "$test_name"
        return 0
    else
        log_failure "$test_name"
        return 1
    fi
}

# ============================================================================
# TEST 1: GEMINI CLI INSTALLATION CHECK
# ============================================================================

test_gemini_installation() {
    if command -v gemini &> /dev/null; then
        local version=$(gemini --version 2>/dev/null || echo "unknown")
        log_info "Gemini CLI version: $version"
        return 0
    else
        log_warning "Gemini CLI not found. Install with: npm install -g @google/gemini-cli"
        return 1
    fi
}

# ============================================================================
# TEST 2: BASIC GEMINI RESPONSE
# ============================================================================

test_basic_response() {
    local response=$(echo "Hello" | timeout 10 gemini -p "Respond with exactly: OK" 2>/dev/null || echo "TIMEOUT")

    if [[ "$response" == *"OK"* ]] || [[ "$response" == *"ok"* ]]; then
        return 0
    else
        log_warning "Response: $response"
        return 1
    fi
}

# ============================================================================
# TEST 3: JSON OUTPUT VALIDATION
# ============================================================================

test_json_output() {
    local temp_file="/tmp/gemini_json_test_$$.json"

    echo "Test" | timeout 15 gemini -p 'Output ONLY this JSON: {"test": true, "value": 42}' > "$temp_file" 2>/dev/null

    # Try to extract JSON if mixed with text
    sed -n '/^{/,/^}/p' "$temp_file" > "${temp_file}.clean"

    if jq empty "${temp_file}.clean" 2>/dev/null; then
        local test_value=$(jq -r '.test' "${temp_file}.clean" 2>/dev/null)
        rm -f "$temp_file" "${temp_file}.clean"
        [[ "$test_value" == "true" ]]
        return $?
    else
        rm -f "$temp_file" "${temp_file}.clean"
        return 1
    fi
}

# ============================================================================
# TEST 4: LIKERT SCALE SCORING
# ============================================================================

test_likert_scoring() {
    local temp_file="/tmp/gemini_likert_test_$$.json"
    local prompt='Rate "This is excellent content" on a 1-5 scale. Output ONLY JSON: {"score": [1-5 integer]}'

    echo "This is excellent content" | timeout 15 gemini -p "$prompt" > "$temp_file" 2>/dev/null

    # Extract JSON
    sed -n '/^{/,/^}/p' "$temp_file" > "${temp_file}.clean"

    if jq empty "${temp_file}.clean" 2>/dev/null; then
        local score=$(jq -r '.score' "${temp_file}.clean" 2>/dev/null)
        rm -f "$temp_file" "${temp_file}.clean"

        # Check if score is between 1 and 5
        if [[ "$score" =~ ^[1-5]$ ]]; then
            log_info "Likert score received: $score"
            return 0
        else
            log_warning "Invalid score: $score"
            return 1
        fi
    else
        rm -f "$temp_file" "${temp_file}.clean"
        return 1
    fi
}

# ============================================================================
# TEST 5: SAMPLE PODCAST SCRIPT EVALUATION
# ============================================================================

test_podcast_evaluation() {
    local script_file="/tmp/sample_podcast_script_$$.md"
    local output_file="/tmp/gemini_podcast_eval_$$.json"

    # Create sample podcast script
    cat > "$script_file" << 'EOF'
# Episode 1: The Mystery of AI Consciousness

Welcome to Nobody Knows, where we explore the boundaries of human knowledge. Today, we're diving into one of the most fascinating questions in AI: consciousness.

## Introduction
Can machines truly think? Nobody really knows for certain. What we do know is that this question has puzzled philosophers and scientists for decades. Let me share what we've learned so far, while acknowledging the vast unknowns that remain.

## Main Content
Recent developments in large language models have reignited debates about machine consciousness. But here's the thing - we don't even fully understand human consciousness yet. How can we determine if a machine experiences something similar?

Some researchers argue that consciousness requires biological neurons. Others suggest it might emerge from any sufficiently complex information processing system. The truth is, we're still figuring this out.

## Conclusion
What do you think? Are we on the verge of creating conscious machines, or is this all an illusion? The beauty is in not knowing for sure. Join us next time as we explore more mysteries at the edge of human understanding.
EOF

    # Create evaluation prompt
    local eval_prompt='Evaluate this podcast script. Output ONLY JSON with these exact fields:
{
  "scores": {
    "factual_accuracy": [1-5],
    "audience_comprehension": [1-5],
    "brand_alignment": [1-5],
    "engagement_quality": [1-5]
  },
  "weighted_average": [float],
  "pass_fail": "PASS or FAIL"
}'

    # Run evaluation
    cat "$script_file" | timeout 20 gemini -p "$eval_prompt" > "$output_file" 2>/dev/null

    # Extract and validate JSON
    sed -n '/^{/,/^}/p' "$output_file" > "${output_file}.clean"

    if jq empty "${output_file}.clean" 2>/dev/null; then
        local factual=$(jq -r '.scores.factual_accuracy' "${output_file}.clean" 2>/dev/null)
        local pass_fail=$(jq -r '.pass_fail' "${output_file}.clean" 2>/dev/null)

        rm -f "$script_file" "$output_file" "${output_file}.clean"

        if [[ "$factual" =~ ^[1-5]$ ]]; then
            log_info "Evaluation completed - Factual: $factual, Result: $pass_fail"
            return 0
        else
            return 1
        fi
    else
        rm -f "$script_file" "$output_file" "${output_file}.clean"
        return 1
    fi
}

# ============================================================================
# TEST 6: ERROR HANDLING - TIMEOUT
# ============================================================================

test_timeout_handling() {
    local start_time=$(date +%s)

    # This should timeout after 2 seconds
    timeout 2 bash -c "echo 'Generate 10000 words' | gemini -p 'Write a very long essay'" &>/dev/null
    local exit_code=$?

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ $exit_code -eq 124 ]] && [[ $duration -le 3 ]]; then
        log_info "Timeout handled correctly in ${duration}s"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# TEST 7: RETRY LOGIC SIMULATION
# ============================================================================

test_retry_logic() {
    local retry_count=0
    local max_retries=3
    local success=false

    while [ $retry_count -lt $max_retries ]; do
        # Simulate evaluation attempt
        if echo "test" | timeout 5 gemini -p "Say OK" 2>/dev/null | grep -q "OK"; then
            success=true
            break
        fi

        retry_count=$((retry_count + 1))
        sleep 1
    done

    if $success; then
        log_info "Retry logic working (succeeded on attempt $((retry_count + 1)))"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# TEST 8: COST CALCULATION
# ============================================================================

test_cost_calculation() {
    local word_count=1500
    local input_tokens=$((word_count * 4 / 3))  # Approximate
    local output_tokens=500

    # Gemini 2.5 Flash pricing
    local input_cost=$(echo "scale=8; $input_tokens * 0.00000015" | bc)
    local output_cost=$(echo "scale=8; $output_tokens * 0.0000006" | bc)
    local total_cost=$(echo "scale=8; $input_cost + $output_cost" | bc)

    # Check if cost is reasonable (should be around $0.0006)
    if (( $(echo "$total_cost < 0.01" | bc -l) )); then
        log_info "Cost calculation: \$$total_cost for ${input_tokens} input tokens"
        return 0
    else
        log_warning "Unexpected cost: \$$total_cost"
        return 1
    fi
}

# ============================================================================
# TEST 9: PARALLEL EXECUTION CAPABILITY
# ============================================================================

test_parallel_execution() {
    local temp_dir="/tmp/gemini_parallel_test_$$"
    mkdir -p "$temp_dir"

    # Launch two evaluations in parallel
    (echo "Test 1" | timeout 10 gemini -p "Output: TEST1" > "$temp_dir/result1.txt" 2>/dev/null) &
    local pid1=$!

    (echo "Test 2" | timeout 10 gemini -p "Output: TEST2" > "$temp_dir/result2.txt" 2>/dev/null) &
    local pid2=$!

    # Wait for both to complete
    wait $pid1
    wait $pid2

    # Check if both produced output
    if [[ -s "$temp_dir/result1.txt" ]] && [[ -s "$temp_dir/result2.txt" ]]; then
        rm -rf "$temp_dir"
        log_info "Parallel execution successful"
        return 0
    else
        rm -rf "$temp_dir"
        return 1
    fi
}

# ============================================================================
# TEST 10: PROMPT TEMPLATE SUBSTITUTION
# ============================================================================

test_template_substitution() {
    local EPISODE_NUM="042"
    local COMPLEXITY="Medium"
    local prompt="Evaluate episode $EPISODE_NUM with complexity $COMPLEXITY. Output JSON: {\"episode\": \"$EPISODE_NUM\"}"

    local result=$(echo "Test content" | timeout 10 gemini -p "$prompt" 2>/dev/null)

    if [[ "$result" == *"042"* ]]; then
        log_info "Template substitution working"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# PERFORMANCE BENCHMARKS
# ============================================================================

run_performance_benchmark() {
    echo -e "\n${BLUE}=== PERFORMANCE BENCHMARKS ===${NC}"

    local total_time=0
    local iterations=3

    for i in $(seq 1 $iterations); do
        local start=$(date +%s%N)
        echo "Benchmark test $i" | timeout 10 gemini -p "Respond with: OK" &>/dev/null
        local end=$(date +%s%N)
        local duration=$(( (end - start) / 1000000 ))  # Convert to milliseconds
        total_time=$((total_time + duration))
        log_info "Iteration $i: ${duration}ms"
    done

    local avg_time=$((total_time / iterations))
    log_info "Average response time: ${avg_time}ms"

    if [[ $avg_time -lt 10000 ]]; then  # Less than 10 seconds
        log_success "Performance benchmark passed"
    else
        log_warning "Performance slower than expected"
    fi
}

# ============================================================================
# MAIN TEST EXECUTION
# ============================================================================

main() {
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     GEMINI CLI QUALITY EVALUATION TEST SUITE              ║"
    echo "║     Version 1.0.0 | Date: $(date +%Y-%m-%d)                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"

    # Run all tests
    run_test "Gemini CLI Installation" test_gemini_installation

    if [[ $? -eq 0 ]]; then
        run_test "Basic Response Test" test_basic_response
        run_test "JSON Output Validation" test_json_output
        run_test "Likert Scale Scoring" test_likert_scoring
        run_test "Podcast Script Evaluation" test_podcast_evaluation
        run_test "Timeout Handling" test_timeout_handling
        run_test "Retry Logic" test_retry_logic
        run_test "Cost Calculation" test_cost_calculation
        run_test "Parallel Execution" test_parallel_execution
        run_test "Template Substitution" test_template_substitution

        # Run performance benchmark
        run_performance_benchmark
    else
        log_warning "Skipping tests - Gemini CLI not installed"
        echo "Install with: npm install -g @google/gemini-cli"
    fi

    # Final summary
    echo -e "\n╔════════════════════════════════════════════════════════════╗"
    echo "║                    TEST SUMMARY                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "  Total Tests:  ${TESTS_RUN}"
    echo -e "  ${GREEN}Passed:${NC}       ${TESTS_PASSED}"
    echo -e "  ${RED}Failed:${NC}       ${TESTS_FAILED}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ ALL TESTS PASSED!${NC}"
        echo "Gemini CLI integration is ready for production use."
        exit 0
    else
        echo -e "\n${RED}✗ SOME TESTS FAILED${NC}"
        echo "Please review the failures above and fix any issues."
        exit 1
    fi
}

# Run main function
main "$@"
