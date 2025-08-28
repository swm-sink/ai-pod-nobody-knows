# /research-query - Advanced Research Intelligence Command

**Technical:** Native Claude Code slash command utilizing validation-orchestrator sub-agent for strategic Perplexity Sonar integration with Deep Research (reasoning_effort=high) and Reasoning optimization, multi-round research coordination, and evidence quality validation.

**Simple:** Like having a brilliant research assistant who knows exactly how to ask the right questions to the world's best search engines and bring back the most reliable, comprehensive answers.

**Connection:** This teaches advanced research methodology where AI-powered inquiry systems enhance human curiosity through systematic, evidence-based investigation techniques.

---

## Command Usage

```
/research-query [topic] [--depth=LEVEL] [--sources=COUNT] [--reasoning=MODE] [--save=LOCATION] [--budget=AMOUNT]
```

Use the validation-orchestrator sub-agent to research query: $ARGUMENTS

Execute strategic multi-round Perplexity research with authority validation, evidence synthesis, and intellectual humility integration.

---

## Parameters

**Required:**
- `topic`: Research topic or question (quoted for complex queries)

**Optional:**
- `--depth`: Research depth (quick|standard|comprehensive|exhaustive) - Default: standard
- `--sources`: Minimum source count (3-20) - Default: 5
- `--reasoning`: Perplexity reasoning mode (deep|strategic|focused) - Default: deep
- `--save`: Save location for research output - Default: episode research directory
- `--budget`: Budget allocation override - Default: based on research depth

---

## Research Pipeline Integration

### Phase 1: Query Optimization & Strategy 🎯
The validation-orchestrator sub-agent will:
- Analyze research topic for optimal query formulation
- Determine strategic research approach based on topic complexity
- Select appropriate Perplexity models (Sonar Deep Research vs Sonar Reasoning)
- Define evidence quality standards and source authority requirements

### Phase 2: Multi-Round Research Execution 📚
The validation-orchestrator sub-agent will:
- Execute strategic query sequence with reasoning_effort=high
- Coordinate between Perplexity Sonar Deep Research and Sonar Reasoning
- Validate source authority and evidence quality at each round
- Implement adaptive query refinement based on initial findings

### Phase 3: Evidence Synthesis & Validation ✅
The validation-orchestrator sub-agent will:
- Cross-reference findings across multiple authoritative sources
- Identify research consensus areas and contested findings
- Validate evidence quality and methodology where applicable
- Document uncertainty areas requiring intellectual humility acknowledgment

### Phase 4: Knowledge Gap Identification 🔍
The validation-orchestrator sub-agent will:
- Map comprehensive understanding against research objectives
- Identify areas requiring additional investigation or expert perspective
- Generate follow-up questions for deeper exploration
- Assess research completeness and quality thresholds

### Phase 5: Research Documentation & Integration 📝
The validation-orchestrator sub-agent will:
- Structure findings with proper source attribution and quality indicators
- Create intellectual humility integration points for uncertain areas
- Generate research summary with evidence quality assessments
- Prepare research package for integration with production pipeline

### Phase 6: Cost & Quality Optimization 💡
The validation-orchestrator sub-agent will:
- Monitor research costs against allocated budget
- Optimize query efficiency for maximum value per API call
- Assess research ROI and effectiveness metrics
- Generate recommendations for future research optimization

---

## Examples

### Standard Research Query
```
/research-query "latest developments in AI reasoning capabilities"
```
**Result:** validation-orchestrator executes 5-source research using Sonar Deep Research, providing comprehensive analysis with authority validation and intellectual humility integration.

### Comprehensive Deep Research
```
/research-query "impact of large language models on scientific discovery" --depth=comprehensive --sources=10 --reasoning=deep
```
**Result:** validation-orchestrator conducts exhaustive multi-round research with 10+ authoritative sources, deep reasoning analysis, and detailed evidence synthesis.

