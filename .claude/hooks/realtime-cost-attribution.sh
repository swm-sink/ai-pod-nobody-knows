#!/bin/bash

# Real-Time Cost Attribution - Production API Call Tagging
# Adds immutable correlation tags to every API call for bulletproof cost tracking
# Research-validated minimal overhead approach with maximum attribution accuracy

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
ATTRIBUTION_LOG="$PROJECT_ROOT/.claude/logs/cost-attribution.log"
SESSION_STATE="$PROJECT_ROOT/.claude/state/current-session.json"
COST_TAGS_CACHE="$PROJECT_ROOT/.claude/cache/cost-tags.json"

# Session and episode identification
SESSION_ID="${CLAUDE_SESSION_ID:-session_$(date +%s)_$(hostname -s)}"
CURRENT_EPISODE="${EPISODE_ID:-unknown}"
CURRENT_WORKFLOW="${WORKFLOW_STAGE:-general}"

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/.claude/logs" "$PROJECT_ROOT/.claude/state" "$PROJECT_ROOT/.claude/cache"

# Generate attribution correlation ID
generate_attribution_id() {
    echo "attr_$(date +%s)_$(openssl rand -hex 4)" 2>/dev/null || echo "attr_$(date +%s)_fallback"
}

# Create immutable cost attribution tag
create_cost_tag() {
    local tool_name="$1"
    local operation="${2:-standard}"
    local episode_context="${3:-$CURRENT_EPISODE}"
    local workflow_stage="${4:-$CURRENT_WORKFLOW}"
    local attribution_id=$(generate_attribution_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    # Determine cost center and project code
    local cost_center="ai_podcast_production"
    local project_code="nobody_knows"

    # Episode-specific attribution
    if [[ "$episode_context" =~ ^ep[0-9]+ ]]; then
        cost_center="episode_production"
        project_code="$episode_context"
    fi

    # Workflow-specific attribution
    case "$workflow_stage" in
        "research"|"research-discovery"|"research-deep-dive"|"research-synthesis")
            cost_center="${cost_center}_research"
            ;;
        "planning"|"episode-planner")
            cost_center="${cost_center}_planning"
            ;;
        "script"|"script-writer"|"script-polisher")
            cost_center="${cost_center}_creative"
            ;;
        "quality"|"quality-claude"|"quality-perplexity"|"brand-voice")
            cost_center="${cost_center}_quality"
            ;;
        "audio"|"tts-optimizer"|"audio-synthesizer")
            cost_center="${cost_center}_audio"
            ;;
        *)
            cost_center="${cost_center}_general"
            ;;
    esac

    # Create comprehensive attribution tag
    local cost_tag="{
        \"attribution_id\": \"$attribution_id\",
        \"timestamp\": \"$timestamp\",
        \"session_id\": \"$SESSION_ID\",
        \"episode_id\": \"$episode_context\",
        \"workflow_stage\": \"$workflow_stage\",
        \"cost_center\": \"$cost_center\",
        \"project_code\": \"$project_code\",
        \"tool_name\": \"$tool_name\",
        \"operation\": \"$operation\",
        \"attribution_version\": \"2.0\",
        \"tracking_metadata\": {
            \"hostname\": \"$(hostname -s)\",
            \"user\": \"$(whoami)\",
            \"git_branch\": \"$(git branch --show-current 2>/dev/null || echo 'unknown')\",
            \"git_commit\": \"$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')\"
        }
    }"

    # Cache the tag for immediate use
    echo "$cost_tag" > "$COST_TAGS_CACHE"

    # Log attribution creation
    echo "$timestamp ATTR_CREATED: ID=$attribution_id Episode=$episode_context Workflow=$workflow_stage Tool=$tool_name CostCenter=$cost_center" >> "$ATTRIBUTION_LOG"

    # Return attribution ID for correlation
    echo "$attribution_id"
}

