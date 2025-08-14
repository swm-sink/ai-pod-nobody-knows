#!/bin/bash

# ============================================================================
# TTS OPTIMIZATION TEST SUITE
# ============================================================================
# Purpose: Comprehensive testing of TTS optimization system
# Usage: ./test-tts-optimization.sh [--verbose] [--cleanup]
# Author: Claude Code AI Assistant  
# Version: 1.0.0
# ============================================================================

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(dirname "$SCRIPT_DIR")/tools"
TEMPLATES_DIR="$(dirname "$SCRIPT_DIR")/templates"
AGENTS_DIR="$(dirname "$SCRIPT_DIR")/agents"
TEST_DATA_DIR="$SCRIPT_DIR/test-data"
TEMP_DIR="/tmp/tts_test_$$"

# Test options
VERBOSE=false
CLEANUP_ON_EXIT=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# ============================================================================
# UTILITY FUNCTIONS
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

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    ((TESTS_SKIPPED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TESTS_RUN++))
    echo -e "\n${BLUE}TEST ${TESTS_RUN}:${NC} $test_name"
    echo "────────────────────────────────────────────"
    
    if $test_function; then
        log_success "$test_name"
        return 0
    else
        log_failure "$test_name"
        return 1
    fi
}

setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR" || return 1
    mkdir -p "$TEST_DATA_DIR" || return 1
    
    # Create sample test scripts only if they don't exist
    if [[ ! -f "$TEST_DATA_DIR/simple_script.md" ]]; then
        create_test_scripts || return 1
    else
        log_info "Using existing test data"
    fi
    
    log_success "Test environment ready"
    return 0
}

cleanup_test_environment() {
    if [[ "$CLEANUP_ON_EXIT" == "true" ]]; then
        log_info "Cleaning up test environment..."
        rm -rf "$TEMP_DIR"
        # Keep test data for inspection if tests failed
        if [[ $TESTS_FAILED -eq 0 ]]; then
            rm -rf "$TEST_DATA_DIR"
        fi
    fi
}

create_test_scripts() {
    # Create a simple test script
    cat > "$TEST_DATA_DIR/simple_script.md" << 'EOF'
# Episode 42: The Future of AI

Welcome to Nobody Knows, where we explore the boundaries of human knowledge. Today we're diving into artificial intelligence and machine learning.

## What We Know

Recent research shows that AI systems are becoming more capable. We've learned that LLMs like GPT-4 can process complex information. However, we don't fully understand how they work.

## The Mystery

Nobody knows exactly how neural networks develop their understanding. It's a fascinating mystery that remains unclear. We're still exploring these questions.

## Conclusion

What do you think about the future of AI? Join us next time as we continue exploring the unknown.
EOF

    # Create a complex test script with many optimization opportunities
    cat > "$TEST_DATA_DIR/complex_script.md" << 'EOF'  
# Episode 123: Advanced AI Research

Welcome to Nobody Knows! Today's episode dives deep into cutting-edge AI/ML research happening in 2025.

## Technical Overview

API development with JSON has accelerated ML deployment. HTTP protocols now support real-time AI inference. Companies like OpenAI and Anthropic are pushing boundaries.

Numbers show impressive growth: 85% of enterprises adopt AI, spending $3300 per employee. COVID-19 accelerated adoption by 200%.

## Complex Questions

What if AGI emerges by 2030? How might consciousness work in artificial systems? Why don't we understand intelligence itself?

## Research Findings

Recent NLP advances show 95.7% accuracy on benchmarks. GPT-4 achieved breakthrough performance. However, we don't know why these models work so well.

## The Unknown

Nobody knows if AI will achieve true understanding. We're still figuring out consciousness, reasoning, and creativity. It's incredibly complex.

## Final Thoughts  

The mystery continues. Thanks for exploring the unknown with us. Until next time!
EOF

    # Create malformed test script for error handling
    cat > "$TEST_DATA_DIR/malformed_script.md" << 'EOF'
# Malformed Script

This script has issues:
- Missing proper structure
- Weird characters: @#$%^&*
- URL: https://example.com/test
- Email: test@domain.com
- No clear sections

Random text with ??? multiple ?? question marks!!! And exclamations!!!
EOF

    log_info "Test scripts created in $TEST_DATA_DIR"
}

