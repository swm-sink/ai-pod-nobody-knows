# Agent Development Memory - Specialized AI Components 🤖

<document type="agent-memory" version="1.0.0" inherits="/.claude/CLAUDE.md">
  <metadata>
    <domain>.claude/agents</domain>
    <scope>AI agent development, orchestration patterns, and MCP integration</scope>
    <inheritance-level>Tier 4 - Component Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>agent development, orchestration work, MCP integration</loads-when>
    <triggers>agent|orchestration|mcp|subagent|coordination</triggers>
  </metadata>
</document>

## 🎯 AGENT DEVELOPMENT CONTEXT

**Technical:** Specialized memory for AI agent development implementing Claude Code native patterns, MCP tool inheritance, direct invocation protocols, and multi-agent coordination for podcast production automation.

**Simple:** Like having a workshop manual for building specialized AI workers - each one an expert at their specific job.

**Connection:** This teaches agent-oriented architecture, specialization patterns, and coordination systems essential for scalable AI applications.

---

## 🤖 AGENT SPECIALIZATION ARCHITECTURE

### **Research Agents** - `@simplified/researcher.md`
<LOAD_IF task="research|investigation|perplexity|fact-checking">
Complete research solution with investigation, fact-checking, and synthesis capabilities
</LOAD_IF>

### **Production Agents** - `@simplified/writer.md` + `@simplified/polisher.md`
<LOAD_IF task="script|writing|content|production|polish">
Script creation and TTS optimization for professional podcast production
</LOAD_IF>

### **Quality Agents** - `@simplified/judge.md`
<LOAD_IF task="quality|validation|consensus|evaluation">
Multi-evaluator consensus system for content quality assurance
</LOAD_IF>

### **Audio Agents** - `@simplified/audio-producer.md` + `@simplified/audio-validator.md`
<LOAD_IF task="audio|synthesis|elevenlabs|tts|validation">
Professional audio synthesis and quality validation
</LOAD_IF>

### **System Agents** - `@simplified/batch-processor.md` + `@simplified/cost-monitor.md`
<LOAD_IF task="batch|cost|monitoring|system|coordination">
Batch processing coordination and cost management
</LOAD_IF>

---

## 🔧 AGENT ORCHESTRATION PATTERNS

### **Direct Invocation Protocol**
```yaml
correct_pattern:
  syntax: 'Use the [agent-name] agent to [action]: "specific requirements"'
  example: 'Use the researcher agent to investigate: "Dark matter mysteries"'
  mcp_inheritance: "Omit tools field for full MCP access"
  
incorrect_patterns:
  task_tool_proxy: "NEVER use Task tool for agent invocation"
  hardcoded_tools: "NEVER specify tools field in agent YAML"
  complex_chaining: "NEVER chain agents directly - use command orchestration"
```

### **MCP Tool Integration**
```yaml
mcp_patterns:
  tool_inheritance:
    correct: "agents inherit ALL MCP tools when tools field omitted"
    mechanism: "Claude Code native pattern for MCP access"
    
  perplexity_integration:
    models: ["sonar-pro", "sonar-reasoning"]
    cost: "$5 per 1M tokens"
    usage: "Research agents get automatic access"
    
  elevenlabs_integration:
    voice_id: "ZF6FPAbjXT4488VcRRnw (Amelia)"
    synthesis: "Single-call up to 40K characters"
    cost: "$0.30 per 1000 characters"
```

---

## 📊 AGENT PERFORMANCE OPTIMIZATION

### **Cost Efficiency Patterns**
- **Research Agents**: $0.50-1.00 per episode through query optimization
- **Production Agents**: $1.00-1.50 per episode through batch processing
- **Audio Agents**: $2.00-3.00 per episode through single-call synthesis
- **Quality Agents**: $0.50 per episode through consensus optimization

### **Quality Standards**
- **Specialization**: Each agent has single clear responsibility
- **Coordination**: Command orchestration, never direct agent-to-agent
- **Inheritance**: Full MCP tool access without configuration
- **Performance**: Optimized for cost and quality balance

---

*Agent memory: Load when developing or working with AI agents and orchestration*
