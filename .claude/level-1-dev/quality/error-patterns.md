# Error Handling Patterns for Level-1-Dev

## Overview

This guide provides common error handling patterns used throughout the Level-1-Dev system. These patterns ensure consistent, predictable error handling that helps users understand and resolve issues quickly.

## Core Principles

### 1. Fail Fast and Fail Clear
- Detect errors as early as possible
- Provide clear, actionable error messages
- Don't mask or swallow errors

### 2. Graceful Degradation
- Continue operation when possible
- Provide fallback options
- Maintain system stability

### 3. User-Centric Recovery
- Guide users toward solutions
- Provide context and examples
- Minimize disruption to workflow

## Error Handling Patterns

### Pattern 1: Defensive Input Validation

**Use Case:** Validating user input and configuration

```bash
validate_input() {
    local input="$1"
    local input_name="$2"
    local required="${3:-true}"
    
    # Check if required input is provided
    if [ "$required" = "true" ] && [ -z "$input" ]; then
        log_error "VALIDATION_ERROR" "Missing required parameter: $input_name"
        show_usage_example "$input_name"
        return 1
    fi
    
    # Validate format if input provided
    if [ -n "$input" ]; then
        case "$input_name" in
            "email")
                if ! [[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    log_error "VALIDATION_ERROR" "Invalid email format: $input"
                    echo "Expected format: user@domain.com"
                    return 1
                fi
                ;;
            "version")
                if ! [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    log_error "VALIDATION_ERROR" "Invalid version format: $input"
                    echo "Expected format: MAJOR.MINOR.PATCH (e.g., 1.2.3)"
                    return 1
                fi
                ;;
        esac
    fi
    
    return 0
}
```

### Pattern 2: File Operation Safety

**Use Case:** Safe file operations with proper error handling

```bash
safe_file_operation() {
    local operation="$1"
    local source_file="$2"
    local target_file="$3"
    
    case "$operation" in
        "copy")
            # Validate source exists
            if [ ! -f "$source_file" ]; then
                log_error "FILE_NOT_FOUND" "Source file does not exist: $source_file"
                suggest_file_recovery "$source_file"
                return 1
            fi
            
            # Check source permissions
            if [ ! -r "$source_file" ]; then
                log_error "PERMISSION_DENIED" "Cannot read source file: $source_file"
                suggest_permission_fix "$source_file"
                return 1
            fi
            
            # Ensure target directory exists
            local target_dir=$(dirname "$target_file")
            if [ ! -d "$target_dir" ]; then
                if ! mkdir -p "$target_dir" 2>/dev/null; then
                    log_error "DIRECTORY_CREATION_FAILED" "Cannot create target directory: $target_dir"
                    suggest_directory_fix "$target_dir"
                    return 1
                fi
            fi
            
            # Perform copy with error handling
            if ! cp "$source_file" "$target_file" 2>/dev/null; then
                log_error "COPY_FAILED" "Failed to copy $source_file to $target_file"
                check_disk_space "$target_dir"
                return 1
            fi
            
            log_info "FILE_COPIED" "Successfully copied $source_file to $target_file"
            ;;
    esac
}
```

### Pattern 3: Command Execution with Retry

**Use Case:** Executing external commands with automatic retry

```bash
execute_with_retry() {
    local command="$1"
    local max_attempts="${2:-3}"
    local delay="${3:-2}"
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_debug "COMMAND_ATTEMPT" "Executing: $command (attempt $attempt/$max_attempts)"
        
        # Execute command and capture output
        local output
        local exit_code
        
        output=$(eval "$command" 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            log_info "COMMAND_SUCCESS" "Command succeeded on attempt $attempt"
            echo "$output"
            return 0
        fi
        
        # Log the failure
        log_warn "COMMAND_FAILED" "Command failed on attempt $attempt/$max_attempts: $command"
        log_debug "COMMAND_OUTPUT" "$output"
        
        # Check if it's a retryable error
        if is_retryable_error "$exit_code" "$output"; then
            if [ $attempt -lt $max_attempts ]; then
                log_info "RETRY_SCHEDULED" "Retrying in ${delay}s..."
                sleep "$delay"
                ((delay *= 2))  # Exponential backoff
            fi
        else
            log_error "COMMAND_FATAL" "Non-retryable error, aborting"
            echo "$output" >&2
            return $exit_code
        fi
        
        ((attempt++))
    done
    
    log_error "COMMAND_MAX_RETRIES" "Command failed after $max_attempts attempts: $command"
    echo "$output" >&2
    return 1
}

is_retryable_error() {
    local exit_code="$1"
    local output="$2"
    
    # Network errors are retryable
    if echo "$output" | grep -q -E "(timeout|connection|network|temporary)"; then
        return 0
    fi
    
    # Temporary file system issues
    if echo "$output" | grep -q -E "(no space|busy|locked)"; then
        return 0
    fi
    
    # Rate limiting
    if echo "$output" | grep -q -E "(rate limit|too many requests)"; then
        return 0
    fi
    
    # Configuration and permission errors are not retryable
    return 1
}
```

