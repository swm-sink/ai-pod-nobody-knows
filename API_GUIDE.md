# 🔑 API Integration Guide - Keys, Costs & Optimization

Complete guide to API integration, cost management, and optimization for the AI podcast system.

## 🎯 Required APIs & Costs

### ElevenLabs (Audio Synthesis)
**Service**: Professional voice synthesis for podcast audio
**Cost**: ~$2-3 per episode (28 minutes)
**Pricing Model**: $0.30 per 1,000 characters

**Get Your Key:**
1. Visit [elevenlabs.io/app/settings](https://elevenlabs.io/app/settings)
2. Create free account (includes free credits)
3. Navigate to "API Keys"
4. Generate new key (starts with `sk_`)

### Perplexity (Research)
**Service**: AI research with real-time web search
**Cost**: ~$1-2 per episode
**Pricing Model**: $5 per 1M tokens

**Get Your Key:**
1. Visit [perplexity.ai/settings/api](https://www.perplexity.ai/settings/api)
2. Create account (Pro recommended)
3. Generate API key (starts with `pplx-`)

---

## 💰 Cost Breakdown & Optimization

### Per Episode Costs (Proven Results)
```yaml
research_phase:
  perplexity_queries: "$0.50-1.00"
  fact_verification: "$0.25-0.50"
  synthesis: "$0.25-0.50"
  total_research: "$1.00-2.00"

script_phase:
  writing: "$0.50-0.75"
  quality_validation: "$0.50-0.75"
  polishing: "$0.25-0.50"
  total_script: "$1.25-2.00"

audio_phase:
  voice_synthesis: "$2.00-3.00"
  quality_validation: "$0.25-0.50"
  total_audio: "$2.25-3.50"

total_per_episode: "$4.50-7.50"
proven_average: "$5.51"
```

### Cost Optimization Strategies

**Single-Call Audio Synthesis**
- **Benefit**: No audio concatenation needed
- **Requirement**: Scripts under 40,000 characters (95% of episodes)
- **Savings**: 20-30% cost reduction vs chunked synthesis

**Research Caching**
- **Benefit**: Reuse research for related topics
- **Implementation**: 24-hour cache for expert information
- **Savings**: 30-40% for series on related topics

**Batch Processing**
- **Benefit**: Parallel processing efficiency gains
- **Savings**: 25-30% cost reduction for 10+ episodes
- **Optimal**: 5 concurrent episodes maximum

---

## 🛡️ Budget Controls & Monitoring

### Automated Cost Controls
```bash
# Set in .env file
MAX_COST_PER_EPISODE=5.00
DAILY_COST_LIMIT=20.00
BUDGET_ALERT_THRESHOLD=8.00
```

### Real-Time Monitoring
```bash
# Check current spending
grep "$(date +%Y-%m-%d)" .claude/logs/cost-tracking.log

# View cost by operation type
./scripts/cost-analysis.sh

# Get cost breakdown for specific episode
./scripts/episode-cost-report.sh [episode-number]
```

### Cost Protection Features
- **Pre-validation**: Budget checking before expensive operations
- **Real-time tracking**: Live cost monitoring during production
- **Alert system**: Warnings at 80% of budget limits
- **Emergency stop**: Automatic halt at budget limits

---

## 📊 API Usage Optimization

### Perplexity Optimization
```yaml
query_optimization:
  model_selection:
    discovery: "sonar-pro ($5/1M tokens)"
    deep_research: "sonar-reasoning ($5/1M tokens)"

  token_management:
    max_per_query: 8192
    typical_usage: 3000-5000
    cost_per_episode: "$1.00-2.00"

  caching_strategy:
    research_results: "24 hour cache"
    expert_profiles: "7 day cache"
    common_topics: "30 day cache"
```

### ElevenLabs Optimization
```yaml
synthesis_optimization:
  voice_settings:
    voice_id: "ZF6FPAbjXT4488VcRRnw"  # Validated Amelia voice
    model: "eleven_turbo_v2_5"
    stability: 0.65
    similarity: 0.8
    style: 0.3

  cost_efficiency:
    single_call_limit: "40,000 characters"
    chunking_fallback: "5,000 character chunks with 100 char overlap"
    cost_per_1000_chars: "$0.30"

  quality_optimization:
    ssml_processing: "Natural pauses and emphasis"
    pronunciation_guide: "IPA for technical terms"
    duration_targeting: "28±1 minutes"
```

---

## 🔐 API Key Security

### Security Best Practices
```bash
# Environment file security
chmod 600 .env              # Restrict file permissions
echo ".env" >> .gitignore   # Never commit to git

# API key validation
./test-mcp-connections.sh   # Test keys work correctly

# Key rotation (recommended monthly)
# 1. Generate new keys on service platforms
# 2. Update .env file
# 3. Test connections
# 4. Revoke old keys
```

### Emergency Procedures
**If API Keys Compromised:**
1. **Immediately revoke** keys on service platforms
2. **Generate new keys** and update .env
3. **Test connections** with ./test-mcp-connections.sh
4. **Monitor usage** for any unauthorized activity

---

## 📈 Scaling & Advanced Usage

### Development Environment
```bash
# Free tier limits for development
ELEVENLABS_FREE_TIER=10000  # characters per month
PERPLEXITY_FREE_TIER=5      # queries per month

# Development optimization
SHADOW_MODE=true            # Test without costs
LOG_LEVEL=debug            # Enhanced debugging
```

### Production Scaling
```bash
# Production environment variables
BATCH_SIZE=5               # Concurrent episodes
CACHE_DURATION=86400       # 24 hour research cache
AUTO_OPTIMIZE=true         # Automatic cost optimization

# Resource allocation
MEMORY_LIMIT=10GB          # For 5 concurrent episodes
SESSION_TIMEOUT=3600       # 1 hour timeout
```

### Enterprise Features
- **Custom Voice Training**: Train specialized voices for your brand
- **Advanced Analytics**: Detailed cost and quality analytics
- **White-Label**: Remove system branding for professional use
- **API Rate Optimization**: Advanced rate limiting and queuing

---

## 📞 API Support & Resources

### Official Documentation
- **ElevenLabs**: [elevenlabs.io/docs](https://elevenlabs.io/docs)
- **Perplexity**: [docs.perplexity.ai](https://docs.perplexity.ai)
- **Claude Code**: [docs.anthropic.com/claude-code](https://docs.anthropic.com/en/docs/claude-code)

### Community Resources
- **ElevenLabs Discord**: Active community for voice synthesis tips
- **Perplexity Community**: Best practices for AI research
- **Claude Code GitHub**: Issues and feature requests

### Getting Help
```bash
# System diagnostics
./validate-config.sh       # Check all configurations
./test-mcp-connections.sh  # Test API connections
claude mcp list           # Check MCP server status

# Cost analysis
grep COST .claude/logs/cost-tracking.log | tail -10

# Quality reports
ls episodes/completed/*/quality_reports/
```

---

## 🎉 Success Metrics

**You'll achieve:**
- **Professional Quality**: 90%+ quality scores across all metrics
- **Cost Efficiency**: $3-7 per episode vs $800-3500 traditional
- **Time Efficiency**: 15-30 minutes vs weeks of traditional production
- **Learning Value**: Deep knowledge about your chosen topics
- **Technical Skills**: Hands-on experience with enterprise AI orchestration

---

**Ready to integrate APIs?** Follow the SETUP_GUIDE.md for step-by-step configuration, then return here to create amazing episodes! 🎙️

*The system handles all API complexity while you focus on choosing fascinating topics that celebrate intellectual humility.*
