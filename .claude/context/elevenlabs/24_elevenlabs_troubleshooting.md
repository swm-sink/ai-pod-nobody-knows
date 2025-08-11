# ElevenLabs Troubleshooting Guide (2025)

## 🎯 Purpose of This Document
**For You**: Solve common problems quickly and understand what went wrong
**For AI**: Complete error handling patterns and recovery strategies

---

## 🎓 Troubleshooting Mindset

**Think like a detective:**
1. **Symptom**: What's happening?
2. **Pattern**: When does it happen?
3. **Cause**: Why is it happening?
4. **Solution**: How to fix it?
5. **Prevention**: How to avoid it?

---

## 🚨 Common Errors & Solutions

### Error 429: Rate Limit Exceeded
```python
# Symptom
"too_many_concurrent_requests" or "system_busy"

# Cause
RATE_LIMITS = {
    'free': 2,      # concurrent requests
    'starter': 3,
    'creator': 5,
    'pro': 10
}

# Solution
class RateLimitHandler:
    def handle_429(self, error):
        if "too_many_concurrent_requests" in str(error):
            # Reduce concurrent requests
            time.sleep(5)
            return "retry"
        
        elif "system_busy" in str(error):
            # System overload, wait longer
            time.sleep(30)
            return "retry"
        
        return "fail"

# Prevention
- Use semaphores to limit concurrency
- Implement exponential backoff
- Monitor response headers
```

### Error 401: Authentication Failed
```python
# Symptom
"Unauthorized" or "Invalid API key"

# Causes & Solutions
AUTH_ISSUES = {
    'invalid_key': {
        'check': 'Is API key correct?',
        'fix': 'Verify key in ElevenLabs dashboard'
    },
    'expired_key': {
        'check': 'Is subscription active?',
        'fix': 'Check billing status'
    },
    'wrong_env': {
        'check': 'Loading from .env?',
        'fix': 'Ensure load_dotenv() is called'
    },
    'typo': {
        'check': 'Extra spaces in key?',
        'fix': 'Strip whitespace: key.strip()'
    }
}

# Debug authentication
def debug_auth():
    api_key = os.getenv('ELEVENLABS_API_KEY')
    print(f"Key exists: {bool(api_key)}")
    print(f"Key length: {len(api_key) if api_key else 0}")
    print(f"Key starts with: {api_key[:4] if api_key else 'None'}")
```

### Error: Quota Exceeded
```python
# Symptom
"Quota exceeded" or "Insufficient credits"

# Check remaining credits
def check_credits():
    user = client.user.get()
    subscription = user.subscription
    
    print(f"Tier: {subscription.tier}")
    print(f"Character count: {subscription.character_count}")
    print(f"Character limit: {subscription.character_limit}")
    print(f"Remaining: {subscription.character_limit - subscription.character_count}")
    
    return subscription.character_limit - subscription.character_count

# Solutions
if check_credits() < 1000:
    options = [
        "Wait for monthly reset",
        "Upgrade subscription",
        "Use cheaper model (Flash)",
        "Optimize text length"
    ]
```

### Voice Not Found
```python
# Symptom
"Voice not found" or "Invalid voice_id"

# Debug voice issues
def debug_voice(voice_id):
    try:
        # Check if voice exists
        voice = client.voices.get(voice_id)
        print(f"✅ Voice found: {voice.name}")
        
    except Exception as e:
        print(f"❌ Voice error: {e}")
        
        # List available voices
        voices = client.voices.get_all()
        print(f"Available voices: {len(voices.voices)}")
        
        # Suggest alternatives
        for v in voices.voices[:5]:
            print(f"  - {v.name}: {v.voice_id}")

# Common voice ID issues
VOICE_ISSUES = {
    'deleted': "Voice removed from library",
    'private': "Voice not shared publicly",
    'typo': "Check voice_id spelling",
    'case': "Voice IDs are case-sensitive"
}
```

