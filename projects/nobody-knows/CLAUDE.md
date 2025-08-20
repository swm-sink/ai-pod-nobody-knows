# Nobody Knows Podcast Project - Project-Specific Memory 🎙️

<document type="project-memory" version="1.0.0" inherits="/.claude/CLAUDE.md">
  <metadata>
    <domain>projects/nobody-knows</domain>
    <scope>Nobody Knows podcast project specifics</scope>
    <inheritance-level>Tier 4 - Component Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>Working in projects/nobody-knows/ directory</loads-when>
    <project-status>Active Development</project-status>
  </metadata>
</document>

## 🎯 PROJECT-SPECIFIC CONTEXT

**Technical:** Nobody Knows Podcast project implements the "intellectual humility" brand focusing on celebrating both what we know and what we don't know, using automated AI orchestration to produce 25-30 minute episodes at <$5 cost per episode.

**Simple:** This is your actual podcast project - where the rubber meets the road and you create real episodes about fascinating topics while being honest about the limits of human knowledge.

**Connection:** This project teaches you to apply all the AI orchestration concepts you've learned to create actual content while maintaining intellectual integrity and cost efficiency.

---

## 🎙️ PODCAST SPECIFICATIONS

### **Brand Philosophy: Intellectual Humility**
- **Core Message**: Celebrate what we know AND what we don't know
- **Approach**: Honest exploration of topics with acknowledgment of uncertainties
- **Tone**: Curious, thoughtful, accessible to general audiences
- **Educational Value**: Every episode teaches something while acknowledging limits

### **Technical Specifications**
```yaml
# Episode specifications:
duration: 25-30 minutes
character_count: 18-22k characters
target_cost: $4-5 per episode
complexity_progression: 1-10 scale across 5 seasons
total_episodes: 125 episodes planned
```

### **Production Quality Standards**
- **Comprehension**: ≥0.85 (accessible to general audience)
- **Brand Consistency**: ≥0.90 (intellectual humility theme)
- **Engagement**: ≥0.80 (maintains listener interest)
- **Technical Accuracy**: ≥0.85 (factually correct content)

---

## 📁 PROJECT STRUCTURE

### **Directory Organization**
```
projects/nobody-knows/
├── CLAUDE.md                 → This file (project context)
├── config/                   → Project-specific configuration
│   ├── CLAUDE.md            → Configuration context
│   ├── project_config.json  → Episode specifications
│   └── quality_gates.json   → Project quality thresholds
├── existing-episodes/        → Original episode content
│   ├── CLAUDE.md            → Episode management context
│   ├── ep001_original.md     → Episode 1 content
│   ├── ep002_original.md     → Episode 2 content
│   └── episode_metadata.json → Episode tracking
├── output/                   → Production outputs
│   ├── CLAUDE.md            → Output management context
│   ├── scripts/             → Generated episode scripts
│   ├── audio-ready/         → TTS-optimized content
│   ├── audio/               → Generated audio files
│   ├── quality/             → Quality validation reports
│   └── sessions/            → Production session tracking
└── series_plan/             → Overall series planning
    ├── CLAUDE.md            → Series planning context
    ├── episodes_master.json → Complete episode planning
    ├── season_themes.json   → Thematic organization
    └── series_bible.xml     → Brand and content guidelines
```

---

## 🎯 EPISODE TOPICS & THEMES

### **Intellectual Humility Topics**
- **Consciousness**: What we know, what remains mysterious
- **Time**: Our understanding vs the deep mysteries
- **Quantum Mechanics**: Known principles vs interpretation debates
- **Climate**: What models tell us vs uncertainty ranges
- **AI**: Current capabilities vs unknown emergent behaviors

### **Progressive Complexity (1-10 Scale)**
```markdown
# Season progression:
Season 1 (Episodes 1-25): Complexity 1-3 → Foundational concepts
Season 2 (Episodes 26-50): Complexity 3-5 → Deeper exploration
Season 3 (Episodes 51-75): Complexity 5-7 → Advanced topics
Season 4 (Episodes 76-100): Complexity 7-9 → Expert-level content
Season 5 (Episodes 101-125): Complexity 9-10 → Cutting-edge frontiers
```

### **Brand Consistency Elements**
- **Opening**: Acknowledgment of topic complexity
- **Throughout**: Regular "what we don't know" segments
- **Closing**: Summary of knowns and unknowns
- **Tone**: Humble curiosity, not authoritative proclamation

---

## 🎬 PRODUCTION WORKFLOW

