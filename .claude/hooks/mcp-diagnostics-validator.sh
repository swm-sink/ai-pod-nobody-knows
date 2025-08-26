#!/bin/bash

# MCP Server Diagnostics and Validation - Production Health Monitoring
# Comprehensive diagnostic suite for Claude Code MCP server reliability
# Research-validated patterns for production MCP troubleshooting

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
DIAGNOSTICS_LOG="$PROJECT_ROOT/.claude/logs/mcp-diagnostics.log"
VALIDATION_LOG="$PROJECT_ROOT/.claude/logs/mcp-validation.log"
HEALTH_REPORT="$PROJECT_ROOT/.claude/logs/mcp-health-report.json"
MCP_CONFIG_FILE="$PROJECT_ROOT/.mcp.json"

# Known MCP servers for validation (aligned with actual .mcp.json configuration)
get_server_type() {
    case "$1" in
        "perplexity") echo "perplexity" ;;
        "ElevenLabs") echo "elevenlabs" ;;
        "github-local") echo "github" ;;
        "playwright") echo "playwright" ;;
        "langfuse") echo "langfuse" ;;
        *) echo "unknown" ;;
    esac
}

# List of known MCP server names (matching actual .mcp.json)
MCP_SERVER_NAMES="perplexity ElevenLabs github-local playwright langfuse"

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Generate diagnostic correlation ID
generate_diagnostic_id() {
    echo "diag_$(date +%s)_$(openssl rand -hex 4)" 2>/dev/null || echo "diag_$(date +%s)_fallback"
}

# Validate MCP configuration file
validate_mcp_config() {
    local diagnostic_id=$(generate_diagnostic_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local config_valid=true
    local issues=()

    echo "$timestamp CONFIG_VALIDATION: ID=$diagnostic_id Starting MCP configuration validation" >> "$DIAGNOSTICS_LOG"

    # Check if MCP config file exists
    if [[ ! -f "$MCP_CONFIG_FILE" ]]; then
        config_valid=false
        issues+=("MCP configuration file missing: $MCP_CONFIG_FILE")
        echo "$timestamp CONFIG_ERROR: ID=$diagnostic_id MCP config file not found" >> "$DIAGNOSTICS_LOG"

        echo "{\"valid\": false, \"issues\": [\"Missing MCP config file\"]}"
        return 1
    fi

    # Validate JSON syntax
    if ! jq . "$MCP_CONFIG_FILE" >/dev/null 2>&1; then
        config_valid=false
        issues+=("Invalid JSON syntax in MCP configuration")
        echo "$timestamp CONFIG_ERROR: ID=$diagnostic_id Invalid JSON in MCP config" >> "$DIAGNOSTICS_LOG"
    fi

    # Check for required MCP server configurations
    if command -v jq >/dev/null 2>&1; then
        local mcps_section=$(jq '.mcpServers' "$MCP_CONFIG_FILE" 2>/dev/null)
        if [[ "$mcps_section" == "null" ]]; then
            config_valid=false
            issues+=("Missing 'mcpServers' section in configuration")
        else
            # Check each expected MCP server
            for server_name in $MCP_SERVER_NAMES; do
                if ! echo "$mcps_section" | jq -e "has(\"$server_name\")" >/dev/null 2>&1; then
                    issues+=("MCP server '$server_name' not configured")
                fi
            done
        fi
    fi

    # Create validation result
    local validation_result="{
        \"diagnostic_id\": \"$diagnostic_id\",
        \"timestamp\": \"$timestamp\",
        \"config_file\": \"$MCP_CONFIG_FILE\",
        \"valid\": $config_valid,
        \"issues\": $(printf '%s\\n' \"${issues[@]}\" | jq -R . | jq -s .)
    }"

    echo "$validation_result" >> "$VALIDATION_LOG"
    echo "$timestamp CONFIG_VALIDATION: ID=$diagnostic_id Valid=$config_valid Issues=${#issues[@]}" >> "$DIAGNOSTICS_LOG"

    if [[ "$config_valid" == "true" ]]; then
        echo "MCP configuration validation PASSED" >&2
        return 0
    else
        echo "MCP configuration validation FAILED:" >&2
        printf '  - %s\\n' "${issues[@]}" >&2
        return 1
    fi
}

