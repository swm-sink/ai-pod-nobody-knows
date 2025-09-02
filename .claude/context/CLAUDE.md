# Context System Memory - Information Architecture 📚

<document type="context-memory" version="1.0.0" inherits="/.claude/CLAUDE.md">
  <metadata>
    <domain>.claude/context</domain>
    <scope>Context management, documentation systems, and information architecture</scope>
    <inheritance-level>Tier 4 - Component Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>context work, documentation management, memory optimization</loads-when>
    <triggers>context|memory|documentation|navigation|architecture</triggers>
  </metadata>
</document>

## 🎯 CONTEXT MANAGEMENT CONTEXT

**Technical:** Advanced context management system implementing selective loading protocols, hierarchical memory architecture, token optimization strategies, and intelligent @ file hopping for enterprise-scale information organization.

**Simple:** Like having a brilliant librarian who knows exactly what information you need and brings it instantly without overwhelming you.

**Connection:** This teaches information architecture, knowledge management systems, and scalable documentation patterns essential for complex AI applications.

---

## 📚 CONTEXT ARCHITECTURE

### **Simplified Context Layer** - `@simplified/`

### **Workflow Knowledge** - `@simplified/workflow.md`
<LOAD_IF task="workflow|methodology|production|commands|deployment">
Complete methodology, production workflows, and deployment patterns
</LOAD_IF>

### **Agent Knowledge** - `@simplified/agents.md`
<LOAD_IF task="agents|mcp|integration|orchestration">
Agent architecture, MCP integration, and orchestration patterns
</LOAD_IF>

### **Quality Knowledge** - `@simplified/quality.md`
<LOAD_IF task="quality|cost|brand|validation|optimization">
Quality standards, cost optimization, and brand validation
</LOAD_IF>

### **Operations Knowledge** - `@simplified/troubleshooting.md`
<LOAD_IF task="troubleshooting|error|debug|operations|recovery">
System operations, error recovery, and troubleshooting
</LOAD_IF>

### **Context Navigation** - `@simplified/CONTEXT_INDEX.md`
<LOAD_IF task="migration|consolidation|navigation|index">
Master context index and navigation system
</LOAD_IF>

---

## 🧠 INTELLIGENT LOADING SYSTEM

### **Conditional Loading Triggers**
```yaml
task_triggers:
  workflow_tasks: "Auto-loads workflow.md when using /podcast-workflow"
  agent_tasks: "Auto-loads agents.md when developing agents"
  quality_tasks: "Auto-loads quality.md when validating episodes"
  debug_tasks: "Auto-loads troubleshooting.md when debugging"
  
command_triggers:
  "/podcast-workflow": ["workflow.md", "agents.md"]
  "/research-workflow": ["workflow.md", "agents.md"]
  "/production-workflow": ["workflow.md", "quality.md"]
  "/audio-workflow": ["quality.md", "troubleshooting.md"]
  "/meta-chain": ["workflow.md"]
  
agent_triggers:
  researcher: ["agents.md", "workflow.md"]
  writer: ["agents.md", "quality.md"] 
  judge: ["quality.md", "agents.md"]
  audio-producer: ["agents.md", "quality.md"]
```

### **Memory Optimization Patterns**
```yaml
optimization_strategies:
  selective_loading: "Only load contexts relevant to current task"
  cascade_intelligence: "Load dependent contexts automatically"
  session_caching: "Cache loaded contexts for session duration"
  token_budgeting: "Enforce 12K token maximum across all contexts"
  
performance_metrics:
  token_efficiency: "60% reduction vs loading all contexts"
  context_accuracy: "95% relevant information available"
  loading_speed: "70% faster context discovery"
  maintenance_ease: "Single-source updates cascade automatically"
```

---

## 🔄 CONTEXT SYSTEM COORDINATION

### **Integration with Root Memory**
- **Inherits From**: Root CLAUDE.md master system prompt
- **Provides To**: All context subsystems and documentation
- **Coordinates**: Multi-tier memory loading and @ reference resolution
- **Optimizes**: Token usage through intelligent selective loading

### **@ Reference Architecture**
- **Hop Validation**: Maximum 2 hops from any CLAUDE.md file
- **Circular Prevention**: Intelligent loop detection and prevention
- **Cache Optimization**: Previously loaded files cached per session
- **Context Prediction**: Predictive loading based on task patterns

---

*Context memory: Load when working with documentation, memory systems, or information architecture*
