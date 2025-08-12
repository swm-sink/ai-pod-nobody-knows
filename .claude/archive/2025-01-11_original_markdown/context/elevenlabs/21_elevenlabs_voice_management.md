# ElevenLabs Voice Management Guide (2025)

## 🎯 Purpose of This Document
**For You**: Master voice selection, cloning, and management - find the perfect voice for your podcast
**For AI**: Complete voice library specifications and management patterns

---

## 🎓 Voice Types Explained

**Think of voices like casting actors:**
- **Default Voices**: Professional actors ready to work
- **Community Voices**: Indie actors with unique styles
- **Cloned Voices**: Your custom actor, trained on specific samples
- **Designed Voices**: AI-created actors from descriptions

---

## 📚 Voice Library Overview

### The Numbers (2025)
- **5,000+** community voices available
- **70+** languages supported
- **100+** default professional voices
- **Unlimited** voice designs possible

### Voice Categories
```python
VOICE_CATEGORIES = {
    'narration': ['Rachel', 'Antoni', 'Domi'],
    'characters': ['Freya', 'Gigi', 'Jessie'],
    'news': ['Matilda', 'Matthew', 'Adam'],
    'conversational': ['Bella', 'Elli', 'Josh'],
    'storytelling': ['Dorothy', 'Harry', 'Callum']
}
```

---

## 🔍 Finding the Right Voice

### Search by Requirements
```python
def find_perfect_voice(requirements):
    """
    Find voices matching your needs
    """
    client = ElevenLabs(api_key=api_key)
    voices = client.voices.get_all()

    matches = []
    for voice in voices.voices:
        score = 0

        # Check language
        if requirements['language'] in voice.languages:
            score += 10

        # Check category
        if voice.category == requirements['category']:
            score += 5

        # Check description keywords
        for keyword in requirements['keywords']:
            if keyword.lower() in voice.description.lower():
                score += 2

        if score > 5:
            matches.append({
                'voice': voice,
                'score': score,
                'id': voice.voice_id,
                'name': voice.name
            })

    # Sort by best match
    return sorted(matches, key=lambda x: x['score'], reverse=True)

# Usage for your podcast
podcast_requirements = {
    'language': 'en',
    'category': 'narration',
    'keywords': ['warm', 'intellectual', 'engaging']
}

best_voices = find_perfect_voice(podcast_requirements)
```

### Voice Sampling
```python
def test_voices(text, voice_ids):
    """
    Generate samples with different voices
    """
    samples = {}

    for voice_id in voice_ids:
        try:
            audio = client.generate(
                text=text[:500],  # Use short sample
                voice=voice_id,
                model="eleven_flash_v2_5"  # Cheap for testing
            )

            filename = f"sample_{voice_id[:8]}.mp3"
            with open(filename, 'wb') as f:
                f.write(audio)

            samples[voice_id] = filename
            print(f"✅ Generated sample: {filename}")

        except Exception as e:
            print(f"❌ Failed for {voice_id}: {e}")

    return samples
```

---

## 🎙️ Voice Cloning

### Instant Voice Cloning (IVC)
```python
def clone_voice_instant(name, audio_files):
    """
    Create voice clone in seconds
    """
    try:
        # Upload audio samples (minimum 1 minute recommended)
        voice = client.voices.add(
            name=name,
            files=audio_files,  # List of file paths
            description="Podcast host voice clone"
        )

        print(f"✅ Voice cloned! ID: {voice.voice_id}")
        return voice.voice_id

    except Exception as e:
        print(f"❌ Cloning failed: {e}")
        return None

# Example usage
my_voice_id = clone_voice_instant(
    name="MyPodcastHost",
    audio_files=["sample1.mp3", "sample2.mp3"]
)
```

### Professional Voice Cloning (PVC)
```python
# Professional cloning requires:
# - 30+ minutes of clean audio
# - Consistent recording quality
# - Manual review process
# - Higher tier subscription

PVC_REQUIREMENTS = {
    'audio_length': '30+ minutes',
    'audio_quality': '44.1kHz, 16-bit minimum',
    'background_noise': 'None',
    'consistency': 'Same recording environment',
    'review_time': '24-48 hours'
}
```

---

## 🎨 Voice Design (v3 Feature)

### Creating Custom Voices
```python
def design_voice(description):
    """
    Design a voice from text description
    """
    prompt = f"""
    Age: {description['age']}
    Gender: {description['gender']}
    Accent: {description['accent']}
    Tone: {description['tone']}
    Characteristics: {description['characteristics']}
    """

    response = client.voices.design(
        prompt=prompt,
        model="eleven_v3_alpha"
    )

    return response.voice_id

# Design perfect podcast host
podcast_host = design_voice({
    'age': 'Middle-aged (40-50)',
    'gender': 'Neutral/Androgynous',
    'accent': 'Neutral American with hint of British',
    'tone': 'Warm, intellectual, slightly mysterious',
    'characteristics': 'Clear articulation, measured pace, engaging'
})
```

