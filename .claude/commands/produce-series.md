---
name: produce-series
description: Execute batch production of multiple podcast episodes with queue management, cost tracking, and failure recovery
---

# Produce Series - Batch Episode Production Command

Execute automated production of multiple podcast episodes with intelligent queue management, series-level cost tracking, and robust failure handling.

## Usage

```
/produce-series [series_config_file]
/produce-series --interactive  # Guided series setup
/produce-series --resume [series_id]  # Resume interrupted series
```

## Examples

```
# Produce predefined series
/produce-series .claude/series/season_01_mysteries.yaml

# Interactive series creation
/produce-series --interactive

# Resume failed series
/produce-series --resume series_20250818_mysteries

# Quick 5-episode series on specific theme
/produce-series --quick "AI limitations" --count 5
```

## Series Configuration Format

Create series configuration in `.claude/series/[name].yaml`:

```yaml
series_metadata:
  name: "AI Mysteries Season 1"
  series_id: "season_01_mysteries"
  description: "Exploring what we don't know about AI"
  target_episodes: 10
  budget_total: 50.00      # Total series budget
  budget_per_episode: 5.00 # Individual episode limit

scheduling:
  mode: "sequential"       # sequential, parallel, or hybrid
  batch_size: 3           # Max concurrent episodes for parallel mode
  delay_between: 300      # Seconds between episode starts

episodes:
  - episode_number: 1
    topic: "The Mystery of Neural Network Weights"
    research_focus: "what_experts_dont_know_about_learned_representations"
    target_duration: 47
    priority: high

  - episode_number: 2
    topic: "Why Large Language Models Hallucinate"
    research_focus: "uncertainty_and_confidence_in_ai_responses"
    target_duration: 47
    priority: high

  - episode_number: 3
    topic: "The Consciousness Question in AI"
    research_focus: "philosophical_uncertainties_about_machine_consciousness"
    target_duration: 47
    priority: medium

quality_overrides:
  research_depth: "enhanced"     # standard, enhanced, comprehensive
  quality_threshold: 0.88        # Higher than default 0.85
  evaluator_consensus: 0.92      # Stricter consensus requirement

failure_handling:
  max_retries_per_episode: 2
  skip_failed_episodes: false    # true to continue series despite failures
  automatic_rollback: true
  preserve_partial_work: true
```

## Execution Workflow

The series orchestrator executes this intelligent workflow:

### Phase 1: Series Initialization
1. **Validate Configuration**
   - Parse and validate series YAML
   - Check total budget allocation
   - Verify episode topics are unique and feasible
   - Create series session directory structure

2. **Resource Planning**
   - Calculate estimated costs for entire series
   - Plan execution schedule based on mode and constraints
   - Set up monitoring and logging infrastructure
   - Create rollback checkpoints

3. **User Confirmation**
   - Present series plan and cost estimates
   - Request explicit approval before proceeding
   - Allow modifications to configuration
   - Document approved plan for tracking

### Phase 2: Episode Production Queue

For each episode in the series:

1. **Research Phase (Stream 1)**
   ```
   /produce-research [episode_topic]
   # Wait for research completion
   # Save research package for user review
   ```

2. **User Review Checkpoint**
   ```
   # Notify user: "Episode X research ready for review"
   # Present research summary and cost tracking
   # Request approval: "Approve for production? (y/n/modify)"
   ```

3. **Production Phase (Stream 2)**
   ```
   /produce-episode [approved_research_session]
   # Execute full production pipeline
   # Apply series-level quality overrides
   # Track costs against episode and series budgets
   ```

4. **Quality Validation**
   - Apply series-level quality standards
   - Validate against user's quality overrides
   - Generate episode completion report
   - Update series progress tracking

### Phase 3: Series Management

**Concurrent Monitoring:**
- Real-time cost tracking across all episodes
- Progress visualization with completion percentages
- Quality metrics aggregation
- Failure detection and automatic recovery

**Adaptive Scheduling:**
- Adjust timing based on actual vs estimated costs
- Reorder episodes if priorities change
- Pause series if budget limits approached
- Scale concurrent processing based on success rates

## Cost Management

### Budget Tracking
- **Episode Level**: Individual episode costs vs `budget_per_episode`
- **Series Level**: Running total vs `budget_total`
- **Predictive**: Estimate remaining costs based on completed episodes
- **Alerts**: Warn at 75%, 90%, and 95% of budget limits

### Cost Optimization
- **Bulk Discounts**: Leverage ElevenLabs subscription tiers for multi-episode production
- **Resource Reuse**: Cache common intro/outro audio segments
- **Parallel Efficiency**: Optimize concurrent processing to reduce per-episode overhead
- **Quality Trading**: Allow slightly lower quality for episodes marked as lower priority

## Failure Handling & Recovery

### Episode-Level Failures
1. **Immediate Preservation**: Save all completed work for failed episode
2. **Impact Assessment**: Determine if failure affects subsequent episodes
3. **Recovery Options**:
   - **Retry**: Restart failed episode from last checkpoint
   - **Skip**: Continue series, mark episode for manual completion later
   - **Pause**: Stop series for manual intervention
   - **Abort**: Cancel remaining episodes, preserve completed work

