# .claude Folder Organization Guide


type="folder-organization"
version="1.0">
.claude/
├── folder_structure.xml       # This file - explains organization
├── NAVIGATION_INDEX.xml       # Master navigation guide
├── README.md                  # .claude directory overview
├── 00_global_constants.xml    # Project-wide constants
├── CLAUDE.local.md            # Local settings documentation
├── settings.local.json        # User-specific Claude Code settings
├── .claudeignore              # Files to exclude from context
│
├── shared/                    # Resources used across ALL levels
│   ├── brand/                 # Brand voice, guidelines
│   │   └── brand_voice.md
│   ├── quality-gates/         # Quality thresholds, metrics
│   │   ├── FILE_REFERENCE_VALIDATION.md
│   │   ├── VALIDATION_CHECKLIST.md
│   │   └── WORKFLOW_TEST_REPORT.md
│   └── templates/             # Reusable templates
│       └── episode_structure.md
│
├── context/                   # Documentation &amp; learning guides (ALL levels)
│   ├── foundation/            # Project basics (6 files)
│   │   ├── 00_project_constants.md
│   │   ├── 01_project_overview.md
│   │   ├── 02_walk_crawl_run_phases.md
│   │   ├── 03_hobbyist_focus.md
│   │   ├── 04_no_api_keys_activities.md
│   │   ├── 05_learning_milestones.md
│   │   └── NAVIGATION.md
│   │
│   ├── ai-orchestration/      # AI concepts (3 files)
│   │   ├── 01_agent_orchestration_basics.md
│   │   ├── 02_cost_optimization_strategies.md
│   │   └── NAVIGATION.md
│   │
│   ├── claude-code/           # Claude Code features (13 files + cookbook)
│   │   ├── 00_claude_code_constants.md
│   │   ├── 15_claude_code_introduction.md through 25_thinking_modes_optimization.md
│   │   ├── agents-cookbook/   # Agent examples
│   │   └── NAVIGATION.md
│   │
│   ├── operations/            # Operational guides (5 files)
│   │   ├── 00_operations_constants.md
│   │   ├── 01_troubleshooting_guide.md
│   │   ├── 02_quick_reference.md
│   │   ├── 03_production_checklist.md
│   │   └── NAVIGATION.md
│   │
│   ├── quality/               # Quality requirements (6 files)
│   │   ├── 00_quality_constants.md
│   │   ├── 01_change_approval_requirements.md
│   │   ├── 02_hallucination_prevention_guide.md
│   │   ├── 03_tdd_requirements_specification.md
│   │   ├── 04_validation_workflow.md
│   │   ├── tdd_enforcement.xml
│   │   └── NAVIGATION.md
│   │
│   ├── elevenlabs/            # ElevenLabs integration (12 files)
│   │   ├── 00_elevenlabs_constants.md
│   │   ├── 15_elevenlabs_overview.md through 24_elevenlabs_troubleshooting.md
│   │   ├── README.md
│   │   └── NAVIGATION.md
│   │
│   ├── prompts_research/      # Prompt engineering research (10 files)
│   │   ├── 15_podcast_prompt_engineering.md through 23_comprehensive_context_roadmap.md
│   │   └── NAVIGATION.md
│   │
│   └── README.md              # Context directory overview
│
├── level-1-dev/               # Development Platform (builds the builders)
│   ├── agents/                # Agents that help development
│   │   ├── test-agent.md
│   │   └── file-validator.md
│   ├── commands/              # Commands for building tools
│   │   ├── agent-builder-dev.md
│   │   ├── command-builder-dev.md
│   │   ├── context-researcher-dev.md
│   │   ├── session-manager.md
│   │   ├── test-workflow.md
│   │   └── validate-project-structure.md
│   ├── sessions/              # Development work tracking
│   │   ├── development-session-template.json
│   │   └── test_session_20250811_1430.json
│   ├── templates/             # Templates for builders
│   │   ├── agent-template.yaml
│   │   └── command-template.yaml
│   ├── workflows/             # Development workflows
│   │   ├── core-workflows.md
│   │   ├── developer-experience.md
│   │   ├── level-1-overview.md
│   │   ├── quality-integration.md
│   │   └── README.md
│   ├── quality/               # Development quality checks
│   │   └── validation-checklist.md
│   ├── test-agent-builder.md
│   ├── test-command-builder.md
│   └── test-context-researcher.md
│
├── level-2-production/        # Podcast Production System
│   ├── agents/                # Production agents (research, script, etc.)
│   │   ├── research-coordinator.md
│   │   └── research-coordinator-tests.md
│   ├── commands/              # Production commands
│   │   ├── agent-builder-production.md
│   │   ├── command-builder-production.md
│   │   ├── autoproduce.md
│   │   ├── batch_produce.md
│   │   ├── project_create.md
│   │   ├── quality_check.md
│   │   └── system_optimize.md
│   └── sessions/              # Episode production tracking
│       └── episode-session-template.json
│
├── level-3-platform-dev/      # Platform Planning &amp; Design
│   └── openrouter/            # OpenRouter integration docs
│       ├── 00_openrouter_constants.md
│       ├── 25_openrouter_overview.md
│       ├── 26_openrouter_api_integration.md
│       ├── 27_openrouter_model_routing.md
│       ├── 28_openrouter_cost_optimization.md
│       ├── 29_openrouter_production_patterns.md
│       └── NAVIGATION.md
│
└── level-4-coded/             # Future Coded Platform (NO CODE YET)
└── [Reserved for future Python implementation]
Level Separation
Each level has its own directory
Don't mix tools between levels
Use level-specific builders
Shared Resources
Brand voice used by all levels → shared/brand/
Quality metrics used by all levels → shared/quality-gates/
Common templates → shared/templates/
Context is Global
All documentation stays in context/
Used by all levels for learning and reference
Not duplicated per level
Clear Naming
Development tools end with -dev
Production tools end with -production
No ambiguity about which level you're in
Consistent Numbering
00-09: Constants and foundations
10-29: Core concepts and features
30-49: Implementation guides
50-69: Advanced topics
70-89: Troubleshooting and reference
90-99: Meta documentation
What Goes Where?
Creating a new development tool?

