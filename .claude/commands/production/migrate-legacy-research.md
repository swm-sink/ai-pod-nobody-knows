---
name: migrate-legacy-research
description: Convert existing research sessions to enhanced research package format with cross-episode analysis
---

# Migrate Legacy Research - Format Conversion and Enhancement

Convert existing traditional research sessions to the enhanced research package format while preserving all valuable research and adding cross-episode awareness capabilities.

## Usage

```
/migrate-legacy-research [source] [target_episodes] [options]
```

## Migration Options

### Single Episode Migration
```
/migrate-legacy-research sessions/ep_001_20250817/research/ 1          # Migrate Episode 1
/migrate-legacy-research sessions/ep_005_20250820/research/ 5 --enhance # Migrate and enhance Episode 5
```

### Batch Migration
```
/migrate-legacy-research sessions/ 1-10                               # Migrate Episodes 1-10
/migrate-legacy-research --all-sessions                              # Migrate all existing sessions
```

### Selective Migration with Enhancement
```
/migrate-legacy-research sessions/ 1-5 --add-cross-connections       # Add cross-episode analysis
/migrate-legacy-research sessions/ --quality-boost                   # Enhance quality during migration
```

## Migration Strategy

Use a specialized migration agent with the following phases:

### Phase 1: Legacy Research Analysis
1. **Session Discovery**: Scan for existing research sessions
2. **Format Detection**: Identify research format and completeness
3. **Content Analysis**: Extract research content and metadata
4. **Quality Assessment**: Evaluate existing research quality

### Phase 2: Enhanced Format Conversion
1. **Schema Mapping**: Map legacy fields to enhanced package format
2. **Metadata Generation**: Create enhanced metadata from existing data
3. **Quality Metrics Calculation**: Assess and quantify research quality
4. **Research Completeness Scoring**: Evaluate production readiness

### Phase 3: Cross-Episode Enhancement (Optional)
1. **Thematic Analysis**: Analyze themes and generate thematic mapping
2. **Cross-Episode Connection Discovery**: Identify relationships to other episodes
3. **Research Synergy Detection**: Find opportunities for research sharing
4. **Brand Alignment Assessment**: Evaluate intellectual humility alignment

## Legacy Format Support

### Traditional Session Format
```yaml
# Legacy format structure
traditional_session:
  research_brief.md: "original research content"
  session_metadata.json: "basic tracking information"
  perplexity_results/: "raw perplexity research files"
  notes/: "any additional research notes"
```

### Conversion Mapping
```yaml
# How legacy fields map to enhanced format
field_mapping:
  research_brief.md → primary_research.perplexity_data
  session_metadata → metadata (enhanced with additional fields)
  cost_tracking → cost_tracking (enhanced with efficiency metrics)
  quality_notes → production_readiness.gaps_identified
```

### Missing Field Handling
```yaml
# Handle fields not present in legacy format
missing_field_strategies:
  cross_episode_connections: "analyze_content_for_relationships"
  thematic_analysis: "extract_themes_from_existing_research"
  research_quality_metrics: "calculate_based_on_available_data"
  freshness_tracking: "use_session_date_as_baseline"
```

## Migration Quality Assurance

### Data Integrity Validation
```yaml
integrity_checks:
  content_preservation:
    - original_research_fully_preserved: true
    - no_data_loss_during_conversion: true
    - metadata_accuracy_maintained: true

  format_compliance:
    - enhanced_schema_validation: true
    - required_fields_populated: true
    - data_type_consistency: true

  quality_standards:
    - minimum_quality_threshold_met: 0.70
    - production_readiness_assessed: true
    - brand_alignment_evaluated: true
```

### Enhancement Verification
```yaml
enhancement_validation:
  cross_episode_analysis:
    - relationship_detection_accuracy: ≥0.80
    - thematic_consistency_valid: true
    - connection_strength_reasonable: ≥0.60

  quality_improvements:
    - research_quality_score_calculated: true
    - production_readiness_assessed: true
    - gaps_identified_appropriately: true
```

## Migration Modes

### Basic Migration Mode
**Purpose:** Convert format with minimal changes
```yaml
basic_migration:
  preserves:
    - all_original_research_content
    - original_cost_tracking
    - existing_quality_assessments

  adds:
    - enhanced_metadata_structure
    - schema_compliance
    - basic_quality_metrics

  cost: "minimal - primarily conversion overhead"
  time: "5-10 minutes per episode"
  quality_impact: "format_upgrade_only"
```

