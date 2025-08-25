#!/bin/bash

# Cost Tracking Functions for Episode Management
# Provides comprehensive cost tracking and aggregation across episodes

EPISODES_DIR="."
STATE_FILE="state.json"
METRICS_FILE="metrics_history.csv"

# Initialize cost tracking for an episode
init_episode_cost_tracking() {
    local episode="$1"
    local ep_dir="$EPISODES_DIR/production/ep$(printf '%03d' $episode)"

    if [ ! -d "$ep_dir" ]; then
        echo "❌ Episode directory not found: $ep_dir"
        return 1
    fi

    # Enhanced status file with cost tracking
    cat > "$ep_dir/status.json" << EOF
{
    "status": "not_started",
    "costs": {
        "research": 0.0,
        "script_writing": 0.0,
        "quality_review": 0.0,
        "audio_synthesis": 0.0,
        "total": 0.0
    },
    "quality_scores": {
        "brand_voice": 0,
        "technical_accuracy": 0,
        "engagement": 0,
        "overall": 0
    },
    "timestamps": {
        "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "research_started": null,
        "research_completed": null,
        "production_started": null,
        "production_completed": null
    },
    "metadata": {
        "research_queries": 0,
        "script_revisions": 0,
        "audio_duration": 0,
        "total_tokens": 0
    }
}
EOF

    echo "✅ Cost tracking initialized for episode $episode"
}

# Update episode cost for a specific phase
update_episode_cost() {
    local episode="$1"
    local phase="$2"  # research, script_writing, quality_review, audio_synthesis
    local cost="$3"
    local ep_dir="$EPISODES_DIR/production/ep$(printf '%03d' $episode)"
    local status_file="$ep_dir/status.json"

    if [ ! -f "$status_file" ]; then
        echo "❌ Status file not found: $status_file"
        return 1
    fi

    # Update the specific phase cost and recalculate total
    local temp_file=$(mktemp)
    jq --argjson cost "$cost" --arg phase "$phase" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
        .costs[$phase] = $cost |
        .costs.total = (.costs.research + .costs.script_writing + .costs.quality_review + .costs.audio_synthesis) |
        .timestamps.last_updated = $timestamp
    ' "$status_file" > "$temp_file" && mv "$temp_file" "$status_file"

    echo "✅ Updated episode $episode $phase cost: \$$cost"

    # Update aggregate totals
    update_cost_aggregates
}

# Update quality score for an episode
update_episode_quality() {
    local episode="$1"
    local metric="$2"  # brand_voice, technical_accuracy, engagement, overall
    local score="$3"
    local ep_dir="$EPISODES_DIR/production/ep$(printf '%03d' $episode)"
    local status_file="$ep_dir/status.json"

    if [ ! -f "$status_file" ]; then
        echo "❌ Status file not found: $status_file"
        return 1
    fi

    local temp_file=$(mktemp)
    jq --argjson score "$score" --arg metric "$metric" --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
        .quality_scores[$metric] = $score |
        .timestamps.last_updated = $timestamp
    ' "$status_file" > "$temp_file" && mv "$temp_file" "$status_file"

    echo "✅ Updated episode $episode $metric quality score: $score"
}

