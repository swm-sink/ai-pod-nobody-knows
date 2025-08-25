---
name: monitor-research-freshness
description: Monitor and manage research freshness across all episodes with automated update recommendations
---

# Monitor Research Freshness - Freshness Tracking & Update Management

Monitor the freshness of all research packages and provide automated recommendations for updates based on staleness, production priority, and episode dependencies.

## Usage

```
/monitor-research-freshness [action] [episode_range] [options]
```

## Actions

### Check Freshness Status
```
/monitor-research-freshness check                    # Check all episodes
/monitor-research-freshness check 1 25              # Check Season 1 only
/monitor-research-freshness check --stale-only      # Show only stale research
```

### Generate Update Plan
```
/monitor-research-freshness plan                     # Generate comprehensive update plan
/monitor-research-freshness plan --priority high    # High priority updates only
/monitor-research-freshness plan --season 2         # Season 2 update plan
```

### Execute Updates
```
/monitor-research-freshness update                   # Update all critical/stale research
/monitor-research-freshness update --episodes 5,12,18  # Update specific episodes
/monitor-research-freshness update --auto-approve   # Update without confirmation
```

## Execution Strategy

Use the 01_research_orchestrator subagent with freshness-specific enhancements:

### Phase 1: Freshness Assessment
1. **Load All Research Packages**: Scan all season directories for research packages
2. **Calculate Freshness Scores**: Determine staleness based on research dates and topic velocity
3. **Assess Update Priority**: Apply production schedule, episode complexity, and dependency analysis
4. **Generate Freshness Report**: Create comprehensive freshness status report

### Phase 2: Update Recommendation Engine
1. **Priority Matrix Analysis**: Cross-reference staleness with production importance
2. **Cost-Benefit Analysis**: Calculate update cost vs. quality improvement
3. **Dependency Mapping**: Identify episodes affected by stale research in related episodes
4. **Resource Optimization**: Group updates for efficiency and bulk discount opportunities

### Phase 3: Automated Update Execution
1. **Targeted Research Updates**: Focus on stale information rather than complete re-research
2. **Cross-Episode Impact Analysis**: Update related episodes when core research changes
3. **Quality Validation**: Ensure updated research meets quality standards
4. **Integration Verification**: Validate updated packages work with production pipeline

## Freshness Scoring Algorithm

### Time-Based Scoring
```yaml
# Base freshness calculation
days_since_research = current_date - research_date
base_staleness_score = min(days_since_research / max_freshness_days, 1.0)

# Topic velocity adjustment (how fast field changes)
topic_velocity_multiplier:
  "AI/ML": 2.0          # Fast-moving field, stales quickly
  "Physics": 0.8        # Slower-moving, longer freshness window
  "Philosophy": 0.5     # Evergreen topics, very slow staleness
  "Current Events": 3.0 # Extremely fast staleness

# Final freshness score
freshness_score = 1.0 - (base_staleness_score * topic_velocity_multiplier)
```

### Freshness Categories
- **Fresh (0.85-1.00):** Research is current and production-ready
- **Aging (0.70-0.84):** Research is acceptable but monitor for updates
- **Stale (0.50-0.69):** Research needs selective updates before production
- **Critical (0.00-0.49):** Research requires comprehensive refresh

### Priority Matrix
```yaml
# Update priority calculation
priority_factors:
  production_schedule:
    "in_production": 5.0      # Currently being produced
    "next_30_days": 4.0       # Production planned within 30 days
    "next_90_days": 2.0       # Production planned within 90 days
    "future": 1.0             # No immediate production plans

  episode_complexity:
    "9-10": 3.0               # Complex episodes need fresh research
    "7-8": 2.5                # Advanced episodes moderately affected
    "5-6": 2.0                # Intermediate episodes somewhat affected
    "1-4": 1.5                # Basic episodes less affected by staleness

  cross_episode_impact:
    "high_connectivity": 3.0   # Episode affects many others
    "medium_connectivity": 2.0 # Episode affects some others
    "low_connectivity": 1.0    # Episode mostly standalone

  brand_criticality:
    "season_finale": 4.0       # Season finales must have fresh research
    "series_premiere": 4.0     # High visibility episodes
    "flagship_episodes": 3.0   # Important brand episodes
    "standard_episodes": 2.0   # Regular episodes

# Final priority score
update_priority = (1.0 - freshness_score) * sum(applicable_factors)
```

## Update Strategies

### Selective Updates (Efficient)
- **Target Stale Information**: Only update outdated facts and sources
- **Preserve Quality Research**: Keep valuable research that's still relevant
- **Incremental Approach**: Add new information rather than replacing everything
- **Cost Range**: $0.10-0.30 per episode

### Comprehensive Refresh (Thorough)
- **Complete Re-research**: Full research pipeline execution
- **Quality Improvement**: Opportunity to enhance research beyond freshness
- **Cross-Episode Sync**: Update related episodes simultaneously
- **Cost Range**: $0.60-0.80 per episode

