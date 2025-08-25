# Episode Directory Structure Template

## Standard Episode Organization

Each episode follows this exact directory structure for consistency and automation:

```
episodes/
  epXXX_[topic_slug]/
    research/
      - questions.json                 # Generated research questions
      - research_raw.json             # Raw Perplexity research data
      - research_synthesis.md         # Compiled research package
      - sources.json                  # Source attribution and verification
      - fact_verification.json        # Fact-checking results

    planning/
      - episode_structure.md          # Episode planning and structure
      - segment_breakdown.json        # Detailed segment timing
      - engagement_hooks.md          # Planned engagement elements

    script/
      - draft_v1.md                  # Initial script draft
      - polished_final.md            # Final polished script
      - ssml_formatted.xml           # TTS-ready SSML markup
      - revision_history.json        # Script revision tracking

    quality/
      - claude_evaluation.json        # Claude quality assessment
      - gemini_evaluation.json       # Gemini quality assessment
      - perplexity_evaluation.json   # Perplexity fact verification
      - brand_voice_score.json       # Brand voice consistency score
      - consensus_report.json        # Three-evaluator consensus results
      - quality_gates_status.json    # Quality gate pass/fail status

    audio/
      - episode_final.mp3            # Final produced audio
      - tts_parameters.json          # Synthesis parameters used
      - audio_segments/              # Individual segment audio files
      - quality_metrics.json        # Audio quality measurements
      - transcript_validation.txt    # Speech-to-text validation transcript
      - pronunciation_check.json     # Pronunciation accuracy results
      - pacing_analysis.json         # Speaking rate and timing analysis

    metadata/
      - episode_info.json            # Episode metadata and details
      - cost_breakdown.json          # Detailed cost tracking
      - production_log.txt           # Complete production log
      - quality_certification.json   # Final quality certification
      - distribution_metadata.json   # Distribution-ready metadata

    assets/
      - thumbnail.png                # Episode thumbnail image
      - waveform.png                # Audio waveform visualization
      - show_notes.md               # Episode show notes
      - transcript.md               # Full episode transcript
```

## File Format Specifications

### Research Files

**questions.json:**
```json
{
  "episode_id": "ep001_quantum_consciousness",
  "topic": "The Mystery of Quantum Consciousness",
  "generated_questions": [
    {
      "id": 1,
      "question": "What is the current scientific understanding of consciousness?",
      "category": "foundational",
      "priority": "high"
    }
  ],
  "metadata": {
    "generated_at": "2025-08-24T12:00:00Z",
    "agent": "question-generator-enhanced"
  }
}
```

**research_synthesis.md:**
```markdown
# Research Synthesis: [Episode Topic]

## Key Findings Summary
- Main discovery points
- Current scientific consensus
- Areas of uncertainty
- Notable researcher perspectives

## Technical Concepts
- Definitions and explanations
- Pronunciation guides for technical terms
- Context for general audience

## Sources and Attribution
- Primary sources with credibility scores
- Researcher credentials and affiliations
- Publication dates and relevance
```

### Script Files

**ssml_formatted.xml:**
```xml
<speak>
  <p>
    <emphasis level="moderate">Welcome to Nobody Knows</emphasis>,
    where we explore the fascinating frontiers of human knowledge.
  </p>
  <break time="1s"/>
  <p>
    Today, we're diving into <emphasis level="strong">quantum consciousness</emphasis>
    <phoneme alphabet="ipa" ph="ˈkwɒntəm ˈkɒnʃəsnəs">quantum consciousness</phoneme>.
  </p>
</speak>
```

### Quality Assessment Files

**consensus_report.json:**
```json
{
  "episode_id": "ep001_quantum_consciousness",
  "evaluation_timestamp": "2025-08-24T14:30:00Z",
  "evaluators": {
    "claude_enhanced": {
      "brand_voice_score": 0.87,
      "engagement_score": 0.92,
      "confidence": 0.85,
      "recommendations": ["Increase wonder expressions", "Add more curiosity markers"]
    },
    "gemini_enhanced": {
      "technical_accuracy": 0.95,
      "production_quality": 0.89,
      "confidence": 0.91,
      "recommendations": ["Verify quantum mechanics terminology"]
    },
    "perplexity_enhanced": {
      "fact_accuracy": 0.96,
      "source_reliability": 0.94,
      "confidence": 0.93,
      "recommendations": ["Update researcher citation format"]
    }
  },
  "consensus_score": 0.89,
  "overall_recommendation": "APPROVE",
  "quality_gates_passed": 8,
  "quality_gates_total": 8
}
```

### Audio Quality Files

**quality_metrics.json:**
```json
{
  "episode_id": "ep001_quantum_consciousness",
  "audio_file": "episode_final.mp3",
  "validation_timestamp": "2025-08-24T16:00:00Z",
  "metrics": {
    "word_accuracy": 0.967,
    "pronunciation_accuracy": 1.0,
    "technical_terms_accuracy": 1.0,
    "pacing_score": 0.89,
    "clarity_score": 0.92,
    "consistency_score": 0.86,
    "composite_quality": 0.905
  },
  "duration": "47:23",
  "speech_rate": "156 WPM",
  "validation_status": "PASSED",
  "retry_count": 0,
  "issues_found": [],
  "validation_cost": "$0.87"
}
```

## Directory Creation Script

**Bash script for automated directory creation:**

```bash
#!/bin/bash
create_episode_structure() {
    local episode_id="$1"
    local topic_slug="$2"
    local base_dir="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/episodes"
    local episode_dir="${base_dir}/${episode_id}_${topic_slug}"

    # Create main episode directory
    mkdir -p "$episode_dir"

    # Create subdirectories
    mkdir -p "$episode_dir/research"
    mkdir -p "$episode_dir/planning"
    mkdir -p "$episode_dir/script"
    mkdir -p "$episode_dir/quality"
    mkdir -p "$episode_dir/audio/audio_segments"
    mkdir -p "$episode_dir/metadata"
    mkdir -p "$episode_dir/assets"

    # Create initial status file
    cat > "$episode_dir/metadata/episode_info.json" << EOF
{
  "episode_id": "${episode_id}_${topic_slug}",
  "status": "initialized",
  "created_at": "$(date -Iseconds)",
  "production_phase": "research",
  "budget_remaining": 15.00,
  "quality_gates_passed": 0,
  "estimated_completion": null
}
EOF

    echo "✅ Created episode structure: $episode_dir"
}

# Usage: create_episode_structure "ep001" "quantum_consciousness"
```

## Production Workflow Integration

The directory structure integrates with the production pipeline:

1. **Research Phase** → Populates `research/` directory
2. **Planning Phase** → Populates `planning/` directory
3. **Script Phase** → Populates `script/` directory
4. **Quality Phase** → Populates `quality/` directory
5. **Audio Phase** → Populates `audio/` directory
6. **Packaging Phase** → Finalizes `metadata/` and `assets/`

Each agent writes to its designated directories, enabling:
- **Progress Tracking**: Monitor completion by checking file existence
- **Error Recovery**: Resume from any phase using existing files
- **Quality Auditing**: Complete trail of all production decisions
- **Cost Tracking**: Detailed cost attribution by phase
- **Archival**: Permanent record for future reference

This structure ensures consistent, automated, and auditable podcast production.
