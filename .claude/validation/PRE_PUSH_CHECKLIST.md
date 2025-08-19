# 50-Step Pre-Push Validation Checklist

**Version**: 1.0
**Created**: 2025-08-19
**Purpose**: Comprehensive validation before GitHub push
**Status**: MANDATORY - Must be completed before ANY push to main/production

<validation-protocol type="MANDATORY" enforcement="BRUTAL">
  <critical-mandate>
    ALL 50 STEPS MUST BE VERIFIED AND SIGNED OFF BEFORE ANY GITHUB PUSH
    FAILURE TO COMPLETE ANY STEP INVALIDATES THE PUSH AND REQUIRES RESTART
    NO SHORTCUTS - NO EXCEPTIONS - NO BYPASSES ALLOWED
  </critical-mandate>
</validation-protocol>

## Validation Overview

**Technical:** This checklist validates every critical system component based on issues encountered during development and potential failure modes identified through deep analysis.

**Simple:** Like a pilot's pre-flight checklist - we check everything that could go wrong before taking off, because fixing problems on the ground is infinitely easier than fixing them in flight.

**Connection:** This teaches systematic quality assurance, risk management, and production deployment practices essential for professional software development.

---

## A. ENVIRONMENT & DEPENDENCIES (Steps 1-5)

### ☐ 1. Python Environment Validation
**Check**: Python 3.11+ active and virtual environment properly activated
**Command**: `python --version && echo $VIRTUAL_ENV`
**Expected**: Python 3.11.x+ and valid venv path
**Failure Action**: Activate correct environment or install Python

### ☐ 2. Node.js Environment Validation
**Check**: Node.js 18+ available for any JavaScript tooling
**Command**: `node --version`
**Expected**: v18.x.x or higher
**Failure Action**: Install/update Node.js

### ☐ 3. Required API Keys Present
**Check**: All required API keys exist in .env (not values, just existence)
**Command**: `grep -E "^(PERPLEXITY_API_KEY|ELEVENLABS_API_KEY|OPENROUTER_API_KEY|GITHUB_PAT)=" .env | wc -l`
**Expected**: 4 (all keys present)
**Failure Action**: Add missing API keys to .env

### ☐ 4. Required Python Packages Installed
**Check**: All dependencies from requirements.txt are installed
**Command**: `pip check`
**Expected**: No errors about missing dependencies
**Failure Action**: `pip install -r requirements.txt`

### ☐ 5. MCP Server Configuration
**Check**: Claude Code MCP configuration file is valid
**Command**: `cat .claude/config/claude-code-mcp.json | python -m json.tool > /dev/null`
**Expected**: Valid JSON, no parsing errors
**Failure Action**: Fix JSON syntax in MCP config

---

## B. FILE STRUCTURE & NAMING (Steps 6-10)

### ☐ 6. Agent File Naming Convention
**Check**: All agent files follow ##_agent-name.md format
**Command**: `scripts/precommit/validate_naming_conventions.sh`
**Expected**: All agent files pass naming validation
**Failure Action**: Rename files to proper format

### ☐ 7. No Duplicate Files Across Directories
**Check**: No agent files exist in multiple locations
**Command**: `find .claude/agents -name "*.md" | sort | uniq -d`
**Expected**: No output (no duplicates)
**Failure Action**: Remove duplicate files

### ☐ 8. Relative Path Usage
**Check**: No hardcoded absolute paths in configuration or code
**Command**: `grep -r "/Users/\|/home/\|C:\\\\" . --include="*.md" --include="*.json" --include="*.yaml" | grep -v ".git"`
**Expected**: No hardcoded paths found
**Failure Action**: Replace with relative paths

### ☐ 9. Directory Structure Integrity
**Check**: All required directories exist with correct structure
**Command**: `test -d .claude/agents/research && test -d .claude/agents/production && test -d .claude/commands && test -d .claude/context && test -d validation`
**Expected**: All directories exist
**Failure Action**: Create missing directories

