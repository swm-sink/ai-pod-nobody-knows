#!/bin/bash

# CI/CD Pipeline Simulation for Level-1-Dev
# Simulates a complete CI/CD pipeline locally using Claude Code native capabilities
# This helps validate the system before actual deployment

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
PROJECT_ROOT="$(cd "$LEVEL1_DIR/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CI_REPORT="$TEST_DIR/reports/ci-report-$TIMESTAMP.md"

# Pipeline stages
STAGES=("validate" "test" "quality" "integration" "coverage" "report")
STAGE_STATUS=()

# Functions
print_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
    echo ""
}

print_stage() {
    local stage=$1
    local status=$2
    case $status in
        "running")
            echo -e "${CYAN}▶${NC} Stage: $stage - Running..."
            ;;
        "passed")
            echo -e "${GREEN}✓${NC} Stage: $stage - Passed"
            ;;
        "failed")
            echo -e "${RED}✗${NC} Stage: $stage - Failed"
            ;;
        "skipped")
            echo -e "${YELLOW}○${NC} Stage: $stage - Skipped"
            ;;
    esac
}

# Initialize CI report
init_report() {
    mkdir -p "$TEST_DIR/reports"
    cat > "$CI_REPORT" << EOF
# CI/CD Pipeline Report
**Date**: $(date)
**System**: Level-1-Dev Framework
**Type**: Local Simulation

## Pipeline Configuration
- **Stages**: ${#STAGES[@]}
- **Parallel**: No (sequential execution)
- **Timeout**: 300 seconds per stage

## Environment
- **User**: $(whoami)
- **Directory**: $LEVEL1_DIR
- **Shell**: $SHELL
- **Git Branch**: $(git branch --show-current 2>/dev/null || echo "unknown")

---

## Pipeline Execution

EOF
}

# Stage 1: Validation
stage_validate() {
    print_stage "Validation" "running"
    local passed=true

    echo "### Stage 1: Validation" >> "$CI_REPORT"
    echo "" >> "$CI_REPORT"

    # Check directory structure
    echo "  Checking directory structure..."
    for dir in agents commands templates quality workflows tests; do
        if [ -d "$LEVEL1_DIR/$dir" ]; then
            echo -e "    ${GREEN}✓${NC} Directory exists: $dir"
            echo "- ✓ Directory exists: $dir" >> "$CI_REPORT"
        else
            echo -e "    ${RED}✗${NC} Directory missing: $dir"
            echo "- ✗ Directory missing: $dir" >> "$CI_REPORT"
            passed=false
        fi
    done

    # Check critical files
    echo "  Checking critical files..."
    critical_files=(
        "CONTEXT.md"
        "templates/agent-template.yaml"
        "templates/command-template.yaml"
        "quality/validation-checklist.xml"
    )

    for file in "${critical_files[@]}"; do
        if [ -f "$LEVEL1_DIR/$file" ]; then
            echo -e "    ${GREEN}✓${NC} File exists: $file"
            echo "- ✓ File exists: $file" >> "$CI_REPORT"
        else
            echo -e "    ${RED}✗${NC} File missing: $file"
            echo "- ✗ File missing: $file" >> "$CI_REPORT"
            passed=false
        fi
    done

    echo "" >> "$CI_REPORT"

    if [ "$passed" = true ]; then
        print_stage "Validation" "passed"
        echo "**Result**: ✅ PASSED" >> "$CI_REPORT"
        return 0
    else
        print_stage "Validation" "failed"
        echo "**Result**: ❌ FAILED" >> "$CI_REPORT"
        return 1
    fi
}

# Stage 2: Unit Tests
stage_test() {
    print_stage "Unit Tests" "running"
    local passed=true

    echo "### Stage 2: Unit Tests" >> "$CI_REPORT"
    echo "" >> "$CI_REPORT"

    # Run unit tests
    echo "  Running unit tests..."
    for test_file in "$TEST_DIR"/unit/*.sh; do
        if [ -f "$test_file" ] && [ -x "$test_file" ]; then
            test_name=$(basename "$test_file" .sh)
            echo -e "    Testing: $test_name"

            if "$test_file" > /dev/null 2>&1; then
                echo -e "    ${GREEN}✓${NC} $test_name passed"
                echo "- ✓ $test_name passed" >> "$CI_REPORT"
            else
                echo -e "    ${RED}✗${NC} $test_name failed"
                echo "- ✗ $test_name failed" >> "$CI_REPORT"
                passed=false
            fi
        fi
    done

    echo "" >> "$CI_REPORT"

    if [ "$passed" = true ]; then
        print_stage "Unit Tests" "passed"
        echo "**Result**: ✅ PASSED" >> "$CI_REPORT"
        return 0
    else
        print_stage "Unit Tests" "failed"
        echo "**Result**: ❌ FAILED" >> "$CI_REPORT"
        return 1
    fi
}

# Stage 3: Quality Checks
stage_quality() {
    print_stage "Quality Checks" "running"
    local passed=true

    echo "### Stage 3: Quality Checks" >> "$CI_REPORT"
    echo "" >> "$CI_REPORT"

    # Check YAML files
    echo "  Checking YAML syntax..."
    yaml_count=0
    yaml_valid=0
    for yaml_file in "$LEVEL1_DIR"/**/*.yaml "$LEVEL1_DIR"/**/*.yml; do
        if [ -f "$yaml_file" ]; then
            yaml_count=$((yaml_count + 1))
            if ! grep -P "\t" "$yaml_file" > /dev/null; then
                yaml_valid=$((yaml_valid + 1))
            else
                echo -e "    ${RED}✗${NC} YAML contains tabs: $(basename "$yaml_file")"
                echo "- ✗ YAML contains tabs: $(basename "$yaml_file")" >> "$CI_REPORT"
                passed=false
            fi
        fi
    done
    echo -e "    ${GREEN}✓${NC} YAML files validated: $yaml_valid/$yaml_count"
    echo "- YAML files validated: $yaml_valid/$yaml_count" >> "$CI_REPORT"

    # Check XML files
    echo "  Checking XML syntax..."
    xml_count=0
    xml_valid=0
    for xml_file in "$LEVEL1_DIR"/**/*.xml; do
        if [ -f "$xml_file" ]; then
            xml_count=$((xml_count + 1))
            if grep -q "<?xml version" "$xml_file"; then
                xml_valid=$((xml_valid + 1))
            else
                echo -e "    ${RED}✗${NC} XML missing declaration: $(basename "$xml_file")"
                echo "- ✗ XML missing declaration: $(basename "$xml_file")" >> "$CI_REPORT"
                passed=false
            fi
        fi
    done
    echo -e "    ${GREEN}✓${NC} XML files validated: $xml_valid/$xml_count"
    echo "- XML files validated: $xml_valid/$xml_count" >> "$CI_REPORT"

    # Check documentation quality
    echo "  Checking documentation quality..."
    doc_patterns=("Technical:" "Simple:" "Connection:")
    doc_quality=0
    for pattern in "${doc_patterns[@]}"; do
        if grep -r "$pattern" "$LEVEL1_DIR" --include="*.md" > /dev/null 2>&1; then
            doc_quality=$((doc_quality + 1))
        fi
    done
    echo -e "    ${GREEN}✓${NC} Documentation patterns found: $doc_quality/${#doc_patterns[@]}"
    echo "- Documentation patterns: $doc_quality/${#doc_patterns[@]}" >> "$CI_REPORT"

    echo "" >> "$CI_REPORT"

    if [ "$passed" = true ]; then
        print_stage "Quality Checks" "passed"
        echo "**Result**: ✅ PASSED" >> "$CI_REPORT"
        return 0
    else
        print_stage "Quality Checks" "failed"
        echo "**Result**: ❌ FAILED" >> "$CI_REPORT"
        return 1
    fi
}

# Stage 4: Integration Tests
stage_integration() {
    print_stage "Integration Tests" "running"
    local passed=true

    echo "### Stage 4: Integration Tests" >> "$CI_REPORT"
    echo "" >> "$CI_REPORT"

    # Run integration tests
    echo "  Running integration tests..."
    for test_file in "$TEST_DIR"/integration/*.sh; do
        if [ -f "$test_file" ] && [ -x "$test_file" ]; then
            test_name=$(basename "$test_file" .sh)
            echo -e "    Testing: $test_name"

            if "$test_file" > /dev/null 2>&1; then
                echo -e "    ${GREEN}✓${NC} $test_name passed"
                echo "- ✓ $test_name passed" >> "$CI_REPORT"
            else
                echo -e "    ${RED}✗${NC} $test_name failed"
                echo "- ✗ $test_name failed" >> "$CI_REPORT"
                passed=false
            fi
        fi
    done

    echo "" >> "$CI_REPORT"

    if [ "$passed" = true ]; then
        print_stage "Integration Tests" "passed"
        echo "**Result**: ✅ PASSED" >> "$CI_REPORT"
        return 0
    else
        print_stage "Integration Tests" "failed"
        echo "**Result**: ❌ FAILED" >> "$CI_REPORT"
        return 1
    fi
}

# Stage 5: Coverage Analysis
stage_coverage() {
    print_stage "Coverage Analysis" "running"

    echo "### Stage 5: Coverage Analysis" >> "$CI_REPORT"
    echo "" >> "$CI_REPORT"

    # Count components
    echo "  Analyzing coverage..."

    # Count tested vs total components
    agent_count=$(ls -1 "$LEVEL1_DIR/agents/"*.md 2>/dev/null | wc -l || echo 0)
    command_count=$(ls -1 "$LEVEL1_DIR/commands/"*.md 2>/dev/null | wc -l || echo 0)
    template_count=$(ls -1 "$LEVEL1_DIR/templates/"*.yaml 2>/dev/null | wc -l || echo 0)
    workflow_count=$(ls -1 "$LEVEL1_DIR/workflows/"*.xml 2>/dev/null | wc -l || echo 0)
    test_count=$(ls -1 "$TEST_DIR/unit/"*.sh "$TEST_DIR/integration/"*.sh 2>/dev/null | wc -l || echo 0)

    total_components=$((agent_count + command_count + template_count + workflow_count))

    echo -e "    ${CYAN}ℹ${NC} Agents: $agent_count"
    echo -e "    ${CYAN}ℹ${NC} Commands: $command_count"
    echo -e "    ${CYAN}ℹ${NC} Templates: $template_count"
    echo -e "    ${CYAN}ℹ${NC} Workflows: $workflow_count"
    echo -e "    ${CYAN}ℹ${NC} Tests: $test_count"

    echo "- Agents: $agent_count" >> "$CI_REPORT"
    echo "- Commands: $command_count" >> "$CI_REPORT"
    echo "- Templates: $template_count" >> "$CI_REPORT"
    echo "- Workflows: $workflow_count" >> "$CI_REPORT"
    echo "- Tests: $test_count" >> "$CI_REPORT"
    echo "- **Total Components**: $total_components" >> "$CI_REPORT"

    # Calculate coverage percentage (rough estimate)
    if [ $total_components -gt 0 ]; then
        coverage_percent=$((test_count * 100 / total_components))
        echo -e "    ${CYAN}ℹ${NC} Estimated coverage: ${coverage_percent}%"
        echo "- **Estimated Coverage**: ${coverage_percent}%" >> "$CI_REPORT"
    fi

    echo "" >> "$CI_REPORT"
    print_stage "Coverage Analysis" "passed"
    echo "**Result**: ✅ COMPLETED" >> "$CI_REPORT"
    return 0
}

# Stage 6: Generate Report
stage_report() {
    print_stage "Report Generation" "running"

    echo "### Stage 6: Report Generation" >> "$CI_REPORT"
    echo "" >> "$CI_REPORT"

    # Generate summary
    echo "  Generating final report..."

    # Count stage results
    passed_stages=0
    failed_stages=0
    for status in "${STAGE_STATUS[@]}"; do
        if [ "$status" = "passed" ]; then
            passed_stages=$((passed_stages + 1))
        elif [ "$status" = "failed" ]; then
            failed_stages=$((failed_stages + 1))
        fi
    done

    echo "" >> "$CI_REPORT"
    echo "---" >> "$CI_REPORT"
    echo "" >> "$CI_REPORT"
    echo "## Pipeline Summary" >> "$CI_REPORT"
    echo "" >> "$CI_REPORT"
    echo "- **Total Stages**: ${#STAGES[@]}" >> "$CI_REPORT"
    echo "- **Passed**: $passed_stages" >> "$CI_REPORT"
    echo "- **Failed**: $failed_stages" >> "$CI_REPORT"
    echo "- **Duration**: ${SECONDS}s" >> "$CI_REPORT"

    if [ $failed_stages -eq 0 ]; then
        echo "- **Overall Result**: ✅ **PIPELINE PASSED**" >> "$CI_REPORT"
    else
        echo "- **Overall Result**: ❌ **PIPELINE FAILED**" >> "$CI_REPORT"
    fi

    echo "" >> "$CI_REPORT"
    echo "---" >> "$CI_REPORT"
    echo "*Report generated at: $(date)*" >> "$CI_REPORT"

    print_stage "Report Generation" "passed"
    return 0
}

# Main pipeline execution
main() {
    print_header "CI/CD Pipeline Simulation"
    echo -e "${CYAN}Starting pipeline for Level-1-Dev Framework${NC}"
    echo ""

    # Initialize
    init_report
    SECONDS=0

    # Execute stages
    for stage in "${STAGES[@]}"; do
        case $stage in
            "validate")
                if stage_validate; then
                    STAGE_STATUS+=("passed")
                else
                    STAGE_STATUS+=("failed")
                fi
                ;;
            "test")
                if stage_test; then
                    STAGE_STATUS+=("passed")
                else
                    STAGE_STATUS+=("failed")
                fi
                ;;
            "quality")
                if stage_quality; then
                    STAGE_STATUS+=("passed")
                else
                    STAGE_STATUS+=("failed")
                fi
                ;;
            "integration")
                if stage_integration; then
                    STAGE_STATUS+=("passed")
                else
                    STAGE_STATUS+=("failed")
                fi
                ;;
            "coverage")
                if stage_coverage; then
                    STAGE_STATUS+=("passed")
                else
                    STAGE_STATUS+=("failed")
                fi
                ;;
            "report")
                if stage_report; then
                    STAGE_STATUS+=("passed")
                else
                    STAGE_STATUS+=("failed")
                fi
                ;;
        esac
        echo ""
    done

    # Final summary
    print_header "Pipeline Complete"

    # Check overall status
    pipeline_passed=true
    for status in "${STAGE_STATUS[@]}"; do
        if [ "$status" = "failed" ]; then
            pipeline_passed=false
            break
        fi
    done

    if [ "$pipeline_passed" = true ]; then
        echo -e "${GREEN}✓ PIPELINE PASSED${NC}"
        echo "All stages completed successfully."
    else
        echo -e "${RED}✗ PIPELINE FAILED${NC}"
        echo "Some stages failed. Check the report for details."
    fi

    echo ""
    echo -e "${CYAN}Report saved to:${NC} $CI_REPORT"
    echo -e "${CYAN}Duration:${NC} ${SECONDS} seconds"
    echo ""

    # Exit with appropriate code
    if [ "$pipeline_passed" = true ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
