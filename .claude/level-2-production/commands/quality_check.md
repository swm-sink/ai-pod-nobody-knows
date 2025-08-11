Evaluate episode quality metrics: $ARGUMENTS

USAGE: /quality:check [project_name] [episode_file]

EVALUATION METRICS:
1. **Comprehension Score** (ROUGE/BLEU)
   - Clarity of explanations
   - Logical flow
   - Information accuracy

2. **Brand Consistency**
   - Voice alignment
   - Tone consistency
   - Intellectual humility presence

3. **Engagement Metrics**
   - Pacing analysis
   - Hook effectiveness
   - Call-to-action clarity

4. **Technical Quality**
   - Audio clarity
   - Duration compliance
   - Transition smoothness

SCORING:
- Each metric scored 0.0 to 1.0
- Weighted average for final score
- Pass/Fail based on project thresholds

EXAMPLE:
/quality:check nobody-knows ep15_audio.mp3

OUTPUT:
```json
{
  "episode": "ep15",
  "comprehension": 0.87,
  "brand_consistency": 0.92,
  "engagement": 0.85,
  "technical": 0.90,
  "overall": 0.89,
  "status": "PASS",
  "recommendations": []
}
```