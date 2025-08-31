# TODO.MD - Single Source of Truth for LangGraph/LangFuse Migration
<!-- SSOT: This is the ONLY todo tracking file for this project -->
<!-- Last Updated: 2025-08-31 -->
<!-- Status: ACTIVE | Phase: LOCAL DEPLOYMENT IMPLEMENTATION -->

## 🎯 PROJECT OVERVIEW (REVISED FOR LOCAL DEPLOYMENT)
**Mission**: Transform AI podcast system from Claude Code to LangGraph/LangFuse for LOCAL hobby use
**Deployment**: LOCAL ONLY - Solo hobby project, no cloud infrastructure needed
**Target Cost**: Maintain $5.51/episode (using direct API calls)
**Timeline**: 2 weeks (part-time development)
**Complexity**: MINIMUM VIABLE - Direct API calls, simple Python scripts

## 📊 PROGRESS TRACKER
```
Overall Progress: [▓▓░░░░░░░░] 20%
Phase 1 (Prep):     [▓▓▓▓▓▓▓▓▓▓] 100%
Phase 2 (Migration): [▓▓░░░░░░░░] 18.75% (3/16 agents)
Phase 2.5 (Local):   [░░░░░░░░░░] 0% (NEW - Active Focus)
Phase 3 (Enhance):   [░░░░░░░░░░] 0% (Simplified)
Phase 4 (Deploy):    [REMOVED - Local Only]
```

## 🔒 QUALITY GATES (SIMPLIFIED FOR LOCAL)
- [ ] QG-001: All changes must pass validation before commit
- [ ] QG-002: Cost per episode must remain ≤ $5.51
- [ ] QG-003: All 16 agents must be migrated (they all serve purposes)
- [ ] QG-004: Tests must pass for core functionality
- [ ] QG-005: Local execution must be single command

---

## 📋 PHASE 1: PREPARATION ✅ COMPLETED
**Status**: COMPLETE | **Completed**: 2025-08-31

### Environment Setup Results:
- ✅ LangGraph installed (v0.5.4)
- ✅ LangFuse available (v3.2.1)
- ✅ Provider interfaces created
- ✅ API key management implemented
- ✅ Test framework established

---

## 📋 PHASE 2.5: LOCAL DEPLOYMENT IMPLEMENTATION (ACTIVE)
**Status**: ACTIVE | **Target**: 2025-09-14 (2 weeks)
**Focus**: Direct API integration for local hobby use

### 🔧 Day 1: Foundation Fixes & API Setup
- [x] P2.5-001: Fix OpenRouter list_models() bug ✅
  - Location: `src/adapters/openrouter/provider.py` line 114
  - Action: Uncommented `self._fetch_available_models()`
  - Result: All 18 tests passing
- [x] P2.5-002: Verify LangFuse SDK installation ✅
  - Current: langfuse==3.2.1 installed
  - Action: Configured in providers.yaml
  - Result: SDK operational, needs valid API credentials
- [ ] P2.5-003: Update OpenRouter provider for real API calls
  - Remove mock responses in generate() method
  - Implement actual HTTP requests
- [ ] P2.5-004: Update Perplexity provider for real API calls
  - Primary: Direct Perplexity API implementation
  - Fallback: MCP integration (if available)
- [ ] P2.5-005: Implement ElevenLabs direct API (NO MCP)
  - Direct API calls only
  - No MCP server needed
- [x] P2.5-006: Configure LangFuse SDK integration ✅
  - Already configured in providers.yaml
  - Ready for provider class integration
- [ ] P2.5-007: Test all API connections
  - Run validate_api_keys.py with real calls
  - Verify actual API responses
- [ ] P2.5-008: Document API patterns in INTEGRATION_GUIDE.md

### 📦 Days 2-7: Complete Agent Migration (13 Remaining)
**Critical Note**: All 16 agents are necessary - each serves a specific purpose

#### Research Pipeline Agents:
- [x] P2-001: research-discovery (DONE - $0.50 budget)
- [x] P2-002: research-deep-dive (DONE - $1.00 budget)
- [x] P2-003: research-validate (DONE - $0.35 budget)
- [ ] P2.5-009: research-synthesis ($0.15 budget)
  - Purpose: Consolidates research into narrative
  - Input: All research outputs
  - Output: Synthesized knowledge package
- [ ] P2.5-010: question-generator ($0.10 budget)
  - Purpose: Creates targeted research questions
  - Improves research depth and coverage

#### Production Pipeline Agents:
- [ ] P2.5-011: episode-planner ($0.20 budget)
  - Purpose: Structures episode flow and segments
  - Critical for coherent narrative
- [ ] P2.5-012: script-writer ($1.75 budget)
  - Purpose: Transforms research into engaging script
  - Core content creation
- [ ] P2.5-013: brand-validator ($0.25 budget)
  - Purpose: Ensures "Nobody Knows" brand consistency
  - Maintains intellectual humility theme
