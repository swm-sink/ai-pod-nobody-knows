# Production Agents - 9-Agent Pipeline Memory 🤖

<document type="component-memory" version="1.0.0" inherits="/.claude/level-2-production/CLAUDE.md">
  <metadata>
    <domain>level-2-production/agents</domain>
    <scope>9-agent production pipeline orchestration</scope>
    <inheritance-level>Tier 4 - Component Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>Working in .claude/level-2-production/agents/ directory</loads-when>
    <agent-count>9</agent-count>
    <pipeline-status>Active Production</pipeline-status>
  </metadata>
</document>

## 🎯 AGENT PIPELINE CONTEXT

**Technical:** The 9-agent production pipeline implements sophisticated AI orchestration with research coordination, script generation, dual-model quality validation, and audio synthesis optimization, featuring session-based state management and comprehensive error recovery mechanisms.

**Simple:** This is where the "AI team" lives - 9 different AI specialists that each have a specific job in creating your podcast episodes, working together like a professional production crew.

**Connection:** Understanding multi-agent orchestration teaches you how to break complex tasks into specialized components and coordinate them effectively - essential for advanced AI system design.

---

## 🤖 AGENT PIPELINE ARCHITECTURE

### **Three-Phase Production Pipeline**
```
Research Phase (Agents 01-03):
01_research_coordinator → 02_episode_planner → 03_script_writer

Quality Phase (Agents 04-06):
04_quality_claude → 05_quality_gemini → 06_feedback_synthesizer

Polish Phase (Agents 07-09):
07_script_polisher → 08_final_reviewer → 09_audio_synthesizer
```

### **Agent Responsibility Matrix**
```markdown
# Research Phase:
01_research_coordinator:  Deep topic research and fact gathering
02_episode_planner:       Structure and outline creation
03_script_writer:         Convert research into engaging script

# Quality Phase:
04_quality_claude:        Claude-based quality evaluation
05_quality_gemini:        Gemini-based quality evaluation  
06_feedback_synthesizer:  Consensus quality assessment

# Polish Phase:
07_script_polisher:       Final script refinement
08_final_reviewer:        Production readiness validation
09_audio_synthesizer:     ElevenLabs TTS optimization
```

---

## 🔄 ORCHESTRATION PATTERNS

### **Sequential Coordination**
```markdown
# Standard flow:
Agent N completes → Creates completion file → Agent N+1 starts
Quality gates validate output at each stage
Error recovery enables retry with improved prompts
```

### **Session-Based State Management**
```json
// Example session file structure:
{
  "agent_id": "01_research_coordinator",
  "status": "completed", 
  "output_quality": 0.87,
  "handoff_data": { /* comprehensive output */ },
  "next_agent": "02_episode_planner",
  "quality_passed": true
}
```

### **Quality Gate Integration**
- Each agent output evaluated against quality thresholds
- Dual validation for critical quality metrics
- Automatic retry on quality failures
- Manual override available for debugging

---

## 🎯 AGENT-SPECIFIC CONTEXTS

### **Research Phase Agents (01-03)**

**01_research_coordinator.md:**
- **Role**: Deep research and fact gathering
- **Output**: Comprehensive research brief with sources
- **Quality Focus**: Accuracy and completeness
- **Brand Integration**: Intellectual humility emphasis

**02_episode_planner.md:**
- **Role**: Structure and outline creation
- **Input**: Research brief from agent 01
- **Output**: Detailed episode outline and flow
- **Quality Focus**: Logical structure and engagement

**03_script_writer.md:**
- **Role**: Convert research into engaging script
- **Input**: Episode outline from agent 02
- **Output**: Complete episode script
- **Quality Focus**: Brand consistency and accessibility

### **Quality Phase Agents (04-06)**

**04_quality_claude.md:**
- **Role**: Claude-based comprehensive quality evaluation
- **Focus**: Technical accuracy, brand consistency, engagement
- **Output**: Detailed quality scores and feedback
- **Thresholds**: Must meet all quality gate requirements

**05_quality_gemini.md:**
- **Role**: Gemini-based independent quality evaluation
- **Focus**: Cross-validation of Claude assessment
- **Output**: Independent quality scores and feedback
- **Purpose**: Eliminate single-model bias

**06_feedback_synthesizer.md:**
- **Role**: Consensus quality assessment and feedback integration
- **Input**: Quality reports from agents 04 and 05
- **Output**: Synthesized feedback and improvement recommendations
- **Decision**: Go/no-go for production advancement

### **Polish Phase Agents (07-09)**

**07_script_polisher.md:**
- **Role**: Final script refinement based on quality feedback
- **Input**: Script + synthesized quality feedback
- **Output**: Polished, production-ready script
- **Focus**: Address all quality concerns

