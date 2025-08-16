#!/bin/bash

# Test: Command Builder Development Command
# Validates that the command-builder-dev command and related components work correctly
# Based on test-command-builder.xml

# Get test utilities
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TEST_DIR/test-utils.sh"

# Set test context
set_test_context "command-builder-dev"

# Define paths
LEVEL1_DIR="$(cd "$TEST_DIR/.." && pwd)"
COMMAND_BUILDER_CMD="$LEVEL1_DIR/commands/command-builder-dev.md"
COMMAND_TEMPLATE="$LEVEL1_DIR/templates/command-template.yaml"
COMMANDS_DIR="$LEVEL1_DIR/commands"

# Test 1: Verify command-builder-dev command exists
assert_file_exists "$COMMAND_BUILDER_CMD" "Command builder file exists"

# Test 2: Verify command template exists
assert_file_exists "$COMMAND_TEMPLATE" "Command template file exists"

# Test 3: Verify commands directory exists
assert_dir_exists "$COMMANDS_DIR" "Commands directory exists"

# Test 4: Validate command-builder-dev structure
assert_contains "$COMMAND_BUILDER_CMD" "# Command Builder" "Has correct title"
assert_contains "$COMMAND_BUILDER_CMD" "Purpose" "Contains purpose section"
assert_contains "$COMMAND_BUILDER_CMD" "Process" "Contains process section"
assert_contains "$COMMAND_BUILDER_CMD" "Command Template" "Contains template section"
assert_contains "$COMMAND_BUILDER_CMD" "Quality Checklist" "Contains quality checklist"

# Test 5: Validate command template structure
assert_contains "$COMMAND_TEMPLATE" "metadata:" "Template has metadata section"
assert_contains "$COMMAND_TEMPLATE" "workflow:" "Template has workflow section"
assert_contains "$COMMAND_TEMPLATE" "quality_gates:" "Template has quality gates"
assert_contains "$COMMAND_TEMPLATE" "error_recovery:" "Template has error recovery"

# Test 6: Check for required command fields in builder
assert_contains "$COMMAND_BUILDER_CMD" "Analyze Command Requirements" "Process: analyze requirements"
assert_contains "$COMMAND_BUILDER_CMD" "Design Command Flow" "Process: design flow"
assert_contains "$COMMAND_BUILDER_CMD" "Write Command Structure" "Process: write structure"
assert_contains "$COMMAND_BUILDER_CMD" "Create Command File" "Process: create file"

# Test 7: Verify command workflow components
assert_contains "$COMMAND_BUILDER_CMD" "Sequential vs parallel" "Workflow: execution strategy"
assert_contains "$COMMAND_BUILDER_CMD" "Dependencies between steps" "Workflow: dependencies"
assert_contains "$COMMAND_BUILDER_CMD" "Error handling and recovery" "Workflow: error handling"
assert_contains "$COMMAND_BUILDER_CMD" "Cost and time limits" "Workflow: resource limits"

# Test 8: Check quality gates in command builder
assert_contains "$COMMAND_BUILDER_CMD" "Single, clear purpose" "Quality: clear purpose"
assert_contains "$COMMAND_BUILDER_CMD" "Explicit step sequence" "Quality: explicit sequence"
assert_contains "$COMMAND_BUILDER_CMD" "Quality gates defined" "Quality: gates defined"
assert_contains "$COMMAND_BUILDER_CMD" "Error handling specified" "Quality: error handling"
assert_contains "$COMMAND_BUILDER_CMD" "Cost limits set" "Quality: cost limits"

# Test 9: Verify existing commands follow structure
command_count=0
valid_commands=0
for cmd_file in "$COMMANDS_DIR"/*.md; do
    if [ -f "$cmd_file" ]; then
        command_count=$((command_count + 1))
        cmd_name=$(basename "$cmd_file" .md)

        # Check for basic command structure
        has_purpose=false
        has_process=false

        if grep -q "Purpose" "$cmd_file" || grep -q "purpose" "$cmd_file"; then
            has_purpose=true
        fi

        if grep -q "Process" "$cmd_file" || grep -q "Workflow" "$cmd_file"; then
            has_process=true
        fi

        if [ "$has_purpose" = true ] && [ "$has_process" = true ]; then
            valid_commands=$((valid_commands + 1))
            echo -e "  ${GREEN}✓${NC} Command '$cmd_name' has valid structure"
        else
            echo -e "  ${YELLOW}⚠${NC} Command '$cmd_name' may need structure update"
        fi
    fi
done

echo -e "  ${GREEN}✓${NC} Found $valid_commands/$command_count commands with valid structure"

# Test 10: Validate YAML syntax of command template
assert_yaml_valid "$COMMAND_TEMPLATE" "Command template has valid YAML"

# Test 11: Check command template sections
assert_contains "$COMMAND_TEMPLATE" "inputs:" "Template has inputs section"
assert_contains "$COMMAND_TEMPLATE" "outputs:" "Template has outputs section"
assert_contains "$COMMAND_TEMPLATE" "steps:" "Template has steps section"
assert_contains "$COMMAND_TEMPLATE" "validation:" "Template has validation section"

# Test 12: Verify test command builder example
TEST_COMMAND="$LEVEL1_DIR/test-command-builder.xml"
if [ -f "$TEST_COMMAND" ]; then
    assert_file_exists "$TEST_COMMAND" "Test command builder example exists"
    assert_contains "$TEST_COMMAND" "workflow-validator" "Test defines workflow-validator"
    assert_contains "$TEST_COMMAND" "command-analysis" "Test includes command analysis"
fi

# Test 13: Check error recovery patterns
assert_contains "$COMMAND_BUILDER_CMD" "Recovery strategy" "Has recovery strategy"
assert_contains "$COMMAND_BUILDER_CMD" "Maximum retries" "Has retry limits"
assert_contains "$COMMAND_BUILDER_CMD" "Fallback" "Has fallback approach"

# Test 14: Verify cost control mechanisms
assert_contains "$COMMAND_BUILDER_CMD" "Maximum budget" "Has budget limits"
assert_contains "$COMMAND_BUILDER_CMD" "Per-step limits" "Has per-step cost limits"
assert_contains "$COMMAND_BUILDER_CMD" "Cost Control" "Has cost control section"

# Test 15: Check success criteria definition
assert_contains "$COMMAND_BUILDER_CMD" "Success Criteria" "Has success criteria"
assert_contains "$COMMAND_BUILDER_CMD" "measurable" "Criteria are measurable"

# Summary
test_summary
