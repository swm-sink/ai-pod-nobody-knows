---
name: test-episode
description: Simple test command demonstrating minimum viable complexity for episode production
---

# Test Episode - Simplified Production Test

Execute a minimal test of the podcast production pipeline using Claude Code's native capabilities.

## Usage

```
/test-episode "Episode Topic"
```

## Examples

```
/test-episode "The Mystery of Sleep"
/test-episode "What Scientists Don't Know About Consciousness"
```

## Execution (Simplified)

This command demonstrates minimum viable complexity by using Claude Code's Task tool directly:

1. **Research Phase**: Use the deep-research-agent subagent to gather basic research
2. **Script Phase**: Use the script-writer subagent to create a draft script
3. **Quality Phase**: Use the quality-claude subagent to evaluate quality
4. **Output**: Simple session folder with results

## Benefits of This Approach

- **Direct Integration**: Uses Claude Code's native Task tool
- **Parallel Execution**: Claude Code handles agent coordination
- **Cost Efficient**: Minimal orchestration overhead
- **Easy Debugging**: Each step is transparent
- **Elegant Simplicity**: No complex state management

## Example Output

```
sessions/test_ep_YYYYMMDD_HHMMSS/
├── research_summary.md
├── script_draft.md
├── quality_report.json
└── session_costs.json
```

This test validates the core pipeline without complex orchestration layers.