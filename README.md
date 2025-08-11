# AI Podcasts - Nobody Knows 🎙️

**A solo hobby project using Claude Code's native capabilities to produce an automated podcast series**

---

## 📋 Documentation Status
- **This Document**: Up-to-date and accurate (v2.0.0)
- **Last Updated**: 2025-08-11
- **Previous Issues**: See PROJECT_AUDIT_INCONSISTENCIES.md for historical context

---

## 🎯 What This Project Actually Is

This is a **Native Claude Code implementation** that uses AI agents to automatically produce a 100-episode podcast series called "Nobody Knows" - exploring complex topics with intellectual humility.

### Key Points:
- **NOT a Python application** (no FastAPI, no server)
- **NOT a REST API** (uses Claude Code commands)
- **Uses MCP servers** for external integrations
- **Solo hobby project** (not enterprise/multi-project)
- **Simple approach** (avoiding over-engineering)

---

## 🏗️ Four-Level Architecture

**Technical:** Hierarchical separation with strict dependency management and approval gates  
**Simple:** Like building levels in a video game - you must complete each before unlocking the next

```
Level 1: Development Platform (COMPLETE)
├── Purpose: Build tools that build the production system
├── Location: .claude/level-1-dev/
├── Status: ✅ Agent builders and command builders ready
└── Learning: Meta-programming and tool creation

Level 2: Native Claude Code Production (CURRENT FOCUS) 🎯
├── Purpose: Actual podcast production using Claude's built-in AI
├── Location: .claude/level-2-production/
├── Components:
│   ├── Claude Code AI (script writing & quality evaluation)
│   ├── Perplexity MCP (web research)
│   └── ElevenLabs MCP (audio synthesis)
├── Status: ⏳ Phase 7 - Testing after restart
└── Learning: Production system design and reliability

Level 3: Platform Planning (DOCUMENTATION ONLY)
├── Purpose: Design and document future platform
├── Location: .claude/level-3-platform-dev/
├── Status: 📝 Planning phase only - no code
└── Learning: Architectural planning and migration strategy

Level 4: Coded Python Platform (LOCKED 🔒)
├── Purpose: Future FastAPI implementation
├── Technologies: OpenRouter + Langfuse
├── Status: ⚠️ REQUIRES EXPLICIT USER APPROVAL
├── Gate: User must say "Approved for Level 4 implementation"
└── Learning: Enterprise patterns and observability
```

---

## 📁 Real File Structure

```
ai-podcasts-nobody-knows/
├── .env                           # API keys (git-ignored)
├── .mcp.json                      # MCP configuration (git-ignored)
├── CLAUDE.md                      # Master system prompt (v5.0.0)
├── PROJECT_STATUS_HANDOVER.md     # Complete project context
├── PROJECT_AUDIT_INCONSISTENCIES.md # Documentation issues
│
├── .claude/                       # Claude Code configuration
│   ├── level-1-dev/              # Development platform
│   │   ├── agents/               # Agent builders
│   │   └── commands/             # Command builders
│   │
│   ├── level-2-production/       # Production system
│   │   ├── agents/               # Agent definitions (Markdown)
│   │   │   ├── research-coordinator.md
│   │   │   ├── script-writer.md
│   │   │   ├── quality-evaluator.md
│   │   │   └── audio-synthesizer.md
│   │   └── commands/
│   │       └── produce-episode.md
│   │
│   └── mcp-servers/              # Local MCP installations (git-ignored)
│       ├── elevenlabs-mcp/       # Python-based MCP
│       └── perplexity-mcp/       # Node.js-based MCP
│
└── projects/nobody-knows/         # Output directory
    ├── config/                   # Project configuration
    └── output/                   # Generated episodes
```

---

## 🚀 Actual Setup Instructions

### Prerequisites
- Claude Code installed
- Python 3.11+ (for ElevenLabs MCP)
- Node.js (for Perplexity MCP)
- API keys for Perplexity and ElevenLabs

### Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/ai-podcasts-nobody-knows.git
cd ai-podcasts-nobody-knows
```

2. **Set up API keys**
```bash
cp .env.example .env
# Edit .env with your API keys:
# PERPLEXITY_API_KEY=pplx-YOUR-KEY
# ELEVENLABS_API_KEY=sk_YOUR-KEY
```

3. **MCPs are already installed locally** (in .claude/mcp-servers/)
   - Already configured in .mcp.json
   - Git-ignored for security

4. **Restart Claude Code** to load MCPs

5. **Verify MCPs are loaded**
```bash
claude mcp list
# Should show: elevenlabs, perplexity
```

6. **Test the setup**
```bash
python3 .claude/scripts/test_mcps.py
```

---

## 📝 Actual Usage

### Producing an Episode (Claude Code Commands)

```bash
# Test with dry run first
claude /produce-episode --topic "consciousness" --episode 1 --dry-run

