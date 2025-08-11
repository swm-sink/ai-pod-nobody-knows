<document type="system-documentation" version="4.0.0">
  <metadata>
    <last-updated>2025-08-11</last-updated>
    <context-engineering>true</context-engineering>
    <claude-code-version>2025-advanced</claude-code-version>
    <context-window>200000-tokens</context-window>
    <semantic-comprehension>40-percent-boost</semantic-comprehension>
  </metadata>

  <critical>
    ANY modification to this document requires:
    1. User explicit approval BEFORE changes
    2. Verification through actual tools (no assumptions)
    3. Validation using chain-of-thought reasoning
    4. User confirmation AFTER implementation
  </critical>
</document>

# CLAUDE.md - AI Podcast Production Context Hub 🎓

## 🚀 QUICK START NAVIGATION

<navigation-hub>
  <new-user>
    **First Time?** → Read .claude/context/foundation/01_project_overview.md → Follow WALK phase below
    **Quick Setup**: python -m venv venv && source venv/bin/activate && pip install -r requirements.txt
  </new-user>
  
  <returning-user>
    **Welcome Back!** → Check current phase → Continue from .claude/context/foundation/05_learning_milestones.md
    **Jump to**: Current todos with `/todolist` command
  </returning-user>
  
  <stuck-user>
    **Need Help?** → .claude/context/operations/01_troubleshooting_guide.md
    **Emergency**: Use `@` navigation to any file instantly
  </stuck-user>
</navigation-hub>

## 📍 CURRENT STATUS

<current-phase>
  <phase>WALK</phase>
  <focus>Learn for FREE - No API keys needed!</focus>
  <next-action>.claude/context/foundation/04_no_api_keys_activities.md</next-action>
  <duration>Weeks 1-4</duration>
  <cost>$0</cost>
</current-phase>

## 🧠 CONTEXT ENGINEERING FRAMEWORK

<context-engineering>
  <definition>
    "Context engineering is the delicate art and science of filling the context window 
    with just the right information for the next step." - Andrej Karpathy, 2025
  </definition>
  
  <evolution>
    <old>Prompt Engineering: Craft perfect prompts</old>
    <new>Context Engineering: Design systems that bring memory, knowledge, tools, and data dynamically</new>
    <benefit>Context engineering begins where prompt engineering ends</benefit>
  </evolution>
  
  <claude-specifics>
    <window>200,000 tokens available (Claude 3.5 Sonnet)</window>
    <optimization>
      - Place long documents (20K+ tokens) at TOP of prompt
      - Instructions at END for better recall
      - Ground responses in quotes from documents
      - Use summary compression after interactions
    </optimization>
  </claude-specifics>
  
  <memory-patterns>
    <external-store>Write important facts to files, retrieve when needed</external-store>
    <summary-compression>Summarize every few interactions to prevent overflow</summary-compression>
    <notes-to-self>AI generates notes stored for future recall</notes-to-self>
  </memory-patterns>
</context-engineering>

## ⚠️ LLM ANTI-PATTERN PROTECTION

<anti-patterns>
  <protection-1 name="Hallucination Prevention">
    <problem>LLMs generate plausible but incorrect information</problem>
    <solution>
      - Chain-of-thought verification with <thinking> tags
      - Multi-query consensus (ask 5 times, check variance)
      - RAG grounding with external sources
      - Allow explicit "I don't know" responses
    </solution>
    <verification>grep -r "UNVERIFIED" output/ || echo "All claims verified"</verification>
  </protection-1>
  
  <protection-2 name="Attention Sink Defense">
    <problem>Manipulation of attention scores induces hallucinations</problem>
    <solution>
      - Dynamic validation of attention patterns
      - Black-box transferability checks
      - Monitor hidden embeddings for anomalies
    </solution>
    <verification>python validate_attention.py --check-sinks</verification>
  </protection-2>
  
  <protection-3 name="Circular Reasoning Guards">
    <problem>Model loops in self-referential logic</problem>
    <solution>
      - Step-by-step reasoning enforcement
      - External fact validation
      - Break complex queries into subtasks
    </solution>
    <example>Think step-by-step: 1) Define terms 2) Check facts 3) Apply logic 4) Validate conclusion</example>
  </protection-3>
  
  <protection-4 name="Injection Attack Prevention">
    <problem>Malicious prompts manipulate model behavior</problem>
    <solution>
      - Input sanitization layers
      - Output validation against expected patterns
      - Role-based access controls
    </solution>
    <validation>All user inputs sanitized before processing</validation>
  </protection-4>
  
  <protection-5 name="Context Overflow Protection">
    <problem>Token limit exceeded, losing critical context</problem>
    <solution>
      - Automatic summary compression
      - External memory for overflow
      - Chunking strategies for large inputs
    </solution>
    <monitoring>Token usage: {current}/200000</monitoring>
  </protection-5>
