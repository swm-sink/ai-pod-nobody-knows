# MCP Tool Inheritance - Technical Guide

**Date Created:** 2025-08-26
**Research Basis:** Official Anthropic docs + empirical testing
**Status:** Technical reference for MCP integration

## MCP Tool Inheritance in Claude Code Sub-Agents

**Technical:** MCP (Multi-Component Plugin) tools are inherited by Claude Code sub-agents based on YAML frontmatter configuration, with default inheritance behavior providing full toolset access when tools field is omitted, enabling seamless integration with external services like Perplexity and ElevenLabs.

**Simple:** Like giving each specialist access to the same toolbox - they can use all the research tools, audio tools, and other capabilities unless you specifically restrict them.

**Connection:** This teaches MCP server integration, permission modeling, and tool accessibility patterns essential for multi-agent system design.

## Default Inheritance Behavior

### Full Inheritance (RECOMMENDED)
```yaml
---
name: research-discovery
description: Strategic research discovery specialist
# tools: # OMITTED - Inherits ALL MCP tools
---
```

**Result:**
- ✅ Access to ALL MCP servers (Perplexity, ElevenLabs, GitHub, etc.)
- ✅ Access to ALL internal Claude Code tools
- ✅ Seamless tool usage without configuration overhead
- ✅ Real tool execution with >0 usage counts

### Restricted Inheritance
```yaml
---
name: file-analyzer
description: File analysis specialist
tools: Read, Write, Grep, Glob
---
```

**Result:**
- ✅ Access ONLY to specified tools
- ❌ No MCP server access unless explicitly listed
- ⚠️ Requires manual maintenance as MCP servers change

## MCP Server Integration

### Available MCP Servers in This Project
Based on `.mcp.json` configuration and research findings:

#### Research & Knowledge
- **Perplexity MCP:** `mcp__perplexity-ask__perplexity_ask`
  - Real-time research with citations
  - Expert knowledge synthesis
  - Current event analysis

#### Audio Production
- **ElevenLabs MCP:** Multiple tools
  - `mcp__elevenlabs__text_to_speech` - Audio synthesis
  - `mcp__elevenlabs__check_subscription` - Quota monitoring
  - `mcp__elevenlabs__list_models` - Model selection
  - `mcp__elevenlabs__speech_to_text` - Audio validation

#### Development
- **GitHub MCP:** Repository management
- **Playwright MCP:** Web automation and testing

### Tool Naming Convention
MCP tools follow the pattern: `mcp__[server-name]__[tool-name]`

Examples:
- `mcp__perplexity-ask__perplexity_ask`
- `mcp__elevenlabs__text_to_speech`
- `mcp__github-local__create_pull_request`

## Configuration Patterns

### Pattern 1: Full MCP Access (Default)
```yaml
---
name: research-deep-dive
description: Comprehensive research specialist using Perplexity and WebSearch
# No tools field - inherits everything
---
```

**Use Cases:**
- Research agents needing Perplexity access
- Audio production agents needing ElevenLabs
- General-purpose agents requiring flexibility

### Pattern 2: MCP + Core Tools Only
```yaml
---
name: audio-specialist
description: Audio production specialist
tools: mcp__elevenlabs__text_to_speech, mcp__elevenlabs__check_subscription, Write, Read
---
```

**Use Cases:**
- Security-sensitive agents
- Specialized workflows with specific tool needs
- Cost optimization for high-volume agents

### Pattern 3: Core Tools Only (No MCP)
```yaml
---
name: file-processor
description: File processing specialist
tools: Read, Write, Edit, Grep, Glob
---
```

**Use Cases:**
- File-only operations
- Security-restricted environments
- Offline-capable workflows

## Task Tool vs Sub-Agent MCP Access

### Sub-Agents (Real MCP Inheritance)
```markdown
Use the research-discovery agent to investigate memory formation:
- Agent inherits full MCP toolset
- Real Perplexity queries executed
- Results in >0 tool uses
- Authentic research synthesis
```

**Technical Details:**
- Sub-agents operate in isolated contexts with real MCP connections
- Tool inheritance happens at agent initialization
- MCP calls are made directly by the sub-agent instance

### Task Tool (Limited/Simulated MCP Access)
```markdown
# PROBLEMATIC PATTERN
Use Task tool to delegate to research agent:
- Task creates lightweight temporary instance
- MCP tools may be simulated or blocked
- Results in 0 tool uses
- Synthetic research synthesis
```

**Technical Limitations:**
- Task instances have restricted MCP integration
- May create simulation contexts instead of real connections
- Tool inheritance is unreliable for MCP servers

## Debugging MCP Tool Access

### Verification Steps

