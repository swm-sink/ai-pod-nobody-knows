---
name: produce-series
description: Simple batch production of multiple episodes using Claude Code's native capabilities
---

# Produce Series - Simplified Batch Production

Execute multiple episode production using Claude Code's Task tool for elegant orchestration.

## Usage

```
/produce-series "Topic Theme" [episode_count]
```

## Examples

```
/produce-series "AI Mysteries" 5
/produce-series "Sleep Science Unknowns" 3
```

## Execution (Minimum Viable Complexity)

This command uses Claude Code's native Task tool to orchestrate multiple episodes:

1. **Generate Episode Topics**: Use the 03_question-generator subagent to create episode topics within the theme
2. **For Each Episode**:
   - Use the 01_research-orchestrator subagent for research
   - Use the 01_production-orchestrator subagent for production
   - Let Claude Code handle parallel execution
3. **Track Progress**: Simple session folder per episode

## Benefits

- **Claude Code Native**: Uses built-in Task tool capabilities
- **Parallel Processing**: Claude Code handles concurrent execution
- **Simple State**: No complex orchestration or state management
- **Easy Recovery**: Each episode is independent
- **Cost Transparent**: Simple per-episode tracking

## Output Structure

```
sessions/series_[theme]_[date]/
├── episode_01/
├── episode_02/
├── episode_03/
└── series_summary.md
```

This approach follows minimum viable complexity principles while leveraging Claude Code's strengths.
