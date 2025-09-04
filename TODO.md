# 📋 TODO.MD - AI Podcast Production System Development Plan

**Status**: READY FOR TESTING  
**Timeline**: 8-Week Sprint (Realistic)  
**Last Updated**: 2025-09-02  
**Purpose**: Single Source of Truth (SSOT) for development priorities and progress

---

## 🎯 Project Mission

Transform a well-architected but unproven system into a production-ready AI podcast generator that:
- Produces 28-minute episodes for $3-5 (validated)
- Maintains 90%+ quality scores
- Scales to 10-125 episodes efficiently
- Follows Claude Code native patterns
- **ENFORCES ZERO TRAINING DATA POLICY** - All content from real-time research only

---

## ✅ Foundation Complete - Ready for Testing

**MAJOR DISCOVERY**: After deep research, this system follows **correct Claude Code native patterns**!

### **✅ Completed (Days 1-3)**
1. **✅ Directory Structure**: Clean organization (content/production/output)
2. **✅ State Management**: ProductionStateManager implemented and tested
3. **✅ Agent Optimization**: All 10 agents updated with content directory references
4. **✅ Command Integration**: All 5 commands updated with correct file paths
5. **✅ MCP Verification**: perplexity-ask + elevenlabs tools confirmed available
6. **✅ Quality Configuration**: Enhanced quality_gates.json with detailed metrics
7. **✅ Zero Training Data Policy**: Enforced throughout system

### **🎯 Current Focus**
- Test individual agents with real MCP tool usage
- Validate file handoffs between agents
- Document actual costs and performance
- Verify complete workflow execution

---

## 📁 Directory Restructure Plan

### Previous Structure (REMOVED):
```
├── episodes/          # Removed - was confusing
├── projects/nobody-knows/  # Moved to nobody-knows/content/
└── sessions/          # Removed - replaced with nobody-knows/production/
```

### New (Clear) Structure:
```
├── nobody-knows/      # Complete podcast production system
│   ├── content/       # Source material & series planning
│   │   ├── series-bible/   # Brand philosophy & teaching methodology
│   │   ├── reference-scripts/ # 10 example episodes
│   │   ├── config/         # Quality gates & project configuration
│   │   └── episode-template.json
│   ├── production/    # Active episode production
│   │   ├── state.json      # Global production state
│   │   ├── state_manager.py # State management system
│   │   └── ep_XXX_*/       # Per-episode working directories
│   └── output/        # Final deliverables
│       ├── episodes/       # Published MP3s
│       ├── transcripts/    # Final scripts
│       └── metrics/        # Quality reports
└── .claude/           # Claude Code configuration (project root)
```

---

## 🛠️ Development Phases

### Phase 1: Foundation & Testing (Week 1 - COMPLETED!) 
**Goal**: Establish working environment and validate core components

#### Week 1 Checklist:
- [x] **Day 1**: Restructure directories per plan above ✅
- [x] **Day 2**: Implement state management system ✅
  ```python
  # Core state manager with persistence
  class ProductionStateManager:
      - create_episode_session() ✅
      - update_phase_status() ✅
      - save_checkpoint() ✅
      - recover_from_error() ✅
  ```
- [x] **Day 3**: Verify MCP connections and Claude Code native patterns ✅
  - [x] Confirmed perplexity-ask MCP available ✅
  - [x] Confirmed elevenlabs MCP available (24 tools) ✅
  - [x] Researched Claude Code native execution patterns ✅
- [x] **Day 4**: System optimization and configuration ✅
  - [x] Fixed all directory references in agents and commands ✅
  - [x] Added content directory references to agents ✅
  - [x] Created quality_gates.json configuration ✅
  - [x] Verified system follows Claude Code native patterns ✅

#### Week 1 Success Criteria: ✅ ALL ACHIEVED
- ✓ Directory structure optimized and clean
- ✓ State management system functional
- ✓ Agent and command integration verified
- ✓ MCP tools confirmed available
- ✓ System ready for production testing

### Phase 2: VALIDATION & TESTING (Days 5-7)
**Goal**: Validate Claude Code native execution with corrected understanding

