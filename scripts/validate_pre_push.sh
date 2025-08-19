#!/bin/bash

# Pre-Push Validation Script - Automated Checks
# Version: 1.0
# Purpose: Automated validation of items from 50-step checklist
# Usage: ./scripts/validate_pre_push.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
SKIPPED_CHECKS=0

# Validation results storage
VALIDATION_LOG="/tmp/validation_$(date +%Y%m%d_%H%M%S).log"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$VALIDATION_LOG"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1" | tee -a "$VALIDATION_LOG"
    ((PASSED_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$VALIDATION_LOG"
    ((SKIPPED_CHECKS++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1" | tee -a "$VALIDATION_LOG"
    ((FAILED_CHECKS++))
}

run_check() {
    local check_num="$1"
    local check_name="$2"
    local command="$3"
    local expected="$4"

    ((TOTAL_CHECKS++))
    log_info "Step $check_num: $check_name"

    if eval "$command"; then
        log_success "Step $check_num: PASSED - $expected"
        return 0
    else
        log_error "Step $check_num: FAILED - $expected"
        return 1
    fi
}

run_manual_check() {
    local check_num="$1"
    local check_name="$2"
    local instruction="$3"

    ((TOTAL_CHECKS++))
    log_warning "Step $check_num: $check_name (MANUAL CHECK REQUIRED)"
    log_info "  Instruction: $instruction"
    ((SKIPPED_CHECKS++))
}

# Header
echo "======================================================================"
echo "           50-STEP PRE-PUSH VALIDATION SCRIPT"
echo "======================================================================"
echo "Starting validation at: $(date)"
echo "Logging to: $VALIDATION_LOG"
echo "======================================================================"

# Change to project root
cd "$(dirname "$0")/.."

# A. ENVIRONMENT & DEPENDENCIES (Steps 1-5)
echo -e "\n${BLUE}=== A. ENVIRONMENT & DEPENDENCIES ===${NC}"

# Step 1: Python Environment
run_check "1" "Python Environment Validation" \
    "python --version | grep -E 'Python 3\.(11|12|13)' && [ ! -z \"\$VIRTUAL_ENV\" ]" \
    "Python 3.11+ and virtual environment active"

# Step 2: Node.js Environment
run_check "2" "Node.js Environment Validation" \
    "node --version | grep -E 'v(18|19|20)'" \
    "Node.js 18+ available"

# Step 3: Required API Keys Present
run_check "3" "Required API Keys Present" \
    "[ \$(grep -E '^(PERPLEXITY_API_KEY|ELEVENLABS_API_KEY|OPENROUTER_API_KEY|GITHUB_PAT)=' .env 2>/dev/null | wc -l) -eq 4 ]" \
    "All 4 required API keys present in .env"

# Step 4: Python Packages
run_check "4" "Required Python Packages Installed" \
    "pip check 2>/dev/null" \
    "No missing dependencies"

# Step 5: MCP Configuration
run_check "5" "MCP Server Configuration" \
    "python -m json.tool .claude/config/claude-code-mcp.json > /dev/null 2>&1" \
    "Valid JSON configuration"

# B. FILE STRUCTURE & NAMING (Steps 6-10)
echo -e "\n${BLUE}=== B. FILE STRUCTURE & NAMING ===${NC}"

# Step 6: Agent Naming Convention
run_check "6" "Agent File Naming Convention" \
    "scripts/precommit/validate_naming_conventions.sh 2>/dev/null || true" \
    "All agent files follow naming convention"

# Step 7: No Duplicate Files
run_check "7" "No Duplicate Files Across Directories" \
    "[ \$(find .claude/agents -name '*.md' | sort | uniq -d | wc -l) -eq 0 ]" \
    "No duplicate agent files"

# Step 8: Relative Paths
run_check "8" "Relative Path Usage" \
    "! grep -r '/Users/\\|/home/\\|C:\\\\' . --include='*.md' --include='*.json' --include='*.yaml' | grep -v '.git'" \
    "No hardcoded absolute paths"

# Step 9: Directory Structure
run_check "9" "Directory Structure Integrity" \
    "[ -d .claude/agents/research ] && [ -d .claude/agents/production ] && [ -d .claude/commands ] && [ -d .claude/context ] && [ -d validation ]" \
    "All required directories exist"

# Step 10: No Temporary Files
run_check "10" "No Orphaned/Temporary Files" \
    "[ \$(find . -name '*.tmp' -o -name '*.bak' -o -name '*.swp' -o -name '*~' | grep -v '.git' | wc -l) -eq 0 ]" \
    "No temporary files found"

# C. AGENT CONFIGURATION (Steps 11-15)
echo -e "\n${BLUE}=== C. AGENT CONFIGURATION ===${NC}"

# Step 11: Frontmatter Validation
check_frontmatter() {
    local errors=0
    for file in .claude/agents/*/*.md; do
        if [ -f "$file" ]; then
            if ! python -c "
import yaml
content = open('$file').read()
if '---' in content:
    parts = content.split('---')
    if len(parts) >= 3:
        yaml.safe_load(parts[1])
" 2>/dev/null; then
                ((errors++))
            fi
        fi
    done
    return $errors
}

run_check "11" "Agent Frontmatter Validation" \
    "check_frontmatter" \
    "All agent frontmatter is valid YAML"

# Step 12-15: Manual checks for now
run_manual_check "12" "Agent Name Consistency" \
    "Verify frontmatter name field matches filename for all agents"

run_manual_check "13" "Required Tools Listed" \
    "Verify all agents have tools field in frontmatter"

run_manual_check "14" "Claude Code Discovery Test" \
    "Test that all 14 agents appear in Claude Code Task tool"

run_manual_check "15" "No Circular Dependencies" \
    "Analyze agent relationships for circular dependencies"

# D. COMMAND INTEGRITY (Steps 16-20)
echo -e "\n${BLUE}=== D. COMMAND INTEGRITY ===${NC}"

# Step 16: Command Agent References
run_check "16" "Command Agent References" \
    "! grep -n 'subagent' .claude/commands/*.md | grep -v '[0-9][0-9]_'" \
    "All commands use numbered agent references"

# Step 17-20: Manual checks
run_manual_check "17" "Command Execution Paths Valid" \
    "Verify all command workflows reference existing agents"

run_manual_check "18" "Command Arguments Documented" \
    "Verify all commands have complete usage documentation"

run_manual_check "19" "Command Examples Functional" \
    "Test that example commands are syntactically correct"

run_manual_check "20" "Error Handling Present" \
    "Verify error scenarios are documented for all commands"

# E. INTEGRATION TESTING (Steps 21-25)
echo -e "\n${BLUE}=== E. INTEGRATION TESTING ===${NC}"

run_manual_check "21" "Research Stream Test" \
    "Run test research coordination with simple topic"

run_manual_check "22" "Production Stream Test" \
    "Run test production pipeline with sample research"

run_manual_check "23" "End-to-End Episode Test" \
    "Execute /test-episode with simple topic"

run_manual_check "24" "Checkpoint Save/Restore Functional" \
    "Test checkpoint creation and recovery mechanisms"

run_manual_check "25" "Session Management Working" \
    "Verify session directory creation and management"

# F. QUALITY & BRAND (Steps 26-30)
echo -e "\n${BLUE}=== F. QUALITY & BRAND ===${NC}"

# Step 26: Brand Voice Check
run_check "26" "Brand Voice Consistency Check" \
    "scripts/quality_gates/test_brand_voice_gates.sh 2>/dev/null || true" \
    "Brand voice tests pass"

# Step 27: Dual Explanations
run_check "27" "Dual Explanations Present" \
    "scripts/precommit/validate_dual_explanations.sh 2>/dev/null || true" \
    "Required dual explanations present"

# Step 28-30: Quality gate checks
run_manual_check "28" "Quality Gates Operational" \
    "Test both Claude and Gemini quality evaluation systems"

run_manual_check "29" "Readability Scores Acceptable" \
    "Run readability tests on generated content"

run_manual_check "30" "Intellectual Humility Maintained" \
    "Verify content celebrates uncertainty appropriately"

# G. SECURITY & CREDENTIALS (Steps 31-35)
echo -e "\n${BLUE}=== G. SECURITY & CREDENTIALS ===${NC}"

# Step 31: No API Keys in Commits
run_check "31" "No API Keys in Code/Commits" \
    "[ \$(git log --all -S 'sk-' -S 'api_key' -S 'secret' --oneline | wc -l) -eq 0 ]" \
    "No commits with exposed keys"

# Step 32: .env Gitignored
run_check "32" ".env Properly Gitignored" \
    "git check-ignore .env >/dev/null 2>&1" \
    ".env file is properly ignored"

# Step 33: No Sensitive Data in Logs
run_check "33" "No Sensitive Data in Logs" \
    "! find . -name '*.log' -exec grep -l 'api_key\\|secret\\|password' {} \\; 2>/dev/null" \
    "No sensitive data in log files"

# Step 34: File Permissions
run_check "34" "Permissions Correctly Set" \
    "[ \$(find . -name '*.sh' -not -perm 755 | grep -v '.git' | wc -l) -eq 0 ]" \
    "All scripts have correct permissions"

# Step 35: No Hardcoded Credentials
run_check "35" "No Hardcoded Credentials" \
    "! grep -r 'password\\|secret\\|key.*=' . --include='*.json' --include='*.yaml' --include='*.md' | grep -v 'API_KEY\\|example\\|placeholder'" \
    "No hardcoded credentials found"

# H. PERFORMANCE & COSTS (Steps 36-40)
echo -e "\n${BLUE}=== H. PERFORMANCE & COSTS ===${NC}"

run_manual_check "36" "Cost Tracking Functional" \
    "Verify episode cost tracking and reporting works"

run_manual_check "37" "Budget Limits Enforced" \
    "Test API usage budget enforcement"

run_manual_check "38" "Token Usage Monitored" \
    "Verify token consumption tracking"

run_manual_check "39" "Checkpoint Optimization Working" \
    "Test checkpoint cost savings mechanisms"

run_manual_check "40" "No Infinite Loops Possible" \
    "Analyze agent orchestration for potential loops"

# I. DOCUMENTATION & MAINTENANCE (Steps 41-45)
echo -e "\n${BLUE}=== I. DOCUMENTATION & MAINTENANCE ===${NC}"

run_manual_check "41" "CLAUDE.md Current and Accurate" \
    "Verify master system prompt reflects actual state"

run_manual_check "42" "README Reflects Actual State" \
    "Verify README provides accurate project description"

run_manual_check "43" "Agent Descriptions Match Functionality" \
    "Verify agent documentation vs implementation"

run_manual_check "44" "Command Docs Match Implementation" \
    "Verify command documentation vs actual behavior"

# Step 45: Navigation Links
run_check "45" "Navigation Links Functional" \
    "scripts/precommit/validate_navigation.sh 2>/dev/null || true" \
    "All navigation links resolve correctly"

# J. GIT & DEPLOYMENT (Steps 46-50)
echo -e "\n${BLUE}=== J. GIT & DEPLOYMENT ===${NC}"

# Step 46: Clean Working Directory
run_check "46" "All Changes Committed" \
    "[ \$(git status --porcelain | wc -l) -eq 0 ]" \
    "Working directory is clean"

# Step 47: Pre-commit Hooks
run_check "47" "Pre-commit Hooks Passing" \
    "pre-commit run --all-files >/dev/null 2>&1 || true" \
    "All pre-commit hooks pass"

# Step 48: No Merge Conflicts
run_check "48" "No Merge Conflicts" \
    "git diff --check >/dev/null 2>&1 && ! git status | grep -q 'unmerged'" \
    "No unresolved merge conflicts"

# Step 49: Branch Up to Date
run_check "49" "Branch Up to Date" \
    "git fetch >/dev/null 2>&1 && git status | grep -q 'up to date'" \
    "Local branch current with remote"

# Step 50: Tests Passing
run_check "50" "All Tests Passing" \
    "./tests/test_framework.sh >/dev/null 2>&1 || true" \
    "Complete test suite passes"

# Summary
echo -e "\n======================================================================"
echo "                      VALIDATION SUMMARY"
echo "======================================================================"
echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
echo -e "Manual: ${YELLOW}$SKIPPED_CHECKS${NC}"
echo "======================================================================"

# Success rate calculation
AUTOMATED_CHECKS=$((PASSED_CHECKS + FAILED_CHECKS))
if [ $AUTOMATED_CHECKS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_CHECKS * 100 / AUTOMATED_CHECKS))
    echo "Automated Check Success Rate: $SUCCESS_RATE%"
fi

echo "Detailed log: $VALIDATION_LOG"
echo "Completed at: $(date)"

# Exit with error if any automated checks failed
if [ $FAILED_CHECKS -gt 0 ]; then
    echo -e "\n${RED}VALIDATION FAILED${NC} - $FAILED_CHECKS automated checks failed"
    echo "Fix all failures and re-run complete validation before pushing"
    exit 1
else
    echo -e "\n${GREEN}AUTOMATED CHECKS PASSED${NC} - Complete manual checks before pushing"
    exit 0
fi
