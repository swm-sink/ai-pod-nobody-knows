#!/bin/bash

# Secret Detector for Level-1-Dev Quality System
# Comprehensive detection of hardcoded secrets, credentials, and sensitive data

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
REPORT_DIR="$SCRIPT_DIR/reports"
RULES_DIR="$SCRIPT_DIR/.secret-rules"
SCAN_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SECRET_REPORT="$REPORT_DIR/secret-scan-$SCAN_TIMESTAMP.json"
SECRET_SUMMARY="$REPORT_DIR/secret-summary-$SCAN_TIMESTAMP.md"

# Scan configuration
MAX_FILE_SIZE="10M"
SCAN_TIMEOUT=300  # 5 minutes
ENTROPY_THRESHOLD=4.5  # Minimum entropy for secret detection
MIN_SECRET_LENGTH=8
MAX_SECRET_LENGTH=100

# Secret detection counters
TOTAL_FILES_SCANNED=0
SECRETS_FOUND=0
FALSE_POSITIVES=0
HIGH_CONFIDENCE=0
MEDIUM_CONFIDENCE=0
LOW_CONFIDENCE=0

# File extensions to scan
SCAN_EXTENSIONS=(
    "sh" "bash" "zsh" "fish"
    "py" "pyw" "pyx"
    "js" "jsx" "ts" "tsx" "mjs"
    "rb" "rbw"
    "php" "phtml"
    "java" "scala" "kt"
    "go" "mod"
    "rs" "toml"
    "c" "cpp" "cc" "cxx" "h" "hpp"
    "cs" "vb" "fs"
    "swift" "m" "mm"
    "pl" "pm" "t"
    "lua" "tcl"
    "yaml" "yml" "json" "xml"
    "conf" "config" "cfg" "ini"
    "env" "properties"
    "sql" "psql" "mysql"
    "dockerfile" "makefile"
    "md" "txt" "rst"
)

# Function: Display help
show_help() {
    cat << EOF
Secret Detector for Level-1-Dev Quality System

Usage: $(basename "$0") [options] [target]

Options:
    -h, --help              Show this help message
    -v, --verbose           Show detailed output including low confidence findings
    -q, --quiet             Suppress non-error output
    -f, --format FORMAT     Output format (json|markdown|console) [default: console]
    -o, --output FILE       Output file path
    -t, --timeout SEC       Scan timeout in seconds [default: 300]
    --entropy-threshold N   Minimum entropy for secret detection [default: 4.5]
    --min-length N          Minimum secret length [default: 8]
    --max-length N          Maximum secret length [default: 100]

Detection Modes:
    --all                   Scan for all types of secrets (default)
    --api-keys              Only scan for API keys and tokens
    --passwords             Only scan for passwords
    --crypto                Only scan for cryptographic keys
    --high-entropy          Only scan for high-entropy strings
    --custom PATTERN        Use custom regex pattern

Confidence Levels:
    --high-only             Only report high confidence findings
    --medium-plus           Report medium and high confidence findings (default)
    --all-confidence        Report all confidence levels

Target:
    [target]                Directory or file to scan [default: current directory]

Examples:
    $(basename "$0")                              # Scan current directory
    $(basename "$0") --api-keys /path/to/code     # Only scan for API keys
    $(basename "$0") --high-only --format json   # High confidence JSON output
    $(basename "$0") --custom "sk_[a-zA-Z0-9]{24}" # Custom pattern

Whitelist:
    Create .secretignore file to exclude false positives:
    # Lines starting with # are comments
    password_example = "example123"
    test_api_key = "your_key_here"

EOF
}

# Function: Initialize secret detector
init_secret_detector() {
    setup_error_handling
    
    # Create directories
    mkdir -p "$REPORT_DIR" "$RULES_DIR"
    
    # Initialize report
    cat > "$SECRET_REPORT" << EOF
{
  "scan_info": {
    "timestamp": "$(date -Iseconds)",
    "detector_version": "1.0.0",
    "target": "",
    "duration_seconds": 0,
    "entropy_threshold": $ENTROPY_THRESHOLD,
    "min_secret_length": $MIN_SECRET_LENGTH,
    "max_secret_length": $MAX_SECRET_LENGTH
  },
  "summary": {
    "total_files_scanned": 0,
    "secrets_found": 0,
    "false_positives": 0,
    "high_confidence": 0,
    "medium_confidence": 0,
    "low_confidence": 0
  },
  "findings": []
}
EOF
    
    # Load secret detection rules
    load_secret_rules
    
    log_info "DETECTOR_INITIALIZED" "Secret detector initialized"
}

