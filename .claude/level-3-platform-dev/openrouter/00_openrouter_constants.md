# OpenRouter Constants

## API Configuration
- **BASE_URL**: `https://openrouter.ai/api/v1`
- **COMPATIBILITY**: OpenAI API v1 compatible
- **LATENCY**: ~25ms edge deployment overhead
- **AVAILABILITY**: 99.9% uptime SLA

## Authentication
- **API_KEY_PREFIX**: `sk-or-v1-`
- **HEADER_NAME**: `Authorization`
- **HEADER_FORMAT**: `Bearer {API_KEY}`
- **HTTP_REFERER**: Required for API keys (your app URL)

## Pricing Model
- **PRICING_TYPE**: Pass-through (no markup)
- **PAYMENT_METHODS**: Credit card, crypto (5% fee)
- **BYOK_FEE**: 5% on base model cost
- **CREDITS_SYSTEM**: Prepaid credits, auto-deduction

## Rate Limits
- **FREE_TIER_DAILY**: 50 requests (no credits)
- **WITH_CREDITS_DAILY**: 1000 requests ($10+ credits)
- **REQUESTS_PER_MINUTE**: Model-dependent
- **TOKEN_LIMITS**: Model-specific maximums

## Model Categories
- **TOTAL_MODELS**: 400+ models available
- **PROVIDERS**: OpenAI, Anthropic, Google, Meta, Mistral, Llama, others
- **UPDATE_FREQUENCY**: New models added weekly

## Dynamic Routing Suffixes
- **:online**: Includes web search results
- **:nitro**: Optimized for speed
- **:floor**: Optimized for cost
- **:extended**: Extended context windows

## Cost Optimization Targets
- **RESEARCH_PHASE_LIMIT**: $1.00 per episode
- **SCRIPT_GENERATION_LIMIT**: $2.00 per episode  
- **QUALITY_EVALUATION_LIMIT**: $0.50 per episode
- **TOTAL_EPISODE_LIMIT**: $4.00 target using OpenRouter

## Model Selection Strategy
```
TASK_MODEL_MAPPING = {
    "simple_research": "mistralai/mixtral-8x7b-instruct",
    "complex_research": "anthropic/claude-3-sonnet",
    "script_writing": "anthropic/claude-3-opus",
    "quality_evaluation": "openai/gpt-4-turbo",
    "fact_checking": "google/gemini-pro",
    "summarization": "anthropic/claude-instant"
}
```

## Fallback Chains
```
FALLBACK_PRIORITY = {
    "tier_1": ["anthropic/claude-3-opus", "openai/gpt-4"],
    "tier_2": ["anthropic/claude-3-sonnet", "openai/gpt-4-turbo"],
    "tier_3": ["anthropic/claude-instant", "openai/gpt-3.5-turbo"],
    "tier_4": ["mistralai/mixtral-8x7b", "meta-llama/llama-3-70b"]
}
```

## Error Codes
- **RATE_LIMIT**: 429 - Slow down requests
- **INVALID_KEY**: 401 - Check API key
- **MODEL_UNAVAILABLE**: 503 - Try fallback model
- **INSUFFICIENT_CREDITS**: 402 - Add more credits
- **CONTEXT_LENGTH_EXCEEDED**: 400 - Reduce input size

## Performance Benchmarks
- **AVERAGE_LATENCY**: 200-500ms per request
- **P95_LATENCY**: <1000ms
- **SUCCESS_RATE**: >99.5%
- **FAILOVER_TIME**: <100ms

## Monitoring Endpoints
- **MODELS_LIST**: `/api/v1/models`
- **USAGE_STATS**: `/api/v1/usage`
- **CREDITS_BALANCE**: `/api/v1/credits`
- **RATE_LIMITS**: `/api/v1/limits`