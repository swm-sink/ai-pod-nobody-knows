# /produce-episode-enhanced - Complete AI Podcast Production Pipeline

**Technical:** Comprehensive end-to-end podcast production orchestration implementing research-first workflow, three-evaluator consensus validation, professional audio synthesis, and automated quality assurance with cost tracking and error recovery for scalable production excellence.

**Simple:** Like having a complete automated production studio that takes just a topic idea and creates a professional broadcast-quality podcast episode with perfect research, engaging scripts, and studio-quality audio - all while ensuring top quality and managing costs.

**Connection:** This teaches production workflow orchestration, automated quality assurance, resource management, and systematic production processes essential for scalable content creation and professional media production.

---

## Command Usage

```
/produce-episode-enhanced "Episode Topic" [optional-parameters]
```

**Examples:**
- `/produce-episode-enhanced "The Mystery of Quantum Consciousness"`
- `/produce-episode-enhanced "What Nobody Knows About Black Holes"`
- `/produce-episode-enhanced "The Science of Memory - What We're Still Discovering"`

**Optional Parameters:**
- `--research-depth=standard|comprehensive` (default: standard)
- `--episode-length=45|47|50` (default: 47 minutes)
- `--quality-threshold=0.85|0.90|0.95` (default: 0.85)
- `--budget-limit=10|15|20` (default: $15.00)

---

## Production Pipeline Orchestration

This command orchestrates the complete production workflow by calling each sub-agent in sequence. Sub-agents cannot call other sub-agents, so this command manages the entire flow.

### Phase 1: Research Excellence (Budget: $2.50)

Execute comprehensive research stream using enhanced parallel query system:

```yaml
research_workflow:
  step_1: Use question-generator-enhanced to create 5 strategic research questions
  step_2: Use deep-research-agent-enhanced for parallel Perplexity queries and fact-checking
  step_3: Use research-synthesizer-enhanced for cross-domain integration and narrative coherence

  quality_requirements:
    source_verification: minimum 2 sources per factual claim
    fact_triangulation: multi-source cross-validation
    research_cache_utilization: 24-hour TTL for cost efficiency

  success_criteria:
    research_depth_score: ≥85% comprehensive coverage
    source_reliability: ≥90% authoritative sources
    knowledge_synthesis: ready for script development
```

### Phase 2: Script Excellence (Budget: $1.75)

Transform research into engaging educational script with brand voice consistency:

```yaml
script_development_workflow:
  primary_agent: script-writer (research-backed, Claude 4.1 Opus optimized)

  script_requirements:
    quote_balance_system: 3-4 maximum quotes with impact scoring
    engagement_hooks: optimized first 15 seconds for attention capture
    segment_structure: 3-4 minute cognitive load chunks
    unverified_marking: transparent uncertainty acknowledgment
    rhetorical_questions: every 2-3 minutes for engagement

  brand_voice_integration:
    intellectual_humility: authentic uncertainty acknowledgment
    learning_celebration: curiosity and wonder expression
    collaborative_exploration: audience as fellow discoverers
    expert_fallibility: scientists as learners, not infallible authorities
```

### Phase 3: Three-Evaluator Quality Consensus (Budget: $1.50)

Comprehensive quality validation through enhanced consensus system:

```yaml
three_evaluator_consensus_workflow:
  evaluator_configuration:
    quality_claude_enhanced: 35% weight (brand voice specialist)
    quality_gemini_enhanced: 30% weight (technical production specialist)
    quality_perplexity_enhanced: 35% weight (research accuracy specialist)

  consensus_mechanisms:
    confidence_scoring_integration: weighted confidence synthesis
    disagreement_threshold_detection: >0.15 difference triggers enhanced resolution
    tiebreaker_hierarchy_rules: domain expertise → confidence → historical accuracy

  quality_gate_enforcement:
    brand_voice_consistency: ≥85% alignment with intellectual humility philosophy
    technical_accuracy: verified facts with source attribution
    research_integrity: proper uncertainty marking and expert positioning
```

### Phase 4: Script Optimization & TTS Preparation (Budget: $0.75)

Professional script polishing and TTS optimization:

```yaml
tts_optimization_workflow:
  primary_agent: script-polisher-enhanced (three-evaluator feedback synthesis)
  technical_agent: tts-optimizer-enhanced (professional audio preparation)

  optimization_features:
    advanced_ssml_markup: natural speech patterns, prosody control
    technical_pronunciation: comprehensive IPA pronunciation guides
    parameter_optimization: stability 0.75, similarity 0.85, style 0.5
    brand_voice_preservation: intellectual humility vocal characteristics

  quality_assurance:
    synthesis_readiness: TTS-ready script with professional markup
    pronunciation_accuracy: technical terms and researcher names verified
    cost_efficiency: character optimization for synthesis budget
```

