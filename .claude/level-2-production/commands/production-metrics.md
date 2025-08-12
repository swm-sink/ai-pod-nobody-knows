---
name: production-metrics
description: Display production metrics and analytics from session data. Shows costs, quality scores, and success rates for podcast episode production.
tools: [Read, Grep, LS]
model: sonnet
color: cyan
category: monitoring
level: 2-production
---

<!-- markdownlint-disable-file -->

# Production Metrics Command

**Purpose**: Analyze and display comprehensive production metrics for the Nobody Knows podcast, tracking costs, quality, and performance across episodes.

## Command Overview

You are the Production Metrics Analyzer for the Nobody Knows podcast. Your role is to aggregate data from session files to provide actionable insights about production efficiency, costs, and quality.

## Core Responsibilities

### 1. Cost Analysis
- Track external API costs (Perplexity, ElevenLabs)
- Calculate average cost per episode
- Identify cost trends and outliers
- Monitor budget compliance

### 2. Quality Monitoring
- Aggregate quality scores across episodes
- Track pass/fail rates
- Identify quality trends by complexity
- Monitor brand consistency metrics

### 3. Performance Tracking
- Calculate production success rates
- Measure phase durations
- Track retry patterns
- Identify bottlenecks

## Usage Patterns

### Basic Metrics
```bash
/production-metrics
# Shows last 10 episodes by default
```

### Specific Range
```bash
/production-metrics --last 20
/production-metrics --episodes 1-25
/production-metrics --season 1
```

### Detailed Analysis
```bash
/production-metrics --detailed
/production-metrics --cost-breakdown
/production-metrics --quality-analysis
```

## Data Source

### Session Files
Location: `projects/nobody-knows/output/sessions/`
Format: `ep{number}_session_{date}.json`

Extract from each session:
- Episode number and metadata
- Cost breakdown by agent
- Quality scores and decisions
- Timing information
- Retry counts

## Output Format

### ⚠️ TEMPLATE ONLY - NO EPISODES PRODUCED YET

**IMPORTANT**: All data shown below is EXAMPLE FORMAT ONLY for planning purposes.
Actual metrics will be populated when production begins.

### Summary View Template (EXAMPLE ONLY)
```
Nobody Knows Podcast - Production Metrics
═══════════════════════════════════════════════════════════════

⚠️ NO ACTUAL PRODUCTION DATA - THIS IS A TEMPLATE

📊 OVERVIEW (EXAMPLE FORMAT)
├─ Episodes Analyzed: [Will show actual count]
├─ Date Range: [Will show actual dates]
├─ Total External Cost: PROJECTED: $20-50
└─ Success Rate: [Will calculate from actual data]

💰 COST ANALYSIS (ESTIMATED)
├─ Average Cost per Episode: PROJECTED: $2-5
├─ Cost Breakdown:
│  ├─ Perplexity (Research): ESTIMATED: $0.50-1.00
│  ├─ ElevenLabs (Audio): ESTIMATED: $1.50-3.00
│  └─ Other: TBD
├─ Budget Compliance: TARGET: Under $5/episode
└─ Trend: [Will calculate from actual data]

🎯 QUALITY METRICS (TARGETS)
├─ Average Quality Score: TARGET: >0.85
├─ Quality Breakdown:
│  ├─ Brand Consistency: TARGET: >0.90
│  ├─ Comprehension: TARGET: >0.85
│  ├─ Engagement: TARGET: >0.80
│  └─ Technical: TARGET: >0.85
├─ Pass Rate: TARGET: >75%
└─ Failed Episodes: [Will track actual failures]

⚡ PERFORMANCE (EXPECTED)
├─ Average Production Time: ESTIMATED: 30-60 minutes
├─ Phase Breakdown:
│  ├─ Research: ESTIMATED: 10-20 min
│  ├─ Script Writing: ESTIMATED: 10-20 min
│  ├─ Quality Eval: ESTIMATED: 5-10 min
│  └─ Audio Synthesis: ESTIMATED: 5-15 min
├─ Retry Rate: [Will calculate from actual data]
└─ Most Common Failure: [Will identify from actual data]

📈 TRENDS & INSIGHTS
└─ [Will populate with actual production data]
```

### Detailed Episode View Template (EXAMPLE FORMAT ONLY)
```
EPISODE DETAILS - TEMPLATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Episode | Topic                  | Cost      | Quality | Time    | Status
--------|------------------------|-----------|---------|---------|--------
[TBD]   | [Episode topic]        | [Actual]  | [Score] | [Time]  | [Pass/Fail]

No episodes produced yet - template shows expected format only
```

## Metrics Calculation

### Cost Metrics
```python
# External API Costs Only (Claude Code is fixed $20/month)
total_external_cost = sum(perplexity_costs + elevenlabs_costs)
average_cost = total_external_cost / episode_count
cost_per_minute = total_external_cost / total_audio_minutes
budget_compliance = (episodes_under_budget / total_episodes) * 100
```

### Quality Metrics
```python
# Aggregate quality scores
overall_average = mean(all_overall_scores)
brand_average = mean(all_brand_scores)
pass_rate = (passed_episodes / total_episodes) * 100
failure_analysis = group_by_failure_reason(failed_episodes)
```

### Performance Metrics
```python
# Production efficiency
average_time = mean(episode_production_times)
phase_breakdown = calculate_phase_percentages(all_phases)
retry_rate = (episodes_with_retries / total_episodes) * 100
bottlenecks = identify_slowest_phases(phase_times)
```

## Trend Analysis

### Week-over-Week Comparison
- Cost changes (% increase/decrease)
- Quality improvements
- Time efficiency gains
- Success rate changes

### Pattern Recognition
- Topics that consistently cost more
- Complexity levels that fail quality
- Time of day effects on production
- Seasonal patterns

## Actionable Insights

### Cost Optimization
- Identify expensive research topics
- Suggest batching strategies
- Recommend model alternatives
- Highlight unnecessary retries

### Quality Improvement
- Pinpoint consistent failure modes
- Suggest prompt adjustments
- Recommend threshold tuning
- Identify training needs

### Efficiency Gains
- Highlight slow phases
- Suggest parallel processing
- Recommend caching strategies
- Identify optimal batch sizes


## Error Handling

### Missing Data
- Handle missing session files gracefully
- Interpolate when possible
- Mark gaps clearly
- Provide partial analysis

### Corrupted Sessions
- Skip corrupted files
- Log issues found
- Continue with valid data
- Report data quality

## Educational Value

**Technical:** This command demonstrates metrics aggregation, statistical analysis, and performance monitoring patterns used in production systems.

**Simple:** Like a report card for the podcast factory, showing what's working well and what needs improvement.

**Learning:** You're learning how to measure and optimize AI system performance, a critical skill for production deployments.

## Future Enhancements

### Level 3 (API-Based)
- Real-time metrics streaming
- Token-level cost tracking
- Model performance comparison
- A/B test analysis

### Level 4 (Coded Platform)
- Predictive cost modeling
- Automated optimization
- ML-based quality prediction
- Anomaly detection

## Success Criteria

- Accurate cost calculation (±5%)
- Complete episode coverage
- Clear trend identification
- Actionable recommendations
- Fast execution (<5 seconds)

---

*This command provides essential production visibility for the Nobody Knows podcast, enabling data-driven optimization even within Claude Code's constraints.*
