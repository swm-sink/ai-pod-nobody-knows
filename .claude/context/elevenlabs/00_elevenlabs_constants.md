# ElevenLabs Central Configuration & Constants (2025)
## Single Source of Truth - Reference This File!

---

## 📋 Model Specifications

```python
ELEVENLABS_MODELS = {
    'flash_v2_5': {
        'id': 'eleven_flash_v2_5',
        'name': 'Flash v2.5',
        'latency_ms': 75,
        'cost_per_1k_chars': 0.25,
        'languages': 32,
        'character_limit': 40000,
        'best_for': 'Real-time, budget, testing',
        'phoneme_support': True,
        'audio_tags': False
    },
    'turbo_v2': {
        'id': 'eleven_turbo_v2',
        'name': 'Turbo v2',
        'latency_ms': 200,
        'cost_per_1k_chars': 0.50,
        'languages': 1,  # English only
        'character_limit': 40000,
        'best_for': 'English podcasts, production',
        'phoneme_support': True,
        'audio_tags': False
    },
    'turbo_v2_5': {
        'id': 'eleven_turbo_v2_5',
        'name': 'Turbo v2.5',
        'latency_ms': 250,
        'cost_per_1k_chars': 0.50,
        'languages': 32,
        'character_limit': 40000,
        'best_for': 'Multilingual content, production',
        'phoneme_support': False,  # Use aliases instead
        'audio_tags': False
    },
    'v3_alpha': {
        'id': 'eleven_v3_alpha',
        'name': 'Eleven v3 (Alpha)',
        'latency_ms': 400,
        'cost_per_1k_chars': 0.20,  # 80% discount until June 2025
        'cost_per_1k_chars_normal': 1.00,
        'languages': 70,
        'character_limit': 50000,
        'best_for': 'Emotional content, expressiveness',
        'phoneme_support': False,
        'audio_tags': True,
        'discount_ends': '2025-06-30'
    }
}

# Quick access aliases
MODEL_IDS = {model['id']: key for key, model in ELEVENLABS_MODELS.items()}
DEFAULT_MODEL = 'eleven_turbo_v2_5'
BUDGET_MODEL = 'eleven_flash_v2_5'
QUALITY_MODEL = 'eleven_v3_alpha'
```

---

## 💰 Subscription Tiers & Pricing

```python
SUBSCRIPTION_TIERS = {
    'free': {
        'monthly_cost': 0,
        'annual_cost': 0,
        'credits': 10000,
        'concurrent_requests': 2,
        'custom_voices': 3,
        'api_access': True
    },
    'starter': {
        'monthly_cost': 5,
        'annual_cost': 50,  # Save $10/year
        'credits': 30000,
        'concurrent_requests': 3,
        'custom_voices': 10,
        'api_access': True
    },
    'creator': {
        'monthly_cost': 22,
        'annual_cost': 220,  # Save ~$44/year
        'credits': 100000,
        'concurrent_requests': 5,
        'custom_voices': 30,
        'api_access': True
    },
    'pro': {
        'monthly_cost': 99,
        'annual_cost': 990,  # Save ~$198/year
        'credits': 500000,
        'concurrent_requests': 10,
        'custom_voices': 160,
        'api_access': True
    },
    'scale': {
        'monthly_cost': 330,
        'annual_cost': 3300,  # Save ~$660/year
        'credits': 2000000,
        'concurrent_requests': 15,
        'custom_voices': 660,
        'api_access': True
    }
}

ANNUAL_DISCOUNT = 0.16  # 16-20% savings on annual billing
```

---

## 🎙️ Voice Library