### Quick Research Validation
```
/research-query "current state of quantum computing" --depth=quick --sources=3
```
**Result:** validation-orchestrator provides rapid research validation with 3 key sources, suitable for fact-checking and baseline understanding.

### Budget-Controlled Research
```
/research-query "machine learning interpretability methods" --budget=2.50 --save=.claude/episodes/current/research
```
**Result:** validation-orchestrator optimizes research within $2.50 budget constraint, saving structured findings to specified episode directory.

### Strategic Research with Focused Reasoning
```
/research-query "ethical implications of AI in healthcare" --reasoning=strategic --sources=8
```
**Result:** validation-orchestrator uses Perplexity Sonar Reasoning for strategic analysis across 8 sources, emphasizing ethical frameworks and practical implications.

---

## Research Depth Specifications

### Quick Research (3-5 sources, $0.50-1.00 budget)
- Essential facts and basic understanding
- Key authoritative sources identified
- Primary consensus and major debates
- Basic intellectual humility points

### Standard Research (5-7 sources, $1.50-2.50 budget)
- Comprehensive topic coverage
- Authority validation and evidence quality assessment
- Detailed consensus mapping and uncertainty identification
- Research-ready synthesis with proper attribution

### Comprehensive Research (8-12 sources, $3.00-4.50 budget)
- Deep domain expertise with cross-domain connections
- Extensive authority validation and methodology assessment
- Detailed evidence synthesis with quality indicators
- Advanced intellectual humility integration

### Exhaustive Research (12-20 sources, $4.50-6.00 budget)
- Expert-level understanding with cutting-edge insights
- Comprehensive methodology and evidence quality analysis
- Cross-reference validation with multiple expert perspectives
- Research-backed recommendations for implementation

---

## Perplexity Integration Optimization

### Sonar Deep Research Utilization
```bash
# Strategic query for deep research with reasoning_effort=high
perplexity_deep_research() {
    local topic=$1
    local reasoning_effort="high"

    # Execute comprehensive research with authority validation
    curl -X POST "https://api.perplexity.ai/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
        -d '{
            "model": "llama-3.1-sonar-huge-128k-online",
            "messages": [
                {
                    "role": "system",
                    "content": "You are a research expert. Provide comprehensive analysis with source validation."
                },
                {
                    "role": "user",
                    "content": "Research: '"$topic"' - Focus on authoritative sources and evidence quality"
                }
            ],
            "reasoning_effort": "'"$reasoning_effort"'",
            "max_tokens": 4000,
            "temperature": 0.2
        }'
}
```

### Sonar Reasoning Strategic Analysis
```bash
# Strategic reasoning for synthesis and cross-domain connections
perplexity_strategic_reasoning() {
    local research_findings=$1
    local analysis_focus=$2

    # Execute strategic reasoning analysis
    curl -X POST "https://api.perplexity.ai/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
        -d '{
            "model": "llama-3.1-sonar-large-128k-chat",
            "messages": [
                {
                    "role": "system",
                    "content": "Analyze research findings for strategic insights and cross-domain connections."
                },
                {
                    "role": "user",
                    "content": "Analyze research findings: '"$research_findings"' Focus: '"$analysis_focus"'"
                }
            ],
            "reasoning_effort": "medium",
            "max_tokens": 2000,
            "temperature": 0.3
        }'
}
```

### Multi-Round Research Coordination
```bash
# Coordinate multi-round research with adaptive refinement
execute_multi_round_research() {
    local topic=$1
    local max_rounds=3
    local current_round=1

    while [ $current_round -le $max_rounds ]; do
        echo "=== Research Round $current_round ==="

        # Execute research round
        research_result=$(perplexity_deep_research "$topic")

        # Validate source quality and completeness
        source_quality=$(validate_source_authority "$research_result")

        if [ "$source_quality" -ge 90 ]; then
            echo "Research quality threshold met ($source_quality%)"
            break
        else
            # Refine query for next round
            topic=$(refine_research_query "$topic" "$research_result")
            echo "Refining query for round $((current_round + 1)): $topic"
        fi

        ((current_round++))
    done
}
```