1. **Check Agent Configuration**
```bash
# Verify agent has no tools restriction
grep -A5 "tools:" .claude/agents/[agent-name].md
# Should show no tools field for full inheritance
```

2. **Test MCP Connection**
```bash
# Launch Claude Code with MCP debugging
claude code --mcp-debug
```

3. **Validate Tool Usage**
- Direct invocation should show >0 tool uses
- Task delegation may show 0 tool uses (simulation)
- Check agent execution logs for actual MCP calls

### Common Issues & Solutions

#### Issue: "Sub-agent can't access Perplexity"
**Solution:**
```yaml
# Remove tools restriction
---
name: research-agent
description: Research specialist
# tools: Read, Write  # REMOVE THIS LINE
---
```

#### Issue: "MCP tools not found"
**Solutions:**
1. Verify `.mcp.json` configuration
2. Check MCP server is running: `claude mcp`
3. Restart Claude Code with MCP servers active
4. Use `--mcp-debug` flag for diagnostics

#### Issue: "Task tool shows 0 tool uses with MCP"
**Solution:**
```markdown
# INSTEAD OF:
Use Task tool to delegate to research agent

# USE:
Use the research-discovery agent to investigate [topic]
```

## Best Practices

### Security & Performance
1. **Use full inheritance by default** - simplifies maintenance
2. **Restrict only when necessary** - for security or performance reasons
3. **Document tool restrictions** - explain why specific tools are limited
4. **Test MCP access regularly** - verify agents can reach external services

### Configuration Management
1. **Omit tools field** for maximum flexibility
2. **Use explicit lists** only for restricted agents
3. **Keep MCP tool names updated** as servers evolve
4. **Version control MCP configurations** in `.mcp.json`

### Development Workflow
1. **Start with full inheritance** during development
2. **Restrict incrementally** if needed for security
3. **Test both patterns** (full vs restricted) in your workflows
4. **Monitor tool usage** to verify real vs simulated execution

## MCP Server Status Monitoring

### Health Check Commands
```bash
# Check MCP server status
claude mcp list

# Test specific server
claude mcp test [server-name]

# Debug MCP connectivity
claude code --mcp-debug
```

### Tool Usage Verification
```markdown
# Expected for working MCP integration:
⏺ research-discovery(Research memory formation)
  ⎿  Done (3 tool uses · 8.2k tokens · 1m 30s)

# Problem indicator - likely simulation:
⏺ research-discovery(Research memory formation)
  ⎿  Done (0 tool uses · 5.1k tokens · 45s)
```

## Integration Examples

### Research Agent with Perplexity
```yaml
---
name: research-deep-dive
description: Use for comprehensive multi-round research requiring Perplexity queries and WebSearch validation
---

You are a research specialist with access to:
- mcp__perplexity-ask__perplexity_ask for expert research
- WebSearch for cross-validation
- Write/Read for result persistence

Always use Perplexity for authoritative source research...
```

### Audio Agent with ElevenLabs
```yaml
---
name: audio-synthesizer-direct-api
description: Professional audio synthesis using ElevenLabs direct API integration
---

You are an audio production specialist with access to:
- mcp__elevenlabs__text_to_speech for synthesis
- mcp__elevenlabs__check_subscription for quota management
- mcp__elevenlabs__list_models for model selection

Always verify quota before synthesis...
```

## Migration Guide

### From Task Tool to Sub-Agent MCP Integration

**Step 1:** Identify Task delegation patterns
```bash
grep -r "Use Task tool" .claude/commands/
```

**Step 2:** Convert to direct sub-agent invocation
```markdown
# BEFORE:
Use Task tool to delegate to research-discovery agent:
- Topic: $ARGUMENTS
- Output: discovery.json

# AFTER:
Use the research-discovery agent to investigate: "$ARGUMENTS"

Requirements:
- Use Perplexity MCP for expert research
- Create discovery.json with findings
- Focus on intellectual humility
```

**Step 3:** Verify MCP tool inheritance
- Remove `tools:` field from agent YAML
- Test with real execution
- Confirm >0 tool uses

**Step 4:** Update documentation
- Reference this guide in command files
- Add MCP requirements to agent descriptions
- Document expected tool usage patterns

## Version Compatibility

### Claude Code Versions
- **v1.0.64+:** Model selection for sub-agents
- **v1.0+:** Full MCP server integration
- **v0.x:** Limited MCP support

### MCP Server Compatibility
- **Perplexity:** Full integration tested
- **ElevenLabs:** Production ready
- **GitHub:** Comprehensive API access
- **Playwright:** Web automation support

---

**This document provides technical guidance for MCP tool inheritance. For architectural patterns, see `sub-agent-architecture.md`.**
