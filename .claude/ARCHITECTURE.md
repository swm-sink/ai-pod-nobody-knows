# System Architecture - Sources of Truth 🏗️

## Critical: DRY Principle Enforcement

**This document defines the SINGLE sources of truth for all system data. Any duplication violates the DRY principle and creates maintenance debt.**

---

## 📍 Primary Sources of Truth

### 1. Episode Data
**Source**: `projects/nobody-knows/series_plan/episodes_master.json`
- **Contains**: All 125 episode titles, descriptions, complexity levels, season organization
- **DO NOT**: Duplicate episode data anywhere else
- **Reference**: All commands and agents should read from this file dynamically

### 2. Production Configuration  
**Source**: `projects/nobody-knows/config/project_config.json`
- **Contains**: Budget limits, quality thresholds, technical settings, API limits
- **DO NOT**: Hardcode these values in commands or agents
- **Reference**: Commands should read configuration at runtime

### 3. Philosophy & Brand Voice
**Source**: `projects/nobody-knows/series_plan/series_bible.md`
- **Contains**: Teaching philosophy, brand voice, narrative approach, recurring segments
- **DO NOT**: Duplicate philosophy statements across documentation
- **Reference**: Agents should reference for content generation

### 4. Teaching Methodology
**Source**: `projects/nobody-knows/series_plan/teaching_philosophy.md`
- **Contains**: Educational principles, episode structure, pedagogical strategies
- **DO NOT**: Recreate teaching approaches in individual agents
- **Reference**: Script writers and quality evaluators should reference

### 5. Season Structure
**Source**: `projects/nobody-knows/series_plan/season_themes.json`
- **Contains**: Season themes, complexity progression, production notes
- **DO NOT**: Hardcode season information elsewhere
- **Reference**: Batch production and planning tools should reference

---

## 🔄 Data Flow Architecture

```
┌─────────────────────────────────────┐
│     PRIMARY SOURCES (Truth)         │
├─────────────────────────────────────┤
│ • episodes_master.json              │ ← Episode details
│ • project_config.json               │ ← Production settings
│ • series_bible.md                   │ ← Philosophy
│ • teaching_philosophy.md            │ ← Pedagogy
│ • season_themes.json                │ ← Season structure
└──────────────┬──────────────────────┘
               │
               ↓ READ ONLY
┌─────────────────────────────────────┐
│    OPERATIONAL FILES (Consumers)    │
├─────────────────────────────────────┤
│ Commands:                           │
│ • produce-episode.md                │ → Reads episode from master
│ • batch-produce.md                  │ → Reads episodes from master
│                                     │
│ Agents:                             │
│ • research-coordinator.md           │ → References config
│ • script-writer.md                  │ → References philosophy
│ • quality-evaluator.md              │ → References quality gates
│ • audio-synthesizer.md              │ → References audio config
└─────────────────────────────────────┘
```

---

## ⚠️ Anti-Patterns to Avoid

### ❌ NEVER DO THIS:
```markdown
# In some random file
The podcast has 125 episodes across 5 seasons...  # WRONG: Hardcoded
```

### ✅ DO THIS INSTEAD:
```markdown
# In documentation
See episodes_master.json for episode details  # RIGHT: Reference source
```

### ❌ NEVER DO THIS:
```python
TOTAL_EPISODES = 125  # WRONG: Duplicated constant
```

### ✅ DO THIS INSTEAD:
```python
# Read from source
import json
with open('projects/nobody-knows/series_plan/episodes_master.json') as f:
    episodes_data = json.load(f)
    total_episodes = len(episodes_data['episodes'])
```

---

## 📋 Quick Reference Guide

| Data Type | Source File | Location |
|-----------|------------|----------|
| Episode titles/descriptions | episodes_master.json | `projects/nobody-knows/series_plan/` |
| Episode count (125) | episodes_master.json | Count array length |
| Season count (5) | episodes_master.json | Count seasons array |
| Budget limits | project_config.json | `projects/nobody-knows/config/` |
| Quality thresholds | project_config.json | `.quality_thresholds` section |
| Brand voice | series_bible.md | `projects/nobody-knows/series_plan/` |
| Teaching approach | teaching_philosophy.md | `projects/nobody-knows/series_plan/` |
| Season themes | season_themes.json | `projects/nobody-knows/series_plan/` |

---

## 🔍 How to Find Information

### "Where do I find episode topics?"
→ `projects/nobody-knows/series_plan/episodes_master.json`

### "What's the budget per episode?"
→ `projects/nobody-knows/config/project_config.json` → `.cost_management.budget_per_episode`

### "What's our brand voice?"
→ `projects/nobody-knows/series_plan/series_bible.md`

### "How many episodes total?"
→ Count episodes in `episodes_master.json` (currently 125)

### "What are the quality thresholds?"
→ `projects/nobody-knows/config/project_config.json` → `.quality_thresholds`

---

## 🚨 Maintenance Rules

1. **Before adding any constant**: Check if it already exists in a source file
2. **Before hardcoding a value**: Ask "Should this be read from a source?"
3. **When updating episode data**: Only update episodes_master.json
4. **When changing configuration**: Only update project_config.json
5. **When refining philosophy**: Only update series_bible.md

---

## 📝 Documentation Guidelines

### High-Level Documentation (README, CLAUDE.md)
- **Acceptable**: Brief mentions for clarity (e.g., "125-episode AI series")
- **Requirement**: Include reference to source files
- **Example**: "This system produces a 125-episode podcast series (see episodes_master.json)"

### Operational Documentation (Commands, Agents)
- **Requirement**: MUST read from source files
- **Forbidden**: Hardcoded values
- **Example**: Commands should load episode data at runtime

### Constants Files
- **Purpose**: Only for values that don't exist elsewhere
- **Requirement**: Add comments pointing to authoritative sources
- **Deprecate**: Any constants that duplicate source data

---

## 🎯 Benefits of This Architecture

1. **Single Point of Update**: Change data in ONE place only
2. **No Sync Issues**: Can't have conflicting values
3. **Clear Hierarchy**: Obvious where to find information
4. **Flexible Production**: Easy to work with episode subsets
5. **Maintainable**: Future changes are simple
6. **Testable**: Clear data contracts
7. **Educational**: Demonstrates proper system design

---

## 📚 For New Contributors

**First Time?**
1. Start by reading this file to understand the architecture
2. Check the source files listed above for authoritative data
3. Never duplicate data - always reference the sources
4. When in doubt, ask: "Where is the single source of truth for this?"

**Making Changes?**
1. Identify which source file owns the data
2. Make changes only in that source file
3. Ensure consumers read the updated data dynamically
4. Update this document if adding new sources of truth

---

*Last Updated: 2025-08-11*
*Principle: DRY (Don't Repeat Yourself) - One source of truth for everything*