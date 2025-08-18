#!/bin/bash
# Claude Code Builder Quality Checks
# Replacement for Level-1-Dev quality hooks using new optimized patterns

# Configuration
PATTERNS_DIR="/Users/smenssink/Documents/GitHub/claude-code-builder/repository-structure/patterns"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Verify patterns directory exists
if [[ ! -d "$PATTERNS_DIR" ]]; then
    echo "❌ ERROR: Claude Code Builder patterns not found at: $PATTERNS_DIR"
    echo "🔧 Make sure claude-code-builder repository is available"
    exit 1
fi

# Load claude-code-builder patterns
source "$PATTERNS_DIR/logging/simple-logging.sh"
source "$PATTERNS_DIR/quality-gates/quality-check.sh"
source "$PATTERNS_DIR/security/security-basics.sh"
source "$PATTERNS_DIR/error-handling/simple-error-handling.sh"

# Set up error handling
set -e
trap 'handle_error $LINENO "Quality check failed"' ERR

log_info "Running Claude Code Builder quality checks..."

# Initialize quality check results
quality_passed=true

# Run security checks
log_info "🔒 Running security checks..."
if ! basic_security_scan .; then
    log_error "Security scan failed"
    quality_passed=false
fi

# Check for secrets in modified files
if has_security_issues .; then
    log_error "Security issues detected"
    quality_passed=false
fi

# Run quality checks on relevant files
log_info "✨ Running code quality checks..."
if ! run_quality_checks .; then
    log_error "Quality checks failed"
    quality_passed=false
fi

# Final result
if [[ "$quality_passed" == "true" ]]; then
    log_success "All Claude Code Builder quality checks passed! ✅"
    exit 0
else
    log_error "Quality checks failed - please fix issues before committing"
    exit 1
fi