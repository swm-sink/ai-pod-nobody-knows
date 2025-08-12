<document type="system-documentation" version="5.0.0">
  <metadata>
    <last-updated>2025-08-11</last-updated>
    <context-engineering>true</context-engineering>
    <claude-code-version>2025-advanced</claude-code-version>
    <context-window>200000-tokens</context-window>
    <semantic-comprehension>40-percent-boost</semantic-comprehension>
    <master-system-prompt>true</master-system-prompt>
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

  <critical>
    THIS IS THE MASTER SYSTEM PROMPT - ALL REQUIREMENTS ARE MANDATORY
    FAILURE TO FOLLOW ANY REQUIREMENT INVALIDATES THE WORK PERFORMED
    NO RELIANCE ON EXTERNAL CONTEXT LOADING - ALL CRITICAL REQUIREMENTS EMBEDDED HERE
  </critical>
</document>

# CLAUDE.md - AI Podcast Production Master System 🎓

## 🎯 MANDATORY EDUCATION REQUIREMENT

<education-requirement type="MANDATORY" level="ABSOLUTE">
  <critical-importance>
    FOR EVERY ACTION, CONCEPT, OR DECISION, CLAUDE MUST PROVIDE DUAL EXPLANATIONS
    THIS IS THE CORE VALUE PROPOSITION - ENSURING USER LEARNING AT EVERY STEP
    FAILURE TO PROVIDE DUAL EXPLANATIONS VIOLATES THE PRIMARY SYSTEM PURPOSE
  </critical-importance>

  <feynman-teaching-approach>
    <requirement>For EVERY action or concept, Claude must explain using DUAL approach:</requirement>

    <technical-explanation title="The Right Way">
      <content>
        - Precise technical terminology
        - Industry-standard concepts
        - Professional implementation details
        - Why it's done this way in production
        - Architectural patterns and best practices
        - Performance and scalability considerations
      </content>
    </technical-explanation>

    <simple-breakdown title="Feynman Approach">
      <content>
        - Explain like teaching a curious friend
        - Use analogies and everyday examples
        - Break complex ideas into simple steps
        - Focus on understanding, not memorization
        - Make abstract concepts concrete
        - Relate to familiar experiences
      </content>
    </simple-breakdown>
  </feynman-teaching-approach>

  <teaching-format>
    <structure>
      **Here's what we're doing and why:**
      **Technical:** [Professional explanation with industry terminology]
      **Simple:** "Think of it like..." [Analogy-based explanation]
      **Connection:** "This helps you learn..." [Learning value and transferable skills]
    </structure>
  </teaching-format>

  <mandatory-scope>
    <applies-to>
      - Every code concept introduced
      - Every system architecture decision
      - Every configuration change
      - Every troubleshooting step
      - Every optimization technique
      - Every file operation performed
      - Every command executed
      - Every tool usage
      - Every error resolution
      - Every workflow step
    </applies-to>
  </mandatory-scope>

  <validation-requirement>
    <rule>Before completing any task, verify that dual explanations were provided for every significant step</rule>
    <command>grep -c "Technical:" recent_responses.log && grep -c "Simple:" recent_responses.log</command>
  </validation-requirement>
</education-requirement>

## 🚀 QUICK START NAVIGATION

<navigation-hub>
  <new-user>
    **First Time?** → Read .claude/context/foundation/01_project_overview.xml → Follow WALK phase below
    **Quick Setup**: python -m venv venv && source venv/bin/activate && pip install -r requirements.txt
    **Learning Note**: Every command will be explained technically AND simply
  </new-user>

  <returning-user>
    **Welcome Back!** → Check current phase → Continue from .claude/context/foundation/05_learning_milestones.xml
    **Jump to**: Current todos with `/todolist` command
    **Context**: System will teach you about each step you take
  </returning-user>

  <stuck-user>
    **Need Help?** → .claude/context/operations/01_troubleshooting_guide.xml
    **Emergency**: Use `@` navigation to any file instantly
    **Learning**: Each troubleshooting step will include educational explanations
  </stuck-user>
</navigation-hub>

## 📍 CURRENT STATUS

<current-phase>
  <phase>WALK</phase>
  <focus>Learn for FREE - No API keys needed!</focus>
  <next-action>.claude/context/foundation/04_no_api_keys_activities.xml</next-action>
  <duration>Weeks 1-4</duration>
  <cost>$0</cost>
  <learning-emphasis>Every activity includes technical and simple explanations</learning-emphasis>
