#!/bin/bash

# Cost Tracking Hook - Monitor Expensive Operations
# Tracks API calls, agent usage, and provides budget warnings

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COST_LOG_FILE="$PROJECT_ROOT/.claude/logs/cost-tracking.log"
COST_DB_FILE="$PROJECT_ROOT/.claude/data/cost-tracking.json"

# Budget configuration
DAILY_BUDGET_WARNING=10.00
DAILY_BUDGET_LIMIT=25.00
WEEKLY_BUDGET_WARNING=50.00
WEEKLY_BUDGET_LIMIT=100.00

# Cost estimates function (USD)
get_operation_cost() {
    local operation="$1"
    local count="${2:-1}"
    
    case "$operation" in
        "perplexity_search") echo "0.005" ;;
        "perplexity_ask") echo "0.02" ;;
        "elevenlabs_tts_short") echo "0.50" ;;
        "elevenlabs_tts_episode") echo "6.00" ;;
        "elevenlabs_voice_clone") echo "5.00" ;;
        "task_research_agent") echo "0.75" ;;
        "task_script_writer") echo "1.25" ;;
        "task_quality_evaluator") echo "0.50" ;;
        "task_audio_synthesizer") echo "6.00" ;;
        *) echo "0.10" ;;  # Default for unknown operations
    esac
}

# Ensure directories exist
mkdir -p "$(dirname "$COST_LOG_FILE")" "$(dirname "$COST_DB_FILE")"

# Initialize cost database if it doesn't exist
if [[ ! -f "$COST_DB_FILE" ]]; then
    echo '{"daily_costs": {}, "weekly_costs": {}, "operation_counts": {}, "budget_alerts": []}' > "$COST_DB_FILE"
fi

# Logging functions
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$COST_LOG_FILE"
}

log_warning() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $*" | tee -a "$COST_LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" | tee -a "$COST_LOG_FILE"
}

log_cost() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [COST] $*" | tee -a "$COST_LOG_FILE"
}

# Cost calculation functions

record_cost() {
    local operation="$1"
    local cost="$2"
    local description="${3:-$operation}"
    
    local today
    today=$(date '+%Y-%m-%d')
    local week
    week=$(date '+%Y-W%U')
    
    # Update cost database
    local temp_file
    temp_file=$(mktemp)
    
    jq --arg date "$today" \
       --arg week "$week" \
       --arg op "$operation" \
       --arg cost "$cost" \
       --arg desc "$description" \
       '.daily_costs[$date] = (.daily_costs[$date] // 0) + ($cost | tonumber) |
        .weekly_costs[$week] = (.weekly_costs[$week] // 0) + ($cost | tonumber) |
        .operation_counts[$op] = (.operation_counts[$op] // 0) + 1' \
        "$COST_DB_FILE" > "$temp_file" && mv "$temp_file" "$COST_DB_FILE"
    
    log_cost "💰 $operation: $cost USD - $description"
}

check_budget_limits() {
    local today
    today=$(date '+%Y-%m-%d')
    local week
    week=$(date '+%Y-W%U')
    
    # Get current costs
    local daily_cost
    daily_cost=$(jq -r --arg date "$today" '.daily_costs[$date] // 0' "$COST_DB_FILE")
    
    local weekly_cost
    weekly_cost=$(jq -r --arg week "$week" '.weekly_costs[$week] // 0' "$COST_DB_FILE")
    
    # Check daily limits
    if (( $(echo "$daily_cost >= $DAILY_BUDGET_LIMIT" | bc -l) )); then
        log_error "🚨 DAILY BUDGET EXCEEDED: $daily_cost USD >= $DAILY_BUDGET_LIMIT USD"
        log_error "🛑 BLOCKING expensive operations for today"
        return 1
    elif (( $(echo "$daily_cost >= $DAILY_BUDGET_WARNING" | bc -l) )); then
        log_warning "⚠️  Daily budget warning: $daily_cost USD >= $DAILY_BUDGET_WARNING USD"
    fi
    
    # Check weekly limits
    if (( $(echo "$weekly_cost >= $WEEKLY_BUDGET_LIMIT" | bc -l) )); then
        log_error "🚨 WEEKLY BUDGET EXCEEDED: $weekly_cost USD >= $WEEKLY_BUDGET_LIMIT USD"
        log_error "🛑 BLOCKING expensive operations for this week"
        return 1
    elif (( $(echo "$weekly_cost >= $WEEKLY_BUDGET_WARNING" | bc -l) )); then
        log_warning "⚠️  Weekly budget warning: $weekly_cost USD >= $WEEKLY_BUDGET_WARNING USD"
    fi
    
    log_info "💚 Budget check passed: Daily $daily_cost USD, Weekly $weekly_cost USD"
    return 0
}

# Hook functions for different operations
track_task_usage() {
    local agent_type="$1"
    local description="${2:-Task operation}"
    
    log_info "🤖 Tracking Task operation: $agent_type"
    
    # Estimate cost based on agent type
    local operation_key="task_${agent_type//-/_}"
    local cost
    cost=$(get_operation_cost "$operation_key" 1)
    
    # Check budget before expensive operations
    if [[ "$agent_type" =~ (audio-synthesizer|research|script-writer) ]]; then
        if ! check_budget_limits; then
            log_error "❌ Operation blocked due to budget limits"
            return 1
        fi
    fi
    
    record_cost "$operation_key" "$cost" "Task: $agent_type - $description"
    return 0
}

track_mcp_usage() {
    local tool_name="$1"
    local parameters="${2:-}"
    
    log_info "🔌 Tracking MCP operation: $tool_name"
    
    local operation_key=""
    local cost=""
    
    case "$tool_name" in
        "mcp__perplexity__perplexity_ask")
            operation_key="perplexity_ask"
            cost=$(get_operation_cost "$operation_key" 1)
            ;;
        "mcp__perplexity__perplexity_search_web")
            operation_key="perplexity_search"
            cost=$(get_operation_cost "$operation_key" 1)
            ;;
        "mcp__ElevenLabs__text_to_speech")
            # Estimate based on text length if available
            if echo "$parameters" | grep -q "18000\|20000\|22000"; then
                operation_key="elevenlabs_tts_episode"
                cost=$(get_operation_cost "$operation_key" 1)
                
                # Check budget for expensive TTS
                if ! check_budget_limits; then
                    log_error "❌ TTS operation blocked due to budget limits"
                    return 1
                fi
            else
                operation_key="elevenlabs_tts_short"
                cost=$(get_operation_cost "$operation_key" 1)
            fi
            ;;
        "mcp__ElevenLabs__voice_clone")
            operation_key="elevenlabs_voice_clone"
            cost=$(get_operation_cost "$operation_key" 1)
            
            if ! check_budget_limits; then
                log_error "❌ Voice cloning blocked due to budget limits"
                return 1
            fi
            ;;
        *)
            operation_key="unknown_mcp"
            cost="0.10"
            ;;
    esac
    
    record_cost "$operation_key" "$cost" "MCP: $tool_name"
    return 0
}

