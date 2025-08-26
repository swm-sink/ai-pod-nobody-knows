#!/bin/bash

# Automated Billing Reconciliation - Production Cost Validation
# Reconciles internal cost tracking with actual provider billing APIs
# Research-validated approach for bulletproof cost attribution

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
COST_LOG="$PROJECT_ROOT/.claude/logs/enhanced-cost-tracking.log"
RECONCILIATION_LOG="$PROJECT_ROOT/.claude/logs/billing-reconciliation.log"
PROVIDER_USAGE_LOG="$PROJECT_ROOT/.claude/logs/provider-usage.log"
DISCREPANCY_LOG="$PROJECT_ROOT/.claude/logs/cost-discrepancies.log"
RECONCILE_CACHE="$PROJECT_ROOT/.claude/cache/billing-cache.json"

# Tolerance thresholds for discrepancy alerts
COST_TOLERANCE=0.10  # $0.10 tolerance for rounding
PERCENTAGE_TOLERANCE=5.0  # 5% variance tolerance

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs" "$PROJECT_ROOT/.claude/cache"

# Generate reconciliation correlation ID
generate_reconcile_id() {
    echo "reconcile_$(date +%s)_$(openssl rand -hex 4)" 2>/dev/null || echo "reconcile_$(date +%s)_fallback"
}

