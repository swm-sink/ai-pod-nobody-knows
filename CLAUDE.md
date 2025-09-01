# CLAUDE.md - AI Podcast Production Master System 🎓

<!-- markdownlint-disable-file -->

<!-- CLAUDE 4 OPTIMIZED: Token budget 12K, Selective loading enabled -->
<MANDATORY_CONTEXT>
<!-- This block MUST be loaded for all operations -->

## 🎯 DUAL-MODE ARCHITECTURE ENFORCEMENT

<SYSTEM_DIRECTIVE priority="MAXIMUM">
**DUAL-MODE OPERATION: Claude Code builds LangGraph; LangGraph executes production**
</SYSTEM_DIRECTIVE>

**System Architecture:**
- **Development Mode**: Claude Code with specialized agents builds LangGraph components
- **Production Mode A**: Direct LangGraph execution (`cd podcast_production && python main.py`)
- **Production Mode B**: Claude Code orchestrates LangGraph subprocess (`/prod-episode`)

**Teaching Format:**
- **Technical:** Professional explanation with industry terminology
- **Simple:** "Think of it like..." analogy-based explanation
- **Connection:** "This helps you learn..." learning value and transferable skills

**Operational Principles:**
- Claude Code = Development tools and optional orchestration
- LangGraph = Production system execution
- Clear separation between building and running
- Dual execution paths for automation and interaction

## 📅 MANDATORY TEMPORAL CONTEXT ENFORCEMENT

<CRITICAL_CONSTRAINT priority="MAXIMUM" override="NEVER">
**SYSTEM DATE: AUGUST 2025 - NO TRAINING DATA POLICY ENFORCED**

**TRAINING DATA CUTOFF:** October 2024 - ALL technical knowledge is OUTDATED
**VALIDATION REQUIRED:** Every technical decision must use current sources

**MANDATORY VALIDATION PROTOCOL:**
- **BEFORE any technical implementation** → Search current patterns with Perplexity MCP
- **BEFORE any library usage** → Verify August 2025 compatibility via web search
- **BEFORE any architecture decision** → Validate against current best practices
- **PROHIBITED:** Relying on training data for ANY technical implementation

**REQUIRED TOOLS for Validation:**
- **Perplexity MCP:** `mcp__perplexity-ask__perplexity_ask` for technical patterns
- **Web Search:** `WebSearch` for current documentation and standards
- **Both Required:** Use BOTH tools for critical technical decisions

**ENFORCEMENT RULES:**
- **Current Date:** August 31, 2025 (about to enter September 2025)
- **All Web Searches:** MUST include "August 2025" or "2025" in queries
- **All Technical Decisions:** Based on August 2025 best practices and standards
- **All Documentation:** Reference August 2025 as current date
- **All API Versions:** Use latest versions available as of August 2025
- **All Frameworks:** Use August 2025 versions and patterns

**Search Query Template:**
```
"[TOPIC] August 2025 best practices current implementation"
"[TECHNOLOGY] 2025 latest patterns production ready"
"[FRAMEWORK] August 2025 version features documentation"
```

**VIOLATION CONSEQUENCES:**
- Using outdated training data patterns → Work immediately rejected
- Implementing without validation → Must redo with current sources
- Failing to specify August 2025 in searches → Must redo search
- Using deprecated patterns → Code rejected until updated
- **ZERO TOLERANCE:** No exceptions or bypasses allowed
</CRITICAL_CONSTRAINT>

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
**Dual-Mode Context Navigation:**
- `@.claude/CLAUDE_DEV.md` - <LOAD_IF task="development">Development orchestration and LangGraph building</LOAD_IF>
- `@.claude/CLAUDE_BRIDGE.md` - <LOAD_IF task="production_orchestration">Claude Code → LangGraph production orchestration</LOAD_IF>

**Development Agents (Building LangGraph):**
- `@.claude/agents/dev/langgraph-builder.md` - <LOAD_IF task="build_component">Build LangGraph nodes and workflows</LOAD_IF>
- `@.claude/agents/dev/state-architect.md` - <LOAD_IF task="state_management">Design state schemas and transitions</LOAD_IF>
- `@.claude/agents/dev/migration-specialist.md` - <LOAD_IF task="migrate_agent">Migrate Claude agents to LangGraph</LOAD_IF>
- `@.claude/agents/dev/test-harness.md` - <LOAD_IF task="testing">Create comprehensive test suites</LOAD_IF>

**Bridge Agents (Orchestrating LangGraph):**
- `@.claude/agents/bridge/production-orchestrator.md` - <LOAD_IF task="run_episode">Orchestrate LangGraph subprocess execution</LOAD_IF>

