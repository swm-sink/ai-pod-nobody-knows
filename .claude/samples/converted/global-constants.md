# Global Constants and Standards



## Architecture constants
LEVEL_1_DEV
.claude/level-1-dev/
Development Platform - Tools that build the production system
LEVEL_2_PRODUCTION
.claude/level-2-production/
Podcast Production - Native Claude Code podcast production
LEVEL_3_PLATFORM
.claude/level-3-platform-dev/
Platform Planning - Design future coded platform
LEVEL_4_CODED
.claude/level-4-coded/
Future Implementation (REQUIRES EXPLICIT APPROVAL)

## File naming conventions
DEV_TOOLS_PATTERN
*-dev.md
Development tools and utilities
PRODUCTION_TOOLS_PATTERN
*-production.md
Production tools and workflows
SESSION_FILENAME_PATTERN
[type]_YYYYMMDD_HHMM.json
Session tracking files with timestamp
EPISODE_FILENAME_PATTERN
ep_XXX_*
Episode files where XXX is episode number

## Quality standards
BRAND_VOICE_TARGET
0.90
Minimum brand consistency score (0-1 scale)
QUALITY_SCORE_TARGET
0.85
Minimum overall quality score for acceptance
EPISODE_DURATION_MINUTES
27
Target episode duration in minutes
EPISODE_WORD_COUNT_MIN
3900
Minimum word count for episode script
EPISODE_WORD_COUNT_MAX
4100
Maximum word count for episode script
COST_LIMIT_PER_EPISODE
9.00
Maximum cost per episode in USD
READABILITY_SCORE_MIN
60
Minimum Flesch-Kincaid readability score
READABILITY_SCORE_MAX
70
Maximum Flesch-Kincaid readability score

```bash

```bash
All quality metrics within acceptable ranges

## Production pipeline
STAGE_RESEARCH
research
Gather and validate information about the topic
STAGE_SCRIPT_WRITING
script_writing
Create narrative structure and episode script
STAGE_AUDIO_SYNTHESIS
audio_synthesis
Generate speech from completed script
STAGE_QUALITY_EVALUATION
quality_evaluation
Validate all outputs against quality standards

## Mcp server limits
PERPLEXITY_LIMIT
3.00
Maximum spend per episode on Perplexity research (USD)
ELEVENLABS_LIMIT
2.00
Maximum spend per episode on ElevenLabs audio synthesis (USD)
WEB_SEARCH_LIMIT
free-tier
Use free tier only initially for web search

## Error recovery
MAX_RETRIES
3
Maximum number of retry attempts before failure
RETRY_BACKOFF_INITIAL
30
Initial retry delay in seconds
RETRY_BACKOFF_SECOND
60
Second retry delay in seconds
RETRY_BACKOFF_FINAL
120
Final retry delay in seconds
SAVE_PROGRESS_TRIGGER
stage_completion
When to save progress checkpoints
SESSION_TIMEOUT
60
Maximum session duration in minutes before timeout

```bash

```bash
All error recovery parameters within reasonable operational bounds

## Thinking modes
THINKING_BASIC
think
Simple analysis and straightforward reasoning
THINKING_ENHANCED
think hard
Complex reasoning and multi-step analysis
THINKING_DEEP
think harder
Multi-perspective analysis and deep consideration
THINKING_MAXIMUM
ultrathink
Comprehensive evaluation for most complex problems
Troubleshooting guide that uses these constants for validation
Cost optimization strategies referencing these budget limits

---

*Converted from XML to Markdown for elegant simplicity*
*Original: global-constants.xml*
*Conversion: Mon Aug 18 00:01:19 EDT 2025*