# Test individual MCP server connectivity
test_mcp_server() {
    local server_name="$1"
    local server_type=$(get_server_type "$server_name")
    local diagnostic_id=$(generate_diagnostic_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local test_result="unknown"
    local response_time=0
    local error_details=""

    echo "$timestamp MCP_TEST: ID=$diagnostic_id Server=$server_name Type=$server_type Starting connectivity test" >> "$DIAGNOSTICS_LOG"

    case "$server_type" in
        "perplexity")
            # Test Perplexity MCP server
            if [[ -n "$PERPLEXITY_API_KEY" ]]; then
                local start_time=$(date +%s.%3N)

                # Simulate MCP call through Claude Code (if available)
                # For now, we'll test the underlying API directly
                local timeout_cmd="timeout"
                if command -v gtimeout >/dev/null 2>&1; then
                    timeout_cmd="gtimeout"
                elif ! command -v timeout >/dev/null 2>&1; then
                    timeout_cmd=""
                fi

                local test_response
                if [[ -n "$timeout_cmd" ]]; then
                    test_response=$($timeout_cmd 15 curl -s -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
                        "https://api.perplexity.ai/chat/completions" \
                        -H "Content-Type: application/json" \
                        -d '{"model": "llama-3.1-sonar-small-128k-online", "messages": [{"role": "user", "content": "test"}], "max_tokens": 1}' 2>&1 || echo "error")
                else
                    test_response=$(curl -s -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
                        "https://api.perplexity.ai/chat/completions" \
                        -H "Content-Type: application/json" \
                        -d '{"model": "llama-3.1-sonar-small-128k-online", "messages": [{"role": "user", "content": "test"}], "max_tokens": 1}' 2>&1 || echo "error")
                fi

                local end_time=$(date +%s.%3N)
                response_time=$(awk "BEGIN {print $end_time - $start_time}")

                if echo "$test_response" | grep -q "error\\|Error\\|ERROR"; then
                    test_result="failed"
                    error_details=$(echo "$test_response" | head -1)
                elif echo "$test_response" | grep -q "choices\\|content\\|message"; then
                    test_result="success"
                else
                    test_result="degraded"
                    error_details="Unexpected response format"
                fi
            else
                test_result="misconfigured"
                error_details="PERPLEXITY_API_KEY not set"
            fi
            ;;

        "elevenlabs")
            # Test ElevenLabs MCP server
            if [[ -n "$ELEVENLABS_API_KEY" ]]; then
                local start_time=$(date +%s.%3N)

                local timeout_cmd="timeout"
                if command -v gtimeout >/dev/null 2>&1; then
                    timeout_cmd="gtimeout"
                elif ! command -v timeout >/dev/null 2>&1; then
                    timeout_cmd=""
                fi

                local test_response
                if [[ -n "$timeout_cmd" ]]; then
                    test_response=$($timeout_cmd 15 curl -s -H "xi-api-key: $ELEVENLABS_API_KEY" \
                        "https://api.elevenlabs.io/v1/voices" 2>&1 || echo "error")
                else
                    test_response=$(curl -s -H "xi-api-key: $ELEVENLABS_API_KEY" \
                        "https://api.elevenlabs.io/v1/voices" 2>&1 || echo "error")
                fi

                local end_time=$(date +%s.%3N)
                response_time=$(awk "BEGIN {print $end_time - $start_time}")

                if echo "$test_response" | grep -q "error\\|Error\\|ERROR"; then
                    test_result="failed"
                    error_details=$(echo "$test_response" | head -1)
                elif echo "$test_response" | grep -q "voices\\|voice_id"; then
                    test_result="success"
                else
                    test_result="degraded"
                    error_details="Unexpected response format"
                fi
            else
                test_result="misconfigured"
                error_details="ELEVENLABS_API_KEY not set"
            fi
            ;;

        "github")
            # Test GitHub MCP server
            if [[ -n "$GITHUB_PAT" ]]; then
                local start_time=$(date +%s.%3N)

                local timeout_cmd="timeout"
                if command -v gtimeout >/dev/null 2>&1; then
                    timeout_cmd="gtimeout"
                elif ! command -v timeout >/dev/null 2>&1; then
                    timeout_cmd=""
                fi

                local test_response
                if [[ -n "$timeout_cmd" ]]; then
                    test_response=$($timeout_cmd 15 curl -s -H "Authorization: token $GITHUB_PAT" \
                        "https://api.github.com/user" 2>&1 || echo "error")
                else
                    test_response=$(curl -s -H "Authorization: token $GITHUB_PAT" \
                        "https://api.github.com/user" 2>&1 || echo "error")
                fi

                local end_time=$(date +%s.%3N)
                response_time=$(awk "BEGIN {print $end_time - $start_time}")

                if echo "$test_response" | grep -q "error\\|Error\\|ERROR"; then
                    test_result="failed"
                    error_details=$(echo "$test_response" | head -1)
                elif echo "$test_response" | grep -q "login\\|id"; then
                    test_result="success"
                else
                    test_result="degraded"
                    error_details="Unexpected response format"
                fi
            else
                test_result="misconfigured"
                error_details="GITHUB_PAT not set"
            fi
            ;;

        *)
            # Generic MCP server test (configuration check only)
            if command -v jq >/dev/null 2>&1 && [[ -f "$MCP_CONFIG_FILE" ]]; then
                if jq -e ".mcps.\"$server_name\"" "$MCP_CONFIG_FILE" >/dev/null 2>&1; then
                    test_result="configured"
                    error_details="Server configured but no specific test available"
                else
                    test_result="not_configured"
                    error_details="Server not found in MCP configuration"
                fi
            else
                test_result="unknown"
                error_details="Cannot validate configuration"
            fi
            ;;
    esac

    # Create test result
    local test_record="{
        \"diagnostic_id\": \"$diagnostic_id\",
        \"timestamp\": \"$timestamp\",
        \"server_name\": \"$server_name\",
        \"server_type\": \"$server_type\",
        \"test_result\": \"$test_result\",
        \"response_time\": $response_time,
        \"error_details\": \"$error_details\"
    }"

    echo "$test_record" >> "$VALIDATION_LOG"
    echo "$timestamp MCP_TEST: ID=$diagnostic_id Server=$server_name Result=$test_result ResponseTime=${response_time}s Error=\"$error_details\"" >> "$DIAGNOSTICS_LOG"

    # Return result for caller
    echo "$test_result|$response_time|$error_details"
}

