# 📋 PROJECT STATUS HANDOVER - AI Podcasts "Nobody Knows"

**Date**: 2025-08-11
**Session Handover**: Complete context for fresh chat after Claude Code restart

---

## ⚠️ CRITICAL ISSUES TO ADDRESS

### README.md is COMPLETELY WRONG
The README describes a FastAPI Python application that DOES NOT EXIST. This project is actually:
- **Native Claude Code implementation** (not Python app)
- **MCP-based architecture** (not REST API)
- **Command-driven agents** (not server-based)
- **See PROJECT_AUDIT_INCONSISTENCIES.md for full details**

**ACTION REQUIRED**: Rewrite README.md to reflect actual project

---

## 🎯 PROJECT OVERVIEW

### What This Is
A **solo hobby project** to build an automated AI podcast production system using Claude Code's native capabilities, producing 100 episodes about the limits of human knowledge.

### Project Philosophy
- **Keep it simple** - This is a hobby project, not enterprise software
- **Use native Claude Code** - Leverage built-in AI for most tasks
- **Minimal external APIs** - Only Perplexity (research) and ElevenLabs (audio)
- **Learn by doing** - Every step teaches AI orchestration concepts

### Architecture Levels
```
Level 2: Native Claude Code Production (CURRENT FOCUS) ✅
├── Claude Code AI (script writing, quality checks)
├── Perplexity MCP (research) 
└── ElevenLabs MCP (audio synthesis)

Level 3: Documentation Only (planning phase)

Level 4: Future Coded Platform (REQUIRES APPROVAL - DO NOT BUILD)
├── OpenRouter (unified model access)
└── Langfuse (evaluation/observability)
```

---

## ✅ WHAT'S BEEN COMPLETED

### Phase 1-3: Foundation Architecture
1. **Single Source of Truth** - Eliminated all duplication
2. **Sophisticated Prompts** - Integrated Feynman + Fridman style
3. **Agent Architecture** - Built 4 production agents

### Phase 4: CLAUDE.md Restoration
- Restored mandatory education requirements (dual explanations)
- Added comprehensive quality enforcement standards
- Implemented DRY principle enforcement
- Added anti-pattern prevention

### Phase 5: API Key Configuration
```bash
# Configured in .env (git-ignored)
PERPLEXITY_API_KEY=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
ELEVENLABS_API_KEY=sk_50caa9b149cb87deffeeec4483de8de13ebd7f97fac88cd2

# Reserved for Level 4 (not used yet)
OPENROUTER_API_KEY=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
# LANGFUSE_API_KEY=future
```

### Phase 6: MCP Installation & Configuration ✅
1. **Installed Official MCPs Locally**
   - ElevenLabs MCP: `.claude/mcp-servers/elevenlabs-mcp/`
   - Perplexity MCP: `.claude/mcp-servers/perplexity-mcp/`

2. **Security Implementation**
   - Removed unnecessary Atlassian MCP
   - All MCP directories git-ignored
   - Created `.mcp.json` with API keys (git-ignored)
   - Created `.mcp.json.example` template for others

3. **Testing Complete**
   - Both MCPs load successfully
   - Configuration validated
   - Test script at `.claude/scripts/test_mcps.py`

---

## 📁 CURRENT FILE STRUCTURE

