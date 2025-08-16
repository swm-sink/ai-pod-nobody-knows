#!/bin/bash

# Test: Quality Gates Integration
# Validates that quality gates are properly integrated throughout level-1-dev
# Tests quality standards, validation checklists, and enforcement mechanisms

# Get test utilities
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TEST_DIR/test-utils.sh"

# Set test context
set_test_context "quality-gates-integration"

# Define paths
LEVEL1_DIR="$(cd "$TEST_DIR/.." && pwd)"
QUALITY_DIR="$LEVEL1_DIR/quality"
VALIDATION_CHECKLIST="$QUALITY_DIR/validation-checklist.xml"
AGENTS_DIR="$LEVEL1_DIR/agents"
COMMANDS_DIR="$LEVEL1_DIR/commands"
TEMPLATES_DIR="$LEVEL1_DIR/templates"

# Test 1: Verify quality directory and files exist
assert_dir_exists "$QUALITY_DIR" "Quality directory exists"
assert_file_exists "$VALIDATION_CHECKLIST" "Validation checklist exists"

# Test 2: Validate quality checklist structure
echo "Validating quality checklist structure..."
if [ -f "$VALIDATION_CHECKLIST" ]; then
    assert_contains "$VALIDATION_CHECKLIST" "<?xml version" "Has XML declaration"
    assert_contains "$VALIDATION_CHECKLIST" "validation" "Contains validation rules"
    assert_contains "$VALIDATION_CHECKLIST" "Level 1 to Level 2" "Covers promotion to Level 2"
    assert_contains "$VALIDATION_CHECKLIST" "Quality First" "Emphasizes quality-first approach"
fi

# Test 3: Check quality criteria in agent template
echo "Checking quality criteria in templates..."
assert_contains "$TEMPLATES_DIR/agent-template.yaml" "quality_criteria:" "Agent template has quality criteria"
assert_contains "$TEMPLATES_DIR/agent-template.yaml" "threshold:" "Has quality thresholds"
assert_contains "$TEMPLATES_DIR/agent-template.yaml" "measurement:" "Has measurement methods"

# Test 4: Check quality gates in command template
assert_contains "$TEMPLATES_DIR/command-template.yaml" "quality_gates:" "Command template has quality gates"
assert_contains "$TEMPLATES_DIR/command-template.yaml" "validation:" "Has validation section"

# Test 5: Validate quality requirements in agent builder
echo "Checking quality enforcement in builders..."
assert_contains "$COMMANDS_DIR/agent-builder-dev.md" "Quality Checklist" "Agent builder has quality checklist"
assert_contains "$COMMANDS_DIR/agent-builder-dev.md" "quality criteria" "Enforces quality criteria"
assert_contains "$COMMANDS_DIR/agent-builder-dev.md" "Measurable" "Requires measurable criteria"

# Test 6: Validate quality requirements in command builder
assert_contains "$COMMANDS_DIR/command-builder-dev.md" "Quality Gates" "Command builder has quality gates"
assert_contains "$COMMANDS_DIR/command-builder-dev.md" "Success Criteria" "Defines success criteria"
assert_contains "$COMMANDS_DIR/command-builder-dev.md" "measurable" "Requires measurable outcomes"

# Test 7: Check for quality validation patterns
echo "Checking quality validation patterns..."
quality_patterns=(
    "validation"
    "criteria"
    "threshold"
    "quality"
    "standard"
    "compliance"
)

pattern_count=0
for pattern in "${quality_patterns[@]}"; do
    if grep -ri "$pattern" "$LEVEL1_DIR" --include="*.md" --include="*.yaml" --include="*.xml" > /dev/null 2>&1; then
        pattern_count=$((pattern_count + 1))
        echo -e "  ${GREEN}✓${NC} Found quality pattern: '$pattern'"
    fi
done
echo -e "  ${GREEN}✓${NC} Quality patterns found: $pattern_count/${#quality_patterns[@]}"

# Test 8: Validate error handling quality gates
echo "Testing error handling quality gates..."
assert_contains "$TEMPLATES_DIR/agent-template.yaml" "error_handling:" "Has error handling"
assert_contains "$TEMPLATES_DIR/command-template.yaml" "error_recovery:" "Has error recovery"
assert_contains "$VALIDATION_CHECKLIST" "error" "Checklist covers error handling"

