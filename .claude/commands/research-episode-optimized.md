# /research-episode-optimized - Memory-Optimized 4-Stage Research Pipeline

Ultra-sophisticated research orchestration using memory-optimized micro-agents with external state persistence and comprehensive quality assurance.

## Command Usage
```
/research-episode-optimized [EPISODE_TOPIC]
```

**Example:**
```
/research-episode-optimized "Quantum Entanglement and the Nature of Reality"
```

## System Architecture - Memory Optimized

**Technical:** Advanced 4-stage research pipeline implementing micro-agent architecture with external state persistence, streaming memory patterns, and sequential processing to prevent heap exhaustion while maintaining comprehensive research quality.

**Simple:** Like having a specialized research team where each expert focuses on their one area, passes their work to the next person via organized files, and never overloads the system's memory.

**Connection:** This teaches production-grade system architecture, memory management, and sophisticated orchestration patterns essential for scalable AI systems.

## Pipeline Architecture

### Stage Sequence & Memory Management
```
Episode Topic Input
        ↓
    [DISCOVERY] → discovery-results.json → Memory Released
        ↓
    [DEEP-DIVE] → deep-research.json → Memory Released
        ↓
   [VALIDATION] → validated-research.json → Memory Released
        ↓
    [SYNTHESIS] → complete-research-package.json → Memory Released
        ↓
    Production-Ready Research Package
```

## Execution Protocol

### Session Initialization
1. Create episode session directory: `sessions/ep_[NUMBER]_optimized_[TIMESTAMP]/`
2. Initialize state tracking: `pipeline_status.json`
3. Set up memory monitoring and budget tracking
4. Prepare error recovery checkpoints

### Stage 1: Strategic Discovery
```bash
# Execute research-discovery micro-agent
Use Task tool to delegate to research-discovery agent with:
- Episode topic: $ARGUMENTS
- Session ID: ep_[NUMBER]_optimized_[TIMESTAMP]
- Budget allocation: $0.50
- Output target: discovery-results.json

# Memory Management
- Agent operates statelessly with minimal context
- Results saved to external JSON file
- Memory released immediately after completion
- Heap usage target: <400MB
```

**Discovery Success Criteria:**
- ✅ Topic landscape mapped with major themes
- ✅ 5+ expert authorities identified and verified
- ✅ Source framework established across all categories
- ✅ Research priorities defined for deep-dive stage
- ✅ discovery-results.json saved successfully

### Stage 2: Comprehensive Deep-Dive
```bash
# Execute research-deep-dive micro-agent
Use Task tool to delegate to research-deep-dive agent with:
- Input: Load discovery-results.json from session directory
- Focus areas: Priority themes from discovery stage
- Budget allocation: $1.00
- Output target: deep-research.json

# Memory Management
- Reads discovery results from external file (not memory)
- Processes research in streaming batches
- Saves comprehensive findings to external JSON
- Memory released immediately after completion
- Heap usage target: <600MB
```

**Deep-Dive Success Criteria:**
- ✅ 15+ verified expert quotes with full attribution
- ✅ Comprehensive content across all priority themes
- ✅ Technical concepts explained with appropriate depth
- ✅ Historical context and future implications covered
- ✅ deep-research.json saved successfully

### Stage 3: Comprehensive Validation
```bash
# Execute research-validation micro-agent
Use Task tool to delegate to research-validation agent with:
- Input: Load deep-research.json from session directory
- Validation focus: Fact-checking and credibility assessment
- Budget allocation: $0.35
- Output target: validated-research.json

# Memory Management
- Loads deep research in validation segments
- Processes fact-checking in streaming batches
- Saves validation results incrementally
- Memory released immediately after completion
- Heap usage target: <500MB
```

**Validation Success Criteria:**
- ✅ 90%+ fact verification rate achieved
- ✅ All expert quotes attribution validated
- ✅ Multi-source triangulation completed
- ✅ Comprehensive credibility scoring assigned
- ✅ validated-research.json saved successfully

### Stage 4: Master Synthesis
```bash
# Execute research-synthesis micro-agent
Use Task tool to delegate to research-synthesis agent with:
- Input: Load validated-research.json from session directory
- Synthesis focus: Narrative optimization and brand integration
- Budget allocation: $0.15
- Output target: complete-research-package.json

# Memory Management
- Loads validated research in synthesis segments
- Builds narrative architecture incrementally
- Saves final package with production guidance
- Memory released immediately after completion
- Heap usage target: <600MB
```

