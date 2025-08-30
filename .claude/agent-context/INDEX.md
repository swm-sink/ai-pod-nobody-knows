# Agent Context Navigation Hub

## 🎯 Purpose
Centralized navigation for all context files in the AI Podcast Production System. This directory consolidates all domain-specific context files to reduce duplication and optimize token usage.

## 📚 Context Files by Domain

### 🤖 Agents
**File:** `@agents.md`
**Purpose:** Sub-agent orchestration patterns and architecture
**Load When:** Modifying agents, understanding agent coordination
**Token Budget:** ~2.5k tokens

### 🎮 Commands
**File:** `@commands.md`
**Purpose:** User-facing workflows and slash commands
**Load When:** Creating/modifying commands, understanding user interfaces
**Token Budget:** ~2k tokens

### 📖 Documentation
**File:** `@docs.md`
**Purpose:** Technical guides and documentation organization
**Load When:** Navigating documentation, finding specific guides
**Token Budget:** ~1.5k tokens

### ⚙️ Systems
**File:** `@systems.md`
**Purpose:** Infrastructure components and system-level patterns
**Load When:** Working with hooks, production orchestration, infrastructure
**Token Budget:** ~2k tokens

### 🔄 Workflows
**File:** `@workflows.md`
**Purpose:** Meta-prompting patterns and systematic methodologies
**Load When:** Understanding meta-prompting, workflow execution
**Token Budget:** ~1.5k tokens

### 🔍 Processes
**File:** `@processes.md`
**Purpose:** Validation procedures and assessment results
**Load When:** Running validations, checking process documentation
**Token Budget:** ~2k tokens

## 🎨 Claude 4 Best Practices Applied

### Selective Loading Pattern
```markdown
# Load only what you need:
- Agents work → @agents.md
- Commands work → @commands.md
- Multiple domains → Load specific files only
```

### Two-Hop Maximum Rule
```
Entry (CLAUDE.md) → This INDEX → Target Context
Never: CLAUDE.md → Context1 → Context2 → Context3 → Target
```

### Token Optimization
- **Total Budget:** ~12k tokens across all contexts
- **Per File:** <2.5k tokens maximum
- **Reserve:** 185k+ tokens for conversation

## 🔗 Quick Navigation

### Common Tasks
- **Research Pipeline:** Load `@agents.md` + `@commands.md`
- **Production Run:** Load `@systems.md` + `@commands.md`
- **Quality Check:** Load `@processes.md` + `@agents.md`
- **Documentation:** Load `@docs.md` only

### Emergency References
- **Troubleshooting:** `@.claude/context/troubleshooting_unified.md`
- **Quick Commands:** `@.claude/context/02_quick_reference.md`
- **Cost Management:** `@.claude/context/cost_optimization_unified.md`

## 📊 Context Management Rules

1. **No Duplication:** Each topic exists in exactly ONE file
2. **On-Demand Loading:** Use @ references, don't preload everything
3. **Clear Purpose:** Each file has specific operational use
4. **Size Limits:** Keep files under 10KB (2.5k tokens)

## 🚀 Usage Examples

### For Agent Development
```markdown
Load contexts:
@.claude/agent-context/agents.md
@.claude/agent-context/systems.md
```

### For Command Creation
```markdown
Load contexts:
@.claude/agent-context/commands.md
@.claude/agent-context/workflows.md
```

### For System Validation
```markdown
Load contexts:
@.claude/agent-context/processes.md
@.claude/agent-context/systems.md
```

## 🔍 File Status

| File | Size | Tokens | Last Updated | Status |
|------|------|--------|--------------|--------|
| agents.md | ~3KB | ~750 | 2025-08-30 | ✅ Active |
| commands.md | ~2KB | ~500 | 2025-08-30 | ✅ Active |
| docs.md | ~2KB | ~500 | 2025-08-30 | ✅ Active |
| systems.md | ~2KB | ~500 | 2025-08-30 | ✅ Active |
| workflows.md | ~1KB | ~250 | 2025-08-30 | ✅ Active |
| processes.md | ~2KB | ~500 | 2025-08-30 | ✅ Active |

---

**Remember:** Context engineering > Prompt engineering in 2025
**Principle:** Load less, achieve more
