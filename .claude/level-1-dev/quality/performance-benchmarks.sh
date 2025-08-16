#!/bin/bash

# Performance Benchmarks for Level-1-Dev Quality System
# Automated performance testing, baseline establishment, and regression detection

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
PROJECT_ROOT="$(cd "$LEVEL1_DIR/../.." && pwd)"
BENCHMARKS_DIR="$SCRIPT_DIR/benchmarks"
BASELINES_DIR="$BENCHMARKS_DIR/baselines"
RESULTS_DIR="$BENCHMARKS_DIR/results"
CONFIG_FILE="$BENCHMARKS_DIR/performance-config.yaml"
BENCHMARK_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BENCHMARK_REPORT="$RESULTS_DIR/benchmark-$BENCHMARK_TIMESTAMP.json"

# Performance thresholds (in milliseconds unless specified)
DEFAULT_TIMEOUT=30000           # 30 seconds
SCRIPT_EXECUTION_THRESHOLD=5000 # 5 seconds
MEMORY_THRESHOLD_MB=100         # 100 MB
CPU_THRESHOLD_PERCENT=80        # 80% CPU usage
REGRESSION_THRESHOLD_PERCENT=20 # 20% performance regression

# Benchmark counters
TOTAL_BENCHMARKS=0
PASSED_BENCHMARKS=0
FAILED_BENCHMARKS=0
REGRESSIONS_DETECTED=0
IMPROVEMENTS_DETECTED=0

# System information
SYSTEM_INFO=""
BASELINE_DATE=""

# Function: Display help
show_help() {
    cat << EOF
Performance Benchmarks for Level-1-Dev Quality System

Usage: $(basename "$0") [options] [benchmark-type]

Options:
    -h, --help              Show this help message
    -v, --verbose           Show detailed output
    -q, --quiet             Suppress non-error output
    -f, --format FORMAT     Output format (json|markdown|console) [default: console]
    -o, --output FILE       Output file path
    --timeout SEC           Benchmark timeout in seconds [default: 30]
    --baseline              Create new performance baseline
    --compare               Compare against baseline
    --regression-threshold N Performance regression threshold % [default: 20]
    --warmup-runs N         Number of warmup runs [default: 3]
    --benchmark-runs N      Number of benchmark runs [default: 5]

Benchmark Types:
    --all                   Run all benchmarks (default)
    --scripts               Benchmark script execution times
    --memory                Benchmark memory usage
    --cpu                   Benchmark CPU usage
    --disk-io               Benchmark disk I/O performance
    --network               Benchmark network operations
    --quality-tools         Benchmark quality tool performance
    --integration           Benchmark end-to-end workflows

Performance Monitoring:
    --continuous            Run continuous performance monitoring
    --alert-threshold N     Alert on N% performance degradation
    --profile               Enable detailed profiling

Examples:
    $(basename "$0")                              # Run all benchmarks
    $(basename "$0") --baseline --scripts         # Create script baseline
    $(basename "$0") --compare --format json     # Compare with JSON output
    $(basename "$0") --continuous --alert-threshold 15  # Continuous monitoring

EOF
}

# Function: Initialize benchmarking system
init_benchmarks() {
    setup_error_handling
    
    # Create directories
    mkdir -p "$BENCHMARKS_DIR" "$BASELINES_DIR" "$RESULTS_DIR"
    
    # Collect system information
    collect_system_info
    
    # Create default configuration if needed
    if [ ! -f "$CONFIG_FILE" ]; then
        create_benchmark_config
    fi
    
    # Initialize benchmark report
    cat > "$BENCHMARK_REPORT" << EOF
{
  "benchmark_info": {
    "timestamp": "$(date -Iseconds)",
    "version": "1.0.0",
    "system_info": $SYSTEM_INFO,
    "baseline_date": "$BASELINE_DATE",
    "duration_seconds": 0
  },
  "summary": {
    "total_benchmarks": 0,
    "passed_benchmarks": 0,
    "failed_benchmarks": 0,
    "regressions_detected": 0,
    "improvements_detected": 0,
    "average_performance_change": 0
  },
  "benchmarks": []
}
EOF
    
    log_info "BENCHMARKS_INITIALIZED" "Performance benchmarking system initialized"
}

