#!/bin/bash

# MCP Reliability Monitor - Production Hardening
# Implements heartbeat, health checks, and intelligent fallback detection
# Research-validated patterns for Claude Code MCP server reliability

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
MCP_LOG="$PROJECT_ROOT/.claude/logs/mcp-reliability.log"
MCP_HEALTH_LOG="$PROJECT_ROOT/.claude/logs/mcp-health.log"
MCP_FALLBACK_LOG="$PROJECT_ROOT/.claude/logs/mcp-fallback.log"
HEALTH_CHECK_INTERVAL=30  # seconds
MAX_RETRY_ATTEMPTS=3
CIRCUIT_BREAKER_THRESHOLD=5

# Ensure log directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Generate health check correlation ID
generate_health_id() {
    echo "health_$(date +%s)_$(openssl rand -hex 3)" 2>/dev/null || echo "health_$(date +%s)_fallback"
}

# MCP Server Health Check
check_mcp_server_health() {
    local server_name="$1"
    local server_type="$2"
    local health_id=$(generate_health_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local status="unknown"
    local response_time=0
    local error_message=""

    case "$server_type" in
        "perplexity")
            # Check Perplexity MCP server
            if command -v node >/dev/null 2>&1; then
                local start_time=$(date +%s.%3N)

                # Test basic connectivity and API key validation
                if [[ -n "$PERPLEXITY_API_KEY" ]]; then
                    # Simulate lightweight health check (use gtimeout on macOS if available)
                    local timeout_cmd="timeout"
                    if command -v gtimeout >/dev/null 2>&1; then
                        timeout_cmd="gtimeout"
                    elif ! command -v timeout >/dev/null 2>&1; then
                        timeout_cmd=""
                    fi

                    local test_response
                    if [[ -n "$timeout_cmd" ]]; then
                        test_response=$($timeout_cmd 10 curl -s -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
                            "https://api.perplexity.ai/chat/completions" \
                            -H "Content-Type: application/json" \
                            -d '{"model": "llama-3.1-sonar-small-128k-online", "messages": [{"role": "user", "content": "health"}], "max_tokens": 1}' 2>&1 || echo "error")
                    else
                        test_response=$(curl -s -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
                            "https://api.perplexity.ai/chat/completions" \
                            -H "Content-Type: application/json" \
                            -d '{"model": "llama-3.1-sonar-small-128k-online", "messages": [{"role": "user", "content": "health"}], "max_tokens": 1}' 2>&1 || echo "error")
                    fi

                    local end_time=$(date +%s.%3N)
                    response_time=$(awk "BEGIN {print $end_time - $start_time}")

                    if echo "$test_response" | grep -q "error\|Error\|ERROR"; then
                        status="unhealthy"
                        error_message=$(echo "$test_response" | head -1)
                    elif echo "$test_response" | grep -q "choices\|content"; then
                        status="healthy"
                    else
                        status="degraded"
                        error_message="Unexpected response format"
                    fi
                else
                    status="misconfigured"
                    error_message="PERPLEXITY_API_KEY not set"
                fi
            else
                status="unavailable"
                error_message="Node.js not available"
            fi
            ;;

        "elevenlabs")
            # Check ElevenLabs MCP server
            if [[ -n "$ELEVENLABS_API_KEY" ]]; then
                local start_time=$(date +%s.%3N)

                # Test ElevenLabs API connectivity
                local timeout_cmd="timeout"
                if command -v gtimeout >/dev/null 2>&1; then
                    timeout_cmd="gtimeout"
                elif ! command -v timeout >/dev/null 2>&1; then
                    timeout_cmd=""
                fi

                local test_response
                if [[ -n "$timeout_cmd" ]]; then
                    test_response=$($timeout_cmd 10 curl -s -H "xi-api-key: $ELEVENLABS_API_KEY" \
                        "https://api.elevenlabs.io/v1/voices" 2>&1 || echo "error")
                else
                    test_response=$(curl -s -H "xi-api-key: $ELEVENLABS_API_KEY" \
                        "https://api.elevenlabs.io/v1/voices" 2>&1 || echo "error")
                fi

                local end_time=$(date +%s.%3N)
                response_time=$(awk "BEGIN {print $end_time - $start_time}")

                if echo "$test_response" | grep -q "error\|Error\|ERROR"; then
                    status="unhealthy"
                    error_message=$(echo "$test_response" | head -1)
                elif echo "$test_response" | grep -q "voices\|voice_id"; then
                    status="healthy"
                else
                    status="degraded"
                    error_message="Unexpected response format"
                fi
            else
                status="misconfigured"
                error_message="ELEVENLABS_API_KEY not set"
            fi
            ;;

        *)
            status="unknown_type"
            error_message="Unknown MCP server type: $server_type"
            ;;
    esac

    # Log health check result
    local health_entry="{\"timestamp\":\"$timestamp\",\"health_id\":\"$health_id\",\"server_name\":\"$server_name\",\"server_type\":\"$server_type\",\"status\":\"$status\",\"response_time\":$response_time,\"error_message\":\"$error_message\"}"
    echo "$health_entry" >> "$MCP_HEALTH_LOG"

    echo "$timestamp HEALTH_CHECK: ID=$health_id Server=$server_name Type=$server_type Status=$status ResponseTime=${response_time}s Error=\"$error_message\"" >> "$MCP_LOG"

    # Return status for caller
    echo "$status|$response_time|$error_message"
}

