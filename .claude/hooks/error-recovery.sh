#!/bin/bash

# Enhanced Error Recovery System - Claude Code Native
# Implements exponential backoff, circuit breaker, and graceful degradation
# Version: 1.0.0

# Configuration
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
ERROR_LOG="$PROJECT_ROOT/.claude/logs/error-recovery.log"
STATE_FILE="$PROJECT_ROOT/.claude/state/circuit-breaker.json"
RECOVERY_LOG="$PROJECT_ROOT/.claude/logs/recovery-attempts.log"

# Circuit breaker settings
FAILURE_THRESHOLD=5
RESET_TIMEOUT=300  # 5 minutes
HALF_OPEN_REQUESTS=2

# Retry settings
MAX_RETRIES=3
INITIAL_DELAY=1
MAX_DELAY=60
BACKOFF_MULTIPLIER=2

# Ensure directories exist
mkdir -p "$(dirname "$ERROR_LOG")"
mkdir -p "$(dirname "$STATE_FILE")"

# =============================================================================
# EXPONENTIAL BACKOFF
# =============================================================================

calculate_backoff_delay() {
    local attempt=$1
    local delay=$INITIAL_DELAY
    
    for ((i=1; i<attempt; i++)); do
        delay=$((delay * BACKOFF_MULTIPLIER))
        if [[ $delay -gt $MAX_DELAY ]]; then
            delay=$MAX_DELAY
            break
        fi
    done
    
    # Add jitter (0-25% random variation)
    local jitter=$((RANDOM % (delay / 4)))
    delay=$((delay + jitter))
    
    echo "$delay"
}

retry_with_backoff() {
    local command="$1"
    local operation="${2:-operation}"
    local attempt=0
    local success=false
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting retry for: $operation" >> "$RECOVERY_LOG"
    
    while [[ $attempt -lt $MAX_RETRIES ]]; do
        ((attempt++))
        
        echo "[RETRY] Attempt $attempt/$MAX_RETRIES for $operation" >> "$ERROR_LOG"
        
        if eval "$command"; then
            echo "[SUCCESS] $operation succeeded on attempt $attempt" >> "$ERROR_LOG"
            success=true
            break
        else
            local exit_code=$?
            echo "[FAILURE] $operation failed with code $exit_code on attempt $attempt" >> "$ERROR_LOG"
            
            if [[ $attempt -lt $MAX_RETRIES ]]; then
                local delay=$(calculate_backoff_delay "$attempt")
                echo "[BACKOFF] Waiting ${delay}s before retry..." >> "$ERROR_LOG"
                sleep "$delay"
            fi
        fi
    done
    
    if $success; then
        return 0
    else
        echo "[EXHAUSTED] All retry attempts failed for $operation" >> "$ERROR_LOG"
        return 1
    fi
}

# =============================================================================
# CIRCUIT BREAKER
# =============================================================================

init_circuit_breaker() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" <<EOF
{
    "state": "closed",
    "failure_count": 0,
    "last_failure": null,
    "last_success": null,
    "half_open_count": 0
}
EOF
    fi
}

get_circuit_state() {
    init_circuit_breaker
    jq -r '.state' "$STATE_FILE"
}

update_circuit_state() {
    local new_state="$1"
    local timestamp=$(date +%s)
    
    jq --arg state "$new_state" --arg ts "$timestamp" \
        '.state = $state | .last_update = ($ts | tonumber)' \
        "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
}

record_failure() {
    local timestamp=$(date +%s)
    local current_failures=$(jq -r '.failure_count' "$STATE_FILE")
    ((current_failures++))
    
    jq --arg ts "$timestamp" --arg fc "$current_failures" \
        '.failure_count = ($fc | tonumber) | .last_failure = ($ts | tonumber)' \
        "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    
    # Check if we should open the circuit
    if [[ $current_failures -ge $FAILURE_THRESHOLD ]]; then
        echo "[CIRCUIT BREAKER] Opening circuit after $current_failures failures" >> "$ERROR_LOG"
        update_circuit_state "open"
    fi
}

