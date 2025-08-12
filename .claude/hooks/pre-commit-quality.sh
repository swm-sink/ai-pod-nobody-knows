#!/bin/bash
# Pre-Commit Quality Validation Hook
# Runs quality checks before allowing commits

echo "🔍 Pre-Commit Quality Validation"
echo "================================"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# 1. Check for backup files
echo -n "Checking for backup files... "
BACKUP_FILES=$(find . -name "*.backup" -o -name "*.bak" -o -name "*~" 2>/dev/null | grep -v ".git")
if [ -z "$BACKUP_FILES" ]; then
    echo -e "${GREEN}✓ None found${NC}"
else
    echo -e "${RED}✗ Backup files detected${NC}"
    echo "$BACKUP_FILES"
    echo "  Please remove backup files and use git instead"
    ERRORS=$((ERRORS + 1))
fi

# 2. Check for TODO markers
echo -n "Checking for TODO markers... "
TODO_COUNT=$(grep -r "TODO\|FIXME\|XXX" --include="*.md" --include="*.xml" --include="*.py" --include="*.sh" . 2>/dev/null | grep -v ".git" | wc -l)
if [ "$TODO_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ None found${NC}"
else
    echo -e "${YELLOW}⚠ $TODO_COUNT TODO markers found${NC}"
fi

# 3. Run integration tests if files changed
echo -n "Checking for agent/tool changes... "
AGENT_CHANGES=$(git diff --cached --name-only | grep -E "(agents|tools|commands)/" | wc -l)
if [ "$AGENT_CHANGES" -gt 0 ]; then
    echo -e "${YELLOW}Changes detected${NC}"
    echo "  Running integration tests..."
    if [ -f ".claude/level-2-production/tests/pipeline-integration-test.sh" ]; then
        if .claude/level-2-production/tests/pipeline-integration-test.sh >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓ Tests pass${NC}"
        else
            echo -e "  ${RED}✗ Tests failed${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
else
    echo -e "${GREEN}✓ No critical changes${NC}"
fi

# 4. Check commit message format
if [ -f ".git/COMMIT_EDITMSG" ]; then
    echo -n "Checking commit message format... "
    COMMIT_MSG=$(cat .git/COMMIT_EDITMSG | head -1)
    if echo "$COMMIT_MSG" | grep -qE "^(feat|fix|docs|style|refactor|test|chore)\(.+\): .+"; then
        echo -e "${GREEN}✓ Valid format${NC}"
    else
        echo -e "${YELLOW}⚠ Non-standard format${NC}"
        echo "  Expected: type(scope): description"
    fi
fi

# 5. Check file sizes
echo -n "Checking file sizes... "
LARGE_FILES=$(find . -type f -size +1M | grep -v ".git" | grep -v "node_modules")
if [ -z "$LARGE_FILES" ]; then
    echo -e "${GREEN}✓ All files reasonable size${NC}"
else
    echo -e "${YELLOW}⚠ Large files detected${NC}"
    echo "$LARGE_FILES"
fi

echo "================================"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ QUALITY CHECKS PASSED${NC}"
    exit 0
else
    echo -e "${RED}❌ QUALITY ISSUES FOUND: $ERRORS${NC}"
    echo "Fix issues or use --no-verify to bypass"
    exit 1
fi
