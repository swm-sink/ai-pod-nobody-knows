# Integration Guide - LangGraph/LangFuse Local Deployment

## Overview
This guide documents the API integration patterns implemented for the AI podcast production system migration from Claude Code to LangGraph/LangFuse architecture.

**Date**: August 2025
**Deployment**: Local-only (hobby project)
**Goal**: Maintain $5.51/episode cost with direct API integration

## 🏗️ Architecture Overview

### Provider Pattern
All providers implement a common interface (`LLMProvider`) with consistent methods:
- `generate()` - Main generation/synthesis method
- `generate_with_template()` - Template-based generation
- `estimate_cost()` - Cost estimation before execution
- `cleanup()` - Resource cleanup

### Direct API Integration
Each provider uses direct API calls via `httpx` client:
- **NO MCP servers required** (except Perplexity as fallback)
- Graceful fallback to mock mode for testing
- Secure API key handling with masking

## 📦 Provider Implementations

### 1. OpenRouter Provider
**Location**: `src/adapters/openrouter/provider.py`
**Purpose**: Multi-model LLM gateway for text generation

**Key Features**:
- Support for 9+ model providers (OpenAI, Anthropic, Google, etc.)
- Model comparison capabilities
- Dynamic pricing calculation
- Real API calls with httpx client

**API Pattern**:
```python
# Initialize with API key
config = {
    'api_key': 'sk-or-...',  # pragma: allowlist secret
    'model': 'anthropic/claude-opus-4.1'
}
provider = OpenRouterProvider(config)

# Generate text
response = provider.generate(
    prompt="Your prompt here",
    max_tokens=1000,
    temperature=0.7
)

# Compare models
results = provider.compare_models(
    prompt="Test prompt",
    models=['anthropic/claude-opus-4.1', 'openai/gpt-5'],
    max_tokens=100
)
```

**Cost Tracking**:
- Per-model pricing stored in `MODEL_PRICING` dictionary
- Automatic token counting with tiktoken
- Cost estimation before execution

### 2. Perplexity Provider
**Location**: `src/adapters/perplexity/provider.py`
**Purpose**: Research and fact-checking with real-time data

**Key Features**:
- Sonar models for deep research
- Source citation and verification
- August 2025 context enforcement
- Direct API with MCP fallback option

**API Pattern**:
```python
# Initialize
config = {
    'api_key': 'pplx-...',  # pragma: allowlist secret
    'model': 'sonar-deep'
}
provider = PerplexityProvider(config)

# Deep research
results = provider.deep_research(
    topic="AI safety",
    depth="comprehensive",
    sources_required=5
)

# Fact checking
verification = provider.fact_check(
    claim="The Earth is round",
    context="Basic astronomy"
)
```

**Research Templates**:
- `topic_research` - Comprehensive topic exploration
- `fact_check` - Claim verification with sources
- `expert_opinions` - Expert perspective gathering

### 3. ElevenLabs Provider
**Location**: `src/adapters/elevenlabs/provider.py`
**Purpose**: Text-to-speech synthesis for audio production

**Key Features**:
- Production voice ID: `ZF6FPAbjXT4488VcRRnw` (Amelia)
- SSML support for enhanced control
- Voice validation and management
- Direct API only (NO MCP)

**API Pattern**:
```python
# Initialize
config = {
    'api_key': 'xi-...',  # pragma: allowlist secret
    'voice_id': 'ZF6FPAbjXT4488VcRRnw',
    'model_id': 'eleven_turbo_v2_5',
    'output_dir': './audio_output'
}
provider = ElevenLabsProvider(config)

# Synthesize audio
audio_file = provider.generate(
    "Your text to synthesize",
    voice_id='ZF6FPAbjXT4488VcRRnw'
)

# SSML synthesis
audio_file = provider.synthesize_with_ssml(
    '<speak>Hello <emphasis>world</emphasis>!</speak>'
)
```

