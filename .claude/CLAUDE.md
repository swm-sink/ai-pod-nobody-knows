# ⚙️ Claude Code Configuration Domain
<!-- Domain Context | Token Budget: 4K | Purpose: System Configuration & Tools -->

## 🎯 CONFIGURATION OVERVIEW

**Purpose:** Central configuration management for Claude Code native patterns, MCP server integration, and system-wide settings.

**Configuration Philosophy:**
- Native Claude Code patterns over custom solutions
- MCP tools for reliability and simplicity
- Hierarchical settings with clear inheritance
- Performance optimization through selective loading

## 🔌 MCP SERVER CONFIGURATION

### Active MCP Servers
```yaml
perplexity-ask:
  status: "✅ Connected"
  purpose: "Research and fact-checking"
  authentication: "User-level (no API key in code)"
  tools:
    - mcp__perplexity-ask__perplexity_ask
  
elevenlabs:
  status: "✅ Connected"
  purpose: "Voice synthesis and validation"
  authentication: "User-level (no API key in code)"
  tools:
    - mcp__elevenlabs__text_to_speech
    - mcp__elevenlabs__speech_to_text
    - mcp__elevenlabs__search_voices
```

### MCP Integration Benefits
- No API key management in code
- Built-in error handling and retries
- Automatic rate limiting
- Native Claude Code integration
- Simplified authentication

## 🎤 VOICE CONFIGURATION

### Production Voice Settings
```json
{
  "voice_id": "ZF6FPAbjXT4488VcRRnw",
  "voice_name": "Amelia",
  "model": "eleven_turbo_v2_5",
  "settings": {
    "stability": 0.65,
    "similarity_boost": 0.8,
    "style": 0.3,
    "use_speaker_boost": true
  },
  "performance": {
    "processing_rate": "206 WPM",
    "cost_per_episode": "$2.77",
    "word_accuracy": "94.89%",
    "quality_score": "92.1/100"
  }
}
```

**⚠️ CRITICAL:** Voice ID is production-locked. Changes require explicit user permission.

## 🪝 HOOKS SYSTEM

### Active Hooks
```yaml
hooks_directory: ".claude/hooks/"
active_hooks:
  - pre-tool-cost-validation.sh
  - post-tool-cost-tracking.sh
  - mcp-reliability-monitor.sh
  - config-protection-system.sh
  - session-cleanup.sh
  - error-recovery-handler.sh
```

### Hook Events
- **pre-tool-use:** Validate before expensive operations
- **post-tool-use:** Track costs and metrics
- **pre-commit:** Enforce quality standards
- **error:** Automatic recovery procedures
- **session-end:** Cleanup and state preservation

## 📝 SETTINGS HIERARCHY

### Global Settings
**Location:** `.claude/settings.json`
```json
{
  "version": "4.0.0",
  "model": "claude-3-opus",
  "temperature": 0.7,
  "max_tokens": 4096,
  "hooks_enabled": true,
  "mcp_servers": ["perplexity-ask", "elevenlabs"]
}
```

### Local Overrides
**Location:** `.claude/settings.local.json`
```json
{
  "debug": true,
  "cost_tracking": true,
  "quality_gates": true,
  "test_mode": false
}
```

## 🗂️ CONTEXT ORGANIZATION

### Context Files
```yaml
operational_contexts:
  claude-code.md: "Agent orchestration patterns"
  perplexity.md: "Research methodology"
  elevenlabs.md: "Voice synthesis optimization"

domain_contexts:
  agents/: "10 specialized agent definitions"
  commands/: "5 workflow commands"
  config/: "Voice and MCP settings"
```

### Context Loading Strategy
- **Selective:** Load only relevant contexts
- **Hierarchical:** Root → Domain → Task
- **Cached:** Frequently used contexts retained
- **Pruned:** Automatic cleanup of stale context

## 🔒 CONFIGURATION PROTECTION

### Protected Files
```yaml
protected_configs:
  - .claude/config/production-voice.json
  - .claude/settings.json
  - nobody-knows/content/config/project_config.json
  - nobody-knows/content/config/quality_gates.json
```

### Change Control
- Voice ID changes blocked without permission
- Quality thresholds require validation
- MCP server changes need testing
- Cost limits enforced automatically

## 📊 QUALITY GATES

### Code Quality
```yaml
test_coverage: "≥80%"
complexity_limit: 10
duplication_threshold: 5%
linting: "strict"
```

### Episode Quality
```yaml
brand_consistency: "≥90%"
technical_accuracy: "≥85%"
engagement_score: "≥80%"
audio_quality: "≥85%"
consensus_required: "≥85%"
```

## 🛠️ UTILITY SCRIPTS

### Validation Scripts
```bash
# Test MCP connections
./test-mcp-connections.sh

# Validate configuration
./validate-config.sh

# Setup MCP servers
./setup-mcp.sh
```

### Production Scripts
```bash
# Cost tracking
.claude/hooks/post-tool-cost-tracking.sh

# Session management
nobody-knows/production/state_manager.py

# Batch processing
nobody-knows/production/cost_tracking_functions.sh
```

## 🔍 DEBUGGING & LOGS

### Log Locations
```yaml
claude_logs: ".claude/logs/"
production_logs: "nobody-knows/production/logs/"
mcp_logs: "~/.claude/mcp/logs/"
```

### Debug Commands
```bash
# Check MCP status
claude mcp list

# View recent logs
tail -f .claude/logs/session.log

# Debug state
python nobody-knows/production/state_manager.py --debug
```

## 🚀 CONFIGURATION COMMANDS

### MCP Management
```bash
# List MCP servers
claude mcp list

# Test specific MCP
claude mcp test perplexity-ask

# Reload MCP configuration
claude mcp reload
```

### Settings Management
```bash
# View current settings
cat .claude/settings.json

# Check local overrides
cat .claude/settings.local.json

# Validate all configs
./validate-config.sh
```

## 🔗 CROSS-REFERENCES

### Related Contexts
- **Agents:** @.claude/agents/CLAUDE.md
- **Commands:** @.claude/commands/CLAUDE.md
- **Production:** @nobody-knows/CLAUDE.md
- **Content:** @nobody-knows/content/CLAUDE.md

### Key Files
- Voice Config: `.claude/config/production-voice.json`
- Project Config: `nobody-knows/content/config/project_config.json`
- Quality Gates: `nobody-knows/content/config/quality_gates.json`
- State Manager: `nobody-knows/production/state_manager.py`

---

*Configuration Domain Context v1.0 | Token Usage: ~3.9K*  
*Central hub for system configuration and tool management*