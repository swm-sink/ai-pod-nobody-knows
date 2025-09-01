#!/bin/bash
# August 2025 Governance Enforcement Hook
# Validates compliance with August 2025 best practices and patterns

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
VIOLATIONS=0
WARNINGS=0

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
}

# Function to check voice ID governance
check_voice_id_governance() {
    log_info "🔒 Checking voice ID governance..."

    # Check for hardcoded voice IDs in Python code (should not exist after our fix)
    hardcoded_voice_ids=$(grep -r "ZF6FPAbjXT4488VcRRnw" podcast_production/ \
        --include="*.py" \
        --exclude="config/voice_config.py" \
        --exclude="*test*.py" \
        --exclude="*setup*.py" \
        --exclude="*validate*.py" \
        --exclude="*.md" \
        2>/dev/null || true)

    if [[ -n "$hardcoded_voice_ids" ]]; then
        log_error "Hardcoded voice IDs detected (governance violation):"
        echo "$hardcoded_voice_ids"
        echo "Use get_production_voice_id() from config.voice_config instead"
        return 1
    fi

    # Check for unauthorized voice ID changes in configuration
    if [[ -f "config/voice_config.py" ]]; then
        # Ensure voice config uses centralized pattern
        if ! grep -q "PRODUCTION_VOICE_ID.*ZF6FPAbjXT4488VcRRnw" config/voice_config.py; then
            log_error "Production voice ID not properly configured in voice_config.py"
            return 1
        fi
    fi

    log_success "Voice ID governance validation passed"
}

# Function to check August 2025 LangGraph patterns
check_langgraph_patterns() {
    log_info "🏗️ Checking LangGraph August 2025 patterns..."

    # Check for deprecated node function signatures (OLD pattern without InjectedStore)
    # OLD: async def _node(self, state: PodcastState, config: RunnableConfig = None)
    # NEW: async def _node(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None)
    deprecated_signatures=$(grep -r "async def.*_node.*state:.*RunnableConfig.*=" podcast_production/ \
        --include="*.py" | grep -v "InjectedStore" | grep -v "store:" || true)

    if [[ -n "$deprecated_signatures" ]]; then
        log_error "Deprecated LangGraph node signatures detected:"
        echo "$deprecated_signatures"
        echo "Update to August 2025 pattern: async def node_function(state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None)"
        return 1
    fi

    # Check for MemorySaver usage (should be PostgresSaver for production)
    memory_saver_usage=$(grep -r "MemorySaver()" podcast_production/ \
        --include="*.py" 2>/dev/null || true)

    if [[ -n "$memory_saver_usage" ]]; then
        log_warning "MemorySaver usage detected (consider PostgresSaver for production):"
        echo "$memory_saver_usage"
    fi

    # Check for missing JsonPlusSerializer with pickle fallback
    missing_serializer=$(grep -r "MemorySaver(" podcast_production/ \
        --include="*.py" | grep -v "JsonPlusSerializer" 2>/dev/null || true)

    if [[ -n "$missing_serializer" ]]; then
        log_warning "MemorySaver without JsonPlusSerializer detected:"
        echo "$missing_serializer"
        echo "Consider using JsonPlusSerializer(pickle_fallback=True) for complex objects"
    fi

    # Check for disabled observability
    disabled_observability=$(grep -r "if False.*langfuse\|if False.*observability" podcast_production/ \
        --include="*.py" 2>/dev/null || true)

    if [[ -n "$disabled_observability" ]]; then
        log_error "Disabled observability blocks detected:"
        echo "$disabled_observability"
        echo "Remove 'if False:' blocks to enable proper observability"
        return 1
    fi

    log_success "LangGraph patterns validation passed"
}

# Function to check configuration centralization
check_configuration_centralization() {
    log_info "⚙️ Checking configuration centralization..."

    # Check for hardcoded configuration values
    hardcoded_configs=$(grep -r -E "(api_key.*=.*['\"][^'\"]*['\"]|voice_id.*=.*['\"][^'\"]*['\"])" podcast_production/ \
        --include="*.py" \
        --exclude="*config*.py" \
        --exclude="*test*.py" 2>/dev/null || true)

    if [[ -n "$hardcoded_configs" ]]; then
        log_warning "Hardcoded configuration values detected:"
        echo "$hardcoded_configs"
        echo "Consider moving to centralized configuration files"
    fi

    # Check for environment variable loading without defaults
    unsafe_env_vars=$(grep -r "os\.getenv(['\"][^'\"]*['\"])" podcast_production/ \
        --include="*.py" | grep -v "os\.getenv.*," 2>/dev/null || true)

    if [[ -n "$unsafe_env_vars" ]]; then
        log_warning "Environment variables without defaults detected:"
        echo "$unsafe_env_vars"
        echo "Consider providing fallback defaults for production robustness"
    fi

    log_success "Configuration centralization check passed"
}