</anti-patterns>

## 🎯 PROJECT OVERVIEW

<project>
  <name>Nobody Knows Podcast</name>
  <mission>Learn AI orchestration by building an automated podcast production system</mission>
  <philosophy>Intellectual humility - celebrating what we know AND what we don't</philosophy>
  <specs>
    <episodes>100 episodes about limits of knowledge</episodes>
    <duration>27 minutes each</duration>
    <cost-target>$4-5 per episode (vs traditional $800-3500)</cost-target>
    <complexity>Progressive 1-10 scale across seasons</complexity>
  </specs>
</project>

## 🤖 MULTI-AGENT ORCHESTRATION

<orchestration>
  <pattern>Orchestrator-Worker Architecture</pattern>
  <warning>⚠️ Multi-agent systems use 15x more tokens than single interactions</warning>
  
  <agents>
    <research-coordinator>
      <purpose>Multi-source research with confidence scoring</purpose>
      <budget>$3.00 per episode</budget>
      <mcp>Perplexity integration</mcp>
    </research-coordinator>
    
    <script-writer>
      <purpose>Transform research into engaging narrative</purpose>
      <budget>$2.50 per episode</budget>
      <style>Feynman clarity + Fridman curiosity</style>
    </script-writer>
    
    <quality-evaluator>
      <purpose>Validate against quality gates</purpose>
      <budget>$0.50 per episode</budget>
      <gates>Comprehension ≥0.85, Brand ≥0.90</gates>
    </quality-evaluator>
    
    <audio-synthesizer>
      <purpose>Generate natural speech</purpose>
      <budget>$2.00 per episode</budget>
      <mcp>ElevenLabs Turbo V2</mcp>
    </audio-synthesizer>
  </agents>
  
  <token-economics>
    <chat>1x baseline tokens</chat>
    <single-agent>4x tokens</single-agent>
    <multi-agent>15x tokens</multi-agent>
    <optimization>Use model cascading, caching, batch processing</optimization>
  </token-economics>
</orchestration>

## 🏗️ FOUR-LEVEL ARCHITECTURE

<architecture>
  <level-1 name="Development Platform">
    <purpose>Build tools that build the production system</purpose>
    <location>.claude/level-1-dev/</location>
    <commands>agent-builder-dev, command-builder-dev</commands>
  </level-1>
  
  <level-2 name="Production System">
    <purpose>Native Claude Code podcast production</purpose>
    <location>.claude/level-2-production/</location>
    <commands>produce-episode, batch-production</commands>
    <status>ACTIVE DEVELOPMENT</status>
  </level-2>
  
  <level-3 name="Platform Planning">
    <purpose>Design future coded platform</purpose>
    <location>.claude/level-3-platform-dev/</location>
    <status>DOCUMENTATION ONLY</status>
  </level-3>
  
  <level-4 name="Coded Platform">
    <purpose>Future Python/FastAPI implementation</purpose>
    <gate>⚠️ REQUIRES EXPLICIT APPROVAL: "Approved for Level 4 implementation"</gate>
    <status>LOCKED - DO NOT IMPLEMENT</status>
  </level-4>
</architecture>

## 📐 DRY PRINCIPLE ENFORCEMENT