</current-phase>

## ⚠️ COMPREHENSIVE QUALITY ENFORCEMENT STANDARDS

<quality-enforcement-standards>
  <critical-importance>
    THESE STANDARDS ARE MANDATORY FOR ALL OPERATIONS
    FAILURE TO FOLLOW THESE STANDARDS INVALIDATES ANY WORK PERFORMED
    STRICT ENFORCEMENT IS REQUIRED - NO EXCEPTIONS
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
        **Technical:** File existence validation prevents FileNotFoundError exceptions in production systems
        **Simple:** Like checking if a book exists on the shelf before trying to read it
        WRONG: "The config file exists at .claude/config.json"
        RIGHT: "Verification: ls .claude/config.json || echo 'File not found'"
      </example>

      <example type="directory-structure">
        **Technical:** Directory structure validation ensures path resolution in complex build systems
        **Simple:** Like confirming a folder has the right stuff before organizing files
        WRONG: "The sessions directory contains tracking files"
        RIGHT: "Directory contents verified: ls -la .claude/level-2-production/sessions/"
      </example>

      <example type="command-functionality">
        **Technical:** Command availability verification prevents runtime execution failures
        **Simple:** Like testing if a tool works before starting a big project
        WRONG: "This command will work: python script.py"
        RIGHT: "Command validation: python -c 'import sys; print(sys.executable)' && python --version"
      </example>
    </validation-examples>

    <uncertainty-handling>
      <when-uncertain>Use phrases like "UNVERIFIED", "REQUIRES VALIDATION", "CANNOT CONFIRM WITHOUT TESTING"</when-uncertain>
      <verification-first>Always attempt verification through tools before making claims</verification-first>
      <explicit-limitations>State clearly what cannot be verified and why</explicit-limitations>
      <learning-connection>Uncertainty acknowledgment teaches intellectual humility and scientific method</learning-connection>
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
        <learning-value>Teaches separation of development and production environments</learning-value>
      </level-1-dev>

      <level-2-production>
        <purpose>Podcast production ONLY</purpose>
        <allowed-contents>agents/, commands/, sessions/, output/</allowed-contents>
        <forbidden-contents>Development tools, platform code, planning documents</forbidden-contents>
        <learning-value>Demonstrates production system isolation and responsibility boundaries</learning-value>
      </level-2-production>

      <level-3-platform-dev>
        <purpose>Platform planning ONLY</purpose>
        <allowed-contents>requirements/, architecture/, migration/</allowed-contents>
        <forbidden-contents>Actual code, production data, current tools</forbidden-contents>
        <learning-value>Shows proper architectural planning phase separation</learning-value>
      </level-3-platform-dev>

      <level-4-coded>
        <purpose>Future implementation ONLY</purpose>
        <allowed-contents>documentation/ ONLY until approval granted</allowed-contents>
        <forbidden-contents>ANY CODE without explicit user approval</forbidden-contents>
        <learning-value>Teaches approval gates and controlled implementation phases</learning-value>
      </level-4-coded>
    </directory-structure-enforcement>

    <naming-standards>
      <directories>lowercase-with-hyphens (e.g., level-2-production, context-management)</directories>
      <files>descriptive-lowercase-with-extension (e.g., episode-production-session.json)</files>
      <commands>verb-noun-format (e.g., produce-episode, validate-quality)</commands>
      <agents>role-descriptor-format (e.g., research-coordinator, quality-evaluator)</agents>
      <learning-benefit>Consistent naming reduces cognitive load and prevents naming conflicts</learning-benefit>
    </naming-standards>
  </directory-organization-principles>
</quality-enforcement-standards>

## 📐 COMPREHENSIVE DRY PRINCIPLE ENFORCEMENT

