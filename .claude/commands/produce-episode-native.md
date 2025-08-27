# /produce-episode-native - Native Claude Code Production Workflow

## 🚨 PRODUCTION-OPTIMIZED WITH EMPIRICAL DATA - Episode 1 Validated

**Date**: August 25, 2025
**Source**: Episode 1 production validation - $2.77 actual cost, 11-minute duration
**Impact**: All production parameters recalibrated based on ElevenLabs 206 WPM empirical rate

Execute comprehensive episode production for a "Nobody Knows" podcast using Claude Code native orchestration patterns with empirically validated production parameters and direct API integration.

## Usage

```bash
/produce-episode-native [episode_number] [--from-research] [--validate-freshness]
```

## Examples

```bash
/produce-episode-native 1 --from-research
/produce-episode-native 25 --validate-freshness
```

## Native Claude Code Orchestration

This command demonstrates proper Claude Code architecture where **the main chat acts as orchestrator** and **directly invokes specialized production agents**, using native orchestration patterns for optimal agent execution and tool access.

### Production Workflow Architecture

**Native Pattern (This Command)**:
```
Main Chat → Direct Agent Invocation → Specialized production agents
```

**Anti-Pattern (Avoided)**:
```
Main Chat → Task Tool Delegation → Simulated agent responses
```

## Production Pipeline Execution

I will coordinate the complete production pipeline using direct orchestrator invocation:

### Prerequisites Validation
```
Before starting, I will verify:
- Research stream completed: sessions/ep_{number}_{timestamp}/research/research_complete.json exists
- Research package approved by user (if --from-research flag used)
- Production session directory ready: sessions/ep_{number}_{timestamp}/production/
- All quality gates and cost tracking systems operational
```

### Step 1: Initialize Production Session
```
Create production session directory: sessions/ep_{number}_{timestamp}/production/
Set up tracking for five-agent production workflow
Initialize cost tracking and quality gates
Load research package if using --from-research flag
```

### Step 2: Direct Invocation of Episode Planner Agent
```
Use the episode-planner agent to create episode structure:

INPUT: Research package (if available) or episode topic
REQUIREMENTS:
- Create detailed episode structure and timing blueprint
- Integrate research findings into narrative flow
- Design 25-30 minute episode architecture (206 WPM empirical rate)
- Ensure intellectual humility brand alignment
- Generate episode plan with segment timing
- Save episode_plan.json with complete structure
```

### Step 3: Direct Invocation of Script Writer Agent
```
Have the script-writer agent create the episode script:

INPUT: Episode plan + research data package
REQUIREMENTS:
- Generate initial 3,200-3,600 word script draft (206 WPM = 25-30 minutes)
- Target 17,500-19,500 characters (including SSML markup)
- Integrate research insights and expert quotes
- Maintain "Nobody Knows" brand voice throughout
- Include intellectual humility theme elements
- Structure for 25-30 minute target duration with empirical validation
- Create engaging, accessible content
- Save script_draft.md with complete script
```

### Step 4: Parallel Direct Invocation of Quality Evaluation Agents
```
Simultaneously use dual quality agents for evaluation:

AGENT A - Use the quality-claude agent to evaluate script quality:
- Evaluate script for brand consistency (>85% threshold - empirically achievable)
- Assess technical accuracy and comprehension
- Check engagement and educational value
- Validate intellectual humility alignment
- Generate quality_claude_report.json

AGENT B - Have the quality-gemini agent provide independent assessment:
- Independent quality assessment and validation
- Cross-verify brand voice consistency (>85% composite score - Episode 1 validated)
- Evaluate production readiness metrics
- Assess accessibility and engagement
- Generate quality_gemini_report.json
```

### Step 5: Direct Invocation of Script Polisher Agent
```
Use the script-polisher agent to improve script based on quality feedback:

INPUT: Script draft + both quality evaluation reports
REQUIREMENTS:
- Consolidate quality evaluations into unified improvements
- Prioritize enhancement recommendations by impact
- Apply consensus-based refinement approach
- Address critical issues requiring script revision
- Generate improved script ready for TTS optimization
```

### Step 6: Direct Invocation of TTS Optimizer Agent
```
Have the tts-optimizer agent prepare script for audio synthesis:

INPUT: Polished script from previous step
REQUIREMENTS:
- Optimize script for ElevenLabs TTS synthesis using empirical effectiveness data
- Add strategic SSML markup: 1s+ breaks (95% effective) vs 500ms breaks (40% effective)
- Add IPA phoneme tags for all expert names and technical terms (100% pronunciation accuracy)
- Optimize pacing, pronunciation, and flow using Episode 1 lessons learned
- Use Amelia voice parameters: stability=0.65, similarity=0.8, style=0.3
- Generate tts_optimized_script.ssml ready for direct API synthesis
```