### **Episode Creation Pipeline**
```markdown
# Standard production workflow:
1. Topic Selection → Research brief creation
2. Research Phase → 3-agent research coordination
3. Script Phase → Quality-validated script generation
4. Audio Phase → ElevenLabs TTS optimization
5. Review Phase → Final quality validation
6. Publication → Archive and metrics tracking
```

### **Quality Integration**
- Every episode passes through dual quality validation (Claude + Gemini)
- Brand consistency checks ensure intellectual humility theme
- Technical accuracy validation prevents misinformation
- Engagement optimization maintains listener interest

### **Cost Management**
```markdown
# Cost breakdown per episode:
Research: ~$0.50-1.00 (comprehensive topic exploration)
Script: ~$1.00-1.50 (multi-agent generation and refinement)
Quality: ~$0.50-1.00 (dual validation systems)
Audio: ~$3.60-4.40 (ElevenLabs Turbo v2.5)
Total: ~$5.60-7.90 per episode (vs traditional $800-3500)
```

---

## 📊 PROJECT METRICS

### **Production Metrics**
- **Episodes Completed**: Track against 125-episode goal
- **Cost Per Episode**: Monitor against $5 target
- **Quality Scores**: Track all quality gate metrics
- **Production Time**: Episode creation efficiency

### **Learning Metrics**
- **Complexity Progression**: Ensure appropriate scaling
- **Educational Value**: Track learning outcomes
- **Brand Consistency**: Intellectual humility adherence
- **Audience Feedback**: Comprehension and engagement

### **Operational Metrics**
- **Session Success Rate**: Production pipeline reliability
- **Error Recovery**: Failed session recovery efficiency
- **Quality Gate Performance**: Validation accuracy
- **Cost Optimization**: Efficiency improvements

---

## 🔗 INTEGRATION POINTS

### **With Production System**
- Inherits all Level 2 production capabilities
- Uses 9-agent orchestration pipeline
- Follows session management protocols
- Applies quality gate standards

### **With Learning System**
- Demonstrates practical application of concepts
- Provides real-world testing environment
- Validates educational approaches
- Contributes to skill development

### **With Quality Standards**
- Enforces project-specific quality gates
- Maintains brand consistency requirements
- Validates technical accuracy standards
- Ensures accessibility compliance

---

## 🎓 LEARNING OBJECTIVES

### **Applied AI Orchestration**
- **Technical**: Real-world implementation of multi-agent systems for content production
- **Simple**: Taking everything you've learned and using it to create actual episodes
- **Connection**: Bridges theory and practice, essential for professional AI deployment

### **Content Quality Management**
- **Technical**: Automated quality assurance for subjective content evaluation
- **Simple**: Making sure your podcast episodes are consistently good without manual checking
- **Connection**: Critical skill for scalable content operations and brand management

### **Cost-Effective Production**
- **Technical**: Optimizing AI costs while maintaining quality for sustainable operations
- **Simple**: Producing professional content affordably enough to actually sustain long-term
- **Connection**: Essential for viable AI-powered content businesses and sustainable automation

---

## ⚡ QUICK ACTIONS

### **Episode Production**
- **Start New Episode**: Navigate to /.claude/commands/ and run produce-episode
- **Check Progress**: @output/sessions/ for active production tracking
- **Review Quality**: @output/quality/ for validation reports
- **Monitor Costs**: @output/metrics/ for cost tracking

### **Project Management**
- **Episode Planning**: @series_plan/episodes_master.json
- **Brand Guidelines**: @series_plan/series_bible.xml
- **Configuration**: @config/project_config.json
- **Output Review**: @output/CLAUDE.md

### **Navigation to Components**
- **Configuration**: @config/CLAUDE.md
- **Episode Management**: @existing-episodes/CLAUDE.md
- **Output Management**: @output/CLAUDE.md
- **Series Planning**: @series_plan/CLAUDE.md

---

## 🎓 EDUCATIONAL VALUE

**Technical:** Nobody Knows Podcast project demonstrates end-to-end AI orchestration for content production, including multi-agent coordination, quality assurance automation, cost optimization, and brand consistency management in a real-world application.

**Simple:** Like running your own professional podcast studio where AI handles most of the heavy lifting, but you maintain creative control and ensure everything meets your standards.

**Connection:** This project integrates all AI orchestration concepts into practical application, teaching project management, quality control, and sustainable automation practices essential for professional content creation and AI-powered businesses.

---

*Access project components: @config/CLAUDE.md for settings, @output/CLAUDE.md for production tracking, @series_plan/CLAUDE.md for episode planning*
