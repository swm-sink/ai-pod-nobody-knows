#!/bin/bash
# XML Validation Script for ai-podcasts-nobody-knows
# Validates XML syntax, encoding, and structure

set -e

ERROR_COUNT=0
TEMP_FILE=$(mktemp)

echo "🔍 Validating XML files..."

# Function to log errors
log_error() {
    echo "❌ ERROR: $1" >&2
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

# Function to log success  
log_success() {
    echo "✅ $1"
}

# Function to validate XML well-formedness
validate_xml_syntax() {
    local file="$1"
    
    if ! xmllint --noout "$file" 2>"$TEMP_FILE"; then
        log_error "XML syntax error in $file:"
        cat "$TEMP_FILE" >&2
        return 1
    fi
    return 0
}

# Function to validate XML encoding declaration
validate_xml_encoding() {
    local file="$1"
    
    # Check for UTF-8 encoding declaration
    if ! head -1 "$file" | grep -q 'encoding="UTF-8"'; then
        log_error "Missing or incorrect UTF-8 encoding declaration in $file"
        echo "  Expected: <?xml version=\"1.0\" encoding=\"UTF-8\"?>" >&2
        echo "  Found: $(head -1 "$file")" >&2
        return 1
    fi
    return 0
}

# Function to validate our custom XML structure
validate_xml_structure() {
    local file="$1"
    
    # Skip if it's a template or archive file
    if [[ "$file" == *"/templates/"* ]] || [[ "$file" == *"/archive/"* ]]; then
        return 0
    fi
    
    # Check for required document structure in context files
    if [[ "$file" == *"/context/"* ]]; then
        if ! grep -q '<document.*type=' "$file"; then
            log_error "Missing document type declaration in $file"
            echo "  Expected: <document type=\"...\" domain=\"...\" version=\"...\">" >&2
            return 1
        fi
        
        if ! grep -q '<metadata>' "$file"; then
            log_error "Missing metadata section in $file"
            return 1
        fi
    fi
    
    return 0
}

# Function to validate XML formatting consistency
validate_xml_formatting() {
    local file="$1"
    
    # Check for consistent indentation (2 or 4 spaces, no tabs)
    if grep -q $'\t' "$file"; then
        log_error "XML file $file contains tabs - use spaces for indentation"
        return 1
    fi
    
    # Check for trailing whitespace (already handled by pre-commit, but double-check critical files)
    if grep -q ' $' "$file"; then
        log_error "XML file $file contains trailing whitespace"
        return 1
    fi
    
    return 0
}

# Main validation loop
for file in "$@"; do
    if [[ "$file" == *.xml ]]; then
        echo "Validating: $file"
        
        # Skip deleted files
        if [[ ! -f "$file" ]]; then
            continue
        fi
        
        # Run all validations
        if validate_xml_syntax "$file" && \
           validate_xml_encoding "$file" && \
           validate_xml_structure "$file" && \
           validate_xml_formatting "$file"; then
            log_success "XML validation passed for $file"
        fi
    fi
done

# Cleanup
rm -f "$TEMP_FILE"

# Final results
if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "🎉 All XML validation checks passed!"
    exit 0
else
    echo "💥 Found $ERROR_COUNT XML validation errors"
    echo ""
    echo "Common fixes:"
    echo "  - Add proper XML declaration: <?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    echo "  - Fix syntax errors with matching tags"
    echo "  - Add required metadata sections to context files"
    echo "  - Use spaces instead of tabs for indentation"
    exit 1
fi