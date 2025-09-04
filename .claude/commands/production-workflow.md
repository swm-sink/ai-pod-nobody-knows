# /production-workflow - Native Script Production Orchestration

Execute complete script production pipeline with quality validation for the "Nobody Knows" podcast.

## Usage

```bash
/production-workflow [episode_number]
```

## Example

```bash
/production-workflow 1
```

## Prerequisites

- Research package must exist in `nobody-knows/production/ep_{number}/research/`
- Quality gates configured in `.claude/config/quality_gates.yaml`

## Purpose

Orchestrate script creation from research through quality validation, maintaining three-evaluator consensus and brand alignment.

## Production Orchestration Flow

I will coordinate the production pipeline using our specialized agents:

### Step 1: Script Creation
```
Use the writer agent to create initial script:
[Load research package from session]

Requirements:
- Episode architecture (intro/body/conclusion)
- Narrative development with progressive complexity
- Educational framework integration
- Feynman analogies (3-5 per episode)
- Intellectual humility moments (3-5 per episode)
- Target: 5,768 words (28 minutes @ 206 WPM)
- Output: Initial script draft
```

### Step 2: Script Optimization
```
Use the polisher agent to refine for production:
[Pass initial script]

Requirements:
- TTS optimization with SSML markup
- Pronunciation validation (IPA for technical terms)
- Brand voice consistency (≥90% target)
- Pacing adjustment for natural speech
- Expert name pronunciation guides
- Output: Production-ready script
```

### Step 3: Quality Validation
```
Use the judge agent for consensus evaluation:
[Pass polished script]

Requirements:
- Three-evaluator consensus system:
  * Claude: Creative & brand assessment (55% weight)
  * Gemini: Technical compliance (45% weight)
  * Perplexity: Fact verification (integrated)
- Quality gates enforcement:
  * Brand consistency ≥90%
  * Engagement ≥80%
  * Technical accuracy ≥85%
- Output: Quality consensus report
```

## Session Management

```yaml
session_structure:
  directory: nobody-knows/production/ep_{number}_{timestamp}/script/
  inputs:
    - research/synthesis_package.json
  outputs:
    - initial_script.md
    - polished_script.md
    - script_with_ssml.txt
    - quality_report.json
    - production_metrics.json
```

## Quality Gates

```yaml
required_scores:
  brand_consistency: 0.90  # Core requirement
  engagement: 0.80         # Listener retention
  technical_accuracy: 0.85 # Factual correctness
  comprehension: 0.85      # General audience

revision_triggers:
  minor: "1-2 gates fail by <5%"
  major: "3+ gates fail OR any by >10%"
  rewrite: "Any score below 70%"
```

## Cost Tracking

- **Budget Allocation**: $0.15 production phase
- **Writer Agent**: $0.05 (script generation)
- **Polisher Agent**: $0.03 (optimization)
- **Judge Agent**: $0.07 (three-evaluator consensus)
- **Cost Monitoring**: Real-time via hooks

## Production Standards

```yaml
episode_structure:
  introduction:
    duration: "1-2 minutes"
    elements: [hook, thesis, preview]

  body:
    duration: "24-26 minutes"
    elements: [foundation, complexity, examples, humility]

  conclusion:
    duration: "1-2 minutes"
    elements: [takeaways, curiosity_prompt, next_tease]

brand_requirements:
  intellectual_humility: "3-5 expressions"
  questions_per_1000_words: "2-4"
  feynman_analogies: "3-5 total"
  curiosity_markers: "2-4 expressions"
```

## Error Handling

```yaml
quality_failures:
  first_attempt: "Targeted revision based on feedback"
  second_attempt: "Comprehensive repolishing"
  third_attempt: "Complete rewrite from research"

cost_overrun:
  action: "Immediate halt with state preservation"
  recovery: "Resume from last checkpoint"
```

## Output Schema

```json
{
  "episode_number": 1,
  "script_quality": {
    "brand_consistency": 0.92,
    "engagement": 0.85,
    "technical_accuracy": 0.88,
    "consensus_score": 0.88
  },
  "word_count": 5768,
  "duration_estimate": 28,
  "revision_count": 1,
  "cost": 0.14,
  "session_id": "ep_001_20250901_1030"
}
```

## Native Claude Code Pattern

This command demonstrates:
- Command orchestrates production workflow
- Agents specialize in distinct tasks
- Quality validation through consensus
- Direct agent invocation pattern

---

**Technical**: Production orchestration with specialized agents for script creation, optimization, and multi-evaluator quality validation.

**Simple**: Like a film production where the writer creates, the editor polishes, and critics evaluate before release.

**Connection**: This teaches quality-driven production workflows and consensus-based validation systems.