# Function: Load secret detection rules
load_secret_rules() {
    # Create default rules if they don't exist
    if [ ! -f "$RULES_DIR/api-keys.txt" ]; then
        create_default_rules
    fi
    
    log_info "RULES_LOADED" "Secret detection rules loaded"
}

# Function: Create default secret detection rules
create_default_rules() {
    # API Keys and Tokens
    cat > "$RULES_DIR/api-keys.txt" << 'EOF'
# API Keys and Access Tokens
api[_-]?key\s*[:=]\s*["\047]([a-zA-Z0-9]{20,})["\047]
access[_-]?token\s*[:=]\s*["\047]([a-zA-Z0-9]{20,})["\047]
auth[_-]?token\s*[:=]\s*["\047]([a-zA-Z0-9]{20,})["\047]
bearer[_-]?token\s*[:=]\s*["\047]([a-zA-Z0-9]{20,})["\047]
client[_-]?secret\s*[:=]\s*["\047]([a-zA-Z0-9]{20,})["\047]
secret[_-]?key\s*[:=]\s*["\047]([a-zA-Z0-9]{20,})["\047]

# AWS Keys
AKIA[0-9A-Z]{16}
["\047][0-9a-zA-Z/+]{40}["\047]

# Google API Keys
AIza[0-9A-Za-z\-_]{35}
ya29\.[0-9A-Za-z\-_]+

# Stripe Keys
sk_live_[a-zA-Z0-9]{24,}
pk_live_[a-zA-Z0-9]{24,}
rk_live_[a-zA-Z0-9]{24,}

# GitHub Tokens
ghp_[a-zA-Z0-9]{36}
gho_[a-zA-Z0-9]{36}
ghu_[a-zA-Z0-9]{36}
ghs_[a-zA-Z0-9]{36}
ghr_[a-zA-Z0-9]{36}

# GitLab Tokens
glpat-[a-zA-Z0-9\-_]{20}

# Slack Tokens
xox[baprs]-[a-zA-Z0-9\-]+

# Discord Tokens
[MN][a-zA-Z\d]{23}\.[a-zA-Z\d]{6}\.[a-zA-Z\d]{27}

# Twilio
SK[a-fA-F0-9]{32}
AC[a-fA-F0-9]{32}

# SendGrid
SG\.[a-zA-Z0-9\-_]{22}\.[a-zA-Z0-9\-_]{43}

# Mailgun
key-[a-fA-F0-9]{32}

# Square
sq0atp-[a-zA-Z0-9\-_]{22}
sq0csp-[a-zA-Z0-9\-_]{43}
EOF

    # Passwords
    cat > "$RULES_DIR/passwords.txt" << 'EOF'
# Password Patterns
password\s*[:=]\s*["\047]([^"\047\s]{8,})["\047]
passwd\s*[:=]\s*["\047]([^"\047\s]{8,})["\047]
pwd\s*[:=]\s*["\047]([^"\047\s]{8,})["\047]
pass\s*[:=]\s*["\047]([^"\047\s]{8,})["\047]

# Database Connection Strings
mysql://[a-zA-Z0-9]+:[a-zA-Z0-9]+@
postgres://[a-zA-Z0-9]+:[a-zA-Z0-9]+@
mongodb://[a-zA-Z0-9]+:[a-zA-Z0-9]+@
redis://[a-zA-Z0-9]+:[a-zA-Z0-9]+@

# FTP/SFTP Credentials
ftp://[a-zA-Z0-9]+:[a-zA-Z0-9]+@
sftp://[a-zA-Z0-9]+:[a-zA-Z0-9]+@
EOF

    # Cryptographic Keys
    cat > "$RULES_DIR/crypto-keys.txt" << 'EOF'
# Private Keys
-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----
-----BEGIN\s+OPENSSH\s+PRIVATE\s+KEY-----
-----BEGIN\s+DSA\s+PRIVATE\s+KEY-----
-----BEGIN\s+EC\s+PRIVATE\s+KEY-----
-----BEGIN\s+PGP\s+PRIVATE\s+KEY\s+BLOCK-----

# Certificates
-----BEGIN\s+CERTIFICATE-----
-----BEGIN\s+PUBLIC\s+KEY-----

# SSH Keys
ssh-rsa\s+[A-Za-z0-9+/]{300,}
ssh-dss\s+[A-Za-z0-9+/]{300,}
ssh-ed25519\s+[A-Za-z0-9+/]{68}
ecdsa-sha2-nistp256\s+[A-Za-z0-9+/]{100,}

# GPG Keys
[0-9A-F]{8}\s+[0-9A-F]{8}\s+[0-9A-F]{8}\s+[0-9A-F]{8}
EOF

    # Common patterns to ignore (whitelist)
    cat > "$RULES_DIR/whitelist.txt" << 'EOF'
# Common test/example patterns to ignore
password\s*[:=]\s*["\047](password|123456|test|example|sample|demo|your_password_here|insert_password)["\047]
api[_-]?key\s*[:=]\s*["\047](your_api_key_here|insert_key|example_key|test_key|api_key_here)["\047]
token\s*[:=]\s*["\047](your_token_here|insert_token|example_token|test_token|token_here)["\047]
secret\s*[:=]\s*["\047](your_secret_here|insert_secret|example_secret|test_secret|secret_here)["\047]

# Placeholder patterns
\$\{[A-Z_]+\}
\{\{[A-Z_]+\}\}
%[A-Z_]+%
<[A-Z_]+>

# Common non-secrets
["\047][A-Za-z0-9+/]{4}=["\047]
["\047][0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}["\047]
EOF

    log_info "DEFAULT_RULES_CREATED" "Created default secret detection rules"
}

