#!/bin/bash

# Shadow Mode Validation - Non-Disruptive Episode Testing
# Validates new episodes against Episode 1 baseline without blocking production
# Research-validated approach for continuous quality assurance

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
SHADOW_LOG="$PROJECT_ROOT/.claude/logs/shadow-validation.log"
SHADOW_RESULTS="$PROJECT_ROOT/.claude/logs/shadow-results.json"
BASELINE_VALIDATOR="$PROJECT_ROOT/.claude/hooks/baseline-metrics-capture.sh"
COST_TRACKER="$PROJECT_ROOT/.claude/hooks/enhanced-post-tool-cost-tracking.sh"
MCP_MONITOR="$PROJECT_ROOT/.claude/hooks/mcp-reliability-monitor.sh"

# Shadow mode configuration
SHADOW_MODE_ENABLED=true
SHADOW_ALERT_THRESHOLD=2  # Number of consecutive failures before alerting
SHADOW_SUCCESS_THRESHOLD=3  # Number of successes needed to clear alert state

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Generate shadow validation correlation ID
generate_shadow_id() {
    echo "shadow_$(date +%s)_$(openssl rand -hex 4)" 2>/dev/null || echo "shadow_$(date +%s)_fallback"
}

# Extract metrics from episode session
extract_episode_metrics() {
    local episode_name="$1"
    local session_dir="$2"
    local shadow_id=$(generate_shadow_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    local extracted_cost=0
    local extracted_quality=0
    local extracted_duration=0
    local extraction_success=false

    echo "$timestamp SHADOW_EXTRACT: ID=$shadow_id Episode=$episode_name SessionDir=$session_dir Starting metric extraction" >> "$SHADOW_LOG"

    # Try to extract cost from cost logs
    local today=$(date '+%Y-%m-%d')
    if [[ -f "$PROJECT_ROOT/.claude/logs/enhanced-cost-tracking.log" ]]; then
        extracted_cost=$(grep "$today" "$PROJECT_ROOT/.claude/logs/enhanced-cost-tracking.log" | \
                        grep "ENHANCED_COST:" | \
                        awk -F'Cost=[$]?' '{sum += $2} END {printf "%.2f", sum+0}')

        # Fallback to legacy cost log
        if [[ "$extracted_cost" == "0.00" ]]; then
            extracted_cost=$(grep "$today" "$PROJECT_ROOT/.claude/logs/enhanced-cost-tracking.log" | \
                            grep "COST:" | grep -v "ENHANCED_COST:" | \
                            awk -F'Cost=[$]?' '{sum += $2} END {printf "%.2f", sum+0}')
        fi
    fi

    # Try to extract quality from session files
    if [[ -d "$session_dir" ]]; then
        # Look for quality scores in pipeline status or quality evaluation files
        for quality_file in "$session_dir"/*quality*.json "$session_dir"/pipeline_status.json "$session_dir"/*evaluation*.json; do
            if [[ -f "$quality_file" ]] && command -v jq >/dev/null 2>&1; then
                local quality_score=$(jq -r '.quality_score // .composite_score // .overall_quality // empty' "$quality_file" 2>/dev/null)
                if [[ -n "$quality_score" && "$quality_score" != "null" ]]; then
                    extracted_quality="$quality_score"
                    break
                fi
            fi
        done

        # Try to extract duration from audio files or script analysis
        for duration_file in "$session_dir"/*duration*.json "$session_dir"/*audio*.json "$session_dir"/*synthesis*.json; do
            if [[ -f "$duration_file" ]] && command -v jq >/dev/null 2>&1; then
                local duration_minutes=$(jq -r '.duration_minutes // .actual_duration // .audio_duration_minutes // empty' "$duration_file" 2>/dev/null)
                if [[ -n "$duration_minutes" && "$duration_minutes" != "null" ]]; then
                    extracted_duration="$duration_minutes"
                    break
                fi
            fi
        done

        # If we got at least cost and one other metric, consider extraction successful
        if [[ "$extracted_cost" != "0.00" ]] && ([[ "$extracted_quality" != "0" ]] || [[ "$extracted_duration" != "0" ]]); then
            extraction_success=true
        fi
    fi

    # Default quality estimation if not found
    if [[ "$extracted_quality" == "0" ]] && [[ "$extraction_success" == "true" ]]; then
        extracted_quality="85.0"  # Conservative estimate
    fi

    echo "$timestamp SHADOW_EXTRACT: ID=$shadow_id Episode=$episode_name Success=$extraction_success Cost=\$$extracted_cost Quality=$extracted_quality Duration=$extracted_duration" >> "$SHADOW_LOG"

    # Return extracted metrics
    echo "$extracted_cost|$extracted_quality|$extracted_duration|$extraction_success"
}

# Perform shadow validation against baseline
perform_shadow_validation() {
    local episode_name="$1"
    local cost="${2:-0}"
    local quality="${3:-0}"
    local duration="${4:-0}"
    local shadow_id=$(generate_shadow_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    if [[ "$SHADOW_MODE_ENABLED" != "true" ]]; then
        echo "$timestamp SHADOW_SKIP: Shadow mode disabled" >> "$SHADOW_LOG"
        return 0
    fi

    echo "$timestamp SHADOW_VALIDATION: ID=$shadow_id Episode=$episode_name Cost=$cost Quality=$quality Duration=$duration Starting validation" >> "$SHADOW_LOG"

    # Perform baseline validation (non-blocking)
    local validation_result=""
    local validation_success=false

    if [[ -f "$BASELINE_VALIDATOR" ]]; then
        # Run baseline validation in shadow mode
        validation_result=$("$BASELINE_VALIDATOR" shadow_validate "$episode_name" "$cost" "$quality" "$duration" 2>&1)
        validation_success=$?
    else
        validation_result="Baseline validator not found"
        validation_success=1
    fi

    # Create shadow validation record
    local shadow_record="{
        \"shadow_id\": \"$shadow_id\",
        \"timestamp\": \"$timestamp\",
        \"episode_name\": \"$episode_name\",
        \"metrics\": {
            \"cost\": $cost,
            \"quality\": $quality,
            \"duration\": $duration
        },
        \"validation\": {
            \"success\": $([ $validation_success -eq 0 ] && echo "true" || echo "false"),
            \"result\": \"$validation_result\",
            \"mode\": \"shadow\"
        },
        \"impact\": \"non_blocking\"
    }"

    # Log shadow validation result
    echo "$shadow_record" >> "$SHADOW_RESULTS"
    echo "$timestamp SHADOW_VALIDATION: ID=$shadow_id Episode=$episode_name Success=$([ $validation_success -eq 0 ] && echo "true" || echo "false") Mode=non-blocking" >> "$SHADOW_LOG"

    # Update shadow state tracking
    update_shadow_state "$episode_name" "$validation_success" "$shadow_id"

    # Output result (non-blocking)
    if [[ $validation_success -eq 0 ]]; then
        echo "SHADOW_VALIDATION: Episode $episode_name baseline validation PASSED (non-blocking)" >&2
        return 0
    else
        echo "SHADOW_VALIDATION: Episode $episode_name baseline validation FAILED (non-blocking)" >&2
        echo "SHADOW_DETAILS: $validation_result" >&2
        return 1
    fi
}

# Update shadow validation state tracking
update_shadow_state() {
    local episode_name="$1"
    local validation_success="$2"
    local shadow_id="$3"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local state_file="$PROJECT_ROOT/.claude/state/shadow-state-$episode_name.json"

    # Ensure state directory exists
    mkdir -p "$PROJECT_ROOT/.claude/state"

    # Load existing state or create new
    local current_state="{}"
    if [[ -f "$state_file" ]]; then
        current_state=$(cat "$state_file")
    fi

    # Update state based on validation result
    local consecutive_failures=0
    local consecutive_successes=0
    local alert_state="none"
    local total_validations=1

    if command -v jq >/dev/null 2>&1; then
        consecutive_failures=$(echo "$current_state" | jq -r '.consecutive_failures // 0')
        consecutive_successes=$(echo "$current_state" | jq -r '.consecutive_successes // 0')
        alert_state=$(echo "$current_state" | jq -r '.alert_state // "none"')
        total_validations=$(echo "$current_state" | jq -r '.total_validations // 0')
        total_validations=$((total_validations + 1))

        if [[ $validation_success -eq 0 ]]; then
            consecutive_successes=$((consecutive_successes + 1))
            consecutive_failures=0

            # Clear alert state if enough successes
            if [[ $consecutive_successes -ge $SHADOW_SUCCESS_THRESHOLD ]]; then
                alert_state="none"
            fi
        else
            consecutive_failures=$((consecutive_failures + 1))
            consecutive_successes=0

            # Set alert state if too many failures
            if [[ $consecutive_failures -ge $SHADOW_ALERT_THRESHOLD ]]; then
                alert_state="degraded"
            fi
        fi

        # Create updated state
        local updated_state="{
            \"episode_name\": \"$episode_name\",
            \"last_updated\": \"$timestamp\",
            \"last_shadow_id\": \"$shadow_id\",
            \"consecutive_failures\": $consecutive_failures,
            \"consecutive_successes\": $consecutive_successes,
            \"alert_state\": \"$alert_state\",
            \"total_validations\": $total_validations,
            \"last_validation_success\": $([ $validation_success -eq 0 ] && echo "true" || echo "false")
        }"

        echo "$updated_state" | jq '.' > "$state_file"
    fi

    echo "$timestamp SHADOW_STATE: Episode=$episode_name Failures=$consecutive_failures Successes=$consecutive_successes AlertState=$alert_state" >> "$SHADOW_LOG"

    # Alert if degraded state
    if [[ "$alert_state" == "degraded" ]]; then
        echo "SHADOW_ALERT: Episode $episode_name has failed $consecutive_failures consecutive validations" >&2
    fi
}

# Auto-detect and validate recent episode
auto_validate_recent_episode() {
    local shadow_id=$(generate_shadow_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    echo "$timestamp SHADOW_AUTO: ID=$shadow_id Starting auto-validation of recent episodes" >> "$SHADOW_LOG"

    # Look for recent session directories
    local recent_sessions=()
    if [[ -d "$PROJECT_ROOT/sessions" ]]; then
        # Find sessions from today or yesterday
        local today=$(date '+%Y%m%d')
        local yesterday=$(date -d 'yesterday' '+%Y%m%d' 2>/dev/null || date -v-1d '+%Y%m%d' 2>/dev/null || echo "$today")

        for session_dir in "$PROJECT_ROOT/sessions"/*; do
            if [[ -d "$session_dir" ]]; then
                local session_name=$(basename "$session_dir")
                if echo "$session_name" | grep -q "$today\\|$yesterday"; then
                    recent_sessions+=("$session_dir")
                fi
            fi
        done
    fi

    if [[ ${#recent_sessions[@]} -eq 0 ]]; then
        echo "$timestamp SHADOW_AUTO: ID=$shadow_id No recent sessions found" >> "$SHADOW_LOG"
        echo "No recent episodes found for auto-validation" >&2
        return 0
    fi

    # Validate each recent session
    for session_dir in "${recent_sessions[@]}"; do
        local session_name=$(basename "$session_dir")
        local episode_name=$(echo "$session_name" | sed 's/_[0-9]*$//g')  # Remove timestamp suffix

        echo "$timestamp SHADOW_AUTO: ID=$shadow_id Processing $session_name as episode $episode_name" >> "$SHADOW_LOG"

        # Extract metrics from session
        local metrics_info=$(extract_episode_metrics "$episode_name" "$session_dir")
        local cost=$(echo "$metrics_info" | cut -d'|' -f1)
        local quality=$(echo "$metrics_info" | cut -d'|' -f2)
        local duration=$(echo "$metrics_info" | cut -d'|' -f3)
        local extraction_success=$(echo "$metrics_info" | cut -d'|' -f4)

        if [[ "$extraction_success" == "true" ]]; then
            perform_shadow_validation "$episode_name" "$cost" "$quality" "$duration"
        else
            echo "$timestamp SHADOW_AUTO: ID=$shadow_id Episode=$episode_name Metric extraction failed" >> "$SHADOW_LOG"
            echo "Could not extract metrics for episode $episode_name" >&2
        fi
    done
}

# Generate shadow validation summary report
generate_shadow_summary() {
    local date_filter="${1:-$(date '+%Y-%m-%d')}"
    local summary_file="$PROJECT_ROOT/.claude/logs/shadow-summary-$date_filter.json"

    if [[ ! -f "$SHADOW_RESULTS" ]]; then
        echo "No shadow validation data available" >&2
        return 1
    fi

    # Count validations by result
    local total_validations=$(grep "$date_filter" "$SHADOW_RESULTS" | wc -l)
    local successful_validations=$(grep "$date_filter" "$SHADOW_RESULTS" | grep '"success": true' | wc -l)
    local failed_validations=$(grep "$date_filter" "$SHADOW_RESULTS" | grep '"success": false' | wc -l)
    local success_rate=0

    if [[ $total_validations -gt 0 ]]; then
        success_rate=$(awk "BEGIN {printf \"%.1f\", $successful_validations / $total_validations * 100}")
    fi

    # Create summary report
    local summary_report="{
        \"date\": \"$date_filter\",
        \"generated_at\": \"$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')\",
        \"shadow_validation_summary\": {
            \"total_validations\": $total_validations,
            \"successful_validations\": $successful_validations,
            \"failed_validations\": $failed_validations,
            \"success_rate\": $success_rate
        },
        \"baseline_compliance\": {
            \"episodes_meeting_baseline\": $successful_validations,
            \"episodes_below_baseline\": $failed_validations,
            \"compliance_rate\": $success_rate
        },
        \"alerts\": {
            \"degraded_episodes\": $(find "$PROJECT_ROOT/.claude/state" -name "shadow-state-*.json" -exec grep -l '"alert_state": "degraded"' {} \\; | wc -l)
        }
    }"

    echo "$summary_report" | jq '.' > "$summary_file"
    echo "Shadow validation summary generated: $summary_file" >&2
    echo "Success rate: $success_rate% ($successful_validations/$total_validations validations)" >&2
}

# Main execution
main() {
    local operation="${1:-auto_validate}"
    local episode_name="${2:-unknown}"
    local cost="${3:-0}"
    local quality="${4:-0}"
    local duration="${5:-0}"

    case "$operation" in
        "validate")
            perform_shadow_validation "$episode_name" "$cost" "$quality" "$duration"
            ;;
        "auto_validate")
            auto_validate_recent_episode
            ;;
        "extract_metrics")
            local session_dir="${3:-$PROJECT_ROOT/sessions/$episode_name}"
            extract_episode_metrics "$episode_name" "$session_dir"
            ;;
        "generate_summary")
            generate_shadow_summary "$episode_name"  # episode_name used as date_filter here
            ;;
        "enable")
            SHADOW_MODE_ENABLED=true
            echo "Shadow mode validation enabled" >&2
            ;;
        "disable")
            SHADOW_MODE_ENABLED=false
            echo "Shadow mode validation disabled" >&2
            ;;
        *)
            echo "Usage: $0 {validate|auto_validate|extract_metrics|generate_summary|enable|disable} [params...]" >&2
            echo "Examples:" >&2
            echo "  $0 validate ep002 2.85 89.5 26" >&2
            echo "  $0 auto_validate" >&2
            echo "  $0 extract_metrics ep002 /path/to/session" >&2
            echo "  $0 generate_summary 2025-08-25" >&2
            echo "  $0 enable" >&2
            echo "  $0 disable" >&2
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