### Enhanced Migration Mode
**Purpose:** Convert and improve research quality
```yaml
enhanced_migration:
  preserves:
    - all_valuable_original_content
    - cost_tracking_with_enhancements
    - quality_assessments_with_improvements

  adds:
    - comprehensive_metadata
    - cross_episode_analysis
    - thematic_mapping
    - quality_enhancements
    - brand_alignment_scoring

  cost: "$0.15-0.25 per episode for analysis"
  time: "20-35 minutes per episode"
  quality_impact: "significant_improvement"
```

### Cross-Episode Aware Migration
**Purpose:** Convert with full cross-episode integration
```yaml
cross_episode_migration:
  preserves:
    - all_original_research
    - enhanced_with_relationships
    - quality_with_context_awareness

  adds:
    - complete_cross_episode_mapping
    - research_synergy_identification
    - thematic_cluster_analysis
    - narrative_continuity_assessment
    - comprehensive_brand_alignment

  cost: "$0.30-0.45 per episode (batch efficient)"
  time: "35-50 minutes per episode initial, faster in batches"
  quality_impact: "transformational_with_series_awareness"
```

## Batch Migration Optimization

### Efficient Batch Processing
```yaml
batch_optimization:
  parallel_conversion:
    - convert_multiple_episodes_simultaneously: true
    - shared_analysis_computation: true
    - bulk_cross_episode_relationship_detection: true

  cost_efficiency:
    - shared_thematic_analysis: "reduce_redundant_analysis"
    - bulk_quality_assessment: "optimize_quality_evaluation_costs"
    - cross_episode_synergy_bulk: "identify_relationships_efficiently"

  time_optimization:
    - pipeline_conversion_process: "overlap_analysis_with_conversion"
    - cache_intermediate_results: "reuse_analysis_across_episodes"
    - progressive_enhancement: "build_analysis_incrementally"
```

### Migration Prioritization
```yaml
migration_priority:
  high_priority:
    - episodes_in_production_soon: "migrate_first_for_immediate_use"
    - high_quality_existing_research: "maximize_value_from_good_research"
    - season_finales_and_premieres: "ensure_flagship_episodes_enhanced"

  medium_priority:
    - complete_seasons: "migrate_seasons_together_for_coherence"
    - thematically_related_episodes: "migrate_clusters_for_cross_analysis"
    - complex_episodes: "enhance_complex_content_first"

  low_priority:
    - standalone_episodes: "less_benefit_from_cross_episode_features"
    - already_produced_episodes: "archival_enhancement_less_urgent"
    - low_quality_original_research: "may_be_better_to_re_research"
```

## Cross-Episode Analysis During Migration

### Relationship Discovery Process
```yaml
relationship_analysis:
  content_similarity:
    - theme_extraction: "identify_common_themes_across_episodes"
    - concept_mapping: "map_shared_concepts_and_ideas"
    - expert_overlap: "find_shared_expert_references"
    - source_sharing: "identify_common_research_sources"

  structural_analysis:
    - complexity_progression: "analyze_complexity_relationships"
    - prerequisite_identification: "identify_conceptual_dependencies"
    - narrative_continuity: "find_story_arc_connections"

  quality_enhancement_opportunities:
    - research_gap_filling: "identify_opportunities_to_share_research"
    - expert_quote_cross_utilization: "find_reusable_expert_insights"
    - source_diversification: "identify_source_sharing_opportunities"
```

### Thematic Cluster Generation
```yaml
thematic_clustering:
  automated_clustering:
    - content_analysis_clustering: "group_episodes_by_content_similarity"
    - theme_based_grouping: "organize_by_primary_and_secondary_themes"
    - complexity_level_grouping: "cluster_by_appropriate_complexity_levels"

  manual_refinement:
    - expert_review_clusters: "validate_clustering_makes_narrative_sense"
    - brand_alignment_validation: "ensure_clusters_support_intellectual_humility"
    - production_practicality: "verify_clusters_useful_for_production"

  cluster_optimization:
    - research_synergy_maximization: "optimize_clusters_for_research_sharing"
    - production_efficiency: "organize_for_efficient_production_workflow"
    - audience_experience: "ensure_clusters_enhance_listener_experience"
```

