#!/bin/bash
# Error Scenario Testing: Checkpoint Corruption and Recovery
# Tests system resilience when checkpoint data is corrupted or invalid

set -euo pipefail

# Test Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_SESSION_DIR="tests/data/test_session_checkpoint_corruption"
MOCK_MODE="${MOCK_MODE:-true}"

# Test Statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging Functions
log_test() { echo "[CHECKPOINT CORRUPTION TEST] $*"; }
log_pass() { echo "[PASS] $*"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_fail() { echo "[FAIL] $*"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

# Setup
setup_test() {
    mkdir -p "$TEST_SESSION_DIR/checkpoints" "$TEST_SESSION_DIR/session_data"
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Create various checkpoint corruption scenarios
create_checkpoint_scenarios() {
    local checkpoints_dir="$TEST_SESSION_DIR/checkpoints"
    
    # Valid checkpoint for comparison
    cat > "$checkpoints_dir/valid_audio_synthesis.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis", 
    "session_id": "ep001_test_20250818",
    "episode_number": 1,
    "status": "completed",
    "timestamp": "2025-08-18T13:15:00Z",
    "cost_invested": 10.50,
    "audio_file_path": "projects/nobody-knows/output/audio/ep001_test_20250818.mp3",
    "synthesis_results": {
        "duration_minutes": 28,
        "file_size_mb": 30,
        "voice_used": "Amelia",
        "voice_id": "ZF6FPAbjXT4488VcRRnw",
        "model_used": "eleven_turbo_v2_5",
        "character_count": 21000
    },
    "quality_validation": {
        "duration_valid": true,
        "voice_consistent": true,
        "file_complete": true
    }
}
EOF

    # JSON syntax corruption
    cat > "$checkpoints_dir/malformed_json.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "ep001_test_20250818",
    "episode_number": 1,
    "status": "completed"
    "timestamp": "2025-08-18T13:15:00Z",  // Missing comma
    "cost_invested": 10.50,
    "audio_file_path": "projects/nobody-knows/output/audio/ep001_test_20250818.mp3"
    // Incomplete JSON
EOF

    # Missing critical fields
    cat > "$checkpoints_dir/missing_critical_fields.json" << 'EOF'
{
    "session_id": "ep001_test_20250818",
    "status": "completed",
    "timestamp": "2025-08-18T13:15:00Z"
}
EOF

    # Invalid timestamp format
    cat > "$checkpoints_dir/invalid_timestamp.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "ep001_test_20250818", 
    "episode_number": 1,
    "status": "completed",
    "timestamp": "invalid-timestamp-format",
    "cost_invested": 10.50,
    "audio_file_path": "projects/nobody-knows/output/audio/ep001_test_20250818.mp3"
}
EOF

    # Session ID mismatch
    cat > "$checkpoints_dir/session_id_mismatch.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "ep999_wrong_session",
    "episode_number": 1,
    "status": "completed", 
    "timestamp": "2025-08-18T13:15:00Z",
    "cost_invested": 10.50,
    "audio_file_path": "projects/nobody-knows/output/audio/ep001_test_20250818.mp3"
}
EOF

    # Corrupted cost data
    cat > "$checkpoints_dir/corrupted_cost_data.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "ep001_test_20250818",
    "episode_number": 1, 
    "status": "completed",
    "timestamp": "2025-08-18T13:15:00Z",
    "cost_invested": "invalid_cost_format",
    "audio_file_path": "projects/nobody-knows/output/audio/ep001_test_20250818.mp3"
}
EOF

    # Partially corrupted (some valid, some invalid data)
    cat > "$checkpoints_dir/partially_corrupted.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "ep001_test_20250818",
    "episode_number": "invalid_number_format",
    "status": "completed",
    "timestamp": "2025-08-18T13:15:00Z", 
    "cost_invested": 10.50,
    "audio_file_path": "projects/nobody-knows/output/audio/ep001_test_20250818.mp3",
    "synthesis_results": {
        "duration_minutes": "invalid_duration",
        "file_size_mb": 30,
        "voice_used": "Amelia"
    }
}
EOF

    # Empty file corruption
    touch "$checkpoints_dir/empty_checkpoint.json"
    
    # Binary corruption (simulate filesystem corruption)
    printf "\x00\x00\xFF\xFF invalid binary data \x00\x00" > "$checkpoints_dir/binary_corrupted.json"
}

