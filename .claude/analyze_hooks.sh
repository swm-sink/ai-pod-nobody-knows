#!/bin/bash

# Script to analyze and categorize all hooks

echo "=== HOOK CATEGORIZATION ANALYSIS ==="
echo ""
echo "Analyzing $(ls -1 .claude/hooks/*.sh | wc -l) hooks..."
echo ""

# Categories
declare -a COST_HOOKS
declare -a JSON_HOOKS
declare -a QUALITY_HOOKS
declare -a MONITORING_HOOKS
declare -a CHECKPOINT_HOOKS
declare -a VALIDATION_HOOKS
declare -a OTHER_HOOKS

# Categorize each hook
for hook in .claude/hooks/*.sh; do
    name=$(basename "$hook")

    # Check for cost-related
    if echo "$name" | grep -qE "cost|budget|anomaly"; then
        COST_HOOKS+=("$name")
    # Check for JSON-related
    elif echo "$name" | grep -qE "json"; then
        JSON_HOOKS+=("$name")
    # Check for quality-related
    elif echo "$name" | grep -qE "quality|validation|gate"; then
        QUALITY_HOOKS+=("$name")
    # Check for monitoring/dashboard
    elif echo "$name" | grep -qE "monitor|dashboard|aggregator|tracker"; then
        MONITORING_HOOKS+=("$name")
    # Check for checkpoint/state
    elif echo "$name" | grep -qE "checkpoint|cleanup|completion"; then
        CHECKPOINT_HOOKS+=("$name")
    # Check for validation/sanitization
    elif echo "$name" | grep -qE "sanitizer|validator|recovery|handler"; then
        VALIDATION_HOOKS+=("$name")
    else
        OTHER_HOOKS+=("$name")
    fi
done

# Display categories
echo "📊 COST TRACKING (${#COST_HOOKS[@]} hooks):"
for h in "${COST_HOOKS[@]}"; do echo "  - $h"; done
echo ""

echo "📄 JSON HANDLING (${#JSON_HOOKS[@]} hooks):"
for h in "${JSON_HOOKS[@]}"; do echo "  - $h"; done
echo ""

echo "⭐ QUALITY CONTROL (${#QUALITY_HOOKS[@]} hooks):"
for h in "${QUALITY_HOOKS[@]}"; do echo "  - $h"; done
echo ""

echo "📈 MONITORING/DASHBOARD (${#MONITORING_HOOKS[@]} hooks):"
for h in "${MONITORING_HOOKS[@]}"; do echo "  - $h"; done
echo ""

echo "💾 CHECKPOINTS/STATE (${#CHECKPOINT_HOOKS[@]} hooks):"
for h in "${CHECKPOINT_HOOKS[@]}"; do echo "  - $h"; done
echo ""

echo "✅ VALIDATION/ERROR HANDLING (${#VALIDATION_HOOKS[@]} hooks):"
for h in "${VALIDATION_HOOKS[@]}"; do echo "  - $h"; done
echo ""

echo "❓ OTHER (${#OTHER_HOOKS[@]} hooks):"
for h in "${OTHER_HOOKS[@]}"; do echo "  - $h"; done
echo ""

echo "=== RECOMMENDATIONS ==="
echo ""
echo "ESSENTIAL HOOKS TO KEEP (5-7):"
echo "1. pre-tool-cost-validation.sh - Prevent budget overruns"
echo "2. post-tool-cost-tracking.sh - Track actual costs"
echo "3. session-cleanup.sh - Clean up on exit"
echo "4. user-prompt-analysis.sh - Input validation"
echo "5. error-recovery-handler.sh - Handle failures gracefully"
echo ""
echo "OPTIONAL/NICE-TO-HAVE (3-5):"
echo "6. notification-handler.sh - User notifications"
echo "7. quality-validation-gate.sh - Quality checks"
echo ""
echo "REDUNDANT/UNNECESSARY (20+):"
echo "- Multiple cost tracking hooks doing similar things"
echo "- Multiple JSON validation hooks"
echo "- Dashboard/monitoring hooks (better as separate tools)"
echo "- Overly specific phase/checkpoint hooks"
