# Agent Architecture & MCP Integration - Native Claude Code Simplified
**Version:** 1.0.0
**Updated:** 2025-09-01
**Purpose:** Complete agent orchestration and MCP integration patterns

## 🚨 Critical Architectural Principles

### Correct Sub-Agent Invocation
**NEVER use Task tool for sub-agents** - Sub-agents are invoked directly by name, not through Task tool proxy delegation.

**Correct Pattern:**
```markdown
Use the researcher agent to investigate: "topic details with specific requirements"
```

**Incorrect Pattern (DO NOT USE):**
```markdown
Task tool: Launch researcher agent... ❌
```

### MCP Tool Inheritance
**Key Insight:** Sub-agents automatically inherit ALL MCP tools when the `tools` field is omitted in their YAML configuration.

```yaml
# Correct - Inherits all MCP tools
name: researcher
model: claude-3-5-sonnet
# tools field omitted = full inheritance

# Incorrect - Limited to specified tools only
name: researcher
model: claude-3-5-sonnet
tools: [Read, Write]  # ❌ Blocks MCP inheritance
```

### Official Documentation
- **Agent Architecture:** https://docs.anthropic.com/en/docs/claude-code/agents
- **MCP Integration:** https://docs.anthropic.com/en/docs/claude-code/mcp
- **Perplexity API:** https://docs.perplexity.ai/api-reference
- **ElevenLabs API:** https://elevenlabs.io/docs/api-reference

## 📊 Simplified Agent Portfolio (10 Agents)

### Research Pipeline (3 Agents)

#### 1. Researcher
```yaml
purpose: "Deep investigation and strategic question generation"
capabilities:
  - Multi-source research via Perplexity
  - Expert discovery and citation
  - Strategic question generation
  - Cross-domain synthesis
mcp_tools:
  - mcp__perplexity-ask__perplexity_ask
  - WebSearch
  - WebFetch
cost_per_use: ~$0.20-0.40
```

#### 2. Fact-Checker
```yaml
purpose: "Validation, verification, and accuracy assurance"
capabilities:
  - Source triangulation
  - Contradiction detection
  - Credibility assessment
  - Citation verification
mcp_tools:
  - mcp__perplexity-ask__perplexity_ask
  - WebSearch
cost_per_use: ~$0.10-0.20
```

#### 3. Synthesizer
```yaml
purpose: "Knowledge packaging and narrative coherence"
capabilities:
  - Research synthesis
  - Narrative arc creation
  - Cross-episode intelligence
  - Brand voice integration
tools:
  - Read, Write, Edit
cost_per_use: ~$0.15-0.25
```

### Production Pipeline (3 Agents)

#### 4. Writer
```yaml
purpose: "Episode architecture and script creation"
capabilities:
  - Episode structure design
  - Narrative development
  - Brand voice preservation
  - Question integration (8-10 per episode)
output:
  format: Markdown script
  length: 12000-16000 characters
  structure: "Opening → 3 segments → closing"
cost_per_use: ~$0.30-0.50
```

#### 5. Polisher
```yaml
purpose: "Script refinement and TTS optimization"
capabilities:
  - SSML enhancement
  - Pronunciation validation (IPA)
  - Brand consistency checking
  - Timing optimization (28 min target)
optimizations:
  - Technical terms → IPA phonetics
  - Natural pauses → SSML breaks
  - Emphasis → prosody tags
cost_per_use: ~$0.20-0.30
```

#### 6. Judge
```yaml
purpose: "Multi-evaluator quality consensus"
evaluators:
  claude:
    weight: 0.55
    focus: "Brand consistency, narrative flow"
  gemini:
    weight: 0.45
    focus: "Technical accuracy, structure"
  perplexity:
    perspective: "Fact verification, citations"
quality_gates:
  brand_consistency: ≥0.90
  technical_accuracy: ≥0.85
  engagement_score: ≥0.80
cost_per_use: ~$0.25-0.40
```

### Audio Pipeline (2 Agents)

