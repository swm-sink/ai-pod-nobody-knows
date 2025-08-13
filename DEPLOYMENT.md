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
git clone https://github.com/smenssink/ai-podcasts-nobody-knows.git
cd ai-podcasts-nobody-knows

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment
cp .env.example .env
# Edit .env with your API keys (see Configuration section)

# 5. Start Claude Code
# Open Claude Code application (desktop app)
# Navigate to this project directory

# 6. Run your first test (no API keys needed!)
# In Claude Code interface, run:
/test-episode-dry-run
```

## 📚 Prerequisites

### Required Software
- **Python 3.11+** - Core runtime
- **Node.js 18+** - For MCP servers (Perplexity)
- **Git** - Version control
- **Claude Code** - AI development platform (desktop app)

### Recommended Software
- **Pre-commit** - For automated code quality checks
- **Virtual environment** - Python dependency isolation
- **VS Code** - For editing XML documentation

### API Keys (for CRAWL phase and beyond)
- **Perplexity API** - For research (via MCP)
- **ElevenLabs API** - For audio synthesis (via MCP)
- **Note:** Claude Code uses built-in Claude - no separate API key needed

## 🔧 Installation

### Option 1: Local Development (Recommended for Learning)

1. **Clone and Navigate:**
```bash
git clone https://github.com/smenssink/ai-podcasts-nobody-knows.git
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
# Claude Code is a desktop application
# Download from: https://claude.ai/download
# Install and launch the application
# Open this project folder in Claude Code
```

4. **Configure MCP Servers:**
```bash
# MCPs are already installed in .claude/mcp-servers/
# Configure in Claude Code settings or .mcp.json
# Restart Claude Code to load MCP servers
```

### Option 2: Production Deployment

For production deployment:
1. Set up proper environment variables in `.env`
2. Configure cost limits and monitoring
3. Use batch processing for efficiency
4. Monitor with `/production-metrics` command

See `.claude/level-2-production/docs/QUICK_START_GUIDE.xml` for detailed production setup.

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

Configure Claude Code settings in `.claude/settings.local.json`:

```json
{
  "permissions": {
    "git": true,
    "filesystem": {
      "write": true,
      "delete": true
    }
  },
  "hooks": {
    "pre-commit": "bash .claude/hooks/pre-commit-quality.sh",
    "session-complete": "bash .claude/hooks/session-complete.sh"
  }
}
```

## 🎙️ Running Your First Episode

### Phase 1: WALK (Free Learning - No API Keys)

```bash
# Start Claude Code application
# Open project folder

# In Claude Code interface, run:
/test-episode-dry-run    # Test without API calls

# Explore available commands
/agent-builder-production    # Learn about agents
/command-builder-production  # Learn about commands
```

### Phase 2: CRAWL (First Real Episode - API Keys Required)

```bash
# Ensure .env is configured with API keys
# Start Claude Code application

# In Claude Code interface:
/produce-episode         # Produce first episode
/production-metrics      # Monitor progress
/pipeline-coordinator    # Manage pipeline
```

### Phase 3: RUN (Batch Production)

```bash
# In Claude Code interface:
/batch-produce          # Produce multiple episodes
/production-metrics     # View statistics
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
# In Claude Code interface:
/produce-episode        # Single episode production
/batch-produce          # Multiple episodes
/production-metrics     # View metrics
/pipeline-coordinator   # Manage pipeline

# Shell commands for monitoring:
ls projects/nobody-knows/output/sessions/  # View sessions
tail -f projects/nobody-knows/output/sessions/*.json  # Monitor progress
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

### Cost Control

```bash
# Cost monitoring via environment variables in .env:
DAILY_COST_LIMIT=10.00
EPISODE_COST_LIMIT=5.00

# Monitor costs with:
/production-metrics     # View production statistics

# Cost optimization built into agents
# See .claude/context/ai-orchestration/cost_optimization_strategies.xml
```

## 🔍 Troubleshooting

### Common Issues

#### 1. API Key Errors
```bash
Error: Invalid API key
Solution: Verify .env file and key format
Test: In Claude Code, test MCP tools directly
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
Solution: Check session files in projects/nobody-knows/output/sessions/
Recovery: Review error in session file and retry with /produce-episode
```

#### 4. Memory Issues
```bash
Error: Context window exceeded
Solution: Clear context in Claude Code
Fix: Use Claude Code's clear conversation, then continue
```

### Debug Commands

```bash
# Test pipeline without API calls
/test-episode-dry-run

# Run validation scripts
bash scripts/precommit/validate_dry_compliance.sh
bash scripts/precommit/validate_navigation.sh

# Check agent dependencies
bash .claude/level-2-production/tools/fix-agent-dependencies.sh
```

### Output Locations

- **Session Files**: `projects/nobody-knows/output/sessions/`
- **Research Output**: `projects/nobody-knows/output/research/`
- **Scripts**: `projects/nobody-knows/output/scripts/`
- **Audio Files**: `projects/nobody-knows/output/audio/`
- **Quality Reports**: `projects/nobody-knows/output/quality/`

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
2. **GitHub Issues**: [Create an issue](https://github.com/smenssink/ai-podcasts-nobody-knows/issues)
3. **GitHub Discussions**: Share experiences and tips
4. **Context Files**: Extensive documentation in `.claude/context/`

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
