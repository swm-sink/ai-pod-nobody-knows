# Claude Code Native Orchestration Patterns

**Phase:** walk
**Skill Level:** beginner
**Estimated Time:** 2-3 hours for full understanding and initial implementation

## Critical Architecture Update

**IMPORTANT:** This guide now reflects Claude Code native patterns discovered through comprehensive research. Previous versions contained anti-patterns that violated official Claude Code architecture.

### Claude Code Native Pattern (CORRECT)
```
Main Chat → Task tool → Specialized sub-agents
```

### Anti-Pattern (AVOIDED)
```
Main Chat → Orchestrator Agent → Sub-agents
```

## Claude Code Native Agents Overview

**Technical:** Claude Code native architecture uses the main chat as orchestrator with Task tool delegation to specialized sub-agents defined in .claude/agents/ with YAML frontmatter.

**Simple:** Think of it like being the conductor of an orchestra - you (the main chat) don't play every instrument, but you coordinate when each specialist (sub-agent) plays their part through the Task tool.

**Connection:** This teaches platform-native development patterns where leveraging built-in capabilities creates more robust and maintainable solutions.

**Native Podcast Production Pipeline:**

```yaml
Sub-Agent Specialists:
  1. deep-research-agent-enhanced 📚
     Location: .claude/agents/deep-research-agent-enhanced.md
     Job: Multi-round Perplexity research with WebSearch validation
     Tools: mcp__perplexity-ask__perplexity_ask, WebSearch, Read, Write
     Output: Comprehensive research package

  2. question-generator-enhanced ❓
     Location: .claude/agents/question-generator-enhanced.md
     Job: Strategic question generation with complexity adaptation
     Tools: mcp__perplexity-ask__perplexity_ask, WebSearch, Read, Write
     Output: Prioritized question framework

  3. research-synthesizer-enhanced 🧩
     Location: .claude/agents/research-synthesizer-enhanced.md
     Job: Knowledge integration with narrative coherence
     Tools: mcp__perplexity-ask__perplexity_ask, WebSearch, Read, Write
     Output: Production-ready content package

  4. script-writer ✍️
     Location: .claude/agents/script-writer.md
     Job: Transform research into engaging scripts
     Tools: Read, Write, mcp__perplexity-ask__perplexity_ask
     Output: Episode script draft

  5. audio-synthesizer-enhanced 🎙️
     Location: .claude/agents/audio-synthesizer-enhanced.md
     Job: Generate high-quality podcast audio
     Tools: mcp__ElevenLabs__text_to_speech, Read, Write
     Output: Final episode audio file
```

Each sub-agent has specialized expertise and operates independently with clean contexts.

## Native Orchestration Patterns

### Native Orchestration Setup

**Technical:** Claude Code native orchestration uses slash commands in .claude/commands/ that delegate to sub-agents via the Task tool, with hooks providing observability.

**Simple:** Set up specialized slash commands that coordinate your sub-agents automatically - like having pre-built workflows that you can trigger with simple commands.

**Connection:** This teaches command-driven automation and workflow orchestration essential for efficient AI system management.

**Setup Steps:**
1. Create sub-agents in `.claude/agents/` with YAML frontmatter
2. Create slash commands in `.claude/commands/` that use Task tool delegation
3. Configure hooks for observability and cost tracking
4. Test complete workflow with quality gates

### Native Orchestration Pattern (CORRECT)

**Research Workflow Example:**
```bash
# /research-episode-enhanced 25 "The Mystery Topic"
# This slash command coordinates the research pipeline:

# Main Chat as Orchestrator:
# Step 1: Use Task tool → deep-research-agent-enhanced
# Step 2: Use Task tool → question-generator-enhanced
# Step 3: Use Task tool → research-synthesizer-enhanced
# Result: Complete research package ready for user review
```

**Production Workflow Example:**
```bash
# /produce-episode-native 25 --from-research
# This slash command coordinates the production pipeline:

# Main Chat as Orchestrator:
# Step 1: Use Task tool → episode-planner-enhanced
# Step 2: Use Task tool → script-writer
# Step 3: Use Task tool → quality-claude-enhanced & quality-gemini-enhanced (parallel)
# Step 4: Use Task tool → script-polisher-enhanced
# Step 5: Use Task tool → audio-synthesizer-enhanced
# Result: Final episode audio and production report
```

### Claude Code Native Benefits

**Advantages of Native Pattern:**
- **Automatic Discovery**: Sub-agents automatically appear in Claude Code interface
- **Tool Validation**: Built-in tool access control and validation
- **Context Management**: Clean context separation between agents
- **Error Recovery**: Built-in error handling and recovery mechanisms
- **Observability**: Native hooks system for monitoring and cost tracking
- **Maintainability**: Standard patterns reduce complexity and improve reliability

### Anti-Pattern Warning (AVOID)

**Incorrect Orchestrator Agent Pattern:**
```bash
# DON'T DO THIS - Violates Claude Code native patterns
01_production_orchestrator.md  # ❌ Anti-pattern
01_research_orchestrator.md    # ❌ Anti-pattern

# These separate orchestrator agents violate native patterns
# Main chat should orchestrate directly via Task tool
```