# Calculate and update aggregate cost totals
update_cost_aggregates() {
    local temp_file=$(mktemp)

    # Calculate production totals
    local total_research_cost=0
    local total_script_cost=0
    local total_quality_cost=0
    local total_audio_cost=0
    local total_overall_cost=0
    local completed_episodes=0
    local researched_episodes=0
    local produced_episodes=0

    # Aggregate costs from all production episodes
    for ep_dir in production/ep*/; do
        if [ -f "${ep_dir}status.json" ]; then
            local ep_status=$(jq -r '.status' "${ep_dir}status.json" 2>/dev/null || echo "not_started")
            local research_cost=$(jq -r '.costs.research // 0' "${ep_dir}status.json" 2>/dev/null || echo "0")
            local script_cost=$(jq -r '.costs.script_writing // 0' "${ep_dir}status.json" 2>/dev/null || echo "0")
            local quality_cost=$(jq -r '.costs.quality_review // 0' "${ep_dir}status.json" 2>/dev/null || echo "0")
            local audio_cost=$(jq -r '.costs.audio_synthesis // 0' "${ep_dir}status.json" 2>/dev/null || echo "0")
            local total_cost=$(jq -r '.costs.total // 0' "${ep_dir}status.json" 2>/dev/null || echo "0")

            total_research_cost=$(echo "$total_research_cost + $research_cost" | bc -l)
            total_script_cost=$(echo "$total_script_cost + $script_cost" | bc -l)
            total_quality_cost=$(echo "$total_quality_cost + $quality_cost" | bc -l)
            total_audio_cost=$(echo "$total_audio_cost + $audio_cost" | bc -l)
            total_overall_cost=$(echo "$total_overall_cost + $total_cost" | bc -l)

            case "$ep_status" in
                "researched"|"producing"|"complete")
                    researched_episodes=$((researched_episodes + 1))
                    ;;
            esac

            case "$ep_status" in
                "producing"|"complete")
                    produced_episodes=$((produced_episodes + 1))
                    ;;
            esac

            case "$ep_status" in
                "complete")
                    completed_episodes=$((completed_episodes + 1))
                    ;;
            esac
        fi
    done

    # Calculate averages (avoid division by zero)
    local avg_cost=0
    if [ $completed_episodes -gt 0 ]; then
        avg_cost=$(echo "scale=2; $total_overall_cost / $completed_episodes" | bc -l)
    fi

    # Update state.json with aggregated data
    jq --argjson researched "$researched_episodes" \
       --argjson produced "$produced_episodes" \
       --argjson completed "$completed_episodes" \
       --argjson total_cost "$total_overall_cost" \
       --argjson avg_cost "$avg_cost" \
       --argjson research_cost "$total_research_cost" \
       --argjson script_cost "$total_script_cost" \
       --argjson quality_cost "$total_quality_cost" \
       --argjson audio_cost "$total_audio_cost" \
       --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       .totals.production.researched = $researched |
       .totals.production.produced = $produced |
       .totals.production.completed = $completed |
       .totals.production.total_cost = $total_cost |
       .totals.production.avg_cost = $avg_cost |
       .totals.production.cost_breakdown = {
           research: $research_cost,
           script_writing: $script_cost,
           quality_review: $quality_cost,
           audio_synthesis: $audio_cost
       } |
       .last_updated = $timestamp
       ' "$STATE_FILE" > "$temp_file" && mv "$temp_file" "$STATE_FILE"

    echo "✅ Cost aggregates updated - Total: \$$total_overall_cost across $completed_episodes episodes"
}

# Add cost entry to metrics history
log_cost_metrics() {
    local episode="$1"
    local phase="$2"
    local cost="$3"
    local quality="${4:-0}"

    # Initialize metrics file if it doesn't exist
    if [ ! -f "$METRICS_FILE" ]; then
        echo "timestamp,episode,phase,cost,quality,cumulative_cost" > "$METRICS_FILE"
    fi

    # Calculate cumulative cost
    local cumulative=$(awk -F',' 'NR>1 {sum+=$4} END {print sum+0}' "$METRICS_FILE")
    cumulative=$(echo "$cumulative + $cost" | bc -l)

    # Add entry
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),$episode,$phase,$cost,$quality,$cumulative" >> "$METRICS_FILE"

    echo "✅ Cost metrics logged for episode $episode $phase"
}

