# /audio-workflow - MCP-Native Audio Production

Execute professional audio synthesis and validation using native Claude Code MCP integration for streamlined, reliable podcast production.

## Usage

```bash
/audio-workflow [episode_number]
```

## Example

```bash
/audio-workflow 1
```

## Prerequisites

- Polished script ready for synthesis 
- Quality validation passed (≥80% all gates)
- ElevenLabs MCP server connected ✅ 
- User-level MCP authentication configured
- Production voice locked (Amelia: ZF6FPAbjXT4488VcRRnw)

## Purpose

Orchestrate MCP-native audio production from script to validated MP3 using built-in Claude Code reliability.

## MCP Audio Production Pipeline

Streamlined orchestration using native MCP tools without custom API management:

### Step 1: MCP Audio Synthesis
```yaml
agent: audio-producer
mcp_tool: "mcp__elevenlabs__text_to_speech"

execution:
  input: "TTS-optimized SSML script"
  voice_id: "ZF6FPAbjXT4488VcRRnw"  # Amelia - PRODUCTION LOCKED
  model_id: "eleven_turbo_v2_5"
  settings:
    stability: 0.65
    similarity_boost: 0.80
    style: 0.30
    use_speaker_boost: true
    output_format: "mp3_44100_128"
    
benefits:
  - No API key management needed
  - Built-in error handling and retries
  - Automatic file management
  - Native Claude Code integration
```

### Step 2: MCP Quality Validation
```yaml
agent: audio-validator
mcp_tool: "mcp__elevenlabs__speech_to_text"

validation:
  input: "Synthesized MP3 audio file"
  model_id: "scribe_v1_experimental"
  thresholds:
    word_accuracy: 94.89     # Episode 1 empirical baseline
    character_accuracy: 91.23 # Episode 1 empirical baseline
    composite_quality: 92.1   # Episode 1 empirical baseline
    
benefits:
  - Automatic transcript generation
  - Built-in accuracy calculations
  - No custom STT client needed
  - Integrated quality assessment
```

## Session Management

```yaml
session_structure:
  directory: nobody-knows/production/ep_{number}_{timestamp}/audio/
  inputs:
    - script/polished_script.md
    - script/script_with_ssml.txt
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