### Phase 5: Professional Audio Synthesis (Budget: $7.25)

Broadcast-quality audio creation with professional standards:

```yaml
audio_synthesis_workflow:
  step_1: Use tts-optimizer-enhanced to prepare SSML-formatted script
  step_2: Use audio-synthesizer-enhanced to generate professional audio

  professional_audio_features:
    elevenlabs_optimization: advanced parameter configuration
    lufs_normalization: -16 LUFS professional broadcast standard
    quality_monitoring: real-time synthesis quality tracking
    platform_compatibility: universal streaming platform optimization

  production_requirements:
    audio_quality: professional broadcast standards
    duration_precision: 47-minute target (±2 minutes acceptable)
    brand_voice_consistency: intellectual humility audio delivery
    cost_efficiency: within $7.25 budget allocation
```

### Phase 6: Audio Quality Validation (Budget: $1.00)

Speech-to-text validation loop for comprehensive quality assurance:

```yaml
audio_validation_workflow:
  primary_agent: audio-quality-validator (NEW - STT validation loop)

  validation_features:
    speech_to_text_verification: convert audio back to text for comparison
    word_accuracy_scoring: ≥95% accuracy requirement
    pronunciation_checking: 100% technical term accuracy
    pacing_analysis: 150-160 words per minute optimization
    timing_validation: 47-minute duration compliance

  quality_gates:
    word_accuracy: ≥95% (auto-retry if lower)
    technical_terms: 100% pronunciation accuracy
    duration: 47 minutes ±2 minutes
    composite_quality: ≥85% overall score

  retry_mechanism:
    max_attempts: 3 retries with parameter adjustment
    failure_escalation: human review after 3 failed attempts
    cost_efficiency: within $1.00 validation budget
```

### Phase 7: Final Quality Validation & Packaging (Budget: $0.25)

Complete production package with comprehensive validation:

```yaml
final_validation_workflow:
  quality_gates_verification:
    audio_quality_gate: professional listening quality test (≥90%)
    brand_voice_gate: intellectual humility consistency (≥85%)
    technical_accuracy_gate: fact verification and pronunciation accuracy
    cost_compliance_gate: total budget ≤$15.00

  production_package_creation:
    high_quality_audio: professional MP3 with -16 LUFS normalization
    comprehensive_metadata: episode information, research sources, quality scores
    production_documentation: synthesis parameters, cost breakdown, quality validation
    distribution_readiness: immediate publication readiness
```

---

## Enhanced Quality Assurance System

### Real-Time Quality Monitoring

**Checkpoint Validation at Each Phase:**
```yaml
quality_checkpoints:
  research_validation: source verification, fact triangulation, knowledge synthesis
  script_validation: brand voice consistency, engagement optimization, technical accuracy
  consensus_validation: evaluator agreement, confidence thresholds, disagreement resolution
  audio_validation: synthesis quality, professional standards, platform compatibility
```

### Cost Tracking & Budget Management

**Intelligent Budget Allocation:**
```yaml
budget_management:
  total_episode_budget: $15.00
  phase_allocation:
    research_excellence: $2.50 (17%)
    script_development: $1.75 (12%)
    quality_consensus: $1.50 (10%)
    audio_synthesis: $7.25 (48%)
    audio_validation: $1.00 (7%)
    final_packaging: $0.25 (2%)

  cost_optimization:
    research_caching: 30-60% cost reduction through semantic caching
    parallel_processing: efficient resource utilization
    quality_prediction: prevent costly re-work through early quality gates
```

### Error Recovery & Resilience

**Automated Error Handling:**
```yaml
error_recovery_system:
  quality_gate_failures: automatic retry with enhanced parameters
  agent_timeout_recovery: graceful degradation with alternative workflows
  budget_overrun_protection: automatic cost optimization and alternative approaches
  api_failure_handling: retry with exponential backoff, fallback providers
```

---

## Success Criteria & Quality Gates

### Production Excellence Requirements

