# /podcast-workflow - MCP-Native Episode Production

Execute complete end-to-end podcast episode production using native Claude Code MCP integration for streamlined, reliable workflow orchestration.

## Usage

```bash
/podcast-workflow [episode_number] [topic]
```

## Example

```bash
/podcast-workflow 1 "The Dirty Secret: Even the Experts Are Making It Up"
```

## Purpose

Master orchestrator leveraging MCP-native workflows for complete episode creation with zero API key management and built-in reliability.

## MCP-Native Production Pipeline

Complete episode production using integrated MCP workflows:

### Phase 1: MCP Research Pipeline
```yaml
workflow: /research-workflow
mcp_integration: "mcp__perplexity-ask__perplexity_ask"

execution:
  - Zero training data research (2024-2025 sources only)
  - Multi-query systematic investigation
  - Automatic source verification and citation
  - Built-in fact-checking and triangulation
  - Intellectual humility integration
  
benefits:
  - No Perplexity API key management
  - Real-time access to current information
  - Automatic expert credential verification
  - Built-in uncertainty documentation
```

### Phase 2: Script Production Pipeline  
```yaml
workflow: /production-workflow
agent_coordination: "writer → polisher → judge"

execution:
  - MCP-researched content to TTS-optimized script
  - SSML markup for Amelia voice optimization
  - Multi-evaluator quality consensus
  - Brand alignment validation (≥90%)
  
benefits:
  - Research integration from MCP pipeline
  - Native Claude Code agent orchestration
  - Quality gates with empirical thresholds
```

### Phase 3: MCP Audio Production Pipeline
```yaml
workflow: /audio-workflow
mcp_integration: "mcp__elevenlabs__text_to_speech + mcp__elevenlabs__speech_to_text"

synthesis_execution:
  - Amelia voice (ZF6FPAbjXT4488VcRRnw) - PRODUCTION LOCKED
  - eleven_turbo_v2_5 model for optimal quality
  - Optimized voice settings (empirically validated)
  - Automatic SSML processing and chunking
  
validation_execution:
  - STT quality verification using scribe_v1_experimental
  - Empirical quality thresholds from Episode 1 baseline
  - Automatic transcript generation and comparison
  - Production approval decision (≥85% threshold)
  
benefits:
  - No ElevenLabs API key management
  - Built-in error handling and retries
  - Automatic file management and storage
  - Integrated quality validation pipeline
```

### 🎯 Complete Episode Delivery
```yaml
final_outputs:
  audio_file: "Professional MP3 (28-minute episode)"
  validation_report: "Quality metrics and approval status"
  research_package: "Source documentation with citations"
  production_metrics: "Cost tracking and performance data"
  
quality_assurance:
  - Research: Current information with source verification
  - Script: Multi-evaluator consensus (≥9.0/10)
  - Audio: Empirical quality thresholds (≥85%)
  - Cost: Target maintenance ($3-5 per episode)
```

## Migration Benefits

**Eliminated API Complexity:**
- No Perplexity API key management
- No ElevenLabs API key management  
- No custom error handling or retry logic
- No manual file management

**Enhanced Reliability:**
- Built-in MCP error recovery
- Automatic source verification
- Real-time information access
- Native Claude Code integration

**Simplified Architecture:**
- Reduced codebase by >1000 lines
- Single MCP authentication point
- Streamlined agent coordination
- Focus on content quality vs. implementation

## Session Architecture

```yaml
master_session:
  root: nobody-knows/production/ep_{number}_{timestamp}/

  phases:
    research/:
      - research_findings.json
      - validation_report.json
      - synthesis_package.json

    script/:
      - initial_script.md
      - polished_script.md
      - quality_report.json

    audio/:
      - episode_{number}.mp3
      - audio_metrics.json
      - validation_report.json

    state.json: # Episode-specific state tracking
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

**MCP Migration Complete**: This master workflow now orchestrates MCP-native pipelines, eliminating custom API management while maintaining all production quality standards and cost targets. Reduced complexity by >1000 lines while improving reliability through native Claude Code integration.
