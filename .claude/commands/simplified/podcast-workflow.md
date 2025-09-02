# /podcast-workflow - Master Episode Production Orchestrator

Execute complete end-to-end podcast episode production by orchestrating all workflow phases.

## Usage

```bash
/podcast-workflow [episode_number] [topic]
```

## Example

```bash
/podcast-workflow 1 "The Dirty Secret: Even the Experts Are Making It Up"
```

## Purpose

Master orchestrator that chains research, production, and audio workflows for complete episode creation with user review points.

## Complete Production Pipeline

I will orchestrate the complete episode production through our specialized workflows:

### Phase 1: Research Pipeline
```
Executing /research-workflow for comprehensive investigation...

/research-workflow $ARGUMENTS

Expected outputs:
- Comprehensive research findings
- Validated facts and sources
- Production-ready knowledge package
- Research quality score ≥9.0/10
```

### Phase 2: Script Production
```
Executing /production-workflow for script creation...

/production-workflow [episode_number]

Expected outputs:
- Polished script with SSML
- Brand-aligned content (≥90%)
- Quality consensus report
- Production approval status
```

### 🛑 User Review Checkpoint

```
========================================
SCRIPT READY FOR REVIEW
========================================

Episode: [number] - [topic]

Quality Scores:
- Brand Consistency: [X.XX]
- Engagement: [X.XX]
- Technical Accuracy: [X.XX]
- Consensus Score: [X.XX]

Word Count: [XXXX] (Target: 5,768)
Duration Estimate: [XX] minutes

Script Location: sessions/ep_[number]/production/polished_script.md

Please review the script before audio production.
Options:
1. Proceed with audio synthesis
2. Request revisions (specify changes)
3. Abort production

Response:
```

### Phase 3: Audio Production (After Approval)
```
Executing /audio-workflow for final synthesis...

/audio-workflow [episode_number]

Expected outputs:
- Professional MP3 audio
- Quality validation metrics
- STT verification report
- Final episode package
```

## Session Architecture

```yaml
master_session:
  root: sessions/ep_{number}_{timestamp}/

  phases:
    research/:
      - research_findings.json
      - validation_report.json
      - synthesis_package.json

    production/:
      - initial_script.md
      - polished_script.md
      - quality_report.json

    audio/:
      - episode_{number}.mp3
      - audio_metrics.json
      - validation_report.json

    final/:
      - episode_complete.json
      - cost_summary.json
      - quality_summary.json
```

## Cost Management

```yaml
episode_budget:
  total_limit: $4.00
  target: $2.80

  phase_allocation:
    research: $1.35
    production: $0.15
    audio: $2.80
    buffer: $0.70

  monitoring:
    real_time: true
    alerts: [50%, 75%, 90%]
    hard_stop: $4.00
```

## Quality Checkpoints

```yaml
phase_gates:
  post_research:
    - Research depth ≥9.0/10
    - Sources verified ≥90%
    - Expert quotes ≥10

  post_production:
    - Brand consistency ≥90%
    - All quality gates passed
    - Word count within range

  post_audio:
    - Word accuracy ≥90%
    - Duration 28±1 minutes
    - No audio artifacts
```

## Progress Tracking

```yaml
status_updates:
  frequency: "After each phase"

  format: |
    =====================================
    Episode [number] Production Status
    =====================================
    ✅ Research: Complete ([time])
    ✅ Script: Complete ([time])
    ⏳ Audio: In Progress...

    Quality: [X.X]/10
    Cost: $[X.XX]/$4.00
    Time: [XX] minutes
    =====================================
```

## Error Recovery

```yaml
failure_modes:
  research_failure:
    retry: "Alternative sources"
    fallback: "Manual research input"

  quality_failure:
    minor: "Targeted revisions"
    major: "Phase restart"
    critical: "Complete restart"

  cost_overrun:
    action: "Immediate halt"
    state: "Preserved for resume"
    notification: "User alert required"

  audio_failure:
    retry: "Re-synthesis with adjusted parameters"
    fallback: "Alternative voice settings"
```

## Final Deliverables

```yaml
episode_package:
  audio:
    file: episode_{number}.mp3
    format: "MP3, 128kbps"
    duration: "28 minutes"

  documentation:
    script: "Full script with timestamps"
    research: "Source documentation"
    metrics: "Quality and cost reports"

  metadata:
    title: "Episode title"
    description: "Episode summary"
    keywords: "SEO tags"
    transcript: "STT-verified text"
```

## Success Metrics

```json
{
  "episode_number": 1,
  "production_time": "2.5 hours",
  "total_cost": 2.92,
  "quality_scores": {
    "research": 9.2,
    "script": 8.8,
    "audio": 9.2,
    "overall": 9.1
  },
  "status": "complete",
  "ready_for_publication": true
}
```

## Native Claude Code Pattern

This master command demonstrates:
- Top-level workflow orchestration
- Sequential phase execution
- User review integration
- Complete episode production

## Batch Processing Extension

For multiple episodes, this workflow can be wrapped in batch processing:

```bash
/batch-10 podcast-workflow [starting_episode]
```

This enables production of 10-125 episodes with:
- Parallel research phases
- Sequential quality reviews
- Batch cost optimization
- Progress dashboards

---

**Technical**: Master orchestration pattern implementing sequential workflow chaining with user review checkpoints and comprehensive state management.

**Simple**: Like a TV show producer who coordinates writers, editors, and sound engineers to create each episode from start to finish.

**Connection**: This teaches complex workflow orchestration, state management, and production pipeline design.
