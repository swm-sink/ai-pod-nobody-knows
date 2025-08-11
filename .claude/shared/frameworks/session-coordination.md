# Session Coordination Framework

## Overview
This framework ensures seamless coordination between agents through shared session state, enabling the podcast production pipeline to maintain context, track progress, and handle failures gracefully.

## Session Structure

### Session Identification
```yaml
session_id: "ep_{number}_{YYYYMMDD}_{HHMM}"
episode_number: 1
topic: "consciousness_hard_problem"
complexity_level: 3
target_audience: "general"
created_at: "2024-08-11T14:30:00Z"
status: "in_progress"
```

## Session State Management

### State Transitions
```
INITIALIZED → RESEARCHING → WRITING → EVALUATING → SYNTHESIZING → COMPLETE
                    ↓            ↓           ↓            ↓
                  FAILED      FAILED      FAILED       FAILED
                    ↓            ↓           ↓            ↓
                  RETRY       RETRY       RETRY        RETRY
```

### Session State File
**Location**: `projects/nobody-knows/output/sessions/`
**Naming**: `ep{number}_session_{date}.json`

### State Structure
```json
{
  "session_id": "ep_001_20240811_1430",
  "episode": {
    "number": 1,
    "topic": "The Hard Problem of Consciousness",
    "complexity_target": 3,
    "duration_target": 27
  },
  
  "pipeline_state": {
    "current_stage": "writing",
    "completed_stages": ["research"],
    "pending_stages": ["evaluation", "synthesis"],
    "failed_attempts": 0,
    "retry_count": 0
  },
  
  "agent_outputs": {
    "research_coordinator": {
      "status": "complete",
      "output_file": "projects/nobody-knows/output/research/ep001_research_consciousness_20240811.md",
      "execution_time": 1680,
      "cost": 0.00,
      "quality_score": 0.92
    },
    "script_writer": {
      "status": "in_progress",
      "start_time": "2024-08-11T14:58:00Z",
      "estimated_completion": "2024-08-11T15:18:00Z"
    },
    "quality_evaluator": {
      "status": "pending"
    },
    "audio_synthesizer": {
      "status": "not_implemented"
    }
  },
  
  "quality_metrics": {
    "research_quality": 0.92,
    "script_quality": null,
    "overall_quality": null,
    "brand_consistency": null
  },
  
  "cost_tracking": {
    "research": 0.00,
    "writing": 0.00,
    "evaluation": 0.00,
    "synthesis": 0.00,
    "total": 0.00,
    "budget": 9.00,
    "within_budget": true
  },
  
  "timestamps": {
    "created": "2024-08-11T14:30:00Z",
    "last_updated": "2024-08-11T14:58:00Z",
    "research_completed": "2024-08-11T14:58:00Z",
    "writing_started": "2024-08-11T14:58:00Z"
  }
}
```

## Agent Coordination Protocol

### 1. Session Initialization
```python
def initialize_session(episode_number, topic, complexity_level):
    session = {
        "session_id": generate_session_id(episode_number),
        "episode": {
            "number": episode_number,
            "topic": topic,
            "complexity_target": complexity_level
        },
        "pipeline_state": {
            "current_stage": "initialized",
            "completed_stages": [],
            "pending_stages": ["research", "writing", "evaluation", "synthesis"]
        }
    }
    save_session_state(session)
    return session["session_id"]
```

### 2. Agent Handoff Protocol

#### Research → Script Writer
```yaml
handoff:
  from: research_coordinator
  to: script_writer
  data:
    research_package: "path/to/research.md"
    complexity_assessment: 3
    key_narratives: ["list", "of", "narratives"]
    confidence_scores: {...}
  validation:
    package_complete: true
    quality_threshold_met: true
    ready_for_script: true
```

#### Script Writer → Quality Evaluator
```yaml
handoff:
  from: script_writer
  to: quality_evaluator
  data:
    script_file: "path/to/script.md"
    word_count: 4000
    estimated_duration: 27.5
    complexity_level: 3
  validation:
    script_complete: true
    format_valid: true
    ready_for_evaluation: true
```

