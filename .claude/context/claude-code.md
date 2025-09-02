# Claude Code Orchestration Context

## Agent Orchestration Patterns

**Correct Invocation:**
```
Use the [agent-name] agent to [action]: "specific requirements"
```

**MCP Tool Inheritance:**
- Agents inherit ALL MCP tools when tools field is omitted
- Never specify tools field in agent YAML
- Direct agent invocation, never Task tool proxy

## Command Orchestration
**Master workflow pattern:**
1. `/podcast-workflow` chains: research → production → audio
2. Each phase uses specialized agents
3. User review checkpoints before expensive operations
4. Session state maintained across phases

## Quality Consensus System
- Claude evaluation (55% weight): Brand voice, creativity
- Gemini evaluation (45% weight): Technical accuracy, structure
- Perplexity validation: Fact verification, source authority
- Consensus threshold: ≥85% for publication

## Cost Management
- Pre-operation validation with budget checking
- Real-time cost tracking and attribution
- Phase-based cost allocation
- Budget limits: $4.00 max per episode

## Session Management
- Persistent state across workflow phases
- Checkpoint system for error recovery
- Cost tracking throughout production
- Quality metrics continuity

This context enables reliable multi-agent coordination and cost control.
