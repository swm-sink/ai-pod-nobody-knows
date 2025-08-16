#!/bin/bash

# Error Handling Template for Level-1-Dev Scripts
# Source this file or copy patterns to implement consistent error handling

# Version: 1.0.0
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/../templates/error-handling-template.sh"

set -euo pipefail

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================

if [[ -t 1 ]]; then  # Only use colors if stdout is a terminal
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly MAGENTA='\033[0;35m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'  # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly MAGENTA=''
    readonly BOLD=''
    readonly NC=''
fi

# ============================================================================
# GLOBAL ERROR HANDLING CONFIGURATION
# ============================================================================

# Script identification
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly COMPONENT_NAME="${COMPONENT_NAME:-$(basename "$SCRIPT_DIR")}"

# Error logging configuration
readonly LOG_DIR="${LOG_DIR:-${SCRIPT_DIR}/../quality/reports}"
readonly ERROR_LOG="${ERROR_LOG:-${LOG_DIR}/error.log}"
readonly DEBUG_LOG="${DEBUG_LOG:-${LOG_DIR}/debug.log}"

# Error handling configuration
readonly ENABLE_STACK_TRACE="${ENABLE_STACK_TRACE:-true}"
readonly ENABLE_AUTO_RECOVERY="${ENABLE_AUTO_RECOVERY:-true}"
readonly ENABLE_USER_GUIDANCE="${ENABLE_USER_GUIDANCE:-true}"
readonly MAX_RETRY_ATTEMPTS="${MAX_RETRY_ATTEMPTS:-3}"
readonly RETRY_DELAY="${RETRY_DELAY:-2}"

# ============================================================================
# ERROR CONTEXT COLLECTION
# ============================================================================

# Collect system context for error reporting
collect_error_context() {
    local context
    context=$(cat << EOF
{
  "timestamp": "$(date -Iseconds)",
  "script": "$SCRIPT_NAME",
  "component": "$COMPONENT_NAME",
  "user": "$(whoami)",
  "working_directory": "$(pwd)",
  "git_commit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
  "system_load": "$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',' || echo 'unknown')",
  "disk_usage": "$(df -h . | tail -1 | awk '{print $5}' || echo 'unknown')",
  "memory_usage": "$(free -h 2>/dev/null | grep '^Mem:' | awk '{print $3"/"$2}' || echo 'unknown')",
  "shell": "$SHELL",
  "pid": "$$",
  "args": $(printf '%s\n' "$@" | jq -R . | jq -s .)
}
EOF
)
    echo "$context"
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

# Initialize logging
init_logging() {
    mkdir -p "$LOG_DIR"
    touch "$ERROR_LOG" "$DEBUG_LOG"
}

# Log with specific level
log_message() {
    local level="$1"
    local code="$2"
    local message="$3"
    local context="${4:-{}}"
    
    local timestamp=$(date -Iseconds)
    local log_entry
    
    log_entry=$(cat << EOF
{
  "timestamp": "$timestamp",
  "level": "$level",
  "component": "$COMPONENT_NAME",
  "script": "$SCRIPT_NAME",
  "code": "$code",
  "message": "$message",
  "context": $context
}
EOF
)
    
    # Write to appropriate log file
    case "$level" in
        "ERROR"|"CRITICAL")
            echo "$log_entry" >> "$ERROR_LOG"
            ;;
        "DEBUG")
            echo "$log_entry" >> "$DEBUG_LOG"
            ;;
        *)
            echo "$log_entry" >> "$ERROR_LOG"
            ;;
    esac
    
    # Display to user based on level
    case "$level" in
        "ERROR"|"CRITICAL")
            echo -e "${RED}[$level] $message${NC}" >&2
            ;;
        "WARN")
            echo -e "${YELLOW}[$level] $message${NC}" >&2
            ;;
        "INFO")
            echo -e "${GREEN}[$level] $message${NC}"
            ;;
        "DEBUG")
            if [ "${DEBUG:-false}" = "true" ]; then
                echo -e "${CYAN}[$level] $message${NC}" >&2
            fi
            ;;
    esac
}