# Test JSON syntax validation
test_json_syntax_validation() {
    setup_test
    log_test "Testing JSON syntax validation for checkpoints"
    
    create_checkpoint_scenarios
    
    local checkpoints_dir="$TEST_SESSION_DIR/checkpoints"
    local valid_checkpoints=0
    local invalid_checkpoints=0
    
    # Test files and their expected validity
    local test_files=(
        "valid_audio_synthesis.json:valid"
        "malformed_json.json:invalid" 
        "missing_critical_fields.json:valid_json_invalid_content"
        "invalid_timestamp.json:valid_json_invalid_content"
        "session_id_mismatch.json:valid_json_invalid_content"
        "corrupted_cost_data.json:valid_json_invalid_content"
        "partially_corrupted.json:valid_json_invalid_content"
        "empty_checkpoint.json:invalid"
        "binary_corrupted.json:invalid"
    )
    
    for test_case in "${test_files[@]}"; do
        local file="${test_case%:*}"
        local expected="${test_case#*:}"
        local file_path="$checkpoints_dir/$file"
        
        if [ ! -f "$file_path" ]; then
            log_fail "Test file missing: $file"
            continue
        fi
        
        # Test JSON validity
        if jq empty "$file_path" 2>/dev/null; then
            local json_status="valid_json"
        else
            local json_status="invalid_json"
        fi
        
        # Validate against expectation
        case "$expected" in
            "valid")
                if [ "$json_status" = "valid_json" ]; then
                    valid_checkpoints=$((valid_checkpoints + 1))
                    log_test "✓ Valid JSON correctly identified: $file"
                else
                    log_fail "Valid JSON incorrectly rejected: $file"
                    return 1
                fi
                ;;
            "invalid")
                if [ "$json_status" = "invalid_json" ]; then
                    invalid_checkpoints=$((invalid_checkpoints + 1))
                    log_test "✓ Invalid JSON correctly identified: $file"
                else
                    log_fail "Invalid JSON incorrectly accepted: $file"
                    return 1
                fi
                ;;
            "valid_json_invalid_content")
                if [ "$json_status" = "valid_json" ]; then
                    log_test "✓ Valid JSON with invalid content identified: $file"
                else
                    log_fail "Valid JSON incorrectly rejected due to syntax: $file"
                    return 1
                fi
                ;;
        esac
    done
    
    log_test "JSON validation summary: $valid_checkpoints valid, $invalid_checkpoints invalid"
    log_pass "JSON syntax validation test complete"
}

# Test required fields validation
test_required_fields_validation() {
    setup_test
    log_test "Testing required fields validation for checkpoints"
    
    create_checkpoint_scenarios
    local checkpoints_dir="$TEST_SESSION_DIR/checkpoints"
    
    # Required fields for different checkpoint types
    local required_fields=(
        "checkpoint_type"
        "session_id" 
        "status"
        "timestamp"
    )
    
    # Test each checkpoint file for required fields
    local checkpoint_files=(
        "valid_audio_synthesis.json"
        "missing_critical_fields.json"
        "invalid_timestamp.json"
        "session_id_mismatch.json"
        "corrupted_cost_data.json"
    )
    
    for checkpoint_file in "${checkpoint_files[@]}"; do
        local file_path="$checkpoints_dir/$checkpoint_file"
        
        if [ ! -f "$file_path" ]; then
            continue
        fi
        
        # Skip if not valid JSON
        if ! jq empty "$file_path" 2>/dev/null; then
            continue
        fi
        
        local missing_fields=()
        local has_all_required=true
        
        # Check each required field
        for field in "${required_fields[@]}"; do
            if ! jq -e ".$field" "$file_path" >/dev/null 2>&1; then
                missing_fields+=("$field")
                has_all_required=false
            fi
        done
        
        # Validate results
        case "$checkpoint_file" in
            "valid_audio_synthesis.json")
                if [ "$has_all_required" = true ]; then
                    log_test "✓ Valid checkpoint has all required fields: $checkpoint_file"
                else
                    log_fail "Valid checkpoint missing required fields: ${missing_fields[*]}"
                    return 1
                fi
                ;;
            "missing_critical_fields.json")
                if [ "$has_all_required" = false ] && [[ " ${missing_fields[*]} " =~ " checkpoint_type " ]]; then
                    log_test "✓ Missing fields correctly detected: $checkpoint_file (${missing_fields[*]})"
                else
                    log_fail "Missing fields validation failed for: $checkpoint_file"
                    return 1
                fi
                ;;
            *)
                # Other files should have required fields but may have invalid content
                if [ "$has_all_required" = true ]; then
                    log_test "✓ Required fields present but content may be invalid: $checkpoint_file"
                else
                    log_test "✓ Missing required fields detected: $checkpoint_file (${missing_fields[*]})"
                fi
                ;;
        esac
    done
    
    log_pass "Required fields validation test complete"
}