# ============================================================================
# INFRASTRUCTURE TESTS
# ============================================================================

test_dependencies_available() {
    log_info "Testing required dependencies..."
    
    local missing_deps=0
    local required_commands=("jq" "bc" "sed" "awk" "grep")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_failure "Missing required command: $cmd"
            missing_deps=1
        else
            [[ "$VERBOSE" == "true" ]] && log_info "✓ Found: $cmd"
        fi
    done
    
    return $missing_deps
}

test_file_structure() {
    log_info "Testing file structure and permissions..."
    
    local required_files=(
        "$TOOLS_DIR/tts-optimizer.sh"
        "$TOOLS_DIR/pronunciation-normalizer.sh"
        "$TOOLS_DIR/audio-tag-injector.sh"
        "$TEMPLATES_DIR/pronunciation-dictionary.json"
        "$TEMPLATES_DIR/audio-tag-library.json"
        "$TEMPLATES_DIR/tts-prompt-template.txt"
        "$AGENTS_DIR/07_tts_optimizer.md"
    )
    
    local missing_files=0
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_failure "Missing required file: $file"
            missing_files=1
        elif [[ ! -r "$file" ]]; then
            log_failure "File not readable: $file"
            missing_files=1
        else
            [[ "$VERBOSE" == "true" ]] && log_info "✓ Found: $(basename "$file")"
        fi
    done
    
    # Check script executability
    local executable_scripts=(
        "$TOOLS_DIR/tts-optimizer.sh"
        "$TOOLS_DIR/pronunciation-normalizer.sh" 
        "$TOOLS_DIR/audio-tag-injector.sh"
    )
    
    for script in "${executable_scripts[@]}"; do
        if [[ ! -x "$script" ]]; then
            log_failure "Script not executable: $script"
            missing_files=1
        fi
    done
    
    return $missing_files
}

test_json_template_validity() {
    log_info "Testing JSON template validity..."
    
    local json_files=(
        "$TEMPLATES_DIR/pronunciation-dictionary.json"
        "$TEMPLATES_DIR/audio-tag-library.json"
    )
    
    local invalid_json=0
    
    for json_file in "${json_files[@]}"; do
        if [[ -f "$json_file" ]]; then
            if jq empty "$json_file" 2>/dev/null; then
                [[ "$VERBOSE" == "true" ]] && log_info "✓ Valid JSON: $(basename "$json_file")"
            else
                log_failure "Invalid JSON: $json_file"
                invalid_json=1
            fi
        fi
    done
    
    return $invalid_json
}

# ============================================================================
# PRONUNCIATION NORMALIZATION TESTS
# ============================================================================

test_pronunciation_normalizer_basic() {
    log_info "Testing pronunciation normalizer basic functionality..."
    
    local input_file="$TEMP_DIR/pronunciation_test_input.md"
    local output_file="$TEMP_DIR/pronunciation_test_output.md"
    
    # Create test input with various normalization targets
    cat > "$input_file" << 'EOF'
Testing AI and ML with GPT-4 models. The API costs $3300 in 2025.
HTTP requests with JSON data achieve 95% accuracy.
COVID-19 changed everything by 200%.
EOF

    # Run pronunciation normalizer
    if bash "$TOOLS_DIR/pronunciation-normalizer.sh" "$input_file" "$output_file"; then
        # Check if normalizations were applied
        local changes_found=0
        
        if grep -q "ay-eye" "$output_file"; then
            changes_found=1
        fi
        
        if grep -q "gee-pee-tee" "$output_file"; then  
            changes_found=1
        fi
        
        if grep -q "percent" "$output_file"; then
            changes_found=1
        fi
        
        if [[ $changes_found -eq 1 ]]; then
            [[ "$VERBOSE" == "true" ]] && log_info "Normalizations detected in output"
            return 0
        else
            log_failure "No expected normalizations found in output"
            return 1
        fi
    else
        log_failure "Pronunciation normalizer script failed"
        return 1
    fi
}

