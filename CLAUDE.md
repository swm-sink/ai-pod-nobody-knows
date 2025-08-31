# CLAUDE.md - AI Podcast Production Master System 🎓

<!-- markdownlint-disable-file -->

<!-- CLAUDE 4 OPTIMIZED: Token budget 12K, Selective loading enabled -->
<MANDATORY_CONTEXT>
<!-- This block MUST be loaded for all operations -->

## 🎯 MANDATORY SIMPLICITY ENFORCEMENT

<SYSTEM_DIRECTIVE priority="MAXIMUM">
**PROHIBIT OVERCOMPLICATED SOLUTIONS - ENFORCE MINIMUM VIABLE COMPLEXITY**
</SYSTEM_DIRECTIVE>

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

<CRITICAL_CONSTRAINT override="NEVER">
**VOICE ID CHANGES REQUIRE EXPLICIT USER PERMISSION - NO EXCEPTIONS**
</CRITICAL_CONSTRAINT>

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

**😵 Feeling Overwhelmed?** → `.claude/GETTING_STARTED.md` → Simple 5-minute path forward
**🏗️ Want to Understand?** → `.claude/ARCHITECTURE_GUIDE.md` → How this sophisticated system works
**🚶 First Time?** → Follow WALK phase (FREE learning) → `@context/02_walk_crawl_run_phases.md`
**🔄 Welcome Back!** → Check current phase → `@context/02_quick_reference.md`
**🚨 Need Help?** → `@context/troubleshooting_unified.md`

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
  - 03_meta_prompting_workflow_summary.md (13-step methodology execution)
  - 02_quick_reference.md (Essential commands and navigation)

user_experience:
  - 02_hallucination_prevention_guide.md (Anti-hallucination protocols)
  - 02_walk_crawl_run_phases.md (Learning progression framework)
```

<CONTEXT_LOADING_PROTOCOL token_budget="12K_MAXIMUM">
**Context Loading Strategy:**
- **Entry Point:** This CLAUDE.md file - navigation hub only (12K token budget)
- **Selective Loading:** Load only MANDATORY blocks unless task requires OPTIONAL content
- **Two-Hop Rule:** CLAUDE.md → Domain File → Detail File (MAXIMUM 2 hops)
- **Token Priority:** MANDATORY > SYSTEM > AGENT > REFERENCE > OPTIONAL
- **Budget Enforcement:** Stop loading if approaching 12K token limit
- **Validation:** Every `@` reference must include explicit requirement justification
- **No Duplication:** Violation of single-source principle immediately stops all work

**File Hop Navigation Rules:**
```yaml
validation_pattern:
  hop_1: "@.claude/context/" # Core system contexts (always valid)
  hop_2: "@.claude/agent-context/" # Domain contexts (conditional)
  hop_3: "FORBIDDEN" # Never exceed 2 hops from CLAUDE.md

token_allocation:
  mandatory_context: "4K tokens maximum"
  optional_context: "6K tokens maximum"
  working_memory: "2K tokens reserved"
```
</CONTEXT_LOADING_PROTOCOL>

<SELECTIVE_CONTEXT_DIRECTORY priority="CONDITIONAL">
**Directory Context Navigation:**
- `@.claude/agent-context/agents.md` - <LOAD_IF task="agent_modification">All specialized sub-agents and orchestration patterns</LOAD_IF>
- `@.claude/agent-context/commands.md` - <LOAD_IF task="command_creation">User-facing commands and workflow interfaces</LOAD_IF>
- `@.claude/agent-context/docs.md` - <LOAD_IF task="documentation">Comprehensive documentation organization</LOAD_IF>
- `@.claude/agent-context/systems.md` - <LOAD_IF task="system_config">System-level infrastructure and orchestration</LOAD_IF>
- `@.claude/agent-context/workflows.md` - <LOAD_IF task="workflow_design">Meta-prompting and systematic methodologies</LOAD_IF>
- `@.claude/agent-context/processes.md` - <LOAD_IF task="process_validation">Detailed procedures and validation results</LOAD_IF>
</SELECTIVE_CONTEXT_DIRECTORY>

## 📍 CURRENT STATUS

**Phase:** WALK
**Focus:** Learn for FREE - No API keys needed!
**Cost:** $0
**Next:** `@context/02_walk_crawl_run_phases.md`

<SYSTEM_COMMANDS priority="HIGH_FREQUENCY">
## 🔧 ESSENTIAL COMMANDS

**Context Management:**
- `/init` - Initialize project memory
- `/clear` - Clear conversation (use frequently!)
- `# note` - Quick memory addition

