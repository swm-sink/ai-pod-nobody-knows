#!/bin/bash

# Test Coverage Analyzer for Level-1-Dev
# Analyzes test coverage across the level-1-dev framework
# Uses only Claude Code native capabilities

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVEL1_DIR="$(cd "$TEST_DIR/.." && pwd)"
REPORT_FILE="$TEST_DIR/reports/coverage-report-$(date +%Y%m%d-%H%M%S).md"

# Coverage tracking
declare -A COMPONENT_COVERAGE
declare -A TEST_MAPPING
TOTAL_COMPONENTS=0
TESTED_COMPONENTS=0
UNTESTED_COMPONENTS=0

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "GOOD")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        "BAD")
            echo -e "${RED}✗${NC} $message"
            ;;
        "INFO")
            echo -e "${CYAN}ℹ${NC} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Function to calculate percentage
calculate_percentage() {
    local numerator=$1
    local denominator=$2

    if [ $denominator -eq 0 ]; then
        echo "0"
    else
        echo $((numerator * 100 / denominator))
    fi
}

# Function to get coverage status color
get_coverage_status() {
    local percentage=$1

    if [ $percentage -ge 80 ]; then
        echo "GOOD"
    elif [ $percentage -ge 60 ]; then
        echo "WARN"
    else
        echo "BAD"
    fi
}

