# Level 2 Production System - Podcast Production Memory 🎙️

<document type="domain-memory" version="1.0.0" inherits="/.claude/CLAUDE.md">
  <metadata>
    <domain>level-2-production</domain>
    <scope>Active podcast production system with 9-agent pipeline</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>Working in .claude/level-2-production/ directory</loads-when>
    <status>ACTIVE PRODUCTION</status>
  </metadata>
</document>

## 🎯 PRODUCTION SYSTEM CONTEXT

**Technical:** Level 2 Production System implements a 9-agent orchestration pipeline for automated podcast production, featuring research coordination, script generation, quality validation, and audio synthesis with comprehensive session management and cost optimization.

**Simple:** This is the actual "factory floor" where your podcast episodes get made - it's where all the AI agents work together like a production line to create finished episodes.

**Connection:** Understanding production system architecture teaches you how to build reliable, scalable AI workflows that can handle real-world demands and quality requirements.

---

## 🏭 PRODUCTION ARCHITECTURE

### **9-Agent Production Pipeline**
```
Episode Production Flow:
01_research_coordinator → 02_episode_planner → 03_script_writer
                ↓
04_quality_claude → 05_quality_gemini → 06_feedback_synthesizer
                ↓
07_script_polisher → 08_final_reviewer → 09_audio_synthesizer
```

### **Directory Structure**
```
level-2-production/
├── CLAUDE.md                 → This file (production context)
├── agents/                   → 9-agent production pipeline
│   ├── CLAUDE.md            → Agent orchestration context
│   ├── 01_research_coordinator.md
│   ├── 02_episode_planner.md
│   ├── 03_script_writer.md
│   ├── 04_quality_claude.md
│   ├── 05_quality_gemini.md
│   ├── 06_feedback_synthesizer.md
│   ├── 07_script_polisher.md
│   ├── 08_final_reviewer.md
│   └── 09_audio_synthesizer.md
├── commands/                 → Production workflow automation
│   ├── CLAUDE.md            → Command orchestration context
│   ├── produce-episode.md   → Complete episode production
│   ├── batch-produce.md     → Multi-episode production
│   └── pipeline-coordinator.md → Agent coordination
├── sessions/                 → Active production tracking
│   ├── CLAUDE.md            → Session management context
│   ├── ep_001_20250814_production/
│   ├── ep_002_20250814_new/
│   └── active/
├── config/                   → Production configuration
│   ├── CLAUDE.md            → Configuration context
│   ├── tts-config.yaml      → ElevenLabs TTS settings
│   ├── quality_gates.yaml   → Quality thresholds
│   └── production-config.yaml → Production parameters
└── analysis/                → Production insights and reporting
    ├── CLAUDE.md            → Analysis context
    ├── performance-metrics.xml
    └── cost-optimization.xml
```

---

## 🤖 AGENT ORCHESTRATION

### **Research Phase (Agents 01-03)**
- **01_research_coordinator**: Deep research on episode topics
- **02_episode_planner**: Structure and outline creation  
- **03_script_writer**: Convert research into engaging script

### **Quality Phase (Agents 04-06)**
- **04_quality_claude**: Claude-based quality evaluation
- **05_quality_gemini**: Gemini-based quality evaluation
- **06_feedback_synthesizer**: Consensus quality assessment

### **Polish Phase (Agents 07-09)**
- **07_script_polisher**: Final script refinement
- **08_final_reviewer**: Production readiness validation
- **09_audio_synthesizer**: ElevenLabs TTS optimization

### **Agent Coordination Patterns**
```markdown
# Session-based coordination:
1. Each agent creates session files for state tracking
2. Handoff protocol ensures complete data transfer
3. Quality gates prevent progression on failures
4. Error recovery enables automatic retries
```

---

## 📋 PRODUCTION COMMANDS

### **Primary Production Commands**
- **produce-episode.md**: Complete single episode production
- **batch-produce.md**: Multi-episode batch processing
- **pipeline-coordinator.md**: Manual agent coordination
- **test-episode-dry-run.md**: Validation without API costs

### **Command Integration**
```markdown
# Production workflow:
1. produce-episode.md orchestrates the full 9-agent pipeline
2. Each command includes cost monitoring and quality gates
3. Session management enables resumption and recovery
4. Comprehensive logging for debugging and optimization
```

---

## 📊 SESSION MANAGEMENT

### **Session Architecture**
```markdown
# Session structure:
ep_{number}_{YYYYMMDD}_{type}/
├── pipeline_status.json     → Overall progress tracking
├── {stage}_complete.json    → Individual stage completion
├── agent_outputs/           → Stage-specific outputs
└── quality_reports/         → Quality validation results
```

### **Session Coordination**
- **State Persistence**: All agent outputs saved for resumption
- **Quality Tracking**: Continuous monitoring of quality metrics
- **Cost Monitoring**: Token usage and API cost tracking
- **Error Recovery**: Automatic retry and recovery mechanisms

