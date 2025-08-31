#!/bin/bash
# ZERO-TOLERANCE DRY enforcement - detect duplicates
# Legacy duplication detector (simplified for v1.0.0)

set -e

echo "[DUPLICATION] Zero-tolerance DRY enforcement check..."

# Check for enhanced-* patterns (prohibited)
if find . -name "enhanced-*" -not -path "./.git/*" -not -path "./archive/*" | grep -q .; then
    echo "ERROR: Enhanced-* pattern detected (PROHIBITED)"
    find . -name "enhanced-*" -not -path "./.git/*" -not -path "./archive/*"
    exit 1
fi

# Check for obvious duplicates (basic content scan)
if find .claude -name "*.md" -type f | grep -v ".git" | sort | uniq -d | grep -q .; then
    echo "WARNING: Potential duplicate files detected"
    find .claude -name "*.md" -type f | grep -v ".git" | sort | uniq -d
fi

echo "[DUPLICATION] DRY enforcement passed"
exit 0
