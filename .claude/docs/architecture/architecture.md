# System Architecture - Sources of Truth


type="system-architecture"
version="1.0">
DRY Principle Enforcement
This document defines the SINGLE sources of truth for all system data. Any duplication violates the DRY principle and creates maintenance debt.
Episode Data
projects/nobody-knows/series_plan/episodes_master.json
All {TOTAL_EPISODES} episode titles
Episode descriptions
Complexity levels
Season organization
DO NOT duplicate episode data anywhere else
All commands and agents should read from this file dynamically
Production Configuration
projects/nobody-knows/config/project_config.json
Budget limits
Quality thresholds
Technical settings
API limits
DO NOT hardcode these values in commands or agents
Commands should read configuration at runtime
Philosophy & Brand Voice
projects/nobody-knows/series_plan/series_bible.md
Teaching philosophy
Brand voice
Narrative approach
Recurring segments
DO NOT duplicate philosophy statements across documentation
Agents should reference for content generation
Teaching Methodology
projects/nobody-knows/series_plan/teaching_philosophy.md
Educational principles
Episode structure
Pedagogical strategies
DO NOT recreate teaching approaches in individual agents
Script writers and quality evaluators should reference
Season Structure
projects/nobody-knows/series_plan/season_themes.json
Season themes
Complexity progression
Production notes
DO NOT hardcode season information elsewhere
Batch production and planning tools should reference
Read-only data flow from primary sources to operational consumers
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
Anti-Patterns to Avoid
Hardcoded Values
In some random file
The podcast has {TOTAL_EPISODES} episodes across {TOTAL_SEASONS} seasons...
WRONG: Hardcoded
In documentation
See episodes_master.json for episode details
RIGHT: Reference source
Duplicated Constants
Python code
TOTAL_EPISODES = 125  # WRONG: Duplicated constant
Dynamic loading
# Read from source
import json
with open('projects/nobody-knows/series_plan/episodes_master.json') as f:
episodes_data = json.load(f)
total_episodes = len(episodes_data['episodes'])
Episode titles/descriptions
episodes_master.json
projects/nobody-knows/series_plan/
Episode count (125)
episodes_master.json
Count array length
Season count (5)
episodes_master.json
Count seasons array
Budget limits
project_config.json
projects/nobody-knows/config/
Quality thresholds
project_config.json
.quality_thresholds section
Brand voice
series_bible.md
projects/nobody-knows/series_plan/
Teaching approach
teaching_philosophy.md
projects/nobody-knows/series_plan/
Season themes
season_themes.json
projects/nobody-knows/series_plan/
Where do I find episode topics?
projects/nobody-knows/series_plan/episodes_master.json
What's the budget per episode?
projects/nobody-knows/config/project_config.json → .cost_management.budget_per_episode
What's our brand voice?
projects/nobody-knows/series_plan/series_bible.md
How many episodes total?
Count episodes in episodes_master.json (currently 125)
What are the quality thresholds?
projects/nobody-knows/config/project_config.json → .quality_thresholds
Before adding any constant: Check if it already exists in a source file
Before hardcoding a value: Ask "Should this be read from a source?"
When updating episode data: Only update episodes_master.json
When changing configuration: Only update project_config.json
When refining philosophy: Only update series_bible.md
High-Level Documentation (README, CLAUDE.md)
Brief mentions for clarity (e.g., "125-episode AI series")
Include reference to source files

**Example:**
Operational Documentation (Commands, Agents)
MUST read from source files
Hardcoded values

**Example:**
Constants Files
Only for values that don't exist elsewhere
Add comments pointing to authoritative sources
Any constants that duplicate source data
Single Point of Update: Change data in ONE place only
No Sync Issues: Can't have conflicting values
Clear Hierarchy: Obvious where to find information
Flexible Production: Easy to work with episode subsets
Maintainable: Future changes are simple
Testable: Clear data contracts
Educational: Demonstrates proper system design

-
      Start by reading this file to understand the architecture

-
      Check the source files listed above for authoritative data

-
      Never duplicate data - always reference the sources

-
      When in doubt, ask: "Where is the single source of truth for this?"

-
      Identify which source file owns the data

-
      Make changes only in that source file

-
      Ensure consumers read the updated data dynamically

-
      Update this document if adding new sources of truth

---

*Converted from XML to Markdown for elegant simplicity*
*Original: architecture.xml*
*Conversion: Mon Aug 18 00:01:19 EDT 2025*