### WebSocket Connection Issues
```python
# Symptom
"Connection closed" or "WebSocket error"

# Debug WebSocket
async def debug_websocket():
    issues = {
        'timeout': {
            'symptom': 'Connection closes after 20s',
            'fix': 'Send keep-alive: {"text": " "}'
        },
        'ssl_error': {
            'symptom': 'SSL handshake failed',
            'fix': 'Update certificates or use http for testing'
        },
        'network': {
            'symptom': 'Connection refused',
            'fix': 'Check firewall/proxy settings'
        }
    }
    
    # Test connection
    try:
        async with websockets.connect(ws_url) as ws:
            await ws.send(json.dumps({"text": "test"}))
            response = await ws.recv()
            print(f"✅ WebSocket working: {response}")
    except Exception as e:
        print(f"❌ WebSocket error: {e}")
        
        # Try fallback to HTTP
        print("Falling back to HTTP API...")
```

### Audio Quality Issues
```python
# Common quality problems and fixes
QUALITY_ISSUES = {
    'robotic_sound': {
        'cause': 'Text too short (<250 chars)',
        'fix': 'Add context or combine sentences'
    },
    'wrong_emotion': {
        'cause': 'Voice incompatible with emotion tag',
        'fix': 'Choose different voice or remove tag'
    },
    'pronunciation': {
        'cause': 'Model doesn\'t understand word',
        'fix': 'Use phonetic spelling or SSML tags'
    },
    'inconsistent': {
        'cause': 'Stability setting too low',
        'fix': 'Increase stability to 70-80%'
    },
    'cut_off': {
        'cause': 'Text exceeds character limit',
        'fix': 'Split into smaller chunks'
    }
}

def diagnose_audio_issue(audio_file):
    """Analyze audio for common issues"""
    from pydub import AudioSegment
    
    audio = AudioSegment.from_mp3(audio_file)
    
    issues = []
    
    # Check duration
    if len(audio) < 1000:  # Less than 1 second
        issues.append("Audio too short - check text input")
    
    # Check volume
    if audio.dBFS < -30:
        issues.append("Audio too quiet - check voice settings")
    
    # Check for silence
    silence = detect_silence(audio)
    if len(silence) > 5:
        issues.append("Multiple silence gaps detected")
    
    return issues
```

---

## 🔧 Debugging Tools

### API Response Inspector
```python
def inspect_api_response(response):
    """
    Detailed response analysis
    """
    print("=== API Response Debug ===")
    print(f"Status Code: {response.status_code if hasattr(response, 'status_code') else 'N/A'}")
    print(f"Headers: {response.headers if hasattr(response, 'headers') else 'N/A'}")
    
    # Check rate limit headers
    if hasattr(response, 'headers'):
        headers = response.headers
        print(f"Rate Limit: {headers.get('X-RateLimit-Limit', 'N/A')}")
        print(f"Remaining: {headers.get('X-RateLimit-Remaining', 'N/A')}")
        print(f"Reset: {headers.get('X-RateLimit-Reset', 'N/A')}")
        print(f"Concurrent: {headers.get('current-concurrent-requests', 'N/A')}/{headers.get('maximum-concurrent-requests', 'N/A')}")
```

### Cost Calculator Debugger
```python
def debug_cost_calculation(text, model):
    """
    Verify cost calculations
    """
    char_count = len(text)
    
    rates = {
        'eleven_flash_v2_5': 0.00025,
        'eleven_turbo_v2_5': 0.0005,
        'eleven_v3_alpha': 0.0002  # Discounted
    }
    
    cost = char_count * rates.get(model, 0.0005)
    
    print(f"Text length: {char_count} characters")
    print(f"Model: {model}")
    print(f"Rate: ${rates.get(model, 0.0005)} per character")
    print(f"Calculated cost: ${cost:.4f}")
    print(f"For 27-min episode: ${cost * 27:.2f}")
    
    return cost
```

---

## 📊 Performance Diagnostics

### Latency Analyzer
```python
def analyze_latency():
    """
    Identify performance bottlenecks
    """
    import time
    
    metrics = {
        'network': 0,
        'generation': 0,
        'download': 0
    }
    
    # Test network latency
    start = time.time()
    client.voices.get_all()  # Simple API call
    metrics['network'] = time.time() - start
    
    # Test generation speed
    start = time.time()
    audio = client.generate(
        text="Test latency measurement.",
        voice="Rachel",
        model="eleven_flash_v2_5"
    )
    metrics['generation'] = time.time() - start
    
    # Analyze results
    print(f"Network latency: {metrics['network']:.2f}s")
    print(f"Generation time: {metrics['generation']:.2f}s")
    
    if metrics['network'] > 1:
        print("⚠️ Slow network connection")
    if metrics['generation'] > 5:
        print("⚠️ Slow generation - try different model")
```

