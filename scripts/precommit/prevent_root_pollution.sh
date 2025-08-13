#!/bin/bash
# Prevent Root Directory Pollution
# Ensures analysis/report files don't end up in the root directory

set -e

ERROR_COUNT=0

echo "🚫 Checking for root directory pollution..."

# Check for analysis/report files being added to root
ROOT_FILES=$(git diff --cached --name-only | grep -E '^[^/]*\.(txt|xml|json)$' | \
    grep -vE '^(README|LICENSE|CONTRIBUTING|DEPLOYMENT|CODE_OF_CONDUCT|requirements|dev-requirements|package|tsconfig|\..*)\.' || true)

if [ -n "$ROOT_FILES" ]; then
    echo "❌ ERROR: Analysis/report files detected in root directory:"
    echo "$ROOT_FILES" | while read -r file; do
        echo "  - $file"
    done
    echo ""
    echo "📁 These files should be moved to appropriate locations:"
    echo "  • Analysis files → .claude/level-2-production/analysis/"
    echo "  • Report files → .claude/level-2-production/reports/"
    echo "  • Temporary files → .claude/archive/"
    echo ""
    echo "💡 Tip: Use 'git reset HEAD <file>' to unstage, then move the file"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# Check for common problematic patterns
PROBLEM_PATTERNS=$(git diff --cached --name-only | grep -E '^[^/]*(audit|report|analysis|validation|compliance|transformation)\.' || true)

if [ -n "$PROBLEM_PATTERNS" ]; then
    echo "⚠️  WARNING: Files with analysis/report patterns in root:"
    echo "$PROBLEM_PATTERNS" | while read -r file; do
        echo "  - $file"
    done
fi

if [ $ERROR_COUNT -eq 0 ]; then
    echo "✅ No root directory pollution detected"
    exit 0
else
    echo ""
    echo "❌ Root directory pollution check failed"
    echo "Please move files to appropriate .claude subdirectories"
    exit 1
fi
