# ElevenLabs Documentation Index

## 📚 Documentation Structure (DRY-Compliant)

This documentation follows the DRY (Don't Repeat Yourself) principle. **Start with the constants file for all specifications, then read topic-specific guides.**

---

## 🎯 File Organization & Purpose

### Core Reference (Read First!)
- **[00_elevenlabs_constants.md](./00_elevenlabs_constants.md)** ⭐
  - Single source of truth for ALL specifications
  - Model specs, pricing, voice IDs, API endpoints
  - Reference this instead of memorizing values

### Conceptual Understanding
- **[15_elevenlabs_overview.md](./15_elevenlabs_overview.md)**
  - What is ElevenLabs and why use it
  - Integration with your podcast project
  - Learning path overview
  - *References constants for specs*

- **[16_elevenlabs_models_reference.md](./16_elevenlabs_models_reference.md)**
  - Model selection strategies
  - Use case comparisons
  - Decision trees for your project
  - *References constants for model details*

### Implementation Guides
- **[17_elevenlabs_prompt_engineering.md](./17_elevenlabs_prompt_engineering.md)**
  - Text optimization techniques
  - Audio tag usage (v3)
  - Voice direction strategies
  - *References constants for tags and settings*

- **[18_elevenlabs_api_implementation.md](./18_elevenlabs_api_implementation.md)**
  - Python SDK setup and usage
  - Code patterns and examples
  - Async implementation
  - *References constants for endpoints and limits*

- **[19_elevenlabs_websocket_streaming.md](./19_elevenlabs_websocket_streaming.md)**
  - Real-time streaming setup
  - Buffer management
  - Latency optimization
  - *References constants for WebSocket config*

### Optimization & Management
- **[20_elevenlabs_cost_optimization.md](./20_elevenlabs_cost_optimization.md)**
  - Cost reduction strategies
  - Caching techniques
  - Budget tracking
  - *References constants for pricing*

- **[21_elevenlabs_voice_management.md](./21_elevenlabs_voice_management.md)**
  - Voice selection and testing
  - Cloning procedures
  - Voice library navigation
  - *References constants for voice IDs*

### Integration & Production
- **[22_elevenlabs_mcp_integration.md](./22_elevenlabs_mcp_integration.md)**
  - Claude Code direct integration
  - MCP server setup
  - Custom commands
  - *References constants for MCP config*

- **[23_elevenlabs_podcast_production.md](./23_elevenlabs_podcast_production.md)**
  - Complete production pipeline
  - Quality assurance
  - Distribution preparation
  - *References constants for podcast specs*

### Support
- **[24_elevenlabs_troubleshooting.md](./24_elevenlabs_troubleshooting.md)**
  - Error diagnosis and recovery
  - Common issues and solutions
  - Debug tools and techniques
  - *References constants for error codes*

---

## 🎓 Learning Paths

### Path 1: Quick Start (2-3 hours)
1. Read `00_constants` - Understand the landscape
2. Read `15_overview` - Get the big picture
3. Read `18_api_implementation` - Start coding
4. Try basic generation examples

### Path 2: Cost-Conscious (4-5 hours)
1. Read `00_constants` - Focus on pricing section
2. Read `20_cost_optimization` - Learn savings strategies
3. Read `16_models_reference` - Choose cost-effective models
4. Implement caching and optimization

### Path 3: Production Ready (8-10 hours)
1. Complete Quick Start path
2. Read `17_prompt_engineering` - Master voice control
3. Read `21_voice_management` - Select perfect voices
4. Read `23_podcast_production` - Build pipeline
5. Read `24_troubleshooting` - Prepare for issues

### Path 4: Advanced Integration (12+ hours)
1. Complete Production Ready path
2. Read `19_websocket_streaming` - Implement real-time
3. Read `22_mcp_integration` - Connect to Claude
4. Build complete automated system

---

## 💡 How to Use This Documentation

### For Learning:
1. **Start with constants** to understand what's available
2. **Read overview** for context and motivation
3. **Follow a learning path** based on your goals
4. **Try code examples** in a test environment
5. **Reference troubleshooting** when stuck

### For Implementation:
1. **Import constants** in your code:
   ```python
   from elevenlabs_constants import (
       ELEVENLABS_MODELS,
       VOICE_IDS,
       DEFAULT_MODEL,
       calculate_episode_cost
   )
   ```

2. **Use configuration objects**:
   ```python
   model = ELEVENLABS_MODELS['turbo_v2_5']
   print(f"Using {model['name']} with {model['languages']} languages")
   ```

3. **Reference presets**:
   ```python
   voice_settings = VOICE_SETTINGS_PRESETS['podcast_host']
   ```

---

## 📊 Quick Reference Matrix

| Task | Primary File | Supporting Files |
|------|-------------|------------------|
| Choose a model | `16_models_reference` | `00_constants`, `20_cost` |
| Set up API | `18_api_implementation` | `00_constants` |
| Optimize costs | `20_cost_optimization` | `00_constants`, `16_models` |
| Fix an error | `24_troubleshooting` | `00_constants` |
| Generate podcast | `23_podcast_production` | All files |
| Stream audio | `19_websocket_streaming` | `00_constants`, `18_api` |
| Select voice | `21_voice_management` | `00_constants` |
| Add emotions | `17_prompt_engineering` | `00_constants` |

---

## 🔄 Maintenance Notes

### When ElevenLabs Updates:
1. Update `00_elevenlabs_constants.md` ONLY
2. All other files automatically use new values
3. Test with new constants
4. Document breaking changes here

### Version Tracking:
- Constants Version: 1.0.0
- Documentation Set: January 2025
- Based on: ElevenLabs API v1

---

## ⚡ Quick Start Code

```python
# Minimal working example using constants
from elevenlabs import ElevenLabs
import os

# Load from constants
DEFAULT_MODEL = 'eleven_turbo_v2_5'
DEFAULT_VOICE = 'rachel'

# Initialize
client = ElevenLabs(api_key=os.getenv('ELEVENLABS_API_KEY'))

# Generate
audio = client.generate(
    text="Welcome to Nobody Knows podcast!",
    voice=DEFAULT_VOICE,
    model=DEFAULT_MODEL
)

# Save
with open('test.mp3', 'wb') as f:
    f.write(audio)
```

---

## 🎯 Your Next Action

1. **Read** `00_elevenlabs_constants.md` (10 minutes)
2. **Choose** your learning path above
3. **Set up** your environment with API key
4. **Try** the quick start code
5. **Build** your first podcast episode!

---

*This documentation is optimized for both human learning and AI context. The DRY principle ensures consistency and maintainability.*