#!/bin/bash
# Production Readiness Validation Hook
# Ensures system meets production deployment standards before commit

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
VIOLATIONS=0
WARNINGS=0
CHECKS_PASSED=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((VIOLATIONS++))
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    ((CHECKS_PASSED++))
}

# Function to check database configuration
check_database_configuration() {
    log_info "🗄️ Checking database configuration..."

    if [[ -f "podcast_production/config/database_config.py" ]]; then
        # Check for PostgreSQL configuration
        if ! grep -q "PostgresSaver\|postgresql" podcast_production/config/database_config.py; then
            log_error "Database configuration missing PostgreSQL support"
            return 1
        fi

        # Check for SSL configuration
        if ! grep -q "ssl.*require\|SSL" podcast_production/config/database_config.py; then
            log_warning "SSL configuration may be missing for production database"
        fi

        # Check for connection pooling
        if ! grep -q "max_connections\|pool" podcast_production/config/database_config.py; then
            log_warning "Connection pooling configuration may be missing"
        fi

        log_success "Database configuration validation passed"
    else
        log_warning "Database configuration file not found"
    fi
}

# Function to check retry logic and resilience
check_retry_logic() {
    log_info "🔄 Checking retry logic and resilience..."

    if [[ -f "podcast_production/core/retry_handler.py" ]]; then
        # Check for circuit breaker pattern
        if ! grep -q "circuit.*breaker\|CircuitBreaker\|failure_threshold" podcast_production/core/retry_handler.py; then
            log_warning "Circuit breaker pattern may be missing"
        fi

        # Check for exponential backoff
        if ! grep -q "exponential.*backoff\|backoff_multiplier" podcast_production/core/retry_handler.py; then
            log_warning "Exponential backoff may be missing"
        fi

        # Check for comprehensive error handling
        if ! grep -q "except.*Exception\|retry.*on.*status.*codes" podcast_production/core/retry_handler.py; then
            log_warning "Comprehensive error handling may be missing"
        fi

        log_success "Retry logic validation passed"
    else
        log_error "Retry handler not found - required for production resilience"
        return 1
    fi
}

# Function to check checkpoint system
check_checkpoint_system() {
    log_info "💾 Checking checkpoint system..."

    if [[ -f "podcast_production/core/checkpoint_manager.py" ]]; then
        # Check for workflow resumption capability
        if ! grep -q "resume.*workflow\|resumable.*workflows" podcast_production/core/checkpoint_manager.py; then
            log_error "Workflow resumption capability missing"
            return 1
        fi

        # Check for checkpoint metadata
        if ! grep -q "CheckpointMetadata\|metadata" podcast_production/core/checkpoint_manager.py; then
            log_warning "Checkpoint metadata handling may be incomplete"
        fi

        log_success "Checkpoint system validation passed"
    else
        log_error "Checkpoint manager not found - required for production reliability"
        return 1
    fi
}

# Function to check observability
check_observability() {
    log_info "📊 Checking observability and monitoring..."

    # Check for Langfuse integration
    langfuse_integration=$(find podcast_production/ -name "*.py" -exec grep -l "langfuse\|Langfuse" {} \; 2>/dev/null || true)

    if [[ -z "$langfuse_integration" ]]; then
        log_warning "No Langfuse observability integration found"
    else
        # Check for disabled observability blocks
        disabled_blocks=$(grep -r "if False.*langfuse" podcast_production/ --include="*.py" 2>/dev/null || true)
        if [[ -n "$disabled_blocks" ]]; then
            log_error "Disabled observability blocks found - must be enabled for production"
            return 1
        fi
        log_success "Observability integration validation passed"
    fi

    # Check for logging configuration
    if [[ -f "podcast_production/core/logging_config.py" ]]; then
        if ! grep -q "logging.*config\|log.*level" podcast_production/core/logging_config.py; then
            log_warning "Logging configuration may be incomplete"
        fi
    else
        log_warning "Logging configuration not found"
    fi
}

# Function to check security compliance
check_security_compliance() {
    log_info "🔒 Checking security compliance..."

    # Check for hardcoded API keys (actual keys, not variable names)
    hardcoded_keys=$(grep -r -E "(api.*key.*=.*['\"][a-zA-Z0-9]{20,}['\"]|secret.*=.*['\"][a-zA-Z0-9]{10,}['\"])" podcast_production/ \
        --include="*.py" \
        --exclude="*test*.py" \
        --exclude="*conftest*.py" \
        2>/dev/null | grep -v "pragma: allowlist secret" || true)

    if [[ -n "$hardcoded_keys" ]]; then
        log_error "Hardcoded API keys or secrets detected:"
        echo "$hardcoded_keys"
        return 1
    fi

    # Check for environment variable usage
    env_var_usage=$(grep -r "os\.getenv\|getenv" podcast_production/ \
        --include="*.py" 2>/dev/null | wc -l)

    if [[ $env_var_usage -eq 0 ]]; then
        log_warning "No environment variable usage detected - check configuration management"
    fi

    # Check for input validation
    input_validation=$(grep -r -E "(validate.*input|sanitize.*input|\.strip\(\)|\.lower\(\))" podcast_production/ \
        --include="*.py" 2>/dev/null | wc -l)

    if [[ $input_validation -eq 0 ]]; then
        log_warning "Limited input validation detected"
    fi

    log_success "Security compliance check completed"
}