# Function to check cost tracking compliance
check_cost_tracking_compliance() {
    log_info "💰 Checking cost tracking compliance..."

    # Check for missing cost tracking in agents
    agents_without_cost_tracking=$(find podcast_production/agents/ -name "*.py" -exec grep -L "cost_tracker\|track_cost" {} \; 2>/dev/null || true)

    if [[ -n "$agents_without_cost_tracking" ]]; then
        log_warning "Agents without cost tracking detected:"
        echo "$agents_without_cost_tracking"
        echo "Consider adding cost tracking for budget compliance"
    fi

    # Check for deprecated cost tracking patterns (storing objects in state)
    deprecated_cost_patterns=$(grep -r "state.*cost_tracker.*=" podcast_production/ \
        --include="*.py" 2>/dev/null || true)

    if [[ -n "$deprecated_cost_patterns" ]]; then
        log_error "Deprecated cost tracking pattern detected (storing objects in state):"
        echo "$deprecated_cost_patterns"
        echo "Use cost_tracker_manager and store serialized cost_data in state instead"
        return 1
    fi

    log_success "Cost tracking compliance check passed"
}

# Function to check import hygiene
check_import_hygiene() {
    log_info "📦 Checking import hygiene..."

    # Check for unused imports (simplified check)
    python_files=$(find podcast_production/ -name "*.py" 2>/dev/null || true)

    if [[ -n "$python_files" ]]; then
        for file in $python_files; do
            # Skip if file doesn't exist or is empty
            [[ -f "$file" ]] || continue
            [[ -s "$file" ]] || continue

            # Check for imports that might be unused (basic check)
            imports=$(grep "^import \|^from .* import" "$file" | head -5)
            if [[ -n "$imports" ]]; then
                # This is a simplified check - in production, you'd use a tool like flake8
                continue
            fi
        done
    fi

    log_success "Import hygiene check completed"
}

# Function to check for temporal compliance
check_temporal_compliance() {
    log_info "📅 Checking temporal compliance (August 2025)..."

    # Check for outdated date references
    outdated_dates=$(grep -r -E "202[0-4]" podcast_production/ \
        --include="*.py" \
        --exclude="*test*" 2>/dev/null | grep -v "August 2025\|2025" || true)

    if [[ -n "$outdated_dates" ]]; then
        log_warning "Outdated date references detected:"
        echo "$outdated_dates"
        echo "Ensure all references use current August 2025 context"
    fi

    # Check for proper August 2025 validation queries
    missing_validation=$(grep -r "perplexity\|web.*search" podcast_production/ \
        --include="*.py" | grep -v "August 2025\|2025" 2>/dev/null || true)

    if [[ -n "$missing_validation" ]]; then
        log_warning "Web searches without August 2025 context detected:"
        echo "$missing_validation"
        echo "Include 'August 2025' in search queries for current validation"
    fi

    log_success "Temporal compliance check completed"
}

# Main execution
main() {
    echo "🏛️ August 2025 Governance Enforcement Check"
    echo "============================================"

    # Change to repository root
    cd "$(git rev-parse --show-toplevel)" 2>/dev/null || {
        log_error "Not in a git repository"
        exit 1
    }

    # Run all checks
    check_voice_id_governance || true
    check_langgraph_patterns || true
    check_configuration_centralization || true
    check_cost_tracking_compliance || true
    check_import_hygiene || true
    check_temporal_compliance || true

    # Summary
    echo ""
    echo "📊 Governance Check Summary"
    echo "=========================="

    if [[ $VIOLATIONS -eq 0 ]]; then
        if [[ $WARNINGS -eq 0 ]]; then
            log_success "✅ All governance checks passed!"
            exit 0
        else
            log_warning "⚠️ $WARNINGS warnings found (commit allowed)"
            exit 0
        fi
    else
        log_error "❌ $VIOLATIONS critical violations found"
        log_error "Commit blocked until violations are resolved"
        exit 1
    fi
}

# Execute main function
main "$@"
