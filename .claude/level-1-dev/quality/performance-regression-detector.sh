#!/bin/bash

# Performance Regression Detector for Level-1-Dev Quality System
# Automated detection of performance regressions and early warning system

set -euo pipefail

# Source error handling
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../templates/error-handling-template.sh"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
LEVEL1_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BENCHMARKS_DIR="$SCRIPT_DIR/benchmarks"
BASELINES_DIR="$BENCHMARKS_DIR/baselines"
RESULTS_DIR="$BENCHMARKS_DIR/results"
ALERTS_DIR="$BENCHMARKS_DIR/alerts"
REGRESSION_CONFIG="$BENCHMARKS_DIR/regression-config.yaml"
REGRESSION_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REGRESSION_REPORT="$ALERTS_DIR/regression-report-$REGRESSION_TIMESTAMP.json"

# Regression thresholds
CRITICAL_THRESHOLD=50    # 50% performance degradation
HIGH_THRESHOLD=30        # 30% performance degradation
MEDIUM_THRESHOLD=20      # 20% performance degradation
LOW_THRESHOLD=10         # 10% performance degradation

# Monitoring configuration
MONITORING_INTERVAL=300  # 5 minutes
CONTINUOUS_MODE=false
ALERT_ENABLED=true
BASELINE_WINDOW_DAYS=7   # Use baselines from last 7 days

# Regression counters
TOTAL_CHECKS=0
REGRESSIONS_FOUND=0
CRITICAL_REGRESSIONS=0
HIGH_REGRESSIONS=0
MEDIUM_REGRESSIONS=0
LOW_REGRESSIONS=0

# Function: Display help
show_help() {
    cat << EOF
Performance Regression Detector for Level-1-Dev Quality System

Usage: $(basename "$0") [options] [mode]

Options:
    -h, --help              Show this help message
    -v, --verbose           Show detailed output
    -q, --quiet             Suppress non-error output
    -f, --format FORMAT     Output format (json|markdown|console) [default: console]
    -o, --output FILE       Output file path
    --baseline NAME         Compare against specific baseline
    --threshold PERCENT     Regression threshold percentage [default: 20]
    --critical-threshold N  Critical regression threshold [default: 50]
    --high-threshold N      High regression threshold [default: 30]
    --medium-threshold N    Medium regression threshold [default: 20]
    --window-days N         Baseline comparison window in days [default: 7]

Detection Modes:
    --single                Run single regression check (default)
    --continuous            Run continuous monitoring
    --batch                 Batch check multiple recent results
    --baseline-drift        Detect baseline drift over time

Alerting:
    --enable-alerts         Enable alert notifications
    --disable-alerts        Disable alert notifications
    --alert-webhook URL     Webhook URL for alerts
    --alert-email EMAIL     Email address for alerts

Monitoring:
    --interval SECONDS      Monitoring interval for continuous mode [default: 300]
    --max-runtime SECONDS   Maximum runtime for continuous mode

Examples:
    $(basename "$0")                                    # Single regression check
    $(basename "$0") --continuous --interval 600       # Continuous monitoring
    $(basename "$0") --baseline stable-v1.0            # Compare against specific baseline
    $(basename "$0") --threshold 15 --enable-alerts    # Custom threshold with alerts

EOF
}

# Function: Initialize regression detector
init_regression_detector() {
    setup_error_handling
    
    # Create directories
    mkdir -p "$ALERTS_DIR"
    
    # Create default configuration if needed
    if [ ! -f "$REGRESSION_CONFIG" ]; then
        create_regression_config
    fi
    
    # Load configuration
    load_regression_config
    
    # Initialize regression report
    cat > "$REGRESSION_REPORT" << EOF
{
  "detection_info": {
    "timestamp": "$(date -Iseconds)",
    "detector_version": "1.0.0",
    "mode": "single",
    "thresholds": {
      "critical": $CRITICAL_THRESHOLD,
      "high": $HIGH_THRESHOLD,
      "medium": $MEDIUM_THRESHOLD,
      "low": $LOW_THRESHOLD
    },
    "baseline_window_days": $BASELINE_WINDOW_DAYS
  },
  "summary": {
    "total_checks": 0,
    "regressions_found": 0,
    "critical_regressions": 0,
    "high_regressions": 0,
    "medium_regressions": 0,
    "low_regressions": 0
  },
  "regressions": [],
  "alerts_sent": []
}
EOF
    
    log_info "REGRESSION_DETECTOR_INITIALIZED" "Performance regression detector initialized"
}

