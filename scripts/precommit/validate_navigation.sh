#!/bin/bash
# Navigation Integrity Validation Script
# Validates @ file references and navigation chains

set -e

ERROR_COUNT=0
TEMP_FILE=$(mktemp)
CHECKED_REFS=$(mktemp)

echo "🧭 Validating navigation integrity..."

# Function to log errors
log_error() {
    echo "❌ ERROR: $1" >&2
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

# Function to log success  
log_success() {
    echo "✅ $1"
}

# Function to check if file exists relative to .claude directory
file_exists_in_claude() {
    local ref="$1"
    local base_dir=".claude"
    
    # Remove leading @ symbol
    local clean_ref="${ref#@}"
    
    # Try different possible locations
    local possible_paths=(
        "$base_dir/$clean_ref"
        "$base_dir/context/foundation/$clean_ref"
        "$base_dir/context/claude-code/$clean_ref"
        "$base_dir/context/elevenlabs/$clean_ref"
        "$base_dir/context/operations/$clean_ref"
        "$base_dir/context/quality/$clean_ref"
        "$base_dir/context/ai-orchestration/$clean_ref"
        "$base_dir/context/prompts_research/$clean_ref"
        "$clean_ref"  # Absolute path case
    )
    
    for path in "${possible_paths[@]}"; do
        if [[ -f "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Function to validate @ references in a file
validate_at_references() {
    local file="$1"
    local file_errors=0
    
    # Extract all @ references
    grep -oE '@[a-zA-Z0-9_/.-]+\.(xml|md)' "$file" 2>/dev/null | sort -u | while read -r ref; do
        # Skip if already checked
        if grep -Fxq "$ref" "$CHECKED_REFS" 2>/dev/null; then
            continue
        fi
        
        echo "$ref" >> "$CHECKED_REFS"
        
        if resolved_path=$(file_exists_in_claude "$ref"); then
            echo "  ✓ $ref → $resolved_path"
        else
            log_error "Broken @ reference in $file: $ref"
            echo "    Searched in:"
            echo "      .claude/${ref#@}"
            echo "      .claude/context/*/${ref#@}"
            file_errors=$((file_errors + 1))
        fi
    done
    
    return $file_errors
}

# Function to validate markdown links to XML files  
validate_markdown_links() {
    local file="$1"
    
    # Extract markdown links to XML files
    grep -oE '\[([^\]]+)\]\(([^)]+\.xml)\)' "$file" 2>/dev/null | while read -r link; do
        # Extract the URL part
        local url=$(echo "$link" | sed 's/.*(\([^)]*\)).*/\1/')
        
        # Convert relative paths to absolute
        local dir=$(dirname "$file")
        local resolved_path
        
        if [[ "$url" =~ ^\./ ]]; then
            resolved_path="$dir/${url#./}"
        elif [[ "$url" =~ ^\.\. ]]; then
            resolved_path=$(realpath "$dir/$url" 2>/dev/null)
        else
            resolved_path="$url"
        fi
        
        if [[ ! -f "$resolved_path" ]]; then
            log_error "Broken markdown link in $file: $url"
            echo "    Link: $link"
            echo "    Resolved to: $resolved_path"
        fi
    done
}

# Function to validate navigation chains
validate_navigation_chains() {
    local file="$1"
    
    # Look for chain patterns like: @file1.xml → @file2.xml → @file3.xml
    grep -oE '@[a-zA-Z0-9_.-]+\.xml(\s*→\s*@[a-zA-Z0-9_.-]+\.xml)+' "$file" 2>/dev/null | while read -r chain; do
        echo "Validating chain: $chain"
        
        # Split chain into individual files
        echo "$chain" | tr '→' '\n' | sed 's/^\s*//;s/\s*$//' | while read -r ref; do
            if [[ -n "$ref" ]] && [[ "$ref" =~ ^@ ]]; then
                if ! file_exists_in_claude "$ref" >/dev/null; then
                    log_error "Broken chain link in $file: $ref (in chain: $chain)"
                fi
            fi
        done
    done
}

# Function to validate domain-specific paths
validate_domain_paths() {
    local file="$1"
    
    # Check for context/domain/ references
    grep -oE '@context/[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+\.(xml|md)' "$file" 2>/dev/null | while read -r ref; do
        local clean_ref="${ref#@}"
        if [[ ! -f ".claude/$clean_ref" ]]; then
            log_error "Broken domain path in $file: $ref"
            echo "    Expected at: .claude/$clean_ref"
        fi
    done
}

# Main validation loop
for file in "$@"; do
    if [[ -f "$file" ]] && [[ "$file" =~ \.(md|xml)$ ]]; then
        echo "Checking navigation in: $file"
        
        validate_at_references "$file"
        
        if [[ "$file" == *.md ]]; then
            validate_markdown_links "$file"
        fi
        
        validate_navigation_chains "$file"
        validate_domain_paths "$file"
    fi
done

# Cleanup
rm -f "$TEMP_FILE" "$CHECKED_REFS"

# Final results
if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "🎉 All navigation integrity checks passed!"
    exit 0
else
    echo "💥 Found $ERROR_COUNT navigation errors"
    echo ""
    echo "Common fixes:"
    echo "  - Update @ references to point to existing files"
    echo "  - Check file paths relative to .claude directory"
    echo "  - Verify markdown links point to existing XML files"
    echo "  - Ensure navigation chains are complete"
    echo ""
    echo "Navigation reference format:"
    echo "  @filename.xml (searches in .claude and context subdirectories)"
    echo "  @context/domain/filename.xml (explicit domain path)"
    exit 1
fi