#### Quality Evaluator → Audio Synthesizer
```yaml
handoff:
  from: quality_evaluator
  to: audio_synthesizer
  data:
    validated_script: "path/to/script.md"
    quality_report: "path/to/quality.json"
    approval_status: "PASS"
  validation:
    quality_gates_passed: true
    audio_ready: true
    synthesis_approved: true
```

### 3. State Update Mechanism

Each agent must update session state:
```python
def update_session_state(session_id, agent_name, update):
    session = load_session_state(session_id)
    
    # Update agent-specific data
    session["agent_outputs"][agent_name] = update
    
    # Update pipeline state
    if update["status"] == "complete":
        session["pipeline_state"]["completed_stages"].append(agent_name)
        session["pipeline_state"]["current_stage"] = get_next_stage(agent_name)
    
    # Update timestamps
    session["timestamps"]["last_updated"] = now()
    
    # Update cost tracking
    session["cost_tracking"][agent_name] = update.get("cost", 0)
    session["cost_tracking"]["total"] = sum_costs(session)
    
    save_session_state(session)
```

## Error Handling

### Failure Recovery
```python
def handle_agent_failure(session_id, agent_name, error):
    session = load_session_state(session_id)
    
    # Record failure
    session["agent_outputs"][agent_name]["status"] = "failed"
    session["agent_outputs"][agent_name]["error"] = str(error)
    session["pipeline_state"]["failed_attempts"] += 1
    
    # Determine retry strategy
    if session["pipeline_state"]["retry_count"] < 3:
        session["pipeline_state"]["retry_count"] += 1
        retry_agent(session_id, agent_name)
    else:
        escalate_failure(session_id, agent_name)
    
    save_session_state(session)
```

### Quality Gate Failures
```python
def handle_quality_failure(session_id, quality_report):
    session = load_session_state(session_id)
    
    # Determine failure type
    failures = quality_report["failures"]
    
    if "brand_consistency" in failures:
        # Return to script_writer with specific feedback
        session["pipeline_state"]["current_stage"] = "writing"
        session["feedback"] = quality_report["recommendations"]
    
    elif "technical" in failures:
        # Return to script_writer for duration adjustment
        session["pipeline_state"]["current_stage"] = "writing"
        session["adjustments_needed"] = quality_report["technical_fixes"]
    
    save_session_state(session)
```

## Session Monitoring

### Progress Tracking
```python
def get_session_progress(session_id):
    session = load_session_state(session_id)
    
    total_stages = 4
    completed = len(session["pipeline_state"]["completed_stages"])
    
    return {
        "progress_percentage": (completed / total_stages) * 100,
        "current_stage": session["pipeline_state"]["current_stage"],
        "estimated_completion": estimate_completion_time(session),
        "cost_so_far": session["cost_tracking"]["total"],
        "quality_status": session["quality_metrics"]
    }
```

### Session Dashboard Data
```json
{
  "active_sessions": [
    {
      "session_id": "ep_001_20240811_1430",
      "episode": 1,
      "stage": "writing",
      "progress": 50,
      "health": "healthy"
    }
  ],
  "completed_today": 3,
  "failed_today": 0,
  "average_time": 95,
  "average_cost": 4.50,
  "quality_average": 0.88
}
```

## Implementation in Agents

### For All Agents
```python
# At agent start
session = load_session_state(session_id)
validate_ready_for_stage(session, agent_name)

# During processing
update_session_progress(session_id, agent_name, "in_progress")

# On completion
update_session_state(session_id, agent_name, {
    "status": "complete",
    "output_file": output_path,
    "cost": actual_cost,
    "quality_score": quality_metrics
})

# On failure
handle_agent_failure(session_id, agent_name, error)
```

## Session Commands

### Initialize Session
```bash
claude-code session init --episode 1 --topic "consciousness" --complexity 3
```

### Check Status
```bash
claude-code session status ep_001_20240811_1430
```

### Resume Failed Session
```bash
claude-code session resume ep_001_20240811_1430
```

### View Dashboard
```bash
claude-code session dashboard
```

---

*This framework ensures reliable, traceable, and recoverable podcast production through comprehensive session state management.*