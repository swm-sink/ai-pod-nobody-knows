#!/bin/bash
# .claude/governance/validate-root-limit.sh

ROOT_FILES=$(find . -maxdepth 1 -type f -not -path "./.*" | wc -l)
MAX_FILES=8

if [ $ROOT_FILES -gt $MAX_FILES ]; then
    echo "❌ ROOT DIRECTORY VIOLATION: $ROOT_FILES files found, maximum $MAX_FILES allowed"
    echo "Files in root:"
    find . -maxdepth 1 -type f -not -path "./.*" | sort
    echo ""
    echo "REQUIRED ACTION: Move files to appropriate subdirectories:"
    echo "  - .py files → src/"
    echo "  - .md files → docs/"
    echo "  - .sh files → build/scripts/"
    echo "  - Config files → config/"
    exit 1
fi

echo "✅ Root directory compliance: $ROOT_FILES/$MAX_FILES files"