# Convenience logging functions
log_error() { log_message "ERROR" "$1" "$2" "${3:-{}}"; }
log_warn() { log_message "WARN" "$1" "$2" "${3:-{}}"; }
log_info() { log_message "INFO" "$1" "$2" "${3:-{}}"; }
log_debug() { log_message "DEBUG" "$1" "$2" "${3:-{}}"; }
log_critical() { log_message "CRITICAL" "$1" "$2" "${3:-{}}"; }

# ============================================================================
# STACK TRACE COLLECTION
# ============================================================================

# Generate stack trace
generate_stack_trace() {
    local stack_trace=""
    local frame=0
    
    while caller $frame >/dev/null 2>&1; do
        local line_info=$(caller $frame)
        local line_number=$(echo "$line_info" | awk '{print $1}')
        local function_name=$(echo "$line_info" | awk '{print $2}')
        local file_name=$(echo "$line_info" | awk '{print $3}')
        
        stack_trace+="{\"frame\": $frame, \"line\": $line_number, \"function\": \"$function_name\", \"file\": \"$file_name\"},"
        ((frame++))
    done
    
    # Remove trailing comma and wrap in array
    stack_trace="[${stack_trace%,}]"
    echo "$stack_trace"
}

# ============================================================================
# ERROR CLASSIFICATION
# ============================================================================

# Classify error type based on exit code and message
classify_error() {
    local exit_code="$1"
    local error_message="$2"
    
    case "$exit_code" in
        1)
            if echo "$error_message" | grep -q -E "(permission|denied|access)"; then
                echo "PERMISSION_ERROR"
            elif echo "$error_message" | grep -q -E "(not found|no such|missing)"; then
                echo "NOT_FOUND_ERROR"
            else
                echo "GENERAL_ERROR"
            fi
            ;;
        2)
            echo "MISUSE_ERROR"
            ;;
        126)
            echo "PERMISSION_ERROR"
            ;;
        127)
            echo "COMMAND_NOT_FOUND_ERROR"
            ;;
        128)
            echo "INVALID_EXIT_ARGUMENT"
            ;;
        130)
            echo "INTERRUPTED_ERROR"
            ;;
        *)
            if echo "$error_message" | grep -q -E "(timeout|network|connection)"; then
                echo "NETWORK_ERROR"
            elif echo "$error_message" | grep -q -E "(syntax|parse|invalid)"; then
                echo "SYNTAX_ERROR"
            elif echo "$error_message" | grep -q -E "(space|full|disk)"; then
                echo "RESOURCE_ERROR"
            else
                echo "UNKNOWN_ERROR"
            fi
            ;;
    esac
}

# ============================================================================
# ERROR RECOVERY FUNCTIONS
# ============================================================================

# Check if error is retryable
is_retryable_error() {
    local error_type="$1"
    local error_message="$2"
    
    case "$error_type" in
        "NETWORK_ERROR"|"RESOURCE_ERROR"|"INTERRUPTED_ERROR")
            return 0
            ;;
        "TIMEOUT_ERROR")
            return 0
            ;;
        *)
            # Check message patterns for retryable conditions
            if echo "$error_message" | grep -q -E "(temporary|retry|busy|locked)"; then
                return 0
            fi
            return 1
            ;;
    esac
}