- [ ] P2.5-014: script-polisher ($0.30 budget)
  - Purpose: Refines script for audio production
  - Optimizes for TTS synthesis

#### Audio Pipeline Agents:
- [ ] P2.5-015: tts-optimizer ($0.15 budget)
  - Purpose: Prepares script with SSML markup
  - Improves audio quality
- [ ] P2.5-016: audio-synthesizer ($0.50 budget)
  - Purpose: Primary ElevenLabs integration
  - Generates final audio
- [ ] P2.5-017: audio-synthesizer-direct ($0.45 budget)
  - Purpose: Backup/alternative synthesis path
  - Direct API approach

#### Quality Assurance Agents:
- [ ] P2.5-018: audio-validator ($0.20 budget)
  - Purpose: Validates audio quality
  - Checks for synthesis errors
- [ ] P2.5-019: claude evaluator ($0.30 budget)
  - Purpose: Quality assessment using Claude
  - Provides improvement feedback
- [ ] P2.5-020: gemini evaluator ($0.25 budget)
  - Purpose: Alternative quality perspective
  - Multi-model validation
- [ ] P2.5-021: perplexity agent ($0.15 budget)
  - Purpose: Fact-checking and verification
  - Research accuracy validation

### 🔄 Days 8-10: LangGraph Orchestration
- [ ] P2.5-022: Create main.py with simple orchestration
  ```python
  # Single entry point for local execution
  python main.py --topic "Why do we dream?"
  ```
- [ ] P2.5-023: Implement PodcastState TypedDict
  - Episode metadata
  - Research data
  - Script content
  - Audio parameters
  - Quality metrics
  - Cost tracking
- [ ] P2.5-024: Build research pipeline graph
  - Sequential flow: discovery → deep-dive → validate → synthesis
  - State passing between agents
- [ ] P2.5-025: Build production pipeline graph
  - Flow: planner → writer → validator → polisher
  - Conditional routing based on quality
- [ ] P2.5-026: Build audio pipeline graph
  - Flow: optimizer → synthesizer → validator
  - Error handling for synthesis failures
- [ ] P2.5-027: Implement error handling
  - Retry logic with exponential backoff
  - Graceful degradation
- [ ] P2.5-028: Add state persistence
  - Save intermediate outputs
  - Enable resume from failures
- [ ] P2.5-029: Create workflow visualization
  - Document agent flow
  - Show decision points

### 📊 Days 11-12: Cost & Quality Tracking
- [ ] P2.5-030: Integrate LangFuse tracking
  - Add to each agent's execute method
  - Track prompt versions
- [ ] P2.5-031: Implement per-call cost tracking
  - Track tokens used
  - Calculate costs per provider
- [ ] P2.5-032: Create CSV cost logging
  - Simple file: `logs/costs.csv`
  - Fields: timestamp, agent, provider, tokens, cost
- [ ] P2.5-033: Implement quality scoring
  - Brand alignment (0-10)
  - Technical accuracy (0-10)
  - Engagement potential (0-10)
- [ ] P2.5-034: Create JSON quality logging
  - File: `logs/quality.json`
  - Track scores per episode
- [ ] P2.5-035: Build analysis scripts
  - `python analyze_costs.py` - Cost breakdown
  - `python analyze_quality.py` - Quality trends

### ✅ Days 13-14: Testing & Validation
- [ ] P2.5-036: Create end-to-end test
  - Test complete pipeline
  - Mock API responses for testing
- [ ] P2.5-037: Test research pipeline independently
  - Verify each agent output
  - Check state transitions
- [ ] P2.5-038: Test production pipeline independently
  - Script generation quality
  - Brand consistency
- [ ] P2.5-039: Test audio pipeline independently
  - SSML markup validation
  - Audio file generation
- [ ] P2.5-040: Produce test episode: "Why do we dream?"
  - Full pipeline execution
  - Real API calls
- [ ] P2.5-041: Verify cost < $5.51
  - Track actual API costs
  - Compare to budget
- [ ] P2.5-042: Verify quality > 8.0/10
  - Run quality evaluators
  - Check all metrics
- [ ] P2.5-043: Test error recovery
  - Simulate API failures
  - Verify graceful handling
- [ ] P2.5-044: Document test results

### 📚 Day 15: Documentation & Finalization
- [ ] P2.5-045: Create LOCAL_SETUP.md
  - Step-by-step setup guide
  - API key configuration
  - Dependencies installation
- [ ] P2.5-046: Create USAGE_GUIDE.md
  - How to run episodes
  - Command-line options
  - Output locations
- [ ] P2.5-047: Create AGENT_REGISTRY.md
  - Document all 16 agents
  - Purpose and necessity of each
  - Budget allocations
- [ ] P2.5-048: Create TROUBLESHOOTING.md
  - Common issues
  - API error handling
  - Debug procedures
- [ ] P2.5-049: Update README.md
  - Reflect local deployment
  - Remove cloud references
  - Simplify instructions
