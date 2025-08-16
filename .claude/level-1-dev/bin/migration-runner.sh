#!/bin/bash

# Migration Runner for Level-1-Dev Components
# Manages execution of version migration scripts

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVEL1_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MIGRATIONS_DIR="$LEVEL1_DIR/versions/migrations"
AVAILABLE_DIR="$MIGRATIONS_DIR/available"
APPLIED_DIR="$MIGRATIONS_DIR/applied"
FAILED_DIR="$MIGRATIONS_DIR/failed"
BACKUPS_DIR="$MIGRATIONS_DIR/backups"

# Ensure directories exist
mkdir -p "$AVAILABLE_DIR" "$APPLIED_DIR" "$FAILED_DIR" "$BACKUPS_DIR"

# Function: Display help
show_help() {
    cat << EOF
Migration Runner for Level-1-Dev Components

Usage: $(basename "$0") <command> [options]

Commands:
    list                     List all available migrations
    status                   Show migration status
    run <migration>         Run a specific migration
    run-all                 Run all pending migrations
    rollback <migration>    Rollback a specific migration
    create <component>      Create new migration from template
    validate                Validate all migration scripts
    clean                   Clean up old backups

Options:
    -h, --help              Show this help message
    -d, --dry-run          Show what would be done without executing
    -f, --force            Force migration even if checks fail
    -v, --verbose          Enable verbose output

Examples:
    $(basename "$0") list
    $(basename "$0") run 20250816_120000_agent-builder
    $(basename "$0") rollback 20250816_120000_agent-builder
    $(basename "$0") create agent-builder

EOF
}

# Function: List available migrations
list_migrations() {
    echo -e "${BLUE}Available Migrations:${NC}"
    echo "===================="

    if [ -d "$AVAILABLE_DIR" ] && [ "$(ls -A "$AVAILABLE_DIR" 2>/dev/null)" ]; then
        for migration in "$AVAILABLE_DIR"/*.sh; do
            if [ -f "$migration" ]; then
                local filename=$(basename "$migration")
                local applied_marker="$APPLIED_DIR/$filename"
                local failed_marker="$FAILED_DIR/$filename"

                # Get migration metadata
                local component=$(grep "^COMPONENT=" "$migration" | cut -d'"' -f2)
                local from_ver=$(grep "^FROM_VERSION=" "$migration" | cut -d'"' -f2)
                local to_ver=$(grep "^TO_VERSION=" "$migration" | cut -d'"' -f2)
                local breaking=$(grep "^BREAKING_CHANGE=" "$migration" | cut -d'"' -f2)

                # Determine status
                local status=""
                if [ -f "$applied_marker" ]; then
                    status="${GREEN}[APPLIED]${NC}"
                elif [ -f "$failed_marker" ]; then
                    status="${RED}[FAILED]${NC}"
                else
                    status="${YELLOW}[PENDING]${NC}"
                fi

                echo -e "$status $filename"
                echo "  Component: $component"
                echo "  Version: $from_ver → $to_ver"
                if [ "$breaking" = "true" ]; then
                    echo -e "  ${YELLOW}⚠ Breaking change${NC}"
                fi
                echo ""
            fi
        done
    else
        echo "No migrations found"
    fi
}

# Function: Show migration status
show_status() {
    echo -e "${BLUE}Migration Status Summary${NC}"
    echo "======================="

    local total=0
    local pending=0
    local applied=0
    local failed=0

    if [ -d "$AVAILABLE_DIR" ]; then
        total=$(find "$AVAILABLE_DIR" -name "*.sh" -type f 2>/dev/null | wc -l)
    fi

    if [ -d "$APPLIED_DIR" ]; then
        applied=$(find "$APPLIED_DIR" -type f 2>/dev/null | wc -l)
    fi

    if [ -d "$FAILED_DIR" ]; then
        failed=$(find "$FAILED_DIR" -type f 2>/dev/null | wc -l)
    fi

    pending=$((total - applied - failed))

    echo "Total migrations: $total"
    echo -e "  ${GREEN}Applied: $applied${NC}"
    echo -e "  ${YELLOW}Pending: $pending${NC}"
    echo -e "  ${RED}Failed: $failed${NC}"

    if [ $pending -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Run '$(basename "$0") run-all' to apply pending migrations${NC}"
    fi
}

# Function: Run a specific migration
run_migration() {
    local migration_name=$1
    local migration_file="$AVAILABLE_DIR/${migration_name}.sh"

    if [ ! -f "$migration_file" ]; then
        # Try with .sh extension if not provided
        migration_file="$AVAILABLE_DIR/${migration_name}"
        if [ ! -f "$migration_file" ]; then
            echo -e "${RED}Error: Migration not found: $migration_name${NC}"
            return 1
        fi
    fi

    local filename=$(basename "$migration_file")
    local applied_marker="$APPLIED_DIR/$filename"
    local failed_marker="$FAILED_DIR/$filename"

    # Check if already applied
    if [ -f "$applied_marker" ]; then
        echo -e "${YELLOW}Migration already applied: $filename${NC}"
        return 0
    fi

    # Remove failed marker if exists
    rm -f "$failed_marker"

    echo -e "${BLUE}Running migration: $filename${NC}"
    echo "----------------------------------------"

    # Make migration executable
    chmod +x "$migration_file"

    # Run the migration
    if "$migration_file"; then
        # Mark as applied
        touch "$applied_marker"
        echo ""
        echo -e "${GREEN}✓ Migration completed successfully${NC}"
        return 0
    else
        # Mark as failed
        touch "$failed_marker"
        echo ""
        echo -e "${RED}✗ Migration failed${NC}"
        return 1
    fi
}

# Function: Run all pending migrations
run_all_migrations() {
    echo -e "${BLUE}Running all pending migrations...${NC}"
    echo "================================="

    local run_count=0
    local fail_count=0

    if [ -d "$AVAILABLE_DIR" ] && [ "$(ls -A "$AVAILABLE_DIR" 2>/dev/null)" ]; then
        # Sort migrations by filename (which includes timestamp)
        for migration in $(ls "$AVAILABLE_DIR"/*.sh 2>/dev/null | sort); do
            if [ -f "$migration" ]; then
                local filename=$(basename "$migration")
                local applied_marker="$APPLIED_DIR/$filename"

                if [ ! -f "$applied_marker" ]; then
                    echo ""
                    if run_migration "$filename"; then
                        ((run_count++))
                    else
                        ((fail_count++))
                        echo -e "${YELLOW}Stopping due to failed migration${NC}"
                        break
                    fi
                fi
            fi
        done
    fi

    echo ""
    echo "================================="
    echo -e "${GREEN}Completed: $run_count migrations${NC}"
    if [ $fail_count -gt 0 ]; then
        echo -e "${RED}Failed: $fail_count migrations${NC}"
    fi
}

# Function: Rollback a migration
rollback_migration() {
    local migration_name=$1
    local migration_file="$AVAILABLE_DIR/${migration_name}.sh"

    if [ ! -f "$migration_file" ]; then
        migration_file="$AVAILABLE_DIR/${migration_name}"
        if [ ! -f "$migration_file" ]; then
            echo -e "${RED}Error: Migration not found: $migration_name${NC}"
            return 1
        fi
    fi

    local filename=$(basename "$migration_file")
    local applied_marker="$APPLIED_DIR/$filename"

    if [ ! -f "$applied_marker" ]; then
        echo -e "${YELLOW}Migration not applied: $filename${NC}"
        return 0
    fi

    echo -e "${BLUE}Rolling back migration: $filename${NC}"
    echo "----------------------------------------"

    # Make migration executable
    chmod +x "$migration_file"

    # Run rollback
    if "$migration_file" --rollback; then
        # Remove applied marker
        rm -f "$applied_marker"
        echo ""
        echo -e "${GREEN}✓ Rollback completed successfully${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}✗ Rollback failed${NC}"
        return 1
    fi
}

# Function: Create new migration from template
create_migration() {
    local component=$1
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local migration_name="${timestamp}_${component}"
    local migration_file="$AVAILABLE_DIR/${migration_name}.sh"
    local template_file="$MIGRATIONS_DIR/migration-template.sh"

    if [ ! -f "$template_file" ]; then
        echo -e "${RED}Error: Migration template not found${NC}"
        return 1
    fi

    # Get version information
    local manifest_file="$LEVEL1_DIR/versions/manifests/${component}.yaml"
    local current_version="0.1.0"

    if [ -f "$manifest_file" ]; then
        current_version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
    fi

    # Prompt for target version
    read -p "Current version: $current_version. Enter target version: " target_version
    read -p "Is this a breaking change? (y/N): " -n 1 -r
    echo
    local breaking="false"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        breaking="true"
    fi

    read -p "Brief description: " description

    # Create migration from template
    cp "$template_file" "$migration_file"

    # Update metadata
    sed -i.bak "s/MIGRATION_ID=.*/MIGRATION_ID=\"$migration_name\"/" "$migration_file"
    sed -i.bak "s/COMPONENT=.*/COMPONENT=\"$component\"/" "$migration_file"
    sed -i.bak "s/FROM_VERSION=.*/FROM_VERSION=\"$current_version\"/" "$migration_file"
    sed -i.bak "s/TO_VERSION=.*/TO_VERSION=\"$target_version\"/" "$migration_file"
    sed -i.bak "s/BREAKING_CHANGE=.*/BREAKING_CHANGE=\"$breaking\"/" "$migration_file"
    sed -i.bak "s/DESCRIPTION=.*/DESCRIPTION=\"$description\"/" "$migration_file"
    rm "${migration_file}.bak"

    echo -e "${GREEN}✓ Created migration: $migration_name${NC}"
    echo "  File: $migration_file"
    echo "  Edit the file to add your migration logic"
}

# Function: Validate migration scripts
validate_migrations() {
    echo -e "${BLUE}Validating migration scripts...${NC}"
    echo "=============================="

    local errors=0

    if [ -d "$AVAILABLE_DIR" ] && [ "$(ls -A "$AVAILABLE_DIR" 2>/dev/null)" ]; then
        for migration in "$AVAILABLE_DIR"/*.sh; do
            if [ -f "$migration" ]; then
                local filename=$(basename "$migration")
                echo -n "Validating $filename... "

                # Check syntax
                if bash -n "$migration" 2>/dev/null; then
                    # Check required variables
                    local required_vars=("MIGRATION_ID" "COMPONENT" "FROM_VERSION" "TO_VERSION")
                    local missing_vars=()

                    for var in "${required_vars[@]}"; do
                        if ! grep -q "^$var=" "$migration"; then
                            missing_vars+=("$var")
                        fi
                    done

                    if [ ${#missing_vars[@]} -eq 0 ]; then
                        echo -e "${GREEN}✓ Valid${NC}"
                    else
                        echo -e "${RED}✗ Missing variables: ${missing_vars[*]}${NC}"
                        ((errors++))
                    fi
                else
                    echo -e "${RED}✗ Syntax error${NC}"
                    ((errors++))
                fi
            fi
        done
    else
        echo "No migrations to validate"
    fi

    if [ $errors -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ All migrations valid${NC}"
    else
        echo ""
        echo -e "${RED}✗ Found $errors invalid migrations${NC}"
        return 1
    fi
}

# Function: Clean up old backups
clean_backups() {
    echo -e "${BLUE}Cleaning up old migration backups...${NC}"

    if [ ! -d "$BACKUPS_DIR" ]; then
        echo "No backups directory found"
        return 0
    fi

    # Find backups older than 30 days
    local old_backups=$(find "$BACKUPS_DIR" -type d -mtime +30 2>/dev/null | wc -l)

    if [ "$old_backups" -gt 0 ]; then
        echo "Found $old_backups backups older than 30 days"
        read -p "Delete them? (y/N): " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            find "$BACKUPS_DIR" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null
            echo -e "${GREEN}✓ Cleaned up $old_backups old backups${NC}"
        else
            echo "Cleanup cancelled"
        fi
    else
        echo "No old backups to clean"
    fi
}

# Main command dispatcher
main() {
    case "${1:-}" in
        list)
            list_migrations
            ;;
        status)
            show_status
            ;;
        run)
            if [ $# -lt 2 ]; then
                echo "Usage: $(basename "$0") run <migration>"
                exit 1
            fi
            run_migration "$2"
            ;;
        run-all)
            run_all_migrations
            ;;
        rollback)
            if [ $# -lt 2 ]; then
                echo "Usage: $(basename "$0") rollback <migration>"
                exit 1
            fi
            rollback_migration "$2"
            ;;
        create)
            if [ $# -lt 2 ]; then
                echo "Usage: $(basename "$0") create <component>"
                exit 1
            fi
            create_migration "$2"
            ;;
        validate)
            validate_migrations
            ;;
        clean)
            clean_backups
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            echo "Unknown command: ${1:-}"
            echo "Run '$(basename "$0") --help' for usage"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