```python
# Common voice IDs for reference
VOICE_IDS = {
    # Default Professional Voices
    'rachel': '21m00Tcm4TlvDq8ikWAM',
    'domi': 'AZnzlk1XvdvUeBnXmlld',
    'bella': 'EXAVITQu4vr4xnSDxMaL',
    'antoni': 'ErXwobaYiN019PkySvjV',
    'elli': 'MF3mGyEYCl7XYWbV9V6O',
    'josh': 'TxGEqnHWrfWFTfGW9XjX',
    'arnold': 'VR6AewLTigWG4xSOukaG',
    'adam': 'pNInz6obpgDQGcFmaJgB',
    'sam': 'yoZ06aMxZJJ28mfd3POQ',
    
    # Categories
    'narration': ['rachel', 'antoni', 'domi'],
    'conversational': ['bella', 'elli', 'josh'],
    'authoritative': ['arnold', 'adam'],
}

# Voice settings presets
VOICE_SETTINGS_PRESETS = {
    'podcast_host': {
        'stability': 0.65,
        'similarity_boost': 0.75,
        'style': 0.30,
        'use_speaker_boost': True
    },
    'narrator': {
        'stability': 0.70,
        'similarity_boost': 0.80,
        'style': 0.20,
        'use_speaker_boost': False
    },
    'character': {
        'stability': 0.50,
        'similarity_boost': 0.70,
        'style': 0.40,
        'use_speaker_boost': True
    },
    'news': {
        'stability': 0.80,
        'similarity_boost': 0.85,
        'style': 0.10,
        'use_speaker_boost': False
    }
}

# Default voice for testing
DEFAULT_VOICE = 'rachel'
DEFAULT_VOICE_ID = VOICE_IDS['rachel']
```

---

## 🎭 Audio Tags (v3 Only)

```python
AUDIO_TAGS = {
    'emotions': [
        '[whispers]',
        '[laughs]',
        '[laughs harder]',
        '[starts laughing]',
        '[sighs]',
        '[gasps]',
        '[clears throat]'
    ],
    'pacing': [
        '[pauses]',
        '[speaking quickly]',
        '[slowly, deliberately]'
    ],
    'tone': [
        '[excited]',
        '[thoughtful]',
        '[sarcastic]',
        '[curious]',
        '[warm]',
        '[mysterious]'
    ]
}

# Tags only work with v3 model
AUDIO_TAG_COMPATIBLE_MODELS = ['eleven_v3_alpha']
```

---

## 🔧 API Configuration

```python
# API Endpoints
API_BASE_URL = 'https://api.elevenlabs.io/v1'
WEBSOCKET_BASE_URL = 'wss://api.elevenlabs.io/v1'

# WebSocket specific
WEBSOCKET_ENDPOINTS = {
    'text_to_speech': '/text-to-speech/{voice_id}/stream-input',
    'speech_to_speech': '/speech-to-speech/{voice_id}/stream'
}

# Connection settings
CONNECTION_CONFIG = {
    'timeout_seconds': 20,
    'keep_alive_interval': 15,
    'max_retries': 3,
    'backoff_multiplier': 2,
    'chunk_length_schedule': {
        'aggressive': [50, 75, 100, 150],    # ~100ms latency
        'balanced': [120, 160, 250, 290],    # ~250ms latency  
        'quality': [250, 350, 450, 500]      # ~400ms latency
    }
}

# Rate limits by tier
RATE_LIMITS = {
    'free': {'concurrent': 2, 'per_minute': 10},
    'starter': {'concurrent': 3, 'per_minute': 30},
    'creator': {'concurrent': 5, 'per_minute': 100},
    'pro': {'concurrent': 10, 'per_minute': 300},
    'scale': {'concurrent': 15, 'per_minute': 1000}
}

# Output formats
OUTPUT_FORMATS = {
    'mp3_low': 'mp3_22050_32',
    'mp3_standard': 'mp3_44100_64',
    'mp3_high': 'mp3_44100_128',
    'mp3_highest': 'mp3_44100_192',
    'pcm_16000': 'pcm_16000',
    'pcm_22050': 'pcm_22050',
    'pcm_24000': 'pcm_24000',
    'pcm_44100': 'pcm_44100'
}

DEFAULT_OUTPUT_FORMAT = 'mp3_44100_128'
```

---

## 📊 Podcast Production Constants