### Pattern 4: Context-Aware Error Reporting

**Use Case:** Providing rich context in error messages

```bash
report_error_with_context() {
    local error_type="$1"
    local error_message="$2"
    local component="${3:-unknown}"
    local operation="${4:-unknown}"
    
    # Gather context information
    local timestamp=$(date -Iseconds)
    local git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local user=$(whoami)
    local pwd=$(pwd)
    local system_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    
    # Create error context
    local context=$(cat << EOF
{
  "timestamp": "$timestamp",
  "error_type": "$error_type",
  "component": "$component",
  "operation": "$operation",
  "user": "$user",
  "working_directory": "$pwd",
  "git_commit": "$git_commit",
  "system_load": "$system_load",
  "message": "$error_message"
}
EOF
)
    
    # Log to error file
    echo "$context" >> "quality/reports/error.log"
    
    # Display user-friendly message
    echo -e "${RED}Error in $component during $operation:${NC}"
    echo -e "${RED}$error_message${NC}"
    echo ""
    echo "Context saved to: quality/reports/error.log"
    echo "Git commit: $git_commit"
    echo "Time: $timestamp"
    
    # Provide recovery suggestions
    suggest_recovery "$error_type" "$component" "$operation"
}
```

### Pattern 5: Configuration Validation Chain

**Use Case:** Validating configuration files with clear error reporting

```bash
validate_configuration() {
    local config_file="$1"
    local validation_errors=()
    
    log_info "CONFIG_VALIDATION" "Validating configuration: $config_file"
    
    # Check file exists
    if [ ! -f "$config_file" ]; then
        validation_errors+=("Configuration file not found: $config_file")
        suggest_config_creation "$config_file"
        return 1
    fi
    
    # Check file is readable
    if [ ! -r "$config_file" ]; then
        validation_errors+=("Configuration file not readable: $config_file")
        suggest_permission_fix "$config_file"
        return 1
    fi
    
    # Validate YAML syntax
    if ! yaml_syntax_check "$config_file"; then
        validation_errors+=("Invalid YAML syntax in: $config_file")
        show_yaml_errors "$config_file"
    fi
    
    # Validate required fields
    local required_fields=("version" "quality" "thresholds")
    for field in "${required_fields[@]}"; do
        if ! yaml_has_field "$config_file" "$field"; then
            validation_errors+=("Missing required field: $field")
            show_field_example "$field"
        fi
    done
    
    # Validate field values
    if yaml_has_field "$config_file" "thresholds.test_pass_rate"; then
        local test_pass_rate=$(yaml_get_value "$config_file" "thresholds.test_pass_rate")
        if ! [[ "$test_pass_rate" =~ ^[0-9]+$ ]] || [ "$test_pass_rate" -lt 0 ] || [ "$test_pass_rate" -gt 100 ]; then
            validation_errors+=("Invalid test_pass_rate: $test_pass_rate (must be 0-100)")
        fi
    fi
    
    # Report validation results
    if [ ${#validation_errors[@]} -eq 0 ]; then
        log_info "CONFIG_VALID" "Configuration validation passed"
        return 0
    else
        log_error "CONFIG_INVALID" "Configuration validation failed with ${#validation_errors[@]} errors"
        for error in "${validation_errors[@]}"; do
            echo -e "  ${RED}✗${NC} $error"
        done
        return 1
    fi
}
```

### Pattern 6: Service Health Monitoring

**Use Case:** Monitoring service health with automated recovery

