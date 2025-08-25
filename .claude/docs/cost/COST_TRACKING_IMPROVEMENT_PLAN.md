# Cost Tracking Improvement Plan

## Phase 1: Schema Standardization (Day 1)

### Step 1.1: Define Standard Cost Schema
```json
{
  "cost_tracking": {
    "research_phase": {
      "perplexity_deep_research": 0.25,
      "perplexity_reasoning": 0.05,
      "agent_coordination": 0.02,
      "subtotal": 0.32
    },
    "production_phase": {
      "claude_script_writing": 1.50,
      "claude_quality_eval": 0.75,
      "gemini_quality_eval": 0.00,
      "elevenlabs_synthesis": 6.30,
      "agent_coordination": 0.10,
      "subtotal": 8.65
    },
    "total_episode_cost": 8.97,
    "cost_savings": {
      "checkpoint_reuse": 2.50,
      "cached_research": 0.96
    },
    "final_cost": 5.51
  }
}
```

### Step 1.2: Update Pipeline Status Structure
Location: All checkpoint and status JSON files
```json
{
  "session_id": "ep_XXX_YYYYMMDD",
  "cost_tracking": {
    // Standard schema from 1.1
  },
  "legacy_fields": {
    "total_savings": "DEPRECATED - see cost_tracking.cost_savings",
    "remaining_cost": "DEPRECATED - see cost_tracking.final_cost"
  }
}
```

## Phase 2: Agent Updates (Day 2-3)

### Step 2.1: Update Cost Tracking in Agents
For each agent, add cost tracking:

```python
# Pseudo-code for agent cost tracking
cost_data = {
    "operation": "script_writing",
    "model": "claude-3-opus",
    "input_tokens": token_count,
    "output_tokens": response_tokens,
    "rate_per_1k": 0.015,
    "operation_cost": calculated_cost
}

# Save to checkpoint
checkpoint["cost_tracking"]["production_phase"]["claude_script_writing"] += operation_cost
```

### Step 2.2: Update Research Orchestrator
```yaml
Location: .claude/agents/research-discovery.md
Add after line 92:

## Cost Tracking Integration

Track costs at each research stage:
```
```json
{
  "deep_research_cost": {
    "searches_performed": 12,
    "search_cost": 0.06,  // $5 per 1k searches
    "output_tokens": 1500,
    "output_cost": 0.12,  // $8 per 1M tokens
    "citations_cost": 0.03,
    "reasoning_cost": 0.04,
    "stage_total": 0.25
  }
}
```

### Step 2.3: Update Production Orchestrator
Similar cost tracking for production phase with detailed breakdowns

## Phase 3: Reporting Infrastructure (Day 4)

### Step 3.1: Create Cost Report Generator
```bash
#!/bin/bash
# generate_cost_report.sh

echo "Episode Cost Analysis Report"
echo "============================"

for session in $(find sessions -name "pipeline_status.json"); do
    echo "Session: $(dirname $session)"

    # Extract costs using jq
    total_cost=$(jq -r '.cost_tracking.total_episode_cost // .remaining_cost' "$session")
    savings=$(jq -r '.cost_tracking.cost_savings // .total_savings' "$session")

    echo "Total Cost: $${total_cost}"
    echo "Savings: $${savings}"
    echo "---"
done
```

### Step 3.2: Create Real-time Cost Monitor
```python
# cost_monitor.py
import json
from pathlib import Path

class CostMonitor:
    def __init__(self, session_path):
        self.session_path = Path(session_path)
        self.cost_data = {"research_phase": {}, "production_phase": {}}

    def track_operation(self, phase, operation, cost):
        """Track individual operation costs"""
        if phase not in self.cost_data:
            self.cost_data[phase] = {}

        self.cost_data[phase][operation] = self.cost_data[phase].get(operation, 0) + cost
        self.save_status()

    def get_total_cost(self):
        """Calculate total episode cost"""
        research_total = sum(self.cost_data["research_phase"].values())
        production_total = sum(self.cost_data["production_phase"].values())
        return research_total + production_total

    def save_status(self):
        """Save current cost status"""
        status = {
            "cost_tracking": self.cost_data,
            "total_episode_cost": self.get_total_cost(),
            "timestamp": datetime.now().isoformat()
        }

        with open(self.session_path / "cost_status.json", "w") as f:
            json.dump(status, f, indent=2)
```

## Phase 4: Validation & Migration (Day 5)

### Step 4.1: Migrate Existing Sessions
```python
# migrate_cost_data.py
def migrate_session(session_path):
    """Migrate old cost format to new standard"""
    status_file = session_path / "pipeline_status.json"

    if status_file.exists():
        with open(status_file) as f:
            old_data = json.load(f)

        # Convert old format
        new_data = {
            **old_data,
            "cost_tracking": {
                "total_episode_cost": float(old_data.get("remaining_cost", 0)),
                "cost_savings": {
                    "total": float(old_data.get("total_savings", 0))
                }
            }
        }

        # Save migrated data
        with open(status_file, "w") as f:
            json.dump(new_data, f, indent=2)
```

### Step 4.2: Validate Cost Achievement
Create validation report showing:
- Average cost per episode
- Cost breakdown by phase
- Savings from optimizations
- Verification of $5.51 achievement

## Phase 5: Documentation & Training (Day 6)

### Step 5.1: Update Documentation
- Add cost tracking guide to .claude/docs/
- Update README with cost monitoring instructions
- Create cost optimization best practices

### Step 5.2: Add Cost Dashboards
- Create simple HTML dashboard for cost visualization
- Add cost trends over time
- Show optimization opportunities

## Success Criteria
- [ ] All sessions use standard cost schema
- [ ] Real-time cost tracking implemented
- [ ] Historical data migrated
- [ ] $5.51 per episode verified with data
- [ ] Cost monitoring tools operational
