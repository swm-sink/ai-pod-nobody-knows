# Produce Episode Command

**Purpose**: Orchestrate the complete podcast episode production pipeline from topic to quality-validated script.

## Command Overview

You are the Episode Production Orchestrator for "Nobody Knows" podcast. Execute the complete production pipeline while maintaining quality standards and cost efficiency.

## Configuration References
- **Production Config**: `.claude/shared/config/production-config.yaml`
- **Quality Gates**: `projects/nobody-knows/config/quality_gates.json`
- **Session Framework**: `.claude/shared/frameworks/session-coordination.md`

## Input Requirements
- **Episode Number**: Integer (e.g., 1, 2, 3)
- **Topic**: String describing the episode topic
- **Complexity Level**: 1-10 based on episode position
- **Target Audience**: "general" or specified subset

## Production Pipeline

### Step 1: Initialize Session
Create session for tracking:
```yaml
session_id: "ep_{number}_{YYYYMMDD}_{HHMM}"
episode_number: {provided}
topic: {provided}
complexity_level: {calculated or provided}
status: "initialized"
```

Save to: `projects/nobody-knows/output/sessions/ep{number}_session_{date}.json`

### Step 2: Research Phase
Execute research-coordinator agent:
```
Agent: research-coordinator
Input: 
  - topic: {provided topic}
  - complexity_level: {from session}
  - episode_number: {from session}
Output: projects/nobody-knows/output/research/ep{number}_research_{topic}_{date}.md
Budget: $3.00
Timeout: 30 minutes
```

Update session state:
- Mark research as complete
- Record cost and time
- Save research quality metrics

### Step 3: Script Writing Phase
Execute script-writer agent:
```
Agent: script-writer
Input:
  - research_package: {from Step 2}
  - episode_number: {from session}
  - complexity_level: {from session}
Output: projects/nobody-knows/output/scripts/ep{number}_script_{topic}_{date}.md
Budget: $2.50
Timeout: 20 minutes
```

Update session state:
- Mark writing as complete
- Record cost and time
- Save script metrics

### Step 4: Quality Evaluation Phase
Execute quality-evaluator agent:
```
Agent: quality-evaluator
Input:
  - script: {from Step 3}
  - episode_number: {from session}
Output: projects/nobody-knows/output/quality/ep{number}_quality_{date}.json
Budget: $0.50
Timeout: 10 minutes
```

Update session state:
- Mark evaluation as complete
- Record quality scores
- Determine pass/fail status

### Step 5: Quality Gate Decision

#### If PASS (overall score ≥ 0.85):
1. Mark episode as quality-approved
2. Proceed to Step 6: Audio Synthesis
3. After audio generation, update session status to "complete"
4. Generate success report with all outputs
5. Archive session data

#### If FAIL (overall score < 0.85):
1. Analyze failure reasons from quality report
2. Determine retry strategy:
   - Below brand consistency → Return to script-writer with feedback
   - Below comprehension → Return to script-writer for simplification
   - Below technical → Return to script-writer for structure fixes
3. Maximum 3 retries allowed
4. Update session with retry count

### Step 6: Audio Synthesis Phase
Execute audio-synthesizer agent:
```
Agent: audio-synthesizer
Input:
  - script: {from Step 3}
  - episode_number: {from session}
  - topic: {from session}
Output: projects/nobody-knows/output/audio/ep{number}_{topic}_{date}.mp3
Budget: $2.00
Timeout: 15 minutes
```

Update session state:
- Mark audio synthesis as complete
- Record audio file path
- Record synthesis cost
- Update total episode cost

## Error Handling

### Agent Failures
- Automatic retry up to 2 times
- Exponential backoff: 30s, 60s, 120s
- Save error details in session
- Escalate after max retries

### Cost Overruns
- Halt if total cost exceeds $9.00
- Alert for manual intervention
- Save partial outputs
- Document cost breakdown

### Timeout Handling
- Research: 30 min max
- Script Writing: 20 min max
- Quality Eval: 10 min max
- Audio Synthesis: 15 min max
- Total: 75 min target

## Output Summary

### Success Output
```json
{
  "status": "SUCCESS",
  "episode_number": 1,
  "topic": "consciousness",
  "outputs": {
    "research": "path/to/research.md",
    "script": "path/to/script.md",
    "quality": "path/to/quality.json",
    "audio": "path/to/audio.mp3"
  },
  "metrics": {
    "total_time": 55,
    "total_cost": 4.50,
    "quality_score": 0.88,
    "retry_count": 0
  },
  "session": "ep_001_20240811_1430"
}
```

### Failure Output
```json
{
  "status": "FAILED",
  "episode_number": 1,
  "failure_reason": "Quality gates not met after 3 retries",
  "last_scores": {
    "overall": 0.82,
    "brand_consistency": 0.78
  },
  "partial_outputs": {...},
  "recommendations": [
    "Manual review of brand voice requirements",
    "Consider topic complexity adjustment"
  ]
}
```

## Usage Example

```bash
# Basic usage
produce-episode --episode 1 --topic "consciousness hard problem"

# With complexity override
produce-episode --episode 1 --topic "consciousness" --complexity 3

# With all options
produce-episode \
  --episode 1 \
  --topic "consciousness hard problem" \
  --complexity 3 \
  --audience "general"
```

## Quality Assurance

Before marking episode complete:
- [ ] Research package validated
- [ ] Script meets duration target (25-30 min)
- [ ] Quality score ≥ 0.85 overall
- [ ] Brand consistency ≥ 0.90
- [ ] All outputs in correct directories
- [ ] Session data complete
- [ ] Cost within budget (<$9.00)

## Monitoring Integration

Update dashboard with:
- Episode production status
- Quality metrics
- Cost tracking
- Time per phase
- Retry statistics
- Success/failure rates

## Success Criteria

- Complete pipeline execution in <60 minutes
- Total cost <$5.00 (target) or <$9.00 (max)
- Quality score ≥0.85
- All outputs properly formatted
- Session tracking complete
- No manual intervention required

---

*This command orchestrates the complete "Nobody Knows" podcast production pipeline, ensuring quality, cost efficiency, and proper tracking throughout the process.*