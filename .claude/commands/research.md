# /research - Enhanced Deep Knowledge Research

Execute comprehensive research for a "Nobody Knows" podcast episode using Claude Code native orchestration patterns with multi-stage research pipeline and quality validation.

## Usage

```bash
/research [episode_number] [topic] [--batch-mode]
```

## Examples

```bash
/research 1 "The Dirty Secret: Even the Experts Are Making It Up"
/research 25 "Season Finale: What We've Learned About Not Knowing" --batch-mode
```

## Purpose
Conduct systematic, evidence-based research using multi-query strategy with cross-verification, expert diversification, and intellectual humility integration.

## Research Strategy Framework

**Comprehensive Research Approach:**
- **Foundation Building**: Topic landscape, stakeholder identification, expert discovery
- **Deep Investigation**: Technical complexity, multiple perspectives, historical context
- **Uncertainty Exploration**: Knowledge gaps, expert disagreements, areas of active debate
- **Validation**: Cross-verification, fact-checking, source triangulation
- **Future Context**: Expert predictions, scenario analysis, emerging developments

**Quality Targets:**
- **Research Quality**: ≥9.0/10 comprehensive coverage
- **Expert Sources**: 10+ diverse expert quotes from multiple institutions
- **Cross-verification**: Major claims verified through multiple sources
- **Budget**: $1.35 research allocation

## When to Use
- **REQUIRED for:** Episode research requiring comprehensive expert integration
- **Requirements:** Multi-query strategy, cross-verification protocols, expert diversification
- **Quality gate:** Research quality ≥9.0/10, brand consistency ≥90%, source authority ≥90%

## Native Claude Code Orchestration

This command demonstrates proper Claude Code architecture where **the main chat acts as orchestrator** and **directly invokes specialized research agents**, using native orchestration patterns for optimal agent execution and tool access.

### Research Workflow Architecture

**Native Pattern (This Command)**:
```
Main Chat → Direct Agent Invocation → Specialized research agents
```

**Anti-Pattern (Avoided)**:
```
Main Chat → Task Tool Delegation → Simulated agent responses
```

## Research Pipeline Execution

I will coordinate the complete research pipeline using direct orchestrator invocation:

### Step 1: Initialize Research Session
```
Create session directory: sessions/ep_{number}_{timestamp}/research/
Set up tracking for three-agent research workflow
Initialize cost tracking and quality gates
```

### Step 2: Direct Invocation of Research Discovery Agent
```
Use the research-discovery agent to establish research foundation:

REQUIREMENTS:
- Strategic research questions with adaptive complexity scaling
- Topic mapping with stakeholder identification and authority assessment
- Expert discovery targeting diverse institutional sources
- Source identification with credibility scoring and verification protocols
- Cross-episode awareness and thematic connections
- Brand alignment with intellectual humility philosophy
```

### Step 3: Direct Invocation of Research Deep Dive Agent
```
Use the research-deep-dive agent for comprehensive investigation:

INPUT: Research foundation from Step 2 (strategic questions + sources)
REQUIREMENTS:
- Execute comprehensive multi-query Perplexity research strategy
- Expert quote collection with pronunciation validation (IPA markup)
- Comprehensive content gathering with cross-verification protocols
- Expert source diversification from multiple institutional types
- Information synthesis with authority validation and bias assessment
- Knowledge gap identification and uncertainty celebration
- Save complete research data with quality metrics validation
```

### Step 4: Direct Invocation of Research Validation Agent
```
Use the research-validation agent for fact-checking and verification:

INPUT: Deep research findings (comprehensive multi-query data)
REQUIREMENTS:
- Multi-source triangulation with minimum 2 independent sources per claim
- Expert quote verification and attribution accuracy checking
- Statistical and technical fact-checking with methodology assessment
- Contradiction detection and expert disagreement documentation
- Credibility assessment and source authority scoring
- Uncertainty quantification and intellectual humility alignment
- Cross-verification using WebSearch for additional validation
```

### Step 5: Direct Invocation of Research Synthesis Agent
```
Use the research-synthesis agent to create production-ready package:

INPUT: Validated research findings + verification results
REQUIREMENTS:
- Cross-verification protocols with triangulated validation
- Expert source diversification documentation and pronunciation guides
- Intelligent knowledge graph management for series-level insights
- Brand voice preservation throughout synthesis (≥90% consistency)
- Production-ready knowledge package with quality gates integration
- Research accuracy verification against production requirements
- Expert name pronunciation accuracy preparation for TTS optimization
```

