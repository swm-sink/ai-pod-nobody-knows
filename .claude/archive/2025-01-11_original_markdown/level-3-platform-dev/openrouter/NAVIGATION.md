# OpenRouter Documentation Navigation

## Quick Links
- [Constants](./00_openrouter_constants.md) - API configuration, pricing, limits
- [Overview](./25_openrouter_overview.md) - What is OpenRouter and why use it
- [API Integration](./26_openrouter_api_integration.md) - Code examples and implementation
- [Model Routing](./27_openrouter_model_routing.md) - Intelligent model selection strategies
- [Cost Optimization](./28_openrouter_cost_optimization.md) - Achieve $4/episode target
- [Production Patterns](./29_openrouter_production_patterns.md) - Reliability and scalability

## Documentation Structure

### Foundation (00-09)
- `00_openrouter_constants.md` - Single source of truth for OpenRouter configuration

### Core Concepts (25-29)
- `25_openrouter_overview.md` - Platform introduction and benefits
- `26_openrouter_api_integration.md` - Technical implementation guide
- `27_openrouter_model_routing.md` - Dynamic model selection
- `28_openrouter_cost_optimization.md` - Cost reduction strategies
- `29_openrouter_production_patterns.md` - Production-ready patterns

## Learning Path

### For Beginners
1. Start with [Overview](./25_openrouter_overview.md)
2. Review [Constants](./00_openrouter_constants.md)
3. Follow [API Integration](./26_openrouter_api_integration.md)

### For Cost Optimization
1. Study [Cost Optimization](./28_openrouter_cost_optimization.md)
2. Understand [Model Routing](./27_openrouter_model_routing.md)
3. Apply patterns from [Production](./29_openrouter_production_patterns.md)

### For Production Deployment
1. Master [Production Patterns](./29_openrouter_production_patterns.md)
2. Implement [API Integration](./26_openrouter_api_integration.md)
3. Configure [Model Routing](./27_openrouter_model_routing.md)

## Key Concepts

### Model Selection
- 400+ models available through single API
- Dynamic routing with :floor, :nitro, :online suffixes
- Automatic failover for reliability

### Cost Management
- Pass-through pricing (no markup)
- Target: $4 per episode
- Achieved: $3.30-3.80 with optimization

### Integration Benefits
- OpenAI SDK compatible
- Unified authentication
- Automatic failover
- Edge deployment (25ms latency)

## Related Documentation
- [Level 3 Platform Development](../) - Parent directory
- [Production System](../../level-2-production/) - Where OpenRouter integrates
- [Cost Constants](../../00_GLOBAL_CONSTANTS.md) - Global budget limits
