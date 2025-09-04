# 🎙️ Nobody Knows - Production Domain Context
<!-- Domain Context | Token Budget: 5K | Purpose: Episode Production Lifecycle -->

## 📋 PRODUCTION OVERVIEW

**System Purpose:** Automated production of "Nobody Knows" podcast episodes exploring intellectual humility through AI orchestration.

**Production Philosophy:**
- Celebrate both knowledge AND ignorance
- Transform confusion from shame into curiosity
- Make uncertainty exciting, not scary
- Every episode teaches transferable AI skills

## 🔄 EPISODE LIFECYCLE

### Phase 1: Research & Discovery
<section id="research-context">

**Workflow:** `/research-workflow`  
**Agents:** researcher → fact-checker → synthesizer  
**MCP Tool:** `mcp__perplexity-ask__perplexity_ask`

**Research Requirements:**
- ZERO training data - all facts from real-time research
- 2024-2025 sources only (current information)
- Minimum 10 diverse expert sources
- Document uncertainties and knowledge gaps
- Cross-verification of all claims

**Output:** `production/ep_XXX/research/`
- `research_findings.json` - Raw research data
- `validation_report.json` - Fact-checking results
- `synthesis_package.json` - Production-ready knowledge

</section>

### Phase 2: Script Creation
<section id="script-context">

**Workflow:** `/production-workflow`  
**Agents:** writer → polisher → judge  
**Quality Gate:** 3-evaluator consensus (≥85%)

**Script Requirements:**
- 28-minute target duration (~4,200 words)
- Three-part explanation method (Technical/Simple/Connection)
- Intellectual humility integration throughout
- TTS optimization with SSML markup
- Brand voice consistency

**Output:** `production/ep_XXX/script/`
- `initial_script.md` - Writer draft
- `polished_script.md` - TTS-optimized version
- `quality_report.json` - Consensus scores

</section>

### Phase 3: Audio Production
<section id="audio-context">

**Workflow:** `/audio-workflow`  
**Agents:** audio-producer → audio-validator  
**MCP Tools:** `mcp__elevenlabs__text_to_speech` + validation

**Audio Configuration:**
```yaml
voice_id: ZF6FPAbjXT4488VcRRnw  # Amelia (LOCKED)
model: eleven_turbo_v2_5
stability: 0.65
similarity_boost: 0.8
style: 0.3
```

**Output:** `output/episodes/`
- `ep_XXX_nobody_knows.mp3` - Final audio
- `ep_XXX_transcript.md` - Validated transcript
- `ep_XXX_metrics.json` - Quality metrics

</section>

## 📊 STATE MANAGEMENT
<section id="state-management">

**State Manager:** `production/state_manager.py`  
**Global State:** `production/state.json`

### Episode Session Structure
```python
session = {
    "episode_number": 1,
    "topic": "Episode topic",
    "session_id": "ep_001_20250903_143022",
    "status": "initialized|research|script|audio|complete",
    "phases": {
        "research": {"status": "pending|active|complete", "cost": 0.0},
        "script": {"status": "pending|active|complete", "cost": 0.0},
        "audio": {"status": "pending|active|complete", "cost": 0.0}
    },
    "total_cost": 0.0,
    "quality_scores": {},
    "created_at": "ISO timestamp",
    "completed_at": "ISO timestamp"
}
```

### State Operations
```python
# Create new episode
state_mgr = ProductionStateManager()
session_id = state_mgr.create_episode_session(1, "Topic")

# Update phase
state_mgr.update_phase(session_id, "research", "complete", cost=1.05)

# Save checkpoint
state_mgr.save_checkpoint(session_id, phase="script", data={})

# Complete episode
state_mgr.complete_episode(session_id)
```

</section>

## 🎯 QUALITY GATES

### Research Quality
- **Depth Score:** ≥9.0/10 comprehensive coverage
- **Source Authority:** ≥90% verified experts
- **Fact Accuracy:** 100% verification required
- **Currency:** 2024-2025 sources prioritized

### Script Quality
- **Brand Consistency:** ≥90% alignment
- **Technical Accuracy:** ≥85% verified
- **Engagement Score:** ≥80% compelling
- **Consensus Required:** ≥85% agreement

### Audio Quality
- **Word Accuracy:** ≥90% STT validation
- **Audio Clarity:** ≥85% quality score
- **Duration Target:** 27-29 minutes
- **Format:** MP3, 128kbps, 44.1kHz

## 💰 COST TRACKING

### Per-Phase Budgets
```yaml
research_budget: $1.00-2.00
script_budget: $1.00-2.00
audio_budget: $2.00-3.00
total_target: $4.00-7.00
```

### Cost Attribution
- Real-time tracking per MCP call
- Phase-based allocation
- Cumulative episode costs
- Global production metrics

## 📁 PRODUCTION STRUCTURE

```
nobody-knows/production/
├── state.json                    # Global state
├── state_manager.py              # State operations
├── cost_tracking_functions.sh    # Bash utilities
└── ep_XXX_YYYYMMDD_HHMMSS/      # Episode sessions
    ├── research/
    │   ├── research_findings.json
    │   ├── validation_report.json
    │   └── synthesis_package.json
    ├── script/
    │   ├── initial_script.md
    │   ├── polished_script.md
    │   └── quality_report.json
    └── audio/
        ├── audio_chunks/         # If chunking needed
        ├── synthesis_report.json
        └── validation_results.json
```

## 🔗 INTEGRATION POINTS

### Input Sources
- **Content Config:** `content/config/project_config.json`
- **Quality Gates:** `content/config/quality_gates.json`
- **Series Bible:** `content/series-bible/series_bible.md`
- **Episode Template:** `content/episode-template.json`

### Output Destinations
- **Episodes:** `output/episodes/*.mp3`
- **Transcripts:** `output/transcripts/*.md`
- **Metrics:** `output/metrics/*.json`

### Cross-References
- **Agents:** Load @.claude/agents/CLAUDE.md for details
- **Commands:** Load @.claude/commands/CLAUDE.md for workflows
- **Context:** Load @.claude/context/*.md for specialized knowledge

## 🚀 PRODUCTION COMMANDS

### Quick Production
```bash
# Single episode
/podcast-workflow "Your Topic"

# Research only
/research-workflow

# Script only (requires research)
/production-workflow

# Audio only (requires script)
/audio-workflow
```

### State Management
```python
# Check active episodes
python nobody-knows/production/state_manager.py --list

# Resume episode
python nobody-knows/production/state_manager.py --resume ep_001

# Clean failed sessions
python nobody-knows/production/state_manager.py --cleanup
```

---

*Production Domain Context v1.0 | Token Usage: ~4.8K*  
*Central hub for episode production lifecycle management*