# /validate-episode - Comprehensive Episode Validation Command

**Technical:** Native Claude Code slash command utilizing validation-orchestrator sub-agent for comprehensive 6-stage validation pipeline including quality gates, brand voice consistency, cost compliance, and technical excellence verification.

**Simple:** Like having a professional quality inspector who checks every aspect of your podcast episode before it goes live - making sure everything meets your standards.

**Connection:** This teaches systematic quality assurance methodology where comprehensive validation prevents issues and ensures consistent excellence across all production outputs.

---

## Command Usage

```
/validate-episode [episode_id] [--stage=STAGE] [--depth=LEVEL] [--report=FORMAT] [--fix-issues]
```

Use the validation-orchestrator sub-agent to validate episode: $ARGUMENTS

Execute comprehensive 6-stage validation workflow with automated quality gates, brand voice verification, and technical excellence assessment.

---

## Parameters

**Optional:**
- `episode_id`: Specific episode to validate (default: current active episode)
- `--stage`: Target validation stage (research|script|audio|integration|quality|deployment) - Default: all
- `--depth`: Validation depth (quick|standard|comprehensive|exhaustive) - Default: standard
- `--report`: Report format (console|json|markdown|html) - Default: console
- `--fix-issues`: Automatically fix detected issues where possible

---

## Validation Pipeline Integration

### Stage 1: Research Validation 🔍
The validation-orchestrator sub-agent will:
- Verify research synthesis completeness and quality scores ≥90%
- Validate source authority and diversity requirements (minimum 3 sources)
- Confirm intellectual humility integration throughout research findings
- Assess evidence quality and uncertainty acknowledgment accuracy

### Stage 2: Script Validation ✍️
The validation-orchestrator sub-agent will:
- Analyze brand voice consistency against reference corpus (≥90% alignment)
- Validate TTS optimization and natural speech pattern formatting
- Confirm research integration accuracy and proper attribution
- Assess accessibility without oversimplification

### Stage 3: Audio Validation 🔊
The validation-orchestrator sub-agent will:
- Verify audio synthesis quality and professional broadcast standards
- Validate voice consistency and brand alignment (95%+ target)
- Confirm technical audio specifications (sample rate, bitrate, duration)
- Assess listening experience and engagement optimization

### Stage 4: Integration Validation 🔗
The validation-orchestrator sub-agent will:
- Test workflow handoffs between all agents (≥99.5% success rate)
- Validate data flow and format consistency across pipeline
- Confirm checkpoint creation and rollback functionality
- Assess system resilience and error recovery procedures

### Stage 5: Quality Gates Assessment ✅
The validation-orchestrator sub-agent will:
- Execute dual-evaluator consensus system (Claude + Gemini)
- Validate quality metrics against established standards
- Confirm brand voice and intellectual humility consistency
- Assess educational value and accessibility targets

### Stage 6: Deployment Readiness 🚀
The validation-orchestrator sub-agent will:
- Verify production readiness with comprehensive checklist
- Validate cost compliance within $33.25 budget constraint
- Confirm all technical specifications and format requirements
- Assess scalability and maintenance considerations

---

## Examples

### Complete Episode Validation
```
/validate-episode
```
**Result:** validation-orchestrator executes full 6-stage pipeline for current episode, generating comprehensive quality report with pass/fail status for all validation criteria.

### Specific Stage Validation
```
/validate-episode episode_2024_08_21 --stage=script --depth=comprehensive
```
**Result:** validation-orchestrator performs exhaustive script validation including detailed brand voice analysis, TTS optimization assessment, and research integration verification.

### Quick Validation Check
```
/validate-episode --depth=quick
```
**Result:** validation-orchestrator performs rapid validation focusing on critical quality gates and budget compliance, suitable for development iterations.

### Automated Issue Resolution
```
/validate-episode --fix-issues --report=markdown
```
**Result:** validation-orchestrator identifies validation failures and automatically applies fixes where possible, generating detailed markdown report of issues resolved.

### Multi-Format Report Generation
```
/validate-episode episode_2024_08_21 --report=json --stage=quality
```
**Result:** validation-orchestrator generates structured JSON report for quality validation stage, suitable for automated processing and dashboard integration.

---

## Quality Gates Framework

### Research Quality Gates
Based on comprehensive research validation analysis:
- **Source Authority**: ≥90% from peer-reviewed or authoritative sources
- **Evidence Diversity**: Minimum 3 independent source perspectives
- **Uncertainty Acknowledgment**: Appropriate intellectual humility integration
- **Research Completeness**: All specified research objectives addressed

### Script Quality Gates
- **Brand Voice Consistency**: ≥90% alignment with reference corpus
- **TTS Optimization**: Natural speech patterns with proper formatting
- **Research Integration**: Accurate attribution and synthesis
- **Accessibility**: Complex concepts understandable without oversimplification

### Audio Quality Gates
- **Technical Standards**: Professional broadcast quality specifications
- **Voice Consistency**: ≥95% brand voice alignment across episode
- **Listening Experience**: Engagement optimization and flow assessment
- **Production Values**: Audio clarity, balance, and professional polish

### Integration Quality Gates
- **Agent Handoffs**: ≥99.5% successful data transfer between agents
- **Workflow Reliability**: Consistent execution without manual intervention
- **Error Recovery**: Graceful handling of failures with rollback capability
- **Performance Metrics**: Processing time and resource utilization within targets

### Cost Compliance Gates
- **Budget Adherence**: 100% compliance within $33.25 per episode limit
- **Cost Tracking**: Real-time monitoring with threshold alerts
- **Efficiency Validation**: Token usage and model selection optimization
- **Predictive Accuracy**: Final cost within ±5% of projections

---

## Validation Report Formats

### Console Output Format
```
=== EPISODE VALIDATION REPORT ===
Episode: episode_2024_08_21_innovation_in_ai
Validation Date: 2024-08-21 14:30:45
Overall Status: PASSED (90.5% quality score)

=== STAGE RESULTS ===
🟢 Research Validation     PASSED (95.2%) - All sources validated
🟢 Script Validation       PASSED (92.8%) - Brand voice excellent
🟢 Audio Validation        PASSED (88.5%) - Minor TTS optimization needed
🟢 Integration Validation  PASSED (96.1%) - All handoffs successful
🟢 Quality Gates          PASSED (91.3%) - Dual evaluator consensus
🟢 Deployment Readiness   PASSED (89.7%) - Production ready

=== QUALITY METRICS ===
📊 Brand Voice Alignment: 92.8% (Target: ≥90%) ✅
📊 Research Integration: 95.2% (Target: ≥90%) ✅
📊 TTS Optimization: 88.5% (Target: ≥85%) ✅
📊 Cost Compliance: $31.25/$33.25 (94.0% budget utilization) ✅

=== RECOMMENDATIONS ===
💡 Minor TTS optimization for section 3 technical terms
💡 Consider voice emphasis for key insights in conclusion
💡 Budget utilization optimal with $2.00 remaining for enhancements
```

### JSON Report Format
```json
{
  "episode_id": "episode_2024_08_21_innovation_in_ai",
  "validation_timestamp": "2024-08-21T14:30:45Z",
  "overall_status": "PASSED",
  "quality_score": 90.5,
  "stages": {
    "research": {
      "status": "PASSED",
      "score": 95.2,
      "checks": {
        "source_authority": {"score": 96.1, "status": "PASSED"},
        "evidence_diversity": {"score": 94.3, "status": "PASSED"},
        "uncertainty_acknowledgment": {"score": 95.0, "status": "PASSED"}
      }
    },
    "script": {
      "status": "PASSED",
      "score": 92.8,
      "brand_voice_alignment": 92.8,
      "tts_optimization": 88.5
    }
  },
  "cost_compliance": {
    "budget_limit": 33.25,
    "actual_cost": 31.25,
    "utilization": 94.0,
    "status": "PASSED"
  },
  "recommendations": [
    {
      "priority": "medium",
      "category": "tts_optimization",
      "description": "Minor TTS optimization for section 3 technical terms"
    }
  ]
}
```

