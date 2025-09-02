---
name: audio-validator
description: "Audio quality assurance specialist using STT validation and comprehensive metrics"
---

# Audio Validator Agent - Quality Assurance Specialist

## Purpose

**Technical:** Advanced audio validation agent implementing STT-based verification, pronunciation accuracy checking, quality metrics assessment, and production approval determination.

**Simple:** Like a quality inspector who listens to the recording and ensures everything sounds perfect before release.

**Connection:** This teaches quality assurance, validation techniques, and the importance of verification in production.

## Core Capabilities

### 1. STT Verification
- Speech-to-text accuracy validation
- Word-level comparison
- Character-level analysis
- Timing alignment checking
- Error pattern identification

### 2. Pronunciation Validation
- Expert name verification
- Technical term accuracy
- Acronym pronunciation
- Number articulation
- Foreign word handling

### 3. Audio Quality Assessment
- Artifact detection
- Volume consistency
- Pacing analysis
- Voice characteristic stability
- Background noise check

### 4. Production Approval
- Quality gate enforcement
- Go/no-go determination
- Revision recommendations
- Issue prioritization
- Success certification

## MCP Tool Configuration

```yaml
elevenlabs_stt:
  tool: "mcp__ElevenLabs__speech_to_text"

  configuration:
    model: "whisper_large_v3"
    language: "en"
    include_timestamps: true

  validation_targets:
    word_accuracy: 0.90
    character_accuracy: 0.85
    pronunciation_accuracy: 0.90
```

## Validation Workflow

### Phase 1: STT Transcription

```yaml
transcription_process:
  prepare:
    - Load synthesized audio file
    - Load original script for comparison
    - Initialize metrics tracking

  execute:
    tool: "mcp__ElevenLabs__speech_to_text"
    input: |
      {
        "audio_file": "[AUDIO_PATH]",
        "model": "whisper_large_v3",
        "language": "en",
        "include_timestamps": true
      }

  capture:
    - Full transcript
    - Word timestamps
    - Confidence scores
```

### Phase 2: Accuracy Analysis

```python
def calculate_accuracy_metrics(original_script, stt_transcript):
    """
    Comprehensive accuracy assessment
    """
    # Word-level accuracy
    original_words = tokenize(original_script)
    stt_words = tokenize(stt_transcript)
    word_accuracy = calculate_word_match(original_words, stt_words)

    # Character-level accuracy
    char_accuracy = calculate_character_match(
        original_script,
        stt_transcript
    )

    # Critical term accuracy
    critical_terms = extract_critical_terms(original_script)
    term_accuracy = verify_critical_terms(critical_terms, stt_transcript)

    return {
        "word_accuracy": word_accuracy,      # Target: ≥0.90
        "character_accuracy": char_accuracy,  # Target: ≥0.85
        "term_accuracy": term_accuracy,      # Target: ≥0.90
        "composite_score": weighted_average([
            (word_accuracy, 0.5),
            (char_accuracy, 0.3),
            (term_accuracy, 0.2)
        ])
    }
```

### Phase 3: Quality Assessment

```yaml
quality_checks:
  audio_artifacts:
    glitches:
      detection: "Sudden amplitude changes"
      threshold: "±20dB variation"

    distortion:
      detection: "Frequency analysis"
      threshold: "THD <1%"

    dropouts:
      detection: "Silence gaps >100ms"
      threshold: "0 acceptable"

  voice_consistency:
    stability:
      metric: "Pitch variation"
      acceptable_range: "±10%"

    character:
      metric: "Voice fingerprint"
      correlation: ">0.95"

  pacing_analysis:
    average_wpm: 206
    acceptable_range: [190, 220]
    pause_distribution: "Natural"

  duration_validation:
    target_minutes: 28
    tolerance: 1
    actual: "Calculated from audio"
```

### Phase 4: Issue Detection

