# User Getting Started Guide 🚀
**Your Complete First-Time User Guide to AI Podcast Production**

*New to this system? Perfect! This guide will get you from zero to your first podcast episode.*

---

## 👋 Welcome! You're About to Learn Something Amazing

This is an **automated AI podcast production system** that can create professional 25-30 minute podcast episodes for about $5.51 each. Instead of paying $800-3500 for traditional production, you'll learn to direct AI agents that do the work for you.

**Don't worry about the complexity** - this guide assumes you know nothing and will walk you through everything step-by-step.

---

## 🎯 What You'll Achieve Today

By the end of this guide, you will:
- ✅ Set up your environment with API keys
- ✅ Understand how to control the system  
- ✅ Create your first professional podcast episode
- ✅ Learn the basic workflows for ongoing production
- ✅ Know where to go for help when you need it

**Time Required**: 2-3 hours | **Cost**: $5-8 for your first episode

---

## 📋 Prerequisites Checklist

Before you start, you'll need:

### Required API Accounts (You'll need to sign up for these):
- [ ] **ElevenLabs Account** - For text-to-speech audio generation
- [ ] **Anthropic Account** - For Claude AI (script writing and evaluation)
- [ ] **Google AI Account** - For Gemini AI (quality evaluation) 
- [ ] **Perplexity Account** - For research queries

### Optional but Recommended:
- [ ] **GitHub Account** - If you want to save your work
- [ ] **Basic terminal knowledge** - Running simple commands

### What You DON'T Need:
- ❌ Programming experience
- ❌ Audio production knowledge  
- ❌ Expensive equipment
- ❌ Understanding of the 300+ files in this system

---

## 🛠️ Step 1: Environment Setup (20 minutes)

### 1.1 Get Your API Keys

You need API keys from 4 services. Here's how to get them:

#### ElevenLabs (Text-to-Speech)
1. Go to [elevenlabs.io](https://elevenlabs.io)
2. Sign up for an account
3. Go to Profile → API Keys
4. Copy your API key (starts with `sk-`)

#### Anthropic Claude
1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Sign up and add billing information  
3. Go to API Keys section
4. Create a new key and copy it

#### Google AI (Gemini)
1. Go to [ai.google.dev](https://ai.google.dev)
2. Sign in with Google account
3. Go to "Get API Key" 
4. Create and copy your API key

#### Perplexity
1. Go to [perplexity.ai](https://perplexity.ai)
2. Sign up for Pro account ($20/month - worth it for research quality)
3. Go to Settings → API
4. Generate and copy your API key

### 1.2 Configure Your Environment

Create a file called `.env` in the project root:

```bash
# API Keys (Replace with your actual keys)
ELEVEN_LABS_API_KEY=your_elevenlabs_key_here
ANTHROPIC_API_KEY=your_claude_key_here  
GOOGLE_API_KEY=your_google_key_here
PERPLEXITY_API_KEY=your_perplexity_key_here

# Production Settings (Keep these as-is)
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
PRODUCTION_BUDGET=5.51
PRODUCTION_ENVIRONMENT=production
```

### 1.3 Test Your Setup

Run this command to verify everything works:

```bash
python check_health.py
```

You should see:
```
✅ ElevenLabs: Connected
✅ Claude: Connected  
✅ Gemini: Connected
✅ Perplexity: Connected
✅ System: Ready for production
```

If you see errors, double-check your API keys.

---

## 🎮 Step 2: Understanding Your Controls (10 minutes)

### The Main Interface

You control everything through **this chat interface**. You don't need to edit files or run complex commands - just use these "slash commands":

### Essential Commands

```bash
/init           # Start a new session (always do this first)
/health         # Check system status  
/clear          # Clean up context (use frequently)
```

### Production Commands

```bash
/research "topic"                    # Research a topic (FREE - no audio created)
/produce-episode "topic"             # Create complete episode (~$5.51)
/batch-produce topics.txt            # Create multiple episodes
```

### Monitoring Commands

```bash
/cost-check                          # See current costs
/validate-production                 # Check system health
/dashboard                          # Real-time monitoring
```

---

## 🎯 Step 3: Your First Episode (30 minutes, ~$5)

Let's create your first podcast episode! We'll start with a simple, interesting topic.

### 3.1 Initialize Your Session

```
/init
```

This sets up your session and prepares the AI agents.

### 3.2 Choose Your First Topic

For your first episode, pick something:
- **Interesting but not too complex**: "Why do we dream?" 
- **Has good research available**: Avoid brand-new topics
- **Personally interesting to you**: You'll be more engaged

### 3.3 Start with Research (FREE!)

```
/research "Why do we dream? The science behind sleeping thoughts"
```

This will:
1. **Discovery Agent**: Find key information about dreams
2. **Deep Dive Agent**: Get expert perspectives  
3. **Validation Agent**: Check facts and sources
4. **Synthesis Agent**: Organize everything into a coherent narrative

**Watch what happens!** You'll see:
- Multiple AI agents working in parallel
- Research being gathered from authoritative sources
- Information being organized and validated
- Cost tracking (should be ~$0.60 for research)

### 3.4 Create Your Episode

```
/produce-episode "Why do we dream? The science behind sleeping thoughts"
```

Now the magic happens! You'll see:

1. **Question Generation**: AI creates engaging questions
2. **Episode Planning**: Structure is planned (intro, main content, conclusion)
3. **Script Writing**: 35,000-character script created in conversational style
4. **Quality Evaluation**: Both Claude and Gemini evaluate quality
5. **Brand Validation**: Ensures "intellectual humility" theme
6. **Audio Synthesis**: Professional TTS audio generation (26-28 minutes)
7. **Final Validation**: Audio quality checks

**Total time**: About 3-5 minutes | **Total cost**: About $5.51

### 3.5 Get Your Results

When complete, you'll find:
- **Script**: `output/scripts/why_do_we_dream_script.md`
- **Audio**: `output/audio/why_do_we_dream_episode.mp3` 
- **Quality Report**: `output/quality/why_do_we_dream_quality.json`

**Congratulations!** 🎉 You just created a professional podcast episode!

---

## 🔧 Step 4: Understanding What Happened (10 minutes)

### The 4-Pipeline System

Your episode went through 4 automated pipelines:

1. **Research Pipeline** (4 AI agents)
   - Discovers information about your topic
   - Gets expert perspectives and technical details
   - Validates facts and checks sources
   - Synthesizes everything into coherent knowledge

2. **Content Pipeline** (4 AI agents)  
   - Generates strategic questions for engagement
   - Plans episode structure and timing
   - Writes conversational script with intellectual humility
   - Validates brand consistency

3. **Quality Pipeline** (2 AI evaluators)
   - Claude evaluator scores content, structure, engagement
   - Gemini evaluator provides alternative perspective
   - Requires consensus score >8.0 to proceed

4. **Production Pipeline** (2 AI agents)
   - Synthesizes script to professional audio
   - Validates audio quality, duration, and pronunciation

### The Cost Breakdown

Your ~$5.51 episode cost breaks down like this:
- **Research**: $0.60 (11%) - Perplexity API for deep research
- **Script Writing**: $1.20 (22%) - Claude for script creation  
- **Quality Evaluation**: $0.80 (14%) - Both Claude and Gemini
- **Audio Synthesis**: $2.50 (45%) - ElevenLabs TTS
- **System Overhead**: $0.41 (8%) - Coordination and retries

### The Quality Standards

Every episode must pass:
- **Brand Consistency**: >85% intellectual humility alignment
- **Evaluator Consensus**: >8.0/10 average score between Claude and Gemini
- **Audio Quality**: 26-28 minutes, clear pronunciation, proper pacing
- **Script Length**: 33,000-37,000 characters for proper timing

---

## 🚀 Step 5: Your Next Steps

### Immediate Next Actions

1. **Listen to your episode** - See what professional AI production sounds like
2. **Read the quality report** - Understand how quality is measured  
3. **Try another topic** - Pick something you're curious about
4. **Use `/clear`** - Clean up context before your next episode

### Beginner-Friendly Topics to Try

- "Why do cats purr? The vibrations that heal"
- "What makes music sound good? The science of harmony"  
- "How do magnets work? The invisible forces around us"
- "Why do we get goosebumps? The evolution of an odd response"
- "What happens when we laugh? The biology of humor"

### Learning Path Forward

**Week 1: Learn the Basics**
- Create 3-5 episodes on topics you find interesting
- Focus on learning the commands and workflow
- Don't worry about optimization yet

**Week 2: Understand Quality**
- Read quality reports to understand scoring
- Try topics of different complexity levels
- Learn to interpret the brand consistency scores

**Week 3: Batch Production**
- Use `/batch-produce` for multiple episodes
- Learn cost optimization techniques
- Start planning episode series

**Month 2+: Advanced Features**
- Custom voice options
- Brand optimization
- Advanced quality controls
- Production scaling

---

## 🆘 Getting Help

### When Things Go Wrong

**Command doesn't work?**
- Try `/health` to check system status
- Use `/clear` to reset context
- Check your API keys in the `.env` file

**Episode quality too low?**  
- Quality scores below 8.0 trigger automatic revision
- Brand consistency below 85% requires script revision
- System will automatically retry with improvements

**Costs too high?**
- Use `/cost-check` to see breakdown
- Research-only commands (like `/research`) cost much less
- Budget protection stops at $6.00 per episode

### Where to Find Answers

1. **This Guide** - Start here for basic questions
2. **System Health**: `/health` command shows current status
3. **Cost Monitoring**: `/cost-check` shows spending breakdown  
4. **Quality Reports**: Check `output/quality/` folder for detailed feedback
5. **Technical Docs**: `docs/ARCHITECTURE.md` for system understanding

### Common Issues and Solutions

| Problem | Solution |
|---------|----------|
| "API key not found" | Check `.env` file has correct keys |
| "Budget exceeded" | Normal protection - increase budget if needed |
| "Quality score too low" | System auto-revises - let it complete |
| "Audio synthesis failed" | Check ElevenLabs API key and account balance |
| "Context too large" | Use `/clear` command more frequently |

---

## 🎓 Understanding the Philosophy

### What Makes This System Special

This isn't just about automating podcast production - it's about **intellectual humility**. Every episode follows the "Nobody Knows" philosophy:

- **Celebrate curiosity**: "What we're learning about X is fascinating..."
- **Acknowledge unknowns**: "Scientists still don't fully understand..."  
- **Embrace mystery**: "This leads us to even bigger questions..."
- **Stay accessible**: Complex topics explained conversationally

### Learning Mindset

This system teaches you **AI orchestration** - how to direct multiple AI agents to work together toward a goal. These skills apply beyond podcasting:

- **Multi-agent coordination**: Managing specialized AI workers
- **Quality assurance**: Automated validation and consensus scoring
- **Cost optimization**: Balancing quality with budget constraints
- **Workflow design**: Pipelining complex tasks efficiently

Every episode you create teaches you more about professional AI deployment.

---

## 🏁 You're Ready to Start!

### Your Action Plan Right Now

1. **Set up your API keys** (Step 1)
2. **Run `/init`** to start your first session
3. **Try `/research "why do cats purr"`** for a free research test
4. **Create your first episode** with `/produce-episode`
5. **Celebrate!** You just used enterprise-grade AI orchestration

### Remember

- **Start simple**: Don't try complex topics immediately
- **Trust the system**: The AI agents know their specializations  
- **Learn incrementally**: Each episode teaches you more
- **Use `/clear` frequently**: Keeps performance optimal
- **Have fun!**: You're learning cutting-edge AI skills

### Final Encouragement

Every expert was once a beginner. This system might seem complex, but you're just directing a team of specialized AI agents. You don't need to understand every detail - you just need to give good directions and let the automation work.

**Ready? Let's create your first podcast episode!** 🎙️

---

*Questions? Issues? The system is designed to be self-explanatory, but if you get stuck, use the help commands and remember - every challenge is a learning opportunity!*