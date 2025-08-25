# Perplexity Optimization Guide - Sonar Deep Research & Sonar Reasoning

## Research Metadata
- **Created**: 2025-08-21
- **Purpose**: Master guide for optimal Perplexity model utilization in agent enhancement
- **Focus**: Sonar Deep Research (reasoning_effort="high") + Sonar Reasoning workflows
- **Context**: AI Podcast Production System Agent Enhancement

---

## Executive Summary

This guide establishes the methodological foundation for using Perplexity's advanced research models optimally for agent enhancement. **Key insight**: Previous basic Perplexity queries were insufficient; we now leverage Sonar Deep Research (exhaustive research across hundreds of sources) with maximum reasoning effort, followed by Sonar Reasoning for strategic synthesis and analysis.

**Critical Success Factor**: 2-phase research workflow maximizes research depth while optimizing costs through strategic model selection.

---

## Perplexity Model Portfolio

### Sonar Deep Research Model
```yaml
sonar_deep_research:
  capabilities:
    - exhaustive_research: "Searches hundreds of sources automatically"
    - expert_level_insights: "Professional-grade analysis and synthesis"
    - comprehensive_reports: "Detailed multi-section analysis"
    - advanced_reasoning: "High-quality logical analysis with citations"

  pricing:
    input_tokens: "$2 per 1M tokens"
    output_tokens: "$8 per 1M tokens"
    citation_tokens: "$2 per 1M tokens"
    search_queries: "$5 per 1K requests"
    reasoning_tokens: "$3 per 1M tokens"

  optimization:
    reasoning_effort: "high"  # Maximum performance setting
    context_length: "128K tokens"
    use_cases: ["academic research", "market analysis", "competitive intelligence", "due diligence"]

  optimal_for:
    - Initial comprehensive research on any topic
    - Exhaustive source gathering and analysis
    - Expert-level domain investigation
    - Foundation research for complex projects
```

### Sonar Reasoning Model
```yaml
sonar_reasoning:
  capabilities:
    - chain_of_thought: "Structured CoT reasoning processes"
    - real_time_search: "Web search with detailed results"
    - logical_analysis: "Step-by-step problem solving"
    - strategic_thinking: "Multi-step decision analysis"

  pricing:
    input_tokens: "$1 per 1M tokens"
    output_tokens: "$5 per 1M tokens"
    flexible_tiers: ["high", "medium", "low"]

  optimization:
    context_length: "128K tokens"
    reasoning_focus: "structured analytical approach"
    use_cases: ["strategic planning", "decision analysis", "synthesis tasks"]

  optimal_for:
    - Analyzing Sonar Deep Research results
    - Strategic synthesis and planning
    - Multi-step logical analysis
    - Decision frameworks and recommendations
```

---

## 2-Phase Research Workflow

### Phase 1: Sonar Deep Research (Foundation)
```yaml
deep_research_phase:
  objective: "Exhaustive research foundation with maximum depth"

  query_structure:
    specificity: "2-3 extra context words for search optimization"
    expert_terminology: "Use domain-specific language experts would use"
    search_friendly: "Frame like expert web search queries"

  example_transformation:
    generic: "Tell me about AI models"
    optimized: "Latest advances in large language model prompt engineering techniques for production systems 2024-2025"

  configuration:
    model: "sonar-deep-research"
    reasoning_effort: "high"
    expected_output: "500-1500 word comprehensive analysis with citations"

  deliverables:
    - comprehensive_source_analysis
    - expert_insights_synthesis
    - cited_evidence_base
    - domain_landscape_mapping
```

### Phase 2: Sonar Reasoning (Analysis)
```yaml
reasoning_phase:
  objective: "Strategic analysis and synthesis of deep research results"

  input: "Sonar Deep Research comprehensive results"
  process: "Chain-of-Thought analysis and synthesis"

  analysis_types:
    - strategic_implications: "What does this mean for our use case?"
    - comparative_analysis: "How do options compare systematically?"
    - implementation_frameworks: "How do we apply these insights?"
    - decision_recommendations: "What actions should we take?"

  configuration:
    model: "sonar-reasoning"
    reasoning_focus: "structured analytical approach"
    expected_output: "200-500 word strategic analysis with recommendations"

  deliverables:
    - strategic_insights
    - implementation_recommendations
    - comparative_frameworks
    - decision_support_analysis
```

---

## Structured JSON Output Schemas

