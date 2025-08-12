# Simple Solo Project Setup

## 🎯 Project Approach: Keep It Simple

**Technical:** Minimum viable complexity with focused API integration for hobby-scale podcast production
**Simple:** Use only what you need, when you need it - like cooking with just three ingredients instead of twenty
**Connection:** This teaches you to avoid over-engineering and focus on delivering value

## 📁 Current Architecture

```
Level 2: Native Claude Code (CURRENT FOCUS)
├── Claude Code built-in AI (script writing, quality checks)
├── Perplexity MCP (research)
└── ElevenLabs MCP (audio synthesis)

Level 3: Documentation Only
└── Planning and learning materials

Level 4: Future Coded Platform (NOT YET)
├── OpenRouter API (unified model access)
└── Langfuse (evaluation and observability)
```

## 🔑 API Keys Configuration

### Active APIs (Level 2)
```bash
# Perplexity - For research
PERPLEXITY_API_KEY=pplx-88Ef...

# ElevenLabs - For audio
ELEVENLABS_API_KEY=sk_50ca...
```

### Reserved for Future (Level 4 Only)
```bash
# OpenRouter - Unified model access (NOT USED YET)
OPENROUTER_API_KEY=sk-or-v1-b7b7...

# Langfuse - Evals and observability (NOT USED YET)
# LANGFUSE_API_KEY=your_key_here
```

## 💰 Solo/Hobby Budget Limits

```
Per Episode: $5.00 max
Daily Limit: $10.00 max
Alert at: $4.00

Rate Limits:
- Perplexity: 10 requests/minute
- ElevenLabs: 5 requests/minute
```

## 🚀 Simple Next Steps

### 1. Install Perplexity MCP
```bash
# Check official docs
# https://docs.perplexity.ai/guides/mcp-server
claude mcp add perplexity
```

### 2. Install ElevenLabs MCP
```bash
# Clone official repo
git clone https://github.com/elevenlabs/elevenlabs-mcp.git
cd elevenlabs-mcp
npm install
claude mcp add elevenlabs
```

### 3. Test with Native Claude Code
- Research agent uses Perplexity
- Script writer uses Claude Code (built-in)
- Quality evaluator uses Claude Code (built-in)
- Audio synthesizer uses ElevenLabs

## 📊 What We're NOT Doing

❌ Multiple AI provider management
❌ Complex team collaboration setup
❌ Enterprise-grade monitoring
❌ Cloud secret managers
❌ Staging/production environments
❌ Email alerts
❌ Database storage

## ✅ What We ARE Doing

✅ Simple .env file for API keys
✅ Basic cost tracking
✅ Native Claude Code agents
✅ Two external MCPs (Perplexity + ElevenLabs)
✅ Mock mode for testing
✅ Dry run capability

## 🎓 Learning Focus

**Current Phase**: Learn multi-agent orchestration with Claude Code
**Not Yet**: Don't worry about OpenRouter/Level 4 until Level 2 works
**Keep Simple**: This is a hobby project, not enterprise software

## 📝 Quick Reference

### Test API Keys
```python
# Simple test script
python .claude/scripts/test_api_keys.py
```

### Check Environment
```bash
echo $PERPLEXITY_API_KEY
echo $ELEVENLABS_API_KEY
```

### Run in Mock Mode
```bash
ENABLE_MOCK_MODE=true claude /produce-episode
```

## 🎯 Success Criteria

1. Can research topics with Perplexity
2. Can write scripts with Claude Code
3. Can evaluate quality with Claude Code
4. Can generate audio with ElevenLabs
5. Total cost per episode < $5

## ⚠️ Important Notes

- **OpenRouter is for Level 4 ONLY** (future Python platform)
- **Level 2 uses Claude Code natively** (no extra AI API needed)
- **Focus on getting basics working first**
- **Don't over-engineer for a solo project**

---

**Philosophy**: Build something that works, then improve it.
**Not**: Build the perfect system before producing anything.

**Current Status**: Ready to install MCPs and test
**Next Action**: Install Perplexity and ElevenLabs MCPs
