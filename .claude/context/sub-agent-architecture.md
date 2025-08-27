# Sub-Agent Architecture - Source of Truth

**Date Created:** 2025-08-26
**Research Basis:** 20+ Perplexity searches + WebSearch validation
**Status:** Authoritative - Required reading before modifying agents

## 🚨 CRITICAL ARCHITECTURAL PRINCIPLES

### The Fundamental Truth About Claude Code Sub-Agents

**Sub-agents are NOT invoked via Task tool delegation.** This is the root cause of "0 tool uses" simulation issues.

**Technical:** Claude Code sub-agents are specialized AI personalities with isolated contexts, custom system prompts, and configurable tool access that are invoked directly by name, not through Task tool proxy delegation which creates simulation contexts.

**Simple:** Think of sub-agents like calling specific experts by name ("Use the research-discovery agent to...") vs Task tool which is like hiring temporary workers for parallel jobs.

**Connection:** This teaches proper AI orchestration patterns, context management, and tool delegation architecture essential for production-grade AI systems.

## ✅ CORRECT PATTERNS

### Pattern 1: Direct Sub-Agent Invocation (RECOMMENDED)
```markdown
Use the research-discovery agent to investigate Episode 3 topic:
"The Science of Memory Formation - What neuroscience reveals about how we create and retrieve memories"

Requirements:
- Use Perplexity MCP to find leading researchers active in 2024-2025
- Cross-validate findings with WebSearch
- Create discovery-results.json with structured findings
- Focus on intellectual humility and research uncertainties
```

**Why This Works:**
- ✅ Invokes real sub-agent with specialized context
- ✅ Sub-agent inherits full MCP toolset
- ✅ Results in >0 tool uses (real execution)
- ✅ Maintains agent-specific prompting and expertise

### Pattern 2: Main Chat Direct Execution
```markdown
I'll conduct research-discovery workflow directly using available MCP tools:

1. Query Perplexity for memory formation experts
2. Cross-validate with WebSearch
3. Structure findings into discovery format
4. Save to discovery-results.json
```

**When to Use:**
- Simple workflows that don't need specialized context
- Quick tasks that benefit from main chat's accumulated context
- When sub-agent overhead isn't justified

### Pattern 3: Task Tool for Parallel Processing (NOT Agent Delegation)
```markdown
Explore the codebase in parallel using 4 tasks:
- Task 1: Analyze .claude/agents/ directory structure
- Task 2: Review .claude/commands/ workflow patterns
- Task 3: Check project configuration files
- Task 4: Examine documentation architecture
```

**Correct Use Case:**
- ✅ Parallel file operations
- ✅ Independent directory exploration
- ✅ Concurrent analysis of separate code sections
- ❌ NOT for sub-agent delegation

## ❌ INCORRECT PATTERNS (CAUSES SIMULATION)

### Anti-Pattern 1: Task Tool "Delegation"
```markdown
# WRONG - Causes 0 tool uses
Use Task tool to delegate to research-discovery agent:
- Episode topic: $ARGUMENTS
- Session ID: ep_[NUMBER]_optimized_[TIMESTAMP]
```

**Why This Fails:**
- ❌ Creates temporary Task instance that simulates agent behavior
- ❌ Task tool lacks specialized agent context and prompting
- ❌ Results in 0 tool uses (simulation instead of real execution)
- ❌ Loses agent-specific expertise and configuration

### Anti-Pattern 2: Ambiguous Agent References
```markdown
# WRONG - Too vague for deterministic invocation
Research this topic using discovery patterns
Have agents investigate the subject
```

**Problems:**
- ❌ Doesn't specify which agent to use
- ❌ May trigger automatic delegation to wrong agent
- ❌ Reduces predictability and control

## Official Documentation Sources

### Primary References
1. **Anthropic Official Documentation:** https://docs.anthropic.com/en/docs/claude-code/sub-agents
   - Sub-agent configuration and file formats
   - Tool inheritance patterns
   - Best practices and usage examples

2. **Claude Code Best Practices:** https://www.anthropic.com/engineering/claude-code-best-practices
   - Production-ready patterns
   - Performance considerations
   - Advanced orchestration techniques

3. **MCP Integration Guide:** https://docs.anthropic.com/en/docs/claude-code/settings#tools-available-to-claude
   - MCP server configuration
   - Tool inheritance behavior
   - Debugging tool access issues

### Community Resources
4. **ClaudeLog Task/Agent Tools:** https://claudelog.com/mechanics/task-agent-tools/
   - Task tool vs sub-agent differences
   - Parallel processing patterns
   - Performance characteristics

5. **GitHub Sub-Agent Collections:**
   - Production-ready examples: https://github.com/wshobson/agents
   - Full-stack development agents: https://github.com/lst97/claude-code-sub-agents
   - Curated agent list: https://github.com/hesreallyhim/awesome-claude-code-agents

### Technical Deep Dives
6. **Sub-Agent Architecture Analysis:** https://cuong.io/blog/2025/06/24-claude-code-subagent-deep-dive
7. **Multi-Agent Parallel Coding:** https://medium.com/@codecentrevibe/claude-code-multi-agent-parallel-coding-83271c4675fa
8. **MCP Integration Enhancement:** https://dev.to/oikon/enhancing-claude-code-with-mcp-servers-and-subagents-29dd

## Architecture Components