### Deep Research Output Schema
```json
{
  "deep_research_results": {
    "research_metadata": {
      "query": "string",
      "model": "sonar-deep-research",
      "reasoning_effort": "high",
      "timestamp": "ISO_8601",
      "cost_estimate": "number"
    },
    "comprehensive_analysis": {
      "executive_summary": "string",
      "key_findings": ["string"],
      "expert_insights": ["string"],
      "evidence_base": ["string"]
    },
    "source_analysis": {
      "primary_sources": [
        {
          "url": "string",
          "title": "string",
          "authority_score": "number",
          "relevance_score": "number",
          "publication_date": "string",
          "key_insights": ["string"]
        }
      ],
      "search_queries_used": ["string"],
      "total_sources_analyzed": "number"
    },
    "research_quality": {
      "completeness_score": "number",
      "authority_distribution": "object",
      "recency_analysis": "object",
      "coverage_assessment": "string"
    }
  }
}
```

### Reasoning Analysis Output Schema
```json
{
  "reasoning_analysis": {
    "analysis_metadata": {
      "input_research_id": "string",
      "model": "sonar-reasoning",
      "analysis_type": "string",
      "timestamp": "ISO_8601",
      "cost_estimate": "number"
    },
    "strategic_analysis": {
      "key_implications": ["string"],
      "strategic_recommendations": ["string"],
      "implementation_priorities": ["string"],
      "risk_assessment": ["string"]
    },
    "comparative_framework": {
      "options_analyzed": ["string"],
      "evaluation_criteria": ["string"],
      "scoring_matrix": "object",
      "recommended_approach": "string"
    },
    "decision_support": {
      "immediate_actions": ["string"],
      "long_term_strategy": "string",
      "success_metrics": ["string"],
      "validation_checkpoints": ["string"]
    }
  }
}
```

---

## Query Optimization Best Practices

### Expert-Level Query Formulation
```yaml
query_optimization:
  specificity_enhancement:
    - add_context_words: "2-3 additional descriptive terms"
    - domain_terminology: "Use expert vocabulary and technical terms"
    - temporal_specificity: "Include relevant time ranges (2024-2025)"
    - use_case_clarity: "Specify intended application context"

  search_optimization:
    - expert_language: "Frame queries as domain experts would search"
    - comparative_intent: "Include comparison keywords when relevant"
    - outcome_focus: "Specify desired insight types (frameworks, strategies, techniques)"
    - authority_preference: "Imply preference for authoritative sources"

  examples:
    generic_query: "LLM prompting techniques"
    optimized_query: "Advanced prompt engineering frameworks for Claude 4.1 Opus creative writing tasks in production environments 2024-2025"

    generic_query: "Multi-agent systems"
    optimized_query: "Hierarchical multi-agent coordination patterns for content production workflows with quality gates and error recovery"
```

### Structured Output Implementation
```yaml
structured_outputs:
  json_schema_usage:
    - define_clear_schema: "Specify expected properties and types"
    - hint_in_prompt: "Reference desired output structure in query"
    - validate_responses: "Check schema compliance automatically"
    - iterate_on_failures: "Refine schema based on actual outputs"

  response_format_configuration:
    type: "json_schema"
    json_schema:
      schema:
        type: "object"
        properties: "defined based on research objectives"
        required: ["list of required fields"]

  best_practices:
    - avoid_recursive_schemas: "Keep structure simple and flat where possible"
    - first_request_delay: "Initial schema requests may have setup delay"
    - reasoning_token_inclusion: "For reasoning models, expect reasoning tokens in output"
```

---

## Cost Optimization Strategies

### Strategic Model Selection
```yaml
cost_efficiency:
  model_selection_matrix:
    sonar_deep_research:
      use_when: "Need comprehensive foundation research"
      cost_profile: "Higher per query but maximizes research depth"
      optimization: "Use for initial research phase only"

    sonar_reasoning:
      use_when: "Need analysis of existing research"
      cost_profile: "Lower cost for strategic analysis"
      optimization: "Use for synthesis and analysis of deep research results"

  workflow_optimization:
    phase_1_approach: "Single comprehensive deep research query per topic"
    phase_2_approach: "Multiple focused reasoning queries for different analysis angles"
    batch_processing: "Group related research topics together"
    reuse_strategies: "Cache and reference prior research for related topics"
```

### Budget Planning Framework
```yaml
budget_estimation:
  deep_research_cost_factors:
    - search_queries: "$5 per 1K queries (typically 10-50 queries per research)"
    - output_tokens: "$8 per 1M tokens (typically 500-1500 tokens per research)"
    - citation_tokens: "$2 per 1M tokens (typically 50-200 tokens per research)"
    - reasoning_tokens: "$3 per 1M tokens (typically 100-500 tokens per research)"

  reasoning_cost_factors:
    - input_tokens: "$1 per 1M tokens (Deep research results as input)"
    - output_tokens: "$5 per 1M tokens (typically 200-500 tokens per analysis)"

  typical_research_cycle:
    phase_1_cost: "$0.10 - $0.30 per deep research query"
    phase_2_cost: "$0.02 - $0.05 per reasoning analysis"
    total_per_topic: "$0.12 - $0.35 per complete research cycle"
```

