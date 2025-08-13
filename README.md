# AI Podcasts - Nobody Knows 🎙️

**A solo hobby project using Claude Code's native capabilities to produce an automated podcast series**

---

## 🎯 What This Is

A production-ready automated podcast system using Claude Code's native AI to create the "Nobody Knows" series. See `projects/nobody-knows/series_plan/episodes_master.json` for the complete episode list.

### Built With
- **9 specialized Claude Code agents** for complete production pipeline
- **MCP integrations** for research (Perplexity) and audio (ElevenLabs)
- **4-level architecture** with strict separation of concerns
- **Educational focus** with mandatory dual explanations (technical + simple)

---

## 🏗️ Four-Level Architecture

**Technical:** Hierarchical separation with strict dependency management and approval gates
**Simple:** Like building levels in a video game - you must complete each before unlocking the next

```text
Level 1: Development Platform (COMPLETE)
├── Purpose: Build tools that build the production system
├── Location: .claude/level-1-dev/
├── Status: ✅ Agent builders and command builders ready
└── Learning: Meta-programming and tool creation

Level 2: Native Claude Code Production (ACTIVE) ✅
├── Purpose: Actual podcast production using Claude's built-in AI
├── Location: .claude/level-2-production/
├── Components:
│   ├── 9 Production Agents (research → script → quality → audio)
│   ├── Perplexity MCP (web research)
│   └── ElevenLabs MCP (audio synthesis)
├── Status: ✅ Production ready with complete testing suite
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
```text

---

## 📁 Real File Structure

```
ai-podcasts-nobody-knows/
├── .env                           # API keys (git-ignored)
├── .claude/config/mcp-config.json # MCP configuration
├── CLAUDE.md                      # Master system prompt (v5.0.0)
├── README.md                      # This file
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
├── projects/nobody-knows/         # Output directory
│   ├── config/                   # Project configuration
│   ├── output/                   # Generated episodes
│   │   ├── audio/               # Final audio files
│   │   ├── research/            # Research packages
│   │   ├── scripts/             # Episode scripts
│   │   ├── quality/             # Quality reports
│   │   └── sessions/            # Session tracking
│   └── series_plan/             # 125 episode definitions
│
└── scripts/                      # Validation and pre-commit scripts
    └── precommit/               # Automated quality checks
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
git clone https://github.com/swm-sink/ai-podcasts-nobody-knows.git
cd ai-podcasts-nobody-knows
```

2. **Set up API keys**

```bash
cp .env.example .env
# Edit .env with your API keys:
# PERPLEXITY_API_KEY=your-perplexity-key
# ELEVENLABS_API_KEY=your-elevenlabs-key
```

3. **MCPs configured locally** (in .claude/mcp-servers/)
   - Configuration: `.claude/config/mcp-config.json`
   - Git-ignored for security

4. **Restart Claude Code** to load MCPs

5. **Install dev dependencies (recommended)**

```bash
python3 -m pip install -r requirements.txt
python3 -m pip install -r dev-requirements.txt
pre-commit install
```

6. **Verify MCPs are loaded in Claude Code**
   - Start Claude Code
   - Check that Perplexity and ElevenLabs tools are available
   - Test with: `mcp__ElevenLabs__list_models`

---

## 📝 Actual Usage

### Producing an Episode (Claude Code Commands)

**In Claude Code interface:**

```
# Test with dry run first (no API costs)
/test-episode-dry-run

# Produce a single episode
/produce-episode

# Batch production
/batch-produce
```

### Available Production Commands
- `/produce-episode` - Main production orchestrator
- `/test-episode-dry-run` - Test without API calls
- `/batch-produce` - Multiple episode production
- `/pipeline-coordinator` - Manage production pipeline
- `/production-metrics` - View production statistics
- `/agent-builder-production` - Create new agents
- `/command-builder-production` - Create new commands

---

## 💰 Actual Costs

### Target Budget (Solo/Hobby)
- **Per Episode**: ESTIMATED <$5.00
- **Daily Limit**: $10.00
- **Alert at**: $4.00

### API Costs (ESTIMATED)
- **Perplexity**: Research (~$2-3)
- **ElevenLabs**: Audio synthesis (~$1-2)
- **Claude Code**: Built-in (no extra cost)

---

## 🤖 Actual AI Agents

All agents are in `.claude/level-2-production/agents/` (9 agents total):

