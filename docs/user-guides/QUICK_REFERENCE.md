# Quick Reference Guide 📖
**Essential Commands and Troubleshooting for AI Podcast Production**

---

## ⚡ Essential Commands

### Session Management
```bash
/init                    # Start new session (always first!)
/clear                   # Clean context (use frequently)
/health                  # Check system status
```

### Production Commands
```bash
/research "topic"                    # Research only (FREE, ~$0.60)
/produce-episode "topic"             # Complete episode (~$5.51)
/batch-produce topics.txt            # Multiple episodes
```

### Monitoring
```bash
/cost-check                          # Current spending
/validate-production                 # System health check
/dashboard                          # Real-time monitoring
```

---

## 🎯 Typical Workflow

### First Time Setup
1. Set up API keys in `.env` file
2. Run `python check_health.py`
3. Use `/init` to start first session

### Creating an Episode  
1. `/init` (start session)
2. `/research "your topic"` (optional, test first)
3. `/produce-episode "your topic"` (full production)
4. `/clear` (clean up afterward)

### Batch Production
1. Create `topics.txt` with one topic per line
2. `/batch-produce topics.txt`
3. Monitor progress with `/dashboard`

---

## 💰 Cost Breakdown

| Component | Typical Cost | Percentage |
|-----------|--------------|------------|
| Research (Perplexity) | $0.60 | 11% |
| Script Writing (Claude) | $1.20 | 22% |
| Quality Evaluation | $0.80 | 14% |
| Audio Synthesis (ElevenLabs) | $2.50 | 45% |
| System Overhead | $0.41 | 8% |
| **Total Average** | **$5.51** | **100%** |

---

## 🚨 Common Issues & Solutions

### API/Authentication Issues
| Problem | Solution |
|---------|----------|
| "API key not found" | Check `.env` file exists with correct keys |
| "Unauthorized" error | Verify API key is valid and has credits |
| "Rate limit exceeded" | Wait a few minutes, then retry |

### Production Issues
| Problem | Solution |
|---------|----------|
| "Quality score too low" | System auto-revises, let it complete |
| "Budget exceeded" | Normal protection at $6.00, increase if needed |
| "Audio synthesis failed" | Check ElevenLabs key and account balance |
| "Context too large" | Use `/clear` command immediately |

### Performance Issues
| Problem | Solution |
|---------|----------|
| Slow responses | Use `/clear` to reduce context size |
| Commands not recognized | Try `/init` to reinitialize session |
| System unresponsive | Run `/health` to check status |

---

## 📁 Output Files

### Episode Production Creates:
```
output/
├── scripts/
│   └── your_topic_script.md          # Episode script
├── audio/  
│   └── your_topic_episode.mp3        # Final audio (26-28 min)
├── quality/
│   └── your_topic_quality.json       # Quality scores
└── sessions/
    └── your_topic_session.log        # Production log
```

---

## 🎯 Quality Standards

### Automatic Quality Gates
- **Brand Consistency**: >85% intellectual humility alignment
- **Evaluator Consensus**: >8.0/10 average (Claude + Gemini)  
- **Audio Duration**: 26-28 minutes
- **Script Length**: 33,000-37,000 characters

### Quality Scores Meaning
- **9.0-10.0**: Excellent, publication ready
- **8.0-8.9**: Good, meets all standards  
- **7.0-7.9**: Acceptable, minor improvements possible
- **<7.0**: Automatic revision triggered

---

## 🔧 Environment Setup

### Required API Keys (.env file)
```bash
ELEVEN_LABS_API_KEY=your_elevenlabs_key
ANTHROPIC_API_KEY=your_claude_key
GOOGLE_API_KEY=your_google_key  
PERPLEXITY_API_KEY=your_perplexity_key

PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
PRODUCTION_BUDGET=5.51
```

### API Account Links
- **ElevenLabs**: [elevenlabs.io](https://elevenlabs.io)
- **Anthropic**: [console.anthropic.com](https://console.anthropic.com)
- **Google AI**: [ai.google.dev](https://ai.google.dev)
- **Perplexity**: [perplexity.ai](https://perplexity.ai)

---

## 🏃 Emergency Procedures

### System Not Responding
1. Use `/clear` to reset context
2. Try `/health` to check status
3. Restart with `/init`
4. Check API keys if still failing

### Costs Getting Too High
1. Use `/cost-check` to see breakdown
2. System auto-stops at $6.00 per episode
3. Research-only commands cost much less
4. Use `/clear` frequently to optimize

### Quality Issues
1. System automatically revises low-quality content
2. Check `output/quality/` folder for detailed feedback
3. Brand consistency issues trigger script revision
4. Audio quality problems trigger re-synthesis

---

## 📚 Learning Progression

### Beginner (Week 1)
- Master basic commands (`/init`, `/produce-episode`, `/clear`)
- Create 3-5 episodes on simple topics
- Learn to read quality reports

### Intermediate (Week 2-3)  
- Use batch production for efficiency
- Understand cost optimization
- Experiment with different topic complexities

### Advanced (Month 2+)
- Custom workflow optimization  
- Advanced quality tuning
- Series production planning

---

## 💡 Pro Tips

1. **Always start with `/init`** for new sessions
2. **Use `/clear` frequently** to maintain performance  
3. **Start with simple topics** before trying complex ones
4. **Read quality reports** to understand scoring
5. **Trust the automation** - let agents do their specialized work
6. **Research first** with `/research` to test topics cheaply
7. **Monitor costs** with `/cost-check` during production
8. **Keep topics focused** - specific is better than general

---

## 🎙️ Recommended First Topics

**Easy & Engaging:**
- "Why do cats purr? The vibrations that heal"  
- "What makes music sound good? The science of harmony"
- "How do magnets work? The invisible forces around us"

**Medium Complexity:**
- "Why do we dream? The science behind sleeping thoughts"
- "What happens when we laugh? The biology of humor"
- "How does GPS know where you are? The satellites above"

**Advanced (Try Later):**
- "What is consciousness? The hard problem of experience"
- "How does quantum computing work? The strange world of qubits"
- "What causes climate change? The evidence and uncertainty"

---

## 🆘 Getting Help

### Self-Service Troubleshooting
1. **This guide** for common issues
2. **`/health`** command for system status
3. **`/cost-check`** for budget information
4. **Quality reports** in `output/quality/` folder

### Documentation
- **User Guide**: `docs/USER_GETTING_STARTED.md`
- **Architecture**: `docs/ARCHITECTURE.md` 
- **Enhanced Features**: `docs/ENHANCED_FEATURES.md`

### System Files
- **Main Config**: `CLAUDE.md` (project overview)
- **Production**: `podcast_production/CLAUDE.md`
- **Health Check**: `python check_health.py`

---

*Keep this reference handy! Bookmark it for quick access during production.*