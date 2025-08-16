#!/bin/bash

# Performance Baseline Manager for Level-1-Dev Quality System
# Manages performance baselines, tracks trends, and detects performance regressions

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
TRENDS_DIR="$BENCHMARKS_DIR/trends"
ARCHIVE_DIR="$BENCHMARKS_DIR/archive"
BASELINE_INDEX="$BASELINES_DIR/baseline-index.json"

# Function: Display help
show_help() {
    cat << EOF
Performance Baseline Manager for Level-1-Dev Quality System

Usage: $(basename "$0") [command] [options]

Commands:
    create              Create new performance baseline
    update              Update existing baseline
    list                List all baselines
    show                Show baseline details
    compare             Compare two baselines
    trend               Show performance trends
    archive             Archive old baselines
    restore             Restore archived baseline
    validate            Validate baseline integrity

Options:
    -h, --help          Show this help message
    -v, --verbose       Show detailed output
    -q, --quiet         Suppress non-error output
    -f, --format FORMAT Output format (json|markdown|console) [default: console]
    --baseline NAME     Specific baseline name
    --date DATE         Baseline date (YYYY-MM-DD)
    --component NAME    Component name filter
    --metric TYPE       Metric type filter (execution_time|memory|cpu)

Baseline Management:
    $(basename "$0") create --baseline stable-v1.0      # Create named baseline
    $(basename "$0") update --baseline stable-v1.0      # Update existing baseline
    $(basename "$0") list                               # List all baselines
    $(basename "$0") show --baseline stable-v1.0        # Show baseline details

Comparison and Analysis:
    $(basename "$0") compare baseline1 baseline2        # Compare two baselines
    $(basename "$0") trend --component quality-dashboard # Show performance trend
    $(basename "$0") validate                           # Validate all baselines

Maintenance:
    $(basename "$0") archive --date 2024-01-01         # Archive old baselines
    $(basename "$0") restore archived-baseline          # Restore from archive

Examples:
    $(basename "$0") create --baseline release-v1.2.3
    $(basename "$0") trend --component security-scanner --metric execution_time
    $(basename "$0") compare stable-v1.0 stable-v1.1

EOF
}

# Function: Initialize baseline manager
init_baseline_manager() {
    setup_error_handling
    
    # Create directories
    mkdir -p "$BASELINES_DIR" "$TRENDS_DIR" "$ARCHIVE_DIR"
    
    # Initialize baseline index if not exists
    if [ ! -f "$BASELINE_INDEX" ]; then
        cat > "$BASELINE_INDEX" << EOF
{
  "version": "1.0.0",
  "created": "$(date -Iseconds)",
  "baselines": {}
}
EOF
    fi
    
    log_info "BASELINE_MANAGER_INITIALIZED" "Performance baseline manager initialized"
}