# Attempt automatic recovery
attempt_auto_recovery() {
    local error_type="$1"
    local error_context="$2"
    
    if [ "$ENABLE_AUTO_RECOVERY" != "true" ]; then
        return 1
    fi
    
    log_info "AUTO_RECOVERY_ATTEMPT" "Attempting automatic recovery for: $error_type"
    
    case "$error_type" in
        "NOT_FOUND_ERROR")
            local missing_file=$(echo "$error_context" | jq -r '.missing_file // empty')
            if [ -n "$missing_file" ]; then
                local missing_dir=$(dirname "$missing_file")
                if [ ! -d "$missing_dir" ]; then
                    if mkdir -p "$missing_dir" 2>/dev/null; then
                        log_info "AUTO_RECOVERY_SUCCESS" "Created missing directory: $missing_dir"
                        return 0
                    fi
                fi
            fi
            ;;
        "PERMISSION_ERROR")
            local target_file=$(echo "$error_context" | jq -r '.target_file // empty')
            if [ -n "$target_file" ] && [ -f "$target_file" ]; then
                if chmod +x "$target_file" 2>/dev/null; then
                    log_info "AUTO_RECOVERY_SUCCESS" "Fixed permissions for: $target_file"
                    return 0
                fi
            fi
            ;;
        "RESOURCE_ERROR")
            # Clean up temporary files
            if find /tmp -name "${SCRIPT_NAME}_*" -mtime +1 -delete 2>/dev/null; then
                log_info "AUTO_RECOVERY_SUCCESS" "Cleaned up old temporary files"
                return 0
            fi
            ;;
    esac
    
    log_warn "AUTO_RECOVERY_FAILED" "Could not automatically recover from: $error_type"
    return 1
}

# ============================================================================
# USER GUIDANCE FUNCTIONS
# ============================================================================

# Provide user guidance for error resolution
provide_user_guidance() {
    local error_type="$1"
    local error_message="$2"
    local error_context="$3"
    
    if [ "$ENABLE_USER_GUIDANCE" != "true" ]; then
        return
    fi
    
    echo ""
    echo -e "${BLUE}${BOLD}How to fix this issue:${NC}"
    
    case "$error_type" in
        "PERMISSION_ERROR")
            echo -e "${CYAN}1. Check file permissions:${NC}"
            echo "   ls -la [filename]"
            echo -e "${CYAN}2. Fix permissions if needed:${NC}"
            echo "   chmod +x [filename]  # Make executable"
            echo "   chmod 644 [filename] # Make readable/writable"
            echo -e "${CYAN}3. Check if you have sudo access:${NC}"
            echo "   sudo [your-command]"
            ;;
        "NOT_FOUND_ERROR")
            echo -e "${CYAN}1. Check if the file/command exists:${NC}"
            echo "   ls -la [path]"
            echo "   which [command]"
            echo -e "${CYAN}2. Check your PATH:${NC}"
            echo "   echo \$PATH"
            echo -e "${CYAN}3. Install missing dependencies:${NC}"
            echo "   # Follow installation guide for missing tools"
            ;;
        "NETWORK_ERROR")
            echo -e "${CYAN}1. Check internet connection:${NC}"
            echo "   ping google.com"
            echo -e "${CYAN}2. Check if service is available:${NC}"
            echo "   curl -I [service-url]"
            echo -e "${CYAN}3. Try again in a moment (temporary issue):${NC}"
            echo "   # Network issues often resolve themselves"
            ;;
        "SYNTAX_ERROR")
            echo -e "${CYAN}1. Check configuration file syntax:${NC}"
            echo "   # Review the error message for specific issues"
            echo -e "${CYAN}2. Validate YAML/JSON:${NC}"
            echo "   yamllint [config-file]"
            echo "   jq . [json-file]"
            echo -e "${CYAN}3. Compare with working examples:${NC}"
            echo "   # Check templates/ directory for examples"
            ;;
        "RESOURCE_ERROR")
            echo -e "${CYAN}1. Check available disk space:${NC}"
            echo "   df -h"
            echo -e "${CYAN}2. Clean up temporary files:${NC}"
            echo "   rm -rf /tmp/${SCRIPT_NAME}_*"
            echo -e "${CYAN}3. Check memory usage:${NC}"
            echo "   free -h"
            ;;
        *)
            echo -e "${CYAN}1. Check the error message above for specifics${NC}"
            echo -e "${CYAN}2. Review the documentation:${NC}"
            echo "   ./help.sh $COMPONENT_NAME"
            echo -e "${CYAN}3. Check logs for more details:${NC}"
            echo "   tail -f $ERROR_LOG"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Need more help?${NC}"
    echo "  • Run: $SCRIPT_NAME --help"
    echo "  • Check: quality/reports/error.log"
    echo "  • Review: quality/error-patterns.md"
    echo ""
}