### Step 7: Direct Invocation of Audio Synthesizer Agent
```
Use the audio-synthesizer-direct-api agent to create final episode audio:

INPUT: TTS-optimized script with SSML markup
REQUIREMENTS:
- Generate final episode audio using ElevenLabs DIRECT API integration
- Use production-validated single-call synthesis method
- Apply Amelia voice settings: stability=0.65, similarity=0.8, style=0.3, speed=1.0
- Implement chunked synthesis for optimal quality and reliability
- Generate high-quality MP3 output ready for distribution
- Save final episode audio to production directory
```

### Step 8: Final Quality Validation & Session Completion
```
Coordinate final validation and completion:
- Validate all production stages completed successfully
- Verify audio meets duration and quality targets (25-30 minutes, >94% accuracy)
- Generate production summary with cost analysis and performance metrics
- Archive session materials in structured format
- Update episode tracking database with production results
- Prepare final deliverable package for distribution
```

### Step 9: Final Quality Validation & Session Completion
```
Coordinate final validation:
- Validate all production stages completed successfully
- Verify audio meets duration and quality targets
- Aggregate cost tracking across all agents
- Generate comprehensive production report
- Create user-deliverable package with all outputs
```

## Quality Gates Integration

At each stage, I will verify:

### Planning Gate
- ✅ Episode structure meets 25-30 minute target architecture (206 WPM empirical)
- ✅ Research integration comprehensive and accurate
- ✅ Brand alignment score >85% for intellectual humility (empirically achievable)

### Writing Gate
- ✅ Script length 3,200-3,600 words (17,500-19,500 characters with SSML)
- ✅ Brand voice consistency >85% throughout script (empirically validated)
- ✅ Educational value and accessibility maintained
- ✅ Expert names prepared for IPA phoneme markup

### Quality Evaluation Gate
- ✅ Both quality evaluators pass with consensus >85% (recalibrated thresholds)
- ✅ Critical issues identified and prioritized
- ✅ Production readiness criteria met
- ✅ Pronunciation accuracy validated for technical terms

### Polish Gate
- ✅ All quality feedback addressed systematically
- ✅ Script refinements maintain brand consistency
- ✅ TTS optimization compatibility verified

### Audio Production Gate
- ✅ Final audio duration 25-30 minutes (206 WPM empirical tolerance)
- ✅ Audio quality meets professional podcast standards (94.89% word accuracy)
- ✅ Voice consistency and clarity validated (Amelia voice optimized settings)
- ✅ Direct API synthesis completed successfully

## Session Management & Data Persistence

**CRITICAL**: Save complete production data using this structure:

```json
{
  "session_metadata": {
    "session_id": "ep_{number}_production_{timestamp}",
    "episode_topic": "[EPISODE_TOPIC]",
    "research_source": "batch_research|individual_research|manual_input",
    "status": "completed",
    "total_cost": 0.00,
    "production_duration_minutes": 0,
    "timestamp": "2025-08-24T00:00:00Z",
    "orchestration_method": "main_chat_task_tool"
  },
  "stage_completion": {
    "episode_planning": {
      "status": "completed",
      "agent": "episode-planner",
      "cost": 0.25,
      "quality_score": 0.88,
      "completion_time": "2025-08-24T10:15:00Z"
    },
    "script_writing": {
      "status": "completed",
      "agent": "script-writer",
      "cost": 1.50,
      "word_count": 3420,
      "character_count": 18650,
      "quality_score": 0.86,
      "completion_time": "2025-08-24T10:45:00Z"
    },
    "quality_evaluation": {
      "status": "completed",
      "claude_agent": "quality-claude",
      "gemini_agent": "quality-gemini",
      "cost": 0.75,
      "consensus_score": 0.84,
      "completion_time": "2025-08-24T11:00:00Z"
    },
    "script_polish": {
      "status": "completed",
      "agent": "script-polisher",
      "cost": 0.50,
      "improvements_applied": 12,
      "final_quality_score": 0.91,
      "completion_time": "2025-08-24T11:30:00Z"
    },
    "tts_optimization": {
      "status": "completed",
      "agent": "tts-optimizer",
      "cost": 0.25,
      "ssml_enhancements": 45,
      "completion_time": "2025-08-24T11:45:00Z"
    },
    "audio_synthesis": {
      "status": "completed",
      "agent": "audio-synthesizer",
      "cost": 3.75,
      "audio_duration": "28:15",
      "voice_model": "Amelia",
      "voice_settings": "stability=0.65,similarity=0.8,style=0.3",
      "completion_time": "2025-08-24T12:15:00Z"
    }
  },
  "quality_metrics": {
    "overall_quality_score": 0.89,
    "brand_consistency_score": 0.92,
    "technical_accuracy_score": 0.87,
    "engagement_score": 0.88,
    "production_readiness": "approved"
  },
  "cost_breakdown": {
    "total_production_cost": 2.77,
    "cost_per_minute": 0.10,
    "budget_efficiency": 0.97,
    "cost_vs_target": "significantly_under_budget",
    "episode_1_validation": "empirically_achieved"
  },
  "deliverables": {
    "episode_plan": "sessions/ep_{number}_{timestamp}/production/episode_plan.json",
    "script_draft": "sessions/ep_{number}_{timestamp}/production/script_draft.md",
    "script_final": "sessions/ep_{number}_{timestamp}/production/script_final.md",
    "tts_optimized": "sessions/ep_{number}_{timestamp}/production/tts_optimized_script.ssml",
    "episode_audio": "sessions/ep_{number}_{timestamp}/production/episode_audio.mp3",
    "quality_reports": "sessions/ep_{number}_{timestamp}/production/quality/",
    "production_summary": "sessions/ep_{number}_{timestamp}/production/production_summary.md"
  }
}
```

