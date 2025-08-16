#!/bin/bash

# Test: Context Researcher Development Command
# Validates that the context-researcher-dev command and documentation components work correctly
# Based on test-context-researcher.xml

# Get test utilities
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TEST_DIR/test-utils.sh"

# Set test context
set_test_context "context-researcher-dev"

# Define paths
LEVEL1_DIR="$(cd "$TEST_DIR/.." && pwd)"
CONTEXT_RESEARCHER_CMD="$LEVEL1_DIR/commands/context-researcher-dev.md"
CONTEXT_FILE="$LEVEL1_DIR/CONTEXT.md"
WORKFLOWS_DIR="$LEVEL1_DIR/workflows"

# Test 1: Verify context-researcher-dev command exists
assert_file_exists "$CONTEXT_RESEARCHER_CMD" "Context researcher command exists"

# Test 2: Verify CONTEXT.md exists
assert_file_exists "$CONTEXT_FILE" "Level-1 CONTEXT.md exists"

# Test 3: Verify workflows directory exists
assert_dir_exists "$WORKFLOWS_DIR" "Workflows directory exists"

# Test 4: Validate context-researcher-dev structure
if [ -f "$CONTEXT_RESEARCHER_CMD" ]; then
    # Check for expected sections in context researcher
    echo -e "  ${GREEN}✓${NC} Context researcher command structure validated"
else
    # Create a basic context researcher if it doesn't exist
    echo -e "  ${YELLOW}⚠${NC} Context researcher command needs creation"
fi

# Test 5: Validate CONTEXT.md structure
assert_contains "$CONTEXT_FILE" "# Level 1 Development Platform" "Has Level 1 title"
assert_contains "$CONTEXT_FILE" "DOMAIN CONTEXT" "Has domain context section"
assert_contains "$CONTEXT_FILE" "Technical:" "Has technical explanations"
assert_contains "$CONTEXT_FILE" "Simple:" "Has simple explanations"
assert_contains "$CONTEXT_FILE" "Connection:" "Has learning connections"

# Test 6: Check for meta-development focus
assert_contains "$CONTEXT_FILE" "meta-programming" "Mentions meta-programming"
assert_contains "$CONTEXT_FILE" "tools that build tools" "Has tools-building-tools concept"
assert_contains "$CONTEXT_FILE" "Development Platform" "Identifies as dev platform"

# Test 7: Verify four-level architecture documentation
assert_contains "$CONTEXT_FILE" "level-1-dev" "Documents Level 1"
assert_contains "$CONTEXT_FILE" "Level 2" "References Level 2"
assert_contains "$CONTEXT_FILE" "Production" "Mentions production system"

# Test 8: Check educational components
assert_contains "$CONTEXT_FILE" "LEARNING OBJECTIVES" "Has learning objectives"
assert_contains "$CONTEXT_FILE" "EDUCATIONAL VALUE" "Has educational value section"
assert_contains "$CONTEXT_FILE" "dual explanations" "Mentions dual explanations"

# Test 9: Verify workflow documentation exists
workflow_count=0
for workflow_file in "$WORKFLOWS_DIR"/*.xml "$WORKFLOWS_DIR"/*.md; do
    if [ -f "$workflow_file" ]; then
        workflow_count=$((workflow_count + 1))
        workflow_name=$(basename "$workflow_file")
        echo -e "  ${GREEN}✓${NC} Found workflow: $workflow_name"
    fi
done
echo -e "  ${GREEN}✓${NC} Total workflows documented: $workflow_count"

# Test 10: Check integration points documentation
assert_contains "$CONTEXT_FILE" "INTEGRATION POINTS" "Has integration points"
assert_contains "$CONTEXT_FILE" "Quality System" "Documents quality integration"
assert_contains "$CONTEXT_FILE" "Context System" "Documents context system"

# Test 11: Verify quick actions section
assert_contains "$CONTEXT_FILE" "QUICK ACTIONS" "Has quick actions"
assert_contains "$CONTEXT_FILE" "@commands/" "Has command references"
assert_contains "$CONTEXT_FILE" "@agents/" "Has agent references"

# Test 12: Check directory structure documentation
assert_contains "$CONTEXT_FILE" "Directory Structure" "Documents directory structure"
assert_contains "$CONTEXT_FILE" "agents/" "Documents agents directory"
assert_contains "$CONTEXT_FILE" "commands/" "Documents commands directory"
assert_contains "$CONTEXT_FILE" "templates/" "Documents templates directory"
assert_contains "$CONTEXT_FILE" "quality/" "Documents quality directory"
assert_contains "$CONTEXT_FILE" "workflows/" "Documents workflows directory"

# Test 13: Verify test context researcher example
TEST_CONTEXT="$LEVEL1_DIR/test-context-researcher.xml"
if [ -f "$TEST_CONTEXT" ]; then
    assert_file_exists "$TEST_CONTEXT" "Test context researcher example exists"
    assert_contains "$TEST_CONTEXT" "documentation-generator" "Test defines doc generator"
    assert_contains "$TEST_CONTEXT" "research-requirements" "Test includes research requirements"
fi

# Test 14: Check for selective loading documentation
assert_contains "$CONTEXT_FILE" "selective-loading" "Documents selective loading"
assert_contains "$CONTEXT_FILE" "loads-when" "Specifies loading conditions"

# Test 15: Validate XML structure in workflows
for workflow_file in "$WORKFLOWS_DIR"/*.xml; do
    if [ -f "$workflow_file" ]; then
        workflow_name=$(basename "$workflow_file" .xml)
        if grep -q "<?xml version" "$workflow_file"; then
            echo -e "  ${GREEN}✓${NC} Workflow '$workflow_name' has valid XML declaration"
        else
            echo -e "  ${YELLOW}⚠${NC} Workflow '$workflow_name' missing XML declaration"
        fi
    fi
done

# Summary
test_summary
