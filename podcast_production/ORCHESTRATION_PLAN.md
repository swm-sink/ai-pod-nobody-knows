# 🎯 ORCHESTRATION PLAN - August 2025 Migration Strategy

## 📅 Context
**Date**: August 31, 2025
**Models Available**:
- Claude: Opus 4.1 (orchestrator), Sonnet 4 (sub-agents)
- OpenAI: GPT-5
- Google: Gemini Pro 2.5, Gemini Flash 2.5
- Perplexity: Sonar models via MCP (PRIMARY, not fallback)

## 🏗️ Parallelization Strategy

### Why Parallelize?
- **Time Efficiency**: 16 agents × 30 min each = 8 hours sequential vs 2 hours parallel
- **Resource Utilization**: Multiple Claude sub-agents can work independently
- **Risk Mitigation**: Failures isolated to specific tasks
- **Cost Optimization**: Parallel work doesn't increase API costs

### Parallelization Matrix

| Task Category | Can Parallelize? | Dependencies | Priority |
|--------------|-----------------|--------------|----------|
| Documentation fixes | ✅ Yes | None | HIGH |
| Model version updates | ✅ Yes | None | CRITICAL |
| Agent migrations | ✅ Partial | Template patterns | HIGH |
| Cost tracking | ✅ Yes | None | HIGH |
| Main.py creation | ✅ Yes | None | HIGH |
| Pipeline integration | ❌ No | Agents complete | MEDIUM |
| E2E testing | ❌ No | Everything | LOW |

## 📋 Execution Phases

### 🚀 PHASE 1: Foundation (Parallel Batch 1)
**Time**: 30 minutes
**Parallel Agents**: 3

#### Sub-Agent 1: Documentation & Model Updates
**Purpose**: Fix all documentation issues and update model versions
**Tasks**:
- Fix AGENT_REGISTRY.md duplicate (line 370-371)
- Update TODO.MD to mark P2.5-009 complete
- Update all model references to August 2025 versions
- Update Perplexity to PRIMARY MCP (not fallback)

#### Sub-Agent 2: Question Generator Migration
**Purpose**: Migrate the question-generator agent
**Tasks**:
- Create `src/agents/question_generator.py`
- Implement LangGraph node pattern
- Add cost tracking ($0.10 budget)
- Create unit tests

#### Sub-Agent 3: Orchestration Foundation
**Purpose**: Create main entry point and state management
**Tasks**:
- Create `main.py` with CLI interface
- Implement `PodcastState` TypedDict
- Create basic workflow structure
- Add command-line argument parsing

### 🔄 SYNC POINT 1: Validation (5 minutes)
- Verify all documentation updated
- Confirm question-generator working
- Test main.py basic functionality

### 🚀 PHASE 2: Core Agents (Parallel Batch 2)
**Time**: 45 minutes
**Parallel Agents**: 4

#### Sub-Agent 4: Episode Planner
**Purpose**: Migrate episode-planner agent
**Budget**: $0.20
**Critical**: Structures entire episode flow

#### Sub-Agent 5: Script Writer
**Purpose**: Migrate script-writer agent
**Budget**: $1.75
**Critical**: Largest budget, core content creation

#### Sub-Agent 6: Brand Validator
**Purpose**: Migrate brand-validator agent
**Budget**: $0.25
**Critical**: Maintains "Nobody Knows" philosophy

#### Sub-Agent 7: Cost Tracking System
**Purpose**: Implement comprehensive cost tracking
**Tasks**:
- Create `src/core/cost_tracker.py`
- CSV logging to `logs/costs.csv`
- Per-agent budget enforcement
- Real-time cost aggregation

### 🔄 SYNC POINT 2: Integration Check (10 minutes)
- Test each agent individually
- Verify cost tracking working
- Check budget compliance

### 🔗 PHASE 3: Pipeline Integration (Sequential)
**Time**: 30 minutes
**Single Agent**: Pipeline builder

**Tasks**:
1. Connect research pipeline (4 agents)
2. Connect planning pipeline (2 agents)
3. Connect writing pipeline (2 agents)
4. Add conditional routing
5. Implement error recovery

### 🚀 PHASE 4: Audio & Validation (Parallel Batch 3)
**Time**: 30 minutes
**Parallel Agents**: 3

#### Sub-Agent 8: Audio Synthesizer
**Purpose**: Primary audio generation
**Budget**: $0.50
**Uses**: ElevenLabs direct API

#### Sub-Agent 9: Audio Validator
**Purpose**: Quality checks
**Budget**: $0.20

#### Sub-Agent 10: Evaluators
**Purpose**: Migrate Claude & Gemini evaluators
**Combined Budget**: $0.55

### 🧪 PHASE 5: Testing & Optimization
**Time**: 20 minutes
**Sequential Execution**

1. Run end-to-end test: "Why do we dream?"
2. Measure actual costs
3. Identify optimization opportunities
4. Implement cost-saving measures
5. Document results

## 🎬 Sub-Agent Deployment Commands

### Parallel Deployment Pattern
```python
# Deploy multiple agents simultaneously
agents = [
    {"name": "docs-updater", "task": "Update documentation"},
    {"name": "question-gen", "task": "Migrate question generator"},
    {"name": "main-creator", "task": "Create orchestration"}
]

# Each runs independently
for agent in agents:
    deploy_sub_agent(agent)
```

### Sequential Dependency Pattern
```python
# Pipeline must wait for agents
if all_agents_complete():
    build_pipeline()
else:
    wait_for_agents()
```

## 📊 Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Agents Migrated | 16/16 | Count completed |
| Cost per Episode | ≤ $5.51 | Track actual |
| Test Coverage | > 80% | pytest coverage |
| E2E Success | 100% | Full pipeline run |
| Documentation | Complete | All guides updated |

## 🚨 Risk Mitigation

### Parallel Execution Risks
- **Conflict**: Agents modifying same files → Use different directories
- **Dependencies**: Hidden coupling → Clear interfaces
- **Cost Overrun**: Multiple agents spending → Budget caps

### Mitigation Strategies
1. **File Locking**: Each agent works in isolated files
2. **Budget Guards**: Hard limits per agent
3. **Rollback Points**: Git commits after each phase
4. **Health Checks**: Validation at sync points

## 📈 Timeline

| Phase | Start | Duration | Agents | Status |
|-------|-------|----------|--------|--------|
| Planning | 0:00 | 10 min | 1 | ✅ |
| Phase 1 | 0:10 | 30 min | 3 | 🔄 |
| Sync 1 | 0:40 | 5 min | 1 | ⏳ |
| Phase 2 | 0:45 | 45 min | 4 | ⏳ |
| Sync 2 | 1:30 | 10 min | 1 | ⏳ |
| Phase 3 | 1:40 | 30 min | 1 | ⏳ |
| Phase 4 | 2:10 | 30 min | 3 | ⏳ |
| Phase 5 | 2:40 | 20 min | 1 | ⏳ |
| **TOTAL** | | **3 hours** | **14** | |

## 🎯 Next Action

Deploy Phase 1 parallel agents NOW:
1. Documentation & Model Updates
2. Question Generator Migration
3. Orchestration Foundation

---
**Updated**: August 31, 2025
**Orchestrator**: Claude Opus 4.1
**Strategy**: Maximum parallelization with sync points
