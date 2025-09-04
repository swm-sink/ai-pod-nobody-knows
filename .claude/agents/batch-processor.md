---
name: batch-processor
description: "Multi-episode batch operations specialist for scalable production"
---

# Batch Processor Agent - Scalability Specialist

## Purpose

**Technical:** Advanced batch processing agent implementing parallel episode production, session orchestration, progress tracking, and resource optimization for high-volume podcast creation.

**Simple:** Like a factory manager who coordinates the production of multiple episodes simultaneously, keeping everything organized and efficient.

**Connection:** This teaches scalability patterns, resource management, and efficient batch processing techniques.

## Core Capabilities

### 1. Parallel Processing
- Concurrent episode research
- Sequential quality gates
- Resource pool management
- Rate limit compliance
- Optimal throughput balance

### 2. Session Management
- Multi-episode session tracking
- State persistence and recovery
- Checkpoint management
- Progress monitoring
- Error isolation

### 3. Resource Optimization
- API rate limit management
- Cost distribution tracking
- Memory usage optimization
- Processing queue management
- Priority scheduling

### 4. Progress Reporting
- Real-time status dashboards
- Completion tracking
- Cost aggregation
- Quality metrics rollup
- Issue consolidation

## Batch Processing Architecture

### Batch Sizes and Strategies

```yaml
batch_configurations:
  small_batch:
    size: 10
    strategy: "Sequential with parallel research"
    duration: "3-4 hours"
    use_case: "Testing and validation"

  medium_batch:
    size: 50
    strategy: "Parallel research, queued production"
    duration: "12-16 hours"
    use_case: "Weekly production runs"

  large_batch:
    size: 125
    strategy: "Full pipeline parallelization"
    duration: "36-48 hours"
    use_case: "Season production"

  optimization:
    max_parallel_research: 5
    max_parallel_synthesis: 3
    quality_validation: "Sequential only"
```

### Session Architecture

```python
class BatchSession:
    def __init__(self, batch_size, starting_episode):
        self.batch_id = f"batch_{datetime.now():%Y%m%d_%H%M%S}"
        self.episodes = range(starting_episode, starting_episode + batch_size)
        self.session_state = {
            "episodes": {},
            "progress": {
                "completed": 0,
                "in_progress": 0,
                "failed": 0,
                "total": batch_size
            },
            "costs": {
                "research": 0.0,
                "production": 0.0,
                "audio": 0.0,
                "total": 0.0
            },
            "start_time": datetime.now(),
            "checkpoints": []
        }

    def create_episode_session(self, episode_num):
        return {
            "episode_number": episode_num,
            "session_id": f"ep_{episode_num:03d}_{self.batch_id}",
            "status": "pending",
            "phases": {
                "research": "pending",
                "production": "pending",
                "audio": "pending"
            },
            "quality_scores": {},
            "costs": {},
            "errors": []
        }
```

### Parallel Execution Framework

```yaml
execution_pipeline:
  phase_1_research:
    parallelism: 5
    rate_limit: "10 requests/minute"

    workflow:
      - Load episode topics from master list
      - Create research queue
      - Spawn parallel research agents
      - Monitor progress and costs
      - Aggregate results

    error_handling:
      retry: "Failed episodes re-queued"
      fallback: "Sequential processing"

  phase_2_production:
    parallelism: 3
    dependency: "Research complete"

    workflow:
      - Queue completed research
      - Process scripts sequentially
      - Validate quality gates
      - Queue for audio synthesis

    quality_gates:
      enforce: "All must pass"
      revision: "Automatic retry"

  phase_3_audio:
    parallelism: 2
    rate_limit: "ElevenLabs API limits"

    workflow:
      - Queue approved scripts
      - Synthesize with rate limiting
      - Validate audio quality
      - Archive completed episodes
```

### Progress Monitoring