# Function: Calculate string entropy
calculate_entropy() {
    local string="$1"
    local length=${#string}
    
    if [ $length -eq 0 ]; then
        echo "0"
        return
    fi
    
    # Count character frequencies
    declare -A char_count
    for ((i=0; i<length; i++)); do
        local char="${string:$i:1}"
        ((char_count["$char"]++))
    done
    
    # Calculate entropy
    local entropy=0
    for count in "${char_count[@]}"; do
        local probability=$(echo "scale=10; $count / $length" | bc -l 2>/dev/null || echo "0")
        if [ "$(echo "$probability > 0" | bc -l 2>/dev/null || echo "0")" = "1" ]; then
            local log_prob=$(echo "scale=10; l($probability) / l(2)" | bc -l 2>/dev/null || echo "0")
            entropy=$(echo "scale=10; $entropy - ($probability * $log_prob)" | bc -l 2>/dev/null || echo "0")
        fi
    done
    
    echo "$entropy"
}

# Function: Check if string is whitelisted
is_whitelisted() {
    local string="$1"
    local file_path="$2"
    
    # Check .secretignore file
    if [ -f ".secretignore" ]; then
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            
            if echo "$string" | grep -qE "$line"; then
                return 0
            fi
        done < ".secretignore"
    fi
    
    # Check whitelist rules
    if [ -f "$RULES_DIR/whitelist.txt" ]; then
        while IFS= read -r pattern; do
            # Skip comments and empty lines
            [[ "$pattern" =~ ^#.*$ ]] && continue
            [[ -z "$pattern" ]] && continue
            
            if echo "$string" | grep -qE "$pattern"; then
                return 0
            fi
        done < "$RULES_DIR/whitelist.txt"
    fi
    
    # Check for common test patterns
    local test_patterns=(
        "test|example|sample|demo|dummy|placeholder|your_.*_here"
        "insert_|add_your_|replace_with_"
        "123456|password|qwerty"
        "lorem|ipsum|dolor|sit|amet"
    )
    
    for pattern in "${test_patterns[@]}"; do
        if echo "$string" | grep -qiE "$pattern"; then
            return 0
        fi
    done
    
    return 1
}

# Function: Determine confidence level
determine_confidence() {
    local string="$1"
    local pattern_type="$2"
    local entropy="$3"
    local file_path="$4"
    local line_content="$5"
    
    local confidence="low"
    local score=0
    
    # Pattern-based scoring
    case "$pattern_type" in
        "api-key"|"token"|"secret")
            ((score += 3))
            ;;
        "password")
            ((score += 2))
            ;;
        "crypto-key")
            ((score += 4))
            ;;
        "high-entropy")
            ((score += 1))
            ;;
    esac
    
    # Entropy scoring
    if (( $(echo "$entropy > 4.5" | bc -l 2>/dev/null || echo "0") )); then
        ((score += 2))
    elif (( $(echo "$entropy > 3.5" | bc -l 2>/dev/null || echo "0") )); then
        ((score += 1))
    fi
    
    # Context scoring
    if echo "$line_content" | grep -qiE "(production|prod|live|real|actual)"; then
        ((score += 2))
    elif echo "$line_content" | grep -qiE "(dev|test|debug|example|demo)"; then
        ((score -= 1))
    fi
    
    # File path scoring
    if echo "$file_path" | grep -qE "\.(env|config|conf|secret)"; then
        ((score += 1))
    elif echo "$file_path" | grep -qE "(test|spec|example|demo)"; then
        ((score -= 1))
    fi
    
    # Length scoring
    local length=${#string}
    if [ $length -gt 50 ]; then
        ((score += 1))
    elif [ $length -lt 15 ]; then
        ((score -= 1))
    fi
    
    # Determine final confidence
    if [ $score -ge 6 ]; then
        confidence="high"
    elif [ $score -ge 3 ]; then
        confidence="medium"
    else
        confidence="low"
    fi
    
    echo "$confidence"
}

