# CLAUDE_DEV.md - Development Orchestration Layer

<!-- markdownlint-disable-file -->

<!-- DEVELOPMENT MODE: Building LangGraph Components -->
<MANDATORY_CONTEXT>
<!-- This context loads when task="development" -->

## 🎯 DEVELOPMENT MISSION

**Purpose**: Build, test, and optimize the LangGraph production system using Claude Code as development orchestrator.

**Key Principle**: Claude Code builds LangGraph; LangGraph executes production.

## 🏗️ CURRENT DEVELOPMENT STATUS

**LangGraph Migration Progress**: 12/16 agents complete (75%)
**Phase**: Architecture Stabilization (StateManager implementation)
**Next**: Complete remaining 4 agent migrations
**Target**: Production-ready LangGraph system

**Remaining Agents to Migrate**:
- question-generator ($0.10 budget)
- episode-planner ($0.20 budget)
- script-writer ($1.75 budget)
- brand-validator ($0.25 budget)

## 🔧 DEVELOPMENT AGENT ORCHESTRATION

<SELECTIVE_CONTEXT_LOADING>
**Agent Specialization Pattern**:
- `@agents/dev/langgraph-builder.md` - <LOAD_IF task="build_component">Builds LangGraph nodes and graphs</LOAD_IF>
- `@agents/dev/state-architect.md` - <LOAD_IF task="state_management">Designs state schemas and transitions</LOAD_IF>
- `@agents/dev/test-harness.md` - <LOAD_IF task="testing">Creates and executes test suites</LOAD_IF>
- `@agents/dev/migration-specialist.md` - <LOAD_IF task="migrate_agent">Migrates Claude agents to LangGraph</LOAD_IF>
- `@agents/dev/cost-optimizer.md` - <LOAD_IF task="optimize_costs">Analyzes and optimizes cost patterns</LOAD_IF>
</SELECTIVE_CONTEXT_LOADING>

## 🎮 DEVELOPMENT COMMANDS

**Core Development Workflow**:
- `/dev-build` - Build LangGraph component
- `/dev-test` - Test LangGraph pipeline
- `/dev-migrate` - Migrate Claude agent to LangGraph
- `/dev-state` - Design state management
- `/dev-validate` - Execute quality gates

**Command Details**: Load from `@commands/dev/` on demand

## 📊 CURRENT TECHNICAL DEBT

**Critical Issues**:
1. StateManager implementation incomplete
2. CostTracker msgpack serialization needs testing
3. Agent orchestration patterns need standardization
4. Missing integration tests for LangGraph workflows

**Quality Gates**:
- All tests must pass before agent migration
- Cost per episode must stay ≤ $5.51
- State serialization must be msgpack compatible
- No functionality regression during migration

## 🔄 DEVELOPMENT WORKFLOW

**Standard Development Process**:
1. **Analyze**: Use appropriate dev agent to analyze requirement
2. **Build**: Implement LangGraph component with proper state handling
3. **Test**: Validate functionality with test-harness agent
4. **Validate**: Ensure cost and quality compliance
5. **Integrate**: Merge into main LangGraph workflow

**Context Loading Strategy**:
- Load this file for development orchestration
- Selectively load agent contexts based on task type
- Never load all contexts simultaneously (token management)

## 📍 NAVIGATION TO LANGGRAPH

**LangGraph System Location**: `@../podcast_production/`
**Entry Point**: `@../podcast_production/main.py`
**State Definition**: `@../podcast_production/core/state.py`
**Workflow Orchestration**: `@../podcast_production/workflows/main_workflow.py`

## 🚨 DEVELOPMENT CONSTRAINTS

**Mandatory Compliance**:
- All LangGraph components must be msgpack serializable
- State transitions must be deterministic
- No agent may exceed its assigned cost budget
- All changes must pass existing tests before deployment
- Maintain backward compatibility with existing episodes

**Token Budget**: 8K maximum for this context file
**Update Frequency**: After each major development milestone
**Validation**: Monthly architecture review and consolidation

## 💡 DEVELOPMENT PRINCIPLES

**Technical**:
- LangGraph components are stateless functions
- All persistence goes through StateManager
- Cost tracking is mandatory for every operation
- Test coverage must be maintained above 80%

**Simple**:
- Think of this as a factory that builds the production line
- Claude Code = Factory tools and engineers
- LangGraph = Production line that makes episodes
- We're currently upgrading the production line

**Connection**:
- This teaches advanced software architecture patterns
- State machine design and workflow orchestration
- API integration and error handling strategies
- Cost optimization and resource management

</MANDATORY_CONTEXT>

---

**Version**: 1.0.0 | **Updated**: 2025-09-01 | **Mode**: Development Orchestration
