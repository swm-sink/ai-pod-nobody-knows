# Episode Management Memory - Production Coordination 📺

<document type="episode-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>episodes</domain>
    <scope>Episode lifecycle, production tracking, and content management</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>episode production, content management, series coordination</loads-when>
    <triggers>episode|production|content|series|publishing</triggers>
  </metadata>
</document>

## 🎯 EPISODE MANAGEMENT CONTEXT

**Technical:** Episode lifecycle management implementing production coordination, content organization, quality tracking, and series-level intelligence for scalable podcast production operations.

**Simple:** Like having a production manager who tracks every episode from idea to publication, keeping everything organized and on track.

**Connection:** This teaches content management systems, production workflows, and scalable media operations essential for professional content creation.

---

## 📺 EPISODE ARCHITECTURE

### **Completed Episodes** - `@completed/`
<LOAD_IF task="completed|published|archive|reference">
```yaml
completed_structure:
  organization: "episode-XXX directories with full production history"
  includes: ["final audio", "scripts", "quality reports", "cost tracking"]
  access: "Reference for templates and quality standards"
  
success_metrics:
  episode_002: "95/100 quality, $22.10 cost, 13.8 min duration"
  episode_003: "CRISPR topic, full production cycle"
  episode_004: "Fall of Rome, historical analysis"
```
</LOAD_IF>

### **Production Templates** - `@templates/`
<LOAD_IF task="template|planning|initialization|structure">
```yaml
template_system:
  episode_template: "Standard episode structure and metadata"
  quality_template: "Quality evaluation frameworks"
  cost_template: "Budget planning and tracking"
  
template_usage:
  new_episodes: "Initialize from templates for consistency"
  quality_standards: "Apply consistent evaluation criteria"
  cost_planning: "Predictable budget allocation"
```
</LOAD_IF>

### **Active Production** - `@in_progress/` (created dynamically)
<LOAD_IF task="active|progress|current|workflow">
```yaml
active_management:
  creation: "Episodes created dynamically when workflow starts"
  tracking: "Real-time progress and cost monitoring"
  coordination: "Cross-workflow state management"
  
workflow_integration:
  research_phase: "Coordinates with /research-workflow"
  production_phase: "Coordinates with /production-workflow"
  audio_phase: "Coordinates with /audio-workflow"
```
</LOAD_IF>

---

## 🎬 PRODUCTION COORDINATION

### **Series Intelligence**
```yaml
series_coordination:
  cross_episode_knowledge: "Maintain continuity across episodes"
  complexity_progression: "Ensure appropriate difficulty scaling"
  theme_consistency: "Intellectual humility throughout series"
  
quality_evolution:
  learning_from_success: "Apply lessons from high-scoring episodes"
  template_refinement: "Improve templates based on results"
  cost_optimization: "Reduce costs while maintaining quality"
```

### **Content Organization**
- **No Pre-Creation**: Episodes created only when work begins
- **Dynamic Management**: Directories created as needed
- **Clean Archive**: Completed episodes organized for reference
- **Template System**: Consistent structure for new episodes

---

*Episode memory: Load when working with episode production, content management, or series coordination*