---

## 📊 Voice Management System

### Complete Voice Manager
```python
class VoiceManager:
    """
    Comprehensive voice management system
    """

    def __init__(self, api_key):
        self.client = ElevenLabs(api_key=api_key)
        self.voice_cache = {}
        self.favorites = []

    def catalog_voices(self):
        """Build voice catalog"""
        voices = self.client.voices.get_all()

        catalog = {
            'total': len(voices.voices),
            'by_category': {},
            'by_language': {},
            'featured': []
        }

        for voice in voices.voices:
            # By category
            cat = voice.category
            if cat not in catalog['by_category']:
                catalog['by_category'][cat] = []
            catalog['by_category'][cat].append(voice)

            # By language
            for lang in voice.languages:
                if lang not in catalog['by_language']:
                    catalog['by_language'][lang] = []
                catalog['by_language'][lang].append(voice)

            # Featured voices
            if voice.featured:
                catalog['featured'].append(voice)

        return catalog

    def save_favorite(self, voice_id, notes=""):
        """Save voice as favorite"""
        self.favorites.append({
            'id': voice_id,
            'notes': notes,
            'added': time.time()
        })

        # Persist to file
        with open('favorite_voices.json', 'w') as f:
            json.dump(self.favorites, f)

    def get_voice_details(self, voice_id):
        """Get comprehensive voice information"""
        if voice_id in self.voice_cache:
            return self.voice_cache[voice_id]

        voice = self.client.voices.get(voice_id)

        details = {
            'id': voice.voice_id,
            'name': voice.name,
            'category': voice.category,
            'description': voice.description,
            'languages': voice.languages,
            'preview_url': voice.preview_url,
            'settings': voice.settings,
            'sharing': voice.sharing
        }

        self.voice_cache[voice_id] = details
        return details
```

---

## 🎯 Podcast Voice Strategy

### Multi-Host Setup
```python
PODCAST_VOICES = {
    'main_host': {
        'voice_id': 'EXAVITQu4vr4xnSDxMaL',  # "Sarah"
        'role': 'Primary narrator',
        'settings': {
            'stability': 0.70,
            'similarity_boost': 0.80
        }
    },
    'co_host': {
        'voice_id': 'TxGEqnHWrfWFTfGW9XjX',  # "Josh"
        'role': 'Commentary and questions',
        'settings': {
            'stability': 0.60,
            'similarity_boost': 0.75
        }
    },
    'guest_voices': [
        'VR6AewLTigWG4xSOukaG',  # Expert voice
        'pNInz6obpgDQGcFmaJgB',  # Storyteller
    ]
}

def generate_dialogue(script_segments):
    """Generate multi-voice dialogue"""
    audio_segments = []

    for segment in script_segments:
        voice_config = PODCAST_VOICES[segment['speaker']]

        audio = client.generate(
            text=segment['text'],
            voice=voice_config['voice_id'],
            voice_settings=voice_config['settings']
        )

        audio_segments.append(audio)

    return combine_audio(audio_segments)
```

---

## 🔒 Voice Rights & Licensing

### Important Considerations
```python
VOICE_LICENSING = {
    'community_voices': {
        'usage': 'Check individual terms',
        'commercial': 'Usually allowed',
        'attribution': 'Sometimes required'
    },
    'cloned_voices': {
        'usage': 'You own the clone',
        'commercial': 'Full rights',
        'attribution': 'Not required'
    },
    'default_voices': {
        'usage': 'Unlimited with subscription',
        'commercial': 'Allowed',
        'attribution': 'Not required'
    }
}

# Voice usage tracking
def track_voice_usage(voice_id, project):
    """Track which voices used where"""
    usage_log = {
        'voice_id': voice_id,
        'project': project,
        'date': datetime.now().isoformat(),
        'license_type': get_license_type(voice_id)
    }

    # Save for compliance
    with open('voice_usage.log', 'a') as f:
        f.write(json.dumps(usage_log) + '\n')
```

---

## 💡 Voice Optimization Tips

### For Your Podcast:
1. **Consistency**: Use same voice throughout series
2. **Backup Voices**: Have 2-3 alternatives ready
3. **Test First**: Always test with target audience
4. **Document Settings**: Save exact configurations
5. **Version Control**: Track voice changes

### Voice Selection Checklist:
- [ ] Matches podcast tone
- [ ] Clear pronunciation
- [ ] Appropriate pace
- [ ] Emotional range
- [ ] Language support
- [ ] Commercial rights
- [ ] Availability (not removed)

---

## 🎓 Learning Exercises

### Exercise 1: Voice A/B Testing
Create system to test same script with different voices and collect feedback

### Exercise 2: Voice Blend
Mix multiple voices for complex narratives

### Exercise 3: Clone Evolution
Track how cloned voice improves with more samples

---

*Last Updated: January 2025*
*Based on ElevenLabs Voice Library and API documentation*