#### 7. Audio-Producer
```yaml
purpose: "Professional audio synthesis via ElevenLabs"
capabilities:
  - Single-call synthesis (<40K chars)
  - Intelligent chunking (>40K chars)
  - SSML processing
  - Voice consistency
voice_config:
  id: "ZF6FPAbjXT4488VcRRnw"
  name: "Amelia"
  stability: 0.75
  similarity: 0.85
mcp_tools:
  - mcp__ElevenLabs__text_to_speech
cost_per_use: ~$1.00-1.50
```

#### 8. Audio-Validator
```yaml
purpose: "Audio quality assurance"
capabilities:
  - STT verification (Whisper)
  - Word accuracy checking (≥90%)
  - Pronunciation validation
  - Duration verification
metrics:
  word_accuracy: ≥0.90
  pronunciation: ≥0.85
  mos_score: ≥4.8/5.0
cost_per_use: ~$0.20-0.30
```

### Utility Agents (2 Agents)

#### 9. Batch-Processor
```yaml
purpose: "Multi-episode batch coordination"
capabilities:
  - Parallel processing (5 concurrent)
  - Progress tracking
  - Session management
  - Error recovery
batch_sizes:
  small: 10 episodes
  medium: 50 episodes
  large: 125 episodes
cost_optimization: "30% reduction at scale"
```

#### 10. Cost-Monitor
```yaml
purpose: "Budget tracking and enforcement"
capabilities:
  - Real-time cost tracking
  - Budget enforcement
  - Cost attribution
  - Optimization recommendations
limits:
  per_episode: $4.00
  daily: $20.00
  project: $500.00
```

## 🔧 MCP Integration Details

### Perplexity Integration
```yaml
models:
  sonar-pro:
    purpose: "Deep research with citations"
    context: 127K tokens
    pricing: "$5 per 1M tokens"

  sonar-reasoning:
    purpose: "Logical analysis and reasoning"
    context: 127K tokens
    pricing: "$5 per 1M tokens"

research_patterns:
  discovery:
    queries: 3-5
    depth: "Comprehensive"
    sources: "100+ automatic"

  validation:
    queries: 2-3
    depth: "Targeted"
    sources: "Cross-verification"

structured_outputs:
  format: JSON
  schema: "Predefined templates"
  validation: "Schema enforcement"
```

### ElevenLabs Integration
```yaml
synthesis_modes:
  single_call:
    limit: 40000 characters
    coverage: "95% of episodes"
    time: "20-30 seconds"
    quality: "Consistent throughout"

  chunked:
    chunk_size: 5000
    overlap: 100
    concatenation: "Seamless"
    quality: "Minor variations possible"

voice_optimization:
  amelia_settings:
    stability: 0.75  # Consistent delivery
    similarity: 0.85  # Natural variation
    style: 0.3       # Subtle emphasis
    speaker_boost: true

ssml_processing:
  short_breaks: "40% reliability"
  medium_breaks: "80% reliability"
  long_breaks: "95% reliability"

pronunciation:
  ipa_support: true
  phoneme_tags: true
  custom_dictionary: true
```

### Duration Calculation
```yaml
speech_rates:
  amelia_base: 206 WPM
  technical: 185 WPM (-10%)
  narrative: 206 WPM (standard)
  conversational: 226 WPM (+10%)

timing_formula:
  base: "word_count / adjusted_wpm"
  ssml: "sum(break_duration * processing_rate)"
  total: "base + ssml"

target_duration:
  ideal: "28 minutes"
  acceptable: "25-30 minutes"
  max: "35 minutes"
```

## 🎯 Agent Invocation Patterns

### Research Phase
```markdown
# Discovery
Use the researcher agent to investigate: "The science of memory formation"
Requirements:
- Find 2025 research breakthroughs
- Identify leading neuroscientists
- Focus on uncertainties and debates
- Generate 10 strategic questions

# Validation
Use the fact-checker agent to verify the research findings
Requirements:
- Cross-reference all claims
- Verify expert credentials
- Check for contradictions
- Assess source reliability

# Synthesis
Use the synthesizer agent to create narrative structure
Requirements:
- Create engaging story arc
- Integrate brand voice
- Connect to previous episodes
- Package for script writing
```

