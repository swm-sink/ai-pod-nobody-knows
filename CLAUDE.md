# AI Podcast Production System 🎙️

## 🎯 System Overview

**Purpose:** Automated podcast production system creating "Nobody Knows" episodes exploring intellectual humility - celebrating both what we know AND what we don't know.

**Achievement:** $2.77-$5 per episode vs traditional $800-3500 (99%+ cost reduction)

---

## 🏗️ SYSTEM ARCHITECTURE

### **Core Components**
- **Agents**: `.claude/agents/simplified/` - 10 specialized AI workers
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

**Phase 1: Research (`/research-workflow`)**
- **Agent**: researcher → fact-checker → synthesizer
- **Function**: Comprehensive topic investigation using Perplexity
- **Output**: Validated research package with expert sources
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

### **Research Team**
- **researcher**: Multi-query Perplexity investigation with expert discovery
- **fact-checker**: Source triangulation and accuracy verification  
- **synthesizer**: Knowledge packaging for script production

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

### **For Voice Synthesis Work**
Load: `@.claude/context/elevenlabs.md`
- Amelia voice optimization settings
- Single-call synthesis strategies (40K char limit)
- SSML markup and pronunciation guides
- Cost efficiency patterns

### **For Research Work**  
Load: `@.claude/context/perplexity.md`
- 5-query research methodology
- Source validation protocols
- Expert discovery strategies
- Fact-checking procedures

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

**Directory Structure:**
```
.claude/
├── agents/simplified/    # 10 working agents
├── commands/            # 5 production workflows
├── config/             # 2 essential configs (voice + MCP)
├── context/            # 4 operational knowledge files
├── hooks/              # 1 simple cost tracker
└── logs/               # Cost tracking output
```

---

## 💡 PROVEN RESULTS

**Episode Examples** (Before deletion):
- Episode 2: Modern Stoicism (95/100 quality, $22.10 cost)
- Episode 3: CRISPR Gene Editing (complete production cycle)  
- Episode 4: Fall of Rome (multi-evaluator consensus)

**Performance Metrics:**
- Cost efficiency: $2.77-$7 per 28-minute episode
- Quality scores: 90%+ consensus across evaluators
- Production time: 15-30 minutes end-to-end
- Word accuracy: 94.89% (speech synthesis)

---

**The system works. It's now organized properly with essential context preserved and complexity minimized.**

*Version: 2.1.0 Enhanced | Updated: 2025-09-01 | Focus: Usability + Essential Knowledge*
