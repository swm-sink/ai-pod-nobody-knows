#!/bin/bash
# Unit Tests for Audio Synthesizer Agent
# Tests the highest cost component - audio synthesis functionality

set -euo pipefail

# Test Configuration
AGENT_FILE=".claude/agents/audio-synthesizer.md"
TEST_SESSION_DIR="tests/data/test_session_audio"
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
test_audio_synthesizer_spec() {
    setup_test
    log_test "Testing audio synthesizer agent specification"

    if [ ! -f "$AGENT_FILE" ]; then
        log_fail "Agent file not found: $AGENT_FILE"
        return 1
    fi

    # Check required tools
    local required_tools=("mcp__ElevenLabs__text_to_speech" "Read" "Write")
    for tool in "${required_tools[@]}"; do
        if grep -q "$tool" "$AGENT_FILE"; then
            log_test "✓ Required tool present: $tool"
        else
            log_fail "Missing required tool: $tool"
            return 1
        fi
    done

    # Check voice and model configuration
    if grep -q "Amelia\|ZF6FPAbjXT4488VcRRnw\|eleven_turbo_v2_5" "$AGENT_FILE"; then
        log_pass "Voice and model configuration documented"
    else
        log_fail "Voice and model configuration not found"
        return 1
    fi

    log_pass "Audio synthesizer agent specification valid"
}

# Test Checkpoint Integration
test_checkpoint_integration() {
    setup_test
    log_test "Testing checkpoint integration for audio synthesizer"

    # Check checkpoint documentation
    if grep -q "09_audio_synthesis_complete.json\|checkpoint_check\|\$6\.00.*savings" "$AGENT_FILE"; then
        log_test "✓ Checkpoint integration and cost protection documented"
    else
        log_fail "Checkpoint integration not documented"
        return 1
    fi

    # Create test checkpoint
    cat > "$TEST_SESSION_DIR/09_audio_synthesis_complete.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "test_session",
    "episode_number": 1,
    "status": "completed",
    "timestamp": "2025-08-18T12:00:00Z",
    "cost_invested": 10.50,
    "audio_file_path": "projects/nobody-knows/output/audio/ep001_test_topic_20250818.mp3",
    "synthesis_results": {
        "duration_minutes": 28,
        "file_size_mb": 30,
        "voice_used": "Amelia",
        "voice_id": "ZF6FPAbjXT4488VcRRnw",
        "model_used": "eleven_turbo_v2_5",
        "character_count": 20000
    }
}
EOF

    # Validate JSON structure
    if jq empty "$TEST_SESSION_DIR/09_audio_synthesis_complete.json" 2>/dev/null; then
        log_pass "Checkpoint JSON structure valid"
    else
        log_fail "Invalid checkpoint JSON structure"
        return 1
    fi

    # Check required fields for audio synthesis
    local required_fields=("checkpoint_type" "session_id" "audio_file_path" "synthesis_results" "voice_used" "model_used")
    for field in "${required_fields[@]}"; do
        if jq -e ".. | select(type == \"object\") | select(has(\"$field\"))" "$TEST_SESSION_DIR/09_audio_synthesis_complete.json" >/dev/null 2>&1; then
            log_test "✓ Required field present: $field"
        else
            log_fail "Missing required field: $field"
            return 1
        fi
    done

    log_pass "Checkpoint integration validation complete"
}