### ☐ 10. No Orphaned/Temporary Files
**Check**: No .tmp, .bak, .swp, or similar temporary files
**Command**: `find . -name "*.tmp" -o -name "*.bak" -o -name "*.swp" -o -name "*~" | grep -v ".git"`
**Expected**: No temporary files found
**Failure Action**: Remove temporary files

---

## C. AGENT CONFIGURATION (Steps 11-15)

### ☐ 11. Agent Frontmatter Validation
**Check**: All agents have valid YAML frontmatter with required fields
**Command**: `for file in .claude/agents/**/*.md; do python -c "import yaml; yaml.safe_load(open('$file').read().split('---')[1])" 2>/dev/null || echo "Invalid: $file"; done`
**Expected**: No invalid frontmatter
**Failure Action**: Fix YAML syntax errors

### ☐ 12. Agent Name Consistency
**Check**: Frontmatter name field matches filename
**Command**: Custom validation script to verify name field = filename
**Expected**: All names consistent
**Failure Action**: Update frontmatter or rename files

### ☐ 13. Required Tools Listed
**Check**: All agents specify required tools in frontmatter
**Command**: Verify tools field exists and is not empty for all agents
**Expected**: All agents have tools specified
**Failure Action**: Add missing tools to frontmatter

### ☐ 14. Claude Code Discovery Test
**Check**: All agents discoverable by Claude Code Task tool
**Command**: Test agent discovery through Claude Code interface
**Expected**: All 14 agents appear in available list
**Failure Action**: Fix naming or frontmatter issues

### ☐ 15. No Circular Dependencies
**Check**: No agent references create circular dependencies
**Command**: Analyze agent task orchestration for loops
**Expected**: Clean dependency graph
**Failure Action**: Restructure agent relationships

---

## D. COMMAND INTEGRITY (Steps 16-20)

### ☐ 16. Command Agent References
**Check**: All commands reference correct numbered agent names
**Command**: `grep -n "subagent" .claude/commands/*.md | grep -v "##_"`
**Expected**: No non-numbered agent references
**Failure Action**: Update commands to use numbered names

### ☐ 17. Command Execution Paths Valid
**Check**: All command workflows reference existing agents and processes
**Command**: Verify all referenced agents/tools exist
**Expected**: All references resolve correctly
**Failure Action**: Fix broken references

### ☐ 18. Command Arguments Documented
**Check**: All commands have proper usage and argument documentation
**Command**: Verify usage sections exist and are complete
**Expected**: Complete documentation for all commands
**Failure Action**: Add missing documentation

### ☐ 19. Command Examples Functional
**Check**: Example commands in documentation are valid and runnable
**Command**: Test example command syntax
**Expected**: All examples are syntactically correct
**Failure Action**: Fix example commands

### ☐ 20. Error Handling Present
**Check**: Commands include proper error handling and recovery instructions
**Command**: Verify error scenarios are documented
**Expected**: Error handling documented for all commands
**Failure Action**: Add error handling documentation

---

## E. INTEGRATION TESTING (Steps 21-25)

### ☐ 21. Research Stream Test
**Check**: Complete research stream executes successfully
**Command**: Run test research coordination with simple topic
**Expected**: Research pipeline completes without errors
**Failure Action**: Debug and fix research stream issues

### ☐ 22. Production Stream Test
**Check**: Complete production stream executes successfully
**Command**: Run test production pipeline with sample research
**Expected**: Production pipeline completes without errors
**Failure Action**: Debug and fix production stream issues

### ☐ 23. End-to-End Episode Test
**Check**: Full episode creation from topic to audio works
**Command**: `/test-episode "Simple Test Topic"`
**Expected**: Complete episode generated successfully
**Failure Action**: Debug full pipeline issues

### ☐ 24. Checkpoint Save/Restore Functional
**Check**: Session checkpoints save and restore correctly
**Command**: Test checkpoint creation and recovery
**Expected**: Checkpoints work without data loss
**Failure Action**: Fix checkpoint mechanism

### ☐ 25. Session Management Working
**Check**: Session directory creation and management functional
**Command**: Verify session creation, organization, and cleanup
**Expected**: Sessions managed correctly
**Failure Action**: Fix session management logic

