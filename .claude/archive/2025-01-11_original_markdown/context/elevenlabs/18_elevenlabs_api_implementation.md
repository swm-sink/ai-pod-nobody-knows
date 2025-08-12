# ElevenLabs API Implementation Guide (Python SDK 2025)

## 🎯 Purpose of This Document
**For You**: Step-by-step guide to integrate ElevenLabs into your Python project - from "Hello World" to production
**For AI**: Complete API specifications, code patterns, and implementation details for building robust integrations

---

## 🎓 API Basics (Simple Explanation)

**Think of an API like ordering at a restaurant:**
1. You (client) look at the menu (documentation)
2. You tell the waiter (API) what you want
3. The kitchen (ElevenLabs servers) prepares it
4. The waiter brings your food (audio data)

The Python SDK is like having a really good waiter who knows exactly how to communicate your order to the kitchen!

---

## 🚀 Getting Started

### Installation
```bash
# Basic installation
pip install elevenlabs

# With all optional dependencies
pip install elevenlabs[all]

# For async support
pip install elevenlabs[async]
```

### Environment Setup
```bash
# Create .env file
echo "ELEVENLABS_API_KEY=your_key_here" > .env

# Never commit this file!
echo ".env" >> .gitignore
```

### First API Call
```python
from elevenlabs import ElevenLabs
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Initialize client
client = ElevenLabs(
    api_key=os.getenv("ELEVENLABS_API_KEY")
)

# Your first generation!
audio = client.generate(
    text="Hello, this is my first AI-generated audio!",
    voice="Rachel",
    model="eleven_turbo_v2_5"
)

# Save to file
with open("output.mp3", "wb") as f:
    f.write(audio)
```

---

## 📚 Core API Patterns

### Pattern 1: Simple Generation
```python
def generate_simple_audio(text, voice="Rachel"):
    """
    Basic audio generation - good for testing
    """
    try:
        audio = client.generate(
            text=text,
            voice=voice,
            model="eleven_turbo_v2_5"
        )
        return audio
    except Exception as e:
        print(f"Generation failed: {e}")
        return None
```

### Pattern 2: Advanced Generation with Settings
```python
def generate_podcast_audio(
    text,
    voice_id="21m00Tcm4TlvDq8ikWAM",  # Rachel
    emotion="neutral"
):
    """
    Production-quality generation with full control
    """
    # Configure voice settings
    voice_settings = {
        "stability": 0.65,
        "similarity_boost": 0.75,
        "style": 0.30,
        "use_speaker_boost": True
    }

    # Add emotional tags for v3
    if emotion == "excited":
        text = f"[excited tone] {text}"
    elif emotion == "thoughtful":
        text = f"[thoughtful, slower] {text}"

    try:
        audio = client.text_to_speech.convert(
            text=text,
            voice_id=voice_id,
            model_id="eleven_turbo_v2_5",
            voice_settings=voice_settings,
            output_format="mp3_44100_128"  # High quality
        )
        return audio
    except Exception as e:
        print(f"Error: {e}")
        return None
```

### Pattern 3: Batch Processing
```python
def batch_generate_episodes(episodes):
    """
    Generate multiple episodes efficiently
    """
    results = []

    for episode in episodes:
        # Generate with retry logic
        max_retries = 3
        for attempt in range(max_retries):
            try:
                audio = generate_podcast_audio(
                    text=episode['script'],
                    voice_id=episode['voice_id']
                )
                results.append({
                    'episode': episode['number'],
                    'audio': audio,
                    'success': True
                })
                break
            except Exception as e:
                if attempt == max_retries - 1:
                    results.append({
                        'episode': episode['number'],
                        'error': str(e),
                        'success': False
                    })
                else:
                    time.sleep(2 ** attempt)  # Exponential backoff

    return results
```

---

## 🔄 Async Implementation (For Scale)

### Basic Async Pattern
```python
import asyncio
from elevenlabs.client import AsyncElevenLabs

async def generate_async(text, voice="Rachel"):
    """
    Async generation for concurrent processing
    """
    async with AsyncElevenLabs(api_key=api_key) as client:
        audio = await client.generate(
            text=text,
            voice=voice,
            model="eleven_turbo_v2_5"
        )
        return audio

# Run multiple generations concurrently
async def batch_generate_async(texts):
    tasks = [generate_async(text) for text in texts]
    results = await asyncio.gather(*tasks)
    return results
```

### Production Async with Rate Limiting
```python
import asyncio
from asyncio import Semaphore

class ElevenLabsAsyncClient:
    def __init__(self, api_key, max_concurrent=5):
        self.client = AsyncElevenLabs(api_key=api_key)
        self.semaphore = Semaphore(max_concurrent)
        self.request_count = 0

    async def generate_with_limit(self, text, **kwargs):
        """
        Generate with concurrency limiting
        """
        async with self.semaphore:
            self.request_count += 1
            print(f"Request {self.request_count}: Generating...")

            try:
                audio = await self.client.generate(
                    text=text,
                    **kwargs
                )
                return audio
            except Exception as e:
                print(f"Request {self.request_count} failed: {e}")
                raise

    async def batch_process(self, items):
        """
        Process batch with rate limiting
        """
        tasks = []
        for item in items:
            task = self.generate_with_limit(
                text=item['text'],
                voice=item.get('voice', 'Rachel'),
                model=item.get('model', 'eleven_turbo_v2_5')
            )
            tasks.append(task)

        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results
```