# Circuit Breaker Pattern Implementation
check_circuit_breaker() {
    local server_name="$1"
    local current_time=$(date +%s)
    local failure_count=0

    # Count failures in the last 5 minutes
    if [[ -f "$MCP_HEALTH_LOG" ]]; then
        local five_minutes_ago=$((current_time - 300))
        failure_count=$(grep "\"server_name\":\"$server_name\"" "$MCP_HEALTH_LOG" | \
                       grep "\"status\":\"unhealthy\|\"status\":\"degraded" | \
                       awk -F'"timestamp":"' '{print $2}' | awk -F'"' '{print $1}' | \
                       while read -r timestamp; do
                           local ts_epoch=$(date -d "$timestamp" +%s 2>/dev/null || echo 0)
                           if [[ $ts_epoch -gt $five_minutes_ago ]]; then
                               echo 1
                           fi
                       done | wc -l)
    fi

    if [[ $failure_count -ge $CIRCUIT_BREAKER_THRESHOLD ]]; then
        echo "open"  # Circuit breaker open - don't try MCP
    else
        echo "closed"  # Circuit breaker closed - MCP available
    fi
}

# Intelligent Retry Logic with Exponential Backoff
retry_mcp_operation() {
    local server_name="$1"
    local server_type="$2"
    local operation="$3"
    local attempt=1
    local delay=1

    while [[ $attempt -le $MAX_RETRY_ATTEMPTS ]]; do
        local health_result=$(check_mcp_server_health "$server_name" "$server_type")
        local status=$(echo "$health_result" | cut -d'|' -f1)

        if [[ "$status" == "healthy" ]]; then
            echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') RETRY_SUCCESS: Server=$server_name Attempt=$attempt Operation=$operation" >> "$MCP_LOG"
            return 0
        fi

        echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') RETRY_ATTEMPT: Server=$server_name Attempt=$attempt/$MAX_RETRY_ATTEMPTS Status=$status Delay=${delay}s" >> "$MCP_LOG"

        if [[ $attempt -lt $MAX_RETRY_ATTEMPTS ]]; then
            sleep "$delay"
            delay=$((delay * 2))  # Exponential backoff
        fi

        attempt=$((attempt + 1))
    done

    echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') RETRY_FAILED: Server=$server_name MaxAttempts=$MAX_RETRY_ATTEMPTS Operation=$operation" >> "$MCP_LOG"
    return 1
}

# Fallback Detection and Logging
detect_and_log_fallback() {
    local tool_name="$1"
    local fallback_reason="$2"
    local fallback_id="fallback_$(date +%s)_$(openssl rand -hex 3)"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    # Log fallback event
    local fallback_entry="{\"timestamp\":\"$timestamp\",\"fallback_id\":\"$fallback_id\",\"tool\":\"$tool_name\",\"reason\":\"$fallback_reason\",\"session_id\":\"${CLAUDE_SESSION_ID:-unknown}\"}"
    echo "$fallback_entry" >> "$MCP_FALLBACK_LOG"

    echo "$timestamp FALLBACK_DETECTED: ID=$fallback_id Tool=$tool_name Reason=$fallback_reason" >> "$MCP_LOG"

    # Alert if too many fallbacks
    local recent_fallbacks=$(grep "FALLBACK_DETECTED" "$MCP_LOG" | grep "$(date '+%Y-%m-%d')" | wc -l)
    if [[ $recent_fallbacks -gt 5 ]]; then
        echo "WARNING: High fallback rate detected ($recent_fallbacks today) - investigate MCP reliability" >&2
    fi
}