# Reporting functions
generate_cost_report() {
    local period="${1:-daily}"
    
    log_info "📊 Generating $period cost report"
    
    case "$period" in
        daily)
            local today
            today=$(date '+%Y-%m-%d')
            local daily_cost
            daily_cost=$(jq -r --arg date "$today" '.daily_costs[$date] // 0' "$COST_DB_FILE")
            
            echo "📅 Daily Cost Report - $today"
            echo "💰 Total: $daily_cost USD"
            echo "📊 Budget: $daily_cost / $DAILY_BUDGET_WARNING USD (warning) / $DAILY_BUDGET_LIMIT USD (limit)"
            
            if (( $(echo "$daily_cost >= $DAILY_BUDGET_WARNING" | bc -l) )); then
                echo "⚠️  Warning threshold reached"
            fi
            ;;
        weekly)
            local week
            week=$(date '+%Y-W%U')
            local weekly_cost
            weekly_cost=$(jq -r --arg week "$week" '.weekly_costs[$week] // 0' "$COST_DB_FILE")
            
            echo "📅 Weekly Cost Report - Week $week"
            echo "💰 Total: $weekly_cost USD"
            echo "📊 Budget: $weekly_cost / $WEEKLY_BUDGET_WARNING USD (warning) / $WEEKLY_BUDGET_LIMIT USD (limit)"
            
            if (( $(echo "$weekly_cost >= $WEEKLY_BUDGET_WARNING" | bc -l) )); then
                echo "⚠️  Warning threshold reached"
            fi
            ;;
        operations)
            echo "🔧 Operation Usage Report"
            jq -r '.operation_counts | to_entries[] | "\(.key): \(.value) times"' "$COST_DB_FILE"
            ;;
    esac
}

# Main entry point
main() {
    local command="${1:-help}"
    local target="${2:-}"
    local params="${3:-}"
    
    case "$command" in
        track-task)
            track_task_usage "$target" "$params"
            ;;
        track-mcp)
            track_mcp_usage "$target" "$params"
            ;;
        check-budget)
            check_budget_limits
            ;;
        report)
            generate_cost_report "$target"
            ;;
        reset-daily)
            local today
            today=$(date '+%Y-%m-%d')
            jq --arg date "$today" 'del(.daily_costs[$date])' "$COST_DB_FILE" > /tmp/cost-db-temp && mv /tmp/cost-db-temp "$COST_DB_FILE"
            log_info "🔄 Reset daily costs for $today"
            ;;
        help|*)
            echo "Cost Tracking Hook - Budget Management"
            echo ""
            echo "Usage: $0 <command> [target] [params]"
            echo ""
            echo "Commands:"
            echo "  track-task <agent-type> [description]  - Track Task operation cost"
            echo "  track-mcp <tool-name> [params]        - Track MCP operation cost"
            echo "  check-budget                          - Check current budget status"
            echo "  report [daily|weekly|operations]      - Generate cost report"
            echo "  reset-daily                           - Reset today's costs"
            echo "  help                                  - Show this help"
            echo ""
            echo "Budget Limits:"
            echo "  Daily Warning: $DAILY_BUDGET_WARNING USD"
            echo "  Daily Limit: $DAILY_BUDGET_LIMIT USD"
            echo "  Weekly Warning: $WEEKLY_BUDGET_WARNING USD"
            echo "  Weekly Limit: $WEEKLY_BUDGET_LIMIT USD"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"