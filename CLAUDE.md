# CLAUDE.md - AI Podcast Production Master System 🎓

<!-- markdownlint-disable-file -->

## 🎯 MANDATORY SIMPLICITY ENFORCEMENT

**PROHIBIT OVERCOMPLICATED SOLUTIONS - ENFORCE MINIMUM VIABLE COMPLEXITY**

**Teaching Format:**
- **Technical:** Professional explanation with industry terminology
- **Simple:** "Think of it like..." analogy-based explanation
- **Connection:** "This helps you learn..." learning value and transferable skills

**Brutal Enforcement Rules:**
- IF solution has more than 3 moving parts → REJECTED
- IF solution requires new infrastructure → REJECTED, use existing tools
- IF solution cannot be explained in 2 sentences → REJECTED
- IF solution creates new abstractions → REJECTED, use Claude Code native patterns

## 🔒 CRITICAL PRODUCTION CONFIGURATION GOVERNANCE

**VOICE ID CHANGES REQUIRE EXPLICIT USER PERMISSION - NO EXCEPTIONS**

**CURRENT PRODUCTION VOICE:** ZF6FPAbjXT4488VcRRnw (Amelia - Episode 1 validated)

**Central Configuration:**
- `.claude/config/production-voice.json` - Single source of truth
- Environment variable: PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
- All scripts reference central config, never hardcode

**Violation Consequences:**
- ANY unauthorized voice ID change immediately stops all work
- All work with wrong voice ID is invalidated
- Must restore correct voice ID before continuing

## 🚀 QUICK START NAVIGATION

**First Time?** → `@context/01_project_overview.md` → Follow WALK phase
**Welcome Back!** → Check current phase → `@context/02_quick_reference.md`
**Need Help?** → `@context/01_troubleshooting_guide.md`

## 📚 MODULAR DOCUMENTATION ARCHITECTURE

**Entry Point:** This file (CLAUDE.md) - high-level overview and navigation hub
**Domain Files:** Focused documents for specific concerns
**Context Loading:** Use `@` references to load specific content on-demand

**Navigation Strategy:**
- `@.claude/protocols/enforcement.md` - All brutal enforcement protocols
- `@.claude/protocols/validation.md` - 50-step validation and quality gates
- `@.claude/architecture/native-patterns.md` - Claude Code native architecture
- `@.claude/workflows/meta-prompting.md` - 10-step protocol details
- `@.claude/systems/hooks-documentation.md` - Hooks system comprehensive guide

## 📍 CURRENT STATUS

**Phase:** WALK
**Focus:** Learn for FREE - No API keys needed!
**Cost:** $0
**Next:** `@context/02_walk_crawl_run_phases.md`

## 🔧 ESSENTIAL COMMANDS

**Context Management:**
- `/init` - Initialize project memory
- `/clear` - Clear conversation (use frequently!)
- `# note` - Quick memory addition

**Thinking Modes:**
- `think` - Basic reasoning
- `think hard` - Enhanced analysis (recommended)
- `ultrathink` - Maximum thinking (complex problems)

## 🔒 SECURITY CONFIGURATION

**GitHub Integration:**
PAT stored in `.env` file (git-ignored)
Usage: `source .env && git push origin main`

**MCP Environment Setup:**
**CRITICAL:** Variables MUST be loaded before Claude Code startup
```bash
source .env
echo "ELEVENLABS_API_KEY: $([ ! -z "$ELEVENLABS_API_KEY" ] && echo 'SET' || echo 'NOT SET')"
claude code
```

## ⚠️ MANDATORY ENFORCEMENT PROTOCOLS

**All detailed enforcement protocols have been extracted to modular files for performance optimization.**

**Load specific enforcement as needed:**
- `@.claude/protocols/enforcement.md` - Complete enforcement protocols
- `@.claude/protocols/validation.md` - Validation and quality gates

**Core Enforcement Summary:**
- **Anti-Hallucination:** Every claim must be tool-verified or marked UNVERIFIED
- **Change Control:** All modifications require user approval and validation
- **Zero Tolerance:** No bypasses, no exceptions, no assumptions

## 🏗️ NATIVE CLAUDE CODE ARCHITECTURE

**Architecture Details:** `@.claude/architecture/native-patterns.md`

**Core Patterns:**
- Main Chat Orchestrator uses Task tool delegation
- Specialized Sub-Agents (14 enhanced agents in `.claude/agents/`)
- Slash Command Workflows (`.claude/commands/`)
- Hooks Observability for cost tracking and quality assurance

**Research-First Workflow:**
- Research Pipeline: `/research-episode-enhanced` → 3 agents → User checkpoint
- Production Pipeline: `/produce-episode-native` → 5 agents → Final audio

## 🔄 WORKFLOW PROTOCOLS

**Meta-Prompting:** `@.claude/workflows/meta-prompting.md`
**10-Step Sequence:** /explore → /research → /plan → /decompose → /implement-tdd → /assess → /validate → /commit → /retrospect

**Hooks System:** `@.claude/systems/hooks-documentation.md`
**Event-driven automation** for cost tracking, validation, and observability

## 📚 CONTEXT LOADING GUIDE

**Technical:** Context engineering optimizes information architecture for 200K token attention mechanisms using selective loading patterns.

**Simple:** Like organizing your desk so you can find the right tool instantly - only load what you need when you need it.

**Connection:** This teaches efficient AI system management and resource optimization.

**Available Contexts:**
- `@context/` - All guides, troubleshooting, and constants
- `@agents/` - Multi-agent orchestration
- `@commands/` - Production commands and workflows

## 🎯 PROJECT OVERVIEW

**Mission:** Learn AI orchestration by building automated podcast production system
**Philosophy:** Intellectual humility - celebrating what we know AND what we don't
**Cost Achieved:** $5.51 per episode (vs traditional $800-3500)
**Learning Emphasis:** Every step teaches transferable AI orchestration skills

## 🎯 CURRENT PRIORITIES

1. Complete WALK phase activities (FREE)
2. Set up selective context loading system
3. Test with single episode production
4. Maintain $5.51 cost per episode

## 💡 PRO TIPS

- **Start FREE:** Complete all no-API activities first
- **Use /clear frequently:** Prevent context bloat
- **Use @ references:** Load only needed context
- **Track everything:** Document learnings in CLAUDE.local.md
- **Verify always:** No assumptions, test everything

## 🎪 REMEMBER

This is YOUR learning journey - go at YOUR pace!
Context engineering > Prompt engineering in 2025.
Every error teaches something valuable.
Use @ references to load detailed contexts on-demand.

---

**Quick Actions:** `/init` | `/clear` | `@context/02_quick_reference.md` | `@context/01_project_overview.md`

**Version:** 6.0.0 | **Updated:** 2025-08-25 | **Optimized:** Modular Architecture | **Performance:** 67k → 8k chars
