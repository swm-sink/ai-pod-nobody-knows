# /research-episode-enhanced - Native Claude Code Research Workflow

## 🚨 QUALITY-OPTIMIZED WITH EMPIRICAL THRESHOLDS - Episode 1 Validated

**Date**: August 25, 2025
**Source**: Episode 1 production validation - quality threshold recalibration
**Impact**: All research quality gates aligned with achievable >85% production thresholds

Execute comprehensive research for a "Nobody Knows" podcast episode using Claude Code native orchestration patterns with empirically validated quality gates and integrated validation framework.

## Usage

```bash
/research-episode-enhanced [episode_number] [topic] [--batch-mode]
```

## Examples

```bash
/research-episode-enhanced 1 "The Dirty Secret: Even the Experts Are Making It Up"
/research-episode-enhanced 25 "Season Finale: What We've Learned About Not Knowing" --batch-mode
```

## Native Claude Code Orchestration

This command demonstrates proper Claude Code architecture where **the main chat acts as orchestrator** and uses the **Task tool** to delegate to specialized sub-agents, rather than using separate orchestrator agents (which violate native patterns).

### Research Workflow Architecture

**Native Pattern (This Command)**:
```
Main Chat → Task tool → Specialized research agents
```

**Anti-Pattern (Avoided)**:
```
Main Chat → Orchestrator Agent → Sub-agents
```

## Research Pipeline Execution

I will coordinate the complete research pipeline using Task tool delegation:

### Step 1: Initialize Research Session
```
Create session directory: sessions/ep_{number}_{timestamp}/research/
Set up tracking for three-agent research workflow
Initialize cost tracking and quality gates
```

### Step 2: Task Delegation to Deep Research Agent
```
Use Task tool to delegate to deep-research-agent-enhanced:

REQUIREMENTS:
- Multi-round Perplexity searches (10+ rounds with current date context August 2025)
- WebSearch integration for real-time source validation and expert quote verification
- Expert quotes with pronunciation validation (IPA phoneme markup for names)
- Expert authority verification and credibility assessment
- Cross-episode awareness for thematic connections and series coherence
- Save COMPLETE research data (not just metadata) with quality metrics
- Focus on intellectual humility brand alignment (>85% threshold target)
```

### Step 3: Task Delegation to Question Generator Agent
```
Use Task tool to delegate to question-generator-enhanced:

INPUT: Deep research findings from Step 2
REQUIREMENTS:
- Generate 50+ specific research questions with empirical validation focus
- Adaptive complexity scaling based on episode complexity level
- Brand alignment with "Nobody Knows" intellectual humility philosophy (>85% consistency target)
- Cross-episode intelligence integration with production quality awareness
- Prioritize by relevance, research depth, and production feasibility
- Include pronunciation and accuracy verification questions for expert names
- Save comprehensive question framework with quality validation criteria
```

### Step 4: Task Delegation to Research Synthesizer Agent
```
Use Task tool to delegate to research-synthesizer-enhanced:

INPUT: All research findings + generated questions
REQUIREMENTS:
- Cross-domain integration and narrative coherence optimization
- Intelligent knowledge graph management for series-level insights
- Brand voice preservation throughout synthesis (>85% consistency validation)
- Production-ready knowledge package with empirical quality gates integration
- Comprehensive research package with cross-episode connections and pronunciation guides
- Quality validation using Episode 1 calibrated thresholds (>85% composite validation)
- Expert name pronunciation accuracy preparation for TTS optimization
- Research accuracy verification against empirical production requirements
```

### Step 5: Session Management & User Review
```
Coordinate session completion:
- Aggregate all agent outputs into comprehensive research package with quality validation
- Create readable summary: sessions/ep_{number}_{timestamp}/research/research_summary.md with quality metrics
- Save complete research data: sessions/ep_{number}_{timestamp}/research/research_complete.json with empirical validation
- Track costs and validate quality gates using Episode 1 calibrated thresholds
- Include pronunciation guide for all expert names and technical terms
- Prepare user review checkpoint with production readiness assessment
```

## Data Persistence Structure

**CRITICAL**: Save complete research data using this structure:

