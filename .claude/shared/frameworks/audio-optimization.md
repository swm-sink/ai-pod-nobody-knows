# Audio Optimization Framework for ElevenLabs Turbo V2



## Overview
Framework Overview
This framework ensures all scripts are optimized for ElevenLabs Turbo V2 TTS synthesis,
requiring zero post-processing while maintaining natural speech patterns.

## Text formatting
Text Formatting Requirements
Numbers and Quantities
Spell out completely

**Example:**
"twenty twenty-five"
"2025"
"one hundred and forty-five"
"145"
Percentages and Fractions
Spell out with "percent"

**Example:**
"ninety-nine percent"
"99%"
"one half", "three quarters"
"1/2", "3/4"
Abbreviations and Acronyms
Expand all abbreviations

**Example:**
"application programming interface"
"API"
"artificial intelligence"
Exception: well-known like "AI" can be kept if used consistently
Symbols and Special Characters
Describe all symbols

**Example:**
"leads to", "approximately", "equals"
"→", "≈", "="
"degrees Celsius", "dollars"
"°C", "$"

## Ssml integration
SSML Integration
Approved Elements
&lt;break time="0.3s" />
&lt;break time="0.5s" />
&lt;break time="0.7s" />
&lt;break time="1.0s" />
&lt;prosody rate="95%" pitch="+2%" volume="medium">emphasized content&lt;/prosody>
&lt;phoneme alphabet="cmu" ph="pronunciation">word&lt;/phoneme>
Use sparingly
Usage Guidelines
Maximum 3-4 break tags per segment
After complex concepts for processing time
At natural comma breaks
Before major topic transitions
Use prosody only for genuinely important points

## Speech patterns
Natural Speech Patterns
Sentence Structure
25 words (hard limit)
15 words (target)
Mix short (5-10), medium (10-20), long (20-25)
Contractions for Natural Flow
we'll, you're, can't, won't, that's, it's, there's
Every 100-150 words
Maintain conversational tone
Conversational Markers
Every 300-400 words
Right, Exactly
Now, So, But here's the thing
You know what's fascinating?

## Forbidden elements
Forbidden Elements (Will Break TTS)
Meta-Directions
[pause], [emphasis], [music]
(aside), (laughs), (sighs)
Stage directions of any kind
Unpronounceable Notation
Mathematical symbols: ∑, ∫, √
Arrows: →, ←, ↔
Brackets: [ ], { }, &lt; >
Special characters: @, #, &amp;
Problematic Abbreviations
e.g., i.e., etc., vs.
Dr., Mr., Ms., Prof.
Units: km, kg, cm (spell out)

## Experience optimization
Audio Experience Optimization
Cognitive Load Management
Maximum 1 per 90 seconds
5-10 seconds between complex ideas
Repeat key terms 3 times with variations
Attention Management
Every 2-3 minutes
Alternate high/low intensity
Clear transitions between segments
Memory-Friendly Design
Everything must work audio-only
Linear progression without "looking back"
Key concepts reinforced naturally

## Script formatting
Script Formatting for TTS
Opening Pattern
Episode [Number]: [Title]
&lt;break time="0.5s" />
[Hook sentence one.] [Hook sentence two.] [Hook sentence three with question?]
&lt;break time="0.7s" />
Let's explore...
Segment Transitions
&lt;break time="0.7s" />
This brings us to an interesting point. &lt;break time="0.3s" />
[New segment content...]
Emphasis Pattern
This is &lt;prosody rate="95%" pitch="+2%">particularly fascinating&lt;/prosody> because...

## Quality checklist
Quality Checklist
Pre-Production
All numbers spelled out
All abbreviations expanded
All symbols described
No forbidden elements
Speech Patterns
Sentences under 25 words
Natural contractions included
Conversational markers present
SSML tags used sparingly
Audio Experience
Works without visual aids
Sequential information flow
Appropriate processing time
Attention management included

## Integration notes
Integration Notes
For Script-Writer Agent

- 
        

- 
          Apply formatting during script generation

- 
          Use SSML tags strategically

- 
          Maintain natural speech patterns

- 
          Check against forbidden elements
For Quality-Evaluator Agent

- 
        

- 
          Validate TTS compatibility

- 
          Check SSML usage frequency

- 
          Verify natural speech patterns

- 
          Ensure audio-only clarity
For Audio-Synthesizer Agent (Future)

- 
        

- 
          Direct ElevenLabs Turbo V2 input

- 
          No post-processing required

- 
          Consistent quality output

- 
          Natural speech synthesis
Audio Quality Gates
Agent Integration
Session Coordination

---

*Converted from XML to Markdown for elegant simplicity*
*Original: audio-optimization.xml*
*Conversion: Mon Aug 18 00:01:18 EDT 2025*