# Display cost summary report
show_cost_report() {
    echo "💰 Cost Tracking Report"
    echo "======================"
    echo

    if [ ! -f "$STATE_FILE" ]; then
        echo "❌ State file not found"
        return 1
    fi

    # Production summary
    echo "📈 Production Episodes:"
    local total_cost=$(jq -r '.totals.production.total_cost // 0' "$STATE_FILE")
    local avg_cost=$(jq -r '.totals.production.avg_cost // 0' "$STATE_FILE")
    local completed=$(jq -r '.totals.production.completed // 0' "$STATE_FILE")
    local researched=$(jq -r '.totals.production.researched // 0' "$STATE_FILE")

    printf "  💵 Total Cost: \$%.2f\n" "$total_cost"
    printf "  📊 Average per Episode: \$%.2f\n" "$avg_cost"
    printf "  ✅ Episodes Completed: %d\n" "$completed"
    printf "  🔍 Episodes Researched: %d\n" "$researched"

    # Cost breakdown
    if jq -e '.totals.production.cost_breakdown' "$STATE_FILE" >/dev/null 2>&1; then
        echo
        echo "💡 Cost Breakdown:"
        local research=$(jq -r '.totals.production.cost_breakdown.research // 0' "$STATE_FILE")
        local script=$(jq -r '.totals.production.cost_breakdown.script_writing // 0' "$STATE_FILE")
        local quality=$(jq -r '.totals.production.cost_breakdown.quality_review // 0' "$STATE_FILE")
        local audio=$(jq -r '.totals.production.cost_breakdown.audio_synthesis // 0' "$STATE_FILE")

        printf "  🔍 Research: \$%.2f\n" "$research"
        printf "  ✍️  Script Writing: \$%.2f\n" "$script"
        printf "  ⭐ Quality Review: \$%.2f\n" "$quality"
        printf "  🎵 Audio Synthesis: \$%.2f\n" "$audio"
    fi

    # Test episodes
    echo
    echo "🧪 Test Episodes:"
    local test_cost=$(jq -r '.totals.test.total_cost // 0' "$STATE_FILE")
    local test_episodes=$(jq -r '.totals.test.episodes_completed // 0' "$STATE_FILE")

    printf "  💵 Total Cost: \$%.2f\n" "$test_cost"
    printf "  📊 Episodes Completed: %d\n" "$test_episodes"

    # Budget alerts
    echo
    show_budget_alerts
}

# Show budget alerts and warnings
show_budget_alerts() {
    local avg_cost=$(jq -r '.totals.production.avg_cost // 0' "$STATE_FILE")
    local target_cost=6.00  # Target cost per episode
    local warning_cost=10.00  # Warning threshold

    echo "🚨 Budget Analysis:"

    if (( $(echo "$avg_cost > $warning_cost" | bc -l) )); then
        printf "  ⚠️  HIGH COST ALERT: Average \$%.2f exceeds warning threshold \$%.2f\n" "$avg_cost" "$warning_cost"
    elif (( $(echo "$avg_cost > $target_cost" | bc -l) )); then
        printf "  ⚠️  Above target: Average \$%.2f exceeds target \$%.2f\n" "$avg_cost" "$target_cost"
    else
        printf "  ✅ On target: Average \$%.2f meets target \$%.2f\n" "$avg_cost" "$target_cost"
    fi

    # Projection for 125 episodes
    local projected_total=$(echo "$avg_cost * 125" | bc -l)
    printf "  📊 Projected total for 125 episodes: \$%.2f\n" "$projected_total"
}

# Find most expensive episodes
show_expensive_episodes() {
    local limit="${1:-5}"
    echo "💸 Most Expensive Episodes (Top $limit):"
    echo "======================================="

    # Create temporary file with episode costs
    local temp_file=$(mktemp)

    for ep_dir in production/ep*/; do
        if [ -f "${ep_dir}status.json" ]; then
            local episode=$(basename "$ep_dir")
            local total_cost=$(jq -r '.costs.total // 0' "${ep_dir}status.json" 2>/dev/null || echo "0")
            local status=$(jq -r '.status // "not_started"' "${ep_dir}status.json" 2>/dev/null)

            if (( $(echo "$total_cost > 0" | bc -l) )); then
                echo "$total_cost|$episode|$status" >> "$temp_file"
            fi
        fi
    done

    # Sort by cost (descending) and show top episodes
    if [ -s "$temp_file" ]; then
        sort -t'|' -k1 -nr "$temp_file" | head -n "$limit" | while IFS='|' read -r cost episode status; do
            printf "  💰 %s: \$%.2f (%s)\n" "$episode" "$cost" "$status"
        done
    else
        echo "  ℹ️  No episodes with cost data found"
    fi

    rm -f "$temp_file"
}