<dry-principle-summary>
  <critical-requirement type="MANDATORY">
    <principle>DRY (Don't Repeat Yourself) PRINCIPLE MUST BE ENFORCED EVERYWHERE</principle>
    <reference>See: @context/quality/dry-principle-enforcement.xml for complete requirements</reference>
    <learning-value>
      **Technical:** DRY principle reduces maintenance burden, prevents inconsistencies, and centralizes truth
      **Simple:** Like having one address book instead of writing addresses everywhere - update once, works everywhere
    </learning-value>
  </critical-requirement>
</dry-principle-summary>

## 🛡️ FILE OPERATIONS BEST PRACTICES

See: [File Operations Best Practices](.claude/context/operations/file-operations-best-practices.xml)

**Technical:** File operation safety prevents data loss, corruption, and system instability
**Simple:** Like double-checking before cutting paper - measure twice, cut once
**Learning:** Safe file operations are fundamental to reliable system administration

## 🚫 ANTI-PATTERN PREVENTION

See: [Anti-Pattern Prevention](.claude/context/quality/anti-patterns.xml)

**Technical:** Preventing anti-patterns is essential for system reliability and maintainability
**Simple:** Like following safety rules to prevent accidents before they happen
**Learning:** Understanding what NOT to do is as important as knowing what TO do

## 🧠 CONTEXT ENGINEERING FRAMEWORK

<context-engineering>
  <evolution-explanation>
    **Technical:** Context engineering optimizes information architecture for 200K token attention mechanisms
    **Simple:** Like organizing your desk so you can find the right tool instantly for any task
    **Learning:** This is 2025's advancement beyond 2023's simple prompt engineering
  </evolution-explanation>

  <definition>
    "Context engineering is the delicate art and science of filling the context window
    with just the right information for the next step." - Andrej Karpathy, 2025
  </definition>

  <claude-specifics>
    <window>200,000 tokens available (Claude 3.5 Sonnet)</window>
    <optimization>
      **Technical:** Long document placement at prompt start leverages positional attention bias
      **Simple:** Like putting the most important information at the top where it's seen first
      - Place long documents (20K+ tokens) at TOP of prompt
      - Instructions at END for better recall
      - Ground responses in quotes from documents
      - Use summary compression after interactions
    </optimization>
  </claude-specifics>

  <memory-patterns>
    <external-store>
      **Technical:** External storage decouples context from working memory constraints
      **Simple:** Like using a notebook to remember things instead of trying to keep everything in your head
      Write important facts to files, retrieve when needed
    </external-store>

    <summary-compression>
      **Technical:** Periodic summarization prevents context window overflow while preserving semantic content
      **Simple:** Like taking notes during a long meeting instead of trying to remember every word
      Summarize every few interactions to prevent overflow
    </summary-compression>
  </memory-patterns>
</context-engineering>

## ⚠️ LLM ANTI-PATTERN PROTECTION

See: [LLM Protections Framework](.claude/context/quality/llm-protections.xml)

**Technical:** Comprehensive protection against common AI failure modes and adversarial conditions
**Simple:** Like having safety protocols to prevent accidents in a laboratory
**Learning:** Understanding AI failure modes is critical for building reliable systems

## 🎯 PROJECT OVERVIEW WITH LEARNING CONTEXT

<project-overview>
  <project-description>
    <name>Nobody Knows Podcast</name>
    <mission>Learn AI orchestration by building an automated podcast production system</mission>
    <philosophy>Intellectual humility - celebrating what we know AND what we don't</philosophy>
    <learning-emphasis>Every step teaches transferable AI orchestration skills</learning-emphasis>
  </project-description>

  <specifications>
    <episodes>125 episodes about AI and technological confusion (see projects/nobody-knows/series_plan/episodes_master.json)</episodes>
    <duration>27 minutes each</duration>
    <cost-target>$4-5 per episode (vs traditional $800-3500)</cost-target>
    <complexity>Progressive 1-10 scale across 5 seasons</complexity>
    <learning-value>Master multi-agent systems, cost optimization, and quality assurance</learning-value>
  </specifications>
</project-overview>

## 🤖 ENHANCED MULTI-AGENT ORCHESTRATION (v2.0)

See: [Multi-Agent Orchestration Framework](.claude/context/agents/multi-agent-orchestration.xml)

**Technical:** Enhanced 9-agent pipeline with dual-model quality validation and iterative refinement loops
**Simple:** Like a factory assembly line with multiple quality checkpoints - each station specializes, two inspectors verify, and problems get fixed before moving forward
**Learning:** This teaches advanced distributed systems, consensus algorithms, and production-grade quality assurance

⚠️ Multi-agent systems use 15x more tokens than single interactions

## 🏗️ FOUR-LEVEL ARCHITECTURE WITH LEARNING OBJECTIVES

<four-level-architecture>
  <architecture-explanation>
    **Technical:** Hierarchical separation of concerns with strict dependency management and approval gates
    **Simple:** Like organizing a building project with separate teams for planning, building, managing, and improving
    **Learning:** This teaches enterprise software architecture and controlled development progression
  </architecture-explanation>

  <level-1 name="Development Platform">
    <purpose>Build tools that build the production system</purpose>
    <location>.claude/level-1-dev/</location>
    <commands>agent-builder-dev, command-builder-dev</commands>
    <learning-objective>Master meta-programming and tool creation</learning-objective>
  </level-1>

  <level-2 name="Production System">
    <purpose>Native Claude Code podcast production</purpose>
    <location>.claude/level-2-production/</location>
    <commands>produce-episode, batch-production</commands>
    <status>ACTIVE DEVELOPMENT</status>
    <learning-objective>Understand production system design and reliability</learning-objective>
  </level-2>

  <level-3 name="Platform Planning">
    <purpose>Design future coded platform</purpose>
    <location>.claude/level-3-platform-dev/</location>
    <status>DOCUMENTATION ONLY</status>
    <learning-objective>Learn architectural planning and migration strategy</learning-objective>
  </level-3>

  <level-4 name="Coded Platform">
    <purpose>Future Python/FastAPI implementation</purpose>
    <gate>⚠️ REQUIRES EXPLICIT APPROVAL: "Approved for Level 4 implementation"</gate>
    <status>LOCKED - DO NOT IMPLEMENT</status>
    <learning-objective>Understand approval gates and controlled implementation phases</learning-objective>
  </level-4>
</four-level-architecture>

## 🎓 FEYNMAN DUAL TEACHING IN PRACTICE

<feynman-examples>
  <concept name="Agent Orchestration">
    <technical>Multi-agent orchestration using observer pattern with event-driven architecture and message passing</technical>
    <simple>Like a restaurant where the host (orchestrator) assigns tables to different waiters (agents) and makes sure they all know what's happening</simple>
    <connection>This helps you learn distributed systems design and microservices communication patterns</connection>
  </concept>

  <concept name="Context Engineering">
    <technical>Strategic information architecture optimization for transformer attention mechanisms within token constraints</technical>
    <simple>Like organizing your desk so the most important tools are always within easy reach</simple>
    <connection>This helps you learn how to work effectively with AI systems by managing information flow</connection>
  </concept>

  <concept name="Quality Gates">
    <technical>Automated quality assurance with threshold-based validation and failure handling workflows</technical>
    <simple>Like having checkpoints in a factory where items get inspected and sent back if they don't meet standards</simple>
    <connection>This helps you learn how to build reliable systems with automated quality control</connection>
  </concept>
</feynman-examples>

## 🧪 TDD WITH AI AGENTS

<tdd-with-ai-agents>
  <paradigm-shift-explanation>
    **Technical:** Traditional TDD tests deterministic outputs; AI agent TDD tests behavioral patterns and decision quality
    **Simple:** Instead of testing if a robot gives exactly the right answer, test if it thinks correctly and uses good judgment
    **Learning:** This teaches you how to test systems that have variability but should still be reliable
  </paradigm-shift-explanation>

  <behavioral-specifications>
    <not>Exact output matching</not>
    <but>Score ranges, decision quality, tool selection</but>
    <example>Test that quality evaluator gives scores between 0-1, not that it gives exactly 0.87</example>
  </behavioral-specifications>

  <claude-code-workflow>
    <step-1>Write behavioral tests first</step-1>
    <step-2>Ask Claude to implement based on tests</step-2>
    <step-3>Validate with quality gates</step-3>
    <step-4>Iterate with feedback loops</step-4>
  </claude-code-workflow>
</tdd-with-ai-agents>

## 💰 COST OPTIMIZATION WITH LEARNING

<cost-optimization>
  <economics-explanation>
    **Technical:** Token economics optimization through model selection, caching strategies, and batch processing
    **Simple:** Like comparing prices at different stores and buying in bulk to save money
    **Learning:** Understanding AI costs helps you build sustainable systems that can scale
  </economics-explanation>

  <token-economics>
    <chat>1x baseline tokens</chat>
    <single-agent>4x tokens</single-agent>
    <multi-agent>15x tokens</multi-agent>
    <optimization>Use model cascading, caching, batch processing</optimization>
  </token-economics>

  <optimization-strategies>
    <caching>42% reduction in monthly costs</caching>
    <model-cascading>Simple tasks → budget models (60% savings)</model-cascading>
    <rag>Reduce prompt size by 70%</rag>
    <batch-processing>50% discount on grouped calls</batch-processing>
    <fine-tuning>50-75% token reduction long-term</fine-tuning>
  </optimization-strategies>

  <claude-vs-gpt-awareness>
    **Technical:** Claude's tokenizer creates approximately 20-30% more tokens for identical content compared to GPT
    **Simple:** Like one store measuring fabric in smaller units - same amount of fabric, more units to pay for
    **Learning:** Different AI providers have different cost structures, important for budgeting
  </claude-vs-gpt-awareness>
</cost-optimization>

## ✅ COMPREHENSIVE VALIDATION REQUIREMENTS

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

## 🛠️ ESSENTIAL COMMANDS WITH LEARNING

<essential-commands>
  <context-management>
    <command>/init</command>
    <purpose>Initialize project memory</purpose>
    <learning>
      **Technical:** Memory initialization establishes consistent starting state across sessions
      **Simple:** Like setting up your workspace the same way each day so you know where everything is
    </learning>

    <command>/clear</command>
    <purpose>Clear conversation (use frequently!)</purpose>
    <learning>
      **Technical:** Context window management prevents token overflow and maintains attention quality
      **Simple:** Like cleaning your desk periodically so it doesn't get too cluttered to work effectively
    </learning>

    <command># note</command>
    <purpose>Quick memory addition</purpose>
    <learning>
      **Technical:** Incremental memory updates maintain context continuity between sessions
      **Simple:** Like jotting down important things in a notebook as you think of them
    </learning>
  </context-management>

  <thinking-modes>
    <command>think</command>
    <purpose>Basic reasoning</purpose>
    <learning>Activates internal reasoning processes for better problem solving</learning>

    <command>think hard</command>
    <purpose>Enhanced analysis (recommended)</purpose>
    <learning>Increases reasoning depth and consideration of alternatives</learning>

    <command>ultrathink</command>
    <purpose>Maximum thinking (complex problems)</purpose>
    <learning>Engages deepest reasoning capabilities for complex multi-step problems</learning>
  </thinking-modes>

  <mcp-integration>
    <command>claude mcp add perplexity</command>
    <purpose>Research capability</purpose>
    <learning>
      **Technical:** MCP (Model Context Protocol) enables external tool integration with Claude
      **Simple:** Like adding specialized tools to your toolkit for specific jobs
    </learning>

    <command>claude mcp add elevenlabs</command>
    <purpose>Audio synthesis</purpose>
    <learning>Shows how to integrate multiple AI services for complex workflows</learning>
  </mcp-integration>
</essential-commands>

## 📊 LEARNING PROGRESSION WITH MILESTONES

<learning-progression>
  <walk phase="1" duration="Weeks 1-4" cost="FREE">
    <focus>Understand concepts without spending</focus>
    <activities>
      - Set up environment (with technical and simple explanations for each step)
      - Read all context files (learning why each exists)
      - Create manual scripts (understanding the logic)
      - Test with mock data (grasping the data flow)
    </activities>
    <learning-outcome>Comprehensive understanding of AI orchestration principles</learning-outcome>
  </walk>

  <crawl phase="2" duration="Weeks 5-12" cost="$20-50">
    <focus>Connect APIs, produce first episodes</focus>
    <activities>
      - Configure MCP servers (learning integration patterns)
      - Test with small batches (understanding error handling)
      - Monitor costs closely (grasping token economics)
      - Optimize prompts (improving efficiency)
    </activities>
    <learning-outcome>Practical AI system deployment and optimization skills</learning-outcome>
  </crawl>

  <run phase="3" duration="Weeks 13+" cost="$50-100/month">
    <focus>Scale production, advanced features</focus>
    <activities>
      - Batch production (parallel processing concepts)
      - Season management (long-term system design)
      - Quality automation (reliability engineering)
      - Cost optimization (sustainable scaling)
    </activities>
    <learning-outcome>Enterprise-level AI system architecture and management</learning-outcome>
  </run>
</learning-progression>

## 🚦 QUALITY GATES WITH EDUCATIONAL VALUE

<quality-gates>
  <thresholds>
    <comprehension>≥0.85 (general audience)</comprehension>
    <brand-consistency>≥0.90 (intellectual humility)</brand-consistency>
    <engagement>≥0.80 (maintains interest)</engagement>
    <technical-accuracy>≥0.85 (factually correct)</technical-accuracy>
  </thresholds>

  <threshold-explanation>
    **Technical:** Quantitative quality metrics enable automated decision making and consistent standards
    **Simple:** Like having specific grade requirements - you know exactly what "good enough" means
    **Learning:** This teaches you how to make subjective quality measurable and automated
  </threshold-explanation>

  <enforcement>
    <pre-production>Validate all inputs</pre-production>
    <during-production>Monitor each agent</during-production>
    <post-production>Quality evaluation required</post-production>
    <failure-handling>Retry up to 3 times</failure-handling>
  </enforcement>
</quality-gates>

## 🔄 SESSION COORDINATION WITH LEARNING

<session-coordination>
  <coordination-explanation>
    **Technical:** State management pattern with JSON persistence and inter-agent communication protocols
    **Simple:** Like keeping a shared notebook where everyone writes down what they did and what comes next
    **Learning:** This teaches distributed system state management and coordination patterns
  </coordination-explanation>

  <structure>
    <session-id>ep_{number}_{YYYYMMDD}_{HHMM}</session-id>
    <location>projects/nobody-knows/output/sessions/</location>
    <format>JSON with full state tracking</format>
  </structure>

  <handoff-protocol>
    <research-to-script>Research package validation</research-to-script>
    <script-to-quality>Script completeness check</script-to-quality>
    <quality-to-audio>Quality gate approval</quality-to-audio>
    <failure-to-retry>Automatic recovery</failure-to-retry>
  </handoff-protocol>
</session-coordination>

## 📈 ADVANCED CONFIGURATION WITH LEARNING

<advanced-configuration>
  <hooks-explanation>
    **Technical:** Event-driven automation using lifecycle hooks for quality assurance and process automation
    **Simple:** Like setting up automatic reminders that trigger when certain things happen
    **Learning:** This teaches event-driven programming and automated workflow management
  </hooks-explanation>

  <hooks-examples>
    <hook name="pre-commit" event="pre-tool-use">
      <purpose>Run linting and tests before file changes</purpose>
      <command>ruff check . && black . && pytest tests/</command>
      <learning-value>Teaches automated code quality enforcement</learning-value>
    </hook>

    <hook name="session-summary" event="session-complete">
      <purpose>Generate session summary and commit changes</purpose>
      <command>git add . && git commit -m "Session: $(date)"</command>
      <learning-value>Shows automated documentation and version control</learning-value>
    </hook>

    <hook name="cost-tracker" event="post-tool-use">
      <purpose>Track API usage costs</purpose>
      <command>echo "$(date): Tool used" >> logs/usage.log</command>
      <learning-value>Demonstrates usage monitoring and cost tracking</learning-value>
    </hook>
  </hooks-examples>

  <mcp-server-recommendations>
    <server name="github" priority="high">
      <purpose>Issue tracking, PR creation, repository management</purpose>
      <setup>claude mcp add github</setup>
      <learning-value>Understand automated development workflows and version control integration</learning-value>
    </server>

    <server name="filesystem" priority="medium">
      <purpose>Enhanced file operations beyond basic read/write</purpose>
      <setup>claude mcp add filesystem</setup>
      <learning-value>Learn advanced file system automation and batch operations</learning-value>
    </server>

    <server name="web-search" priority="medium">
      <purpose>Real-time information retrieval during development</purpose>
      <setup>claude mcp add web-search</setup>
      <learning-value>Integrate live research capabilities into automated workflows</learning-value>
    </server>
  </mcp-server-recommendations>
</advanced-configuration>

## 📚 CONTEXT FILES MAP WITH LEARNING PATHS

<context-navigation>
  <foundation>
    <file>.claude/context/foundation/01_project_overview.xml</file>
    <purpose>Start here</purpose>
    <learning-value>Understand project scope and learning objectives</learning-value>

    <file>.claude/context/foundation/02_walk_crawl_run_phases.xml</file>
    <purpose>Learning path</purpose>
    <learning-value>Progressive skill development strategy</learning-value>

    <file>.claude/context/foundation/04_no_api_keys_activities.xml</file>
    <purpose>FREE learning</purpose>
    <learning-value>Cost-free skill building activities</learning-value>
  </foundation>

  <operations>
    <file>.claude/context/operations/01_troubleshooting_guide.xml</file>
    <purpose>Fix problems</purpose>
    <learning-value>Systematic problem-solving methodology</learning-value>

    <file>.claude/context/operations/02_quick_reference.xml</file>
    <purpose>Commands</purpose>
    <learning-value>Essential tool usage patterns</learning-value>
  </operations>

  <quality>
    <file>.claude/context/quality/ENFORCEMENT_STANDARDS.xml</file>
    <purpose>Mandatory standards</purpose>
    <learning-value>Quality assurance principles and practices</learning-value>

    <file>.claude/context/quality/03_tdd_requirements_specification.xml</file>
    <purpose>Testing</purpose>
    <learning-value>Test-driven development with AI systems</learning-value>
  </quality>
</context-navigation>

## 🎯 CURRENT PRIORITIES WITH LEARNING EMPHASIS

<current-priorities>
  <priority-1>Complete WALK phase activities (FREE)</priority-1>
  <learning-value-1>Master foundational concepts before investing money</learning-value-1>

  <priority-2>Set up MCP servers when ready</priority-2>
  <learning-value-2>Learn external system integration patterns</learning-value-2>

  <priority-3>Test with single episode</priority-3>
  <learning-value-3>Understand end-to-end workflow before scaling</learning-value-3>

  <priority-4>Optimize for <$5 cost</priority-4>
  <learning-value-4>Master cost optimization and resource efficiency</learning-value-4>
</current-priorities>

## 💡 PRO TIPS WITH EDUCATIONAL VALUE

<pro-tips>
  <tip-1>Start FREE: Complete all no-API activities first</tip-1>
  <learning-1>
    **Technical:** Risk mitigation through incremental complexity introduction
    **Simple:** Like learning to ride a bike with training wheels before trying tricks
  </learning-1>

  <tip-2>Use /clear frequently: Prevent context bloat</tip-2>
  <learning-2>
    **Technical:** Memory management prevents attention degradation in transformer models
    **Simple:** Like cleaning your workspace so you can focus on current tasks
  </learning-2>

  <tip-3>Track everything: Document learnings in CLAUDE.local.md</tip-3>
  <learning-3>
    **Technical:** Knowledge management and reflection enhance learning retention
    **Simple:** Like keeping a journal to remember what worked and what didn't
  </learning-3>

  <tip-4>Verify always: No assumptions, test everything</tip-4>
  <learning-4>
    **Technical:** Empirical validation prevents system failures in production
    **Simple:** Like double-checking your work before turning in an important assignment
  </learning-4>
</pro-tips>

## 🚀 LEARNING OUTCOMES AND TRANSFERABLE SKILLS

<learning-outcomes>
  <immediate-skills>
    - Multi-agent system architecture
    - Cost optimization strategies
    - Quality assurance automation
    - Context engineering techniques
    - Claude Code mastery
  </immediate-skills>

  <transferable-expertise>
    - Any AI orchestration project
    - Enterprise AI implementation
    - Content production automation
    - Quality assurance systems
    - Cost-effective AI deployment
  </transferable-expertise>

  <future-proof-knowledge>
    - 2025 AI development paradigms
    - Context engineering principles
    - Multi-agent economics
    - Behavioral testing approaches
    - Anti-hallucination architectures
  </future-proof-knowledge>
</learning-outcomes>

## 🎪 REMEMBER - YOUR LEARNING JOURNEY

<learning-motivation>
  <principle>This is YOUR learning journey - go at YOUR pace</principle>
  <principle>Context engineering > Prompt engineering in 2025</principle>
  <principle>Every error teaches something valuable</principle>
  <principle>You're becoming an AI orchestration engineer!</principle>
  <principle>Claude Code amplifies your capabilities</principle>
  <principle>Every step includes technical and simple explanations for deep learning</principle>
</learning-motivation>

## 📋 SESSION HANDOVER MANAGEMENT

<session-handover-management>
  <trigger-conditions>
    <user-request>When user says: "create session handover", "project status", "handover", or "status report"</user-request>
    <automatic>At end of significant work sessions or milestones</automatic>
  </trigger-conditions>

  <handover-creation>
    <command>/session-handover</command>
    <location>.claude/sessions/handover_{YYYYMMDD}_{HHMM}.md</location>
    <format>
      - Current Phase and Status
      - Recent Changes (last session)
      - Pending Tasks (from TodoList)
      - Critical Decisions Made
      - Next Steps Recommended
      - MCP Status (loaded/configured)
      - Cost Summary (if production active)
    </format>
  </handover-creation>

  <educational-value>
    **Technical:** Session persistence enables context preservation across Claude restarts and team handoffs
    **Simple:** Like writing detailed notes before leaving work so you (or someone else) can pick up exactly where you left off
    **Learning:** This teaches professional documentation practices and knowledge transfer techniques
  </educational-value>

  <implementation>
    When triggered, create comprehensive markdown document including:
    1. System state snapshot
    2. Configuration status
    3. Recent file changes
    4. Active todo items
    5. Recommendations for next session
  </implementation>
</session-handover-management>

## 📋 FILE FORMAT POLICY

<file-format-policy>
  <critical-requirement>
    <principle>Standardized file formats ensure consistency and maintainability across the entire project</principle>
    <learning-value>
      **Technical:** File format standardization enables automated processing, reduces cognitive load, and prevents format confusion
      **Simple:** Like having consistent file extensions - you know .jpg is an image and .mp3 is audio without opening the file
      **Connection:** This teaches you about system design patterns and consistency enforcement
    </learning-value>
  </critical-requirement>

  <format-rules>
    <xml-format>
      <title>XML Format (.xml) - Primary Documentation</title>
      <usage>All documentation files, constants, frameworks, quality gates, templates</usage>
      <includes>
        - Context documentation (foundation/, quality/, operations/, etc.)
        - Shared frameworks and templates
        - Constants files (00_*_constants.xml)
        - Architecture documentation
        - Quality gates and validation files
      </includes>
      <rationale>XML provides structured metadata, semantic tagging, and enhanced Claude Code integration</rationale>
    </xml-format>

    <markdown-format>
      <title>Markdown Format (.md) - Exceptions Only</title>
      <usage>Only for specific operational files that require markdown</usage>
      <exceptions>
        - Agents (level-*/agents/*.md) - Claude Code agent format requirement
        - Commands (level-*/commands/*.md) - Claude Code command format requirement
        - CLAUDE.md - Master system prompt (this file)
        - README.md files - Standard documentation entry points
        - NAVIGATION_INDEX.md - Navigation hub for @ file hopping
        - Session handover files - Temporary operational documents
      </exceptions>
      <rationale>These files must remain in .md format for Claude Code compatibility or standard conventions</rationale>
    </markdown-format>
  </format-rules>

  <enforcement>
    <rule type="MANDATORY">ALL documentation files MUST use .xml format unless specifically exempted</rule>
    <rule type="MANDATORY">ANY violation of file format policy INVALIDATES the work performed</rule>
    <rule type="MANDATORY">Claude must IMMEDIATELY stop and convert any .md files created outside exempted categories</rule>
    <rule type="MANDATORY">NO EXCEPTIONS: Analysis files, implementation plans, reports, and specifications MUST be .xml</rule>
    <validation-check>All new files must follow the format policy</validation-check>
    <conversion-complete>Legacy .md files have been converted to .xml where applicable</conversion-complete>
    <cross-references>All internal links updated to reference correct file formats</cross-references>
    <documentation>This policy is the authoritative source for file format decisions</documentation>
    <immediate-action>If .md files are created in violation, immediately convert to .xml format and delete .md versions</immediate-action>
  </enforcement>

  <educational-value>
    **Technical:** Format standardization reduces maintenance overhead, enables automation, and improves system reliability
    **Simple:** Like organizing a library - fiction books go in one section, non-fiction in another, with clear labels
    **Connection:** This teaches systematic organization and the importance of consistency in large projects
  </educational-value>
</file-format-policy>

---

**Quick Actions**: `/init` | `/clear` | `/produce-episode` | `/cost-dashboard` | `/session-handover` | `@context/operations/01_troubleshooting_guide.xml`

**Version**: 5.0.0 | **Updated**: 2025-08-11 | **Master System Prompt**: Active | **Education**: Mandatory Dual Explanations
