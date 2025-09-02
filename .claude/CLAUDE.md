# Claude System Memory - Core Infrastructure 🏗️

<document type="infrastructure-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>.claude</domain>
    <scope>Core Claude Code infrastructure and system components</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>Working in .claude/ directory or using system commands</loads-when>
    <system-status>Production Active</system-status>
  </metadata>
</document>

## 🎯 CLAUDE INFRASTRUCTURE CONTEXT

**Technical:** Core infrastructure memory for Claude Code native patterns, agent orchestration, command workflows, configuration management, and system-level operations for the AI podcast production system.

**Simple:** Like the engine room of a ship - all the core systems that make everything else work smoothly.

**Connection:** This teaches infrastructure design, system architecture, and the foundation layer that enables all higher-level functionality.

---

## 🏗️ INFRASTRUCTURE COMPONENTS

### **Agent Architecture** - `@agents/CLAUDE.md`
<LOAD_IF task="agent|orchestration|mcp|research|production|audio|quality">
Agent development, MCP integration, and orchestration patterns
</LOAD_IF>

### **Command Workflows** - `@commands/CLAUDE.md`
<LOAD_IF task="command|workflow|slash|orchestration|production">
Command architecture, workflow orchestration, and user interface patterns
</LOAD_IF>

### **Context Management** - `@context/CLAUDE.md`
<LOAD_IF task="context|memory|navigation|documentation">
Context system architecture, memory management, and navigation patterns
</LOAD_IF>

### **Configuration System** - `@config/CLAUDE.md`
<LOAD_IF task="config|setup|environment|production|voice">
System configuration, environment management, and production settings
</LOAD_IF>

### **Hooks & Automation** - `@hooks/CLAUDE.md`
<LOAD_IF task="hooks|automation|cost|tracking|lifecycle">
Hook architecture, automation patterns, and system lifecycle management
</LOAD_IF>

### **Infrastructure Services** - `@infrastructure/CLAUDE.md`
<LOAD_IF task="infrastructure|state|persistence|optimization|dashboard">
Infrastructure services, state management, and system optimization
</LOAD_IF>

---

## 🔄 SYSTEM COORDINATION

### **Memory Loading Strategy**
```yaml
auto_inheritance:
  from_root: "/CLAUDE.md (master system prompt)"
  domain_loading: "Infrastructure contexts when working in .claude/"
  component_loading: "Specific subsystem contexts on-demand"
  
selective_triggers:
  agent_work: "Loads @agents/CLAUDE.md + @commands/CLAUDE.md"
  command_work: "Loads @commands/CLAUDE.md + @context/CLAUDE.md"
  config_work: "Loads @config/CLAUDE.md + @hooks/CLAUDE.md"
  infrastructure: "Loads @infrastructure/CLAUDE.md + specialized contexts"
```

### **System Status Integration**
- **Production Status**: All infrastructure components validated and operational
- **Cost Tracking**: Real-time monitoring across all system components
- **Quality Gates**: Infrastructure-level validation and enforcement
- **Error Recovery**: Automated recovery protocols for system reliability

---

## 🎯 QUICK NAVIGATION

**Component Development:**
- Agent Development → `@agents/CLAUDE.md`
- Command Creation → `@commands/CLAUDE.md` 
- Context Organization → `@context/CLAUDE.md`

**System Operations:**
- Configuration → `@config/CLAUDE.md`
- Automation → `@hooks/CLAUDE.md`
- Infrastructure → `@infrastructure/CLAUDE.md`

**Integration Points:**
- Project Work → `@/projects/CLAUDE.md`
- Episode Production → `@/episodes/CLAUDE.md`
- Source Development → `@/src/CLAUDE.md`

---

*Infrastructure memory: Provides foundation for all specialized AI orchestration capabilities*