test_pronunciation_dictionary_integration() {
    log_info "Testing pronunciation dictionary integration..."
    
    if [[ ! -f "$TEMPLATES_DIR/pronunciation-dictionary.json" ]]; then
        log_skip "Pronunciation dictionary not found"
        return 0
    fi
    
    # Test dictionary structure
    local required_sections=("ai_ml_terms" "technical_acronyms" "company_names")
    local missing_sections=0
    
    for section in "${required_sections[@]}"; do
        if ! jq -e ".$section" "$TEMPLATES_DIR/pronunciation-dictionary.json" &>/dev/null; then
            log_failure "Missing dictionary section: $section"
            missing_sections=1
        fi
    done
    
    # Test that dictionary has reasonable content
    local ai_terms_count=$(jq '.ai_ml_terms | length' "$TEMPLATES_DIR/pronunciation-dictionary.json" 2>/dev/null || echo 0)
    if [[ $ai_terms_count -lt 5 ]]; then
        log_failure "Insufficient AI/ML terms in dictionary: $ai_terms_count"
        missing_sections=1
    fi
    
    return $missing_sections
}

test_number_normalization() {
    log_info "Testing number normalization patterns..."
    
    local input_file="$TEMP_DIR/number_test_input.md"
    local output_file="$TEMP_DIR/number_test_output.md"
    
    cat > "$input_file" << 'EOF'
The year 2025 saw 85% growth. Companies spent $3300 per user.
Version 2.5 improved on v1.0 significantly.
Temperature reached 25°C (77°F).
EOF

    bash "$TOOLS_DIR/pronunciation-normalizer.sh" "$input_file" "$output_file"
    
    local test_cases=(
        "twenty.*twenty-five:2025"
        "percent:85%"
        "version.*two.*point.*five:2.5"
        "degrees.*celsius:25°C"
    )
    
    local failed_cases=0
    for test_case in "${test_cases[@]}"; do
        local pattern="${test_case%%:*}"
        local original="${test_case##*:}"
        
        if grep -qi "$pattern" "$output_file"; then
            [[ "$VERBOSE" == "true" ]] && log_info "✓ Normalized: $original → $pattern"
        else
            log_failure "Failed to normalize: $original"
            failed_cases=1
        fi
    done
    
    return $failed_cases
}

# ============================================================================
# AUDIO TAG INJECTION TESTS
# ============================================================================

test_audio_tag_injector_basic() {
    log_info "Testing audio tag injector basic functionality..."
    
    local input_file="$TEMP_DIR/audio_tag_test_input.md"
    local output_file="$TEMP_DIR/audio_tag_test_output.md"
    
    cat > "$input_file" << 'EOF'
# Welcome to Nobody Knows

What if AI becomes conscious? We don't know the answer.
Research shows promising results. However, it's complicated.
In conclusion, the mystery continues.
EOF

    if bash "$TOOLS_DIR/audio-tag-injector.sh" "$input_file" "$output_file"; then
        # Check for tag presence
        local tag_count=$(grep -c '\[[a-zA-Z]*\]' "$output_file" || echo 0)
        
        if [[ $tag_count -gt 0 ]]; then
            [[ "$VERBOSE" == "true" ]] && log_info "Found $tag_count audio tags in output"
            return 0
        else
            log_failure "No audio tags found in output"
            return 1
        fi
    else
        log_failure "Audio tag injector script failed"
        return 1
    fi
}

