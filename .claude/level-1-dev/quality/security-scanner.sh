#!/bin/bash

# Security Scanner for Level-1-Dev Quality System
# Comprehensive security vulnerability detection and analysis

set -euo pipefail

# Source error handling
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../templates/error-handling-template.sh"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
LEVEL1_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$LEVEL1_DIR/../.." && pwd)"
SECURITY_CONFIG="$SCRIPT_DIR/../security/security-config.yaml"
REPORT_DIR="$SCRIPT_DIR/reports"
SCAN_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SCAN_REPORT="$REPORT_DIR/security-scan-$SCAN_TIMESTAMP.json"
SCAN_SUMMARY="$REPORT_DIR/security-summary-$SCAN_TIMESTAMP.md"

# Scan configuration
MAX_FILE_SIZE="10M"
SCAN_TIMEOUT=300  # 5 minutes
EXCLUDED_DIRS=(".git" "node_modules" "vendor" ".venv" "venv" "__pycache__" ".pytest_cache")
EXCLUDED_FILES=("*.log" "*.tmp" "*.cache" "*.pyc" "*.pyo")

# Security counters
TOTAL_FILES_SCANNED=0
VULNERABILITIES_FOUND=0
SECRETS_FOUND=0
WARNINGS_FOUND=0
CRITICAL_ISSUES=0
HIGH_ISSUES=0
MEDIUM_ISSUES=0
LOW_ISSUES=0

# Function: Display help
show_help() {
    cat << EOF
Security Scanner for Level-1-Dev Quality System

Usage: $(basename "$0") [options] [target]

Options:
    -h, --help          Show this help message
    -v, --verbose       Show detailed output
    -q, --quiet         Suppress non-error output
    -f, --format FORMAT Output format (json|markdown|console) [default: console]
    -o, --output FILE   Output file path
    -t, --timeout SEC   Scan timeout in seconds [default: 300]
    --full             Run comprehensive scan (slower)
    --quick            Run quick scan (faster, less thorough)
    --secrets-only     Only scan for secrets and credentials
    --vulns-only       Only scan for code vulnerabilities
    --deps-only        Only scan dependencies

Scan Types:
    --code             Scan code for security vulnerabilities
    --secrets          Scan for hardcoded secrets and credentials  
    --dependencies     Scan dependencies for known vulnerabilities
    --permissions      Check file and directory permissions
    --config           Validate security configuration
    --all              Run all scan types (default)

Target:
    [target]           Directory or file to scan [default: current directory]

Examples:
    $(basename "$0")                    # Scan current directory
    $(basename "$0") --full /path/to/code  # Full scan of specific path
    $(basename "$0") --secrets-only        # Only check for secrets
    $(basename "$0") --format json -o security-report.json  # JSON output

EOF
}

# Function: Initialize scanning
init_scanner() {
    setup_error_handling
    
    # Create report directory
    mkdir -p "$REPORT_DIR"
    
    # Initialize scan report
    cat > "$SCAN_REPORT" << EOF
{
  "scan_info": {
    "timestamp": "$(date -Iseconds)",
    "scanner_version": "1.0.0",
    "target": "$SCAN_TARGET",
    "scan_type": "$SCAN_TYPE",
    "duration_seconds": 0
  },
  "summary": {
    "total_files_scanned": 0,
    "vulnerabilities_found": 0,
    "secrets_found": 0,
    "warnings_found": 0,
    "critical_issues": 0,
    "high_issues": 0,
    "medium_issues": 0,
    "low_issues": 0
  },
  "findings": []
}
EOF
    
    log_info "SCAN_INITIALIZED" "Security scanner initialized"
}

# Function: Load security configuration
load_security_config() {
    if [ -f "$SECURITY_CONFIG" ]; then
        log_info "CONFIG_LOADED" "Security configuration loaded from: $SECURITY_CONFIG"
        
        # Extract key configuration values
        if command -v yq >/dev/null 2>&1; then
            SECRET_PATTERNS=$(yq -r '.secret_detection.patterns[]' "$SECURITY_CONFIG" 2>/dev/null || echo "")
            VULNERABILITY_PATTERNS=$(yq -r '.vulnerability_detection.patterns[]' "$SECURITY_CONFIG" 2>/dev/null || echo "")
        else
            log_warn "YQ_NOT_AVAILABLE" "yq not available, using default patterns"
        fi
    else
        log_warn "CONFIG_NOT_FOUND" "Security configuration not found, using defaults"
        create_default_security_config
    fi
}

