#!/bin/bash
# Simple Error Detection Script for Podcast Pipeline
# Checks for common problems and reports them clearly

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Running Pipeline Error Detection..."

# Check 1: Sessions directory exists and is writable
echo -n "Checking sessions directory... "
if [ -d ".claude/level-2-production/sessions" ] && [ -w ".claude/level-2-production/sessions" ]; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
    echo "  Fix: mkdir -p .claude/level-2-production/sessions"
    exit 1
fi

# Check 2: Required MCP tools are referenced correctly
echo -n "Checking ElevenLabs tool references... "
if grep -q "mcp__ElevenLabs__text_to_speech" .claude/level-2-production/agents/09_audio_synthesizer.md; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
    echo "  Fix: Tool reference needs to be mcp__ElevenLabs__text_to_speech"
    exit 1
fi

# Check 3: Check for session files that might be stuck
echo -n "Checking for stuck sessions... "
STUCK_COUNT=$(find .claude/level-2-production/sessions/active -name "*.json" -mmin +60 2>/dev/null | wc -l)
if [ "$STUCK_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  Found $STUCK_COUNT sessions older than 60 minutes"
    echo "  Consider running: ./recovery-helper.sh cleanup"
fi

# Check 4: Configuration files exist
echo -n "Checking configuration files... "
MISSING_CONFIGS=0
for config in production-config.yaml episode-config.yaml quality-thresholds.yaml; do
    if [ ! -f ".claude/shared/config/$config" ]; then
        echo -e "${RED}Missing: $config${NC}"
        MISSING_CONFIGS=$((MISSING_CONFIGS + 1))
    fi
done
if [ "$MISSING_CONFIGS" -eq 0 ]; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ $MISSING_CONFIGS config files missing${NC}"
fi

# Check 5: Disk space (need at least 1GB free)
echo -n "Checking disk space... "
FREE_SPACE=$(df . | awk 'NR==2 {print $4}')
if [ "$FREE_SPACE" -gt 1048576 ]; then  # 1GB in KB
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  Less than 1GB free space available"
fi

echo ""
echo "🎯 Error Detection Complete!"
