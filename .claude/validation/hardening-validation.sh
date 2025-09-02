#!/bin/bash

# Production Hardening Validation Suite
# Claude Code Native - Bash-only implementation
# Version: 1.0.0
# Purpose: Validate all hardening measures are in place and functional

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VALIDATION_LOG="$PROJECT_ROOT/.claude/logs/hardening-validation-$(date +%Y%m%d-%H%M%S).log"
HARDENING_CONFIG="$PROJECT_ROOT/.claude/config/hardening.yaml"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS=0

# Ensure log directory exists
mkdir -p "$(dirname "$VALIDATION_LOG")"

# Logging functions
log_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$VALIDATION_LOG"
    echo -e "${BLUE}$*${NC}" | tee -a "$VALIDATION_LOG"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$VALIDATION_LOG"
}

log_test() {
    echo -e "${YELLOW}[TEST]${NC} $*" | tee -a "$VALIDATION_LOG"
    ((TESTS_RUN++))
}

log_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $*" | tee -a "$VALIDATION_LOG"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $*" | tee -a "$VALIDATION_LOG"
    ((TESTS_FAILED++))
}

log_warn() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $*" | tee -a "$VALIDATION_LOG"
    ((WARNINGS++))
}

# =============================================================================
# SECURITY VALIDATION
# =============================================================================

validate_api_keys() {
    log_header "API KEY SECURITY VALIDATION"

    log_test "Checking API keys are not exposed in code"
    if grep -r "sk-ant-\|sk_\|pplx-" "$PROJECT_ROOT" --exclude-dir=.git --exclude-dir=.env --exclude="*.log" 2>/dev/null | grep -v "example\|template"; then
        log_fail "API keys found in code!"
        return 1
    else
        log_pass "No API keys exposed in code"
    fi

    log_test "Checking .env file is git-ignored"
    if grep -q "^\.env$" "$PROJECT_ROOT/.gitignore"; then
        log_pass ".env properly git-ignored"
    else
        log_fail ".env not in .gitignore!"
        return 1
    fi

    log_test "Checking API key masking in logs"
    local log_files=$(find "$PROJECT_ROOT/.claude/logs" -name "*.log" 2>/dev/null)
    if [[ -n "$log_files" ]]; then
        if echo "$log_files" | xargs grep -l "sk-ant-\|sk_\|pplx-" 2>/dev/null; then
            log_warn "Potential API keys found in logs"
        else
            log_pass "No API keys exposed in logs"
        fi
    else
        log_pass "No log files to check"
    fi
}

validate_input_sanitization() {
    log_header "INPUT VALIDATION SECURITY"

    log_test "Checking input validation configuration"
    if [[ -f "$HARDENING_CONFIG" ]]; then
        if grep -q "input_validation:" "$HARDENING_CONFIG"; then
            log_pass "Input validation configured"
        else
            log_fail "Input validation not configured"
            return 1
        fi
    else
        log_fail "Hardening config missing"
        return 1
    fi

    log_test "Checking SQL injection prevention"
    if grep -q "sql_injection_check: true" "$HARDENING_CONFIG"; then
        log_pass "SQL injection prevention enabled"
    else
        log_warn "SQL injection prevention not enabled"
    fi

    log_test "Checking XSS prevention"
    if grep -q "xss_prevention: true" "$HARDENING_CONFIG"; then
        log_pass "XSS prevention enabled"
    else
        log_warn "XSS prevention not enabled"
    fi
}

validate_rate_limiting() {
    log_header "RATE LIMITING VALIDATION"

    log_test "Checking rate limiting configuration"
    if grep -q "rate_limiting:" "$HARDENING_CONFIG"; then
        log_pass "Rate limiting configured"

        # Check specific API limits
        for api in perplexity elevenlabs anthropic; do
            if grep -q "$api:" "$HARDENING_CONFIG"; then
                echo "  ✓ $api rate limits configured" >> "$VALIDATION_LOG"
            else
                echo "  ⚠ $api rate limits missing" >> "$VALIDATION_LOG"
            fi
        done
    else
        log_fail "Rate limiting not configured"
        return 1
    fi
}

validate_audit_logging() {
    log_header "AUDIT LOGGING VALIDATION"

    log_test "Checking audit logging configuration"
    if grep -q "audit_logging:" "$HARDENING_CONFIG" && grep -q "enabled: true" "$HARDENING_CONFIG"; then
        log_pass "Audit logging enabled"
    else
        log_fail "Audit logging not enabled"
        return 1
    fi

    log_test "Checking log directory permissions"
    local log_dir="$PROJECT_ROOT/.claude/logs"
    if [[ -d "$log_dir" ]]; then
        if [[ -w "$log_dir" ]]; then
            log_pass "Log directory writable"
        else
            log_fail "Log directory not writable"
            return 1
        fi
    else
        log_fail "Log directory doesn't exist"
        mkdir -p "$log_dir"
        log_warn "Created log directory"
    fi
}

