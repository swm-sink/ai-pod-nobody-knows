#!/usr/bin/env bash

# Configuration Validation Hooks - Enforcement System
# Prevents hardcoded configuration values from entering the codebase
# Enforces single source of truth architecture

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$(dirname "$BASE_DIR")")"

# Debug paths
echo "SCRIPT_DIR: $SCRIPT_DIR" >&2
echo "BASE_DIR: $BASE_DIR" >&2

# Forbidden hardcoded patterns - these should use CONFIG references instead
FORBIDDEN_PATTERNS=(
    # Episode duration patterns
    "47.minute"
    "35k.character"
    "4[0-9][0-9][0-9].word"
    "[0-9]+.minute.*episode"
    
    # Cost patterns  
    "\\\$[0-9]+\.[0-9][0-9]"
    "cost.*\\\$[1-9][0-9]*"
    "[0-9]+\.[0-9][0-9].*USD"
    
    # TTS model patterns
    "eleven_flash_v2_5"
    "eleven_turbo_v2_5"  # Should use CONFIG reference
    "ZF6FPAbjXT4488VcRRnw"  # Voice ID should use CONFIG
    
    # Quality threshold patterns
    "0\.[89][0-9]"  # Quality scores like 0.85, 0.90 should use CONFIG
    
    # Character count patterns
    "[1-9][0-9],[0-9]{3}.*character"
    "[0-9]{5}.*character"
    
    # File size patterns
    "[0-9]+.*MB.*episode"
    
    # API endpoint patterns
    "api\.elevenlabs\.io"
    "api\.perplexity\.ai"
    "api\.anthropic\.com"
)

# Allowed exceptions - files that can contain these patterns
EXCEPTION_FILES=(
    "production-config.yaml"       # Master config file
    "config-loader.sh"             # Config loading system
    "config-validation-hooks.sh"   # This file
    "*.md"                         # Documentation files
    "README*"                      # README files
    "CHANGELOG*"                   # Changelog files
    ".gitignore"                   # Git ignore
    "package.json"                 # Dependencies
    "requirements.txt"             # Dependencies
    "*.lock"                       # Lock files
    ".claude/context/**"           # Context documentation
)

