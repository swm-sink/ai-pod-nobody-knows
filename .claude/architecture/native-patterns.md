# Claude Code Native Architecture Patterns

## 🏗️ CLAUDE CODE NATIVE COMPATIBILITY ENFORCEMENT

### Critical Mandate
ALL SYSTEM COMPONENTS MUST USE CLAUDE CODE NATIVE ARCHITECTURE
NO STANDALONE IMPLEMENTATIONS - ONLY NATIVE SUB-AGENTS, SLASH COMMANDS, AND HOOKS
FAILURE TO USE NATIVE PATTERNS INVALIDATES ALL WORK PERFORMED

### Scope
Applies to ALL validation harnesses, agent implementations, command definitions, orchestration systems, monitoring tools, and automation workflows. NO EXCEPTIONS.

### Mandatory Patterns

#### Native Sub-Agents
**Requirement:** All AI agents MUST be implemented as Claude Code sub-agents in .claude/agents/ directory
**Structure:** Markdown files with YAML frontmatter following official specification
**Documentation:** https://docs.anthropic.com/en/docs/claude-code/sub-agents
**Enforcement:** No standalone Python/JavaScript agent implementations allowed

**Example Structure:**
```markdown
---
name: validation-orchestrator
description: "Comprehensive validation and testing orchestrator for podcast production system"
tools: Read, Write, Bash, Grep, Glob
---
# Sub-agent system prompt and instructions
```

#### Native Slash Commands
**Requirement:** All custom commands MUST be implemented as Claude Code slash commands in .claude/commands/ directory
**Structure:** Markdown files with optional frontmatter and $ARGUMENTS placeholder support
**Documentation:** https://docs.anthropic.com/en/docs/claude-code/slash-commands
**Enforcement:** No external command-line tools or scripts for core functionality

**Example Structure:**
```markdown
# /enhance-agent - Research-Backed Agent Enhancement

Use the validation-orchestrator sub-agent to enhance agent: $ARGUMENTS

Execute 6-phase enhancement workflow with Perplexity integration.
```

#### Native Hooks System
**Requirement:** All observability and automation MUST use Claude Code hooks system
**Structure:** Shell commands configured via settings with proper event targeting
**Documentation:** https://docs.anthropic.com/en/docs/claude-code/hooks-guide
**Enforcement:** No standalone monitoring or logging systems outside hooks

**Observability Patterns:**
- **Pre-tool-use:** Cost tracking and budget validation before agent execution
- **Post-tool-use:** Quality validation and checkpoint creation after agent completion
- **User-prompt-submit:** Input validation and processing pipeline triggers
- **Notification:** Alert systems and status updates
- **Stop:** Cleanup, logging, and state persistence

### Integration Requirements

#### Directory Structure
- **.claude/agents/** - All sub-agent definitions with research-backed prompts
- **.claude/commands/** - All slash command definitions with parameter handling
- **Settings configuration** - All hook definitions with event targeting
- **.claude/infrastructure/** - Configuration files and schemas only

#### Workflow Orchestration
**Pattern:** Slash commands invoke sub-agents with hooks providing observability
**Example:** /enhance-agent → validation-orchestrator sub-agent → cost-tracking hooks
**Enforcement:** No external orchestration systems or workflow engines

#### Tool Access Control
**Principle:** Sub-agents specify required tools in YAML frontmatter
**Validation:** Hook system validates tool usage against agent permissions
**Security:** Minimal tool access principle with explicit authorization

### Migration Enforcement

#### Immediate Requirements
- **Existing Python code:** Must be converted to sub-agents and hooks immediately
- **Standalone scripts:** Must be converted to slash commands with sub-agent delegation
- **External monitoring:** Must be converted to hooks-based observability system

#### Validation Gates
- **Pre-implementation:** All new work must demonstrate Claude Code native patterns
- **Code review:** No merge without native compatibility validation
- **Continuous compliance:** Regular audits for non-native pattern elimination

#### Transition Timeline
- **Phase 1:** Convert validation harness to sub-agents and hooks (Week 1)
- **Phase 2:** Convert all commands to native slash command pattern (Week 1)
- **Phase 3:** Implement complete hooks-based observability (Week 2)
- **Phase 4:** Eliminate all standalone implementations (Week 2)

### Quality Assurance

#### Native Pattern Validation
- **Agents compliance:** All agents in .claude/agents/ with proper YAML frontmatter
- **Commands compliance:** All commands in .claude/commands/ with proper parameter handling
- **Hooks compliance:** All automation via hooks system with proper event configuration

#### Integration Testing
- **Command-to-agent:** Slash commands properly delegate to appropriate sub-agents
- **Agent tool access:** Sub-agents can access only specified tools
- **Hooks observability:** Hooks provide complete workflow visibility and control

#### Performance Standards
- **Native efficiency:** Native patterns provide superior performance vs standalone implementations
- **Maintenance reduction:** Native patterns reduce maintenance overhead by 80%+
- **User experience:** Consistent Claude Code interface patterns and behaviors

### Violation Consequences
- **Immediate rejection:** All work using non-native patterns rejected immediately
- **No hybrid approaches:** No mixing native and standalone implementations allowed
- **Complete rework required:** Must restart implementation using native patterns
- **Documentation update:** All documentation must reflect native-only approach

### Success Criteria
- **Complete native implementation:** 100% of functionality using Claude Code native patterns
- **Zero standalone code:** No Python/JavaScript/external tools for core functionality
- **Hooks-based observability:** Complete workflow visibility through hooks system
- **User experience consistency:** All interactions through standard Claude Code interfaces

### Educational Value

**Technical:** Native Claude Code patterns provide optimal integration with the platform's architecture, ensuring compatibility with future updates and leveraging built-in capabilities for security, performance, and maintainability.

**Simple:** Like using the tools and methods that come with your workshop instead of building everything from scratch - it works better and is much easier to maintain.

**Connection:** This teaches platform-native development principles where leveraging built-in capabilities creates more robust, maintainable, and user-friendly solutions than custom implementations.

## 🌊 NATIVE CLAUDE CODE ARCHITECTURE v2.0

### Architecture Summary

**Technical:** Claude Code native architecture with main chat orchestration, Task tool delegation to specialized sub-agents, and slash command workflows. Eliminates anti-pattern orchestrator agents discovered through comprehensive research.

**Simple:** Like a conductor (main chat) leading an orchestra - you coordinate specialized musicians (sub-agents) through clear signals (Task tool), using pre-written scores (slash commands).

**Critical Architecture Fix:** Previous versions contained anti-pattern orchestrator agents that violated Claude Code native patterns. These have been eliminated and converted to proper slash command workflows.

### Native Patterns
- **Main Chat Orchestrator:** Uses Task tool delegation (not separate orchestrator agents)
- **Specialized Sub-Agents:** 14 enhanced agents (.claude/agents/) with external research integration
- **Slash Command Workflows:** Native commands (.claude/commands/) using Task tool delegation
- **Research Tools Integration:** WebSearch and Perplexity MCP for validation and current research
- **Hooks Observability:** Native hooks system for cost tracking and quality assurance

### Research-First Workflow
- **Research Pipeline:** `/research-episode-enhanced` → 3 research agents → User review checkpoint
- **Production Pipeline:** `/produce-episode-native` → 5 production agents → Final episode audio
- **External Validation:** WebSearch + Perplexity MCP integration throughout both pipelines
- **Quality Assurance:** Dual evaluation system with consensus-based quality gates
