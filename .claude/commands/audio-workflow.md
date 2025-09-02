# /audio-workflow - Native Audio Production Orchestration

Execute professional audio synthesis and validation pipeline for the "Nobody Knows" podcast.

## Usage

```bash
/audio-workflow [episode_number]
```

## Example

```bash
/audio-workflow 1
```

## Prerequisites

- Polished script must exist in `sessions/ep_{number}/production/`
- Quality validation passed (≥80% all gates)
- ElevenLabs MCP server connected
- Production voice configured (Amelia: ZF6FPAbjXT4488VcRRnw)

## Purpose

Orchestrate audio production from validated script through final MP3 delivery with quality assurance.

## Audio Orchestration Flow

I will coordinate the audio pipeline using our specialized agents:

### Step 1: Audio Synthesis
```
Use the audio-producer agent to generate audio:
[Load polished script with SSML]

Requirements:
- Voice: Amelia (ZF6FPAbjXT4488VcRRnw) - LOCKED
- Model: eleven_turbo_v2_5
- Settings:
  * Stability: 0.65
  * Similarity: 0.80
  * Style: 0.30
  * Speaker boost: enabled
- Single-call synthesis (up to 40K chars)
- Intelligent chunking for longer content
- SSML processing for natural speech
- Output: High-quality MP3 audio
```

### Step 2: Audio Validation
```
Use the audio-validator agent to verify quality:
[Pass synthesized audio]

Requirements:
- STT verification using ElevenLabs
- Quality metrics:
  * Word accuracy ≥90% (target: 95%)
  * Character accuracy ≥85% (target: 92%)
  * Pronunciation accuracy ≥90%
- Duration validation (28±1 minutes)
- Audio quality assessment:
  * No artifacts or glitches
  * Consistent voice characteristics
  * Natural pacing (206 WPM)
- Output: Validation report with metrics
```

## Session Management

```yaml
session_structure:
  directory: sessions/ep_{number}_{timestamp}/audio/
  inputs:
    - production/polished_script.md
    - production/script_with_ssml.txt
  outputs:
    - episode_{number}.mp3
    - audio_metrics.json
    - stt_transcript.txt
    - validation_report.json
```

## Production Configuration

```yaml
voice_configuration:
  voice_id: "ZF6FPAbjXT4488VcRRnw"  # IMMUTABLE
  voice_name: "Amelia"
  model_id: "eleven_turbo_v2_5"

  settings:
    stability: 0.65
    similarity_boost: 0.80
    style: 0.30
    use_speaker_boost: true

  governance:
    immutable_without_permission: true
    source: ".claude/config/production-voice.json"
```

## Quality Standards

```yaml
audio_quality_gates:
  word_accuracy:
    minimum: 0.90
    target: 0.95
    episode_1_achieved: 0.9489

  character_accuracy:
    minimum: 0.85
    target: 0.92
    episode_1_achieved: 0.9123

  pronunciation_accuracy:
    minimum: 0.90
    target: 0.95
    critical_terms: [expert_names, technical_terms]

  duration:
    target_minutes: 28
    tolerance: 1
    wpm_rate: 206
```

## Cost Tracking

- **Budget Allocation**: $2.80 audio phase
- **Synthesis Cost**: ~$2.77 (based on character count)
- **Validation Cost**: ~$0.03 (STT processing)
- **Episode 1 Empirical**: $2.77 total
- **Cost Monitoring**: Real-time via hooks

## Error Handling

```yaml
synthesis_errors:
  api_failure:
    action: "Exponential backoff retry"
    max_attempts: 3

  quality_failure:
    word_accuracy_low: "Adjust pronunciation guides"
    pacing_issues: "Modify SSML timing"
    artifacts: "Re-synthesize affected chunks"

cost_overrun:
  threshold: $4.00
  action: "Immediate halt"
  alert: "User notification required"
```

## Single-Call Optimization

```yaml
synthesis_strategy:
  default: "Single API call for entire script"
  threshold: 40000  # Characters

  benefits:
    - No audio concatenation needed
    - Consistent voice characteristics
    - Natural flow maintained
    - 95% of episodes fit limit

  chunking_fallback:
    when: "Script >40K characters"
    strategy: "Intelligent paragraph breaks"
    overlap: "50 characters for seamless joining"
```

## Output Schema

```json
{
  "episode_number": 1,
  "audio_file": "episode_001.mp3",
  "duration_minutes": 28.3,
  "quality_metrics": {
    "word_accuracy": 0.9489,
    "character_accuracy": 0.9123,
    "pronunciation_accuracy": 0.93,
    "composite_score": 0.921
  },
  "synthesis_method": "single_call",
  "character_count": 15398,
  "cost": 2.77,
  "session_id": "ep_001_20250901_1100"
}
```

## Native Claude Code Pattern

This command demonstrates:
- Command orchestrates audio workflow
- Agents handle synthesis and validation
- Direct MCP tool usage via agents
- Configuration governance maintained

---

**Technical**: Audio production orchestration with ElevenLabs MCP integration for synthesis and STT-based quality validation.

**Simple**: Like a recording studio where the narrator records and the engineer validates quality before release.

**Connection**: This teaches audio production workflows and quality assurance in AI-generated content.