# =============================================================================
# RELIABILITY VALIDATION
# =============================================================================

validate_error_handling() {
    log_header "ERROR HANDLING VALIDATION"

    log_test "Checking retry configuration"
    if grep -q "retry_strategy:" "$HARDENING_CONFIG" && grep -q "max_attempts:" "$HARDENING_CONFIG"; then
        log_pass "Retry strategy configured"
    else
        log_fail "Retry strategy not configured"
        return 1
    fi

    log_test "Checking circuit breaker configuration"
    if grep -q "circuit_breaker:" "$HARDENING_CONFIG" && grep -q "enabled: true" "$HARDENING_CONFIG"; then
        log_pass "Circuit breaker enabled"
    else
        log_warn "Circuit breaker not enabled"
    fi

    log_test "Checking fallback mechanisms"
    if grep -q "fallback:" "$HARDENING_CONFIG" && grep -q "use_cache: true" "$HARDENING_CONFIG"; then
        log_pass "Fallback mechanisms configured"
    else
        log_warn "Fallback mechanisms not fully configured"
    fi
}

validate_resource_limits() {
    log_header "RESOURCE LIMITS VALIDATION"

    log_test "Checking memory limits"
    if grep -q "memory:" "$HARDENING_CONFIG" && grep -q "max_mb:" "$HARDENING_CONFIG"; then
        log_pass "Memory limits configured"
    else
        log_fail "Memory limits not configured"
        return 1
    fi

    log_test "Checking disk limits"
    if grep -q "disk:" "$HARDENING_CONFIG" && grep -q "max_gb:" "$HARDENING_CONFIG"; then
        log_pass "Disk limits configured"
    else
        log_fail "Disk limits not configured"
        return 1
    fi

    log_test "Checking concurrent operation limits"
    if grep -q "concurrent_operations:" "$HARDENING_CONFIG"; then
        log_pass "Concurrent operation limits configured"
    else
        log_warn "Concurrent operation limits not configured"
    fi
}

validate_health_checks() {
    log_header "HEALTH CHECK VALIDATION"

    log_test "Checking health check configuration"
    if grep -q "health_checks:" "$HARDENING_CONFIG" && grep -q "enabled: true" "$HARDENING_CONFIG"; then
        log_pass "Health checks enabled"
    else
        log_fail "Health checks not enabled"
        return 1
    fi

    log_test "Testing MCP connectivity check"
    if command -v claude &> /dev/null; then
        if claude mcp list &> /dev/null; then
            log_pass "MCP connectivity check functional"
        else
            log_warn "MCP connectivity check failed"
        fi
    else
        log_warn "Claude CLI not available for testing"
    fi
}

# =============================================================================
# OPERATIONAL VALIDATION
# =============================================================================

validate_monitoring() {
    log_header "MONITORING VALIDATION"

    log_test "Checking monitoring configuration"
    if grep -q "monitoring:" "$HARDENING_CONFIG" && grep -q "enabled: true" "$HARDENING_CONFIG"; then
        log_pass "Monitoring enabled"
    else
        log_fail "Monitoring not enabled"
        return 1
    fi

    log_test "Checking alerting configuration"
    if grep -q "alerting:" "$HARDENING_CONFIG" && grep -q "enabled: true" "$HARDENING_CONFIG"; then
        log_pass "Alerting enabled"
    else
        log_warn "Alerting not enabled"
    fi
}

validate_session_management() {
    log_header "SESSION MANAGEMENT VALIDATION"

    log_test "Checking session lifecycle hook"
    local session_hook="$PROJECT_ROOT/.claude/hooks/simplified/session-lifecycle.sh"
    if [[ -f "$session_hook" ]]; then
        if [[ -x "$session_hook" ]]; then
            log_pass "Session lifecycle hook exists and is executable"
        else
            log_fail "Session lifecycle hook not executable"
            chmod +x "$session_hook"
            log_warn "Made session hook executable"
        fi
    else
        log_fail "Session lifecycle hook missing"
        return 1
    fi

    log_test "Checking checkpoint configuration"
    if grep -q "checkpoint_interval:" "$HARDENING_CONFIG"; then
        log_pass "Checkpoint interval configured"
    else
        log_warn "Checkpoint interval not configured"
    fi
}

# =============================================================================
# CLAUDE CODE NATIVE VALIDATION
# =============================================================================

