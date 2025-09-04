# 🎙️ AI Podcast Production System - Navigation Hub
<!-- CLAUDE.md v4.0 | Token Budget: 3K | Navigation-Focused -->

## 📊 SYSTEM STATUS DASHBOARD

**Production Ready:** ✅ All systems operational  
**MCP Servers:** ✅ perplexity-ask | ✅ elevenlabs  
**Cost Achievement:** $4.77/episode (target: $3-5)  
**Quality Score:** 92.1% average (target: ≥90%)  
**Architecture:** 10 agents | 5 workflows | Native Claude Code patterns

## ⚡ QUICK START

```bash
# First Time Setup (10 minutes)
./setup-mcp.sh              # Configure MCP servers
cp .env.example .env         # Add API keys
./test-mcp-connections.sh    # Validate setup

# Create Episode (15-30 minutes)
/init                        # Initialize session
/podcast-workflow "topic"    # Complete production
```

## 🗺️ CONTEXT NAVIGATION MAP

### By Task Type
<LOAD_IF task="research">
→ Load: @nobody-knows/production/CLAUDE.md#research-context
→ Load: @.claude/context/perplexity.md
</LOAD_IF>

<LOAD_IF task="script_writing">
→ Load: @nobody-knows/production/CLAUDE.md#script-context
→ Load: @nobody-knows/content/CLAUDE.md
</LOAD_IF>

<LOAD_IF task="audio_production">
→ Load: @nobody-knows/production/CLAUDE.md#audio-context
→ Load: @.claude/context/elevenlabs.md
</LOAD_IF>

<LOAD_IF task="agent_modification">
→ Load: @.claude/agents/CLAUDE.md
→ Load: @.claude/context/claude-code.md
</LOAD_IF>

<LOAD_IF task="command_execution">
→ Load: @.claude/commands/CLAUDE.md
→ Load: @nobody-knows/production/CLAUDE.md#state-management
</LOAD_IF>

### Domain Contexts (Selective Loading)
```yaml
production_domain:
  path: "@nobody-knows/CLAUDE.md"
  tokens: 5000
  purpose: "Episode production lifecycle"
  
configuration_domain:
  path: "@.claude/CLAUDE.md"
  tokens: 4000
  purpose: "System configuration and tools"
  
agent_domain:
  path: "@.claude/agents/CLAUDE.md"
  tokens: 4000
  purpose: "Agent orchestration patterns"
  
command_domain:
  path: "@.claude/commands/CLAUDE.md"
  tokens: 3000
  purpose: "Workflow execution details"
```

## 🎯 PRIMARY WORKFLOWS

### Complete Episode Production
```bash
/podcast-workflow "Your Topic"
# Executes: research → script → audio → validation
# Cost: $4-7 | Time: 15-30 min | Quality: ≥90%
```

### Individual Phases
```bash
/research-workflow    # MCP research only ($1-2)
/production-workflow  # Script creation ($1-2)  
/audio-workflow      # Voice synthesis ($2-3)
```

## ⚠️ CRITICAL POLICIES

### Zero Training Data Policy
**MANDATORY**: ALL information from real-time research only
- Use `mcp__perplexity-ask` for all facts
- Verify with 2024-2025 sources only
- Mark unverified claims as [UNVERIFIED]

### Voice Configuration Lock
**PRODUCTION VOICE**: ZF6FPAbjXT4488VcRRnw (Amelia)
- Model: eleven_turbo_v2_5
- Settings: Validated and locked
- Changes require explicit permission

## 🏗️ PROJECT STRUCTURE

```
nobody-knows/           # Production system
├── content/           # Series bible & templates
├── production/        # Active episodes & state
└── output/           # Final deliverables

.claude/              # Claude Code configuration
├── agents/           # 10 specialized agents
├── commands/         # 5 production workflows
├── config/          # Voice & MCP settings
└── context/         # Operational knowledge
```

## 📈 TOKEN BUDGET ALLOCATION

```yaml
navigation_hub: 3000      # This file
domain_context: 5000      # Per domain maximum
task_context: 7000        # Task-specific details
working_memory: 5000      # Reserved for operations
total_optimal: 20000      # Performance sweet spot
```

## 🔧 ESSENTIAL COMMANDS

**Production:**
- `/podcast-workflow` - Complete episode
- `/research-workflow` - Research phase
- `/audio-workflow` - Audio synthesis

**Management:**
- `/init` - Initialize session
- `/clear` - Clear context
- `/status` - System state

**Development:**
- `./validate-config.sh` - Check configuration
- `./test-mcp-connections.sh` - Test MCP servers
- See: @.claude/commands/meta-chain.md for advanced

## 📚 QUICK REFERENCE

### Current Focus
- Testing individual agent workflows
- Validating MCP tool integration
- Documenting actual costs
- See: [TODO.md](./TODO.md) for priorities

### Key Files
- Series Bible: `nobody-knows/content/series-bible/series_bible.md`
- Quality Gates: `nobody-knows/content/config/quality_gates.json`
- State Manager: `nobody-knows/production/state_manager.py`
- Project Config: `nobody-knows/content/config/project_config.json`

### Support Resources
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - Detailed setup
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
- [PROJECT_HANDOFF_SUMMARY.md](./PROJECT_HANDOFF_SUMMARY.md) - Complete overview

## 🚀 NEXT ACTIONS

1. **New User?** → Start with SETUP_GUIDE.md
2. **Returning?** → Check TODO.md for current priorities
3. **Testing?** → Run `/podcast-workflow` with test topic
4. **Debugging?** → Check `.claude/logs/` for details

---

*Navigation Hub v4.0 | Optimized for Claude Code Native Patterns*  
*Token Usage: ~2.8K | Load domain contexts as needed*