---

## 🎙️ Voice Management

### List Available Voices
```python
def get_available_voices():
    """
    Fetch all voices you can use
    """
    voices = client.voices.get_all()

    voice_list = []
    for voice in voices.voices:
        voice_list.append({
            'id': voice.voice_id,
            'name': voice.name,
            'category': voice.category,
            'description': voice.description,
            'languages': voice.languages
        })

    return voice_list

# Find voices by criteria
def find_voices(language="en", category="narrative"):
    voices = get_available_voices()
    filtered = [
        v for v in voices
        if language in v.get('languages', [])
        and v.get('category') == category
    ]
    return filtered
```

### Voice Cloning
```python
def clone_voice(name, audio_files):
    """
    Create a custom voice from audio samples
    """
    try:
        voice = client.voices.add(
            name=name,
            files=audio_files,
            description="Custom cloned voice for podcast"
        )
        return voice.voice_id
    except Exception as e:
        print(f"Voice cloning failed: {e}")
        return None
```

---

## 📊 Rate Limit Management

### Understanding Rate Limits
```python
# Rate limits by tier (2025)
RATE_LIMITS = {
    'free': {'concurrent': 2, 'per_minute': 10},
    'starter': {'concurrent': 3, 'per_minute': 30},
    'creator': {'concurrent': 5, 'per_minute': 100},
    'pro': {'concurrent': 10, 'per_minute': 300},
    'scale': {'concurrent': 15, 'per_minute': 1000}
}
```

### Smart Rate Limiter
```python
import time
from collections import deque
from threading import Lock

class RateLimiter:
    def __init__(self, max_requests_per_minute=100):
        self.max_requests = max_requests_per_minute
        self.requests = deque()
        self.lock = Lock()

    def wait_if_needed(self):
        """
        Wait if we're hitting rate limits
        """
        with self.lock:
            now = time.time()

            # Remove requests older than 1 minute
            while self.requests and self.requests[0] < now - 60:
                self.requests.popleft()

            # If at limit, wait
            if len(self.requests) >= self.max_requests:
                sleep_time = 60 - (now - self.requests[0]) + 0.1
                print(f"Rate limit reached. Waiting {sleep_time:.1f}s...")
                time.sleep(sleep_time)

            # Record this request
            self.requests.append(now)

# Usage
rate_limiter = RateLimiter(max_requests_per_minute=100)

def generate_with_rate_limit(text, **kwargs):
    rate_limiter.wait_if_needed()
    return client.generate(text, **kwargs)
```

---

## 🔍 Error Handling

### Comprehensive Error Handler
```python
from enum import Enum

class ErrorType(Enum):
    RATE_LIMIT = "rate_limit"
    AUTH = "authentication"
    QUOTA = "quota_exceeded"
    SERVER = "server_error"
    NETWORK = "network_error"
    INVALID = "invalid_request"

def handle_api_error(error):
    """
    Intelligent error handling with recovery strategies
    """
    error_str = str(error).lower()

    if "429" in error_str or "too_many" in error_str:
        return ErrorType.RATE_LIMIT, "Wait and retry with backoff"

    elif "401" in error_str or "unauthorized" in error_str:
        return ErrorType.AUTH, "Check API key"

    elif "quota" in error_str or "limit" in error_str:
        return ErrorType.QUOTA, "Upgrade plan or wait for reset"

    elif "500" in error_str or "502" in error_str:
        return ErrorType.SERVER, "ElevenLabs server issue, retry later"

    elif "timeout" in error_str or "connection" in error_str:
        return ErrorType.NETWORK, "Check internet connection"

    else:
        return ErrorType.INVALID, "Check request parameters"

def safe_generate(text, max_retries=3, **kwargs):
    """
    Production-ready generation with full error handling
    """
    for attempt in range(max_retries):
        try:
            return client.generate(text, **kwargs)

        except Exception as e:
            error_type, solution = handle_api_error(e)

            if error_type == ErrorType.AUTH:
                raise Exception(f"Authentication failed: {solution}")

            elif error_type == ErrorType.QUOTA:
                raise Exception(f"Quota exceeded: {solution}")

            elif attempt < max_retries - 1:
                wait_time = 2 ** attempt
                print(f"Attempt {attempt + 1} failed: {error_type.value}")
                print(f"Solution: {solution}")
                print(f"Retrying in {wait_time}s...")
                time.sleep(wait_time)

            else:
                raise Exception(f"Max retries reached. Last error: {e}")
```

---

## 🎯 Podcast Production Class