# Function to check cost controls
check_cost_controls() {
    log_info "💰 Checking cost controls..."

    # Check for budget enforcement
    budget_enforcement=$(grep -r "budget.*limit\|BudgetExceededException\|over.*budget" podcast_production/ \
        --include="*.py" 2>/dev/null || true)

    if [[ -z "$budget_enforcement" ]]; then
        log_error "Budget enforcement mechanisms not found"
        return 1
    fi

    # Check for cost tracking integration
    cost_tracking=$(grep -r "CostTracker\|track.*cost\|cost.*data" podcast_production/ \
        --include="*.py" 2>/dev/null || true)

    if [[ -z "$cost_tracking" ]]; then
        log_error "Cost tracking integration not found"
        return 1
    fi

    # Check for model recommendations based on budget
    model_recommendations=$(grep -r "model.*recommendation\|cheaper.*model\|budget.*remaining" podcast_production/ \
        --include="*.py" 2>/dev/null || true)

    if [[ -z "$model_recommendations" ]]; then
        log_warning "Dynamic model recommendations based on budget not found"
    fi

    log_success "Cost controls validation passed"
}

# Function to check error handling
check_error_handling() {
    log_info "🚨 Checking error handling..."

    # Check for comprehensive exception handling
    python_files=$(find podcast_production/ -name "*.py" 2>/dev/null || true)
    files_without_error_handling=0

    if [[ -n "$python_files" ]]; then
        for file in $python_files; do
            [[ -f "$file" ]] || continue
            [[ -s "$file" ]] || continue

            # Check if file has try-catch blocks
            if ! grep -q "try:\|except.*:" "$file"; then
                ((files_without_error_handling++))
            fi
        done

        total_files=$(echo "$python_files" | wc -l)
        if [[ $files_without_error_handling -gt $((total_files / 2)) ]]; then
            log_warning "Many files lack error handling (${files_without_error_handling}/${total_files})"
        fi
    fi

    # Check for specific error types
    specific_errors=$(grep -r -E "(BudgetExceededException|APIException|ValidationError)" podcast_production/ \
        --include="*.py" 2>/dev/null || true)

    if [[ -n "$specific_errors" ]]; then
        log_success "Specific error types found for better error handling"
    else
        log_warning "Consider adding specific exception types for better error handling"
    fi

    log_success "Error handling check completed"
}

# Function to check deployment readiness
check_deployment_readiness() {
    log_info "🚀 Checking deployment readiness..."

    # Check for Docker configuration
    if [[ -f "Dockerfile.production" ]]; then
        if ! grep -q "FROM.*python\|WORKDIR\|COPY.*requirements" Dockerfile.production; then
            log_warning "Docker configuration may be incomplete"
        else
            log_success "Docker production configuration found"
        fi
    else
        log_warning "Production Dockerfile not found"
    fi

    # Check for requirements.txt
    if [[ -f "requirements.txt" ]]; then
        # Check for production dependencies
        prod_deps=("psycopg2" "redis" "prometheus" "gunicorn")
        missing_deps=()

        for dep in "${prod_deps[@]}"; do
            if ! grep -q "$dep" requirements.txt; then
                missing_deps+=("$dep")
            fi
        done

        if [[ ${#missing_deps[@]} -gt 0 ]]; then
            log_warning "Missing production dependencies: ${missing_deps[*]}"
        fi
    else
        log_warning "requirements.txt not found"
    fi

    # Check for environment configuration
    if [[ -f ".env.example" ]]; then
        required_vars=("POSTGRES_URL" "ELEVENLABS_API_KEY" "PRODUCTION_VOICE_ID" "ENVIRONMENT")
        missing_vars=()

        for var in "${required_vars[@]}"; do
            if ! grep -q "^$var=" .env.example; then
                missing_vars+=("$var")
            fi
        done

        if [[ ${#missing_vars[@]} -gt 0 ]]; then
            log_warning "Missing environment variables in .env.example: ${missing_vars[*]}"
        fi
    else
        log_warning ".env.example not found"
    fi

    log_success "Deployment readiness check completed"
}

# Main execution
main() {
    echo "🏭 Production Readiness Validation Check"
    echo "========================================"

    # Change to repository root
    cd "$(git rev-parse --show-toplevel)" 2>/dev/null || {
        log_error "Not in a git repository"
        exit 1
    }

    # Run all production readiness checks
    check_database_configuration || true
    check_retry_logic || true
    check_checkpoint_system || true
    check_observability || true
    check_security_compliance || true
    check_cost_controls || true
    check_error_handling || true
    check_deployment_readiness || true

    # Summary
    echo ""
    echo "📊 Production Readiness Summary"
    echo "=============================="
    echo "✅ Checks Passed: $CHECKS_PASSED"
    echo "⚠️  Warnings: $WARNINGS"
    echo "❌ Critical Issues: $VIOLATIONS"

    if [[ $VIOLATIONS -eq 0 ]]; then
        if [[ $WARNINGS -le 3 ]]; then
            log_success "🚀 System ready for production deployment!"
            exit 0
        else
            log_warning "⚠️ System has warnings but can proceed to production"
            log_warning "Consider addressing warnings for optimal production experience"
            exit 0
        fi
    else
        log_error "❌ System not ready for production deployment"
        log_error "Address critical issues before proceeding"
        exit 1
    fi
}

# Execute main function
main "$@"
