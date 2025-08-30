#!/bin/bash
# File Lifecycle Management Enforcement Hook
# Prevents documentation sprawl and maintains optimal architecture

set -e

# Color output for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[LIFECYCLE]${NC} File lifecycle management check..."

# Directory limits configuration
declare -A LIMITS=(
    [".claude/context"]=15
    [".claude/processes"]=5
    [".claude/agents"]=20
    [".claude/commands"]=40
    [".claude/docs"]=15
)

# Check each governed directory
violation_found=false

for dir in "${!LIMITS[@]}"; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "*.md" -type f | wc -l)
        limit=${LIMITS[$dir]}

        if [ "$count" -gt "$limit" ]; then
            echo -e "${RED}[ERROR]${NC} $dir has $count files (limit: $limit)"
            echo -e "${YELLOW}[SUGGEST]${NC} Run: .claude/systems/archive-stale-files.sh --preview"
            violation_found=true
        else
            echo -e "${GREEN}[OK]${NC} $dir: $count/$limit files"
        fi
    fi
done

# Check for prohibited enhanced-* patterns
if find . -name "enhanced-*" -not -path "./.git/*" -not -path "./archive/*" | grep -q .; then
    echo -e "${RED}[ERROR]${NC} Enhanced-* pattern detected (PROHIBITED)"
    echo -e "${YELLOW}[ACTION]${NC} Consolidate into existing architecture"
    find . -name "enhanced-*" -not -path "./.git/*" -not -path "./archive/*"
    violation_found=true
fi

# Check for process file accumulation
process_count=$(find .claude/processes -name "*.md" -type f 2>/dev/null | wc -l)
if [ "$process_count" -gt 10 ]; then
    echo -e "${YELLOW}[WARNING]${NC} Process directory growing ($process_count files)"
    echo -e "${YELLOW}[SUGGEST]${NC} Archive completed processes"
fi

# Success or failure
if [ "$violation_found" = true ]; then
    echo -e "${RED}[LIFECYCLE]${NC} File lifecycle violations detected - commit blocked"
    exit 1
else
    echo -e "${GREEN}[LIFECYCLE]${NC} File lifecycle management passed"
    exit 0
fi