# Function: Collect system information
collect_system_info() {
    local cpu_info=""
    local memory_info=""
    local disk_info=""
    local os_info=""
    
    # CPU information
    if command -v nproc >/dev/null 2>&1; then
        local cpu_cores=$(nproc)
        cpu_info="\"cores\": $cpu_cores"
    fi
    
    if [ -f "/proc/cpuinfo" ]; then
        local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        cpu_info="$cpu_info, \"model\": \"$cpu_model\""
    fi
    
    # Memory information
    if command -v free >/dev/null 2>&1; then
        local total_memory=$(free -m | grep "Mem:" | awk '{print $2}')
        memory_info="\"total_mb\": $total_memory"
    fi
    
    # Disk information
    if command -v df >/dev/null 2>&1; then
        local disk_usage=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
        disk_info="\"usage_percent\": $disk_usage"
    fi
    
    # OS information
    if command -v uname >/dev/null 2>&1; then
        local os_name=$(uname -s)
        local os_version=$(uname -r)
        os_info="\"name\": \"$os_name\", \"version\": \"$os_version\""
    fi
    
    SYSTEM_INFO=$(cat << EOF
{
  "cpu": {$cpu_info},
  "memory": {$memory_info},
  "disk": {$disk_info},
  "os": {$os_info},
  "timestamp": "$(date -Iseconds)"
}
EOF
)
}

# Function: Create benchmark configuration
create_benchmark_config() {
    cat > "$CONFIG_FILE" << 'EOF'
# Performance Benchmark Configuration
version: "1.0.0"

# Global settings
global:
  timeout_seconds: 30
  warmup_runs: 3
  benchmark_runs: 5
  regression_threshold_percent: 20
  improvement_threshold_percent: 10

# Script benchmarks
scripts:
  enabled: true
  timeout_seconds: 10
  scripts_to_test:
    - "bin/version-validator.sh --help"
    - "quality/quality-dashboard.sh"
    - "quality/security-scanner.sh --quick ."
    - "tests/run-unit-tests.sh"
    - "bin/agent-builder.sh --help"

# Memory benchmarks
memory:
  enabled: true
  max_memory_mb: 100
  tools_to_test:
    - "quality/quality-dashboard.sh"
    - "quality/security-scanner.sh"
    - "quality/dependency-checker.sh"

# CPU benchmarks
cpu:
  enabled: true
  max_cpu_percent: 80
  duration_seconds: 10
  
# Disk I/O benchmarks
disk_io:
  enabled: true
  test_file_size_mb: 10
  operations:
    - "write"
    - "read"
    - "random_read"
    - "random_write"

# Network benchmarks
network:
  enabled: true
  test_urls:
    - "https://httpbin.org/get"
    - "https://api.github.com"
  timeout_seconds: 5

# Quality tools benchmarks
quality_tools:
  enabled: true
  tools:
    - name: "quality-dashboard"
      command: "./quality/quality-dashboard.sh"
      expected_max_time_ms: 5000
    
    - name: "security-scanner"
      command: "./quality/security-scanner.sh --quick ."
      expected_max_time_ms: 10000
    
    - name: "dependency-checker"
      command: "./quality/dependency-checker.sh --offline ."
      expected_max_time_ms: 15000

# Integration benchmarks
integration:
  enabled: true
  workflows:
    - name: "full-quality-check"
      steps:
        - "./quality/quality-dashboard.sh"
        - "./quality/security-scanner.sh --quick ."
        - "./tests/run-unit-tests.sh"
      expected_max_time_ms: 30000
    
    - name: "pre-commit-simulation"
      steps:
        - "./quality/hooks/pre-commit-quality.sh --dry-run"
      expected_max_time_ms: 10000

# Alerting thresholds
alerts:
  performance_degradation_percent: 25
  memory_increase_percent: 30
  failure_rate_percent: 10
EOF

    log_info "CONFIG_CREATED" "Created benchmark configuration: $CONFIG_FILE"
}

# Function: Run warmup
run_warmup() {
    local command="$1"
    local warmup_runs="${2:-3}"
    
    log_debug "WARMUP_START" "Running $warmup_runs warmup iterations for: $command"
    
    for ((i=1; i<=warmup_runs; i++)); do
        timeout 30 bash -c "$command" >/dev/null 2>&1 || true
    done
    
    log_debug "WARMUP_COMPLETE" "Warmup complete for: $command"
}

# Function: Measure execution time
measure_execution_time() {
    local command="$1"
    local runs="${2:-5}"
    local timeout_seconds="${3:-30}"
    
    local times=()
    local success_count=0
    
    for ((i=1; i<=runs; i++)); do
        local start_time=$(date +%s%N)
        
        if timeout "$timeout_seconds" bash -c "$command" >/dev/null 2>&1; then
            local end_time=$(date +%s%N)
            local duration_ms=$(( (end_time - start_time) / 1000000 ))
            times+=("$duration_ms")
            ((success_count++))
        else
            log_warn "BENCHMARK_TIMEOUT" "Command timed out: $command"
        fi
    done
    
    if [ $success_count -eq 0 ]; then
        echo "null"
        return 1
    fi
    
    # Calculate statistics
    local total=0
    local min_time=${times[0]}
    local max_time=${times[0]}
    
    for time in "${times[@]}"; do
        ((total += time))
        if [ "$time" -lt "$min_time" ]; then
            min_time=$time
        fi
        if [ "$time" -gt "$max_time" ]; then
            max_time=$time
        fi
    done
    
    local avg_time=$((total / success_count))
    
    # Calculate median
    IFS=$'\n' sorted=($(sort -n <<<"${times[*]}"))
    local median_time
    local array_length=${#sorted[@]}
    if [ $((array_length % 2)) -eq 1 ]; then
        median_time=${sorted[$((array_length / 2))]}
    else
        local mid1=${sorted[$((array_length / 2 - 1))]}
        local mid2=${sorted[$((array_length / 2))]}
        median_time=$(((mid1 + mid2) / 2))
    fi
    
    echo "{\"average\": $avg_time, \"median\": $median_time, \"min\": $min_time, \"max\": $max_time, \"runs\": $success_count}"
}

# Function: Measure memory usage
measure_memory_usage() {
    local command="$1"
    local timeout_seconds="${2:-30}"
    
    # Create temporary script to monitor memory
    local monitor_script=$(mktemp)
    local pid_file=$(mktemp)
    local memory_file=$(mktemp)
    
    cat > "$monitor_script" << 'SCRIPT_EOF'
#!/bin/bash
pid_file="$1"
memory_file="$2"
max_memory=0

while [ -f "$pid_file" ]; do
    if [ -s "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            memory=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
            if [ -n "$memory" ] && [ "$memory" -gt "$max_memory" ]; then
                max_memory=$memory
                echo $max_memory > "$memory_file"
            fi
        fi
    fi
    sleep 0.1
done
SCRIPT_EOF
    
    chmod +x "$monitor_script"
    
    # Start memory monitor
    "$monitor_script" "$pid_file" "$memory_file" &
    local monitor_pid=$!
    
    # Run command and capture PID
    (
        echo $$ > "$pid_file"
        timeout "$timeout_seconds" bash -c "$command" >/dev/null 2>&1
        rm -f "$pid_file"
    ) &
    local command_pid=$!
    
    # Wait for command completion
    wait $command_pid
    local exit_code=$?
    
    # Clean up monitor
    kill $monitor_pid 2>/dev/null || true
    wait $monitor_pid 2>/dev/null || true
    
    # Get memory usage
    local max_memory_kb=0
    if [ -f "$memory_file" ] && [ -s "$memory_file" ]; then
        max_memory_kb=$(cat "$memory_file")
    fi
    
    local max_memory_mb=$((max_memory_kb / 1024))
    
    # Clean up
    rm -f "$monitor_script" "$pid_file" "$memory_file"
    
    if [ $exit_code -eq 0 ]; then
        echo "{\"max_memory_mb\": $max_memory_mb, \"max_memory_kb\": $max_memory_kb}"
    else
        echo "null"
        return 1
    fi
}

# Function: Add benchmark result
add_benchmark_result() {
    local benchmark_name="$1"
    local benchmark_type="$2"
    local result="$3"
    local baseline="$4"
    local passed="$5"
    local regression="${6:-false}"
    local improvement="${7:-false}"
    
    # Update counters
    ((TOTAL_BENCHMARKS++))
    if [ "$passed" = "true" ]; then
        ((PASSED_BENCHMARKS++))
    else
        ((FAILED_BENCHMARKS++))
    fi
    
    if [ "$regression" = "true" ]; then
        ((REGRESSIONS_DETECTED++))
    fi
    
    if [ "$improvement" = "true" ]; then
        ((IMPROVEMENTS_DETECTED++))
    fi
    
    # Create benchmark result JSON
    local benchmark_json
    benchmark_json=$(cat << EOF
{
  "name": "$benchmark_name",
  "type": "$benchmark_type",
  "result": $result,
  "baseline": $baseline,
  "passed": $passed,
  "regression": $regression,
  "improvement": $improvement,
  "timestamp": "$(date -Iseconds)"
}
EOF
)
    
    # Add to report
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".benchmarks += [$benchmark_json]" "$BENCHMARK_REPORT" > "$temp_report"
        mv "$temp_report" "$BENCHMARK_REPORT"
    else
        echo "$benchmark_json" >> "${BENCHMARK_REPORT}.benchmarks"
    fi
    
    # Display result
    local status_color=""
    local status_text=""
    
    if [ "$passed" = "true" ]; then
        if [ "$improvement" = "true" ]; then
            status_color="$GREEN"
            status_text="✓ IMPROVED"
        else
            status_color="$GREEN"
            status_text="✓ PASSED"
        fi
    else
        if [ "$regression" = "true" ]; then
            status_color="$RED"
            status_text="✗ REGRESSION"
        else
            status_color="$YELLOW"
            status_text="✗ FAILED"
        fi
    fi
    
    echo -e "${status_color}[$status_text] $benchmark_name${NC}"
    
    if [ "${VERBOSE:-false}" = "true" ]; then
        echo "  Type: $benchmark_type"
        echo "  Result: $result"
        if [ "$baseline" != "null" ]; then
            echo "  Baseline: $baseline"
        fi
        echo ""
    fi
}

# Function: Compare with baseline
compare_with_baseline() {
    local benchmark_name="$1"
    local current_value="$2"
    local baseline_value="$3"
    local metric_type="${4:-execution_time}"  # execution_time, memory, cpu
    
    if [ "$baseline_value" = "null" ] || [ -z "$baseline_value" ]; then
        echo "false false"  # No regression, no improvement
        return
    fi
    
    # Calculate percentage change
    local change_percent
    if command -v bc >/dev/null 2>&1; then
        change_percent=$(echo "scale=2; (($current_value - $baseline_value) / $baseline_value) * 100" | bc)
    else
        change_percent=$(( (current_value - baseline_value) * 100 / baseline_value ))
    fi
    
    local regression="false"
    local improvement="false"
    
    # Determine if it's a regression or improvement
    case "$metric_type" in
        "execution_time"|"memory")
            # Lower is better
            if (( $(echo "$change_percent > $REGRESSION_THRESHOLD_PERCENT" | bc -l 2>/dev/null || echo "0") )); then
                regression="true"
            elif (( $(echo "$change_percent < -10" | bc -l 2>/dev/null || echo "0") )); then
                improvement="true"
            fi
            ;;
        "cpu")
            # Lower is better for CPU usage
            if (( $(echo "$change_percent > $REGRESSION_THRESHOLD_PERCENT" | bc -l 2>/dev/null || echo "0") )); then
                regression="true"
            elif (( $(echo "$change_percent < -10" | bc -l 2>/dev/null || echo "0") )); then
                improvement="true"
            fi
            ;;
    esac
    
    echo "$regression $improvement"
}

# Function: Benchmark script execution
benchmark_scripts() {
    echo -e "${BLUE}Benchmarking script execution times...${NC}"
    
    local scripts=(
        "bin/version-validator.sh --help"
        "quality/quality-dashboard.sh"
        "tests/run-unit-tests.sh"
    )
    
    for script_cmd in "${scripts[@]}"; do
        local script_name=$(echo "$script_cmd" | awk '{print $1}' | xargs basename .sh)
        
        # Check if script exists
        local script_path=$(echo "$script_cmd" | awk '{print $1}')
        if [ ! -f "$script_path" ]; then
            log_warn "SCRIPT_NOT_FOUND" "Script not found: $script_path"
            continue
        fi
        
        # Run warmup
        run_warmup "$script_cmd" 2
        
        # Measure execution time
        local result=$(measure_execution_time "$script_cmd" 3 10)
        
        if [ "$result" = "null" ]; then
            add_benchmark_result "$script_name" "script_execution" "null" "null" "false"
            continue
        fi
        
        # Get average time
        local avg_time
        if command -v jq >/dev/null 2>&1; then
            avg_time=$(echo "$result" | jq -r '.average')
        else
            avg_time=$(echo "$result" | grep -o '"average": [0-9]*' | cut -d: -f2 | tr -d ' ')
        fi
        
        # Load baseline if available
        local baseline_file="$BASELINES_DIR/${script_name}_execution.json"
        local baseline_value="null"
        if [ -f "$baseline_file" ]; then
            baseline_value=$(jq -r '.average' "$baseline_file" 2>/dev/null || echo "null")
        fi
        
        # Compare with baseline
        local regression improvement
        read regression improvement <<< $(compare_with_baseline "$script_name" "$avg_time" "$baseline_value" "execution_time")
        
        # Determine if passed
        local passed="true"
        if [ "$avg_time" -gt "$SCRIPT_EXECUTION_THRESHOLD" ] || [ "$regression" = "true" ]; then
            passed="false"
        fi
        
        add_benchmark_result "$script_name" "script_execution" "$result" "$baseline_value" "$passed" "$regression" "$improvement"
        
        # Save as new baseline if creating baseline
        if [ "${CREATE_BASELINE:-false}" = "true" ]; then
            echo "$result" > "$baseline_file"
            log_info "BASELINE_SAVED" "Saved baseline for $script_name: $avg_time ms"
        fi
    done
}

# Function: Benchmark memory usage
benchmark_memory() {
    echo -e "${BLUE}Benchmarking memory usage...${NC}"
    
    local tools=(
        "quality/quality-dashboard.sh"
        "quality/security-scanner.sh --quick ."
    )
    
    for tool_cmd in "${tools[@]}"; do
        local tool_name=$(echo "$tool_cmd" | awk '{print $1}' | xargs basename .sh)
        
        # Check if tool exists
        local tool_path=$(echo "$tool_cmd" | awk '{print $1}')
        if [ ! -f "$tool_path" ]; then
            continue
        fi
        
        # Measure memory usage
        local result=$(measure_memory_usage "$tool_cmd" 15)
        
        if [ "$result" = "null" ]; then
            add_benchmark_result "$tool_name" "memory_usage" "null" "null" "false"
            continue
        fi
        
        # Get memory usage
        local memory_mb
        if command -v jq >/dev/null 2>&1; then
            memory_mb=$(echo "$result" | jq -r '.max_memory_mb')
        else
            memory_mb=$(echo "$result" | grep -o '"max_memory_mb": [0-9]*' | cut -d: -f2 | tr -d ' ')
        fi
        
        # Load baseline if available
        local baseline_file="$BASELINES_DIR/${tool_name}_memory.json"
        local baseline_value="null"
        if [ -f "$baseline_file" ]; then
            baseline_value=$(jq -r '.max_memory_mb' "$baseline_file" 2>/dev/null || echo "null")
        fi
        
        # Compare with baseline
        local regression improvement
        read regression improvement <<< $(compare_with_baseline "$tool_name" "$memory_mb" "$baseline_value" "memory")
        
        # Determine if passed
        local passed="true"
        if [ "$memory_mb" -gt "$MEMORY_THRESHOLD_MB" ] || [ "$regression" = "true" ]; then
            passed="false"
        fi
        
        add_benchmark_result "$tool_name" "memory_usage" "$result" "$baseline_value" "$passed" "$regression" "$improvement"
        
        # Save as new baseline if creating baseline
        if [ "${CREATE_BASELINE:-false}" = "true" ]; then
            echo "$result" > "$baseline_file"
            log_info "BASELINE_SAVED" "Saved memory baseline for $tool_name: $memory_mb MB"
        fi
    done
}

# Function: Benchmark quality tools
benchmark_quality_tools() {
    echo -e "${BLUE}Benchmarking quality tools performance...${NC}"
    
    local tools=(
        "quality-dashboard:./quality/quality-dashboard.sh:5000"
        "security-scanner:./quality/security-scanner.sh --quick .:10000"
        "dependency-checker:./quality/dependency-checker.sh --offline .:15000"
    )
    
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool_name tool_cmd expected_max_ms <<< "$tool_info"
        
        # Check if tool exists
        local tool_path=$(echo "$tool_cmd" | awk '{print $1}')
        if [ ! -f "$tool_path" ]; then
            continue
        fi
        
        # Run warmup
        run_warmup "$tool_cmd" 1
        
        # Measure execution time
        local result=$(measure_execution_time "$tool_cmd" 3 30)
        
        if [ "$result" = "null" ]; then
            add_benchmark_result "$tool_name" "quality_tool" "null" "null" "false"
            continue
        fi
        
        # Get average time
        local avg_time
        if command -v jq >/dev/null 2>&1; then
            avg_time=$(echo "$result" | jq -r '.average')
        else
            avg_time=$(echo "$result" | grep -o '"average": [0-9]*' | cut -d: -f2 | tr -d ' ')
        fi
        
        # Load baseline if available
        local baseline_file="$BASELINES_DIR/${tool_name}_quality.json"
        local baseline_value="null"
        if [ -f "$baseline_file" ]; then
            baseline_value=$(jq -r '.average' "$baseline_file" 2>/dev/null || echo "null")
        fi
        
        # Compare with baseline
        local regression improvement
        read regression improvement <<< $(compare_with_baseline "$tool_name" "$avg_time" "$baseline_value" "execution_time")
        
        # Determine if passed
        local passed="true"
        if [ "$avg_time" -gt "$expected_max_ms" ] || [ "$regression" = "true" ]; then
            passed="false"
        fi
        
        add_benchmark_result "$tool_name" "quality_tool" "$result" "$baseline_value" "$passed" "$regression" "$improvement"
        
        # Save as new baseline if creating baseline
        if [ "${CREATE_BASELINE:-false}" = "true" ]; then
            echo "$result" > "$baseline_file"
            log_info "BASELINE_SAVED" "Saved quality tool baseline for $tool_name: $avg_time ms"
        fi
    done
}

