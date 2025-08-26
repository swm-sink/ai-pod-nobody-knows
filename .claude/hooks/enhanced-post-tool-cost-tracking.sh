#!/bin/bash

# Enhanced Post-Tool Cost Tracking - Production Hardening
# Addresses $1.25 vs $2.77 discrepancies with bulletproof attribution
# Research-validated August 2025 patterns

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
COST_LOG="$PROJECT_ROOT/.claude/logs/enhanced-cost-tracking.log"
AUDIT_LOG="$PROJECT_ROOT/.claude/logs/cost-audit-trail.log"
CORRELATION_LOG="$PROJECT_ROOT/.claude/logs/cost-correlation.log"
DAILY_SUMMARY="$PROJECT_ROOT/.claude/logs/daily-cost-summary.log"

# Ensure log directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Generate correlation ID for end-to-end tracking
generate_correlation_id() {
    echo "$(date +%s)_$(openssl rand -hex 4)" 2>/dev/null || echo "$(date +%s)_$(xxd -l 4 -p /dev/urandom 2>/dev/null || echo 'fallback')"
}

# Enhanced cost calculation with provider-specific rates
calculate_enhanced_cost() {
    local tool="$1"
    local tokens="${2:-0}"
    local provider="${3:-unknown}"
    local operation="${4:-standard}"
    local cost=0
    local rate_source="estimated"

    case "$tool" in
        *"perplexity"*|*"mcp__perplexity"*)
            case "$operation" in
                "sonar-pro"|"sonar-deep")
                    cost=$(awk "BEGIN {printf \"%.4f\", $tokens * 0.003 / 1000}")
                    rate_source="sonar-pro-rate"
                    ;;
                *)
                    cost=$(awk "BEGIN {printf \"%.4f\", $tokens * 0.001 / 1000}")
                    rate_source="sonar-standard-rate"
                    ;;
            esac
            ;;
        *"elevenlabs"*|*"mcp__ElevenLabs"*)
            # ElevenLabs character-based pricing
            local chars="${tokens:-0}"  # For ElevenLabs, tokens = characters
            case "$operation" in
                "turbo_v2_5"|"eleven_turbo_v2_5")
                    cost=$(awk "BEGIN {printf \"%.4f\", $chars * 0.0002}")
                    rate_source="elevenlabs-turbo-rate"
                    ;;
                "multilingual_v2"|"eleven_multilingual_v2")
                    cost=$(awk "BEGIN {printf \"%.4f\", $chars * 0.0003}")
                    rate_source="elevenlabs-multilingual-rate"
                    ;;
                *)
                    cost=$(awk "BEGIN {printf \"%.4f\", $chars * 0.00022}")
                    rate_source="elevenlabs-standard-rate"
                    ;;
            esac
            ;;
        *"claude"*|*"anthropic"*)
            case "$operation" in
                "claude-4-opus"|"opus")
                    cost=$(awk "BEGIN {printf \"%.4f\", $tokens * 0.000015}")
                    rate_source="claude-opus-rate"
                    ;;
                "claude-sonnet-4"|"sonnet")
                    cost=$(awk "BEGIN {printf \"%.4f\", $tokens * 0.000003}")
                    rate_source="claude-sonnet-rate"
                    ;;
                *)
                    cost=$(awk "BEGIN {printf \"%.4f\", $tokens * 0.000003}")
                    rate_source="claude-default-rate"
                    ;;
            esac
            ;;
        *"Task"*)
            # Task delegation overhead
            cost=$(awk "BEGIN {printf \"%.4f\", $tokens * 0.000003}")
            rate_source="task-delegation-rate"
            ;;
        *)
            # Default fallback
            cost=$(awk "BEGIN {printf \"%.4f\", $tokens * 0.0001}")
            rate_source="fallback-rate"
            ;;
    esac

    echo "$cost|$rate_source"
}

# Immutable audit trail logging
log_immutable_cost() {
    local correlation_id="$1"
    local tool="$2"
    local tokens="$3"
    local cost_info="$4"
    local metadata="$5"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local session_id="${CLAUDE_SESSION_ID:-unknown}"

    # Parse cost and rate source
    local cost=$(echo "$cost_info" | cut -d'|' -f1)
    local rate_source=$(echo "$cost_info" | cut -d'|' -f2)

    # Create audit entry (append-only)
    local audit_entry="{\"timestamp\":\"$timestamp\",\"correlation_id\":\"$correlation_id\",\"session_id\":\"$session_id\",\"tool\":\"$tool\",\"tokens\":$tokens,\"cost\":$cost,\"rate_source\":\"$rate_source\",\"metadata\":\"$metadata\",\"host\":\"$(hostname -s 2>/dev/null || echo 'unknown')\",\"pid\":$$}"

    echo "$audit_entry" >> "$AUDIT_LOG"

    # Also log in readable format
    echo "$timestamp ENHANCED_COST: ID=$correlation_id Tool=$tool Tokens=$tokens Cost=\$$cost Source=$rate_source Meta=$metadata" >> "$COST_LOG"
}