---

## F. QUALITY & BRAND (Steps 26-30)

### ☐ 26. Brand Voice Consistency Check
**Check**: Generated content maintains "Nobody Knows" intellectual humility brand
**Command**: `scripts/quality_gates/test_brand_voice_gates.sh`
**Expected**: Brand voice tests pass
**Failure Action**: Fix brand voice violations

### ☐ 27. Dual Explanations Present
**Check**: All technical concepts include both technical and simple explanations
**Command**: `scripts/precommit/validate_dual_explanations.sh`
**Expected**: All files have required dual explanations
**Failure Action**: Add missing dual explanations

### ☐ 28. Quality Gates Operational
**Check**: Both Claude and Gemini quality evaluation systems functional
**Command**: `scripts/quality_gates/test_dual_evaluation_consensus.sh`
**Expected**: Quality gates working correctly
**Failure Action**: Fix quality evaluation systems

### ☐ 29. Readability Scores Acceptable
**Check**: Generated content meets readability standards
**Command**: `scripts/quality_gates/test_readability_accessibility_gates.sh`
**Expected**: Readability tests pass
**Failure Action**: Improve content readability

### ☐ 30. Intellectual Humility Maintained
**Check**: Content celebrates uncertainty and expert confusion appropriately
**Command**: Verify humility phrases and uncertainty acknowledgments
**Expected**: Intellectual humility standards met
**Failure Action**: Enhance uncertainty acknowledgments

---

## G. SECURITY & CREDENTIALS (Steps 31-35)

### ☐ 31. No API Keys in Code/Commits
**Check**: No API keys or secrets in committed code
**Command**: `git log --all -S "sk-" -S "api_key" -S "secret" --oneline | head -10`
**Expected**: No commits with exposed keys
**Failure Action**: Remove keys from history, regenerate

### ☐ 32. .env Properly Gitignored
**Check**: .env file excluded from git tracking
**Command**: `git check-ignore .env`
**Expected**: .env is ignored
**Failure Action**: Add .env to .gitignore

### ☐ 33. No Sensitive Data in Logs
**Check**: Log files contain no sensitive information
**Command**: `grep -ri "api_key\|secret\|password" *.log 2>/dev/null || echo "No sensitive data in logs"`
**Expected**: No sensitive data found
**Failure Action**: Clean logs, fix logging

### ☐ 34. Permissions Correctly Set
**Check**: File permissions appropriate for security
**Command**: `find . -name "*.sh" -not -perm 755 | grep -v ".git"`
**Expected**: No improperly permissioned scripts
**Failure Action**: Fix file permissions

### ☐ 35. No Hardcoded Credentials
**Check**: No credentials hardcoded in configuration files
**Command**: `grep -r "password\|secret\|key.*=" . --include="*.json" --include="*.yaml" --include="*.md" | grep -v "API_KEY\|example\|placeholder"`
**Expected**: No hardcoded credentials
**Failure Action**: Move credentials to .env

---

## H. PERFORMANCE & COSTS (Steps 36-40)

### ☐ 36. Cost Tracking Functional
**Check**: Episode cost tracking and reporting works
**Command**: Verify cost calculation mechanisms
**Expected**: Costs properly tracked and reported
**Failure Action**: Fix cost tracking system

### ☐ 37. Budget Limits Enforced
**Check**: API usage budgets prevent overruns
**Command**: Test budget limit enforcement
**Expected**: Budget limits working correctly
**Failure Action**: Implement/fix budget controls

### ☐ 38. Token Usage Monitored
**Check**: Token consumption tracking operational
**Command**: Verify token monitoring systems
**Expected**: Token usage properly monitored
**Failure Action**: Implement token monitoring

### ☐ 39. Checkpoint Optimization Working
**Check**: Checkpoint system prevents unnecessary API calls
**Command**: Test checkpoint cost savings
**Expected**: Checkpoints reduce redundant operations
**Failure Action**: Fix checkpoint optimization