# Apply cost attribution to tool execution
apply_cost_attribution() {
    local tool_name="$1"
    local operation="${2:-standard}"
    local episode_context="${3:-$CURRENT_EPISODE}"
    local workflow_stage="${4:-$CURRENT_WORKFLOW}"
    local attribution_id=$(create_cost_tag "$tool_name" "$operation" "$episode_context" "$workflow_stage")
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    # Update session state with current attribution
    local session_update="{
        \"session_id\": \"$SESSION_ID\",
        \"current_attribution_id\": \"$attribution_id\",
        \"last_updated\": \"$timestamp\",
        \"episode_context\": \"$episode_context\",
        \"workflow_stage\": \"$workflow_stage\",
        \"active_tool\": \"$tool_name\",
        \"operation\": \"$operation\"
    }"

    echo "$session_update" > "$SESSION_STATE"

    # Export attribution variables for MCP and API calls
    export COST_ATTRIBUTION_ID="$attribution_id"
    export COST_ATTRIBUTION_SESSION="$SESSION_ID"
    export COST_ATTRIBUTION_EPISODE="$episode_context"
    export COST_ATTRIBUTION_WORKFLOW="$workflow_stage"
    export COST_ATTRIBUTION_TOOL="$tool_name"

    # Log attribution application
    echo "$timestamp ATTR_APPLIED: ID=$attribution_id Tool=$tool_name Episode=$episode_context Workflow=$workflow_stage Session=$SESSION_ID" >> "$ATTRIBUTION_LOG"

    echo "$attribution_id"
}

# Tag API call with cost attribution
tag_api_call() {
    local provider="$1"
    local endpoint="${2:-unknown}"
    local request_size="${3:-0}"
    local attribution_id="${COST_ATTRIBUTION_ID:-$(generate_attribution_id)}"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    # Create API call record with full attribution
    local api_call_record="{
        \"call_id\": \"call_$(date +%s)_$(openssl rand -hex 3)\",
        \"attribution_id\": \"$attribution_id\",
        \"timestamp\": \"$timestamp\",
        \"provider\": \"$provider\",
        \"endpoint\": \"$endpoint\",
        \"request_size\": $request_size,
        \"session_id\": \"${COST_ATTRIBUTION_SESSION:-$SESSION_ID}\",
        \"episode_id\": \"${COST_ATTRIBUTION_EPISODE:-$CURRENT_EPISODE}\",
        \"workflow_stage\": \"${COST_ATTRIBUTION_WORKFLOW:-$CURRENT_WORKFLOW}\",
        \"tool_name\": \"${COST_ATTRIBUTION_TOOL:-unknown}\",
        \"call_type\": \"api_request\",
        \"attribution_complete\": true
    }"

    # Log API call with attribution
    echo "$api_call_record" >> "$ATTRIBUTION_LOG"
    echo "$timestamp API_TAGGED: Provider=$provider Endpoint=$endpoint AttributionID=$attribution_id Size=$request_size" >> "$ATTRIBUTION_LOG"

    # Return call information for cost tracking
    echo "$api_call_record"
}

# Generate attribution summary for episode/workflow
generate_attribution_summary() {
    local episode_filter="${1:-$CURRENT_EPISODE}"
    local workflow_filter="${2:-all}"
    local date_filter="${3:-$(date '+%Y-%m-%d')}"
    local summary_file="$PROJECT_ROOT/.claude/logs/attribution-summary-$episode_filter-$(date +%Y%m%d).json"

    if [[ ! -f "$ATTRIBUTION_LOG" ]]; then
        echo "No attribution data available" >&2
        return 1
    fi

    # Count attributions by workflow stage
    local research_count=$(grep "$date_filter" "$ATTRIBUTION_LOG" | grep "\"episode_id\": \"$episode_filter\"" | grep "_research" | wc -l)
    local creative_count=$(grep "$date_filter" "$ATTRIBUTION_LOG" | grep "\"episode_id\": \"$episode_filter\"" | grep "_creative" | wc -l)
    local quality_count=$(grep "$date_filter" "$ATTRIBUTION_LOG" | grep "\"episode_id\": \"$episode_filter\"" | grep "_quality" | wc -l)
    local audio_count=$(grep "$date_filter" "$ATTRIBUTION_LOG" | grep "\"episode_id\": \"$episode_filter\"" | grep "_audio" | wc -l)
    local general_count=$(grep "$date_filter" "$ATTRIBUTION_LOG" | grep "\"episode_id\": \"$episode_filter\"" | grep "_general" | wc -l)

    # Generate summary report
    local attribution_summary="{
        \"summary_id\": \"summary_$(date +%s)_$(openssl rand -hex 3)\",
        \"generated_at\": \"$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')\",
        \"episode_id\": \"$episode_filter\",
        \"date_filter\": \"$date_filter\",
        \"attribution_breakdown\": {
            \"research_operations\": $research_count,
            \"creative_operations\": $creative_count,
            \"quality_operations\": $quality_count,
            \"audio_operations\": $audio_count,
            \"general_operations\": $general_count,
            \"total_operations\": $((research_count + creative_count + quality_count + audio_count + general_count))
        },
        \"cost_center_distribution\": {
            \"research_percentage\": $(awk "BEGIN {total=$research_count+$creative_count+$quality_count+$audio_count+$general_count; if(total > 0) printf \"%.1f\", $research_count/total*100; else print 0}"),
            \"creative_percentage\": $(awk "BEGIN {total=$research_count+$creative_count+$quality_count+$audio_count+$general_count; if(total > 0) printf \"%.1f\", $creative_count/total*100; else print 0}"),
            \"quality_percentage\": $(awk "BEGIN {total=$research_count+$creative_count+$quality_count+$audio_count+$general_count; if(total > 0) printf \"%.1f\", $quality_count/total*100; else print 0}"),
            \"audio_percentage\": $(awk "BEGIN {total=$research_count+$creative_count+$quality_count+$audio_count+$general_count; if(total > 0) printf \"%.1f\", $audio_count/total*100; else print 0}")
        }
    }"

    echo "$attribution_summary" | jq '.' > "$summary_file"
    echo "Attribution summary generated: $summary_file" >&2
}

