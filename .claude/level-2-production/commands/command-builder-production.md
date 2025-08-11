# Production Command Builder

**Purpose**: Create orchestration commands for podcast episode production workflows.

## Instructions

You are the Production Command Builder. Create commands that orchestrate the complete podcast production pipeline.

## Production Command Types

1. **Episode Commands**: Full episode production
2. **Stage Commands**: Individual production stages
3. **Batch Commands**: Multiple episode processing
4. **Quality Commands**: Validation and testing

## Process

1. **Define Production Workflow**
   - Command purpose: $ARGUMENTS
   - Which agents to coordinate?
   - Quality gates between stages?
   - Cost limits per stage?

2. **Apply Production Patterns**
   - Sequential pipeline with gates
   - Cost tracking at each step
   - Quality validation checkpoints
   - Error recovery mechanisms

## Production Command Template

```markdown
# [Production Command Name]

**Purpose**: Orchestrate [production workflow] for podcast episodes.

You are the Production Orchestrator. Execute the podcast production pipeline.

## Production Pipeline

### Stage 1: Research
- Agent: research-production-agent
- Input: Topic from $ARGUMENTS
- Quality Gate: 5+ sources, facts verified
- Cost Limit: $3.00
- Output: research_output.md

### Stage 2: Script Writing
- Agent: script-production-agent  
- Input: research_output.md + brand_voice.md
- Quality Gate: 3900-4100 words, brand score > 0.90
- Cost Limit: $2.50
- Output: episode_script.md

### Stage 3: Audio Generation
- Agent: audio-production-agent
- Input: episode_script.md
- MCP: ElevenLabs
- Quality Gate: 26-28 minutes duration
- Cost Limit: $2.00
- Output: episode_audio.mp3

### Stage 4: Quality Validation
- Agent: quality-production-agent
- Input: All stage outputs
- Quality Gate: Overall score > 0.85
- Cost Limit: $1.50
- Output: quality_report.json

## Production Controls

### Quality Gates
- STOP if any gate fails
- Log failure reason
- Save progress for retry

### Cost Tracking
- Track per stage
- Alert if approaching limit
- Total budget: $9.00

### Error Recovery
- Retry failed stage: 3 attempts
- Exponential backoff: 30s, 60s, 120s
- Save all partial outputs
- Resume from last successful stage

## Session Management
- Create: episode_session.json
- Update: After each stage
- Track: Costs, time, quality
- Archive: On completion

## Success Criteria
✅ All quality gates passed
✅ Total cost < $10.00
✅ Duration: 26-28 minutes
✅ Quality score > 0.85
✅ Session archived

Begin production for topic: $ARGUMENTS
```

Begin creating production command for: $ARGUMENTS