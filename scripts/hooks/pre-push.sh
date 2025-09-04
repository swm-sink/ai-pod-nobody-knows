#!/bin/bash
# Pre-push hook for secret detection and validation
# This provides last-line defense before code reaches GitHub
set -e

# Color codes for output
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔒 Pre-Push Security Checks${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Track if any checks fail
CHECKS_FAILED=0

# Get project root
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
# Real-agents subdirectory
REAL_AGENTS_DIR="$PROJECT_ROOT/.conductor/real-agents"

# 1. Run Gitleaks to scan all commits being pushed
echo -e "\n${YELLOW}🔍 Scanning for secrets with Gitleaks...${NC}"
if command -v gitleaks &> /dev/null; then
    # Read stdin to get the commits being pushed
    while read local_ref local_sha remote_ref remote_sha; do
        # Skip delete operations
        if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
            continue
        fi

        # For new branches, scan from root
        if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
            echo -e "${YELLOW}  New branch detected, scanning all commits...${NC}"
            if ! gitleaks detect --source "$PROJECT_ROOT" --config "$REAL_AGENTS_DIR/.gitleaks.toml" --verbose --no-banner 2>&1 | grep -v "INFO"; then
                echo -e "${RED}  ❌ Secrets detected in commits!${NC}"
                CHECKS_FAILED=1
            else
                echo -e "${GREEN}  ✅ No secrets detected by Gitleaks${NC}"
            fi
        else
            # Scan only the new commits
            echo -e "${YELLOW}  Scanning commits from $remote_sha to $local_sha...${NC}"
            if ! gitleaks detect --source "$PROJECT_ROOT" --config "$REAL_AGENTS_DIR/.gitleaks.toml" --log-opts="$remote_sha..$local_sha" --verbose --no-banner 2>&1 | grep -v "INFO"; then
                echo -e "${RED}  ❌ Secrets detected in commits!${NC}"
                CHECKS_FAILED=1
            else
                echo -e "${GREEN}  ✅ No secrets detected by Gitleaks${NC}"
            fi
        fi
    done
else
    echo -e "${YELLOW}  ⚠️  Gitleaks not installed. Install with: brew install gitleaks${NC}"
    echo -e "${YELLOW}  Continuing without Gitleaks scanning...${NC}"
fi

# 2. Run detect-secrets as additional check
echo -e "\n${YELLOW}🔍 Running detect-secrets baseline check...${NC}"
if command -v detect-secrets &> /dev/null; then
    # Look for baseline file
    BASELINE_FILE=""
    if [ -f "$PROJECT_ROOT/.secrets.baseline" ]; then
        BASELINE_FILE="$PROJECT_ROOT/.secrets.baseline"
    elif [ -f "$REAL_AGENTS_DIR/config/.secrets.baseline" ]; then
        BASELINE_FILE="$REAL_AGENTS_DIR/config/.secrets.baseline"
    fi

    if [ -n "$BASELINE_FILE" ]; then
        echo -e "${YELLOW}  Using baseline: $BASELINE_FILE${NC}"
        if ! detect-secrets-hook --baseline "$BASELINE_FILE" 2>&1 | grep -v "INFO"; then
            echo -e "${RED}  ❌ New secrets detected by detect-secrets!${NC}"
            echo -e "${YELLOW}  To update baseline: detect-secrets scan --baseline $BASELINE_FILE${NC}"
            CHECKS_FAILED=1
        else
            echo -e "${GREEN}  ✅ No new secrets detected by detect-secrets${NC}"
        fi
    else
        echo -e "${YELLOW}  ⚠️  No secrets baseline found. Creating one...${NC}"
        detect-secrets scan --baseline "$REAL_AGENTS_DIR/config/.secrets.baseline"
        echo -e "${GREEN}  ✅ Baseline created at .conductor/real-agents/config/.secrets.baseline${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  detect-secrets not installed. Install with: pip install detect-secrets${NC}"
fi

# 3. Check for large files
echo -e "\n${YELLOW}📦 Checking for large files...${NC}"
LARGE_FILES_FOUND=0

# Get list of files to be pushed
FILES_TO_CHECK=$(git diff --name-only "$remote_sha..$local_sha" 2>/dev/null || git ls-files)

for file in $FILES_TO_CHECK; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        # Get file size (compatible with both macOS and Linux)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            size=$(stat -f%z "$PROJECT_ROOT/$file" 2>/dev/null || echo "0")
        else
            size=$(stat -c%s "$PROJECT_ROOT/$file" 2>/dev/null || echo "0")
        fi

        # Check if file is larger than 50MB
        if [ "$size" -gt 52428800 ]; then
            echo -e "${RED}  ❌ Large file detected: $file ($(($size / 1048576))MB)${NC}"
            echo -e "${YELLOW}     Consider using Git LFS for files larger than 50MB${NC}"
            LARGE_FILES_FOUND=1
            CHECKS_FAILED=1
        fi
    fi
done

if [ "$LARGE_FILES_FOUND" -eq 0 ]; then
    echo -e "${GREEN}  ✅ No large files detected${NC}"
fi

# 4. Check for hardcoded sensitive patterns
echo -e "\n${YELLOW}🔍 Checking for hardcoded sensitive patterns...${NC}"
PATTERNS_FOUND=0

# Check for hardcoded API endpoints (excluding safe files)
UNSAFE_ENDPOINTS=$(git diff --cached --name-only | \
    xargs grep -l "api\.elevenlabs\.io\|api\.perplexity\.ai\|api\.anthropic\.com\|api\.openai\.com" 2>/dev/null | \
    grep -v ".env.example\|.md\|test_\|.gitleaks.toml" || true)

if [ -n "$UNSAFE_ENDPOINTS" ]; then
    echo -e "${YELLOW}  ⚠️  Warning: Hardcoded API endpoints detected in:${NC}"
    for file in $UNSAFE_ENDPOINTS; do
        echo -e "${YELLOW}     - $file${NC}"
    done
    echo -e "${YELLOW}  Consider using environment variables for API endpoints${NC}"
    PATTERNS_FOUND=1
fi

# Check for voice ID hardcoding (project-specific check)
VOICE_ID_VIOLATIONS=$(grep -r "ZF6FPAbjXT4488VcRRnw" "$REAL_AGENTS_DIR/podcast_production/" \
    --include="*.py" \
    --exclude="config/voice_config.py" \
    --exclude="*test*.py" \
    --exclude="*setup*.py" \
    --exclude="*validate*.py" 2>/dev/null | head -5 || true)

if [ -n "$VOICE_ID_VIOLATIONS" ]; then
    echo -e "${RED}  ❌ Hardcoded voice IDs detected! Use get_production_voice_id() instead${NC}"
    echo "$VOICE_ID_VIOLATIONS" | head -3
    PATTERNS_FOUND=1
    CHECKS_FAILED=1
fi

if [ "$PATTERNS_FOUND" -eq 0 ]; then
    echo -e "${GREEN}  ✅ No problematic patterns detected${NC}"
fi

# 5. Final summary
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$CHECKS_FAILED" -eq 1 ]; then
    echo -e "${RED}❌ Pre-push checks FAILED!${NC}"
    echo -e "${YELLOW}\nTo investigate:${NC}"
    echo -e "${YELLOW}  • Run: gitleaks detect --source . --verbose${NC}"
    echo -e "${YELLOW}  • Check: detect-secrets scan --baseline config/.secrets.baseline${NC}"
    echo -e "${YELLOW}\n⚠️  To bypass (EMERGENCY ONLY): git push --no-verify${NC}"
    echo -e "${RED}  WARNING: Only bypass after manual verification!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All pre-push security checks PASSED!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
fi
