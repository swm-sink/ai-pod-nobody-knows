#!/bin/bash

# fix-xml-references.sh - Update XML references to Markdown in converted files
# Part of elegant simplicity initiative - fixing reference impacts

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
LOG_FILE="$PROJECT_ROOT/reference-fix.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "${RED}ERROR: $1${NC}"
    exit 1
}

# Success logging
success() {
    log "${GREEN}SUCCESS: $1${NC}"
}

# Info logging
info() {
    log "${BLUE}INFO: $1${NC}"
}

# Fix XML references to Markdown
fix_xml_references() {
    local file="$1"
    local changes=0
    
    # Skip if file doesn't exist or is in archive
    if [[ ! -f "$file" ]] || [[ "$file" == *archive* ]]; then
        return 0
    fi
    
    info "Processing: $(basename "$file")"
    
    # Create backup
    cp "$file" "${file}.backup"
    
    # Fix common reference patterns
    sed -i '' \
        -e 's/\.xml"/.md"/g' \
        -e "s/\.xml'/.md'/g" \
        -e 's/\.xml)/.md)/g' \
        -e 's/\.xml>/.md>/g' \
        -e 's/@import [^}]*\.xml/@import \&.md/g' \
        -e 's/file="[^"]*\.xml"/file="\&.md"/g' \
        -e 's/\.\.\///g' \
        "$file"
    
    # Count changes by comparing with backup
    if ! diff -q "$file" "${file}.backup" > /dev/null 2>&1; then
        changes=$(diff "$file" "${file}.backup" | wc -l)
        success "Updated $changes lines in $(basename "$file")"
        rm "${file}.backup"
        return 1
    else
        # No changes needed
        rm "${file}.backup"
        return 0
    fi
}

# Main function
main() {
    info "Starting XML reference cleanup"
    info "Project root: $PROJECT_ROOT"
    info "Log file: $LOG_FILE"
    
    # Clear log file
    > "$LOG_FILE"
    
    local total_files=0
    local changed_files=0
    
    # Process all markdown files in .claude directory
    while IFS= read -r -d '' file; do
        ((total_files++))
        if fix_xml_references "$file"; then
            ((changed_files++))
        fi
    done < <(find "$CLAUDE_DIR" -name "*.md" -type f -print0)
    
    info "Processed $total_files files"
    success "Updated $changed_files files with reference fixes"
    
    # Validate no broken references remain
    local remaining_refs
    remaining_refs=$(grep -r "\.xml" "$CLAUDE_DIR" --exclude-dir=archive | grep -v "\.xml:" | wc -l)
    
    if [[ $remaining_refs -eq 0 ]]; then
        success "All XML references successfully updated to Markdown"
    else
        log "${YELLOW}WARNING: $remaining_refs XML references still remain${NC}"
        info "Run: grep -r '\.xml' .claude --exclude-dir=archive | grep -v '\.xml:' | head -5"
    fi
}

# Run main function
main "$@"