#### **🔍 Research Complete**: 5 Perplexity MCP searches revealed:
- ✅ Our system follows **correct Claude Code native patterns**
- ✅ Agent markdown files ARE executable contracts
- ✅ "Use the X agent" pattern works as designed
- ✅ Multi-agent workflows supported through orchestrator architecture
- ✅ File-based handoffs are standard Claude Code practice

#### **Quick Validation Plan (30-45 minutes total)**:
- [ ] **Step 1**: Verify available MCP tool names (5 min)
  - [ ] "List all available MCP tools and their exact names"
  - [ ] Update agent tool references if needed
  
- [ ] **Step 2**: Test directory creation (5 min)
  - [ ] "Create nobody-knows/production/test_episode/research/ directory structure"
  - [ ] Verify file save operations work
  
- [ ] **Step 3**: Test researcher agent (10 min)
  - [ ] Use the researcher agent: "CRISPR gene editing 2024-2025"
  - [ ] Verify Perplexity MCP usage and zero training data compliance
  
- [ ] **Step 4**: Test file handoff (10 min)
  - [ ] Save research as JSON file
  - [ ] Use fact-checker agent to read and validate the JSON
  
- [ ] **Step 5**: Document results (10 min)
  - [ ] Record actual costs, timing, and functionality
  - [ ] Update system status based on findings

#### Success Criteria:
- ✓ MCP tools callable with correct names
- ✓ Agents execute their markdown instructions
- ✓ File operations work (save/read JSON)
- ✓ Zero training data policy enforced

---

### Phase 2: Production Testing (Weeks 3-4)
**Goal**: Produce first real episodes and validate all claims

#### Week 3: First Episodes (ZERO TRAINING DATA)
- [ ] **Episode 1**: "The Science of Sleep and Dreams"
  - [ ] Complete research phase using Perplexity MCP only (<$1.50)
  - [ ] Verify ALL sources are 2024-2025 dated
  - [ ] Script production with quality gates (no training data)
  - [ ] Audio synthesis (target 28 min)
  - [ ] STT validation (>90% accuracy)
  - [ ] Document actual costs
  - [ ] Audit: Confirm zero training data used
  
- [ ] **Episode 2**: "Quantum Computing Explained"
  - [ ] Optimize based on Episode 1 learnings
  - [ ] Test cost reduction strategies
  - [ ] Validate quality consistency

#### Week 3 Success Criteria:
- ✓ 2 complete episodes produced
- ✓ Actual costs documented
- ✓ Quality scores validated
- ✓ 28-minute target achieved

#### Week 4: Quality & Optimization
- [ ] **Quality System Testing**:
  - [ ] Claude evaluation (55% weight)
  - [ ] Gemini evaluation (45% weight)  
  - [ ] Perplexity fact-checking
  - [ ] Consensus calculation verified
  
- [ ] **Cost Optimization**:
  - [ ] Research query efficiency
  - [ ] Single-call audio synthesis
  - [ ] Token usage optimization
  
- [ ] **Performance Metrics**:
  - [ ] Time per episode: <30 minutes
  - [ ] Cost per episode: $3-5 confirmed
  - [ ] Quality consistency: >85%

---

### Phase 3: Scaling (Weeks 5-6)
**Goal**: Implement batch processing and monitoring

#### Week 5: Batch Processing
- [ ] **Batch System Implementation**:
  ```python
  # Batch processor with parallelization
  - Parallel research (max 5)
  - Sequential script production
  - Rate-limited audio synthesis
  - Progress tracking dashboard
  ```
- [ ] **Test Batches**:
  - [ ] 5-episode batch
  - [ ] 10-episode batch
  - [ ] Performance metrics

#### Week 6: Monitoring & Dashboard
- [ ] **Production Dashboard**:
  ```
  ╔═══════════════════════════════╗
  ║   AI PODCAST DASHBOARD        ║
  ╠═══════════════════════════════╣
  ║ Active: 3  Complete: 7        ║
  ║ Total Cost: $42.50            ║
  ║ Avg Cost: $4.25/episode       ║
  ║ Success Rate: 90%             ║
  ╚═══════════════════════════════╝
  ```
