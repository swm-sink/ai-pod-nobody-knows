# Simple Solo Project Setup



## Project approach
Project Approach: Keep It Simple

<technical>
Minimum viable complexity with focused API integration for hobby-scale podcast production
</technical>

<simple>
Use only what you need, when you need it - like cooking with just three ingredients instead of twenty
</simple>

This teaches you to avoid over-engineering and focus on delivering value

## Current architecture
Current Architecture
Claude Code built-in AI (script writing, quality checks)
Perplexity MCP (research)
ElevenLabs MCP (audio synthesis)
Planning and learning materials
OpenRouter API (unified model access)
Langfuse (evaluation and observability)

## Api configuration
API Keys Configuration
PERPLEXITY_API_KEY
Active
ELEVENLABS_API_KEY
Active
OPENROUTER_API_KEY
Reserved - NOT USED YET
LANGFUSE_API_KEY
Reserved - NOT USED YET

## Budget limits
Solo/Hobby Budget Limits
$5.00 max
$10.00 max
$4.00
10 requests/minute
5 requests/minute

## Setup steps
Simple Next Steps

-

claude mcp add perplexity
https://docs.perplexity.ai/guides/mcp-server

-

git clone https://github.com/elevenlabs/elevenlabs-mcp.git
cd elevenlabs-mcp
npm install
claude mcp add elevenlabs

-

Research agent uses Perplexity
Script writer uses Claude Code (built-in)
Quality evaluator uses Claude Code (built-in)
Audio synthesizer uses ElevenLabs

## Scope definition
Scope Definition
Multiple AI provider management
Complex team collaboration setup
Enterprise-grade monitoring
Cloud secret managers
Staging/production environments
Email alerts
Database storage
Simple .env file for API keys
Basic cost tracking
Native Claude Code agents
Two external MCPs (Perplexity + ElevenLabs)
Mock mode for testing
Dry run capability

## Learning focus
Learning Focus
Learn multi-agent orchestration with Claude Code
Don't worry about OpenRouter/Level 4 until Level 2 works
This is a hobby project, not enterprise software

## Quick reference
Quick Reference
python .claude/scripts/test_api_keys.py
echo $PERPLEXITY_API_KEY
echo $ELEVENLABS_API_KEY
ENABLE_MOCK_MODE=true claude /produce-episode

## Success criteria
Success Criteria
Can research topics with Perplexity
Can write scripts with Claude Code
Can evaluate quality with Claude Code
Can generate audio with ElevenLabs
Total cost per episode less than $5

## Important notes
Important Notes
OpenRouter is for Level 4 ONLY (future Python platform)
Level 2 uses Claude Code natively (no extra AI API needed)
Focus on getting basics working first
Don't over-engineer for a solo project
Build something that works, then improve it
Build the perfect system before producing anything
Ready to install MCPs and test
Install Perplexity and ElevenLabs MCPs
Environment Management
MCP Setup Guide
Project Phases

---

*Converted from XML to Markdown for elegant simplicity*
*Original: simple-setup.xml*
*Conversion: Mon Aug 18 00:01:17 EDT 2025*