# Check if file is in exception list
is_exception_file() {
    local file="$1"
    local base_file=$(basename "$file")
    local rel_path=${file#$PROJECT_ROOT/}
    
    for exception in "${EXCEPTION_FILES[@]}"; do
        # Handle wildcard patterns
        if [[ "$exception" == *"*"* ]]; then
            if [[ "$base_file" == $exception ]]; then
                return 0
            fi
        # Handle directory patterns  
        elif [[ "$exception" == *"/**" ]]; then
            local dir_pattern=${exception%/**}
            if [[ "$rel_path" == "$dir_pattern"* ]]; then
                return 0
            fi
        # Handle exact matches
        elif [[ "$base_file" == "$exception" ]] || [[ "$rel_path" == "$exception" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Validate single file for hardcoded patterns
validate_file() {
    local file="$1"
    local violations=0
    local temp_report=$(mktemp)
    
    # Skip if file is in exception list
    if is_exception_file "$file"; then
        return 0
    fi
    
    # Skip binary files
    if file "$file" | grep -q binary; then
        return 0
    fi
    
    # Check for forbidden patterns
    for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
        local matches=$(grep -n -E "$pattern" "$file" 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            echo "VIOLATION in $file:" >> "$temp_report"
            echo "  Pattern: $pattern" >> "$temp_report"
            echo "  Matches:" >> "$temp_report"
            echo "$matches" | sed 's/^/    /' >> "$temp_report"
            echo "" >> "$temp_report"
            ((violations++))
        fi
    done
    
    if [[ $violations -gt 0 ]]; then
        cat "$temp_report"
        rm -f "$temp_report"
        return 1
    fi
    
    rm -f "$temp_report"
    return 0
}

# Pre-commit hook - validates staged files
pre_commit_validation() {
    echo -e "${BLUE}🔍 Configuration Validation - Pre-commit Hook${NC}"
    echo "Checking staged files for hardcoded configuration values..."
    
    local violations=0
    local files_checked=0
    
    # Get list of staged files
    local staged_files
    if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
        # In git repository, check staged files
        staged_files=$(git diff --cached --name-only --diff-filter=ACM)
        if [[ -z "$staged_files" ]]; then
            echo -e "${YELLOW}No staged files to validate${NC}"
            return 0
        fi
    else
        # Not in git repo, check recent files in level-2-production
        staged_files=$(find "$BASE_DIR" -type f -name "*.md" -o -name "*.yaml" -o -name "*.json" -o -name "*.sh" | head -20)
    fi
    
    echo "Files to validate:"
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        # Skip if file doesn't exist (deleted files)
        [[ ! -f "$file" ]] && continue
        
        echo "  $file"
        ((files_checked++))
        
        if ! validate_file "$file"; then
            ((violations++))
        fi
        
    done <<< "$staged_files"
    
    echo ""
    echo "Validation Summary:"
    echo "  Files checked: $files_checked"
    echo "  Violations found: $violations"
    
    if [[ $violations -gt 0 ]]; then
        echo ""
        echo -e "${RED}❌ COMMIT BLOCKED - Configuration violations detected${NC}"
        echo -e "${YELLOW}Fix required:${NC}"
        echo "1. Replace hardcoded values with CONFIG references"
        echo "2. Use: source tools/config-loader.sh"
        echo "3. Reference values like: \$CONFIG_EPISODE_DURATION_TARGET"
        echo "4. See production-config.yaml for all available CONFIG variables"
        echo ""
        echo -e "${YELLOW}Example fixes:${NC}"
        echo '  ❌ "47 minutes"              → ✅ "${CONFIG_EPISODE_DURATION_TARGET} minutes"'
        echo '  ❌ $10.50                   → ✅ $CONFIG_ELEVENLABS_ESTIMATED_COST'  
        echo '  ❌ eleven_turbo_v2_5        → ✅ $CONFIG_ELEVENLABS_MODEL_ID'
        echo '  ❌ 0.85                     → ✅ $CONFIG_QUALITY_COMPREHENSION_MIN'
        return 1
    else
        echo -e "${GREEN}✅ Configuration validation passed${NC}"
        return 0
    fi
}

# Full system audit - checks all files
full_system_audit() {
    echo -e "${BLUE}🔍 Full System Configuration Audit${NC}"
    echo "Scanning entire production system for hardcoded values..."
    
    local violations=0
    local files_checked=0
    local violation_files=()
    
    # Find all relevant files in production system  
    local all_files=$(find "$BASE_DIR" -type f \( \
        -name "*.md" -o \
        -name "*.yaml" -o -name "*.yml" -o \
        -name "*.json" -o \
        -name "*.sh" -o \
        -name "*.bash" \
        \) 2>/dev/null | grep -v "/\." | grep -v "/.git/" | sort)
    
    echo "Scanning production files..."
    echo "DEBUG: Found $(echo "$all_files" | wc -l) files:" >&2
    echo "$all_files" | head -5 >&2
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        ((files_checked++))
        
        if ! validate_file "$file"; then
            ((violations++))
            violation_files+=("$file")
        fi
        
    done <<< "$all_files"
    
    echo ""
    echo "=== SYSTEM AUDIT RESULTS ==="
    echo "Files scanned: $files_checked"
    echo "Violations found: $violations"
    echo "Violation files: ${#violation_files[@]}"
    
    if [[ $violations -gt 0 ]]; then
        echo ""
        echo -e "${RED}❌ SYSTEM AUDIT FAILED - Configuration violations exist${NC}"
        echo ""
        echo "Files with violations:"
        for file in "${violation_files[@]}"; do
            echo "  - $file"
        done
        echo ""
        echo -e "${YELLOW}Required actions:${NC}"
        echo "1. Update each violation file to use CONFIG references"
        echo "2. Source config-loader.sh in scripts before using CONFIG variables"
        echo "3. Replace hardcoded values with \$CONFIG_* variables"
        echo "4. Run this audit again until violations = 0"
        return 1
    else
        echo -e "${GREEN}✅ SYSTEM AUDIT PASSED - No configuration violations${NC}"
        return 0
    fi
}

# Generate migration report for hardcoded values
generate_migration_report() {
    echo -e "${BLUE}📊 Configuration Migration Report${NC}"
    
    local report_file="$BASE_DIR/analysis/config_migration_report.txt"
    mkdir -p "$(dirname "$report_file")"
    
    {
        echo "Configuration Migration Report - $(date)"
        echo "=============================================="
        echo ""
        echo "This report identifies all hardcoded configuration values"
        echo "that should be migrated to use CONFIG references."
        echo ""
        
        local total_violations=0
        
        # Scan and report violations by pattern
        for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
            echo "Pattern: $pattern"
            echo "----------------------------------------"
            
            local pattern_violations=0
            local files=$(find "$BASE_DIR" -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.json" -o -name "*.sh" \) | grep -v "/\.")
            
            while IFS= read -r file; do
                [[ -z "$file" ]] && continue
                
                # Skip exception files
                if is_exception_file "$file"; then
                    continue
                fi
                
                local matches=$(grep -n -E "$pattern" "$file" 2>/dev/null || true)
                if [[ -n "$matches" ]]; then
                    echo "File: $file"
                    echo "$matches" | sed 's/^/  Line /'
                    echo ""
                    ((pattern_violations++))
                fi
                
            done <<< "$files"
            
            if [[ $pattern_violations -eq 0 ]]; then
                echo "  ✅ No violations found"
            else
                echo "  ❌ $pattern_violations files with violations"
            fi
            
            echo ""
            ((total_violations += pattern_violations))
        done
        
        echo "=============================================="
        echo "Total violation instances: $total_violations"
        echo "Report generated: $(date)"
        
    } | tee "$report_file"
    
    echo ""
    echo "Migration report saved to: $report_file"
}

# Install pre-commit hook
install_pre_commit_hook() {
    local git_hooks_dir="$PROJECT_ROOT/.git/hooks"
    local pre_commit_hook="$git_hooks_dir/pre-commit"
    
    if [[ ! -d "$git_hooks_dir" ]]; then
        echo -e "${YELLOW}Warning: Not in a git repository or .git/hooks directory not found${NC}"
        return 1
    fi
    
    # Create pre-commit hook that calls this script
    cat > "$pre_commit_hook" << 'EOF'
#!/usr/bin/env bash
# Auto-generated pre-commit hook for configuration validation

SCRIPT_PATH=".claude/level-2-production/tools/config-validation-hooks.sh"

if [[ -f "$SCRIPT_PATH" ]]; then
    "$SCRIPT_PATH" pre-commit
else
    echo "WARNING: Configuration validation hook not found: $SCRIPT_PATH"
    exit 1
fi
EOF
    
    chmod +x "$pre_commit_hook"
    
    echo -e "${GREEN}✅ Pre-commit hook installed${NC}"
    echo "Location: $pre_commit_hook"
    echo "All future commits will be validated for configuration compliance"
}

# Main execution
main() {
    local command="${1:-help}"
    
    case "$command" in
        "pre-commit")
            pre_commit_validation
            ;;
        "audit"|"--audit")
            full_system_audit
            ;;
        "report"|"--report")
            generate_migration_report
            ;;
        "install"|"--install")
            install_pre_commit_hook
            ;;
        "help"|"--help"|*)
            echo "Configuration Validation Hooks - Enforcement System"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  pre-commit    Validate staged files (used by git hook)"
            echo "  audit         Full system audit for hardcoded values"
            echo "  report        Generate migration report"
            echo "  install       Install git pre-commit hook"
            echo "  help          Show this help"
            echo ""
            echo "Enforcement Rules:"
            echo "  - No hardcoded episode durations (47 minutes, etc.)"
            echo "  - No hardcoded costs (\$10.50, etc.)"
            echo "  - No hardcoded TTS model IDs (eleven_turbo_v2_5, etc.)"
            echo "  - No hardcoded quality thresholds (0.85, etc.)"
            echo "  - No hardcoded voice IDs (ZF6FPAbjXT4488VcRRnw, etc.)"
            echo ""
            echo "Use CONFIG references instead:"
            echo "  \$CONFIG_EPISODE_DURATION_TARGET"
            echo "  \$CONFIG_ELEVENLABS_ESTIMATED_COST"
            echo "  \$CONFIG_ELEVENLABS_MODEL_ID"
            echo "  \$CONFIG_QUALITY_COMPREHENSION_MIN"
            ;;
    esac
}

main "$@"