record_success() {
    local timestamp=$(date +%s)
    local current_state=$(get_circuit_state)
    
    if [[ "$current_state" == "half_open" ]]; then
        local half_open_count=$(jq -r '.half_open_count' "$STATE_FILE")
        ((half_open_count++))
        
        if [[ $half_open_count -ge $HALF_OPEN_REQUESTS ]]; then
            echo "[CIRCUIT BREAKER] Closing circuit after successful half-open requests" >> "$ERROR_LOG"
            jq --arg ts "$timestamp" \
                '.state = "closed" | .failure_count = 0 | .half_open_count = 0 | .last_success = ($ts | tonumber)' \
                "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
        else
            jq --arg ts "$timestamp" --arg hoc "$half_open_count" \
                '.half_open_count = ($hoc | tonumber) | .last_success = ($ts | tonumber)' \
                "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
        fi
    else
        jq --arg ts "$timestamp" \
            '.failure_count = 0 | .last_success = ($ts | tonumber)' \
            "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi
}

check_circuit_timeout() {
    local current_state=$(get_circuit_state)
    
    if [[ "$current_state" == "open" ]]; then
        local last_failure=$(jq -r '.last_failure' "$STATE_FILE")
        local current_time=$(date +%s)
        local time_diff=$((current_time - last_failure))
        
        if [[ $time_diff -ge $RESET_TIMEOUT ]]; then
            echo "[CIRCUIT BREAKER] Moving to half-open state after timeout" >> "$ERROR_LOG"
            update_circuit_state "half_open"
            jq '.half_open_count = 0' "$STATE_FILE" > "${STATE_FILE}.tmp" && \
                mv "${STATE_FILE}.tmp" "$STATE_FILE"
        fi
    fi
}

execute_with_circuit_breaker() {
    local command="$1"
    local operation="${2:-operation}"
    
    init_circuit_breaker
    check_circuit_timeout
    
    local state=$(get_circuit_state)
    
    case "$state" in
        "open")
            echo "[CIRCUIT BREAKER] Circuit is OPEN - rejecting $operation" >> "$ERROR_LOG"
            return 1
            ;;
        "half_open")
            echo "[CIRCUIT BREAKER] Circuit is HALF-OPEN - attempting $operation" >> "$ERROR_LOG"
            if eval "$command"; then
                record_success
                return 0
            else
                record_failure
                return 1
            fi
            ;;
        "closed")
            if eval "$command"; then
                record_success
                return 0
            else
                record_failure
                return 1
            fi
            ;;
    esac
}

# =============================================================================
# GRACEFUL DEGRADATION
# =============================================================================

fallback_to_cache() {
    local operation="$1"
    local cache_file="$PROJECT_ROOT/.claude/cache/${operation}.cache"
    
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file") ))
        local max_cache_age=3600  # 1 hour
        
        if [[ $cache_age -lt $max_cache_age ]]; then
            echo "[FALLBACK] Using cached result for $operation (age: ${cache_age}s)" >> "$ERROR_LOG"
            cat "$cache_file"
            return 0
        else
            echo "[FALLBACK] Cache too old for $operation (age: ${cache_age}s)" >> "$ERROR_LOG"
            return 1
        fi
    else
        echo "[FALLBACK] No cache available for $operation" >> "$ERROR_LOG"
        return 1
    fi
}

degraded_mode_operation() {
    local full_command="$1"
    local degraded_command="$2"
    local operation="${3:-operation}"
    
    echo "[DEGRADED MODE] Attempting full operation: $operation" >> "$ERROR_LOG"
    
    if execute_with_circuit_breaker "$full_command" "$operation"; then
        return 0
    else
        echo "[DEGRADED MODE] Full operation failed, trying degraded mode" >> "$ERROR_LOG"
        
        if [[ -n "$degraded_command" ]]; then
            if eval "$degraded_command"; then
                echo "[DEGRADED MODE] Degraded operation succeeded" >> "$ERROR_LOG"
                return 0
            fi
        fi
        
        # Last resort: try cache
        if fallback_to_cache "$operation"; then
            echo "[DEGRADED MODE] Cache fallback succeeded" >> "$ERROR_LOG"
            return 0
        fi
        
        echo "[DEGRADED MODE] All fallback options exhausted" >> "$ERROR_LOG"
        return 1
    fi
}

# =============================================================================
# ERROR CATEGORIZATION AND HANDLING
# =============================================================================