# Function: Create baseline
create_baseline() {
    local baseline_name="$1"
    local description="${2:-Automated baseline}"
    
    echo -e "${BLUE}Creating performance baseline: $baseline_name${NC}"
    
    # Validate baseline name
    if [[ ! "$baseline_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        log_error "INVALID_BASELINE_NAME" "Baseline name must contain only alphanumeric characters, dots, hyphens, and underscores"
        return 1
    fi
    
    # Check if baseline already exists
    if baseline_exists "$baseline_name"; then
        log_error "BASELINE_EXISTS" "Baseline '$baseline_name' already exists. Use 'update' to modify it."
        return 1
    fi
    
    # Run performance benchmarks to create baseline
    echo "Running performance benchmarks to establish baseline..."
    local benchmark_output
    benchmark_output=$(cd "$LEVEL1_DIR" && "$SCRIPT_DIR/performance-benchmarks.sh" --baseline --format json 2>/dev/null) || {
        log_error "BENCHMARK_FAILED" "Failed to run performance benchmarks"
        return 1
    }
    
    # Create baseline directory
    local baseline_dir="$BASELINES_DIR/$baseline_name"
    mkdir -p "$baseline_dir"
    
    # Copy benchmark results to baseline
    cp "$BENCHMARKS_DIR/results"/benchmark-*.json "$baseline_dir/benchmark-results.json" 2>/dev/null || true
    
    # Create baseline metadata
    create_baseline_metadata "$baseline_name" "$description" "$baseline_dir"
    
    # Update baseline index
    update_baseline_index "$baseline_name" "created" "$description"
    
    echo -e "${GREEN}✓ Baseline '$baseline_name' created successfully${NC}"
    log_info "BASELINE_CREATED" "Performance baseline created: $baseline_name"
}

# Function: Check if baseline exists
baseline_exists() {
    local baseline_name="$1"
    
    if command -v jq >/dev/null 2>&1; then
        jq -e ".baselines.\"$baseline_name\"" "$BASELINE_INDEX" >/dev/null 2>&1
    else
        grep -q "\"$baseline_name\"" "$BASELINE_INDEX" 2>/dev/null
    fi
}

# Function: Create baseline metadata
create_baseline_metadata() {
    local baseline_name="$1"
    local description="$2"
    local baseline_dir="$3"
    
    # Collect system information
    local system_info
    system_info=$(cat << EOF
{
  "hostname": "$(hostname 2>/dev/null || echo 'unknown')",
  "os": "$(uname -s 2>/dev/null || echo 'unknown')",
  "os_version": "$(uname -r 2>/dev/null || echo 'unknown')",
  "cpu_cores": $(nproc 2>/dev/null || echo 1),
  "memory_mb": $(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo 0),
  "git_commit": "$(cd "$LEVEL1_DIR" && git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
  "git_branch": "$(cd "$LEVEL1_DIR" && git branch --show-current 2>/dev/null || echo 'unknown')"
}
EOF
)
    
    # Create metadata file
    cat > "$baseline_dir/metadata.json" << EOF
{
  "name": "$baseline_name",
  "description": "$description",
  "created": "$(date -Iseconds)",
  "version": "1.0.0",
  "system_info": $system_info,
  "benchmark_files": [
    "benchmark-results.json"
  ],
  "metrics": {
    "execution_time": true,
    "memory_usage": true,
    "cpu_usage": false,
    "disk_io": false
  }
}
EOF
}

# Function: Update baseline index
update_baseline_index() {
    local baseline_name="$1"
    local action="$2"
    local description="$3"
    
    if command -v jq >/dev/null 2>&1; then
        local temp_index=$(mktemp)
        jq ".baselines.\"$baseline_name\" = {
            \"description\": \"$description\",
            \"action\": \"$action\",
            \"updated\": \"$(date -Iseconds)\",
            \"path\": \"$baseline_name\"
        }" "$BASELINE_INDEX" > "$temp_index"
        mv "$temp_index" "$BASELINE_INDEX"
    else
        # Fallback for systems without jq
        log_warn "JQ_NOT_AVAILABLE" "jq not available, using simple baseline tracking"
    fi
}

# Function: List baselines
list_baselines() {
    echo -e "${BLUE}Performance Baselines${NC}"
    echo "══════════════════════════════════════════════════════"
    
    if [ ! -f "$BASELINE_INDEX" ]; then
        echo "No baselines found."
        return 0
    fi
    
    if command -v jq >/dev/null 2>&1; then
        # Use jq for formatted output
        echo ""
        printf "%-20s %-15s %-25s %s\n" "NAME" "ACTION" "UPDATED" "DESCRIPTION"
        echo "────────────────────────────────────────────────────────────────────────────────"
        
        jq -r '.baselines | to_entries[] | "\(.key)|\(.value.action)|\(.value.updated)|\(.value.description)"' "$BASELINE_INDEX" | \
        while IFS='|' read -r name action updated description; do
            # Truncate long descriptions
            short_desc=$(echo "$description" | cut -c1-40)
            if [ ${#description} -gt 40 ]; then
                short_desc="${short_desc}..."
            fi
            
            printf "%-20s %-15s %-25s %s\n" "$name" "$action" "$updated" "$short_desc"
        done
    else
        # Fallback without jq
        echo "Baseline directories found:"
        ls -la "$BASELINES_DIR" 2>/dev/null | grep "^d" | awk '{print $9}' | grep -v "^\.$\|^\.\.$" || echo "None"
    fi
    
    echo ""
    echo "Total baselines: $(ls -1 "$BASELINES_DIR" 2>/dev/null | wc -l)"
}

# Function: Show baseline details
show_baseline() {
    local baseline_name="$1"
    
    if ! baseline_exists "$baseline_name"; then
        log_error "BASELINE_NOT_FOUND" "Baseline '$baseline_name' not found"
        return 1
    fi
    
    local baseline_dir="$BASELINES_DIR/$baseline_name"
    local metadata_file="$baseline_dir/metadata.json"
    
    echo -e "${BLUE}Baseline Details: $baseline_name${NC}"
    echo "══════════════════════════════════════════════════════"
    
    if [ -f "$metadata_file" ]; then
        if command -v jq >/dev/null 2>&1; then
            echo ""
            echo -e "${CYAN}Metadata:${NC}"
            echo "  Name: $(jq -r '.name' "$metadata_file")"
            echo "  Description: $(jq -r '.description' "$metadata_file")"
            echo "  Created: $(jq -r '.created' "$metadata_file")"
            echo "  Version: $(jq -r '.version' "$metadata_file")"
            echo ""
            
            echo -e "${CYAN}System Information:${NC}"
            jq -r '.system_info | to_entries[] | "  \(.key): \(.value)"' "$metadata_file"
            echo ""
            
            echo -e "${CYAN}Available Metrics:${NC}"
            jq -r '.metrics | to_entries[] | select(.value == true) | "  ✓ \(.key)"' "$metadata_file"
            echo ""
        else
            echo "Metadata file found but jq not available for parsing"
        fi
    else
        echo "No metadata file found for this baseline"
    fi
    
    # Show benchmark results summary
    local results_file="$baseline_dir/benchmark-results.json"
    if [ -f "$results_file" ] && command -v jq >/dev/null 2>&1; then
        echo -e "${CYAN}Benchmark Results Summary:${NC}"
        local total_benchmarks=$(jq -r '.summary.total_benchmarks // 0' "$results_file")
        local passed_benchmarks=$(jq -r '.summary.passed_benchmarks // 0' "$results_file")
        local failed_benchmarks=$(jq -r '.summary.failed_benchmarks // 0' "$results_file")
        
        echo "  Total Benchmarks: $total_benchmarks"
        echo "  Passed: $passed_benchmarks"
        echo "  Failed: $failed_benchmarks"
        echo ""
        
        # Show top benchmark results
        echo -e "${CYAN}Key Performance Metrics:${NC}"
        jq -r '.benchmarks[] | select(.type == "script_execution" or .type == "quality_tool") | 
               "\(.name): \(.result.average // "N/A") ms"' "$results_file" | head -5 | \
        while read -r line; do
            echo "  $line"
        done
    fi
}

# Function: Compare baselines
compare_baselines() {
    local baseline1="$1"
    local baseline2="$2"
    
    if ! baseline_exists "$baseline1"; then
        log_error "BASELINE1_NOT_FOUND" "Baseline '$baseline1' not found"
        return 1
    fi
    
    if ! baseline_exists "$baseline2"; then
        log_error "BASELINE2_NOT_FOUND" "Baseline '$baseline2' not found"
        return 1
    fi
    
    echo -e "${BLUE}Comparing Baselines: $baseline1 vs $baseline2${NC}"
    echo "══════════════════════════════════════════════════════"
    
    local results1="$BASELINES_DIR/$baseline1/benchmark-results.json"
    local results2="$BASELINES_DIR/$baseline2/benchmark-results.json"
    
    if [ ! -f "$results1" ] || [ ! -f "$results2" ]; then
        log_error "RESULTS_NOT_FOUND" "Benchmark results not found for one or both baselines"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_error "JQ_REQUIRED" "jq is required for baseline comparison"
        return 1
    fi
    
    echo ""
    printf "%-25s %-15s %-15s %-15s %s\n" "BENCHMARK" "$baseline1" "$baseline2" "CHANGE" "STATUS"
    echo "────────────────────────────────────────────────────────────────────────────────"
    
    # Get common benchmarks
    local common_benchmarks
    common_benchmarks=$(comm -12 \
        <(jq -r '.benchmarks[].name' "$results1" | sort) \
        <(jq -r '.benchmarks[].name' "$results2" | sort))
    
    echo "$common_benchmarks" | while read -r benchmark_name; do
        if [ -n "$benchmark_name" ]; then
            local value1=$(jq -r ".benchmarks[] | select(.name == \"$benchmark_name\") | .result.average // 0" "$results1")
            local value2=$(jq -r ".benchmarks[] | select(.name == \"$benchmark_name\") | .result.average // 0" "$results2")
            
            if [ "$value1" != "0" ] && [ "$value2" != "0" ]; then
                local change_percent=$(echo "scale=1; (($value2 - $value1) / $value1) * 100" | bc -l 2>/dev/null || echo "0")
                local status=""
                local status_color=""
                
                if (( $(echo "$change_percent > 20" | bc -l 2>/dev/null || echo "0") )); then
                    status="REGRESSION"
                    status_color="$RED"
                elif (( $(echo "$change_percent < -10" | bc -l 2>/dev/null || echo "0") )); then
                    status="IMPROVEMENT"
                    status_color="$GREEN"
                else
                    status="STABLE"
                    status_color="$CYAN"
                fi
                
                printf "%-25s %-15s %-15s %+14.1f%% " "$benchmark_name" "${value1}ms" "${value2}ms" "$change_percent"
                echo -e "${status_color}$status${NC}"
            fi
        fi
    done
    
    echo ""
}

# Function: Show performance trends
show_trends() {
    local component="${1:-all}"
    local metric_type="${2:-execution_time}"
    
    echo -e "${BLUE}Performance Trends: $component ($metric_type)${NC}"
    echo "══════════════════════════════════════════════════════"
    
    # Create trends data file
    local trends_file="$TRENDS_DIR/${component}_${metric_type}_trend.json"
    
    # Collect data from all baselines
    local trend_data="[]"
    
    for baseline_dir in "$BASELINES_DIR"/*; do
        if [ -d "$baseline_dir" ]; then
            local baseline_name=$(basename "$baseline_dir")
            local results_file="$baseline_dir/benchmark-results.json"
            local metadata_file="$baseline_dir/metadata.json"
            
            if [ -f "$results_file" ] && [ -f "$metadata_file" ] && command -v jq >/dev/null 2>&1; then
                local created_date=$(jq -r '.created' "$metadata_file")
                
                # Extract relevant metrics
                if [ "$component" = "all" ]; then
                    # Average across all components
                    local avg_value=$(jq -r ".benchmarks[] | select(.type == \"script_execution\" or .type == \"quality_tool\") | .result.average // 0" "$results_file" | \
                        awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
                else
                    # Specific component
                    local avg_value=$(jq -r ".benchmarks[] | select(.name == \"$component\") | .result.average // 0" "$results_file")
                fi
                
                if [ "$avg_value" != "0" ]; then
                    local data_point=$(cat << EOF
{
  "baseline": "$baseline_name",
  "date": "$created_date",
  "value": $avg_value,
  "component": "$component",
  "metric": "$metric_type"
}
EOF
)
                    trend_data=$(echo "$trend_data" | jq ". += [$data_point]" 2>/dev/null || echo "$trend_data")
                fi
            fi
        fi
    done
    
    # Save trends data
    echo "$trend_data" > "$trends_file"
    
    # Display trends
    if command -v jq >/dev/null 2>&1; then
        echo ""
        printf "%-20s %-25s %-15s\n" "BASELINE" "DATE" "VALUE"
        echo "────────────────────────────────────────────────────────────"
        
        echo "$trend_data" | jq -r '.[] | "\(.baseline)|\(.date)|\(.value)"' | sort -t'|' -k2 | \
        while IFS='|' read -r baseline date value; do
            printf "%-20s %-25s %-15.1fms\n" "$baseline" "$date" "$value"
        done
        
        echo ""
        echo -e "${CYAN}Trend Analysis:${NC}"
        
        # Calculate trend direction
        local values=($(echo "$trend_data" | jq -r '.[] | .value' | sort -n))
        local count=${#values[@]}
        
        if [ $count -gt 1 ]; then
            local first_value=${values[0]}
            local last_value=${values[$((count-1))]}
            local trend_change=$(echo "scale=1; (($last_value - $first_value) / $first_value) * 100" | bc -l 2>/dev/null || echo "0")
            
            if (( $(echo "$trend_change > 10" | bc -l 2>/dev/null || echo "0") )); then
                echo -e "  ${RED}Performance is degrading (${trend_change}% increase)${NC}"
            elif (( $(echo "$trend_change < -10" | bc -l 2>/dev/null || echo "0") )); then
                echo -e "  ${GREEN}Performance is improving (${trend_change}% decrease)${NC}"
            else
                echo -e "  ${CYAN}Performance is stable (${trend_change}% change)${NC}"
            fi
        else
            echo "  Insufficient data for trend analysis"
        fi
    else
        echo "jq is required for trend analysis"
    fi
}

# Function: Archive old baselines
archive_baselines() {
    local cutoff_date="$1"
    
    echo -e "${BLUE}Archiving baselines older than: $cutoff_date${NC}"
    
    local archived_count=0
    
    for baseline_dir in "$BASELINES_DIR"/*; do
        if [ -d "$baseline_dir" ]; then
            local baseline_name=$(basename "$baseline_dir")
            local metadata_file="$baseline_dir/metadata.json"
            
            if [ -f "$metadata_file" ] && command -v jq >/dev/null 2>&1; then
                local created_date=$(jq -r '.created' "$metadata_file" | cut -d'T' -f1)
                
                if [[ "$created_date" < "$cutoff_date" ]]; then
                    echo "Archiving baseline: $baseline_name ($created_date)"
                    
                    # Create archive
                    local archive_file="$ARCHIVE_DIR/${baseline_name}_${created_date}.tar.gz"
                    tar -czf "$archive_file" -C "$BASELINES_DIR" "$baseline_name"
                    
                    # Remove original
                    rm -rf "$baseline_dir"
                    
                    # Update index
                    if command -v jq >/dev/null 2>&1; then
                        local temp_index=$(mktemp)
                        jq "del(.baselines.\"$baseline_name\")" "$BASELINE_INDEX" > "$temp_index"
                        mv "$temp_index" "$BASELINE_INDEX"
                    fi
                    
                    ((archived_count++))
                fi
            fi
        fi
    done
    
    echo "Archived $archived_count baselines"
    log_info "BASELINES_ARCHIVED" "Archived $archived_count baselines older than $cutoff_date"
}

# Function: Validate baselines
validate_baselines() {
    echo -e "${BLUE}Validating baseline integrity${NC}"
    
    local total_baselines=0
    local valid_baselines=0
    local invalid_baselines=0
    
    for baseline_dir in "$BASELINES_DIR"/*; do
        if [ -d "$baseline_dir" ]; then
            local baseline_name=$(basename "$baseline_dir")
            ((total_baselines++))
            
            echo -n "Validating $baseline_name... "
            
            # Check required files
            local metadata_file="$baseline_dir/metadata.json"
            local results_file="$baseline_dir/benchmark-results.json"
            
            local valid=true
            
            if [ ! -f "$metadata_file" ]; then
                echo -e "${RED}✗ Missing metadata${NC}"
                valid=false
            elif [ ! -f "$results_file" ]; then
                echo -e "${RED}✗ Missing results${NC}"
                valid=false
            elif command -v jq >/dev/null 2>&1; then
                # Validate JSON structure
                if ! jq -e '.name' "$metadata_file" >/dev/null 2>&1; then
                    echo -e "${RED}✗ Invalid metadata JSON${NC}"
                    valid=false
                elif ! jq -e '.benchmarks' "$results_file" >/dev/null 2>&1; then
                    echo -e "${RED}✗ Invalid results JSON${NC}"
                    valid=false
                fi
            fi
            
            if [ "$valid" = "true" ]; then
                echo -e "${GREEN}✓ Valid${NC}"
                ((valid_baselines++))
            else
                ((invalid_baselines++))
            fi
        fi
    done
    
    echo ""
    echo "Validation Summary:"
    echo "  Total baselines: $total_baselines"
    echo -e "  Valid: ${GREEN}$valid_baselines${NC}"
    echo -e "  Invalid: ${RED}$invalid_baselines${NC}"
    
    if [ $invalid_baselines -eq 0 ]; then
        echo -e "${GREEN}✓ All baselines are valid${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Some baselines have issues${NC}"
        return 1
    fi
}

# Main execution
main() {
    local command=""
    local baseline_name=""
    local baseline2=""
    local component="all"
    local metric_type="execution_time"
    local cutoff_date=""
    
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
            --component)
                component="$2"
                shift 2
                ;;
            --metric)
                metric_type="$2"
                shift 2
                ;;
            --date)
                cutoff_date="$2"
                shift 2
                ;;
            create|update|list|show|compare|trend|archive|restore|validate)
                command="$1"
                shift
                ;;
            *)
                if [ -z "$baseline_name" ]; then
                    baseline_name="$1"
                elif [ -z "$baseline2" ] && [ "$command" = "compare" ]; then
                    baseline2="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Default command
    if [ -z "$command" ]; then
        command="list"
    fi
    
    # Initialize
    init_baseline_manager
    
    # Execute command
    case "$command" in
        create)
            if [ -z "$baseline_name" ]; then
                baseline_name="baseline-$(date +%Y%m%d_%H%M%S)"
            fi
            create_baseline "$baseline_name"
            ;;
        list)
            list_baselines
            ;;
        show)
            if [ -z "$baseline_name" ]; then
                log_error "BASELINE_REQUIRED" "Baseline name required for show command"
                exit 1
            fi
            show_baseline "$baseline_name"
            ;;
        compare)
            if [ -z "$baseline_name" ] || [ -z "$baseline2" ]; then
                log_error "TWO_BASELINES_REQUIRED" "Two baseline names required for compare command"
                exit 1
            fi
            compare_baselines "$baseline_name" "$baseline2"
            ;;
        trend)
            show_trends "$component" "$metric_type"
            ;;
        archive)
            if [ -z "$cutoff_date" ]; then
                # Default: archive baselines older than 30 days
                cutoff_date=$(date -d '30 days ago' '+%Y-%m-%d' 2>/dev/null || date -v-30d '+%Y-%m-%d' 2>/dev/null || echo "2024-01-01")
            fi
            archive_baselines "$cutoff_date"
            ;;
        validate)
            validate_baselines
            ;;
        *)
            log_error "UNKNOWN_COMMAND" "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"