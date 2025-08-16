#!/bin/bash

# Version Manager for Level-1-Dev Components
# Manages semantic versioning across all components

set -euo pipefail

# Color output for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVEL1_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSIONS_DIR="$LEVEL1_DIR/versions"
MANIFESTS_DIR="$VERSIONS_DIR/manifests"
HISTORY_DIR="$VERSIONS_DIR/history"
SCHEMA_FILE="$VERSIONS_DIR/schema.yaml"

# Ensure directories exist
mkdir -p "$MANIFESTS_DIR" "$HISTORY_DIR"

# Function: Display help
show_help() {
    cat << EOF
Version Manager for Level-1-Dev Components

Usage: $(basename "$0") <command> [options]

Commands:
    init <component> <type>     Initialize version tracking for component
    bump <component> <level>    Bump version (major|minor|patch)
    tag <component> [message]   Create git tag for component version
    check <component>           Check component compatibility
    list                        List all versioned components
    history <component>         Show version history
    rollback <component>        Rollback to previous version
    validate                    Validate all version manifests
    changelog <component>       Generate changelog
    status                      Show version status of all components

Options:
    -h, --help                  Show this help message
    -v, --verbose              Enable verbose output
    -d, --dry-run              Show what would be done without making changes

Examples:
    $(basename "$0") init agent-builder agent
    $(basename "$0") bump agent-builder minor
    $(basename "$0") tag agent-builder "Added new validation features"
    $(basename "$0") check agent-builder
    $(basename "$0") history agent-builder

EOF
}

# Function: Parse semantic version
parse_version() {
    local version=$1
    if [[ $version =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
    else
        echo "Invalid version format: $version" >&2
        return 1
    fi
}

# Function: Initialize version tracking for component
init_version() {
    local component=$1
    local type=$2
    local manifest_file="$MANIFESTS_DIR/${component}.yaml"

    if [ -f "$manifest_file" ]; then
        echo -e "${YELLOW}Warning: Manifest already exists for $component${NC}"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Initialization cancelled"
            return 1
        fi
    fi

    # Create initial manifest
    cat > "$manifest_file" << EOF
# Version manifest for $component
name: "$component"
type: "$type"
version: "0.1.0"
created: "$(date +%Y-%m-%d)"
updated: "$(date +%Y-%m-%d)"
status: "experimental"
author: "$(git config user.name 2>/dev/null || echo 'unknown')"
description: "Component $component of type $type"

dependencies: []

changelog:
  - version: "0.1.0"
    date: "$(date +%Y-%m-%d)"
    changes:
      - "Initial version"
    breaking: false

compatibility:
  min_claude_version: "2.0.0"
  required_tools: []

tags:
  - "level-1-dev"
  - "$type"
EOF

    echo -e "${GREEN}✓ Initialized version tracking for $component${NC}"
    echo "  Type: $type"
    echo "  Version: 0.1.0"
    echo "  Manifest: $manifest_file"
}

# Function: Bump version
bump_version() {
    local component=$1
    local level=$2
    local manifest_file="$MANIFESTS_DIR/${component}.yaml"

    if [ ! -f "$manifest_file" ]; then
        echo -e "${RED}Error: No manifest found for $component${NC}"
        echo "Run: $(basename "$0") init $component <type>"
        return 1
    fi

    # Get current version
    local current_version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
    read -r major minor patch <<< $(parse_version "$current_version")

    # Bump based on level
    case $level in
        major)
            new_version="$((major + 1)).0.0"
            breaking=true
            ;;
        minor)
            new_version="$major.$((minor + 1)).0"
            breaking=false
            ;;
        patch)
            new_version="$major.$minor.$((patch + 1))"
            breaking=false
            ;;
        *)
            echo -e "${RED}Error: Invalid bump level. Use major, minor, or patch${NC}"
            return 1
            ;;
    esac

    # Backup current manifest
    cp "$manifest_file" "$HISTORY_DIR/${component}_$(date +%Y%m%d_%H%M%S).yaml"

    # Update version in manifest
    sed -i.bak "s/^version:.*/version: \"$new_version\"/" "$manifest_file"
    sed -i.bak "s/^updated:.*/updated: \"$(date +%Y-%m-%d)\"/" "$manifest_file"
    rm "${manifest_file}.bak"

    # Add changelog entry (insert after "changelog:" line)
    local changelog_entry="  - version: \"$new_version\"
    date: \"$(date +%Y-%m-%d)\"
    changes:
      - \"Version bump: $level\"
    breaking: $breaking"

    # Use awk to insert changelog entry
    awk -v entry="$changelog_entry" '/^changelog:/ {print; print entry; next} {print}' "$manifest_file" > "${manifest_file}.tmp"
    mv "${manifest_file}.tmp" "$manifest_file"

    echo -e "${GREEN}✓ Bumped $component version${NC}"
    echo "  Previous: $current_version"
    echo "  New: $new_version"
    echo "  Level: $level"

    # Update component file if it exists
    update_component_version "$component" "$new_version"
}

