#!/bin/bash

# State Persistence Manager for Memory-Optimized Research Pipeline
# Manages JSON state handoffs between micro-agents with validation and error recovery

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SESSIONS_DIR="$PROJECT_ROOT/sessions"
SCHEMAS_DIR="$SCRIPT_DIR/schemas"

# Logging configuration
LOG_FILE="$PROJECT_ROOT/.claude/logs/state-persistence.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Utility functions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [STATE-MANAGER] $*" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $*"
    exit 1
}

validate_json() {
    local file_path="$1"
    if ! jq empty "$file_path" 2>/dev/null; then
        error_exit "Invalid JSON structure in $file_path"
    fi
}

validate_schema() {
    local file_path="$1"
    local schema_name="$2"
    local schema_file="$SCHEMAS_DIR/${schema_name}.json"

    if [[ -f "$schema_file" ]]; then
        if ! jq -s '.[0] as $schema | .[1] | map(select($schema | contains(.) | not))' "$schema_file" "$file_path" >/dev/null 2>&1; then
            log "WARNING: Schema validation failed for $file_path against $schema_name"
            return 1
        fi
    else
        log "WARNING: Schema file $schema_file not found, skipping validation"
        return 1
    fi
    return 0
}

# Main functions

# Initialize session directory with proper structure
init_session() {
    local episode_topic="$1"
    local episode_number="${2:-$(date +%s)}"
    local session_id="ep_${episode_number}_optimized_$(date +%Y%m%d_%H%M%S)"
    local session_dir="$SESSIONS_DIR/$session_id"

    log "Initializing session: $session_id"
    mkdir -p "$session_dir"

    # Create initial pipeline status
    cat > "$session_dir/pipeline_status.json" << EOF
{
  "session_id": "$session_id",
  "episode_number": $episode_number,
  "episode_topic": "$episode_topic",
  "created_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "pipeline_status": "initialized",
  "stages_completed": [],
  "current_stage": "discovery",
  "memory_optimization": {
    "external_state_persistence": true,
    "streaming_processing": true,
    "garbage_collection": true
  },
  "cost_tracking": {
    "total_budget": 2.00,
    "spent": 0.00,
    "remaining": 2.00
  }
}
EOF

    echo "$session_dir"
    log "Session initialized successfully: $session_dir"
}

# Save stage results with validation and backup
save_stage_result() {
    local session_dir="$1"
    local stage_name="$2"
    local json_data="$3"
    local output_file="$session_dir/${stage_name}.json"
    local backup_file="${output_file}.backup"

    log "Saving $stage_name results to $output_file"

    # Create backup if file exists
    if [[ -f "$output_file" ]]; then
        cp "$output_file" "$backup_file"
        log "Created backup: $backup_file"
    fi

    # Save new data
    echo "$json_data" > "$output_file"

    # Validate JSON structure
    validate_json "$output_file"

    # Validate against schema if available
    validate_schema "$output_file" "$stage_name"

    # Update pipeline status
    update_pipeline_status "$session_dir" "$stage_name" "completed"

    log "Successfully saved $stage_name results"
}

# Load stage input with error handling
load_stage_input() {
    local session_dir="$1"
    local input_file_name="$2"
    local input_file="$session_dir/$input_file_name"

    log "Loading input from $input_file"

    if [[ ! -f "$input_file" ]]; then
        error_exit "Input file not found: $input_file"
    fi

    # Validate JSON structure
    validate_json "$input_file"

    # Return file path for agent to read
    echo "$input_file"
    log "Successfully loaded input: $input_file"
}

# Update pipeline status tracking
update_pipeline_status() {
    local session_dir="$1"
    local stage_name="$2"
    local status="$3"
    local status_file="$session_dir/pipeline_status.json"

    log "Updating pipeline status: $stage_name = $status"

    # Update status with jq
    local temp_file=$(mktemp)
    jq --arg stage "$stage_name" --arg status "$status" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
        .stages_completed += [$stage] |
        .last_updated = $timestamp |
        if $status == "completed" then
            .pipeline_status = "stage_" + $stage + "_completed"
        elif $status == "error" then
            .pipeline_status = "stage_" + $stage + "_failed"
        else
            .pipeline_status = $status
        end
    ' "$status_file" > "$temp_file"

    mv "$temp_file" "$status_file"
    validate_json "$status_file"

    log "Pipeline status updated successfully"
}

