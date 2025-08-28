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

## 📚 CRITICAL CONTEXT MANAGEMENT GOVERNANCE

**CONTEXT SPRAWL PREVENTION - MAXIMUM 15 FILES ENFORCED**

**Context Management Rules:**
- **Maximum Context Files**: 15 total files in `.claude/context/` directory
- **Single Source Truth**: Each topic covered in exactly ONE context file
- **Usage Documentation**: Every context file must have clear operational purpose
- **Automatic Archival**: Unused files archived after 30 days without access

**Enforcement Mechanisms:**
```yaml
context_governance_enforcement:
  file_limit: "Block new context creation if >15 files exist"
  duplication_detection: "Pre-commit hooks prevent topic overlap"
  usage_tracking: "Monitor file access patterns for archival decisions"
  periodic_audit: "Monthly context directory cleanup and consolidation"
```

**STREAMLINED CONTEXT ARCHITECTURE (15 FILES ACHIEVED):**
```yaml
core_contexts:
  - 01_current_system_status.md (System health and operational status)
  - 02_deployment_instructions.md (Production deployment protocols)
  - project_foundation.md (Mission, philosophy, quality standards, architecture)
  - agent_orchestration_complete.md (Sub-agent patterns, MCP inheritance, orchestration)
  - troubleshooting_unified.md (Complete issue resolution framework)

specialized_contexts:
  - perplexity_integration.md (Complete Perplexity research framework)
  - cost_optimization_unified.md (Complete cost management and optimization)
  - audio_synthesis_unified.md (Complete audio production framework)
  - quality_validation_unified.md (Complete quality assurance system)
  - batch_processing_scalability.md (High-volume production architecture)

workflow_contexts:
  - claude_code_integration.md (MCP integration and sub-agent coordination)
  - 03_meta_prompting_workflow_summary.md (10-step methodology execution)
  - 02_quick_reference.md (Essential commands and navigation)

user_experience:
  - 02_hallucination_prevention_guide.md (Anti-hallucination protocols)
  - 02_walk_crawl_run_phases.md (Learning progression framework)
```

**Context Loading Strategy:**
- **Entry Point:** This CLAUDE.md file - navigation hub only
- **Domain Files:** Maximum 15 focused documents for specific concerns
- **On-Demand Loading:** Use `@` references to load specific content when needed
- **No Duplication:** Violation of single-source principle immediately stops all work

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

## 🚨 ZERO-TOLERANCE DRY ENFORCEMENT - ABSOLUTE PROHIBITION

**CRITICAL SYSTEM INTEGRITY POLICY - NO EXCEPTIONS**

**DUPLICATION IS FORBIDDEN - VIOLATIONS STOP ALL WORK IMMEDIATELY**

**Enforcement Level:** MAXIMUM - Nuclear Option Activated
**Scope:** Entire project - all files, directories, configurations
**Status:** ✅ ACTIVE - Automated pre-commit detection enforcing zero tolerance

### 📋 DUPLICATION REGISTRY STATUS
**Current Crisis Level:** RESOLVED (2025-08-26)
**Files Audited:** 100+ duplicates eliminated
**Cleanup Status:** Phase 1-3 Complete

**Protected Patterns:**
- **Hooks:** Only enhanced-* versions allowed (10 files total)
- **Agents:** Only current production agents (16 files maximum)
- **Sessions:** One active session per episode
- **Documentation:** Single-source with @references only

### 🛡️ BRUTAL ENFORCEMENT MECHANISMS

**Automated Detection:** ✅ ACTIVE
```bash
# Pre-commit hooks scan for duplicates - INSTALLED & ACTIVE
.claude/hooks/duplication-detector.sh detect
# Integrated with .pre-commit-config.yaml
# Blocks ALL commits with duplicates - ZERO tolerance enforced
```

**Manual Validation Required:**
- Before ANY new file creation → Check for existing equivalent
- Before ANY file modification → Ensure single-source principle
- Before ANY commit → Run duplication audit

### ⚙️ APPROVED SINGLE-SOURCE PATTERNS

**Configuration Management:**
- `.claude/config/production-voice.json` (ONLY voice config)
- `.claude/settings.json` (ONLY enhanced hooks)
- `.env` (ONLY environment variables)

