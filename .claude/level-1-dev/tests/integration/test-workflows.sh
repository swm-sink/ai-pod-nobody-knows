#!/bin/bash

# Test: Workflow Validation (Integration Test)
# Validates that workflows in level-1-dev are properly structured and integrated
# Tests the complete workflow from agent creation to deployment

# Get test utilities
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TEST_DIR/test-utils.sh"

# Set test context
set_test_context "workflows-integration"

# Define paths
LEVEL1_DIR="$(cd "$TEST_DIR/.." && pwd)"
WORKFLOWS_DIR="$LEVEL1_DIR/workflows"
AGENTS_DIR="$LEVEL1_DIR/agents"
COMMANDS_DIR="$LEVEL1_DIR/commands"
TEMPLATES_DIR="$LEVEL1_DIR/templates"

# Test 1: Verify workflows directory structure
assert_dir_exists "$WORKFLOWS_DIR" "Workflows directory exists"

# Test 2: Check for core workflow documentation
echo "Checking core workflow files..."
assert_file_exists "$WORKFLOWS_DIR/level-1-overview.xml" "Level 1 overview exists"
assert_file_exists "$WORKFLOWS_DIR/core-workflows.xml" "Core workflows documentation exists"
assert_file_exists "$WORKFLOWS_DIR/developer-experience.xml" "Developer experience doc exists"
assert_file_exists "$WORKFLOWS_DIR/quality-integration.xml" "Quality integration doc exists"

# Test 3: Validate workflow XML structure
for workflow_file in "$WORKFLOWS_DIR"/*.xml; do
    if [ -f "$workflow_file" ]; then
        workflow_name=$(basename "$workflow_file" .xml)

        # Check for XML declaration
        if grep -q "<?xml version" "$workflow_file"; then
            echo -e "  ${GREEN}✓${NC} Workflow '$workflow_name' has XML declaration"
        else
            echo -e "  ${RED}✗${NC} Workflow '$workflow_name' missing XML declaration"
        fi

        # Check for document type
        assert_contains "$workflow_file" 'type="dev-guide"' "Has dev-guide type: $workflow_name"

        # Check for metadata section
        assert_contains "$workflow_file" "<metadata>" "Has metadata: $workflow_name"
    fi
done

# Test 4: Validate agent creation workflow
echo "Testing agent creation workflow..."
# Check that templates exist for agent creation
assert_file_exists "$TEMPLATES_DIR/agent-template.yaml" "Agent template available"
assert_file_exists "$COMMANDS_DIR/agent-builder-dev.md" "Agent builder command available"

# Verify workflow references in documentation
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "agent-builder-dev" "Workflow references agent builder"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Agent Development Cycle" "Documents agent dev cycle"

# Test 5: Validate command creation workflow
echo "Testing command creation workflow..."
assert_file_exists "$TEMPLATES_DIR/command-template.yaml" "Command template available"
assert_file_exists "$COMMANDS_DIR/command-builder-dev.md" "Command builder available"

# Verify workflow documentation
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "command-builder-dev" "Workflow references command builder"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Command Development Cycle" "Documents command dev cycle"

# Test 6: Test development workflow phases
echo "Validating development phases..."
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Foundation Setup" "Has foundation phase"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Tool Familiarization" "Has familiarization phase"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Integration Understanding" "Has integration phase"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Advanced Development" "Has advanced phase"

# Test 7: Validate quality integration workflow
echo "Testing quality integration..."
assert_contains "$WORKFLOWS_DIR/quality-integration.xml" "quality" "Documents quality processes"
assert_file_exists "$LEVEL1_DIR/quality/validation-checklist.xml" "Quality checklist exists"

# Test 8: Test inter-component dependencies
echo "Validating component dependencies..."
# Agent builder should reference templates
if [ -f "$COMMANDS_DIR/agent-builder-dev.md" ]; then
    assert_contains "$COMMANDS_DIR/agent-builder-dev.md" "template" "Agent builder uses templates"
fi

# Command builder should reference templates
if [ -f "$COMMANDS_DIR/command-builder-dev.md" ]; then
    assert_contains "$COMMANDS_DIR/command-builder-dev.md" "template" "Command builder uses templates"
fi

# Test 9: Validate workflow success criteria
echo "Checking workflow success criteria..."
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "success-criteria" "Has success criteria"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "graduation-criteria" "Has graduation criteria"

# Test 10: Test educational workflow components
echo "Validating educational components..."
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Technical:" "Has technical explanations"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Simple:" "Has simple explanations"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "Learning Value:" "Has learning value"

# Test 11: Validate workflow orchestration patterns
assert_contains "$WORKFLOWS_DIR/core-workflows.xml" "orchestration" "Documents orchestration"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "workflow-orchestration" "Has orchestration patterns"

# Test 12: Check for DRY principle in workflows
echo "Checking DRY principle adherence..."
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "DRY" "References DRY principle"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "single source of truth" "Promotes single source"

# Test 13: Validate cost tracking in workflows
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "cost" "Includes cost considerations"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "budget" "Includes budget management"

# Test 14: Test workflow metrics
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "success-metrics" "Has success metrics"
assert_contains "$WORKFLOWS_DIR/level-1-overview.xml" "measurement" "Has measurement criteria"

# Test 15: End-to-end workflow simulation
echo "Simulating end-to-end workflow..."
# Check that all components needed for a complete workflow exist
components_needed=0
components_found=0

# Check for agent creation components
components_needed=$((components_needed + 3))
[ -f "$TEMPLATES_DIR/agent-template.yaml" ] && components_found=$((components_found + 1))
[ -f "$COMMANDS_DIR/agent-builder-dev.md" ] && components_found=$((components_found + 1))
[ -d "$AGENTS_DIR" ] && components_found=$((components_found + 1))

# Check for command creation components
components_needed=$((components_needed + 3))
[ -f "$TEMPLATES_DIR/command-template.yaml" ] && components_found=$((components_found + 1))
[ -f "$COMMANDS_DIR/command-builder-dev.md" ] && components_found=$((components_found + 1))
[ -d "$COMMANDS_DIR" ] && components_found=$((components_found + 1))

# Check for quality validation
components_needed=$((components_needed + 1))
[ -f "$LEVEL1_DIR/quality/validation-checklist.xml" ] && components_found=$((components_found + 1))

echo -e "  ${GREEN}✓${NC} Workflow components: $components_found/$components_needed available"

if [ $components_found -eq $components_needed ]; then
    echo -e "  ${GREEN}✓${NC} All workflow components present - workflows can execute"
else
    echo -e "  ${YELLOW}⚠${NC} Some workflow components missing"
fi

# Summary
test_summary
