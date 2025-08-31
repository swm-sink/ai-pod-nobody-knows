# AGENT REGISTRY - Complete Documentation of All 16 Agents

## Overview
This document provides comprehensive documentation for all 16 agents in the AI Podcast Production System. Each agent serves a specific, necessary purpose in the production pipeline.

**Total Episode Budget**: $5.51 (optimizing from $6.75)
**Architecture**: LangGraph nodes with state management
**Deployment**: Local execution only

---

## 🔬 RESEARCH STREAM (4 Agents - $2.00 Total)

### 1. research-discovery
**Budget**: $0.50
**Purpose**: Maps the topic landscape and identifies key experts
**Location**: `.claude/agents/discovery.md` → `src/agents/research_discovery.py`
**Status**: ✅ Migrated to LangGraph

**Inputs**:
- Topic string
- Episode context

**Outputs**:
- Topic overview
- Key concepts identified
- Expert list
- Initial source materials
- Research directions

**Why Necessary**: Creates the foundation for all subsequent research. Without proper discovery, the episode lacks comprehensive coverage.

---

### 2. research-deep-dive
**Budget**: $1.00
**Purpose**: Conducts comprehensive research with citations
**Location**: `.claude/agents/deep-dive.md` → `src/agents/research_deep_dive.py`
**Status**: ✅ Migrated to LangGraph

**Inputs**:
- Discovery results
- Research directions

**Outputs**:
- Detailed research data
- Expert quotes
- Statistical evidence
- Historical context
- Current developments

**Why Necessary**: Provides the depth and credibility that distinguishes quality content from surface-level discussion.

---

### 3. research-validate
**Budget**: $0.35
**Purpose**: Fact-checking and credibility assessment
**Location**: `.claude/agents/research-validate.md` → `src/agents/research_validation.py`
**Status**: ✅ Migrated to LangGraph

**Inputs**:
- Deep dive results
- Claims to verify

**Outputs**:
- Verified facts
- Credibility scores
- Contradiction flags
- Source reliability ratings

**Why Necessary**: Ensures accuracy and prevents misinformation. Critical for maintaining trust and intellectual integrity.

---

### 4. research-synthesis
**Budget**: $0.15
**Purpose**: Consolidates all research into coherent narrative
**Location**: `.claude/agents/synthesis.md` → `src/agents/research_synthesis.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- All research outputs
- Validation results

**Outputs**:
- Synthesized knowledge package
- Key themes
- Narrative structure
- Episode hooks

**Why Necessary**: Transforms raw research into a structured foundation for script writing. Bridges research and production.

---

## ✍️ PLANNING & WRITING STREAM (4 Agents - $2.50 Total)

### 5. question-generator
**Budget**: $0.10
**Purpose**: Creates targeted research questions
**Location**: `.claude/agents/generator.md` → `src/agents/question_generator.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Topic
- Initial research

**Outputs**:
- Research questions
- Exploration angles
- Curiosity hooks

**Why Necessary**: Drives deeper investigation and ensures comprehensive topic coverage. Creates engaging narrative angles.

---

### 6. episode-planner
**Budget**: $0.20
**Purpose**: Structures episode flow and segments
**Location**: `.claude/agents/planner.md` → `src/agents/episode_planner.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Research synthesis
- Target duration

**Outputs**:
- Episode structure
- Segment breakdown
- Timing allocations
- Transition points

**Why Necessary**: Creates professional podcast structure. Ensures logical flow and proper pacing.

---

### 7. script-writer
**Budget**: $1.75
**Purpose**: Core content creation - transforms research into script
**Location**: `.claude/agents/writer.md` → `src/agents/script_writer.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Episode plan
- Research synthesis
- Brand guidelines

**Outputs**:
- Full episode script
- Speaker notes
- Emphasis markers

**Why Necessary**: The heart of content creation. Transforms research into engaging, conversational narrative.

---

### 8. script-polisher
**Budget**: $0.30
**Purpose**: Refines script for audio production
**Location**: `.claude/agents/polisher.md` → `src/agents/script_polisher.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Raw script
- TTS requirements

**Outputs**:
- Polished script
- Pronunciation guides
- Pacing markers

**Why Necessary**: Optimizes script for TTS synthesis. Improves audio quality and listener experience.

---

## 🎯 BRAND & QUALITY STREAM (3 Agents - $0.80 Total)

### 9. brand-validator
**Budget**: $0.25
**Purpose**: Ensures "Nobody Knows" brand consistency
**Location**: `.claude/agents/brand-validator.md` → `src/agents/brand_validator.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Script content
- Brand guidelines

**Outputs**:
- Brand alignment score
- Violation flags
- Improvement suggestions

**Why Necessary**: Maintains consistent brand voice and intellectual humility philosophy across all episodes.

---

### 10. claude-evaluator
**Budget**: $0.30
**Purpose**: Primary quality assessment using Claude
**Location**: `.claude/agents/claude.md` → `src/agents/claude_evaluator.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Complete script
- Quality criteria

**Outputs**:
- Quality scores
- Improvement recommendations
- Content gaps

**Why Necessary**: Provides sophisticated quality evaluation. Identifies areas for improvement before production.

---

### 11. gemini-evaluator
**Budget**: $0.25
**Purpose**: Alternative quality perspective using Gemini
**Location**: `.claude/agents/gemini.md` → `src/agents/gemini_evaluator.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Complete script
- Quality criteria

