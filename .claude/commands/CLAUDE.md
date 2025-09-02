# Command Development Memory - Workflow Orchestration 🎮

<document type="command-memory" version="1.0.0" inherits="/.claude/CLAUDE.md">
  <metadata>
    <domain>.claude/commands</domain>
    <scope>Command architecture, workflow orchestration, and user interface patterns</scope>
    <inheritance-level>Tier 4 - Component Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>command development, workflow design, user interface work</loads-when>
    <triggers>command|workflow|slash|orchestration|pipeline</triggers>
  </metadata>
</document>

## 🎯 COMMAND DEVELOPMENT CONTEXT

**Technical:** Specialized memory for command architecture implementing workflow orchestration, user interface patterns, agent coordination protocols, and production pipeline management for Claude Code native operations.

**Simple:** Like having a control panel design manual - how to create the buttons and workflows that make the complex system simple to use.

**Connection:** This teaches user experience design, workflow architecture, and system orchestration patterns essential for usable AI applications.

---

## 🎮 COMMAND ARCHITECTURE

### **Production Commands** - `@simplified/`

### **Master Workflow** - `@simplified/podcast-workflow.md`
<LOAD_IF task="podcast|episode|production|complete|workflow">
Complete end-to-end episode production orchestrator
</LOAD_IF>

### **Research Pipeline** - `@simplified/research-workflow.md`
<LOAD_IF task="research|investigation|perplexity|fact">
Comprehensive research pipeline with validation
</LOAD_IF>

### **Production Pipeline** - `@simplified/production-workflow.md`
<LOAD_IF task="script|writing|production|quality|consensus">
Script creation and quality validation workflow
</LOAD_IF>

### **Audio Pipeline** - `@simplified/audio-workflow.md`
<LOAD_IF task="audio|synthesis|elevenlabs|tts|validation">
Audio synthesis and validation workflow
</LOAD_IF>

### **Development Workflow** - `@simplified/meta-chain.md`
<LOAD_IF task="meta|development|methodology|planning">
13-step meta-prompting methodology for systematic development
</LOAD_IF>

---

## ⚡ COMMAND ORCHESTRATION PATTERNS

### **Agent Coordination Protocol**
```yaml
orchestration_rules:
  command_responsibility: "Commands orchestrate, agents execute"
  agent_invocation: 'Use the [agent] agent to [action]: "requirements"'
  no_agent_chaining: "Agents never call other agents directly"
  session_management: "Commands handle state and checkpoints"
  
workflow_patterns:
  research_phase: "researcher → fact-checker → synthesizer"
  production_phase: "writer → polisher → judge"
  audio_phase: "audio-producer → audio-validator"
  quality_phase: "judge (three-evaluator consensus)"
```

### **User Interface Design**
```yaml
command_ui_patterns:
  simple_syntax: "/command-name arguments"
  clear_feedback: "Progress indication at each stage"
  user_checkpoints: "Review points before expensive operations"
  error_recovery: "Clear error messages with next steps"
  cost_transparency: "Real-time cost tracking and warnings"
```

---

## 🎯 WORKFLOW INTELLIGENCE

### **Context-Aware Loading**
```yaml
command_triggers:
  "/podcast-workflow": "Loads @agents/CLAUDE.md + @config/CLAUDE.md"
  "/research-workflow": "Loads @agents/CLAUDE.md (research focus)"
  "/production-workflow": "Loads @agents/CLAUDE.md (production focus)"
  "/audio-workflow": "Loads @agents/CLAUDE.md (audio focus)"
  "/meta-chain": "Loads @context/CLAUDE.md (development focus)"
```

### **Session State Management**
- **State Persistence**: Commands maintain episode state across workflow phases
- **Cost Attribution**: Per-command cost tracking and budget enforcement
- **Recovery Protocols**: Automatic checkpoint and resume functionality
- **Quality Gates**: Command-level validation before proceeding

---

*Command memory: Load when developing workflows, creating commands, or orchestrating agents*