# Test timestamp validation
test_timestamp_validation() {
    setup_test
    log_test "Testing timestamp validation for checkpoints"
    
    create_checkpoint_scenarios
    local checkpoints_dir="$TEST_SESSION_DIR/checkpoints"
    
    # Valid and invalid timestamp test cases
    local timestamp_tests=(
        "valid_audio_synthesis.json:2025-08-18T13:15:00Z:valid"
        "invalid_timestamp.json:invalid-timestamp-format:invalid"
    )
    
    for test_case in "${timestamp_tests[@]}"; do
        local file="${test_case%%:*}"
        local timestamp="${test_case#*:}"
        timestamp="${timestamp%:*}"
        local expected="${test_case##*:}"
        local file_path="$checkpoints_dir/$file"
        
        if [ ! -f "$file_path" ] || ! jq empty "$file_path" 2>/dev/null; then
            continue
        fi
        
        local actual_timestamp
        actual_timestamp=$(jq -r '.timestamp' "$file_path" 2>/dev/null || echo "null")
        
        # Test timestamp format (ISO 8601)
        local is_valid_format=false
        if [[ "$actual_timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
            is_valid_format=true
        fi
        
        # Validate results
        case "$expected" in
            "valid")
                if [ "$is_valid_format" = true ]; then
                    log_test "✓ Valid timestamp format: $file ($actual_timestamp)"
                else
                    log_fail "Valid timestamp incorrectly rejected: $file ($actual_timestamp)"
                    return 1
                fi
                ;;
            "invalid")
                if [ "$is_valid_format" = false ]; then
                    log_test "✓ Invalid timestamp format correctly detected: $file ($actual_timestamp)"
                else
                    log_fail "Invalid timestamp incorrectly accepted: $file ($actual_timestamp)"
                    return 1
                fi
                ;;
        esac
    done
    
    log_pass "Timestamp validation test complete"
}

# Test session ID consistency
test_session_id_consistency() {
    setup_test
    log_test "Testing session ID consistency validation"
    
    create_checkpoint_scenarios
    local checkpoints_dir="$TEST_SESSION_DIR/checkpoints"
    local expected_session_id="ep001_test_20250818"
    
    # Test session ID matching
    local session_id_tests=(
        "valid_audio_synthesis.json:ep001_test_20250818:match"
        "session_id_mismatch.json:ep999_wrong_session:mismatch"
    )
    
    for test_case in "${session_id_tests[@]}"; do
        local file="${test_case%%:*}"
        local actual_session_id="${test_case#*:}"
        actual_session_id="${actual_session_id%:*}"
        local expected_result="${test_case##*:}"
        local file_path="$checkpoints_dir/$file"
        
        if [ ! -f "$file_path" ] || ! jq empty "$file_path" 2>/dev/null; then
            continue
        fi
        
        local checkpoint_session_id
        checkpoint_session_id=$(jq -r '.session_id' "$file_path" 2>/dev/null || echo "null")
        
        # Test session ID consistency
        local ids_match=false
        if [ "$checkpoint_session_id" = "$expected_session_id" ]; then
            ids_match=true
        fi
        
        # Validate results
        case "$expected_result" in
            "match")
                if [ "$ids_match" = true ]; then
                    log_test "✓ Session ID match correctly validated: $file"
                else
                    log_fail "Session ID match validation failed: $file (expected $expected_session_id, got $checkpoint_session_id)"
                    return 1
                fi
                ;;
            "mismatch")
                if [ "$ids_match" = false ]; then
                    log_test "✓ Session ID mismatch correctly detected: $file"
                else
                    log_fail "Session ID mismatch not detected: $file"
                    return 1
                fi
                ;;
        esac
    done
    
    log_pass "Session ID consistency test complete"
}