# Function: Create regression configuration
create_regression_config() {
    cat > "$REGRESSION_CONFIG" << 'EOF'
# Performance Regression Detection Configuration
version: "1.0.0"

# Regression Thresholds (percentage)
thresholds:
  critical: 50      # 50% or more degradation
  high: 30          # 30-49% degradation
  medium: 20        # 20-29% degradation
  low: 10           # 10-19% degradation

# Baseline Configuration
baseline:
  window_days: 7              # Days to look back for baseline comparison
  minimum_samples: 3          # Minimum samples required for reliable baseline
  auto_update_baseline: false # Automatically update baseline with good results
  drift_detection: true       # Detect gradual baseline drift

# Monitoring Configuration
monitoring:
  continuous_enabled: false
  interval_seconds: 300       # 5 minutes
  max_runtime_seconds: 3600   # 1 hour
  batch_size: 10             # Number of recent results to check in batch mode

# Alert Configuration
alerts:
  enabled: true
  channels:
    console: true
    file: true
    webhook: false
    email: false
  
  webhook:
    url: ""
    headers: {}
    timeout_seconds: 10
  
  email:
    smtp_server: ""
    smtp_port: 587
    username: ""
    password: ""
    from: ""
    to: []

# Component-specific thresholds
components:
  quality-dashboard:
    critical: 60    # Quality dashboard can be slightly slower
    high: 40
    medium: 25
    low: 15
  
  security-scanner:
    critical: 100   # Security scanner is expected to be slower
    high: 60
    medium: 40
    low: 20
  
  test-runner:
    critical: 30    # Test runner should be fast
    high: 20
    medium: 15
    low: 10

# Noise filtering
filtering:
  ignore_first_run: true      # Ignore first run after system restart
  minimum_runtime_ms: 100     # Ignore very fast operations
  outlier_detection: true     # Filter statistical outliers
  consecutive_failures: 2     # Require N consecutive failures to trigger alert

# Integration settings
integration:
  git_hooks: true            # Integrate with git hooks
  ci_cd: true               # Integrate with CI/CD pipeline
  quality_dashboard: true    # Show in quality dashboard
EOF

    log_info "REGRESSION_CONFIG_CREATED" "Created regression detection configuration"
}

# Function: Load regression configuration
load_regression_config() {
    if [ -f "$REGRESSION_CONFIG" ] && command -v yq >/dev/null 2>&1; then
        CRITICAL_THRESHOLD=$(yq -r '.thresholds.critical // 50' "$REGRESSION_CONFIG")
        HIGH_THRESHOLD=$(yq -r '.thresholds.high // 30' "$REGRESSION_CONFIG")
        MEDIUM_THRESHOLD=$(yq -r '.thresholds.medium // 20' "$REGRESSION_CONFIG")
        LOW_THRESHOLD=$(yq -r '.thresholds.low // 10' "$REGRESSION_CONFIG")
        BASELINE_WINDOW_DAYS=$(yq -r '.baseline.window_days // 7' "$REGRESSION_CONFIG")
        ALERT_ENABLED=$(yq -r '.alerts.enabled // true' "$REGRESSION_CONFIG")
    else
        log_warn "CONFIG_LOAD_FAILED" "Could not load regression configuration, using defaults"
    fi
}

# Function: Get latest benchmark result
get_latest_benchmark_result() {
    local latest_result=""
    
    # Find the most recent benchmark result
    if [ -d "$RESULTS_DIR" ]; then
        latest_result=$(ls -t "$RESULTS_DIR"/benchmark-*.json 2>/dev/null | head -1)
    fi
    
    if [ -z "$latest_result" ]; then
        log_warn "NO_RECENT_RESULTS" "No recent benchmark results found"
        return 1
    fi
    
    echo "$latest_result"
}

