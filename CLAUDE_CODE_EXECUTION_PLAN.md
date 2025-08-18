# Claude Code Sonnet 4 Execution Plan
**Generated:** 2025-01-17
**Project:** AI Podcasts Nobody Knows
**Target:** Claude 3.5 Sonnet with no reasoning output

## Executive Summary

This plan provides precise, actionable instructions for Claude Code Sonnet 4 to execute critical fixes and improvements to the AI Podcasts Nobody Knows project. All tasks are designed to be executed without showing reasoning, focusing on direct action and results.

## Critical Issues to Fix

### 1. File Format Standardization (URGENT)
**Problem:** 47+ MD files contain XML/HTML tags violating semantic tagging policy
**Impact:** Parsing errors, validation failures, system inconsistency

**Actions:**
1. Remove all XML tags from these MD files:
   - `.claude/CONTEXT.md`
   - `.claude/TOKEN_OPTIMIZATION_GUIDE.md`
   - `.claude/context/*/NAVIGATION.md` files
   - `projects/nobody-knows/existing-episodes/*.md`
   - All other MD files with XML tags

2. Move XML content to appropriate `.xml` files in same directories
3. Update references to point to new XML files
4. Run validation: `scripts/precommit/validate_xml.sh`

### 2. Agent Duplication Cleanup
**Problem:** Multiple research coordinator files causing confusion
**Files:** `01_research_coordinator.md` and `04_research_coordinator.md`

**Actions:**
1. Deprecate `01_research_coordinator.md` (already marked as legacy)
2. Update all references to use `04_research_coordinator.md`
3. Move deprecated file to `agents/backups/legacy/`
4. Update `STAGE_MAPPING.md` to reflect single coordinator

### 3. Git Repository Cleanup
**Problem:** 20 modified files not staged for commit
**Impact:** Unclear project state, potential loss of work

**Actions:**
1. Run `git status` to list all changes
2. Stage and commit completed work:
   ```bash
   git add -p  # Review each change
   git commit -m "fix: standardize file formats and clean up agents"
   ```
3. Create `.gitignore` entries for local-only files
4. Push changes to remote repository

### 4. Complete Level-1-Dev Quality Gates
**Status:** 34/75 tasks complete (45%)
**Current:** Task 35 - Quality Enforcement Hooks

**Actions for Task 35:**
1. Create `quality/hooks/install-hooks.sh`:
   ```bash
   #!/bin/bash
   # Git hooks installer
   cp quality/hooks/pre-push-quality.sh .git/hooks/pre-push
   cp quality/hooks/prepare-commit-msg.sh .git/hooks/prepare-commit-msg
   chmod +x .git/hooks/*
   ```

2. Create `quality/hooks/pre-push-quality.sh`:
   ```bash
   #!/bin/bash
   # Pre-push validation
   ./quality/run-quality-checks.sh || exit 1
   ```

3. Create emergency bypass in `quality/hooks/hook-manager.sh`:
   ```bash
   #!/bin/bash
   # Hook management with bypass
   if [[ "$BYPASS_HOOKS" == "true" ]]; then
     echo "⚠️  Bypassing quality hooks"
     exit 0
   fi
   ```

4. Document usage in `quality/README.md`

## Production Optimization Tasks

### 5. Token Usage Optimization
**Goal:** Reduce costs to meet $4-5 per episode target
**Current:** Unknown actual costs

**Actions:**
1. Implement token tracking in all agents:
   ```yaml
   # Add to each agent header
   token-tracking:
     enabled: true
     log-file: sessions/tokens/${SESSION_ID}.log
   ```

2. Add token limits to agent configs:
   ```yaml
   # In production-config.yaml
   token-limits:
     research: 50000
     script-writing: 30000
     quality-check: 20000
   ```

3. Create cost monitoring dashboard:
   ```bash
   tools/monitor-costs.sh --session $SESSION_ID
   ```

### 6. MCP Integration Validation
**Components:** Perplexity MCP, ElevenLabs MCP
**Status:** Configured but needs validation

**Actions:**
1. Test Perplexity MCP:
   ```bash
   .claude/mcp-servers/test-official-perplexity.sh
   ```

2. Test ElevenLabs MCP:
   ```bash
   python .claude/scripts/test_mcps.py
   ```

3. Validate configurations in `.claude/config/mcp-config.json`
4. Document any issues in `mcp-servers/validation-report.md`

### 7. Episode Production Pipeline Test
**Goal:** Validate full production pipeline
**Target:** Episode 1 from series plan

**Actions:**
1. Run dry test (no API costs):
   ```
   /test-episode-dry-run
   ```

2. If successful, run small production test:
   ```
   /produce-episode --episode 1 --limit-tokens 10000
   ```

3. Review outputs in:
   - `projects/nobody-knows/output/sessions/`
   - `projects/nobody-knows/output/scripts/`
   - `projects/nobody-knows/output/quality/`

4. Calculate actual costs and compare to targets

## Quality Assurance Tasks

### 8. Enforce Dual Explanations
**Problem:** Some documentation missing required explanations
**Validation:** `scripts/precommit/validate_dual_explanations.sh`

**Actions:**
1. Run validation on all XML files:
   ```bash
   find . -name "*.xml" -exec scripts/precommit/validate_dual_explanations.sh {} \;
   ```

2. Add missing explanations to flagged files using format:
   ```xml
   <technical-explanation>Professional explanation</technical-explanation>
   <simple-explanation>Everyday analogy</simple-explanation>
   <learning-value>What this teaches</learning-value>
   ```

### 9. DRY Compliance
**Problem:** Hardcoded values instead of constants
**Validation:** `scripts/precommit/validate_dry_compliance.sh`

**Actions:**
1. Replace all hardcoded values:
   - "125 episodes" → `EPISODE_SPECS['total_episodes']`
   - "27 minutes" → `EPISODE_SPECS['duration_minutes']`
   - "$4-5" → `COST_TARGETS['target_cost']`

2. Update constants in `.claude/00_global_constants.xml`
3. Run validation to confirm compliance

## Documentation Updates

### 10. Update Project Documentation
**Files:** README.md, CONTRIBUTING.md, DEPLOYMENT.md

**Actions:**
1. Update README.md with:
   - Current project status
   - Actual vs target costs
   - Known issues and resolutions

2. Update CONTRIBUTING.md with:
   - File format standards (no XML in MD)
   - Agent naming conventions
   - Quality gate requirements

3. Create CHANGELOG.md documenting all fixes

## Execution Priority

1. **IMMEDIATE (Day 1)**
   - File format standardization (#1)
   - Git cleanup (#3)
   - Agent deduplication (#2)

2. **SHORT TERM (Days 2-3)**
   - Complete quality gates (#4)
   - Token optimization (#5)
   - MCP validation (#6)

3. **VALIDATION (Days 4-5)**
   - Production pipeline test (#7)
   - Quality assurance (#8-9)
   - Documentation updates (#10)

## Success Metrics

- ✅ All MD files free of XML tags
- ✅ Single research coordinator agent
- ✅ Clean git status
- ✅ Quality gates at 50%+ completion
- ✅ Successful dry run of episode production
- ✅ Cost per episode < $5
- ✅ All validations passing

## Notes for Claude Code Sonnet 4

- Execute tasks directly without explaining reasoning
- Use tool calls efficiently - batch operations where possible
- Commit changes atomically with clear messages
- Run validations after each major change
- Stop immediately if any critical errors occur
- Use emergency bypass only when explicitly needed

---
**End of Execution Plan**