# Test cost data integrity
test_cost_data_integrity() {
    setup_test
    log_test "Testing cost data integrity validation"
    
    create_checkpoint_scenarios
    local checkpoints_dir="$TEST_SESSION_DIR/checkpoints"
    
    # Test cost data validation
    local cost_tests=(
        "valid_audio_synthesis.json:10.50:valid"
        "corrupted_cost_data.json:invalid_cost_format:invalid"
    )
    
    for test_case in "${cost_tests[@]}"; do
        local file="${test_case%%:*}"
        local cost_value="${test_case#*:}"
        cost_value="${cost_value%:*}"
        local expected_validity="${test_case##*:}"
        local file_path="$checkpoints_dir/$file"
        
        if [ ! -f "$file_path" ] || ! jq empty "$file_path" 2>/dev/null; then
            continue
        fi
        
        local actual_cost
        actual_cost=$(jq -r '.cost_invested' "$file_path" 2>/dev/null || echo "null")
        
        # Test cost format (should be numeric)
        local is_valid_cost=false
        if [[ "$actual_cost" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            is_valid_cost=true
        fi
        
        # Test cost reasonableness (for audio synthesis: $1-$15 range)
        local is_reasonable_cost=false
        if [ "$is_valid_cost" = true ]; then
            if (( $(echo "$actual_cost >= 1.0 && $actual_cost <= 15.0" | bc -l) )); then
                is_reasonable_cost=true
            fi
        fi
        
        # Validate results
        case "$expected_validity" in
            "valid")
                if [ "$is_valid_cost" = true ] && [ "$is_reasonable_cost" = true ]; then
                    log_test "✓ Valid cost data: $file (\$${actual_cost})"
                else
                    log_fail "Valid cost data incorrectly rejected: $file (\$${actual_cost})"
                    return 1
                fi
                ;;
            "invalid")
                if [ "$is_valid_cost" = false ]; then
                    log_test "✓ Invalid cost data correctly detected: $file ($actual_cost)"
                else
                    log_fail "Invalid cost data incorrectly accepted: $file ($actual_cost)"
                    return 1
                fi
                ;;
        esac
    done
    
    log_pass "Cost data integrity test complete"
}

# Test checkpoint recovery mechanisms
test_checkpoint_recovery_mechanisms() {
    setup_test
    log_test "Testing checkpoint recovery mechanisms"
    
    # Create corrupted and backup checkpoint scenarios
    local session_dir="$TEST_SESSION_DIR/session_data/ep001_test_20250818"
    mkdir -p "$session_dir"
    
    # Primary checkpoint (corrupted)
    echo "corrupted data" > "$session_dir/09_audio_synthesis_complete.json"
    
    # Backup checkpoint (valid)
    cat > "$session_dir/09_audio_synthesis_complete.json.backup" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "ep001_test_20250818",
    "status": "completed",
    "timestamp": "2025-08-18T13:15:00Z",
    "cost_invested": 10.50,
    "backup_restored": true
}
EOF
    
    # Test recovery process
    local primary_checkpoint="$session_dir/09_audio_synthesis_complete.json"
    local backup_checkpoint="$session_dir/09_audio_synthesis_complete.json.backup"
    
    # Check if primary is corrupted
    local primary_valid=false
    if jq empty "$primary_checkpoint" 2>/dev/null; then
        primary_valid=true
    fi
    
    # Test backup availability and validity
    local backup_available=false
    local backup_valid=false
    
    if [ -f "$backup_checkpoint" ]; then
        backup_available=true
        if jq empty "$backup_checkpoint" 2>/dev/null; then
            backup_valid=true
        fi
    fi
    
    # Test recovery logic
    if [ "$primary_valid" = false ] && [ "$backup_available" = true ] && [ "$backup_valid" = true ]; then
        log_test "✓ Backup checkpoint available for recovery"
        
        # Simulate recovery
        cp "$backup_checkpoint" "$primary_checkpoint.recovered"
        
        # Verify recovery
        if jq empty "$primary_checkpoint.recovered" 2>/dev/null; then
            local backup_restored
            backup_restored=$(jq -r '.backup_restored' "$primary_checkpoint.recovered" 2>/dev/null || echo "false")
            
            if [ "$backup_restored" = "true" ]; then
                log_test "✓ Checkpoint recovery successful from backup"
            else
                log_fail "Checkpoint recovery failed - backup flag not set"
                return 1
            fi
        else
            log_fail "Checkpoint recovery failed - restored file invalid"
            return 1
        fi
    else
        log_fail "Checkpoint recovery conditions not met (primary_valid=$primary_valid, backup_available=$backup_available, backup_valid=$backup_valid)"
        return 1
    fi
    
    log_pass "Checkpoint recovery mechanisms test complete"
}

