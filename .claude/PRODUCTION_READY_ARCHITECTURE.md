# 🎯 PRODUCTION-READY ARCHITECTURE - CLAUDE CODE NATIVE

## CRITICAL CONSTRAINT DISCOVERED
**Sub-agents CANNOT call other sub-agents** - they don't have access to the Task tool.
Only the main Claude Code agent (YOU) can orchestrate sub-agents via commands.

## CORRECTED SIMPLE ARCHITECTURE

### 1. Commands (5 total) - These orchestrate everything
```
/produce-episode "Topic"     # Main production command (calls agents in sequence)
/research-topic "Topic"      # Research-only command
/episode-status              # Check current episode progress
/cost-check                  # Monitor spending
/validate-episode "ID"       # Quality validation
```

### 2. Sub-Agents (10 total) - Simple, single-purpose tools

**Research Agents (3):**
- `research-agent.md` - Perplexity research execution
- `question-generator.md` - Generate research questions
- `research-synthesizer.md` - Compile research into package

**Production Agents (7):**
- `episode-planner.md` - Structure the episode
- `script-writer.md` - Write the script
- `script-polisher.md` - Polish and refine
- `quality-validator.md` - Validate quality (combines 3 evaluators)
- `tts-optimizer.md` - Prepare for TTS
- `audio-synthesizer.md` - Generate audio
- `brand-validator.md` - Ensure brand consistency

### 3. How It ACTUALLY Works

The `/produce-episode` command must orchestrate EVERYTHING:

```markdown
# /produce-episode command

## Step 1: Research Phase
Use the research-agent sub-agent to gather information about: $ARGUMENTS

## Step 2: Generate Questions
Use the question-generator sub-agent to create research questions based on initial findings

## Step 3: Deep Research
Use the research-agent sub-agent again with the generated questions

## Step 4: Synthesize Research
Use the research-synthesizer sub-agent to compile findings

## Step 5: Plan Episode
Use the episode-planner sub-agent to structure the episode

## Step 6: Write Script
Use the script-writer sub-agent to create the script

## Step 7: Polish Script
Use the script-polisher sub-agent to refine

## Step 8: Validate Quality
Use the quality-validator sub-agent to check quality

## Step 9: Optimize for TTS
Use the tts-optimizer sub-agent to prepare for audio

## Step 10: Generate Audio
Use the audio-synthesizer sub-agent to create final audio
```

### 4. What to DELETE

**Remove these "orchestrator" agents (they can't work):**
- production-orchestrator-enhanced.md
- research-orchestrator-enhanced.md
- Any agent that claims to coordinate other agents

### 5. Hooks for Observability
Hooks monitor each step but don't orchestrate:
- PreToolUse: Cost validation before each agent
- PostToolUse: Track results and costs
- Stop: Final reporting

## THE SIMPLE TRUTH

1. **Commands orchestrate** (because only main Claude can use Task tool)
2. **Sub-agents execute single tasks** (they can't call other agents)
3. **Hooks observe** (they monitor but don't control flow)

This is MUCH SIMPLER than the overcomplicated architecture we had!

## IMMEDIATE ACTIONS

1. Delete orchestrator agents (they literally cannot work)
2. Simplify remaining agents to single-purpose tools
3. Move ALL orchestration logic into commands
4. Test with simple episode production

## Why This Is Better

- **Actually works** with Claude Code constraints
- **Simpler** - no complex agent hierarchies
- **Clearer** - commands control flow explicitly
- **Maintainable** - easy to debug and modify
- **Native** - uses Claude Code as designed