**Voice Settings**:
```python
VOICE_SETTINGS = {
    "stability": 0.5,
    "similarity_boost": 0.75,
    "style": 0.0,
    "use_speaker_boost": True
}
```

### 4. LangFuse Provider
**Location**: `src/adapters/langfuse/provider.py`
**Purpose**: Observability, tracking, and A/B testing

**Key Features**:
- Execution logging with state tracking
- Cost tracking per execution
- Prompt experimentation
- Metric collection

**API Pattern**:
```python
# Initialize
config = {
    'public_key': 'pk-lf-...',
    'secret_key': 'sk-lf-...',  # pragma: allowlist secret
    'host': 'https://us.cloud.langfuse.com'
}
provider = LangFuseProvider(config)

# Log execution
provider.log_execution(
    execution_id='exec-123',
    workflow_id='workflow-456',
    state=agent_state
)

# Track costs
provider.log_cost(
    execution_id='exec-123',
    cost_type='llm',
    amount=0.05,
    metadata={'model': 'gpt-5'}
)

# A/B testing
exp_id = provider.create_prompt_experiment(
    name='prompt_test',
    variants=[
        {'template': 'Variant A: {topic}'},
        {'template': 'Variant B: Research {topic}'}
    ]
)
```

## 🔒 Security Patterns

### API Key Management
```python
# 1. Environment variables (recommended)
api_key = os.environ.get('OPENROUTER_API_KEY')

# 2. Configuration files (.env)
from dotenv import load_dotenv
load_dotenv()

# 3. Masked logging
masked_key = f"...{api_key[-4:]}" if len(api_key) > 4 else "****"
logger.info(f"Using API key: {masked_key}")

# 4. Error masking
def _mask_error(self, error: Exception) -> str:
    error_msg = str(error)
    if self.api_key:
        error_msg = error_msg.replace(self.api_key, '***API_KEY***')
    return error_msg
```

### Mock Mode Detection
```python
# Automatic mock mode for test keys
if self.api_key.startswith('test_'):
    logger.info("Running in mock mode")
    self._client = None
else:
    self._client = httpx.Client(...)
```

## 🧪 Testing Patterns

### Unit Testing
All providers include comprehensive test coverage:
- Security tests (API key masking)
- Functional tests (generation, cost estimation)
- Integration tests (cross-provider consistency)

### API Connection Testing
Use `test_all_apis.py` to validate connections:
```bash
python test_all_apis.py
```

Results saved to `test_results.json` with detailed status.

## 💰 Cost Optimization

### Cost Estimation Before Execution
```python
# Always estimate before generating
cost = provider.estimate_cost(prompt, max_tokens=1000)
if cost > budget:
    logger.warning(f"Cost ${cost} exceeds budget ${budget}")
    # Use cheaper model or reduce tokens
```

### Model Selection by Cost
```python
# OpenRouter: Choose model by cost
cheap_models = [
    'openai/gpt-3.5-turbo',  # $0.0005/$0.0015 per 1K
    'google/gemini-flash',    # $0.00035/$0.00105 per 1K
]

expensive_models = [
    'anthropic/claude-opus-4.1',  # $0.012/$0.060 per 1K
    'openai/gpt-5',            # $0.008/$0.024 per 1K
]
```

### Character-Based Pricing (ElevenLabs)
```python
# ElevenLabs charges per character, not token
character_count = len(text)
rate_per_1k_chars = 0.24  # Creator tier
cost = (character_count / 1000) * rate_per_1k_chars
```

## 🔄 Error Handling

### Graceful Degradation
```python
try:
    # Try real API call
    response = self._client.post(endpoint, json=payload)
    response.raise_for_status()
    return response.json()
except Exception as e:
    # Fall back to mock response
    logger.warning(f"API failed: {self._mask_error(e)}, using mock")
    return f"[Mock response for: {prompt[:50]}...]"
```

### Retry Logic (TODO)
```python
# Implement exponential backoff
import backoff

@backoff.on_exception(
    backoff.expo,
    httpx.HTTPStatusError,
    max_tries=3
)
def make_api_call(self, payload):
    response = self._client.post(...)
    response.raise_for_status()
    return response
```