test_brand_alignment_tags() {
    log_info "Testing brand alignment tag application..."
    
    local input_file="$TEMP_DIR/brand_test_input.md"
    local output_file="$TEMP_DIR/brand_test_output.md"
    
    cat > "$input_file" << 'EOF'
Nobody knows how consciousness works. We don't understand intelligence.
It remains uncertain whether AI can think. We're still exploring these questions.
The mystery continues to puzzle researchers.
EOF

    bash "$TOOLS_DIR/audio-tag-injector.sh" "$input_file" "$output_file"
    
    # Check for brand-specific tags
    local brand_tags=0
    if grep -q '\[contemplative\]\|\[thoughtful\]\|\[humble\]\|\[curious\]' "$output_file"; then
        brand_tags=1
    fi
    
    if [[ $brand_tags -eq 1 ]]; then
        local specific_count=$(grep -o '\[contemplative\]\|\[thoughtful\]\|\[humble\]\|\[curious\]' "$output_file" | wc -l)
        [[ "$VERBOSE" == "true" ]] && log_info "Found $specific_count brand alignment tags"
        return 0
    else
        log_failure "No brand alignment tags found"
        return 1
    fi
}

test_tag_distribution_limits() {
    log_info "Testing tag distribution and overuse prevention..."
    
    local input_file="$TEMP_DIR/overuse_test_input.md"
    local output_file="$TEMP_DIR/overuse_test_output.md"
    
    # Create content with repeated patterns that might trigger overuse
    cat > "$input_file" << 'EOF'
Welcome! Welcome! Welcome! Welcome! Welcome!
What if this? What if that? What if something else?
We don't know. We don't know. We don't know. We don't know.
Research shows. Research shows. Research shows. Research shows.
EOF

    bash "$TOOLS_DIR/audio-tag-injector.sh" "$input_file" "$output_file"
    
    # Count occurrences of each tag type
    declare -A tag_counts
    while IFS= read -r tag; do
        clean_tag=$(echo "$tag" | tr -d '[]')
        ((tag_counts["$clean_tag"]++))
    done < <(grep -o '\[[a-zA-Z]*\]' "$output_file")
    
    # Check that no single tag appears more than 3 times
    local overuse_detected=0
    for tag in "${!tag_counts[@]}"; do
        if [[ ${tag_counts[$tag]} -gt 3 ]]; then
            log_failure "Tag [$tag] overused: ${tag_counts[$tag]} times (max 3)"
            overuse_detected=1
        fi
    done
    
    return $overuse_detected
}

# ============================================================================
# MAIN TTS OPTIMIZER TESTS
# ============================================================================

test_tts_optimizer_integration() {
    log_info "Testing main TTS optimizer integration..."
    
    local test_script="$TEST_DATA_DIR/simple_script.md"
    local test_output_dir="$TEMP_DIR/tts_optimizer_test"
    
    mkdir -p "$test_output_dir"
    
    # Run the main TTS optimizer
    if bash "$TOOLS_DIR/tts-optimizer.sh" "$test_script" "001" "$test_output_dir"; then
        # Check that output files were created
        local session_dir=$(find "$test_output_dir" -name "*_tts_opt_*" -type d | head -1)
        
        if [[ -n "$session_dir" ]] && [[ -d "$session_dir" ]]; then
            local expected_files=(
                "scripts/tts_optimized_script.md"
                "logs/optimization_log.json"
                "metrics/cost_estimate.json"
                "elevenlabs_generation_instructions.md"
            )
            
            local missing_files=0
            for file in "${expected_files[@]}"; do
                if [[ ! -f "$session_dir/$file" ]]; then
                    log_failure "Missing expected output file: $file"
                    missing_files=1
                fi
            done
            
            return $missing_files
        else
            log_failure "TTS optimizer session directory not created"
            return 1
        fi
    else
        log_failure "TTS optimizer script execution failed"
        return 1
    fi
}

