# Production Domain Context - LangGraph Podcast System
<!-- Context Level: Domain | Inherits: Project Root | Token Budget: 5K -->

## 📍 DOMAIN OVERVIEW

**Purpose**: Automated podcast production using LangGraph orchestration
**Architecture**: 4-pipeline system with 16 specialized agents
**Performance**: $5.51/episode | 95% success rate | 26-28min audio

## 🏗️ LANGGRAPH PRODUCTION PATTERNS

### Core State Schema
```python
from typing_extensions import TypedDict
from typing import List, Dict, Any, Optional
from datetime import datetime

class PodcastState(TypedDict):
    """Production state - msgpack serializable"""
    # Core fields
    episode_id: str
    topic: str
    budget: float
    timestamp: str
    
    # Pipeline data
    research_data: Dict[str, Any]
    questions: List[str]
    episode_plan: Dict[str, Any]
    script: str
    audio_url: Optional[str]
    
    # Quality & monitoring
    cost_tracking: Dict[str, float]
    quality_scores: Dict[str, float]
    brand_validation: Dict[str, Any]
    consensus_scores: Dict[str, float]
    
    # Workflow control
    checkpoint_id: Optional[str]
    error_state: Optional[Dict[str, Any]]
    retry_count: int
```

### Workflow Orchestration
```python
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint import MemorySaver

# Create graph with checkpointing
memory = MemorySaver()
graph = StateGraph(PodcastState)

# Add pipeline nodes
graph.add_node("research_pipeline", research_pipeline_node)
graph.add_node("content_pipeline", content_pipeline_node)
graph.add_node("quality_pipeline", quality_pipeline_node)
graph.add_node("production_pipeline", production_pipeline_node)

# Define flow
graph.add_edge(START, "research_pipeline")
graph.add_conditional_edges(
    "research_pipeline",
    lambda x: "content" if x["research_data"] else "error",
    {"content": "content_pipeline", "error": END}
)

# Compile with checkpointing
app = graph.compile(checkpointer=memory)
```

## 🤖 AGENT SPECIFICATIONS

### Research Pipeline (4 agents)
```yaml
research_discovery:
  api: Perplexity Sonar Deep Research
  pattern: Concurrent queries with httpx.AsyncClient
  output: Discovery findings + citations
  cost: ~$0.15

research_deep_dive:
  api: Perplexity follow-up queries
  pattern: Expert perspectives + technical details
  output: Comprehensive research package
  cost: ~$0.20

research_validation:
  api: Cross-reference verification
  pattern: Fact-checking + source validation
  output: Validated claims with confidence scores
  cost: ~$0.10

research_synthesis:
  api: Knowledge consolidation
  pattern: Structured narrative building
  output: Cohesive research document
  cost: ~$0.15
```

### Content Pipeline (4 agents)
```yaml
question_generator:
  pattern: Strategic question creation
  output: 15-20 engaging questions
  validation: Diversity + depth scoring

episode_planner:
  pattern: 47-minute structure planning
  output: Detailed episode outline
  validation: Timing + flow checks

script_writer:
  requirement: 33,000-37,000 characters
  pattern: Conversational narrative
  output: Complete episode script
  validation: Brand voice compliance

brand_validator:
  pattern: Intellectual humility scoring
  metrics: Wonder, acknowledgment, exploration
  threshold: 0.85 minimum score
```

### Quality Pipeline (2 evaluators)
```yaml
claude_evaluator:
  model: Claude via MCP
  dimensions: Content, structure, engagement
  output: Detailed feedback + scores

gemini_evaluator:
  model: Gemini via API
  dimensions: Technical accuracy, flow, accessibility  
  output: Alternative perspective + scores

consensus: Multi-evaluator agreement required (>8.0)
```