<dry-enforcement>
  <single-source-truth>
    <rule>Every piece of knowledge has ONE authoritative location</rule>
    <hierarchy>
      - Global: .claude/00_GLOBAL_CONSTANTS.md
      - Domain: .claude/context/*/00_*_constants.md
      - Shared: .claude/shared/
    </hierarchy>
  </single-source-truth>
  
  <validation-workflow>
    <before-creation>
      grep -r "search_term" .claude/  # Check if exists
      ls -la target/directory/        # Verify location
      cat existing/file.md            # Read before modifying
    </before-creation>
  </validation-workflow>
  
  <reference-patterns>
    <internal>See .claude/context/XX_topic.md</internal>
    <config>Reference: .claude/shared/config/production-config.yaml</config>
    <template>Template: .claude/shared/templates/agent-template.md</template>
  </reference-patterns>
  
  <prohibited>
    <duplication>NEVER copy-paste content between files</duplication>
    <hardcoding>NEVER hardcode values (use constants)</hardcoding>
    <assumptions>NEVER assume file exists without checking</assumptions>
  </prohibited>
</dry-enforcement>

## 🎓 FEYNMAN DUAL TEACHING

<feynman-teaching>
  <mandatory>EVERY concept explained TWO ways:</mandatory>
  
  <technical-explanation>
    Professional terminology, industry standards, production implementation
    Example: "Multi-agent orchestration using observer pattern with event-driven architecture"
  </technical-explanation>
  
  <simple-breakdown>
    Analogies, everyday examples, step-by-step understanding
    Example: "Like a restaurant where the host (orchestrator) assigns tasks to specialized staff (agents)"
  </simple-breakdown>
  
  <ai-enhancement>
    <benefit>AI validates understanding through dual explanations</benefit>
    <practice>Human experts create, AI analyzes patterns, experts review</practice>
  </ai-enhancement>
</feynman-teaching>

## 🧪 TDD WITH AI AGENTS

<test-driven-development>
  <paradigm-shift>
    <old>Test predictable outputs</old>
    <new>Test behaviors and reasoning</new>
  </paradigm-shift>
  
  <behavioral-specifications>
    <not>Exact output matching</not>
    <but>Score ranges, decision quality, tool selection</but>
  </behavioral-specifications>
  
  <claude-code-workflow>
    1. Write behavioral tests first
    2. Ask Claude to implement based on tests
    3. Validate with quality gates
    4. Iterate with feedback loops
  </claude-code-workflow>
  
  <benefits>
    <speed>AI generates boilerplate in seconds</speed>
    <coverage>Comprehensive edge case testing</coverage>
    <reliability>Automated PR reviews and refactoring</reliability>
  </benefits>
</test-driven-development>

## 💰 COST OPTIMIZATION DASHBOARD

<cost-management>
  <monitoring>
    <real-time>Track token usage per agent</real-time>
    <alerts>Notify when approaching budget limits</alerts>
    <analytics>Identify optimization opportunities</analytics>
  </monitoring>
  
  <optimization-strategies>
    <caching>42% reduction in monthly costs</caching>
    <model-cascading>Simple tasks → budget models (60% savings)</model-cascading>
    <rag>Reduce prompt size by 70%</rag>
    <batch-processing>50% discount on grouped calls</batch-processing>
    <fine-tuning>50-75% token reduction long-term</fine-tuning>
  </optimization-strategies>
  
  <token-awareness>
    <claude-vs-gpt>Claude uses 20-30% more tokens for same content</claude-vs-gpt>
    <tracking>Log every API call with cost calculation</tracking>
    <target>$4-5 per episode after optimization</target>
  </token-awareness>
  
  <dashboard-command>/cost-dashboard --show-trends --by-agent</dashboard-command>
</cost-management>

## ✅ QUALITY ENFORCEMENT STANDARDS

<quality-standards>
  <verification-mandate>
    <rule-1>VERIFY before claiming (use actual tools)</rule-1>
    <rule-2>RESEARCH before documenting (Grep, Read, LS)</rule-2>
    <rule-3>TEST before implementing (run validation)</rule-3>
    <rule-4>SOURCE attribution required (file:line)</rule-4>
    <rule-5>ADMIT uncertainty ("UNVERIFIED - requires validation")</rule-5>
  </verification-mandate>
  
  <validation-examples>
    <file-check>ls -la file.md || echo "File not found"</file-check>
    <dir-verify>find .claude -type d -name "sessions"</dir-verify>
    <content-search>grep -r "quality_gates" .claude/</content-search>
    <command-test>which produce-episode || echo "Command not installed"</command-test>
  </validation-examples>
  
  <measurable-metrics>
    <accuracy>File paths: 100% correct</accuracy>
    <completeness>All steps executable</completeness>
    <consistency>Naming conventions followed</consistency>
    <verifiability>All claims testable</verifiability>
  </measurable-metrics>
</quality-standards>

## 🛠️ ESSENTIAL COMMANDS

<commands>
  <context-management>
    /init                  # Initialize project memory
    /clear                 # Clear conversation (use frequently!)
    /compact               # Summarize to save tokens
    # note                 # Quick memory addition
    /memory                # Open CLAUDE.md for editing
  </context-management>
  
  <thinking-modes>
    think                  # Basic reasoning
    think hard             # Enhanced analysis (recommended)
    think harder           # Deep exploration
    ultrathink             # Maximum thinking (complex problems)
  </thinking-modes>
  
  <mcp-integration>
    claude mcp add perplexity     # Research capability
    claude mcp add elevenlabs     # Audio synthesis
    claude mcp list               # Show installed MCPs
    /mcp__perplexity__search     # Use MCP directly
  </mcp-integration>
  
  <production>
    /produce-episode              # Single episode production
    /batch-produce                # Multiple episodes
    /cost-dashboard               # Monitor spending
    /quality-check                # Validate outputs
  </production>
</commands>

## 📊 LEARNING PROGRESSION

<learning-path>
  <walk phase="1" duration="Weeks 1-4" cost="FREE">
    <focus>Understand concepts without spending</focus>
    <activities>
      - Set up environment
      - Read all context files
      - Create manual scripts
      - Test with mock data
    </activities>
    <milestone>Understanding complete</milestone>
  </walk>
  
  <crawl phase="2" duration="Weeks 5-12" cost="$20-50">
    <focus>Connect APIs, produce first episodes</focus>
    <activities>
      - Configure MCP servers
      - Test with small batches
      - Monitor costs closely
      - Optimize prompts
    </activities>
    <milestone>Episode under $10</milestone>
  </crawl>
  
  <run phase="3" duration="Weeks 13+" cost="$50-100/month">
    <focus>Scale production, advanced features</focus>
    <activities>
      - Batch production
      - Season management
      - Quality automation
      - Cost optimization
    </activities>
    <milestone>Consistent $4-5/episode</milestone>
  </run>
</learning-path>

## 🚦 QUICK REFERENCE

<quick-reference>
  <setup>
    python -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    uvicorn core.orchestration.server:app --reload
  </setup>
  
  <navigation>
    @filename.md           # Jump to any file
    @NAVIGATION_INDEX.md   # Master navigation (if exists)
    @operations/01_troubleshooting_guide.md  # When stuck
  </navigation>
  
  <testing>
    ls -la path/           # Verify directories
    grep -r "term" .       # Search content
    find . -name "*.md"    # Find files
    git status             # Check changes
  </testing>
</quick-reference>

## 🎯 QUALITY GATES

<quality-gates>
  <thresholds>
    <comprehension>≥0.85 (general audience)</comprehension>
    <brand-consistency>≥0.90 (intellectual humility)</brand-consistency>
    <engagement>≥0.80 (maintains interest)</engagement>
    <technical-accuracy>≥0.85 (factually correct)</technical-accuracy>
  </thresholds>
  
  <enforcement>
    <pre-production>Validate all inputs</pre-production>
    <during-production>Monitor each agent</during-production>
    <post-production>Quality evaluation required</post-production>
    <failure-handling>Retry up to 3 times</failure-handling>
  </enforcement>
</quality-gates>

## 🔄 SESSION COORDINATION

<session-management>
  <structure>
    session_id: "ep_{number}_{YYYYMMDD}_{HHMM}"
    location: projects/nobody-knows/output/sessions/
    format: JSON with full state tracking
  </structure>
  
  <handoff-protocol>
    research → script: Research package validation
    script → quality: Script completeness check
    quality → audio: Quality gate approval
    failure → retry: Automatic recovery
  </handoff-protocol>
  
  <monitoring>/session-status --active --show-progress</monitoring>
</session-management>

## 📈 MONITORING & HOOKS

<automation>
  <hooks>
    <pre-commit>Run tests before changes</pre-commit>
    <post-agent>Track completion metrics</post-agent>
    <quality-gate>Enforce standards</quality-gate>
    <cost-tracker>Log API usage</cost-tracker>
  </hooks>
  
  <dashboard-metrics>
    - Active sessions
    - Cost per episode
    - Quality scores
    - Token usage trends
    - Success/failure rates
  </dashboard-metrics>
</automation>

## 🔒 SECURITY & VALIDATION

<security>
  <api-keys>
    NEVER commit to git
    Use .env file only
    Test with mock first
  </api-keys>
  
  <validation>
    Every claim verified
    Every path tested
    Every command validated
    Every output checked
  </validation>
</security>

## 📚 CONTEXT FILES MAP

<context-navigation>
  <foundation>
    .claude/context/foundation/01_project_overview.md → Start here
    .claude/context/foundation/02_walk_crawl_run_phases.md → Learning path
    .claude/context/foundation/03_hobbyist_focus.md → Your journey
    .claude/context/foundation/04_no_api_keys_activities.md → FREE learning
    .claude/context/foundation/05_learning_milestones.md → Track progress
  </foundation>
  
  <operations>
    .claude/context/operations/01_troubleshooting_guide.md → Fix problems
    .claude/context/operations/02_quick_reference.md → Commands
    .claude/context/operations/03_production_checklist.md → Step-by-step
  </operations>
  
  <quality>
    .claude/context/quality/01_change_approval_requirements.md → Control
    .claude/context/quality/02_hallucination_prevention_guide.md → Validation
    .claude/context/quality/03_tdd_requirements_specification.md → Testing
    .claude/context/quality/04_validation_workflow.md → Quality process
    .claude/context/quality/ENFORCEMENT_STANDARDS.md → Mandatory standards
  </quality>
  
  <claude-code>
    .claude/context/claude-code/ → Claude Code mastery (check NAVIGATION.md)
    .claude/context/ai-orchestration/ → Multi-agent concepts
    .claude/context/elevenlabs/ → Audio production guides
    .claude/context/prompts_research/ → Advanced prompting
  </claude-code>
</context-navigation>

## 🎯 CURRENT PRIORITIES

<priorities>
  1. Complete WALK phase activities (FREE)
  2. Set up MCP servers when ready
  3. Test with single episode
  4. Optimize for <$5 cost
  5. Scale to batch production
</priorities>

## 💡 PRO TIPS

<tips>
  <tip-1>Start FREE: Complete all no-API activities first</tip-1>
  <tip-2>Use /clear frequently: Prevent context bloat</tip-2>
  <tip-3>Track everything: Document learnings in CLAUDE.local.md</tip-3>
  <tip-4>Test small: Single episodes before batches</tip-4>
  <tip-5>Monitor costs: Check dashboard after each run</tip-5>
  <tip-6>Verify always: No assumptions, test everything</tip-6>
</tips>

## 🚀 REMEMBER

<motivation>
  <principle>This is YOUR learning journey - go at YOUR pace</principle>
  <principle>Context engineering > Prompt engineering in 2025</principle>
  <principle>Every error teaches something valuable</principle>
  <principle>You're becoming an AI orchestration engineer!</principle>
  <principle>Claude Code amplifies your capabilities</principle>
</motivation>

---

**Quick Actions**: `/init` | `/clear` | `/produce-episode` | `/cost-dashboard` | `@08_troubleshooting_guide.md`

**Version**: 4.0.0 | **Updated**: 2025-08-11 | **Context Window**: 200K tokens | **Status**: WALK Phase Active