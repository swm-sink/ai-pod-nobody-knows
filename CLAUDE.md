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
  <instruction>Read these files in order to understand your journey:</instruction>
  <file number="1" path=".claude/context/01_project_overview.md">What this project is all about</file>
  <file number="2" path=".claude/context/02_walk_crawl_run_phases.md">Your learning progression</file>
  <file number="3" path=".claude/context/03_hobbyist_focus.md">Why this is perfect for YOU</file>
  <file number="4" path=".claude/context/04_no_api_keys_activities.md">Learn for FREE first!</file>
  <file number="5" path=".claude/context/05_agent_orchestration_basics.md">Core concepts explained simply</file>
  <file number="6" path=".claude/context/06_cost_optimization_strategies.md">Save money while learning</file>
  <file number="7" path=".claude/context/07_learning_milestones.md">Track your achievements</file>
  <file number="8" path=".claude/context/08_troubleshooting_guide.md">When things go wrong (they will!)</file>
  <file number="9" path=".claude/context/09_quick_reference.md">Quick commands and snippets</file>
  <file number="10" path=".claude/context/10_production_checklist.md">Step-by-step production guide</file>
  <file number="11" path=".claude/context/11_change_approval_requirements.md">MANDATORY change control</file>
  <file number="12" path=".claude/context/12_hallucination_prevention_guide.md">MANDATORY validation requirements</file>
  <file number="13" path=".claude/context/13_tdd_requirements_specification.md">MANDATORY TDD requirements</file>
  <file number="14" path=".claude/context/14_validation_workflow.md">Step-by-step validation process</file>
</context-files>

<current-phase>
  <phase-name>WALK</phase-name>
  <description>No API Keys Needed!</description>
  <note>You can learn for WEEKS without spending any money!</note>
  <reference>See .claude/context/04_no_api_keys_activities.md for everything you can do right now.</reference>
</current-phase>

<learning-goals>
  <goal status="pending">Understand how AI agents work together</goal>
  <goal status="pending">Learn to optimize costs (from $50 to $4 per episode!)</goal>
  <goal status="pending">Build a real podcast while learning</goal>
  <goal status="pending">Master prompt engineering</goal>
  <goal status="pending">Gain confidence with AI tools</goal>
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
  │   ├── commands/              # ⚡ Custom slash commands
  │   ├── hooks/                 # 🔧 Workflow automation
  │   └── context/               # 📚 Your learning guides (START HERE!)
  ├── core/                      # 🤖 Agent implementations (DELETED - TDD required)
  ├── projects/                  # 🎙️ Your podcast projects
  ├── requirements.txt           # 📦 Python packages
  ├── .claudeignore             # 🚫 Files to exclude from context
  └── .env.example              # 🔐 API key template
  ```
</project-structure>

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
  <milestone status="pending">Environment set up</milestone>
  <milestone status="pending">Server running locally</milestone>
  <milestone status="pending">First manual script written</milestone>
  <milestone status="pending">First API connected</milestone>
  <milestone status="pending">First episode produced</milestone>
  <milestone status="pending">Episode under $10</milestone>
  <milestone status="pending">Episode under $5</milestone>
  <milestone status="pending">10 episodes complete</milestone>
  <milestone status="pending">100 EPISODES! 🎉</milestone>
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
</critical-requirements>

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