**08_final_reviewer.md:**
- **Role**: Production readiness validation
- **Input**: Polished script from agent 07
- **Output**: Final approval and production clearance
- **Responsibility**: Ultimate quality gate

**09_audio_synthesizer.md:**
- **Role**: ElevenLabs TTS optimization
- **Input**: Final approved script
- **Output**: TTS-optimized text for audio generation
- **Specialization**: Voice synthesis preparation

---

## 🔧 AGENT DEVELOPMENT CONTEXT

### **Agent Creation Standards**
```markdown
# All production agents must include:
- Clear role definition and responsibilities
- Input/output specifications
- Quality validation criteria
- Error handling and recovery
- Educational dual explanations
- Brand consistency enforcement
```

### **Agent Modification Protocol**
1. **Backup Creation**: Use git commits, not file copies
2. **Quality Validation**: Test with dry-run episodes
3. **Performance Monitoring**: Track quality scores and costs
4. **Documentation Update**: Maintain agent specifications
5. **Session Testing**: Validate handoff protocols

### **Integration Requirements**
- Session file compatibility
- Quality gate compliance
- Cost tracking integration
- Error recovery support
- Brand consistency enforcement

---

## 📊 PIPELINE PERFORMANCE

### **Quality Metrics**
```markdown
# Target quality scores per agent:
Research Phase: Accuracy ≥0.85, Completeness ≥0.80
Quality Phase: Consensus ≥0.85 across all metrics
Polish Phase: Production readiness ≥0.90
```

### **Cost Management**
```markdown
# Cost allocation per phase:
Research Phase (01-03): ~$1.50-2.50 per episode
Quality Phase (04-06): ~$0.50-1.00 per episode  
Polish Phase (07-09): ~$1.00-1.50 per episode
Total Agent Costs: ~$3.00-5.00 per episode
```

### **Performance Optimization**
- Token usage monitoring per agent
- Quality score tracking and improvement
- Session completion rate analysis
- Error recovery effectiveness measurement

---

## 🔄 ERROR RECOVERY & DEBUGGING

### **Common Failure Patterns**
```markdown
# Typical failure modes:
- Quality gate failures → Automatic retry with improved prompts
- Session handoff issues → Manual intervention points
- Agent output formatting → Validation and correction
- Brand consistency violations → Specific feedback integration
```

### **Debugging Workflows**
1. **Session Analysis**: Review completion files for failure points
2. **Quality Review**: Analyze quality scores and feedback
3. **Agent Testing**: Isolated agent testing with known inputs
4. **Pipeline Testing**: End-to-end validation with test episodes

### **Recovery Mechanisms**
- Automatic retry with enhanced prompts
- Session resumption from any point
- Quality gate bypass for debugging
- Manual agent execution for complex issues

---

## 🎓 LEARNING OBJECTIVES

### **Multi-Agent Orchestration**
- **Technical**: Coordinating multiple AI agents with state management and quality gates
- **Simple**: Managing a team of AI specialists to work together toward a common goal
- **Connection**: Essential for complex AI applications requiring specialized capabilities

### **Quality Assurance Automation**
- **Technical**: Automated quality validation with dual-model consensus and threshold management
- **Simple**: Setting up automatic quality checks so your output consistently meets standards
- **Connection**: Critical for professional AI deployments requiring reliability and consistency

### **Production Pipeline Design**
- **Technical**: Designing robust, scalable pipelines with error recovery and performance monitoring
- **Simple**: Building a reliable "assembly line" that can handle problems and keep producing quality work
- **Connection**: Fundamental to any automated system requiring consistent, high-quality output

---

## ⚡ QUICK ACTIONS

### **Agent Management**
- **Test Individual Agent**: Load specific agent for isolated testing
- **Review Pipeline Status**: Check session files for current state
- **Monitor Quality Metrics**: Review agent performance scores
- **Debug Pipeline Issues**: Analyze failure points and recovery

### **Development Tasks**
- **Create New Agent**: Follow agent template and standards
- **Modify Existing Agent**: Use git workflow and quality validation
- **Test Pipeline Changes**: Run dry-run episodes before production
- **Monitor Performance**: Track costs and quality continuously

---

## 🎓 EDUCATIONAL VALUE

**Technical:** The 9-agent production pipeline demonstrates advanced AI orchestration with sequential coordination, session-based state management, dual-model quality validation, and comprehensive error recovery for reliable content production.

**Simple:** Like managing a professional production team where each member has specialized skills, they communicate effectively, check each other's work, and can recover gracefully when things go wrong.

**Connection:** This teaches enterprise-level AI system design including coordination patterns, quality assurance, error handling, and performance optimization that are essential for building reliable, scalable AI applications.

---

*Access individual agents: Load any .md file in this directory for specific agent context, or use sessions/ for pipeline state tracking*