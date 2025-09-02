# Session Memory - Production State Management 🎬

<document type="session-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>sessions</domain>
    <scope>Production session management, state tracking, and workflow coordination</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>session management, production tracking, workflow coordination</loads-when>
    <triggers>session|production|workflow|state|tracking</triggers>
  </metadata>
</document>

## 🎯 SESSION MANAGEMENT CONTEXT

**Technical:** Session state management implementing production workflow coordination, cross-phase state persistence, cost attribution tracking, and quality validation continuity for reliable podcast production operations.

**Simple:** Like having a production coordinator who remembers everything about each episode as it moves through research, scripting, and audio production.

**Connection:** This teaches state management, workflow coordination, and production pipeline reliability essential for complex AI automation systems.

---

## 🎬 SESSION ARCHITECTURE

### **Active Production Sessions**
<LOAD_IF task="active|current|workflow|production">
```yaml
active_sessions:
  ep_002_production: "Modern Stoicism - COMPLETED (95/100 quality)"
  ep_003_crispr: "CRISPR Gene Editing - COMPLETED"  
  ep_004_rome: "Fall of Rome Lessons - COMPLETED"
  ep_005_ai_regulation: "AI Regulation 2025 - IN PROGRESS"
  
session_structure:
  research_phase: "research/ directory with findings and validation"
  production_phase: "production/ directory with scripts and quality reports"
  audio_phase: "audio/ directory with synthesis and validation"
  final_phase: "Complete episode package with all assets"
```
</LOAD_IF>

### **Batch Research Sessions** - `@batch_research_*/`
<LOAD_IF task="batch|research|coordination|parallel">
```yaml
batch_coordination:
  parallel_processing: "5 concurrent research operations maximum"
  resource_allocation: "Intelligent cost and time distribution"
  quality_consistency: "Uniform standards across batch operations"
  
batch_sessions:
  batch_research_20250825: "Episode 2-5 research coordination"
  progress_tracking: "Real-time batch operation monitoring"
```
</LOAD_IF>

### **Episode Templates** - `@templates/`
<LOAD_IF task="template|initialization|structure|planning">
```yaml
template_management:
  session_template: "Standard session structure and metadata"
  quality_template: "Quality evaluation frameworks"
  cost_template: "Budget planning and attribution"
  
template_evolution:
  learn_from_success: "Update templates based on successful episodes"
  cost_optimization: "Refine templates for better efficiency"
  quality_improvement: "Incorporate lessons from quality assessments"
```
</LOAD_IF>

---

## 🔄 WORKFLOW STATE COORDINATION

### **Cross-Phase Intelligence**
```yaml
state_management:
  research_to_production:
    input: "Research findings and expert sources"
    output: "Production-ready narrative structure"
    state: "Maintains research context for script quality"
    
  production_to_audio:
    input: "Validated script with quality consensus"
    output: "Audio-optimized script with SSML"
    state: "Maintains quality standards for audio validation"
    
  phase_continuity:
    cost_tracking: "Precise cost attribution across phases"
    quality_tracking: "Quality metrics maintained throughout"
    error_recovery: "Resume from any phase on failure"
```

### **Session Intelligence**
- **Progress Tracking**: Real-time workflow progress monitoring
- **Cost Attribution**: Per-phase cost allocation and tracking
- **Quality Continuity**: Quality standards maintained across phases
- **Error Recovery**: Intelligent checkpoint and resume functionality

---

*Session memory: Load when working with production workflows, session coordination, or state management*