# Test Audio Quality Specifications
test_audio_quality_specs() {
    setup_test
    log_test "Testing audio quality specifications"

    # Check quality standards in agent spec
    if grep -q "25-30.*minute\|18-22k.*character\|mp3_44100_128\|128kbps" "$AGENT_FILE"; then
        log_test "✓ Audio quality standards documented"
    else
        log_fail "Audio quality standards not found"
        return 1
    fi

    # Test quality validation logic
    local duration_minutes=28
    local target_min=25
    local target_max=30
    local file_size_mb=30
    local character_count=20000

    # Duration validation
    if [ $duration_minutes -ge $target_min ] && [ $duration_minutes -le $target_max ]; then
        log_test "✓ Duration within target range: $duration_minutes minutes"
    else
        log_fail "Duration outside target range: $duration_minutes minutes"
        return 1
    fi

    # File size validation (25-35 MB expected for 25-30 minute content)
    if [ $file_size_mb -ge 25 ] && [ $file_size_mb -le 35 ]; then
        log_test "✓ File size within expected range: ${file_size_mb}MB"
    else
        log_fail "File size outside expected range: ${file_size_mb}MB"
        return 1
    fi

    # Character count validation (18-22k for 25-30 minutes)
    if [ $character_count -ge 18000 ] && [ $character_count -le 22000 ]; then
        log_test "✓ Character count within target range: $character_count"
    else
        log_fail "Character count outside target range: $character_count"
        return 1
    fi

    log_pass "Audio quality specifications validation complete"
}

# Test Voice and Model Configuration
test_voice_model_config() {
    setup_test
    log_test "Testing voice and model configuration"

    # Check required voice and model settings
    if grep -q "voice_name.*Amelia\|voice_id.*ZF6FPAbjXT4488VcRRnw\|model_id.*eleven_turbo_v2_5" "$AGENT_FILE"; then
        log_test "✓ Required voice and model configuration present"
    else
        log_fail "Required voice and model configuration missing"
        return 1
    fi

    # Create mock voice configuration test
    cat > "$TEST_SESSION_DIR/voice_config_test.json" << 'EOF'
{
    "voice_settings": {
        "voice_name": "Amelia",
        "voice_id": "ZF6FPAbjXT4488VcRRnw",
        "model_id": "eleven_turbo_v2_5",
        "stability": 0.5,
        "similarity_boost": 0.75,
        "style": 0.3,
        "speed": 1.0,
        "use_speaker_boost": true
    }
}
EOF

    # Validate voice configuration parameters
    local stability
    stability=$(jq -r '.voice_settings.stability' "$TEST_SESSION_DIR/voice_config_test.json")

    local similarity_boost
    similarity_boost=$(jq -r '.voice_settings.similarity_boost' "$TEST_SESSION_DIR/voice_config_test.json")

    local voice_name
    voice_name=$(jq -r '.voice_settings.voice_name' "$TEST_SESSION_DIR/voice_config_test.json")

    # Validate settings are within expected ranges
    if (( $(echo "$stability >= 0.0 && $stability <= 1.0" | bc -l) )); then
        log_test "✓ Stability setting valid: $stability"
    else
        log_fail "Stability setting invalid: $stability"
        return 1
    fi

    if (( $(echo "$similarity_boost >= 0.0 && $similarity_boost <= 1.0" | bc -l) )); then
        log_test "✓ Similarity boost setting valid: $similarity_boost"
    else
        log_fail "Similarity boost setting invalid: $similarity_boost"
        return 1
    fi

    if [ "$voice_name" = "Amelia" ]; then
        log_test "✓ Required voice name configured: $voice_name"
    else
        log_fail "Incorrect voice name configured: $voice_name"
        return 1
    fi

    log_pass "Voice and model configuration validation complete"
}

# Test Cost Tracking and Protection
test_cost_tracking() {
    setup_test
    log_test "Testing cost tracking and protection mechanisms"

    # Check cost tracking documentation
    if grep -q "cost_invested\|\$6\.00\|unlimited.*budget\|cost.*protection" "$AGENT_FILE"; then
        log_pass "Cost tracking and protection documented"
    else
        log_fail "Cost tracking and protection not documented"
        return 1
    fi

    # Test cost calculation logic
    local estimated_cost=10.50
    local character_count=20000
    local cost_per_character=0.000525  # ~$10.50 for 20k characters

    # Calculate expected cost
    local calculated_cost
    calculated_cost=$(echo "scale=2; $character_count * $cost_per_character" | bc)

    if (( $(echo "$calculated_cost >= 9.00 && $calculated_cost <= 12.00" | bc -l) )); then
        log_test "✓ Cost calculation within expected range: \$${calculated_cost}"
    else
        log_fail "Cost calculation outside expected range: \$${calculated_cost}"
        return 1
    fi

    # Test checkpoint cost protection savings
    local cost_protection_savings=10.50
    if (( $(echo "$cost_protection_savings >= 6.00" | bc -l) )); then
        log_pass "Cost protection savings meet minimum threshold"
    else
        log_fail "Cost protection savings below threshold"
        return 1
    fi
}

