# 🚀 Setup Guide - AI Podcast System

Get your AI podcast system running in under 10 minutes with this step-by-step guide.

## ⚡ Quick Start Checklist

```bash
□ Get API keys (5 minutes)
□ Configure environment (2 minutes)  
□ Test connections (1 minute)
□ Create first episode (15 minutes)
```

---

## 📋 Step 1: Get Your API Keys (5 minutes)

### ElevenLabs API Key
1. Go to [elevenlabs.io/app/settings](https://elevenlabs.io/app/settings)
2. Create account (free tier available)
3. Navigate to "API Keys" 
4. Click "Generate API Key"
5. Copy the key (starts with `sk_`)

### Perplexity API Key  
1. Go to [perplexity.ai/settings/api](https://www.perplexity.ai/settings/api)
2. Create account 
3. Navigate to "API" settings
4. Generate new API key
5. Copy the key (starts with `pplx-`)

**Cost Estimates:**
- **ElevenLabs**: ~$2-3 per episode for audio synthesis
- **Perplexity**: ~$1-2 per episode for research
- **Total**: $3-5 per 28-minute professional episode

---

## 📝 Step 2: Configure Environment (2 minutes)

### Create .env File
```bash
# Copy template
cp .env.example .env

# Edit .env file with your keys
nano .env  # or use your preferred editor
```

### Required Variables
```bash
# Paste your actual keys here
ELEVENLABS_API_KEY=your-elevenlabs-key-here
PERPLEXITY_API_KEY=pplx-your-perplexity-key-here

# Production settings (don't change)
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw

# Budget controls (adjust as needed)
MAX_COST_PER_EPISODE=5.00
DAILY_COST_LIMIT=20.00
```

### Verify Configuration
```bash
# Run the configuration validator
./validate-config.sh
```

If all checks pass ✅, you're ready for the next step!

---

## 🔧 Step 3: Setup MCP Servers (1 minute)

### One-Command Setup
```bash
# Configure everything automatically
./scripts/setup-mcp.sh
```

This script will:
- Verify your API keys work
- Configure Perplexity MCP server for research
- Configure ElevenLabs MCP server for audio
- Test all connections

### Verify Setup
```bash
# Test all connections
./scripts/test-mcp-connections.sh
```

You should see:
```
✅ PASS: Environment file exists
✅ PASS: API keys configured  
✅ PASS: MCP servers configured
✅ PASS: Perplexity API connection
✅ PASS: ElevenLabs API connection
✅ PASS: Production voice ID
✅ PASS: Required directories
```

---

## 🎙️ Step 4: Create Your First Episode (15 minutes)

### Initialize Your Session
```bash
# In Claude Code interface
/init
```

This activates the hierarchical memory system and session tracking.

### Start Production
```bash
# Create your first episode  
/podcast-workflow "Your Topic Here"

# Examples:
/podcast-workflow "The Mystery of Dark Matter"  
/podcast-workflow "Why Nobody Understands Consciousness"
/podcast-workflow "The Future of AI: What Experts Don't Know"
```

### Watch the Magic Happen
The system will automatically:

1. **Research** (5 minutes, ~$1)
   - Explore topic with Perplexity AI
   - Find expert opinions and recent findings
   - Identify knowledge gaps and uncertainties

2. **Script Creation** (5 minutes, ~$1)  
   - Write 28-minute episode script
   - Add intellectual humility moments
   - Optimize for audio synthesis

3. **Quality Validation** (3 minutes, ~$0.50)
   - Three-evaluator consensus (Claude, Gemini, Perplexity)
   - Brand consistency checking
   - Technical accuracy verification

4. **Audio Synthesis** (2 minutes, ~$2.50)
   - Professional voice synthesis (Amelia)
   - SSML optimization for natural speech
   - Quality validation with STT checking

### Your Episode is Ready! 🎉
Find your completed episode in:
- **Audio**: `nobody-knows/output/episodes/episode-XXX.mp3`
- **Script**: Same directory with full production notes
- **Metrics**: Quality scores and cost breakdown

---

## 🔧 Troubleshooting

### MCP Connection Issues
```bash
# Check MCP status
claude mcp list

# Should show:
# ✓ Connected: perplexity
# ✓ Connected: elevenlabs
```

**Fix**: If not connected, run `./scripts/setup-mcp.sh` again

### High Costs  
**Problem**: Episode costs more than expected

**Solutions**:
- Check `.claude/logs/cost-tracking.log` for details
- Reduce research depth for simpler topics
- Use single episodes before batch processing

### Quality Issues
**Problem**: Episode doesn't pass quality gates

**Solutions**:
- Check quality evaluation reports in episode session
- All episodes automatically pass 85%+ thresholds
- System has built-in retry logic for improvements

### API Errors
**Problem**: 401 authentication errors

**Solutions**:
```bash
# Test API keys directly
curl -H "xi-api-key: YOUR_KEY" https://api.elevenlabs.io/v1/models
curl -H "Authorization: Bearer YOUR_KEY" https://api.perplexity.ai/chat/completions
```

**Fix**: If keys don't work, regenerate them on the respective platforms

---

## 📊 What to Expect

### First Episode Performance
- **Time**: 15-30 minutes total
- **Cost**: $3-5 per episode  
- **Quality**: 90%+ professional broadcast standard
- **Format**: 28-minute MP3 ready for podcast distribution

### System Capabilities
- **Research**: 100+ sources automatically gathered and verified
- **Script**: Professional-quality writing with intellectual humility theme
- **Audio**: Broadcast-standard synthesis with natural speech patterns
- **Quality**: Multi-evaluator consensus ensures consistency

---

## 🎯 Next Steps

After your first successful episode:

1. **Try batch processing**: Create multiple episodes with `/batch episodes.json`
2. **Explore topics**: The system works best with topics that have expert debates
3. **Monitor costs**: Track spending patterns in the logs
4. **Scale up**: Move from single episodes to series production

---

## 💡 Pro Tips

1. **Pick fascinating topics** - The system shines with subjects that have genuine mysteries
2. **Start simple** - Try familiar topics first to understand the system
3. **Monitor budgets** - Set conservative limits while learning
4. **Save good examples** - Keep successful episodes as templates
5. **Use /clear frequently** - Clear context between major operations

---

## 📞 Getting Help

**Configuration Issues**: Run `./validate-config.sh` for comprehensive diagnosis  
**Connection Problems**: Run `./scripts/test-mcp-connections.sh` to test everything  
**System Status**: Use `/status` command in Claude Code  
**Cost Monitoring**: Check `.claude/logs/cost-tracking.log`  

---

**Ready to begin?** Run `./scripts/setup-mcp.sh` and start creating professional podcasts! 🎙️

*This system has produced episodes with 95/100 quality scores at $2.77-$5.51 cost vs $800-3500 traditional production.*
