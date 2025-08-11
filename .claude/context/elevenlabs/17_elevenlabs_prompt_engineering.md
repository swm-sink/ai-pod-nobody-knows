# ElevenLabs Prompt Engineering & Voice Control (2025)

## 🎯 Purpose of This Document
**For You**: Learn how to make AI voices sound natural, emotional, and engaging - the "director" skills for AI actors
**For AI**: Complete prompt engineering specifications, SSML usage, and audio control techniques

---

## 🎓 The Art of AI Voice Direction (Simple Explanation)

**Think of it like this**: You're a movie director, and the AI voice is your actor. You can't physically demonstrate, so you must communicate through:
1. **The script** (your text)
2. **Stage directions** (audio tags)
3. **Character notes** (voice settings)
4. **Pronunciation guides** (phoneme tags)

A good director gets amazing performances. A great director does it consistently!

---

## 📝 Core Prompt Engineering Principles

### The 250-Character Rule
```
❌ Bad: "Hello."
✅ Good: "Hello, and welcome to `PROJECT['name']`, the podcast that explores the vast ocean of human ignorance with curiosity and humility. I'm your host, and today we're diving into a fascinating paradox: the more we learn, the more we realize we don't know."

> **Reference**: Project name and theme from [Global Constants](../../00_GLOBAL_CONSTANTS.md#project-specifications)
```

**Why 250+ characters?**
- **Simple**: The AI needs context to understand HOW to speak
- **Technical**: Neural networks use surrounding text for prosody inference
- **Result**: More consistent, natural-sounding output

---

## 🎭 Eleven v3 Audio Tags (The Game Changer)

### Available Emotional Controls

