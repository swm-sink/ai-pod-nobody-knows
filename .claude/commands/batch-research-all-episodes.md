# /batch-research-all-episodes - Batch Research for 125 Episodes

Process research for all 125 episodes using episodes_master.json and the memory-optimized 4-stage research pipeline.

## Usage

```bash
/batch-research-all-episodes [start_episode] [end_episode]
```

**Examples:**
```bash
/batch-research-all-episodes                    # Process all 125 episodes
/batch-research-all-episodes 1 25              # Process episodes 1-25 only
/batch-research-all-episodes 51 75             # Process episodes 51-75 only
```

## System Architecture

**Technical:** Batch orchestration using Claude Code native Task tool delegation to existing memory-optimized research pipeline, with progress tracking, cost monitoring, and error recovery.

**Simple:** Like running the proven research command 125 times automatically, with smart progress saving and cost tracking.

**Connection:** This demonstrates production-scale automation using established patterns without adding complexity.

## Implementation

I will coordinate the complete batch research process using Task tool delegation to the existing `/research-episode-optimized` command:

### Step 1: Initialize Batch Session
```bash
# Create batch session directory
BATCH_SESSION="batch_research_$(date '+%Y%m%d_%H%M%S')"
SESSION_DIR="sessions/$BATCH_SESSION"
mkdir -p "$SESSION_DIR"

# Initialize progress tracking
echo '{"batch_id": "'$BATCH_SESSION'", "total_episodes": 125, "completed": [], "failed": [], "current_costs": 0.0, "started": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"}' > "$SESSION_DIR/batch_progress.json"
```

### Step 2: Load Episodes from episodes_master.json
```bash
# Load all 125 episodes from the master plan
EPISODES_FILE="projects/nobody-knows/series_plan/episodes_master.json"

# Extract episode data: number, title, description for each episode
# Process in order: Season 1 (eps 1-25), Season 2 (eps 26-50), etc.
```

### Step 3: Sequential Episode Processing
For each episode in the specified range, I will:

```bash
# For episode N:
EPISODE_TITLE="[Episode Title from JSON]"
EPISODE_DESCRIPTION="[Episode Description from JSON]"
RESEARCH_TOPIC="$EPISODE_TITLE: $EPISODE_DESCRIPTION"

echo "Processing Episode $N/125: $EPISODE_TITLE"
echo "Research Topic: $RESEARCH_TOPIC"

# Use existing research command
Use Task tool to delegate to research-episode-optimized:
INPUT: "$RESEARCH_TOPIC"
OUTPUT: Research package saved to sessions/ep_${N}_optimized_[timestamp]/
```

### Step 4: Progress Tracking & Cost Monitoring
After each episode completion:

```bash
# Update progress
COMPLETED_COUNT=$(expr $COMPLETED_COUNT + 1)
CURRENT_COST=$(calculate_episode_cost)
TOTAL_COST=$(expr $TOTAL_COST + $CURRENT_COST)

echo "Episode $N completed - Cost: $CURRENT_COST - Total: $TOTAL_COST ($COMPLETED_COUNT/125)"

# Update batch_progress.json
# Add episode to completed list
# Update cost totals
# Save checkpoint for resume capability
```

### Step 5: Error Handling & Recovery
If any episode fails:

```bash
echo "Episode $N FAILED - Reason: $ERROR_REASON"
# Add to failed list in progress.json
# Continue with next episode
# User can retry failed episodes manually later
```

### Step 6: Batch Completion Report
```bash
echo "Batch Research Complete!"
echo "Episodes Completed: $COMPLETED_COUNT/125"
echo "Episodes Failed: $FAILED_COUNT"
echo "Total Cost: $TOTAL_COST"
echo "Average Cost per Episode: $AVERAGE_COST"
echo "Session Directory: $SESSION_DIR"

# Generate final report
create_batch_report
```

## Quality Control

**Research Validation Points:**
- ✅ Each episode uses proven /research-episode-optimized pipeline
- ✅ Research packages saved to individual episode sessions
- ✅ Cost tracking per episode and cumulative
- ✅ Failed episodes logged for manual review

**Progress Checkpoints:**
- Every 10 episodes: Progress summary with cost analysis
- Every 25 episodes: Quality spot-check recommendation
- Every 50 episodes: Major milestone notification

## Error Recovery

**Resume Capability:**
```bash
# If batch processing is interrupted, resume from progress.json
LAST_COMPLETED=$(get_last_completed_episode)
START_FROM=$(expr $LAST_COMPLETED + 1)
echo "Resuming from episode $START_FROM"
```

**Retry Failed Episodes:**
```bash
# Retry specific failed episodes
/batch-research-all-episodes [failed_episode_numbers]
```

## Output Structure

```
sessions/batch_research_YYYYMMDD_HHMMSS/
├── batch_progress.json          # Real-time progress tracking
├── batch_report.md             # Final completion report
├── cost_analysis.json          # Detailed cost breakdown
└── episode_sessions/           # Links to individual episode research
    ├── ep_001 -> ../../ep_001_optimized_TIMESTAMP/
    ├── ep_002 -> ../../ep_002_optimized_TIMESTAMP/
    └── ...
```

## Success Criteria

- ✅ All 125 episodes processed through research pipeline
- ✅ Individual research packages created for each episode
- ✅ Cost tracking maintained throughout batch process
- ✅ Failed episodes identified for manual intervention
- ✅ Resume capability functional if interrupted
- ✅ Total research cost within reasonable bounds (~$250-375 for 125 episodes)

## Integration with Production Phase

Research packages from this batch process will be used by:
```bash
/batch-produce-all-episodes --from-research
```

This separation allows you to:
1. **Review research quality** across all episodes before committing to audio production costs
2. **Optimize research approach** based on patterns and cost analysis
3. **Make production decisions** with complete research foundation

Ready to execute batch research for all 125 episodes using Claude Code native orchestration with existing proven research pipeline.
