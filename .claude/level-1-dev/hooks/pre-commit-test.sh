#!/bin/bash

# Pre-commit Test Hook for Level-1-Dev
# Runs tests before allowing commits to ensure quality
# Can be symlinked to .git/hooks/pre-commit or called manually

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get the directory of this script
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVEL1_DIR="$(cd "$HOOK_DIR/.." && pwd)"
TEST_DIR="$LEVEL1_DIR/tests"
TEST_RUNNER="$TEST_DIR/run-all-tests.sh"

echo "=========================================="
echo "Pre-commit Quality Gate"
echo "=========================================="
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} Not in a git repository. Skipping pre-commit tests."
    exit 0
fi

# Check if there are changes in level-1-dev
CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.claude/level-1-dev/" || true)

if [ -z "$CHANGED_FILES" ]; then
    echo -e "${GREEN}✓${NC} No changes in level-1-dev. Skipping tests."
    exit 0
fi

echo -e "${YELLOW}ℹ${NC} Changes detected in level-1-dev:"
echo "$CHANGED_FILES" | sed 's/^/  - /'
echo ""

# Check if test runner exists
if [ ! -f "$TEST_RUNNER" ]; then
    echo -e "${RED}✗${NC} Test runner not found: $TEST_RUNNER"
    echo "Please ensure the test framework is properly installed."
    exit 1
fi

# Make test runner executable if needed
if [ ! -x "$TEST_RUNNER" ]; then
    chmod +x "$TEST_RUNNER"
fi

# Run specific tests based on changed files
echo "Running quality gate tests..."
echo ""

# Determine which tests to run based on changes
RUN_AGENT_TESTS=false
RUN_COMMAND_TESTS=false
RUN_TEMPLATE_TESTS=false
RUN_WORKFLOW_TESTS=false
RUN_QUALITY_TESTS=false

for file in $CHANGED_FILES; do
    case "$file" in
        *agents/*)
            RUN_AGENT_TESTS=true
            ;;
        *commands/*)
            RUN_COMMAND_TESTS=true
            ;;
        *templates/*)
            RUN_TEMPLATE_TESTS=true
            ;;
        *workflows/*)
            RUN_WORKFLOW_TESTS=true
            ;;
        *quality/*)
            RUN_QUALITY_TESTS=true
            ;;
    esac
done

# Run relevant tests
TEST_FAILED=false

if [ "$RUN_AGENT_TESTS" = true ] && [ -f "$TEST_DIR/unit/test-agent-builder.sh" ]; then
    echo -e "${YELLOW}ℹ${NC} Running agent tests..."
    if ! "$TEST_DIR/unit/test-agent-builder.sh"; then
        TEST_FAILED=true
    fi
    echo ""
fi

if [ "$RUN_COMMAND_TESTS" = true ] && [ -f "$TEST_DIR/unit/test-command-builder.sh" ]; then
    echo -e "${YELLOW}ℹ${NC} Running command tests..."
    if ! "$TEST_DIR/unit/test-command-builder.sh"; then
        TEST_FAILED=true
    fi
    echo ""
fi

if [ "$RUN_TEMPLATE_TESTS" = true ] && [ -f "$TEST_DIR/unit/test-templates.sh" ]; then
    echo -e "${YELLOW}ℹ${NC} Running template tests..."
    if ! "$TEST_DIR/unit/test-templates.sh"; then
        TEST_FAILED=true
    fi
    echo ""
fi

if [ "$RUN_WORKFLOW_TESTS" = true ] && [ -f "$TEST_DIR/integration/test-workflows.sh" ]; then
    echo -e "${YELLOW}ℹ${NC} Running workflow tests..."
    if ! "$TEST_DIR/integration/test-workflows.sh"; then
        TEST_FAILED=true
    fi
    echo ""
fi

if [ "$RUN_QUALITY_TESTS" = true ] && [ -f "$TEST_DIR/integration/test-quality-gates.sh" ]; then
    echo -e "${YELLOW}ℹ${NC} Running quality gate tests..."
    if ! "$TEST_DIR/integration/test-quality-gates.sh"; then
        TEST_FAILED=true
    fi
    echo ""
fi

# If no specific tests were triggered, run a quick validation
if [ "$RUN_AGENT_TESTS" = false ] && [ "$RUN_COMMAND_TESTS" = false ] && \
   [ "$RUN_TEMPLATE_TESTS" = false ] && [ "$RUN_WORKFLOW_TESTS" = false ] && \
   [ "$RUN_QUALITY_TESTS" = false ]; then
    echo -e "${YELLOW}ℹ${NC} Running quick validation tests..."

    # Quick validation of changed files
    for file in $CHANGED_FILES; do
        if [ -f "$file" ]; then
            case "$file" in
                *.yaml|*.yml)
                    # Basic YAML validation
                    if grep -P "\t" "$file" > /dev/null; then
                        echo -e "${RED}✗${NC} YAML file contains tabs: $file"
                        TEST_FAILED=true
                    else
                        echo -e "${GREEN}✓${NC} YAML validation passed: $(basename "$file")"
                    fi
                    ;;
                *.xml)
                    # Basic XML validation
                    if ! grep -q "<?xml version" "$file"; then
                        echo -e "${RED}✗${NC} XML file missing declaration: $file"
                        TEST_FAILED=true
                    else
                        echo -e "${GREEN}✓${NC} XML validation passed: $(basename "$file")"
                    fi
                    ;;
                *.md)
                    # Basic markdown validation
                    echo -e "${GREEN}✓${NC} Markdown file: $(basename "$file")"
                    ;;
            esac
        fi
    done
fi

echo ""
echo "=========================================="

if [ "$TEST_FAILED" = true ]; then
    echo -e "${RED}✗ QUALITY GATE FAILED${NC}"
    echo ""
    echo "Tests failed. Please fix the issues before committing."
    echo "To bypass (not recommended), use: git commit --no-verify"
    exit 1
else
    echo -e "${GREEN}✓ QUALITY GATE PASSED${NC}"
    echo ""
    echo "All tests passed. Proceeding with commit."
    exit 0
fi