# Main Health Monitoring Function
monitor_mcp_reliability() {
    local tool_name="${1:-unknown}"
    local operation="${2:-health_check}"

    # Determine server type from tool name
    local server_name=""
    local server_type=""

    case "$tool_name" in
        *"perplexity"*|*"mcp__perplexity"*)
            server_name="perplexity-ask"
            server_type="perplexity"
            ;;
        *"elevenlabs"*|*"mcp__ElevenLabs"*)
            server_name="elevenlabs"
            server_type="elevenlabs"
            ;;
        *)
            # Not an MCP tool - skip monitoring
            return 0
            ;;
    esac

    # Check circuit breaker status
    local circuit_status=$(check_circuit_breaker "$server_name")
    if [[ "$circuit_status" == "open" ]]; then
        detect_and_log_fallback "$tool_name" "circuit_breaker_open"
        echo "CIRCUIT_BREAKER_OPEN: Server $server_name unavailable - recommend direct API fallback" >&2
        return 1
    fi

    # Perform health check
    local health_result=$(check_mcp_server_health "$server_name" "$server_type")
    local status=$(echo "$health_result" | cut -d'|' -f1)
    local response_time=$(echo "$health_result" | cut -d'|' -f2)
    local error_message=$(echo "$health_result" | cut -d'|' -f3)

    case "$status" in
        "healthy")
            echo "MCP_HEALTHY: Server $server_name operational (${response_time}s)" >&2
            return 0
            ;;
        "degraded")
            echo "MCP_DEGRADED: Server $server_name slow/unstable (${response_time}s)" >&2
            # Try retry logic
            if retry_mcp_operation "$server_name" "$server_type" "$operation"; then
                return 0
            else
                detect_and_log_fallback "$tool_name" "degraded_performance"
                return 1
            fi
            ;;
        "unhealthy"|"misconfigured"|"unavailable")
            echo "MCP_UNHEALTHY: Server $server_name failed - $error_message" >&2
            detect_and_log_fallback "$tool_name" "$status"
            return 1
            ;;
        *)
            echo "MCP_UNKNOWN: Server $server_name status unknown" >&2
            detect_and_log_fallback "$tool_name" "unknown_status"
            return 1
            ;;
    esac
}

# Environment Validation
validate_mcp_environment() {
    echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') ENV_CHECK: Starting MCP environment validation" >> "$MCP_LOG"

    # Check API keys
    if [[ -z "$PERPLEXITY_API_KEY" ]]; then
        echo "WARNING: PERPLEXITY_API_KEY not set - Perplexity MCP will fail" >&2
    fi

    if [[ -z "$ELEVENLABS_API_KEY" ]]; then
        echo "WARNING: ELEVENLABS_API_KEY not set - ElevenLabs MCP will fail" >&2
    fi

    # Check network connectivity
    if ! ping -c 1 api.perplexity.ai >/dev/null 2>&1; then
        echo "WARNING: Cannot reach api.perplexity.ai - network issues detected" >&2
    fi

    if ! ping -c 1 api.elevenlabs.io >/dev/null 2>&1; then
        echo "WARNING: Cannot reach api.elevenlabs.io - network issues detected" >&2
    fi

    echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') ENV_CHECK: MCP environment validation complete" >> "$MCP_LOG"
}

# Generate MCP Health Report
generate_health_report() {
    local today=$(date '+%Y-%m-%d')
    local report_file="$PROJECT_ROOT/.claude/logs/mcp-health-report-$today.json"

    local perplexity_checks=$(grep "$today" "$MCP_HEALTH_LOG" | grep "perplexity" | wc -l)
    local perplexity_healthy=$(grep "$today" "$MCP_HEALTH_LOG" | grep "perplexity" | grep "\"healthy\"" | wc -l)
    local elevenlabs_checks=$(grep "$today" "$MCP_HEALTH_LOG" | grep "elevenlabs" | wc -l)
    local elevenlabs_healthy=$(grep "$today" "$MCP_HEALTH_LOG" | grep "elevenlabs" | grep "\"healthy\"" | wc -l)
    local total_fallbacks=$(grep "$today" "$MCP_FALLBACK_LOG" | wc -l)

    cat > "$report_file" <<EOF
{
  "date": "$today",
  "generated_at": "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')",
  "perplexity": {
    "total_checks": $perplexity_checks,
    "healthy_checks": $perplexity_healthy,
    "health_rate": $(awk "BEGIN {if($perplexity_checks > 0) printf \"%.2f\", $perplexity_healthy / $perplexity_checks * 100; else print 0}")
  },
  "elevenlabs": {
    "total_checks": $elevenlabs_checks,
    "healthy_checks": $elevenlabs_healthy,
    "health_rate": $(awk "BEGIN {if($elevenlabs_checks > 0) printf \"%.2f\", $elevenlabs_healthy / $elevenlabs_checks * 100; else print 0}")
  },
  "fallbacks": {
    "total_today": $total_fallbacks
  }
}
EOF

    echo "MCP health report generated: $report_file" >&2
}

# Main execution
main() {
    local tool_name="${1:-unknown}"
    local operation="${2:-health_check}"

    case "$operation" in
        "validate_environment")
            validate_mcp_environment
            ;;
        "health_report")
            generate_health_report
            ;;
        *)
            monitor_mcp_reliability "$tool_name" "$operation"
            ;;
    esac
}

# Execute main function
main "$@"