# Function: Create default security configuration
create_default_security_config() {
    mkdir -p "$(dirname "$SECURITY_CONFIG")"
    
    cat > "$SECURITY_CONFIG" << 'EOF'
# Security Configuration for Level-1-Dev
version: "1.0.0"

# Secret Detection Patterns
secret_detection:
  enabled: true
  patterns:
    - 'password\s*[:=]\s*["\047]([^"\047\s]{4,})["\047]'
    - 'api[_-]?key\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
    - 'secret[_-]?key\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
    - 'access[_-]?token\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
    - 'auth[_-]?token\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
    - 'private[_-]?key\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
    - '-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----'
    - 'sk_live_[a-zA-Z0-9]{24,}'
    - 'pk_live_[a-zA-Z0-9]{24,}'
    - 'AIza[0-9A-Za-z\\-_]{35}'
    - 'ya29\\.[0-9A-Za-z\\-_]+'
  
  whitelist_patterns:
    - 'password\s*[:=]\s*["\047](example|test|dummy|placeholder)["\047]'
    - 'key\s*[:=]\s*["\047](your_key_here|insert_key)["\047]'

# Vulnerability Detection
vulnerability_detection:
  enabled: true
  patterns:
    dangerous_functions:
      - 'eval\s*\('
      - 'exec\s*\('
      - 'system\s*\('
      - 'shell_exec\s*\('
      - 'passthru\s*\('
      - 'popen\s*\('
    
    command_injection:
      - '\$\([^)]*\)'
      - '`[^`]*`'
      - 'os\.system\s*\('
      - 'subprocess\.call\s*\('
      - 'subprocess\.run\s*\('
    
    path_traversal:
      - '\.\./\.\.'
      - '\.\.\\\.\..'
      - '/\.\./\.\.'
      - '\\\.\.\\\.\..'
    
    sql_injection:
      - 'SELECT.*\+.*FROM'
      - 'UNION.*SELECT'
      - 'INSERT.*VALUES.*\+'
      - 'UPDATE.*SET.*\+'
    
    xss_patterns:
      - '<script[^>]*>'
      - 'javascript:'
      - 'onload\s*='
      - 'onerror\s*='

# File Permission Checks
permission_checks:
  enabled: true
  max_permissions:
    scripts: "755"
    configs: "644"
    keys: "600"
    directories: "755"
  
  forbidden_permissions:
    - "777"
    - "666"
    - "755" # for sensitive files

# Dependency Scanning
dependency_scanning:
  enabled: true
  package_managers:
    - npm
    - pip
    - gem
    - composer
  
  vulnerability_databases:
    - "https://api.osv.dev"
    - "https://api.security.snyk.io"

# Compliance Checks
compliance:
  enabled: true
  standards:
    - "owasp-top-10"
    - "sans-top-25"
    - "pci-dss"
EOF

    log_info "DEFAULT_CONFIG_CREATED" "Created default security configuration: $SECURITY_CONFIG"
}

# Function: Add finding to report
add_finding() {
    local severity="$1"
    local type="$2"
    local file="$3"
    local line="${4:-0}"
    local description="$5"
    local evidence="${6:-}"
    local recommendation="${7:-}"
    
    # Update counters
    case "$severity" in
        "critical") ((CRITICAL_ISSUES++)) ;;
        "high") ((HIGH_ISSUES++)) ;;
        "medium") ((MEDIUM_ISSUES++)) ;;
        "low") ((LOW_ISSUES++)) ;;
    esac
    
    case "$type" in
        "secret"|"credential") ((SECRETS_FOUND++)) ;;
        "vulnerability"|"security") ((VULNERABILITIES_FOUND++)) ;;
        *) ((WARNINGS_FOUND++)) ;;
    esac
    
    # Create finding JSON
    local finding
    finding=$(cat << EOF
{
  "severity": "$severity",
  "type": "$type",
  "file": "$file",
  "line": $line,
  "description": "$description",
  "evidence": "$evidence",
  "recommendation": "$recommendation",
  "timestamp": "$(date -Iseconds)"
}
EOF
)
    
    # Add to report (requires jq for proper JSON manipulation)
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".findings += [$finding]" "$SCAN_REPORT" > "$temp_report"
        mv "$temp_report" "$SCAN_REPORT"
    else
        # Fallback: append to simple log
        echo "$finding" >> "${SCAN_REPORT}.findings"
    fi
    
    # Display finding
    local color=""
    case "$severity" in
        "critical") color="$RED" ;;
        "high") color="$MAGENTA" ;;
        "medium") color="$YELLOW" ;;
        "low") color="$CYAN" ;;
    esac
    
    if [ "${VERBOSE:-false}" = "true" ] || [ "$severity" = "critical" ] || [ "$severity" = "high" ]; then
        echo -e "${color}[$severity] $type in $file:$line${NC}"
        echo -e "  Description: $description"
        if [ -n "$evidence" ]; then
            echo -e "  Evidence: $evidence"
        fi
        if [ -n "$recommendation" ]; then
            echo -e "  Fix: $recommendation"
        fi
        echo ""
    fi
}

