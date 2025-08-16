#!/bin/bash

# Test: Agent Builder Development Command
# Validates that the agent-builder-dev command and related components work correctly
# Based on test-agent-builder.xml

# Get test utilities
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TEST_DIR/test-utils.sh"

# Set test context
set_test_context "agent-builder-dev"

# Define paths
LEVEL1_DIR="$(cd "$TEST_DIR/.." && pwd)"
AGENT_BUILDER_CMD="$LEVEL1_DIR/commands/agent-builder-dev.md"
AGENT_TEMPLATE="$LEVEL1_DIR/templates/agent-template.yaml"
AGENTS_DIR="$LEVEL1_DIR/agents"

# Test 1: Verify agent-builder-dev command exists
assert_file_exists "$AGENT_BUILDER_CMD" "Agent builder command file exists"

# Test 2: Verify agent template exists
assert_file_exists "$AGENT_TEMPLATE" "Agent template file exists"

# Test 3: Verify agents directory exists
assert_dir_exists "$AGENTS_DIR" "Agents directory exists"

# Test 4: Validate agent-builder-dev command structure
assert_contains "$AGENT_BUILDER_CMD" "# Agent Builder Command" "Has correct title"
assert_contains "$AGENT_BUILDER_CMD" "Purpose" "Contains purpose section"
assert_contains "$AGENT_BUILDER_CMD" "Process" "Contains process section"
assert_contains "$AGENT_BUILDER_CMD" "Agent Template" "Contains template section"
assert_contains "$AGENT_BUILDER_CMD" "Quality Checklist" "Contains quality checklist"

# Test 5: Validate agent template structure
assert_contains "$AGENT_TEMPLATE" "metadata:" "Template has metadata section"
assert_contains "$AGENT_TEMPLATE" "configuration:" "Template has configuration section"
assert_contains "$AGENT_TEMPLATE" "prompt:" "Template has prompt section"
assert_contains "$AGENT_TEMPLATE" "quality_criteria:" "Template has quality criteria"
assert_contains "$AGENT_TEMPLATE" "error_handling:" "Template has error handling"

# Test 6: Check for required agent fields in template
assert_contains "$AGENT_TEMPLATE" "name:" "Template includes name field"
assert_contains "$AGENT_TEMPLATE" "tools:" "Template includes tools field"
assert_contains "$AGENT_TEMPLATE" "model:" "Template includes model field"
assert_contains "$AGENT_TEMPLATE" "description:" "Template includes description field"

# Test 7: Verify existing agents follow the template structure
for agent_file in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file" .md)
        # Basic structure check for existing agents
        if grep -q "Purpose" "$agent_file" || grep -q "description" "$agent_file"; then
            echo -e "  ${GREEN}✓${NC} Agent '$agent_name' has basic structure"
        else
            echo -e "  ${YELLOW}⚠${NC} Agent '$agent_name' may need structure update"
        fi
    fi
done

# Test 8: Validate YAML syntax of template
assert_yaml_valid "$AGENT_TEMPLATE" "Agent template has valid YAML"

# Test 9: Check quality criteria requirements
assert_contains "$AGENT_BUILDER_CMD" "Clear, single purpose" "Quality: single purpose"
assert_contains "$AGENT_BUILDER_CMD" "Minimal tool permissions" "Quality: minimal permissions"
assert_contains "$AGENT_BUILDER_CMD" "Explicit input/output specs" "Quality: explicit I/O"
assert_contains "$AGENT_BUILDER_CMD" "Measurable quality criteria" "Quality: measurable criteria"

# Test 10: Verify test agent example exists
TEST_AGENT="$LEVEL1_DIR/test-agent-builder.xml"
if [ -f "$TEST_AGENT" ]; then
    assert_file_exists "$TEST_AGENT" "Test agent builder example exists"
    assert_contains "$TEST_AGENT" "file-validator" "Test defines file-validator agent"
    assert_contains "$TEST_AGENT" "requirements-analysis" "Test includes requirements analysis"
fi

# Test 11: Check for process steps in agent builder
assert_contains "$AGENT_BUILDER_CMD" "Gather Requirements" "Process: gather requirements"
assert_contains "$AGENT_BUILDER_CMD" "Design Agent Structure" "Process: design structure"
assert_contains "$AGENT_BUILDER_CMD" "Write System Prompt" "Process: write prompt"
assert_contains "$AGENT_BUILDER_CMD" "Create Agent File" "Process: create file"
assert_contains "$AGENT_BUILDER_CMD" "Generate Test Cases" "Process: generate tests"

# Test 12: Verify template includes all necessary sections
assert_contains "$AGENT_TEMPLATE" "inputs:" "Template has inputs section"
assert_contains "$AGENT_TEMPLATE" "outputs:" "Template has outputs section"
assert_contains "$AGENT_TEMPLATE" "testing:" "Template has testing section"
assert_contains "$AGENT_TEMPLATE" "cost_limits:" "Template has cost limits"

# Summary
test_summary