---

## ⚙️ CONFIGURATION MANAGEMENT

### **Production Settings**
- **tts-config.yaml**: ElevenLabs Turbo v2.5 configuration (permanent decision)
- **quality_gates.yaml**: Quality thresholds and validation rules
- **production-config.yaml**: Episode specifications and pipeline settings

### **TTS Configuration (Permanent)**
```yaml
# Finalized TTS decision (2025-08-14):
model: eleven_turbo_v2_5
voice: Amelia (ZF6FPAbjXT4488VcRRnw)
reasoning: Quality over speed for 25-30 minute episodes
cost_per_episode: $3.60-4.40 for 18-22k characters
```

### **Quality Gates**
- **Comprehension**: ≥0.85 (general audience)
- **Brand Consistency**: ≥0.90 (intellectual humility)
- **Engagement**: ≥0.80 (maintains interest)
- **Technical Accuracy**: ≥0.85 (factually correct)

---

## 💰 COST OPTIMIZATION

### **Target Economics**
- **Episode Length**: 25-30 minutes (18-22k characters)
- **Target Cost**: $4-5 per episode (vs traditional $800-3500)
- **Token Management**: Multi-agent workflows use 15x tokens but provide professional quality

### **Cost Monitoring**
```markdown
# Cost tracking per episode:
- Research phase: ~$0.50-1.00
- Script generation: ~$1.00-1.50
- Quality validation: ~$0.50-1.00
- Audio synthesis: ~$3.60-4.40
Total: ~$5.60-7.90 per episode
```

---

## 🔄 PRODUCTION WORKFLOWS

### **Standard Episode Production**
```markdown
1. Topic Selection → Research brief creation
2. Research Phase → Agents 01-03 coordination
3. Quality Phase → Agents 04-06 validation
4. Polish Phase → Agents 07-09 finalization
5. Session Completion → Output validation and archival
```

### **Quality Assurance Integration**
- Continuous monitoring throughout pipeline
- Dual-model validation (Claude + Gemini)
- Automatic retry on quality gate failures
- Comprehensive reporting and metrics

### **Error Recovery Patterns**
- Session resumption from any point
- Automatic retry with improved prompts
- Quality gate bypass for debugging
- Manual intervention points for complex issues

---

## 🎓 LEARNING OBJECTIVES

### **Production System Design**
- **Technical**: Multi-agent orchestration, session management, quality gates, and error recovery
- **Simple**: Building a reliable "factory" that can produce consistent, high-quality output
- **Connection**: Essential skills for any automated content creation or complex AI workflow

### **Quality Assurance Automation**
- **Technical**: Dual-model validation, threshold-based quality gates, and continuous monitoring
- **Simple**: Setting up automatic quality checks so you know your output meets standards
- **Connection**: Critical for professional AI deployments and maintaining consistency

### **Cost-Effective AI Orchestration**
- **Technical**: Token optimization, model selection, and cost monitoring for sustainable operations
- **Simple**: Building systems that produce great results without breaking the budget
- **Connection**: Essential for sustainable AI business models and scalable operations

---

## 🔗 INTEGRATION POINTS

### **With Level 1 Development**
- Production agents created using Level 1 development tools
- Quality standards inherit from development platform
- Testing frameworks validate production readiness

### **With Context System**
- Production documentation follows established patterns
- Quality gates reference centralized standards
- Session data contributes to learning and optimization

### **With External APIs**
- ElevenLabs integration for audio synthesis
- Perplexity integration for research enhancement
- Cost monitoring across all external services

---

## ⚡ QUICK ACTIONS

### **Production Operations**
- **Start Episode**: @commands/produce-episode.md
- **Batch Production**: @commands/batch-produce.md
- **Check Sessions**: @sessions/CLAUDE.md
- **Monitor Quality**: @config/quality_gates.yaml

### **Navigation to Components**
- **Agent Pipeline**: @agents/CLAUDE.md
- **Command System**: @commands/CLAUDE.md
- **Session Management**: @sessions/CLAUDE.md
- **Configuration**: @config/CLAUDE.md

---

## 🎓 EDUCATIONAL VALUE

**Technical:** Level 2 Production System demonstrates enterprise-grade AI orchestration with multi-agent pipelines, session management, quality assurance automation, and cost optimization for sustainable content production.

**Simple:** Like learning to manage a sophisticated factory - you understand how all the pieces work together to create consistent, high-quality products efficiently and reliably.

**Connection:** This teaches real-world AI deployment skills including system reliability, quality management, cost control, and operational excellence that are essential for professional AI applications.

---

*Access production components: @agents/CLAUDE.md for pipeline details, @sessions/CLAUDE.md for active tracking, @config/CLAUDE.md for system settings*