### Strategic Hybrid (Balanced)
- **Core Facts Update**: Refresh critical information
- **Source Validation**: Verify and update key sources
- **Expert Quote Refresh**: Seek recent expert perspectives
- **Cost Range**: $0.25-0.45 per episode

## Automated Update Workflows

### Daily Freshness Monitoring
```yaml
# Automated daily tasks
daily_monitoring:
  - scan_all_research_packages: true
  - calculate_freshness_scores: true
  - identify_critical_staleness: true
  - flag_production_conflicts: true
  - generate_daily_report: true
  - alert_on_critical_issues: true
```

### Weekly Update Planning
```yaml
# Weekly planning automation
weekly_planning:
  - generate_update_recommendations: true
  - calculate_update_costs: true
  - prioritize_by_production_schedule: true
  - optimize_batch_updates: true
  - prepare_update_proposals: true
  - schedule_update_execution: true
```

### Production-Triggered Updates
```yaml
# When episode enters production
production_triggers:
  - validate_research_freshness: true
  - alert_if_stale_research: true
  - provide_update_options: true
  - track_production_delays: true
  - escalate_critical_staleness: true
```

## Integration with Production Pipeline

### Research Package Validation
```yaml
# Pre-production freshness checks
validation_gates:
  - check_research_freshness_score: true
  - validate_source_currency: true
  - verify_expert_quote_relevance: true
  - assess_fact_accuracy: true
  - flag_potential_staleness_issues: true
```

### Dynamic Update Triggers
```yaml
# Real-time update triggers
triggers:
  breaking_news_in_topic: "immediate_update_required"
  expert_retraction: "immediate_validation_required"
  research_contradiction: "investigation_required"
  source_update: "selective_update_recommended"
```

## Cost Optimization for Updates

### Bulk Update Economics
- **Volume Discounts**: 15% discount for 10+ episode updates
- **Thematic Batching**: Group related episodes for research efficiency
- **Shared Source Updates**: Update shared sources once, apply to multiple episodes
- **Progressive Updates**: Stage updates based on production schedule

### Update Cost Projections
```yaml
# Cost scenarios for 125 episodes
scenario_analysis:
  aggressive_updates:
    update_frequency: "monthly"
    episodes_updated_per_cycle: 25
    annual_cost: $300-400
    quality_benefit: "high"

  balanced_updates:
    update_frequency: "quarterly"
    episodes_updated_per_cycle: 15
    annual_cost: $150-200
    quality_benefit: "good"

  conservative_updates:
    update_frequency: "bi_annually"
    episodes_updated_per_cycle: 8
    annual_cost: $75-100
    quality_benefit: "acceptable"
```

## Freshness Reporting

### Daily Freshness Dashboard
```yaml
# Daily freshness metrics
dashboard_metrics:
  - total_episodes_tracked: 125
  - fresh_episodes_count: "count with score 0.85+"
  - aging_episodes_count: "count with score 0.70-0.84"
  - stale_episodes_count: "count with score 0.50-0.69"
  - critical_episodes_count: "count with score <0.50"
  - episodes_in_production_with_stale_research: "critical metric"
  - average_freshness_score: "overall health"
  - projected_update_costs: "budget planning"
```

### Weekly Update Reports
```yaml
# Weekly comprehensive reports
report_sections:
  - freshness_trend_analysis: "week over week changes"
  - update_recommendations: "prioritized update list"
  - cost_benefit_analysis: "ROI for proposed updates"
  - production_impact_assessment: "effects on production schedule"
  - research_gap_identification: "systematic weaknesses"
  - quality_improvement_opportunities: "beyond freshness"
```

## Advanced Features

### Predictive Staleness Modeling
- **Topic Velocity Analysis**: Predict when research will become stale
- **Event-Driven Updates**: Anticipate research impacts from breaking news
- **Seasonal Patterns**: Account for cyclical research update needs
- **Expert Activity Tracking**: Monitor when experts publish new work

### Smart Update Scheduling
- **Production Calendar Integration**: Schedule updates based on production timeline
- **Resource Availability**: Consider research capacity and budget constraints
- **Dependency Chain Updates**: Update prerequisite episodes first
- **Impact Minimization**: Schedule updates to minimize production disruption

### Quality Enhancement Integration
- **Update + Improve**: Combine freshness updates with quality improvements
- **Source Diversification**: Use updates to add source diversity
- **Expert Network Expansion**: Leverage updates to include new expert perspectives
- **Cross-Episode Consistency**: Ensure updates maintain thematic consistency

## Recovery and Rollback

### Update Failure Recovery
- **Checkpoint-Based Updates**: Save progress during multi-episode updates
- **Graceful Degradation**: Fall back to previous research if update fails
- **Quality Validation**: Ensure updated research meets quality standards
- **Rollback Procedures**: Restore previous research packages if needed

### Version Control for Research
- **Research Package Versioning**: Track all research package versions
- **Change Log Maintenance**: Document all updates and reasons
- **Diff Analysis**: Show what changed between research versions
- **Audit Trail**: Complete history of all research modifications

This freshness tracking system ensures research quality remains high while optimizing update costs and minimizing production disruption.
