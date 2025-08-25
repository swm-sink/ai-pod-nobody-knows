---
name: research-all-episodes
description: Batch research multiple episodes using existing research agents
---

# Research All Episodes - Simple Batch Research

Execute research for multiple episodes using the existing research orchestrator agent.

## Usage

```
/research-all-episodes [episode_count] [starting_episode]
```

## Examples

```
/research-all-episodes 5                 # Research next 5 episodes starting from 1
/research-all-episodes 5 10             # Research 5 episodes starting from episode 10
```

## Execution

For each episode in the range, sequentially execute:

1. **Load Episode Details**: Read episode title and description from `episodes_master.json`
2. **Create Research Session**: Use standard session directory structure
3. **Execute Research**: Run 01_research_orchestrator with episode topic
4. **Save Results**: Store research in standard format for later production use

## Process

For episode_count episodes starting at starting_episode:
- Read episode details from series plan
- Create session directory: `sessions/ep_{number}_{date}/`
- Research episode using existing research workflow
- Track total costs and time
- Continue to next episode

## Output

- Individual research sessions for each episode
- Cost tracking across all episodes
- Standard research packages ready for production
- Session directories following existing patterns

## Output Structure

```
projects/nobody-knows/output/research/
├── batch_research_[date]/
│   ├── research_session_metadata.json     # Master batch tracking
│   ├── progress_tracking.json            # Real-time progress and costs
│   ├── cross_episode_mapping.json        # Episode relationship analysis
│   ├── thematic_index.json              # Theme-to-episode mapping
│   ├── season_01/                        # Season-based organization
│   │   ├── ep_001_research_package.json
│   │   ├── ep_002_research_package.json
│   │   └── ...
│   ├── season_02/
│   │   ├── ep_026_research_package.json
│   │   └── ...
│   └── research_quality_report.md        # Overall batch quality assessment
└── master_research_index.json            # Global searchable index
```

## Benefits of Research-First Approach

### Research Quality Benefits
- **Cross-Episode Synergies**: Identify shared themes and research efficiencies
- **Thematic Consistency**: Ensure coherent narrative across seasons
- **Source Optimization**: Reuse high-quality sources across related episodes
- **Depth Scaling**: Appropriate research intensity for complexity levels

### Production Benefits
- **Faster Episode Production**: Research pre-completed, focus on script quality
- **Batch Cost Optimization**: Negotiate better rates for bulk research
- **Research Reusability**: Share research components across related episodes
- **Quality Predictability**: Pre-validated research reduces production risks

### Operational Benefits
- **Parallel Production**: Multiple episodes can be produced simultaneously
- **Resource Planning**: Predictable research costs and timelines
- **Gap Identification**: Early identification of research gaps across series
- **Strategic Pivoting**: Ability to adjust series direction based on research findings

## Research Freshness Management

### Freshness Tracking
- **Initial Research Date**: Track when research was conducted
- **Staleness Threshold**: 3-month default freshness window
- **Update Triggers**: Automatic alerts when research approaches staleness
- **Priority Updates**: Critical episodes flagged for research refresh

### Update Strategy
```yaml
# Research Update Prioritization
high_priority_updates:
  - episodes_in_production: "Immediate update required"
  - season_finales: "High visibility episodes need fresh research"
  - complex_episodes: "Level 7+ episodes require recent research"

medium_priority_updates:
  - seasonal_themes: "Update research for thematic consistency"
  - cross_episode_dependencies: "Update when related episodes change"

low_priority_updates:
  - evergreen_topics: "Foundational concepts, less frequent updates"
  - completed_seasons: "Lower priority for aired content"
```

## Cost Optimization Features

### Batch Research Economics
- **Volume Discounts**: Negotiate better per-query rates for bulk research
- **Research Sharing**: Amortize research costs across related episodes
- **Smart Batching**: Optimal batch sizes to minimize API overhead
- **Progress Checkpoints**: Fail-safe mechanisms to prevent research loss

### Estimated Costs
```yaml
# Research Cost Projections (125 episodes)
traditional_approach:
  per_episode_research: $1.00
  total_research_cost: $125.00

research_first_approach:
  bulk_research_discount: 15%
  cross_episode_efficiency: 20%
  estimated_total_cost: $85.00  # ~32% savings
  additional_benefits: "Higher quality, faster production"
```

## Integration with Existing Production

### Production Pipeline Integration
1. **Research Package Validation**: Verify research packages before production
2. **Freshness Checks**: Automated staleness warnings during production
3. **Research Enhancement**: Option to supplement existing research during production
4. **Quality Gate Integration**: Research quality scores feed into production quality gates

### Backward Compatibility
- **Existing Commands Preserved**: /produce-research continues to work for individual episodes
- **Hybrid Workflow Support**: Can mix batch-researched and individually-researched episodes
- **Graceful Fallback**: If batch research unavailable, fall back to individual research
- **Session Integration**: Batch research sessions integrate with existing session tracking

## Risk Mitigation

### Research Staleness Risks
- **Automated Monitoring**: Track research age and flag stale content
- **Progressive Updates**: Prioritize updates based on episode production schedule
- **Quality Degradation Detection**: Monitor for declining research quality over time

### Batch Processing Risks
- **Checkpoint System**: Regular save points to prevent data loss
- **Error Recovery**: Resume batch processing from last successful checkpoint
- **Cost Runaway Protection**: Budget limits and alerts for batch operations
- **Quality Monitoring**: Real-time quality assessment during batch processing

This research-first architecture enables efficient, high-quality research for all 125 episodes while maintaining production flexibility and optimizing costs.