# Function: Add secret finding
add_secret_finding() {
    local file_path="$1"
    local line_number="$2"
    local line_content="$3"
    local secret_value="$4"
    local pattern_type="$5"
    local confidence="$6"
    local entropy="$7"
    local description="$8"
    
    # Update counters
    ((SECRETS_FOUND++))
    case "$confidence" in
        "high") ((HIGH_CONFIDENCE++)) ;;
        "medium") ((MEDIUM_CONFIDENCE++)) ;;
        "low") ((LOW_CONFIDENCE++)) ;;
    esac
    
    # Mask secret value for reporting
    local masked_secret
    local secret_length=${#secret_value}
    if [ $secret_length -gt 8 ]; then
        masked_secret="${secret_value:0:3}***${secret_value: -3}"
    else
        masked_secret="***"
    fi
    
    # Create finding JSON
    local finding
    finding=$(cat << EOF
{
  "file": "$file_path",
  "line": $line_number,
  "type": "$pattern_type",
  "confidence": "$confidence",
  "entropy": $entropy,
  "description": "$description",
  "secret_hash": "$(echo -n "$secret_value" | sha256sum | cut -d' ' -f1)",
  "masked_value": "$masked_secret",
  "line_content": "$(echo "$line_content" | sed 's/"/\\"/g')",
  "timestamp": "$(date -Iseconds)"
}
EOF
)
    
    # Add to report
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".findings += [$finding]" "$SECRET_REPORT" > "$temp_report"
        mv "$temp_report" "$SECRET_REPORT"
    else
        echo "$finding" >> "${SECRET_REPORT}.findings"
    fi
    
    # Display finding
    local color=""
    case "$confidence" in
        "high") color="$RED" ;;
        "medium") color="$YELLOW" ;;
        "low") color="$CYAN" ;;
    esac
    
    if should_report_confidence "$confidence"; then
        echo -e "${color}[$confidence] $pattern_type in $file_path:$line_number${NC}"
        echo -e "  Description: $description"
        echo -e "  Masked Value: $masked_secret"
        echo -e "  Entropy: $entropy"
        echo -e "  Line: $(echo "$line_content" | sed "s/$secret_value/$masked_secret/g")"
        echo ""
    fi
}

