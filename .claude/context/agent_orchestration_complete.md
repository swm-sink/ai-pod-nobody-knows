# Agent Orchestration & Sub-Agent Architecture - Complete Framework

**Created**: 2025-08-27 (Consolidated from 3 files)
**Purpose**: Unified guide for Claude Code native orchestration patterns, sub-agent architecture, and MCP tool inheritance
**Research Basis**: 20+ Perplexity searches, official documentation, empirical testing

---

## 🚨 CRITICAL ARCHITECTURAL PRINCIPLES

### The Fundamental Truth About Claude Code Sub-Agents
**Sub-agents are NOT invoked via Task tool delegation** - this is the root cause of "0 tool uses" simulation issues.

**Correct Understanding**: Claude Code sub-agents are specialized AI personalities with isolated contexts, custom system prompts, and configurable tool access that are invoked directly by name, not through Task tool proxy delegation.

**Simple Analogy**: Think of sub-agents like calling specific experts by name ("Use the research-discovery agent to...") vs Task tool which is like hiring temporary workers for parallel jobs.

---

## ✅ CORRECT ORCHESTRATION PATTERNS

### Pattern 1: Direct Sub-Agent Invocation (RECOMMENDED)
```markdown
Use the discovery agent to investigate Episode 3 topic:
"The Science of Memory Formation - What neuroscience reveals about how we create and retrieve memories"

Requirements:
- Use Perplexity MCP to find leading researchers active in 2024-2025
- Cross-validate findings with WebSearch
- Create discovery-results.json with structured findings
- Focus on intellectual humility and research uncertainties
```

### Pattern 2: Claude Code Native Architecture
```yaml
native_architecture:
  main_orchestrator: "Main Chat coordinates overall workflow"
  specialized_agents: "Domain-specific agents invoked by name"
  tool_inheritance: "Agents inherit MCP tools when properly configured"
  quality_gates: "Built-in validation and consensus systems"
```

### Pattern 3: Sequential Agent Coordination
```markdown
# Phase 1: Research Discovery
Use the discovery agent to identify key researchers and topics

# Phase 2: Deep Research
Use the deep-dive agent to gather comprehensive information

# Phase 3: Content Synthesis
Use the writer agent to create episode content

# Phase 4: Quality Validation
Use the claude agent to validate content quality
```

---

## 🔧 MCP TOOL INHERITANCE FRAMEWORK

### Default Inheritance Behavior (RECOMMENDED)
```yaml
# CORRECT: Full MCP tool inheritance
---
name: discovery
description: "Agent for topic discovery and initial research"
# Omit 'tools' field = inherit ALL MCP tools
---
```

### Restricted Tool Access (Use Sparingly)
```yaml
# CAREFUL: Explicit tools field blocks MCP inheritance
---
name: limited-agent
tools: ["Read", "Write", "Grep"]
# This agent CANNOT access MCP tools like Perplexity or ElevenLabs
---
```

### MCP Integration Requirements
```yaml
mcp_requirements:
  environment_loading:
    critical: "Environment variables must be loaded BEFORE Claude Code starts"
    method: "Use ./start-claude.sh or source .env before claude code"
    validation: "Direct_API_elevenlabs_check_subscription should return data"

  agent_configuration:
    inheritance: "Omit 'tools' field for full MCP access"
    validation: "Agent should access all configured MCP tools"
    testing: "Test agent MCP access with simple tool invocation"
```

---

## 🏗️ PRODUCTION ORCHESTRATION ARCHITECTURE

### Multi-Agent Workflow Patterns
```yaml
workflow_patterns:
  sequential_processing:
    pattern: "Agent A → Process → Agent B → Process → Agent C"
    use_case: "Research → Script → Audio → Quality validation"
    implementation: "Direct agent invocation with result passing"

  parallel_processing:
    pattern: "Multiple agents processing simultaneously"
    use_case: "Concurrent research on different aspects"
    implementation: "Multiple agent invocations in single message"

  consensus_systems:
    pattern: "Multiple agents evaluate same content"
    use_case: "Three-evaluator quality consensus"
    implementation: "Parallel evaluation with result synthesis"
```

### Episode Production Workflow
```yaml
production_orchestration:
  phase_1_research:
    agents: "generator → discovery → deep-dive → synthesis"
    tools: "Perplexity MCP, WebSearch, file operations"
    output: "Comprehensive research package"

  phase_2_script:
    agents: "planner → writer → polisher"
    tools: "Research access, content generation, file operations"
    output: "Production-ready script with SSML"

  phase_3_quality:
    agents: "claude → gemini → perplexity → brand-validator"
    tools: "All MCP tools for comprehensive validation"
    output: "Quality consensus with scoring"

  phase_4_audio:
    agents: "optimizer → synthesizer → audio-validator"
    tools: "ElevenLabs MCP, audio processing, validation"
    output: "Professional MP3 with quality metrics"
```

