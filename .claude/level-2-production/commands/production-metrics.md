---
name: production-metrics
description: Display production metrics and analytics from session data. Shows costs, quality scores, and success rates for podcast episode production.
tools: [Read, Grep, LS]
model: sonnet
color: cyan
category: monitoring
level: 2-production
---

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

### Summary View (Default)
```
Nobody Knows Podcast - Production Metrics
═══════════════════════════════════════════════════════════════

📊 OVERVIEW (Last 10 Episodes)
├─ Episodes Analyzed: 10
├─ Date Range: 2024-08-01 to 2024-08-11
├─ Total External Cost: $23.50
└─ Success Rate: 80% (8/10 passed quality gates)

💰 COST ANALYSIS
├─ Average Cost per Episode: $2.35
├─ Cost Breakdown:
│  ├─ Perplexity (Research): $0.50 avg (21%)
│  ├─ ElevenLabs (Audio): $1.85 avg (79%)
│  └─ Other: $0.00 (0%)
├─ Budget Compliance: 100% under $5 target
└─ Trend: Stable ➡️

🎯 QUALITY METRICS
├─ Average Quality Score: 0.87
├─ Quality Breakdown:
│  ├─ Brand Consistency: 0.91 (✅ exceeds 0.90 threshold)
│  ├─ Comprehension: 0.86 (✅ exceeds 0.85 threshold)
│  ├─ Engagement: 0.84 (✅ exceeds 0.80 threshold)
│  └─ Technical: 0.87 (✅ exceeds 0.85 threshold)
├─ Pass Rate: 80% (8/10)
└─ Failed Episodes: [3, 7] - Brand consistency issues

⚡ PERFORMANCE
├─ Average Production Time: 45 minutes
├─ Phase Breakdown:
│  ├─ Research: 15 min (33%)
│  ├─ Script Writing: 12 min (27%)
│  ├─ Quality Eval: 8 min (18%)
│  └─ Audio Synthesis: 10 min (22%)
├─ Retry Rate: 20% (2 episodes needed retries)
└─ Most Common Failure: Brand voice (60% of failures)

📈 TRENDS & INSIGHTS
├─ Cost Trend: Decreasing (-5% week-over-week)
├─ Quality Trend: Improving (+3% week-over-week)
├─ Efficiency: 15% faster than previous week
└─ Recommendation: Consider increasing brand voice emphasis in prompts
```

### Detailed Episode View
```
EPISODE DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Episode | Topic                  | Cost   | Quality | Time  | Status
--------|------------------------|--------|---------|-------|--------
001     | AI Consciousness       | $2.35  | 0.87    | 42min | ✅ PASS
002     | Quantum Computing      | $2.50  | 0.91    | 38min | ✅ PASS
003     | Dark Matter           | $3.10  | 0.83    | 55min | ❌ FAIL
004     | Climate Tipping       | $2.25  | 0.89    | 41min | ✅ PASS
005     | Gene Editing          | $2.40  | 0.88    | 44min | ✅ PASS
...

Averages| -                     | $2.52  | 0.87    | 44min | 80%
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