## Quality Enhancement During Migration

### Research Quality Improvement
```yaml
quality_improvements:
  source_credibility_enhancement:
    - verify_and_score_existing_sources: "assess_credibility_of_legacy_sources"
    - identify_credibility_gaps: "find_opportunities_for_better_sources"
    - suggest_source_improvements: "recommend_higher_quality_alternatives"

  expert_perspective_diversification:
    - analyze_expert_diversity: "assess_range_of_expert_perspectives"
    - identify_perspective_gaps: "find_missing_viewpoints"
    - suggest_expert_additions: "recommend_additional_expert_perspectives"

  research_depth_enhancement:
    - assess_research_completeness: "evaluate_depth_of_existing_research"
    - identify_research_gaps: "find_areas_needing_additional_research"
    - prioritize_enhancement_opportunities: "rank_improvement_opportunities_by_value"
```

### Brand Alignment Enhancement
```yaml
brand_alignment_improvements:
  intellectual_humility_scoring:
    - analyze_existing_uncertainty_acknowledgment: "assess_current_humility_level"
    - identify_certainty_overstatements: "find_areas_needing_more_humility"
    - suggest_humility_enhancements: "recommend_ways_to_increase_intellectual_humility"

  nobody_knows_moment_identification:
    - extract_existing_uncertainty_moments: "find_current_nobody_knows_moments"
    - identify_additional_opportunities: "suggest_additional_uncertainty_highlights"
    - optimize_uncertainty_presentation: "enhance_how_uncertainty_is_presented"
```

## Migration Validation and Testing

### Conversion Accuracy Testing
```yaml
accuracy_validation:
  content_preservation:
    - compare_original_vs_converted: "ensure_no_research_content_lost"
    - validate_metadata_accuracy: "verify_all_metadata_correctly_converted"
    - check_cost_tracking_preservation: "ensure_cost_data_accurately_migrated"

  schema_compliance:
    - validate_against_enhanced_schema: "ensure_converted_data_meets_schema"
    - test_production_pipeline_compatibility: "verify_works_with_production_commands"
    - validate_cross_episode_data_integrity: "ensure_relationship_data_valid"
```

### Quality Improvement Validation
```yaml
improvement_validation:
  quality_score_improvements:
    - before_after_quality_comparison: "measure_quality_improvement_from_migration"
    - validate_quality_score_accuracy: "ensure_quality_scores_reflect_actual_quality"
    - test_production_readiness: "verify_migrated_research_production_ready"

  cross_episode_relationship_accuracy:
    - validate_relationship_strength_scores: "ensure_relationship_scores_accurate"
    - test_thematic_consistency: "verify_themes_correctly_identified"
    - check_brand_alignment_scores: "validate_brand_alignment_assessment"
```

## Migration Reporting and Documentation

### Migration Summary Reports
```yaml
migration_reporting:
  conversion_summary:
    - episodes_migrated_count: "total_episodes_successfully_converted"
    - migration_mode_breakdown: "count_by_basic/enhanced/cross_episode"
    - quality_improvements_achieved: "average_quality_score_improvement"
    - cost_efficiency_gains: "estimated_production_cost_savings"

  quality_enhancement_summary:
    - research_quality_improvements: "detailed_quality_improvement_analysis"
    - brand_alignment_enhancements: "intellectual_humility_score_improvements"
    - cross_episode_relationships_discovered: "count_and_quality_of_relationships_found"

  production_impact_assessment:
    - estimated_production_time_savings: "time_savings_from_enhanced_research"
    - quality_gate_pass_rate_improvements: "expected_quality_gate_improvements"
    - cross_episode_production_benefits: "benefits_from_cross_episode_awareness"
```

### Migration Documentation Generation
```yaml
documentation_generation:
  conversion_logs:
    - detailed_conversion_process_log: "step_by_step_conversion_record"
    - quality_assessment_documentation: "detailed_quality_analysis_results"
    - cross_episode_analysis_report: "comprehensive_relationship_analysis"

  user_guides:
    - using_migrated_research_guide: "how_to_use_enhanced_research_packages"
    - cross_episode_features_guide: "leveraging_cross_episode_capabilities"
    - quality_improvements_guide: "understanding_quality_enhancements"
```

This migration system ensures smooth transition from legacy research to the enhanced research-first workflow while preserving all valuable research and adding significant new capabilities.
