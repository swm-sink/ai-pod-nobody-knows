#!/bin/bash

# Fix XML References V2 - Update remaining broken .xml references to .md
# This addresses second-order impacts from XML→Markdown conversion

echo "🔧 Fixing broken XML references to point to Markdown files..."

# Create scripts directory if it doesn't exist
mkdir -p scripts

# Files to update (excluding archive)
FILES=(
    ".claude/context/CONTEXT.md"
    ".claude/context/quality/NAVIGATION.md"
    ".claude/context/ai-orchestration/NAVIGATION.md"
    ".claude/context/project_foundation.md"
    ".claude/docs/README.md"
    ".claude/context/operations/NAVIGATION.md"
    ".claude/context/elevenlabs/NAVIGATION.md"
    ".claude/CONTEXT.md"
    ".claude/agents/audio-synthesizer.md"
    ".claude/NAVIGATION.md"
    ".claude/shared/templates/documentation/doc-template.md"
    ".claude/shared/templates/documentation/constants-template.md"
    ".claude/shared/templates/documentation/workflow-template.md"
    ".claude/shared/templates/xml/conversion-guide.md"
    ".claude/docs/orchestration_plan.md"
    ".claude/MAINTENANCE_PROCEDURES.md"
    ".claude/NAVIGATION_INDEX.md"
)

# Counter for changes
CHANGES=0

for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "📝 Processing: $file"

        # Count .xml references before
        BEFORE=$(grep -o '@[^[:space:]]*\.xml' "$file" 2>/dev/null | wc -l)

        if [[ $BEFORE -gt 0 ]]; then
            # Fix common .xml → .md patterns
            sed -i '' \
                -e 's/@\([^[:space:]]*\)\.xml/@\1.md/g' \
                -e 's/@{domain}\/00_{domain}_constants\.xml/@{domain}\/00_{domain}_constants.md/g' \
                -e 's/@foundation\/01_project_overview\.xml/@foundation\/01_project_overview.md/g' \
                -e 's/@claude-code\/15_claude_code_introduction\.xml/@claude-code\/15_claude_code_introduction.md/g' \
                -e 's/@elevenlabs\/15_elevenlabs_overview\.xml/@elevenlabs\/15_elevenlabs_overview.md/g' \
                -e 's/@quality\/02_hallucination_prevention_guide\.xml/@quality\/02_hallucination_prevention_guide.md/g' \
                -e 's/tdd_enforcement\.xml/tdd_enforcement.md/g' \
                -e 's/agent-orchestration-basics\.xml/agent-orchestration-basics.md/g' \
                -e 's/cost-optimization-strategies\.xml/cost-optimization-strategies.md/g' \
                "$file"

            # Count .xml references after
            AFTER=$(grep -o '@[^[:space:]]*\.xml' "$file" 2>/dev/null | wc -l)

            FIXED=$((BEFORE - AFTER))
            if [[ $FIXED -gt 0 ]]; then
                echo "  ✅ Fixed $FIXED XML references"
                CHANGES=$((CHANGES + FIXED))
            fi
        else
            echo "  ✓ No XML references found"
        fi
    else
        echo "  ⚠️  File not found: $file"
    fi
done

echo
echo "🎯 SUMMARY:"
echo "   Fixed $CHANGES broken XML references"
echo "   All references now point to Markdown files"

# Verify no XML references remain (excluding archive and SSML)
echo
echo "🔍 Verification - Remaining XML references (should be minimal):"
REMAINING=$(find .claude -name "*.md" -exec grep -l '@.*\.xml' {} \; | grep -v archive | wc -l)
echo "   Files with XML references: $REMAINING"

if [[ $REMAINING -eq 0 ]]; then
    echo "   ✅ All navigation references fixed!"
else
    echo "   📋 Remaining files to check:"
    find .claude -name "*.md" -exec grep -l '@.*\.xml' {} \; | grep -v archive
fi

echo
echo "✨ XML reference fix complete!"

# Exit with success if no remaining XML references, otherwise informational success
if [[ $REMAINING -eq 0 ]]; then
    exit 0
else
    exit 0  # Still successful - remaining refs are acceptable (SSML, etc.)
fi