### Sub-Agent Configuration (`.claude/agents/*.md`)
```yaml
---
name: research-discovery
description: Strategic research discovery for podcast topics. Use to investigate new episode subjects, identify experts, and map knowledge landscapes with intellectual humility focus.
# tools: # REMOVED - Inherits ALL tools including full MCP suite from main thread
---

You are a strategic research discovery specialist for the "Nobody Knows" podcast...
```

**Key Points:**
- **Omit `tools:` field** to inherit full MCP toolset
- **Detailed descriptions** enable automatic delegation
- **Action-oriented language** improves invocation matching

### Command File Patterns (`.claude/commands/*.md`)
```markdown
### Stage 1: Strategic Discovery
Use the research-discovery agent to investigate the episode topic: "$ARGUMENTS"

Requirements:
- Use Perplexity MCP for expert identification and current research
- Cross-validate findings with WebSearch for authority verification
- Create discovery-results.json in session directory
- Focus on intellectual humility and acknowledged uncertainties
```

**Architecture Notes:**
- **Direct agent invocation** instead of Task delegation
- **Specific MCP tool requirements** ensure proper tool usage
- **Clear deliverables** guide agent execution
- **Session management** maintains workflow coordination

### MCP Tool Inheritance Behavior
```markdown
Sub-Agent Tool Access:
├── tools: field OMITTED → Inherits ALL MCP tools (RECOMMENDED)
├── tools: field SPECIFIED → Restricted to listed tools only
└── Task tool instances → LIMITED inheritance with simulation contexts
```

## Troubleshooting Guide

### "0 Tool Uses" Diagnosis

**Symptom:** Sub-agent appears to execute but shows 0 tool uses

**Diagnosis Steps:**
1. **Check Invocation Pattern:** Using Task tool delegation? → Switch to direct invocation
2. **Verify Agent Config:** Has `tools:` field? → Remove to inherit MCP tools
3. **Test Direct Execution:** Try main chat MCP calls → Compare tool usage counts
4. **Check Agent Description:** Too vague? → Make action-oriented and specific

**Common Fixes:**
```markdown
# BEFORE (0 tools)
Use Task tool to delegate to research-discovery agent

# AFTER (>0 tools)
Use the research-discovery agent to investigate [topic]
```

### MCP Tool Access Issues

**Symptom:** Sub-agent can't access Perplexity/ElevenLabs/etc.

**Solutions:**
1. Remove `tools:` field from agent YAML frontmatter
2. Verify MCP servers are configured in main Claude Code
3. Check `.mcp.json` configuration
4. Use `--mcp-debug` flag for diagnostics

### Agent Selection Problems

**Symptom:** Wrong agent invoked or no agent selected

**Solutions:**
1. Use explicit agent naming: "Use the [agent-name] agent to..."
2. Improve agent descriptions with specific use cases
3. Add "use proactively" language to agent descriptions
4. Check for naming conflicts (project vs user agents)

## Performance Considerations

### Context Efficiency
- **Sub-agents:** Isolated context prevents main thread pollution
- **Task tool:** Lightweight but creates simulation contexts for complex workflows
- **Direct execution:** Uses main context but preserves accumulated knowledge

### Latency Characteristics
- **Sub-agents:** Initial latency for context setup, then specialized execution
- **Task parallel:** Fast for file operations, poor for MCP integration
- **Direct main:** Immediate execution with full context

### Cost Optimization
- **Batch operations** in sub-agents to minimize context switching
- **Use Task tool** only for true parallel file operations
- **Direct invocation** for simple workflows requiring MCP tools

## Integration Patterns

### Research Pipeline Example
```markdown
## 4-Stage Research Pipeline - Correct Architecture

### Stage 1: Strategic Discovery
Use the research-discovery agent to investigate: "$ARGUMENTS"
→ Outputs: discovery-results.json

### Stage 2: Deep Investigation
Use the research-deep-dive agent to expand research:
→ Input: discovery-results.json
→ Outputs: deep-research.json

### Stage 3: Validation & Verification
Use the research-validation agent to verify findings:
→ Input: deep-research.json
→ Outputs: validated-research.json

### Stage 4: Synthesis & Packaging
Use the research-synthesis agent to create production package:
→ Input: validated-research.json
→ Outputs: complete-research-package.json
```

**Key Success Factors:**
- Each stage uses **direct sub-agent invocation**
- Clear **input/output specifications**
- **MCP tool inheritance** ensures real execution
- **Sequential coordination** by main chat orchestrator

## Validation Checklist

Before modifying any agent or command file:

- [ ] **Architecture Review:** Does this use correct sub-agent invocation patterns?
- [ ] **Tool Inheritance:** Are agents configured to inherit MCP tools?
- [ ] **Pattern Compliance:** No Task tool delegation for agent workflows?
- [ ] **Explicit Invocation:** Clear "Use the [agent-name] agent to..." syntax?
- [ ] **MCP Integration:** Will this result in >0 tool uses for MCP operations?
- [ ] **Documentation Update:** Are changes reflected in this source of truth?

## Version History

- **v1.0 (2025-08-26):** Initial architecture documentation based on comprehensive research
- **Research Base:** 20+ Perplexity searches, 10+ WebSearch validations, official docs analysis
- **Validation:** Empirical testing confirmed Task tool causes simulation (0 tools) vs direct invocation (>0 tools)

---

**This document is the authoritative source for Claude Code sub-agent architecture in this project. All agent modifications must comply with these patterns.**