### Production Phase
```markdown
# Writing
Use the writer agent to create episode script
Requirements:
- Target 28 minutes (15K characters)
- Include 8-10 questions
- Three main segments
- Intellectual humility tone

# Polishing
Use the polisher agent to optimize for audio
Requirements:
- Add SSML tags for pacing
- Convert technical terms to IPA
- Validate pronunciation
- Check brand consistency

# Judging
Use the judge agent to evaluate quality
Requirements:
- Three-evaluator consensus
- All quality gates must pass
- Provide improvement suggestions
- Final approval decision
```

### Audio Phase
```markdown
# Synthesis
Use the audio-producer agent to generate audio
Requirements:
- Use Amelia voice (ZF6FPAbjXT4488VcRRnw)
- Single-call synthesis if <40K
- Process SSML tags
- Export as MP3

# Validation
Use the audio-validator agent to verify quality
Requirements:
- STT accuracy ≥90%
- Pronunciation check
- Duration verification
- MOS score ≥4.8
```

## 📊 Quality & Performance Metrics

### Agent Performance Targets
```yaml
research_agents:
  depth: "100+ sources per topic"
  accuracy: "≥95% fact verification"
  cost: "$0.50-1.00 per episode"
  time: "5-10 minutes"

production_agents:
  quality: "≥0.90 brand consistency"
  engagement: "≥0.80 score"
  cost: "$0.75-1.50 per episode"
  time: "5-10 minutes"

audio_agents:
  quality: "≥4.8/5.0 MOS"
  accuracy: "≥90% word accuracy"
  cost: "$1.50-2.00 per episode"
  time: "5-10 minutes"
```

### Cost Optimization Strategies
1. **Batch Processing** - 30% cost reduction at scale
2. **Cache Research** - Avoid duplicate API calls
3. **Model Selection** - Use appropriate model for task
4. **Token Optimization** - Concise prompts, selective context
5. **Single-Call Audio** - Leverage 40K character limit

## 🔄 Error Handling & Recovery

### Common Issues & Solutions
```yaml
mcp_authentication:
  error: "401 invalid_api_key"
  solution: "Ensure env vars loaded before Claude Code starts"
  command: "./build/scripts/start-claude.sh"

synthesis_timeout:
  error: "ElevenLabs timeout"
  solution: "Chunk script if >40K characters"
  fallback: "Use chunked synthesis mode"

quality_failure:
  error: "Score below threshold"
  solution: "Review judge feedback, iterate"
  retry: "Maximum 3 attempts"

cost_overrun:
  error: "Budget exceeded"
  solution: "Check pre-validation hooks"
  prevention: "Monitor continuously"
```

## 🎪 Best Practices

### Agent Design
1. **Single Responsibility** - Each agent has one clear purpose
2. **Tool Inheritance** - Omit tools field for MCP access
3. **Clear Interfaces** - Well-defined inputs/outputs
4. **Error Handling** - Graceful degradation
5. **Cost Awareness** - Monitor and optimize

### Orchestration
1. **Direct Invocation** - Use agent name directly
2. **Clear Requirements** - Specific, measurable goals
3. **Quality Gates** - Enforce at each stage
4. **Parallel Processing** - When tasks are independent
5. **Session Management** - Track state and costs

### Integration
1. **Validate MCP** - Check connections before use
2. **Monitor Costs** - Real-time tracking
3. **Cache Results** - Avoid redundant calls
4. **Log Everything** - Enable debugging
5. **Test Fallbacks** - Ensure recovery paths work

---

**External References:**
- MCP Specification: https://modelcontextprotocol.io/docs
- Claude Code Agents: https://docs.anthropic.com/en/docs/claude-code/agents
- Perplexity Models: https://docs.perplexity.ai/api-reference/models
- ElevenLabs Voices: https://elevenlabs.io/docs/voices