# ============================================================================
# RETRY MECHANISM
# ============================================================================

# Execute command with retry logic
execute_with_retry() {
    local command="$1"
    local max_attempts="${2:-$MAX_RETRY_ATTEMPTS}"
    local delay="${3:-$RETRY_DELAY}"
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_debug "RETRY_ATTEMPT" "Executing: $command (attempt $attempt/$max_attempts)"
        
        local output
        local exit_code
        
        # Execute command and capture output
        if output=$(eval "$command" 2>&1); then
            log_info "COMMAND_SUCCESS" "Command succeeded on attempt $attempt"
            echo "$output"
            return 0
        else
            exit_code=$?
            
            local error_type=$(classify_error "$exit_code" "$output")
            log_warn "COMMAND_FAILED" "Command failed on attempt $attempt/$max_attempts: $command"
            log_debug "COMMAND_OUTPUT" "$output"
            
            # Check if retryable
            if is_retryable_error "$error_type" "$output"; then
                if [ $attempt -lt $max_attempts ]; then
                    log_info "RETRY_SCHEDULED" "Retrying in ${delay}s..."
                    sleep "$delay"
                    ((delay *= 2))  # Exponential backoff
                fi
            else
                log_error "COMMAND_NOT_RETRYABLE" "Non-retryable error, aborting"
                echo "$output" >&2
                return $exit_code
            fi
        fi
        
        ((attempt++))
    done
    
    log_error "COMMAND_MAX_RETRIES" "Command failed after $max_attempts attempts: $command"
    echo "$output" >&2
    return 1
}

# ============================================================================
# MAIN ERROR HANDLER
# ============================================================================

# Main error handling function
handle_error() {
    local exit_code="$1"
    local line_number="$2"
    local error_message="${3:-Unknown error}"
    local command="${4:-Unknown command}"
    
    # Collect context
    local error_context=$(collect_error_context "$@")
    local stack_trace=""
    
    if [ "$ENABLE_STACK_TRACE" = "true" ]; then
        stack_trace=$(generate_stack_trace)
    fi
    
    # Classify error
    local error_type=$(classify_error "$exit_code" "$error_message")
    
    # Create comprehensive error report
    local error_report
    error_report=$(cat << EOF
{
  "error_type": "$error_type",
  "exit_code": $exit_code,
  "line_number": $line_number,
  "message": "$error_message",
  "command": "$command",
  "stack_trace": $stack_trace,
  "context": $error_context
}
EOF
)
    
    # Log the error
    log_error "$error_type" "$error_message" "$error_report"
    
    # Attempt automatic recovery
    if attempt_auto_recovery "$error_type" "$error_report"; then
        log_info "ERROR_RECOVERED" "Successfully recovered from error"
        return 0
    fi
    
    # Provide user guidance
    provide_user_guidance "$error_type" "$error_message" "$error_report"
    
    # Exit with original code
    return $exit_code
}

# ============================================================================
# TRAP HANDLERS
# ============================================================================

# Set up error trapping
setup_error_handling() {
    # Initialize logging
    init_logging
    
    # Set up trap for errors
    trap 'handle_error $? $LINENO "${BASH_COMMAND}" "${BASH_COMMAND}"' ERR
    
    # Set up trap for exit
    trap 'cleanup_on_exit' EXIT
    
    # Set up trap for interruption
    trap 'handle_interruption' INT TERM
    
    log_info "ERROR_HANDLING_INITIALIZED" "Error handling system initialized for $SCRIPT_NAME"
}

# Handle script interruption
handle_interruption() {
    log_warn "SCRIPT_INTERRUPTED" "Script was interrupted by user"
    echo ""
    echo -e "${YELLOW}Script interrupted. Cleaning up...${NC}"
    cleanup_on_exit
    exit 130
}

