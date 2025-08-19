#!/bin/bash

# Session Validation Hook - Data Integrity and Checkpoint Management
# Validates session data, checkpoint integrity, and prevents data corruption

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SESSION_LOG_FILE="$PROJECT_ROOT/.claude/logs/session-validation.log"
SESSIONS_DIR="$PROJECT_ROOT/.claude/level-2-production/sessions"
BACKUP_DIR="$PROJECT_ROOT/.claude/backups/sessions"

# Ensure directories exist
mkdir -p "$(dirname "$SESSION_LOG_FILE")" "$SESSIONS_DIR" "$BACKUP_DIR"

# Logging functions
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$SESSION_LOG_FILE"
}

log_warning() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $*" | tee -a "$SESSION_LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" | tee -a "$SESSION_LOG_FILE"
}

log_success() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $*" | tee -a "$SESSION_LOG_FILE"
}

# Validation functions
validate_json_format() {
    local file="$1"

    if ! jq . "$file" >/dev/null 2>&1; then
        log_error "Invalid JSON format in: $file"
        return 1
    fi

    return 0
}

validate_session_structure() {
    local session_file="$1"
    local issues=0

    # Required session fields
    local required_fields=("session_id" "status" "timestamp")

    for field in "${required_fields[@]}"; do
        if ! jq -e ".${field}" "$session_file" >/dev/null 2>&1; then
            log_warning "Missing required field '$field' in: $session_file"
            ((issues++))
        fi
    done

    # Validate session_id format (should be ep_XXX_YYYYMMDD_*)
    local session_id
    session_id=$(jq -r '.session_id' "$session_file" 2>/dev/null || echo "")

    if [[ ! "$session_id" =~ ^ep_[0-9]+_[0-9]{8}_.+ ]]; then
        log_warning "Invalid session_id format in $session_file: $session_id"
        ((issues++))
    fi

    # Validate timestamp format
    local timestamp
    timestamp=$(jq -r '.timestamp' "$session_file" 2>/dev/null || echo "")

    if [[ ! "$timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
        log_warning "Invalid timestamp format in $session_file: $timestamp"
        ((issues++))
    fi

    return $issues
}

validate_checkpoint_integrity() {
    local session_dir="$1"
    local issues=0

    # Check for checkpoint consistency
    local checkpoints
    checkpoints=$(find "$session_dir" -name "*_complete.json" 2>/dev/null || true)

    for checkpoint in $checkpoints; do
        if [[ -f "$checkpoint" ]]; then
            # Validate JSON format
            if ! validate_json_format "$checkpoint"; then
                ((issues++))
                continue
            fi

            # Check checkpoint has required fields
            local checkpoint_type
            checkpoint_type=$(jq -r '.checkpoint_type' "$checkpoint" 2>/dev/null || echo "")

            if [[ -z "$checkpoint_type" ]]; then
                log_warning "Missing checkpoint_type in: $checkpoint"
                ((issues++))
            fi

            # Validate cost tracking in checkpoint
            local cost_invested
            cost_invested=$(jq -r '.cost_invested' "$checkpoint" 2>/dev/null || echo "")

            if [[ -n "$cost_invested" && ! "$cost_invested" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                log_warning "Invalid cost_invested format in $checkpoint: $cost_invested"
                ((issues++))
            fi
        fi
    done

    return $issues
}

validate_file_references() {
    local session_dir="$1"
    local issues=0

    # Find all JSON files and check file references
    local json_files
    json_files=$(find "$session_dir" -name "*.json" 2>/dev/null || true)

    for json_file in $json_files; do
        if [[ -f "$json_file" ]]; then
            # Check for file path references
            local file_paths
            file_paths=$(jq -r '.. | objects | to_entries[] | select(.key | contains("file") or contains("path")) | .value' "$json_file" 2>/dev/null | grep -E '^/' || true)

            for file_path in $file_paths; do
                if [[ -n "$file_path" && ! -f "$file_path" ]]; then
                    log_warning "Referenced file not found: $file_path (from $json_file)"
                    ((issues++))
                fi
            done
        fi
    done

    return $issues
}

# Backup and recovery functions
create_session_backup() {
    local session_dir="$1"
    local session_name
    session_name=$(basename "$session_dir")

    local backup_file="$BACKUP_DIR/${session_name}_$(date +%Y%m%d_%H%M%S).tar.gz"

    if [[ -d "$session_dir" ]]; then
        tar -czf "$backup_file" -C "$(dirname "$session_dir")" "$session_name" 2>/dev/null

        if [[ -f "$backup_file" ]]; then
            log_success "Session backup created: $backup_file"
            echo "$backup_file"
            return 0
        else
            log_error "Failed to create session backup: $backup_file"
            return 1
        fi
    else
        log_warning "Session directory not found for backup: $session_dir"
        return 1
    fi
}

restore_session_backup() {
    local backup_file="$1"
    local restore_dir="${2:-$SESSIONS_DIR}"

    if [[ -f "$backup_file" ]]; then
        tar -xzf "$backup_file" -C "$restore_dir" 2>/dev/null

        if [[ $? -eq 0 ]]; then
            log_success "Session restored from backup: $backup_file"
            return 0
        else
            log_error "Failed to restore session from backup: $backup_file"
            return 1
        fi
    else
        log_error "Backup file not found: $backup_file"
        return 1
    fi
}

# Main validation functions
validate_single_session() {
    local session_dir="$1"
    local total_issues=0

    log_info "🔍 Validating session: $session_dir"

    if [[ ! -d "$session_dir" ]]; then
        log_error "Session directory not found: $session_dir"
        return 1
    fi

    # Find main session file
    local session_file
    session_file=$(find "$session_dir" -name "session_*.json" | head -1)

    if [[ -z "$session_file" ]]; then
        log_warning "No session file found in: $session_dir"
        ((total_issues++))
    else
        # Validate JSON format
        validate_json_format "$session_file"
        local json_issues=$?
        total_issues=$((total_issues + json_issues))

        # Validate session structure
        if [[ $json_issues -eq 0 ]]; then
            validate_session_structure "$session_file"
            local structure_issues=$?
            total_issues=$((total_issues + structure_issues))
        fi
    fi

    # Validate checkpoints
    validate_checkpoint_integrity "$session_dir"
    local checkpoint_issues=$?
    total_issues=$((total_issues + checkpoint_issues))

    # Validate file references
    validate_file_references "$session_dir"
    local reference_issues=$?
    total_issues=$((total_issues + reference_issues))

    if [[ $total_issues -eq 0 ]]; then
        log_success "✅ Session validation passed: $session_dir"
    else
        log_error "❌ Session validation failed: $session_dir ($total_issues issues)"
    fi

    return $total_issues
}

validate_all_sessions() {
    local total_sessions=0
    local total_issues=0

    log_info "🔍 Running batch session validation"

    if [[ ! -d "$SESSIONS_DIR" ]]; then
        log_warning "Sessions directory not found: $SESSIONS_DIR"
        return 1
    fi

    # Find all session directories
    for session_dir in "$SESSIONS_DIR"/*/; do
        if [[ -d "$session_dir" ]]; then
            ((total_sessions++))

            validate_single_session "$session_dir"
            local session_issues=$?
            total_issues=$((total_issues + session_issues))
        fi
    done

    log_info "📊 Batch validation complete: $total_sessions sessions, $total_issues total issues"

    if [[ $total_issues -eq 0 ]]; then
        log_success "✅ All sessions passed validation!"
    else
        log_warning "⚠️  Found $total_issues issues across $total_sessions sessions"
    fi

    return $total_issues
}

# Hook entry points
pre_session_operation() {
    local session_dir="$1"
    local operation="${2:-unknown}"

    log_info "🚀 Pre-session operation hook: $operation on $session_dir"

    # Create backup before any operation
    if [[ -d "$session_dir" ]]; then
        create_session_backup "$session_dir"
        local backup_result=$?

        if [[ $backup_result -ne 0 ]]; then
            log_warning "Failed to create pre-operation backup"
        fi
    fi

    return 0
}

post_session_operation() {
    local session_dir="$1"
    local operation="${2:-unknown}"

    log_info "🔄 Post-session operation hook: $operation on $session_dir"

    # Validate session after operation
    validate_single_session "$session_dir"
    local validation_result=$?

    if [[ $validation_result -ne 0 ]]; then
        log_error "Session validation failed after $operation"
        log_error "Consider restoring from backup if data corruption detected"
    fi

    return $validation_result
}

# Main entry point
main() {
    local command="${1:-help}"
    local target="${2:-}"
    local params="${3:-}"

    case "$command" in
        validate)
            if [[ -z "$target" ]]; then
                validate_all_sessions
            else
                validate_single_session "$target"
            fi
            ;;
        backup)
            create_session_backup "$target"
            ;;
        restore)
            restore_session_backup "$target" "$params"
            ;;
        pre-operation)
            pre_session_operation "$target" "$params"
            ;;
        post-operation)
            post_session_operation "$target" "$params"
            ;;
        help|*)
            echo "Session Validation Hook - Data Integrity Management"
            echo ""
            echo "Usage: $0 <command> [target] [params]"
            echo ""
            echo "Commands:"
            echo "  validate [session-dir]           - Validate session(s) (all if no target)"
            echo "  backup <session-dir>             - Create session backup"
            echo "  restore <backup-file> [dest]     - Restore session from backup"
            echo "  pre-operation <session> <op>     - Pre-operation hook"
            echo "  post-operation <session> <op>    - Post-operation hook"
            echo "  help                             - Show this help"
            echo ""
            echo "Validation Checks:"
            echo "  ✓ JSON format validity"
            echo "  ✓ Session structure compliance"
            echo "  ✓ Checkpoint integrity"
            echo "  ✓ File reference validation"
            echo "  ✓ Backup and recovery readiness"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
exit $?