validate_claude_code_patterns() {
    log_header "CLAUDE CODE NATIVE PATTERNS VALIDATION"

    log_test "Checking for Task tool usage (forbidden)"
    if grep -r "Task tool\|task_tool" "$PROJECT_ROOT/.claude" --include="*.md" 2>/dev/null | grep -v "NOT\|forbidden\|prohibited"; then
        log_fail "Task tool references found!"
        return 1
    else
        log_pass "No Task tool usage found"
    fi

    log_test "Checking agent YAML structure"
    local agent_files=$(find "$PROJECT_ROOT/.claude/agents/simplified" -name "*.md" 2>/dev/null)
    local all_valid=true
    for agent in $agent_files; do
        if grep -q "^name:" "$agent"; then
            if grep -q "^tools:" "$agent"; then
                echo "  ✗ $(basename "$agent") has hardcoded tools!" >> "$VALIDATION_LOG"
                all_valid=false
            fi
        fi
    done

    if $all_valid; then
        log_pass "All agents use MCP inheritance correctly"
    else
        log_fail "Some agents have hardcoded tools"
        return 1
    fi

    log_test "Checking hook scripts are bash-only"
    local hook_files=$(find "$PROJECT_ROOT/.claude/hooks" -name "*.sh" 2>/dev/null)
    local all_bash=true
    for hook in $hook_files; do
        if ! head -1 "$hook" | grep -q "^#!/bin/bash"; then
            echo "  ✗ $(basename "$hook") is not a bash script!" >> "$VALIDATION_LOG"
            all_bash=false
        fi
    done

    if $all_bash; then
        log_pass "All hooks are bash scripts"
    else
        log_fail "Some hooks are not bash scripts"
        return 1
    fi
}

# =============================================================================
# PRODUCTION READINESS
# =============================================================================

validate_production_readiness() {
    log_header "PRODUCTION READINESS VALIDATION"

    local ready=true

    log_test "Checking critical configurations"

    # Check voice ID
    if grep -q "ZF6FPAbjXT4488VcRRnw" "$PROJECT_ROOT/.claude/config/production-voice.json" 2>/dev/null; then
        echo "  ✓ Production voice ID correct" >> "$VALIDATION_LOG"
    else
        echo "  ✗ Production voice ID incorrect!" >> "$VALIDATION_LOG"
        ready=false
    fi

    # Check quality gates
    if [[ -f "$PROJECT_ROOT/.claude/config/quality_gates.yaml" ]]; then
        echo "  ✓ Quality gates configured" >> "$VALIDATION_LOG"
    else
        echo "  ✗ Quality gates missing!" >> "$VALIDATION_LOG"
        ready=false
    fi

    # Check cost tracking
    if [[ -f "$PROJECT_ROOT/.claude/hooks/simplified/post-tool-tracking.sh" ]]; then
        echo "  ✓ Cost tracking configured" >> "$VALIDATION_LOG"
    else
        echo "  ✗ Cost tracking missing!" >> "$VALIDATION_LOG"
        ready=false
    fi

    if $ready; then
        log_pass "System is production ready"
    else
        log_fail "System not production ready"
        return 1
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    echo "=== PRODUCTION HARDENING VALIDATION SUITE ===" | tee "$VALIDATION_LOG"
    echo "Date: $(date)" | tee -a "$VALIDATION_LOG"
    echo "Project: $PROJECT_ROOT" | tee -a "$VALIDATION_LOG"
    echo "" | tee -a "$VALIDATION_LOG"

    # Security Validation
    validate_api_keys || true
    validate_input_sanitization || true
    validate_rate_limiting || true
    validate_audit_logging || true

    # Reliability Validation
    validate_error_handling || true
    validate_resource_limits || true
    validate_health_checks || true

    # Operational Validation
    validate_monitoring || true
    validate_session_management || true

    # Claude Code Native Validation
    validate_claude_code_patterns || true

    # Production Readiness
    validate_production_readiness || true

    # Summary
    echo "" | tee -a "$VALIDATION_LOG"
    log_header "VALIDATION SUMMARY"
    echo "Tests Run: $TESTS_RUN" | tee -a "$VALIDATION_LOG"
    echo "Tests Passed: $TESTS_PASSED" | tee -a "$VALIDATION_LOG"
    echo "Tests Failed: $TESTS_FAILED" | tee -a "$VALIDATION_LOG"
    echo "Warnings: $WARNINGS" | tee -a "$VALIDATION_LOG"

    local pass_rate=$((TESTS_PASSED * 100 / TESTS_RUN))
    echo "Pass Rate: ${pass_rate}%" | tee -a "$VALIDATION_LOG"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All critical hardening measures validated!${NC}" | tee -a "$VALIDATION_LOG"
        echo -e "${GREEN}System is HARDENED and PRODUCTION READY${NC}" | tee -a "$VALIDATION_LOG"
        exit 0
    else
        echo -e "${RED}✗ Some hardening measures failed validation${NC}" | tee -a "$VALIDATION_LOG"
        echo -e "${YELLOW}Review the log for details: $VALIDATION_LOG${NC}"
        exit 1
    fi
}

# Run validation
main "$@"
