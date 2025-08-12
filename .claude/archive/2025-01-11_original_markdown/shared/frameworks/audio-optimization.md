# Audio Optimization Framework for ElevenLabs Turbo V2

## Overview
This framework ensures all scripts are optimized for ElevenLabs Turbo V2 TTS synthesis, requiring zero post-processing while maintaining natural speech patterns.

## Text Formatting Requirements

### Numbers and Quantities
- **Numbers**: Spell out completely
  - ✅ "twenty twenty-five"
  - ❌ "2025"
  - ✅ "one hundred and forty-five"
  - ❌ "145"

### Percentages and Fractions
- **Percentages**: Spell out with "percent"
  - ✅ "ninety-nine percent"
  - ❌ "99%"
- **Fractions**: Use words
  - ✅ "one half", "three quarters"
  - ❌ "1/2", "3/4"

### Abbreviations and Acronyms
- **Expand All Abbreviations**:
  - ✅ "application programming interface"
  - ❌ "API"
  - ✅ "artificial intelligence"
  - ❌ "AI" (exception: well-known like "AI" can be kept if used consistently)

### Symbols and Special Characters
- **Describe All Symbols**:
  - ✅ "leads to", "approximately", "equals"
  - ❌ "→", "≈", "="
  - ✅ "degrees Celsius", "dollars"
  - ❌ "°C", "$"

## SSML Integration

### Approved Elements
```xml
<!-- Natural pauses -->
<break time="0.3s" />  <!-- Brief pause -->
<break time="0.5s" />  <!-- Medium pause -->
<break time="0.7s" />  <!-- Long pause -->
<break time="1.0s" />  <!-- Maximum pause -->

<!-- Subtle emphasis -->
<prosody rate="95%" pitch="+2%" volume="medium">
  emphasized content
</prosody>

<!-- Pronunciation guidance (use sparingly) -->
<phoneme alphabet="cmu" ph="pronunciation">word</phoneme>
```

### Usage Guidelines
- **Pause Frequency**: Maximum 3-4 break tags per segment
- **Pause Placement**:
  - After complex concepts for processing time
  - At natural comma breaks
  - Before major topic transitions
- **Emphasis**: Use prosody only for genuinely important points

## Natural Speech Patterns

### Sentence Structure
- **Maximum Length**: 25 words (hard limit)
- **Average Length**: 15 words (target)
- **Variety Pattern**: Mix short (5-10), medium (10-20), long (20-25)

### Contractions for Natural Flow
- **Use Strategically**:
  - "we'll", "you're", "can't", "won't"
  - "that's", "it's", "there's"
- **Frequency**: Every 100-150 words
- **Purpose**: Maintain conversational tone

### Conversational Markers
- **Frequency**: Every 300-400 words
- **Types**:
  - Acknowledgments: "Right", "Exactly"
  - Transitions: "Now", "So", "But here's the thing"
  - Engagement: "You know what's fascinating?"

## Forbidden Elements (Will Break TTS)

### Meta-Directions
- ❌ [pause], [emphasis], [music]
- ❌ (aside), (laughs), (sighs)
- ❌ Stage directions of any kind

### Unpronounceable Notation
- ❌ Mathematical symbols: ∑, ∫, √
- ❌ Arrows: →, ←, ↔
- ❌ Brackets: [ ], { }, < >
- ❌ Special characters: @, #, &

### Problematic Abbreviations
- ❌ e.g., i.e., etc., vs.
- ❌ Dr., Mr., Ms., Prof.
- ❌ Units: km, kg, cm (spell out)

## Audio Experience Optimization

### Cognitive Load Management
- **New Concepts**: Maximum 1 per 90 seconds
- **Processing Time**: 5-10 seconds between complex ideas
- **Reinforcement**: Repeat key terms 3 times with variations

### Attention Management
- **Curiosity Hooks**: Every 2-3 minutes
- **Energy Variation**: Alternate high/low intensity
- **Reset Points**: Clear transitions between segments

### Memory-Friendly Design
- **No Visual References**: Everything must work audio-only
- **Sequential Information**: Linear progression without "looking back"
- **Repetition Strategy**: Key concepts reinforced naturally

## Script Formatting for TTS

### Opening Pattern
```
Episode [Number]: [Title]

<break time="0.5s" />

[Hook sentence one.] [Hook sentence two.] [Hook sentence three with question?]

<break time="0.7s" />

Let's explore...
```

### Segment Transitions
```
<break time="0.7s" />

This brings us to an interesting point. <break time="0.3s" />

[New segment content...]
```

### Emphasis Pattern
```
This is <prosody rate="95%" pitch="+2%">particularly fascinating</prosody> because...
```

## Quality Checklist

### Pre-Production
- [ ] All numbers spelled out
- [ ] All abbreviations expanded
- [ ] All symbols described
- [ ] No forbidden elements

### Speech Patterns
- [ ] Sentences under 25 words
- [ ] Natural contractions included
- [ ] Conversational markers present
- [ ] SSML tags used sparingly

### Audio Experience
- [ ] Works without visual aids
- [ ] Sequential information flow
- [ ] Appropriate processing time
- [ ] Attention management included

## Integration Notes

### For Script-Writer Agent
1. Apply formatting during script generation
2. Use SSML tags strategically
3. Maintain natural speech patterns
4. Check against forbidden elements

### For Quality-Evaluator Agent
1. Validate TTS compatibility
2. Check SSML usage frequency
3. Verify natural speech patterns
4. Ensure audio-only clarity

### For Audio-Synthesizer Agent (Future)
1. Direct ElevenLabs Turbo V2 input
2. No post-processing required
3. Consistent quality output
4. Natural speech synthesis

---

*This framework ensures podcast scripts are perfectly optimized for ElevenLabs Turbo V2, creating natural, engaging audio content without any post-production requirements.*
