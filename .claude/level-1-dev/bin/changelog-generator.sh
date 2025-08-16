#!/bin/bash

# Changelog Generator for Level-1-Dev Components
# Generates formatted changelogs from version manifests

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
CHANGELOG_DIR="$LEVEL1_DIR/changelogs"

# Ensure directories exist
mkdir -p "$CHANGELOG_DIR"

# Function: Display help
show_help() {
    cat << EOF
Changelog Generator for Level-1-Dev Components

Usage: $(basename "$0") <command> [options]

Commands:
    generate <component>    Generate changelog for specific component
    generate-all           Generate changelogs for all components
    markdown <component>   Generate markdown changelog
    json <component>       Generate JSON changelog
    summary               Generate summary of recent changes

Options:
    -h, --help            Show this help message
    -o, --output <file>   Output to file instead of stdout
    -f, --format <fmt>    Output format (markdown|json|text)
    -l, --limit <n>       Limit to last n versions

Examples:
    $(basename "$0") generate agent-builder
    $(basename "$0") generate-all
    $(basename "$0") markdown agent-builder -o CHANGELOG.md
    $(basename "$0") summary -l 10

EOF
}

# Function: Generate markdown changelog
generate_markdown_changelog() {
    local component=$1
    local manifest_file="$MANIFESTS_DIR/${component}.yaml"

    if [ ! -f "$manifest_file" ]; then
        echo -e "${RED}Error: No manifest found for $component${NC}" >&2
        return 1
    fi

    # Extract component info
    local name=$(grep "^name:" "$manifest_file" | sed 's/name: *"\?\([^"]*\)"\?/\1/')
    local type=$(grep "^type:" "$manifest_file" | sed 's/type: *"\?\([^"]*\)"\?/\1/')
    local current_version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
    local description=$(grep "^description:" "$manifest_file" | sed 's/description: *"\?\([^"]*\)"\?/\1/')

    echo "# Changelog: $name"
    echo ""
    echo "**Type:** $type  "
    echo "**Current Version:** $current_version  "
    echo "**Description:** $description  "
    echo ""
    echo "## Version History"
    echo ""

    # Parse changelog entries
    local in_changelog=0
    local version=""
    local date=""
    local breaking=""

    while IFS= read -r line; do
        if [[ $line =~ ^changelog: ]]; then
            in_changelog=1
        elif [[ $in_changelog -eq 1 ]]; then
            if [[ $line =~ ^[a-z] ]] && ! [[ $line =~ ^\ \ - ]]; then
                in_changelog=0
            elif [[ $line =~ ^\ \ -\ version:\ \"(.*)\" ]]; then
                version="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^\ \ \ \ date:\ \"(.*)\" ]]; then
                date="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^\ \ \ \ breaking:\ (.*) ]]; then
                breaking="${BASH_REMATCH[1]}"

                # Output version header
                echo "### Version $version ($date)"
                if [ "$breaking" = "true" ]; then
                    echo "**⚠️ BREAKING CHANGES**"
                fi
                echo ""
            elif [[ $line =~ ^\ \ \ \ \ \ -\ \"(.*)\" ]] || [[ $line =~ ^\ \ \ \ \ \ -\ (.*) ]]; then
                local change="${BASH_REMATCH[1]}"
                echo "- $change"
            fi
        fi
    done < "$manifest_file"

    echo ""
    echo "---"
    echo "_Generated: $(date '+%Y-%m-%d %H:%M:%S')_"
}

# Function: Generate JSON changelog
generate_json_changelog() {
    local component=$1
    local manifest_file="$MANIFESTS_DIR/${component}.yaml"

    if [ ! -f "$manifest_file" ]; then
        echo -e "${RED}Error: No manifest found for $component${NC}" >&2
        return 1
    fi

    # Start JSON
    echo "{"

    # Component info
    local name=$(grep "^name:" "$manifest_file" | sed 's/name: *"\?\([^"]*\)"\?/\1/')
    local type=$(grep "^type:" "$manifest_file" | sed 's/type: *"\?\([^"]*\)"\?/\1/')
    local current_version=$(grep "^version:" "$manifest_file" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

    echo "  \"component\": \"$name\","
    echo "  \"type\": \"$type\","
    echo "  \"current_version\": \"$current_version\","
    echo "  \"changelog\": ["

    # Parse changelog entries (simplified for JSON)
    local first_entry=1
    awk '/^changelog:/{flag=1; next} /^[a-z]/{flag=0} flag && /^  - version:/' "$manifest_file" | while read -r line; do
        if [ $first_entry -eq 0 ]; then
            echo ","
        fi
        first_entry=0

        # Extract version info
        local version=$(echo "$line" | sed 's/.*version: *"\?\([^"]*\)"\?/\1/')
        echo -n "    {\"version\": \"$version\"}"
    done

    echo ""
    echo "  ],"
    echo "  \"generated\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\""
    echo "}"
}

# Function: Generate changelog for all components
generate_all_changelogs() {
    local format=${1:-markdown}

    echo -e "${BLUE}Generating changelogs for all components...${NC}"

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)
                local output_file="$CHANGELOG_DIR/${component}.md"

                echo -n "  Generating changelog for $component..."

                if [ "$format" = "markdown" ]; then
                    generate_markdown_changelog "$component" > "$output_file"
                elif [ "$format" = "json" ]; then
                    output_file="$CHANGELOG_DIR/${component}.json"
                    generate_json_changelog "$component" > "$output_file"
                fi

                echo -e " ${GREEN}✓${NC}"
            fi
        done
    else
        echo "No components found"
    fi

    echo -e "${GREEN}✓ All changelogs generated${NC}"
}

# Function: Generate summary of recent changes
generate_summary() {
    local limit=${1:-10}

    echo -e "${BLUE}Recent Changes Summary (last $limit entries)${NC}"
    echo "================================================"
    echo ""

    # Collect all changes with timestamps
    local temp_file=$(mktemp)

    if [ -d "$MANIFESTS_DIR" ] && [ "$(ls -A "$MANIFESTS_DIR" 2>/dev/null)" ]; then
        for manifest in "$MANIFESTS_DIR"/*.yaml; do
            if [ -f "$manifest" ]; then
                local component=$(basename "$manifest" .yaml)

                # Extract recent changes
                awk -v comp="$component" '
                    /^changelog:/{flag=1; next}
                    /^[a-z]/{flag=0}
                    flag && /^  - version:/{
                        version=$3
                        gsub(/"/, "", version)
                    }
                    flag && /^    date:/{
                        date=$2
                        gsub(/"/, "", date)
                    }
                    flag && /^      - /{
                        sub(/^      - /, "")
                        gsub(/"/, "")
                        print date "\t" comp "\t" version "\t" $0
                    }
                ' "$manifest"
            fi
        done | sort -r | head -n "$limit" > "$temp_file"
    fi

    # Display formatted summary
    if [ -s "$temp_file" ]; then
        echo "Date       | Component            | Version | Change"
        echo "-----------|---------------------|---------|-------"
        while IFS=$'\t' read -r date component version change; do
            printf "%-10s | %-19s | %-7s | %s\n" "$date" "$component" "$version" "$change"
        done < "$temp_file"
    else
        echo "No recent changes found"
    fi

    rm -f "$temp_file"
    echo ""
}

# Main command dispatcher
main() {
    local output_file=""
    local format="markdown"
    local limit=10

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -f|--format)
                format="$2"
                shift 2
                ;;
            -l|--limit)
                limit="$2"
                shift 2
                ;;
            generate)
                if [ -z "${2:-}" ]; then
                    echo "Error: Component name required"
                    exit 1
                fi
                if [ -n "$output_file" ]; then
                    generate_markdown_changelog "$2" > "$output_file"
                else
                    generate_markdown_changelog "$2"
                fi
                exit 0
                ;;
            generate-all)
                generate_all_changelogs "$format"
                exit 0
                ;;
            markdown)
                if [ -z "${2:-}" ]; then
                    echo "Error: Component name required"
                    exit 1
                fi
                if [ -n "$output_file" ]; then
                    generate_markdown_changelog "$2" > "$output_file"
                else
                    generate_markdown_changelog "$2"
                fi
                exit 0
                ;;
            json)
                if [ -z "${2:-}" ]; then
                    echo "Error: Component name required"
                    exit 1
                fi
                if [ -n "$output_file" ]; then
                    generate_json_changelog "$2" > "$output_file"
                else
                    generate_json_changelog "$2"
                fi
                exit 0
                ;;
            summary)
                generate_summary "$limit"
                exit 0
                ;;
            *)
                echo "Unknown command: $1"
                echo "Run '$(basename "$0") --help' for usage"
                exit 1
                ;;
        esac
    done

    # No command specified
    show_help
}

# Run main function
main "$@"
