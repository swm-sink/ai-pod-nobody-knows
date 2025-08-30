# /produce-episode-native - Native Claude Code Production Workflow

## Production-Optimized Native Claude Code Workflow

Execute comprehensive episode production for a "Nobody Knows" podcast using Claude Code native orchestration patterns with empirically validated production parameters and direct API integration.

## Usage

```bash
/produce-episode-native [episode_topic] [optional-parameters]
```

**Examples:**
- `/produce-episode-native "The Mystery of Quantum Consciousness"`
- `/produce-episode-native "What Nobody Knows About Black Holes" --from-research`
- `/produce-episode-native "The Science of Memory - What We're Still Discovering" --quality-threshold=0.96`

**Optional Parameters:**
- `--from-research` - Use existing research package from batch research
- `--validate-freshness` - Check research freshness before production
- `--research-depth=standard|comprehensive` (default: comprehensive)
- `--episode-length=15|30|45` (default: 25-30 minutes)
- `--quality-threshold=0.90|0.94|0.96` (default: 0.94)
- `--budget-limit=8|10|12` (default: $8.00)

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

## Production Pipeline Orchestration

This command orchestrates the complete production workflow by calling each sub-agent in sequence with quality validation at each stage.

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
- Generate initial 5,150-6,200 word script draft (206 WPM = 25-30 minutes)
- Target 28,000-33,500 characters (including SSML markup)
- Integrate research insights and expert quotes
- Maintain "Nobody Knows" brand voice throughout
- Include intellectual humility theme elements
- Structure for 25-30 minute target duration with empirical validation
- Create engaging, accessible content
- Save script_draft.md with complete script
```

### Step 4: Enhanced Three-Evaluator Consensus Validation (Budget: $1.50)
```
Execute comprehensive quality consensus using Episode 1 proven three-evaluator system:

EVALUATOR 1 - Use the claude agent (35% weight - creative content specialist):
- Evaluate brand voice consistency and intellectual humility integration
- Assess narrative coherence and engagement optimization
- Creative content evaluation with multi-dimensional assessment
- Validate accessibility and learning celebration
- Generate quality_claude_evaluation.json with confidence scoring

EVALUATOR 2 - Use the gemini agent (30% weight - technical production specialist):
- Technical production quality and format compliance assessment
- Structural analysis and production readiness validation
- Cross-verify factual accuracy and technical compliance
- Evaluate timing precision and audio synthesis preparation
- Generate quality_gemini_evaluation.json with production metrics

EVALUATOR 3 - Use the perplexity agent (35% weight - research accuracy specialist):
- Independent research accuracy verification and fact-checking
- Expert quote validation and source credibility assessment
- Cross-reference claims against authoritative sources
- Validate uncertainty acknowledgment and intellectual humility
- Generate quality_perplexity_evaluation.json with verification scores

QUALITY REQUIREMENTS:
- Overall quality target: ≥9.0/10
- Brand consistency: ≥90%
- Research accuracy: ≥95% fact verification
- Budget: $1.50 allocated
```

### Step 5: Enhanced Script Polishing with AI Quality Prediction (Budget: $0.75)
```
Use the script-polisher agent with three-evaluator consensus integration:

INPUT: Script draft + three quality evaluation reports (claude/gemini/perplexity)
REQUIREMENTS:
- Consolidate three-evaluator consensus into unified improvements
- Apply weighted feedback synthesis (Claude 35%, Gemini 30%, Perplexity 35%)
- Use ai-quality-predictor for real-time optimization guidance
- Prioritize enhancement recommendations by quality impact
- Address critical issues preventing production advancement
- Maintain brand voice integrity through polishing process
- Generate improved script ready for TTS optimization
- Target: >9.0/10 quality with 90%+ brand consistency
```

### Step 6: Enhanced TTS Optimization & Audio Preparation (Budget: $0.25)
```
Have the tts-optimizer agent prepare script for professional audio synthesis:

INPUT: Polished script with consensus-validated quality
REQUIREMENTS:
- Comprehensive IPA pronunciation system for all expert names and technical terms
- Strategic SSML optimization for natural speech patterns
- Timing control: target 206 WPM for optimal pacing
- IPA pronunciation tags for all expert names and technical terms
- Strategic breaks: 1s+ pauses for better comprehension
- Voice settings: stability=0.65, similarity=0.8, style=0.3
- Duration target: 25-30 minutes
- Generate tts_optimized_script.ssml ready for professional synthesis
```

### Step 7: Professional Audio Synthesis (Budget: $3.50)
```
Use the audio-synthesizer-direct-api agent for broadcast-quality audio:

INPUT: TTS-optimized script with comprehensive SSML markup
REQUIREMENTS:
- Professional audio synthesis using ElevenLabs direct API integration
- Voice configuration: ZF6FPAbjXT4488VcRRnw (production voice)
- Synthesis parameters: stability=0.65, similarity_boost=0.8, style=0.3
- Chunked synthesis for reliability and quality
- Duration target: 25-30 minutes
- Professional broadcast standards with -16 LUFS normalization
- Generate high-quality MP3 ready for distribution
```

### Step 8: Audio Quality Validation (Budget: $1.00)
```
Use the audio-validator agent for comprehensive quality assurance:

INPUT: Synthesized episode audio
REQUIREMENTS:
- Speech-to-text validation loop for word accuracy verification
- Pronunciation checking: 100% technical term accuracy validation
- Pacing analysis: optimal 150-160 words per minute assessment
- Timing validation: 25-30 minute duration compliance
- Quality scoring: ≥95% word accuracy, ≥85% composite quality
- Automated retry mechanism: max 3 attempts with parameter adjustment
- Quality certification for production advancement
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
- ✅ Script length 5,150-6,200 words (28,000-33,500 characters with SSML)
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
- ✅ Final audio meets duration (25-30 minutes) and quality targets (94.89% word accuracy)
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
