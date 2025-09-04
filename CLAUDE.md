# AI Podcast Production System 🎙️

## 🚨 DEVELOPMENT STATUS: ACTIVE IMPLEMENTATION

**Current Focus:** See [TODO.md](./TODO.md) for development priorities and progress tracking.  
**Status:** System completely updated and verified - ready for agent testing.  
**Last Updated:** 2025-09-03

## ⚠️ CRITICAL POLICY: ZERO TRAINING DATA

**MANDATORY**: This system operates under a **ZERO TRAINING DATA POLICY**. 
- **DO NOT** use any information from AI training data
- **ALWAYS** use Perplexity MCP (`mcp_perplexity-ask`) for current information
- **ALWAYS** use web search for verification and updates
- **ALWAYS** cite sources with dates from 2024-2025
- **NEVER** make claims without real-time verification

---

## 🎯 System Overview

**Purpose:** Automated podcast production system creating "Nobody Knows" episodes exploring intellectual humility - celebrating both what we know AND what we don't know.

**Goal:** $3-5 per episode vs traditional $800-3500 (99%+ cost reduction)  
**Current Status:** Architecture validated, production testing needed

---

## 🏗️ SYSTEM ARCHITECTURE

### **Directory Structure** (Consolidated under nobody-knows/)
```
nobody-knows/            # Complete podcast production system
├── content/            # Source material & series planning
│   ├── series-bible/   # Brand philosophy & teaching methodology
│   ├── reference-scripts/ # 10 example episodes
│   ├── config/         # Quality gates & project configuration
│   └── episode-template.json
├── production/         # Active episode production
│   ├── state.json      # Global production state
│   ├── state_manager.py # State management system
│   └── ep_XXX_*/       # Per-episode working directories
└── output/             # Final deliverables
    ├── episodes/       # Published MP3 files
    ├── transcripts/    # Final scripts
    └── metrics/        # Quality reports

.claude/                # Claude Code configuration (project root)
├── agents/             # 10 specialized agents
├── commands/           # 5 production workflows
├── config/             # Voice & MCP settings
└── context/            # Operational knowledge
```

### **Core Components**
- **Agents**: `.claude/agents/` - 10 specialized AI workers
- **Commands**: `.claude/commands/` - 5 production workflows  
- **Config**: `.claude/config/` - Essential settings (voice + MCP)
- **Context**: `.claude/context/` - Operational knowledge base

### **Essential Context Knowledge**
- `@.claude/context/elevenlabs.md` - Voice synthesis optimization (Amelia voice settings)
- `@.claude/context/perplexity.md` - Research methodology and query strategies  
- `@.claude/context/claude-code.md` - Agent orchestration patterns and workflows

---

## 🚀 PRODUCTION WORKFLOW

### **Complete Episode Creation**

**Master Command**: `/podcast-workflow "Your Topic"`

**Phase 1: Research (`/research-workflow`)** - ZERO TRAINING DATA
- **Agent**: researcher → fact-checker → synthesizer
- **Function**: Comprehensive topic investigation using Perplexity MCP ONLY
- **Sources**: MUST be 2024-2025, verified via web search
- **Output**: Validated research package with dated expert sources
- **Cost**: ~$1-2, **Time**: 5-10 minutes

**Phase 2: Script Production (`/production-workflow`)**  
- **Agent**: writer → polisher → judge
- **Function**: Create 28-minute script with quality consensus
- **Output**: TTS-optimized script with SSML markup
- **Cost**: ~$1-2, **Time**: 5-10 minutes

**Phase 3: Audio Synthesis (`/audio-workflow`)**
- **Agent**: audio-producer → audio-validator
- **Function**: Professional voice synthesis with Amelia
- **Output**: Broadcast-quality MP3 episode
- **Cost**: ~$2-3, **Time**: 5-10 minutes

**Total**: $4-7 per episode, 15-30 minutes production time

---

## 🤖 AGENT SYSTEM

### **Research Team** (ZERO TRAINING DATA POLICY)
- **researcher**: Multi-query Perplexity MCP investigation (2024-2025 sources ONLY)
- **fact-checker**: Web search verification and source date validation  
- **synthesizer**: Knowledge packaging with current information only

### **Production Team**
- **writer**: Episode script creation with intellectual humility theme
- **polisher**: TTS optimization with SSML and pronunciation guides
- **judge**: 3-evaluator quality consensus (Claude 55%, Gemini 45%, Perplexity)

### **Audio Team**  
- **audio-producer**: ElevenLabs synthesis with Amelia voice
- **audio-validator**: Speech-to-text quality verification (≥90% accuracy)

### **Support Team**
- **batch-processor**: Multi-episode coordination
- **cost-monitor**: Budget tracking and cost attribution

