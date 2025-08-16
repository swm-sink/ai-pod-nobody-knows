#!/bin/bash

# Migration Template for Level-1-Dev Components
# Copy this template when creating new migrations

# Migration Metadata
MIGRATION_ID="YYYYMMDD_HHMMSS_component_name"
COMPONENT="component-name"
FROM_VERSION="0.1.0"
TO_VERSION="1.0.0"
BREAKING_CHANGE="true"
DESCRIPTION="Brief description of what this migration does"
AUTHOR="$(git config user.name 2>/dev/null || echo 'unknown')"
DATE="$(date +%Y-%m-%d)"

# Safety checks
set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVEL1_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Migration functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pre-migration validation
validate_preconditions() {
    log_info "Validating preconditions for migration $MIGRATION_ID"

    # Check current version
    local manifest_file="$LEVEL1_DIR/versions/manifests/${COMPONENT}.yaml"
    if [ ! -f "$manifest_file" ]; then
        log_error "Component manifest not found: $COMPONENT"
        return 1
    fi

    local current_version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
    if [ "$current_version" != "$FROM_VERSION" ]; then
        log_error "Version mismatch. Expected $FROM_VERSION, found $current_version"
        return 1
    fi

    # Add additional validation checks here
    # Example: Check for required files, dependencies, etc.

    log_success "Preconditions validated"
    return 0
}

# Backup current state
create_backup() {
    log_info "Creating backup before migration"

    local backup_dir="$LEVEL1_DIR/versions/migrations/backups/${MIGRATION_ID}"
    mkdir -p "$backup_dir"

    # Backup component files
    # Example: cp -r "$LEVEL1_DIR/agents/${COMPONENT}*" "$backup_dir/" 2>/dev/null || true

    # Backup manifest
    cp "$LEVEL1_DIR/versions/manifests/${COMPONENT}.yaml" "$backup_dir/"

    log_success "Backup created at $backup_dir"
    return 0
}

# Main migration logic
perform_migration() {
    log_info "Starting migration from $FROM_VERSION to $TO_VERSION"

    # ================================================================
    # ADD YOUR MIGRATION LOGIC HERE
    # ================================================================

    # Example migration steps:
    # 1. Update file structures
    # 2. Modify configurations
    # 3. Transform data formats
    # 4. Update dependencies

    # Example:
    # log_info "Updating configuration format..."
    # sed -i.bak 's/old_format/new_format/g' "$LEVEL1_DIR/path/to/file"

    # ================================================================
    # END OF MIGRATION LOGIC
    # ================================================================

    log_success "Migration logic completed"
    return 0
}

# Update version information
update_version() {
    log_info "Updating version information"

    local manifest_file="$LEVEL1_DIR/versions/manifests/${COMPONENT}.yaml"

    # Update version
    sed -i.bak "s/^version:.*/version: \"$TO_VERSION\"/" "$manifest_file"
    sed -i.bak "s/^updated:.*/updated: \"$(date +%Y-%m-%d)\"/" "$manifest_file"
    rm "${manifest_file}.bak"

    # Add migration record
    local migration_record="  - version: \"$TO_VERSION\"
    date: \"$(date +%Y-%m-%d)\"
    changes:
      - \"Migrated from $FROM_VERSION\"
      - \"$DESCRIPTION\"
    breaking: $BREAKING_CHANGE"

    # Insert into changelog
    awk -v entry="$migration_record" '/^changelog:/ {print; print entry; next} {print}' "$manifest_file" > "${manifest_file}.tmp"
    mv "${manifest_file}.tmp" "$manifest_file"

    log_success "Version updated to $TO_VERSION"
    return 0
}

# Post-migration validation
validate_migration() {
    log_info "Validating migration results"

    # Add validation checks here
    # Example: Test that files exist, configs are valid, etc.

    # Check version was updated
    local manifest_file="$LEVEL1_DIR/versions/manifests/${COMPONENT}.yaml"
    local new_version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

    if [ "$new_version" != "$TO_VERSION" ]; then
        log_error "Version update failed. Expected $TO_VERSION, found $new_version"
        return 1
    fi

    log_success "Migration validated successfully"
    return 0
}

# Rollback function
rollback_migration() {
    log_warning "Rolling back migration $MIGRATION_ID"

    local backup_dir="$LEVEL1_DIR/versions/migrations/backups/${MIGRATION_ID}"

    if [ ! -d "$backup_dir" ]; then
        log_error "Backup directory not found. Cannot rollback."
        return 1
    fi

    # Restore backed up files
    # Add rollback logic here

    # Restore manifest
    cp "$backup_dir/${COMPONENT}.yaml" "$LEVEL1_DIR/versions/manifests/"

    log_success "Migration rolled back successfully"
    return 0
}

# Main execution
main() {
    echo "=========================================="
    echo "Migration: $MIGRATION_ID"
    echo "Component: $COMPONENT"
    echo "Version: $FROM_VERSION → $TO_VERSION"
    echo "Breaking: $BREAKING_CHANGE"
    echo "=========================================="
    echo ""

    # Run migration steps
    if ! validate_preconditions; then
        log_error "Precondition validation failed"
        exit 1
    fi

    if ! create_backup; then
        log_error "Backup creation failed"
        exit 1
    fi

    if ! perform_migration; then
        log_error "Migration failed. Attempting rollback..."
        rollback_migration
        exit 1
    fi

    if ! update_version; then
        log_error "Version update failed. Attempting rollback..."
        rollback_migration
        exit 1
    fi

    if ! validate_migration; then
        log_error "Post-migration validation failed. Attempting rollback..."
        rollback_migration
        exit 1
    fi

    # Mark migration as applied
    touch "$SCRIPT_DIR/../applied/$(basename "${BASH_SOURCE[0]}")"

    echo ""
    echo "=========================================="
    log_success "Migration $MIGRATION_ID completed successfully!"
    echo "=========================================="
}

# Handle rollback flag
if [ "${1:-}" = "--rollback" ]; then
    rollback_migration
    exit $?
fi

# Run migration
main "$@"
