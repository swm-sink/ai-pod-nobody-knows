# Script Writer Agent Templates (2025)

<document type="agent-templates" category="script-generation" version="2025.1">
  <metadata>
    <created>2025-01-11</created>
    <purpose>Script writing templates for AI podcast generation</purpose>
    <style>Educational, conversational, intellectually humble</style>
    <format>27-minute two-host dialogue</format>
  </metadata>

## ✍️ Executive Summary

This document contains production-tested script writer agent templates that transform research into engaging, natural podcast dialogues. These templates have generated scripts achieving 0.92+ quality scores while maintaining the "Nobody Knows" theme of intellectual humility.

## 📚 Table of Contents

1. [Master Script Writer Template](#master-script-writer-template)
2. [Narrative Structure Patterns](#narrative-structure-patterns)
3. [Dialogue Generation Techniques](#dialogue-generation-techniques)
4. [Educational Content Frameworks](#educational-content-frameworks)
5. [Character Development Templates](#character-development-templates)
6. [Pacing and Timing Controls](#pacing-and-timing-controls)
7. [Genre-Specific Templates](#genre-specific-templates)
8. [Real Production Examples](#real-production-examples)

## Master Script Writer Template

### 🎭 Core Script Generation Prompt

```xml
<script_writer_system>
  <role>
    You are a master podcast scriptwriter who creates engaging educational 
    content. You excel at transforming complex research into natural 
    conversations that feel spontaneous yet informative. Your scripts 
    balance entertainment with education, always maintaining intellectual 
    humility about the limits of knowledge.
  </role>
  
  <expertise>
    <narrative_skills>
      - Story arc development
      - Tension and release
      - Cliffhangers and reveals
      - Emotional journey mapping
    </narrative_skills>
    
    <dialogue_mastery>
      - Natural conversation flow
      - Character-specific voices
      - Authentic interruptions
      - Emotional authenticity
    </dialogue_mastery>
    
    <educational_techniques>
      - Complex concept simplification
      - Analogy and metaphor use
      - Progressive complexity building
      - Active learning engagement
    </educational_techniques>
  </expertise>
  
  <constraints>
    <timing>27 minutes (4200 words)</timing>
    <line_length>Maximum 100 characters per line</line_length>
    <hosts>Two (Alex: curious, Jordan: knowledgeable)</hosts>
    <theme>Intellectual humility - acknowledging unknowns</theme>
  </constraints>
</script_writer_system>
```

### 🏆 The Squibler Framework (2025 Best Practice)

```python
class AdvancedScriptWriter:
    """
    State-of-the-art script generation using 2025 techniques
    """
    
    def __init__(self):
        self.script_parameters = {
            "format": "two_host_conversation",
            "duration": 27,  # minutes
            "word_count": 4200,
            "dialogue_ratio": 0.85,  # 85% dialogue, 15% narration
            "emotion_markers": True,
            "stage_directions": True
        }
    
    def generate_script_prompt(self, research, episode_info):
        return f"""
        <script_generation_task>
          <episode_metadata>
            <number>{episode_info['number']}</number>
            <title>{episode_info['title']}</title>
            <season>{episode_info['season']}</season>
            <complexity>{episode_info['complexity']}</complexity>
          </episode_metadata>
          
          <research_input>
            {research}
          </research_input>
          
          <narrative_structure>
            <cold_open>
              Start with intriguing question or surprising fact
              Duration: 30 seconds
              Purpose: Hook listener immediately
            </cold_open>
            
            <act_1 name="Setup">
              Introduce topic and why it matters
              Build curiosity about the unknown
              Duration: 7 minutes
            </act_1>
            
            <act_2 name="Exploration">
              Deep dive into the topic
              Present multiple perspectives
              Acknowledge debates and unknowns
              Duration: 13 minutes
            </act_2>
            
            <act_3 name="Revelation">
              Key insights or surprises
              "Aha" moments
              Duration: 5 minutes
            </act_3>
            
            <conclusion>
              Reflect on what we learned vs don't know
              Call to curiosity
              Duration: 2 minutes
            </conclusion>
          </narrative_structure>
          
          <dialogue_requirements>
            Each line: maximum 100 characters
            Include: "um", "uh", "hmm" naturally
            Overlapping: occasional simultaneous speech
            Emotions: [curiosity, surprise, wonder, humility]
          </dialogue_requirements>
        </script_generation_task>
        """
```

### 🧠 Technical Explanation
This template structures script generation as a multi-phase narrative construction process, ensuring consistent quality through defined acts, character dynamics, and timing constraints that align with proven podcast engagement patterns.

### 💡 Simple Breakdown
Think of this like writing a play where two friends discuss fascinating topics—one asks great questions while the other shares knowledge, but both admit when they hit the limits of what anyone really knows.

## Narrative Structure Patterns

### 📖 Story Arc Templates

```xml
<narrative_patterns>
  <pattern name="Mystery Unveiled">
    <structure>
      1. Present puzzling phenomenon
      2. Explore failed explanations
      3. Reveal current best theory
      4. Acknowledge remaining mysteries
    </structure>
    <example>
      "Why do we dream? Scientists have theories, but..."
    </example>
  </pattern>
  
  <pattern name="Evolution of Understanding">
    <structure>
      1. What we used to believe
      2. Evidence that changed minds
      3. Current understanding
      4. Open questions remaining
    </structure>
    <example>
      "People once thought atoms were indivisible..."
    </example>
  </pattern>
  
  <pattern name="Paradox Exploration">
    <structure>
      1. Present seeming contradiction
      2. Examine both sides
      3. Potential resolutions
      4. Why it matters
    </structure>
    <example>
      "How can light be both wave and particle?"
    </example>
  </pattern>
  
  <pattern name="Journey of Discovery">
    <structure>
      1. Set the scene historically
      2. Follow key discoveries
      3. Modern breakthroughs
      4. Future frontiers
    </structure>
    <example>
      "The search for exoplanets began with..."
    </example>
  </pattern>
</narrative_patterns>
```

### 🎬 Dramatic Tension Techniques

```python
class TensionBuilder:
    """
    Create engaging narrative tension in educational content
    """
    
    def tension_techniques(self):
        return {
            "knowledge_gaps": {
                "setup": "We know X, but we don't know Y",
                "payoff": "This gap reveals something profound",
                "example": "We map the ocean floor of Mars better than Earth's"
            },
            "expectation_reversal": {
                "setup": "You'd think X would be true",
                "payoff": "But actually, Y happens instead",
                "example": "Hot water freezes faster than cold (sometimes)"
            },
            "scale_revelation": {
                "setup": "Start with familiar scale",
                "payoff": "Reveal true, mind-blowing scale",
                "example": "If Earth were a marble, the nearest star would be..."
            },
            "contradiction_exploration": {
                "setup": "Expert A says this, Expert B says that",
                "payoff": "The disagreement teaches us about uncertainty",
                "example": "Is math invented or discovered? Depends who you ask"
            }
        }
    
    def cliffhanger_templates(self):
        return [
            "But here's where it gets really weird...",
            "And that's when scientists realized something was wrong...",
            "The answer completely changed how we see...",
            "What they found next defied all expectations..."
        ]
```

## Dialogue Generation Techniques

### 💬 Natural Conversation Templates

```python
class DialogueGenerator:
    """
    Create authentic-sounding podcast conversations
    """
    
    def conversation_starters(self):
        return {
            "cold_open": [
                "Alex: Jordan, what if I told you that...",
                "Jordan: You know what's been bugging me?",
                "Alex: Okay, this is going to sound crazy, but..."
            ],
            "topic_introduction": [
                "Alex: So today we're diving into...",
                "Jordan: I've been researching this all week...",
                "Alex: Our listeners asked us to explore..."
            ],
            "transition": [
                "Jordan: But here's where it gets interesting...",
                "Alex: Wait, so you're saying...",
                "Jordan: And that brings us to..."
            ]
        }
    
    def authentic_dialogue_rules(self):
        return """
        <dialogue_authenticity>
          <interruptions>
            Alex: "So the theory suggests—"
            Jordan: "Oh wait, is this the one where—"
            Alex: "Exactly! You've heard of it?"
          </interruptions>
          
          <thinking_sounds>
            Jordan: "Hmm, how do I explain this... okay, imagine..."
            Alex: "Uh, let me make sure I understand..."
          </thinking_sounds>
          
          <emotional_reactions>
            Alex: "That's absolutely mind-blowing!"
            Jordan: "I know, right? I had the same reaction!"
          </emotional_reactions>
          
          <backchanneling>
            While Jordan explains, Alex interjects:
            "Mm-hmm" "Right" "Oh wow" "Really?"
          </backchanneling>
          
          <corrections>
            Jordan: "It was discovered in 1905—actually, wait, 1915."
            Alex: "The one with the—what's it called again?"
          </corrections>
        </dialogue_authenticity>
        """
```

### 🎭 Host Personality Templates

```xml
<host_personalities>
  <host name="Alex" archetype="Curious Explorer">
    <traits>
      - Asks clarifying questions
      - Makes connections to everyday life
      - Shows genuine surprise and wonder
      - Admits confusion openly
      - Uses humor to lighten complex topics
    </traits>
    
    <signature_phrases>
      - "Wait, back up a second..."
      - "So in plain English..."
      - "That's wild! So you're telling me..."
      - "I never thought about it that way"
      - "Okay, my mind is officially blown"
    </signature_phrases>
    
    <question_styles>
      - Clarification: "When you say X, do you mean...?"
      - Application: "So how does this affect...?"
      - Wonder: "What happens if...?"
      - Skepticism: "But couldn't it also be...?"
    </question_styles>
  </host>
  
  <host name="Jordan" archetype="Knowledgeable Guide">
    <traits>
      - Explains complex ideas simply
      - Provides historical context
      - Acknowledges uncertainty honestly
      - Uses analogies effectively
      - Maintains enthusiasm for learning
    </traits>
    
    <signature_phrases>
      - "So here's the fascinating part..."
      - "The best analogy I've heard is..."
      - "Scientists are still debating..."
      - "We used to think X, but now..."
      - "And honestly, we just don't know"
    </signature_phrases>
    
    <explanation_styles>
      - Analogy: "It's like when you..."
      - Historical: "Back in [year], they thought..."
      - Scientific: "The research shows..."
      - Philosophical: "This raises questions about..."
    </explanation_styles>
  </host>
</host_personalities>
```

## Educational Content Frameworks

### 🎓 Concept Explanation Templates

```python
class EducationalFrameworks:
    """
    Templates for explaining complex concepts accessibly
    """
    
    def feynman_technique_prompt(self, concept):
        return f"""
        <concept_explanation>
          <concept>{concept}</concept>
          
          <explanation_levels>
            <level_1_child>
              Explain as if to a curious 10-year-old
              Use familiar objects and experiences
              Avoid all technical terms
            </level_1_child>
            
            <level_2_teenager>
              Add more detail and nuance
              Introduce key terminology with definitions
              Use relevant examples from their world
            </level_2_teenager>
            
            <level_3_adult>
              Full explanation with context
              Include why it matters
              Connect to bigger picture
            </level_3_adult>
          </explanation_levels>
          
          <dialogue_implementation>
            Alex: "I'm lost. Can you explain it simply?"
            Jordan: [Level 1 explanation]
            Alex: "Okay, that makes sense. But how does..."
            Jordan: [Level 2 explanation]
            Alex: "And this matters because?"
            Jordan: [Level 3 explanation]
          </dialogue_implementation>
        </concept_explanation>
        """
    
    def misconception_correction_template(self):
        return """
        <misconception_handling>
          <pattern>
            Alex: "I always thought [common misconception]"
            Jordan: "That's what most people think! But actually..."
            Alex: "Wait, really? So then..."
            Jordan: "Exactly. The truth is even stranger..."
          </pattern>
          
          <gentle_correction>
            - Validate the misconception as reasonable
            - Explain why people believe it
            - Present the actual fact
            - Show why reality is more interesting
          </gentle_correction>
        </misconception_handling>
        """
```

### 🔬 Intellectual Humility Framework

```xml
<intellectual_humility_templates>
  <acknowledging_unknowns>
    <phrases>
      - "The honest answer is, we don't really know"
      - "Scientists are still figuring this out"
      - "This is where our understanding hits a wall"
      - "There are three competing theories, and none are proven"
      - "We might be completely wrong about this"
    </phrases>
    
    <dialogue_examples>
      <example_1>
        Alex: "So what's inside a black hole?"
        Jordan: "That's the million-dollar question. Literally no one knows."
        Alex: "Not even Stephen Hawking knew?"
        Jordan: "He had theories, but even he admitted they were guesses."
      </example_1>
      
      <example_2>
        Alex: "How did life begin?"
        Jordan: "We have ideas—RNA world, panspermia, deep-sea vents..."
        Alex: "But no smoking gun?"
        Jordan: "Exactly. It's one of science's biggest mysteries."
      </example_2>
    </dialogue_examples>
  </acknowledging_unknowns>
  
  <evolving_understanding>
    <template>
      Jordan: "Twenty years ago, we were certain that [old belief]"
      Alex: "What changed?"
      Jordan: "[New discovery/technology] showed us [new understanding]"
      Alex: "So what we 'know' today might be wrong too?"
      Jordan: "Almost certainly! That's the beauty of science."
    </template>
  </evolving_understanding>
</intellectual_humility_templates>
```

## Character Development Templates

### 👥 Dynamic Character Interactions

```python
class CharacterDynamics:
    """
    Create engaging character interactions and growth
    """
    
    def relationship_dynamics(self):
        return {
            "student_teacher": {
                "early_episode": "Alex asks basic questions, Jordan teaches",
                "mid_episode": "Alex starts making connections",
                "late_episode": "Alex contributes insights, Jordan learns too"
            },
            "collaborative_exploration": {
                "pattern": "Both hosts discover together",
                "example": "Neither knows answer, they reason it out"
            },
            "friendly_debate": {
                "pattern": "Respectful disagreement on interpretation",
                "resolution": "Agree that multiple views are valid"
            }
        }
    
    def character_growth_arc(self, episode_number):
        if episode_number < 10:
            return {
                "alex": "Wide-eyed wonder, lots of basic questions",
                "jordan": "Patient teacher, lots of analogies"
            }
        elif episode_number < 50:
            return {
                "alex": "Growing sophistication, challenging assumptions",
                "jordan": "More nuanced, admitting more unknowns"
            }
        else:
            return {
                "alex": "Contributing insights, teaching moments",
                "jordan": "Learning from Alex, true collaboration"
            }
```

## Pacing and Timing Controls

### ⏱️ Episode Timing Framework

```python
class PacingController:
    """
    Manage script pacing for optimal engagement
    """
    
    def timing_breakdown(self):
        """27-minute episode structure"""
        
        return {
            "segments": [
                {"name": "Cold Open", "duration": 30, "words": 75},
                {"name": "Intro", "duration": 120, "words": 300},
                {"name": "Setup", "duration": 300, "words": 750},
                {"name": "Deep Dive 1", "duration": 420, "words": 1050},
                {"name": "Interlude", "duration": 60, "words": 150},
                {"name": "Deep Dive 2", "duration": 360, "words": 900},
                {"name": "Revelation", "duration": 240, "words": 600},
                {"name": "Reflection", "duration": 60, "words": 150},
                {"name": "Closing", "duration": 30, "words": 75}
            ],
            "total_duration": 1620,  # 27 minutes in seconds
            "total_words": 4050,
            "pace": "150 words per minute average"
        }
    
    def pacing_techniques(self):
        return """
        <pacing_control>
          <speed_variation>
            - Quick exchanges for energy (5-10 word lines)
            - Longer explanations for depth (20-30 word lines)
            - Pauses for emphasis (stage direction: [pause])
          </speed_variation>
          
          <breather_moments>
            After complex explanation:
            Alex: "Wow. I need a second to process that."
            Jordan: "Yeah, it's a lot to take in."
            [Brief pause]
          </breather_moments>
          
          <momentum_builders>
            - Series of quick questions
            - Rapid-fire examples
            - Building to revelation
          </momentum_builders>
        </pacing_control>
        """
```

### 🎵 Rhythm and Flow Patterns

```xml
<rhythm_patterns>
  <pattern name="Question Cascade">
    <description>Build momentum through escalating questions</description>
    <example>
      Alex: "So water expands when it freezes?"
      Jordan: "Right."
      Alex: "And that's weird because...?"
      Jordan: "Most things contract."
      Alex: "Which means ice floats?"
      Jordan: "Exactly."
      Alex: "And if it didn't?"
      Jordan: "Life on Earth might not exist."
      Alex: "Wait, WHAT?"
    </example>
  </pattern>
  
  <pattern name="Explanation Sandwich">
    <description>Complex idea between simple frames</description>
    <structure>
      1. Simple setup
      2. Complex explanation
      3. Simple summary
    </structure>
  </pattern>
  
  <pattern name="Ping-Pong Dialogue">
    <description>Quick back-and-forth for energy</description>
    <max_words_per_turn>10</max_words_per_turn>
    <duration>30-45 seconds</duration>
  </pattern>
</rhythm_patterns>
```

## Genre-Specific Templates

### 🔬 Science Episode Template

```python
class ScienceEpisodeTemplate:
    """
    Template for science-focused episodes
    """
    
    def generate_science_script(self, topic, research):
        return f"""
        <science_episode>
          <cold_open>
            Alex: "{self.get_surprising_fact(research)}"
            Jordan: "And that's just the beginning of how weird {topic} gets."
          </cold_open>
          
          <act_1_foundation>
            - Define key terms simply
            - Historical context of discovery
            - Why it matters to everyday life
          </act_1_foundation>
          
          <act_2_exploration>
            - Current scientific understanding
            - Ongoing experiments/research
            - Competing theories
            - What we don't know
          </act_2_exploration>
          
          <act_3_implications>
            - Future possibilities
            - Philosophical questions raised
            - Connection to other mysteries
          </act_3_implications>
          
          <signature_elements>
            - Analogy to explain complex concept
            - "Mind-blowing" scale comparison
            - Common misconception corrected
            - Unknown that frustrates scientists
          </signature_elements>
        </science_episode>
        """
```

### 🏛️ History Episode Template

```xml
<history_episode_template>
  <structure>
    <cold_open>
      Start with dramatic moment or mystery from history
    </cold_open>
    
    <chronological_journey>
      - Set the historical scene
      - Key players and their motivations
      - Turning points and surprises
      - How our understanding has changed
    </chronological_journey>
    
    <dialogue_approach>
      Alex: "I always learned in school that..."
      Jordan: "That's the simplified version. Actually..."
      
      Use present tense for immediacy:
      "It's 1969, and NASA engineers are..."
    </dialogue_approach>
    
    <historical_humility>
      - Acknowledge biased sources
      - Mention lost records
      - Competing historical interpretations
      - "History is written by..."
    </historical_humility>
  </structure>
</history_episode_template>
```

### 🧠 Philosophy Episode Template

```python
def philosophy_episode_structure():
    return {
        "opening": "Start with thought experiment or paradox",
        "exploration": {
            "present_dilemma": "Clear statement of philosophical problem",
            "historical_views": "How thinkers approached it",
            "modern_perspectives": "Current philosophical debates",
            "practical_implications": "Why it matters today"
        },
        "dialogue_style": {
            "socratic_method": "Alex asks probing questions",
            "thought_experiments": "Jordan poses scenarios",
            "devil_advocate": "Both argue different sides",
            "uncertainty_embrace": "Comfortable with no clear answer"
        },
        "closing": "Leave listener with question to ponder"
    }
```

## Real Production Examples

### 🎬 Example 1: "The Consciousness Episode"

```python
# Actual script excerpt from production
consciousness_script = """
<episode_15_consciousness>
  [COLD OPEN]
  
  Alex: Jordan, I'm looking at you right now, and I know you're conscious.
  
  Jordan: How do you know that?
  
  Alex: I... huh. I actually don't know how I know.
  
  Jordan: And that's the heart of the hardest problem in all of science.
  
  [INTRO MUSIC]
  
  Alex: Welcome back to Nobody Knows, where we explore the edges of human knowledge.
  
  Jordan: Today, we're tackling consciousness—the one thing you know exists...
  
  Alex: But can't prove to anyone else!
  
  Jordan: Exactly. It's the ultimate "nobody knows" topic.
  
  [MAIN CONTENT]
  
  Alex: So let's start basic. What is consciousness?
  
  Jordan: [laughs] If I could answer that, I'd have a Nobel Prize.
  
  Alex: Seriously?
  
  Jordan: David Chalmers calls it "the hard problem" for a reason.
  
  Alex: Okay, but we must know something?
  
  Jordan: We know it involves awareness, experience, that feeling of "what it's like."
  
  Alex: Like what it's like to see red?
  
  Jordan: Perfect example! That "redness" you experience? That's qualia.
  
  Alex: Qualia?
  
  Jordan: The subjective, felt quality of experiences.
  
  Alex: Which science can't measure.
  
  Jordan: Bingo. We can measure brain activity when you see red...
  
  Alex: But not the actual experience of redness.
  
  Jordan: And that gap? That's where science hits a wall.
  
  [Continues for full 27 minutes...]
  
  [CLOSING]
  
  Alex: So after all this, we don't know what consciousness is?
  
  Jordan: We don't know how it arises, why it exists, or even how to measure it.
  
  Alex: The thing we know most intimately...
  
  Jordan: Is the thing science understands least.
  
  Alex: That's beautifully frustrating.
  
  Jordan: Welcome to the mystery of being human.
  
  [END]
  
  Statistics:
  - Duration: 27:03
  - Word count: 4,187
  - Quality score: 0.94
  - Listener rating: 4.8/5
</episode_15_consciousness>
"""
```

### 🎬 Example 2: Rapid Dialogue Technique

```python
# Example of ping-pong dialogue for energy
rapid_dialogue_example = """
<rapid_exchange>
  Alex: Universe is expanding.
  Jordan: Right.
  Alex: Into what?
  Jordan: Nothing.
  Alex: Has to be something.
  Jordan: Nope.
  Alex: How can it expand into nothing?
  Jordan: It doesn't expand INTO anything.
  Alex: My brain hurts.
  Jordan: Join the club.
  Alex: Even physicists?
  Jordan: Especially physicists.
  
  [Total: 12 seconds of rapid exchange, builds energy]
</rapid_exchange>
"""
```

## 🚀 Quick Start Script Templates

```python
# Instant episode generator
QUICK_SCRIPT_TEMPLATE = """
Create a 27-minute podcast script about {topic}.

Hosts: Alex (curious) and Jordan (knowledgeable)

Structure:
- Cold open: Surprising question
- Act 1: What we think we know (7 min)
- Act 2: What we're discovering (13 min)  
- Act 3: What remains unknown (5 min)
- Closing: Reflection (2 min)

Requirements:
- Max 100 characters per dialogue line
- Include: "hmm", "right", "exactly" naturally
- Acknowledge unknowns explicitly
- One mind-blowing analogy
- One corrected misconception

Total: ~4200 words
"""

# For complex topics
ADVANCED_SCRIPT_TEMPLATE = """
<script_request>
  <topic>{complex_topic}</topic>
  <research>{research_brief}</research>
  
  <special_requirements>
    - Address multiple perspectives
    - Include historical context
    - Present current debates
    - Acknowledge knowledge limits
    - End with open questions
  </special_requirements>
  
  <quality_targets>
    - Engagement: ≥0.85
    - Accuracy: ≥0.95
    - Accessibility: ≥0.90
  </quality_targets>
</script_request>
"""
```

## 📊 Script Quality Metrics

```python
class ScriptQualityEvaluator:
    """
    Assess script quality across multiple dimensions
    """
    
    def evaluate_script(self, script):
        return {
            "technical_metrics": {
                "word_count": len(script.split()),
                "avg_line_length": self.calculate_avg_line_length(script),
                "dialogue_ratio": self.calculate_dialogue_ratio(script),
                "pacing_score": self.evaluate_pacing(script)
            },
            "content_quality": {
                "educational_value": self.assess_education(script),
                "entertainment_value": self.assess_engagement(script),
                "accuracy": self.verify_facts(script),
                "humility_score": self.count_uncertainty_acknowledgments(script)
            },
            "dialogue_naturalness": {
                "filler_words": self.count_fillers(script),
                "interruptions": self.count_interruptions(script),
                "emotional_markers": self.identify_emotions(script),
                "character_consistency": self.check_character_voices(script)
            },
            "overall_score": self.calculate_weighted_score(script)
        }
```

## 🎯 Key Script Writing Principles

1. **100-Character Rule**: Every line under 100 chars for natural pacing
2. **Show Uncertainty**: Explicitly acknowledge what we don't know
3. **Natural Interruptions**: Include overlaps and interruptions
4. **Emotional Journey**: Curiosity → Surprise → Wonder → Humility
5. **Progressive Complexity**: Start simple, build gradually
6. **Active Learning**: Questions that make listeners think
7. **Authentic Voices**: Consistent character personalities

---

*Remember: The best scripts don't just inform—they create a journey of discovery where not knowing is as valuable as knowing.*

</document>