# Cleanup function called on exit
cleanup_on_exit() {
    local exit_code=$?
    
    # Clean up temporary files
    if [ -n "${TEMP_FILES:-}" ]; then
        for temp_file in $TEMP_FILES; do
            if [ -f "$temp_file" ]; then
                rm -f "$temp_file"
                log_debug "CLEANUP" "Removed temporary file: $temp_file"
            fi
        done
    fi
    
    # Log exit
    if [ $exit_code -eq 0 ]; then
        log_info "SCRIPT_COMPLETED" "Script completed successfully"
    else
        log_error "SCRIPT_FAILED" "Script exited with code: $exit_code"
    fi
}

# ============================================================================
# VALIDATION HELPERS
# ============================================================================

# Validate required parameters
validate_required_param() {
    local param_value="$1"
    local param_name="$2"
    local param_description="${3:-$param_name}"
    
    if [ -z "$param_value" ]; then
        handle_error 1 "$LINENO" "Missing required parameter: $param_name" "validate_required_param"
        echo ""
        echo -e "${YELLOW}Parameter required: $param_description${NC}"
        echo "Please provide the $param_name parameter and try again."
        return 1
    fi
}

# Validate file exists
validate_file_exists() {
    local file_path="$1"
    local file_description="${2:-file}"
    
    if [ ! -f "$file_path" ]; then
        local error_context="{\"missing_file\": \"$file_path\"}"
        handle_error 1 "$LINENO" "$file_description not found: $file_path" "validate_file_exists"
        return 1
    fi
}

# Validate directory exists
validate_directory_exists() {
    local dir_path="$1"
    local dir_description="${2:-directory}"
    
    if [ ! -d "$dir_path" ]; then
        local error_context="{\"missing_directory\": \"$dir_path\"}"
        handle_error 1 "$LINENO" "$dir_description not found: $dir_path" "validate_directory_exists"
        return 1
    fi
}

# ============================================================================
# SAFE OPERATION WRAPPERS
# ============================================================================

# Safe file copy
safe_copy() {
    local source="$1"
    local target="$2"
    
    validate_file_exists "$source" "Source file"
    
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir" || {
            handle_error $? "$LINENO" "Failed to create target directory: $target_dir" "safe_copy"
            return 1
        }
    fi
    
    cp "$source" "$target" || {
        handle_error $? "$LINENO" "Failed to copy $source to $target" "safe_copy"
        return 1
    }
    
    log_info "FILE_COPIED" "Successfully copied $source to $target"
}

# Safe command execution
safe_execute() {
    local command="$1"
    local description="${2:-command}"
    
    log_info "EXECUTING_COMMAND" "Executing: $description"
    log_debug "COMMAND_DETAILS" "Command: $command"
    
    if ! eval "$command"; then
        handle_error $? "$LINENO" "Failed to execute: $description" "$command"
        return 1
    fi
    
    log_info "COMMAND_SUCCESS" "Successfully executed: $description"
}

# ============================================================================
# USAGE EXAMPLE
# ============================================================================

# Example usage function (remove or modify for your script)
example_usage() {
    echo "Error Handling Template Usage Example:"
    echo ""
    echo "# At the beginning of your script:"
    echo "source \"\$(dirname \"\${BASH_SOURCE[0]}\")/templates/error-handling-template.sh\""
    echo "setup_error_handling"
    echo ""
    echo "# Use validation functions:"
    echo "validate_required_param \"\$1\" \"input_file\" \"Path to input file\""
    echo "validate_file_exists \"\$1\" \"Input file\""
    echo ""
    echo "# Use safe operations:"
    echo "safe_copy \"\$1\" \"\$2\""
    echo "safe_execute \"git commit -m 'Update'\" \"Git commit\""
    echo ""
    echo "# Use retry mechanism:"
    echo "execute_with_retry \"curl https://api.example.com/data\" 3 2"
    echo ""
    echo "# Manual logging:"
    echo "log_info \"PROCESS_STARTED\" \"Processing file: \$1\""
    echo "log_error \"VALIDATION_FAILED\" \"Invalid data format\""
}

# ============================================================================
# SCRIPT INITIALIZATION
# ============================================================================

# Auto-setup if this script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error Handling Template for Level-1-Dev Scripts"
    echo "This file should be sourced by other scripts."
    echo ""
    example_usage
fi