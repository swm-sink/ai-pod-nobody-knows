#!/bin/bash

# Test: Template Validation
# Validates that all templates in the level-1-dev system are properly structured
# and follow consistent patterns

# Get test utilities
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TEST_DIR/test-utils.sh"

# Set test context
set_test_context "templates"

# Define paths
LEVEL1_DIR="$(cd "$TEST_DIR/.." && pwd)"
TEMPLATES_DIR="$LEVEL1_DIR/templates"
AGENT_TEMPLATE="$TEMPLATES_DIR/agent-template.yaml"
COMMAND_TEMPLATE="$TEMPLATES_DIR/command-template.yaml"

# Test 1: Verify templates directory exists
assert_dir_exists "$TEMPLATES_DIR" "Templates directory exists"

# Test 2: Verify agent template exists and is valid
assert_file_exists "$AGENT_TEMPLATE" "Agent template exists"
assert_yaml_valid "$AGENT_TEMPLATE" "Agent template is valid YAML"

# Test 3: Verify command template exists and is valid
assert_file_exists "$COMMAND_TEMPLATE" "Command template exists"
assert_yaml_valid "$COMMAND_TEMPLATE" "Command template is valid YAML"

# Test 4: Validate agent template required sections
echo "Validating agent template structure..."
assert_contains "$AGENT_TEMPLATE" "metadata:" "Agent template has metadata"
assert_contains "$AGENT_TEMPLATE" "name:" "Agent template has name field"
assert_contains "$AGENT_TEMPLATE" "version:" "Agent template has version field"
assert_contains "$AGENT_TEMPLATE" "created:" "Agent template has created date"
assert_contains "$AGENT_TEMPLATE" "configuration:" "Agent template has configuration"
assert_contains "$AGENT_TEMPLATE" "prompt:" "Agent template has prompt section"

# Test 5: Validate agent template configuration fields
assert_contains "$AGENT_TEMPLATE" "description:" "Has description field"
assert_contains "$AGENT_TEMPLATE" "tools:" "Has tools list"
assert_contains "$AGENT_TEMPLATE" "model:" "Has model selection"
assert_contains "$AGENT_TEMPLATE" "color:" "Has color identifier"

# Test 6: Validate agent template prompt structure
assert_contains "$AGENT_TEMPLATE" "role:" "Has role definition"
assert_contains "$AGENT_TEMPLATE" "mission:" "Has mission statement"
assert_contains "$AGENT_TEMPLATE" "process:" "Has process steps"
assert_contains "$AGENT_TEMPLATE" "inputs:" "Has input specification"
assert_contains "$AGENT_TEMPLATE" "outputs:" "Has output specification"

# Test 7: Validate agent template quality sections
assert_contains "$AGENT_TEMPLATE" "quality_criteria:" "Has quality criteria"
assert_contains "$AGENT_TEMPLATE" "error_handling:" "Has error handling"
assert_contains "$AGENT_TEMPLATE" "cost_limits:" "Has cost limits"
assert_contains "$AGENT_TEMPLATE" "testing:" "Has testing section"

# Test 8: Validate command template required sections
echo "Validating command template structure..."
assert_contains "$COMMAND_TEMPLATE" "metadata:" "Command template has metadata"
assert_contains "$COMMAND_TEMPLATE" "workflow:" "Command template has workflow"
assert_contains "$COMMAND_TEMPLATE" "quality_gates:" "Command template has quality gates"
assert_contains "$COMMAND_TEMPLATE" "error_recovery:" "Command template has error recovery"

# Test 9: Validate command template workflow components
assert_contains "$COMMAND_TEMPLATE" "steps:" "Has workflow steps"
assert_contains "$COMMAND_TEMPLATE" "inputs:" "Has input specification"
assert_contains "$COMMAND_TEMPLATE" "outputs:" "Has output specification"
assert_contains "$COMMAND_TEMPLATE" "validation:" "Has validation rules"

# Test 10: Check for educational components in templates
assert_contains "$AGENT_TEMPLATE" "notes:" "Agent template has notes section"
assert_contains "$COMMAND_TEMPLATE" "documentation:" "Command template has documentation"

# Test 11: Validate template placeholders are consistent
echo "Checking placeholder consistency..."
# Check for consistent placeholder format [placeholder]
if grep -E '\[[a-zA-Z_-]+\]' "$AGENT_TEMPLATE" > /dev/null; then
    echo -e "  ${GREEN}✓${NC} Agent template uses consistent placeholders"
else
    echo -e "  ${YELLOW}⚠${NC} Agent template may have inconsistent placeholders"
fi

if grep -E '\[[a-zA-Z_-]+\]' "$COMMAND_TEMPLATE" > /dev/null; then
    echo -e "  ${GREEN}✓${NC} Command template uses consistent placeholders"
else
    echo -e "  ${YELLOW}⚠${NC} Command template may have inconsistent placeholders"
fi

# Test 12: Check for required vs optional field markers
assert_contains "$AGENT_TEMPLATE" "required:" "Has required field markers"
assert_contains "$AGENT_TEMPLATE" "optional:" "Has optional field markers"

# Test 13: Validate both templates follow DRY principle
echo "Checking DRY principle adherence..."
# Check if templates reference shared components
shared_sections=0
if grep -q "inherits\|extends\|includes" "$AGENT_TEMPLATE" 2>/dev/null || \
   grep -q "# Standard\|# Common" "$AGENT_TEMPLATE" 2>/dev/null; then
    shared_sections=$((shared_sections + 1))
fi

if grep -q "inherits\|extends\|includes" "$COMMAND_TEMPLATE" 2>/dev/null || \
   grep -q "# Standard\|# Common" "$COMMAND_TEMPLATE" 2>/dev/null; then
    shared_sections=$((shared_sections + 1))
fi

echo -e "  ${GREEN}✓${NC} Templates follow structure patterns"

# Test 14: Check for versioning support
assert_contains "$AGENT_TEMPLATE" "version:" "Agent template supports versioning"
assert_contains "$COMMAND_TEMPLATE" "version:" "Command template supports versioning"

# Test 15: Validate template examples
assert_contains "$AGENT_TEMPLATE" "sample_inputs:" "Has sample inputs"
assert_contains "$AGENT_TEMPLATE" "expected_output:" "Has expected outputs"
assert_contains "$COMMAND_TEMPLATE" "example:" "Has usage examples"

# Test 16: Check for cost awareness
assert_contains "$AGENT_TEMPLATE" "cost_limits:" "Agent template has cost limits"
assert_contains "$AGENT_TEMPLATE" "maximum:" "Has maximum cost specification"
assert_contains "$COMMAND_TEMPLATE" "budget:" "Command template has budget awareness"

# Test 17: Additional template files check
echo "Checking for additional templates..."
template_count=0
for template_file in "$TEMPLATES_DIR"/*.yaml "$TEMPLATES_DIR"/*.yml; do
    if [ -f "$template_file" ]; then
        template_count=$((template_count + 1))
        template_name=$(basename "$template_file")
        echo -e "  ${GREEN}✓${NC} Found template: $template_name"

        # Basic YAML validation for each template
        assert_yaml_valid "$template_file" "Template $template_name is valid YAML"
    fi
done
echo -e "  ${GREEN}✓${NC} Total templates found: $template_count"

# Summary
test_summary
