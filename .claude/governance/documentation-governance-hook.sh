#!/bin/bash
# Documentation Governance Enforcement Hook
# Validates documentation quality and standards compliance

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[GOVERNANCE]${NC} Documentation governance validation..."

violation_count=0

# Process each markdown file
for file in "$@"; do
    if [[ "$file" =~ \.md$ ]]; then
        echo -e "${BLUE}[CHECKING]${NC} $file"

        # Check 1: Educational dual explanations
        has_technical=$(grep -c "Technical:" "$file" || echo 0)
        has_simple=$(grep -c "Simple:" "$file" || echo 0)
        has_connection=$(grep -c "Connection:" "$file" || echo 0)

        if [ "$has_technical" -eq 0 ] || [ "$has_simple" -eq 0 ]; then
            # Allow certain file types to skip educational requirements
            if [[ ! "$file" =~ (README|LICENSE|CHANGELOG|INDEX|\.github/) ]]; then
                echo -e "${YELLOW}[WARNING]${NC} $file missing educational explanations"
                echo -e "${YELLOW}[SUGGEST]${NC} Add Technical: and Simple: sections"
            fi
        else
            echo -e "${GREEN}[OK]${NC} Educational standards met"
        fi

        # Check 2: Prohibited enhanced-* pattern
        if [[ "$(basename "$file")" =~ ^enhanced- ]]; then
            echo -e "${RED}[ERROR]${NC} Enhanced-* pattern prohibited: $file"
            echo -e "${YELLOW}[ACTION]${NC} Rename and consolidate into existing architecture"
            violation_count=$((violation_count + 1))
        fi

        # Check 3: File size limits (warning only)
        file_size=$(wc -c < "$file")
        if [ "$file_size" -gt 10240 ]; then  # 10KB
            echo -e "${YELLOW}[WARNING]${NC} $file is large (${file_size} bytes)"
            echo -e "${YELLOW}[SUGGEST]${NC} Consider splitting into smaller focused files"
        fi

        # Check 4: Naming conventions
        basename_file=$(basename "$file")
        if [[ "$basename_file" =~ (temp|draft|backup|old|copy) ]]; then
            echo -e "${YELLOW}[WARNING]${NC} $file contains temporary naming pattern"
            echo -e "${YELLOW}[SUGGEST]${NC} Use proper naming or remove if not needed"
        fi

        # Check 5: Purpose statement (for certain directories)
        if [[ "$file" =~ \.claude/(agents|commands|docs)/ ]]; then
            if ! grep -q "Purpose:" "$file"; then
                echo -e "${YELLOW}[WARNING]${NC} $file missing Purpose statement"
                echo -e "${YELLOW}[SUGGEST]${NC} Add clear operational purpose"
            fi
        fi

        # Check 6: Updated timestamp
        if [[ "$file" =~ \.claude/context/ ]] || [[ "$file" =~ \.claude/docs/ ]]; then
            if ! grep -E "(Updated|Last Updated):" "$file" >/dev/null; then
                echo -e "${YELLOW}[INFO]${NC} Consider adding Updated timestamp to $file"
            fi
        fi
    fi
done

# Check directory file limits
echo -e "${BLUE}[LIMITS]${NC} Checking directory file limits..."

declare -A LIMITS=(
    [".claude/context"]=15
    [".claude/processes"]=5
    [".claude/agents"]=20
    [".claude/commands"]=40
    [".claude/docs"]=15
)

for dir in "${!LIMITS[@]}"; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "*.md" -type f | wc -l)
        limit=${LIMITS[$dir]}

        if [ "$count" -gt "$limit" ]; then
            echo -e "${RED}[ERROR]${NC} $dir exceeds limit: $count/$limit files"
            echo -e "${YELLOW}[ACTION]${NC} Archive stale files: .claude/systems/archive-stale-files.sh --preview"
            violation_count=$((violation_count + 1))
        else
            echo -e "${GREEN}[OK]${NC} $dir: $count/$limit files"
        fi
    fi
done

# Final validation result
if [ "$violation_count" -gt 0 ]; then
    echo -e "${RED}[GOVERNANCE]${NC} $violation_count violations detected - commit blocked"
    echo -e "${YELLOW}[HELP]${NC} Review .claude/governance/documentation-governance.md for standards"
    exit 1
else
    echo -e "${GREEN}[GOVERNANCE]${NC} Documentation governance validation passed"
    exit 0
fi
