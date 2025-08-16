#!/bin/bash

# Rollback Manager for Level-1-Dev Components
# Comprehensive rollback and recovery procedures

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVEL1_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSIONS_DIR="$LEVEL1_DIR/versions"
MANIFESTS_DIR="$VERSIONS_DIR/manifests"
MIGRATIONS_DIR="$VERSIONS_DIR/migrations"
HISTORY_DIR="$VERSIONS_DIR/history"
RECOVERY_DIR="$VERSIONS_DIR/recovery"
BACKUP_MARKER="$RECOVERY_DIR/.last_known_good"

# Ensure directories exist
mkdir -p "$RECOVERY_DIR"

# Function: Display help
show_help() {
    cat << EOF
Rollback Manager for Level-1-Dev Components

Usage: $(basename "$0") <command> [options]

Commands:
    status                      Show current system state
    checkpoint                  Create recovery checkpoint
    rollback <type> [target]    Perform rollback
    recover                     Emergency recovery mode
    verify                      Verify system after rollback
    history                     Show rollback history
    clean                       Clean old recovery data

Rollback Types:
    version <component> [version]   Rollback component version
    migration <migration-id>        Rollback specific migration
    git [commit]                   Rollback git changes
    full [checkpoint]              Full system rollback

Options:
    -h, --help                 Show this help message
    -f, --force               Force rollback without confirmation
    -d, --dry-run            Show what would be done
    -v, --verbose            Enable verbose output
    --no-backup              Skip backup creation

Examples:
    $(basename "$0") checkpoint                    # Create recovery point
    $(basename "$0") rollback version agent-builder 0.1.0
    $(basename "$0") rollback migration 20250816_120000_agent
    $(basename "$0") rollback git HEAD~1
    $(basename "$0") rollback full                # To last checkpoint
    $(basename "$0") recover                      # Emergency recovery

EOF
}

# Function: Create recovery checkpoint
create_checkpoint() {
    echo -e "${BLUE}Creating recovery checkpoint...${NC}"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local checkpoint_dir="$RECOVERY_DIR/checkpoint_$timestamp"

    mkdir -p "$checkpoint_dir"

    # Save current state
    echo "Saving manifests..."
    cp -r "$MANIFESTS_DIR" "$checkpoint_dir/manifests" 2>/dev/null || true

    echo "Saving compatibility matrix..."
    cp "$VERSIONS_DIR/compatibility-matrix.yaml" "$checkpoint_dir/" 2>/dev/null || true

    echo "Saving migration status..."
    cp -r "$MIGRATIONS_DIR/applied" "$checkpoint_dir/applied_migrations" 2>/dev/null || true

    # Save git state
    echo "Saving git state..."
    git rev-parse HEAD > "$checkpoint_dir/git_commit"
    git status --short > "$checkpoint_dir/git_status"

    # Save component versions
    echo "Saving component versions..."
    for component in "$LEVEL1_DIR/agents"/*.md "$LEVEL1_DIR/commands"/*.md; do
        if [ -f "$component" ]; then
            local name=$(basename "$component")
            grep "^version:" "$component" 2>/dev/null > "$checkpoint_dir/version_$name" || true
        fi
    done

    # Mark as last known good
    echo "$checkpoint_dir" > "$BACKUP_MARKER"

    # Create checkpoint manifest
    cat > "$checkpoint_dir/checkpoint.yaml" << EOF
checkpoint_id: checkpoint_$timestamp
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
git_commit: $(git rev-parse HEAD)
git_branch: $(git branch --show-current)
components: $(find "$MANIFESTS_DIR" -name "*.yaml" 2>/dev/null | wc -l)
description: Recovery checkpoint
EOF

    echo -e "${GREEN}✓ Checkpoint created: checkpoint_$timestamp${NC}"
    echo "  Location: $checkpoint_dir"
}

# Function: Show system status
show_status() {
    echo -e "${BLUE}System Status${NC}"
    echo "============="

    # Git status
    echo -e "\n${CYAN}Git Status:${NC}"
    echo "  Branch: $(git branch --show-current)"
    echo "  Commit: $(git rev-parse --short HEAD)"
    local changes=$(git status --short | wc -l)
    if [ "$changes" -gt 0 ]; then
        echo -e "  Changes: ${YELLOW}$changes uncommitted changes${NC}"
    else
        echo -e "  Changes: ${GREEN}Working tree clean${NC}"
    fi

    # Version status
    echo -e "\n${CYAN}Version Status:${NC}"
    local component_count=$(find "$MANIFESTS_DIR" -name "*.yaml" 2>/dev/null | wc -l)
    echo "  Components tracked: $component_count"

    # Migration status
    echo -e "\n${CYAN}Migration Status:${NC}"
    local applied=$(find "$MIGRATIONS_DIR/applied" -type f 2>/dev/null | wc -l)
    local available=$(find "$MIGRATIONS_DIR/available" -name "*.sh" 2>/dev/null | wc -l)
    local failed=$(find "$MIGRATIONS_DIR/failed" -type f 2>/dev/null | wc -l)
    echo "  Applied: $applied"
    echo "  Available: $available"
    if [ "$failed" -gt 0 ]; then
        echo -e "  Failed: ${RED}$failed${NC}"
    fi

    # Validation status
    echo -e "\n${CYAN}Validation Status:${NC}"
    if "$SCRIPT_DIR/version-validator.sh" --quiet 2>/dev/null; then
        echo -e "  ${GREEN}✓ All validations passing${NC}"
    else
        echo -e "  ${YELLOW}⚠ Validation issues detected${NC}"
    fi

    # Last checkpoint
    echo -e "\n${CYAN}Recovery Points:${NC}"
    if [ -f "$BACKUP_MARKER" ]; then
        local last_checkpoint=$(cat "$BACKUP_MARKER")
        local checkpoint_time=$(basename "$last_checkpoint" | cut -d_ -f2-3)
        echo "  Last checkpoint: $checkpoint_time"
    else
        echo "  No checkpoints available"
    fi

    local checkpoint_count=$(find "$RECOVERY_DIR" -name "checkpoint_*" -type d 2>/dev/null | wc -l)
    echo "  Total checkpoints: $checkpoint_count"
}

# Function: Rollback version
rollback_version() {
    local component=$1
    local target_version=${2:-}

    echo -e "${BLUE}Rolling back $component version...${NC}"

    local manifest_file="$MANIFESTS_DIR/${component}.yaml"
    if [ ! -f "$manifest_file" ]; then
        echo -e "${RED}Error: Component manifest not found${NC}"
        return 1
    fi

    local current_version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

    # Find target version
    if [ -z "$target_version" ]; then
        # Find previous version from history
        local history_files=$(find "$HISTORY_DIR" -name "${component}_*.yaml" 2>/dev/null | sort -r)
        if [ -z "$history_files" ]; then
            echo -e "${RED}Error: No version history found${NC}"
            return 1
        fi

        # Get the most recent historical version
        for hist_file in $history_files; do
            target_version=$(grep "^version:" "$hist_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
            if [ "$target_version" != "$current_version" ]; then
                break
            fi
        done
    fi

    echo "  Current version: $current_version"
    echo "  Target version: $target_version"

    # Confirm rollback
    if [ "${FORCE:-false}" != "true" ]; then
        read -p "Proceed with rollback? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Rollback cancelled"
            return 1
        fi
    fi

    # Create backup
    local backup_file="$HISTORY_DIR/${component}_rollback_$(date +%Y%m%d_%H%M%S).yaml"
    cp "$manifest_file" "$backup_file"

    # Find and restore historical manifest
    local found=false
    for hist_file in $(find "$HISTORY_DIR" -name "${component}_*.yaml" 2>/dev/null | sort -r); do
        local hist_version=$(grep "^version:" "$hist_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
        if [ "$hist_version" = "$target_version" ]; then
            cp "$hist_file" "$manifest_file"
            found=true
            break
        fi
    done

    if [ "$found" = "false" ]; then
        # Create minimal rollback
        sed -i.bak "s/^version:.*/version: \"$target_version\"/" "$manifest_file"
        rm "${manifest_file}.bak"
    fi

    # Update component file
    for path in "$LEVEL1_DIR/agents/${component}.md" "$LEVEL1_DIR/commands/${component}.md"; do
        if [ -f "$path" ]; then
            sed -i.bak "s/^version:.*/version: $target_version/" "$path"
            rm "${path}.bak"
        fi
    done

    echo -e "${GREEN}✓ Rolled back $component to version $target_version${NC}"
}

# Function: Rollback migration
rollback_migration() {
    local migration_id=$1

    echo -e "${BLUE}Rolling back migration $migration_id...${NC}"

    # Use migration runner for rollback
    if [ -x "$SCRIPT_DIR/migration-runner.sh" ]; then
        "$SCRIPT_DIR/migration-runner.sh" rollback "$migration_id"
    else
        echo -e "${RED}Error: Migration runner not found${NC}"
        return 1
    fi
}

# Function: Git rollback
rollback_git() {
    local target=${1:-HEAD~1}

    echo -e "${BLUE}Rolling back git to $target...${NC}"

    # Check for uncommitted changes
    if [ "$(git status --short | wc -l)" -gt 0 ]; then
        echo -e "${YELLOW}Warning: Uncommitted changes detected${NC}"

        if [ "${FORCE:-false}" != "true" ]; then
            read -p "Stash changes and continue? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Rollback cancelled"
                return 1
            fi
        fi

        git stash push -m "Rollback stash $(date +%Y%m%d_%H%M%S)"
    fi

    # Perform git reset
    git reset --hard "$target"

    echo -e "${GREEN}✓ Git rolled back to $target${NC}"
}

# Function: Full system rollback
rollback_full() {
    local checkpoint=${1:-}

    echo -e "${BLUE}Performing full system rollback...${NC}"

    # Find checkpoint
    if [ -z "$checkpoint" ]; then
        if [ -f "$BACKUP_MARKER" ]; then
            checkpoint=$(cat "$BACKUP_MARKER")
        else
            echo -e "${RED}Error: No checkpoint specified and no default found${NC}"
            return 1
        fi
    else
        checkpoint="$RECOVERY_DIR/$checkpoint"
    fi

    if [ ! -d "$checkpoint" ]; then
        echo -e "${RED}Error: Checkpoint not found: $checkpoint${NC}"
        return 1
    fi

    echo "Using checkpoint: $(basename "$checkpoint")"

    # Confirm rollback
    if [ "${FORCE:-false}" != "true" ]; then
        echo -e "${YELLOW}Warning: This will restore the entire system state${NC}"
        read -p "Proceed with full rollback? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Rollback cancelled"
            return 1
        fi
    fi

    # Create current backup
    echo "Creating backup of current state..."
    create_checkpoint

    # Restore manifests
    echo "Restoring manifests..."
    if [ -d "$checkpoint/manifests" ]; then
        rm -rf "$MANIFESTS_DIR"
        cp -r "$checkpoint/manifests" "$MANIFESTS_DIR"
    fi

    # Restore compatibility matrix
    echo "Restoring compatibility matrix..."
    if [ -f "$checkpoint/compatibility-matrix.yaml" ]; then
        cp "$checkpoint/compatibility-matrix.yaml" "$VERSIONS_DIR/"
    fi

    # Restore migration status
    echo "Restoring migration status..."
    if [ -d "$checkpoint/applied_migrations" ]; then
        rm -rf "$MIGRATIONS_DIR/applied"
        cp -r "$checkpoint/applied_migrations" "$MIGRATIONS_DIR/applied"
    fi

    # Restore git state
    if [ -f "$checkpoint/git_commit" ]; then
        local git_commit=$(cat "$checkpoint/git_commit")
        echo "Restoring git state to $git_commit..."
        git reset --hard "$git_commit"
    fi

    echo -e "${GREEN}✓ Full rollback completed${NC}"
}

# Function: Emergency recovery
emergency_recovery() {
    echo -e "${RED}EMERGENCY RECOVERY MODE${NC}"
    echo "======================="

    echo -e "${YELLOW}This will attempt to restore a working system state${NC}"
    echo ""

    # Step 1: Check git status
    echo "Step 1: Checking git status..."
    local git_ok=true
    if ! git status &>/dev/null; then
        echo -e "${RED}Git repository corrupted${NC}"
        git_ok=false
    else
        echo -e "${GREEN}Git repository OK${NC}"
    fi

    # Step 2: Find last known good state
    echo "Step 2: Finding recovery points..."
    local recovery_point=""

    if [ -f "$BACKUP_MARKER" ]; then
        recovery_point=$(cat "$BACKUP_MARKER")
        echo "  Found last checkpoint: $(basename "$recovery_point")"
    elif [ -d "$RECOVERY_DIR" ]; then
        recovery_point=$(find "$RECOVERY_DIR" -name "checkpoint_*" -type d | sort -r | head -1)
        if [ -n "$recovery_point" ]; then
            echo "  Found checkpoint: $(basename "$recovery_point")"
        fi
    fi

    if [ -z "$recovery_point" ] || [ ! -d "$recovery_point" ]; then
        echo -e "${RED}No recovery points available${NC}"
        echo "Attempting git-based recovery..."

        if [ "$git_ok" = "true" ]; then
            # Find last known good commit
            local last_good=$(git log --format="%H %s" -20 | grep -E "(stable|working|good)" | head -1 | cut -d' ' -f1)
            if [ -n "$last_good" ]; then
                echo "  Found stable commit: $last_good"
                git reset --hard "$last_good"
            else
                echo "  Using HEAD~5 as recovery point"
                git reset --hard HEAD~5
            fi
        else
            echo -e "${RED}Cannot recover without git or checkpoints${NC}"
            return 1
        fi
    else
        # Use checkpoint for recovery
        echo "Step 3: Restoring from checkpoint..."
        FORCE=true rollback_full "$recovery_point"
    fi

    # Step 4: Validate recovered state
    echo "Step 4: Validating recovered state..."
    local validation_ok=true

    if ! "$SCRIPT_DIR/version-validator.sh" --quiet 2>/dev/null; then
        echo -e "${YELLOW}Validation issues detected${NC}"
        validation_ok=false

        # Attempt auto-fix
        echo "Attempting auto-fix..."
        "$SCRIPT_DIR/version-validator.sh" --fix --quiet
    fi

    # Step 5: Report status
    echo ""
    echo "Recovery Summary:"
    echo "================="

    if [ "$git_ok" = "true" ]; then
        echo -e "  Git Status:       ${GREEN}OK${NC}"
    else
        echo -e "  Git Status:       ${RED}FAILED${NC}"
    fi

    if [ "$validation_ok" = "true" ]; then
        echo -e "  Validation:       ${GREEN}OK${NC}"
    else
        echo -e "  Validation:       ${YELLOW}ISSUES${NC}"
    fi

    echo ""
    echo "Recommended next steps:"
    echo "  1. Run: ./bin/version-validator.sh"
    echo "  2. Run: ./bin/compatibility-checker.sh validate"
    echo "  3. Create new checkpoint: $(basename "$0") checkpoint"

    if [ "$validation_ok" = "true" ]; then
        echo -e "\n${GREEN}✓ Emergency recovery completed successfully${NC}"
        return 0
    else
        echo -e "\n${YELLOW}⚠ Emergency recovery completed with issues${NC}"
        return 1
    fi
}

# Function: Verify system after rollback
verify_system() {
    echo -e "${BLUE}Verifying system state...${NC}"
    echo "========================"

    local issues=0

    # Run version validator
    echo "Running version validation..."
    if "$SCRIPT_DIR/version-validator.sh" --quiet; then
        echo -e "  ${GREEN}✓ Version validation passed${NC}"
    else
        echo -e "  ${RED}✗ Version validation failed${NC}"
        ((issues++))
    fi

    # Run compatibility checker
    echo "Running compatibility check..."
    if "$SCRIPT_DIR/compatibility-checker.sh" validate 2>&1 | grep -q "All components are compatible"; then
        echo -e "  ${GREEN}✓ Compatibility check passed${NC}"
    else
        echo -e "  ${YELLOW}⚠ Compatibility issues detected${NC}"
        ((issues++))
    fi

    # Check migrations
    echo "Checking migration status..."
    local failed_migrations=$(find "$MIGRATIONS_DIR/failed" -type f 2>/dev/null | wc -l)
    if [ "$failed_migrations" -eq 0 ]; then
        echo -e "  ${GREEN}✓ No failed migrations${NC}"
    else
        echo -e "  ${RED}✗ $failed_migrations failed migrations${NC}"
        ((issues++))
    fi

    # Check git status
    echo "Checking git status..."
    if git diff --quiet && git diff --cached --quiet; then
        echo -e "  ${GREEN}✓ Working tree clean${NC}"
    else
        echo -e "  ${YELLOW}⚠ Uncommitted changes present${NC}"
    fi

    echo ""
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✓ System verification passed${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ System has $issues issues${NC}"
        echo "Run individual tools for details:"
        echo "  ./bin/version-validator.sh"
        echo "  ./bin/compatibility-checker.sh conflicts"
        return 1
    fi
}

# Function: Show rollback history
show_history() {
    echo -e "${BLUE}Rollback History${NC}"
    echo "================"

    # Show checkpoints
    echo -e "\n${CYAN}Recovery Checkpoints:${NC}"
    if [ -d "$RECOVERY_DIR" ]; then
        for checkpoint in $(find "$RECOVERY_DIR" -name "checkpoint_*" -type d | sort -r); do
            local name=$(basename "$checkpoint")
            local manifest="$checkpoint/checkpoint.yaml"

            if [ -f "$manifest" ]; then
                local created=$(grep "^created:" "$manifest" | cut -d' ' -f2)
                local commit=$(grep "^git_commit:" "$manifest" | cut -d' ' -f2 | cut -c1-8)
                echo "  $name"
                echo "    Created: $created"
                echo "    Commit: $commit"
            else
                echo "  $name (no manifest)"
            fi
        done
    else
        echo "  No checkpoints found"
    fi

    # Show version history
    echo -e "\n${CYAN}Version History Backups:${NC}"
    local backup_count=$(find "$HISTORY_DIR" -name "*_rollback_*.yaml" 2>/dev/null | wc -l)
    echo "  Rollback backups: $backup_count"

    # Recent rollbacks
    if [ "$backup_count" -gt 0 ]; then
        echo "  Recent rollbacks:"
        find "$HISTORY_DIR" -name "*_rollback_*.yaml" 2>/dev/null | sort -r | head -5 | while read -r file; do
            echo "    - $(basename "$file")"
        done
    fi
}

# Function: Clean old recovery data
clean_recovery() {
    echo -e "${BLUE}Cleaning old recovery data...${NC}"

    # Find old checkpoints (older than 30 days)
    local old_checkpoints=$(find "$RECOVERY_DIR" -name "checkpoint_*" -type d -mtime +30 2>/dev/null | wc -l)

    if [ "$old_checkpoints" -gt 0 ]; then
        echo "Found $old_checkpoints checkpoints older than 30 days"

        if [ "${FORCE:-false}" != "true" ]; then
            read -p "Delete old checkpoints? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Cleanup cancelled"
                return 0
            fi
        fi

        find "$RECOVERY_DIR" -name "checkpoint_*" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null
        echo -e "${GREEN}✓ Deleted $old_checkpoints old checkpoints${NC}"
    else
        echo "No old checkpoints to clean"
    fi

    # Clean old rollback backups
    local old_backups=$(find "$HISTORY_DIR" -name "*_rollback_*.yaml" -mtime +30 2>/dev/null | wc -l)

    if [ "$old_backups" -gt 0 ]; then
        echo "Found $old_backups rollback backups older than 30 days"
        find "$HISTORY_DIR" -name "*_rollback_*.yaml" -mtime +30 -delete
        echo -e "${GREEN}✓ Deleted $old_backups old backups${NC}"
    fi
}

# Main command dispatcher
main() {
    # Parse global options
    FORCE=false
    DRY_RUN=false
    VERBOSE=false

    while [[ $# -gt 0 ]] && [[ "$1" == -* ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # Execute command
    case "${1:-}" in
        status)
            show_status
            ;;
        checkpoint)
            create_checkpoint
            ;;
        rollback)
            case "${2:-}" in
                version)
                    if [ $# -lt 3 ]; then
                        echo "Usage: $(basename "$0") rollback version <component> [version]"
                        exit 1
                    fi
                    rollback_version "$3" "${4:-}"
                    ;;
                migration)
                    if [ $# -lt 3 ]; then
                        echo "Usage: $(basename "$0") rollback migration <migration-id>"
                        exit 1
                    fi
                    rollback_migration "$3"
                    ;;
                git)
                    rollback_git "${3:-HEAD~1}"
                    ;;
                full)
                    rollback_full "${3:-}"
                    ;;
                *)
                    echo "Unknown rollback type: ${2:-}"
                    echo "Use: version, migration, git, or full"
                    exit 1
                    ;;
            esac
            ;;
        recover)
            emergency_recovery
            ;;
        verify)
            verify_system
            ;;
        history)
            show_history
            ;;
        clean)
            clean_recovery
            ;;
        *)
            echo "Unknown command: ${1:-}"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