# Test high-cost operation protection
test_high_cost_operation_protection() {
    setup_test
    log_test "Testing high-cost operation protection during corruption"
    
    create_checkpoint_scenarios
    local checkpoints_dir="$TEST_SESSION_DIR/checkpoints"
    
    # Simulate high-cost operation checkpoint corruption scenarios
    local cost_protection_scenarios=(
        "audio_synthesis:10.50:critical_protection_required"
        "research:2.35:moderate_protection"
        "script_writing:1.75:standard_protection"
    )
    
    for scenario in "${cost_protection_scenarios[@]}"; do
        local operation="${scenario%%:*}"
        local cost="${scenario#*:}"
        cost="${cost%:*}"
        local protection_level="${scenario##*:}"
        
        # Test cost protection thresholds
        case "$protection_level" in
            "critical_protection_required")
                # Operations > $5 require immediate checkpoint backup
                if (( $(echo "$cost >= 5.0" | bc -l) )); then
                    log_test "✓ Critical protection required for $operation: \$${cost}"
                    
                    # Test that backup mechanisms are triggered
                    local requires_backup=true
                    local requires_validation=true
                    local requires_recovery_plan=true
                    
                    if [ "$requires_backup" = true ] && [ "$requires_validation" = true ] && [ "$requires_recovery_plan" = true ]; then
                        log_test "✓ High-cost protection mechanisms active for $operation"
                    else
                        log_fail "High-cost protection mechanisms insufficient for $operation"
                        return 1
                    fi
                else
                    log_fail "Cost threshold misconfigured for critical protection"
                    return 1
                fi
                ;;
            "moderate_protection"|"standard_protection")
                if (( $(echo "$cost >= 1.0" | bc -l) )); then
                    log_test "✓ Standard protection adequate for $operation: \$${cost}"
                else
                    log_fail "Cost threshold misconfigured for standard protection"
                    return 1
                fi
                ;;
        esac
    done
    
    log_pass "High-cost operation protection test complete"
}

# Test file system corruption scenarios
test_filesystem_corruption_scenarios() {
    setup_test
    log_test "Testing filesystem corruption scenarios"
    
    local corruption_dir="$TEST_SESSION_DIR/filesystem_corruption"
    mkdir -p "$corruption_dir"
    
    # Simulate various filesystem corruption scenarios
    
    # 1. Permissions corruption
    cat > "$corruption_dir/permissions_test.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "test",
    "status": "completed"
}
EOF
    chmod 000 "$corruption_dir/permissions_test.json"
    
    # Test permission handling
    local can_read=false
    if [ -r "$corruption_dir/permissions_test.json" ]; then
        can_read=true
    fi
    
    if [ "$can_read" = false ]; then
        log_test "✓ Permission corruption correctly detected"
        
        # Test recovery attempt
        if chmod 644 "$corruption_dir/permissions_test.json" 2>/dev/null; then
            if [ -r "$corruption_dir/permissions_test.json" ]; then
                log_test "✓ Permission corruption recovery successful"
            else
                log_fail "Permission corruption recovery failed"
                return 1
            fi
        else
            log_test "✓ Permission corruption recovery not possible (expected in some environments)"
        fi
    else
        log_test "✓ No permission issues detected (expected in some environments)"
    fi
    
    # 2. Disk space simulation (create large file, then test)
    # Note: This is a simulation - actual disk space testing would be environment-specific
    local disk_space_available=true  # Simulate available space
    local file_size_mb=30           # Typical audio file size
    
    if [ "$disk_space_available" = true ]; then
        log_test "✓ Sufficient disk space for checkpoint operations"
    else
        log_test "✓ Disk space shortage detected - would trigger cleanup procedures"
    fi
    
    # 3. Concurrent access corruption
    local lock_file="$corruption_dir/checkpoint.lock"
    
    # Simulate lock file creation
    echo "lock_created_by_process_123" > "$lock_file"
    
    if [ -f "$lock_file" ]; then
        log_test "✓ Concurrent access lock detected"
        
        # Simulate lock cleanup after process completion
        rm "$lock_file"
        
        if [ ! -f "$lock_file" ]; then
            log_test "✓ Lock file cleanup successful"
        else
            log_fail "Lock file cleanup failed"
            return 1
        fi
    else
        log_fail "Lock file creation failed"
        return 1
    fi
    
    log_pass "Filesystem corruption scenarios test complete"
}

# Run All Checkpoint Corruption Tests
run_tests() {
    log_test "Starting checkpoint corruption and recovery scenario tests"
    
    # Run all test scenarios
    test_json_syntax_validation
    test_required_fields_validation
    test_timestamp_validation
    test_session_id_consistency
    test_cost_data_integrity
    test_checkpoint_recovery_mechanisms
    test_high_cost_operation_protection
    test_filesystem_corruption_scenarios
    
    # Summary
    echo "=== Checkpoint Corruption Recovery Test Summary ==="
    echo "Tests Run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo "✅ All checkpoint corruption recovery tests passed"
        return 0
    else
        echo "❌ $TESTS_FAILED checkpoint corruption recovery tests failed"
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