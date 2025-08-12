#!/bin/bash
# Pre-Production Validation Hook
# Ensures system is ready for episode production

echo "🚀 Pre-Production Validation Starting..."
echo "======================================="

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# 1. Check Git State
echo -n "Checking git state... "
if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${GREEN}✓ Clean${NC}"
else
    echo -e "${RED}✗ Uncommitted changes detected${NC}"
    echo "  Please commit or stash changes before production"
    ERRORS=$((ERRORS + 1))
fi

# 2. Check Python Environment
echo -n "Checking Python... "
if python3 --version >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    echo -e "${GREEN}✓ Python $PYTHON_VERSION${NC}"
else
    echo -e "${RED}✗ Python not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 3. Check Disk Space
echo -n "Checking disk space... "
DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 90 ]; then
    echo -e "${GREEN}✓ ${DISK_USAGE}% used${NC}"
else
    echo -e "${YELLOW}⚠ ${DISK_USAGE}% used - Low space${NC}"
fi

# 4. Check Required Directories
echo -n "Checking directories... "
REQUIRED_DIRS=(
    ".claude/level-2-production/sessions"
    ".claude/level-2-production/agents"
    ".claude/level-2-production/tools"
    "projects/nobody-knows/output"
)

DIR_ERRORS=0
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        DIR_ERRORS=$((DIR_ERRORS + 1))
    fi
done

if [ $DIR_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All present${NC}"
else
    echo -e "${RED}✗ $DIR_ERRORS directories missing${NC}"
    ERRORS=$((ERRORS + DIR_ERRORS))
fi

# 5. Check Integration Tests
echo -n "Running quick validation... "
if [ -f ".claude/level-2-production/tests/pipeline-integration-test.sh" ]; then
    if .claude/level-2-production/tests/pipeline-integration-test.sh >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Tests pass${NC}"
    else
        echo -e "${RED}✗ Tests failed${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ Test script not found${NC}"
fi

# 6. Check MCP Connectivity (if configured)
echo -n "Checking MCP servers... "
if [ -n "$PERPLEXITY_API_KEY" ]; then
    echo -e "${GREEN}✓ Perplexity configured${NC}"
else
    echo -e "${YELLOW}⚠ Perplexity not configured${NC}"
fi

echo "======================================="

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ READY FOR PRODUCTION${NC}"
    exit 0
else
    echo -e "${RED}❌ NOT READY: $ERRORS issues found${NC}"
    echo "Please resolve issues before starting production"
    exit 1
fi
