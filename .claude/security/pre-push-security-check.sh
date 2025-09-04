#!/bin/bash

# Pre-Push Security Check - API Key Detection
# Version: 1.0.0
# Purpose: Prevent accidental API key leaks to GitHub
# Author: Claude Code Security Module

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration paths (relative to git root)
GIT_ROOT=$(git rev-parse --show-toplevel)
SECURITY_DIR="${GIT_ROOT}/.claude/security"
PATTERNS_FILE="${SECURITY_DIR}/api-key-patterns.txt"
WHITELIST_FILE="${SECURITY_DIR}/whitelist-patterns.txt"
AUDIT_LOG="${SECURITY_DIR}/security-audit.log"

# Create security dir if it doesn't exist
mkdir -p "${SECURITY_DIR}"

# Statistics
TOTAL_CHECKS=0
ISSUES_FOUND=0
FILES_CHECKED=0

# Log function
log_security_event() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | ${level} | ${message}" >> "${AUDIT_LOG}"
}

# Print banner
echo -e "${CYAN}┌──────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│        🔒 API KEY SECURITY CHECK 🔒          │${NC}"
echo -e "${CYAN}└──────────────────────────────────────────────┘${NC}"
echo ""

log_security_event "INFO" "Security check initiated by user $(whoami)"