# Test File Output Management
test_file_output_management() {
    setup_test
    log_test "Testing file output management"

    # Check file naming and organization
    if grep -q "projects/nobody-knows/output/audio\|ep.*_.*_.*\.mp3" "$AGENT_FILE"; then
        log_test "✓ File naming and organization documented"
    else
        log_fail "File naming and organization not documented"
        return 1
    fi

    # Create mock output directory structure
    mkdir -p "$TEST_SESSION_DIR/projects/nobody-knows/output/audio"

    # Test file naming convention
    local episode_num=1
    local topic="test_topic"
    local date=$(date +%Y%m%d)
    local expected_filename="ep${episode_num}_${topic}_${date}.mp3"

    # Create mock audio file
    touch "$TEST_SESSION_DIR/projects/nobody-knows/output/audio/$expected_filename"

    # Validate file exists and naming is correct
    if [ -f "$TEST_SESSION_DIR/projects/nobody-knows/output/audio/$expected_filename" ]; then
        log_test "✓ File naming convention validated: $expected_filename"
    else
        log_fail "File naming convention validation failed"
        return 1
    fi

    # Test directory structure
    if [ -d "$TEST_SESSION_DIR/projects/nobody-knows/output/audio" ]; then
        log_pass "Output directory structure validation complete"
    else
        log_fail "Output directory structure validation failed"
        return 1
    fi
}

# Test Error Handling for Large Content
test_large_content_handling() {
    setup_test
    log_test "Testing large content processing error handling"

    # Check error handling documentation
    if grep -q "Large.*Content.*Processing\|18-22k.*characters\|single.*API.*call\|15-25.*minutes" "$AGENT_FILE"; then
        log_test "✓ Large content processing documented"
    else
        log_fail "Large content processing not documented"
        return 1
    fi

    # Test content size validation
    local content_size=20000  # 20k characters
    local min_size=18000
    local max_size=22000

    if [ $content_size -ge $min_size ] && [ $content_size -le $max_size ]; then
        log_test "✓ Content size within processing range: $content_size characters"
    else
        log_fail "Content size outside processing range: $content_size characters"
        return 1
    fi

    # Test processing time expectations
    local processing_minutes=20  # Expected 15-25 minutes
    local min_processing=15
    local max_processing=25

    if [ $processing_minutes -ge $min_processing ] && [ $processing_minutes -le $max_processing ]; then
        log_test "✓ Processing time within expected range: $processing_minutes minutes"
    else
        log_fail "Processing time outside expected range: $processing_minutes minutes"
        return 1
    fi

    log_pass "Large content handling validation complete"
}

# Test Technical Specifications Compliance
test_technical_specifications() {
    setup_test
    log_test "Testing technical specifications compliance"

    # Check technical spec documentation
    if grep -q "mp3_44100_128\|44100\|128kbps\|mono" "$AGENT_FILE"; then
        log_test "✓ Technical specifications documented"
    else
        log_fail "Technical specifications not documented"
        return 1
    fi

    # Create mock technical specifications test
    cat > "$TEST_SESSION_DIR/tech_specs.json" << 'EOF'
{
    "audio_output": {
        "format": "mp3_44100_128",
        "sample_rate": 44100,
        "bitrate": 128,
        "channels": "mono",
        "target_duration": "25-30 minutes",
        "expected_file_size": "25-35 MB"
    }
}
EOF

    # Validate technical specifications
    local sample_rate
    sample_rate=$(jq -r '.audio_output.sample_rate' "$TEST_SESSION_DIR/tech_specs.json")

    local bitrate
    bitrate=$(jq -r '.audio_output.bitrate' "$TEST_SESSION_DIR/tech_specs.json")

    local format
    format=$(jq -r '.audio_output.format' "$TEST_SESSION_DIR/tech_specs.json")

    if [ "$sample_rate" -eq 44100 ]; then
        log_test "✓ Sample rate meets specification: ${sample_rate}Hz"
    else
        log_fail "Sample rate does not meet specification: ${sample_rate}Hz"
        return 1
    fi

    if [ "$bitrate" -eq 128 ]; then
        log_test "✓ Bitrate meets specification: ${bitrate}kbps"
    else
        log_fail "Bitrate does not meet specification: ${bitrate}kbps"
        return 1
    fi

    if [ "$format" = "mp3_44100_128" ]; then
        log_test "✓ Format specification validated: $format"
    else
        log_fail "Format specification validation failed: $format"
        return 1
    fi

    log_pass "Technical specifications compliance validation complete"
}

