# Global Constants and Standards



## Architecture constants

<technical>
Simplified Production Architecture with separation of concerns focused on the core podcast production system. Development tools have been extracted to claude-code-builder for clear boundaries.
</technical>

<simple>
The basic building blocks that organize the project with clean separation between development tools (in claude-code-builder) and production system (here).
</simple>

PRODUCTION_SYSTEM
.claude/level-2-production/
Core podcast production system using native Claude Code agents
AGENT_DIRECTORY
.claude/agents/
Claude Code sub-agents for production pipeline
COMMAND_DIRECTORY
.claude/commands/
Slash commands for user interaction

## File naming conventions

<technical>
Standardized file naming conventions ensure consistent organization and prevent naming conflicts across the system. These patterns enable programmatic file discovery and maintain clear separation between development and production assets.
</technical>

<simple>
Consistent naming rules so everyone knows where to find things and what type of file they're looking at just from the name.
</simple>

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

<technical>
Quality assurance thresholds and validation criteria for automated systems. These metrics ensure consistent output quality and enable automated decision-making in the production pipeline.
</technical>

<simple>
The standards that determine if something is "good enough" to proceed - like grade thresholds in school.
</simple>

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

<technical>
Production pipeline stages define the sequential workflow for episode creation with clear stage boundaries and validation checkpoints. Each stage has specific inputs, outputs, and success criteria.
</technical>

<simple>
The step-by-step process for making each episode, like an assembly line where each station does one job.
</simple>

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

<technical>
MCP (Model Context Protocol) server cost limits and usage constraints to prevent budget overruns and ensure sustainable operation. These limits enable cost-controlled API usage across different service providers.
</technical>

<simple>
Spending limits for different AI services to keep costs under control - like having a budget for different types of tools.
</simple>

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

<technical>
Error recovery constants define resilience patterns for handling failures in distributed AI systems. These values balance reliability against performance, implementing exponential backoff and circuit breaker patterns.
</technical>

<simple>
Rules for what to do when things go wrong - like how many times to try again and how long to wait between attempts.
</simple>

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

<technical>
Claude Code thinking mode specifications for different complexity levels of analysis. These modes optimize computational resources while ensuring appropriate depth of reasoning for different types of problems.
</technical>

<simple>
Different levels of "thinking power" to use depending on how complex the problem is - like using a calculator for simple math but a computer for complex calculations.
</simple>

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
*Original: 00_global_constants.xml*
*Conversion: Mon Aug 18 00:01:11 EDT 2025*
