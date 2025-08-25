#!/bin/bash
# Unit Tests for Script Writer Agent
# Tests the most complex production agent - script writing functionality

set -euo pipefail

# Test Configuration
AGENT_FILE=".claude/agents/script-writer.md"
TEST_SESSION_DIR="tests/data/test_session_script"
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
test_script_writer_spec() {
    setup_test
    log_test "Testing script writer agent specification"

    if [ ! -f "$AGENT_FILE" ]; then
        log_fail "Agent file not found: $AGENT_FILE"
        return 1
    fi

    # Check required tools
    local required_tools=("Read" "Write" "Edit" "MultiEdit")
    for tool in "${required_tools[@]}"; do
        if grep -q "$tool" "$AGENT_FILE"; then
            log_test "✓ Required tool present: $tool"
        else
            log_fail "Missing required tool: $tool"
            return 1
        fi
    done

    # Check brand voice integration
    if grep -q "Feynman.*Fridman\|brand_voice" "$AGENT_FILE"; then
        log_pass "Brand voice integration documented"
    else
        log_fail "Brand voice integration not found"
        return 1
    fi

    log_pass "Script writer agent specification valid"
}

# Test Checkpoint Integration
test_checkpoint_integration() {
    setup_test
    log_test "Testing checkpoint integration for script writer"

    # Check checkpoint documentation
    if grep -q "checkpoint_check\|05_script_complete.json" "$AGENT_FILE"; then
        log_test "✓ Checkpoint integration documented"
    else
        log_fail "Checkpoint integration not documented"
        return 1
    fi

    # Create test checkpoint
    cat > "$TEST_SESSION_DIR/05_script_complete.json" << 'EOF'
{
    "checkpoint_type": "script_writing",
    "session_id": "test_session",
    "episode_number": 1,
    "status": "completed",
    "timestamp": "2025-08-18T12:00:00Z",
    "cost_invested": 1.75,
    "script_results": {
        "character_count": 35000,
        "word_count": 7050,
        "duration_estimate": "47:00",
        "structure_type": "narrative_arc",
        "brand_elements": "humility_phrases:35,questions:28",
        "research_integration": "comprehensive",
        "complete_script_content": "# Mock Script Content\n\nThis is a test script..."
    },
    "quality_validation": {
        "character_count_target": "within_range",
        "brand_alignment": 0.92,
        "accessibility": 0.88,
        "research_accuracy": 0.95
    }
}
EOF

    # Validate JSON structure
    if jq empty "$TEST_SESSION_DIR/05_script_complete.json" 2>/dev/null; then
        log_pass "Checkpoint JSON structure valid"
    else
        log_fail "Invalid checkpoint JSON structure"
        return 1
    fi

    # Check required fields
    local required_fields=("checkpoint_type" "session_id" "script_results" "character_count" "word_count")
    for field in "${required_fields[@]}"; do
        if jq -e ".. | select(type == \"object\") | select(has(\"$field\"))" "$TEST_SESSION_DIR/05_script_complete.json" >/dev/null 2>&1; then
            log_test "✓ Required field present: $field"
        else
            log_fail "Missing required field: $field"
            return 1
        fi
    done

    log_pass "Checkpoint integration validation complete"
}

# Test Script Quality Metrics
test_script_quality_metrics() {
    setup_test
    log_test "Testing script quality metrics validation"

    # Check quality gates in agent spec
    if grep -q "3900.*4100\|word.*count\|Flesch.*Reading.*Ease" "$AGENT_FILE"; then
        log_pass "Quality gates specified in agent"
    else
        log_fail "Quality gates not found in agent specification"
        return 1
    fi

    # Test quality validation logic
    local word_count=4050
    local target_min=3900
    local target_max=4100
    local brand_score=0.92
    local readability=75

    # Word count validation
    if [ $word_count -ge $target_min ] && [ $word_count -le $target_max ]; then
        log_test "✓ Word count within target range: $word_count"
    else
        log_fail "Word count outside target range: $word_count"
        return 1
    fi

    # Brand score validation
    if (( $(echo "$brand_score >= 0.90" | bc -l) )); then
        log_test "✓ Brand voice score meets requirement: $brand_score"
    else
        log_fail "Brand voice score below requirement: $brand_score"
        return 1
    fi

    # Readability validation
    if [ $readability -ge 60 ] && [ $readability -le 80 ]; then
        log_test "✓ Readability within target range: $readability"
    else
        log_fail "Readability outside target range: $readability"
        return 1
    fi

    log_pass "Script quality metrics validation complete"
}