---

## ⚙️ CONFIGURATION

### **Voice Settings (Validated)**
```yaml
# Amelia voice (ZF6FPAbjXT4488VcRRnw) - Production validated
stability: 0.65
similarity_boost: 0.8  
style: 0.3
model: eleven_turbo_v2_5

# Proven performance:
processing_rate: 206 WPM
cost_per_episode: $2.77
word_accuracy: 94.89%
quality_score: 92.1/100
```

### **MCP Integration**
```yaml
# Required MCP servers (auto-configured)
perplexity-ask: Research and fact-checking
elevenlabs: Voice synthesis and validation

# API requirements:
PERPLEXITY_API_KEY: Research access
ELEVENLABS_API_KEY: Audio synthesis
```

### **Quality Standards**
```yaml
# Episode quality thresholds
brand_consistency: ≥90%
technical_accuracy: ≥85%  
engagement_score: ≥80%
audio_quality: ≥85%

# 3-evaluator consensus system
claude_weight: 55% (brand/creativity)
gemini_weight: 45% (technical/structure)
perplexity_role: fact_verification
```

---

## 📚 ESSENTIAL CONTEXT

### **CRITICAL: Zero Training Data Policy**
**MANDATORY FOR ALL WORK:**
- NO information from AI training data
- ALL facts must come from Perplexity MCP or web search
- ALL sources must be dated 2024-2025
- ALWAYS verify current information before use
- NEVER assume or recall - always research fresh

### **For Voice Synthesis Work**
Load: `@.claude/context/elevenlabs.md`
- Amelia voice optimization settings
- Single-call synthesis strategies (40K char limit)
- SSML markup and pronunciation guides
- Cost efficiency patterns

### **For Research Work** (ZERO TRAINING DATA) 
Load: `@.claude/context/perplexity.md`
- 5-query research methodology using Perplexity MCP
- Source validation via web search
- Current expert discovery (2024-2025)
- Real-time fact-checking procedures

### **For Agent Orchestration**
Load: `@.claude/context/claude-code.md`
- Direct agent invocation patterns
- MCP tool inheritance rules
- Command orchestration workflows
- Quality consensus systems

---

## 🎓 EDUCATIONAL PHILOSOPHY

### **"Nobody Knows" Approach**
**Core Message**: Celebrate both knowledge AND ignorance
- **What we know**: Current expert consensus
- **What we're discovering**: Recent breakthroughs
- **What we don't know**: Open questions and uncertainties
- **Why that's exciting**: How ignorance drives discovery

### **Dual Explanation Method**
Every concept explained three ways:
- **Technical**: Professional explanation with industry terminology
- **Simple**: "Think of it like..." analogy-based explanation  
- **Connection**: Learning value and transferable skills

---

## 🚀 QUICK START

### **Setup (10 minutes)**
1. **Get API Keys**: ElevenLabs + Perplexity (see API_GUIDE.md)
2. **Configure Environment**: `cp .env.example .env` (add your keys)
3. **Setup MCP**: `./setup-mcp.sh` (one-command configuration)
4. **Validate**: `./test-mcp-connections.sh` (verify everything works)

### **Create First Episode (15-30 minutes)**
1. **Initialize**: `/init` (load project memory)
2. **Create Episode**: `/podcast-workflow "Your Fascinating Topic"`
3. **Review Quality**: Check consensus scores before audio
4. **Get Result**: 28-minute professional podcast MP3

### **User Guides**
- **SETUP_GUIDE.md**: Detailed setup instructions
- **EPISODE_GUIDE.md**: Episode creation with philosophy
- **API_GUIDE.md**: Cost management and optimization

---

## 🔧 SYSTEM VALIDATION

**Testing Scripts:**
- `./test-mcp-connections.sh` - Validate MCP servers and API keys
- `./validate-config.sh` - Check configuration consistency
- `./setup-mcp.sh` - One-command MCP server setup



---

## 💡 CURRENT STATUS

**Development Phase:** Active implementation per TODO.md

**Target Metrics:**
- Cost target: $3-5 per 28-minute episode
- Quality target: 90%+ consensus across evaluators
- Production time: 15-30 minutes end-to-end
- Word accuracy: >90% (speech synthesis)

**Testing Status:**
- Architecture: ✅ Complete and validated
- Agent Design: ✅ 10 specialized agents ready and updated
- Integration: ✅ All file paths and references corrected
- Directory Structure: ✅ Consolidated under nobody-knows/ 
- State Management: ✅ Functional and tested
- Ready for Testing: ✅ MCP tools + agent workflows

---

**Next Steps:** Follow TODO.md for systematic implementation and validation of all system components.

*Version: 3.0.0 | Updated: 2025-09-03 | Status: Ready for Testing*