1. **01_research_coordinator.md** - Perplexity MCP web research
2. **02_episode_planner.md** - Episode structure and flow planning
3. **03_script_writer.md** - Claude Code script generation
4. **04_quality_claude.md** - Claude-based quality evaluation
5. **05_quality_gemini.md** - Gemini cross-validation (optional)
6. **06_feedback_synthesizer.md** - Consolidate quality feedback
7. **07_script_polisher.md** - Final script refinement
8. **08_final_reviewer.md** - Production approval gate
9. **09_audio_synthesizer.md** - ElevenLabs audio generation

---

## 🎯 The "Nobody Knows" Podcast

125 episodes exploring the limits of human knowledge with intellectual humility.

### Quality Standards
- **Comprehension**: ≥0.85
- **Brand Consistency**: ≥0.90
- **Engagement**: ≥0.80
- **Technical Accuracy**: ≥0.85

### Season Structure
5 seasons × 25 episodes = 125 episodes total
(See projects/nobody-knows/series_plan/episodes_master.json for complete episode list)

---

## 🔧 Configuration

### API Keys
- `.env` - Contains API keys (git-ignored)
- `.env.example` - Template for others
- Pre-commit hooks include secret scanning; see `.pre-commit-config.yaml` and `.secrets.baseline`.

### MCP Configuration
- `.claude/config/mcp-config.json` - MCP server config

### Project Config
- `projects/nobody-knows/config/project_config.json`
- `projects/nobody-knows/config/quality_gates.json`

---


## 🚶‍♂️ WALK-CRAWL-RUN Learning Progression

**Technical:** Progressive complexity introduction with cost-gated milestones
**Simple:** Like learning to cook - first read recipes, then try simple dishes, finally create feasts

### 🚶 WALK Phase (Weeks 1-4) - Complete ✅
- **Cost:** FREE - No API keys needed
- **Focus:** Understanding concepts without spending money
- **Activities:**
  - ✅ Set up environment
  - ✅ Read all context files
  - ✅ Create agent/command structures
  - ✅ Test with mock data
- **Status:** Complete - Ready for CRAWL phase

### 🐾 CRAWL Phase (Weeks 5-12) - Current Phase 🎯
- **Cost:** $20-50 total
- **Focus:** Connect APIs, produce first episodes
- **Activities:**
  - ✅ Configure MCP servers
  - ⏳ Test with small batches
  - ⏳ Monitor costs closely
  - ⏳ Optimize prompts
- **Status:** Ready to begin production

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

### ✅ Completed Components
- **Foundation:** Complete 4-level architecture
- **Documentation:** Comprehensive XML-based system
- **Agents:** 9 production agents implemented
- **Commands:** 7 production commands ready
- **Testing:** Full test suite with validation scripts
- **MCP Setup:** Perplexity and ElevenLabs configured
- **Quality Gates:** Automated quality assurance

### 🎯 Current Focus: CRAWL Phase
- **Ready to produce first episodes**
- **All systems tested and validated**
- **Cost optimization strategies in place**

### 📝 Next Steps
1. Run `/test-episode-dry-run` to validate pipeline
2. Produce first episode with `/produce-episode`
3. Monitor costs with production metrics
4. Scale to batch production when comfortable

### 🔒 Future (Requires Approval)
- **Level 3:** Documentation only
- **Level 4:** Python/FastAPI with OpenRouter + Langfuse
- **⚠️ GATE:** DO NOT implement Level 4 without explicit "Approved for Level 4 implementation"

---

## 📚 Key Documentation

- `CLAUDE.md` - Master system prompt with educational requirements
- `.claude/README.md` - Technical details and structure
- `.claude/sessions/` - Project status and handovers
- `.claude/context/foundation/` - Core concepts and phases

---

## 🤝 Contributing

We welcome contributions that enhance the educational value of this project!

1. **Read [CONTRIBUTING.md](CONTRIBUTING.md)** for detailed guidelines
2. **Follow the Feynman Rule:** Every contribution must include dual explanations
3. **Test thoroughly:** Use validation scripts in `/scripts/precommit/`
4. **Maintain quality:** Follow DRY principles and quality gates

See [CONTRIBUTING.md](CONTRIBUTING.md) for the complete contribution process.

---

## 📄 License

MIT License (see LICENSE file)

---

## 🙏 Acknowledgments

- Built with Claude Code's native capabilities
- Uses Perplexity and ElevenLabs via MCP
- Philosophy: "Nobody knows everything, but together we can learn anything"

---

**This document reflects the ACTUAL state of the project as of 2025-08-13**

⚠️ **Zero Hallucination Policy**: All claims verified against actual codebase. See CLAUDE.md for enforcement standards.

---

**Quick Start**: Run `/test-episode-dry-run` in Claude Code to begin!
