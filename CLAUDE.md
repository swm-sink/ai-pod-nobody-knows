<document type="system-documentation" version="3.0.0">
  <metadata>
    <last-updated>2025-08-10</last-updated>
    <requires-approval>true</requires-approval>
    <validation-status>claude-code-2025-optimized</validation-status>
    <claude-code-version>2025-advanced</claude-code-version>
    <context-management>hierarchical-xml-semantic</context-management>
  </metadata>

  <change-control>
    <critical-requirement>
      ANY modification to this document requires:
      1. User explicit approval BEFORE changes
      2. AI detailed impact assessment
      3. Validation through research (3+ sources)
      4. User confirmation AFTER implementation
    </critical-requirement>
  </change-control>

  <dry-principle-enforcement>
    <critical-requirement type="MANDATORY">
      DRY (Don't Repeat Yourself) PRINCIPLE MUST BE ENFORCED:
      
      1. BEFORE creating ANY new documentation:
         - Check if information already exists elsewhere
         - Reference existing content instead of duplicating
         - Use constants files for all repeated values
      
      2. CONSTANTS FILE HIERARCHY:
         - Global: .claude/00_GLOBAL_CONSTANTS.md (project-wide values)
         - Domain: .claude/context/*/00_*_constants.md (domain-specific)
         - Reference these instead of hardcoding values
      
      3. PROHIBITED DUPLICATIONS:
         - Project specifications (name, duration, costs)
         - API configurations and endpoints
         - Command definitions and syntax
         - Error codes and messages
         - File paths and directory structures
      
      4. REQUIRED PATTERNS:
         - Use: "See [Constants](./00_constants.md#section)"
         - Not: Hardcoded values or copy-pasted content
         - Create: Single source of truth for each piece of information
      
      5. VALIDATION BEFORE CREATION:
         - Run: grep -r "search_term" .claude/
         - Check: Does this information exist already?
         - Decide: Reference or create new (if truly unique)
    </critical-requirement>
    
    <enforcement-rules>
      <rule>Every file creation must check for existing content first</rule>
      <rule>Every constant value must be extracted to constants files</rule>
      <rule>Every reference must use links, not duplication</rule>
      <rule>Every update must maintain single source of truth</rule>
    </enforcement-rules>
  </dry-principle-enforcement>

  <claude-code-integration>
    <memory-management>
      <type>project-level</type>
      <hierarchy>root-level</hierarchy>
      <auto-loaded>true</auto-loaded>
      <context-priority>highest</context-priority>
    </memory-management>
    
    <performance-optimization>
      <xml-semantic-tagging>enabled</xml-semantic-tagging>
      <comprehension-boost>40-percent</comprehension-boost>
      <context-window-efficiency>optimized</context-window-efficiency>
    </performance-optimization>
    
    <advanced-features>
      <hooks-integration>configured</hooks-integration>
      <mcp-servers>enabled</mcp-servers>
      <custom-commands>enabled</custom-commands>
      <thinking-modes>ultrathink-available</thinking-modes>
    </advanced-features>
  </claude-code-integration>

  <file-operations-best-practices>
    <critical-requirement type="MANDATORY">
      FILE OPERATIONS BEST PRACTICES FOR CLAUDE:
      
      1. DIRECTORY VERIFICATION:
         - ALWAYS use explicit paths (no assumptions)
         - Use find command for comprehensive searches
         - Check hidden folders with ls -la
         - Verify existence before operations
      
      2. WHEN SEARCHING FOR FILES:
         - Use: find /full/path -name "pattern" -type f
         - Not: ls pattern (may miss hidden files)
         - Use: grep -r for content searches
         - Always specify full paths
      
      3. WHEN MOVING/DELETING:
         - Verify source exists first
         - Check git status before bulk operations
         - Use -i flag for interactive confirmation when risky
         - Create backups for critical operations
      
      4. COMMON PITFALLS TO AVOID:
         - Hidden folders may not show in basic ls
         - Empty directory removal may cascade
         - Relative paths can be ambiguous
         - Shell expansion may not work as expected
      
      5. VERIFICATION COMMANDS:
         - find /path -type d (find all directories)
         - find /path -type f -name "*.md" (find files by pattern)
         - ls -la /path/ (show all including hidden)
         - git status --porcelain (check git state)
    </critical-requirement>
  </file-operations-best-practices>

# CLAUDE.md - Your AI Podcast Learning Project 🎓

<welcome>
  <greeting>WELCOME HOBBYIST!</greeting>
  <purpose>
    This is YOUR personal learning project - A hands-on way to master AI agent orchestration 
    by building an automated podcast production system. You're not building for a company; 
    you're building for your own learning and enjoyment!
  </purpose>
</welcome>

<context-files>
  <instruction>Read these files in order to understand your journey - Click @ references for instant navigation!</instruction>
  <navigation-master>@NAVIGATION_INDEX.md - Master navigation guide for @ file hopping</navigation-master>
  
  <learning-progression>
    <file number="1" ref="@01_project_overview.md">What this project is all about → @02_walk_crawl_run_phases.md</file>
    <file number="2" ref="@02_walk_crawl_run_phases.md">Your learning progression → @03_hobbyist_focus.md</file>
    <file number="3" ref="@03_hobbyist_focus.md">Why this is perfect for YOU → @04_no_api_keys_activities.md</file>
    <file number="4" ref="@04_no_api_keys_activities.md">Learn for FREE first! → @05_agent_orchestration_basics.md</file>
  </learning-progression>
  
  <core-concepts>
    <file number="5" ref="@05_agent_orchestration_basics.md">Core concepts explained simply → @06_cost_optimization_strategies.md</file>
    <file number="6" ref="@06_cost_optimization_strategies.md">Save money while learning → @07_learning_milestones.md</file>
    <file number="7" ref="@07_learning_milestones.md">Track your achievements → @08_troubleshooting_guide.md</file>
  </core-concepts>
  
  <operations-workflow>
    <file number="8" ref="@08_troubleshooting_guide.md">When things go wrong (they will!) → @09_quick_reference.md</file>
    <file number="9" ref="@09_quick_reference.md">Quick commands and snippets → @10_production_checklist.md</file>
    <file number="10" ref="@10_production_checklist.md">Step-by-step production guide</file>
  </operations-workflow>
  
  <quality-assurance>
    <file number="11" ref="@11_change_approval_requirements.md">MANDATORY change control → @12_hallucination_prevention_guide.md</file>
    <file number="12" ref="@12_hallucination_prevention_guide.md">MANDATORY validation requirements → @13_tdd_requirements_specification.md</file>
    <file number="13" ref="@13_tdd_requirements_specification.md">MANDATORY TDD requirements → @14_validation_workflow.md</file>
    <file number="14" ref="@14_validation_workflow.md">Step-by-step validation process</file>
  </quality-assurance>
  
  <claude-code-mastery>
    <file number="15" ref="@15_claude_code_introduction.md">Claude Code basics → @16_memory_management_system.md</file>
    <file number="16" ref="@16_memory_management_system.md">Memory management → @17_command_reference_guide.md</file>
    <file number="17" ref="@17_command_reference_guide.md">Commands and automation → @18_file_operations_guide.md</file>
    <file number="18" ref="@18_file_operations_guide.md">Advanced file operations</file>
  </claude-code-mastery>
</context-files>

<current-phase>
  <phase-name>WALK</phase-name>
  <description>No API Keys Needed!</description>
  <note>You can learn for WEEKS without spending any money!</note>
  <reference>See .claude/context/04_no_api_keys_activities.md for everything you can do right now.</reference>
</current-phase>

<learning-goals>
  <goal>Understand how AI agents work together</goal>
  <goal>Learn to optimize costs (from $50 to $4 per episode!)</goal>
  <goal>Build a real podcast while learning</goal>
  <goal>Master prompt engineering</goal>
  <goal>Gain confidence with AI tools</goal>
</learning-goals>

<quick-start>
  <section name="Setup Without API Keys">
    <step number="1">
      <description>Set up your environment</description>
      <commands>
        python -m venv venv
        source venv/bin/activate  # Windows: venv\Scripts\activate
        pip install -r requirements.txt
      </commands>
    </step>
    
    <step number="2">
      <description>Start the server locally</description>
      <command>uvicorn core.orchestration.server:app --reload</command>
    </step>
    
    <step number="3">
      <description>Visit the API docs</description>
      <action>Open browser: http://localhost:8000/docs</action>
    </step>
    
    <step number="4">
      <description>Create a test project (works offline!)</description>
      <command>
        curl -X POST http://localhost:8000/projects \
          -H "Content-Type: application/json" \
          -d '{"project_name": "my-test", "episode_duration": 27}'
      </command>
    </step>
  </section>
</quick-start>

<project-description>
  <name>Nobody Knows Podcast</name>
  <description>A 100-episode educational series about the limits of human knowledge</description>
  <specifications>
    <spec>27-minute episodes</spec>
    <spec>Intellectual humility as core theme</spec>
    <spec>Progressive complexity across 10 seasons</spec>
    <spec>Cost: $4-8 per episode (vs traditional $800-3500!)</spec>
  </specifications>
</project-description>

<ai-agents>
  <agent name="Research Coordinator" icon="📚">Gathers information</agent>
  <agent name="Script Writer" icon="✍️">Creates engaging content</agent>
  <agent name="Audio Synthesizer" icon="🎙️">Generates speech</agent>
  <agent name="Quality Evaluator" icon="✅">Ensures quality</agent>
  <note>Each agent teaches you different AI concepts!</note>
</ai-agents>

<project-structure>
  ```
  ai-podcasts-nobody-knows/
  ├── .claude/                    # 🧠 Claude Code configuration
  │   ├── CLAUDE.md              # 📄 This file! (auto-loaded)
  │   ├── CLAUDE.local.md        # 🔒 Personal notes (git-ignored)
  │   ├── level-1-dev/           # 🔧 Development platform (builds the builders)
  │   │   ├── agents/            # Development agents
  │   │   ├── commands/          # agent-builder-dev, command-builder-dev
  │   │   ├── sessions/          # Development tracking
  │   │   └── templates/         # Templates for builders
  │   ├── level-2-production/    # 🎙️ Podcast production system (native)
  │   │   ├── agents/            # research, script, audio, quality agents
  │   │   ├── commands/          # produce-episode, batch-production
  │   │   ├── sessions/          # Episode production tracking
  │   │   └── output/            # Episode artifacts
  │   ├── level-3-platform-dev/  # 📋 Platform planning (future architecture)
  │   │   ├── requirements/      # Platform specifications
  │   │   ├── architecture/      # System design docs
  │   │   └── migration/         # Native to coded transition
  │   ├── level-4-coded/         # 🚫 Future coded platform (REQUIRES APPROVAL)
  │   │   └── documentation/     # Plans only - NO CODE without approval
  │   └── context/               # 📚 Your learning guides (START HERE!)
  ├── core/                      # 🤖 Agent implementations (DELETED - TDD required)
  ├── projects/                  # 🎙️ Your podcast projects
  ├── requirements.txt           # 📦 Python packages
  ├── .claudeignore             # 🚫 Files to exclude from context
  └── .env.example              # 🔐 API key template
  ```
</project-structure>

<four-level-architecture>
  <critical-importance>
    THIS PROJECT USES A 4-LEVEL ARCHITECTURE TO SEPARATE CONCERNS.
    EACH LEVEL HAS DISTINCT PURPOSE AND TOOLS. DO NOT MIX LEVELS!
  </critical-importance>
  
  <level number="1" name="Claude Code Development Platform">
    <purpose>Build the tools that build the production system</purpose>
    <location>.claude/level-1-dev/</location>
    <key-commands>
      <command>agent-builder-dev: Creates development agents</command>
      <command>command-builder-dev: Creates development commands</command>
      <command>context-researcher-dev: Researches and documents</command>
    </key-commands>
    <when-to-use>When building new capabilities for Claude Code itself</when-to-use>
  </level>
  
  <level number="2" name="Podcast Production System">
    <purpose>The actual podcast production using Claude Code native features</purpose>
    <location>.claude/level-2-production/</location>
    <key-commands>
      <command>agent-builder-production: Creates podcast agents</command>
      <command>produce-episode: Orchestrates full production</command>
    </key-commands>
    <agents>
      <agent>research-coordinator: Gathers episode information</agent>
      <agent>script-writer: Creates episode narrative</agent>
      <agent>audio-synthesizer: Generates speech via ElevenLabs</agent>
      <agent>quality-evaluator: Validates output quality</agent>
    </agents>
    <when-to-use>When producing actual podcast episodes</when-to-use>
  </level>
  
  <level number="3" name="Platform Development Environment">
    <purpose>Plan and design the future coded platform</purpose>
    <location>.claude/level-3-platform-dev/</location>
    <activities>Requirements gathering, architecture design, migration planning</activities>
    <when-to-use>When planning how to migrate from native to coded solution</when-to-use>
  </level>
  
  <level number="4" name="Coded Platform">
    <purpose>Future Python/FastAPI implementation</purpose>
    <location>.claude/level-4-coded/</location>
    <status>REQUIRES EXPLICIT APPROVAL - DO NOT START</status>
    <note>Documentation only until approval given</note>
  </level>
  
  <usage-rules>
    <rule>ALWAYS work in the correct level directory</rule>
    <rule>Use level-specific builders (dev vs production)</rule>
    <rule>Track work in level-appropriate session files</rule>
    <rule>Do NOT create Python code without explicit approval (Level 4)</rule>
  </usage-rules>
</four-level-architecture>

<context-management-system>
  <hierarchy>
    <level priority="1" scope="global">~/.claude/CLAUDE.md (Personal preferences)</level>
    <level priority="2" scope="project">./CLAUDE.md (This file - project conventions)</level>
    <level priority="3" scope="directory">subdirectory/CLAUDE.md (Local overrides)</level>
    <level priority="4" scope="personal">CLAUDE.local.md (Git-ignored personal notes)</level>
  </hierarchy>
  
  <memory-patterns>
    <pattern name="bootstrap">Use /init to generate initial project memory</pattern>
    <pattern name="checkpoint">Update memory before major changes</pattern>
    <pattern name="context-clearing">Use /clear frequently, /compact for summarization</pattern>
    <pattern name="memory-update">Use # to quickly add memories during sessions</pattern>
  </memory-patterns>
  
  <optimization-strategies>
    <strategy>XML semantic tagging for 40% better comprehension</strategy>
    <strategy>Hierarchical context loading (most specific first)</strategy>
    <strategy>Regular context window cleaning with /clear</strategy>
    <strategy>.claudeignore to exclude irrelevant files</strategy>
  </optimization-strategies>
</context-management-system>

<claude-code-features>
  <thinking-modes>
    <mode level="1" trigger="think">Basic reasoning</mode>
    <mode level="2" trigger="think hard">Enhanced analysis</mode>
    <mode level="3" trigger="think harder">Deep exploration</mode>
    <mode level="4" trigger="ultrathink">Maximum thinking budget</mode>
  </thinking-modes>
  
  <workflow-automation>
    <hooks>
      <hook event="pre-tool-use">Run linting/formatting before file changes</hook>
      <hook event="post-tool-use">Execute tests after code modifications</hook>
      <hook event="session-complete">Generate session summary and commit</hook>
    </hooks>
    
    <mcp-integration>
      <server name="github">GitHub API integration for issues, PRs</server>
      <server name="filesystem">Enhanced file operations</server>
      <server name="web-search">Real-time information retrieval</server>
    </mcp-integration>
  </workflow-automation>
  
  <productivity-features>
    <custom-commands>Project-specific workflows in .claude/commands/</custom-commands>
    <tab-completion>Quick file and folder reference</tab-completion>
    <escape-interruption>Stop and redirect Claude anytime</escape-interruption>
    <session-continuity>Context preservation across interruptions</session-continuity>
  </productivity-features>
</claude-code-features>

<learning-integration>
  <hobbyist-approach>
    <principle>Learn AI orchestration through practical podcast creation</principle>
    <principle>Progress from free activities to paid API usage</principle>
    <principle>Build real skills while creating something you enjoy</principle>
    <principle>No enterprise pressure - learn at your own pace</principle>
  </hobbyist-approach>
  
  <skill-progression>
    <phase name="WALK">Master Claude Code basics, context management, local development</phase>
    <phase name="CRAWL">Add API integrations, hooks, custom commands</phase>
    <phase name="RUN">Advanced automation, MCP servers, production workflows</phase>
  </skill-progression>
  
  <learning-checkpoints>
    <checkpoint>First successful /init command execution</checkpoint>
    <checkpoint>Custom slash command creation</checkpoint>
    <checkpoint>Hook configuration for automated testing</checkpoint>
    <checkpoint>MCP server integration</checkpoint>
    <checkpoint>Full podcast production pipeline</checkpoint>
  </learning-checkpoints>
</learning-integration>

<learning-path>
  <phase number="1" name="WALK" duration="Weeks 1-4" cost="FREE">
    <activities>
      <activity>Set up environment ✅</activity>
      <activity>Understand the code</activity>
      <activity>Create manual scripts</activity>
      <activity>Test without APIs</activity>
    </activities>
  </phase>
  
  <phase number="2" name="CRAWL" duration="Weeks 5-12" cost="$20-50">
    <activities>
      <activity>Connect first API</activity>
      <activity>Produce first episode</activity>
      <activity>Learn from errors</activity>
      <activity>Optimize costs</activity>
    </activities>
  </phase>
  
  <phase number="3" name="RUN" duration="Weeks 13+" cost="$50-100/month">
    <activities>
      <activity>Automate production</activity>
      <activity>Batch processing</activity>
      <activity>Advanced features</activity>
      <activity>Share your podcast!</activity>
    </activities>
  </phase>
</learning-path>

<cost-progression>
  <month number="1" cost="$20-30/episode">Learning phase</month>
  <month number="2" cost="$10-15/episode">Improving phase</month>
  <month number="3" cost="$5-8/episode">Optimizing phase</month>
  <month number="4+" cost="$4-5/episode">Mastered!</month>
</cost-progression>

<claude-code-commands>
  <section name="Context Management">
    <command purpose="Initialize project memory">/init</command>
    <command purpose="Clear conversation">/clear</command>
    <command purpose="Compact conversation">/compact</command>
    <command purpose="Add quick memory"># [your memory note]</command>
    <command purpose="Open memory file">/memory</command>
  </section>
  
  <section name="Thinking Modes">
    <command purpose="Basic reasoning">think about this problem</command>
    <command purpose="Enhanced analysis">think hard about the architecture</command>
    <command purpose="Deep exploration">think harder about edge cases</command>
    <command purpose="Maximum thinking">ultrathink the complete solution</command>
  </section>
  
  <section name="MCP Integration">
    <command purpose="Add MCP server">claude mcp add [server-name]</command>
    <command purpose="List MCP servers">claude mcp list</command>
    <command purpose="Use MCP resource">@[resource-name]</command>
    <command purpose="MCP slash command">/mcp__servername__promptname</command>
  </section>
  
  <section name="Custom Commands">
    <command purpose="Create command">mkdir -p .claude/commands && echo "Prompt text" > .claude/commands/mycommand.md</command>
    <command purpose="Use custom command">/mycommand</command>
    <command purpose="Command with args">/mycommand arg1 arg2</command>
  </section>
  
  <section name="Productivity Features">
    <command purpose="Tab completion">[Tab] for files/folders</command>
    <command purpose="Interrupt Claude">[Escape] to stop/redirect</command>
    <command purpose="Edit previous prompt">[Escape][Escape] to go back</command>
    <command purpose="File reference">@filename.py</command>
  </section>
</claude-code-commands>

<essential-commands>
  <section name="Daily Use">
    <command purpose="Activate environment">source venv/bin/activate</command>
    <command purpose="Start server">uvicorn core.orchestration.server:app --reload</command>
    <command purpose="Check costs">grep "Cost:" logs/*.log | tail -10</command>
  </section>
  
  <section name="When Ready for APIs">
    <command purpose="Copy environment template">cp .env.example .env</command>
    <command purpose="Edit API keys">nano .env</command>
    <command purpose="Test API connection">python test_apis.py</command>
  </section>
</essential-commands>

<troubleshooting>
  <checklist>
    <item>Is virtual environment activated?</item>
    <item>Are you in the right directory?</item>
    <item>Check .claude/context/08_troubleshooting_guide.md</item>
    <item>Google the exact error message</item>
    <item>Ask Claude.ai for help</item>
  </checklist>
</troubleshooting>

<quality-targets>
  <note>Don't worry about these yet - focus on learning first!</note>
  <target name="Comprehension" threshold="≥0.85"/>
  <target name="Brand Consistency" threshold="≥0.90"/>
  <target name="Engagement" threshold="≥0.80"/>
  <target name="Technical" threshold="≥0.85"/>
</quality-targets>

<milestones>
  <milestone>Environment set up</milestone>
  <milestone>Server running locally</milestone>
  <milestone>First manual script written</milestone>
  <milestone>First API connected</milestone>
  <milestone>First episode produced</milestone>
  <milestone>Episode under $10</milestone>
  <milestone>Episode under $5</milestone>
  <milestone>10 episodes complete</milestone>
  <milestone>100 EPISODES! 🎉</milestone>
</milestones>

<pro-tips>
  <tip number="1">Start FREE - Do everything in .claude/context/04_no_api_keys_activities.md first</tip>
  <tip number="2">Learn Slowly - Understanding > Speed</tip>
  <tip number="3">Track Everything - Keep a learning journal</tip>
  <tip number="4">Ask Questions - Use Claude.ai free tier for explanations</tip>
  <tip number="5">Have Fun - This is your hobby, enjoy it!</tip>
</pro-tips>

<security-reminder>
  <rule>NEVER commit API keys to git</rule>
  <rule>Keep .env file private</rule>
  <rule>Use .env.example as template</rule>
  <rule>Test with mock data first</rule>
</security-reminder>

<help-resources>
  <step number="1">First: Check .claude/context/ files</step>
  <step number="2">Then: Try the troubleshooting guide</step>
  <step number="3">Finally: Ask in communities or Claude.ai</step>
</help-resources>

<next-steps>
  <step number="1">Read .claude/context/01_project_overview.md</step>
  <step number="2">Follow .claude/context/02_walk_crawl_run_phases.md</step>
  <step number="3">Complete activities in .claude/context/04_no_api_keys_activities.md</step>
  <step number="4">Track progress with .claude/context/07_learning_milestones.md</step>
</next-steps>

<critical-requirements>
  <requirement type="change-control">
    ALL changes require user approval - see context/11_change_approval_requirements.md
  </requirement>
  <requirement type="validation">
    ALL information must be validated - see context/12_hallucination_prevention_guide.md
  </requirement>
  <requirement type="development">
    ALL code must follow TDD - see context/13_tdd_requirements_specification.md
  </requirement>
  <requirement type="workflow">
    ALL validation must follow process - see context/14_validation_workflow.md
  </requirement>
  <requirement type="quality-standards">
    ALL operations must comply with QUALITY ENFORCEMENT STANDARDS - see section below for mandatory requirements
  </requirement>
  <requirement type="education" level="MANDATORY">
    <feynman-teaching-approach>
      For EVERY action or concept, Claude must explain using DUAL approach:
      
      1. TECHNICAL EXPLANATION (The Right Way):
         - Precise technical terminology
         - Industry-standard concepts
         - Professional implementation details
         - Why it's done this way in production
      
      2. SIMPLE BREAKDOWN (Feynman Approach):
         - Explain like teaching a curious friend
         - Use analogies and everyday examples
         - Break complex ideas into simple steps
         - Focus on understanding, not memorization
    </feynman-teaching-approach>
    
    <teaching-format>
      Structure: "Here's what we're doing and why..."
      Technical: [Professional explanation]
      Simple: "Think of it like..." [Analogy-based explanation]
      Connection: "This helps you learn..." [Learning value]
    </teaching-format>
    
    <mandatory-for>
      - Every code concept introduced
      - Every system architecture decision
      - Every configuration change
      - Every troubleshooting step
      - Every optimization technique
    </mandatory-for>
  </requirement>
  <requirement type="quality-enforcement">
    ALL operations must adhere to comprehensive quality standards - see QUALITY ENFORCEMENT STANDARDS section below
  </requirement>
</critical-requirements>

<QUALITY-ENFORCEMENT-STANDARDS>
  <critical-importance>
    THESE STANDARDS ARE MANDATORY FOR ALL OPERATIONS.
    FAILURE TO FOLLOW THESE STANDARDS INVALIDATES ANY WORK PERFORMED.
    STRICT ENFORCEMENT IS REQUIRED - NO EXCEPTIONS.
  </critical-importance>

  <anti-hallucination-requirements>
    <verification-mandate>
      <rule type="MANDATORY">VERIFY before claiming: Every statement must be verifiable through actual tools or research</rule>
      <rule type="MANDATORY">RESEARCH before documenting: Use Grep, Read, LS, or other verification tools to confirm information</rule>
      <rule type="MANDATORY">TEST before implementing: Run actual validation commands to ensure functionality</rule>
      <rule type="MANDATORY">SOURCE attribution required: Cite specific files, line numbers, or tool outputs for every claim</rule>
      <rule type="MANDATORY">NO assumptions: If uncertain, explicitly state "UNVERIFIED - requires validation"</rule>
      <rule type="MANDATORY">VALIDATION commands: Include specific test commands for every technical claim</rule>
      <rule type="MANDATORY">ERROR acknowledgment: Admit immediately when something cannot be verified</rule>
    </verification-mandate>
    
    <validation-examples>
      <example type="file-existence">
        WRONG: "The config file exists at .claude/config.json"
        RIGHT: "Verification needed: ls .claude/config.json || echo 'File not found'"
      </example>
      <example type="directory-structure">
        WRONG: "The sessions directory contains tracking files"
        RIGHT: "Directory contents verified: ls -la .claude/level-2-production/sessions/"
      </example>
      <example type="command-functionality">
        WRONG: "This command will work: python script.py"
        RIGHT: "Command validation: python -c 'import sys; print(sys.executable)' && python --version"
      </example>
    </validation-examples>
    
    <uncertainty-handling>
      <when-uncertain>Use phrases like "UNVERIFIED", "REQUIRES VALIDATION", "CANNOT CONFIRM WITHOUT TESTING"</when-uncertain>
      <verification-first>Always attempt verification through tools before making claims</verification-first>
      <explicit-limitations>State clearly what cannot be verified and why</explicit-limitations>
    </uncertainty-handling>
  </anti-hallucination-requirements>

  <directory-organization-principles>
    <separation-mandate>
      <rule type="MANDATORY">One purpose per directory: Each directory serves exactly one function</rule>
      <rule type="MANDATORY">Clear naming conventions: Use descriptive-lowercase-hyphenated names</rule>
      <rule type="MANDATORY">No cross-level dependencies: Level 1 cannot import from Level 2, etc.</rule>
      <rule type="MANDATORY">Separation of concerns: Development tools separate from production tools</rule>
      <rule type="MANDATORY">File placement rules: Config in root, templates in templates/, sessions in sessions/</rule>
      <rule type="MANDATORY">No orphan files: Every file must have a clearly defined organizational home</rule>
      <rule type="MANDATORY">Documentation location: All documentation in context/ directory, organized by topic</rule>
    </separation-mandate>
    
    <directory-structure-enforcement>
      <level-1-dev>
        <purpose>Development platform tools ONLY</purpose>
        <allowed-contents>agents/, commands/, sessions/, templates/</allowed-contents>
        <forbidden-contents>Production data, episode content, API integrations</forbidden-contents>
      </level-1-dev>
      <level-2-production>
        <purpose>Podcast production ONLY</purpose>
        <allowed-contents>agents/, commands/, sessions/, output/</allowed-contents>
        <forbidden-contents>Development tools, platform code, planning documents</forbidden-contents>
      </level-2-production>
      <level-3-platform-dev>
        <purpose>Platform planning ONLY</purpose>
        <allowed-contents>requirements/, architecture/, migration/</allowed-contents>
        <forbidden-contents>Actual code, production data, current tools</forbidden-contents>
      </level-3-platform-dev>
      <level-4-coded>
        <purpose>Future implementation ONLY</purpose>
        <allowed-contents>documentation/ ONLY until approval granted</allowed-contents>
        <forbidden-contents>ANY CODE without explicit user approval</forbidden-contents>
      </level-4-coded>
    </directory-structure-enforcement>
    
    <naming-standards>
      <directories>lowercase-with-hyphens (e.g., level-2-production, context-management)</directories>
      <files>descriptive-lowercase-with-extension (e.g., episode-production-session.json)</files>
      <commands>verb-noun-format (e.g., produce-episode, validate-quality)</commands>
      <agents>role-descriptor-format (e.g., research-coordinator, quality-evaluator)</agents>
    </naming-standards>
  </directory-organization-principles>

  <dry-enforcement>
    <single-source-truth>
      <rule type="MANDATORY">One canonical location: Each piece of information exists in exactly one authoritative place</rule>
      <rule type="MANDATORY">Shared resources: Common elements must be placed in .claude/shared/ directory</rule>
      <rule type="MANDATORY">Template usage: Use templates for repetitive structures instead of copying</rule>
      <rule type="MANDATORY">Variable extraction: Common values must be stored in configuration files</rule>
      <rule type="MANDATORY">Reference over duplication: Link to existing documentation rather than copying content</rule>
      <rule type="MANDATORY">Configuration inheritance: Base configurations with level-specific overrides</rule>
    </single-source-truth>
    
    <duplication-exceptions>
      <exception type="prompts">Agent prompts may repeat context for clarity and effectiveness</exception>
      <exception type="validation">Critical validation steps may be repeated for safety</exception>
      <exception type="learning">Educational examples may repeat concepts for comprehension</exception>
      <note>ALL exceptions must be explicitly justified and documented</note>
    </duplication-exceptions>
    
    <reference-patterns>
      <pattern type="internal">See .claude/context/XX_topic_name.md for details</pattern>
      <pattern type="configuration">Reference: .claude/config/base-settings.json</pattern>
      <pattern type="template">Template: .claude/shared/templates/agent-template.md</pattern>
    </reference-patterns>
  </dry-enforcement>

  <anti-pattern-prevention>
    <forbidden-patterns>
      <pattern type="status-tracking">NO status="pending"/"completed" attributes in markdown documentation</pattern>
      <pattern type="hardcoded-progress">NO hardcoded progress indicators - use dynamic JSON session files</pattern>
      <pattern type="circular-dependencies">NO circular dependencies - maintain clear dependency hierarchy</pattern>
      <pattern type="vague-criteria">NO vague success criteria - all outcomes must be measurable</pattern>
      <pattern type="untestable-claims">NO untestable claims - everything must be verifiable</pattern>
      <pattern type="mixed-responsibilities">NO mixed responsibilities - one component serves one purpose</pattern>
      <pattern type="hidden-state">NO hidden state - all state must be visible in session files</pattern>
    </forbidden-patterns>
    
    <required-patterns>
      <pattern type="state-tracking">Use JSON session files in appropriate level directories</pattern>
      <pattern type="progress-indication">Dynamic progress calculation from session data</pattern>
      <pattern type="clear-hierarchy">Level 1 -> Level 2 -> Level 3 -> Level 4 dependency flow</pattern>
      <pattern type="measurable-outcomes">Specific metrics with thresholds (e.g., "<$5 per episode")</pattern>
      <pattern type="testable-functionality">Include validation commands for every feature</pattern>
      <pattern type="single-responsibility">Each agent/command/tool has one clear purpose</pattern>
      <pattern type="visible-state">All progress/state tracked in .claude/*/sessions/ files</pattern>
    </required-patterns>
  </anti-pattern-prevention>

  <validation-requirements>
    <operation-validation>
      <rule type="MANDATORY">Every operation must include specific validation steps</rule>
      <rule type="MANDATORY">Every file reference must be tested for existence before use</rule>
      <rule type="MANDATORY">Every command must have clearly defined success criteria</rule>
      <rule type="MANDATORY">Every workflow must include checkpoint validations</rule>
      <rule type="MANDATORY">Every claim must include verification method</rule>
      <rule type="MANDATORY">Every integration must have comprehensive test coverage</rule>
      <rule type="MANDATORY">Every session must track measurable metrics</rule>
    </operation-validation>
    
    <validation-commands>
      <file-existence>ls -la [file-path] || echo "File not found: [file-path]"</file-existence>
      <directory-structure>find .claude -type d -name "*" | sort</directory-structure>
      <command-availability>which [command] || echo "Command not found: [command]"</command-availability>
      <api-connectivity>[specific API test command] || echo "API connection failed"</api-connectivity>
      <dependency-check>pip list | grep [package] || echo "Package not installed: [package]"</dependency-check>
    </validation-commands>
    
    <checkpoint-requirements>
      <before-major-operations>Validate environment state and prerequisites</before-major-operations>
      <during-execution>Confirm each step completes successfully before proceeding</during-execution>
      <after-completion>Verify all expected outputs exist and are valid</after-completion>
      <error-handling>Document specific error conditions and recovery steps</error-handling>
    </checkpoint-requirements>
  </validation-requirements>

  <attention-to-detail-requirements>
    <precision-mandate>
      <rule type="MANDATORY">File paths must be exact and case-sensitive</rule>
      <rule type="MANDATORY">Command syntax must be precisely correct</rule>
      <rule type="MANDATORY">No placeholder values in production configurations</rule>
      <rule type="MANDATORY">Version numbers must be tracked and documented</rule>
      <rule type="MANDATORY">Dependencies must be explicitly listed with versions</rule>
      <rule type="MANDATORY">Error messages must be actionable and specific</rule>
      <rule type="MANDATORY">Documentation must match actual implementation exactly</rule>
    </precision-mandate>
    
    <accuracy-standards>
      <file-paths>Use absolute paths consistently, verify case sensitivity</file-paths>
      <commands>Test all commands in target environment before documenting</commands>
      <configurations>No [PLACEHOLDER] or TODO values in working systems</configurations>
      <versions>Specify exact version numbers (e.g., Python 3.11.5, not just Python 3)</versions>
      <dependencies>Include specific package versions in requirements files</dependencies>
      <errors>Provide exact error text and step-by-step resolution</errors>
      <docs>Keep documentation synchronized with code changes immediately</docs>
    </accuracy-standards>
    
    <quality-checkpoints>
      <checkpoint type="syntax">All commands and code snippets must be syntax-valid</checkpoint>
      <checkpoint type="paths">All file and directory references must be verified</checkpoint>
      <checkpoint type="consistency">Naming conventions must be applied consistently</checkpoint>
      <checkpoint type="completeness">No incomplete configurations or partial implementations</checkpoint>
      <checkpoint type="testability">All instructions must be executable and testable</checkpoint>
    </quality-checkpoints>
  </attention-to-detail-requirements>

  <enforcement-procedures>
    <pre-operation-checks>
      <step number="1">Validate all file paths and directory structure</step>
      <step number="2">Confirm all dependencies and prerequisites</step>
      <step number="3">Test all commands in appropriate environment</step>
      <step number="4">Verify no anti-patterns are present</step>
      <step number="5">Ensure all claims are verifiable</step>
    </pre-operation-checks>
    
    <during-operation-monitoring>
      <monitor>Track each step completion status</monitor>
      <validate>Confirm outputs match expectations</validate>
      <document>Record all validation commands and results</document>
      <checkpoint>Pause at defined validation points</checkpoint>
      <recover>Have explicit error recovery procedures</recover>
    </during-operation-monitoring>
    
    <post-operation-verification>
      <verify>All expected files and directories created</verify>
      <test>All functionality works as documented</test>
      <measure>All success criteria are met</measure>
      <record>All metrics and outcomes documented</record>
      <validate>All references and links are functional</validate>
    </post-operation-verification>
  </enforcement-procedures>

  <quality-metrics>
    <measurable-standards>
      <accuracy>File path accuracy: 100% (zero broken references)</accuracy>
      <completeness>Operation completeness: 100% (all steps executable)</completeness>
      <consistency>Naming consistency: 100% (all conventions followed)</consistency>
      <verifiability>Claim verifiability: 100% (all statements testable)</verifiability>
      <organization>Directory organization: 100% (no misplaced files)</organization>
    </measurable-standards>
    
    <failure-handling>
      <immediate-stop>Stop all operations if quality standards are not met</immediate-stop>
      <root-cause-analysis>Identify why standards were violated</root-cause-analysis>
      <corrective-action>Fix all issues before proceeding</corrective-action>
      <prevention-update>Update procedures to prevent recurrence</prevention-update>
    </failure-handling>
  </quality-metrics>
</QUALITY-ENFORCEMENT-STANDARDS>

<advanced-configuration>
  <hooks-examples>
    <hook name="pre-commit" event="pre-tool-use">
      <purpose>Run linting and tests before file changes</purpose>
      <command>ruff check . && black . && pytest tests/</command>
    </hook>
    
    <hook name="session-summary" event="session-complete">
      <purpose>Generate session summary and commit changes</purpose>
      <command>git add . && git commit -m "Session: $(date)"</command>
    </hook>
    
    <hook name="cost-tracker" event="post-tool-use">
      <purpose>Track API usage costs</purpose>
      <command>echo "$(date): Tool used" >> logs/usage.log</command>
    </hook>
  </hooks-examples>
  
  <mcp-server-recommendations>
    <server name="github" priority="high">
      <purpose>Issue tracking, PR creation, repository management</purpose>
      <setup>claude mcp add github</setup>
      <learning-value>Understand automated development workflows</learning-value>
    </server>
    
    <server name="filesystem" priority="medium">
      <purpose>Enhanced file operations beyond basic read/write</purpose>
      <setup>claude mcp add filesystem</setup>
      <learning-value>Learn advanced file system automation</learning-value>
    </server>
    
    <server name="web-search" priority="medium">
      <purpose>Real-time information retrieval during development</purpose>
      <setup>claude mcp add web-search</setup>
      <learning-value>Integrate live research into coding workflow</learning-value>
    </server>
  </mcp-server-recommendations>
  
  <claudeignore-template>
    <comment># Exclude common directories that consume context unnecessarily</comment>
    <exclusions>
      node_modules/
      .git/
      __pycache__/
      .pytest_cache/
      *.log
      .DS_Store
      .env
      dist/
      build/
      .venv/
      venv/
    </exclusions>
  </claudeignore-template>
</advanced-configuration>

<learning-checkpoints-detailed>
  <checkpoint level="beginner">
    <milestone>Successfully run /init and understand the generated CLAUDE.md</milestone>
    <validation>Can explain what each section does</validation>
    <next-step>Create first custom slash command</next-step>
  </checkpoint>
  
  <checkpoint level="intermediate">
    <milestone>Configure hooks for automated code quality checks</milestone>
    <validation>Hooks execute automatically during development</validation>
    <next-step>Integrate MCP servers for external tool access</next-step>
  </checkpoint>
  
  <checkpoint level="advanced">
    <milestone>Full Claude Code workflow with automation, memory management, and context optimization</milestone>
    <validation>Can produce podcast episodes with <$5 cost using automated pipeline</validation>
    <next-step>Share knowledge and help other hobbyist learners</next-step>
  </checkpoint>
</learning-checkpoints-detailed>

<context-optimization-tips>
  <tip category="memory-management">
    <principle>Use /clear frequently to prevent context bloat</principle>
    <explanation>Long conversations consume context window space, reducing Claude's effectiveness</explanation>
    <frequency>Every 3-5 major tasks or when switching focus areas</frequency>
  </tip>
  
  <tip category="file-organization">
    <principle>Keep .claudeignore updated with irrelevant files</principle>
    <explanation>Excluding unnecessary files saves token usage and improves response quality</explanation>
    <examples>Log files, node_modules, .git directory, build artifacts</examples>
  </tip>
  
  <tip category="semantic-structure">
    <principle>Use XML tags consistently in all documentation</principle>
    <explanation>XML semantic tagging provides 40% better comprehension for Claude</explanation>
    <benefit>More accurate responses and better context understanding</benefit>
  </tip>
  
  <tip category="learning-progression">
    <principle>Document learnings in CLAUDE.local.md</principle>
    <explanation>Personal notes help track progress without cluttering shared documentation</explanation>
    <privacy>CLAUDE.local.md is git-ignored for personal learning notes</privacy>
  </tip>
</context-optimization-tips>

<remember>
  <principle>This is YOUR learning journey</principle>
  <principle>Go at YOUR pace</principle>
  <principle>Every error teaches you something</principle>
  <principle>Every success is YOUR achievement</principle>
  <principle>You're not just running code - you're becoming an AI orchestration engineer!</principle>
  <principle>Claude Code amplifies your capabilities - you remain the architect of your learning</principle>
</remember>

<final-message>
  Welcome to your AI learning adventure with Claude Code! 🎓🚀
  
  You now have access to a state-of-the-art AI development environment that will grow with you from beginner to expert. This isn't just about building a podcast - it's about mastering the future of human-AI collaboration in software development.
  
  Start with /init, explore your context files, and begin your journey to becoming an AI orchestration engineer!
</final-message>

</document>