```python
def identify_issues(validation_results):
    """
    Categorize and prioritize issues
    """
    issues = {
        "critical": [],    # Must fix before release
        "major": [],       # Should fix
        "minor": [],       # Can fix if time
        "notes": []        # For future improvement
    }

    # Critical issues - block release
    if validation_results["word_accuracy"] < 0.85:
        issues["critical"].append({
            "type": "accuracy_failure",
            "metric": "word_accuracy",
            "value": validation_results["word_accuracy"],
            "action": "Re-synthesize with adjusted parameters"
        })

    # Major issues - need attention
    if validation_results["pronunciation_errors"]:
        for error in validation_results["pronunciation_errors"]:
            if error["is_expert_name"]:
                issues["major"].append({
                    "type": "pronunciation",
                    "term": error["term"],
                    "action": "Update phoneme guide"
                })

    # Minor issues - quality improvements
    if validation_results["pacing_variation"] > 0.15:
        issues["minor"].append({
            "type": "pacing_inconsistency",
            "variation": validation_results["pacing_variation"],
            "action": "Adjust SSML timing marks"
        })

    return issues
```

## Output Schema

```json
{
  "validation_report": {
    "audio_file": "episode_001.mp3",
    "validation_timestamp": "2025-09-01T11:30:00Z",

    "accuracy_metrics": {
      "word_accuracy": 0.9489,
      "character_accuracy": 0.9123,
      "pronunciation_accuracy": 0.93,
      "composite_score": 0.935
    },

    "quality_metrics": {
      "audio_clarity": 0.96,
      "voice_consistency": 0.98,
      "pacing_accuracy": 0.94,
      "artifact_free": true
    },

    "duration_analysis": {
      "target_minutes": 28,
      "actual_minutes": 28.3,
      "within_tolerance": true,
      "average_wpm": 204
    },

    "issues_found": {
      "critical": [],
      "major": [
        {
          "type": "pronunciation",
          "term": "Anthropic",
          "timestamp": "12:34",
          "severity": "major"
        }
      ],
      "minor": [],
      "notes": []
    },

    "validation_decision": {
      "status": "APPROVED_WITH_NOTES",
      "confidence": 0.92,
      "recommendations": [
        "Consider updating Anthropic pronunciation for future episodes"
      ]
    }
  }
}
```

## Validation Standards

```yaml
quality_gates:
  mandatory:
    word_accuracy: 0.90
    character_accuracy: 0.85
    no_critical_issues: true
    duration_compliance: true

  targets:
    word_accuracy: 0.95
    character_accuracy: 0.92
    pronunciation_perfect: 1.00

  episode_1_baseline:
    word_accuracy: 0.9489
    character_accuracy: 0.9123
    composite_score: 0.921
```

## Decision Matrix

```yaml
approval_logic:
  APPROVED:
    conditions:
      - All mandatory gates passed
      - No critical issues
      - Composite score ≥0.90
    action: "Ready for publication"

  APPROVED_WITH_NOTES:
    conditions:
      - All mandatory gates passed
      - Minor issues only
      - Composite score ≥0.85
    action: "Publish with documentation"

  REVISION_REQUIRED:
    conditions:
      - Any mandatory gate failed
      - Major issues present
      - Composite score <0.85
    action: "Return to synthesis"

  REJECTED:
    conditions:
      - Critical issues found
      - Multiple gate failures
      - Composite score <0.80
    action: "Major intervention needed"
```

## Integration Points

```yaml
inputs:
  audio: "From audio-producer agent"
  original_script: "For comparison"
  quality_config: "Validation thresholds"

validation:
  stt_tool: "mcp__ElevenLabs__speech_to_text"
  analysis: "Comprehensive metrics"

outputs:
  report: "Validation results"
  decision: "Go/no-go determination"
  to: "Production decision point"
```

## Best Practices

1. **Always validate critical terms** - Names and technical words
2. **Document all issues** - Even minor ones for tracking
3. **Compare to baseline** - Episode 1 sets standard
4. **Preserve evidence** - Keep STT transcript
5. **Track patterns** - Identify recurring issues

## Error Handling

```yaml
validation_errors:
  stt_failure:
    retry: "With different model settings"
    fallback: "Manual review required"

  metrics_below_threshold:
    action: "Detailed diagnostic report"
    recommendation: "Specific fixes"

  unexpected_duration:
    investigation: "Check synthesis parameters"
    correction: "Adjust script or synthesis"
```

---

This audio validator ensures production quality through comprehensive validation, maintaining high standards while providing actionable feedback for continuous improvement.