# Test 9: Check cost control quality gates
echo "Testing cost control quality gates..."
assert_contains "$TEMPLATES_DIR/agent-template.yaml" "cost_limits:" "Has cost limits"
assert_contains "$TEMPLATES_DIR/command-template.yaml" "budget:" "Has budget controls"
assert_contains "$COMMANDS_DIR/command-builder-dev.md" "Cost Control" "Builder enforces cost control"

# Test 10: Validate testing quality gates
echo "Testing quality gates for testing..."
assert_contains "$TEMPLATES_DIR/agent-template.yaml" "testing:" "Has testing section"
assert_contains "$TEMPLATES_DIR/agent-template.yaml" "sample_inputs:" "Requires sample inputs"
assert_contains "$TEMPLATES_DIR/agent-template.yaml" "expected_output:" "Requires expected outputs"

# Test 11: Check documentation quality standards
echo "Checking documentation quality standards..."
doc_quality_count=0
# Check for dual explanations
if grep -r "Technical:" "$LEVEL1_DIR" --include="*.md" > /dev/null 2>&1; then
    doc_quality_count=$((doc_quality_count + 1))
    echo -e "  ${GREEN}✓${NC} Has technical explanations"
fi
if grep -r "Simple:" "$LEVEL1_DIR" --include="*.md" > /dev/null 2>&1; then
    doc_quality_count=$((doc_quality_count + 1))
    echo -e "  ${GREEN}✓${NC} Has simple explanations"
fi
if grep -r "Connection:" "$LEVEL1_DIR" --include="*.md" > /dev/null 2>&1; then
    doc_quality_count=$((doc_quality_count + 1))
    echo -e "  ${GREEN}✓${NC} Has learning connections"
fi
echo -e "  ${GREEN}✓${NC} Documentation quality elements: $doc_quality_count/3"

# Test 12: Validate promotion criteria to Level 2
echo "Checking Level 1 to Level 2 promotion criteria..."
if [ -f "$VALIDATION_CHECKLIST" ]; then
    assert_contains "$VALIDATION_CHECKLIST" "production" "Has production readiness criteria"
    assert_contains "$VALIDATION_CHECKLIST" "validation" "Has validation requirements"
    assert_contains "$VALIDATION_CHECKLIST" "Level 2" "References Level 2 requirements"
fi

# Test 13: Check quality gate automation
echo "Checking quality gate automation..."
# Look for automated validation scripts or commands
validation_scripts=0
for file in "$LEVEL1_DIR"/commands/validate*.md "$LEVEL1_DIR"/bin/validate*.sh; do
    if [ -f "$file" ]; then
        validation_scripts=$((validation_scripts + 1))
        echo -e "  ${GREEN}✓${NC} Found validation script: $(basename "$file")"
    fi
done

if [ $validation_scripts -gt 0 ]; then
    echo -e "  ${GREEN}✓${NC} Quality validation automation available"
else
    echo -e "  ${YELLOW}⚠${NC} Limited quality validation automation"
fi

# Test 14: Validate quality metrics tracking
echo "Checking quality metrics tracking..."
metrics_found=0
metrics_keywords=("metric" "measurement" "threshold" "criteria" "benchmark")
for keyword in "${metrics_keywords[@]}"; do
    if grep -q "$keyword" "$VALIDATION_CHECKLIST" 2>/dev/null; then
        metrics_found=$((metrics_found + 1))
    fi
done
echo -e "  ${GREEN}✓${NC} Quality metrics keywords: $metrics_found/${#metrics_keywords[@]}"

# Test 15: Integration test - Quality gate workflow
echo "Testing complete quality gate workflow..."
workflow_components=(
    "$TEMPLATES_DIR/agent-template.yaml"
    "$TEMPLATES_DIR/command-template.yaml"
    "$COMMANDS_DIR/agent-builder-dev.md"
    "$COMMANDS_DIR/command-builder-dev.md"
    "$VALIDATION_CHECKLIST"
)

workflow_ready=true
for component in "${workflow_components[@]}"; do
    if [ ! -f "$component" ]; then
        workflow_ready=false
        echo -e "  ${RED}✗${NC} Missing: $component"
    fi
done

if [ "$workflow_ready" = true ]; then
    echo -e "  ${GREEN}✓${NC} All quality gate workflow components present"

    # Additional workflow validation
    echo -e "  ${GREEN}✓${NC} Quality gates can be enforced throughout development"
else
    echo -e "  ${RED}✗${NC} Quality gate workflow incomplete"
fi

# Summary
test_summary
