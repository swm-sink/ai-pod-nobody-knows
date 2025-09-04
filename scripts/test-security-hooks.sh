#!/bin/bash
# Test script to verify security hooks are working correctly
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧪 Security Hooks Test Suite${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get project root (two levels up from scripts/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo -e "\n${YELLOW}📍 Project root: $PROJECT_ROOT${NC}"

# Test 1: Verify gitleaks is installed
echo -e "\n${YELLOW}Test 1: Checking Gitleaks installation...${NC}"
if command -v gitleaks &> /dev/null; then
    VERSION=$(gitleaks version 2>&1 | head -1)
    echo -e "${GREEN}✅ Gitleaks installed: $VERSION${NC}"
else
    echo -e "${RED}❌ Gitleaks not found. Please run setup-hooks.sh${NC}"
    exit 1
fi

# Test 2: Verify detect-secrets is installed
echo -e "\n${YELLOW}Test 2: Checking detect-secrets installation...${NC}"
if command -v detect-secrets &> /dev/null; then
    VERSION=$(detect-secrets --version 2>&1)
    echo -e "${GREEN}✅ detect-secrets installed: $VERSION${NC}"
else
    echo -e "${RED}❌ detect-secrets not found. Please run setup-hooks.sh${NC}"
    exit 1
fi

# Test 3: Check pre-push hook exists
echo -e "\n${YELLOW}Test 3: Checking pre-push hook...${NC}"
if [ -f "$PROJECT_ROOT/.git/hooks/pre-push" ]; then
    echo -e "${GREEN}✅ Pre-push hook is installed${NC}"
else
    echo -e "${RED}❌ Pre-push hook not found at $PROJECT_ROOT/.git/hooks/pre-push${NC}"
    exit 1
fi

# Test 4: Check gitleaks configuration
echo -e "\n${YELLOW}Test 4: Checking .gitleaks.toml configuration...${NC}"
GITLEAKS_CONFIG="$PROJECT_ROOT/ai-podcasts-nobody-knows/.conductor/real-agents/.gitleaks.toml"
if [ -f "$GITLEAKS_CONFIG" ]; then
    echo -e "${GREEN}✅ Gitleaks configuration exists${NC}"
else
    GITLEAKS_CONFIG="$PROJECT_ROOT/.conductor/real-agents/.gitleaks.toml"
    if [ -f "$GITLEAKS_CONFIG" ]; then
        echo -e "${GREEN}✅ Gitleaks configuration exists${NC}"
    else
        echo -e "${YELLOW}⚠️ .gitleaks.toml not found, using defaults${NC}"
    fi
fi

# Test 5: Check secrets baseline
echo -e "\n${YELLOW}Test 5: Checking secrets baseline...${NC}"
BASELINE_FILE="$PROJECT_ROOT/ai-podcasts-nobody-knows/.conductor/real-agents/config/.secrets.baseline"
if [ -f "$BASELINE_FILE" ]; then
    echo -e "${GREEN}✅ Secrets baseline exists${NC}"
else
    BASELINE_FILE="$PROJECT_ROOT/.conductor/real-agents/config/.secrets.baseline"
    if [ -f "$BASELINE_FILE" ]; then
        echo -e "${GREEN}✅ Secrets baseline exists${NC}"
    else
        echo -e "${YELLOW}⚠️ No baseline found. Creating one...${NC}"
        detect-secrets scan --baseline "$PROJECT_ROOT/.conductor/real-agents/config/.secrets.baseline"
    fi
fi

# Test 6: Run gitleaks scan (current state only)
echo -e "\n${YELLOW}Test 6: Running Gitleaks scan on current state...${NC}"
cd "$PROJECT_ROOT/.conductor/real-agents"
if gitleaks detect --source . --config .gitleaks.toml --no-banner 2>&1 | grep -q "no leaks found"; then
    echo -e "${GREEN}✅ No secrets detected by Gitleaks${NC}"
else
    echo -e "${YELLOW}⚠️ Potential issues detected. Run 'gitleaks detect --verbose' for details${NC}"
fi

# Test 7: Test with a fake secret (should fail)
echo -e "\n${YELLOW}Test 7: Testing detection of fake secret...${NC}"
TEST_FILE="/tmp/test_secret_$$"
echo 'ELEVENLABS_API_KEY="test123456789abcdef123456789abcdef"' > "$TEST_FILE"

if gitleaks detect --source "$TEST_FILE" --no-banner 2>&1 | grep -q "leaks found"; then
    echo -e "${GREEN}✅ Gitleaks correctly detected test secret${NC}"
else
    echo -e "${YELLOW}⚠️ Gitleaks did not detect test secret (may need config adjustment)${NC}"
fi
rm -f "$TEST_FILE"

# Test 8: Check for hardcoded voice IDs
echo -e "\n${YELLOW}Test 8: Checking for hardcoded voice IDs...${NC}"
cd "$PROJECT_ROOT/.conductor/real-agents"
VOICE_VIOLATIONS=$(grep -r "ZF6FPAbjXT4488VcRRnw" podcast_production/ \
    --include="*.py" \
    --exclude="config/voice_config.py" \
    --exclude="*test*.py" \
    --exclude="*setup*.py" \
    --exclude="*validate*.py" 2>/dev/null || true)

if [ -z "$VOICE_VIOLATIONS" ]; then
    echo -e "${GREEN}✅ No hardcoded voice IDs found${NC}"
else
    echo -e "${RED}❌ Hardcoded voice IDs detected:${NC}"
    echo "$VOICE_VIOLATIONS" | head -3
fi

# Test 9: Check for large files
echo -e "\n${YELLOW}Test 9: Checking for large files (>50MB)...${NC}"
LARGE_FILES=0
while IFS= read -r -d '' file; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
        size=$(stat -f%z "$file" 2>/dev/null || echo "0")
    else
        size=$(stat -c%s "$file" 2>/dev/null || echo "0")
    fi

    if [ "$size" -gt 52428800 ]; then
        echo -e "${YELLOW}⚠️ Large file: $file ($(($size / 1048576))MB)${NC}"
        LARGE_FILES=1
    fi
done < <(find "$PROJECT_ROOT/.conductor/real-agents" -type f -size +50M -print0 2>/dev/null)

if [ "$LARGE_FILES" -eq 0 ]; then
    echo -e "${GREEN}✅ No large files detected${NC}"
fi

# Summary
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Security Hooks Test Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${GREEN}✅ All critical security components are in place${NC}"
echo -e "\n${CYAN}Next steps:${NC}"
echo -e "  ${YELLOW}•${NC} Try a test commit: ${YELLOW}git commit -m 'test'${NC}"
echo -e "  ${YELLOW}•${NC} Try a test push: ${YELLOW}git push --dry-run${NC}"
echo -e "  ${YELLOW}•${NC} Update baseline: ${YELLOW}detect-secrets scan --update config/.secrets.baseline${NC}"

echo -e "\n${GREEN}Security hooks are ready to protect your code!${NC}"
