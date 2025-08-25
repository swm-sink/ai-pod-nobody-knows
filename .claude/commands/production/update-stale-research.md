---
name: update-stale-research
description: Execute targeted updates for stale research packages with cost optimization and quality preservation
---

# Update Stale Research - Targeted Research Refresh System

Execute selective or comprehensive updates for stale research packages while preserving valuable existing research and optimizing for cost efficiency.

## Usage

```
/update-stale-research [episodes] [update_strategy] [options]
```

## Update Strategies

### Selective Update (Default)
```
/update-stale-research 5,12,18 selective              # Update specific episodes selectively
/update-stale-research --stale-only selective         # Update all stale episodes selectively
```

### Comprehensive Refresh
```
/update-stale-research 5,12,18 comprehensive          # Full re-research of episodes
/update-stale-research --critical-only comprehensive  # Full refresh for critical staleness
```

### Strategic Hybrid
```
/update-stale-research 1-25 hybrid                    # Balanced approach for Season 1
/update-stale-research --priority high hybrid         # Hybrid updates for high priority
```

## Execution Strategy

Use the 01_research_orchestrator subagent with update-specific enhancements:

### Phase 1: Update Scope Analysis
1. **Research Package Assessment**: Load existing research and identify stale components
2. **Value Preservation Analysis**: Determine high-value research to preserve
3. **Gap Identification**: Identify specific information that needs updating
4. **Cross-Episode Impact**: Analyze how updates affect related episodes

### Phase 2: Targeted Update Execution
1. **Selective Information Refresh**: Update only stale facts, sources, and quotes
2. **Source Validation**: Verify existing sources are still credible and accessible
3. **Expert Perspective Updates**: Seek recent expert opinions and developments
4. **Quality Enhancement**: Improve research quality during update process

### Phase 3: Integration and Validation
1. **Research Package Merging**: Intelligently combine old and new research
2. **Cross-Episode Synchronization**: Update related episodes with shared information
3. **Quality Validation**: Ensure updated packages meet quality standards
4. **Production Pipeline Integration**: Verify compatibility with existing workflows

## Update Strategies in Detail

### Selective Update Strategy
**Best for:** Recent research (aging status) with good foundation

```yaml
selective_update_process:
  preserve_components:
    - high_quality_expert_quotes: "Keep valuable expert insights"
    - credible_academic_sources: "Maintain peer-reviewed research"
    - evergreen_concepts: "Preserve timeless information"
    - cross_episode_connections: "Maintain relationship mappings"

  update_components:
    - recent_developments: "Add latest discoveries or changes"
    - outdated_statistics: "Refresh numerical data and metrics"
    - broken_or_moved_sources: "Fix accessibility issues"
    - contradicted_information: "Replace information proven wrong"

  enhancement_opportunities:
    - source_diversification: "Add new perspectives"
    - geographic_expansion: "Include global viewpoints"
    - expert_network_growth: "Connect with new experts"

cost_range: "$0.10-0.30 per episode"
time_range: "15-30 minutes per episode"
quality_impact: "Preserves existing quality, adds freshness"
```

### Comprehensive Refresh Strategy
**Best for:** Critical staleness or fundamental changes in topic

```yaml
comprehensive_refresh_process:
  complete_re_research:
    - full_perplexity_research: "Execute complete research pipeline"
    - expert_quote_refresh: "Seek entirely new expert perspectives"
    - source_base_rebuild: "Build new foundation of sources"
    - thematic_analysis_update: "Re-evaluate themes and concepts"

  quality_improvement:
    - higher_source_standards: "Raise credibility requirements"
    - broader_perspective_range: "Include more diverse viewpoints"
    - deeper_complexity_analysis: "Enhanced depth for complex topics"

  integration_enhancements:
    - cross_episode_optimization: "Improve connections to related episodes"
    - brand_alignment_strengthening: "Enhance intellectual humility themes"
    - production_readiness_boost: "Optimize for script generation"

cost_range: "$0.60-0.80 per episode"
time_range: "45-60 minutes per episode"
quality_impact: "Potential significant quality improvements"
```