### ☐ 40. No Infinite Loops Possible
**Check**: Agent orchestration cannot create infinite loops
**Command**: Analyze agent calling patterns for potential loops
**Expected**: No loop scenarios possible
**Failure Action**: Add loop prevention mechanisms

---

## I. DOCUMENTATION & MAINTENANCE (Steps 41-45)

### ☐ 41. CLAUDE.md Current and Accurate
**Check**: Master system prompt reflects actual system state
**Command**: Verify CLAUDE.md matches implementation
**Expected**: Documentation matches reality
**Failure Action**: Update CLAUDE.md to match current state

### ☐ 42. README Reflects Actual State
**Check**: README.md provides accurate project description
**Command**: Verify README accuracy
**Expected**: README is current and helpful
**Failure Action**: Update README content

### ☐ 43. Agent Descriptions Match Functionality
**Check**: Agent documentation accurately describes what agents do
**Command**: Verify agent descriptions vs. implementation
**Expected**: Descriptions are accurate
**Failure Action**: Update agent documentation

### ☐ 44. Command Docs Match Implementation
**Check**: Command documentation reflects actual command behavior
**Command**: Verify command docs vs. actual execution
**Expected**: Documentation matches implementation
**Failure Action**: Update command documentation

### ☐ 45. Navigation Links Functional
**Check**: All @ references and navigation links work correctly
**Command**: `scripts/precommit/validate_navigation.sh`
**Expected**: All navigation links resolve
**Failure Action**: Fix broken navigation links

---

## J. GIT & DEPLOYMENT (Steps 46-50)

### ☐ 46. All Changes Committed
**Check**: Working directory clean, no uncommitted changes
**Command**: `git status --porcelain`
**Expected**: No output (clean working directory)
**Failure Action**: Commit or stash changes

### ☐ 47. Pre-commit Hooks Passing
**Check**: All pre-commit hooks execute successfully
**Command**: `pre-commit run --all-files`
**Expected**: All hooks pass
**Failure Action**: Fix hook failures

### ☐ 48. No Merge Conflicts
**Check**: No unresolved merge conflicts in any files
**Command**: `git diff --check && git status | grep -q "unmerged" && echo "Conflicts found" || echo "No conflicts"`
**Expected**: No merge conflicts
**Failure Action**: Resolve merge conflicts

### ☐ 49. Branch Up to Date
**Check**: Local branch is current with remote main
**Command**: `git fetch && git status | grep "up to date"`
**Expected**: Branch is up to date
**Failure Action**: Pull latest changes, resolve conflicts

### ☐ 50. All Tests Passing
**Check**: Complete test suite executes successfully
**Command**: `./tests/test_framework.sh`
**Expected**: All tests pass
**Failure Action**: Fix failing tests

---

## VALIDATION SIGN-OFF

**Validator Name**: ________________________
**Date/Time**: ____________________________
**Validation Duration**: ___________________
**Issues Found**: __________________________
**Issues Resolved**: _______________________

**Critical Assertion**: I certify that all 50 validation steps have been completed successfully and the system is ready for production deployment.

**Signature**: _____________________________

---

## VALIDATION FAILURE PROTOCOL

<failure-protocol type="MANDATORY" enforcement="BRUTAL">
  <critical-actions>
    IF ANY STEP FAILS:
    1. IMMEDIATELY STOP the push process
    2. Document the failure in detail
    3. Fix the underlying issue completely
    4. RESTART the entire 50-step validation from Step 1
    5. NO PARTIAL VALIDATIONS OR SKIPPING ALLOWED
  </critical-actions>
</failure-protocol>

**Technical:** This validation protocol ensures systematic verification of all critical system components before deployment, preventing the propagation of defects to production.

**Simple:** Like a pilot who finds one problem during pre-flight inspection and then rechecks everything from the beginning - one failure means we start over to ensure nothing was missed.

**Connection:** This teaches professional quality assurance practices and the importance of systematic verification in complex systems.

---

*Version 1.0 - Comprehensive validation framework based on encountered issues and failure mode analysis.*
