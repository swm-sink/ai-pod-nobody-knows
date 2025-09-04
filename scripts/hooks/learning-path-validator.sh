#!/bin/bash

# Learning Path Validator - WALK→CRAWL→RUN Progression Validation
# Ensures learning path integrity and optimal educational progression

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VALIDATION_LOG="$PROJECT_ROOT/.claude/logs/learning-path-validation.log"

# Ensure log directory exists
mkdir -p "$(dirname "$VALIDATION_LOG")"

# Logging functions
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$VALIDATION_LOG"
}

log_warning() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $*" | tee -a "$VALIDATION_LOG"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" | tee -a "$VALIDATION_LOG"
}

log_success() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $*" | tee -a "$VALIDATION_LOG"
}

# Validation functions
validate_reference_integrity() {
    local issues=0

    log_info "🔗 Validating @ reference integrity"

    # Check CLAUDE.md references - more precise regex for actual file references
    local claude_refs
    claude_refs=$(grep -o '@[a-zA-Z0-9_/-]*\.md' "$PROJECT_ROOT/CLAUDE.md" || true)

    for ref in $claude_refs; do
        # Convert @ reference to actual file path
        local file_path="$PROJECT_ROOT/${ref#@}"

        if [[ ! -f "$file_path" ]]; then
            log_error "Broken reference in CLAUDE.md: $ref → $file_path (file not found)"
            ((issues++))
        else
            log_info "✅ Valid reference: $ref"
        fi
    done

    return $issues
}

validate_phase_progression() {
    local issues=0

    log_info "📚 Validating WALK→CRAWL→RUN phase progression"

    # Check WALK phase definition
    if ! grep -q "WALK.*Learn for FREE" "$PROJECT_ROOT/CLAUDE.md"; then
        log_error "WALK phase not properly defined in CLAUDE.md"
        ((issues++))
    fi

    # Check phase progression files exist
    local phase_file="$PROJECT_ROOT/.claude/context/02_walk_crawl_run_phases.md"
    if [[ ! -f "$phase_file" ]]; then
        log_error "Phase progression file missing: $phase_file"
        ((issues++))
    fi

    # Validate cost progression ($0 → $20-50 → $50-100/month)
    local foundation_context="$PROJECT_ROOT/.claude/context/project_foundation.md"
    if [[ -f "$foundation_context" ]]; then
        if ! grep -q "WALK.*\$0.*CRAWL.*\$20-50.*RUN.*\$50-100" "$foundation_context"; then
            log_warning "Cost progression pattern not found in expected format"
            ((issues++))
        fi
    fi

    return $issues
}

validate_educational_scaffolding() {
    local issues=0

    log_info "🎓 Validating educational scaffolding"

    # Check foundation learning files exist
    local foundation_files=(
        "01_project_overview.md"
        "02_walk_crawl_run_phases.md"
        "04_no_api_keys_activities.md"
        "05_learning_milestones.md"
    )

    for file in "${foundation_files[@]}"; do
        local full_path="$PROJECT_ROOT/.claude/context/$file"
        if [[ ! -f "$full_path" ]]; then
            log_error "Foundation learning file missing: $file"
            ((issues++))
        else
            # Check for dual explanations in educational files
            if ! grep -q "<technical>" "$full_path" || ! grep -q "<simple>" "$full_path"; then
                log_warning "Educational file missing dual explanations: $file"
                ((issues++))
            fi
        fi
    done

    return $issues
}

validate_learning_objectives() {
    local issues=0

    log_info "🎯 Validating learning objectives alignment"

    # Check current phase consistency
    local current_phase
    current_phase=$(grep -A 5 "<current-phase>" "$PROJECT_ROOT/CLAUDE.md" | grep "<phase>" | sed 's/.*<phase>\(.*\)<\/phase>.*/\1/' || echo "")

    if [[ "$current_phase" != "WALK" ]]; then
        log_warning "Current phase is '$current_phase' - validate if this is intentional"
    fi

    # Check next-action file exists
    local next_action
    next_action=$(grep -A 5 "<current-phase>" "$PROJECT_ROOT/CLAUDE.md" | grep "<next-action>" | sed 's/.*@\(.*\)<\/next-action>.*/\1/' || echo "")

    if [[ -n "$next_action" ]]; then
        local next_action_file="$PROJECT_ROOT/.claude/context/$next_action"
        if [[ ! -f "$next_action_file" ]]; then
            log_error "Next action file missing: $next_action_file"
            ((issues++))
        fi
    fi

    return $issues
}