### Step 6: Session Management & User Review
```
Coordinate session completion:
- Aggregate all agent outputs into comprehensive research package
- Create readable summary: sessions/ep_{number}_{timestamp}/research/research_summary.md
- Save complete research data: sessions/ep_{number}_{timestamp}/research/research_complete.json
- Track costs and validate quality gates using production-calibrated thresholds
- Include pronunciation guide for all expert names and technical terms
- Prepare user review checkpoint with production readiness assessment
```

## Process

### 1. Research Planning
**Using structured research framework:**
- **Focused Research Questions:** Transform exploration findings into specific, answerable research questions with success criteria
- **Information Architecture:** Map required information types using knowledge taxonomy (factual, procedural, conceptual, metacognitive)
- **Research Scope Definition:** Set clear boundaries with inclusion/exclusion criteria and timeline constraints
- **Source Validation Strategy:** Define credibility assessment framework with scoring criteria (authority, accuracy, objectivity, currency, coverage)

**Chain-of-Thought Planning:** For each research question, document: "To answer [question], I need [information type] from [source types] validated by [criteria]"

### 2. Source Gathering
**Using multi-source evidence collection:**
- **Academic Sources:** Research studies and papers with impact factor assessment and peer review status
- **Official Documentation:** Specifications, standards, and technical documentation with version control and maintenance status
- **Industry Intelligence:** Best practices, case studies, and implementation reports with adoption metrics and outcome validation
- **Expert Consensus:** Professional opinions, community discussions, and expert interviews with credentialing verification
- **Performance Data:** Benchmarks, comparisons, and empirical studies with methodology assessment and reproducibility validation

**Source Quality Matrix:** Rate each source on 5-point scale for Authority, Accuracy, Objectivity, Currency, Coverage (AAOCC Framework)

### 3. Information Analysis
**Using systematic analysis methodology:**
- **Source Triangulation:** Cross-validate findings across minimum 3 independent sources with conflict resolution protocols
- **Temporal Analysis:** Assess information currency and trend patterns with timeline mapping and evolution tracking
- **Pattern Recognition:** Identify consistent themes, emerging trends, and anomalous findings using structured pattern analysis
- **Gap Identification:** Document information gaps, contradictions, and areas requiring additional investigation

**Evidence Weight Assessment:** Assign confidence levels (High/Medium/Low) based on source quality, consensus level, and validation depth

### 4. Synthesis
**Using evidence-based synthesis framework:**
- **Relevance Prioritization:** Organize findings using weighted relevance scoring aligned with exploration objectives
- **Evidence-Based Recommendations:** Create recommendations with explicit evidence trails and confidence intervals
- **Uncertainty Documentation:** Clearly identify assumptions, limitations, and areas of incomplete knowledge
- **Actionability Assessment:** Evaluate recommendation feasibility with implementation complexity and risk analysis

**Synthesis Quality Gates:** All recommendations must have supporting evidence from minimum 2 independent sources with Medium+ confidence levels

## Deliverable
Create research document in `.claude/processes/research-[topic]-[date].md` containing:
- **Research Framework:** Structured research questions with methodology and source validation strategy
- **Evidence Portfolio:** Annotated source list (minimum 5 sources) with AAOCC quality ratings and triangulation matrix
- **Comparative Analysis:** Multi-criteria approach comparison with weighted scoring and evidence trails
- **Validated Recommendations:** Evidence-based conclusions with explicit confidence levels and supporting source citations
- **Knowledge Synthesis:** Uncertainty documentation, limitation analysis, and actionability assessment

**Argument Handoff to Next Step:** Pass research findings, validated recommendations, and evidence base to `/plan` for strategic implementation planning

## Educational Value
**Technical:** Develops information literacy, source evaluation skills, and evidence-based decision making essential for technical leadership.

**Simple:** Like being a scientist - you gather evidence from multiple sources before drawing conclusions, so your decisions are based on facts not guesses.

**Connection:** This teaches research methodology and critical analysis skills valuable in any professional context.

## Next Steps
- **Flows to:** `/plan` with validated research findings and evidence-based recommendations for strategic implementation planning
- **Confidence <7/10:** Continue research with gap-specific investigation until sufficient evidence gathered
- **Conflicting Evidence:** Document alternatives with weighted pros/cons analysis and source triangulation
- **Quality Gate:** All synthesis frameworks must achieve minimum quality standards before progression