### Strategic Hybrid Strategy
**Best for:** Balanced approach with good ROI

```yaml
hybrid_update_process:
  core_refresh:
    - key_facts_validation: "Verify and update central information"
    - primary_source_refresh: "Update most important sources"
    - expert_quote_enhancement: "Add recent expert perspectives"

  selective_preservation:
    - high_value_research: "Keep excellent existing research"
    - unique_insights: "Preserve rare or unique findings"
    - cross_episode_synergies: "Maintain valuable connections"

  strategic_enhancements:
    - gap_filling: "Address identified research gaps"
    - quality_boost: "Improve weak areas without full refresh"
    - efficiency_optimization: "Leverage shared research opportunities"

cost_range: "$0.25-0.45 per episode"
time_range: "25-40 minutes per episode"
quality_impact: "Good balance of freshness and quality improvement"
```

## Smart Update Algorithms

### Value Preservation Algorithm
```yaml
# Determine what to preserve during updates
preservation_scoring:
  expert_quotes:
    factors:
      - expert_credibility: 0.3
      - quote_uniqueness: 0.3
      - quote_relevance: 0.2
      - quote_timeliness: 0.2
    threshold: 0.75  # Keep quotes scoring above this

  sources:
    factors:
      - source_credibility: 0.4
      - source_accessibility: 0.2
      - information_uniqueness: 0.2
      - cross_episode_value: 0.2
    threshold: 0.70  # Keep sources scoring above this

  research_insights:
    factors:
      - insight_depth: 0.3
      - supporting_evidence: 0.3
      - brand_alignment: 0.2
      - production_value: 0.2
    threshold: 0.80  # Keep insights scoring above this
```

### Update Priority Algorithm
```yaml
# Determine what needs updating most urgently
update_priority_scoring:
  factual_information:
    factors:
      - information_age: 0.4
      - contradiction_risk: 0.3
      - production_criticality: 0.2
      - verification_difficulty: 0.1

  expert_perspectives:
    factors:
      - expert_activity_since_quote: 0.3
      - field_development_rate: 0.3
      - quote_relevance_drift: 0.2
      - expert_availability: 0.2

  source_materials:
    factors:
      - source_staleness: 0.4
      - source_accessibility: 0.3
      - source_credibility_changes: 0.2
      - replacement_availability: 0.1
```

## Batch Update Optimization

### Thematic Batching
```yaml
# Group updates by theme for efficiency
thematic_batch_examples:
  ai_consciousness_cluster:
    episodes: [13, 87, 103, 117]
    shared_research_opportunities:
      - consciousness_research_updates
      - neuroscience_developments
      - philosophy_of_mind_advances
    estimated_savings: "25% through shared research"

  quantum_mechanics_cluster:
    episodes: [28, 76, 116]
    shared_research_opportunities:
      - quantum_computing_advances
      - theoretical_physics_updates
      - experimental_verification_results
    estimated_savings: "30% through specialized expertise"
```

### Cross-Episode Update Propagation
```yaml
# When updating one episode affects others
propagation_rules:
  shared_expert_updates:
    trigger: "expert_quote_update"
    action: "update_all_episodes_quoting_expert"
    cost_sharing: "distribute_update_cost_across_episodes"

  source_material_updates:
    trigger: "primary_source_update"
    action: "evaluate_impact_on_related_episodes"
    selective_propagation: "update_only_if_material_impact"

  factual_corrections:
    trigger: "fact_correction_identified"
    action: "immediate_update_all_affected_episodes"
    priority: "critical"
```

## Cost Control and Budgeting

### Update Budget Planning
```yaml
# Budget allocation strategies
budget_scenarios:
  conservative_updates:
    monthly_budget: "$25-35"
    episodes_per_month: "5-8 selective updates"
    quality_maintenance: "acceptable"
    staleness_tolerance: "medium"

  balanced_updates:
    monthly_budget: "$50-75"
    episodes_per_month: "8-12 mixed strategy updates"
    quality_maintenance: "good"
    staleness_tolerance: "low"

  aggressive_updates:
    monthly_budget: "$100-150"
    episodes_per_month: "15-20 comprehensive updates"
    quality_maintenance: "excellent"
    staleness_tolerance: "very_low"
```