# Function: Scan for hardcoded secrets
scan_secrets() {
    local target="$1"
    
    echo -e "${BLUE}Scanning for hardcoded secrets and credentials...${NC}"
    
    # Define secret patterns
    local patterns=(
        # API Keys and tokens
        'password\s*[:=]\s*["\047]([^"\047\s]{4,})["\047]'
        'api[_-]?key\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
        'secret[_-]?key\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
        'access[_-]?token\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
        'auth[_-]?token\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
        'bearer[_-]?token\s*[:=]\s*["\047]([^"\047\s]{10,})["\047]'
        
        # Cloud provider keys
        'AKIA[0-9A-Z]{16}'  # AWS Access Key
        'sk_live_[a-zA-Z0-9]{24,}'  # Stripe Live Key
        'pk_live_[a-zA-Z0-9]{24,}'  # Stripe Publishable Key
        'AIza[0-9A-Za-z\\-_]{35}'   # Google API Key
        'ya29\\.[0-9A-Za-z\\-_]+'   # Google OAuth Token
        
        # Private keys
        '-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----'
        '-----BEGIN\s+OPENSSH\s+PRIVATE\s+KEY-----'
        '-----BEGIN\s+DSA\s+PRIVATE\s+KEY-----'
        '-----BEGIN\s+EC\s+PRIVATE\s+KEY-----'
        
        # Database URLs
        'mysql://[^\\s]+'
        'postgres://[^\\s]+'
        'mongodb://[^\\s]+'
        'redis://[^\\s]+'
        
        # Generic secrets
        '["\047][a-zA-Z0-9]{32,}["\047]'  # Long random strings
    )
    
    # Whitelist patterns (to reduce false positives)
    local whitelist_patterns=(
        'password\s*[:=]\s*["\047](example|test|dummy|placeholder|your_password_here)["\047]'
        'key\s*[:=]\s*["\047](your_key_here|insert_key|example_key)["\047]'
        'token\s*[:=]\s*["\047](your_token_here|insert_token|example_token)["\047]'
    )
    
    while IFS= read -r -d '' file; do
        ((TOTAL_FILES_SCANNED++))
        
        # Skip binary files
        if file "$file" | grep -q "binary"; then
            continue
        fi
        
        local line_num=0
        while IFS= read -r line; do
            ((line_num++))
            
            # Check for secrets
            for pattern in "${patterns[@]}"; do
                if echo "$line" | grep -qE "$pattern"; then
                    # Check if it's whitelisted
                    local is_whitelisted=false
                    for whitelist in "${whitelist_patterns[@]}"; do
                        if echo "$line" | grep -qE "$whitelist"; then
                            is_whitelisted=true
                            break
                        fi
                    done
                    
                    if [ "$is_whitelisted" = "false" ]; then
                        local evidence=$(echo "$line" | grep -oE "$pattern" | head -1)
                        add_finding "high" "secret" "$file" "$line_num" \
                            "Potential hardcoded secret detected" \
                            "$evidence" \
                            "Move secrets to environment variables or secure vault"
                    fi
                fi
            done
        done < "$file"
        
    done < <(find "$target" -type f \
        \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" -o -name "*.conf" -o -name "*.config" \) \
        -not -path "*/.git/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/.venv/*" \
        -not -path "*/venv/*" \
        -print0)
}

# Function: Scan for code vulnerabilities
scan_vulnerabilities() {
    local target="$1"
    
    echo -e "${BLUE}Scanning for code vulnerabilities...${NC}"
    
    # Define vulnerability patterns
    declare -A vuln_patterns=(
        # Command injection
        ["command_injection"]='eval\s+\$|system\s*\(|exec\s*\(|shell_exec\s*\(|passthru\s*\(|`[^`]*\$'
        
        # Path traversal
        ["path_traversal"]='\.\./\.\.|\.\.\\\.\..|/\.\./\.\.|\\\.\.\\\.\..'
        
        # SQL injection indicators
        ["sql_injection"]='SELECT.*\+.*FROM|UNION.*SELECT|INSERT.*VALUES.*\+|UPDATE.*SET.*\+'
        
        # Dangerous file operations
        ["file_inclusion"]='include\s*\(\s*\$|require\s*\(\s*\$|file_get_contents\s*\(\s*\$'
        
        # XSS patterns
        ["xss"]='echo\s+\$_(GET|POST|REQUEST)|printf.*\$_(GET|POST)|<script|javascript:|onload\s*=|onerror\s*='
        
        # Unsafe random number generation
        ["weak_random"]='rand\s*\(\)|mt_rand\s*\(\)|srand\s*\('
        
        # Unsafe serialization
        ["unsafe_serialization"]='unserialize\s*\(\s*\$|pickle\.loads\s*\(|yaml\.load\s*\('
        
        # Information disclosure
        ["info_disclosure"]='phpinfo\s*\(\)|var_dump\s*\(|print_r\s*\(.*\$_(GET|POST)|error_reporting\s*\(\s*E_ALL'
        
        # Hardcoded crypto
        ["weak_crypto"]='md5\s*\(|sha1\s*\(|crypt\s*\(.*\$_(GET|POST)'
    )
    
    while IFS= read -r -d '' file; do
        ((TOTAL_FILES_SCANNED++))
        
        # Skip binary files
        if file "$file" | grep -q "binary"; then
            continue
        fi
        
        local line_num=0
        while IFS= read -r line; do
            ((line_num++))
            
            # Check for vulnerability patterns
            for vuln_type in "${!vuln_patterns[@]}"; do
                local pattern="${vuln_patterns[$vuln_type]}"
                
                if echo "$line" | grep -qE "$pattern"; then
                    local evidence=$(echo "$line" | grep -oE "$pattern" | head -1)
                    local severity="medium"
                    local recommendation="Review code for security implications"
                    
                    # Adjust severity based on vulnerability type
                    case "$vuln_type" in
                        "command_injection"|"sql_injection"|"path_traversal")
                            severity="high"
                            recommendation="Sanitize user input and use parameterized queries"
                            ;;
                        "xss"|"file_inclusion")
                            severity="medium"
                            recommendation="Validate and escape user input"
                            ;;
                        "weak_random"|"weak_crypto")
                            severity="low"
                            recommendation="Use cryptographically secure random functions"
                            ;;
                    esac
                    
                    add_finding "$severity" "vulnerability" "$file" "$line_num" \
                        "Potential $vuln_type vulnerability detected" \
                        "$evidence" \
                        "$recommendation"
                fi
            done
            
        done < "$file"
        
    done < <(find "$target" -type f \
        \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.php" -o -name "*.rb" -o -name "*.go" \) \
        -not -path "*/.git/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/.venv/*" \
        -not -path "*/venv/*" \
        -print0)
}

# Function: Check file permissions
scan_permissions() {
    local target="$1"
    
    echo -e "${BLUE}Checking file and directory permissions...${NC}"
    
    # Check for overly permissive files
    while IFS= read -r -d '' file; do
        local perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)
        local filename=$(basename "$file")
        
        # Check for dangerous permissions
        case "$perms" in
            "777")
                add_finding "high" "permission" "$file" "0" \
                    "File has world-writable permissions (777)" \
                    "chmod 777" \
                    "Use more restrictive permissions like 755 or 644"
                ;;
            "666")
                add_finding "medium" "permission" "$file" "0" \
                    "File has world-writable permissions (666)" \
                    "chmod 666" \
                    "Use more restrictive permissions like 644"
                ;;
            *7??)
                if [[ "$filename" =~ \.(key|pem|p12|pfx)$ ]]; then
                    add_finding "high" "permission" "$file" "0" \
                        "Private key file has overly permissive permissions" \
                        "chmod $perms" \
                        "Set permissions to 600 for private keys"
                fi
                ;;
        esac
        
        # Check for executable files without shebang
        if [[ "$perms" =~ ^[0-9]*[1357]$ ]] && [ -f "$file" ]; then
            if [[ "$filename" =~ \.(sh|py|pl|rb)$ ]]; then
                local first_line=$(head -1 "$file" 2>/dev/null)
                if [[ ! "$first_line" =~ ^#! ]]; then
                    add_finding "low" "permission" "$file" "1" \
                        "Executable script missing shebang" \
                        "No shebang found" \
                        "Add appropriate shebang line (#!/bin/bash, #!/usr/bin/env python, etc.)"
                fi
            fi
        fi
        
    done < <(find "$target" -type f -print0)
}

# Function: Scan dependencies
scan_dependencies() {
    local target="$1"
    
    echo -e "${BLUE}Scanning dependencies for known vulnerabilities...${NC}"
    
    # Check for package.json (Node.js)
    if [ -f "$target/package.json" ]; then
        scan_npm_dependencies "$target"
    fi
    
    # Check for requirements.txt (Python)
    if [ -f "$target/requirements.txt" ]; then
        scan_pip_dependencies "$target"
    fi
    
    # Check for Gemfile (Ruby)
    if [ -f "$target/Gemfile" ]; then
        scan_gem_dependencies "$target"
    fi
    
    # Check for composer.json (PHP)
    if [ -f "$target/composer.json" ]; then
        scan_composer_dependencies "$target"
    fi
}

# Function: Scan NPM dependencies
scan_npm_dependencies() {
    local target="$1"
    
    if command -v npm >/dev/null 2>&1; then
        echo "  Checking NPM dependencies..."
        
        local audit_output
        if audit_output=$(cd "$target" && npm audit --json 2>/dev/null); then
            # Parse npm audit output
            if echo "$audit_output" | jq -e '.vulnerabilities' >/dev/null 2>&1; then
                echo "$audit_output" | jq -r '.vulnerabilities | to_entries[] | "\(.key) \(.value.severity)"' | while read -r package severity; do
                    add_finding "$severity" "dependency" "$target/package.json" "0" \
                        "Vulnerable dependency: $package" \
                        "npm audit reported $severity vulnerability" \
                        "Run 'npm audit fix' to update vulnerable packages"
                done
            fi
        else
            add_finding "low" "dependency" "$target/package.json" "0" \
                "Could not audit NPM dependencies" \
                "npm audit failed" \
                "Ensure npm is properly configured and packages are installed"
        fi
    fi
}

# Function: Scan Python dependencies
scan_pip_dependencies() {
    local target="$1"
    
    if command -v pip >/dev/null 2>&1; then
        echo "  Checking Python dependencies..."
        
        # Check for known vulnerable packages
        local vulnerable_packages=(
            "Pillow<8.1.1"
            "PyYAML<5.4"
            "requests<2.20.0"
            "urllib3<1.24.2"
        )
        
        if [ -f "$target/requirements.txt" ]; then
            while IFS= read -r line; do
                for vuln_pkg in "${vulnerable_packages[@]}"; do
                    local pkg_name=$(echo "$vuln_pkg" | cut -d'<' -f1)
                    if echo "$line" | grep -q "^$pkg_name"; then
                        add_finding "medium" "dependency" "$target/requirements.txt" "0" \
                            "Potentially vulnerable dependency: $line" \
                            "Package may be outdated" \
                            "Update to latest secure version of $pkg_name"
                    fi
                done
            done < "$target/requirements.txt"
        fi
    fi
}

# Function: Scan Ruby dependencies
scan_gem_dependencies() {
    local target="$1"
    
    if command -v bundle >/dev/null 2>&1; then
        echo "  Checking Ruby dependencies..."
        
        if [ -f "$target/Gemfile.lock" ]; then
            # Check for bundle audit if available
            if command -v bundle-audit >/dev/null 2>&1; then
                local audit_output
                if audit_output=$(cd "$target" && bundle audit 2>&1); then
                    echo "$audit_output" | grep "Name:" | while read -r line; do
                        local gem_name=$(echo "$line" | awk '{print $2}')
                        add_finding "medium" "dependency" "$target/Gemfile" "0" \
                            "Vulnerable gem: $gem_name" \
                            "bundle-audit reported vulnerability" \
                            "Run 'bundle update $gem_name' to update vulnerable gem"
                    done
                fi
            fi
        fi
    fi
}

# Function: Scan PHP dependencies
scan_composer_dependencies() {
    local target="$1"
    
    if command -v composer >/dev/null 2>&1; then
        echo "  Checking PHP dependencies..."
        
        if [ -f "$target/composer.lock" ]; then
            # Basic check for common vulnerable packages
            if grep -q "monolog/monolog.*1\." "$target/composer.lock"; then
                add_finding "low" "dependency" "$target/composer.json" "0" \
                    "Old version of monolog detected" \
                    "monolog 1.x may have vulnerabilities" \
                    "Update to monolog 2.x or later"
            fi
        fi
    fi
}

# Function: Generate scan summary
generate_summary() {
    local scan_duration=$(($(date +%s) - SCAN_START_TIME))
    
    # Update scan report with final counts
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".scan_info.duration_seconds = $scan_duration |
            .summary.total_files_scanned = $TOTAL_FILES_SCANNED |
            .summary.vulnerabilities_found = $VULNERABILITIES_FOUND |
            .summary.secrets_found = $SECRETS_FOUND |
            .summary.warnings_found = $WARNINGS_FOUND |
            .summary.critical_issues = $CRITICAL_ISSUES |
            .summary.high_issues = $HIGH_ISSUES |
            .summary.medium_issues = $MEDIUM_ISSUES |
            .summary.low_issues = $LOW_ISSUES" \
            "$SCAN_REPORT" > "$temp_report"
        mv "$temp_report" "$SCAN_REPORT"
    fi
    
    # Generate markdown summary
    cat > "$SCAN_SUMMARY" << EOF
# Security Scan Report

**Scan Date:** $(date)  
**Scan Duration:** ${scan_duration}s  
**Target:** $SCAN_TARGET  
**Files Scanned:** $TOTAL_FILES_SCANNED  

## Summary

| Severity | Count |
|----------|-------|
| Critical | $CRITICAL_ISSUES |
| High     | $HIGH_ISSUES |
| Medium   | $MEDIUM_ISSUES |
| Low      | $LOW_ISSUES |

| Category | Count |
|----------|-------|
| Vulnerabilities | $VULNERABILITIES_FOUND |
| Secrets Found | $SECRETS_FOUND |
| Warnings | $WARNINGS_FOUND |

## Recommendations

EOF

    if [ $CRITICAL_ISSUES -gt 0 ]; then
        echo "🚨 **CRITICAL**: Immediate action required for $CRITICAL_ISSUES critical security issues." >> "$SCAN_SUMMARY"
    fi
    
    if [ $HIGH_ISSUES -gt 0 ]; then
        echo "⚠️ **HIGH**: Address $HIGH_ISSUES high-priority security issues soon." >> "$SCAN_SUMMARY"
    fi
    
    if [ $SECRETS_FOUND -gt 0 ]; then
        echo "🔑 **SECRETS**: Remove $SECRETS_FOUND hardcoded secrets immediately." >> "$SCAN_SUMMARY"
    fi
    
    if [ $((CRITICAL_ISSUES + HIGH_ISSUES + MEDIUM_ISSUES + LOW_ISSUES)) -eq 0 ]; then
        echo "✅ **CLEAN**: No security issues detected in this scan." >> "$SCAN_SUMMARY"
    fi
    
    cat >> "$SCAN_SUMMARY" << EOF

## Next Steps

1. Review detailed findings in: \`$SCAN_REPORT\`
2. Address critical and high-priority issues first
3. Remove any hardcoded secrets
4. Update vulnerable dependencies
5. Re-run scan to verify fixes

## Scan Configuration

- Scanner Version: 1.0.0
- Configuration: $SECURITY_CONFIG
- Excluded Directories: ${EXCLUDED_DIRS[*]}
- Excluded Files: ${EXCLUDED_FILES[*]}

EOF
}

# Function: Display results
display_results() {
    echo ""
    echo "========================================"
    echo -e "${BOLD}${BLUE}Security Scan Complete${NC}"
    echo "========================================"
    echo ""
    echo "Files Scanned: $TOTAL_FILES_SCANNED"
    echo ""
    echo "Issues Found:"
    echo -e "  ${RED}Critical: $CRITICAL_ISSUES${NC}"
    echo -e "  ${MAGENTA}High:     $HIGH_ISSUES${NC}"
    echo -e "  ${YELLOW}Medium:   $MEDIUM_ISSUES${NC}"
    echo -e "  ${CYAN}Low:      $LOW_ISSUES${NC}"
    echo ""
    echo "Categories:"
    echo "  Vulnerabilities: $VULNERABILITIES_FOUND"
    echo "  Secrets Found:   $SECRETS_FOUND"
    echo "  Warnings:        $WARNINGS_FOUND"
    echo ""
    echo "Reports Generated:"
    echo "  JSON Report:     $SCAN_REPORT"
    echo "  Summary Report:  $SCAN_SUMMARY"
    echo ""
    
    # Overall security assessment
    local total_issues=$((CRITICAL_ISSUES + HIGH_ISSUES + MEDIUM_ISSUES + LOW_ISSUES))
    
    if [ $CRITICAL_ISSUES -gt 0 ]; then
        echo -e "${RED}${BOLD}SECURITY STATUS: CRITICAL - Immediate action required${NC}"
        return 1
    elif [ $HIGH_ISSUES -gt 0 ]; then
        echo -e "${MAGENTA}${BOLD}SECURITY STATUS: HIGH RISK - Address soon${NC}"
        return 1
    elif [ $MEDIUM_ISSUES -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}SECURITY STATUS: MEDIUM RISK - Review and fix${NC}"
        return 0
    elif [ $LOW_ISSUES -gt 0 ]; then
        echo -e "${CYAN}${BOLD}SECURITY STATUS: LOW RISK - Minor issues found${NC}"
        return 0
    else
        echo -e "${GREEN}${BOLD}SECURITY STATUS: CLEAN - No issues detected${NC}"
        return 0
    fi
}

# Main execution
main() {
    local scan_type="all"
    local output_format="console"
    local output_file=""
    local target="${1:-.}"
    
    SCAN_START_TIME=$(date +%s)
    SCAN_TARGET="$(cd "$target" && pwd)"
    SCAN_TYPE="$scan_type"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -f|--format)
                output_format="$2"
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -t|--timeout)
                SCAN_TIMEOUT="$2"
                shift 2
                ;;
            --full)
                scan_type="full"
                shift
                ;;
            --quick)
                scan_type="quick"
                shift
                ;;
            --secrets-only)
                scan_type="secrets"
                shift
                ;;
            --vulns-only)
                scan_type="vulnerabilities"
                shift
                ;;
            --deps-only)
                scan_type="dependencies"
                shift
                ;;
            --all)
                scan_type="all"
                shift
                ;;
            *)
                target="$1"
                shift
                ;;
        esac
    done
    
    # Validate target
    if [ ! -d "$target" ] && [ ! -f "$target" ]; then
        log_error "INVALID_TARGET" "Target does not exist: $target"
        exit 1
    fi
    
    # Initialize
    init_scanner
    load_security_config
    
    echo -e "${BOLD}${BLUE}Starting Security Scan${NC}"
    echo "Target: $target"
    echo "Scan Type: $scan_type"
    echo ""
    
    # Run scans based on type
    case "$scan_type" in
        "all"|"full")
            scan_secrets "$target"
            scan_vulnerabilities "$target"
            scan_permissions "$target"
            scan_dependencies "$target"
            ;;
        "quick")
            scan_secrets "$target"
            scan_vulnerabilities "$target"
            ;;
        "secrets")
            scan_secrets "$target"
            ;;
        "vulnerabilities")
            scan_vulnerabilities "$target"
            ;;
        "permissions")
            scan_permissions "$target"
            ;;
        "dependencies")
            scan_dependencies "$target"
            ;;
    esac
    
    # Generate reports
    generate_summary
    
    # Display results
    if [ "${QUIET:-false}" != "true" ]; then
        display_results
    fi
    
    # Handle output format
    case "$output_format" in
        "json")
            if [ -n "$output_file" ]; then
                cp "$SCAN_REPORT" "$output_file"
                echo "JSON report saved to: $output_file"
            else
                cat "$SCAN_REPORT"
            fi
            ;;
        "markdown")
            if [ -n "$output_file" ]; then
                cp "$SCAN_SUMMARY" "$output_file"
                echo "Markdown report saved to: $output_file"
            else
                cat "$SCAN_SUMMARY"
            fi
            ;;
        "console")
            # Already displayed above
            ;;
    esac
}

# Run main function
main "$@"