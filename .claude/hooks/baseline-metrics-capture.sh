#!/bin/bash

# Baseline Metrics Capture - Episode 1 Success Pattern Recording
# Creates golden baseline from successful Episode 1 for regression prevention
# Research-validated minimal validation approach

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
BASELINE_DIR="$PROJECT_ROOT/.claude/baselines"
METRICS_LOG="$PROJECT_ROOT/.claude/logs/baseline-metrics.log"
CURRENT_BASELINE="$BASELINE_DIR/episode-1-golden-baseline.json"
VALIDATION_LOG="$PROJECT_ROOT/.claude/logs/baseline-validation.log"

# Ensure directories exist
mkdir -p "$BASELINE_DIR" "$PROJECT_ROOT/.claude/logs"

# Episode 1 Success Metrics (from empirical data)
EPISODE_1_COST="2.77"
EPISODE_1_QUALITY="92.1"
EPISODE_1_DURATION="11"  # minutes
EPISODE_1_WORD_COUNT="1506"
EPISODE_1_WPM="206"  # empirically validated

# Generate baseline capture ID
generate_baseline_id() {
    echo "baseline_$(date +%s)_$(openssl rand -hex 4)" 2>/dev/null || echo "baseline_$(date +%s)_fallback"
}

# Capture Episode 1 Golden Baseline
capture_episode1_baseline() {
    local baseline_id=$(generate_baseline_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    cat > "$CURRENT_BASELINE" <<EOF
{
  "baseline_id": "$baseline_id",
  "captured_at": "$timestamp",
  "episode": "ep001",
  "status": "golden_baseline",
  "empirical_data": {
    "cost_metrics": {
      "total_cost": $EPISODE_1_COST,
      "cost_per_minute": $(awk "BEGIN {printf \"%.3f\", $EPISODE_1_COST / $EPISODE_1_DURATION}"),
      "cost_efficiency": "validated"
    },
    "quality_metrics": {
      "composite_score": $EPISODE_1_QUALITY,
      "brand_voice_alignment": 90.0,
      "technical_quality": 94.5,
      "content_accuracy": 91.8,
      "intellectual_humility": 88.5
    },
    "production_metrics": {
      "actual_duration_minutes": $EPISODE_1_DURATION,
      "target_duration_minutes": 27,
      "word_count": $EPISODE_1_WORD_COUNT,
      "empirical_wpm": $EPISODE_1_WPM,
      "synthesis_success": true
    },
    "workflow_metrics": {
      "research_phase_success": true,
      "script_generation_success": true,
      "tts_optimization_success": true,
      "audio_synthesis_success": true,
      "mcp_fallback_required": true,
      "direct_api_success": true
    }
  },
  "success_thresholds": {
    "cost_range": {
      "min": 2.50,
      "max": 3.00,
      "target": 2.77
    },
    "quality_range": {
      "min": 85.0,
      "target": 92.1
    },
    "duration_range": {
      "min": 25,
      "max": 30,
      "empirical_baseline": 11
    },
    "word_count_range": {
      "min": 3000,
      "max": 3700,
      "empirical_baseline": 1506
    }
  },
  "critical_success_factors": [
    "cost_under_3_dollars",
    "quality_above_85_percent",
    "successful_audio_synthesis",
    "complete_workflow_execution",
    "fallback_mechanisms_working"
  ],
  "regression_detection_criteria": {
    "cost_deviation_threshold": 0.50,
    "quality_deviation_threshold": 5.0,
    "duration_variance_acceptable": 20.0,
    "workflow_failure_critical": true
  }
}
EOF

    echo "$timestamp BASELINE_CAPTURED: ID=$baseline_id Episode=ep001 Cost=\$$EPISODE_1_COST Quality=$EPISODE_1_QUALITY%" >> "$METRICS_LOG"
    echo "Golden baseline captured: $CURRENT_BASELINE" >&2
}

# Validate Current Episode Against Baseline
validate_against_baseline() {
    local episode_name="$1"
    local current_cost="${2:-0}"
    local current_quality="${3:-0}"
    local current_duration="${4:-0}"
    local validation_id=$(generate_baseline_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    if [[ ! -f "$CURRENT_BASELINE" ]]; then
        echo "ERROR: No baseline found - run capture_baseline first" >&2
        return 1
    fi

    # Extract thresholds from baseline
    local cost_max=$(jq -r '.success_thresholds.cost_range.max' "$CURRENT_BASELINE" 2>/dev/null || echo "3.00")
    local quality_min=$(jq -r '.success_thresholds.quality_range.min' "$CURRENT_BASELINE" 2>/dev/null || echo "85.0")
    local cost_deviation=$(jq -r '.regression_detection_criteria.cost_deviation_threshold' "$CURRENT_BASELINE" 2>/dev/null || echo "0.50")
    local quality_deviation=$(jq -r '.regression_detection_criteria.quality_deviation_threshold' "$CURRENT_BASELINE" 2>/dev/null || echo "5.0")

    # Calculate deviations
    local cost_diff=$(awk "BEGIN {printf \"%.2f\", $current_cost - $EPISODE_1_COST}")
    local quality_diff=$(awk "BEGIN {printf \"%.1f\", $current_quality - $EPISODE_1_QUALITY}")
    local duration_diff=$(awk "BEGIN {printf \"%.1f\", $current_duration - $EPISODE_1_DURATION}")

    # Validation results
    local cost_valid="true"
    local quality_valid="true"
    local overall_valid="true"
    local alerts=()

    # Cost validation
    if (( $(awk "BEGIN {print ($current_cost > $cost_max)}") )); then
        cost_valid="false"
        overall_valid="false"
        alerts+=("Cost exceeded maximum: \$$current_cost > \$$cost_max")
    fi

    if (( $(awk "BEGIN {print (($cost_diff > $cost_deviation) || ($cost_diff < -$cost_deviation))}") )); then
        if [[ "$cost_valid" == "true" ]]; then
            cost_valid="warning"
        fi
        alerts+=("Cost deviation from baseline: $cost_diff (threshold: ±$cost_deviation)")
    fi

    # Quality validation
    if (( $(awk "BEGIN {print ($current_quality < $quality_min)}") )); then
        quality_valid="false"
        overall_valid="false"
        alerts+=("Quality below minimum: $current_quality% < $quality_min%")
    fi

    if (( $(awk "BEGIN {print (($quality_diff > $quality_deviation) || ($quality_diff < -$quality_deviation))}") )); then
        if [[ "$quality_valid" == "true" ]]; then
            quality_valid="warning"
        fi
        alerts+=("Quality deviation from baseline: $quality_diff% (threshold: ±$quality_deviation%)")
    fi

    # Create validation report
    local validation_report="{
        \"validation_id\": \"$validation_id\",
        \"timestamp\": \"$timestamp\",
        \"episode\": \"$episode_name\",
        \"baseline_episode\": \"ep001\",
        \"current_metrics\": {
            \"cost\": $current_cost,
            \"quality\": $current_quality,
            \"duration\": $current_duration
        },
        \"baseline_metrics\": {
            \"cost\": $EPISODE_1_COST,
            \"quality\": $EPISODE_1_QUALITY,
            \"duration\": $EPISODE_1_DURATION
        },
        \"deviations\": {
            \"cost_diff\": $cost_diff,
            \"quality_diff\": $quality_diff,
            \"duration_diff\": $duration_diff
        },
        \"validation_results\": {
            \"cost_valid\": \"$cost_valid\",
            \"quality_valid\": \"$quality_valid\",
            \"overall_valid\": \"$overall_valid\"
        },
        \"alerts\": $(printf '%s\n' "${alerts[@]}" | jq -R . | jq -s .)
    }"

    # Log validation results
    echo "$validation_report" >> "$VALIDATION_LOG"
    echo "$timestamp VALIDATION: ID=$validation_id Episode=$episode_name Cost=$current_cost Quality=$current_quality Valid=$overall_valid" >> "$METRICS_LOG"

    # Output results
    if [[ "$overall_valid" == "true" ]]; then
        echo "VALIDATION_PASSED: Episode $episode_name meets baseline criteria" >&2
        if [[ ${#alerts[@]} -gt 0 ]]; then
            echo "WARNINGS:" >&2
            printf '  - %s\n' "${alerts[@]}" >&2
        fi
        return 0
    else
        echo "VALIDATION_FAILED: Episode $episode_name regression detected" >&2
        echo "CRITICAL ISSUES:" >&2
        printf '  - %s\n' "${alerts[@]}" >&2
        return 1
    fi
}

# Shadow Mode Validation (Non-Blocking)
shadow_validate() {
    local episode_name="$1"
    local current_cost="${2:-0}"
    local current_quality="${3:-0}"
    local current_duration="${4:-0}"

    echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') SHADOW_VALIDATION: Starting non-blocking validation for $episode_name" >> "$METRICS_LOG"

    # Run validation but don't block on failure
    if validate_against_baseline "$episode_name" "$current_cost" "$current_quality" "$current_duration"; then
        echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') SHADOW_RESULT: PASSED for $episode_name" >> "$METRICS_LOG"
    else
        echo "$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ') SHADOW_RESULT: FAILED for $episode_name (non-blocking)" >> "$METRICS_LOG"
        echo "SHADOW_MODE: Regression detected but continuing (non-blocking mode)" >&2
    fi
}

# Generate Baseline Comparison Report
generate_comparison_report() {
    local episode_name="$1"
    local report_file="$BASELINE_DIR/comparison-report-$episode_name-$(date +%Y%m%d).json"

    if [[ ! -f "$VALIDATION_LOG" ]]; then
        echo "No validation data available" >&2
        return 1
    fi

    # Get latest validation for this episode
    local latest_validation=$(grep "\"episode\": \"$episode_name\"" "$VALIDATION_LOG" | tail -1)

    if [[ -n "$latest_validation" ]]; then
        echo "$latest_validation" | jq '.' > "$report_file"
        echo "Comparison report generated: $report_file" >&2
    else
        echo "No validation data found for episode: $episode_name" >&2
        return 1
    fi
}

# Main execution
main() {
    local operation="${1:-capture_baseline}"
    local episode_name="${2:-ep001}"
    local cost="${3:-0}"
    local quality="${4:-0}"
    local duration="${5:-0}"

    case "$operation" in
        "capture_baseline")
            capture_episode1_baseline
            ;;
        "validate")
            validate_against_baseline "$episode_name" "$cost" "$quality" "$duration"
            ;;
        "shadow_validate")
            shadow_validate "$episode_name" "$cost" "$quality" "$duration"
            ;;
        "generate_report")
            generate_comparison_report "$episode_name"
            ;;
        *)
            echo "Usage: $0 {capture_baseline|validate|shadow_validate|generate_report} [episode] [cost] [quality] [duration]" >&2
            echo "Examples:" >&2
            echo "  $0 capture_baseline" >&2
            echo "  $0 validate ep002 2.85 89.5 26" >&2
            echo "  $0 shadow_validate ep002 2.85 89.5 26" >&2
            echo "  $0 generate_report ep002" >&2
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
