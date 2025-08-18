---
name: produce-research
description: Execute comprehensive research pipeline for podcast episode
---

# Produce Research - Research Stream Execution

Execute the complete research pipeline for a podcast episode using the research orchestrator.

## Usage

```
/produce-research "Episode Topic" [episode_number]
```

## Examples

```
/produce-research "AI Uncertainty and Expert Humility"
/produce-research "The Things Scientists Don't Understand" 5
```

## Execution

Use the research-orchestrator subagent to conduct comprehensive research on: $ARGUMENTS

The research orchestrator will:
1. Create session directory with timestamp
2. Execute 3-agent research pipeline:
   - Deep research with Perplexity
   - Question generation
   - Research synthesis
3. Save COMPLETE research data for review
4. Provide research summary for inspection

## Output

- Complete research package saved to: `sessions/ep_{number}_{date}/research/`
- Reviewable summary available at: `sessions/ep_{number}_{date}/research/research_summary.md`
- Cost tracking included in session metadata

## Next Steps

After research completion:
1. Review the research package thoroughly
2. When satisfied, proceed with `/produce-episode` using the research session path
3. If research needs improvement, re-run this command with refined topic focus

The research stream must be completed and approved before production begins.
