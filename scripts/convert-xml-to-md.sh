#!/bin/bash

# convert-xml-to-md.sh - Transform XML documentation to pure Markdown with strategic semantic tags
# Part of AI Podcast System v1.0 - Minimum Viable Complexity initiative

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
BACKUP_DIR="$PROJECT_ROOT/.claude/archive/xml-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$PROJECT_ROOT/xml-to-md-conversion.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Warning logging
warn() {
    log "${YELLOW}WARNING: $1${NC}"
}

# Info logging
info() {
    log "${BLUE}INFO: $1${NC}"
}

# Initialize conversion
init_conversion() {
    info "Starting XML to Markdown conversion"
    info "Project root: $PROJECT_ROOT"
    info "Claude directory: $CLAUDE_DIR"
    info "Log file: $LOG_FILE"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    info "Backup directory: $BACKUP_DIR"
    
    # Clear log file
    > "$LOG_FILE"
}

# Convert XML content to Markdown
convert_xml_content() {
    local xml_file="$1"
    local md_file="$2"
    
    info "Converting: $xml_file -> $md_file"
    
    # Read the XML file
    if [[ ! -f "$xml_file" ]]; then
        error_exit "Source file not found: $xml_file"
    fi
    
    # Create output directory if needed
    mkdir -p "$(dirname "$md_file")"
    
    # Start conversion process
    {
        # Extract title from XML metadata or filename
        local title
        if grep -q "<title>" "$xml_file"; then
            title=$(grep -o "<title>[^<]*</title>" "$xml_file" | sed 's/<[^>]*>//g' | head -1)
        else
            title=$(basename "$xml_file" .xml | tr '_' ' ' | sed 's/\b\w/\U&/g')
        fi
        
        echo "# $title"
        echo ""
        
        # Extract key metadata if present
        if grep -q "<phase>" "$xml_file"; then
            local phase=$(grep -o "<phase>[^<]*</phase>" "$xml_file" | sed 's/<[^>]*>//g' | head -1)
            echo "**Phase:** $phase"
        fi
        
        if grep -q "<skill-level>" "$xml_file"; then
            local skill_level=$(grep -o "<skill-level>[^<]*</skill-level>" "$xml_file" | sed 's/<[^>]*>//g' | head -1)
            echo "**Skill Level:** $skill_level"
        fi
        
        if grep -q "<estimated-time>" "$xml_file"; then
            local time=$(grep -o "<estimated-time>[^<]*</estimated-time>" "$xml_file" | sed 's/<[^>]*>//g' | head -1)
            echo "**Estimated Time:** $time"
        fi
        echo ""
        
        # Process content while preserving dual explanations  
        awk '
        BEGIN { 
            in_technical = 0
            in_simple = 0
            in_meta = 0
            in_content = 0
        }
        
        # Skip XML header and document tags
        /^<\?xml/ { next }
        /^<document/ { next }
        /^<\/document>/ { next }
        
        # Skip metadata section entirely (we handle title above)
        /<metadata>/ { in_meta = 1; next }
        /<\/metadata>/ { in_meta = 0; next }
        in_meta { next }
        
        # Mark content start
        /<content>/ { in_content = 1; next }
        /<\/content>/ { in_content = 0; next }
        
        # Handle technical explanations
        /<technical-explanation>/ { 
            in_technical = 1
            print "\n<technical>"
            next 
        }
        /<\/technical-explanation>/ { 
            in_technical = 0
            print "</technical>"
            next 
        }
        
        # Handle simple explanations  
        /<simple-explanation>/ { 
            in_simple = 1
            print "\n<simple>"
            next 
        }
        /<\/simple-explanation>/ { 
            in_simple = 0
            print "</simple>\n"
            next 
        }
        
        # Handle sections - extract id/type for better headers
        /<section[^>]*>/ {
            section_line = $0
            title = ""
            # Extract id attribute if present
            if (match(section_line, /id="[^"]*"/)) {
                id_part = substr(section_line, RSTART, RLENGTH)
                gsub(/id="|"/, "", id_part)
                title = id_part
                gsub(/-/, " ", title)
                # Capitalize first letter of each word
                title = toupper(substr(title, 1, 1)) substr(title, 2)
            }
            if (title == "") title = "Section"
            print "\n## " title
            next 
        }
        /<\/section>/ { next }
        
        # Handle instructions as lists
        /<instructions>/ { print "\n### Setup Instructions\n"; next }
        /<\/instructions>/ { next }
        
        # Handle steps
        /<step[^>]*>/ { 
            print "\n- "
            # Extract step content without tags
            gsub(/<[^>]*>/, "")
            print $0
            next 
        }
        /<\/step>/ { next }
        
        # Handle examples
        /<example[^>]*>/ { print "\n**Example:**"; next }
        /<\/example>/ { print ""; next }
        /<implementation>/ { print "\n```bash"; next }
        /<\/implementation>/ { print "```\n"; next }
        
        # Handle validation commands
        /<validation-command[^>]*>/ { print "\n```bash"; next }
        /<\/validation-command>/ { print "```\n"; next }
        
        # Regular content lines - remove XML tags but keep content
        {
            # Only process if we are in content and not in metadata
            if (in_content || (!in_meta)) {
                line = $0
                gsub(/<[^>]*>/, "", line)
                # Clean up whitespace
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
                if (line != "" && line !~ /^[[:space:]]*$/) {
                    print line
                }
            }
        }
        ' "$xml_file"
        
        # Add footer with conversion info
        echo ""
        echo "---"
        echo ""
        echo "*Converted from XML to Markdown for elegant simplicity*"
        echo "*Original: $(basename "$xml_file")*"
        echo "*Conversion: $(date)*"
        
    } > "$md_file"
    
    success "Converted: $(basename "$xml_file")"
}

