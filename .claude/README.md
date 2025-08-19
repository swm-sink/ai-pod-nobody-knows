# AI Podcasts v1.0 - Simplified Structure

## 🚀 Quick Navigation

**Core System (Ready to Use):**
- **[agents/](./agents/)** - 14 specialized agents (research + production)
- **[commands/](./commands/)** - 4 production commands  
- **[config/](./config/)** - 5 essential configuration files
- **[context/](./context/)** - 10 core learning files

**Documentation & Shared Resources:**
- **[docs/](./docs/)** - 8 essential documentation files
- **[shared/](./shared/)** - 5 essential templates and configs

## 🎯 Essential Files

**Start Here:**
1. `CLAUDE.md` - Master system configuration
2. `agents/` - Browse all 14 agents
3. `commands/produce-episode.md` - Main production command
4. `config/production-config.yaml` - Core settings

**Core Architecture:**
- **Research Stream:** 3 agents (research → questions → synthesis)
- **Production Stream:** 10 agents (planning → script → quality → audio)
- **Bridge Agent:** research-synthesizer.md (connects streams)

## 📊 Simplification Results

- **Before:** 775 files in .claude/
- **After:** 216 files in .claude/ 
- **Reduction:** 72% reduction (559 files removed)
- **Target:** <50 files (more simplification needed)

## 🔗 External Documentation

*Coming Soon: Web-hosted references for:*
- Claude Code platform guides (12 files moved)
- ElevenLabs integration guides (11 files moved)  
- Advanced research patterns (9 files moved)
- Complex frameworks and templates (45+ files moved)

## ⚡ Quick Start

```bash
# Main production command
/produce-episode

# Research only
/produce-research  

# Check costs
grep "Cost:" sessions/*/production/*.json | tail -5
```

---

*Simplified Structure v1.0 - Essential functionality preserved, complexity removed*