## 📝 Configuration Management

### Provider Configuration (providers.yaml)
```yaml
providers:
  openrouter:
    api_key: ${OPENROUTER_API_KEY}
    model: anthropic/claude-opus-4.1
    temperature: 0.7

  perplexity:
    api_key: ${PERPLEXITY_API_KEY}
    model: sonar-deep
    search_recency_filter: week

  elevenlabs:
    api_key: ${ELEVENLABS_API_KEY}
    voice_id: ZF6FPAbjXT4488VcRRnw
    model_id: eleven_turbo_v2_5

  langfuse:
    public_key: ${LANGFUSE_PUBLIC_KEY}
    secret_key: ${LANGFUSE_SECRET_KEY}
    host: https://us.cloud.langfuse.com
```

### Environment Variables (.env)
```bash
# API Keys
OPENROUTER_API_KEY=sk-or-...
PERPLEXITY_API_KEY=pplx-...
ELEVENLABS_API_KEY=xi-...
LANGFUSE_PUBLIC_KEY=pk-lf-...
LANGFUSE_SECRET_KEY=sk-lf-...

# Production Configuration
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
MAX_COST_PER_EPISODE=5.51
```

## 🚀 Usage Example

### Complete Episode Production Flow
```python
# 1. Research Phase
perplexity = PerplexityProvider(config)
research = perplexity.deep_research(
    topic="Why do we dream?",
    depth="comprehensive",
    sources_required=10
)

# 2. Script Generation
openrouter = OpenRouterProvider(config)
script = openrouter.generate(
    prompt=f"Write a podcast script about: {research['content']}",
    model='anthropic/claude-opus-4.1',
    max_tokens=4000
)

# 3. Audio Synthesis
elevenlabs = ElevenLabsProvider(config)
audio_file = elevenlabs.generate(
    script,
    voice_id='ZF6FPAbjXT4488VcRRnw'
)

# 4. Track Everything
langfuse = LangFuseProvider(config)
langfuse.log_execution(
    execution_id='episode-001',
    workflow_id='production-pipeline',
    state=final_state
)
```

## 📊 Monitoring & Observability

### LangFuse Integration
- Every API call logged with execution ID
- Cost tracking per provider
- Prompt version management
- Performance metrics collection

### Local Logging
```python
# Cost logging to CSV
with open('logs/costs.csv', 'a') as f:
    f.write(f"{timestamp},{provider},{tokens},{cost}\n")

# Quality metrics to JSON
metrics = {
    'episode_id': 'ep-001',
    'brand_score': 8.5,
    'technical_score': 9.0,
    'engagement_score': 8.0
}
with open('logs/quality.json', 'w') as f:
    json.dump(metrics, f)
```

## 🎯 Next Steps

1. **Complete Agent Migration** (13 remaining)
   - Research pipeline agents (2 remaining)
   - Production pipeline agents (4 remaining)
   - Audio pipeline agents (3 remaining)
   - Quality assurance agents (4 remaining)

2. **LangGraph Orchestration**
   - Implement StateGraph for workflows
   - Add conditional routing
   - Enable state persistence

3. **Cost Optimization**
   - Implement retry logic with backoff
   - Add caching for research results
   - Optimize token usage

4. **Production Hardening**
   - Add comprehensive error recovery
   - Implement rate limiting
   - Add monitoring dashboards

## 📚 References

- [LangGraph Documentation](https://python.langchain.com/docs/langgraph)
- [LangFuse Documentation](https://langfuse.com/docs)
- [OpenRouter API](https://openrouter.ai/docs)
- [Perplexity API](https://docs.perplexity.ai)
- [ElevenLabs API](https://elevenlabs.io/docs/api-reference)

---

**Last Updated**: August 31, 2025
**Version**: 1.0.0
**Status**: Day 1 Foundation Complete