### Series-Level Failures
1. **Session Preservation**: Complete series state saved automatically
2. **Resume Capability**: `/produce-series --resume [series_id]` continues from failure point
3. **Partial Recovery**: Individual episodes can be extracted and completed manually
4. **Cost Protection**: Failed episodes don't consume full episode budget

## Quality Gates for Series Production

### Enhanced Quality Standards
- **Research Consistency**: Ensure series maintains thematic coherence
- **Quality Progression**: Later episodes should meet or exceed early episode quality
- **Brand Voice Stability**: Consistent intellectual humility theme across series
- **Technical Standards**: Audio quality and format consistency

### Series-Level Validations
- **Topic Diversity**: Prevent overly similar episodes within series
- **Expert Source Distribution**: Ensure diverse expert perspectives across series
- **Complexity Balance**: Mix of introductory and advanced topics
- **Narrative Arc**: Optional story progression across episodes

## Output Structure

```
.claude/series/[series_id]/
├── series_config.yaml           # Original configuration
├── series_status.json           # Real-time progress tracking
├── series_cost_tracking.json    # Comprehensive cost analytics
├── series_quality_report.json   # Aggregated quality metrics
├── episodes/
│   ├── ep_001_[topic_slug]/
│   │   ├── research/            # Research stream outputs
│   │   ├── production/          # Production stream outputs
│   │   └── episode_summary.json # Episode completion report
│   ├── ep_002_[topic_slug]/
│   └── ...
├── logs/
│   ├── series_execution.log     # Detailed execution logging
│   ├── cost_tracking.log        # Financial audit trail
│   └── quality_metrics.log      # Quality progression tracking
└── backups/
    ├── checkpoint_001/          # Series state after episode 1
    ├── checkpoint_002/          # Series state after episode 2
    └── ...
```

## Monitoring & Progress Tracking

### Real-Time Dashboard
- **Series Progress**: Episodes completed/in-progress/queued
- **Cost Tracking**: Current spend vs budget with projections
- **Quality Trends**: Quality scores trending up/down across episodes
- **Timeline**: Estimated completion dates based on current progress

### Notification System
- **Milestone Alerts**: "Episode 5 of 10 completed successfully"
- **Budget Warnings**: "Series at 80% of budget with 40% episodes remaining"
- **Quality Issues**: "Episode 3 quality below series standards - review recommended"
- **Completion**: "Series 'AI Mysteries Season 1' completed: 10/10 episodes, $47.50 total cost"

## Interactive Mode

For users who prefer guided setup:

```
/produce-series --interactive

> Welcome to Series Production! Let's create your podcast series.
>
> Series name: AI Mysteries Season 1
> Number of episodes: 10
> Budget per episode ($1-9): 5
> Total series budget: $50
>
> Episode topics (one per line, empty line to finish):
> 1. The Mystery of Neural Network Weights
> 2. Why Large Language Models Hallucinate
> 3. [continue...]
>
> Quality level (standard/enhanced/premium): enhanced
> Production mode (sequential/parallel): sequential
>
> Review your series configuration:
> [Display formatted configuration]
>
> Start production? (y/n/save): y
```

## Advanced Features

### Smart Scheduling
- **Peak Hours Avoidance**: Schedule API-intensive work during off-peak hours for potential cost savings
- **Dependency Management**: Automatically handle episodes that reference previous episodes
- **Resource Optimization**: Balance API rate limits across multiple concurrent episodes

### Series Templates
- **Predefined Templates**: "AI Mysteries", "Science Unknowns", "Technology Limits"
- **Custom Templates**: Save successful series configurations for reuse
- **Community Templates**: Share series configurations with other creators

### Analytics & Insights
- **Performance Metrics**: Track improvement in quality and efficiency across episodes
- **Cost Analysis**: Identify cost optimization opportunities for future series
- **Content Insights**: Analysis of which topics and formats perform best

## Success Criteria

✅ **Automation**: 90% hands-off operation after initial approval
✅ **Cost Control**: Series stays within budget with accurate tracking
✅ **Quality Consistency**: All episodes meet or exceed quality standards
✅ **Failure Resilience**: Series can recover from individual episode failures
✅ **User Experience**: Clear progress visibility and control options

## Example Execution

```bash
# User starts series production
/produce-series .claude/series/ai_mysteries_s1.yaml

# System creates series session and begins
Series "AI Mysteries Season 1" initialized
├── 10 episodes planned
├── $50 budget allocated ($5 per episode)
├── Enhanced quality mode enabled
├── Sequential processing selected

Episode 1: "The Mystery of Neural Network Weights"
├── Research phase: ✅ Completed ($2.35)
├── User review: ✅ Approved
├── Production phase: ✅ Completed ($2.89)
├── Quality validation: ✅ Passed (0.91)
└── Episode 1 complete: $5.24 total

Episode 2: "Why Large Language Models Hallucinate"
├── Research phase: ✅ Completed ($2.41)
├── User review: ⏳ Awaiting approval
└── ...

Series Progress: 1/10 episodes complete, $5.24/$50 budget used
Estimated completion: 2 days, 14 hours
```

This comprehensive batch command enables efficient multi-episode production while maintaining the quality and cost control principles of our two-stream architecture.