### Complete Implementation
```python
class PodcastProducer:
    """
    Complete podcast production system
    """

    def __init__(self, api_key, voice_id=None):
        self.client = ElevenLabs(api_key=api_key)
        self.voice_id = voice_id or "21m00Tcm4TlvDq8ikWAM"  # Rachel
        self.rate_limiter = RateLimiter(100)

    def process_script(self, script):
        """
        Process script for optimal generation
        """
        # Split into chunks if too long
        max_chars = 5000
        if len(script) > max_chars:
            chunks = self._split_script(script, max_chars)
        else:
            chunks = [script]

        return chunks

    def _split_script(self, script, max_chars):
        """
        Smart script splitting on sentence boundaries
        """
        sentences = script.split('. ')
        chunks = []
        current_chunk = ""

        for sentence in sentences:
            if len(current_chunk) + len(sentence) < max_chars:
                current_chunk += sentence + ". "
            else:
                chunks.append(current_chunk.strip())
                current_chunk = sentence + ". "

        if current_chunk:
            chunks.append(current_chunk.strip())

        return chunks

    def generate_episode(self, script, episode_num):
        """
        Generate complete episode
        """
        print(f"Generating Episode {episode_num}...")

        # Process script
        chunks = self.process_script(script)
        audio_parts = []

        # Generate each chunk
        for i, chunk in enumerate(chunks):
            print(f"  Part {i+1}/{len(chunks)}...")

            self.rate_limiter.wait_if_needed()

            try:
                audio = self.client.text_to_speech.convert(
                    text=chunk,
                    voice_id=self.voice_id,
                    model_id="eleven_turbo_v2_5",
                    voice_settings={
                        "stability": 0.65,
                        "similarity_boost": 0.75
                    }
                )
                audio_parts.append(audio)

            except Exception as e:
                print(f"  Error on part {i+1}: {e}")
                raise

        # Combine audio parts
        combined = self._combine_audio(audio_parts)

        # Save episode
        filename = f"episode_{episode_num:03d}.mp3"
        with open(filename, "wb") as f:
            f.write(combined)

        print(f"Episode {episode_num} complete: {filename}")
        return filename

    def _combine_audio(self, parts):
        """
        Combine multiple audio chunks
        """
        # Simple concatenation for MP3
        # For production, use pydub or ffmpeg
        return b''.join(parts)
```

---

## 💰 Cost Tracking

### Usage Monitor
```python
class UsageTracker:
    def __init__(self):
        self.requests = []
        self.characters = 0
        self.cost = 0.0

    def track_request(self, text, model="eleven_turbo_v2_5"):
        """
        Track usage and calculate costs
        """
        char_count = len(text)
        self.characters += char_count

        # Cost per 1000 characters
        costs = {
            "eleven_flash_v2_5": 0.25,
            "eleven_turbo_v2_5": 0.50,
            "eleven_v3_alpha": 0.20  # With discount
        }

        cost = (char_count / 1000) * costs.get(model, 0.50)
        self.cost += cost

        self.requests.append({
            'timestamp': time.time(),
            'characters': char_count,
            'cost': cost,
            'model': model
        })

        return cost

    def get_summary(self):
        """
        Get usage summary
        """
        return {
            'total_requests': len(self.requests),
            'total_characters': self.characters,
            'total_cost': round(self.cost, 2),
            'average_cost': round(self.cost / len(self.requests), 2) if self.requests else 0
        }
```

---

## 🔧 Testing Setup

### Unit Tests
```python
import unittest
from unittest.mock import Mock, patch

class TestElevenLabsIntegration(unittest.TestCase):

    def setUp(self):
        self.client = Mock()

    def test_generation(self):
        """Test basic generation"""
        self.client.generate.return_value = b"audio_data"

        result = self.client.generate(
            text="Test",
            voice="Rachel"
        )

        self.assertIsNotNone(result)
        self.assertEqual(result, b"audio_data")

    def test_error_handling(self):
        """Test error handling"""
        self.client.generate.side_effect = Exception("Rate limit")

        with self.assertRaises(Exception):
            self.client.generate(text="Test")
```

---

## 🎓 Learning Checkpoints

### Milestone 1: First Audio
- [ ] Install SDK
- [ ] Get API key
- [ ] Generate "Hello World"
- [ ] Save to file

### Milestone 2: Custom Settings
- [ ] Adjust voice settings
- [ ] Try different models
- [ ] Add emotional tags
- [ ] Handle errors

### Milestone 3: Production Ready
- [ ] Implement rate limiting
- [ ] Add retry logic
- [ ] Track costs
- [ ] Batch processing

---

## 💡 Pro Tips

1. **Cache Common Phrases**: Save intros/outros, reuse them
2. **Test with Short Text**: Don't waste credits on long tests
3. **Log Everything**: Track what works for future reference
4. **Monitor Response Headers**: Check rate limit status
5. **Use Async for Scale**: Critical for batch processing

---

*Last Updated: January 2025*
*Based on ElevenLabs Python SDK v0.3.0*