# Function: Update version in component file
update_component_version() {
    local component=$1
    local version=$2

    # Try to find component file
    local component_files=(
        "$LEVEL1_DIR/agents/${component}.md"
        "$LEVEL1_DIR/commands/${component}.sh"
        "$LEVEL1_DIR/templates/${component}.yaml"
        "$LEVEL1_DIR/workflows/${component}.yaml"
    )

    for file in "${component_files[@]}"; do
        if [ -f "$file" ]; then
            # Update version header
            if grep -q "^# Version:" "$file" 2>/dev/null; then
                sed -i.bak "s/^# Version:.*/# Version: $version/" "$file"
            elif grep -q "^version:" "$file" 2>/dev/null; then
                sed -i.bak "s/^version:.*/version: \"$version\"/" "$file"
            else
                # Add version header if missing
                echo -e "# Version: $version\n$(cat "$file")" > "$file"
            fi
            rm -f "${file}.bak"
            echo "  Updated: $file"
        fi
    done
}

# Function: Create git tag
tag_release() {
    local component=$1
    local message=${2:-"Release $component"}
    local manifest_file="$MANIFESTS_DIR/${component}.yaml"

    if [ ! -f "$manifest_file" ]; then
        echo -e "${RED}Error: No manifest found for $component${NC}"
        return 1
    fi

    # Get current version
    local version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
    local tag_name="${component}-v${version}"

    # Check if tag already exists
    if git tag -l "$tag_name" | grep -q .; then
        echo -e "${YELLOW}Warning: Tag $tag_name already exists${NC}"
        return 1
    fi

    # Create annotated tag
    git tag -a "$tag_name" -m "$message"

    echo -e "${GREEN}✓ Created git tag: $tag_name${NC}"
    echo "  Message: $message"
    echo "  Push with: git push origin $tag_name"
}