```python
# Nobody Knows Podcast Specifications
PODCAST_CONFIG = {
    'name': 'Nobody Knows',
    'episode_duration_minutes': 27,
    'characters_per_minute': 1000,
    'total_characters_per_episode': 27000,
    'target_cost_per_episode': 8.00,
    'max_cost_per_episode': 10.00,
    
    'structure': {
        'intro_duration': 30,  # seconds
        'teaser_duration': 45,
        'main_content_segments': 5,
        'segment_duration': 300,  # 5 minutes each
        'conclusion_duration': 120,
        'outro_duration': 20
    },
    
    'voices': {
        'primary_host': 'rachel',
        'secondary_host': 'antoni',
        'guest_voices': ['arnold', 'bella', 'sam']
    }
}

# Episode cost calculations
def calculate_episode_cost(model_key, characters=27000):
    """Calculate cost for a single episode"""
    model = ELEVENLABS_MODELS[model_key]
    return (characters / 1000) * model['cost_per_1k_chars']

# Quick reference costs for 27-minute episode
EPISODE_COSTS = {
    'flash_v2_5': calculate_episode_cost('flash_v2_5'),      # $6.75
    'turbo_v2': calculate_episode_cost('turbo_v2'),          # $13.50
    'turbo_v2_5': calculate_episode_cost('turbo_v2_5'),      # $13.50
    'v3_alpha': calculate_episode_cost('v3_alpha'),          # $5.40 (discounted)
    'v3_alpha_normal': 27.00                                 # After June 2025
}
```

---

## 🚨 Error Codes

```python
ERROR_CODES = {
    400: {'type': 'Bad Request', 'action': 'Check parameters', 'retry': False},
    401: {'type': 'Unauthorized', 'action': 'Check API key', 'retry': False},
    403: {'type': 'Forbidden', 'action': 'Check permissions', 'retry': False},
    404: {'type': 'Not Found', 'action': 'Check resource ID', 'retry': False},
    429: {'type': 'Rate Limited', 'action': 'Wait and retry', 'retry': True},
    500: {'type': 'Server Error', 'action': 'Retry later', 'retry': True},
    502: {'type': 'Gateway Error', 'action': 'Retry later', 'retry': True},
    503: {'type': 'Service Unavailable', 'action': 'Check status', 'retry': True}
}

RETRY_CODES = [429, 500, 502, 503]
NO_RETRY_CODES = [400, 401, 403, 404]
```

---

## 🔗 MCP Configuration

```python
MCP_CONFIG = {
    'server_command': 'npx',
    'server_args': ['@elevenlabs/mcp-server'],
    'capabilities': [
        'text_to_speech',
        'voice_clone',
        'transcribe',
        'voice_design',
        'outbound_call',
        'list_voices',
        'get_usage'
    ],
    'environment': {
        'DEFAULT_VOICE': DEFAULT_VOICE,
        'DEFAULT_MODEL': DEFAULT_MODEL,
        'OUTPUT_FORMAT': DEFAULT_OUTPUT_FORMAT,
        'CACHE_ENABLED': 'true'
    }
}
```

---

## 📝 File Paths

```python
PROJECT_PATHS = {
    'base': './projects/nobody_knows',
    'cache': './projects/nobody_knows/cache',
    'episodes': './projects/nobody_knows/episodes',
    'scripts': './projects/nobody_knows/scripts',
    'logs': './projects/nobody_knows/logs',
    'temp': './projects/nobody_knows/temp'
}
```

---

## ⚠️ Important Notes

1. **v3 Discount**: Expires June 30, 2025 - price increases from $0.20 to $1.00 per 1K chars
2. **Rate Limits**: Burst capability allows 3x configured limit temporarily  
3. **Character Counting**: 1 character = 1 credit (including spaces)
4. **Silence Billing**: Silence periods billed at 5% of normal rate
5. **Minimum Text**: 250+ characters recommended for consistent output

---

## 🔄 Version Info

- **Document Version**: 1.0.0
- **Last Updated**: January 2025
- **ElevenLabs API Version**: v1
- **Python SDK Version**: 0.3.0+

---

*This is the single source of truth for all ElevenLabs constants and configuration. All other documentation files should reference this file instead of duplicating values.*