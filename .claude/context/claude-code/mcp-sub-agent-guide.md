# MCP Sub-Agent Integration Guide

**Technical:** Comprehensive guide for configuring Model Context Protocol (MCP) tool access in Claude Code sub-agents, enabling seamless integration of external services like Perplexity, ElevenLabs, and WebSearch within Task delegation workflows.

**Simple:** Like giving your specialized team members access to all the same research tools and external services you have - they can do their jobs independently without asking you to look things up.

**Connection:** This teaches advanced AI orchestration patterns, external service integration, and distributed agent architecture essential for scalable AI systems.

## Quick Reference

### ✅ Sub-Agents CAN Access MCP Tools
**Official Anthropic Documentation:** *"When the tools field is omitted, subagents inherit all MCP tools available to the main thread."*

### ✅ Correct Agent Configuration
```yaml
---
name: research-agent
description: Specialized research agent using MCP tools
# tools: # OMIT this field to inherit ALL MCP tools
model: claude-opus-4-1-20250805
---
```

### ✅ Available MCP Tools (Auto-Inherited)
- `mcp__perplexity-ask__perplexity_ask` - Web search and AI research
- `mcp__ElevenLabs__text_to_speech` - Audio synthesis
- `mcp__ElevenLabs__speech_to_text` - Audio transcription
- `WebSearch` - Direct web search functionality

## Configuration Patterns

### Pattern 1: Full Tool Inheritance (Recommended)
```yaml
---
name: comprehensive-agent
description: Agent with access to all available tools
# tools field omitted = inherits ALL MCP tools
model: claude-opus-4-1-20250805
---
```

### Pattern 2: Selective Tool Access
```yaml
---
name: research-only-agent
description: Agent limited to research tools only
tools: ["mcp__perplexity-ask__perplexity_ask", "WebSearch", "Read", "Write"]
model: claude-opus-4-1-20250805
---
```

### Pattern 3: Specialized Tool Access
```yaml
---
name: audio-agent
description: Agent specialized for audio processing
tools: ["mcp__ElevenLabs__text_to_speech", "mcp__ElevenLabs__speech_to_text", "Read", "Write"]
model: claude-opus-4-1-20250805
---
```

## MCP Server Configuration

### Current Working Setup
Our MCP servers are correctly configured in `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "perplexity-ask": {
      "command": "npx",
      "args": ["-y", "server-perplexity-ask"],
      "env": {
        "PERPLEXITY_API_KEY": "pplx-xxx"
      }
    },
    "ElevenLabs": {
      "command": "/Library/Frameworks/Python.framework/Versions/3.13/bin/python3",
      "args": ["/path/to/elevenlabs_mcp/server.py"],
      "env": {
        "ELEVENLABS_API_KEY // pragma: allowlist secret": "sk_xxx"
      }
    }
  }
}
```

## Usage Examples

### Research Workflow with Sub-Agents
```markdown
Use the Task tool to delegate research to specialized sub-agents:

1. **Question Generation**: Sub-agent generates research questions using MCP tools
2. **Deep Research**: Sub-agent conducts Perplexity searches with current date context
3. **Synthesis**: Sub-agent compiles findings using web search validation
4. **Quality Check**: Sub-agent cross-references sources for accuracy
```

### Task Delegation Command
```
Use the research-agent to investigate [TOPIC] using comprehensive web research and AI analysis.
```

The sub-agent will automatically have access to:
- Perplexity API for deep research
- WebSearch for source validation
- ElevenLabs for any audio processing needs
- Standard file operations (Read, Write, etc.)

## Troubleshooting

### Issue: Sub-Agent Can't Access MCP Tools
**Solution:** Verify agent configuration has:
1. Tools field omitted (for full inheritance) OR
2. Correct MCP tool names in tools array
3. Correct model identifier: `claude-opus-4-1-20250805`

### Issue: MCP Server Connection Problems
**Solution:**
1. Check `/mcp` command output in Claude Code
2. Restart Claude Code after configuration changes
3. Verify API keys in environment variables
4. Check MCP server logs for errors

### Issue: Task Delegation Fails
**Solution:**
1. Verify agent YAML syntax is correct
2. Check model inheritance (known issue #5456)
3. Test with simplified agent configuration first

## Best Practices

### 1. Tool Inheritance Strategy
- **Omit tools field** for maximum flexibility
- **Specify tools** only when security/focus requires limitation
- **Use consistent YAML array syntax** when specifying tools

### 2. Model Configuration
- **Standardize on `claude-opus-4-1-20250805`** for consistency
- **Monitor for model inheritance bugs** in Task delegation
- **Test agent configurations** before production use

### 3. Error Handling
- **Monitor MCP server logs** for connection issues
- **Test MCP functionality** in main chat before delegation
- **Have fallback strategies** for when MCP tools are unavailable

### 4. Performance Optimization
- **Use specialized agents** for focused tasks
- **Leverage parallel processing** with multiple sub-agents
- **Cache research results** to minimize API calls

## Common Patterns

### Research-First Workflow
1. Generate research questions with question-generator-agent
2. Conduct deep research with research-agent
3. Synthesize findings with synthesis-agent
4. Validate quality with quality-agent

### Content Production Pipeline
1. Research with MCP tools for current information
2. Generate content with research context
3. Optimize for specific formats (audio, text, etc.)
4. Validate and refine output

### Multi-Source Validation
1. Primary research with Perplexity API
2. Cross-validation with WebSearch
3. Source verification with multiple agents
4. Consensus building across findings

## Integration with Existing Workflows

This MCP sub-agent integration enhances our existing podcast production system:
- **Research Phase**: Sub-agents use MCP tools for comprehensive topic investigation
- **Script Development**: Agents access current information via web search
- **Audio Production**: Agents use ElevenLabs tools for TTS optimization
- **Quality Assurance**: Agents validate content using external sources

For more details, see @context/claude-code/CLAUDE_CODE_MCP_RESEARCH_FINDINGS.md
