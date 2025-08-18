#!/bin/bash

# Quality Enforcement Hook - Claude 4 Best Practices Validation
# Validates dual explanations and semantic XML tagging in all content

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK_LOG_FILE="$PROJECT_ROOT/.claude/logs/quality-enforcement.log"

# Ensure log directory exists
mkdir -p "$(dirname "$HOOK_LOG_FILE")"

# Logging functions
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$HOOK_LOG_FILE"
}

log_warning() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $*" | tee -a "$HOOK_LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" | tee -a "$HOOK_LOG_FILE"
}

log_success() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $*" | tee -a "$HOOK_LOG_FILE"
}

# Quality validation functions
validate_dual_explanations() {
    local file="$1"
    local issues=0
    
    # Check for technical explanations
    local technical_count
    technical_count=$(grep -c "<technical>" "$file" 2>/dev/null || echo "0")
    technical_count=${technical_count//[^0-9]/}
    
    # Check for simple explanations
    local simple_count
    simple_count=$(grep -c "<simple>" "$file" 2>/dev/null || echo "0")
    simple_count=${simple_count//[^0-9]/}
    
    # Check for connection statements
    local connection_count
    connection_count=$(grep -c "<connection>" "$file" 2>/dev/null || echo "0")
    connection_count=${connection_count//[^0-9]/}
    
    # Claude 4 best practice: Technical concepts should have dual explanations
    if [[ $technical_count -gt 0 ]]; then
        if [[ $simple_count -eq 0 ]]; then
            log_warning "Missing <simple> explanations in $file (found $technical_count <technical> tags)"
            ((issues++))
        fi
        
        if [[ $connection_count -eq 0 ]]; then
            log_warning "Missing <connection> statements in $file (educational value unclear)"
            ((issues++))
        fi
    fi
    
    # Check for balanced explanation counts
    if [[ $technical_count -ne $simple_count && $technical_count -gt 0 && $simple_count -gt 0 ]]; then
        log_warning "Unbalanced explanations in $file: $technical_count technical vs $simple_count simple"
        ((issues++))
    fi
    
    return $issues
}

validate_semantic_tagging() {
    local file="$1"
    local issues=0
    
    # Claude 4 best practice: Consistent XML tag usage
    # Check for common semantic tags
    local semantic_tags=("instructions" "example" "formatting" "context" "requirements" "output")
    
    for tag in "${semantic_tags[@]}"; do
        local open_count
        open_count=$(grep -c "<$tag>" "$file" 2>/dev/null || echo "0")
        open_count=${open_count//[^0-9]/}  # Remove non-numeric characters
        
        local close_count
        close_count=$(grep -c "</$tag>" "$file" 2>/dev/null || echo "0")
        close_count=${close_count//[^0-9]/}  # Remove non-numeric characters
        
        if [[ ${open_count:-0} -ne ${close_count:-0} ]]; then
            log_error "Unmatched XML tags in $file: <$tag> opens=$open_count closes=$close_count"
            ((issues++))
        fi
    done
    
    # Check for nested tag issues (Claude 4 best practice: keep flat when possible)
    local deeply_nested
    deeply_nested=$(grep -c "<[^>]*><[^>]*><[^>]*>" "$file" 2>/dev/null || echo "0")
    deeply_nested=${deeply_nested//[^0-9]/}  # Remove non-numeric characters
    
    if [[ ${deeply_nested:-0} -gt 0 ]]; then
        log_warning "Deeply nested XML tags found in $file (Claude 4 prefers flat structure)"
        ((issues++))
    fi
    
    return $issues
}

validate_markdown_consistency() {
    local file="$1"
    local issues=0
    
    # Check if file mixes XML structure with markdown improperly
    if [[ "$file" == *.md ]]; then
        # Should not have XML document declarations in .md files
        if grep -q "<?xml" "$file"; then
            log_error "XML declaration found in Markdown file: $file"
            ((issues++))
        fi
        
        # Check for proper semantic tagging in markdown context
        local semantic_xml_count
        semantic_xml_count=$(grep -c "<technical>\|<simple>\|<connection>" "$file" 2>/dev/null || echo "0")
        semantic_xml_count=${semantic_xml_count//[^0-9]/}
        
        if [[ $semantic_xml_count -gt 0 ]]; then
            log_info "Semantic XML tagging found in $file (Claude 4 best practice)"
        fi
    fi
    
    return $issues
}

# Main quality enforcement function
enforce_quality() {
    local target_file="$1"
    local total_issues=0
    
    log_info "🔍 Quality enforcement check: $target_file"
    
    # Skip if file doesn't exist or is binary
    if [[ ! -f "$target_file" ]]; then
        log_warning "File not found: $target_file"
        return 1
    fi
    
    if ! file "$target_file" | grep -q "text"; then
        log_info "Skipping binary file: $target_file"
        return 0
    fi
    
    # Run quality validations
    local dual_issues=0
    local semantic_issues=0
    local markdown_issues=0
    
    # Only check documentation files for dual explanations
    if [[ "$target_file" =~ \.(md|xml)$ ]]; then
        validate_dual_explanations "$target_file"
        dual_issues=$?
        
        validate_semantic_tagging "$target_file"
        semantic_issues=$?
        
        validate_markdown_consistency "$target_file"
        markdown_issues=$?
    fi
    
    total_issues=$((dual_issues + semantic_issues + markdown_issues))
    
    if [[ $total_issues -eq 0 ]]; then
        log_success "✅ Quality check passed: $target_file"
        return 0
    else
        log_error "❌ Quality check failed: $target_file ($total_issues issues)"
        return $total_issues
    fi
}

# Hook entry points for different Claude Code events
run_pre_write_check() {
    local file_path="$1"
    
    log_info "🚀 Pre-write quality enforcement triggered for: $file_path"
    
    # For new files, we mainly check for proper structure planning
    if [[ ! -f "$file_path" ]]; then
        log_info "📝 New file will be created: $file_path"
        # Check if it's a documentation file that should have dual explanations
        if [[ "$file_path" =~ \.(md|xml)$ ]] && [[ "$file_path" =~ (guide|tutorial|overview|explanation) ]]; then
            log_info "📋 Educational content detected - will validate dual explanations post-write"
        fi
    fi
    
    return 0
}

run_post_write_check() {
    local file_path="$1"
    
    log_info "🔄 Post-write quality enforcement triggered for: $file_path"
    
    enforce_quality "$file_path"
    local result=$?
    
    if [[ $result -ne 0 ]]; then
        log_error "💥 Quality enforcement failed for $file_path"
        log_error "🔧 Please review and fix quality issues before proceeding"
        
        # Don't block the operation, just warn
        log_warning "⚠️  Continuing with warnings (hook in advisory mode)"
        return 0
    fi
    
    return 0
}

run_batch_quality_check() {
    local target_dir="${1:-.claude}"
    local total_files=0
    local total_issues=0
    
    log_info "🔍 Running batch quality check on: $target_dir"
    
    # Find all documentation files
    while IFS= read -r -d '' file; do
        ((total_files++))
        
        enforce_quality "$file"
        local file_issues=$?
        total_issues=$((total_issues + file_issues))
        
    done < <(find "$target_dir" -type f \( -name "*.md" -o -name "*.xml" \) -print0)
    
    log_info "📊 Batch quality check complete: $total_files files, $total_issues total issues"
    
    if [[ $total_issues -eq 0 ]]; then
        log_success "✅ All files passed quality checks!"
    else
        log_warning "⚠️  Found $total_issues quality issues across $total_files files"
    fi
    
    return $total_issues
}

# Main entry point
main() {
    local command="${1:-help}"
    local target="${2:-}"
    
    case "$command" in
        pre-write)
            run_pre_write_check "$target"
            ;;
        post-write)
            run_post_write_check "$target"
            ;;
        batch)
            run_batch_quality_check "$target"
            ;;
        enforce)
            enforce_quality "$target"
            ;;
        help|*)
            echo "Quality Enforcement Hook - Claude 4 Best Practices"
            echo ""
            echo "Usage: $0 <command> [target]"
            echo ""
            echo "Commands:"
            echo "  pre-write <file>    - Pre-write quality check"
            echo "  post-write <file>   - Post-write quality validation"
            echo "  batch [directory]   - Batch quality check (default: .claude)"
            echo "  enforce <file>      - Single file quality enforcement"
            echo "  help               - Show this help"
            echo ""
            echo "Quality Checks:"
            echo "  ✓ Dual explanations (technical + simple + connection)"
            echo "  ✓ Semantic XML tagging (Claude 4 best practices)"
            echo "  ✓ Markdown consistency"
            echo "  ✓ Tag balance and nesting"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"