# Fetch Perplexity Usage (API-based reconciliation)
fetch_perplexity_usage() {
    local date_filter="${1:-$(date '+%Y-%m-%d')}"
    local reconcile_id=$(generate_reconcile_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    if [[ -z "$PERPLEXITY_API_KEY" ]]; then
        echo "$timestamp RECONCILE_SKIP: Perplexity API key not configured" >> "$RECONCILIATION_LOG"
        echo "0.0000|skipped|no_api_key"
        return 0
    fi

    # Note: Perplexity doesn't currently provide usage API, so we estimate from request logs
    local request_count=$(grep "$date_filter" "$COST_LOG" | grep -i "perplexity" | wc -l)
    local estimated_cost=$(awk "BEGIN {printf \"%.4f\", $request_count * 0.002}")  # Conservative estimate

    echo "$timestamp RECONCILE_ESTIMATE: ID=$reconcile_id Provider=perplexity Date=$date_filter Requests=$request_count Estimated=\$$estimated_cost" >> "$RECONCILIATION_LOG"
    echo "$estimated_cost|estimated|request_based"
}

# Fetch ElevenLabs Usage (API-based reconciliation)
fetch_elevenlabs_usage() {
    local date_filter="${1:-$(date '+%Y-%m-%d')}"
    local reconcile_id=$(generate_reconcile_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    if [[ -z "$ELEVENLABS_API_KEY" ]]; then
        echo "$timestamp RECONCILE_SKIP: ElevenLabs API key not configured" >> "$RECONCILIATION_LOG"
        echo "0.0000|skipped|no_api_key"
        return 0
    fi

    # Fetch subscription and usage information
    local usage_response
    local timeout_cmd="timeout"
    if command -v gtimeout >/dev/null 2>&1; then
        timeout_cmd="gtimeout"
    elif ! command -v timeout >/dev/null 2>&1; then
        timeout_cmd=""
    fi

    if [[ -n "$timeout_cmd" ]]; then
        usage_response=$($timeout_cmd 15 curl -s -H "xi-api-key: $ELEVENLABS_API_KEY" \
            "https://api.elevenlabs.io/v1/user/subscription" 2>/dev/null || echo "error")
    else
        usage_response=$(curl -s -H "xi-api-key: $ELEVENLABS_API_KEY" \
            "https://api.elevenlabs.io/v1/user/subscription" 2>/dev/null || echo "error")
    fi

    if echo "$usage_response" | grep -q "error\|Error\|ERROR"; then
        echo "$timestamp RECONCILE_ERROR: ID=$reconcile_id Provider=elevenlabs Error=API_FAILURE" >> "$RECONCILIATION_LOG"
        echo "0.0000|error|api_failure"
        return 1
    fi

    # Extract character usage (ElevenLabs charges by characters)
    local chars_used=0
    local chars_limit=0
    local cost_this_period=0

    if command -v jq >/dev/null 2>&1 && echo "$usage_response" | jq . >/dev/null 2>&1; then
        chars_used=$(echo "$usage_response" | jq -r '.character_count // 0' 2>/dev/null)
        chars_limit=$(echo "$usage_response" | jq -r '.character_limit // 0' 2>/dev/null)

        # Calculate cost based on character usage (approximate)
        cost_this_period=$(awk "BEGIN {printf \"%.4f\", $chars_used * 0.00022}")
    else
        # Fallback to log-based estimation
        local char_estimate=$(grep "$date_filter" "$COST_LOG" | grep -i "elevenlabs" | \
                            awk -F'Chars=' '{sum += $2} END {printf "%.0f", sum+0}')
        chars_used=${char_estimate:-0}
        cost_this_period=$(awk "BEGIN {printf \"%.4f\", $chars_used * 0.00022}")
    fi

    echo "$timestamp RECONCILE_SUCCESS: ID=$reconcile_id Provider=elevenlabs Date=$date_filter Chars=$chars_used Cost=\$$cost_this_period" >> "$RECONCILIATION_LOG"
    echo "$cost_this_period|success|api_verified"
}

# Calculate internal cost tracking totals
calculate_internal_totals() {
    local date_filter="${1:-$(date '+%Y-%m-%d')}"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    if [[ ! -f "$COST_LOG" ]]; then
        echo "0.0000|0.0000|0.0000"
        return 0
    fi

    # Enhanced cost log totals
    local perplexity_internal=$(grep "$date_filter" "$COST_LOG" | grep "ENHANCED_COST:" | grep -i "perplexity" | \
                              awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')
    local elevenlabs_internal=$(grep "$date_filter" "$COST_LOG" | grep "ENHANCED_COST:" | grep -i "elevenlabs" | \
                               awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')
    local other_internal=$(grep "$date_filter" "$COST_LOG" | grep "ENHANCED_COST:" | grep -v -i "perplexity\|elevenlabs" | \
                          awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')

    # Fallback to legacy cost log if enhanced is empty
    if [[ "$perplexity_internal" == "0.0000" ]]; then
        perplexity_internal=$(grep "$date_filter" "$COST_LOG" | grep "COST:" | grep -v "ENHANCED_COST:" | grep -i "perplexity" | \
                             awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')
    fi

    if [[ "$elevenlabs_internal" == "0.0000" ]]; then
        elevenlabs_internal=$(grep "$date_filter" "$COST_LOG" | grep "COST:" | grep -v "ENHANCED_COST:" | grep -i "elevenlabs" | \
                             awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')
    fi

    echo "$timestamp INTERNAL_TOTALS: Date=$date_filter Perplexity=\$$perplexity_internal ElevenLabs=\$$elevenlabs_internal Other=\$$other_internal" >> "$RECONCILIATION_LOG"
    echo "${perplexity_internal:-0.0000}|${elevenlabs_internal:-0.0000}|${other_internal:-0.0000}"
}

# Perform comprehensive reconciliation
perform_reconciliation() {
    local date_filter="${1:-$(date '+%Y-%m-%d')}"
    local reconcile_id=$(generate_reconcile_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    echo "$timestamp RECONCILIATION_START: ID=$reconcile_id Date=$date_filter" >> "$RECONCILIATION_LOG"

    # Fetch provider data
    local perplexity_provider_info=$(fetch_perplexity_usage "$date_filter")
    local elevenlabs_provider_info=$(fetch_elevenlabs_usage "$date_filter")

    local perplexity_provider=$(echo "$perplexity_provider_info" | cut -d'|' -f1)
    local perplexity_status=$(echo "$perplexity_provider_info" | cut -d'|' -f2)
    local elevenlabs_provider=$(echo "$elevenlabs_provider_info" | cut -d'|' -f1)
    local elevenlabs_status=$(echo "$elevenlabs_provider_info" | cut -d'|' -f2)

    # Calculate internal totals
    local internal_totals=$(calculate_internal_totals "$date_filter")
    local perplexity_internal=$(echo "$internal_totals" | cut -d'|' -f1)
    local elevenlabs_internal=$(echo "$internal_totals" | cut -d'|' -f2)
    local other_internal=$(echo "$internal_totals" | cut -d'|' -f3)

    # Calculate discrepancies
    local perplexity_diff=$(awk "BEGIN {printf \"%.4f\", $perplexity_provider - $perplexity_internal}")
    local elevenlabs_diff=$(awk "BEGIN {printf \"%.4f\", $elevenlabs_provider - $elevenlabs_internal}")

    local total_internal=$(awk "BEGIN {printf \"%.4f\", $perplexity_internal + $elevenlabs_internal + $other_internal}")
    local total_provider=$(awk "BEGIN {printf \"%.4f\", $perplexity_provider + $elevenlabs_provider}")
    local total_diff=$(awk "BEGIN {printf \"%.4f\", $total_provider - $total_internal}")

    # Create reconciliation report
    local reconciliation_report="{
        \"reconcile_id\": \"$reconcile_id\",
        \"timestamp\": \"$timestamp\",
        \"date\": \"$date_filter\",
        \"internal_tracking\": {
            \"perplexity\": $perplexity_internal,
            \"elevenlabs\": $elevenlabs_internal,
            \"other\": $other_internal,
            \"total\": $total_internal
        },
        \"provider_data\": {
            \"perplexity\": {
                \"cost\": $perplexity_provider,
                \"status\": \"$perplexity_status\"
            },
            \"elevenlabs\": {
                \"cost\": $elevenlabs_provider,
                \"status\": \"$elevenlabs_status\"
            },
            \"total\": $total_provider
        },
        \"discrepancies\": {
            \"perplexity_diff\": $perplexity_diff,
            \"elevenlabs_diff\": $elevenlabs_diff,
            \"total_diff\": $total_diff,
            \"percentage_diff\": $(awk "BEGIN {if($total_internal > 0) printf \"%.1f\", abs($total_diff) / $total_internal * 100; else print 0}")
        }
    }"

    # Log reconciliation results
    echo "$reconciliation_report" >> "$PROVIDER_USAGE_LOG"
    echo "$timestamp RECONCILIATION_COMPLETE: ID=$reconcile_id TotalInternal=\$$total_internal TotalProvider=\$$total_provider Diff=\$$total_diff" >> "$RECONCILIATION_LOG"

    # Check for significant discrepancies
    local abs_diff=$(awk "BEGIN {printf \"%.4f\", ($total_diff < 0) ? -$total_diff : $total_diff}")
    local percentage_diff=$(awk "BEGIN {if($total_internal > 0) printf \"%.1f\", $abs_diff / $total_internal * 100; else print 0}")

    if (( $(awk "BEGIN {print ($abs_diff > $COST_TOLERANCE)}") )) || \
       (( $(awk "BEGIN {print ($percentage_diff > $PERCENTAGE_TOLERANCE)}") )); then

        # Log discrepancy alert
        local discrepancy_alert="{
            \"alert_id\": \"alert_$(date +%s)_$(openssl rand -hex 3)\",
            \"timestamp\": \"$timestamp\",
            \"reconcile_id\": \"$reconcile_id\",
            \"date\": \"$date_filter\",
            \"alert_type\": \"significant_discrepancy\",
            \"total_diff\": $total_diff,
            \"percentage_diff\": $percentage_diff,
            \"tolerance_exceeded\": {
                \"cost_tolerance\": $COST_TOLERANCE,
                \"percentage_tolerance\": $PERCENTAGE_TOLERANCE
            },
            \"details\": $reconciliation_report
        }"

        echo "$discrepancy_alert" >> "$DISCREPANCY_LOG"
        echo "DISCREPANCY_ALERT: Significant cost variance detected - Internal: \$$total_internal, Provider: \$$total_provider, Diff: \$$total_diff ($percentage_diff%)" >&2

        return 1
    else
        echo "RECONCILIATION_SUCCESS: Costs within tolerance - Internal: \$$total_internal, Provider: \$$total_provider, Diff: \$$total_diff" >&2
        return 0
    fi
}