### Setup Instructions


- 
        Use level-1-dev/commands/agent-builder-dev.md

- 
        Save to level-1-dev/agents/ or level-1-dev/commands/
Creating a podcast production agent?

### Setup Instructions


- 
        Use level-2-production/commands/agent-builder-production.md

- 
        Save to level-2-production/agents/
Documenting how something works?

### Setup Instructions


- 
        Add to appropriate context/ subfolder
Planning the future platform?

### Setup Instructions


- 
        Work in level-3-platform-dev/
Want to write Python code?

### Setup Instructions


- 
        STOP! Get approval first

- 
        Document plan in level-4-coded/documentation/
~100 markdown files
28 (after cleanup from 61)
7 (properly scoped)
8 (hierarchical)
33
Removed 33 empty directories
Consolidated duplicate ElevenLabs files
Fixed file numbering inconsistencies
Moved context folder to correct location
Created OpenRouter documentation in level-3
Moved CLAUDE.md to project root
Added file operations best practices
All constants centralized in 00_*_constants.md files
No duplicate information across files
All values reference constants
Cross-references use links, not duplication
Use @ References: All files support @filename.md quick navigation
Start with NAVIGATION_INDEX.xml: Master guide to all content
Follow Constants: Always check 00_*_constants.md first
Check NAVIGATION.md: Each context folder has its own guide
Use Find Command: find .claude -name "pattern" for searches

---

*Converted from XML to Markdown for elegant simplicity*
*Original: folder_structure.xml*
*Conversion: Mon Aug 18 00:01:19 EDT 2025*