# Function: Get baseline for comparison
get_comparison_baseline() {
    local component_name="$1"
    local metric_type="$2"
    local baseline_name="${3:-}"
    
    # If specific baseline provided, use it
    if [ -n "$baseline_name" ] && [ -f "$BASELINES_DIR/$baseline_name/benchmark-results.json" ]; then
        echo "$BASELINES_DIR/$baseline_name/benchmark-results.json"
        return 0
    fi
    
    # Find the most appropriate baseline within the window
    local cutoff_date=$(date -d "$BASELINE_WINDOW_DAYS days ago" '+%Y-%m-%d' 2>/dev/null || \
                       date -v-${BASELINE_WINDOW_DAYS}d '+%Y-%m-%d' 2>/dev/null || \
                       echo "2024-01-01")
    
    local best_baseline=""
    local best_date=""
    
    for baseline_dir in "$BASELINES_DIR"/*; do
        if [ -d "$baseline_dir" ]; then
            local metadata_file="$baseline_dir/metadata.json"
            local results_file="$baseline_dir/benchmark-results.json"
            
            if [ -f "$metadata_file" ] && [ -f "$results_file" ] && command -v jq >/dev/null 2>&1; then
                local created_date=$(jq -r '.created' "$metadata_file" | cut -d'T' -f1)
                
                # Check if within window and has the component
                if [[ "$created_date" > "$cutoff_date" ]]; then
                    local has_component=$(jq -e ".benchmarks[] | select(.name == \"$component_name\")" "$results_file" >/dev/null 2>&1 && echo "true" || echo "false")
                    
                    if [ "$has_component" = "true" ]; then
                        if [ -z "$best_date" ] || [[ "$created_date" > "$best_date" ]]; then
                            best_baseline="$results_file"
                            best_date="$created_date"
                        fi
                    fi
                fi
            fi
        fi
    done
    
    if [ -n "$best_baseline" ]; then
        echo "$best_baseline"
        return 0
    else
        log_warn "NO_SUITABLE_BASELINE" "No suitable baseline found for $component_name within $BASELINE_WINDOW_DAYS days"
        return 1
    fi
}

# Function: Calculate performance change
calculate_performance_change() {
    local current_value="$1"
    local baseline_value="$2"
    
    if [ "$baseline_value" = "0" ] || [ -z "$baseline_value" ]; then
        echo "null"
        return 1
    fi
    
    local change_percent
    if command -v bc >/dev/null 2>&1; then
        change_percent=$(echo "scale=2; (($current_value - $baseline_value) / $baseline_value) * 100" | bc)
    else
        change_percent=$(( (current_value - baseline_value) * 100 / baseline_value ))
    fi
    
    echo "$change_percent"
}

# Function: Classify regression severity
classify_regression_severity() {
    local change_percent="$1"
    local component_name="$2"
    
    # Get component-specific thresholds if available
    local critical_thresh=$CRITICAL_THRESHOLD
    local high_thresh=$HIGH_THRESHOLD
    local medium_thresh=$MEDIUM_THRESHOLD
    local low_thresh=$LOW_THRESHOLD
    
    if [ -f "$REGRESSION_CONFIG" ] && command -v yq >/dev/null 2>&1; then
        local component_critical=$(yq -r ".components.\"$component_name\".critical // $CRITICAL_THRESHOLD" "$REGRESSION_CONFIG")
        local component_high=$(yq -r ".components.\"$component_name\".high // $HIGH_THRESHOLD" "$REGRESSION_CONFIG")
        local component_medium=$(yq -r ".components.\"$component_name\".medium // $MEDIUM_THRESHOLD" "$REGRESSION_CONFIG")
        local component_low=$(yq -r ".components.\"$component_name\".low // $LOW_THRESHOLD" "$REGRESSION_CONFIG")
        
        critical_thresh=$component_critical
        high_thresh=$component_high
        medium_thresh=$component_medium
        low_thresh=$component_low
    fi
    
    # Classify based on thresholds
    if (( $(echo "$change_percent >= $critical_thresh" | bc -l 2>/dev/null || echo "0") )); then
        echo "critical"
    elif (( $(echo "$change_percent >= $high_thresh" | bc -l 2>/dev/null || echo "0") )); then
        echo "high"
    elif (( $(echo "$change_percent >= $medium_thresh" | bc -l 2>/dev/null || echo "0") )); then
        echo "medium"
    elif (( $(echo "$change_percent >= $low_thresh" | bc -l 2>/dev/null || echo "0") )); then
        echo "low"
    else
        echo "none"
    fi
}

# Function: Add regression finding
add_regression_finding() {
    local component_name="$1"
    local metric_type="$2"
    local current_value="$3"
    local baseline_value="$4"
    local change_percent="$5"
    local severity="$6"
    local baseline_source="$7"
    
    # Update counters
    ((TOTAL_CHECKS++))
    ((REGRESSIONS_FOUND++))
    
    case "$severity" in
        "critical") ((CRITICAL_REGRESSIONS++)) ;;
        "high") ((HIGH_REGRESSIONS++)) ;;
        "medium") ((MEDIUM_REGRESSIONS++)) ;;
        "low") ((LOW_REGRESSIONS++)) ;;
    esac
    
    # Create regression finding JSON
    local regression_json
    regression_json=$(cat << EOF
{
  "component": "$component_name",
  "metric_type": "$metric_type",
  "current_value": $current_value,
  "baseline_value": $baseline_value,
  "change_percent": $change_percent,
  "severity": "$severity",
  "baseline_source": "$baseline_source",
  "detected_at": "$(date -Iseconds)",
  "impact": "Performance degradation of ${change_percent}% detected"
}
EOF
)
    
    # Add to report
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".regressions += [$regression_json]" "$REGRESSION_REPORT" > "$temp_report"
        mv "$temp_report" "$REGRESSION_REPORT"
    else
        echo "$regression_json" >> "${REGRESSION_REPORT}.regressions"
    fi
    
    # Display finding
    local color=""
    case "$severity" in
        "critical") color="$RED" ;;
        "high") color="$MAGENTA" ;;
        "medium") color="$YELLOW" ;;
        "low") color="$CYAN" ;;
    esac
    
    echo -e "${color}[$severity] REGRESSION DETECTED${NC}"
    echo -e "  Component: $component_name"
    echo -e "  Metric: $metric_type"
    echo -e "  Current: ${current_value}ms"
    echo -e "  Baseline: ${baseline_value}ms"
    echo -e "  Change: ${change_percent}% slower"
    echo -e "  Impact: Performance degradation detected"
    echo ""
    
    # Send alert if enabled
    if [ "$ALERT_ENABLED" = "true" ]; then
        send_regression_alert "$component_name" "$severity" "$change_percent" "$current_value" "$baseline_value"
    fi
}

# Function: Send regression alert
send_regression_alert() {
    local component="$1"
    local severity="$2"
    local change_percent="$3"
    local current_value="$4"
    local baseline_value="$5"
    
    local alert_message="PERFORMANCE REGRESSION DETECTED
Component: $component
Severity: $severity
Performance change: ${change_percent}% slower
Current value: ${current_value}ms
Baseline value: ${baseline_value}ms
Detected at: $(date)

This requires immediate attention to prevent performance degradation."
    
    # Console alert
    echo -e "${RED}${BOLD}ALERT: Performance Regression Detected${NC}"
    echo "$alert_message"
    echo ""
    
    # File alert
    local alert_file="$ALERTS_DIR/alert-$REGRESSION_TIMESTAMP.txt"
    echo "$alert_message" > "$alert_file"
    
    # Webhook alert (if configured)
    send_webhook_alert "$component" "$severity" "$change_percent" "$alert_message"
    
    # Email alert (if configured)
    send_email_alert "$component" "$severity" "$alert_message"
    
    # Record alert in report
    if command -v jq >/dev/null 2>&1; then
        local alert_record=$(cat << EOF
{
  "component": "$component",
  "severity": "$severity",
  "change_percent": $change_percent,
  "channels": ["console", "file"],
  "sent_at": "$(date -Iseconds)"
}
EOF
)
        local temp_report=$(mktemp)
        jq ".alerts_sent += [$alert_record]" "$REGRESSION_REPORT" > "$temp_report"
        mv "$temp_report" "$REGRESSION_REPORT"
    fi
    
    log_info "ALERT_SENT" "Regression alert sent for $component ($severity severity)"
}

# Function: Send webhook alert
send_webhook_alert() {
    local component="$1"
    local severity="$2"
    local change_percent="$3"
    local message="$4"
    
    if [ -f "$REGRESSION_CONFIG" ] && command -v yq >/dev/null 2>&1; then
        local webhook_enabled=$(yq -r '.alerts.channels.webhook // false' "$REGRESSION_CONFIG")
        local webhook_url=$(yq -r '.alerts.webhook.url // ""' "$REGRESSION_CONFIG")
        
        if [ "$webhook_enabled" = "true" ] && [ -n "$webhook_url" ] && command -v curl >/dev/null 2>&1; then
            local payload=$(cat << EOF
{
  "text": "Performance Regression Alert",
  "component": "$component",
  "severity": "$severity",
  "change_percent": $change_percent,
  "message": "$message",
  "timestamp": "$(date -Iseconds)"
}
EOF
)
            
            if curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$webhook_url" >/dev/null 2>&1; then
                log_info "WEBHOOK_SENT" "Webhook alert sent successfully"
            else
                log_warn "WEBHOOK_FAILED" "Failed to send webhook alert"
            fi
        fi
    fi
}

# Function: Send email alert
send_email_alert() {
    local component="$1"
    local severity="$2"
    local message="$3"
    
    if [ -f "$REGRESSION_CONFIG" ] && command -v yq >/dev/null 2>&1; then
        local email_enabled=$(yq -r '.alerts.channels.email // false' "$REGRESSION_CONFIG")
        
        if [ "$email_enabled" = "true" ] && command -v mail >/dev/null 2>&1; then
            local recipients=$(yq -r '.alerts.email.to[]' "$REGRESSION_CONFIG" 2>/dev/null || echo "")
            
            if [ -n "$recipients" ]; then
                echo "$message" | mail -s "Performance Regression Alert: $component ($severity)" "$recipients" || \
                    log_warn "EMAIL_FAILED" "Failed to send email alert"
            fi
        fi
    fi
}

# Function: Check for regressions in benchmark result
check_benchmark_regressions() {
    local result_file="$1"
    local baseline_name="${2:-}"
    
    if [ ! -f "$result_file" ]; then
        log_error "RESULT_FILE_NOT_FOUND" "Benchmark result file not found: $result_file"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_error "JQ_REQUIRED" "jq is required for regression detection"
        return 1
    fi
    
    echo -e "${BLUE}Checking for performance regressions...${NC}"
    echo "Result file: $result_file"
    if [ -n "$baseline_name" ]; then
        echo "Baseline: $baseline_name"
    else
        echo "Baseline: Auto-selected from last $BASELINE_WINDOW_DAYS days"
    fi
    echo ""
    
    # Get all benchmarks from the result
    local benchmarks
    benchmarks=$(jq -r '.benchmarks[] | "\(.name)|\(.type)|\(.result.average // 0)"' "$result_file")
    
    echo "$benchmarks" | while IFS='|' read -r component_name benchmark_type current_value; do
        if [ -n "$component_name" ] && [ "$current_value" != "0" ]; then
            ((TOTAL_CHECKS++))
            
            # Get baseline for comparison
            local baseline_file
            if baseline_file=$(get_comparison_baseline "$component_name" "$benchmark_type" "$baseline_name"); then
                local baseline_value=$(jq -r ".benchmarks[] | select(.name == \"$component_name\") | .result.average // 0" "$baseline_file")
                
                if [ "$baseline_value" != "0" ]; then
                    # Calculate performance change
                    local change_percent
                    if change_percent=$(calculate_performance_change "$current_value" "$baseline_value"); then
                        
                        # Check if it's a regression (positive change means slower)
                        if (( $(echo "$change_percent > 0" | bc -l 2>/dev/null || echo "0") )); then
                            local severity=$(classify_regression_severity "$change_percent" "$component_name")
                            
                            if [ "$severity" != "none" ]; then
                                add_regression_finding "$component_name" "$benchmark_type" \
                                    "$current_value" "$baseline_value" "$change_percent" \
                                    "$severity" "$(basename "$baseline_file")"
                            fi
                        else
                            # Performance improvement - log but don't alert
                            if [ "${VERBOSE:-false}" = "true" ]; then
                                echo -e "${GREEN}[improvement] $component_name: ${change_percent}% faster${NC}"
                            fi
                        fi
                    fi
                else
                    log_warn "NO_BASELINE_VALUE" "No baseline value found for $component_name"
                fi
            else
                log_warn "NO_BASELINE" "No suitable baseline found for $component_name"
            fi
        fi
    done
}

# Function: Run continuous monitoring
run_continuous_monitoring() {
    local max_runtime="${1:-3600}"  # 1 hour default
    local interval="${2:-300}"      # 5 minutes default
    
    echo -e "${BLUE}Starting continuous performance monitoring${NC}"
    echo "Interval: ${interval}s"
    echo "Max runtime: ${max_runtime}s"
    echo "Press Ctrl+C to stop"
    echo ""
    
    local start_time=$(date +%s)
    local check_count=0
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -gt $max_runtime ]; then
            echo "Maximum runtime reached, stopping monitoring"
            break
        fi
        
        ((check_count++))
        echo -e "${CYAN}[$(date)] Monitoring check #$check_count${NC}"
        
        # Run performance benchmark
        local benchmark_output
        if benchmark_output=$(cd "$LEVEL1_DIR" && "$SCRIPT_DIR/performance-benchmarks.sh" --format json --quiet 2>/dev/null); then
            # Check for regressions in the new result
            local latest_result
            if latest_result=$(get_latest_benchmark_result); then
                check_benchmark_regressions "$latest_result"
            fi
        else
            log_warn "BENCHMARK_FAILED" "Performance benchmark failed in monitoring check #$check_count"
        fi
        
        echo ""
        sleep "$interval"
    done
    
    echo "Continuous monitoring completed after $check_count checks"
}

# Function: Generate regression summary
generate_summary() {
    local detection_duration=$(($(date +%s) - DETECTION_START_TIME))
    
    # Update final report
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".detection_info.duration_seconds = $detection_duration |
            .summary.total_checks = $TOTAL_CHECKS |
            .summary.regressions_found = $REGRESSIONS_FOUND |
            .summary.critical_regressions = $CRITICAL_REGRESSIONS |
            .summary.high_regressions = $HIGH_REGRESSIONS |
            .summary.medium_regressions = $MEDIUM_REGRESSIONS |
            .summary.low_regressions = $LOW_REGRESSIONS" \
            "$REGRESSION_REPORT" > "$temp_report"
        mv "$temp_report" "$REGRESSION_REPORT"
    fi
    
    # Generate markdown summary
    local summary_file="$ALERTS_DIR/regression-summary-$REGRESSION_TIMESTAMP.md"
    cat > "$summary_file" << EOF
# Performance Regression Detection Report

**Detection Date:** $(date)  
**Detection Duration:** ${detection_duration}s  
**Total Checks:** $TOTAL_CHECKS  
**Regressions Found:** $REGRESSIONS_FOUND  

## Regression Summary

| Severity | Count |
|----------|-------|
| Critical | $CRITICAL_REGRESSIONS |
| High     | $HIGH_REGRESSIONS |
| Medium   | $MEDIUM_REGRESSIONS |
| Low      | $LOW_REGRESSIONS |

## Detection Configuration

- Critical Threshold: ${CRITICAL_THRESHOLD}%
- High Threshold: ${HIGH_THRESHOLD}%
- Medium Threshold: ${MEDIUM_THRESHOLD}%
- Low Threshold: ${LOW_THRESHOLD}%
- Baseline Window: ${BASELINE_WINDOW_DAYS} days

## Status Assessment

EOF

    if [ $CRITICAL_REGRESSIONS -gt 0 ]; then
        echo "🚨 **CRITICAL**: $CRITICAL_REGRESSIONS critical performance regressions detected." >> "$summary_file"
    fi
    
    if [ $HIGH_REGRESSIONS -gt 0 ]; then
        echo "⚠️ **HIGH**: $HIGH_REGRESSIONS high-severity regressions detected." >> "$summary_file"
    fi
    
    if [ $REGRESSIONS_FOUND -eq 0 ]; then
        echo "✅ **GOOD**: No performance regressions detected." >> "$summary_file"
    fi
    
    cat >> "$summary_file" << EOF

## Detailed Report

For detailed regression findings, see: \`$REGRESSION_REPORT\`

## Recommendations

EOF
    
    if [ $REGRESSIONS_FOUND -gt 0 ]; then
        cat >> "$summary_file" << EOF
1. Investigate recent code changes that may have caused regressions
2. Review and optimize slow components
3. Consider reverting changes if regressions are severe
4. Update performance baselines after fixes are implemented
5. Increase monitoring frequency for affected components
EOF
    else
        cat >> "$summary_file" << EOF
1. Continue regular performance monitoring
2. Update baselines periodically to reflect improvements
3. Consider tightening regression thresholds if system is stable
EOF
    fi
    
    echo "$summary_file"
}

# Function: Display results
display_results() {
    echo ""
    echo "========================================"
    echo -e "${BOLD}${BLUE}Regression Detection Complete${NC}"
    echo "========================================"
    echo ""
    echo "Total Checks:        $TOTAL_CHECKS"
    echo "Regressions Found:   $REGRESSIONS_FOUND"
    echo ""
    echo "Regression Severity:"
    echo -e "  ${RED}Critical: $CRITICAL_REGRESSIONS${NC}"
    echo -e "  ${MAGENTA}High:     $HIGH_REGRESSIONS${NC}"
    echo -e "  ${YELLOW}Medium:   $MEDIUM_REGRESSIONS${NC}"
    echo -e "  ${CYAN}Low:      $LOW_REGRESSIONS${NC}"
    echo ""
    echo "Report: $REGRESSION_REPORT"
    echo "Summary: $(generate_summary)"
    echo ""
    
    # Overall assessment
    if [ $CRITICAL_REGRESSIONS -gt 0 ]; then
        echo -e "${RED}${BOLD}REGRESSION STATUS: CRITICAL - Immediate action required${NC}"
        return 1
    elif [ $HIGH_REGRESSIONS -gt 0 ]; then
        echo -e "${MAGENTA}${BOLD}REGRESSION STATUS: HIGH RISK - Investigation needed${NC}"
        return 1
    elif [ $MEDIUM_REGRESSIONS -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}REGRESSION STATUS: MEDIUM RISK - Monitor closely${NC}"
        return 1
    elif [ $LOW_REGRESSIONS -gt 0 ]; then
        echo -e "${CYAN}${BOLD}REGRESSION STATUS: LOW RISK - Minor regressions detected${NC}"
        return 0
    else
        echo -e "${GREEN}${BOLD}REGRESSION STATUS: CLEAN - No regressions detected${NC}"
        return 0
    fi
}

# Main execution
main() {
    local mode="single"
    local baseline_name=""
    local threshold=""
    local max_runtime=3600
    local interval=300
    
    DETECTION_START_TIME=$(date +%s)
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            --baseline)
                baseline_name="$2"
                shift 2
                ;;
            --threshold)
                MEDIUM_THRESHOLD="$2"
                shift 2
                ;;
            --critical-threshold)
                CRITICAL_THRESHOLD="$2"
                shift 2
                ;;
            --high-threshold)
                HIGH_THRESHOLD="$2"
                shift 2
                ;;
            --medium-threshold)
                MEDIUM_THRESHOLD="$2"
                shift 2
                ;;
            --window-days)
                BASELINE_WINDOW_DAYS="$2"
                shift 2
                ;;
            --single|--continuous|--batch|--baseline-drift)
                mode="${1#--}"
                shift
                ;;
            --enable-alerts)
                ALERT_ENABLED=true
                shift
                ;;
            --disable-alerts)
                ALERT_ENABLED=false
                shift
                ;;
            --interval)
                interval="$2"
                shift 2
                ;;
            --max-runtime)
                max_runtime="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Initialize
    init_regression_detector
    
    echo -e "${BOLD}${BLUE}Starting Performance Regression Detection${NC}"
    echo "Mode: $mode"
    if [ -n "$baseline_name" ]; then
        echo "Baseline: $baseline_name"
    fi
    echo "Thresholds: Critical:${CRITICAL_THRESHOLD}% High:${HIGH_THRESHOLD}% Medium:${MEDIUM_THRESHOLD}% Low:${LOW_THRESHOLD}%"
    echo ""
    
    # Execute based on mode
    case "$mode" in
        "single")
            local latest_result
            if latest_result=$(get_latest_benchmark_result); then
                check_benchmark_regressions "$latest_result" "$baseline_name"
            else
                log_error "NO_RESULTS" "No recent benchmark results found for regression detection"
                exit 1
            fi
            ;;
        "continuous")
            run_continuous_monitoring "$max_runtime" "$interval"
            ;;
        "batch")
            # Check multiple recent results
            ls -t "$RESULTS_DIR"/benchmark-*.json 2>/dev/null | head -5 | while read -r result_file; do
                echo -e "${CYAN}Checking: $(basename "$result_file")${NC}"
                check_benchmark_regressions "$result_file" "$baseline_name"
                echo ""
            done
            ;;
    esac
    
    # Display results
    if [ "${QUIET:-false}" != "true" ]; then
        display_results
    fi
}

# Run main function
main "$@"