### Production Pipeline (2 agents)
```yaml
audio_synthesizer:
  api: ElevenLabs TTS
  voice: ZF6FPAbjXT4488VcRRnw (Amelia)
  optimization: Chunked synthesis + SSML
  output: 26-28 minute audio file

audio_validator:
  checks: Duration, quality, pronunciation
  pattern: STT validation + metrics
  output: Quality report + pass/fail
```

## 📁 FILE STRUCTURE

```
podcast_production/
├── main.py                    # CLI entry point
├── workflows/
│   ├── main_workflow.py      # Primary StateGraph
│   ├── research_pipeline.py  # Research orchestration
│   └── production_pipeline.py # Content → Audio
├── agents/                   # 16 agent implementations
├── core/
│   ├── state.py             # State management
│   ├── cost_tracker.py      # Budget enforcement
│   └── checkpoint_manager.py # Persistence
└── config/
    ├── production-voice.json # Voice configuration
    └── providers.yaml       # API settings
```

## ⚡ PRODUCTION COMMANDS

### Standard Production
```bash
cd podcast_production
python main.py --topic "Why do we dream?" --budget 5.51
```

### Advanced Options
```bash
# Dry run (no API calls)
python main.py --topic "Topic" --dry-run

# Research only
python main.py --topic "Topic" --research-only

# Resume from checkpoint
python main.py --resume checkpoint_id

# Verbose monitoring
python main.py --topic "Topic" --verbose
```

### Batch Production
```bash
# Multiple episodes
python main.py --batch topics.txt --budget 5.51

# With parallel research
python main.py --batch topics.txt --parallel-research
```

## 💰 COST BREAKDOWN

| Component | Cost | Percentage |
|-----------|------|------------|
| Research (Perplexity) | $0.60 | 11% |
| Script Writing (Claude) | $1.20 | 22% |
| Quality Evaluation | $0.80 | 14% |
| Audio Synthesis (ElevenLabs) | $2.50 | 45% |
| Overhead & Retries | $0.41 | 8% |
| **Total Average** | **$5.51** | **100%** |

## 🔧 CONFIGURATION

### Environment Variables
```bash
# Required API keys
ELEVEN_LABS_API_KEY=xxx
ANTHROPIC_API_KEY=xxx
GOOGLE_API_KEY=xxx
PERPLEXITY_API_KEY=xxx

# Production settings
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
PRODUCTION_BUDGET=5.51
PRODUCTION_RETRY_LIMIT=3
```

### Config Files
- `config.yaml` - System configuration
- `providers.yaml` - API provider settings
- `production-voice.json` - Voice configuration (PROTECTED)

## 🚨 ERROR HANDLING

### Retry Strategy
```python
retry_config = {
    "max_attempts": 3,
    "backoff_factor": 2.0,
    "timeout": 30.0,
    "retry_on": [httpx.TimeoutException, httpx.HTTPStatusError]
}
```

### Checkpoint Recovery
```python
# Automatic checkpoint on each node completion
# Resume from any failure point
if checkpoint_id:
    state = app.get_state(checkpoint_id)
    app.resume(state)
```

### Budget Protection
```python
# Hard stop at budget limit
if state["cost_tracking"]["total"] >= state["budget"]:
    return {...state, "error_state": {"reason": "budget_exceeded"}}
```

## 📊 MONITORING

### Real-time Dashboard
```bash
npm run dashboard  # WebSocket monitoring
```

### Metrics Tracked
- Cost per agent/operation
- Token usage by provider
- Quality scores per episode
- Error rates and recovery
- Production timeline

## 🔄 INHERITANCE

**Inherits From**: `/CLAUDE.md` (Project Root)
**Child Contexts**:
- `@agents/CLAUDE.md` - Agent-specific patterns
- `@workflows/CLAUDE.md` - Workflow details
- `@config/CLAUDE.md` - Configuration rules

**Loading Priority**: Production tasks load this + relevant children

---

**Quick Ref**: Token Budget: 5K | Focus: LangGraph patterns | Status: Production-ready