categorize_error() {
    local exit_code=$1
    local error_message="${2:-}"
    
    case "$exit_code" in
        1)
            echo "general_error"
            ;;
        2)
            echo "usage_error"
            ;;
        126)
            echo "permission_denied"
            ;;
        127)
            echo "command_not_found"
            ;;
        *)
            if echo "$error_message" | grep -qi "401\|unauthorized"; then
                echo "auth_error"
            elif echo "$error_message" | grep -qi "429\|rate"; then
                echo "rate_limit"
            elif echo "$error_message" | grep -qi "500\|502\|503"; then
                echo "server_error"
            elif echo "$error_message" | grep -qi "timeout"; then
                echo "timeout_error"
            elif echo "$error_message" | grep -qi "network\|connection"; then
                echo "network_error"
            else
                echo "unknown_error"
            fi
            ;;
    esac
}

handle_error_by_type() {
    local error_type="$1"
    local operation="$2"
    
    echo "[ERROR HANDLER] Handling $error_type for $operation" >> "$ERROR_LOG"
    
    case "$error_type" in
        "auth_error")
            echo "[ACTION] Checking API key validity..." >> "$ERROR_LOG"
            # Trigger API key validation
            "$PROJECT_ROOT/.claude/hooks/simplified/pre-tool-validation.sh" check_keys
            ;;
        "rate_limit")
            echo "[ACTION] Rate limit hit, backing off..." >> "$ERROR_LOG"
            sleep 30
            ;;
        "server_error"|"timeout_error"|"network_error")
            echo "[ACTION] Transient error, will retry with backoff" >> "$ERROR_LOG"
            return 0  # Allow retry
            ;;
        "permission_denied")
            echo "[ACTION] Permission issue, checking file permissions..." >> "$ERROR_LOG"
            # Check and fix permissions if possible
            ;;
        *)
            echo "[ACTION] Generic error handling" >> "$ERROR_LOG"
            ;;
    esac
}

# =============================================================================
# RECOVERY PROCEDURES
# =============================================================================

recover_from_error() {
    local exit_code=$1
    local operation="${2:-unknown}"
    local error_message="${3:-}"
    
    echo "[RECOVERY] Starting recovery for $operation (exit code: $exit_code)" >> "$ERROR_LOG"
    
    # Categorize the error
    local error_type=$(categorize_error "$exit_code" "$error_message")
    
    # Handle specific error types
    handle_error_by_type "$error_type" "$operation"
    
    # Determine if retry is appropriate
    case "$error_type" in
        "auth_error"|"permission_denied"|"command_not_found")
            echo "[RECOVERY] Error type '$error_type' is not retryable" >> "$ERROR_LOG"
            return 1
            ;;
        *)
            echo "[RECOVERY] Error type '$error_type' is retryable" >> "$ERROR_LOG"
            return 0
            ;;
    esac
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    local action="${1:-status}"
    shift
    
    case "$action" in
        retry)
            local command="$1"
            local operation="${2:-operation}"
            retry_with_backoff "$command" "$operation"
            ;;
        circuit)
            local command="$1"
            local operation="${2:-operation}"
            execute_with_circuit_breaker "$command" "$operation"
            ;;
        degraded)
            local full_command="$1"
            local degraded_command="$2"
            local operation="${3:-operation}"
            degraded_mode_operation "$full_command" "$degraded_command" "$operation"
            ;;
        recover)
            local exit_code="$1"
            local operation="${2:-unknown}"
            local error_message="${3:-}"
            recover_from_error "$exit_code" "$operation" "$error_message"
            ;;
        status)
            echo "Circuit Breaker State: $(get_circuit_state)"
            echo "Recent Errors: $(tail -5 "$ERROR_LOG" 2>/dev/null | wc -l)"
            echo "Recovery Log: $RECOVERY_LOG"
            ;;
        reset)
            echo "Resetting circuit breaker..."
            update_circuit_state "closed"
            jq '.failure_count = 0 | .half_open_count = 0' "$STATE_FILE" > "${STATE_FILE}.tmp" && \
                mv "${STATE_FILE}.tmp" "$STATE_FILE"
            echo "Circuit breaker reset to CLOSED state"
            ;;
        *)
            echo "Usage: $0 {retry|circuit|degraded|recover|status|reset} [args...]"
            exit 1
            ;;
    esac
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi