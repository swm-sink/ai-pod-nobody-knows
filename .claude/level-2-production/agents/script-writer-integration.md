# Script-Writer Agent Integration Guide

## Integration Overview

The script-writer agent is a critical component in the Level 2 podcast production pipeline, transforming research-coordinator output into engaging, brand-aligned podcast scripts ready for audio synthesis.

## Production Pipeline Position

```
Research-Coordinator → Script-Writer → Quality-Evaluator → Audio-Synthesizer
                          ↑
                    Current Agent
```

## Input Integration

### Research-Coordinator Handoff Protocol

**Expected Input Format**: Research package following the established structure:
- Location: `.claude/level-2-production/output/[episode]/research/`
- Format: Markdown with standardized knowledge layers
- Required sections: Executive Summary, Knowledge Layers (4), Podcast-Ready Elements, Source Validation

**Integration Validation**:
```yaml
input_validation:
  required_sections:
    - "Executive Summary"
    - "Knowledge Layers" 
    - "Podcast-Ready Elements"
    - "Source Credibility Assessment"
  
  knowledge_layer_completeness:
    - "What We Know (High Confidence ≥90%)"
    - "Emerging Understanding (Medium Confidence 60-89%)"
    - "Active Debates (Mixed Confidence)"
    - "Knowledge Frontiers (Low/Unknown <60%)"
    
  metadata_requirements:
    - research_hook
    - core_theme
    - complexity_level
    - unknown_factor
```

**Handoff Command Pattern**:
```
@script-writer "Transform research package: [episode]/research/[package-name] into podcast script"
```

## Output Integration  

### Quality-Evaluator Handoff Protocol

**Output Format**: Complete script package ready for evaluation
- Location: `.claude/level-2-production/output/[episode]/script/`
- Format: Markdown with embedded audio notation
- Required elements: Script content, metadata, self-assessment, quality documentation

**Output Structure**:
```markdown
# Podcast Script: [Episode Title]
*Target Duration: 27 minutes | Word Count: [actual] | Estimated Reading Time: [calculation]*

## Production Metadata
[Complete production information for quality evaluation]

## Script Content  
[Full script with audio notation and delivery markers]

## Quality Self-Assessment
[Built-in compliance documentation]
```

## Session Management Integration

### Episode Session State Updates

**Session Tracking Integration**:
```json
{
  "script_writing": {
    "status": "in_progress|completed|failed",
    "started_at": "2025-01-11T10:30:00Z",
    "completed_at": null,
    "agent": "script-writer",
    "attempts": 1,
    "quality_gates": {
      "word_count": {"target": [3900, 4100], "actual": 4023, "passed": true},
      "brand_score": {"target": 0.90, "actual": 0.92, "passed": true},
      "readability": {"target": [60, 70], "actual": 67, "passed": true},
      "structure_valid": {"target": true, "actual": true, "passed": true}
    },
    "outputs": {
      "script_markdown": "/output/ep123/script/script.md",
      "word_count": 4023,
      "estimated_duration": "27.2 minutes"
    },
    "cost": {
      "limit": 2.50,
      "actual": 1.87,
      "breakdown": {"claude_tokens": 1.87}
    },
    "errors": []
  }
}
```

### Cost and Time Tracking

**Resource Monitoring**:
- Real-time token usage tracking
- Generation time measurement
- Quality iteration cost accounting
- Budget alert integration

**Reporting Integration**:
```yaml
metrics_reporting:
  cost_efficiency:
    - cost_per_word_generated
    - cost_per_quality_point_achieved
    - revision_cost_overhead
    
  time_efficiency:
    - generation_speed_wpm
    - time_per_quality_gate_passed
    - total_pipeline_impact
    
  quality_trends:
    - brand_consistency_improvement
    - first_pass_success_rate
    - revision_effectiveness
```

## Quality Gate Integration

### Automated Quality Assessment

**Built-in Quality Monitoring**:
```python
# Quality gate integration during generation
def monitor_script_quality(script_content):
    quality_metrics = {
        'comprehension': calculate_readability_score(script_content),
        'brand_consistency': assess_brand_alignment(script_content),
        'engagement': measure_engagement_factors(script_content),
        'technical': validate_structure_compliance(script_content)
    }
    
    # Real-time gate checking
    for gate, score in quality_metrics.items():
        if score < quality_gates[gate]['threshold']:
            trigger_improvement_protocol(gate, score)
    
    return quality_metrics
```

**Quality Gate Failure Recovery**:
```yaml
failure_recovery_protocol:
  comprehension_failure:
    actions:
      - simplify_complex_sentences
      - add_explanatory_content
      - reduce_technical_jargon
    retry_limit: 2
    
  brand_consistency_failure:
    actions:
      - increase_humility_phrases
      - add_questioning_patterns
      - remove_absolutist_language
    retry_limit: 3
    
  engagement_failure:
    actions:
      - strengthen_opening_hook
      - increase_sentence_variety
      - add_curiosity_triggers
    retry_limit: 2
```

### Quality Evaluator Preparation

**Pre-Evaluation Documentation**:
- Complete self-assessment against all quality gates
- Identified areas for potential improvement
- Brand voice compliance verification
- Technical structure validation

**Handoff Package Contents**:
1. Complete script with audio notation
2. Production metadata and specifications
3. Quality self-assessment results
4. Source traceability documentation
5. Cost and time expenditure report