**Synthesis Success Criteria:**
- ✅ Masterful narrative architecture optimized for engagement
- ✅ Seamless brand voice integration with intellectual humility
- ✅ Cross-episode intelligence with cumulative learning
- ✅ Production-ready package with script writing guidance
- ✅ complete-research-package.json saved successfully

## Quality Assurance & Monitoring

### Memory Usage Monitoring
```json
{
  "memory_tracking": {
    "stage_1_peak_usage": "<400MB",
    "stage_2_peak_usage": "<600MB",
    "stage_3_peak_usage": "<500MB",
    "stage_4_peak_usage": "<600MB",
    "total_pipeline_peak": "<600MB (sequential, not cumulative)",
    "heap_exhaustion_prevention": "external_state_persistence"
  }
}
```

### Cost Optimization
```json
{
  "budget_allocation": {
    "discovery_stage": "$0.50 (25%)",
    "deep_dive_stage": "$1.00 (50%)",
    "validation_stage": "$0.35 (17.5%)",
    "synthesis_stage": "$0.15 (7.5%)",
    "total_budget": "$2.00",
    "optimization_target": "85-95% utilization"
  }
}
```

### Error Recovery Protocol
```bash
# Stage Failure Recovery
if [STAGE_FAILS]; then
  - Save current progress to checkpoint
  - Analyze failure cause (memory/API/validation)
  - Implement appropriate recovery strategy
  - Resume from last successful checkpoint
  - Maintain budget tracking accuracy
fi

# Memory Pressure Recovery
if [HEAP_USAGE > 1GB]; then
  - Force garbage collection
  - Clear temporary variables
  - Restart stage with optimized parameters
  - Alert user to memory pressure condition
fi
```

## Session Directory Structure
```
sessions/ep_[NUMBER]_optimized_[TIMESTAMP]/
├── pipeline_status.json          # Execution tracking
├── discovery-results.json        # Stage 1 output
├── deep-research.json            # Stage 2 output
├── validated-research.json       # Stage 3 output
├── complete-research-package.json # Stage 4 final output
├── memory_usage_log.json         # Performance tracking
├── cost_tracking.json            # Budget utilization
└── error_recovery_log.json       # Issue resolution tracking
```

## Success Validation

### Technical Validation
```bash
# Validate each stage completion
for stage in discovery deep-dive validation synthesis; do
  if [[ -f "sessions/[SESSION]/${stage}*.json" ]]; then
    echo "✅ Stage ${stage} completed successfully"
    # Validate JSON structure
    jq empty "sessions/[SESSION]/${stage}*.json" && echo "✅ Valid JSON"
  else
    echo "❌ Stage ${stage} failed - investigate and recover"
  fi
done

# Memory efficiency validation
if [[ $(memory_peak) -lt 700MB ]]; then
  echo "✅ Memory optimization successful"
else
  echo "⚠️ Memory usage higher than expected - review optimization"
fi
```

### Quality Validation
```json
{
  "final_quality_gates": {
    "research_completeness": ">80%",
    "source_credibility_average": ">0.85",
    "fact_verification_rate": ">90%",
    "brand_alignment_score": ">0.85",
    "narrative_coherence_score": ">0.90",
    "production_readiness": "complete"
  }
}
```

## Integration Notes

- **Input**: Episode topic from command arguments
- **Processing**: Sequential 4-stage pipeline with external state persistence
- **Output**: Production-ready complete-research-package.json
- **Handoff**: Script writing pipeline receives optimized, structured research
- **Memory**: Peak usage <700MB through streaming and external state management
- **Cost**: $2.00 total budget with 85-95% optimization target

## Advanced Features

### Parallel Processing Potential
- Once memory issues resolved, stages 2-3 could run partially in parallel
- Discovery → (Deep-Dive || Validation) → Synthesis
- Requires careful state management and coordination

### Cross-Episode Intelligence
- Automatic loading of previous episode contexts for connection opportunities
- Knowledge graph management with cumulative learning integration
- Audience journey mapping with progressive complexity optimization

### Production Integration
- Direct handoff to script writing pipeline
- Quality assurance integration with brand voice validation
- Cost tracking integration with budget management system

This memory-optimized command represents a production-grade solution to the heap exhaustion issue while maintaining all research quality and functionality requirements through sophisticated micro-agent architecture and external state persistence.