**Development Commands:**
- `@.claude/commands/dev/build-langgraph.md` - <LOAD_IF task="build">Build LangGraph components with validation</LOAD_IF>

**Production Commands:**
- `@.claude/commands/prod/run-episode.md` - <LOAD_IF task="episode_production">Full episode production via LangGraph</LOAD_IF>

**Planning & Tracking:**
- `@podcast_production/TODO_dev.yaml` - <LOAD_IF task="development_planning">Development task tracking</LOAD_IF>
- `@podcast_production/TODO_prod.yaml` - <LOAD_IF task="production_planning">Episode production planning</LOAD_IF>
</SELECTIVE_CONTEXT_DIRECTORY>

## 📍 CURRENT STATUS

**Phase:** Architecture Stabilization (75% complete)
**LangGraph Migration:** 12/16 agents complete
**System Mode:** Dual-mode (Development + Production)
**Focus:** Complete remaining agent migrations and production readiness
**Cost Target:** $5.51 per episode maintained

<SYSTEM_COMMANDS priority="HIGH_FREQUENCY">
## 🔧 DUAL-MODE COMMANDS

**Development Commands (Building LangGraph):**
- `/dev-build` - Build LangGraph component
- `/dev-test` - Test LangGraph pipeline
- `/dev-migrate` - Migrate Claude agent to LangGraph
- `/dev-state` - Design state management

**Production Commands (Running LangGraph):**
- `/prod-episode` - Full episode production via LangGraph
- `/prod-research` - Research pipeline only
- `/prod-monitor` - Monitor production progress
- `/prod-analyze` - Analyze production metrics

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
# Use: claude mcp add-json elevenlabs '{"type": "stdio", "command": "python3", "args": ["/path/to/elevenlabs_mcp/server.py"], "env": {"ELEVENLABS_API_KEY": "your-key-here"}}'  # pragma: allowlist secret
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

## 🏗️ DUAL-MODE LANGGRAPH ARCHITECTURE

**🚨 CRITICAL:** This system operates in two distinct modes with clear separation of concerns.

**Architecture Overview:**
```
Claude Code (Development & Optional Orchestration)
    ↓ builds and optionally orchestrates
LangGraph (Production Execution System)
    ↓ executes via
Python Subprocess (podcast_production/main.py)
```

**Mode 1: Development (Claude Code):**
- **Purpose**: Build, test, and migrate LangGraph components
- **Agents**: langgraph-builder, state-architect, migration-specialist, test-harness
- **Commands**: `/dev-build`, `/dev-test`, `/dev-migrate`, `/dev-state`
- **Output**: LangGraph-compatible Python code in `podcast_production/`

**Mode 2A: Direct Production (LangGraph):**
- **Purpose**: Automated episode production without Claude Code
- **Execution**: `cd podcast_production && python main.py --topic "Topic"`
- **Use Case**: Batch processing, automated systems, CI/CD integration

**Mode 2B: Orchestrated Production (Claude Code → LangGraph):**
- **Purpose**: Interactive production with monitoring and control
- **Agents**: production-orchestrator, monitor-agent, recovery-agent
- **Commands**: `/prod-episode`, `/prod-research`, `/prod-monitor`
- **Execution**: Subprocess orchestration with real-time feedback

**LangGraph Production System:**
- **Location**: `podcast_production/` directory
- **State Management**: PodcastState TypedDict with msgpack serialization
- **Cost Tracking**: CostTracker with budget enforcement
- **Workflows**: StateGraph with checkpointing and recovery
- **Agent Implementation**: 12/16 agents migrated (75% complete)

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

1. **Complete LangGraph Migration** (4 agents remaining):
   - script-writer ($1.75 budget) - CRITICAL
   - brand-validator ($0.25 budget) - HIGH
   - episode-planner ($0.20 budget) - MEDIUM
   - question-generator ($0.10 budget) - LOW

2. **Finish Architecture Stabilization**:
   - Complete StateManager implementation and testing
   - Implement AgentOrchestrator for workflow coordination
   - Consolidate configuration management

3. **Production Readiness Validation**:
   - Test dual-mode architecture end-to-end
   - Validate cost tracking accuracy (≤ $5.51/episode)
   - Ensure quality standards maintained (≥ 8.0)

4. **Launch Production Pipeline**:
   - First post-migration validation episode
   - Regular production schedule (2 episodes/week target)

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

**Quick Actions:** `/dev-build` | `/prod-episode` | `/clear` | `@.claude/CLAUDE_DEV.md` | `@.claude/CLAUDE_BRIDGE.md`

**Version:** 8.0.0 | **Updated:** 2025-09-01 | **Architecture:** Dual-Mode LangGraph | **Migration:** 75% Complete