**Outputs**:
- Alternative quality scores
- Different perspective insights
- Technical accuracy checks

**Why Necessary**: Provides second opinion. Different model perspectives catch different issues.

---

## 🎙️ AUDIO PRODUCTION STREAM (3 Agents - $1.10 Total)

### 12. tts-optimizer
**Budget**: $0.15
**Purpose**: Prepares script with SSML markup
**Location**: `.claude/agents/optimizer.md` → `src/agents/tts_optimizer.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Polished script
- Voice parameters

**Outputs**:
- SSML-enhanced script
- Emphasis tags
- Pause markers
- Pronunciation guides

**Why Necessary**: Dramatically improves TTS output quality. Makes synthetic voice sound more natural.

---

### 13. audio-synthesizer
**Budget**: $0.50
**Purpose**: Primary audio generation via ElevenLabs
**Location**: `.claude/agents/synthesizer.md` → `src/agents/audio_synthesizer.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- SSML script
- Voice configuration

**Outputs**:
- Audio file (MP3)
- Generation metadata
- Cost tracking

**Why Necessary**: Core audio production. Generates the actual podcast audio file.

---

### 14. audio-synthesizer-direct
**Budget**: $0.45
**Purpose**: Backup/alternative synthesis path
**Location**: `.claude/agents/synthesizer-direct.md` → `src/agents/audio_synthesizer_direct.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Script (non-SSML)
- Voice configuration

**Outputs**:
- Audio file (MP3)
- Direct API metadata

**Why Necessary**: Provides fallback option. Different approach can handle edge cases main synthesizer misses.

---

## ✅ VALIDATION STREAM (2 Agents - $0.35 Total)

### 15. audio-validator
**Budget**: $0.20
**Purpose**: Validates audio quality and correctness
**Location**: `.claude/agents/audio-validator.md` → `src/agents/audio_validator.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Generated audio
- Original script

**Outputs**:
- Audio quality metrics
- Error detection
- Pronunciation accuracy

**Why Necessary**: Catches synthesis errors before publication. Ensures professional audio quality.

---

### 16. perplexity-agent
**Budget**: $0.15
**Purpose**: Final fact verification and accuracy check
**Location**: `.claude/agents/perplexity.md` → `src/agents/perplexity_agent.py`
**Status**: ⏳ Pending Migration

**Inputs**:
- Final script
- Key claims

**Outputs**:
- Final fact checks
- Accuracy confirmation
- Update flags

**Why Necessary**: Last line of defense against errors. Ensures factual accuracy in final product.

---

## 📊 BUDGET OPTIMIZATION

### Current Budget Allocation
| Stream | Agents | Budget | Percentage |
|--------|--------|--------|------------|
| Research | 4 | $2.00 | 29.6% |
| Planning & Writing | 4 | $2.50 | 37.0% |
| Brand & Quality | 3 | $0.80 | 11.9% |
| Audio Production | 3 | $1.10 | 16.3% |
| Validation | 2 | $0.35 | 5.2% |
| **TOTAL** | **16** | **$6.75** | **100%** |

### Optimization Strategy
Target: Reduce from $6.75 to $5.51 (18.4% reduction)

**Optimization Approaches**:
1. Use caching for repeated research queries
2. Batch API calls where possible
3. Implement conditional routing (skip agents if quality already high)
4. Use smaller models for simple tasks
5. Optimize prompt lengths

---

## 🔄 MIGRATION STATUS

### Completed (3/16 - 18.75%)
- ✅ research-discovery
- ✅ research-deep-dive
- ✅ research-validate

### In Progress (0/16)
None currently

### Pending (13/16 - 81.25%)
- ⏳ research-synthesis
- ⏳ question-generator
- ⏳ episode-planner
- ⏳ script-writer
- ⏳ script-polisher
- ⏳ brand-validator
- ⏳ claude-evaluator
- ⏳ gemini-evaluator
- ⏳ tts-optimizer
- ⏳ audio-synthesizer
- ⏳ audio-synthesizer-direct
- ⏳ audio-validator
- ⏳ perplexity-agent

---

## 🏗️ IMPLEMENTATION NOTES

### LangGraph Node Pattern
Each agent follows this pattern:
```python
class AgentNode:
    def __init__(self, config):
        self.budget = config['budget']
        self.provider = config['provider']

    async def execute(self, state: PodcastState) -> PodcastState:
        # Agent logic here
        return updated_state
```

### State Management
All agents share and update the same PodcastState:
```python
class PodcastState(TypedDict):
    episode_id: str
    topic: str
    research_data: Dict
    script: str
    audio_config: Dict
    quality_scores: Dict
    cost_tracking: Dict
    # ... more fields
```

### Error Handling
Each agent implements:
- Retry logic with exponential backoff
- Graceful degradation
- Cost tracking per attempt
- Error logging and reporting

---

## 📝 MAINTENANCE NOTES

**Last Updated**: August 31, 2025
**Maintainer**: Solo Developer (Hobby Project)
**Review Frequency**: After each migration

**Key Principles**:
1. Each agent has a specific, non-redundant purpose
2. Agents are loosely coupled via state
3. Failed agents should not break the pipeline
4. Cost tracking is mandatory for each agent
5. Quality validation happens at multiple stages

---

END OF AGENT REGISTRY