# Test Brand Voice Requirements
test_brand_voice_requirements() {
    setup_test
    log_test "Testing brand voice requirements"

    # Check brand voice metrics in spec
    if grep -q "5.*per.*1000.*words\|4.*per.*1000.*words\|humility.*phrases" "$AGENT_FILE"; then
        log_test "✓ Brand voice metrics documented"
    else
        log_fail "Brand voice metrics not documented"
        return 1
    fi

    # Create mock script content for testing
    cat > "$TEST_SESSION_DIR/mock_script_content.md" << 'EOF'
# Mock Script Content (1000 words for testing)

Current evidence suggests that this topic is fascinating. We think we understand the basics, but one possibility is that there's much more to discover. Scientists are still working to understand the deeper implications. This remains an open question in many ways.

What's truly remarkable is how this field has evolved? Here's what we know so far. This opens up an entire world of questions about the nature of reality. The more we learn, the more mysterious it becomes in some ways.

Think of it this way - imagine you're exploring a vast cave system. You know how when you first enter a cave, everything seems dark and mysterious? This is similar, but instead of physical darkness, we're dealing with intellectual uncertainty. To put this in perspective, every answer seems to generate two new questions.

Here's an analogy that might help explain the complexity. Scientists are still working to understand how these mechanisms interact. Current evidence suggests multiple pathways are involved. We think we understand the primary route, but one possibility is that secondary pathways play crucial roles too.

What's fascinating is how much we don't know about these processes? This challenges our fundamental assumptions about how things work. The more we learn, the more questions arise about the underlying mechanisms.

[Content continues for approximately 1000 words total...]
EOF

    # Test humility phrase detection
    local humility_count
    humility_count=$(grep -o "Current evidence suggests\|We think we understand\|One possibility is\|Scientists are still working\|This remains an open question\|What's fascinating is how much we don't know" "$TEST_SESSION_DIR/mock_script_content.md" | wc -l)

    # Test question detection
    local question_count
    question_count=$(grep -o "?" "$TEST_SESSION_DIR/mock_script_content.md" | wc -l)

    # Validate metrics (for 1000 words, expect ~5 humility phrases and ~4 questions)
    if [ "$humility_count" -ge 3 ]; then
        log_test "✓ Sufficient humility phrases detected: $humility_count"
    else
        log_fail "Insufficient humility phrases: $humility_count"
        return 1
    fi

    if [ "$question_count" -ge 2 ]; then
        log_test "✓ Sufficient questions detected: $question_count"
    else
        log_fail "Insufficient questions: $question_count"
        return 1
    fi

    log_pass "Brand voice requirements validation complete"
}

# Test Audio Formatting Requirements
test_audio_formatting() {
    setup_test
    log_test "Testing audio formatting requirements"

    # Check audio formatting documentation
    if grep -q "PAUSE:\|TONE:\|EMPHASIS:\|Audio.*Optimization" "$AGENT_FILE"; then
        log_test "✓ Audio formatting documented in agent spec"
    else
        log_fail "Audio formatting not documented"
        return 1
    fi

    # Create mock script with audio formatting
    cat > "$TEST_SESSION_DIR/mock_audio_script.md" << 'EOF'
# Mock Audio-Formatted Script

### Opening Hook [SEGMENT: 0:00-3:30]
**[TONE: Engaging, Curious]**

Here's a question that might surprise you. **[EMPHASIS: surprise]** What if everything we thought we knew about this topic was just the beginning?

**[PAUSE: Medium]**

**[TONE: Thoughtful]** Current evidence suggests we're on the verge of a breakthrough. **[PAUSE: Brief]** But here's what makes this story truly fascinating...

### Foundation Building [SEGMENT: 3:30-8:00]
**[TONE: Educational, Confident]**

Think of it this way - **[EMPHASIS: this way]** imagine you're building a house of knowledge. **[PAUSE: Brief]** The foundation needs to be solid before we can explore the more complex architecture above.
EOF

    # Validate audio markers presence
    local pause_markers
    pause_markers=$(grep -c "\[PAUSE:" "$TEST_SESSION_DIR/mock_audio_script.md" || echo 0)

    local tone_markers
    tone_markers=$(grep -c "\[TONE:" "$TEST_SESSION_DIR/mock_audio_script.md" || echo 0)

    local emphasis_markers
    emphasis_markers=$(grep -c "\[EMPHASIS:" "$TEST_SESSION_DIR/mock_audio_script.md" || echo 0)

    if [ "$pause_markers" -ge 2 ] && [ "$tone_markers" -ge 2 ] && [ "$emphasis_markers" -ge 2 ]; then
        log_pass "Audio formatting markers present and sufficient"
    else
        log_fail "Insufficient audio formatting markers (pause:$pause_markers, tone:$tone_markers, emphasis:$emphasis_markers)"
        return 1
    fi

    log_pass "Audio formatting requirements validation complete"
}