---

## Source Authority Validation

### Authority Assessment Framework
```json
{
  "source_authority_levels": {
    "tier_1_primary": {
      "types": ["peer_reviewed_journals", "government_agencies", "established_institutions"],
      "weight": 1.0,
      "quality_threshold": 95
    },
    "tier_2_secondary": {
      "types": ["industry_reports", "expert_analysis", "reputable_news_organizations"],
      "weight": 0.8,
      "quality_threshold": 85
    },
    "tier_3_supporting": {
      "types": ["trade_publications", "conference_proceedings", "expert_blogs"],
      "weight": 0.6,
      "quality_threshold": 75
    }
  },
  "validation_criteria": {
    "author_expertise": "Domain authority and credentials",
    "publication_credibility": "Editorial standards and peer review",
    "citation_analysis": "Reference quality and academic impact",
    "recency_relevance": "Publication date and ongoing validity",
    "methodology_rigor": "Research methods and evidence standards"
  }
}
```

### Evidence Quality Scoring
```bash
# Calculate evidence quality score based on multiple factors
calculate_evidence_quality() {
    local source_authority=$1
    local methodology_rigor=$2
    local citation_count=$3
    local recency_score=$4

    # Weighted scoring algorithm
    local authority_weight=0.4
    local methodology_weight=0.3
    local citation_weight=0.2
    local recency_weight=0.1

    local total_score=$(echo "
        ($source_authority * $authority_weight) +
        ($methodology_rigor * $methodology_weight) +
        ($citation_count * $citation_weight) +
        ($recency_score * $recency_weight)
    " | bc -l)

    echo "$total_score"
}
```

---

## Research Output Formats

### Structured Research Summary
```markdown
# Research Summary: [Topic]
**Query Date:** 2024-08-21
**Research Depth:** Comprehensive
**Sources Analyzed:** 8
**Budget Utilized:** $3.25 / $4.50

## Key Findings

### Consensus Areas (High Confidence)
- **Finding 1:** [Statement with 95%+ source agreement]
  - *Sources:* Nature (2024), MIT Technology Review (2024), Stanford Research (2024)
  - *Quality Score:* 96.2%
  - *Evidence Strength:* Strong peer-reviewed validation

### Emerging Developments (Moderate Confidence)
- **Finding 2:** [Statement with 70-85% source agreement]
  - *Sources:* Industry Report (2024), Expert Analysis (2024)
  - *Quality Score:* 78.5%
  - *Evidence Strength:* Industry validation, academic pending

### Areas of Uncertainty (Intellectual Humility Required)
- **Debate 1:** [Contested area requiring humble acknowledgment]
  - *Perspectives:* Expert A argues X, Expert B argues Y
  - *Quality Score:* 65.0%
  - *Evidence Strength:* Ongoing research, limited consensus

## Research Quality Assessment
- **Overall Authority Score:** 89.2%
- **Evidence Diversity:** 8 independent sources across 4 domains
- **Methodology Rigor:** Peer-reviewed (60%), Industry (30%), Expert (10%)
- **Intellectual Humility Integration Points:** 12 identified areas

## Follow-up Research Opportunities
1. [Specific area requiring deeper investigation]
2. [Expert perspective needed for validation]
3. [Emerging development requiring monitoring]
```

