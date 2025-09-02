# /research-workflow - Native Research Orchestration

Execute comprehensive research pipeline using specialized agents for the "Nobody Knows" podcast.

## Usage

```bash
/research-workflow [episode_number] [topic]
```

## Example

```bash
/research-workflow 1 "The Dirty Secret: Even the Experts Are Making It Up"
```

## Purpose

Orchestrate the complete research pipeline through direct agent invocation, maintaining the 4-stage depth while simplifying coordination.

## Research Orchestration Flow

I will coordinate the research pipeline using our specialized agents:

### Step 1: Deep Investigation
```
Use the researcher agent to investigate the topic:
"$ARGUMENTS"

Requirements:
- Topic landscape mapping with 2024-2025 focus
- Expert discovery with institutional verification
- Multi-query Perplexity research (Sonar-Deep-Research model)
- Source diversification across academic/industry/news
- Knowledge gap identification
- Output: Comprehensive research findings
```

### Step 2: Fact Verification
```
Use the fact-checker agent to validate research:
[Pass researcher output]

Requirements:
- Source triangulation and cross-verification
- Contradiction detection and resolution
- Expert quote verification
- Statistical accuracy checking
- Currency validation (2024-2025 sources)
- Output: Validated research package
```

### Step 3: Knowledge Synthesis
```
Use the synthesizer agent to package for production:
[Pass validated research]

Requirements:
- Narrative coherence optimization
- Cross-episode intelligence integration
- Brand voice alignment preparation
- Educational framework structuring
- Intellectual humility moments identification
- Output: Production-ready research package
```

## Session Management

```yaml
session_structure:
  directory: sessions/ep_{number}_{timestamp}/research/
  outputs:
    - research_findings.json
    - validation_report.json
    - synthesis_package.json
    - research_metrics.json
```

## Quality Gates

- **Research Depth**: ≥9.0/10 comprehensive coverage
- **Source Authority**: ≥90% verification rate
- **Expert Diversity**: 10+ sources from multiple institutions
- **Fact Accuracy**: 100% verified claims
- **Brand Alignment**: Intellectual humility integrated

## Cost Tracking

- **Budget Allocation**: $1.35 research phase
- **Perplexity Queries**: 3-5 Sonar-Deep calls
- **WebSearch Validation**: 2-3 verification searches
- **Cost Monitoring**: Real-time via hooks

## Error Handling

```yaml
retry_strategy:
  max_attempts: 3
  backoff: exponential
  fallback: alternative_sources
  
recovery_points:
  - After each agent completion
  - Session state preserved
  - Partial results saved
```

## Output Schema

```json
{
  "episode_number": 1,
  "topic": "...",
  "research_quality": 9.2,
  "sources_count": 15,
  "expert_quotes": 12,
  "knowledge_gaps": 3,
  "cost": 1.25,
  "session_id": "ep_001_20250901_1000"
}
```

## Native Claude Code Pattern

This command demonstrates proper orchestration where:
- The command coordinates workflow
- Agents handle specialized tasks
- Direct invocation (not Task delegation)
- Clean separation of concerns

---

**Technical**: Command-level orchestration with specialized agent invocation for comprehensive research pipeline execution.

**Simple**: Like a research coordinator who assigns specific tasks to expert researchers, fact-checkers, and editors.

**Connection**: This teaches workflow orchestration and specialization patterns essential for complex AI systems.