# Analyze agent coverage
analyze_agents() {
    echo "Analyzing agent coverage..."

    local agents_dir="$LEVEL1_DIR/agents"
    local agent_test="$TEST_DIR/unit/test-agent-builder.sh"
    local agent_count=0
    local tested_count=0

    for agent_file in "$agents_dir"/*.md; do
        if [ -f "$agent_file" ]; then
            agent_count=$((agent_count + 1))
            local agent_name=$(basename "$agent_file" .md)

            # Check if agent is referenced in tests
            if grep -q "$agent_name" "$agent_test" 2>/dev/null || \
               grep -r "$agent_name" "$TEST_DIR" --include="*.sh" 2>/dev/null | grep -q "$agent_name"; then
                COMPONENT_COVERAGE["agents/$agent_name"]=1
                TEST_MAPPING["agents/$agent_name"]="test-agent-builder.sh"
                tested_count=$((tested_count + 1))
                echo "  ${GREEN}✓${NC} $agent_name - tested"
            else
                COMPONENT_COVERAGE["agents/$agent_name"]=0
                echo "  ${RED}✗${NC} $agent_name - not tested"
            fi
        fi
    done

    local coverage=$(calculate_percentage $tested_count $agent_count)
    echo "  Agent Coverage: $tested_count/$agent_count (${coverage}%)"

    TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + agent_count))
    TESTED_COMPONENTS=$((TESTED_COMPONENTS + tested_count))
}

# Analyze command coverage
analyze_commands() {
    echo "Analyzing command coverage..."

    local commands_dir="$LEVEL1_DIR/commands"
    local command_test="$TEST_DIR/unit/test-command-builder.sh"
    local command_count=0
    local tested_count=0

    for command_file in "$commands_dir"/*.md; do
        if [ -f "$command_file" ]; then
            command_count=$((command_count + 1))
            local command_name=$(basename "$command_file" .md)

            # Check if command is referenced in tests
            if grep -q "$command_name" "$command_test" 2>/dev/null || \
               grep -r "$command_name" "$TEST_DIR" --include="*.sh" 2>/dev/null | grep -q "$command_name"; then
                COMPONENT_COVERAGE["commands/$command_name"]=1
                TEST_MAPPING["commands/$command_name"]="test-command-builder.sh"
                tested_count=$((tested_count + 1))
                echo "  ${GREEN}✓${NC} $command_name - tested"
            else
                COMPONENT_COVERAGE["commands/$command_name"]=0
                echo "  ${RED}✗${NC} $command_name - not tested"
            fi
        fi
    done

    local coverage=$(calculate_percentage $tested_count $command_count)
    echo "  Command Coverage: $tested_count/$command_count (${coverage}%)"

    TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + command_count))
    TESTED_COMPONENTS=$((TESTED_COMPONENTS + tested_count))
}

# Analyze template coverage
analyze_templates() {
    echo "Analyzing template coverage..."

    local templates_dir="$LEVEL1_DIR/templates"
    local template_test="$TEST_DIR/unit/test-templates.sh"
    local template_count=0
    local tested_count=0

    for template_file in "$templates_dir"/*.yaml; do
        if [ -f "$template_file" ]; then
            template_count=$((template_count + 1))
            local template_name=$(basename "$template_file" .yaml)

            # Check if template is tested
            if grep -q "$template_name" "$template_test" 2>/dev/null || \
               [ -f "$template_test" ]; then
                COMPONENT_COVERAGE["templates/$template_name"]=1
                TEST_MAPPING["templates/$template_name"]="test-templates.sh"
                tested_count=$((tested_count + 1))
                echo "  ${GREEN}✓${NC} $template_name - tested"
            else
                COMPONENT_COVERAGE["templates/$template_name"]=0
                echo "  ${RED}✗${NC} $template_name - not tested"
            fi
        fi
    done

    local coverage=$(calculate_percentage $tested_count $template_count)
    echo "  Template Coverage: $tested_count/$template_count (${coverage}%)"

    TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + template_count))
    TESTED_COMPONENTS=$((TESTED_COMPONENTS + tested_count))
}

# Analyze workflow coverage
analyze_workflows() {
    echo "Analyzing workflow coverage..."

    local workflows_dir="$LEVEL1_DIR/workflows"
    local workflow_test="$TEST_DIR/integration/test-workflows.sh"
    local workflow_count=0
    local tested_count=0

    for workflow_file in "$workflows_dir"/*.xml "$workflows_dir"/*.md; do
        if [ -f "$workflow_file" ]; then
            workflow_count=$((workflow_count + 1))
            local workflow_name=$(basename "$workflow_file" | sed 's/\.[^.]*$//')

            # Check if workflow is tested
            if grep -q "$workflow_name" "$workflow_test" 2>/dev/null || \
               [ -f "$workflow_test" ]; then
                COMPONENT_COVERAGE["workflows/$workflow_name"]=1
                TEST_MAPPING["workflows/$workflow_name"]="test-workflows.sh"
                tested_count=$((tested_count + 1))
                echo "  ${GREEN}✓${NC} $workflow_name - tested"
            else
                COMPONENT_COVERAGE["workflows/$workflow_name"]=0
                echo "  ${RED}✗${NC} $workflow_name - not tested"
            fi
        fi
    done

    local coverage=$(calculate_percentage $tested_count $workflow_count)
    echo "  Workflow Coverage: $tested_count/$workflow_count (${coverage}%)"

    TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + workflow_count))
    TESTED_COMPONENTS=$((TESTED_COMPONENTS + tested_count))
}

# Analyze quality gate coverage
analyze_quality() {
    echo "Analyzing quality gate coverage..."

    local quality_dir="$LEVEL1_DIR/quality"
    local quality_test="$TEST_DIR/integration/test-quality-gates.sh"
    local quality_count=0
    local tested_count=0

    for quality_file in "$quality_dir"/*.xml "$quality_dir"/*.yaml "$quality_dir"/*.md; do
        if [ -f "$quality_file" ]; then
            quality_count=$((quality_count + 1))
            local quality_name=$(basename "$quality_file" | sed 's/\.[^.]*$//')

            # Check if quality component is tested
            if [ -f "$quality_test" ]; then
                COMPONENT_COVERAGE["quality/$quality_name"]=1
                TEST_MAPPING["quality/$quality_name"]="test-quality-gates.sh"
                tested_count=$((tested_count + 1))
                echo "  ${GREEN}✓${NC} $quality_name - tested"
            else
                COMPONENT_COVERAGE["quality/$quality_name"]=0
                echo "  ${RED}✗${NC} $quality_name - not tested"
            fi
        fi
    done

    local coverage=$(calculate_percentage $tested_count $quality_count)
    echo "  Quality Coverage: $tested_count/$quality_count (${coverage}%)"

    TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + quality_count))
    TESTED_COMPONENTS=$((TESTED_COMPONENTS + tested_count))
}

# Count test files
count_tests() {
    echo "Counting test files..."

    local unit_tests=$(ls -1 "$TEST_DIR/unit/"*.sh 2>/dev/null | wc -l || echo 0)
    local integration_tests=$(ls -1 "$TEST_DIR/integration/"*.sh 2>/dev/null | wc -l || echo 0)
    local total_tests=$((unit_tests + integration_tests))

    echo "  Unit Tests: $unit_tests"
    echo "  Integration Tests: $integration_tests"
    echo "  Total Tests: $total_tests"

    return $total_tests
}

# Generate coverage report
generate_report() {
    mkdir -p "$TEST_DIR/reports"

    cat > "$REPORT_FILE" << EOF
# Test Coverage Report - Level-1-Dev Framework

**Generated**: $(date)
**System**: Level-1-Dev Meta-Development Platform

## Executive Summary

- **Total Components**: $TOTAL_COMPONENTS
- **Tested Components**: $TESTED_COMPONENTS
- **Untested Components**: $UNTESTED_COMPONENTS
- **Overall Coverage**: ${OVERALL_COVERAGE}%
- **Coverage Status**: $COVERAGE_STATUS

## Coverage by Category

| Category | Tested | Total | Coverage | Status |
|----------|--------|-------|----------|---------|
EOF

    # Add category summaries
    for category in agents commands templates workflows quality; do
        local cat_total=0
        local cat_tested=0

        for component in "${!COMPONENT_COVERAGE[@]}"; do
            if [[ "$component" == "$category/"* ]]; then
                cat_total=$((cat_total + 1))
                if [ "${COMPONENT_COVERAGE[$component]}" -eq 1 ]; then
                    cat_tested=$((cat_tested + 1))
                fi
            fi
        done

        if [ $cat_total -gt 0 ]; then
            local cat_coverage=$(calculate_percentage $cat_tested $cat_total)
            local cat_status="✅"
            [ $cat_coverage -lt 80 ] && cat_status="⚠️"
            [ $cat_coverage -lt 60 ] && cat_status="❌"

            echo "| $category | $cat_tested | $cat_total | ${cat_coverage}% | $cat_status |" >> "$REPORT_FILE"
        fi
    done

    cat >> "$REPORT_FILE" << EOF

## Detailed Component Coverage

### ✅ Tested Components

EOF

    # List tested components
    for component in "${!COMPONENT_COVERAGE[@]}"; do
        if [ "${COMPONENT_COVERAGE[$component]}" -eq 1 ]; then
            echo "- $component → ${TEST_MAPPING[$component]}" >> "$REPORT_FILE"
        fi
    done

    cat >> "$REPORT_FILE" << EOF

### ❌ Untested Components

EOF

    # List untested components
    local has_untested=false
    for component in "${!COMPONENT_COVERAGE[@]}"; do
        if [ "${COMPONENT_COVERAGE[$component]}" -eq 0 ]; then
            echo "- $component" >> "$REPORT_FILE"
            has_untested=true
        fi
    done

    if [ "$has_untested" = false ]; then
        echo "*All components have test coverage!*" >> "$REPORT_FILE"
    fi

    cat >> "$REPORT_FILE" << EOF

## Test Distribution

- **Unit Tests**: $(ls -1 "$TEST_DIR/unit/"*.sh 2>/dev/null | wc -l || echo 0)
- **Integration Tests**: $(ls -1 "$TEST_DIR/integration/"*.sh 2>/dev/null | wc -l || echo 0)
- **Total Test Files**: $(find "$TEST_DIR" -name "*.sh" -type f | wc -l)

## Coverage Recommendations

EOF

    # Add recommendations based on coverage
    if [ $OVERALL_COVERAGE -lt 60 ]; then
        cat >> "$REPORT_FILE" << EOF
### ⚠️ Critical - Low Coverage

Your test coverage is below 60%. Consider:
1. Adding unit tests for untested components
2. Creating integration tests for workflows
3. Implementing automated test generation
4. Setting up continuous testing practices

EOF
    elif [ $OVERALL_COVERAGE -lt 80 ]; then
        cat >> "$REPORT_FILE" << EOF
### ⚠️ Warning - Moderate Coverage

Your test coverage is between 60-80%. Consider:
1. Filling gaps in component testing
2. Adding edge case tests
3. Improving integration test coverage
4. Setting coverage targets per category

EOF
    else
        cat >> "$REPORT_FILE" << EOF
### ✅ Good Coverage

Your test coverage is above 80%! To maintain quality:
1. Keep tests updated with changes
2. Add tests for new components
3. Monitor coverage trends
4. Consider mutation testing

EOF
    fi

    cat >> "$REPORT_FILE" << EOF
## Coverage Trends

To track coverage over time, run this analyzer regularly and compare reports.

### Next Steps

1. Review untested components
2. Prioritize critical component testing
3. Set coverage goals (recommend 80%+)
4. Integrate coverage checks in CI/CD

---

*Coverage analyzer version: 1.0.0*
*Report generated: $(date)*
EOF
}

# Main execution
main() {
    echo "=========================================="
    echo "Test Coverage Analysis"
    echo "=========================================="
    echo ""

    # Analyze each category
    analyze_agents
    echo ""
    analyze_commands
    echo ""
    analyze_templates
    echo ""
    analyze_workflows
    echo ""
    analyze_quality
    echo ""
    count_tests
    echo ""

    # Calculate overall coverage
    UNTESTED_COMPONENTS=$((TOTAL_COMPONENTS - TESTED_COMPONENTS))
    OVERALL_COVERAGE=$(calculate_percentage $TESTED_COMPONENTS $TOTAL_COMPONENTS)
    COVERAGE_STATUS=$(get_coverage_status $OVERALL_COVERAGE)

    # Generate report
    generate_report

    # Display summary
    echo "=========================================="
    echo "Coverage Summary"
    echo "=========================================="
    echo ""

    print_status "INFO" "Total Components: $TOTAL_COMPONENTS"
    print_status "GOOD" "Tested: $TESTED_COMPONENTS"

    if [ $UNTESTED_COMPONENTS -gt 0 ]; then
        print_status "BAD" "Untested: $UNTESTED_COMPONENTS"
    fi

    # Display overall coverage with appropriate color
    local status=$(get_coverage_status $OVERALL_COVERAGE)
    print_status "$status" "Overall Coverage: ${OVERALL_COVERAGE}%"

    echo ""
    print_status "INFO" "Report saved to: $REPORT_FILE"
    echo ""

    # Exit with appropriate code
    if [ $OVERALL_COVERAGE -lt 60 ]; then
        exit 1  # Fail if coverage is too low
    else
        exit 0
    fi
}

# Run main function
main "$@"