> **Reference**: Complete audio tags list in [ElevenLabs Constants](./00_elevenlabs_constants.md#audio-tags)

Available tags include emotions (`[whispers]`, `[laughs]`, `[sighs]`), pacing (`[pauses]`, `[speaking quickly]`), and tone controls (`[excited]`, `[thoughtful]`, `[sarcastic]`).

**Note**: Audio tags only work with models listed in `AUDIO_TAG_COMPATIBLE_MODELS`.

### How to Use Audio Tags Effectively

**Example 1 - Building Suspense**:
```
"The data was conclusive... [pauses] or so we thought. [whispers] But hidden in the 
footnotes was something nobody noticed. [clears throat] Let me read it exactly as 
written: [normal voice] 'Results may vary under conditions not tested.' [sighs] 
Those seven words changed everything."
```

**Example 2 - Adding Personality**:
```
"So the physicist walks into the bar [laughs] - I know, I know, another physics 
joke - but hear me out! [clears throat] He orders a beer that exists in quantum 
superposition. The bartender says [pauses] 'That'll be $5 and not $5 simultaneously.' 
[laughs harder] Okay, maybe you had to be there... [sighs]"
```

### Audio Tag Best Practices

**DO**:
- Match tags to voice character
- Use sparingly for impact
- Test with different voices
- Combine for complex emotions

**DON'T**:
- Force incompatible emotions (whisper with shouty voice)
- Overuse (becomes unnatural)
- Expect 100% consistency
- Use with incompatible models

---

## 🎛️ Voice Settings Optimization

### The Three Sliders Explained

#### 1. Stability (0-100)
```
0 (Variable) ←────────────→ 100 (Monotone)
                    ↑
                 50-70
            (Sweet spot for podcasts)
```

**Simple**: How much the voice varies vs. stays consistent
**Technical**: Controls randomness in voice generation
**For Podcasts**: 50-70% for natural but reliable narration

#### 2. Similarity Boost (0-100)
```
0 (Creative) ←────────────→ 100 (Exact)
                    ↑
                 75-85
            (Recommended default)
```

**Simple**: How closely to match the original voice
**Technical**: Strength of voice embedding influence
**For Podcasts**: 75% for consistency across episodes

#### 3. Style Exaggeration (0-100) [v3 only]
```
0 (Neutral) ←────────────→ 100 (Theatrical)
                   ↑
                 20-40
            (Natural enhancement)
```

**Simple**: How much to amplify emotional expression
**Technical**: Magnifies prosodic features
**For Podcasts**: 30% for engaging but not overdramatic

### Settings by Content Type

**Interview/Conversation**:
- Stability: 45-55%
- Similarity: 75%
- Style: 20%

**Narration/Storytelling**:
- Stability: 60-70%
- Similarity: 80%
- Style: 30%

**Educational/Technical**:
- Stability: 70-80%
- Similarity: 85%
- Style: 10%

---

## 🔤 Pronunciation Control Systems

### Method 1: SSML Phoneme Tags (Technical Models)

**Compatible Models**: Flash v2, Turbo v2, English v1
**NOT Compatible**: Turbo v2.5, v3

**CMU Arpabet Example**:
```xml
The <phoneme alphabet="cmu" ph="T R AE P AH Z IY">trapezii</phoneme> muscle...
```

**IPA Example**:
```xml
The <phoneme alphabet="ipa" ph="trəˈpiːzi">trapezii</phoneme> muscle...
```

### Method 2: Pronunciation Dictionaries (All Models)

**Create a dictionary file** (`pronunciation.dict`):
```json
{
  "pronunciations": [
    {
      "word": "Kubernetes",
      "replacement": "koo-ber-net-eez"
    },
    {
      "word": "PostgreSQL", 
      "replacement": "post-gres-Q-L"
    },
    {
      "word": "AI",
      "replacement": "artificial intelligence"
    }
  ]
}
```

### Method 3: Creative Text Manipulation

**For models without phoneme support**:
```
Original: "The API returned an error"
Better: "The A.P.I. returned an error"
Or: "The A-P-I returned an error"

Original: "nginx server"
Better: "engine-x server"
```

---

## 📊 Prompt Engineering Patterns

### Pattern 1: The Context Sandwich
```
[Context Setup]
[Main Content]
[Context Reinforcement]
```

**Example**:
```
"Speaking as someone who's studied this for decades,
[Main points about quantum mechanics]
which is why, after all these years, I'm still amazed."
```

### Pattern 2: Rhythm Markers
```
Short sentence. Longer sentence with more detail. Back to short.
This creates natural rhythm. It prevents monotony. And it keeps 
listeners engaged throughout the episode.
```

### Pattern 3: Emotional Arcs
```
Start neutral → Build interest → Peak excitement → Thoughtful conclusion
```

**Example**:
```
"Let's discuss memory. [neutral]
But not just any memory - the kind that changes who you are. [building]
Imagine losing everything you know, every face, every name! [peak]
[pauses] Yet somehow... still being you. [thoughtful]"
```

---

## 🎯 Podcast-Specific Techniques

### Opening Hook Template
```python
def create_opening(topic, emotion="curious"):
    return f"""
    [clears throat] Have you ever wondered about {topic}? 
    [pauses] I mean, really wondered - to the point where you 
    question everything you thought you knew? [voice rises slightly]
    Welcome to Nobody Knows, where we embrace the beautiful uncertainty 
    of human knowledge. [warm tone] I'm your host, and today... 
    [voice drops, {emotion}] we're going somewhere unexpected.
    """
```

### Transition Techniques
```
Smooth: "Which brings us naturally to..."
Dramatic: "[pauses] But wait. [voice drops] There's more."
Questioning: "So you might be wondering..."
Surprising: "[laughs] Okay, this next part surprised even me..."
```

### Closing Patterns
```
Reflective: "[sighs thoughtfully] So what have we learned?"
Call-to-action: "Your homework, should you choose to accept it..."
Teaser: "[whispers] Next week's episode will blow your mind..."
Open-ended: "I'll leave you with this thought..."
```

---

## 🔧 Advanced Techniques

### Multi-Voice Conversations (v3)
```python
def create_dialogue(speaker1_text, speaker2_text):
    return f"""
    [Voice: Alex] {speaker1_text}
    [Voice: Sam] [different energy] {speaker2_text}
    [Voice: Alex] [reacting to Sam] Interesting point...
    """
```

### Dynamic Pacing
```
Fast section... [speaking quickly] when excitement builds...
[normal pace] returning to baseline...
[slowly, deliberately] when... making... a... crucial... point.
```

### Contextual Emphasis
```
The answer isn't what you'd expect.
The ANSWER isn't what you'd expect.  
The answer ISN'T what you'd expect.
The answer isn't what YOU'D expect.
```

---

## 💡 Troubleshooting Common Issues

### Problem: Inconsistent Emotion
**Solution**: Ensure 250+ character context around emotional tags

### Problem: Mispronunciation
**Solution**: Use pronunciation dictionary or creative spelling

### Problem: Robotic Sound
**Solution**: Vary sentence length and add natural breaks

### Problem: Wrong Emphasis
**Solution**: Use CAPS, punctuation, or restructure sentence

### Problem: Unnatural Pauses
**Solution**: Use ellipses (...) instead of [pause] tags

---

## 📈 Quality Metrics

### What Makes Good AI Narration?

1. **Comprehension**: Listeners understand first time
2. **Engagement**: Voice holds attention
3. **Naturalness**: Sounds human, not robotic
4. **Consistency**: Same quality throughout
5. **Emotion**: Appropriate feeling for content

### Testing Checklist
- [ ] Listen at 1.5x speed - still clear?
- [ ] Close eyes - can you stay engaged?
- [ ] Play for someone - do they notice it's AI?
- [ ] Check pronunciations - all correct?
- [ ] Emotional beats - do they land?

---

## 🎓 Learning Exercises

### Exercise 1: Emotion Ladder
Take one sentence and add increasing emotion:
1. Neutral: "The discovery changed everything."
2. Interested: "The discovery changed everything!"
3. Excited: "[voice rises] The discovery changed EVERYTHING!"
4. Mind-blown: "[gasps] The discovery... [pauses] changed... EVERYTHING!"

### Exercise 2: Pronunciation Practice
Create dictionaries for:
- Technical terms in your field
- Names of people/places
- Acronyms and abbreviations
- Brand names

### Exercise 3: Voice Character
Write the same content for:
- Enthusiastic teacher
- Skeptical scientist
- Storytelling grandparent
- News anchor

---

## 🚀 Implementation Code

### Prompt Optimizer Function
```python
def optimize_prompt(text, style="podcast"):
    """
    Enhances text for better AI narration
    """
    # Ensure minimum length
    if len(text) < 250:
        text = add_context(text)
    
    # Add style-specific markers
    if style == "podcast":
        text = add_podcast_markers(text)
    elif style == "educational":
        text = add_educational_structure(text)
    
    # Check for problem words
    text = fix_pronunciations(text)
    
    # Add emotional arc if long
    if len(text) > 1000:
        text = add_emotional_journey(text)
    
    return text
```

### Settings Configuration
```python
VOICE_SETTINGS = {
    # Reference from constants instead of hardcoding
"podcast_host": VOICE_SETTINGS_PRESETS['podcast_host'],
# See: ElevenLabs Constants for all voice setting presets
    "narrator": {
        "stability": 0.70,
        "similarity_boost": 0.80,
        "style": 0.20,
        "use_speaker_boost": False
    },
    "character": {
        "stability": 0.50,
        "similarity_boost": 0.70,
        "style": 0.40,
        "use_speaker_boost": True
    }
}
```

---

## 🎯 Your Podcast Application

### For "Nobody Knows" Episodes:

**Opening Formula**:
```
[clears throat] [warm but mysterious tone]
"There's something {adjective} about {topic}...
[pauses]
Something that {historical figure} discovered, but couldn't explain.
[voice drops]
Today, we journey into {metaphor for unknown}."
```

**Content Delivery**:
- Use stability: 65% for natural variation
- Add [sighs] for philosophical moments
- Include [laughs] for ironic observations
- Employ [whispers] for secrets/mysteries

**Closing Formula**:
```
"[thoughtfully] So we return to our central truth:
[pauses]
The more we know... [voice rises slightly]
the more we realize... [pauses]
nobody knows. [whispers]
[normal voice] Until next time, keep questioning."
```

---

## 🔮 Future-Proofing

### Coming Features (Expected 2025):
- More granular emotional controls
- Real-time prompt adjustment
- Context memory across sessions
- Automatic pronunciation learning

### Prepare Now:
- Document all pronunciation fixes
- Save successful prompt patterns
- Track which voices work best
- Build prompt template library

---

## 💡 Golden Rules

1. **Test Everything**: Same prompt, different voices = different results
2. **Document Winners**: Save prompts that work perfectly
3. **Iterate Rapidly**: Small changes, test, repeat
4. **Listen Like a User**: Not a developer
5. **Embrace Imperfection**: 90% perfect is better than 0% done

---

*Last Updated: January 2025*
*Based on ElevenLabs v3 alpha documentation and best practices*