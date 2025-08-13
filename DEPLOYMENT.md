# 🚀 AI Podcasts Nobody Knows - Deployment Guide

## 📋 Table of Contents
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running Your First Episode](#running-your-first-episode)
- [Production Deployment](#production-deployment)
- [Cost Management](#cost-management)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

## 🎯 Quick Start

**Get up and running in 5 minutes:**

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/ai-podcasts-nobody-knows.git
cd ai-podcasts-nobody-knows

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Install Claude Code CLI
npm install -g @anthropic/claude-code

# 5. Configure environment
cp .env.example .env
# Edit .env with your API keys (see Configuration section)

# 6. Initialize the system
claude code --init

# 7. Run your first test (no API keys needed!)
claude code --command /walk-phase-test
```

## 📚 Prerequisites

### Required Software
- **Python 3.9+** - Core runtime
- **Node.js 18+** - For Claude Code CLI
- **Git** - Version control
- **Claude Code CLI** - AI development platform

### Recommended Software
- **Docker** (optional) - For containerized deployment
- **PostgreSQL** (optional) - For production session storage
- **Redis** (optional) - For caching and queues

### API Keys (for CRAWL phase and beyond)
- **Anthropic Claude API** - For AI agents
- **Perplexity API** (optional) - For research enhancement
- **ElevenLabs API** (optional) - For audio synthesis
- **OpenAI API** (optional) - For GPT-based quality validation

## 🔧 Installation

### Option 1: Local Development (Recommended for Learning)

1. **Clone and Navigate:**
```bash
git clone https://github.com/yourusername/ai-podcasts-nobody-knows.git
cd ai-podcasts-nobody-knows
```

2. **Python Environment Setup:**
```bash
# Create virtual environment
python -m venv venv

# Activate it
# macOS/Linux:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

3. **Claude Code Setup:**
```bash
# Install Claude Code globally
npm install -g @anthropic/claude-code

# Or use npx (no installation needed)
npx @anthropic/claude-code --version
```

4. **Initialize Project Memory:**
```bash
claude code
# In Claude Code, run:
/init
```

### Option 2: Docker Deployment (Production)

```bash
# Build the container
docker build -t ai-podcasts .

# Run with environment variables
docker run -it \
  -e ANTHROPIC_API_KEY=your_key \
  -v $(pwd)/output:/app/output \
  ai-podcasts
```

### Option 3: Cloud Deployment

See `.claude/docs/cloud-deployment.md` for AWS/GCP/Azure instructions.

## ⚙️ Configuration

### Environment Variables

Create a `.env` file from the template:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```bash
# Core Configuration (Required for CRAWL phase)
ANTHROPIC_API_KEY=sk-ant-xxxxx  # Your Claude API key

# Optional Enhancements
PERPLEXITY_API_KEY=pplx-xxxxx   # For research
ELEVENLABS_API_KEY=el-xxxxx     # For audio synthesis
OPENAI_API_KEY=sk-xxxxx         # For GPT validation

# Cost Controls (Recommended)
DAILY_COST_LIMIT=10.00           # Maximum daily spend
EPISODE_COST_LIMIT=5.00          # Maximum per episode
WARNING_THRESHOLD=0.80           # Alert at 80% of limit

# Performance Settings
MAX_CONCURRENT_AGENTS=3          # Parallel agent execution
CACHE_ENABLED=true               # Enable response caching
BATCH_SIZE=5                     # Episodes per batch
```

### MCP Server Configuration

Configure Model Context Protocol servers for enhanced capabilities:

```bash
# Add Perplexity for research
claude mcp add perplexity

# Add ElevenLabs for audio
claude mcp add elevenlabs

# Add GitHub for repository management
claude mcp add github
```

### Claude Code Settings

Configure Claude Code hooks in `.claude/config/settings.json`:

```json
{
  "hooks": {
    "pre-commit": "python scripts/validate.py",
    "post-episode": "python scripts/cost-tracker.py",
    "session-end": "git add . && git commit -m 'Session: $(date)'"
  },
  "memory": {
    "persistent": true,
    "location": ".claude/memory"
  }
}
```

## 🎙️ Running Your First Episode

### Phase 1: WALK (Free Learning - No API Keys)

```bash
# Start Claude Code
claude code

# Run free learning activities
/walk-phase-test

# Explore the system
/explore-agents
/test-pipeline-mock
```

### Phase 2: CRAWL (First Real Episode - API Keys Required)

```bash
# Ensure .env is configured with API keys
# Start Claude Code
claude code

# Produce your first episode
/produce-episode 1

# Monitor progress
/session-status

# Check costs
/cost-dashboard
```

### Phase 3: RUN (Batch Production)

```bash
# Produce multiple episodes
/batch-production 1-5

# Season management
/produce-season 1
```

## 🏭 Production Deployment

### System Requirements

- **CPU**: 2+ cores recommended
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB for system, 1GB per 10 episodes
- **Network**: Stable internet for API calls

### Deployment Checklist

- [ ] API keys configured and tested
- [ ] Cost limits set appropriately
- [ ] Monitoring configured (see `.claude/level-2-production/observability.xml`)
- [ ] Backup strategy in place
- [ ] Error recovery tested
- [ ] Session storage configured
- [ ] Logging enabled

### Production Commands

```bash
# Start production system
./scripts/start-production.sh

# Monitor system health
./scripts/health-check.sh

# View logs
tail -f logs/production.log

# Backup session data
./scripts/backup-sessions.sh
```

### Scaling Considerations

1. **Horizontal Scaling**: Run multiple instances with different episode ranges
2. **Caching**: Enable Redis for 42% cost reduction
3. **Batch Processing**: Process 5-10 episodes concurrently
4. **Model Cascading**: Use cheaper models for simple tasks

## 💰 Cost Management

### Expected Costs

| Phase | Episodes | Monthly Cost | Per Episode |
|-------|----------|--------------|-------------|
| WALK  | 0        | $0           | $0          |
| CRAWL | 1-5      | $20-50       | $10-15      |
| RUN   | 50+      | $200-250     | $4-5        |

### Cost Optimization Tips

1. **Use Caching**: Reduces costs by 42%
2. **Batch Processing**: 50% discount on grouped API calls
3. **Model Cascading**: Use budget models when possible
4. **Content Reuse**: Leverage memory system
5. **Monitor Daily**: Check `/cost-dashboard` regularly

### Cost Control Commands

```bash
# Check current costs
/cost-dashboard

# Set cost limits
/set-cost-limit daily 10.00
/set-cost-limit episode 5.00

# View cost history
/cost-history 7  # Last 7 days
```

## 🔍 Troubleshooting

### Common Issues

#### 1. API Key Errors
```bash
Error: Invalid API key
Solution: Verify .env file and key format
Test: claude code --test-api
```

#### 2. Cost Limit Exceeded
```bash
Error: Daily cost limit reached
Solution: Increase limit or wait until tomorrow
Override: /force-continue (use cautiously)
```

#### 3. Agent Pipeline Failures
```bash
Error: Agent 03_script_writer failed
Solution: Check logs and retry
Recovery: /retry-from-stage SCRIPT_GENERATION
```

#### 4. Memory Issues
```bash
Error: Context window exceeded
Solution: Clear context and continue
Fix: /clear then /resume-episode
```

### Debug Commands

```bash
# Enable verbose logging
export DEBUG=true

# Test individual agents
/test-agent 01_research_coordinator

# Validate configuration
/validate-config

# Check system health
/health-check
```

### Log Locations

- **System Logs**: `logs/system.log`
- **Episode Logs**: `output/episodes/ep_*/logs/`
- **Cost Logs**: `logs/costs.log`
- **Error Logs**: `logs/errors.log`

## 📖 Learning Resources

### Documentation Structure
- **Quick Start**: `.claude/context/foundation/01_project_overview.xml`
- **Learning Path**: `.claude/context/foundation/02_walk_crawl_run_phases.xml`
- **Free Activities**: `.claude/context/foundation/04_no_api_keys_activities.xml`
- **Troubleshooting**: `.claude/context/operations/01_troubleshooting_guide.xml`

### Educational Progression
1. **WALK Phase** (Weeks 1-4): Learn concepts without spending
2. **CRAWL Phase** (Weeks 5-12): Connect APIs, produce first episodes
3. **RUN Phase** (Weeks 13+): Scale production, optimize costs

### Community Resources
- **GitHub Issues**: Report bugs and request features
- **Discussions**: Share experiences and tips
- **Wiki**: Community-contributed guides

## 🆘 Support

### Getting Help

1. **Documentation First**: Check `.claude/context/operations/01_troubleshooting_guide.xml`
2. **GitHub Issues**: [Create an issue](https://github.com/yourusername/ai-podcasts-nobody-knows/issues)
3. **Community Discord**: Join our learning community
4. **Email Support**: support@ai-podcasts-nobody-knows.com

### Reporting Issues

When reporting issues, include:
- Error messages and stack traces
- Your phase (WALK/CRAWL/RUN)
- Configuration (redact API keys)
- Steps to reproduce
- System information

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Submitting bug reports
- Requesting features
- Contributing code
- Improving documentation

## 🎓 What This Deployment Teaches You

**Technical:** This deployment guide demonstrates production deployment practices including environment configuration, dependency management, scaling strategies, cost optimization, monitoring setup, and operational procedures.

**Simple:** Like getting a complex machine ready to run in a factory - you need to install it correctly, configure all the settings, test everything works, and know how to fix problems when they arise.

**Connection:** These deployment skills transfer to any software project, teaching you how to move from development to production, manage configurations, handle scaling, and maintain systems reliably.

---

**Version**: 1.0.0 | **Updated**: 2025-08-13 | **License**: MIT