```bash
monitor_service_health() {
    local service_name="$1"
    local health_check_command="$2"
    local recovery_command="$3"
    local max_failures="${4:-3}"
    
    local failure_count=0
    local consecutive_failures=0
    
    while true; do
        if eval "$health_check_command" >/dev/null 2>&1; then
            if [ $consecutive_failures -gt 0 ]; then
                log_info "SERVICE_RECOVERED" "$service_name recovered after $consecutive_failures failures"
                consecutive_failures=0
            fi
            
            log_debug "SERVICE_HEALTHY" "$service_name is healthy"
        else
            ((failure_count++))
            ((consecutive_failures++))
            
            log_warn "SERVICE_UNHEALTHY" "$service_name health check failed (failure $consecutive_failures/$max_failures)"
            
            if [ $consecutive_failures -ge $max_failures ]; then
                log_error "SERVICE_CRITICAL" "$service_name failed $max_failures consecutive health checks"
                
                if [ -n "$recovery_command" ]; then
                    log_info "SERVICE_RECOVERY" "Attempting to recover $service_name"
                    
                    if eval "$recovery_command" >/dev/null 2>&1; then
                        log_info "SERVICE_RECOVERY_SUCCESS" "$service_name recovery command executed successfully"
                        consecutive_failures=0
                    else
                        log_error "SERVICE_RECOVERY_FAILED" "$service_name recovery command failed"
                        alert_service_failure "$service_name" "$failure_count"
                    fi
                else
                    alert_service_failure "$service_name" "$failure_count"
                fi
            fi
        fi
        
        sleep 30  # Check every 30 seconds
    done
}
```

## Error Message Guidelines

### Good Error Messages

1. **Specific and Actionable**
   ```bash
   # Good
   echo "Error: Configuration file 'config.yaml' is missing the required 'api_key' field"
   echo "Please add: api_key: your_api_key_here"
   
   # Bad
   echo "Configuration error"
   ```

2. **Include Context**
   ```bash
   # Good
   echo "Error: Test 'test_user_validation' failed in file 'tests/user_tests.sh' line 42"
   echo "Expected: 'valid user' but got: 'invalid user'"
   
   # Bad
   echo "Test failed"
   ```

3. **Provide Next Steps**
   ```bash
   # Good
   echo "Error: Git repository is not clean"
   echo "Please commit or stash your changes before continuing:"
   echo "  git add . && git commit -m 'your message'"
   echo "  OR"
   echo "  git stash"
   
   # Bad
   echo "Dirty repository"
   ```

### Error Message Templates

```bash
# System Error Template
system_error() {
    local component="$1"
    local operation="$2"
    local error="$3"
    local suggestion="$4"
    
    echo -e "${RED}System Error in $component${NC}"
    echo "Operation: $operation"
    echo "Error: $error"
    echo ""
    echo "Suggestion: $suggestion"
    echo ""
    echo "For help, run: ./help.sh $component"
}

# Validation Error Template
validation_error() {
    local field="$1"
    local value="$2"
    local expected="$3"
    local example="$4"
    
    echo -e "${YELLOW}Validation Error${NC}"
    echo "Field: $field"
    echo "Provided: $value"
    echo "Expected: $expected"
    echo ""
    echo "Example: $example"
}

# User Error Template
user_error() {
    local action="$1"
    local reason="$2"
    local correct_usage="$3"
    
    echo -e "${BLUE}Usage Error${NC}"
    echo "Cannot $action: $reason"
    echo ""
    echo "Correct usage:"
    echo "  $correct_usage"
    echo ""
    echo "Run with --help for more information"
}
```

## Recovery Procedures

### Automatic Recovery Patterns

```bash
auto_recover() {
    local error_type="$1"
    local context="$2"
    
    case "$error_type" in
        "MISSING_DIRECTORY")
            local dir_path=$(echo "$context" | jq -r '.path')
            if mkdir -p "$dir_path"; then
                log_info "AUTO_RECOVERY" "Created missing directory: $dir_path"
                return 0
            fi
            ;;
        "INVALID_PERMISSIONS")
            local file_path=$(echo "$context" | jq -r '.path')
            local expected_perms=$(echo "$context" | jq -r '.expected_permissions')
            if chmod "$expected_perms" "$file_path"; then
                log_info "AUTO_RECOVERY" "Fixed permissions for: $file_path"
                return 0
            fi
            ;;
        "CORRUPTED_CONFIG")
            local config_file=$(echo "$context" | jq -r '.config_file')
            local backup_file="${config_file}.backup"
            if [ -f "$backup_file" ] && cp "$backup_file" "$config_file"; then
                log_info "AUTO_RECOVERY" "Restored config from backup: $config_file"
                return 0
            fi
            ;;
    esac
    
    return 1
}
```

