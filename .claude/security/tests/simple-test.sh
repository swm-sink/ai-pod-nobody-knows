#!/bin/bash

# Simple Security Test
# Tests that the security check can detect obvious API keys

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== Simple Security Detection Test ===${NC}"
echo ""

# Create a temporary test file with a fake API key
TEST_FILE="test-leak-temp.txt"

echo -e "${YELLOW}1. Creating test file with fake OpenAI key...${NC}"
echo 'OPENAI_KEY="sk-proj-testkey1234567890abcdefghijklmnopqrstuvwxyz123456"' > "$TEST_FILE"

echo -e "${YELLOW}2. Staging the file...${NC}"
git add "$TEST_FILE"

echo -e "${YELLOW}3. Running security check...${NC}"
echo ""

# Run the security check
if bash /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.git/hooks/pre-push-security-check.sh; then
    echo -e "${RED}❌ TEST FAILED: Security check should have detected the API key${NC}"
    RESULT=1
else
    echo -e "${GREEN}✅ TEST PASSED: Security check correctly detected the API key${NC}"
    RESULT=0
fi

echo ""
echo -e "${YELLOW}4. Cleaning up test file...${NC}"
git reset HEAD "$TEST_FILE" 2>/dev/null || true
rm -f "$TEST_FILE"

echo ""
if [ $RESULT -eq 0 ]; then
    echo -e "${GREEN}🎉 Security detection is working correctly!${NC}"
else
    echo -e "${RED}⚠️  Security detection may not be working properly${NC}"
fi

exit $RESULT