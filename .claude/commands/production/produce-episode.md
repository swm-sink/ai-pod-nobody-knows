---
name: produce-episode
description: Execute complete episode production from approved research to final audio
---

# Produce Episode - Production Stream Execution

Execute the complete production pipeline for a podcast episode using approved research.

## Usage

```
/produce-episode [research_session_path]
```

## Examples

```
/produce-episode sessions/ep_001_20250817/research/
/produce-episode  # Uses most recent research session
```

## Prerequisites

- Research stream must be completed via `/produce-research`
- Research package must be reviewed and approved
- Session directory with research data must exist

## Execution

Use the 01_production_orchestrator subagent to produce episode from research at: $ARGUMENTS

The production orchestrator will:
1. Validate research package exists and is complete
2. Execute 5-agent production pipeline:
   - Episode planning from research
   - Script writing (35k characters)
   - Parallel quality evaluation (Claude + Gemini)
   - Script polishing based on feedback
   - Audio production with ElevenLabs TTS
3. Apply quality gates at each stage
4. Track costs and enable recovery from failures

## Quality Gates

- **Planning**: Structure meets 47-minute target
- **Writing**: 33k-37k characters, brand voice ≥0.90
- **Quality**: Both evaluators pass with consensus
- **Polish**: All quality issues addressed
- **Audio**: Duration 26-28 minutes, quality validated

## Output

- Final episode audio: `sessions/ep_{number}_{date}/production/episode_audio.mp3`
- Production tracking: `sessions/ep_{number}_{date}/production/production_status.json`
- Quality reports for each stage
- Complete cost tracking

## Recovery

If production fails at any stage:
- Progress is automatically saved
- Can restart from last successful stage
- Detailed failure logs provided
- Cost tracking preserved

Transform approved research into broadcast-ready podcast episode.