### Guided Recovery Patterns

```bash
guided_recovery() {
    local error_type="$1"
    local context="$2"
    
    echo -e "${BLUE}Guided Recovery for: $error_type${NC}"
    echo ""
    
    case "$error_type" in
        "GIT_CONFLICTS")
            echo "Git merge conflicts detected. Let's resolve them step by step:"
            echo ""
            echo "1. First, let's see which files have conflicts:"
            git status --porcelain | grep "^UU"
            echo ""
            echo "2. For each file, you can:"
            echo "   a) Edit manually to resolve conflicts"
            echo "   b) Keep your version: git checkout --ours <file>"
            echo "   c) Keep their version: git checkout --theirs <file>"
            echo ""
            read -p "Press Enter when you've resolved all conflicts..."
            echo ""
            echo "3. Mark conflicts as resolved:"
            echo "   git add <resolved-files>"
            echo ""
            echo "4. Complete the merge:"
            echo "   git commit"
            ;;
        "FAILED_TESTS")
            echo "Some tests are failing. Let's investigate:"
            echo ""
            echo "1. First, let's see which tests failed:"
            ./tests/run-all-tests.sh | grep "FAIL"
            echo ""
            echo "2. Run a specific test with verbose output:"
            echo "   ./tests/run-specific-test.sh <test-name> --verbose"
            echo ""
            echo "3. Common causes:"
            echo "   - Recent code changes"
            echo "   - Environment differences"
            echo "   - Outdated test expectations"
            ;;
    esac
}
```

## Testing Error Handling

### Error Simulation

```bash
simulate_error() {
    local error_type="$1"
    
    case "$error_type" in
        "file_not_found")
            local fake_file="/tmp/nonexistent_file_$(date +%s)"
            cat "$fake_file" 2>/dev/null || handle_file_error "$fake_file"
            ;;
        "permission_denied")
            local restricted_file="/tmp/restricted_$(date +%s)"
            touch "$restricted_file"
            chmod 000 "$restricted_file"
            cat "$restricted_file" 2>/dev/null || handle_permission_error "$restricted_file"
            rm -f "$restricted_file"
            ;;
        "network_timeout")
            timeout 1 curl https://httpstat.us/200?sleep=5000 || handle_network_error
            ;;
    esac
}
```

### Error Handler Testing

```bash
test_error_handlers() {
    echo "Testing error handling patterns..."
    
    local test_results=()
    
    # Test file not found handling
    if simulate_error "file_not_found" 2>&1 | grep -q "Error:.*not found"; then
        test_results+=("✓ File not found handling")
    else
        test_results+=("✗ File not found handling")
    fi
    
    # Test permission denied handling
    if simulate_error "permission_denied" 2>&1 | grep -q "Error:.*permission"; then
        test_results+=("✓ Permission denied handling")
    else
        test_results+=("✗ Permission denied handling")
    fi
    
    # Test network timeout handling
    if simulate_error "network_timeout" 2>&1 | grep -q "Error:.*timeout"; then
        test_results+=("✓ Network timeout handling")
    else
        test_results+=("✗ Network timeout handling")
    fi
    
    # Report results
    echo "Error Handler Test Results:"
    for result in "${test_results[@]}"; do
        echo "  $result"
    done
}
```

## Best Practices Summary

1. **Always validate inputs** before processing
2. **Provide specific error messages** with context
3. **Include recovery suggestions** in error output
4. **Log errors with sufficient detail** for debugging
5. **Use consistent error codes** across components
6. **Implement retry logic** for transient failures
7. **Fail fast** on configuration errors
8. **Provide fallback options** when possible
9. **Test error paths** as thoroughly as success paths
10. **Document recovery procedures** for each error type

## Integration with Level-1-Dev

These error patterns integrate with:

- **Quality Gates**: Error handling quality is measured and enforced
- **Testing Framework**: Error scenarios are tested automatically  
- **Monitoring System**: Error patterns are tracked and analyzed
- **Documentation**: Error handling is documented automatically
- **User Interface**: Consistent error presentation across all tools

Remember: Good error handling is not just about catching errors - it's about guiding users to successful outcomes.