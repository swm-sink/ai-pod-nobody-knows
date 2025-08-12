# Batch Produce Command

**Purpose**: Process multiple podcast episodes sequentially from research through complete production.

## Command Overview

You are the Batch Production Orchestrator for "Nobody Knows" podcast. Execute multiple episode productions while managing resources and tracking progress.

## Configuration References
- **Production Config**: `.claude/shared/config/production-config.yaml`
- **Episodes Master**: `projects/nobody-knows/series_plan/episodes_master.json`
- **Quality Standards**: `projects/nobody-knows/config/quality_gates.json`
- **Series Bible**: `projects/nobody-knows/series_plan/series_bible.md`

## Input Requirements
- **Episode Numbers**: List of episode numbers (1-125) or range (e.g., "1-5", "season:1")
- **Batch Size**: Maximum episodes to process (default: 5)
- **Mode**: "full" or "scripts-only" (for testing without audio)
- **Cost Limit**: Maximum budget for batch
- **Season Filter**: Optional - process specific season (1-5)

## Batch Production Process

### Step 1: Batch Initialization

1. Load episodes from `episodes_master.json`
2. Filter based on input parameters (episode numbers, season)
3. Create batch session:

```yaml
batch_session_id: "batch_{YYYYMMDD}_{HHMM}"
episodes_to_process: [
  {number: 1, title: "The Dirty Secret: Even the Experts Are Making It Up", complexity: 1},
  {number: 2, title: "The Emperor's New Neural Network", complexity: 1},
  {number: 3, title: "Confession Time: I Asked ChatGPT How ChatGPT Works", complexity: 2}
]
batch_status: "initialized"
season: 1  # If processing by season
```

Save to: `projects/nobody-knows/output/sessions/batch_{date}.json`

### Step 2: Sequential Episode Processing

For each episode in batch:
```
1. Execute produce-episode command
   - Pass episode number (retrieves details from episodes_master.json)
   - Monitor for completion
   - Track individual costs

2. Success Handling
   - Move to next episode
   - Update batch progress
   - Log cumulative metrics

3. Failure Handling
   - Log failure reason
   - Optionally continue or halt batch
   - Save partial results
```

### Step 3: Batch Completion

After all episodes processed:
```yaml
batch_summary:
  total_episodes: 3
  successful: 2
  failed: 1
  total_cost: $12.50
  total_time: 180 minutes
  outputs:
    - episode_1: {all output paths}
    - episode_2: {all output paths}
    - episode_3: {failure reason}
```

## Progress Tracking

### Real-time Updates
```
[1/3] Processing Episode 1: "The Dirty Secret: Even the Experts Are Making It Up"
  ✓ Research complete ($2.50)
  ✓ Script complete ($1.00)
  ✓ Quality passed (0.88)
  ✓ Audio generated ($1.75)
  Episode 1 complete: $5.25 total

[2/3] Processing Episode 2: "The Emperor's New Neural Network"
  ⟳ Research in progress...
```

### Cost Management
- Track cumulative costs
- Alert if approaching limits
- Pause if budget exceeded
- Save state for resumption

## Execution Modes

### Full Production Mode
```bash
Command: batch-produce --mode full --episodes 1-5
Process: Research → Script → Quality → Audio
Output: Complete episodes with audio
```

### Scripts Only Mode
```bash
Command: batch-produce --mode scripts-only --episodes 1-10
Process: Research → Script → Quality
Output: Validated scripts (no audio)
```

### Season Production Mode
```bash
Command: batch-produce --mode full --season 1
Process: All 25 episodes from Season 1
Output: Complete season with audio
```

### Dry Run Mode
```bash
Command: batch-produce --mode dry-run --episodes 1-3
Process: Simulate all steps with mock data
Output: Test results without API calls
```

## Error Recovery

### Automatic Recovery
- Retry failed episodes up to 2 times
- Skip permanently failed episodes
- Continue with remaining batch
- Document all retry attempts

### Manual Intervention Points
1. Quality failure after 3 retries
2. Cost limit exceeded
3. API rate limits hit
4. System errors

## Output Organization

### Directory Structure
```
projects/nobody-knows/output/
├── batch_YYYYMMDD_HHMM/
│   ├── episode_001/
│   │   ├── research.md
│   │   ├── script.md
│   │   ├── quality.json
│   │   └── audio.mp3
│   ├── episode_002/
│   │   └── ... (same structure)
│   └── batch_summary.json
```

### Batch Report
```json
{
  "batch_id": "batch_20250811_1430",
  "configuration": {
    "mode": "full",
    "episodes_requested": 5,
    "cost_limit": 30.00
  },
  "results": {
    "completed": 4,
    "failed": 1,
    "total_cost": 21.00,
    "average_cost_per_episode": 5.25,
    "total_duration_minutes": 240
  },
  "episodes": [
    {
      "number": 1,
      "status": "completed",
      "cost": 5.25,
      "quality_score": 0.88,
      "outputs": {...}
    }
  ]
}
```

## Quality Assurance

### Batch-level Checks
- [ ] All requested episodes attempted
- [ ] Success rate ≥ 80%
- [ ] Average quality score ≥ 0.85
- [ ] Cost per episode < $6.00
- [ ] No data corruption

### Episode-level Validation
- Each episode follows standard quality gates
- Failed episodes documented with reasons
- Successful episodes have all outputs
- Session data properly tracked

## Example Usage

**Input Command**:
```
batch-produce --episodes 1,2,3 --mode full --cost-limit 20
```

**Expected Execution**:
```
Starting batch production...
Loading episodes from: projects/nobody-knows/series_plan/episodes_master.json
Episodes loaded:
  1: "The Dirty Secret: Even the Experts Are Making It Up" (S1, complexity: 1)
  2: "The Emperor's New Neural Network" (S1, complexity: 1)
  3: "Confession Time: I Asked ChatGPT How ChatGPT Works" (S1, complexity: 2)
Cost limit: $20.00
Mode: Full production (including audio)

[1/3] Episode 1: "The Dirty Secret"...
[2/3] Episode 2: "The Emperor's New Neural Network"...
[3/3] Episode 3: "Confession Time"...

Batch complete!
- Success: 3/3 episodes
- Total cost: $15.75
- Time elapsed: 3 hours 45 minutes
- All outputs saved to: projects/nobody-knows/output/batch_20250811_1430/
```

## Cost Optimization

### Strategies
1. Process during off-peak hours
2. Batch similar topics together
3. Reuse research where applicable
4. Monitor API rate limits
5. Use efficient prompting

### Budget Tracking
```yaml
per_episode_target: $5.00
batch_buffer: 20%  # Allow 20% cost variance
alert_threshold: 80%  # Alert at 80% of limit
hard_stop: 100%  # Stop at cost limit
```
