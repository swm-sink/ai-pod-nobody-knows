#!/usr/bin/env bash

# Simple validation test

echo "=== CONFIGURATION VALIDATION TEST ==="
echo "Testing for hardcoded values in specific files..."
echo ""

# Test quality_gates.yaml
echo "Testing config/quality_gates.yaml:"
if grep -q "27.*minute\|0\.8[0-9]" config/quality_gates.yaml 2>/dev/null; then
    echo "❌ VIOLATION: Found hardcoded values in quality_gates.yaml"
    grep -n "27.*minute\|0\.8[0-9]" config/quality_gates.yaml | head -3
else
    echo "✅ No violations found"
fi
echo ""

# Test environment.yaml
echo "Testing config/environment.yaml:"
if grep -q "duration_minutes.*[0-9]\+\|target_word_count.*[0-9]\+" config/environment.yaml 2>/dev/null; then
    echo "❌ VIOLATION: Found hardcoded values in environment.yaml"
    grep -n "duration_minutes.*[0-9]\+\|target_word_count.*[0-9]\+" config/environment.yaml | head -3
else
    echo "✅ No violations found"
fi
echo ""

# Test agents with 47-minute references
echo "Testing agent files for '47' minute references:"
AGENT_VIOLATIONS=$(find agents -name "*.md" -exec grep -l "47.*minute\|35k.*character" {} \; 2>/dev/null)
if [[ -n "$AGENT_VIOLATIONS" ]]; then
    echo "❌ VIOLATION: Found hardcoded episode durations:"
    echo "$AGENT_VIOLATIONS"
else
    echo "✅ No agent violations found"
fi
echo ""

# Count total files that should be migrated
echo "Files that should use CONFIG references:"
find . -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.json" -o -name "*.sh" \) \
    -exec grep -l "47.*minute\|25-30.*minute\|35k.*character\|0\.8[5-9]\|\$[0-9]\+\.[0-9]\+" {} \; 2>/dev/null | \
    grep -v "production-config.yaml" | wc -l

echo ""
echo "=== TEST COMPLETE ==="