```
ai-podcasts-nobody-knows/
├── .env                           # API keys (git-ignored) ✅
├── .env.example                   # Template for others ✅
├── .mcp.json                      # MCP config (git-ignored) ✅
├── .mcp.json.example              # MCP template ✅
├── .gitignore                     # Updated with MCP paths ✅
├── CLAUDE.md                      # Master system prompt v5.0.0 ✅
├── PROJECT_STATUS_HANDOVER.md     # This file
│
├── .claude/
│   ├── config/
│   │   ├── simple-setup.md       # Simplified approach doc
│   │   ├── environment-management.md
│   │   └── mcp-config.json
│   │
│   ├── mcp-servers/              # Git-ignored directory
│   │   ├── elevenlabs-mcp/       # Installed Python MCP
│   │   ├── perplexity-mcp/       # Installed Node.js MCP
│   │   └── README.md             # MCP documentation
│   │
│   ├── scripts/
│   │   ├── test_api_keys.py      # API key validator
│   │   └── test_mcps.py          # MCP tester
│   │
│   ├── level-1-dev/              # Development platform
│   │   ├── agents/               # Agent builders
│   │   └── commands/             # Command builders
│   │
│   └── level-2-production/       # Production system
│       ├── agents/
│       │   ├── research-coordinator.md    # Uses Perplexity MCP
│       │   ├── script-writer.md          # Uses Claude native
│       │   ├── quality-evaluator.md      # Uses Claude native
│       │   └── audio-synthesizer.md      # Uses ElevenLabs MCP
│       └── commands/
│           └── produce-episode.md        # Main orchestrator
│
└── projects/nobody-knows/
    └── output/                   # Episode outputs go here
        ├── research/
        ├── scripts/
        ├── quality/
        ├── audio/
        └── sessions/
```

---

## 🔄 IMMEDIATE NEXT STEPS

### Step 1: Restart Claude Code
The MCPs are configured in `.mcp.json` but need Claude Code to restart to load them.

### Step 2: Verify MCP Loading
```bash
# After restart, from project directory:
cd /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows
claude mcp list

# Should show:
# - elevenlabs (stdio)
# - perplexity (stdio)
```

### Step 3: Test MCP Availability
```bash
# Run test script
python3 .claude/scripts/test_mcps.py

# All tests should pass
```

### Step 4: Test Agent Integration
Test each agent individually before full pipeline:

1. **Test Research Agent**
   - Use Perplexity MCP for web search
   - Try a simple query first
   - Check cost tracking

2. **Test Audio Agent**
   - Use ElevenLabs MCP for TTS
   - Generate a short test audio
   - Verify voice quality

3. **Test Script Writer**
   - Uses Claude Code natively (no external API)
   - Generate a short script

4. **Test Quality Evaluator**
   - Uses Claude Code natively
   - Evaluate a sample script

### Step 5: Run Test Episode
```bash
# When ready, test full pipeline
claude /produce-episode --topic "consciousness" --episode 1 --dry-run
```

---

## 📋 TODO LIST STATUS

### ✅ Completed
- [x] Phase 1-3: Foundation architecture
- [x] Phase 4: CLAUDE.md restoration
- [x] Phase 5: API key configuration
- [x] Phase 6: MCP installation and setup

### ⏳ In Progress
- [ ] **ACTION REQUIRED**: Restart Claude Code to load MCPs

### 📝 Pending
- [ ] Phase 7: Test Native Claude Code
  - [ ] 7.1 Verify MCPs available after restart
  - [ ] 7.2 Test research agent with Perplexity
  - [ ] 7.3 Test audio agent with ElevenLabs
  - [ ] 7.4 Test script writer with Claude native
  - [ ] 7.5 Test quality evaluator

- [ ] Phase 8: Simple Integration
  - [ ] 8.1 Update agents to use MCP tools
  - [ ] 8.2 Test episode production end-to-end
  - [ ] 8.3 Verify costs are under $5/episode

- [ ] CHECKPOINT: Level 2 Production Ready

### 🔒 Future (Requires Approval)
- [ ] Level 3: Documentation only
- [ ] Level 4: OpenRouter + Langfuse implementation
- [ ] **GATE**: DO NOT proceed to Level 4 without explicit approval

---

## 💰 BUDGET & LIMITS

```yaml
Cost Limits:
  Per Episode: $5.00
  Daily Maximum: $10.00
  Alert Threshold: $4.00

Rate Limits:
  Perplexity: 10 requests/minute
  ElevenLabs: 5 requests/minute

Episode Targets:
  Duration: 25-30 minutes
  Word Count: 3,900-4,100 words
  Quality Score: ≥0.85
```

---

## 🐛 TROUBLESHOOTING