**Problems with Anti-Pattern:**
- Violates Claude Code architecture principles
- Creates unnecessary complexity layers
- Reduces discoverability and maintainability
- Bypasses built-in Claude Code capabilities


## Key Concepts

### Native State Management

**Technical:** Claude Code native state management uses session directories and JSON files for persistence, with hooks providing real-time workflow tracking.

**Simple:** Instead of complex code, use simple folders and files to track where you are in the workflow - like having a progress checklist that saves automatically.

**Connection:** This teaches file-based state management and persistent workflow tracking essential for reliable long-running processes.

**Native State Pattern:**
```yaml
Session Structure:
  sessions/ep_25_20250824/
    research/
      research_complete.json     # Research pipeline state
      research_summary.md        # User-readable summary
    production/
      production_status.json     # Production pipeline state
      episode_audio.mp3         # Final output
```

**State Tracking Example:**
```json
{
  "session_metadata": {
    "session_id": "ep_25_research_20250824",
    "status": "completed",
    "total_cost": 4.75,
    "timestamp": "2025-08-24T10:30:00Z"
  },
  "stage_completion": {
    "deep_research": {"status": "completed", "cost": 2.25},
    "question_generation": {"status": "completed", "cost": 1.50},
    "research_synthesis": {"status": "completed", "cost": 1.00}
  }
}
```

### Native Error Recovery

**Technical:** Claude Code hooks system provides error recovery through PostToolUse event handling and session state persistence.

**Simple:** When something goes wrong, the system automatically saves your progress and gives you options to restart from where you left off.

**Connection:** This teaches resilient system design and graceful failure recovery essential for production workflows.

**Hook-Based Recovery Pattern:**
```json
{
  "PostToolUse": [{
    "matcher": "Task",
    "hooks": [{
      "type": "command",
      "command": ".claude/hooks/error-recovery-handler.sh",
      "timeout": 10
    }]
  }]
}
```

### Native Cost Tracking

**Technical:** Claude Code hooks system enables comprehensive cost tracking through PreToolUse and PostToolUse event monitoring with real-time budget validation.

**Simple:** Automatic cost counter that watches every action and keeps track of spending, warning you before you go over budget.

**Connection:** This teaches resource monitoring and budget management essential for sustainable AI system operations.

**Hooks Cost Tracking:**
```json
{
  "PreToolUse": [{
    "matcher": "*",
    "hooks": [{
      "type": "command",
      "command": ".claude/hooks/pre-tool-cost-validation.sh",
      "timeout": 5
    }]
  }]
}
```

### Native Quality Gates

**Technical:** Claude Code sub-agents with specialized quality evaluation tools provide automated quality assurance through standardized assessment frameworks.

**Simple:** Quality checkers that automatically review your work at each step and make sure everything meets high standards before moving forward.

**Connection:** This teaches automated quality assurance and systematic evaluation essential for maintaining professional content standards.

**Quality Gate Pattern:**
```bash
# Quality gates integrated into workflow
# Step N: Use Task tool → quality-claude-enhanced
# Step N+1: Use Task tool → quality-gemini-enhanced
# Result: Dual evaluation with consensus scoring
```

### Success Validation

**Native Pattern Verification:**
- ✅ Sub-agents discoverable in Claude Code interface
- ✅ Slash commands execute Task tool delegation successfully
- ✅ Hooks provide complete workflow observability
- ✅ Session state persists across workflow stages
- ✅ Error recovery enables workflow continuation
- ✅ Cost tracking validates budget compliance

## Learning Progression

### Native Pattern Mastery Path

**Level 1: Understanding Native Architecture**
- Read sub-agent definitions in `.claude/agents/` directory
- Trace Task tool delegation through slash commands
- Identify specialized tool access patterns for each agent
- Practice using `/research-episode-enhanced` and `/produce-episode-native`

**Level 2: Customization and Enhancement**
- Modify sub-agent prompts while preserving YAML frontmatter structure
- Create custom slash commands that use Task tool delegation
- Configure hooks for workflow observability and cost tracking
- Test different agent orchestration sequences and parameters

**Level 3: Advanced Workflow Design**
- Build new specialized sub-agents (Summary, Social Media, SEO)
- Design custom multi-stage workflows with quality gates
- Implement sophisticated error recovery through hooks system
- Create cross-episode learning and knowledge building systems

**Level 4: Expert System Optimization**
- Master parallel Task tool execution for efficiency optimization
- Design conditional workflow flows based on quality metrics
- Implement advanced cost optimization and budget management
- Create sophisticated cross-episode intelligence and pattern recognition

### Key Learning Outcomes

**Technical Mastery:**
- Claude Code native pattern implementation
- Task tool delegation and sub-agent coordination
- Hooks system for observability and automation
- Session-based state management and persistence

**Practical Skills:**
- Workflow orchestration and quality assurance
- Cost tracking and budget optimization
- Error recovery and resilient system design
- Multi-stage content production pipeline management

**Transferable Knowledge:**
- Platform-native development principles
- Event-driven architecture and automation
- Systematic quality assurance frameworks
- Resource monitoring and operational excellence

---

*Updated for Claude Code Native Patterns*
*Architecture Research: August 24, 2025*
*Previous Anti-Patterns Corrected: Orchestrator Agent Elimination*
