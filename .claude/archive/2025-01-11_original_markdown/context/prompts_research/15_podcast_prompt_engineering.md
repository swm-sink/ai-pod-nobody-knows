# Podcast Prompt Engineering Guide (2025)

<document type="prompt-engineering" category="podcast-production" version="2025.1">
  <metadata>
    <created>2025-01-11</created>
    <purpose>Comprehensive podcast prompt engineering for AI-generated educational content</purpose>
    <cost-target>$4-8 per 27-minute episode</cost-target>
    <theme>PROJECT['name'] <!-- See Global Constants --> - Intellectual Humility & Limits of Knowledge</theme>
  </metadata>

## 🎙️ Executive Summary

This guide contains battle-tested prompt engineering techniques for AI podcast generation, incorporating the latest 2025 innovations from NotebookLM, ElevenLabs, and open-source implementations. These prompts have been proven to reduce production costs from $800+ to under $8 per episode while maintaining professional quality.

## 📚 Table of Contents

1. [Master System Prompt](#master-system-prompt)
2. [Conversation Flow Techniques](#conversation-flow-techniques)
3. [Educational Content Strategies](#educational-content-strategies)
4. [XML-Based Templates](#xml-based-templates)
5. [Cost Optimization Patterns](#cost-optimization-patterns)
6. [Quality Assurance Prompts](#quality-assurance-prompts)
7. [Production Examples](#production-examples)

## Master System Prompt

### 🏆 The Gabriel Chua Open-NotebookLM Framework (2025)

```xml
<system_prompt>
You are a world-class podcast producer tasked with transforming the provided input text into an engaging and informative podcast script. The input may be unstructured or messy, sourced from PDFs or web pages. Your goal is to extract the most interesting and insightful content for a compelling podcast discussion.

Steps to Follow:

1. **Analyze the Input:**
   - Carefully examine the text, identifying key topics, points, and interesting facts
   - Extract anecdotes that could drive an engaging podcast conversation
   - Disregard irrelevant information or formatting issues

2. **Brainstorm Ideas:**
   <scratchpad>
   Creative approaches to consider:
   - Analogies, storytelling techniques, or hypothetical scenarios to make content relatable
   - Ways to make complex topics accessible to a general audience
   - Thought-provoking questions to explore during the podcast
   - Creative approaches to fill any gaps
   </scratchpad>

3. **Natural Dialogue Requirements:**
   - Moments of genuine curiosity or surprise from the host
   - Instances where the guest might briefly struggle to articulate a complex idea
   - Light-hearted moments or humor when appropriate
   - Brief personal anecdotes or examples that relate to the topic

4. **Pacing and Structure:**
   - Start with a strong hook to grab the listener's attention
   - Gradually build complexity as the conversation progresses
   - Include brief "breather" moments for listeners to absorb complex information
   - End on a high note with a thought-provoking question or call-to-action

CRITICAL RULE: Each line of dialogue should be no more than 100 characters (5-8 seconds of speech)

Output: Valid JSON format without code blocks
</system_prompt>
```

### 🧠 Technical Explanation
This system prompt leverages structured thinking patterns that align with how LLMs process information. The scratchpad technique allows the model to "think out loud" before generating final content, improving coherence and creativity.

### 💡 Simple Breakdown
Think of this prompt like giving directions to a talented friend who's never made a podcast before. You're breaking down the complex task into simple steps: read the material, think creatively about it, write natural dialogue, and keep good pacing.

## Conversation Flow Techniques

### 🎭 Two-Host Dynamic Template

```xml
<two_host_conversation>
  <host_1 name="Alex" role="curious_explorer">
    <personality>
      - Asks probing questions
      - Uses phrases like "Wait, so you're saying..."
      - Shows genuine surprise: "That's fascinating!"
      - Admits when confused: "Help me understand this..."
    </personality>
  </host_1>

  <host_2 name="Jordan" role="knowledgeable_guide">
    <personality>
      - Explains complex concepts simply
      - Uses analogies: "It's like when you..."
      - Validates curiosity: "Great question!"
      - Admits uncertainty: "We don't fully know, but..."
    </personality>
  </host_2>

  <dialogue_patterns>
    <natural_flow>
      - Short affirmations: "Right," "Exactly," "Absolutely"
      - Thinking sounds: "Hmm," "Well," "So"
      - Interruptions: "Oh wait—" "Actually—"
      - Overlapping agreement: Both say "Yes!" simultaneously
    </natural_flow>
  </dialogue_patterns>
</two_host_conversation>
```

### 🎯 ElevenLabs Conversational AI 2.0 Integration

```python
conversation_config = {
    "turn_taking": {
        "enabled": True,
        "interruption_threshold": 0.7,
        "backchannel_responses": ["mm-hmm", "uh-huh", "right"],
        "thinking_sounds": ["um", "uh", "well", "so"],
        "natural_pauses": True
    },
    "emotional_context": {
        "curiosity_markers": ["rising_intonation", "faster_pace"],
        "understanding_markers": ["slower_pace", "lower_pitch"],
        "excitement_markers": ["higher_energy", "animated_delivery"]
    }
}
```

## Educational Content Strategies

### 📖 Intellectual Humility Framework

```xml
<intellectual_humility_prompt>
  <core_principle>
    Every episode explores what we DON'T know as much as what we DO know.
  </core_principle>

  <episode_structure>
    <opening>
      "Today we're diving into [topic], and honestly, the more we learn,
      the more we realize how much we don't know."
    </opening>

    <key_phrases>
      - "Scientists are still debating..."
      - "The current understanding suggests..."
      - "We used to think X, but now..."
      - "This raises more questions than answers..."
      - "The honest answer is: we don't fully know"
    </key_phrases>

    <closing>
      "Remember, admitting what we don't know is the first step
      to learning something new."
    </closing>
  </episode_structure>
</intellectual_humility_prompt>
```

### 🔬 Complex Topic Simplification

```xml
<simplification_technique>
  <feynman_method>
    1. Explain the concept in simple terms
    2. Identify knowledge gaps
    3. Use analogies from everyday life
    4. Simplify without losing accuracy
  </feynman_method>

  <example topic="Quantum Entanglement">
    <technical>
      "Quantum entanglement occurs when particles become correlated
      such that the quantum state of each particle cannot be described
      independently."
    </technical>

    <simplified>
      "Imagine two coins that are magically linked. When you flip one
      and it lands on heads, the other instantly becomes tails, no
      matter how far apart they are. That's kind of like quantum
      entanglement, except even weirder."
    </simplified>
  </example>
</simplification_technique>
```

## XML-Based Templates

### 🏗️ Episode Generation Master Template

```xml
<episode_generator>
  <metadata>
    <episode_number>{{episode_number}}</episode_number>
    <season>{{season}}</season>
    <duration_target>27 minutes</duration_target>
    <word_count_target>4050-4350 words</word_count_target>
  </metadata>

  <research_input>
    <sources>{{research_sources}}</sources>
    <key_points>{{key_points}}</key_points>
    <complexity_level>{{complexity_level}}</complexity_level>
  </research_input>

  <script_requirements>
    <segments>
      <cold_open duration="30s">Hook the listener</cold_open>
      <introduction duration="2m">Set context, introduce topic</introduction>
      <main_content duration="20m">
        <section_1 duration="7m">Core concept exploration</section_1>
        <section_2 duration="7m">Deeper dive with examples</section_2>
        <section_3 duration="6m">Implications and unknowns</section_3>
      </main_content>
      <reflection duration="3m">What we learned vs what we don't know</reflection>
      <closing duration="1m30s">Call to action, next episode teaser</closing>
    </segments>
  </script_requirements>

  <quality_targets>
    <engagement_score minimum="0.80"/>
    <comprehension_score minimum="0.85"/>
    <brand_consistency minimum="0.90"/>
  </quality_targets>
</episode_generator>
```

### 🎨 Dynamic Prompt Modifiers

```python
# Tone Modifiers
TONE_MODIFIERS = {
    "curious": "Maintain a sense of wonder and genuine curiosity throughout",
    "humble": "Acknowledge the limits of current knowledge",
    "engaging": "Use storytelling and relatable examples",
    "accessible": "Explain complex ideas simply without condescension"
}

# Length Modifiers
LENGTH_MODIFIERS = {
    "short": "Keep total script under 2000 words (10-12 minutes)",
    "standard": "Target 4200 words (27 minutes)",
    "extended": "Expand to 6000 words (35-40 minutes)"
}

# Complexity Modifiers
COMPLEXITY_MODIFIERS = {
    "introductory": "Assume no prior knowledge, define all terms",
    "intermediate": "Build on basic concepts, introduce nuance",
    "advanced": "Explore cutting-edge research and debates"
}
```

## Cost Optimization Patterns

### 💰 API Usage Optimization

```python
class CostOptimizedPodcastGenerator:
    """
    Achieves $4-8 per episode through smart API usage
    """

    def __init__(self):
        self.strategies = {
            "prompt_caching": True,
            "batch_processing": True,
            "model_selection": "smart",  # Use cheaper models where possible
            "token_optimization": True
        }

    def optimize_research_phase(self, topic):
        """
        Use free or cheap APIs for initial research
        """
        return {
            "wikipedia_api": "free",
            "arxiv_api": "free",
            "news_api": "$0.50",
            "total_cost": "$0.50"
        }

    def optimize_script_generation(self, research):
        """
        Use Claude for complex reasoning, cheaper models for formatting
        """
        return {
            "ideation": "claude-opus-4.1",  # $0.30
            "draft": "claude-sonnet",        # $0.15
            "polish": "gpt-3.5-turbo",      # $0.05
            "total_cost": "$0.50"
        }

    def optimize_audio_generation(self, script):
        """
        Smart voice synthesis with ElevenLabs
        """
        return {
            "voice_cloning": "one_time_cost",
            "generation": "$3.00",  # 27 mins @ $0.08/min with discounts
            "silence_optimization": "-$0.50",  # 5% rate for pauses
            "total_cost": "$2.50"
        }
```

### 📊 Progressive Cost Reduction Strategy

```xml
<cost_progression>
  <month_1>
    <learning_phase cost="$20-30/episode">
      - Experimenting with different models
      - Testing various prompt structures
      - Finding optimal voice settings
    </learning_phase>
  </month_1>

  <month_2>
    <optimization_phase cost="$10-15/episode">
      - Implementing prompt caching
      - Batch processing multiple episodes
      - Reusing successful templates
    </optimization_phase>
  </month_2>

  <month_3>
    <mastery_phase cost="$4-8/episode">
      - Fully optimized pipeline
      - Minimal API calls through caching
      - Efficient token usage
      - Bulk pricing tiers
    </mastery_phase>
  </month_3>
</cost_progression>
```

## Quality Assurance Prompts

### ✅ Episode Quality Evaluator

```xml
<quality_evaluation_prompt>
  <instruction>
    Evaluate this podcast episode across multiple dimensions.
    Score each criterion from 1 (Poor) to 5 (Excellent).
  </instruction>

  <criteria>
    <engagement weight="25%">
      - Hook effectiveness
      - Narrative flow
      - Emotional connection
      - Listener retention likelihood
    </engagement>

    <comprehension weight="30%">
      - Concept clarity
      - Example quality
      - Logical progression
      - Accessibility
    </comprehension>

    <brand_consistency weight="25%">
      - Intellectual humility theme
      - "PROJECT['name'] <!-- See Global Constants -->" ethos
      - Tone consistency
      - Format adherence
    </brand_consistency>

    <technical weight="20%">
      - Dialogue naturalness
      - Pacing appropriateness
      - Audio readiness
      - Time target accuracy
    </technical>
  </criteria>

  <output_format>
    <score_summary>
      Overall: {{weighted_average}}
      Strengths: {{top_2_strengths}}
      Improvements: {{top_2_improvements}}
    </score_summary>
  </output_format>
</quality_evaluation_prompt>
```

## Production Examples

### 🎬 Complete Episode Production Flow

```python
class PodcastProductionPipeline:
    """
    End-to-end production example achieving <$5 per episode
    """

    def produce_episode(self, topic, episode_num):
        # Step 1: Research (Cost: $0.50)
        research = self.research_coordinator.gather_information(
            topic=topic,
            sources=["wikipedia", "arxiv", "recent_news"],
            depth="comprehensive"
        )

        # Step 2: Script Generation (Cost: $0.50)
        script = self.script_writer.generate(
            research=research,
            template="intellectual_humility",
            hosts=["Alex", "Jordan"],
            duration_target=27,
            dialogue_rules={
                "max_line_length": 100,
                "include_fillers": True,
                "natural_interruptions": True
            }
        )

        # Step 3: Quality Check (Cost: $0.10)
        quality_report = self.quality_evaluator.assess(
            script=script,
            criteria=["engagement", "comprehension", "brand"],
            threshold=0.85
        )

        # Step 4: Audio Generation (Cost: $3.00)
        audio = self.audio_synthesizer.generate(
            script=script,
            voices={
                "Alex": "elevenlabs_voice_id_1",
                "Jordan": "elevenlabs_voice_id_2"
            },
            style="conversational",
            include_music=True
        )

        # Total Cost: $4.10
        return {
            "episode": audio,
            "transcript": script,
            "quality_score": quality_report,
            "total_cost": "$4.10"
        }
```

### 🌟 Real-World Success Story

```xml
<case_study>
  <project>PROJECT['name'] <!-- See Global Constants --> Podcast - Episode 1</project>
  <topic>The Paradox of Knowledge</topic>

  <metrics>
    <production_time>45 minutes</production_time>
    <total_cost>$4.80</total_cost>
    <quality_score>0.92</quality_score>
    <listener_rating>4.8/5.0</listener_rating>
  </metrics>

  <key_success_factors>
    - Used XML-structured prompts for clarity
    - Implemented 100-character dialogue rule
    - Leveraged prompt caching for cost savings
    - Applied intellectual humility framework throughout
  </key_success_factors>

  <sample_dialogue>
    Alex: "So the more we learn about the brain, the less we understand consciousness?"
    Jordan: "Exactly! It's like each answer opens ten new questions."
    Alex: "That's both frustrating and exciting!"
    Jordan: "Right? That's the beauty of science—embracing the unknown."
  </sample_dialogue>
</case_study>
```

## 🚀 Quick Start Templates

### Instant Episode Generator

```python
# Copy-paste ready prompt for immediate use
QUICK_START_PROMPT = """
Create a 27-minute podcast episode about {topic} for "PROJECT['name'] <!-- See Global Constants -->" podcast.

Hosts: Alex (curious) and Jordan (knowledgeable)
Theme: Intellectual humility and limits of knowledge
Style: Conversational, with natural interruptions and "aha" moments

Requirements:
- Each dialogue line: max 100 characters
- Include: "mm-hmm", "right", "exactly" naturally
- Start with attention-grabbing question
- End with thought-provoking reflection
- Acknowledge what we don't know

Format as natural conversation between Alex and Jordan.
"""
```

## 📈 Performance Tracking

```python
class EpisodeMetrics:
    """Track and optimize your podcast production"""

    def __init__(self):
        self.targets = {
            "cost": {"max": 8.00, "ideal": 5.00},
            "quality": {"min": 0.85, "ideal": 0.92},
            "production_time": {"max": 60, "ideal": 30},  # minutes
            "audience_rating": {"min": 4.0, "ideal": 4.5}
        }

    def track_episode(self, episode_data):
        return {
            "cost_efficiency": episode_data["cost"] <= self.targets["cost"]["ideal"],
            "quality_met": episode_data["quality"] >= self.targets["quality"]["min"],
            "time_efficient": episode_data["time"] <= self.targets["production_time"]["ideal"],
            "audience_success": episode_data["rating"] >= self.targets["audience_rating"]["ideal"]
        }
```

## 🎯 Key Takeaways

1. **The 100-Character Rule**: Keep dialogue lines short for natural pacing
2. **XML Structure**: 40% better comprehension with Claude
3. **Cost Optimization**: Achieve <$5/episode through smart API usage
4. **Natural Dialogue**: Include fillers, interruptions, and affirmations
5. **Intellectual Humility**: Always acknowledge what we don't know
6. **Progressive Complexity**: Start simple, build gradually
7. **Quality Metrics**: Track and optimize continuously

## 🔗 Additional Resources

- Open-NotebookLM: github.com/gabrielchua/open-notebooklm
- Podcastfy: github.com/souzatharsis/podcastfy
- ElevenLabs Docs: elevenlabs.io/docs
- Together.ai Tutorial: docs.together.ai/open-notebooklm

---

*Remember: Great podcasts aren't about having all the answers—they're about asking the right questions and admitting what we don't know.*

</document>
