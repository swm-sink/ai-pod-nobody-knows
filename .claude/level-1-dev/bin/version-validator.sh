#!/bin/bash

# Version Validator for Level-1-Dev Components
# Comprehensive validation of version consistency across the system

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVEL1_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSIONS_DIR="$LEVEL1_DIR/versions"
MANIFESTS_DIR="$VERSIONS_DIR/manifests"
MATRIX_FILE="$VERSIONS_DIR/compatibility-matrix.yaml"
SCHEMA_FILE="$VERSIONS_DIR/schema.yaml"

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Function: Display help
show_help() {
    cat << EOF
Version Validator for Level-1-Dev Components

Usage: $(basename "$0") [options]

Options:
    -h, --help              Show this help message
    -v, --verbose          Enable verbose output
    -q, --quiet            Suppress non-error output
    -f, --fix              Attempt to fix issues automatically
    --skip-migrations      Skip migration validation
    --strict               Treat warnings as errors

Validation Checks:
    1. Version Headers      - All components have version headers
    2. Semantic Versioning  - Versions follow MAJOR.MINOR.PATCH format
    3. Manifest Sync       - Manifests match component files
    4. Schema Compliance   - Manifests follow schema rules
    5. Compatibility       - No version conflicts exist
    6. Dependencies        - All dependencies are satisfied
    7. Migrations         - Breaking changes have migrations
    8. Consistency        - Version info is consistent

Examples:
    $(basename "$0")                  # Run all validations
    $(basename "$0") --verbose        # Show detailed output
    $(basename "$0") --fix           # Auto-fix issues where possible
    $(basename "$0") --strict        # Fail on warnings

Exit Codes:
    0 - All validations passed
    1 - Validation failures found
    2 - Fatal error occurred

EOF
}

# Function: Log validation result
log_check() {
    local check_name=$1
    local status=$2
    local message=${3:-""}

    ((TOTAL_CHECKS++))

    case $status in
        "pass")
            ((PASSED_CHECKS++))
            echo -e "  ${GREEN}✓${NC} $check_name"
            ;;
        "fail")
            ((FAILED_CHECKS++))
            echo -e "  ${RED}✗${NC} $check_name"
            if [ -n "$message" ]; then
                echo -e "    ${RED}→ $message${NC}"
            fi
            ;;
        "warn")
            ((WARNINGS++))
            echo -e "  ${YELLOW}⚠${NC} $check_name"
            if [ -n "$message" ]; then
                echo -e "    ${YELLOW}→ $message${NC}"
            fi
            ;;
        "skip")
            echo -e "  ${CYAN}○${NC} $check_name (skipped)"
            ;;
    esac
}

# Function: Validate semantic version format
validate_version_format() {
    local version=$1
    if [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Check 1: Version Headers
check_version_headers() {
    echo -e "\n${BLUE}Checking Version Headers...${NC}"

    local missing_headers=0
    local components_checked=0

    # Check agents
    for agent in "$LEVEL1_DIR/agents"/*.md; do
        if [ -f "$agent" ]; then
            ((components_checked++))
            if ! grep -q "^version:" "$agent" 2>/dev/null; then
                log_check "$(basename "$agent")" "fail" "Missing version header"
                ((missing_headers++))
            fi
        fi
    done

    # Check commands
    for command in "$LEVEL1_DIR/commands"/*.md; do
        if [ -f "$command" ]; then
            ((components_checked++))
            if ! grep -q "^version:" "$command" 2>/dev/null; then
                log_check "$(basename "$command")" "fail" "Missing version header"
                ((missing_headers++))
            fi
        fi
    done

    if [ $missing_headers -eq 0 ]; then
        log_check "Version headers present" "pass" "$components_checked components checked"
    else
        log_check "Version headers check" "fail" "$missing_headers components missing headers"
    fi
}

# Check 2: Semantic Versioning
check_semantic_versioning() {
    echo -e "\n${BLUE}Checking Semantic Versioning...${NC}"

    local invalid_versions=0

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local version=$(grep "^version:" "$manifest" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
                local component=$(basename "$manifest" .yaml)

                if ! validate_version_format "$version"; then
                    log_check "$component version" "fail" "Invalid format: $version"
                    ((invalid_versions++))
                fi
            fi
        done
    fi

    if [ $invalid_versions -eq 0 ]; then
        log_check "Semantic versioning" "pass"
    else
        log_check "Semantic versioning" "fail" "$invalid_versions invalid versions"
    fi
}

# Check 3: Manifest-Component Sync
check_manifest_sync() {
    echo -e "\n${BLUE}Checking Manifest-Component Sync...${NC}"

    local sync_issues=0

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)
                local manifest_version=$(grep "^version:" "$manifest" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

                # Find corresponding component file
                local component_file=""
                for path in "$LEVEL1_DIR/agents/${component}.md" "$LEVEL1_DIR/commands/${component}.md"; do
                    if [ -f "$path" ]; then
                        component_file="$path"
                        break
                    fi
                done

                if [ -n "$component_file" ]; then
                    local file_version=$(grep "^version:" "$component_file" 2>/dev/null | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

                    if [ "$manifest_version" != "$file_version" ]; then
                        log_check "$component sync" "fail" "Manifest: $manifest_version, File: $file_version"
                        ((sync_issues++))
                    fi
                else
                    log_check "$component file" "warn" "No component file found for manifest"
                fi
            fi
        done
    fi

    if [ $sync_issues -eq 0 ]; then
        log_check "Manifest-component sync" "pass"
    else
        log_check "Manifest-component sync" "fail" "$sync_issues sync issues"
    fi
}

# Check 4: Schema Compliance
check_schema_compliance() {
    echo -e "\n${BLUE}Checking Schema Compliance...${NC}"

    if [ ! -f "$SCHEMA_FILE" ]; then
        log_check "Schema file" "fail" "Schema file not found"
        return
    fi

    local schema_violations=0
    local required_fields=("name" "type" "version" "created" "updated" "status")

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)
                local missing_fields=()

                for field in "${required_fields[@]}"; do
                    if ! grep -q "^$field:" "$manifest"; then
                        missing_fields+=("$field")
                    fi
                done

                if [ ${#missing_fields[@]} -gt 0 ]; then
                    log_check "$component schema" "fail" "Missing fields: ${missing_fields[*]}"
                    ((schema_violations++))
                fi

                # Check status values
                local status=$(grep "^status:" "$manifest" | sed 's/status: *"\?\([^"]*\)"\?/\1/')
                if ! [[ "$status" =~ ^(active|deprecated|archived|experimental)$ ]]; then
                    log_check "$component status" "fail" "Invalid status: $status"
                    ((schema_violations++))
                fi
            fi
        done
    fi

    if [ $schema_violations -eq 0 ]; then
        log_check "Schema compliance" "pass"
    else
        log_check "Schema compliance" "fail" "$schema_violations violations"
    fi
}

# Check 5: Compatibility Matrix
check_compatibility() {
    echo -e "\n${BLUE}Checking Compatibility...${NC}"

    if [ ! -f "$MATRIX_FILE" ]; then
        log_check "Compatibility matrix" "warn" "Matrix file not found"
        return
    fi

    # Run compatibility checker
    if command -v "$SCRIPT_DIR/compatibility-checker.sh" &> /dev/null; then
        local conflicts=$("$SCRIPT_DIR/compatibility-checker.sh" conflicts 2>&1 | grep -c "Conflict:" || true)

        if [ "$conflicts" -eq 0 ]; then
            log_check "Compatibility conflicts" "pass"
        else
            log_check "Compatibility conflicts" "fail" "$conflicts conflicts found"
        fi
    else
        log_check "Compatibility checker" "skip" "Checker script not found"
    fi
}

# Check 6: Dependencies
check_dependencies() {
    echo -e "\n${BLUE}Checking Dependencies...${NC}"

    local missing_deps=0

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)

                # Check dependencies in manifest
                grep -A20 "^dependencies:" "$manifest" 2>/dev/null | grep "name:" | while read -r line; do
                    local dep_name=$(echo "$line" | sed 's/.*name: *"\?\([^"]*\)"\?/\1/')

                    if [ ! -f "$MANIFESTS_DIR/${dep_name}.yaml" ]; then
                        log_check "$component → $dep_name" "fail" "Dependency not found"
                        ((missing_deps++))
                    fi
                done
            fi
        done
    fi

    if [ $missing_deps -eq 0 ]; then
        log_check "Dependencies" "pass"
    else
        log_check "Dependencies" "fail" "$missing_deps missing dependencies"
    fi
}

# Check 7: Migrations for Breaking Changes
check_migrations() {
    echo -e "\n${BLUE}Checking Migrations...${NC}"

    local migrations_dir="$VERSIONS_DIR/migrations/available"

    if [ ! -d "$migrations_dir" ]; then
        log_check "Migrations directory" "warn" "Directory not found"
        return
    fi

    # Check breaking changes in history
    local breaking_without_migration=0

    if [ -f "$MATRIX_FILE" ]; then
        grep -A5 "breaking_changes:" "$MATRIX_FILE" | grep "component:" | while read -r line; do
            local component=$(echo "$line" | sed 's/.*component: *"\?\([^"]*\)"\?/\1/')
            local has_migration=false

            # Check if migration exists for this component
            for migration in "$migrations_dir"/*.sh; do
                if [ -f "$migration" ] && grep -q "COMPONENT=\"$component\"" "$migration"; then
                    has_migration=true
                    break
                fi
            done

            if [ "$has_migration" = false ]; then
                log_check "$component migration" "warn" "Breaking change without migration"
                ((breaking_without_migration++))
            fi
        done
    fi

    if [ $breaking_without_migration -eq 0 ]; then
        log_check "Migration coverage" "pass"
    else
        log_check "Migration coverage" "warn" "$breaking_without_migration components need migrations"
    fi
}

# Check 8: Overall Consistency
check_consistency() {
    echo -e "\n${BLUE}Checking Overall Consistency...${NC}"

    # Count components
    local agent_count=$(find "$LEVEL1_DIR/agents" -name "*.md" -type f 2>/dev/null | wc -l)
    local command_count=$(find "$LEVEL1_DIR/commands" -name "*.md" -type f 2>/dev/null | wc -l)
    local manifest_count=$(find "$MANIFESTS_DIR" -name "*.yaml" -type f 2>/dev/null | wc -l)
    local total_components=$((agent_count + command_count))

    # Check manifest coverage
    if [ "$manifest_count" -lt "$total_components" ]; then
        local missing=$((total_components - manifest_count))
        log_check "Manifest coverage" "warn" "$missing components without manifests"
    else
        log_check "Manifest coverage" "pass" "All $total_components components have manifests"
    fi

    # Check for orphaned manifests
    local orphaned=0
    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)
                local found=false

                for path in "$LEVEL1_DIR/agents/${component}.md" "$LEVEL1_DIR/commands/${component}.md"; do
                    if [ -f "$path" ]; then
                        found=true
                        break
                    fi
                done

                if [ "$found" = false ]; then
                    log_check "$component manifest" "warn" "Orphaned manifest (no component file)"
                    ((orphaned++))
                fi
            fi
        done
    fi

    if [ $orphaned -eq 0 ]; then
        log_check "Orphaned manifests" "pass"
    else
        log_check "Orphaned manifests" "warn" "$orphaned orphaned manifests"
    fi
}

# Function: Attempt automatic fixes
auto_fix() {
    echo -e "\n${BLUE}Attempting Auto-Fixes...${NC}"

    local fixes_applied=0

    # Fix missing version headers
    echo "Fixing missing version headers..."
    for file in "$LEVEL1_DIR/agents"/*.md "$LEVEL1_DIR/commands"/*.md; do
        if [ -f "$file" ] && ! grep -q "^version:" "$file" 2>/dev/null; then
            # Add version after name field
            sed -i.bak '/^name:/a\
version: 0.1.0' "$file"
            rm "${file}.bak"
            echo -e "  ${GREEN}✓${NC} Added version to $(basename "$file")"
            ((fixes_applied++))
        fi
    done

    # Fix manifest-component sync issues
    echo "Fixing version sync issues..."
    if [ -d "$MANIFESTS_DIR" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)
                local manifest_version=$(grep "^version:" "$manifest" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

                for path in "$LEVEL1_DIR/agents/${component}.md" "$LEVEL1_DIR/commands/${component}.md"; do
                    if [ -f "$path" ]; then
                        local file_version=$(grep "^version:" "$path" 2>/dev/null | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

                        if [ "$manifest_version" != "$file_version" ]; then
                            sed -i.bak "s/^version:.*/version: $manifest_version/" "$path"
                            rm "${path}.bak"
                            echo -e "  ${GREEN}✓${NC} Synced version for $component"
                            ((fixes_applied++))
                        fi
                    fi
                done
            fi
        done
    fi

    echo -e "\n${GREEN}Applied $fixes_applied fixes${NC}"
}

# Function: Generate validation report
generate_report() {
    echo ""
    echo "=========================================="
    echo -e "${BLUE}Version Validation Report${NC}"
    echo "=========================================="
    echo "Total Checks:    $TOTAL_CHECKS"
    echo -e "Passed:         ${GREEN}$PASSED_CHECKS${NC}"
    echo -e "Failed:         ${RED}$FAILED_CHECKS${NC}"
    echo -e "Warnings:       ${YELLOW}$WARNINGS${NC}"
    echo ""

    local success_rate=0
    if [ $TOTAL_CHECKS -gt 0 ]; then
        success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    fi

    echo "Success Rate:    ${success_rate}%"
    echo ""

    if [ $FAILED_CHECKS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✓ All validations passed successfully!${NC}"
        return 0
    elif [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${YELLOW}⚠ Validation completed with warnings${NC}"
        return 0
    else
        echo -e "${RED}✗ Validation failed with $FAILED_CHECKS errors${NC}"
        return 1
    fi
}

# Main execution
main() {
    local verbose=false
    local quiet=false
    local fix=false
    local skip_migrations=false
    local strict=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            -f|--fix)
                fix=true
                shift
                ;;
            --skip-migrations)
                skip_migrations=true
                shift
                ;;
            --strict)
                strict=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}Starting Version Validation...${NC}"
    echo "=========================================="

    # Run validation checks
    check_version_headers
    check_semantic_versioning
    check_manifest_sync
    check_schema_compliance
    check_compatibility
    check_dependencies

    if [ "$skip_migrations" = false ]; then
        check_migrations
    fi

    check_consistency

    # Apply fixes if requested
    if [ "$fix" = true ] && [ $FAILED_CHECKS -gt 0 ]; then
        auto_fix

        # Re-run validation after fixes
        echo -e "\n${BLUE}Re-validating after fixes...${NC}"
        TOTAL_CHECKS=0
        PASSED_CHECKS=0
        FAILED_CHECKS=0
        WARNINGS=0

        check_version_headers
        check_semantic_versioning
        check_manifest_sync
    fi

    # Generate report
    generate_report

    # Exit based on results
    if [ "$strict" = true ] && [ $WARNINGS -gt 0 ]; then
        exit 1
    elif [ $FAILED_CHECKS -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"