# Function: Check if confidence level should be reported
should_report_confidence() {
    local confidence="$1"
    
    case "${CONFIDENCE_LEVEL:-medium-plus}" in
        "high-only")
            [[ "$confidence" = "high" ]]
            ;;
        "medium-plus")
            [[ "$confidence" =~ ^(medium|high)$ ]]
            ;;
        "all-confidence")
            return 0
            ;;
    esac
}

# Function: Scan for secrets using patterns
scan_with_patterns() {
    local file_path="$1"
    local pattern_file="$2"
    local pattern_type="$3"
    
    if [ ! -f "$pattern_file" ]; then
        return 0
    fi
    
    local line_number=0
    while IFS= read -r line; do
        ((line_number++))
        
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        while IFS= read -r pattern; do
            # Skip comments and empty patterns
            [[ "$pattern" =~ ^#.*$ ]] && continue
            [[ -z "$pattern" ]] && continue
            
            if echo "$line" | grep -qE "$pattern"; then
                # Extract the matched secret
                local secret=$(echo "$line" | grep -oE "$pattern" | head -1)
                
                # Check if whitelisted
                if is_whitelisted "$secret" "$file_path"; then
                    ((FALSE_POSITIVES++))
                    continue
                fi
                
                # Calculate entropy
                local entropy=$(calculate_entropy "$secret")
                
                # Determine confidence
                local confidence=$(determine_confidence "$secret" "$pattern_type" "$entropy" "$file_path" "$line")
                
                # Add finding
                add_secret_finding "$file_path" "$line_number" "$line" "$secret" \
                    "$pattern_type" "$confidence" "$entropy" \
                    "Potential $pattern_type detected using pattern matching"
            fi
        done < "$pattern_file"
        
    done < "$file_path"
}

# Function: Scan for high-entropy strings
scan_high_entropy() {
    local file_path="$1"
    
    local line_number=0
    while IFS= read -r line; do
        ((line_number++))
        
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Look for quoted strings
        local quoted_strings
        quoted_strings=$(echo "$line" | grep -oE '["\047][A-Za-z0-9+/=]{'"$MIN_SECRET_LENGTH"','"$MAX_SECRET_LENGTH"'}["\047]' || true)
        
        echo "$quoted_strings" | while IFS= read -r quoted_string; do
            if [ -n "$quoted_string" ]; then
                # Remove quotes
                local string="${quoted_string:1:-1}"
                
                # Skip if too short or too long
                local length=${#string}
                if [ $length -lt $MIN_SECRET_LENGTH ] || [ $length -gt $MAX_SECRET_LENGTH ]; then
                    continue
                fi
                
                # Calculate entropy
                local entropy=$(calculate_entropy "$string")
                
                # Check if entropy meets threshold
                if (( $(echo "$entropy > $ENTROPY_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
                    # Check if whitelisted
                    if is_whitelisted "$string" "$file_path"; then
                        ((FALSE_POSITIVES++))
                        continue
                    fi
                    
                    # Determine confidence
                    local confidence=$(determine_confidence "$string" "high-entropy" "$entropy" "$file_path" "$line")
                    
                    # Add finding
                    add_secret_finding "$file_path" "$line_number" "$line" "$string" \
                        "high-entropy" "$confidence" "$entropy" \
                        "High-entropy string detected (entropy: $entropy)"
                fi
            fi
        done
        
    done < "$file_path"
}

# Function: Scan single file
scan_file() {
    local file_path="$1"
    local scan_mode="${2:-all}"
    
    ((TOTAL_FILES_SCANNED++))
    
    # Skip binary files
    if file "$file_path" | grep -q "binary"; then
        return 0
    fi
    
    # Skip large files
    local file_size=$(stat -c%s "$file_path" 2>/dev/null || stat -f%z "$file_path" 2>/dev/null || echo "0")
    local max_size_bytes=$(echo "$MAX_FILE_SIZE" | sed 's/M/*1024*1024/g' | bc 2>/dev/null || echo "10485760")
    if [ "$file_size" -gt "$max_size_bytes" ]; then
        log_warn "FILE_TOO_LARGE" "Skipping large file: $file_path ($(($file_size / 1024 / 1024))MB)"
        return 0
    fi
    
    # Run scans based on mode
    case "$scan_mode" in
        "all")
            scan_with_patterns "$file_path" "$RULES_DIR/api-keys.txt" "api-key"
            scan_with_patterns "$file_path" "$RULES_DIR/passwords.txt" "password"
            scan_with_patterns "$file_path" "$RULES_DIR/crypto-keys.txt" "crypto-key"
            scan_high_entropy "$file_path"
            ;;
        "api-keys")
            scan_with_patterns "$file_path" "$RULES_DIR/api-keys.txt" "api-key"
            ;;
        "passwords")
            scan_with_patterns "$file_path" "$RULES_DIR/passwords.txt" "password"
            ;;
        "crypto")
            scan_with_patterns "$file_path" "$RULES_DIR/crypto-keys.txt" "crypto-key"
            ;;
        "high-entropy")
            scan_high_entropy "$file_path"
            ;;
    esac
}

# Function: Generate scan summary
generate_summary() {
    local scan_duration=$(($(date +%s) - SCAN_START_TIME))
    
    # Update final report
    if command -v jq >/dev/null 2>&1; then
        local temp_report=$(mktemp)
        jq ".scan_info.duration_seconds = $scan_duration |
            .summary.total_files_scanned = $TOTAL_FILES_SCANNED |
            .summary.secrets_found = $SECRETS_FOUND |
            .summary.false_positives = $FALSE_POSITIVES |
            .summary.high_confidence = $HIGH_CONFIDENCE |
            .summary.medium_confidence = $MEDIUM_CONFIDENCE |
            .summary.low_confidence = $LOW_CONFIDENCE" \
            "$SECRET_REPORT" > "$temp_report"
        mv "$temp_report" "$SECRET_REPORT"
    fi
    
    # Generate markdown summary
    cat > "$SECRET_SUMMARY" << EOF
# Secret Detection Report

**Scan Date:** $(date)  
**Scan Duration:** ${scan_duration}s  
**Files Scanned:** $TOTAL_FILES_SCANNED  
**Secrets Found:** $SECRETS_FOUND  
**False Positives:** $FALSE_POSITIVES  

## Confidence Levels

| Confidence | Count |
|------------|-------|
| High       | $HIGH_CONFIDENCE |
| Medium     | $MEDIUM_CONFIDENCE |
| Low        | $LOW_CONFIDENCE |

## Detection Methods

- **Pattern Matching**: API keys, tokens, passwords using regex patterns
- **Entropy Analysis**: High-entropy strings indicating potential secrets
- **Context Analysis**: File paths and content context for confidence scoring
- **Whitelist Filtering**: Known false positives filtered out

## Recommendations

EOF

    if [ $HIGH_CONFIDENCE -gt 0 ]; then
        echo "🚨 **HIGH PRIORITY**: Remove $HIGH_CONFIDENCE high-confidence secrets immediately." >> "$SECRET_SUMMARY"
    fi
    
    if [ $MEDIUM_CONFIDENCE -gt 0 ]; then
        echo "⚠️ **MEDIUM PRIORITY**: Review $MEDIUM_CONFIDENCE medium-confidence findings." >> "$SECRET_SUMMARY"
    fi
    
    if [ $SECRETS_FOUND -eq 0 ]; then
        echo "✅ **CLEAN**: No secrets detected in scanned files." >> "$SECRET_SUMMARY"
    fi
    
    cat >> "$SECRET_SUMMARY" << EOF

## Next Steps

1. Review detailed findings in: \`$SECRET_REPORT\`
2. Remove or move secrets to secure storage (environment variables, vaults)
3. Add false positives to .secretignore file
4. Integrate secret scanning into CI/CD pipeline
5. Set up pre-commit hooks to prevent future secret commits

## Security Best Practices

- Use environment variables for secrets
- Use secret management services (AWS Secrets Manager, Azure Key Vault, etc.)
- Never commit secrets to version control
- Rotate compromised secrets immediately
- Use separate secrets for different environments

EOF

    echo "$SECRET_SUMMARY"
}

# Function: Display results
display_results() {
    echo ""
    echo "========================================"
    echo -e "${BOLD}${BLUE}Secret Detection Complete${NC}"
    echo "========================================"
    echo ""
    echo "Files Scanned:     $TOTAL_FILES_SCANNED"
    echo "Secrets Found:     $SECRETS_FOUND"
    echo "False Positives:   $FALSE_POSITIVES"
    echo ""
    echo "Confidence Levels:"
    echo -e "  ${RED}High:   $HIGH_CONFIDENCE${NC}"
    echo -e "  ${YELLOW}Medium: $MEDIUM_CONFIDENCE${NC}"
    echo -e "  ${CYAN}Low:    $LOW_CONFIDENCE${NC}"
    echo ""
    echo "Report: $SECRET_REPORT"
    echo "Summary: $(generate_summary)"
    echo ""
    
    # Security assessment
    if [ $HIGH_CONFIDENCE -gt 0 ]; then
        echo -e "${RED}${BOLD}SECRET STATUS: CRITICAL - Remove secrets immediately${NC}"
        return 1
    elif [ $MEDIUM_CONFIDENCE -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}SECRET STATUS: WARNING - Review potential secrets${NC}"
        return 1
    elif [ $SECRETS_FOUND -gt 0 ]; then
        echo -e "${CYAN}${BOLD}SECRET STATUS: INFO - Low confidence findings detected${NC}"
        return 0
    else
        echo -e "${GREEN}${BOLD}SECRET STATUS: CLEAN - No secrets detected${NC}"
        return 0
    fi
}

# Main execution
main() {
    local target="${1:-.}"
    local scan_mode="all"
    local custom_pattern=""
    
    SCAN_START_TIME=$(date +%s)
    
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
            --entropy-threshold)
                ENTROPY_THRESHOLD="$2"
                shift 2
                ;;
            --min-length)
                MIN_SECRET_LENGTH="$2"
                shift 2
                ;;
            --max-length)
                MAX_SECRET_LENGTH="$2"
                shift 2
                ;;
            --all|--api-keys|--passwords|--crypto|--high-entropy)
                scan_mode="${1#--}"
                shift
                ;;
            --custom)
                custom_pattern="$2"
                scan_mode="custom"
                shift 2
                ;;
            --high-only|--medium-plus|--all-confidence)
                CONFIDENCE_LEVEL="${1#--}"
                shift
                ;;
            *)
                target="$1"
                shift
                ;;
        esac
    done
    
    # Validate target
    if [ ! -e "$target" ]; then
        log_error "INVALID_TARGET" "Target does not exist: $target"
        exit 1
    fi
    
    # Initialize
    init_secret_detector
    
    echo -e "${BOLD}${BLUE}Starting Secret Detection Scan${NC}"
    echo "Target: $target"
    echo "Scan Mode: $scan_mode"
    echo "Entropy Threshold: $ENTROPY_THRESHOLD"
    echo ""
    
    # Handle custom pattern
    if [ "$scan_mode" = "custom" ] && [ -n "$custom_pattern" ]; then
        echo "$custom_pattern" > "$RULES_DIR/custom.txt"
    fi
    
    # Scan files
    if [ -f "$target" ]; then
        # Single file
        scan_file "$target" "$scan_mode"
    else
        # Directory
        while IFS= read -r -d '' file; do
            scan_file "$file" "$scan_mode"
        done < <(find "$target" -type f \
            \( $(printf " -name '*.%s' -o" "${SCAN_EXTENSIONS[@]}" | sed 's/ -o$//') \) \
            -not -path "*/.git/*" \
            -not -path "*/node_modules/*" \
            -not -path "*/.venv/*" \
            -not -path "*/venv/*" \
            -not -path "*/__pycache__/*" \
            -print0)
    fi
    
    # Display results
    if [ "${QUIET:-false}" != "true" ]; then
        display_results
    fi
}

# Run main function
main "$@"