# Sonar Reasoning Templates - Strategic Analysis & Synthesis Frameworks

## Research Metadata
- **Created**: 2025-08-21
- **Purpose**: Production templates for Sonar Reasoning strategic analysis and synthesis
- **Focus**: Chain-of-Thought analysis templates for processing Sonar Deep Research results
- **Context**: Phase 2 of 2-phase research workflow for agent enhancement

---

## Template Categories

### 1. Strategic Implementation Analysis Template
```yaml
strategic_analysis_framework:
  template_structure:
    analysis_objective: "Strategic analysis of [RESEARCH_TOPIC] for [IMPLEMENTATION_CONTEXT]"

    query_template: |
      "Analyze the comprehensive research findings on [RESEARCH_TOPIC] to develop a strategic implementation framework for [SPECIFIC_APPLICATION]. Provide structured recommendations including priority assessment, resource requirements, implementation timeline, success metrics, and risk mitigation strategies. Focus on actionable insights that can be immediately applied to [CONTEXT]."

    configuration:
      model: "sonar-reasoning"
      reasoning_approach: "chain-of-thought"
      analysis_depth: "strategic"

    input_requirements:
      - comprehensive_research_results: "Sonar Deep Research findings"
      - implementation_context: "Specific application scenario"
      - strategic_objectives: "Desired outcomes and goals"
      - resource_constraints: "Budget, time, and capability limitations"

    expected_deliverables:
      - strategic_priorities: "Ranked list of implementation priorities"
      - implementation_framework: "Step-by-step execution plan"
      - resource_allocation: "Budget, time, and capability requirements"
      - success_metrics: "Measurable outcomes and validation criteria"
      - risk_assessment: "Potential issues and mitigation strategies"

examples:
  claude_opus_creative_implementation:
    analysis_query: |
      "Analyze the comprehensive research on Claude 4.1 Opus creative writing optimization to develop a strategic implementation plan for podcast script generation. Prioritize techniques by impact and feasibility, create a phased rollout strategy, define success metrics for brand voice consistency and narrative quality, and identify potential integration challenges with existing production workflow."

  multi_agent_orchestration_strategy:
    analysis_query: |
      "Analyze the research on multi-agent coordination patterns to create an implementation framework for podcast production automation. Develop a strategic approach for transitioning from current manual processes, prioritize coordination improvements by ROI, and establish quality gates and monitoring systems for reliable automated production."
```

### 2. Comparative Analysis Template
```yaml
comparative_analysis_framework:
  template_structure:
    analysis_objective: "Comparative evaluation of [OPTIONS/APPROACHES] for [DECISION_CONTEXT]"

    query_template: |
      "Conduct a systematic comparative analysis of the research findings on [TOPIC] to evaluate [OPTION_A] versus [OPTION_B] versus [OPTION_C] for [SPECIFIC_USE_CASE]. Create a structured decision framework with weighted criteria, scoring matrix, and clear recommendation based on [DECISION_FACTORS]. Include implementation implications and trade-off analysis."

    configuration:
      model: "sonar-reasoning"
      reasoning_approach: "structured-comparison"
      analysis_depth: "comprehensive"

    input_requirements:
      - research_findings: "Comprehensive analysis of all options"
      - evaluation_criteria: "Factors for comparison (cost, performance, ease, etc.)"
      - use_case_context: "Specific application requirements"
      - decision_timeline: "Implementation timeframe and constraints"

    expected_deliverables:
      - comparison_matrix: "Structured evaluation across all criteria"
      - weighted_scoring: "Quantified assessment with rationale"
      - recommendation: "Clear choice with supporting evidence"
      - trade_off_analysis: "What you gain/lose with each option"
      - implementation_implications: "Practical considerations for chosen option"

examples:
  model_selection_analysis:
    analysis_query: |
      "Compare Claude 4.1 Opus versus Claude Sonnet 4 versus Gemini Pro 2.5 for quality evaluation tasks in podcast production, evaluating accuracy, cost efficiency, integration complexity, and reliability. Create weighted scoring based on production priorities and recommend optimal model assignment strategy with cost-benefit analysis."

  orchestration_pattern_comparison:
    analysis_query: |
      "Analyze supervisor pattern versus peer-to-peer versus hierarchical orchestration approaches for multi-agent research coordination. Evaluate complexity, reliability, cost efficiency, and scalability for podcast research automation. Provide recommendation with implementation roadmap and migration considerations."
```