# Set episode and workflow context for session
set_context() {
    local episode_id="${1:-unknown}"
    local workflow_stage="${2:-general}"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    # Update global context
    CURRENT_EPISODE="$episode_id"
    CURRENT_WORKFLOW="$workflow_stage"

    # Update session state
    local context_update="{
        \"session_id\": \"$SESSION_ID\",
        \"context_updated_at\": \"$timestamp\",
        \"episode_context\": \"$episode_id\",
        \"workflow_stage\": \"$workflow_stage\",
        \"context_source\": \"manual_set\"
    }"

    echo "$context_update" > "$SESSION_STATE"

    # Export context for child processes
    export EPISODE_ID="$episode_id"
    export WORKFLOW_STAGE="$workflow_stage"

    echo "$timestamp CONTEXT_SET: Episode=$episode_id Workflow=$workflow_stage Session=$SESSION_ID" >> "$ATTRIBUTION_LOG"
    echo "Context set: Episode=$episode_id, Workflow=$workflow_stage" >&2
}

# Main execution
main() {
    local operation="${1:-create_tag}"
    local tool_name="${2:-unknown}"
    local context_param1="${3:-standard}"
    local context_param2="${4:-$CURRENT_EPISODE}"
    local context_param3="${5:-$CURRENT_WORKFLOW}"

    case "$operation" in
        "create_tag")
            create_cost_tag "$tool_name" "$context_param1" "$context_param2" "$context_param3"
            ;;
        "apply_attribution")
            apply_cost_attribution "$tool_name" "$context_param1" "$context_param2" "$context_param3"
            ;;
        "tag_api_call")
            tag_api_call "$tool_name" "$context_param1" "$context_param2"
            ;;
        "set_context")
            set_context "$tool_name" "$context_param1"  # episode_id, workflow_stage
            ;;
        "generate_summary")
            generate_attribution_summary "$tool_name" "$context_param1" "$context_param2"
            ;;
        "get_current_context")
            if [[ -f "$SESSION_STATE" ]]; then
                cat "$SESSION_STATE" | jq '.'
            else
                echo "{\"session_id\": \"$SESSION_ID\", \"episode_context\": \"$CURRENT_EPISODE\", \"workflow_stage\": \"$CURRENT_WORKFLOW\"}"
            fi
            ;;
        *)
            echo "Usage: $0 {create_tag|apply_attribution|tag_api_call|set_context|generate_summary|get_current_context} [params...]" >&2
            echo "Examples:" >&2
            echo "  $0 create_tag mcp__perplexity research ep001 research-deep-dive" >&2
            echo "  $0 apply_attribution Task script-writer ep001 creative" >&2
            echo "  $0 tag_api_call perplexity /chat/completions 1500" >&2
            echo "  $0 set_context ep002 research" >&2
            echo "  $0 generate_summary ep001 all 2025-08-25" >&2
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
