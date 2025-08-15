# 🧭 NAVIGATION HUB - @ Reference Guide

**Technical:** Centralized navigation system enables efficient context loading through semantic @ references, optimizing token usage while maintaining comprehensive access to project documentation.

**Simple:** Think of this like a table of contents or index - it helps you quickly find and load exactly what you need without digging through everything.

**Connection:** This teaches efficient information architecture and resource management in large systems.

## 🚀 COMPLETE CONTEXT PACKAGES (LLM-OPTIMIZED)

### 🎯 PRIMARY CONTEXT PACKAGES - Complete & Self-Contained
- `@production-complete` - Everything needed for episode production
- `@learning-essentials` - Complete beginner onboarding and education
- `@troubleshooting-kit` - Complete diagnostic and resolution toolkit

### 📚 LEGACY INDIVIDUAL CONTEXTS (Use packages above instead)

#### Foundation & Learning
- `@foundation/01_project_overview.xml` - Start here for new users
- `@foundation/02_walk_crawl_run_phases.xml` - Learning progression
- `@foundation/04_no_api_keys_activities.xml` - FREE learning activities
- `@foundation/00_project_constants.xml` - Core project constants

#### Operations & Commands
- `@operations/01_troubleshooting_guide.xml` - Fix problems
- `@operations/02_quick_reference.xml` - Essential commands
- `@operations/03_production_checklist.xml` - Production workflows
- `@operations/00_operations_constants.xml` - Operations constants

#### Quality & Standards
- `@quality/enforcement_standards.xml` - Mandatory standards
- `@quality/03_tdd_requirements_specification.xml` - Testing approach
- `@quality/04_validation_workflow.xml` - Validation procedures
- `@quality/dry-principle-enforcement.xml` - DRY requirements
- `@quality/00_quality_constants.xml` - Quality constants

#### Agent & Tool Systems
- `@agents/multi-agent-orchestration.xml` - Multi-agent framework
- `@tools/elevenlabs-v3-optimization-guide.xml` - TTS optimization
- `@tools/gemini-cli-quality-judge-guide.xml` - Quality evaluation

#### Level-Specific Contexts
- `@level1/CONTEXT.md` - Development Platform (Level 1)
- `@level2/CONTEXT.md` - Production System (Level 2)
- `@level2/agents/CONTEXT.md` - Production agents
- `@level2/sessions/CONTEXT.md` - Session management

#### External Integrations
- `@elevenlabs/15_elevenlabs_overview.xml` - ElevenLabs integration
- `@elevenlabs/20_elevenlabs_cost_optimization.xml` - Cost strategies
- `@claude-code/22_subagents_guide.xml` - Subagent usage

## 🎯 LLM-OPTIMIZED WORKFLOWS

### New User Onboarding (Complete in ONE load)
**Command**: `@learning-essentials`
**Contains**: Project overview, learning phases, essential commands, architecture, quality requirements, next steps
**Result**: Complete understanding and clear next actions

### Episode Production (Complete in ONE load)
**Command**: `@production-complete`
**Contains**: All constants, agent specs, workflow, troubleshooting, templates
**Result**: Can produce episode end-to-end without additional context

### Problem Solving (Complete in ONE load)
**Command**: `@troubleshooting-kit`
**Contains**: Diagnostics, resolutions, error patterns, prevention, escalation
**Result**: Can diagnose and resolve any system issue

### 📚 LEGACY MULTI-STEP WORKFLOWS (Less Efficient)

#### Traditional New User Setup
1. `@foundation/01_project_overview.xml` - Understand the project
2. `@foundation/02_walk_crawl_run_phases.xml` - See learning path
3. `@foundation/04_no_api_keys_activities.xml` - Start FREE activities

#### Traditional Troubleshooting
1. `@operations/01_troubleshooting_guide.xml` - Systematic diagnosis
2. `@quality/04_validation_workflow.xml` - Validation procedures
3. `@operations/02_quick_reference.xml` - Quick fixes

#### Traditional Production
1. `@level2/CONTEXT.md` - Production system overview
2. `@operations/03_production_checklist.xml` - Production workflow
3. `@elevenlabs/20_elevenlabs_cost_optimization.xml` - Cost control

## 📁 DIRECTORY STRUCTURE

```
.claude/
├── NAVIGATION.md (this file)
├── CONTEXT.md (level overview)
├── context/
│   ├── foundation/     # @foundation/
│   ├── operations/     # @operations/
│   ├── quality/        # @quality/
│   ├── agents/         # @agents/
│   ├── elevenlabs/     # @elevenlabs/
│   ├── claude-code/    # @claude-code/
│   └── tools/          # @tools/
├── level-1-dev/
│   └── CONTEXT.md      # @level1/CONTEXT.md
├── level-2-production/
│   ├── CONTEXT.md      # @level2/CONTEXT.md
│   ├── agents/CONTEXT.md
│   └── sessions/CONTEXT.md
└── tools/              # Implementation utilities
```

## 🔍 SEARCH PATTERNS

### Find Specific Information
- Constants: Look in `00_*_constants.xml` files
- Procedures: Check `@operations/` directory
- Standards: Reference `@quality/` directory
- Technical guides: Browse `@tools/` and specific integration directories

### Context Loading Strategy
1. **Start minimal**: Only root CLAUDE.md loads automatically
2. **Load on-demand**: Use @ references for specific needs
3. **Clear frequently**: Use `/clear` to manage token usage
4. **Reference efficiently**: Load context groups, not individual files

## 💡 PRO TIPS

- **Batch loading**: Load multiple related contexts together
- **Use /clear**: Prevent context overflow after loading large contexts
- **Reference patterns**: Use `@directory/` to load multiple related files
- **Learning path**: Follow numbered sequences (01_, 02_, etc.) for structured learning

---

**Remember**: Load only what you need, when you need it. This keeps Claude Code fast and focused!

**Quick Actions**: `@foundation/01_project_overview.xml` | `@operations/02_quick_reference.xml` | `/clear`
