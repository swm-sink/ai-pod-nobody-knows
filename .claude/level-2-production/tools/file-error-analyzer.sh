#!/bin/bash
# File Error Analyzer - Analyzes text files for error patterns
# Used by test suite to validate error detection capabilities

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file_to_analyze>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

# Count different types of errors
ERROR_COUNT=$(grep -ci "error" "$FILE" 2>/dev/null || echo "0")
FAILURE_COUNT=$(grep -ci "failure\|failed" "$FILE" 2>/dev/null || echo "0")
WARNING_COUNT=$(grep -ci "warning" "$FILE" 2>/dev/null || echo "0")

TOTAL_ERRORS=$((ERROR_COUNT + FAILURE_COUNT))

echo "$TOTAL_ERRORS errors found"
echo "Details:"
echo "  Errors: $ERROR_COUNT"
echo "  Failures: $FAILURE_COUNT"
echo "  Warnings: $WARNING_COUNT"

if [ $TOTAL_ERRORS -gt 0 ]; then
    echo ""
    echo "Error lines:"
    grep -i "error\|failure\|failed" "$FILE" 2>/dev/null | head -5
fi

exit 0
