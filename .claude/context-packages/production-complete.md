# Complete Production Context Package



## Production constants

<technical>
Production constants define the complete configuration for podcast episode creation, including TTS models, quality thresholds, cost targets, and file naming conventions. These values are embedded here for complete LLM context without external lookups.
</technical>

<simple>
These are all the specific settings and numbers the AI needs to make podcasts correctly - like recipe measurements that need to be exact every time.
</simple>

TTS_MODEL
eleven_turbo_v2_5
ElevenLabs Turbo v2.5 - Final decision after comprehensive research
TTS_VOICE
Amelia (ZF6FPAbjXT4488VcRRnw)
Selected voice optimized for narrative podcast content
EPISODE_TARGET_DURATION
25-30 minutes
Target duration for each episode
EPISODE_TARGET_CHARACTERS
18000-22000
Character count for target duration
COST_TARGET_PER_EPISODE
$4-5
Target cost per episode (vs traditional $800-3500)
QUALITY_THRESHOLD_COMPREHENSION
0.85
Minimum comprehension score for general audience
QUALITY_THRESHOLD_BRAND
0.90
Minimum brand consistency score for intellectual humility theme
QUALITY_THRESHOLD_ENGAGEMENT
0.80
Minimum engagement score to maintain listener interest
QUALITY_THRESHOLD_TECHNICAL
0.85
Minimum technical accuracy score for factual correctness

## Production agents

<technical>
The production pipeline uses a 4-agent system with orchestration: Research Coordinator, Script Writer, Audio Synthesizer, and Quality Evaluator. Each agent has specific prompts, input/output formats, and quality criteria embedded here for complete operational context.
</technical>

<simple>
Think of this as four AI specialists working together like a podcast production team - one gathers information, one writes the script, one creates the audio, and one checks the quality.
</simple>

Research Coordinator
Gather and synthesize information for episode topics
Topic description, research requirements
Structured research package with facts, quotes, examples
Accuracy ≥0.90, Source diversity ≥3, Fact verification required
Script Writer
Create engaging podcast script from research
Research package, episode structure template
Conversational script with intellectual humility theme
Comprehension ≥0.85, Brand consistency ≥0.90, Flow score ≥0.80
Audio Synthesizer
Convert script to high-quality audio
Final approved script
MP3 file using ElevenLabs Turbo v2.5 with Amelia voice
No synthesis errors, proper pacing, consistent voice
Quality Evaluator
Assess output against all quality thresholds
Script, audio file, production metrics
Quality scores and approval/rejection decision
All thresholds met: Comprehension, Brand, Engagement, Technical

## Production process

<technical>
The production workflow implements a sequential pipeline with quality gates, retry logic, and atomic commits. Each step validates inputs, executes the operation, validates outputs, and hands off to the next stage only upon successful completion.
</technical>

<simple>
Like an assembly line where each station checks the quality before passing the work to the next station, and if something's wrong, it goes back to be fixed.
</simple>


-


-

Research Phase
Research Coordinator
Fact-checking, source verification, completeness check
Research package with ≥3 diverse sources, all facts verified
Retry with expanded search terms, additional sources

-

Script Creation
Script Writer
Quality evaluation against all thresholds
All quality scores ≥ minimum thresholds
Revise script, retry up to 3 times, escalate if needed

-

Audio Synthesis
Audio Synthesizer
Audio quality check, duration verification
Clean audio file, target duration achieved
Regenerate audio, adjust script if necessary

-

Final Quality Check
Quality Evaluator
Comprehensive quality assessment
All quality thresholds met, episode approved
Return to appropriate stage for revision

## Production troubleshooting

<technical>
Common production issues include API failures, quality threshold failures, cost overruns, and timing issues. Each problem type has specific diagnostic steps and resolution procedures embedded here for immediate LLM access.
</technical>

<simple>
When things go wrong during podcast creation, these are the specific problems you might encounter and exactly how to fix them.
</simple>

ElevenLabs API Failure
Audio synthesis step fails, API timeout errors
Check API key, verify credit balance, test with shorter text
Retry with exponential backoff, split text if too long, verify credentials
Quality Threshold Failure
Script or audio doesn't meet minimum quality scores
Identify which threshold failed, analyze specific issues
Revise content, adjust prompts, retry with improvements
Cost Overrun
Episode cost exceeds $5 target
Review token usage, API calls, TTS character count
Optimize prompts, reduce script length, batch operations

## Episode structure

<technical>
Standard episode structure optimized for the "Nobody Knows" podcast theme of intellectual humility. Template includes specific segment types, timing guidelines, and transition patterns for consistent quality.
</technical>

<simple>
This is the basic recipe for every podcast episode - the standard ingredients and order that makes each episode feel consistent and professional.
</simple>

Hook listeners, introduce topic, set expectations
Conversational, curious, humble approach to complex topics
Topic introduction, why it matters, what we'll explore
Explore the topic with intellectual humility
Balanced perspective, acknowledge unknowns, multiple viewpoints
Key concepts, examples, what we know vs don't know
Synthesize insights, acknowledge limitations, inspire curiosity
Reflective, encouraging further exploration
Key takeaways, remaining questions, call to curiosity

---

*Converted from XML to Markdown for elegant simplicity*
*Original: production-complete.xml*
*Conversion: Mon Aug 18 00:01:19 EDT 2025*