# Function: Check component compatibility
check_compatibility() {
    local component=$1
    local manifest_file="$MANIFESTS_DIR/${component}.yaml"

    if [ ! -f "$manifest_file" ]; then
        echo -e "${RED}Error: No manifest found for $component${NC}"
        return 1
    fi

    echo -e "${BLUE}Checking compatibility for $component...${NC}"

    # Check dependencies
    echo "Dependencies:"
    grep -A 10 "^dependencies:" "$manifest_file" | grep "  - name:" | while read -r line; do
        local dep_name=$(echo "$line" | sed 's/.*name: *"\?\([^"]*\)"\?/\1/')
        local dep_manifest="$MANIFESTS_DIR/${dep_name}.yaml"

        if [ -f "$dep_manifest" ]; then
            local dep_version=$(grep "^version:" "$dep_manifest" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
            echo -e "  ${GREEN}✓${NC} $dep_name: $dep_version"
        else
            echo -e "  ${RED}✗${NC} $dep_name: NOT FOUND"
        fi
    done

    # Check required tools
    echo "Required tools:"
    grep -A 10 "required_tools:" "$manifest_file" | grep "  - " | while read -r line; do
        local tool=$(echo "$line" | sed 's/  - *"\?\([^"]*\)"\?/\1/')
        echo "  • $tool"
    done

    echo -e "${GREEN}✓ Compatibility check complete${NC}"
}

# Function: List all versioned components
list_components() {
    echo -e "${BLUE}Versioned Components:${NC}"
    echo "---------------------"

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local name=$(grep "^name:" "$manifest" | sed 's/name: *"\?\([^"]*\)"\?/\1/')
                local version=$(grep "^version:" "$manifest" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
                local type=$(grep "^type:" "$manifest" | sed 's/type: *"\?\([^"]*\)"\?/\1/')
                local status=$(grep "^status:" "$manifest" | sed 's/status: *"\?\([^"]*\)"\?/\1/')

                printf "%-25s %-10s %-15s %s\n" "$name" "$version" "$type" "$status"
            fi
        done
    else
        echo "No versioned components found"
    fi
}

# Function: Show version history
show_history() {
    local component=$1
    local manifest_file="$MANIFESTS_DIR/${component}.yaml"

    if [ ! -f "$manifest_file" ]; then
        echo -e "${RED}Error: No manifest found for $component${NC}"
        return 1
    fi

    echo -e "${BLUE}Version History for $component:${NC}"
    echo "--------------------------------"

    # Extract and display changelog
    awk '/^changelog:/{flag=1; next} /^[a-z]/{flag=0} flag' "$manifest_file" | \
    awk '/^  - version:/{
        if (NR>1) print ""
        gsub(/"/, "", $3)
        printf "Version %s", $3
    }
    /^    date:/{
        gsub(/"/, "", $2)
        printf " (%s)\n", $2
    }
    /^      - /{
        sub(/^      - /, "  • ")
        print
    }
    /^    breaking:/{
        if ($2 == "true") print "  ⚠️  BREAKING CHANGE"
    }'
}

# Function: Validate all manifests
validate_manifests() {
    echo -e "${BLUE}Validating all version manifests...${NC}"

    local errors=0

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local name=$(basename "$manifest" .yaml)

                # Check required fields
                local required_fields=("name" "type" "version" "created" "updated" "status")
                for field in "${required_fields[@]}"; do
                    if ! grep -q "^$field:" "$manifest"; then
                        echo -e "  ${RED}✗${NC} $name: Missing required field '$field'"
                        ((errors++))
                    fi
                done

                # Validate version format
                local version=$(grep "^version:" "$manifest" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
                if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo -e "  ${RED}✗${NC} $name: Invalid version format '$version'"
                    ((errors++))
                fi

                if [ $errors -eq 0 ]; then
                    echo -e "  ${GREEN}✓${NC} $name: Valid"
                fi
            fi
        done
    else
        echo "No manifests found to validate"
    fi

    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✓ All manifests valid${NC}"
    else
        echo -e "${RED}✗ Found $errors validation errors${NC}"
        return 1
    fi
}

# Main command dispatcher
main() {
    case "${1:-}" in
        init)
            if [ $# -lt 3 ]; then
                echo "Usage: $(basename "$0") init <component> <type>"
                exit 1
            fi
            init_version "$2" "$3"
            ;;
        bump)
            if [ $# -lt 3 ]; then
                echo "Usage: $(basename "$0") bump <component> <level>"
                exit 1
            fi
            bump_version "$2" "$3"
            ;;
        tag)
            if [ $# -lt 2 ]; then
                echo "Usage: $(basename "$0") tag <component> [message]"
                exit 1
            fi
            tag_release "$2" "${3:-}"
            ;;
        check)
            if [ $# -lt 2 ]; then
                echo "Usage: $(basename "$0") check <component>"
                exit 1
            fi
            check_compatibility "$2"
            ;;
        list)
            list_components
            ;;
        history)
            if [ $# -lt 2 ]; then
                echo "Usage: $(basename "$0") history <component>"
                exit 1
            fi
            show_history "$2"
            ;;
        validate)
            validate_manifests
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            echo "Unknown command: ${1:-}"
            echo "Run '$(basename "$0") --help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