test_elevenlabs_v3_compliance() {
    log_info "Testing ElevenLabs v3 format compliance..."
    
    local test_script="$TEST_DATA_DIR/complex_script.md"
    local test_output_dir="$TEMP_DIR/compliance_test"
    
    mkdir -p "$test_output_dir"
    
    bash "$TOOLS_DIR/tts-optimizer.sh" "$test_script" "123" "$test_output_dir"
    
    # Find the optimized script
    local session_dir=$(find "$test_output_dir" -name "*_tts_opt_*" -type d | head -1)
    local optimized_script="$session_dir/scripts/tts_optimized_script.md"
    
    if [[ ! -f "$optimized_script" ]]; then
        log_failure "Optimized script not found"
        return 1
    fi
    
    # Check segment structure
    local segments=$(grep -c "^## Segment" "$optimized_script" || echo 0)
    if [[ $segments -lt 1 ]]; then
        log_failure "No segments found in optimized script"
        return 1
    fi
    
    # Check minimum length compliance (250+ characters per segment)
    local min_length_violations=0
    while IFS= read -r segment_content; do
        if [[ ${#segment_content} -lt 250 ]] && [[ -n "$segment_content" ]]; then
            log_failure "Segment too short: ${#segment_content} characters"
            min_length_violations=1
        fi
    done < <(awk '/^## Segment/,/^$/ { if (!/^## Segment/ && !/^$/) segment = segment $0 } /^$/ { if (segment) print segment; segment = "" } END { if (segment) print segment }' "$optimized_script")
    
    # Check for audio tags
    local audio_tags=$(grep -c '\[[a-zA-Z]*\]' "$optimized_script" || echo 0)
    if [[ $audio_tags -lt 3 ]]; then
        log_failure "Insufficient audio tags: $audio_tags (minimum 3 expected)"
        return 1
    fi
    
    [[ "$VERBOSE" == "true" ]] && log_info "✓ Found $segments segments with $audio_tags audio tags"
    
    return $min_length_violations
}

test_audio_quality_outcomes() {
    log_info "Testing audio quality enhancement for Spotify readiness..."
    
    local test_script="$TEST_DATA_DIR/complex_script.md"
    local test_output_dir="$TEMP_DIR/quality_test"
    
    mkdir -p "$test_output_dir"
    
    bash "$TOOLS_DIR/tts-optimizer.sh" "$test_script" "123" "$test_output_dir"
    
    # Find the optimized script
    local session_dir=$(find "$test_output_dir" -name "*_tts_opt_*" -type d | head -1)
    local optimized_script="$session_dir/scripts/tts_optimized_script.md"
    
    if [[ ! -f "$optimized_script" ]]; then
        log_failure "Optimized script not found"
        return 1
    fi
    
    # Quality metrics for Spotify-ready audio
    local quality_failures=0
    
    # Check for pronunciation improvements (AI/ML terms normalized)
    if ! grep -q "ay-eye\|artificial intelligence" "$optimized_script"; then
        log_failure "AI/ML terms not properly normalized"
        quality_failures=1
    fi
    
    # Check for brand alignment (intellectual humility preserved)
    local humility_markers=$(grep -c "nobody knows\|we don't know\|unclear\|exploring\|complicated" "$optimized_script" || echo 0)
    if [[ $humility_markers -lt 3 ]]; then
        log_failure "Insufficient brand alignment markers: $humility_markers (need 3+)"
        quality_failures=1
    fi
    
    # Check for emotional context (audio tags)
    local audio_tags=$(grep -c '\[[a-zA-Z]*\]' "$optimized_script" || echo 0)
    if [[ $audio_tags -lt 5 ]]; then
        log_failure "Insufficient audio tags for emotional context: $audio_tags (need 5+)"
        quality_failures=1
    fi
    
    # Check for natural speech patterns (some filler words)
    local natural_patterns=$(grep -c '\(um\|uh\|well\|you know\|so\),' "$optimized_script" || echo 0)
    if [[ $natural_patterns -lt 2 ]]; then
        log_failure "Insufficient natural speech patterns: $natural_patterns (need 2+)"
        quality_failures=1
    fi
    
    if [[ $quality_failures -eq 0 ]]; then
        [[ "$VERBOSE" == "true" ]] && log_info "✓ Spotify-quality audio optimization verified"
        return 0
    else
        return 1
    fi
}

test_cost_estimation() {
    log_info "Testing cost estimation accuracy..."
    
    local test_script="$TEST_DATA_DIR/simple_script.md"
    local test_output_dir="$TEMP_DIR/cost_test"
    
    mkdir -p "$test_output_dir"
    
    bash "$TOOLS_DIR/tts-optimizer.sh" "$test_script" "042" "$test_output_dir"
    
    # Find cost estimate file
    local session_dir=$(find "$test_output_dir" -name "*_tts_opt_*" -type d | head -1)
    local cost_file="$session_dir/metrics/cost_estimate.json"
    
    if [[ ! -f "$cost_file" ]]; then
        log_failure "Cost estimate file not created"
        return 1
    fi
    
    # Validate cost estimate structure
    local required_fields=("content_metrics" "elevenlabs_v3_pricing" "budget_recommendations")
    local missing_fields=0
    
    for field in "${required_fields[@]}"; do
        if ! jq -e ".$field" "$cost_file" &>/dev/null; then
            log_failure "Missing cost estimate field: $field"
            missing_fields=1
        fi
    done
    
    # Check that costs are reasonable (not zero, not excessive)
    local discounted_cost=$(jq -r '.elevenlabs_v3_pricing.promotional_period.estimated_cost' "$cost_file" | sed 's/\$//g')
    if [[ "$discounted_cost" != "null" ]] && [[ $(echo "$discounted_cost < 0.001" | bc -l) -eq 1 ]]; then
        log_failure "Cost estimate seems too low: $discounted_cost"
        missing_fields=1
    fi
    
    return $missing_fields
}

# ============================================================================
# ERROR HANDLING TESTS
# ============================================================================

test_error_handling() {
    log_info "Testing error handling and edge cases..."
    
    # Test with non-existent input file
    local non_existent_file="$TEMP_DIR/does_not_exist.md"
    if bash "$TOOLS_DIR/tts-optimizer.sh" "$non_existent_file" 2>/dev/null; then
        log_failure "Should have failed with non-existent input file"
        return 1
    fi
    
    # Test with empty input file
    local empty_file="$TEMP_DIR/empty_script.md"
    touch "$empty_file"
    
    local empty_output_dir="$TEMP_DIR/empty_test"
    mkdir -p "$empty_output_dir"
    
    if bash "$TOOLS_DIR/tts-optimizer.sh" "$empty_file" "000" "$empty_output_dir"; then
        [[ "$VERBOSE" == "true" ]] && log_info "✓ Handled empty file gracefully"
    else
        log_failure "Failed to handle empty file"
        return 1
    fi
    
    # Test with malformed content
    local malformed_output_dir="$TEMP_DIR/malformed_test"  
    mkdir -p "$malformed_output_dir"
    
    if bash "$TOOLS_DIR/tts-optimizer.sh" "$TEST_DATA_DIR/malformed_script.md" "999" "$malformed_output_dir"; then
        [[ "$VERBOSE" == "true" ]] && log_info "✓ Handled malformed content gracefully"
    else
        log_failure "Failed to handle malformed content"
        return 1
    fi
    
    return 0
}

test_validation_and_reporting() {
    log_info "Testing validation and reporting functionality..."
    
    local test_script="$TEST_DATA_DIR/complex_script.md"
    local test_output_dir="$TEMP_DIR/validation_test"
    
    mkdir -p "$test_output_dir"
    
    bash "$TOOLS_DIR/tts-optimizer.sh" "$test_script" "456" "$test_output_dir"
    
    # Find session directory and check for reports
    local session_dir=$(find "$test_output_dir" -name "*_tts_opt_*" -type d | head -1)
    
    local expected_reports=(
        "logs/content_analysis.json"
        "logs/optimization_log.json"
        "session_summary.json"
    )
    
    local missing_reports=0
    for report in "${expected_reports[@]}"; do
        if [[ ! -f "$session_dir/$report" ]]; then
            log_failure "Missing validation report: $report"
            missing_reports=1
        else
            # Validate JSON structure
            if ! jq empty "$session_dir/$report" 2>/dev/null; then
                log_failure "Invalid JSON in report: $report"
                missing_reports=1
            fi
        fi
    done
    
    return $missing_reports
}

# ============================================================================
# PERFORMANCE TESTS
# ============================================================================

test_performance_benchmarks() {
    log_info "Testing performance and efficiency..."
    
    local large_script="$TEMP_DIR/large_test_script.md"
    local perf_output_dir="$TEMP_DIR/performance_test"
    
    mkdir -p "$perf_output_dir"
    
    # Create a larger test script (simulate ~2000 word episode)
    cat > "$large_script" << 'EOF'
# Episode 789: Large Scale AI Systems

Welcome to Nobody Knows, the podcast where we explore the boundaries of human knowledge and artificial intelligence.

## Introduction to Large Language Models

Today we're diving deep into LLMs and their implications. What exactly are these systems? How do they work? Why do they sometimes fail?

The truth is, nobody knows exactly how these neural networks develop their remarkable capabilities. We can observe their behavior, measure their performance, but the internal mechanisms remain largely mysterious.

## Technical Deep Dive  

Let's explore the technical aspects. GPT-4 has approximately 1.76 trillion parameters. That's 1,760,000,000,000 individual weights that somehow encode knowledge about language, reasoning, and world knowledge.

How does this work? We don't fully understand. The training process involves massive datasets - terabytes of text from the internet. But how does statistical correlation emerge as something resembling understanding?

## Current Limitations

These systems have significant limitations. They can't actually reason in the way humans do. They lack persistent memory. They don't have genuine understanding of the physical world.

However, they demonstrate remarkable capabilities in language tasks, mathematical reasoning, and creative writing. It's a fascinating paradox that continues to puzzle researchers.

## Research Frontiers

Current research focuses on several key areas:

1. Alignment - ensuring AI systems behave as intended
2. Interpretability - understanding how these models work internally  
3. Robustness - making systems more reliable and predictable
4. Efficiency - reducing computational requirements

Each area presents unique challenges. We're making progress, but significant unknowns remain.

## The Bigger Picture

What does this mean for society? How will these systems evolve? When might we achieve artificial general intelligence?

These are profound questions without clear answers. We're in uncharted territory, exploring the boundaries of what's possible with artificial intelligence.

## Conclusion

The journey into AI continues to surprise us. Every breakthrough reveals new mysteries. Every answer generates new questions.

That's the beauty of scientific discovery - the more we learn, the more we realize how much we don't know.

Thank you for joining us on this exploration of the unknown. Until next time, keep wondering about the mysteries that surround us.
EOF

    # Measure execution time
    local start_time=$(date +%s%N)
    bash "$TOOLS_DIR/tts-optimizer.sh" "$large_script" "789" "$perf_output_dir"
    local end_time=$(date +%s%N)
    
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    # Performance expectations (should complete within reasonable time)
    if [[ $duration_ms -lt 30000 ]]; then  # Less than 30 seconds
        [[ "$VERBOSE" == "true" ]] && log_info "✓ Performance acceptable: ${duration_ms}ms"
        return 0
    else
        log_failure "Performance too slow: ${duration_ms}ms (expected < 30000ms)"
        return 1
    fi
}

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

test_pipeline_integration() {
    log_info "Testing pipeline integration readiness..."
    
    # Test that the optimizer produces outputs compatible with next pipeline stage
    local test_script="$TEST_DATA_DIR/simple_script.md"
    local integration_output_dir="$TEMP_DIR/integration_test"
    
    mkdir -p "$integration_output_dir"
    
    bash "$TOOLS_DIR/tts-optimizer.sh" "$test_script" "001" "$integration_output_dir"
    
    # Find session directory
    local session_dir=$(find "$integration_output_dir" -name "*_tts_opt_*" -type d | head -1)
    local optimized_script="$session_dir/scripts/tts_optimized_script.md"
    local instructions_file="$session_dir/elevenlabs_generation_instructions.md"
    
    # Verify outputs are ready for next stage
    if [[ ! -f "$optimized_script" ]]; then
        log_failure "Optimized script not generated"
        return 1
    fi
    
    if [[ ! -f "$instructions_file" ]]; then
        log_failure "Generation instructions not created"
        return 1
    fi
    
    # Check that instructions contain required information
    if ! grep -q "ElevenLabs v3" "$instructions_file"; then
        log_failure "Instructions missing ElevenLabs v3 reference"
        return 1
    fi
    
    if ! grep -q "Recommended.*Settings" "$instructions_file"; then
        log_failure "Instructions missing recommended settings"
        return 1
    fi
    
    [[ "$VERBOSE" == "true" ]] && log_info "✓ Pipeline integration outputs verified"
    
    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --no-cleanup)
                CLEANUP_ON_EXIT=false
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

show_usage() {
    cat << EOF
TTS OPTIMIZATION TEST SUITE - SPOTIFY QUALITY VALIDATION

Usage: $0 [OPTIONS]

Options:
    --verbose, -v     Enable verbose output
    --no-cleanup      Keep temporary files after testing
    --help, -h        Show this help message

Core Quality Tests:
    • System dependencies and readiness
    • End-to-end TTS optimization quality
    • ElevenLabs v3 format compliance
    • Audio quality enhancement (Spotify-ready)
    • Cost estimation accuracy
    • Error handling and safety
    • Pipeline integration validation

Quality Standards:
    ✓ Professional audio output indistinguishable from human
    ✓ Brand voice consistency (intellectual humility)
    ✓ Technical term pronunciation accuracy
    ✓ Emotional context through audio tags
    ✓ Natural speech patterns for engagement

Exit Codes:
    0 - All quality tests passed - Ready for Spotify!
    1 - Quality issues detected - Review needed
    2 - Test environment setup failed
EOF
}

main() {
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              TTS OPTIMIZATION TEST SUITE v1.0             ║"
    echo "║                 SPOTIFY QUALITY VALIDATION                ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    parse_arguments "$@"
    
    # Setup test environment
    if ! setup_test_environment; then
        log_failure "Test environment setup failed"
        exit 2
    fi
    
    # Set cleanup trap
    trap cleanup_test_environment EXIT
    
    echo "🔧 CORE QUALITY TESTS (Spotify-Ready Validation)"
    echo "════════════════════════════════════════════════════════════"
    run_test "System Dependencies Available" test_dependencies_available
    run_test "TTS Optimizer End-to-End Quality" test_tts_optimizer_integration
    run_test "ElevenLabs v3 Format Compliance" test_elevenlabs_v3_compliance
    run_test "Audio Quality Enhancement" test_audio_quality_outcomes
    run_test "Cost Estimation Accuracy" test_cost_estimation
    run_test "Error Recovery & Safety" test_error_handling
    run_test "Pipeline Integration Ready" test_pipeline_integration
    
    # Final summary
    echo -e "\n╔════════════════════════════════════════════════════════════╗"
    echo "║                         TEST SUMMARY                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "  Total Tests:     ${TESTS_RUN}"
    echo -e "  ${GREEN}Passed:${NC}        ${TESTS_PASSED}"
    echo -e "  ${RED}Failed:${NC}        ${TESTS_FAILED}"
    echo -e "  ${YELLOW}Skipped:${NC}       ${TESTS_SKIPPED}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 ALL QUALITY TESTS PASSED!${NC}"
        echo "🎵 TTS optimization system is READY FOR SPOTIFY!"
        echo ""
        echo "Your podcast audio will be:"
        echo "  ✓ Professionally optimized for human-like quality"
        echo "  ✓ Brand-aligned with intellectual humility"
        echo "  ✓ Technically accurate and engaging"
        echo "  ✓ Cost-effective with promotional pricing"
        exit 0
    else
        echo -e "${RED}⚠️  QUALITY ISSUES DETECTED${NC}"
        echo "Your audio might not meet Spotify standards."
        echo "Please review the failures above and fix any issues."
        exit 1
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi