#!/bin/bash

# Compatibility Checker for Level-1-Dev Components
# Validates version compatibility across components

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
VERSIONS_DIR="$LEVEL1_DIR/versions"
MANIFESTS_DIR="$VERSIONS_DIR/manifests"
MATRIX_FILE="$VERSIONS_DIR/compatibility-matrix.yaml"

# Function: Display help
show_help() {
    cat << EOF
Compatibility Checker for Level-1-Dev Components

Usage: $(basename "$0") <command> [options]

Commands:
    check <component> [version]    Check if component update is safe
    validate                       Validate all current versions are compatible
    conflicts                      Find all compatibility conflicts
    upgrade <component> <version>  Show upgrade path for component
    group <group_name>            Check compatibility within a group
    impact <component>            Show impact of updating component
    matrix                        Display compatibility matrix summary

Options:
    -h, --help                    Show this help message
    -v, --verbose                Enable verbose output
    -f, --fix                    Suggest fixes for conflicts

Examples:
    $(basename "$0") check agent-builder 1.2.0
    $(basename "$0") validate
    $(basename "$0") conflicts
    $(basename "$0") impact test-utils
    $(basename "$0") group testing_suite

EOF
}

# Function: Parse version for comparison
version_compare() {
    local v1=$1
    local v2=$2
    local op=$3

    # Convert versions to comparable format
    local v1_major=$(echo "$v1" | cut -d. -f1)
    local v1_minor=$(echo "$v1" | cut -d. -f2)
    local v1_patch=$(echo "$v1" | cut -d. -f3)

    local v2_major=$(echo "$v2" | cut -d. -f1)
    local v2_minor=$(echo "$v2" | cut -d. -f2)
    local v2_patch=$(echo "$v2" | cut -d. -f3)

    # Compare based on operator
    case $op in
        "gt")
            if [ "$v1_major" -gt "$v2_major" ]; then return 0; fi
            if [ "$v1_major" -lt "$v2_major" ]; then return 1; fi
            if [ "$v1_minor" -gt "$v2_minor" ]; then return 0; fi
            if [ "$v1_minor" -lt "$v2_minor" ]; then return 1; fi
            if [ "$v1_patch" -gt "$v2_patch" ]; then return 0; fi
            return 1
            ;;
        "ge")
            if version_compare "$v1" "$v2" "gt"; then return 0; fi
            if [ "$v1" = "$v2" ]; then return 0; fi
            return 1
            ;;
        "lt")
            version_compare "$v2" "$v1" "gt"
            ;;
        "le")
            version_compare "$v2" "$v1" "ge"
            ;;
        "eq")
            [ "$v1" = "$v2" ]
            ;;
        *)
            echo "Unknown operator: $op" >&2
            return 2
            ;;
    esac
}

# Function: Check if component version is compatible
check_compatibility() {
    local component=$1
    local new_version=${2:-}
    local manifest_file="$MANIFESTS_DIR/${component}.yaml"

    if [ ! -f "$manifest_file" ]; then
        echo -e "${RED}Error: No manifest found for $component${NC}"
        return 1
    fi

    local current_version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

    if [ -z "$new_version" ]; then
        new_version=$current_version
        echo -e "${BLUE}Checking compatibility for $component at version $current_version${NC}"
    else
        echo -e "${BLUE}Checking compatibility for $component upgrade: $current_version → $new_version${NC}"
    fi

    local issues_found=0

    # Check dependencies
    echo "Checking dependencies..."

    # Check if this component has dependents
    if grep -q "$component" "$MATRIX_FILE" 2>/dev/null; then
        # Find components that depend on this one
        grep -B5 -A5 "component: $component" "$MATRIX_FILE" | grep -E "^\s+[a-z-]+:" | while read -r line; do
            local dependent=$(echo "$line" | sed 's/^\s*\([a-z-]*\):.*/\1/')
            if [ -f "$MANIFESTS_DIR/${dependent}.yaml" ]; then
                echo -n "  Checking impact on $dependent... "

                # Would this break the dependent?
                if version_compare "$new_version" "$current_version" "gt"; then
                    # Check if it's a major version bump
                    local new_major=$(echo "$new_version" | cut -d. -f1)
                    local cur_major=$(echo "$current_version" | cut -d. -f1)

                    if [ "$new_major" -gt "$cur_major" ]; then
                        echo -e "${YELLOW}⚠ Major version change - may break${NC}"
                        ((issues_found++))
                    else
                        echo -e "${GREEN}✓ Compatible${NC}"
                    fi
                else
                    echo -e "${GREEN}✓ Compatible${NC}"
                fi
            fi
        done
    fi

    # Check compatibility groups
    echo "Checking compatibility groups..."
    local group=$(grep -B10 "- $component" "$MATRIX_FILE" | grep -E "^\s+[a-z_]+:" | tail -1 | sed 's/^\s*\([a-z_]*\):.*/\1/')

    if [ -n "$group" ]; then
        echo "  Component is in group: $group"
        local update_policy=$(grep -A5 "$group:" "$MATRIX_FILE" | grep "update_policy:" | sed 's/.*update_policy: *"\?\([^"]*\)"\?/\1/')

        if [ "$update_policy" = "synchronized" ]; then
            echo -e "  ${YELLOW}Warning: This group requires synchronized updates${NC}"
            echo "  Other components in group:"
            grep -A10 "$group:" "$MATRIX_FILE" | grep "^\s*- " | while read -r line; do
                local comp=$(echo "$line" | sed 's/^\s*- *//')
                if [ "$comp" != "$component" ] && [ -f "$MANIFESTS_DIR/${comp}.yaml" ]; then
                    local comp_version=$(grep "^version:" "$MANIFESTS_DIR/${comp}.yaml" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
                    echo "    - $comp: $comp_version"
                fi
            done
        fi
    fi

    if [ $issues_found -eq 0 ]; then
        echo -e "${GREEN}✓ No compatibility issues found${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Found $issues_found potential compatibility issues${NC}"
        return 1
    fi
}

# Function: Validate all components are compatible
validate_all() {
    echo -e "${BLUE}Validating compatibility of all components...${NC}"
    echo "================================================"

    local total_issues=0

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)
                echo ""
                echo "Validating $component..."

                if ! check_compatibility "$component"; then
                    ((total_issues++))
                fi
            fi
        done
    else
        echo "No components found to validate"
    fi

    echo ""
    echo "================================================"
    if [ $total_issues -eq 0 ]; then
        echo -e "${GREEN}✓ All components are compatible${NC}"
    else
        echo -e "${YELLOW}⚠ Found compatibility issues in $total_issues components${NC}"
    fi
}

# Function: Find all conflicts
find_conflicts() {
    echo -e "${BLUE}Searching for compatibility conflicts...${NC}"
    echo "=========================================="

    local conflicts=0

    # Check for version mismatches in dependencies
    echo "Checking dependency versions..."

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)

                # Check dependencies listed in manifest
                grep -A20 "^dependencies:" "$manifest" 2>/dev/null | grep "name:" | while read -r line; do
                    local dep_name=$(echo "$line" | sed 's/.*name: *"\?\([^"]*\)"\?/\1/')
                    local dep_version=$(grep -A1 "$line" "$manifest" | grep "version:" | sed 's/.*version: *"\?\([^"]*\)"\?/\1/')

                    if [ -f "$MANIFESTS_DIR/${dep_name}.yaml" ]; then
                        local actual_version=$(grep "^version:" "$MANIFESTS_DIR/${dep_name}.yaml" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

                        if [ -n "$dep_version" ] && [ "$dep_version" != "$actual_version" ]; then
                            echo -e "  ${RED}✗ Conflict:${NC} $component expects $dep_name@$dep_version but found $actual_version"
                            ((conflicts++))
                        fi
                    fi
                done
            fi
        done
    fi

    if [ $conflicts -eq 0 ]; then
        echo -e "${GREEN}✓ No conflicts found${NC}"
    else
        echo -e "${RED}✗ Found $conflicts conflicts${NC}"
        echo ""
        echo "Suggested resolutions:"
        echo "  1. Update dependency versions in manifests"
        echo "  2. Use version manager to align versions"
        echo "  3. Run migration scripts if available"
    fi
}

# Function: Show impact of updating a component
show_impact() {
    local component=$1

    echo -e "${BLUE}Impact analysis for updating $component${NC}"
    echo "==========================================="

    if [ ! -f "$MANIFESTS_DIR/${component}.yaml" ]; then
        echo -e "${RED}Error: Component $component not found${NC}"
        return 1
    fi

    echo "Components that depend on $component:"
    local found_deps=0

    # Search all manifests for dependencies on this component
    for manifest in "$MANIFESTS_DIR"/*.yaml; do
        if [ -f "$manifest" ]; then
            if grep -q "name: *\"*$component\"*" "$manifest" 2>/dev/null; then
                local dependent=$(basename "$manifest" .yaml)
                if [ "$dependent" != "$component" ]; then
                    echo "  • $dependent"
                    ((found_deps++))
                fi
            fi
        fi
    done

    if [ $found_deps -eq 0 ]; then
        echo "  (none found)"
    fi

    # Check compatibility group
    echo ""
    echo "Compatibility group membership:"
    local group=$(grep -B10 "- $component" "$MATRIX_FILE" 2>/dev/null | grep -E "^\s+[a-z_]+:" | tail -1 | sed 's/^\s*\([a-z_]*\):.*/\1/')

    if [ -n "$group" ]; then
        echo "  Group: $group"
        local policy=$(grep -A5 "$group:" "$MATRIX_FILE" | grep "update_policy:" | sed 's/.*update_policy: *"\?\([^"]*\)"\?/\1/')
        echo "  Update policy: $policy"

        echo "  Co-members:"
        grep -A10 "$group:" "$MATRIX_FILE" | grep "^\s*- " | while read -r line; do
            local comp=$(echo "$line" | sed 's/^\s*- *//')
            if [ "$comp" != "$component" ]; then
                echo "    • $comp"
            fi
        done
    else
        echo "  (not in any group)"
    fi

    # Check for breaking changes
    echo ""
    echo "Breaking change history:"
    if grep -q "component: *\"*$component\"*" "$MATRIX_FILE" 2>/dev/null; then
        grep -B2 -A3 "component: *\"*$component\"*" "$MATRIX_FILE" | grep -E "(version:|date:|impacts:)" | while read -r line; do
            echo "  $line"
        done
    else
        echo "  (no breaking changes recorded)"
    fi
}

# Function: Display matrix summary
show_matrix() {
    echo -e "${BLUE}Compatibility Matrix Summary${NC}"
    echo "============================"

    if [ ! -f "$MATRIX_FILE" ]; then
        echo -e "${RED}Error: Compatibility matrix not found${NC}"
        return 1
    fi

    echo "Compatibility Groups:"
    grep -E "^\s+[a-z_]+:" "$MATRIX_FILE" | grep -B1 "components:" | grep -v "components:" | while read -r line; do
        local group=$(echo "$line" | sed 's/^\s*\([a-z_]*\):.*/\1/')
        if [ -n "$group" ] && [ "$group" != "--" ]; then
            local policy=$(grep -A5 "$group:" "$MATRIX_FILE" | grep "update_policy:" | sed 's/.*update_policy: *"\?\([^"]*\)"\?/\1/')
            echo "  • $group ($policy)"
        fi
    done

    echo ""
    echo "Components with dependencies:"
    local comp_count=0
    grep -E "^\s+[a-z-]+:" "$MATRIX_FILE" | grep -B1 "requires:" | grep -v "requires:" | while read -r line; do
        local comp=$(echo "$line" | sed 's/^\s*\([a-z-]*\):.*/\1/')
        if [ -n "$comp" ] && [ "$comp" != "--" ]; then
            echo "  • $comp"
            ((comp_count++))
        fi
    done

    echo ""
    echo "Matrix last updated: $(grep "last_updated:" "$MATRIX_FILE" | sed 's/.*last_updated: *"\?\([^"]*\)"\?/\1/')"
}

# Main command dispatcher
main() {
    case "${1:-}" in
        check)
            if [ $# -lt 2 ]; then
                echo "Usage: $(basename "$0") check <component> [version]"
                exit 1
            fi
            check_compatibility "$2" "${3:-}"
            ;;
        validate)
            validate_all
            ;;
        conflicts)
            find_conflicts
            ;;
        impact)
            if [ $# -lt 2 ]; then
                echo "Usage: $(basename "$0") impact <component>"
                exit 1
            fi
            show_impact "$2"
            ;;
        matrix)
            show_matrix
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