### 3. Risk Assessment & Mitigation Template
```yaml
risk_analysis_framework:
  template_structure:
    analysis_objective: "Risk assessment and mitigation planning for [IMPLEMENTATION_TOPIC]"

    query_template: |
      "Analyze the research findings on [TOPIC] to identify potential risks, failure modes, and challenges for implementing [SPECIFIC_APPROACH] in [CONTEXT]. Develop a comprehensive risk mitigation framework including probability assessment, impact analysis, preventive measures, and contingency plans. Focus on practical risk management for production deployment."

    configuration:
      model: "sonar-reasoning"
      reasoning_approach: "risk-assessment"
      analysis_depth: "thorough"

    input_requirements:
      - implementation_research: "Technical and operational findings"
      - deployment_context: "Production environment and constraints"
      - stakeholder_requirements: "Quality, reliability, and performance expectations"
      - resource_limitations: "Budget, time, and capability constraints"

    expected_deliverables:
      - risk_identification: "Comprehensive list of potential issues"
      - probability_impact_matrix: "Likelihood and severity assessment"
      - mitigation_strategies: "Preventive measures for each risk"
      - contingency_plans: "Response strategies for risk occurrence"
      - monitoring_framework: "Early warning systems and indicators"

examples:
  multi_model_integration_risks:
    analysis_query: |
      "Analyze risks in integrating Claude, Gemini, Perplexity, and ElevenLabs models for automated podcast production. Assess API dependency risks, cost overrun potential, quality consistency challenges, and system reliability concerns. Develop mitigation strategies for each risk category with monitoring and fallback procedures."
```

### 4. Optimization Strategy Template
```yaml
optimization_analysis_framework:
  template_structure:
    analysis_objective: "Optimization strategy development for [SYSTEM/PROCESS] performance"

    query_template: |
      "Analyze the research on [OPTIMIZATION_TOPIC] to develop a systematic optimization strategy for [TARGET_SYSTEM]. Identify performance bottlenecks, efficiency opportunities, cost reduction potential, and quality improvement areas. Create prioritized optimization roadmap with measurable impact projections and implementation complexity assessment."

    configuration:
      model: "sonar-reasoning"
      reasoning_approach: "optimization-focused"
      analysis_depth: "systematic"

    input_requirements:
      - performance_research: "Current state analysis and optimization techniques"
      - system_constraints: "Technical, operational, and resource limitations"
      - optimization_objectives: "Performance, cost, quality, or reliability targets"
      - implementation_capacity: "Available resources and timeline"

    expected_deliverables:
      - bottleneck_analysis: "Primary constraints limiting performance"
      - optimization_opportunities: "Ranked list of improvement areas"
      - implementation_roadmap: "Phased optimization strategy"
      - impact_projections: "Expected benefits from each optimization"
      - resource_requirements: "Investment needed for each improvement"

examples:
  cost_optimization_strategy:
    analysis_query: |
      "Analyze cost optimization research to develop a strategy for reducing podcast production costs from current $33.25 to target $25-28 per episode. Identify highest-impact cost reduction opportunities, assess implementation complexity, and create phased optimization plan with projected savings and quality impact analysis."

  quality_consistency_optimization:
    analysis_query: |
      "Analyze quality assurance research to optimize brand voice consistency across automated podcast production. Identify key quality control points, develop systematic improvement strategy, and create implementation plan for achieving >95% brand consistency while maintaining production efficiency."
```

---

## Specialized Analysis Templates

