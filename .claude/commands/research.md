# /research - Deep Knowledge Research

Execute comprehensive knowledge research for: **$ARGUMENTS**

## Purpose
Conduct systematic, evidence-based research to fill knowledge gaps using multi-source validation and structured synthesis frameworks.

## When to Use
- **REQUIRED for:** Knowledge gaps from exploration, technology evaluation, best practices investigation
- **Forbidden without:** Minimum 5 high-quality sources, comparative analysis framework, source validation
- **Quality gate:** Confidence ≥7/10, evidence-based recommendations, validated source synthesis

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