```json
{
  "session_metadata": {
    "session_id": "ep_{number}_research_{timestamp}",
    "topic": "[EPISODE_TOPIC]",
    "complexity_level": 1-10,
    "status": "completed",
    "total_cost": 0.00,
    "timestamp": "2025-08-24T00:00:00Z",
    "orchestration_method": "main_chat_task_tool"
  },
  "research_data": {
    "deep_research": {
      "perplexity_rounds": [...],
      "websearch_results": [...],
      "expert_quotes": [...],
      "research_findings": [...],
      "authoritative_sources": [...],
      "cross_episode_connections": [...]
    },
    "questions": {
      "strategic_questions": [...],
      "complexity_adapted": [...],
      "brand_aligned": [...],
      "cross_episode_aware": [...]
    },
    "synthesis": {
      "structured_knowledge": {...},
      "key_insights": [...],
      "research_gaps": [...],
      "production_ready_package": {...},
      "quality_validation": {...}
    }
  },
  "quality_metrics": {
    "research_depth_score": "percentage (target >85% - empirically validated)",
    "brand_consistency_score": "percentage (target >85% - Episode 1 aligned)",
    "source_authority_score": "percentage (target >90% - expert validation)",
    "cross_episode_value_score": "percentage (target >80% - series coherence)",
    "pronunciation_readiness_score": "percentage (target 100% - IPA coverage for experts)",
    "production_compatibility_score": "percentage (target >85% - empirical integration)"
  },
  "external_tools_used": {
    "websearch_queries": [...],
    "perplexity_queries": [...],
    "validation_sources": [...]
  }
}
```

## Integration with External Research Tools

### WebSearch Integration
- Real-time source validation during research with authority scoring
- Official documentation verification and credibility assessment
- Current developments and expert perspectives with 2025 context validation
- Cross-reference validation for research findings against multiple authoritative sources
- Expert pronunciation verification and name authority validation

### Perplexity MCP Integration
- Citation-backed expert synthesis with >90% authority threshold
- Multi-source knowledge consolidation with cross-validation requirements
- Authoritative source prioritization using empirical quality criteria
- Fact-checking and validation support with >85% accuracy target
- Expert quote authenticity verification and pronunciation guide preparation

## Success Criteria

- ✅ All three research agents completed successfully via Task tool delegation
- ✅ COMPLETE research data saved with empirical quality validation metrics
- ✅ External tools (WebSearch, Perplexity MCP) successfully integrated with authority scoring
- ✅ Research package ready for user review with >85% quality threshold validation
- ✅ Cost tracked and within reasonable bounds (research cost efficiency optimized)
- ✅ Cross-episode insights and brand alignment achieved (>85% consistency target)
- ✅ Expert pronunciation readiness validated (IPA coverage for all technical names)
- ✅ Production compatibility validated using Episode 1 empirical standards
- ✅ Native Claude Code orchestration pattern demonstrated

## User Review Point

After completing all research coordination:

1. **Create readable summary**: `sessions/ep_{number}_{timestamp}/research/research_summary.md`
2. **Save complete data package**: `sessions/ep_{number}_{timestamp}/research/research_complete.json`
3. **Quality validation report**: Research depth >85%, brand consistency >85%, source authority >90% metrics
4. **Pronunciation readiness report**: IPA coverage validation for all expert names and technical terms
5. **Cost tracking summary**: Total research cost and efficiency metrics with production cost integration
5. **Notify user**: "Research completed! Review at: [SESSION_PATH] before proceeding to production."

This enhanced research command demonstrates proper Claude Code native orchestration while preserving and enhancing all research functionality, integrating external research tools, and providing comprehensive quality assurance.

## Technical Implementation Notes

- Uses **Task tool delegation** instead of separate orchestrator agents
- **Main chat maintains context** and coordinates all research activities
- **Sub-agents operate independently** with clean contexts and specialized expertise
- **External tool integration** enhances research depth and validation
- **Complete data persistence** ensures no information loss
- **Quality gates** maintain high standards throughout research process
- **User review checkpoints** enable approval before production begins

Ready to execute comprehensive research for the specified episode using Claude Code native patterns.