# Validate dual explanations are preserved
validate_dual_explanations() {
    local md_file="$1"
    
    if grep -q "<technical>" "$md_file" && grep -q "<simple>" "$md_file"; then
        return 0
    else
        warn "Missing dual explanations in: $(basename "$md_file")"
        return 1
    fi
}

# Process single file
convert_single_file() {
    local xml_file="$1"
    
    # Generate output path - handle both absolute and relative paths
    if [[ "$xml_file" = /* ]]; then
        # Absolute path
        local relative_path="${xml_file#$CLAUDE_DIR/}"
        local md_file="$CLAUDE_DIR/${relative_path%.xml}.md"
    else
        # Relative path
        local md_file="${xml_file%.xml}.md"
    fi
    
    # Backup original
    local backup_path
    if [[ "$xml_file" = /* ]]; then
        backup_path="${xml_file#$CLAUDE_DIR/}"
    else
        backup_path="$xml_file"
    fi
    local backup_file="$BACKUP_DIR/$backup_path"
    mkdir -p "$(dirname "$backup_file")"
    cp "$xml_file" "$backup_file"
    
    # Convert
    convert_xml_content "$xml_file" "$md_file"
    
    # Validate
    if validate_dual_explanations "$md_file"; then
        success "Validation passed: $(basename "$md_file")"
    fi
}

# Main conversion function
main() {
    init_conversion
    
    # Check if specific file provided
    if [[ $# -eq 1 ]]; then
        info "Single file mode: $1"
        convert_single_file "$1"
        exit 0
    fi
    
    # Check if test mode
    if [[ "${1:-}" == "--test" ]]; then
        info "Test mode: Converting first file only"
        local test_file
        test_file=$(find "$CLAUDE_DIR" -name "*.xml" | head -1)
        if [[ -n "$test_file" ]]; then
            convert_single_file "$test_file"
        else
            error_exit "No XML files found for testing"
        fi
        exit 0
    fi
    
    # Batch mode - process all XML files
    info "Batch mode: Converting all XML files"
    
    local count=0
    local success_count=0
    local failed_files=()
    
    while IFS= read -r xml_file; do
        if [[ -f "$xml_file" ]]; then
            ((count++))
            info "Processing $count: $(basename "$xml_file")"
            
            if convert_single_file "$xml_file"; then
                ((success_count++))
            else
                failed_files+=("$xml_file")
            fi
        fi
    done < <(find "$CLAUDE_DIR" -name "*.xml" -type f)
    
    # Summary
    info "Conversion complete"
    success "Successfully converted: $success_count/$count files"
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        warn "Failed conversions:"
        printf '%s\n' "${failed_files[@]}"
    fi
    
    info "Backup location: $BACKUP_DIR"
    info "Log file: $LOG_FILE"
}

# Script usage
usage() {
    echo "Usage: $0 [file.xml|--test]"
    echo ""
    echo "Modes:"
    echo "  $0                  - Convert all XML files to Markdown"
    echo "  $0 file.xml         - Convert single file"
    echo "  $0 --test           - Test conversion on first file only"
    echo ""
    echo "Features:"
    echo "  - Preserves dual explanations with <technical> and <simple> tags"
    echo "  - Maintains learning connections"
    echo "  - Creates automatic backups"
    echo "  - Validates conversion quality"
    echo "  - Generates detailed logs"
}

# Handle help
if [[ $# -gt 0 && ("$1" == "-h" || "$1" == "--help") ]]; then
    usage
    exit 0
fi

# Run main function
main "$@"