**Thinking Modes:**
- `think` - Basic reasoning
- `think hard` - Enhanced analysis (recommended)
- `ultrathink` - Maximum thinking (complex problems)
</SYSTEM_COMMANDS>

## 🔒 SECURITY CONFIGURATION

**GitHub Integration:**
PAT stored in `.env` file (git-ignored)
Usage: `source .env && git push origin main`

**MCP Environment Setup:**
**UPDATED 2025-08-28:** Environment variable inheritance is NOT the primary MCP issue.

**ElevenLabs MCP Configuration (Working):**
```bash
# API key should be configured directly in MCP server configuration
# Use: claude mcp add-json elevenlabs '{"type": "stdio", "command": "python3", "args": ["/path/to/elevenlabs_mcp/server.py"], "env": {"ELEVENLABS_API_KEY": "your-key-here"}}'
```

**Troubleshooting MCP Authentication:**
1. Verify MCP server shows ✓ Connected: `claude mcp list`
2. Test API key directly: `curl -H "xi-api-key: YOUR_KEY" https://api.elevenlabs.io/v1/models`
3. Check package version compatibility if tools fail with 401 errors
4. See current system status in validation reports

## ⚠️ MANDATORY ENFORCEMENT PROTOCOLS

**All detailed enforcement protocols have been extracted to modular files for performance optimization.**

**Load specific enforcement as needed:**
- `@.claude/protocols/enforcement.md` - Complete enforcement protocols
- `@.claude/protocols/validation.md` - Validation and quality gates

**Core Enforcement Summary:**
- **Anti-Hallucination:** Every claim must be tool-verified or marked UNVERIFIED
- **Change Control:** All modifications require user approval and validation
- **Zero Tolerance:** No bypasses, no exceptions, no assumptions

## 📁 DIRECTORY STRUCTURE ENFORCEMENT

**PROFESSIONAL STANDARD DIRECTORY ORGANIZATION - ABSOLUTE REQUIREMENT**

**Current Structure (v1.0.0 Production Standard):**
```
/
├── src/                    # Python source code
│   ├── audio/             # Audio processing (tts_*.py)
│   ├── validation/        # Validation scripts (stt_*.py, ssml_*.py)
│   └── utils/            # Utility scripts (test_*.py)
├── docs/                  # All documentation
│   ├── architecture/     # Detailed architecture docs
│   ├── deployment/       # Deployment guides (DEPLOYMENT.md)
│   ├── development/      # Implementation guides (ROADMAP_*.md)
│   ├── reports/          # Assessment reports (AI_PODCAST_*.md)
│   └── legacy/           # Outdated documentation
├── tests/                 # Test files and validation
│   ├── validation/       # Test validation files (validation_*.md)
│   ├── unit/            # Unit tests
│   └── integration/     # Integration tests
├── config/                # Configuration files
│   ├── environments/    # Environment-specific configs
│   └── templates/       # Configuration templates
├── build/                 # Build and deployment tools
│   ├── scripts/         # Build scripts (start-claude.sh)
│   └── tools/           # Development tools
└── Root (≤8 files only): README.md, ARCHITECTURE.md, CONTRIBUTING.md,
                          LICENSE, .env.example, requirements.txt,
                          package.json, CLAUDE.md
```

**Directory Governance Rules:**
- **Root Directory Limit**: Maximum 8 files (navigation and essential configs only)
- **No Code in Root**: All Python files → `src/` directories by type
- **Documentation Categorization**: All .md files → `docs/` subdirectories by purpose
- **Test Organization**: All test/validation files → `tests/` subdirectories
- **Configuration Centralization**: All config files → `config/` or appropriate subdirectories
- **Build Tooling**: All scripts → `build/scripts/`, tools → `build/tools/`

**Enforcement Mechanisms:**
```yaml
directory_structure_enforcement:
  pre_commit_hooks: "Validate directory compliance before commits"
  root_file_limit: "Block commits if root has >8 files"
  categorization_check: "Ensure files are in correct directories"
  governance_validation: ".claude/governance/directory-structure-enforcement.md"
```

