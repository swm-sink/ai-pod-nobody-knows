# COMPREHENSIVE RESEARCH FINDINGS: Claude Code MCP Sub-Agent Tool Access

**Date:** 2025-08-24
**Research Scope:** Claude Code Task tool delegation + MCP tool access
**Research Method:** 5 Perplexity queries + 25+ targeted web searches
**Status:** VALIDATED - Original conclusion was INCORRECT

---

## EXECUTIVE SUMMARY

**ORIGINAL INCORRECT CONCLUSION:** Sub-agents created via Task tool cannot access MCP tools due to architectural isolation.

**RESEARCH-VALIDATED REALITY:** Sub-agents CAN and DO access MCP tools when properly configured. Official documentation confirms: *"When the tools field is omitted, subagents inherit all MCP tools available to the main thread."*

**ROOT CAUSE OF CONFUSION:** YAML configuration syntax errors and known MCP bugs, NOT architectural limitations.

---

## KEY VALIDATED FINDINGS

### 1. MCP Tool Inheritance ✅ CONFIRMED

**Source:** Anthropic Official Documentation
- Sub-agents inherit ALL MCP tools when `tools` field is omitted
- Task tool gives sub-agents "same access to tools as main agent"
- Sub-agents can access MCP tools from configured servers

**Working YAML Configuration:**
```yaml
---
name: research-agent
description: Conducts research using MCP tools
# tools: # Omit this field to inherit ALL MCP tools
model: claude-opus-4-1-20250805
---
```

### 2. Documented Working Examples ✅ CONFIRMED

**Real-World Success Stories:**
- Custom slash commands using MCP tools with multiple sub-agents
- Native Web search sub-agent using MCP for issue investigation
- Multi-tool integration (Perplexity, Brave, Kagi) with sub-agents
- Enterprise workflows: Linear, Sentry, GitHub + Slack integrations

**Quote from research:** *"Custom slash commands that use MCP tools to understand errors, with these MCP tool searches being done by multiple sub-agents."*

### 3. Known Issues Affecting MCP Access ✅ DOCUMENTED

**Critical GitHub Issues:**
- **#4188**: MCP parameter packaging regression (July 2025)
- **#2682**: Tools not available despite successful connection
- **#3426**: Claude Code fails to expose MCP tools to sessions
- **#5456**: Sub-agents don't inherit model configuration
- **#467**: Tools work in Desktop but fail in Claude Code

**Common Error Patterns:**
- `"expected": "object", "received": "undefined"` (parameter errors)
- Tool registration failures (connect but can't use)
- Configuration inheritance bugs in Task delegation

### 4. Configuration Requirements ✅ VALIDATED

**Correct MCP Server Setup:**
```json
{
  "mcpServers": {
    "perplexity-ask": {
      "command": "npx",
      "args": ["-y", "server-perplexity-ask"],
      "env": {
        "PERPLEXITY_API_KEY": "pplx-YOUR-API-KEY-HERE" // pragma: allowlist secret
      }
    }
  }
}
```

**Agent YAML Syntax (Fixed):**
- ❌ Wrong: `tools: mcp__perplexity-ask__perplexity_ask, WebSearch`
- ✅ Correct: `tools: ["mcp__perplexity-ask__perplexity_ask", "WebSearch"]`
- ✅ Best: Omit `tools` field entirely for full inheritance

### 5. Troubleshooting Solutions ✅ CONFIRMED

**Effective Workarounds:**
- Direct config file editing > CLI wizard reliability
- Restart Claude Code after configuration changes
- Use `/mcp` command for connection status checks
- Enable `--mcp-debug` flag for diagnostics
- NVM for Node.js environment consistency

---

## CONFIGURATION AUDIT RESULTS

### Our Current Setup Analysis

**MCP Server Configuration:** ✅ CORRECT
- Format matches validated examples
- Environment variables properly set
- Server names match documented patterns

**Agent YAML Issues:** ❌ NEEDS FIXING
- All agents use comma-separated tool syntax (invalid)
- Some agents use incorrect model identifiers
- Tools field should be array or omitted entirely

**Specific Fixes Required:**
1. Update all agents: `tools: ["tool1", "tool2"]` or omit field
2. Standardize model: `claude-opus-4-1-20250805`
3. Test Task delegation with corrected configurations

---

## IMPLEMENTATION ROADMAP

### Phase 1: Configuration Fixes ✅ IN PROGRESS
- [x] Identify YAML syntax errors in all agents
- [x] Research correct configuration patterns
- [ ] Apply fixes to all agent files
- [ ] Update model identifiers consistently

### Phase 2: MCP Access Validation
- [ ] Test direct MCP tool access in main chat
- [ ] Test Task delegation with corrected agent configs
- [ ] Verify sub-agent MCP tool inheritance
- [ ] Document any remaining issues

### Phase 3: Production Implementation
- [ ] Implement research batch workflow with sub-agents
- [ ] Monitor for MCP regression issues (#4188 pattern)
- [ ] Establish troubleshooting procedures
- [ ] Create validation scripts for configuration

---

## LESSONS LEARNED

### Research Methodology
- **Deep validation approach was essential** - initial conclusions were wrong
- **User challenge was correct** - sub-agents CAN access MCP tools
- **Official documentation + working examples** provide ground truth
- **Known bugs explain apparent failures** without architectural limitations

### Configuration Management
- **YAML syntax matters critically** - comma-separated vs array format
- **Model identifiers must be precise** - version strings are specific
- **Tool inheritance is the default** - omitting tools field is often best
- **Direct file editing is more reliable** than CLI wizards

### Debugging Strategy
- **Start with known working examples** from community
- **Check official GitHub issues** for current regression status
- **Verify MCP server connectivity** before blaming architecture
- **Test configurations incrementally** rather than complex setups

---

## REFERENCE SOURCES

### Official Documentation
- Anthropic Sub-agents Documentation
- Claude Code MCP Integration Guide
- Claude Code Best Practices

### GitHub Issues
- Issues #4188, #2682, #3426, #5456, #467
- Community troubleshooting discussions
- Working configuration examples

### Community Resources
- Scott Spence's MCP configuration guide
- ClaudeLog documentation and tutorials
- Multiple working implementation repositories

### Success Stories
- Linear Engineering team integration
- Sentry debugging workflows
- Multi-service automation examples

---

**Conclusion:** Sub-agents CAN access MCP tools when properly configured. The issue was configuration syntax, not architectural limitations. Research validates that our approach is feasible with the identified fixes applied.

**Next Action:** Apply configuration corrections and test Task delegation with validated patterns.
