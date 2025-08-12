#!/bin/bash
# Naming Convention Validation Script
# Ensures consistent file naming across the project

set -e

ERROR_COUNT=0
WARNING_COUNT=0

echo "📝 Validating file naming conventions..."

# Function to log errors
log_error() {
    echo "❌ ERROR: $1" >&2
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

# Function to log warnings
log_warning() {
    echo "⚠️  WARNING: $1" >&2
    WARNING_COUNT=$((WARNING_COUNT + 1))
}

# Function to log success  
log_success() {
    echo "✅ $1"
}

# Function to validate XML file naming in context directories
validate_xml_naming() {
    local file="$1"
    local basename=$(basename "$file")
    local dirname=$(dirname "$file")
    
    # Skip certain directories
    if [[ "$dirname" == *"/archive/"* ]] || 
       [[ "$dirname" == *"/templates/"* ]]; then
        return 0
    fi
    
    # Context XML files should follow numbered_underscore.xml pattern
    if [[ "$dirname" == *"/context/"* ]]; then
        if [[ "$basename" =~ ^[0-9]{2}_[a-z0-9_]+\.xml$ ]]; then
            log_success "Naming convention correct: $file"
        elif [[ "$basename" =~ ^00_[a-z0-9_]+_constants\.xml$ ]]; then
            log_success "Constants file naming correct: $file"
        elif [[ "$basename" == "README.xml" ]] || 
             [[ "$basename" == "NAVIGATION.xml" ]] ||
             [[ "$basename" == "ENFORCEMENT_STANDARDS.xml" ]]; then
            log_success "Special file naming correct: $file"
        else
            log_error "XML naming convention violation: $file"
            echo "    Expected: ##_descriptive_name.xml (e.g., 01_project_overview.xml)"
            echo "    Or: 00_domain_constants.xml for constants files"
            echo "    Found: $basename"
            return 1
        fi
    fi
    
    # Level directories have specific patterns
    if [[ "$dirname" == *"/level-"*"/agents/"* ]]; then
        if [[ "$basename" =~ ^[0-9]{2}_[a-z0-9_]+\.md$ ]]; then
            log_success "Agent naming correct: $file"
        else
            log_error "Agent naming convention violation: $file"
            echo "    Expected: ##_agent_name.md (e.g., 01_research_coordinator.md)"
            return 1
        fi
    fi
    
    return 0
}

# Function to validate markdown file naming
validate_md_naming() {
    local file="$1"
    local basename=$(basename "$file")
    local dirname=$(dirname "$file")
    
    # Skip archive
    if [[ "$dirname" == *"/archive/"* ]]; then
        return 0
    fi
    
    # Special files that are allowed
    if [[ "$basename" == "README.md" ]] || 
       [[ "$basename" == "CLAUDE.md" ]] ||
       [[ "$basename" == "NAVIGATION_INDEX.md" ]]; then
        log_success "Special MD file naming correct: $file"
        return 0
    fi
    
    # Agent files
    if [[ "$dirname" == *"/agents/"* ]]; then
        if [[ "$basename" =~ ^[0-9]{2}_[a-z0-9_]+\.md$ ]]; then
            log_success "Agent MD naming correct: $file"
        else
            log_error "Agent MD naming convention violation: $file"
            echo "    Expected: ##_agent_name.md"
            return 1
        fi
    fi
    
    # Command files  
    if [[ "$dirname" == *"/commands/"* ]]; then
        if [[ "$basename" =~ ^[a-z0-9_-]+\.md$ ]]; then
            log_success "Command naming correct: $file"
        else
            log_error "Command naming convention violation: $file"
            echo "    Expected: kebab-case-name.md or snake_case_name.md"
            return 1
        fi
    fi
    
    # Other MD files should generally be XML
    if [[ "$dirname" == *"/context/"* ]]; then
        log_warning "Markdown file in context directory: $file"
        echo "    Consider converting to XML unless it's navigation/index file"
    fi
    
    return 0
}

# Function to validate YAML file naming
validate_yaml_naming() {
    local file="$1"
    local basename=$(basename "$file")
    
    # YAML files should use kebab-case or snake_case
    if [[ "$basename" =~ ^[a-z0-9_-]+\.(yaml|yml)$ ]]; then
        log_success "YAML naming correct: $file"
    else
        log_error "YAML naming convention violation: $file"
        echo "    Expected: kebab-case-name.yaml or snake_case_name.yaml"
        echo "    Avoid spaces, capitals, and special characters"
        return 1
    fi
    
    return 0
}

# Function to validate JSON file naming
validate_json_naming() {
    local file="$1"
    local basename=$(basename "$file")
    
    # JSON files should use kebab-case or snake_case
    if [[ "$basename" =~ ^[a-z0-9_-]+\.json$ ]]; then
        log_success "JSON naming correct: $file"
    else
        log_error "JSON naming convention violation: $file"
        echo "    Expected: kebab-case-name.json or snake_case_name.json"
        echo "    Avoid spaces, capitals, and special characters"
        return 1
    fi
    
    return 0
}

# Function to check for forbidden characters
check_forbidden_characters() {
    local file="$1"
    local basename=$(basename "$file")
    
    # Check for spaces in filenames
    if [[ "$basename" == *" "* ]]; then
        log_error "Filename contains spaces: $file"
        echo "    Replace spaces with underscores or hyphens"
        return 1
    fi
    
    # Check for special characters that cause issues
    if [[ "$basename" =~ [^a-zA-Z0-9._-] ]]; then
        log_error "Filename contains forbidden characters: $file"
        echo "    Use only letters, numbers, dots, underscores, and hyphens"
        return 1
    fi
    
    return 0
}

# Function to validate directory structure compliance
validate_directory_placement() {
    local file="$1"
    local dirname=$(dirname "$file")
    
    # Check that XML files are in appropriate locations
    if [[ "$file" == *.xml ]]; then
        if [[ "$dirname" != *"/context/"* ]] && 
           [[ "$dirname" != *"/config/"* ]] && 
           [[ "$dirname" != *"/shared/"* ]] && 
           [[ "$dirname" != *"/level-"* ]] &&
           [[ "$dirname" != ".claude" ]]; then
            log_warning "XML file outside standard directories: $file"
            echo "    Consider moving to .claude/context/, .claude/config/, or .claude/shared/"
        fi
    fi
    
    return 0
}

# Main validation function
validate_file_naming() {
    local file="$1"
    local errors=0
    
    echo "Checking naming for: $file"
    
    # Check forbidden characters first
    if ! check_forbidden_characters "$file"; then
        errors=$((errors + 1))
    fi
    
    # Validate based on file extension
    case "$file" in
        *.xml)
            if ! validate_xml_naming "$file"; then
                errors=$((errors + 1))
            fi
            ;;
        *.md)
            if ! validate_md_naming "$file"; then
                errors=$((errors + 1))
            fi
            ;;
        *.yaml|*.yml)
            if ! validate_yaml_naming "$file"; then
                errors=$((errors + 1))
            fi
            ;;
        *.json)
            if ! validate_json_naming "$file"; then
                errors=$((errors + 1))
            fi
            ;;
    esac
    
    # Check directory placement
    validate_directory_placement "$file"
    
    return $errors
}

# Main validation loop
for file in "$@"; do
    if [[ -f "$file" ]]; then
        validate_file_naming "$file"
    fi
done

# Final results
echo ""
echo "📊 Naming Convention Summary:"
echo "   Errors: $ERROR_COUNT"
echo "   Warnings: $WARNING_COUNT"

if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "🎉 All naming convention checks passed!"
    if [[ $WARNING_COUNT -gt 0 ]]; then
        echo "⚠️  Consider addressing $WARNING_COUNT warnings for consistency"
    fi
    exit 0
else
    echo "💥 Found $ERROR_COUNT naming convention errors"
    echo ""
    echo "Naming Convention Rules:"
    echo "  📁 Context XML files: ##_descriptive_name.xml (e.g., 01_project_overview.xml)"
    echo "  📁 Constants files: 00_domain_constants.xml"
    echo "  📁 Agent files: ##_agent_name.md"
    echo "  📁 Command files: kebab-case-name.md or snake_case_name.md"
    echo "  📁 Config files: kebab-case-name.yaml/json"
    echo "  🚫 No spaces, special characters, or mixed case"
    echo "  ✅ Use underscores for numbered files, hyphens for commands"
    exit 1
fi