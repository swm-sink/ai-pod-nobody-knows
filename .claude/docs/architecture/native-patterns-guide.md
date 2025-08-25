# Claude Code Native Patterns Guide

## Overview

**Technical:** Guide for implementing podcast production workflows using Claude Code's native architecture patterns: sub-agents, slash commands, and hooks.

**Simple:** Like a recipe book for building podcast automation using Claude Code's built-in tools instead of creating everything from scratch.

**Connection:** This teaches platform-native development patterns that are more maintainable and reliable.

## Pattern 1: Sub-Agents

### Purpose
Self-contained AI agents for specific podcast production tasks.

### Structure
```markdown
---
name: agent-name
description: "What this agent does"
tools: Read, Write, [specific tools needed]
model: claude-sonnet-4-20250805
max_tokens: 2000
temperature: 0.1
---

# Agent Name

Clear, simple prompt with specific instructions.
Maximum 50 lines of content.
```

### Examples
- `research-orchestrator` - Coordinates Perplexity research
- `script-writer` - Creates podcast scripts
- `audio-synthesizer` - Generates audio with ElevenLabs

## Pattern 2: Slash Commands

### Purpose
User-facing commands that delegate to sub-agents.

### Structure
```markdown
# /command-name - Brief description

Use the [sub-agent-name] sub-agent to: $ARGUMENTS

Execute [specific workflow steps].
```

### Examples
- `/research-query` - Delegates to research-orchestrator
- `/create-episode` - Orchestrates full episode production
- `/quality-check` - Runs quality validation

## Pattern 3: Hooks

### Purpose
Event-driven automation and monitoring.

### Configuration
```json
{
  "hooks": {
    "pre-tool-use": ["cost-tracking.sh", "validation.sh"],
    "post-tool-use": ["quality-check.sh", "cleanup.sh"],
    "user-prompt-submit": ["input-validation.sh"]
  }
}
```

### Use Cases
- Cost tracking before expensive operations
- Quality validation after content creation
- Input sanitization on user inputs

## Best Practices

1. **Keep It Simple**
   - Sub-agents: Max 50 lines
   - Single responsibility per agent
   - Clear, specific prompts

2. **Native Integration**
   - Use Claude Code tools, not external scripts
   - Leverage built-in capabilities
   - Minimize dependencies

3. **Clear Communication**
   - Commands delegate to agents
   - Agents focus on execution
   - Hooks provide automation

## Anti-Patterns

❌ **Don't:**
- Create enterprise frameworks
- Build complex abstractions
- Use external orchestration systems
- Implement security theater

✅ **Do:**
- Use native Claude Code patterns
- Focus on podcast production needs
- Keep solutions simple and maintainable
- Leverage platform capabilities