# Comprehensive MCP health check
perform_full_health_check() {
    local diagnostic_id=$(generate_diagnostic_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    echo "$timestamp HEALTH_CHECK: ID=$diagnostic_id Starting comprehensive MCP health check" >> "$DIAGNOSTICS_LOG"

    # Validate configuration first
    local config_validation_result=$(validate_mcp_config)
    local config_valid=$?

    # Test all MCP servers
    local server_results=()
    local total_servers=0
    local healthy_servers=0
    local degraded_servers=0
    local failed_servers=0
    local misconfigured_servers=0

    for server_name in $MCP_SERVER_NAMES; do
        total_servers=$((total_servers + 1))
        local test_info=$(test_mcp_server "$server_name")
        local result=$(echo "$test_info" | cut -d'|' -f1)
        local response_time=$(echo "$test_info" | cut -d'|' -f2)
        local error=$(echo "$test_info" | cut -d'|' -f3)

        server_results+=("{\"server\": \"$server_name\", \"result\": \"$result\", \"response_time\": $response_time, \"error\": \"$error\"}")

        case "$result" in
            "success") healthy_servers=$((healthy_servers + 1)) ;;
            "degraded"|"configured") degraded_servers=$((degraded_servers + 1)) ;;
            "failed") failed_servers=$((failed_servers + 1)) ;;
            "misconfigured"|"not_configured") misconfigured_servers=$((misconfigured_servers + 1)) ;;
        esac
    done

    # Calculate overall health score
    local health_score=0
    if [[ $total_servers -gt 0 ]]; then
        health_score=$(awk "BEGIN {printf \"%.1f\", ($healthy_servers + $degraded_servers * 0.5) / $total_servers * 100}")
    fi

    # Create comprehensive health report
    local health_report="{
        \"diagnostic_id\": \"$diagnostic_id\",
        \"timestamp\": \"$timestamp\",
        \"configuration\": {
            \"valid\": $([ $config_valid -eq 0 ] && echo "true" || echo "false"),
            \"file_path\": \"$MCP_CONFIG_FILE\"
        },
        \"server_health\": {
            \"total_servers\": $total_servers,
            \"healthy_servers\": $healthy_servers,
            \"degraded_servers\": $degraded_servers,
            \"failed_servers\": $failed_servers,
            \"misconfigured_servers\": $misconfigured_servers,
            \"health_score\": $health_score
        },
        \"server_details\": [$(IFS=,; echo "${server_results[*]}")],
        \"recommendations\": []
    }"

    # Add recommendations based on results
    local recommendations=()
    if [[ $config_valid -ne 0 ]]; then
        recommendations+=("\"Fix MCP configuration file\"")
    fi
    if [[ $misconfigured_servers -gt 0 ]]; then
        recommendations+=("\"Configure API keys for misconfigured servers\"")
    fi
    if [[ $failed_servers -gt 0 ]]; then
        recommendations+=("\"Investigate failed server connections\"")
    fi
    if [[ $health_score < 50 ]]; then
        recommendations+=("\"Critical: Most MCP servers unhealthy - investigate system configuration\"")
    fi

    # Update health report with recommendations
    health_report=$(echo "$health_report" | jq ".recommendations = [$(IFS=,; echo "${recommendations[*]}")]")

    # Write health report
    echo "$health_report" | jq '.' > "$HEALTH_REPORT"

    echo "$timestamp HEALTH_CHECK: ID=$diagnostic_id Complete HealthScore=$health_score% Healthy=$healthy_servers/$total_servers" >> "$DIAGNOSTICS_LOG"

    # Output summary
    echo "MCP Health Check Results:"
    echo "  Configuration Valid: $([ $config_valid -eq 0 ] && echo "✓" || echo "✗")"
    echo "  Health Score: $health_score%"
    echo "  Servers: $healthy_servers healthy, $degraded_servers degraded, $failed_servers failed, $misconfigured_servers misconfigured"
    echo "  Report: $HEALTH_REPORT"

    # Return overall status
    if [[ $config_valid -eq 0 && $health_score > 70 ]]; then
        return 0
    else
        return 1
    fi
}