**Violation Consequences:**
- Root directory violations immediately block all commits
- Misplaced files trigger automatic reorganization requirements
- Directory governance violations stop all work until resolved
- No exceptions or bypass mechanisms - professional standards enforced

</MANDATORY_CONTEXT>

<OPTIONAL_CONTEXT priority="LOAD_ON_DEMAND">
<!-- Load only when duplication issues are detected -->

## 🚨 ZERO-TOLERANCE DRY ENFORCEMENT - ABSOLUTE PROHIBITION

<ENFORCEMENT_PROTOCOL severity="NUCLEAR">
**CRITICAL SYSTEM INTEGRITY POLICY - NO EXCEPTIONS**

**DUPLICATION IS FORBIDDEN - VIOLATIONS STOP ALL WORK IMMEDIATELY**
</ENFORCEMENT_PROTOCOL>

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
- `pre-tool-cost-validation.sh` ✅
- `post-tool-cost-tracking.sh` ✅
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

### 🚨 ENHANCED-* PATTERN PROHIBITION - ABSOLUTE BAN

**ZERO TOLERANCE FOR "enhanced-*" FILE PATTERNS**

**Prohibited Patterns:**
- `enhanced-*.md` - FORBIDDEN (use existing files or create properly named files)
- `*-enhanced.*` - FORBIDDEN (consolidate into existing architecture)
- Any file containing "enhanced" in name - REQUIRES explicit justification

**Enforcement Actions:**
- Immediate detection and blocking of enhanced-* pattern creation
- Automatic consolidation requirement for any enhanced-* files found
- All work stops until enhanced-* violations are resolved
- No exceptions or bypass mechanisms available

**Prevention Mechanisms:**
- Pre-commit hooks scan for enhanced-* patterns
- Automated file creation blocking for prohibited names
- Regular audit scans for pattern violations
- Context file validation prevents enhanced-* references

### 🚫 IMMEDIATE VIOLATION CONSEQUENCES

**File Creation Violations:**
- Creation blocked immediately
- All associated work invalidated
- Must eliminate duplicate before continuing
- Enhanced-* patterns trigger automatic consolidation requirement

**File Modification Violations:**
- Changes rejected
- Must consolidate to single-source first
- No bypass mechanisms available
- Enhanced-* modifications require immediate renaming and consolidation

**Commit Violations:**
- Pre-commit hooks block with detailed failure report
- Must resolve ALL duplicates before any commit
- Enhanced-* pattern detection prevents all commits
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
</OPTIONAL_CONTEXT>

## 🏗️ NATIVE CLAUDE CODE ARCHITECTURE

**🚨 CRITICAL:** Before modifying any agent or command, load: `@.claude/context/agent_orchestration_complete.md`

**Architecture Details:**
- `@.claude/context/agent_orchestration_complete.md` - **REQUIRED READING** for agent modifications
- `@.claude/context/claude_code_integration.md` - MCP tool integration patterns

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

## 📊 PRODUCTION SYSTEM STATUS

**System Validation**: ✅ **PRODUCTION CERTIFIED** (August 30, 2025)
**Validation Status**: System validated and production-ready
**Readiness Level**: Complete 50-step validation passed with 98% confidence
**Quality Standards**: Multi-evaluator consensus operational (9.0+/10 targets)
**Cost Performance**: $5.51-$8.00 per episode range validated

**Latest Results Summary:**
- ✅ All MCP connections operational
- ✅ Agent coordination validated with brand alignment system
- ✅ Production pipeline certified and ready
- ✅ Claude Code native patterns confirmed
- ✅ Quality gates and cost controls functional

## 📚 CONTEXT LOADING GUIDE

**Technical:** Context engineering optimizes information architecture for 200K token attention mechanisms using selective loading patterns.

**Simple:** Like organizing your desk so you can find the right tool instantly - only load what you need when you need it.

**Connection:** This teaches efficient AI system management and resource optimization.

**Available Contexts:**
- `@context/` - All guides, troubleshooting, and constants
- `@.claude/agent-context/` - Domain-specific context navigation
- `@.claude/agent-context/INDEX.md` - Complete context directory

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

**Version:** 7.0.0 | **Updated:** 2025-08-30 | **Optimized:** Claude 4 + Selective Loading | **Performance:** 67k → 12k chars
