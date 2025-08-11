# Script-Writer Agent Testing Framework

## Test Suite Overview

This comprehensive testing framework validates the script-writer agent's ability to transform research packages into high-quality podcast scripts that meet "Nobody Knows" brand standards and Level 2 production quality gates.

## Test Categories

### 1. Input Processing Tests

#### Test 1.1: Research Package Parsing
**Objective**: Verify agent correctly processes research-coordinator output format

**Test Data**: Use existing consciousness-hard-problem-research-package.md
**Expected Behavior**:
- Correctly identifies all four knowledge layers
- Extracts opening hook options
- Maps story arc framework
- Identifies key talking points

**Validation Criteria**:
```yaml
parsing_accuracy:
  knowledge_layers_identified: 4/4
  hook_options_extracted: ≥2
  story_arc_mapped: true
  talking_points_identified: ≥4
```

**Test Command**:
```
@script-writer "Transform the consciousness hard problem research package into a podcast script"
```

#### Test 1.2: Invalid Input Handling  
**Objective**: Ensure graceful handling of incomplete research packages

**Test Data**: Research package missing knowledge frontiers section
**Expected Behavior**:
- Identifies missing sections
- Requests complete package or works with available content
- Documents limitations in script metadata

#### Test 1.3: Content Complexity Assessment
**Objective**: Verify appropriate complexity level detection and handling

**Test Scenarios**:
- Simple topic (established scientific concept)
- Intermediate topic (emerging field with some debate)  
- Complex topic (cutting-edge research with major unknowns)

### 2. Brand Voice Compliance Tests

#### Test 2.1: Intellectual Humility Integration
**Objective**: Validate consistent intellectual humility throughout script

**Measurement Criteria**:
```yaml
humility_metrics:
  phrases_per_1000_words:
    minimum: 3
    target: 5
    measured_patterns:
      - "Current evidence suggests"
      - "We think"  
      - "One possibility is"
      - "Scientists are still working to understand"
      - "This remains an open question"
      - "What's fascinating is how much we don't know"
  
  avoided_absolutist_language:
    maximum_violations: 2
    flagged_terms:
      - "definitely"
      - "obviously" 
      - "certainly"
      - "without doubt"
      - "we know for sure"
```

**Test Method**: Automated pattern matching + human review

#### Test 2.2: Curiosity and Wonder Expression
**Objective**: Ensure genuine curiosity pervades script content

**Validation Points**:
- Questions per 1000 words (target: 4)
- Wonder expressions in mystery sections
- Excitement about unknowns rather than frustration
- Future exploration encouragement

#### Test 2.3: Accessibility Without Oversimplification
**Objective**: Balance accessibility with intellectual integrity

**Test Criteria**:
- Flesch Reading Ease: 60-80 range
- Technical terms defined clearly
- Complex concepts explained through analogies
- No factual accuracy sacrificed for simplicity

### 3. Narrative Construction Tests

#### Test 3.1: Story Arc Coherence
**Objective**: Validate compelling narrative progression from known to unknown

**Structure Validation**:
```yaml
narrative_arc:
  opening_hook:
    duration_minutes: [2, 5]
    engagement_level: high
    promise_delivery: verified
  
  exploration_segments:
    foundation_layer: [4, 5] minutes
    discovery_layer: [6, 7] minutes  
    complexity_layer: [4, 5] minutes
    mystery_layer: [4, 5] minutes
    
  resolution_segment:
    duration_minutes: [4, 6]
    synthesis_quality: high
    future_orientation: present
```

#### Test 3.2: Transition Smoothness
**Objective**: Ensure natural flow between segments

**Test Method**: 
- Human reviewer rates transition naturalness (1-10 scale)
- Target: ≥8 average across all transitions
- No jarring topic shifts or logical gaps

#### Test 3.3: Information Architecture
**Objective**: Verify optimal information revelation timing

**Criteria**:
- Progressive complexity building
- Strategic surprise element placement
- Curiosity loops opened and resolved appropriately
- No information overload at any point

### 4. Audio Readiness Tests

#### Test 4.1: Speech Pattern Optimization
**Objective**: Validate script works for single-narrator audio delivery

**Audio Criteria**:
```yaml
speech_optimization:
  sentence_variety:
    average_length: [15, 25] words
    variety_score: ≥0.75
    
  natural_rhythm:
    pause_markers: appropriately placed
    emphasis_points: clearly indicated
    breathing_points: adequate frequency
    
  pronunciation_support:
    technical_terms: guidance provided
    foreign_words: phonetic notes included
```

#### Test 4.2: Pacing and Timing
**Objective**: Ensure script fits 27-minute target duration

**Timing Validation**:
- Word count: 3,900-4,100 words
- Estimated reading time: 26-28 minutes at 145 WPM
- Pause time allowance: included in calculations
- Segment balance: no single segment >8 minutes

#### Test 4.3: Delivery Notation Completeness  
**Objective**: Verify comprehensive audio direction

**Required Elements**:
- Tone markers for each segment
- Pause indicators (brief/medium/long)
- Emphasis markers for key concepts
- Transition cues between segments

### 5. Quality Gate Compliance Tests

#### Test 5.1: Comprehensive Quality Metrics
**Objective**: Validate all Level 2 production quality gates

