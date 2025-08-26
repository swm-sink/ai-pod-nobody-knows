#!/bin/bash

# Enhanced Pre-Tool Cost Validation - Production Hardening
# Prevents budget overruns with research-validated cost prediction
# Integrates with enhanced cost tracking for bulletproof attribution

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
BUDGET_LIMIT=33.25
COST_LOG="$PROJECT_ROOT/.claude/logs/enhanced-cost-tracking.log"
PREDICTION_LOG="$PROJECT_ROOT/.claude/logs/cost-predictions.log"
AUDIT_LOG="$PROJECT_ROOT/.claude/logs/cost-audit-trail.log"
WARNING_THRESHOLD=26.60  # 80% of budget

# Ensure log directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs"

# Generate prediction correlation ID
generate_prediction_id() {
    echo "pred_$(date +%s)_$(openssl rand -hex 3)" 2>/dev/null || echo "pred_$(date +%s)_fallback"
}

# Enhanced cost prediction with provider-specific rates
predict_operation_cost() {
    local tool="$1"
    local estimated_tokens="${2:-1000}"
    local operation="${3:-standard}"
    local cost=0
    local confidence="medium"

    case "$tool" in
        *"perplexity"*|*"mcp__perplexity"*)
            case "$operation" in
                "sonar-pro"|"sonar-deep")
                    cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.003 / 1000}")
                    confidence="high"
                    ;;
                "research"|"synthesis")
                    cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.002 / 1000}")
                    confidence="high"
                    ;;
                *)
                    cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.001 / 1000}")
                    confidence="medium"
                    ;;
            esac
            ;;
        *"elevenlabs"*|*"mcp__ElevenLabs"*)
            # ElevenLabs character-based pricing with script length estimation
            local chars="${estimated_tokens:-1000}"
            case "$operation" in
                "text_to_speech"|"synthesis")
                    # For TTS, estimate characters from episode length
                    chars=3500  # Typical episode script length
                    cost=$(awk "BEGIN {printf \"%.4f\", $chars * 0.00022}")
                    confidence="high"
                    ;;
                "audio_quality_validation")
                    cost=$(awk "BEGIN {printf \"%.4f\", 0.50}")  # Fixed cost for validation
                    confidence="high"
                    ;;
                *)
                    cost=$(awk "BEGIN {printf \"%.4f\", $chars * 0.00022}")
                    confidence="medium"
                    ;;
            esac
            ;;
        *"claude"*|*"anthropic"*)
            case "$operation" in
                "script-writer"|"creative")
                    cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.000015}")  # Opus rates
                    confidence="high"
                    ;;
                "quality-evaluation"|"analysis")
                    cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.000003}")  # Sonnet rates
                    confidence="high"
                    ;;
                *)
                    cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.000003}")
                    confidence="medium"
                    ;;
            esac
            ;;
        *"Task"*)
            # Task delegation with sub-agent cost estimation
            case "$operation" in
                "research-deep-dive"|"research-synthesis")
                    cost=$(awk "BEGIN {printf \"%.4f\", 1.50}")  # Research agent budget
                    confidence="high"
                    ;;
                "script-writer")
                    cost=$(awk "BEGIN {printf \"%.4f\", 1.75}")  # Script writer budget
                    confidence="high"
                    ;;
                "quality-perplexity"|"quality-claude")
                    cost=$(awk "BEGIN {printf \"%.4f\", 0.50}")  # Quality validation budget
                    confidence="high"
                    ;;
                "audio-synthesizer"|"tts-optimizer")
                    cost=$(awk "BEGIN {printf \"%.4f\", 0.25}")  # Audio processing budget
                    confidence="high"
                    ;;
                *)
                    cost=$(awk "BEGIN {printf \"%.4f\", 0.75}")  # Default sub-agent budget
                    confidence="medium"
                    ;;
            esac
            ;;
        *)
            # Default prediction with conservative estimate
            cost=$(awk "BEGIN {printf \"%.4f\", $estimated_tokens * 0.0001}")
            confidence="low"
            ;;
    esac

    echo "$cost|$confidence"
}