# Function: Generate benchmark summary
generate_summary() {
    local benchmark_duration=$(($(date +%s) - BENCHMARK_START_TIME))
    
    # Update final report
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".benchmark_info.duration_seconds = $benchmark_duration |
            .summary.total_benchmarks = $TOTAL_BENCHMARKS |
            .summary.passed_benchmarks = $PASSED_BENCHMARKS |
            .summary.failed_benchmarks = $FAILED_BENCHMARKS |
            .summary.regressions_detected = $REGRESSIONS_DETECTED |
            .summary.improvements_detected = $IMPROVEMENTS_DETECTED" \
            "$BENCHMARK_REPORT" > "$temp_report"
        mv "$temp_report" "$BENCHMARK_REPORT"
    fi
    
    # Generate markdown summary
    local summary_file="$RESULTS_DIR/benchmark-summary-$BENCHMARK_TIMESTAMP.md"
    cat > "$summary_file" << EOF
# Performance Benchmark Report

**Benchmark Date:** $(date)  
**Benchmark Duration:** ${benchmark_duration}s  
**Total Benchmarks:** $TOTAL_BENCHMARKS  

## Summary

| Metric | Count |
|--------|-------|
| Passed | $PASSED_BENCHMARKS |
| Failed | $FAILED_BENCHMARKS |
| Regressions | $REGRESSIONS_DETECTED |
| Improvements | $IMPROVEMENTS_DETECTED |

## System Information

$(echo "$SYSTEM_INFO" | jq -r 'to_entries[] | "- **\(.key | ascii_upcase)**: \(.value)"' 2>/dev/null || echo "System info not available")

## Performance Status

EOF

    if [ $REGRESSIONS_DETECTED -gt 0 ]; then
        echo "🚨 **REGRESSIONS**: $REGRESSIONS_DETECTED performance regressions detected." >> "$summary_file"
    fi
    
    if [ $IMPROVEMENTS_DETECTED -gt 0 ]; then
        echo "✨ **IMPROVEMENTS**: $IMPROVEMENTS_DETECTED performance improvements detected." >> "$summary_file"
    fi
    
    if [ $FAILED_BENCHMARKS -eq 0 ] && [ $REGRESSIONS_DETECTED -eq 0 ]; then
        echo "✅ **GOOD**: All benchmarks passed without regressions." >> "$summary_file"
    fi
    
    cat >> "$summary_file" << EOF

## Benchmark Details

For detailed benchmark results, see: \`$BENCHMARK_REPORT\`

## Baseline Information

EOF
    
    if [ -d "$BASELINES_DIR" ] && [ "$(ls -A "$BASELINES_DIR")" ]; then
        echo "Baseline files found:" >> "$summary_file"
        ls -la "$BASELINES_DIR"/*.json 2>/dev/null | while read -r line; do
            echo "- $line" >> "$summary_file"
        done
    else
        echo "No baseline files found. Run with --baseline to create baselines." >> "$summary_file"
    fi
    
    echo "$summary_file"
}

# Function: Display results
display_results() {
    echo ""
    echo "========================================"
    echo -e "${BOLD}${BLUE}Performance Benchmarks Complete${NC}"
    echo "========================================"
    echo ""
    echo "Total Benchmarks:     $TOTAL_BENCHMARKS"
    echo -e "Passed:               ${GREEN}$PASSED_BENCHMARKS${NC}"
    echo -e "Failed:               ${RED}$FAILED_BENCHMARKS${NC}"
    echo ""
    echo "Performance Changes:"
    echo -e "  ${RED}Regressions:    $REGRESSIONS_DETECTED${NC}"
    echo -e "  ${GREEN}Improvements:   $IMPROVEMENTS_DETECTED${NC}"
    echo ""
    echo "Report: $BENCHMARK_REPORT"
    echo "Summary: $(generate_summary)"
    echo ""
    
    # Overall assessment
    if [ $REGRESSIONS_DETECTED -gt 0 ]; then
        echo -e "${RED}${BOLD}PERFORMANCE STATUS: REGRESSION DETECTED${NC}"
        return 1
    elif [ $FAILED_BENCHMARKS -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}PERFORMANCE STATUS: SOME BENCHMARKS FAILED${NC}"
        return 1
    elif [ $IMPROVEMENTS_DETECTED -gt 0 ]; then
        echo -e "${GREEN}${BOLD}PERFORMANCE STATUS: IMPROVEMENTS DETECTED${NC}"
        return 0
    else
        echo -e "${GREEN}${BOLD}PERFORMANCE STATUS: ALL BENCHMARKS PASSED${NC}"
        return 0
    fi
}

# Main execution
main() {
    local benchmark_type="all"
    local create_baseline=false
    local compare_mode=false
    
    BENCHMARK_START_TIME=$(date +%s)
    
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
                CREATE_BASELINE=true
                shift
                ;;
            --compare)
                compare_mode=true
                shift
                ;;
            --regression-threshold)
                REGRESSION_THRESHOLD_PERCENT="$2"
                shift 2
                ;;
            --timeout)
                DEFAULT_TIMEOUT="$2"
                shift 2
                ;;
            --all|--scripts|--memory|--cpu|--disk-io|--network|--quality-tools|--integration)
                benchmark_type="${1#--}"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Initialize
    init_benchmarks
    
    echo -e "${BOLD}${BLUE}Starting Performance Benchmarks${NC}"
    echo "Benchmark Type: $benchmark_type"
    if [ "$CREATE_BASELINE" = "true" ]; then
        echo "Mode: Creating new baseline"
    elif [ "$compare_mode" = "true" ]; then
        echo "Mode: Comparing with baseline"
    fi
    echo ""
    
    # Run benchmarks based on type
    case "$benchmark_type" in
        "all")
            benchmark_scripts
            benchmark_memory
            benchmark_quality_tools
            ;;
        "scripts")
            benchmark_scripts
            ;;
        "memory")
            benchmark_memory
            ;;
        "quality-tools")
            benchmark_quality_tools
            ;;
    esac
    
    # Display results
    if [ "${QUIET:-false}" != "true" ]; then
        display_results
    fi
}

# Run main function
main "$@"