## Error Handling and Recovery

### Integration Error Management

**Common Integration Issues**:
```yaml
input_errors:
  incomplete_research_package:
    detection: "Missing required knowledge layers"
    response: "Request complete package or work with available content"
    documentation: "Log limitations in script metadata"
    
  conflicting_research_data:
    detection: "Contradictory information across sources"
    response: "Present multiple perspectives with appropriate caveats"
    documentation: "Flag uncertainty areas for quality review"
    
  invalid_format:
    detection: "Research package doesn't match expected structure"
    response: "Parse available content and document format issues"
    documentation: "Include format compliance notes"

output_errors:
  quality_gate_failure:
    detection: "Below threshold on critical quality metrics"
    response: "Execute improvement protocols with targeted edits"
    documentation: "Log all improvement attempts and results"
    
  word_count_violation:
    detection: "Outside acceptable 3900-4100 word range"
    response: "Content density adjustment without message change"
    documentation: "Track adjustment strategy and effectiveness"
    
  structure_compliance_failure:
    detection: "Missing required segments or poor transitions"
    response: "Reconstruct problematic sections with improved flow"
    documentation: "Document structural improvements made"
```

### Recovery Protocols

**Graceful Degradation Strategy**:
1. Attempt automatic improvement for failed quality gates
2. Document limitations if full compliance impossible
3. Provide partial script with clear quality status
4. Escalate to human review if critical failures persist

**State Preservation**:
- Incremental save every 5 minutes during generation
- Version control for rollback capability
- Progress checkpoints for recovery after interruption
- Complete audit trail for all changes and improvements

## Performance Optimization

### Integration Efficiency

**Optimization Strategies**:
```yaml
efficiency_improvements:
  single_pass_generation:
    strategy: "Comprehensive planning to minimize revision cycles"
    target: "90% first-pass quality gate success"
    measurement: "Quality gates passed without revision"
    
  intelligent_caching:
    strategy: "Reuse successful narrative patterns and brand voice elements"
    target: "20% generation time reduction"
    measurement: "Time per script generation"
    
  predictive_quality:
    strategy: "Monitor quality during generation, not just at end"
    target: "50% reduction in failed scripts"
    measurement: "Scripts requiring major revision"
```

### Resource Management

**Cost Optimization**:
- Token usage monitoring and prediction
- Efficient prompting strategies to minimize iterations
- Quality-cost trade-off optimization
- Learning from successful generation patterns

**Time Management**:
- Parallel processing where possible
- Efficient research package parsing
- Streamlined quality assessment
- Automated routine validations

## Testing Integration

### Continuous Integration Testing

**Automated Test Suite Integration**:
```yaml
ci_testing:
  regression_tests:
    frequency: "Every script generation"
    scope: "Quality gate compliance, brand voice, structure"
    automation_level: "Fully automated"
    
  integration_tests:
    frequency: "Weekly"
    scope: "End-to-end pipeline functionality"  
    automation_level: "Automated with human validation"
    
  performance_tests:
    frequency: "Monthly"
    scope: "Speed, cost efficiency, quality trends"
    automation_level: "Automated monitoring with human analysis"
```

### Quality Assurance Integration

**Human-in-the-Loop Validation**:
- Expert review of brand voice compliance
- Target audience comprehension testing
- Audio director review of delivery notation
- Continuous improvement feedback integration

## Deployment and Rollout

### Agent Deployment Protocol

**Pre-Deployment Checklist**:
- [ ] All integration tests passed
- [ ] Quality gate compliance verified
- [ ] Cost and time budgets validated
- [ ] Error handling protocols tested
- [ ] Documentation complete and accessible

**Rollout Strategy**:
1. **Phase 1**: Limited testing with existing research packages
2. **Phase 2**: Parallel running with manual script writing for comparison
3. **Phase 3**: Primary script generation with human quality assurance
4. **Phase 4**: Full autonomous operation with monitoring

### Monitoring and Maintenance

**Ongoing Monitoring**:
```yaml
monitoring_metrics:
  quality_maintenance:
    - brand_consistency_score_trends
    - quality_gate_pass_rates
    - user_satisfaction_ratings
    
  performance_tracking:
    - generation_time_trends
    - cost_efficiency_improvements
    - error_rate_monitoring
    
  integration_health:
    - handoff_success_rates
    - session_state_accuracy
    - pipeline_throughput
```

**Maintenance Protocols**:
- Monthly performance review and optimization
- Quarterly brand voice calibration
- Semi-annual integration testing
- Annual comprehensive system evaluation

## Training and Support

### User Training Materials

**Script-Writer Agent Usage Guide**:
1. Input preparation best practices
2. Quality expectations and standards
3. Integration workflow understanding
4. Troubleshooting common issues
5. Performance optimization tips

### Support Infrastructure

**Documentation Access**:
- Agent specification (script-writer.md)
- Testing framework (script-writer-tests.md)  
- Integration guide (this document)
- Quality standards reference
- Brand voice guidelines

**Support Escalation**:
1. Automated error resolution (built-in)
2. Documentation and FAQ consultation
3. Technical support for integration issues
4. Expert consultation for quality concerns
5. Development team escalation for system issues

This integration guide ensures seamless incorporation of the script-writer agent into the Level 2 production pipeline while maintaining high quality standards and efficient resource utilization.