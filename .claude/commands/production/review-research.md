---
name: review-research
description: Review and analyze completed research packages before production
---

# Review Research - Research Package Inspector

Review completed research packages to assess quality and completeness before proceeding to production.

## Usage

```
/review-research [research_session_path]
```

## Examples

```
/review-research sessions/ep_001_20250817/research/
/review-research  # Reviews most recent research session
```

## Analysis Provided

### Research Quality Assessment
- **Completeness**: Verify all research components present
- **Depth**: Evaluate research thoroughness and expert source quality
- **Currency**: Check for 2024-2025 sources and recent developments
- **Balance**: Assess multiple perspectives and viewpoint coverage

### Content Review
- **Expert Quotes**: Quality and relevance of expert statements
- **Source Verification**: Credibility and authority of sources
- **Research Gaps**: Identification of areas needing deeper exploration
- **Question Quality**: Assessment of generated research questions

### Cost Analysis
- **Research Costs**: Breakdown of Perplexity API usage
- **Cost Efficiency**: Value assessment of research investment
- **Budget Impact**: Projection for remaining production costs

## Output Format

```markdown
# Research Review Report
## Executive Summary
- Overall Quality Score: X/10
- Research Completeness: X%
- Recommended Action: [Proceed/Enhance/Redo]

## Detailed Analysis
### Strengths
- [Key strengths identified]

### Areas for Improvement
- [Specific enhancement suggestions]

### Expert Source Quality
- [Assessment of expert quotes and authority]

### Research Depth Assessment
- [Coverage and thoroughness evaluation]

## Cost Analysis
- Total Research Cost: $X.XX
- Estimated Production Cost: $X.XX
- Cost Efficiency Rating: [High/Medium/Low]

## Recommendation
[Detailed recommendation on whether to proceed]
```

## Decision Support

Based on review:
- **Proceed**: Research meets quality standards for production
- **Enhance**: Specific areas need additional research
- **Redo**: Research quality insufficient, restart recommended

This review helps ensure research investment is maximized before expensive production begins.