---

## 🚑 Emergency Recovery

### Fallback System
```python
class FallbackSystem:
    """
    Graceful degradation when things go wrong
    """
    
    def __init__(self):
        self.strategies = [
            self.try_primary,
            self.try_alternative_model,
            self.try_cached,
            self.try_basic_tts
        ]
    
    def generate_with_fallback(self, text, voice):
        """
        Try multiple strategies
        """
        for strategy in self.strategies:
            try:
                result = strategy(text, voice)
                if result:
                    return result
            except Exception as e:
                print(f"Strategy failed: {e}")
                continue
        
        # All strategies failed
        return self.return_error_audio()
    
    def try_primary(self, text, voice):
        """Primary: v3 model"""
        return client.generate(text, voice, "eleven_v3_alpha")
    
    def try_alternative_model(self, text, voice):
        """Fallback: Turbo model"""
        return client.generate(text, voice, "eleven_turbo_v2_5")
    
    def try_cached(self, text, voice):
        """Check cache for similar text"""
        return cache.get_similar(text, voice)
    
    def try_basic_tts(self, text, voice):
        """Last resort: Flash model with basic settings"""
        return client.generate(
            text, 
            "Rachel",  # Default voice
            "eleven_flash_v2_5"
        )
```

---

## 📝 Error Log Analysis

### Pattern Recognition
```python
def analyze_error_patterns(log_file):
    """
    Find patterns in errors
    """
    errors = []
    
    with open(log_file, 'r') as f:
        for line in f:
            if 'error' in line.lower():
                errors.append(line)
    
    # Categorize errors
    patterns = {
        'rate_limit': 0,
        'auth': 0,
        'network': 0,
        'voice': 0,
        'other': 0
    }
    
    for error in errors:
        if '429' in error:
            patterns['rate_limit'] += 1
        elif '401' in error:
            patterns['auth'] += 1
        elif 'timeout' in error:
            patterns['network'] += 1
        elif 'voice' in error.lower():
            patterns['voice'] += 1
        else:
            patterns['other'] += 1
    
    # Report findings
    print("Error Pattern Analysis:")
    for pattern, count in patterns.items():
        if count > 0:
            print(f"  {pattern}: {count} occurrences")
    
    # Recommendations
    if patterns['rate_limit'] > 5:
        print("💡 Recommendation: Implement better rate limiting")
    if patterns['network'] > 3:
        print("💡 Recommendation: Add retry logic with backoff")
```

---

## 🔮 Preventive Measures

### Health Check System
```python
def daily_health_check():
    """
    Proactive problem detection
    """
    checks = {
        'api_key': test_authentication(),
        'credits': check_credit_balance(),
        'voices': verify_voice_availability(),
        'models': test_model_access(),
        'network': test_network_speed()
    }
    
    # Alert if issues found
    for check, result in checks.items():
        if not result:
            send_alert(f"Health check failed: {check}")
    
    return all(checks.values())

def test_authentication():
    try:
        client.user.get()
        return True
    except:
        return False

def check_credit_balance():
    user = client.user.get()
    remaining = user.subscription.character_limit - user.subscription.character_count
    return remaining > 10000  # Alert if less than 10k credits

def verify_voice_availability():
    required_voices = ['Rachel', 'Antoni']
    voices = client.voices.get_all()
    available = [v.name for v in voices.voices]
    return all(v in available for v in required_voices)
```

---

## 💡 Quick Reference

### Error Code Cheat Sheet
```
400 - Bad Request (check parameters)
401 - Unauthorized (check API key)
403 - Forbidden (check permissions)
404 - Not Found (check voice/model ID)
429 - Rate Limited (slow down)
500 - Server Error (retry later)
502 - Gateway Error (ElevenLabs issue)
503 - Service Unavailable (maintenance)
```

### Recovery Priority
1. **Always retry**: Network timeouts, 502, 503
2. **Sometimes retry**: 429 (with backoff), 500
3. **Never retry**: 401, 403, 404
4. **Check and fix**: 400

---

## 🎓 Learning from Errors

Each error teaches you:
- **Rate limits** → Better architecture
- **Auth failures** → Security practices
- **Quality issues** → Prompt engineering
- **Network errors** → Resilient systems

---

*Last Updated: January 2025*
*Based on ElevenLabs API error responses and best practices*