# Function to check if content matches whitelist
is_whitelisted() {
    local content="$1"
    local file="$2"
    
    # Check if file is in whitelisted directory
    if echo "$file" | grep -qE "(\.env\.example|\.env\.template|/docs/|/documentation/|/examples/|/templates/|/\.archived/|/archived/|/backup/|README\.md|SETUP_GUIDE\.md|CONTRIBUTING\.md)"; then
        return 0  # Whitelisted
    fi
    
    # Check if content matches whitelist patterns
    if [ -f "${WHITELIST_FILE}" ]; then
        while IFS= read -r pattern; do
            # Skip comments and empty lines
            [[ "$pattern" =~ ^#.*$ || -z "$pattern" ]] && continue
            
            # Check if the content contains the whitelisted pattern
            if echo "$content" | grep -qF "$pattern"; then
                return 0  # Whitelisted
            fi
        done < "${WHITELIST_FILE}"
    fi
    
    return 1  # Not whitelisted
}

# Function to scan content for API keys
scan_for_secrets() {
    local content="$1"
    local file="$2"
    local line_num="$3"
    local found=0
    
    # Skip if file is whitelisted
    if is_whitelisted "$content" "$file"; then
        return 0
    fi
    
    # Read patterns file if it exists
    if [ -f "${PATTERNS_FILE}" ]; then
        while IFS='|' read -r provider pattern description; do
            # Skip comments and empty lines
            [[ "$provider" =~ ^#.*$ || -z "$provider" ]] && continue
            
            # Check if line matches pattern
            if echo "$content" | grep -qE "$pattern"; then
                # Double-check it's not whitelisted
                if ! is_whitelisted "$content" "$file"; then
                    echo -e "${RED}❌ POTENTIAL API KEY DETECTED!${NC}"
                    echo -e "   ${YELLOW}Provider:${NC} $provider"
                    echo -e "   ${YELLOW}File:${NC} $file"
                    echo -e "   ${YELLOW}Line:${NC} $line_num"
                    echo -e "   ${YELLOW}Pattern:${NC} $description"
                    echo -e "   ${YELLOW}Content:${NC} ${content:0:60}..."
                    echo ""
                    
                    log_security_event "CRITICAL" "API key detected: $provider in $file:$line_num"
                    ((ISSUES_FOUND++))
                    found=1
                    break
                fi
            fi
        done < "${PATTERNS_FILE}"
    fi
    
    # Generic pattern checking (fallback)
    if [ $found -eq 0 ]; then
        # Check for generic API key patterns
        if echo "$content" | grep -qiE "(api[_-]?key|apikey|api_secret|access[_-]?token|secret[_-]?key|private[_-]?key|auth[_-]?token)[\s]*[=:]\s*[\"']?[a-zA-Z0-9]{20,}[\"']?"; then
            if ! is_whitelisted "$content" "$file"; then
                echo -e "${YELLOW}⚠️  SUSPICIOUS PATTERN DETECTED${NC}"
                echo -e "   ${YELLOW}File:${NC} $file"
                echo -e "   ${YELLOW}Line:${NC} $line_num"
                echo -e "   ${YELLOW}Content:${NC} ${content:0:60}..."
                echo ""
                
                log_security_event "WARNING" "Suspicious pattern in $file:$line_num"
                ((ISSUES_FOUND++))
            fi
        fi
    fi
    
    ((TOTAL_CHECKS++))
    
    return 0
}

# Function to check staged files
check_staged_files() {
    echo -e "${BLUE}→ Checking staged files...${NC}"
    
    # Get list of staged files
    local staged_files=$(git diff --cached --name-only --diff-filter=ACM)
    
    if [ -z "$staged_files" ]; then
        echo -e "  ${GREEN}✓ No staged files to check${NC}"
        return 0
    fi
    
    # Check each staged file
    while IFS= read -r file; do
        # Skip binary files
        if file "$file" 2>/dev/null | grep -q "binary"; then
            continue
        fi
        
        # Skip if file doesn't exist (deleted)
        if [ ! -f "$file" ]; then
            continue
        fi
        
        ((FILES_CHECKED++))
        
        # Read file line by line
        local line_num=0
        while IFS= read -r line; do
            ((line_num++))
            scan_for_secrets "$line" "$file" "$line_num"
        done < "$file"
    done <<< "$staged_files"
    
    echo -e "  ${GREEN}✓ Checked ${FILES_CHECKED} files${NC}"
}

# Function to check commit messages
check_commit_messages() {
    echo -e "${BLUE}→ Checking commit messages...${NC}"
    
    # Get commits that would be pushed
    local remote="${1:-origin}"
    local branch="${2:-HEAD}"
    
    # Get unpushed commits
    local commits=$(git rev-list @{u}..HEAD 2>/dev/null || git rev-list HEAD~10..HEAD)
    
    if [ -z "$commits" ]; then
        echo -e "  ${GREEN}✓ No new commits to check${NC}"
        return 0
    fi
    
    while IFS= read -r commit; do
        local message=$(git log -1 --format=%B "$commit")
        scan_for_secrets "$message" "commit:$commit" "message"
    done <<< "$commits"
    
    echo -e "  ${GREEN}✓ Commit messages checked${NC}"
}

# Function to check for .env files
check_env_files() {
    echo -e "${BLUE}→ Checking for tracked .env files...${NC}"
    
    # Check if any .env files are tracked (excluding .env.example and .env.template)
    local env_files=$(git ls-files | grep -E "(^|\/)\.env($|\.)" | grep -v -E "(\.env\.example|\.env\.template)" || true)
    
    if [ -n "$env_files" ]; then
        echo -e "${RED}❌ TRACKED .ENV FILES DETECTED!${NC}"
        echo -e "   The following .env files are being tracked:"
        echo "$env_files" | while IFS= read -r file; do
            echo -e "   ${YELLOW}→ $file${NC}"
            log_security_event "CRITICAL" ".env file tracked: $file"
            ((ISSUES_FOUND++))
        done
        echo ""
    else
        echo -e "  ${GREEN}✓ No sensitive .env files are tracked${NC}"
    fi
}

# Function to check for base64 encoded secrets
check_base64_secrets() {
    echo -e "${BLUE}→ Checking for base64 encoded secrets...${NC}"
    
    # Get staged content
    local staged_content=$(git diff --cached --no-color 2>/dev/null || true)
    
    if [ -z "$staged_content" ]; then
        echo -e "  ${GREEN}✓ No staged content to check${NC}"
        return 0
    fi
    
    # Look for long base64 strings (40+ chars)
    if echo "$staged_content" | grep -qE '[A-Za-z0-9+/]{40,}={0,2}'; then
        # Extract potential base64 strings
        local potential_secrets=$(echo "$staged_content" | grep -oE '[A-Za-z0-9+/]{40,}={0,2}')
        
        while IFS= read -r b64_string; do
            # Try to decode and check if it contains API key patterns
            local decoded=$(echo "$b64_string" | base64 -d 2>/dev/null || true)
            
            if [ -n "$decoded" ]; then
                # Check if decoded content looks like an API key
                if echo "$decoded" | grep -qiE "(api|key|token|secret|password)"; then
                    echo -e "${YELLOW}⚠️  POTENTIAL BASE64 ENCODED SECRET${NC}"
                    echo -e "   ${YELLOW}Encoded:${NC} ${b64_string:0:50}..."
                    echo -e "   ${YELLOW}Decoded preview:${NC} ${decoded:0:30}..."
                    echo ""
                    log_security_event "WARNING" "Potential base64 secret detected"
                    ((ISSUES_FOUND++))
                fi
            fi
        done <<< "$potential_secrets"
    fi
    
    echo -e "  ${GREEN}✓ Base64 check complete${NC}"
}

# Main execution
main() {
    echo -e "${CYAN}Starting security scan...${NC}"
    echo ""
    
    # Run all checks
    check_staged_files
    check_commit_messages
    check_env_files
    check_base64_secrets
    
    echo ""
    echo -e "${CYAN}┌──────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│            SECURITY CHECK SUMMARY            │${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────┘${NC}"
    echo ""
    
    if [ $ISSUES_FOUND -gt 0 ]; then
        echo -e "${RED}❌ SECURITY CHECK FAILED${NC}"
        echo -e "   ${YELLOW}Issues found:${NC} $ISSUES_FOUND"
        echo -e "   ${YELLOW}Total checks:${NC} $TOTAL_CHECKS"
        echo -e "   ${YELLOW}Files checked:${NC} $FILES_CHECKED"
        echo ""
        echo -e "${MAGENTA}📋 HOW TO FIX:${NC}"
        echo -e "   1. Remove the API keys from your files"
        echo -e "   2. Use environment variables instead:"
        echo -e "      ${CYAN}export API_KEY=your_actual_key${NC}"
        echo -e "   3. Add keys to .env file (which should be in .gitignore)"
        echo -e "   4. If you committed the key, remove it from history:"
        echo -e "      ${CYAN}git reset HEAD~1${NC}  # Undo last commit"
        echo -e "   5. For emergencies only, bypass with:"
        echo -e "      ${CYAN}SKIP_SECURITY_CHECK=1 git push${NC}"
        echo ""
        echo -e "${RED}⚠️  IMPORTANT:${NC} If you've already pushed keys to GitHub:"
        echo -e "   • Immediately rotate/regenerate the exposed keys"
        echo -e "   • Check GitHub's secret scanning alerts"
        echo -e "   • Review repository access logs"
        echo ""
        
        log_security_event "FAIL" "Push blocked - $ISSUES_FOUND security issues"
        
        # Check for emergency bypass
        if [ "${SKIP_SECURITY_CHECK:-0}" = "1" ]; then
            echo -e "${YELLOW}⚠️  SECURITY CHECK BYPASSED!${NC}"
            echo -e "   ${RED}This is logged and should only be used in emergencies${NC}"
            log_security_event "WARNING" "Security check bypassed by user $(whoami)"
            exit 0
        fi
        
        exit 1
    else
        echo -e "${GREEN}✅ SECURITY CHECK PASSED${NC}"
        echo -e "   ${GREEN}No API keys or secrets detected${NC}"
        echo -e "   ${CYAN}Total checks:${NC} $TOTAL_CHECKS"
        echo -e "   ${CYAN}Files checked:${NC} $FILES_CHECKED"
        echo ""
        
        log_security_event "PASS" "Push approved - no security issues"
        exit 0
    fi
}

# Handle errors
trap 'echo -e "${RED}Security check encountered an error${NC}"; exit 1' ERR

# Run main function
main "$@"