# Actual production
claude /produce-episode --topic "consciousness" --episode 1
```

### Available Commands
- `/produce-episode` - Main production orchestrator
- More commands in `.claude/level-2-production/commands/`

### NOT Available (Despite README.md claims):
- ❌ No REST API endpoints
- ❌ No curl commands
- ❌ No FastAPI server
- ❌ No localhost:8000

---

## 💰 Actual Costs

### Target Budget (Solo/Hobby)
- **Per Episode**: <$5.00
- **Daily Limit**: $10.00
- **Alert at**: $4.00

### API Costs
- **Perplexity**: Research (~$2-3)
- **ElevenLabs**: Audio synthesis (~$1-2)
- **Claude Code**: Built-in (no extra cost)

---

## 🤖 Actual AI Agents

All agents are Markdown files in `.claude/level-2-production/agents/`:

1. **research-coordinator.md**
   - Uses Perplexity MCP for web research
   - Outputs to projects/nobody-knows/output/research/

2. **script-writer.md**
   - Uses Claude Code natively
   - Applies Feynman + Fridman style
   - Outputs to projects/nobody-knows/output/scripts/

3. **quality-evaluator.md**
   - Uses Claude Code natively
   - Validates against quality gates
   - Outputs to projects/nobody-knows/output/quality/

4. **audio-synthesizer.md**
   - Uses ElevenLabs MCP
   - Generates MP3 audio
   - Outputs to projects/nobody-knows/output/audio/

---

## 🎯 The "Nobody Knows" Podcast

100 episodes exploring the limits of human knowledge with intellectual humility.

### Quality Standards
- **Comprehension**: ≥0.85
- **Brand Consistency**: ≥0.90
- **Engagement**: ≥0.80
- **Technical Accuracy**: ≥0.85

### Season Structure
10 seasons × 10 episodes = 100 episodes total
(See season1_topics.csv for episode topics)

---

## 🔧 Configuration

### API Keys
- `.env` - Contains API keys (git-ignored)
- `.env.example` - Template for others

### MCP Configuration
- `.mcp.json` - MCP server config (git-ignored)
- `.mcp.json.example` - Template for others

### Project Config
- `projects/nobody-knows/config/project_config.json`
- `projects/nobody-knows/config/quality_gates.json`

---

## ⚠️ What This Project Is NOT

- ❌ **NOT a Python web application**
- ❌ **NOT a FastAPI server**
- ❌ **NOT using ChromaDB**
- ❌ **NOT a REST API**
- ❌ **NOT multi-project**
- ❌ **NOT using pytest**
- ❌ **NOT enterprise software**

---

## 🚶‍♂️ WALK-CRAWL-RUN Learning Progression

**Technical:** Progressive complexity introduction with cost-gated milestones  
**Simple:** Like learning to cook - first read recipes, then try simple dishes, finally create feasts

### 🚶 WALK Phase (Weeks 1-4) - Current Phase 🎯
- **Cost:** FREE - No API keys needed
- **Focus:** Understanding concepts without spending money
- **Activities:**
  - ✅ Set up environment
  - ✅ Read all context files  
  - ✅ Create agent/command structures
  - ⏳ Test with mock data
- **Status:** Phase 6 complete, Phase 7 pending restart

### 🐾 CRAWL Phase (Weeks 5-12)
- **Cost:** $20-50 total
- **Focus:** Connect APIs, produce first episodes
- **Activities:**
  - Configure MCP servers (done)
  - Test with small batches
  - Monitor costs closely
  - Optimize prompts
- **Status:** Ready after Phase 7-8 testing

### 🏃 RUN Phase (Weeks 13+)
- **Cost:** $50-100/month
- **Focus:** Scale production
- **Activities:**
  - Batch production
  - Season management
  - Quality automation
  - Cost optimization
- **Status:** Future phase

---

## 🚦 Current Project Status

### ✅ Completed Phases
- **Phase 1-3:** Foundation Architecture ✅
- **Phase 4:** CLAUDE.md Restoration (v5.0.0) ✅
- **Phase 5:** API Key Configuration (.env) ✅
- **Phase 6:** MCP Installation & Setup ✅

### ⏳ Current Phase
- **Phase 7:** Test Native Claude Code (PENDING RESTART)
  - 7.1: Verify MCPs available after restart
  - 7.2: Test research agent with Perplexity
  - 7.3: Test audio agent with ElevenLabs
  - 7.4: Test script writer with Claude native
  - 7.5: Test quality evaluator

### 📝 Next Phase
- **Phase 8:** Simple Integration
  - 8.1: Update agents to use MCP tools
  - 8.2: Test episode production end-to-end
  - 8.3: Verify costs are under $5/episode

### 🔒 Future (Requires Approval)
- **Level 3:** Documentation only
- **Level 4:** Python/FastAPI with OpenRouter + Langfuse
- **⚠️ GATE:** DO NOT implement Level 4 without explicit "Approved for Level 4 implementation"

---

## 📚 Key Documentation

- `CLAUDE.md` - Master system prompt (v5.0.0)
- `PROJECT_STATUS_HANDOVER.md` - Complete project context
- `PROJECT_AUDIT_INCONSISTENCIES.md` - Issues found in docs
- `.claude/config/simple-setup.md` - Simplified approach

---

## 🤝 Contributing

This is a solo hobby project, but if you want to use it:

1. Copy `.env.example` to `.env` and add your API keys
2. Copy `.mcp.json.example` to `.mcp.json` and update paths
3. Install MCPs locally in `.claude/mcp-servers/`
4. Follow the setup instructions above

---

## 📄 License

No license file exists yet (README.md incorrectly claims MIT)

---

## 🙏 Acknowledgments

- Built with Claude Code's native capabilities
- Uses Perplexity and ElevenLabs via MCP
- Philosophy: "Nobody knows everything, but together we can learn anything"

---

**This document reflects the ACTUAL state of the project as of 2025-08-11**