# Get current usage with enhanced parsing
get_enhanced_current_usage() {
    local today=$(date '+%Y-%m-%d')

    if [[ -f "$COST_LOG" ]]; then
        # Parse both legacy and enhanced cost logs
        local enhanced_total=$(grep "$today" "$COST_LOG" | grep "ENHANCED_COST:" | \
                              awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')
        local legacy_total=$(grep "$today" "$COST_LOG" | grep "COST:" | grep -v "ENHANCED_COST:" | \
                            awk -F'Cost=[$]?' '{sum += $2} END {printf "%.4f", sum+0}')

        # Use enhanced total if available, otherwise use legacy
        if [[ "$enhanced_total" != "0.0000" ]]; then
            echo "$enhanced_total"
        elif [[ "$legacy_total" != "0.0000" ]]; then
            echo "$legacy_total"
        else
            echo "0.0000"
        fi
    else
        echo "0.0000"
    fi
}

# Enhanced budget validation with operation-aware prediction
validate_enhanced_budget() {
    local tool="$1"
    local operation="${2:-standard}"
    local prediction_id=$(generate_prediction_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    # Estimate tokens/characters based on tool and operation
    local estimated_usage=1000
    case "$tool" in
        *"Task"*)
            case "$operation" in
                "research-deep-dive") estimated_usage=15000 ;;
                "script-writer") estimated_usage=20000 ;;
                *) estimated_usage=5000 ;;
            esac
            ;;
        *"elevenlabs"*) estimated_usage=3500 ;;  # Characters for typical episode
        *) estimated_usage=1000 ;;
    esac

    # Get cost prediction
    local prediction_info=$(predict_operation_cost "$tool" "$estimated_usage" "$operation")
    local predicted_cost=$(echo "$prediction_info" | cut -d'|' -f1)
    local confidence=$(echo "$prediction_info" | cut -d'|' -f2)

    # Get current usage
    local current_usage=$(get_enhanced_current_usage)
    local projected_total=$(awk "BEGIN {printf \"%.4f\", $current_usage + $predicted_cost}")

    # Log prediction for audit trail
    echo "$timestamp PREDICTION: ID=$prediction_id Tool=$tool Op=$operation Est=$estimated_usage Predicted=\$$predicted_cost Confidence=$confidence Current=\$$current_usage Projected=\$$projected_total" >> "$PREDICTION_LOG"

    # Audit log entry
    local audit_entry="{\"timestamp\":\"$timestamp\",\"prediction_id\":\"$prediction_id\",\"tool\":\"$tool\",\"operation\":\"$operation\",\"estimated_usage\":$estimated_usage,\"predicted_cost\":$predicted_cost,\"confidence\":\"$confidence\",\"current_usage\":$current_usage,\"projected_total\":$projected_total}"
    echo "$audit_entry" >> "$AUDIT_LOG"

    # Budget validation with confidence-based thresholds
    local effective_limit=$BUDGET_LIMIT
    if [[ "$confidence" == "low" ]]; then
        # More conservative limit for low-confidence predictions
        effective_limit=$(awk "BEGIN {printf \"%.2f\", $BUDGET_LIMIT * 0.9}")
    fi

    # Critical budget check
    if (( $(awk "BEGIN {print ($projected_total > $effective_limit)}") )); then
        echo "BUDGET_CRITICAL: Operation would exceed limit (current: \$$current_usage, predicted: +\$$predicted_cost, projected: \$$projected_total, limit: \$$effective_limit)" >&2
        echo "$timestamp ALERT: BUDGET_BLOCKED prediction_id=$prediction_id projected_total=$projected_total limit=$effective_limit" >> "$AUDIT_LOG"
        echo '{"continue": false, "message": "Budget limit would be exceeded", "current": '$current_usage', "predicted": '$predicted_cost', "projected": '$projected_total', "limit": '$effective_limit'}'
        return 1
    fi

    # Warning threshold check
    if (( $(awk "BEGIN {print ($projected_total > $WARNING_THRESHOLD)}") )); then
        echo "BUDGET_WARNING: Approaching limit (current: \$$current_usage, predicted: +\$$predicted_cost, projected: \$$projected_total)" >&2
        echo "$timestamp ALERT: BUDGET_WARNING prediction_id=$prediction_id projected_total=$projected_total threshold=$WARNING_THRESHOLD" >> "$AUDIT_LOG"
    fi

    # Success - log and continue
    echo "Budget validation passed: \$$current_usage + \$$predicted_cost = \$$projected_total (limit: \$$effective_limit)" >&2
    return 0
}

# Main execution with enhanced error handling
main() {
    local tool_name="${1:-unknown}"
    local operation="${2:-standard}"

    # Enhanced tool classification for better prediction
    local classified_operation="$operation"
    case "$tool_name" in
        *"research-deep-dive"*) classified_operation="research-deep-dive" ;;
        *"research-synthesis"*) classified_operation="research-synthesis" ;;
        *"script-writer"*) classified_operation="script-writer" ;;
        *"quality-perplexity"*) classified_operation="quality-perplexity" ;;
        *"audio-synthesizer"*) classified_operation="synthesis" ;;
        *"text_to_speech"*) classified_operation="text_to_speech" ;;
    esac

    # Only validate expensive operations
    case "$tool_name" in
        *"perplexity"*|*"elevenlabs"*|*"Task"*|*"mcp__"*)
            if validate_enhanced_budget "$tool_name" "$classified_operation"; then
                echo '{"continue": true, "budget_validated": true}'
            else
                # Budget validation failed - already output error JSON
                exit 1
            fi
            ;;
        *)
            # Log cheap operations but don't validate budget
            echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') CHEAP_OP: Tool=$tool_name (skipping budget validation)" >> "$PREDICTION_LOG"
            echo '{"continue": true, "budget_validated": false, "reason": "low_cost_operation"}'
            ;;
    esac
}

# Error handling wrapper
set -euo pipefail
trap 'echo "ERROR: Budget validation failed with error $?" >&2; echo "{\"continue\": false, \"error\": \"validation_script_error\"}"' ERR

# Execute main function
main "$@"