---

## ❌ ANTI-PATTERNS TO AVOID

### Anti-Pattern 1: Task Tool Delegation
```markdown
# INCORRECT - Creates simulation context
Use the Task tool to have discovery investigate the topic

# CORRECT - Direct agent invocation
Use the discovery agent to investigate the topic
```

### Anti-Pattern 2: Orchestrator Agent Pattern
```yaml
# INCORRECT - Violates Claude Code architecture
main_chat → orchestrator_agent → sub_agents

# CORRECT - Claude Code native pattern
main_chat → direct_agent_invocation → specialized_agents
```

### Anti-Pattern 3: Explicit Tool Restrictions
```yaml
# AVOID - Blocks MCP inheritance unnecessarily
tools: ["Read", "Write"]  # This prevents MCP tool access

# PREFER - Full tool inheritance
# Omit tools field entirely for MCP access
```

---

## 🔍 AGENT CONFIGURATION STANDARDS

### Production Agent Template
```yaml
# .claude/agents/example-agent.md
---
name: example-agent
description: "Clear description of agent purpose and capabilities"
# IMPORTANT: Omit 'tools' field to inherit all MCP tools
---

# Agent Instructions
Detailed instructions for the agent's behavior, including:
- Specific responsibilities and capabilities
- Expected input/output formats
- Quality standards and validation requirements
- MCP tool usage patterns
```

### Agent Validation Checklist
```yaml
validation_checklist:
  configuration_syntax:
    - "Valid YAML in markdown frontmatter"
    - "Required fields present (name, description)"
    - "No 'tools' field unless explicitly restricting access"

  functionality_testing:
    - "Agent responds to direct invocation"
    - "Agent can access MCP tools if configured"
    - "Agent produces expected output format"
    - "Agent follows brand voice and quality standards"

  integration_testing:
    - "Agent works in production workflow"
    - "Agent coordinates well with other agents"
    - "Agent maintains quality and consistency"
```

---

## 🎯 BEST PRACTICES & OPTIMIZATION

### Orchestration Best Practices
```yaml
orchestration_guidelines:
  agent_specialization:
    principle: "Each agent should have clear, focused responsibilities"
    implementation: "Avoid creating general-purpose agents"
    benefit: "Better quality, easier maintenance, clearer workflows"

  context_management:
    principle: "Agents should have appropriate context for their tasks"
    implementation: "Provide relevant background and requirements"
    benefit: "More accurate and useful agent outputs"

  quality_validation:
    principle: "Build validation into the orchestration workflow"
    implementation: "Use quality gates between major workflow phases"
    benefit: "Catch issues early, maintain consistent quality"
```

### Performance Optimization
```yaml
performance_optimization:
  agent_efficiency:
    technique: "Design agents with specific, focused capabilities"
    impact: "Faster execution, more predictable outputs"
    implementation: "Avoid overlapping responsibilities between agents"

  workflow_optimization:
    technique: "Optimize agent invocation sequences"
    impact: "Reduced total execution time, better resource utilization"
    implementation: "Parallel processing where possible, efficient sequencing"

  resource_management:
    technique: "Monitor and optimize MCP tool usage"
    impact: "Cost control, better API rate limit management"
    implementation: "Strategic tool usage, result caching where appropriate"
```

---

## 🚀 ADVANCED ORCHESTRATION PATTERNS

### Dynamic Agent Selection
```yaml
dynamic_patterns:
  content_based_routing:
    concept: "Select agents based on content characteristics"
    implementation: "Route technical content to specialized technical agents"
    benefit: "Optimized processing for different content types"

  quality_based_escalation:
    concept: "Escalate to more capable agents when quality thresholds not met"
    implementation: "Retry with higher-tier agents if initial results insufficient"
    benefit: "Balanced cost and quality optimization"

  consensus_validation:
    concept: "Use multiple agents for critical quality decisions"
    implementation: "Three-evaluator consensus for final quality validation"
    benefit: "Higher confidence in quality assessments"
```

### Scalability Patterns
```yaml
scalability_considerations:
  batch_processing:
    approach: "Design orchestration for batch episode production"
    implementation: "Parallel agent invocation for multiple episodes"
    benefit: "Efficient high-volume production capability"

  resource_pooling:
    approach: "Share expensive resources across agent invocations"
    implementation: "MCP connection pooling, result caching"
    benefit: "Better resource utilization, cost optimization"

  error_recovery:
    approach: "Build resilient orchestration with error handling"
    implementation: "Retry mechanisms, graceful degradation patterns"
    benefit: "Robust production system with high reliability"
```

This consolidated framework provides complete understanding and implementation guidance for Claude Code native orchestration patterns, sub-agent architecture, and MCP tool inheritance in production environments.