### Decision Support Template
```yaml
decision_support_framework:
  template_structure:
    analysis_objective: "Decision support analysis for [DECISION_CONTEXT]"

    query_template: |
      "Based on comprehensive research findings, provide structured decision support for [SPECIFIC_DECISION]. Analyze all viable options, assess implications of each choice, consider constraints and requirements, and recommend optimal path forward with clear rationale. Include implementation considerations and success factors."

    configuration:
      model: "sonar-reasoning"
      reasoning_approach: "decision-analysis"
      analysis_depth: "comprehensive"

    expected_deliverables:
      - decision_options: "All viable alternatives with pros/cons"
      - criteria_analysis: "How each option meets requirements"
      - recommendation: "Optimal choice with supporting logic"
      - implementation_path: "Next steps for chosen option"
      - success_factors: "Critical elements for successful execution"

examples:
  agent_enhancement_prioritization:
    analysis_query: |
      "Analyze research findings to recommend priority order for enhancing 14 podcast production agents. Consider impact potential, implementation complexity, cost-benefit ratio, and interdependencies. Provide phased enhancement strategy with resource allocation and timeline recommendations."
```

### Synthesis & Integration Template
```yaml
synthesis_framework:
  template_structure:
    analysis_objective: "Synthesis and integration of [MULTIPLE_RESEARCH_AREAS]"

    query_template: |
      "Synthesize research findings from [AREA_A], [AREA_B], and [AREA_C] to create an integrated framework for [COMBINED_APPLICATION]. Identify synergies, resolve conflicts between approaches, and develop unified strategy that leverages strengths from all research areas while addressing limitations."

    configuration:
      model: "sonar-reasoning"
      reasoning_approach: "synthesis-integration"
      analysis_depth: "holistic"

    expected_deliverables:
      - integrated_framework: "Unified approach combining all research"
      - synergy_identification: "How different areas complement each other"
      - conflict_resolution: "How to address contradictory findings"
      - unified_strategy: "Single coherent implementation approach"
      - validation_approach: "How to test integrated framework"

examples:
  multi_domain_synthesis:
    analysis_query: |
      "Synthesize research on LLM optimization, multi-agent coordination, and quality assurance to create integrated framework for podcast production automation. Resolve conflicts between cost optimization and quality requirements, identify synergies between coordination patterns and quality gates, and develop unified implementation strategy."
```

---

## Analysis Enhancement Techniques

### Chain-of-Thought Prompting Patterns
```yaml
cot_optimization:
  structured_reasoning_prompts:
    problem_decomposition:
      - "First, let's break down the key components of this analysis..."
      - "The main factors to consider are..."
      - "Let's examine each aspect systematically..."

    evidence_evaluation:
      - "Based on the research findings, we can observe..."
      - "The evidence suggests that..."
      - "Comparing different approaches reveals..."

    logical_progression:
      - "Given these findings, the logical next step is..."
      - "This leads us to conclude..."
      - "Therefore, the recommended approach is..."

    validation_reasoning:
      - "To validate this recommendation, we should consider..."
      - "The success of this approach depends on..."
      - "Potential challenges include..."

reasoning_depth_control:
  surface_analysis: "Quick strategic overview with key recommendations"
  structured_analysis: "Systematic evaluation with detailed reasoning"
  comprehensive_analysis: "Thorough investigation with multi-angle assessment"
```

### Strategic Thinking Patterns
```yaml
strategic_reasoning_frameworks:
  impact_assessment:
    - "What are the primary benefits of this approach?"
    - "What are the potential risks and downsides?"
    - "How does this align with strategic objectives?"
    - "What resources and capabilities are required?"

  comparative_evaluation:
    - "How do the options compare on key criteria?"
    - "What are the trade-offs between approaches?"
    - "Which option provides the best risk-adjusted return?"
    - "What are the implementation implications of each choice?"

  implementation_planning:
    - "What are the critical success factors?"
    - "What sequence of steps will maximize success probability?"
    - "How should resources be allocated across initiatives?"
    - "What metrics will indicate progress and success?"
```

---

## Output Structure Templates