**Mandatory Quality Gates:**
- [x] Research Quality: ≥85% comprehensive coverage with verified sources
- [x] Script Excellence: ≥85% brand voice consistency with engagement optimization
- [x] Consensus Achievement: ≥0.75 system confidence through evaluator agreement
- [x] Audio Quality: ≥90% professional broadcast standards with -16 LUFS normalization
- [x] Cost Efficiency: ≤$15.00 total episode production cost
- [x] Duration Compliance: 47 minutes ±2 minutes target achievement

### Production Package Deliverables

**Complete Episode Package:**
```yaml
deliverables:
  primary_audio:
    format: Professional MP3 (44.1kHz, 192kbps)
    duration: ~47 minutes
    loudness: -16 LUFS normalized
    quality: Broadcast-standard synthesis

  supporting_materials:
    research_documentation: comprehensive source attribution and fact verification
    script_archive: final polished script with SSML markup and quality scores
    production_metadata: synthesis parameters, cost breakdown, quality validation
    quality_certification: all quality gate validation results and consensus scores

  distribution_preparation:
    platform_compatibility: verified across major podcast platforms
    metadata_optimization: SEO-optimized titles, descriptions, and tags
    technical_validation: complete audio file integrity and playback verification
```

---

## Advanced Production Features

### Cross-Episode Intelligence

**Series Consistency Management:**
```yaml
series_optimization:
  voice_consistency: maintain character recognition across episodes
  quality_calibration: consistent quality standards and brand voice delivery
  cost_pattern_learning: optimize budget allocation based on topic complexity
  audience_feedback_integration: continuous improvement based on listener response
```

### Scalability & Efficiency

**Production Optimization:**
```yaml
scalability_features:
  parallel_episode_production: support multiple concurrent episode development
  template_optimization: reusable quality patterns for consistent excellence
  resource_pooling: efficient utilization of API quotas and synthesis resources
  automated_quality_learning: continuous improvement in quality prediction and optimization
```

---

## Explicit Agent Orchestration Workflow

**Step-by-Step Task Tool Implementation:**

```yaml
production_orchestration:
  # Phase 1: Research (Budget: $2.50)
  step_01: Use question-generator-enhanced to create strategic research questions for: $ARGUMENTS
  step_02: Use deep-research-agent-enhanced to conduct comprehensive Perplexity research
  step_03: Use research-synthesizer-enhanced to compile research into knowledge package

  # Phase 2: Script Development (Budget: $1.75)
  step_04: Use episode-planner-enhanced to create episode structure from research
  step_05: Use script-writer to transform research into engaging script
  step_06: Use script-polisher-enhanced to refine script with quality feedback

  # Phase 3: Quality Consensus (Budget: $1.50)
  step_07: Use quality-claude-enhanced to evaluate brand voice and engagement
  step_08: Use quality-gemini-enhanced to assess technical production quality
  step_09: Use quality-perplexity-enhanced to verify research accuracy
  step_10: Use brand-voice-validator to ensure intellectual humility consistency

  # Phase 4: Audio Production (Budget: $7.25)
  step_11: Use tts-optimizer-enhanced to prepare SSML-formatted script
  step_12: Use audio-synthesizer-enhanced to generate professional audio

  # Phase 5: Audio Validation (Budget: $1.00)
  step_13: Use audio-quality-validator to perform speech-to-text validation loop

  # Phase 6: Final Packaging (Budget: $0.25)
  step_14: Create episode directory structure and organize all files
  step_15: Generate comprehensive production report and quality metrics
```

**Implementation Example:**

```bash
# Execute complete episode production
/produce-episode-enhanced "The Fascinating Mystery of Dark Matter"

# With custom parameters
/produce-episode-enhanced "Quantum Computing: What We Don't Understand Yet" \
  --research-depth=comprehensive \
  --episode-length=50 \
  --quality-threshold=0.90 \
  --budget-limit=18
```

---

## Production Excellence Achievement

This enhanced production command represents the culmination of professional podcast production automation, delivering broadcast-quality educational content through intelligent research orchestration, sophisticated quality consensus, and professional audio synthesis while maintaining authentic intellectual humility and optimal cost efficiency.

**Expected Results:**
- **Quality**: Professional broadcast-standard episodes exceeding industry benchmarks
- **Efficiency**: Complete production in <2 hours with minimal human intervention
- **Cost**: ≤$15 per episode with 96% quality achievement
- **Consistency**: Reliable quality and brand voice across unlimited episode production
- **Scalability**: Ready for high-volume production with maintained excellence standards

The `/produce-episode-enhanced` command transforms topic ideas into professional podcast episodes through comprehensive automation while preserving the curious, humble spirit that makes "Nobody Knows" educational content exceptional.