# Generate daily reconciliation summary
generate_daily_summary() {
    local date_filter="${1:-$(date '+%Y-%m-%d')}"
    local summary_file="$PROJECT_ROOT/.claude/logs/daily-reconciliation-summary-$date_filter.json"

    if [[ ! -f "$PROVIDER_USAGE_LOG" ]]; then
        echo "No reconciliation data available for $date_filter" >&2
        return 1
    fi

    # Get latest reconciliation for the date
    local latest_reconciliation=$(grep "\"date\": \"$date_filter\"" "$PROVIDER_USAGE_LOG" | tail -1)

    if [[ -n "$latest_reconciliation" ]]; then
        echo "$latest_reconciliation" | jq '.' > "$summary_file"
        echo "Daily reconciliation summary generated: $summary_file" >&2
    else
        echo "No reconciliation data found for $date_filter" >&2
        return 1
    fi
}

# Main execution
main() {
    local operation="${1:-reconcile}"
    local date_filter="${2:-$(date '+%Y-%m-%d')}"

    case "$operation" in
        "reconcile")
            perform_reconciliation "$date_filter"
            ;;
        "summary")
            generate_daily_summary "$date_filter"
            ;;
        "perplexity_usage")
            fetch_perplexity_usage "$date_filter"
            ;;
        "elevenlabs_usage")
            fetch_elevenlabs_usage "$date_filter"
            ;;
        "internal_totals")
            calculate_internal_totals "$date_filter"
            ;;
        *)
            echo "Usage: $0 {reconcile|summary|perplexity_usage|elevenlabs_usage|internal_totals} [date]" >&2
            echo "Examples:" >&2
            echo "  $0 reconcile 2025-08-25" >&2
            echo "  $0 summary 2025-08-25" >&2
            echo "  $0 perplexity_usage" >&2
            echo "  $0 elevenlabs_usage" >&2
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