**Hook System (12 files maximum):**
- `enhanced-pre-tool-cost-validation.sh` ✅
- `enhanced-post-tool-cost-tracking.sh` ✅
- `mcp-reliability-monitor.sh` ✅
- `baseline-metrics-capture.sh` ✅
- `config-protection-system.sh` ✅
- `automated-billing-reconciliation.sh` ✅
- `realtime-cost-attribution.sh` ✅
- `mcp-diagnostics-validator.sh` ✅
- `shadow-mode-validation.sh` ✅
- `session-cleanup.sh` ✅
- `error-recovery-handler.sh` ✅
- `user-prompt-submit.sh` ✅

**Agent System (16 files maximum):**
- discovery.md, deep-dive.md, research-validate.md, synthesis.md
- generator.md, planner.md, writer.md, brand-validator.md
- claude.md, gemini.md, perplexity.md
- polisher.md, optimizer.md
- synthesizer.md, synthesizer-direct.md, audio-validator.md

### 🚫 IMMEDIATE VIOLATION CONSEQUENCES

**File Creation Violations:**
- Creation blocked immediately
- All associated work invalidated
- Must eliminate duplicate before continuing

**File Modification Violations:**
- Changes rejected
- Must consolidate to single-source first
- No bypass mechanisms available

**Commit Violations:**
- Pre-commit hooks block with detailed failure report
- Must resolve ALL duplicates before any commit
- No override flags or escape hatches

### 📊 AUDIT REQUIREMENTS

**Daily Compliance Check:**
```bash
find . -name "*.md" -o -name "*.sh" -o -name "*.json" | \
grep -v ".git" | sort | uniq -d
# Must return ZERO results
```

**Weekly Deep Audit:**
```bash
.claude/hooks/comprehensive-duplication-audit.sh
# Generates compliance report
# Any violations require immediate resolution
```

### 🔧 APPROVED CONSOLIDATION PATTERNS

**Documentation Cross-References:** ✅ IMPLEMENTED
- Use `@.claude/path/file.md` references - Template system active
- Never copy-paste content between files - Automated detection enforces
- Single source of truth per topic - Templates in `.claude/templates/`

**Configuration Inheritance:**
- Central config files with referencing
- No hardcoded values in scripts
- Environment variable indirection

**Script Modularity:**
- Shared functions in single utility file
- Source inclusion, never duplication
- Version control for shared components

### ⚡ EMERGENCY PROCEDURES

**Duplication Detected:**
1. Stop all current work immediately
2. Identify single-source-of-truth version
3. Delete all duplicates
4. Update all references
5. Verify no functionality lost
6. Resume work only after cleanup complete

**Archive Management:**
- External backups only (not in project)
- Git history sufficient for recovery
- No local archive directories

### 🎯 SUCCESS METRICS

**Zero Tolerance Achieved:**
- 0 duplicate files detected
- 0 duplicate configurations
- 0 duplicate logic patterns
- 100% single-source compliance

**This policy is NON-NEGOTIABLE and ABSOLUTE.**

## 🏗️ NATIVE CLAUDE CODE ARCHITECTURE

**🚨 CRITICAL:** Before modifying any agent or command, load: `@.claude/context/sub-agent-architecture.md`

**Architecture Details:**
- `@.claude/context/sub-agent-architecture.md` - **REQUIRED READING** for agent modifications
- `@.claude/context/mcp-tool-inheritance.md` - MCP tool integration patterns

**Core Patterns (CORRECTED 2025-08-26):**
- **Main Chat Orchestrator** uses **direct sub-agent invocation** (NOT Task tool delegation)
- **Specialized Sub-Agents** (16 enhanced agents in `.claude/agents/`) with full MCP tool inheritance
- **Slash Command Workflows** (`.claude/commands/`) using correct invocation patterns
- **Hooks Observability** for cost tracking, validation, and architecture compliance

**Correct Invocation Pattern:**
```markdown
Use the [agent-name] agent to [action]: "specific requirements"
```

**Research-First Workflow (Updated):**
- Research Pipeline: Direct sub-agent invocation → MCP tools → Real execution (>0 tool uses)
- Production Pipeline: Sequential agent coordination → ElevenLabs integration → Final audio

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