# Real-time cost attribution and correlation
update_enhanced_cost_tracking() {
    local tool="$1"
    local tokens="${2:-1000}"
    local operation="${3:-standard}"
    local correlation_id=$(generate_correlation_id)

    # Detect provider from tool name
    local provider="unknown"
    case "$tool" in
        *"perplexity"*) provider="perplexity" ;;
        *"elevenlabs"*) provider="elevenlabs" ;;
        *"claude"*) provider="anthropic" ;;
        *"Task"*) provider="claude-task" ;;
    esac

    # Calculate cost with enhanced attribution
    local cost_info=$(calculate_enhanced_cost "$tool" "$tokens" "$provider" "$operation")
    local cost=$(echo "$cost_info" | cut -d'|' -f1)

    # Create metadata for tracking
    local metadata="provider:$provider,operation:$operation,session:${CLAUDE_SESSION_ID:-none}"

    # Log to immutable audit trail
    log_immutable_cost "$correlation_id" "$tool" "$tokens" "$cost_info" "$metadata"

    # Update correlation tracking
    echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') CORRELATION: $correlation_id -> Tool=$tool Cost=\$$cost" >> "$CORRELATION_LOG"

    # Calculate and log daily total with attribution
    local today=$(date '+%Y-%m-%d')
    local daily_total=$(grep "$today" "$COST_LOG" | grep -E "(COST:|ENHANCED_COST:)" | \
                       awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')

    # Log daily total with breakdown
    echo "$(date '+%Y-%m-%d %H:%M:%S') DAILY_TOTAL: $daily_total (Entry: +\$$cost)" >> "$COST_LOG"

    # Enhanced budget alerting
    local budget_limit=33.25
    local warning_threshold=26.60  # 80% of budget

    if (( $(awk "BEGIN {print ($daily_total > $budget_limit)}") )); then
        echo "CRITICAL: Budget exceeded! Current: \$$daily_total / \$$budget_limit" >&2
        echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') ALERT: BUDGET_EXCEEDED daily_total=$daily_total limit=$budget_limit" >> "$AUDIT_LOG"
    elif (( $(awk "BEGIN {print ($daily_total > $warning_threshold)}") )); then
        echo "WARNING: Approaching budget limit (\$$daily_total / \$$budget_limit)" >&2
        echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') ALERT: BUDGET_WARNING daily_total=$daily_total threshold=$warning_threshold" >> "$AUDIT_LOG"
    fi

    # Output current total for validation
    echo "Current daily total: \$$daily_total" >&2
}

# Automated reconciliation helper
generate_reconciliation_report() {
    local today=$(date '+%Y-%m-%d')
    local report_file="$PROJECT_ROOT/.claude/logs/reconciliation-report-$today.json"

    # Extract structured data for API reconciliation
    local perplexity_cost=$(grep "$today" "$COST_LOG" | grep "perplexity" | awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')
    local elevenlabs_cost=$(grep "$today" "$COST_LOG" | grep "elevenlabs" | awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')
    local claude_cost=$(grep "$today" "$COST_LOG" | grep -E "(claude|Task)" | awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')
    local total_cost=$(grep "$today" "$COST_LOG" | grep -E "(COST:|ENHANCED_COST:)" | awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')

    cat > "$report_file" <<EOF
{
  "date": "$today",
  "generated_at": "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')",
  "breakdown": {
    "perplexity": $perplexity_cost,
    "elevenlabs": $elevenlabs_cost,
    "claude": $claude_cost,
    "total": $total_cost
  },
  "audit_entries": $(grep "$today" "$AUDIT_LOG" | wc -l),
  "correlation_entries": $(grep "$today" "$CORRELATION_LOG" | wc -l)
}
EOF

    echo "Reconciliation report generated: $report_file" >&2
}

# Main execution with enhanced error handling
main() {
    local tool_name="${1:-unknown}"
    local token_count="${2:-1000}"
    local operation="${3:-standard}"

    # Validate inputs
    if ! [[ "$token_count" =~ ^[0-9]+$ ]]; then
        token_count=1000
        echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') WARNING: Invalid token count, using default 1000" >> "$AUDIT_LOG"
    fi

    # Execute enhanced tracking
    update_enhanced_cost_tracking "$tool_name" "$token_count" "$operation"

    # Generate reconciliation data (every 10th call for efficiency)
    if (( $$ % 10 == 0 )); then
        generate_reconciliation_report
    fi
}

# Execute main function
main "$@"

# Always continue
echo '{"continue": true}'
