#!/bin/bash
# Agent Configuration Validation Script
# Checks YAML syntax and model consistency across all agents

echo "🔍 AGENT CONFIGURATION VALIDATION"
echo "=================================="

AGENT_DIR="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents"
ERRORS=0
TOTAL=0

echo ""
echo "Checking agent configurations..."

for agent_file in "$AGENT_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        TOTAL=$((TOTAL + 1))
        agent_name=$(basename "$agent_file" .md)

        echo ""
        echo "📋 $agent_name"
        echo "   File: $agent_file"

        # Check if YAML frontmatter exists
        if ! grep -q "^---" "$agent_file"; then
            echo "   ❌ No YAML frontmatter found"
            ERRORS=$((ERRORS + 1))
            continue
        fi

        # Extract YAML frontmatter
        yaml_content=$(sed -n '/^---$/,/^---$/p' "$agent_file" | head -n -1 | tail -n +2)

        # Check tools field syntax
        if echo "$yaml_content" | grep -q "^tools:"; then
            tools_line=$(echo "$yaml_content" | grep "^tools:")
            if echo "$tools_line" | grep -q '\[.*\]'; then
                echo "   ✅ Tools field: Array syntax"
            elif echo "$tools_line" | grep -q ','; then
                echo "   ❌ Tools field: Comma-separated (should be array)"
                ERRORS=$((ERRORS + 1))
            else
                echo "   ⚠️  Tools field: Single tool or unusual format"
            fi
        else
            echo "   ✅ Tools field: Omitted (inherits all MCP tools)"
        fi

        # Check model field
        if echo "$yaml_content" | grep -q "^model:"; then
            model_line=$(echo "$yaml_content" | grep "^model:" | head -1)
            if echo "$model_line" | grep -q "claude-opus-4-1-20250805"; then
                echo "   ✅ Model: claude-opus-4-1-20250805"
            else
                echo "   ❌ Model: $(echo "$model_line" | cut -d: -f2 | xargs) (should be claude-opus-4-1-20250805)"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo "   ⚠️  Model: Not specified (will inherit default)"
        fi

        # Check for MCP tool usage
        if echo "$yaml_content" | grep -q "mcp__"; then
            echo "   🔗 MCP Tools: Configured"
        else
            echo "   📝 MCP Tools: None explicitly configured"
        fi

    fi
done

echo ""
echo "=================================="
echo "📊 VALIDATION SUMMARY"
echo "Total agents checked: $TOTAL"
echo "Configuration errors: $ERRORS"

if [ $ERRORS -eq 0 ]; then
    echo "✅ ALL CONFIGURATIONS VALID"
    exit 0
else
    echo "❌ CONFIGURATION ERRORS FOUND"
    echo "Please fix the errors above before proceeding."
    exit 1
fi