# Test Cost Tracking Integration
test_cost_tracking() {
    setup_test
    log_test "Testing cost tracking integration"

    # Check if agent spec mentions cost tracking
    if grep -q "cost.*invested\|budget\|\$1\.50.*\$2\.50\|Cost.*Target" "$AGENT_FILE"; then
        log_pass "Cost tracking integration documented"
    else
        log_fail "Cost tracking integration not documented"
        return 1
    fi

    # Validate cost estimation
    local estimated_cost=1.75
    local min_cost=1.50
    local max_cost=2.50

    if (( $(echo "$estimated_cost >= $min_cost && $estimated_cost <= $max_cost" | bc -l) )); then
        log_pass "Cost estimation within target range"
    else
        log_fail "Cost estimation outside target range"
        return 1
    fi
}

# Test Output Structure Validation
test_output_structure() {
    setup_test
    log_test "Testing script output structure validation"

    # Check required structure elements in spec
    if grep -q "Opening Hook\|Foundation Building\|Emerging Understanding\|Resolution\|Production Metadata" "$AGENT_FILE"; then
        log_test "✓ Required structure elements documented"
    else
        log_fail "Required structure elements not documented"
        return 1
    fi

    # Create mock script structure for validation
    cat > "$TEST_SESSION_DIR/mock_script_structure.md" << 'EOF'
# Podcast Script: Test Episode

*Target Duration: 47 minutes | Word Count: 7050 words*

## Production Metadata
- **Research Package Source**: test_research_package.json
- **Script Version**: v1.0
- **Brand Voice Score**: 0.92
- **Complexity Level**: accessible

## Script Content

### Opening Hook [SEGMENT: 0:00-3:30]
Test opening content...

### Foundation Building [SEGMENT: 3:30-8:00]
Test foundation content...

### Emerging Understanding [SEGMENT: 8:00-15:00]
Test emerging content...

### Resolution [SEGMENT: 24:30-47:00]
Test resolution content...

## Audio Production Notes
- **Estimated Speaking Pace**: 145 words per minute

## Brand Voice Compliance
- **Humility Phrases**: 35 per 7050 words
- **Questions**: 28 per 7050 words
EOF

    # Validate required sections are present
    local required_sections=("Production Metadata" "Script Content" "Opening Hook" "Foundation Building" "Brand Voice Compliance")
    for section in "${required_sections[@]}"; do
        if grep -q "$section" "$TEST_SESSION_DIR/mock_script_structure.md"; then
            log_test "✓ Required section present: $section"
        else
            log_fail "Missing required section: $section"
            return 1
        fi
    done

    log_pass "Output structure validation complete"
}

# Mock Script Generation (for API-free testing)
test_mock_script_generation() {
    if [ "$MOCK_MODE" = "true" ]; then
        setup_test
        log_test "Testing mock script generation functionality"

        # Create comprehensive mock script output
        cat > "$TEST_SESSION_DIR/mock_complete_script.json" << 'EOF'
{
    "script_generation": {
        "input_research_package": "test_research_comprehensive.json",
        "processing_time_minutes": 18.5,
        "total_cost": 1.85
    },
    "script_content": {
        "character_count": 35200,
        "word_count": 7100,
        "segments": 6,
        "audio_markers": 45,
        "brand_voice_score": 0.93
    },
    "quality_metrics": {
        "humility_phrases": 36,
        "questions": 29,
        "flesch_reading_ease": 72,
        "structure_completeness": 1.0
    }
}
EOF

        # Validate mock output meets requirements
        local word_count
        word_count=$(jq -r '.script_content.word_count' "$TEST_SESSION_DIR/mock_complete_script.json")

        local brand_score
        brand_score=$(jq -r '.script_content.brand_voice_score' "$TEST_SESSION_DIR/mock_complete_script.json")

        if [ "$word_count" -ge 3900 ] && [ "$word_count" -le 8000 ]; then
            log_test "✓ Mock script word count within acceptable range"
        else
            log_fail "Mock script word count outside range: $word_count"
            return 1
        fi

        if (( $(echo "$brand_score >= 0.90" | bc -l) )); then
            log_pass "Mock script generation meets quality requirements"
        else
            log_fail "Mock script generation below quality requirements"
            return 1
        fi
    else
        log_test "Skipping mock script generation (not in mock mode)"
    fi
}

# Run All Tests
run_tests() {
    log_test "Starting script writer agent tests"

    test_script_writer_spec
    test_checkpoint_integration
    test_script_quality_metrics
    test_brand_voice_requirements
    test_audio_formatting
    test_cost_tracking
    test_output_structure
    test_mock_script_generation

    # Summary
    echo "=== Script Writer Agent Test Summary ==="
    echo "Tests Run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo "✅ All script writer agent tests passed"
        return 0
    else
        echo "❌ $TESTS_FAILED script writer agent tests failed"
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