### If MCPs Don't Show After Restart
1. Check you're in project directory when running `claude mcp list`
2. Verify `.mcp.json` exists in project root
3. Check API keys are correct in `.mcp.json`
4. Look for errors in Claude Code logs

### If API Calls Fail
1. Test API keys: `python3 .claude/scripts/test_api_keys.py`
2. Check rate limits haven't been exceeded
3. Verify account has credits/balance

### If Costs Exceed Budget
1. Enable dry-run mode first
2. Use mock responses for testing
3. Check token usage in responses

---

## 📚 KEY DOCUMENTATION

### Essential Files to Review
1. **CLAUDE.md** - Master system prompt with all requirements
2. **.claude/config/simple-setup.md** - Simplified approach overview
3. **.claude/MCP_SETUP_COMPLETE.md** - MCP installation details
4. **.claude/level-2-production/commands/produce-episode.md** - Main orchestrator

### Important Context
- This is a **solo hobby project** - avoid over-engineering
- **Level 2 only** - Don't implement Level 4 without approval
- **MCPs are local** - Installed in project, not globally
- **Everything is git-ignored** - Security first

---

## 🎯 SUCCESS CRITERIA

### For Next Session
1. ✅ MCPs loading in Claude Code
2. ✅ Can call Perplexity for research
3. ✅ Can call ElevenLabs for audio
4. ✅ Can produce test episode
5. ✅ Total cost < $5 per episode

### For Project Completion
1. 100 episodes produced
2. Average cost < $5 per episode
3. Quality score ≥ 0.85 for all episodes
4. Full automation achieved

---

## 💡 IMPORTANT REMINDERS

1. **DON'T** implement Level 4 (OpenRouter/Langfuse) without approval
2. **DON'T** over-engineer - this is a hobby project
3. **DO** use mock mode for testing to save costs
4. **DO** track costs carefully - $10/day limit
5. **DO** focus on getting Level 2 working first

---

## 🚀 QUICK START FOR NEXT SESSION

```bash
# 1. Navigate to project
cd /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows

# 2. Check MCPs are loaded
claude mcp list

# 3. If not showing, check config
cat .mcp.json

# 4. Test MCPs work
python3 .claude/scripts/test_mcps.py

# 5. Ready to continue with Phase 7
```

---

## 🔴 CRITICAL DOCUMENTATION FIXES NEEDED

### Files That Are WRONG:
1. **README.md** - Describes FastAPI app that doesn't exist
2. **requirements.txt** - Lists 72 unused dependencies
3. Various references to "core/" directory that doesn't exist

### Files That Are CORRECT:
1. **ACTUAL_README.md** - New accurate description
2. **requirements-actual.txt** - Minimal correct dependencies
3. **CLAUDE.md** - Master prompt is accurate
4. **.env/.mcp.json** - Configurations are correct

### Immediate Actions for Next Session:
1. Replace README.md with ACTUAL_README.md content
2. Replace requirements.txt with requirements-actual.txt
3. Delete references to non-existent Python app
4. Update all documentation to reflect Native Claude Code implementation

---

## 📝 SESSION NOTES

### What Worked Well
- Simplified approach (removed enterprise features)
- Local MCP installation (project-specific)
- Clear separation of levels (2, 3, 4)
- Comprehensive git-ignore for security

### Key Decisions Made
- Use only Perplexity + ElevenLabs for Level 2
- Reserve OpenRouter + Langfuse for Level 4
- No Atlassian MCP in this project
- Keep everything simple for solo development

### Next Session Focus
- Verify MCPs are working after restart
- Test agents individually
- Run first test episode
- Optimize for <$5 cost per episode

---

**Project Status**: MCP setup complete, ready for testing after Claude Code restart
**Security**: All sensitive data properly git-ignored
**Simplicity**: Focused on Level 2 native Claude Code implementation
**Next Action**: Restart Claude Code and verify MCPs are loaded

---

*This handover document contains everything needed to continue in a fresh chat session.*