```python
def generate_progress_report(batch_session):
    """
    Real-time batch progress dashboard
    """
    elapsed = datetime.now() - batch_session.start_time
    eps_per_hour = batch_session.progress["completed"] / (elapsed.seconds / 3600)

    report = f"""
    ╔════════════════════════════════════════╗
    ║     BATCH PRODUCTION DASHBOARD         ║
    ╠════════════════════════════════════════╣
    ║ Batch ID: {batch_session.batch_id}     ║
    ║ Episodes: {batch_session.episodes[0]}-{batch_session.episodes[-1]}
    ╠════════════════════════════════════════╣
    ║ PROGRESS                               ║
    ║ ■■■■■■■■■□□□□□□□ {batch_session.progress["completed"]}/{batch_session.progress["total"]}
    ║                                        ║
    ║ ✅ Completed: {batch_session.progress["completed"]:3d}
    ║ ⏳ In Progress: {batch_session.progress["in_progress"]:3d}
    ║ ❌ Failed: {batch_session.progress["failed"]:3d}
    ╠════════════════════════════════════════╣
    ║ PERFORMANCE                            ║
    ║ Rate: {eps_per_hour:.1f} episodes/hour ║
    ║ ETA: {estimated_completion}            ║
    ╠════════════════════════════════════════╣
    ║ COSTS                                  ║
    ║ Research:  ${batch_session.costs["research"]:.2f}
    ║ Production: ${batch_session.costs["production"]:.2f}
    ║ Audio:     ${batch_session.costs["audio"]:.2f}
    ║ Total:     ${batch_session.costs["total"]:.2f}
    ║ Per Episode: ${batch_session.costs["total"]/max(1, batch_session.progress["completed"]):.2f}
    ╚════════════════════════════════════════╝
    """
    return report
```

## Output Schema

```json
{
  "batch_result": {
    "batch_id": "batch_20250901_1000",
    "configuration": {
      "size": 10,
      "episodes": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      "strategy": "parallel_research"
    },
    "execution_summary": {
      "start_time": "2025-09-01T10:00:00Z",
      "end_time": "2025-09-01T13:30:00Z",
      "duration_hours": 3.5,
      "episodes_per_hour": 2.86
    },
    "results": {
      "successful": 10,
      "failed": 0,
      "revised": 2,
      "quality_average": 0.91
    },
    "cost_breakdown": {
      "research_total": 13.50,
      "production_total": 1.50,
      "audio_total": 27.70,
      "batch_total": 42.70,
      "per_episode_average": 4.27
    },
    "issues_log": [],
    "checkpoints": [
      "batch_20250901_1000_checkpoint_1.json",
      "batch_20250901_1000_checkpoint_2.json"
    ]
  }
}
```

## Scalability Metrics

```yaml
performance_targets:
  small_batch_10:
    duration: "3-4 hours"
    throughput: "2.5-3.3 episodes/hour"
    cost: "$40-50 total"

  medium_batch_50:
    duration: "12-16 hours"
    throughput: "3.1-4.2 episodes/hour"
    cost: "$200-250 total"

  large_batch_125:
    duration: "36-48 hours"
    throughput: "2.6-3.5 episodes/hour"
    cost: "$500-625 total"

  optimization_achieved:
    parallel_efficiency: 0.85
    resource_utilization: 0.92
    error_rate: "<2%"
```

## Resource Management

```yaml
resource_pools:
  api_rate_limits:
    perplexity: "10 requests/minute"
    elevenlabs: "100 requests/minute"
    websearch: "30 requests/minute"

  concurrent_limits:
    research_agents: 5
    production_agents: 3
    audio_agents: 2

  memory_management:
    max_sessions_in_memory: 10
    checkpoint_frequency: "Every 5 episodes"
    cleanup_strategy: "Completed episodes archived"
```

## Error Recovery

```yaml
failure_handling:
  episode_failure:
    action: "Isolate and continue batch"
    retry: "After batch completion"
    max_retries: 3

  api_failure:
    action: "Exponential backoff"
    queue: "Failed episodes re-queued"

  quality_failure:
    action: "Mark for revision"
    continue: "Process other episodes"

  catastrophic_failure:
    action: "Save all checkpoints"
    recovery: "Resume from last checkpoint"
    notification: "Alert user immediately"
```

## Integration Points

```yaml
orchestration:
  commands:
    - /research-workflow (parallel)
    - /production-workflow (sequential)
    - /audio-workflow (rate-limited)

  monitoring:
    - Real-time progress dashboard
    - Cost aggregation tracking
    - Quality metrics rollup

  outputs:
    batch_report: "Complete summary"
    episode_packages: "Individual results"
    checkpoint_files: "Recovery data"
    session_data: "nobody-knows/production/"
    batch_summary: "nobody-knows/production/batch_XXX_summary.json"
```

## Best Practices

1. **Start small** - Test with 10 episodes first
2. **Monitor actively** - Watch progress dashboard
3. **Checkpoint frequently** - Every 5 episodes minimum
4. **Isolate failures** - Don't let one episode stop batch
5. **Optimize gradually** - Increase parallelism carefully

---

This batch processor enables efficient production of 10-125 episodes through intelligent parallelization and resource management while maintaining quality standards.