# Validate environment variables
validate_environment() {
    local diagnostic_id=$(generate_diagnostic_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local env_issues=()

    echo "$timestamp ENV_VALIDATION: ID=$diagnostic_id Starting environment validation" >> "$DIAGNOSTICS_LOG"

    # Check required environment variables
    if [[ -z "$PERPLEXITY_API_KEY" ]]; then
        env_issues+=("PERPLEXITY_API_KEY not set")
    fi

    if [[ -z "$ELEVENLABS_API_KEY" ]]; then
        env_issues+=("ELEVENLABS_API_KEY not set")
    fi

    if [[ -z "$GITHUB_PAT" ]]; then
        env_issues+=("GITHUB_PAT not set")
    fi

    # Check .env file exists and is sourced
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        if ! grep -q "PERPLEXITY_API_KEY\|ELEVENLABS_API_KEY\|GITHUB_PAT" "$PROJECT_ROOT/.env"; then
            env_issues+=(".env file exists but may be missing API keys")
        fi
    else
        env_issues+=(".env file missing")
    fi

    # Network connectivity check
    if ! ping -c 1 api.perplexity.ai >/dev/null 2>&1; then
        env_issues+=("Cannot reach api.perplexity.ai")
    fi

    if ! ping -c 1 api.elevenlabs.io >/dev/null 2>&1; then
        env_issues+=("Cannot reach api.elevenlabs.io")
    fi

    if ! ping -c 1 api.github.com >/dev/null 2>&1; then
        env_issues+=("Cannot reach api.github.com")
    fi

    echo "$timestamp ENV_VALIDATION: ID=$diagnostic_id Complete Issues=${#env_issues[@]}" >> "$DIAGNOSTICS_LOG"

    if [[ ${#env_issues[@]} -eq 0 ]]; then
        echo "Environment validation PASSED - all requirements met" >&2
        return 0
    else
        echo "Environment validation FAILED:" >&2
        printf '  - %s\\n' "${env_issues[@]}" >&2
        return 1
    fi
}

# Main execution
main() {
    local operation="${1:-health_check}"
    local server_name="${2:-all}"

    case "$operation" in
        "health_check")
            perform_full_health_check
            ;;
        "validate_config")
            validate_mcp_config
            ;;
        "test_server")
            if [[ "$server_name" == "all" ]]; then
                echo "Testing all MCP servers:" >&2
                for server in "${!MCP_SERVERS[@]}"; do
                    echo "Testing $server..." >&2
                    test_mcp_server "$server"
                done
            else
                test_mcp_server "$server_name"
            fi
            ;;
        "validate_environment")
            validate_environment
            ;;
        "list_servers")
            echo "Configured MCP servers:" >&2
            for server in $MCP_SERVER_NAMES; do
                echo "  - $server ($(get_server_type "$server"))" >&2
            done
            ;;
        *)
            echo "Usage: $0 {health_check|validate_config|test_server|validate_environment|list_servers} [server_name]" >&2
            echo "Examples:" >&2
            echo "  $0 health_check" >&2
            echo "  $0 validate_config" >&2
            echo "  $0 test_server perplexity-ask" >&2
            echo "  $0 test_server all" >&2
            echo "  $0 validate_environment" >&2
            echo "  $0 list_servers" >&2
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
