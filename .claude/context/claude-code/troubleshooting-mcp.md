# MCP Troubleshooting Guide

**Technical:** Systematic diagnostic and resolution procedures for Model Context Protocol (MCP) integration issues in Claude Code, covering server connectivity, tool registration failures, and sub-agent delegation problems.

**Simple:** Like a repair manual for when your AI tools stop working - step-by-step fixes for the most common problems.

**Connection:** This teaches systematic troubleshooting, diagnostic procedures, and issue resolution methodologies essential for maintaining complex AI systems.

## Quick Diagnostics

### Step 1: Check MCP Server Status
```bash
# In Claude Code, run:
/mcp
```

**Expected Output:**
```
⎿ MCP Server Status ⎿
⎿ • perplexity-ask: connected ⎿
⎿ • ElevenLabs: connected ⎿
```

### Step 2: Test Direct MCP Access
Try using MCP tools directly in main chat:
- `Use Perplexity to search for current AI developments`
- `Use ElevenLabs to convert text to speech`

### Step 3: Check Agent Configuration
Verify YAML syntax in agent files:
```yaml
---
name: agent-name
description: Description
# tools: # Omitted = inherits all MCP tools
model: claude-opus-4-1-20250805
---
```

## Common Issues & Solutions

### Issue 1: "MCP Tools Not Available"

**Symptoms:**
- Sub-agents report no access to MCP tools
- Task delegation works but tools missing
- Direct MCP access works in main chat

**Diagnosis:**
1. Check agent YAML configuration
2. Verify tools field is omitted or contains correct MCP tool names
3. Check model identifier consistency

**Solution:**
```yaml
# Fix YAML syntax - either omit tools or use array format
---
name: research-agent
description: Research agent with MCP access
# Option 1: Omit tools (recommended)
model: claude-opus-4-1-20250805

# Option 2: Explicit tools array
tools: ["mcp__perplexity-ask__perplexity_ask", "WebSearch", "Read", "Write"]
---
```

### Issue 2: "Parameter Packaging Errors"

**Symptoms:**
- Error: `"expected": "object", "received": "undefined"`
- MCP servers connect but tools fail on invocation
- Tools work once then fail on subsequent calls

**Root Cause:** Known regression (GitHub Issue #4188) affecting parameter serialization

**Solution:**
1. Update Claude Code to latest version
2. Restart Claude Code completely
3. Clear Claude Code cache if available
4. Monitor Anthropic GitHub for patch status

### Issue 3: "Tool Registration Failure"

**Symptoms:**
- MCP servers show as "connected"
- Tools not visible in conversation interface
- `/mcp` shows connected but tools unavailable

**Solution:**
1. **Restart Sequence:**
   ```bash
   # 1. Quit Claude Code completely
   # 2. Restart Claude Code
   # 3. Check /mcp status
   ```

2. **Configuration Validation:**
   ```bash
   # Check config file syntax
   cat ~/.claude.json | jq .  # Validate JSON
   ```

3. **Server Log Review:**
   - Check MCP server logs for errors
   - Look for connection or authentication issues

### Issue 4: "Sub-Agent Model Inheritance Bug"

**Symptoms:**
- Sub-agents default to Claude Sonnet 4
- Parent uses Opus 4.1 but sub-agents don't inherit
- Inconsistent model behavior between main and sub-agents

**Root Cause:** Known bug (GitHub Issue #5456)

**Workaround:**
```yaml
# Explicitly specify model in each agent
---
name: agent-name
description: Agent description
model: claude-opus-4-1-20250805  # Force correct model
---
```

### Issue 5: "Configuration File Conflicts"

**Symptoms:**
- MCP tools work in Claude Desktop but not Claude Code
- Tools visible but produce API errors
- Inconsistent tool availability

**Solution:**
1. **Check Configuration Locations:**
   - Claude Desktop: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - Claude Code: `~/.claude.json` or `.claude/settings.json`

2. **Verify Configuration Consistency:**
   ```json
   // Ensure MCP server names match between files
   {
     "mcpServers": {
       "perplexity-ask": {  // Consistent naming
         "command": "npx",
         "args": ["-y", "server-perplexity-ask"]
       }
     }
   }
   ```

## Advanced Troubleshooting

### Debug Mode Activation
```bash
# Start Claude Code with debug logging
claude --mcp-debug
```

### Environment Validation
```bash
# Check Node.js environment (common issue)
node --version
npm --version

# Check MCP server installation
npx server-perplexity-ask --help
```

### Manual Server Testing
```bash
# Test MCP server directly
echo '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","clientInfo":{"name":"test","version":"1.0.0"},"capabilities":{}},"id":1}' | npx server-perplexity-ask
```

### Configuration Backup & Restore
```bash
# Backup current configuration
cp ~/.claude.json ~/.claude.json.backup

# Restore from backup
cp ~/.claude.json.backup ~/.claude.json
```

## Known Issues & Status

### Active GitHub Issues
- **#4188**: MCP parameter packaging regression (July 2025)
- **#2682**: Tools not available despite connection
- **#3426**: Claude Code fails to expose MCP tools
- **#5456**: Sub-agents don't inherit model configuration

### Environment-Specific Issues
- **Windows/WSL2**: Higher incidence of permission inheritance problems
- **Node.js Conflicts**: Multiple Node versions can cause MCP server failures
- **API Key Issues**: Environment variable loading problems

## Escalation Procedures

### When to Escalate
1. **Configuration is correct** but tools still unavailable
2. **Known workarounds fail** to resolve the issue
3. **System-wide MCP failure** affecting all tools
4. **Data loss or corruption** in configurations

### Escalation Steps
1. **Document Issue:** Collect logs, configuration files, error messages
2. **Search GitHub:** Check for existing issues and solutions
3. **Community Resources:** Check Anthropic Discord, Claude Code forums
4. **Create Issue:** File detailed bug report with reproduction steps

### Emergency Fallbacks
1. **Main Chat Research:** Use MCP tools directly without delegation
2. **Configuration Rollback:** Restore known-working configurations
3. **Alternative Tools:** Use built-in Claude Code tools as backup
4. **Manual Process:** Fall back to manual research if needed

## Maintenance Best Practices

### Regular Health Checks
1. **Weekly**: Test MCP server connectivity with `/mcp`
2. **After Updates**: Verify tool functionality after Claude Code updates
3. **Configuration Changes**: Test immediately after any config modifications

### Preventive Measures
1. **Backup Configurations** before making changes
2. **Version Control** important configuration files
3. **Monitor GitHub Issues** for known regressions
4. **Test in Development** before production deployment

### Documentation Updates
- Keep troubleshooting guide current with new issues
- Document successful resolution procedures
- Share solutions with team/community

For additional help, see @context/claude-code/mcp-sub-agent-guide.md or consult the comprehensive research findings at @context/claude-code/CLAUDE_CODE_MCP_RESEARCH_FINDINGS.md.