### ROI-Based Update Decisions
```yaml
# Calculate return on investment for updates
roi_calculation:
  quality_improvement_value:
    script_quality_boost: 0.3    # Better scripts from fresh research
    production_time_savings: 0.4  # Less research during production
    brand_consistency_value: 0.3  # Maintaining intellectual humility

  update_costs:
    direct_research_costs: "actual_api_and_time_costs"
    opportunity_costs: "time_not_spent_on_new_episodes"
    integration_costs: "validation_and_merging_effort"

  roi_threshold: 2.0  # Only update if ROI > 2.0
```

## Quality Assurance for Updates

### Update Validation Framework
```yaml
# Ensure update quality
validation_checks:
  freshness_verification:
    - research_date_updated: true
    - staleness_score_improved: true
    - new_information_credible: true

  quality_maintenance:
    - overall_quality_score_maintained_or_improved: true
    - source_credibility_average_maintained: true
    - expert_perspective_diversity_maintained: true

  integration_validation:
    - cross_episode_connections_updated: true
    - thematic_consistency_maintained: true
    - production_pipeline_compatibility: true
```

### Rollback Procedures
```yaml
# Handle update failures
rollback_triggers:
  quality_degradation: "quality_score_drops_below_threshold"
  integration_failure: "updated_package_incompatible_with_pipeline"
  cost_overrun: "update_cost_exceeds_approved_budget"
  expert_disagreement: "contradictory_expert_opinions_introduced"

rollback_process:
  1. preserve_update_attempt_log: "document_what_was_attempted"
  2. restore_previous_research_package: "revert_to_last_known_good_version"
  3. flag_for_manual_review: "human_intervention_required"
  4. analyze_failure_cause: "prevent_similar_future_failures"
```

## Automation and Scheduling

### Automated Update Triggers
```yaml
# Conditions that trigger automatic updates
automatic_triggers:
  production_imminent:
    condition: "episode_production_scheduled_within_7_days"
    action: "execute_selective_update_if_stale"
    approval: "auto_approved_within_budget"

  critical_staleness:
    condition: "freshness_score_below_0.3"
    action: "flag_for_immediate_update"
    approval: "requires_manual_approval"

  breaking_developments:
    condition: "major_development_in_episode_topic"
    action: "selective_update_of_affected_sections"
    approval: "auto_approved_for_critical_updates"
```

### Scheduled Maintenance Updates
```yaml
# Regular maintenance schedule
maintenance_schedule:
  weekly_staleness_scan:
    day: "sunday"
    action: "identify_episodes_approaching_staleness"
    output: "weekly_update_recommendations"

  monthly_batch_updates:
    schedule: "first_friday_of_month"
    action: "execute_approved_batch_updates"
    budget_limit: "monthly_update_budget"

  quarterly_comprehensive_review:
    schedule: "end_of_quarter"
    action: "comprehensive_research_quality_assessment"
    output: "strategic_update_plan_for_next_quarter"
```

## Integration with Existing Systems

### Production Pipeline Integration
```yaml
# Seamless integration with production workflow
integration_points:
  pre_production_check:
    trigger: "episode_production_initiated"
    action: "validate_research_freshness"
    response: "proceed | update_required | manual_review"

  quality_gate_integration:
    location: "script_generation_quality_gate"
    check: "research_package_freshness_score"
    threshold: "minimum_0.7_for_production"

  session_tracking_compatibility:
    update_session_metadata: true
    preserve_original_research_attribution: true
    track_update_costs_separately: true
```

### Backward Compatibility
```yaml
# Maintain compatibility with existing workflows
compatibility_features:
  legacy_research_format_support: true
  gradual_migration_to_enhanced_format: true
  fallback_to_individual_episode_research: true
  existing_command_preservation: true
```

This update system ensures research remains fresh and valuable while optimizing costs and preserving high-quality existing research.