- [ ] P2.5-050: Final validation
  - Run full test suite
  - Produce 3 test episodes
  - Verify all documentation

---

## 📋 PHASE 3: LOCAL ENHANCEMENTS (SIMPLIFIED)
**Status**: PENDING | **Target**: After Phase 2.5

### Simplified Enhancements:
- [ ] P3-S01: Basic A/B testing with LangFuse
- [ ] P3-S02: Simple prompt versioning
- [ ] P3-S03: Local caching for research
- [ ] P3-S04: Batch episode production script
- [ ] P3-S05: Cost optimization analysis

---

## 📋 PHASE 4: REMOVED (Cloud Deployment Not Needed)
**This phase has been removed as this is a local hobby project**

---

## 🎯 AGENT PURPOSE DOCUMENTATION

### Why All 16 Agents Are Necessary:

#### Research Stream (4 agents = $2.00):
1. **research-discovery**: Maps topic landscape, identifies experts
2. **research-deep-dive**: Comprehensive research with citations
3. **research-validate**: Fact-checking and credibility assessment
4. **research-synthesis**: Consolidates into coherent narrative

#### Planning & Writing (4 agents = $2.50):
5. **question-generator**: Creates engaging research angles
6. **episode-planner**: Structures episode flow
7. **script-writer**: Core content creation
8. **script-polisher**: Optimizes for audio production

#### Brand & Quality (3 agents = $0.80):
9. **brand-validator**: Maintains "Nobody Knows" philosophy
10. **claude evaluator**: Primary quality assessment
11. **gemini evaluator**: Alternative quality perspective

#### Audio Production (3 agents = $1.10):
12. **tts-optimizer**: SSML markup for better audio
13. **audio-synthesizer**: Primary audio generation
14. **audio-synthesizer-direct**: Backup synthesis path

#### Validation (2 agents = $0.35):
15. **audio-validator**: Audio quality checks
16. **perplexity agent**: Final fact verification

**Total: $6.75 budget (optimizing to $5.51)**

---

## 📈 SUCCESS METRICS (LOCAL PROJECT)

### Simplified Metrics:
- [ ] SM-001: Complete episode production working locally
- [ ] SM-002: Cost per episode ≤ $5.51 achieved
- [ ] SM-003: Quality score ≥ 8.0/10 maintained
- [ ] SM-004: Single command execution working
- [ ] SM-005: All 16 agents successfully migrated
- [ ] SM-006: LangFuse tracking operational
- [ ] SM-007: Error recovery functional
- [ ] SM-008: Documentation complete and clear

---

## 🚨 RISK MITIGATION (SIMPLIFIED)

### Local Project Risks:
- [ ] RISK-001: API rate limits → Implement retry logic
- [ ] RISK-002: API key exposure → Use .env files
- [ ] RISK-003: Cost overruns → Track per-call costs
- [ ] RISK-004: Quality issues → Multi-evaluator validation

---

## 📝 KEY DECISIONS & NOTES

### Architecture Decisions (Revised):
- **Deployment**: Local-only, no cloud infrastructure
- **APIs**: Direct integration, MCP as fallback only
- **ElevenLabs**: Direct API only (no MCP)
- **Perplexity**: Direct API primary, MCP fallback
- **LangFuse**: SDK for observability
- **Complexity**: Minimum viable, simple Python scripts
- **All 16 Agents**: Each serves specific purpose, all needed

### Implementation Notes:
- OpenRouter bug is simple fix (uncomment one line)
- Provider implementations need real API calls (remove mocks)
- LangGraph already installed (v0.5.4)
- LangFuse already installed (v3.2.1)
- Focus on making it work locally first

---

## 🔄 UPDATE HISTORY

| Date | Phase | Update | By |
|------|-------|--------|-----|
| 2025-01-31 | Planning | Initial TODO.MD created | System |
| 2025-08-31 | Phase 2.5 | Revised for local deployment | Assistant |
| 2025-08-31 | Phase 2.5 | Added detailed agent purposes | Assistant |
| 2025-08-31 | Phase 2.5 | Simplified for hobby project | Assistant |

---

## 📌 ENFORCEMENT RULES

1. **This TODO.MD is the SINGLE SOURCE OF TRUTH for project tracking**
2. **All tasks MUST be tracked here - no exceptions**
3. **Updates must be made in real-time as work progresses**
4. **Focus on MINIMUM VIABLE COMPLEXITY**
5. **All 16 agents must be migrated - each has a purpose**
6. **Direct API calls primary, MCP only as fallback**
7. **Local deployment only - no cloud infrastructure**

---

**CURRENT FOCUS**: Phase 2.5 - Local Deployment Implementation
**NEXT ACTION**: Fix OpenRouter bug (P2.5-001)
**TIME ESTIMATE**: 2 weeks part-time (35-40 hours total)

**END OF TODO.MD - Total Tasks: 50 (Phase 2.5) | Completed: 0 | In Progress: 1 | Pending: 49**