**Quality Assessment Matrix**:
```yaml
comprehension_gate:
  flesch_reading_ease: [60, 80]
  flesch_kincaid_grade: [8, 12] 
  average_sentence_length: [15, 25]
  threshold: 0.85

brand_consistency_gate:
  humility_phrases_per_1000: ≥3
  questions_per_1000: ≥2
  avoided_terms_count: ≤2
  threshold: 0.90

engagement_gate:
  hook_effectiveness: ≥0.75
  sentence_variety: ≥0.70
  engagement_phrases: ≥5
  threshold: 0.80

technical_gate:
  duration_accuracy: ±2 minutes from 27
  structure_compliance: all segments present
  audio_readiness: complete notation
  threshold: 0.85
```

#### Test 5.2: Cost Efficiency Validation
**Objective**: Ensure script generation stays within budget constraints

**Budget Tracking**:
- Token usage monitoring throughout generation
- Target cost: $1.50-$2.50 per script
- Efficiency metrics: cost per quality point achieved

#### Test 5.3: Integration Compliance
**Objective**: Verify proper handoff formatting for quality-evaluator

**Output Validation**:
- Complete metadata included
- Self-assessment provided
- Quality documentation present
- Source integration traceable

### 6. Edge Case and Resilience Tests

#### Test 6.1: Complex Topic Handling
**Objective**: Test performance on challenging research packages

**Challenge Scenarios**:
- Highly technical content (quantum physics, advanced mathematics)
- Controversial topics with expert disagreement
- Rapidly evolving fields with new developments
- Abstract philosophical concepts

#### Test 6.2: Incomplete Information Management
**Objective**: Validate handling of research gaps

**Test Cases**:
- Missing knowledge layer
- Conflicting source information
- Insufficient confidence ratings
- Unclear research recommendations

#### Test 6.3: Brand Voice Edge Cases
**Objective**: Test intellectual humility in difficult scenarios

**Scenarios**:
- Topics with strong scientific consensus
- Politically sensitive subjects
- Complex ethical implications
- Historical controversies

### 7. Performance and Efficiency Tests

#### Test 7.1: Generation Speed
**Objective**: Validate time constraints adherence

**Time Targets**:
- Research analysis: ≤7 minutes
- Script development: ≤12 minutes  
- Audio formatting: ≤5 minutes
- Total generation: ≤20 minutes

#### Test 7.2: Revision Efficiency
**Objective**: Test improvement capability when quality gates fail

**Test Method**:
- Intentionally create below-threshold script
- Request quality improvements
- Measure revision effectiveness and speed
- Validate learning from feedback

#### Test 7.3: Consistency Across Topics
**Objective**: Ensure quality maintenance across different domains

**Domain Coverage**:
- Hard sciences (physics, chemistry, biology)
- Social sciences (psychology, anthropology)
- Philosophy and abstract concepts
- Current events and technology
- Historical mysteries

## Test Execution Protocols

### Automated Testing
```python
# Quality metrics automation
def run_script_quality_tests(script_content):
    results = {
        'word_count': count_words(script_content),
        'reading_ease': calculate_flesch_reading_ease(script_content),
        'humility_phrases': count_humility_patterns(script_content),
        'questions_per_1000': count_questions_normalized(script_content),
        'segment_structure': validate_required_segments(script_content),
        'audio_markers': validate_pacing_notation(script_content),
        'brand_consistency': calculate_brand_score(script_content)
    }
    return results
```

### Human Evaluation
- Expert review of narrative flow and engagement
- Brand voice assessment by "Nobody Knows" team
- Audio director review of delivery notation
- Target audience comprehension testing

### Integration Testing
- Full pipeline test: research → script → quality evaluation
- Cross-agent compatibility verification  
- Session management integration validation
- Cost and time tracking accuracy

## Test Data Sets

### Primary Test Cases
1. **Consciousness Research Package** (existing)
2. **Quantum Computing Mysteries** (to be created)
3. **Ancient Civilization Unknowns** (to be created)
4. **Climate Science Frontiers** (to be created)
5. **AI Ethics Debates** (to be created)

### Edge Case Test Data
- Incomplete research packages (missing sections)
- Conflicting information scenarios
- Highly technical content
- Controversial topics
- Rapidly evolving subjects

## Success Criteria

### Minimum Acceptable Performance
- 85% of quality gates passed on first generation
- Brand consistency score ≥0.90
- Cost within budget for 95% of scripts
- Time constraints met for 90% of generations

### Target Performance Goals  
- 95% quality gate success rate
- Average brand consistency ≥0.92
- Cost efficiency improvement over time
- Generation time reduction through learning

### Quality Improvement Tracking
- Episode-to-episode quality trend analysis
- Brand voice consistency improvement
- User feedback integration and learning
- Cost optimization without quality compromise

## Test Reporting Framework

### Real-Time Monitoring
- Quality gate status dashboard
- Cost and time tracking
- Error rate monitoring
- Performance trend analysis

### Comprehensive Reports
- Weekly quality assessment summary
- Monthly improvement recommendations
- Quarterly brand alignment analysis
- Annual learning and optimization review

This testing framework ensures the script-writer agent consistently produces high-quality podcast scripts that embody the "Nobody Knows" brand voice while meeting all Level 2 production requirements.