## Error Recovery & Resilience

### Error Handling Protocol
If any production stage fails:
1. **Save Current Progress**: Persist all completed stage outputs
2. **Log Specific Failure Reason**: Document exact error and context
3. **Provide Recovery Options**: Present user with restart/resume choices
4. **Enable Stage Restart**: Allow restart from last successful stage
5. **Maintain Session Integrity**: Preserve all successful work and cost tracking

### Recovery Strategies
- **Planning Failure**: Restart with research package validation
- **Writing Failure**: Retry with modified parameters or manual guidance
- **Quality Gate Failure**: Review feedback and re-run with adjustments
- **Polish Failure**: Manual review with user guidance for complex issues
- **Audio Synthesis Failure**: Retry with optimized settings or voice model selection

## Integration with External Research Tools

### WebSearch Validation
- Real-time fact-checking during script review
- Official source verification for claims and statistics
- Expert quote validation and attribution verification
- Current development tracking for dynamic content

### Perplexity MCP Quality Assurance
- Independent fact verification during quality evaluation
- Expert consensus validation for controversial topics
- Citation verification for research claims
- Authority validation for source credibility

## Success Criteria

- ✅ All production agents completed successfully via Task tool delegation
- ✅ Quality gates passed at every stage with documented scores
- ✅ Final audio meets duration (25-30 minutes) and quality targets
- ✅ Brand consistency >85% throughout production pipeline (empirically achievable)
- ✅ Total cost tracked and within reasonable bounds (target <$2.80 - Episode 1 achieved $2.77)
- ✅ Complete episode ready for delivery with all supporting materials
- ✅ Native Claude Code orchestration pattern demonstrated throughout
- ✅ External research tools successfully integrated for validation
- ✅ Error recovery capabilities validated and operational

## User Delivery Package

After completing all production coordination:

1. **Episode Audio File**: `sessions/ep_{number}_{date}/production/episode_audio.mp3`
2. **Production Summary**: Comprehensive markdown summary with all metrics
3. **Quality Validation Report**: Detailed quality scores and validation results
4. **Cost Analysis**: Complete cost breakdown with efficiency metrics
5. **Session Archive**: Complete production history with all intermediate outputs
6. **Delivery Notification**: "Episode production completed! Full package at: [SESSION_PATH]"

This native production command demonstrates proper Claude Code orchestration while preserving and enhancing all production functionality, integrating external validation tools, and providing comprehensive quality assurance with complete error recovery capabilities.

## Technical Implementation Notes

- Uses **Task tool delegation** instead of separate orchestrator agents
- **Main chat maintains context** and coordinates all production activities
- **Sub-agents operate independently** with specialized expertise and clean contexts
- **External tool integration** enhances validation and quality assurance
- **Complete session management** ensures no work loss and full traceability
- **Quality gates** maintain high standards throughout production process
- **Cost optimization** balances quality with efficiency targets
- **Error recovery** enables resilient production workflows

Ready to execute comprehensive episode production using Claude Code native patterns with full external research tool integration.