### JSON Research Package
```json
{
  "research_metadata": {
    "topic": "AI reasoning capabilities development",
    "query_timestamp": "2024-08-21T14:30:45Z",
    "research_depth": "comprehensive",
    "budget_utilized": 3.25,
    "total_sources": 8,
    "research_quality_score": 89.2
  },
  "findings": {
    "consensus_areas": [
      {
        "statement": "Large language models show significant improvement in reasoning tasks",
        "confidence_level": 95.2,
        "source_count": 6,
        "authority_score": 94.1,
        "supporting_sources": [
          {"title": "Reasoning in LLMs", "publication": "Nature", "year": 2024, "authority": 98},
          {"title": "AI Progress Report", "publication": "MIT Tech Review", "year": 2024, "authority": 92}
        ]
      }
    ],
    "emerging_developments": [
      {
        "statement": "Chain-of-thought prompting effectiveness varies by domain",
        "confidence_level": 78.5,
        "source_count": 4,
        "authority_score": 81.2
      }
    ],
    "uncertainty_areas": [
      {
        "topic": "Long-term reasoning capability scaling",
        "debate_summary": "Expert disagreement on future performance limits",
        "confidence_level": 45.0,
        "humility_integration": "requires acknowledgment of significant uncertainty"
      }
    ]
  },
  "cost_analysis": {
    "perplexity_api_cost": 2.85,
    "processing_overhead": 0.40,
    "cost_per_source": 0.41,
    "efficiency_rating": "high"
  }
}
```

---

## Cost Optimization Strategies

### Query Efficiency Optimization
- **Strategic Query Design**: Maximize information density per API call
- **Multi-Round Coordination**: Adaptive refinement based on quality thresholds
- **Budget-Based Depth Selection**: Automatic depth adjustment for cost constraints
- **Source Quality Prioritization**: Focus resources on highest-authority sources

### Budget Monitoring Integration
```bash
# Real-time cost tracking during research
track_research_cost() {
    local query_cost=$1
    local cumulative_cost=$2
    local budget_limit=$3

    local utilization=$(echo "$cumulative_cost / $budget_limit * 100" | bc -l)

    echo "Research Cost: $cumulative_cost / $budget_limit (${utilization}% utilization)"

    if (( $(echo "$utilization > 90" | bc -l) )); then
        echo "WARNING: Research budget 90% utilized - optimize remaining queries"
        return 1
    fi

    return 0
}
```

---

## Integration with Episode Production

### Research-to-Script Handoff
```bash
# Prepare research package for script writer integration
prepare_research_package() {
    local episode_id=$1
    local research_summary=$2

    # Structure research for script integration
    mkdir -p .claude/episodes/$episode_id/research

    # Save research findings with metadata
    echo "$research_summary" > .claude/episodes/$episode_id/research/synthesis.md

    # Generate intellectual humility integration points
    extract_humility_points "$research_summary" > .claude/episodes/$episode_id/research/humility_points.json

    # Create source authority reference
    extract_source_metadata "$research_summary" > .claude/episodes/$episode_id/research/sources.json

    echo "Research package prepared for episode $episode_id"
}
```

---

## Success Metrics

### Research Quality Metrics
- **Source Authority**: ≥90% authoritative sources for comprehensive research
- **Evidence Diversity**: Minimum 3 independent source perspectives per major finding
- **Methodology Validation**: Research methods assessed and validated where applicable
- **Intellectual Humility Integration**: Uncertainty areas properly identified and documented

### Cost Effectiveness Metrics
- **Cost per Quality Point**: Optimize research value per dollar spent
- **Query Efficiency**: Maximum information extraction per API call
- **Budget Accuracy**: Research costs within ±10% of initial estimates
- **ROI Validation**: Research quality justifies investment in enhanced understanding

### Research Impact Metrics
- **Script Integration Success**: ≥95% research findings successfully integrated
- **Accuracy Validation**: Post-production fact-checking confirms research quality
- **Audience Engagement**: Research-backed content shows measurable engagement improvement
- **Educational Value**: Research complexity appropriately accessible for target audience

The /research-query command transforms information gathering from simple search to systematic investigation, ensuring every research effort contributes to high-quality, evidence-based content creation while maintaining cost efficiency and intellectual integrity.
