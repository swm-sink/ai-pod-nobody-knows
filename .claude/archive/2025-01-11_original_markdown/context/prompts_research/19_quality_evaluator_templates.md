# Quality Evaluator Agent Templates (2025)

<document type="agent-templates" category="quality-assessment" version="2025.1">
  <metadata>
    <created>2025-01-11</created>
    <purpose>Quality evaluation templates for podcast content assessment</purpose>
    <framework>Multi-criteria scoring with LLM-as-judge</framework>
    <benchmark>Achieving 0.90+ quality scores consistently</benchmark>
  </metadata>

## ✅ Executive Summary

This document contains comprehensive quality evaluator templates that assess podcast scripts, audio, and overall production quality. These templates implement 2025's best practices including LLM-as-judge frameworks, weighted scoring rubrics, and automated feedback generation proven to maintain consistent quality above 0.90.

## 📚 Table of Contents

1. [Master Evaluator Template](#master-evaluator-template)
2. [Multi-Criteria Scoring Framework](#multi-criteria-scoring-framework)
3. [LLM-as-Judge Implementation](#llm-as-judge-implementation)
4. [Content Assessment Rubrics](#content-assessment-rubrics)
5. [Feedback Generation Templates](#feedback-generation-templates)
6. [Automated Quality Gates](#automated-quality-gates)
7. [Performance Tracking Systems](#performance-tracking-systems)
8. [Real-World Evaluation Examples](#real-world-evaluation-examples)

## Master Evaluator Template

### 🎯 Core Quality Assessment Prompt

```xml
<quality_evaluator_system>
  <role>
    You are a senior podcast quality evaluator with expertise in educational
    content, audience engagement, and production standards. You provide
    objective, actionable feedback based on established criteria while
    maintaining high standards for accuracy, engagement, and brand consistency.
  </role>

  <expertise>
    <evaluation_skills>
      - Multi-dimensional quality assessment
      - Objective scoring with justification
      - Pattern recognition across episodes
      - Constructive feedback generation
    </evaluation_skills>

    <domain_knowledge>
      - Educational content effectiveness
      - Podcast engagement metrics
      - Audio production standards
      - Brand consistency evaluation
    </domain_knowledge>

    <assessment_framework>
      - 15-point criteria system
      - Weighted scoring methodology
      - Confidence level assignment
      - Improvement prioritization
    </assessment_framework>
  </expertise>

  <evaluation_principles>
    <objectivity>
      Base scores on defined rubrics, not preferences
      Provide evidence for each assessment
      Acknowledge evaluation limitations
    </objectivity>

    <constructiveness>
      Identify specific strengths to maintain
      Suggest concrete improvements
      Prioritize feedback by impact
    </constructiveness>
  </evaluation_principles>
</quality_evaluator_system>
```

### 🏆 2025 Best Practice Framework

```python
class AdvancedQualityEvaluator:
    """
    State-of-the-art quality evaluation system
    """

    def __init__(self):
        self.evaluation_criteria = {
            "accuracy": {"weight": 0.40, "threshold": 0.95},
            "engagement": {"weight": 0.25, "threshold": 0.85},
            "clarity": {"weight": 0.20, "threshold": 0.90},
            "brand_consistency": {"weight": 0.15, "threshold": 0.92}
        }

        self.scoring_scale = {
            5: "Excellent (90-100%)",
            4: "Good (75-89%)",
            3: "Satisfactory (60-74%)",
            2: "Needs Improvement (40-59%)",
            1: "Poor (<40%)"
        }

    def comprehensive_evaluation_prompt(self, content):
        return f"""
        <quality_evaluation_task>
          <content_to_evaluate>
            {content}
          </content_to_evaluate>

          <evaluation_framework>
            <step_1>
              Initial assessment across all criteria
              Score each dimension 1-5
              Note initial impressions
            </step_1>

            <step_2>
              Deep dive into each criterion
              Gather supporting evidence
              Identify specific examples
            </step_2>

            <step_3>
              Apply weighted scoring
              Calculate overall score
              Determine pass/fail status
            </step_3>

            <step_4>
              Generate actionable feedback
              Prioritize improvements
              Suggest specific changes
            </step_4>
          </evaluation_framework>

          <output_requirements>
            <scores>
              Provide numerical scores with justification
            </scores>
            <feedback>
              One clear strength to maintain
              One priority improvement with specific suggestion
            </feedback>
            <recommendation>
              PASS (>85%) or REVISE (<85%) with reasoning
            </recommendation>
          </output_requirements>
        </quality_evaluation_task>
        """
```

### 🧠 Technical Explanation
This evaluator implements a multi-stage assessment process that mirrors human expert evaluation while maintaining consistency through defined rubrics and weighted scoring, essential for maintaining quality at scale.

### 💡 Simple Breakdown
Think of this like a teacher grading a paper—checking if facts are right, if it's interesting to read, if it's clearly written, and if it follows the assignment guidelines, then combining all those scores into a final grade.

## Multi-Criteria Scoring Framework

### 📊 15-Point Evaluation Criteria

```python
class ComprehensiveScoring:
    """
    Detailed scoring across 15 essential criteria
    """

    def __init__(self):
        self.criteria = {
            # Content Quality (40% weight)
            "factual_accuracy": {
                "weight": 0.15,
                "rubric": {
                    5: "All facts verified, sources cited",
                    4: "Minor inaccuracies, easily corrected",
                    3: "Some unverified claims",
                    2: "Multiple errors found",
                    1: "Significant inaccuracies"
                }
            },
            "depth_of_content": {
                "weight": 0.10,
                "rubric": {
                    5: "Comprehensive coverage with nuance",
                    4: "Good depth, minor gaps",
                    3: "Adequate coverage",
                    2: "Surface-level treatment",
                    1: "Insufficient depth"
                }
            },
            "intellectual_humility": {
                "weight": 0.15,
                "rubric": {
                    5: "Consistently acknowledges unknowns",
                    4: "Usually acknowledges limits",
                    3: "Sometimes mentions uncertainty",
                    2: "Rarely admits unknowns",
                    1: "Presents speculation as fact"
                }
            },

            # Engagement (25% weight)
            "hook_effectiveness": {
                "weight": 0.08,
                "rubric": {
                    5: "Instantly captivating opening",
                    4: "Strong, interesting start",
                    3: "Adequate hook",
                    2: "Weak opening",
                    1: "No clear hook"
                }
            },
            "narrative_flow": {
                "weight": 0.09,
                "rubric": {
                    5: "Seamless, compelling progression",
                    4: "Good flow, minor bumps",
                    3: "Generally coherent",
                    2: "Disjointed sections",
                    1: "No clear structure"
                }
            },
            "emotional_journey": {
                "weight": 0.08,
                "rubric": {
                    5: "Rich emotional arc throughout",
                    4: "Good emotional moments",
                    3: "Some emotional engagement",
                    2: "Limited emotional content",
                    1: "Emotionally flat"
                }
            },

            # Clarity (20% weight)
            "concept_explanation": {
                "weight": 0.10,
                "rubric": {
                    5: "Crystal clear, perfect analogies",
                    4: "Well explained, minor confusion",
                    3: "Generally understandable",
                    2: "Often confusing",
                    1: "Unclear throughout"
                }
            },
            "language_accessibility": {
                "weight": 0.10,
                "rubric": {
                    5: "Perfect for target audience",
                    4: "Mostly accessible",
                    3: "Some jargon issues",
                    2: "Too technical/simple",
                    1: "Wrong level throughout"
                }
            },

            # Technical Quality (15% weight)
            "dialogue_naturalness": {
                "weight": 0.05,
                "rubric": {
                    5: "Completely natural conversation",
                    4: "Mostly natural, occasional stiffness",
                    3: "Adequate dialogue",
                    2: "Often sounds scripted",
                    1: "Robotic dialogue"
                }
            },
            "pacing": {
                "weight": 0.05,
                "rubric": {
                    5: "Perfect rhythm and timing",
                    4: "Good pacing, minor issues",
                    3: "Generally well-paced",
                    2: "Pacing problems",
                    1: "Poor pacing throughout"
                }
            },
            "timing_accuracy": {
                "weight": 0.05,
                "rubric": {
                    5: "Within 30 seconds of target",
                    4: "Within 1 minute",
                    3: "Within 2 minutes",
                    2: "3-5 minutes off",
                    1: "More than 5 minutes off"
                }
            }
        }

    def calculate_weighted_score(self, individual_scores):
        """Calculate final weighted score"""

        total = 0
        for criterion, score in individual_scores.items():
            weight = self.criteria[criterion]["weight"]
            total += score * weight

        return {
            "raw_score": total,
            "percentage": total * 20,  # Convert 5-point to 100%
            "grade": self.assign_grade(total * 20)
        }

    def assign_grade(self, percentage):
        if percentage >= 90: return "A"
        elif percentage >= 80: return "B"
        elif percentage >= 70: return "C"
        elif percentage >= 60: return "D"
        else: return "F"
```

### 🎨 Scoring Rubric Visualization

```xml
<scoring_visualization>
  <excellence_indicators score="5">
    <characteristics>
      - Exceeds all requirements
      - Could serve as exemplar
      - No improvements needed
      - Delights audience
    </characteristics>
    <frequency>10-15% of content</frequency>
  </excellence_indicators>

  <good_performance score="4">
    <characteristics>
      - Meets all requirements
      - Minor improvements possible
      - Engaging and accurate
      - Professional quality
    </characteristics>
    <frequency>40-50% of content</frequency>
  </good_performance>

  <satisfactory score="3">
    <characteristics>
      - Meets basic requirements
      - Some issues present
      - Acceptable for release
      - Room for improvement
    </characteristics>
    <frequency>30-35% of content</frequency>
  </satisfactory>

  <needs_improvement score="2">
    <characteristics>
      - Below standards
      - Significant issues
      - Requires revision
      - Not release-ready
    </characteristics>
    <frequency>5-10% of content</frequency>
  </needs_improvement>

  <poor_performance score="1">
    <characteristics>
      - Fails requirements
      - Major problems
      - Complete rework needed
      - Unacceptable quality
    </characteristics>
    <frequency><5% of content</frequency>
  </poor_performance>
</scoring_visualization>
```

## LLM-as-Judge Implementation

### 🤖 Automated Judge Configuration

```python
class LLMJudgeSystem:
    """
    Implement LLM-as-judge for scalable quality assessment
    """

    def __init__(self):
        self.judge_configuration = {
            "model": "claude-opus-4.1",
            "temperature": 0.3,  # Low for consistency
            "role": "expert_evaluator"
        }

    def judge_prompt_template(self, content, criteria):
        return f"""
        <llm_judge_task>
          <role>
            You are an expert judge evaluating podcast content quality.
            You must be objective, consistent, and provide evidence-based scoring.
          </role>

          <content_to_judge>
            {content}
          </content_to_judge>

          <evaluation_criteria>
            {self.format_criteria(criteria)}
          </evaluation_criteria>

          <scoring_instructions>
            For each criterion:
            1. Read the content carefully
            2. Compare against the rubric
            3. Select appropriate score (1-5)
            4. Provide specific evidence from content
            5. Suggest one improvement if score < 5
          </scoring_instructions>

          <output_format>
            <criterion name="[name]">
              <score>[1-5]</score>
              <evidence>[Quote or description from content]</evidence>
              <reasoning>[Why this score was assigned]</reasoning>
              <improvement>[Specific suggestion if needed]</improvement>
            </criterion>
          </output_format>

          <calibration_examples>
            {self.provide_calibration_examples()}
          </calibration_examples>
        </llm_judge_task>
        """

    def consistency_check(self, evaluation1, evaluation2):
        """Ensure consistent scoring across evaluations"""

        variance_threshold = 0.5  # Maximum acceptable variance

        for criterion in evaluation1:
            score_diff = abs(evaluation1[criterion] - evaluation2[criterion])
            if score_diff > variance_threshold:
                return {
                    "consistent": False,
                    "criterion": criterion,
                    "variance": score_diff,
                    "action": "Re-evaluate with clarified rubric"
                }

        return {"consistent": True}
```

### 🎯 Prometheus-Style Open Evaluation

```xml
<prometheus_evaluation_framework>
  <description>
    Open-source LLM evaluation comparable to GPT-4
  </description>

  <components>
    <reference_answer>
      The ideal response that would score 5/5
    </reference_answer>

    <score_rubric>
      Detailed scoring criteria for each point level
    </score_rubric>

    <evaluation_steps>
      <step_1>Compare response to reference</step_1>
      <step_2>Identify gaps and strengths</step_2>
      <step_3>Apply rubric systematically</step_3>
      <step_4>Assign score with justification</step_4>
    </evaluation_steps>
  </components>

  <use_case_agnostic>
    Can evaluate any content type:
    - Scripts
    - Research briefs
    - Audio transcripts
    - Production notes
  </use_case_agnostic>
</prometheus_evaluation_framework>
```

## Content Assessment Rubrics

### 📝 Script Quality Rubric

```python
class ScriptAssessmentRubric:
    """
    Detailed rubric for podcast script evaluation
    """

    def __init__(self):
        self.script_criteria = {
            "opening_hook": {
                "excellent": "Immediately grabs attention, poses intriguing question",
                "good": "Interesting start, clear topic introduction",
                "satisfactory": "Adequate opening, sets context",
                "poor": "Weak or missing hook"
            },
            "dialogue_authenticity": {
                "excellent": "Sounds completely natural, includes fillers, interruptions",
                "good": "Mostly natural with good flow",
                "satisfactory": "Some stiffness but generally okay",
                "poor": "Sounds scripted and unnatural"
            },
            "educational_value": {
                "excellent": "Teaches complex concepts clearly, memorable",
                "good": "Good explanations, mostly clear",
                "satisfactory": "Basic information conveyed",
                "poor": "Confusing or inaccurate teaching"
            },
            "intellectual_humility": {
                "excellent": "Consistently acknowledges unknowns, embraces uncertainty",
                "good": "Usually mentions knowledge limits",
                "satisfactory": "Some acknowledgment of uncertainty",
                "poor": "Presents everything as certain"
            },
            "narrative_structure": {
                "excellent": "Compelling arc with clear acts, satisfying conclusion",
                "good": "Good structure with minor pacing issues",
                "satisfactory": "Basic structure present",
                "poor": "Disjointed or no clear structure"
            }
        }

    def evaluate_script(self, script):
        evaluation_prompt = f"""
        <script_evaluation>
          <script>{script}</script>

          <evaluate_against>
            {self.script_criteria}
          </evaluate_against>

          <specific_checks>
            - Count uncertainty acknowledgments
            - Measure dialogue line lengths
            - Check for filler words (um, uh, hmm)
            - Verify timing (150 words/minute)
            - Assess emotional journey
          </specific_checks>

          <output>
            Score each criterion and provide:
            - Overall script quality (1-5)
            - Strongest element
            - Priority improvement
            - Revision recommendation
          </output>
        </script_evaluation>
        """
        return evaluation_prompt
```

### 🎙️ Audio Quality Rubric

```xml
<audio_quality_rubric>
  <voice_performance>
    <excellent>
      - Natural intonation and emotion
      - Clear articulation
      - Appropriate pacing
      - Distinct character voices
    </excellent>
    <good>
      - Generally natural delivery
      - Mostly clear speech
      - Good pacing with minor issues
    </good>
    <poor>
      - Robotic or monotone
      - Unclear articulation
      - Poor pacing
    </poor>
  </voice_performance>

  <technical_quality>
    <excellent>
      - Consistent audio levels
      - No artifacts or glitches
      - Smooth transitions
      - Professional sound
    </excellent>
    <good>
      - Minor level variations
      - Occasional small artifacts
      - Generally smooth
    </good>
    <poor>
      - Significant level issues
      - Noticeable artifacts
      - Jarring transitions
    </poor>
  </technical_quality>

  <production_elements>
    <music_integration>
      Enhances without overwhelming
    </music_integration>
    <sound_effects>
      Used sparingly and effectively
    </sound_effects>
    <silence_usage>
      Strategic pauses for emphasis
    </silence_usage>
  </production_elements>
</audio_quality_rubric>
```

## Feedback Generation Templates

### 💬 Constructive Feedback Framework

```python
class FeedbackGenerator:
    """
    Generate actionable, constructive feedback
    """

    def __init__(self):
        self.feedback_structure = {
            "sandwich_method": True,  # Positive-Negative-Positive
            "specificity": "high",
            "actionability": "required",
            "tone": "encouraging yet honest"
        }

    def generate_feedback(self, scores, content):
        return f"""
        <feedback_generation>
          <opening_positive>
            Start with strongest element:
            "The {identify_strength(scores)} was excellent, particularly..."
          </opening_positive>

          <constructive_criticism>
            <priority_1>
              Issue: {identify_main_issue(scores)}
              Impact: Why this matters for quality
              Solution: Specific steps to improve
              Example: How it could be better
            </priority_1>

            <priority_2>
              Issue: {identify_secondary_issue(scores)}
              Quick fix: Simple adjustment needed
            </priority_2>
          </constructive_criticism>

          <closing_encouragement>
            Overall assessment: {overall_quality(scores)}
            Potential seen: What could make this excellent
            Next steps: Clear action items
          </closing_encouragement>
        </feedback_generation>
        """

    def feedback_templates(self):
        return {
            "accuracy_issue": """
                The claim about {topic} needs verification.
                Current: "{current_claim}"
                Suggested: "{corrected_claim}"
                Source: {reliable_source}
                """,

            "engagement_improvement": """
                The section on {topic} could be more engaging.
                Try: Adding a relatable analogy or surprising fact
                Example: "It's like when you..."
                """,

            "pacing_adjustment": """
                The pacing between minutes {start}-{end} feels rushed.
                Consider: Adding a breather moment or transition
                Example: "Let's pause and think about what this means..."
                """,

            "humility_reminder": """
                The explanation of {topic} sounds too certain.
                Add phrases like: "Current research suggests..." or
                "Scientists are still debating..."
                """
        }
```

### 🎯 Improvement Prioritization

```xml
<improvement_prioritization>
  <priority_matrix>
    <high_impact_easy>
      <description>Quick fixes with big results</description>
      <examples>
        - Add uncertainty acknowledgments
        - Fix factual errors
        - Improve opening hook
      </examples>
      <action>Do immediately</action>
    </high_impact_easy>

    <high_impact_hard>
      <description>Major improvements requiring effort</description>
      <examples>
        - Restructure narrative arc
        - Rewrite unclear sections
        - Add missing research
      </examples>
      <action>Plan for revision</action>
    </high_impact_hard>

    <low_impact_easy>
      <description>Nice-to-have quick adjustments</description>
      <examples>
        - Add more filler words
        - Adjust minor timing
        - Polish transitions
      </examples>
      <action>Do if time permits</action>
    </low_impact_easy>

    <low_impact_hard>
      <description>Not worth the effort</description>
      <examples>
        - Perfect symmetry in segments
        - Extensive rewrites for style
      </examples>
      <action>Skip for now</action>
    </low_impact_hard>
  </priority_matrix>
</improvement_prioritization>
```

## Automated Quality Gates

### 🚦 Pass/Fail Decision System

```python
class QualityGateSystem:
    """
    Automated decision system for content approval
    """

    def __init__(self):
        self.thresholds = {
            "must_pass": {
                "factual_accuracy": 0.90,
                "brand_consistency": 0.85,
                "no_harmful_content": 1.00
            },
            "should_pass": {
                "engagement": 0.80,
                "clarity": 0.85,
                "dialogue_quality": 0.75
            },
            "overall_minimum": 0.85
        }

    def evaluate_for_release(self, evaluation_scores):
        """Determine if content passes quality gates"""

        # Check must-pass criteria
        for criterion, threshold in self.thresholds["must_pass"].items():
            if evaluation_scores.get(criterion, 0) < threshold:
                return {
                    "decision": "FAIL",
                    "reason": f"{criterion} below threshold",
                    "score": evaluation_scores[criterion],
                    "required": threshold,
                    "action": "Must fix before release"
                }

        # Check overall score
        overall = self.calculate_overall(evaluation_scores)
        if overall < self.thresholds["overall_minimum"]:
            return {
                "decision": "REVISE",
                "reason": "Overall quality below standard",
                "score": overall,
                "required": self.thresholds["overall_minimum"],
                "action": "Improve weak areas"
            }

        # All checks passed
        return {
            "decision": "PASS",
            "score": overall,
            "strengths": self.identify_strengths(evaluation_scores),
            "minor_improvements": self.suggest_minor_improvements(evaluation_scores)
        }

    def revision_guidance(self, failed_evaluation):
        """Provide specific guidance for revision"""

        return f"""
        <revision_requirements>
          <failed_criterion>{failed_evaluation['reason']}</failed_criterion>
          <current_score>{failed_evaluation['score']}</current_score>
          <required_score>{failed_evaluation['required']}</required_score>

          <revision_steps>
            1. Focus on {failed_evaluation['reason']}
            2. Review rubric for this criterion
            3. Make specific improvements
            4. Re-evaluate before resubmission
          </revision_steps>

          <estimated_effort>
            {self.estimate_revision_time(failed_evaluation)}
          </estimated_effort>
        </revision_requirements>
        """
```

## Performance Tracking Systems

### 📈 Quality Metrics Dashboard

```python
class QualityMetricsDashboard:
    """
    Track quality trends over time
    """

    def __init__(self):
        self.metrics_history = []
        self.targets = {
            "episode_quality": 0.90,
            "consistency": 0.85,
            "improvement_rate": 0.02  # 2% per month
        }

    def track_episode(self, episode_data):
        """Record quality metrics for an episode"""

        metrics = {
            "episode_number": episode_data["number"],
            "date": episode_data["date"],
            "overall_score": episode_data["quality_score"],
            "sub_scores": {
                "accuracy": episode_data["accuracy"],
                "engagement": episode_data["engagement"],
                "clarity": episode_data["clarity"],
                "brand": episode_data["brand_consistency"]
            },
            "revision_needed": episode_data["quality_score"] < 0.85,
            "strengths": episode_data["top_strengths"],
            "improvements": episode_data["improvements_made"]
        }

        self.metrics_history.append(metrics)
        return self.analyze_trends()

    def analyze_trends(self):
        """Identify quality trends and patterns"""

        recent_episodes = self.metrics_history[-10:]

        return {
            "average_quality": sum(e["overall_score"] for e in recent_episodes) / len(recent_episodes),
            "trending": self.calculate_trend(recent_episodes),
            "consistent_strengths": self.identify_consistent_strengths(recent_episodes),
            "recurring_issues": self.identify_recurring_issues(recent_episodes),
            "improvement_areas": self.suggest_focus_areas(recent_episodes)
        }

    def generate_report(self):
        """Monthly quality report"""

        return f"""
        # Quality Report - {datetime.now().strftime('%B %Y')}

        ## Overall Performance
        - Average Quality Score: {self.calculate_average()}
        - Episodes Meeting Target: {self.count_passing()}%
        - Improvement Rate: {self.calculate_improvement()}%

        ## Strengths
        {self.list_strengths()}

        ## Areas for Improvement
        {self.list_improvements()}

        ## Recommendations
        {self.generate_recommendations()}
        """
```

## Real-World Evaluation Examples

### 🎬 Example 1: High-Quality Episode Evaluation

```python
# Actual evaluation of Episode 42: "The Fermi Paradox"
fermi_paradox_evaluation = """
<evaluation_report>
  <episode>42: The Fermi Paradox</episode>
  <date>2025-01-10</date>

  <scores>
    <factual_accuracy>4.8/5.0</factual_accuracy>
    <engagement>4.9/5.0</engagement>
    <clarity>4.7/5.0</clarity>
    <brand_consistency>5.0/5.0</brand_consistency>
    <dialogue_naturalness>4.8/5.0</dialogue_naturalness>
    <intellectual_humility>5.0/5.0</intellectual_humility>
  </scores>

  <overall_score>0.94 (A)</overall_score>

  <strengths>
    1. Perfect embodiment of "Nobody Knows" theme
       - "We could be alone, or surrounded. We just don't know."
    2. Exceptional hook: "The universe is talking. Is anyone listening?"
    3. Natural dialogue with authentic reactions
       - Alex: "Wait, WHAT? 2 trillion galaxies?"
       - Jordan: "I know, right? The numbers break your brain."
  </strengths>

  <minor_improvements>
    1. Drake Equation explanation slightly rushed (minute 12-13)
       Suggestion: Add 30-second breather for absorption

    2. One uncited statistic about exoplanet discovery rate
       Action: Add source reference in show notes
  </minor_improvements>

  <decision>PASS - Excellent Quality</decision>

  <listener_feedback_prediction>
    Expected rating: 4.8-4.9/5.0
    Likely praise: Mind-blowing scale, humble approach
    Potential critique: Want more on specific solutions
  </listener_feedback_prediction>
</evaluation_report>
"""
```

### 🎬 Example 2: Episode Requiring Revision

```python
# Evaluation requiring revision
revision_needed_example = """
<evaluation_report>
  <episode>Draft: Quantum Computing</episode>

  <scores>
    <factual_accuracy>3.2/5.0</factual_accuracy>
    <engagement>4.0/5.0</engagement>
    <clarity>2.8/5.0</clarity>
    <brand_consistency>3.5/5.0</brand_consistency>
  </scores>

  <overall_score>0.68 (D)</overall_score>

  <critical_issues>
    1. ACCURACY: Incorrect explanation of superposition
       Current: "Qubits are in all states at once"
       Correct: "Qubits exist in probability distributions until measured"

    2. CLARITY: Technical jargon without explanation
       Problems: "decoherence", "entanglement", "quantum supremacy"
       Solution: Add simple analogies for each term

    3. HUMILITY: Too certain about disputed claims
       Issue: "Quantum computers will definitely replace classical"
       Better: "Some experts believe... others argue..."
  </critical_issues>

  <revision_requirements>
    1. Fact-check with physics sources (2 hours)
    2. Simplify technical sections (1 hour)
    3. Add uncertainty acknowledgments (30 minutes)

    Estimated revision time: 3.5 hours
  </revision_requirements>

  <decision>REVISE - Multiple criteria below threshold</decision>
</evaluation_report>
"""
```

## 🚀 Quick Evaluation Templates

```python
# Rapid quality check
QUICK_EVALUATION = """
Evaluate this podcast content:
{content}

Rate 1-5 on:
- Accuracy
- Engagement
- Clarity
- Brand fit

Provide:
- Overall score
- One strength
- One improvement
- Pass/Revise decision
"""

# Comprehensive evaluation
DETAILED_EVALUATION = """
<comprehensive_evaluation>
  <content>{content}</content>

  <evaluate_all_criteria>
    - All 15 criteria with scores
    - Evidence for each score
    - Weighted overall calculation
  </evaluate_all_criteria>

  <generate_feedback>
    - Top 3 strengths
    - Top 3 improvements
    - Specific revision guidance
  </generate_feedback>

  <quality_gate_check>
    - Pass/Fail decision
    - If fail, requirements for passing
  </quality_gate_check>
</comprehensive_evaluation>
"""
```

## 📊 Evaluation Best Practices

1. **Consistency**: Use same rubrics across all episodes
2. **Evidence-Based**: Always cite specific examples
3. **Constructive**: Focus on actionable improvements
4. **Balanced**: Acknowledge strengths alongside weaknesses
5. **Objective**: Base on criteria, not preferences
6. **Efficient**: Prioritize high-impact feedback
7. **Trackable**: Monitor trends over time

---

*Remember: Quality evaluation isn't about perfection—it's about consistent improvement and maintaining standards that serve your audience.*

</document>