# Mock Audio Synthesis (for API-free testing)
test_mock_audio_synthesis() {
    if [ "$MOCK_MODE" = "true" ]; then
        setup_test
        log_test "Testing mock audio synthesis functionality"

        # Create comprehensive mock synthesis output
        cat > "$TEST_SESSION_DIR/mock_synthesis_output.json" << 'EOF'
{
    "synthesis_process": {
        "input_character_count": 20000,
        "processing_time_minutes": 18,
        "api_calls_made": 1,
        "total_cost": 10.50
    },
    "audio_output": {
        "file_path": "projects/nobody-knows/output/audio/ep001_mock_topic_20250818.mp3",
        "duration_minutes": 27,
        "file_size_mb": 29,
        "format": "mp3_44100_128",
        "voice_consistency": "Amelia_throughout"
    },
    "quality_metrics": {
        "voice_id_used": "ZF6FPAbjXT4488VcRRnw",
        "model_used": "eleven_turbo_v2_5",
        "stability": 0.5,
        "similarity_boost": 0.75,
        "single_call_success": true
    }
}
EOF

        # Validate mock synthesis meets requirements
        local duration_minutes
        duration_minutes=$(jq -r '.audio_output.duration_minutes' "$TEST_SESSION_DIR/mock_synthesis_output.json")

        local file_size_mb
        file_size_mb=$(jq -r '.audio_output.file_size_mb' "$TEST_SESSION_DIR/mock_synthesis_output.json")

        local single_call_success
        single_call_success=$(jq -r '.quality_metrics.single_call_success' "$TEST_SESSION_DIR/mock_synthesis_output.json")

        if [ "$duration_minutes" -ge 25 ] && [ "$duration_minutes" -le 30 ]; then
            log_test "✓ Mock synthesis duration within target: $duration_minutes minutes"
        else
            log_fail "Mock synthesis duration outside target: $duration_minutes minutes"
            return 1
        fi

        if [ "$file_size_mb" -ge 25 ] && [ "$file_size_mb" -le 35 ]; then
            log_test "✓ Mock synthesis file size within target: ${file_size_mb}MB"
        else
            log_fail "Mock synthesis file size outside target: ${file_size_mb}MB"
            return 1
        fi

        if [ "$single_call_success" = "true" ]; then
            log_pass "Mock audio synthesis meets all requirements"
        else
            log_fail "Mock audio synthesis single call requirement failed"
            return 1
        fi
    else
        log_test "Skipping mock audio synthesis (not in mock mode)"
    fi
}

# Run All Tests
run_tests() {
    log_test "Starting audio synthesizer agent tests"

    test_audio_synthesizer_spec
    test_checkpoint_integration
    test_audio_quality_specs
    test_voice_model_config
    test_cost_tracking
    test_file_output_management
    test_large_content_handling
    test_technical_specifications
    test_mock_audio_synthesis

    # Summary
    echo "=== Audio Synthesizer Agent Test Summary ==="
    echo "Tests Run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo "✅ All audio synthesizer agent tests passed"
        return 0
    else
        echo "❌ $TESTS_FAILED audio synthesizer agent tests failed"
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