---

## Integration with Hooks System

### Pre-Validation Cost Check
```bash
# Hook integration for budget validation before validation
pre_validation_hook() {
    local episode_id=$1
    local validation_depth=$2

    # Check current episode cost against budget
    current_cost=$(cost-tracker get_episode_cost $episode_id)
    if [[ $(echo "$current_cost > 33.25" | bc -l) -eq 1 ]]; then
        echo "BUDGET_VIOLATION: Episode $episode_id over budget ($current_cost > $33.25)"
        return 1
    fi

    echo "BUDGET_OK: Episode validation approved (Cost: $current_cost)"
}
```

### Post-Validation Quality Recording
```bash
# Automatic quality score recording after validation
post_validation_hook() {
    local episode_id=$1
    local quality_score=$2
    local validation_status=$3
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Record validation results
    echo "$timestamp,$episode_id,$quality_score,$validation_status" >> logs/validation_history.csv

    # Update episode quality metrics
    echo "quality_score:$quality_score" >> .claude/episodes/$episode_id/metadata.txt

    # Trigger alerts for quality issues
    if [[ $(echo "$quality_score < 85.0" | bc -l) -eq 1 ]]; then
        echo "QUALITY_ALERT: Episode $episode_id below quality threshold ($quality_score < 85.0)"
    fi
}
```

---

## Validation Depth Levels

### Quick Validation (5-10 minutes)
- Essential quality gates only
- Budget compliance verification
- Critical error detection
- Basic brand voice check

### Standard Validation (15-20 minutes)
- Complete 6-stage pipeline
- All quality metrics assessment
- Cost optimization analysis
- Comprehensive reporting

### Comprehensive Validation (30-45 minutes)
- Deep quality analysis with detailed metrics
- Cross-reference validation with historical episodes
- Performance benchmarking and optimization recommendations
- Detailed issue analysis with root cause assessment

### Exhaustive Validation (60-90 minutes)
- Research-backed validation with external source verification
- Advanced analytics and predictive quality modeling
- Comparative analysis against industry standards
- Complete audit trail with detailed documentation

---

## Automated Issue Resolution

### TTS Optimization Fixes
- Automatic pronunciation guide generation for technical terms
- Speech pattern optimization for improved audio flow
- Sentence structure adjustments for TTS compatibility
- Emphasis marker insertion for key concepts

### Brand Voice Corrections
- Intellectual humility phrasing adjustment
- Uncertainty acknowledgment enhancement
- Learning celebration language optimization
- Consistent tone and voice pattern alignment

### Research Integration Improvements
- Source attribution formatting corrections
- Evidence presentation optimization
- Research synthesis coherence enhancement
- Accuracy verification and correction

### Cost Optimization Adjustments
- Model selection optimization recommendations
- Token usage efficiency improvements
- Budget reallocation suggestions
- Resource utilization optimization

---

## Success Metrics

### Validation Effectiveness
- **Accuracy**: ≥95% correlation with final episode quality scores
- **Coverage**: 100% of critical quality dimensions assessed
- **Reliability**: ≤2% false positive/negative rate
- **Performance**: All validation depths complete within target timeframes

### Quality Improvement Impact
- **Issue Prevention**: ≥90% of potential issues detected before production
- **Consistency**: ≤5% quality variation across episodes
- **Efficiency**: 25-40% reduction in post-production corrections
- **Cost Impact**: Validation cost ≤2% of total episode budget

The /validate-episode command transforms quality assurance from reactive problem-solving to proactive excellence assurance, ensuring every episode meets established standards before production deployment while maintaining cost efficiency and brand consistency.