- [ ] **Alerts & Notifications**:
  - [ ] Budget warnings (80%, 90%)
  - [ ] Quality failures
  - [ ] API errors

---

### Phase 4: Production Ready (Weeks 7-8)
**Goal**: Finalize system and prepare for handoff

#### Week 7: Documentation & Testing
- [ ] **Complete Documentation Suite**:
  - [ ] API Guide with real examples
  - [ ] Troubleshooting guide
  - [ ] Cost optimization guide
  - [ ] Architecture documentation
  
- [ ] **Failure Testing**:
  - [ ] API failures
  - [ ] Budget overruns
  - [ ] Quality rejections
  - [ ] State corruption

#### Week 8: Production Handoff
- [ ] **Production Checklist**:
  - [ ] 25+ episodes produced
  - [ ] Costs validated <$5/episode
  - [ ] Quality consistently >85%
  - [ ] Batch processing proven
  
- [ ] **Deliverables**:
  - [ ] Working system with state management
  - [ ] Proven cost/quality metrics
  - [ ] Complete documentation
  - [ ] Monitoring dashboard

---

## 📊 Key Metrics to Track

### Per Episode:
- **Research Phase**: Time, cost, sources found
- **Script Phase**: Time, cost, quality scores  
- **Audio Phase**: Time, cost, accuracy, duration
- **Total**: Time (<30 min), Cost (<$5), Quality (>85%)

### System Health:
- **API Success Rate**: >95%
- **Error Recovery Rate**: >90%
- **Cost Predictability**: ±10%
- **Quality Consistency**: <5% variance

---

## 🚦 Go/No-Go Decision Points

1. **After Week 2**: Can we produce a single episode?
2. **After Week 4**: Is cost <$7 and quality >80%?
3. **After Week 6**: Can we scale to 10 episodes?
4. **After Week 8**: Ready for production use?

---

## 💡 Implementation Notes

### State Management Pattern:
```python
# Every operation updates state
state_manager.start_phase("research")
try:
    result = agent_operation()
    state_manager.complete_phase("research", result, cost)
except Exception as e:
    state_manager.fail_phase("research", error=e)
    checkpoint = state_manager.get_last_checkpoint()
    # Retry from checkpoint
```

### Cost Tracking Pattern:
```python
# Before any API call
estimated_cost = estimate_api_cost(operation)
if current_total + estimated_cost > budget:
    raise BudgetExceededError()

# After API call
actual_cost = calculate_actual_cost(response)
cost_tracker.log(operation, actual_cost)
state_manager.update_cost(actual_cost)
```

### Quality Gate Pattern:
```python
# Multi-evaluator consensus
scores = {
    "claude": claude_evaluate(script),     # 0.92
    "gemini": gemini_evaluate(script),     # 0.88
    "facts": perplexity_verify(script)     # 0.95
}
consensus = calculate_weighted_consensus(scores)
if consensus < 0.85:
    return require_revision(script, scores)
```

---

## 🎯 Definition of Success

The system is considered production-ready when:

1. **Proven Production**: 25+ episodes produced successfully
2. **Validated Costs**: Consistent $3-5 per episode
3. **Quality Standards**: All episodes >85% quality score
4. **Reliability**: <5% failure rate with recovery
5. **Performance**: <30 minutes per episode
6. **Scale**: 10-episode batches work smoothly
7. **Documentation**: Complete and accurate

---

## 📝 Daily Progress Tracking

Use this format for daily updates:

```markdown
### 2025-09-01 (Day 1)
- [x] Directory restructure completed
- [x] State management implemented
- [ ] MCP testing (blocked by API keys)
- **Blockers**: Need production API keys
- **Tomorrow**: Test individual agents
```

---

**Remember**: This is a living document. Update daily with progress, blockers, and learnings. The goal is honest tracking of what actually works, not what we hope will work.

*Reference this file from CLAUDE.md for current development priorities.*