validate_navigation_consistency() {
    local issues=0

    log_info "🧭 Validating navigation consistency"

    # Check NAVIGATION.md files exist and are consistent
    local nav_files=(
        ".claude/NAVIGATION.md"
        ".claude/NAVIGATION_SIMPLIFIED.md"
        ".claude/docs/NAVIGATION_INDEX.md"
    )

    for nav_file in "${nav_files[@]}"; do
        local full_path="$PROJECT_ROOT/$nav_file"
        if [[ ! -f "$full_path" ]]; then
            log_warning "Navigation file missing: $nav_file"
            ((issues++))
        fi
    done

    return $issues
}

# Main validation function
run_learning_path_validation() {
    local total_issues=0

    log_info "🚀 Starting comprehensive learning path validation"

    # Run all validation functions
    validate_reference_integrity
    local ref_issues=$?
    total_issues=$((total_issues + ref_issues))

    validate_phase_progression
    local phase_issues=$?
    total_issues=$((total_issues + phase_issues))

    validate_educational_scaffolding
    local scaffolding_issues=$?
    total_issues=$((total_issues + scaffolding_issues))

    validate_learning_objectives
    local objectives_issues=$?
    total_issues=$((total_issues + objectives_issues))

    validate_navigation_consistency
    local nav_issues=$?
    total_issues=$((total_issues + nav_issues))

    # Report results
    log_info "📊 Learning path validation complete"
    log_info "Issues found: Reference($ref_issues) Phase($phase_issues) Scaffolding($scaffolding_issues) Objectives($objectives_issues) Navigation($nav_issues)"

    if [[ $total_issues -eq 0 ]]; then
        log_success "✅ Learning path validation PASSED - All systems optimal"
    else
        log_error "❌ Learning path validation FAILED - $total_issues total issues"
    fi

    return $total_issues
}

# Integration with quality enforcement
integrate_with_quality_system() {
    log_info "🔗 Integrating with quality enforcement system"

    # Run quality checks on key learning files
    local key_files=(
        "CLAUDE.md"
        ".claude/context/project_foundation.md"
        ".claude/context/02_walk_crawl_run_phases.md"
    )

    for file in "${key_files[@]}"; do
        local full_path="$PROJECT_ROOT/$file"
        if [[ -f "$full_path" ]]; then
            log_info "Running quality check on learning file: $file"
            "$SCRIPT_DIR/quality-enforcement.sh" enforce "$full_path" || true
        fi
    done
}

# Main entry point
main() {
    local command="${1:-validate}"

    case "$command" in
        validate)
            run_learning_path_validation
            ;;
        integrate)
            integrate_with_quality_system
            ;;
        full)
            run_learning_path_validation
            integrate_with_quality_system
            ;;
        help|*)
            echo "Learning Path Validator - WALK→CRAWL→RUN Progression Validation"
            echo ""
            echo "Usage: $0 <command>"
            echo ""
            echo "Commands:"
            echo "  validate    - Run comprehensive learning path validation"
            echo "  integrate   - Integrate with quality enforcement system"
            echo "  full        - Run both validation and integration"
            echo "  help        - Show this help"
            echo ""
            echo "Validation Checks:"
            echo "  ✓ Reference integrity (@ links work correctly)"
            echo "  ✓ Phase progression (WALK→CRAWL→RUN structure)"
            echo "  ✓ Educational scaffolding (learning builds properly)"
            echo "  ✓ Learning objectives (phase alignment)"
            echo "  ✓ Navigation consistency (user pathfinding)"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
exit $?