### Strategic Analysis Output Schema
```json
{
  "analysis_metadata": {
    "research_input_reference": "string",
    "analysis_objective": "string",
    "model": "sonar-reasoning",
    "reasoning_approach": "chain-of-thought|structured-comparison|risk-assessment",
    "analysis_date": "ISO_8601",
    "estimated_cost": "number"
  },
  "strategic_assessment": {
    "key_insights": ["string"],
    "strategic_implications": ["string"],
    "critical_success_factors": ["string"],
    "primary_risks": ["string"]
  },
  "implementation_framework": {
    "recommended_approach": "string",
    "implementation_priorities": [
      {
        "priority_rank": "number",
        "initiative": "string",
        "rationale": "string",
        "resource_requirements": "string",
        "timeline": "string",
        "success_metrics": ["string"]
      }
    ],
    "resource_allocation": {
      "budget_requirements": "string",
      "capability_needs": ["string"],
      "timeline_estimate": "string"
    }
  },
  "comparative_analysis": {
    "options_evaluated": ["string"],
    "evaluation_criteria": ["string"],
    "scoring_matrix": [
      {
        "option": "string",
        "criteria_scores": "object",
        "total_score": "number",
        "ranking": "number"
      }
    ],
    "recommendation": {
      "preferred_option": "string",
      "rationale": "string",
      "implementation_considerations": ["string"]
    }
  },
  "risk_assessment": {
    "identified_risks": [
      {
        "risk_description": "string",
        "probability": "low|medium|high",
        "impact": "low|medium|high|critical",
        "mitigation_strategy": "string",
        "contingency_plan": "string"
      }
    ],
    "overall_risk_profile": "string",
    "monitoring_requirements": ["string"]
  }
}
```

### Decision Support Output Schema
```json
{
  "decision_support": {
    "decision_context": "string",
    "options_analysis": [
      {
        "option": "string",
        "advantages": ["string"],
        "disadvantages": ["string"],
        "requirements": ["string"],
        "risks": ["string"]
      }
    ],
    "recommendation": {
      "preferred_choice": "string",
      "confidence_level": "high|medium|low",
      "supporting_rationale": "string",
      "key_assumptions": ["string"]
    },
    "implementation_guidance": {
      "immediate_actions": ["string"],
      "success_factors": ["string"],
      "validation_checkpoints": ["string"],
      "fallback_options": ["string"]
    }
  }
}
```

---

## Integration Guidelines

### Research-to-Reasoning Workflow
```yaml
workflow_integration:
  input_preparation:
    - sonar_deep_research_results: "Complete research package from Phase 1"
    - analysis_objectives: "Specific strategic questions to address"
    - decision_context: "Implementation constraints and requirements"
    - success_criteria: "How to evaluate analysis quality"

  analysis_execution:
    - template_selection: "Choose appropriate reasoning template"
    - query_customization: "Adapt template for specific context"
    - sonar_reasoning_execution: "Run strategic analysis"
    - quality_validation: "Assess analysis completeness and logic"

  output_processing:
    - insight_extraction: "Key strategic implications and recommendations"
    - implementation_planning: "Convert analysis to actionable plans"
    - validation_framework: "Define success metrics and checkpoints"
    - integration_preparation: "Ready for agent enhancement implementation"
```

### Quality Assurance Framework
```yaml
reasoning_quality_assessment:
  logical_coherence:
    - reasoning_chain_validity: "Does the logic flow make sense?"
    - evidence_support: "Are conclusions supported by research findings?"
    - assumption_clarity: "Are key assumptions explicitly stated?"
    - contradiction_resolution: "Are conflicting insights addressed?"

  strategic_value:
    - actionability: "Can recommendations be practically implemented?"
    - specificity: "Are recommendations concrete and measurable?"
    - feasibility: "Are suggestions realistic given constraints?"
    - impact_potential: "Will implementation deliver meaningful benefits?"

  completeness_assessment:
    - scope_coverage: "Are all key aspects addressed?"
    - risk_consideration: "Are potential issues identified and addressed?"
    - implementation_guidance: "Are next steps clearly defined?"
    - validation_criteria: "Are success measures established?"
```

This template collection provides structured frameworks for converting comprehensive research into strategic insights and actionable implementation plans using Sonar Reasoning's chain-of-thought capabilities.