---

## Integration with Agent Enhancement

### Research Workflow Integration
```yaml
agent_enhancement_workflow:
  step_1_deep_research:
    input: "Agent enhancement objective (e.g., 'Claude 4.1 Opus creative writing optimization')"
    process: "Sonar Deep Research with reasoning_effort=high"
    output: "Comprehensive research package with structured JSON"

  step_2_reasoning_analysis:
    input: "Deep research results + specific analysis objectives"
    process: "Sonar Reasoning strategic analysis"
    output: "Implementation framework with recommendations"

  step_3_synthesis:
    input: "Both research and analysis results"
    process: "Human synthesis with AI assistance"
    output: "Agent enhancement proposal with research backing"
```

### Quality Assurance Framework
```yaml
research_validation:
  deep_research_quality_gates:
    - source_authority: "Minimum average authority score >0.8"
    - source_diversity: "Multiple source types and perspectives"
    - recency_compliance: "Sources within specified timeframe"
    - coverage_completeness: "All key aspects of topic addressed"

  reasoning_analysis_quality_gates:
    - logical_coherence: "Clear reasoning chain and conclusions"
    - actionable_insights: "Specific implementable recommendations"
    - evidence_alignment: "Analysis supported by research findings"
    - strategic_value: "Clear implications for agent enhancement"
```

---

## Implementation Templates

### Deep Research Template
```markdown
# Sonar Deep Research Template

RESEARCH_OBJECTIVE: [Specific agent enhancement goal]

QUERY_STRUCTURE:
- Domain: [Technical area - e.g., "LLM prompt engineering"]
- Context: [Application context - e.g., "creative writing for podcast production"]
- Timeframe: [Relevance window - e.g., "2024-2025 techniques"]
- Specificity: [Detailed focus - e.g., "Claude 4.1 Opus optimization patterns"]

FORMATTED_QUERY:
"[Expert-level query combining all elements above]"

CONFIGURATION:
- Model: sonar-deep-research
- reasoning_effort: high
- response_format: structured JSON
- expected_scope: comprehensive analysis with citations

DELIVERABLE_EXPECTATIONS:
- 500-1500 word comprehensive analysis
- 5-15 authoritative sources with citations
- Expert-level insights and frameworks
- Domain landscape mapping
```

### Reasoning Analysis Template
```markdown
# Sonar Reasoning Analysis Template

ANALYSIS_OBJECTIVE: [Strategic analysis goal]

INPUT_CONTEXT:
- Deep research results: [Reference to prior research]
- Analysis focus: [Specific angle - e.g., "implementation framework"]
- Decision context: [Application scenario]

REASONING_REQUEST:
"Analyze the deep research findings to develop [specific deliverable - e.g., 'implementation framework for Claude 4.1 Opus creative writing optimization']. Provide strategic recommendations, comparative analysis, and actionable next steps."

CONFIGURATION:
- Model: sonar-reasoning
- reasoning_approach: chain-of-thought
- response_format: structured JSON
- analysis_depth: strategic

DELIVERABLE_EXPECTATIONS:
- Strategic implications analysis
- Implementation recommendations
- Comparative framework (if applicable)
- Decision support with priorities
```

---

## Success Metrics and Validation

### Research Quality Indicators
```yaml
quality_metrics:
  deep_research_assessment:
    - comprehensiveness_score: ">90% topic coverage"
    - source_authority_average: ">0.8 authority score"
    - citation_density: ">5 citations per 100 words"
    - expert_insight_quality: "Domain-specific frameworks and techniques"

  reasoning_analysis_assessment:
    - strategic_value_score: "Clear actionable implications"
    - logical_coherence_rating: "Sound reasoning chain"
    - implementation_specificity: "Concrete next steps provided"
    - decision_support_quality: "Clear recommendations with rationale"

  cost_efficiency_metrics:
    - cost_per_insight: "<$0.10 per key actionable insight"
    - research_cycle_cost: "<$0.35 per complete topic research"
    - time_to_insight: "<24 hours for complete research cycle"
    - reusability_factor: ">70% of insights applicable to multiple agents"
```

---

## Next Steps Integration

### CLAUDE.md Integration
```yaml
claude_md_integration:
  context_loading_addition:
    - "@context/perplexity" - "Perplexity research methodology and templates"
    - Quick reference for optimal research workflows
    - Cost optimization guidance and best practices

  methodology_reference:
    - Research-first approach documentation
    - Quality gate integration requirements
    - Agent enhancement research standards
```

This guide establishes the foundation for sophisticated, research-backed agent enhancement using Perplexity's most advanced models optimally. The 2-phase workflow (Deep Research → Reasoning) maximizes research depth while maintaining cost efficiency.