# Memory usage monitoring
monitor_memory_usage() {
    local session_dir="$1"
    local stage_name="$2"
    local memory_log="$session_dir/memory_usage_log.json"

    # Get current memory usage (macOS specific)
    local memory_usage
    if command -v ps >/dev/null; then
        memory_usage=$(ps -o pid,rss,command | grep -E "(claude|node)" | grep -v grep | head -1 | awk '{print $2}') || memory_usage="unknown"
    else
        memory_usage="unavailable"
    fi

    # Initialize or update memory log
    if [[ ! -f "$memory_log" ]]; then
        echo '{"memory_tracking": []}' > "$memory_log"
    fi

    # Add memory usage data point
    local temp_file=$(mktemp)
    jq --arg stage "$stage_name" --arg memory "$memory_usage" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
        .memory_tracking += [{
            "stage": $stage,
            "memory_kb": $memory,
            "timestamp": $timestamp,
            "memory_mb": ($memory | tonumber / 1024 | floor)
        }]
    ' "$memory_log" > "$temp_file"

    mv "$temp_file" "$memory_log"
    log "Memory usage logged: $stage_name = ${memory_usage}KB"
}

# Cost tracking update
update_cost_tracking() {
    local session_dir="$1"
    local stage_cost="$2"
    local status_file="$session_dir/pipeline_status.json"

    log "Updating cost tracking: +$stage_cost"

    local temp_file=$(mktemp)
    jq --argjson cost "$stage_cost" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
        .cost_tracking.spent = (.cost_tracking.spent + $cost) |
        .cost_tracking.remaining = (.cost_tracking.total_budget - .cost_tracking.spent) |
        .cost_tracking.last_updated = $timestamp
    ' "$status_file" > "$temp_file"

    mv "$temp_file" "$status_file"
    log "Cost tracking updated: spent $stage_cost, total $(jq -r '.cost_tracking.spent' "$status_file")"
}

# Error recovery utilities
create_recovery_checkpoint() {
    local session_dir="$1"
    local stage_name="$2"
    local checkpoint_dir="$session_dir/checkpoints"

    mkdir -p "$checkpoint_dir"

    # Copy current session state
    cp -r "$session_dir"/*.json "$checkpoint_dir/" 2>/dev/null || true

    # Create checkpoint metadata
    cat > "$checkpoint_dir/checkpoint_${stage_name}.json" << EOF
{
  "checkpoint_stage": "$stage_name",
  "created_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "session_id": "$(basename "$session_dir")",
  "recovery_instructions": "Load checkpoint and resume from $stage_name stage"
}
EOF

    log "Recovery checkpoint created for $stage_name"
}

# Main command dispatcher
main() {
    case "${1:-}" in
        "init")
            init_session "${2:-}" "${3:-}"
            ;;
        "save")
            save_stage_result "$2" "$3" "$4"
            ;;
        "load")
            load_stage_input "$2" "$3"
            ;;
        "update-status")
            update_pipeline_status "$2" "$3" "$4"
            ;;
        "monitor-memory")
            monitor_memory_usage "$2" "$3"
            ;;
        "update-cost")
            update_cost_tracking "$2" "$3"
            ;;
        "checkpoint")
            create_recovery_checkpoint "$2" "$3"
            ;;
        *)
            echo "Usage: $0 {init|save|load|update-status|monitor-memory|update-cost|checkpoint} [args...]"
            echo ""
            echo "Commands:"
            echo "  init TOPIC [EPISODE_NUM]           - Initialize new session"
            echo "  save SESSION_DIR STAGE JSON_DATA   - Save stage results"
            echo "  load SESSION_DIR INPUT_FILE         - Load stage input"
            echo "  update-status SESSION_DIR STAGE STATUS - Update pipeline status"
            echo "  monitor-memory SESSION_DIR STAGE   - Log memory usage"
            echo "  update-cost SESSION_DIR COST       - Update cost tracking"
            echo "  checkpoint SESSION_DIR STAGE       - Create recovery checkpoint"
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
