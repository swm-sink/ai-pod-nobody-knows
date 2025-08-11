# .claude Folder Organization Guide

## Structure Overview

```
.claude/
├── FOLDER_STRUCTURE.md        # This file - explains organization
├── settings.local.json         # User-specific Claude Code settings
├── .claudeignore              # Files to exclude from context
│
├── shared/                    # Resources used across ALL levels
│   ├── templates/             # Reusable templates
│   ├── brand/                 # Brand voice, guidelines
│   └── quality-gates/         # Quality thresholds, metrics
│
├── context/                   # Documentation & learning guides (ALL levels)
│   ├── foundation/            # Project basics
│   ├── ai-orchestration/      # AI concepts
│   ├── claude-code/           # Claude Code features
│   ├── operations/            # Operational guides
│   └── quality/               # Quality requirements
│
├── level-1-dev/               # Development Platform (builds the builders)
│   ├── agents/                # Agents that help development
│   ├── commands/              # Commands for building tools
│   │   ├── agent-builder-dev.md
│   │   ├── command-builder-dev.md
│   │   └── context-researcher-dev.md
│   ├── sessions/              # Development work tracking
│   └── templates/             # Templates for builders
│
├── level-2-production/        # Podcast Production System
│   ├── agents/                # Production agents (research, script, etc.)
│   ├── commands/              # Production commands
│   │   ├── agent-builder-production.md
│   │   ├── command-builder-production.md
│   │   ├── produce-episode.md (TBD)
│   │   └── [legacy commands moved here]
│   ├── sessions/              # Episode production tracking
│   └── output/                # Generated episodes
│       └── episode_XXX/       # Per-episode artifacts
│
├── level-3-platform-dev/      # Platform Planning & Design
│   ├── requirements/          # System requirements docs
│   ├── architecture/          # Technical design docs
│   ├── migration/             # Native-to-coded migration plans
│   └── testing/               # Test strategies
│
└── level-4-coded/             # Future Coded Platform (NO CODE YET)
    └── documentation/         # Plans only - requires approval
```

## Key Principles

### 1. Level Separation
- Each level has its own directory
- Don't mix tools between levels
- Use level-specific builders

### 2. Shared Resources
- Brand voice used by all levels → `shared/brand/`
- Quality metrics used by all levels → `shared/quality-gates/`
- Common templates → `shared/templates/`

### 3. Context is Global
- All documentation stays in `context/`
- Used by all levels for learning and reference
- Not duplicated per level

### 4. Clear Naming
- Development tools end with `-dev`
- Production tools end with `-production`
- No ambiguity about which level you're in

## What Goes Where?

### Creating a new development tool?
→ Use `level-1-dev/commands/agent-builder-dev.md`
→ Save to `level-1-dev/agents/` or `level-1-dev/commands/`

### Creating a podcast production agent?
→ Use `level-2-production/commands/agent-builder-production.md`
→ Save to `level-2-production/agents/`

### Documenting how something works?
→ Add to appropriate `context/` subfolder

### Planning the future platform?
→ Work in `level-3-platform-dev/`

### Want to write Python code?
→ STOP! Get approval first. Document plan in `level-4-coded/documentation/`

## Common Files

### Root Level (.claude/)
- `FOLDER_STRUCTURE.md` - This guide
- `settings.local.json` - Your Claude Code settings
- `.claudeignore` - Exclude patterns

### Each Level Has
- `agents/` - Level-specific agents
- `commands/` - Level-specific commands  
- `sessions/` - Work tracking
- `templates/` - Level-specific templates

## Remember
1. **Always check which level you're working in**
2. **Use the right builder for your level**
3. **Don't create Python code without approval (Level 4)**
4. **Keep shared resources in `shared/`**
5. **Document everything in `context/`**