# Level-1-Dev Test Framework Documentation

## Overview

**Technical:** Comprehensive bash-based testing framework for Level-1-Dev meta-development platform using only Claude Code native capabilities - no external dependencies required.

**Simple:** Think of it like a quality inspector for your tool-building workshop - it checks that every tool you create works properly before you use it to build other things.

**Connection:** This teaches you test-driven development, quality assurance practices, and how to build reliable automation systems.

## Quick Start

```bash
# Run all tests
./tests/run-all-tests.sh

# Run specific test
./tests/unit/test-agent-builder.sh

# Simulate CI/CD pipeline
./tests/ci-simulate.sh

# Check test coverage
./tests/coverage.sh
```

## Directory Structure

```
tests/
├── README.md                    # This file
├── run-all-tests.sh            # Main test orchestrator
├── test-utils.sh               # Shared testing utilities
├── ci-simulate.sh              # CI/CD pipeline simulation
├── coverage.sh                 # Test coverage analyzer
├── unit/                       # Unit tests
│   ├── test-agent-builder.sh  # Agent builder validation
│   ├── test-command-builder.sh # Command builder validation
│   ├── test-context-researcher.sh # Context researcher validation
│   └── test-templates.sh      # Template validation
├── integration/                # Integration tests
│   ├── test-workflows.sh      # Workflow integration
│   └── test-quality-gates.sh  # Quality gate integration
└── reports/                    # Test reports (auto-generated)
```

## Test Utilities

The `test-utils.sh` library provides assertion functions:

### File System Assertions
- `assert_file_exists` - Verify file exists
- `assert_dir_exists` - Verify directory exists
- `assert_executable` - Check if file is executable
- `assert_permissions` - Verify specific permissions

### Content Assertions
- `assert_contains` - File contains pattern
- `assert_not_contains` - File doesn't contain pattern
- `assert_equals` - String equality
- `assert_not_equals` - String inequality

### Format Validation
- `assert_yaml_valid` - Validate YAML syntax
- `assert_json_valid` - Validate JSON syntax

### Command Assertions
- `assert_command_succeeds` - Command returns 0
- `assert_command_fails` - Command returns non-0

## Writing New Tests

### Unit Test Template

```bash
#!/bin/bash

# Test: [Component Name]
# Purpose: [What this test validates]

# Get test utilities
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TEST_DIR/test-utils.sh"

# Set test context
set_test_context "component-name"

# Define paths
LEVEL1_DIR="$(cd "$TEST_DIR/../.." && pwd)"

# Test 1: [Description]
assert_file_exists "$LEVEL1_DIR/path/to/file" "File should exist"

# Test 2: [Description]
assert_contains "$LEVEL1_DIR/file.md" "pattern" "Should contain pattern"

# Summary
test_summary
```

### Integration Test Template

```bash
#!/bin/bash

# Integration Test: [Workflow Name]
# Tests: [What integration this validates]

# Same structure as unit tests, but tests interactions between components
```

## Pre-commit Hook

Install the pre-commit hook to run tests automatically:

```bash
# Option 1: Symlink (recommended)
ln -s ../../.claude/level-1-dev/hooks/pre-commit-test.sh .git/hooks/pre-commit

# Option 2: Copy
cp .claude/level-1-dev/hooks/pre-commit-test.sh .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit
```

## CI/CD Simulation

The `ci-simulate.sh` script runs a complete pipeline:

1. **Validation** - Check structure and files
2. **Unit Tests** - Run all unit tests
3. **Quality Checks** - Validate YAML/XML/Markdown
4. **Integration Tests** - Test component interactions
5. **Coverage Analysis** - Calculate test coverage
6. **Report Generation** - Create summary report

## Test Reports

Reports are automatically generated in `tests/reports/`:
- `test-report-YYYYMMDD-HHMMSS.md` - Test execution reports
- `ci-report-YYYYMMDD-HHMMSS.md` - CI pipeline reports
- `coverage-report-YYYYMMDD-HHMMSS.md` - Coverage analysis

## Best Practices

### Test Organization
- **Unit tests** - Test individual components in isolation
- **Integration tests** - Test component interactions
- **Keep tests atomic** - Each test should be independent
- **Use descriptive names** - Clear test naming helps debugging

### Assertions
- **Be specific** - Use precise assertions
- **Test positive and negative** - Check both success and failure cases
- **Provide context** - Include descriptive messages
- **Clean up** - Remove temporary files after tests

### Performance
- **Fast tests first** - Quick validations before slow operations
- **Parallel when possible** - Run independent tests concurrently
- **Cache results** - Avoid redundant operations
- **Timeout long operations** - Prevent hanging tests

## Troubleshooting

### Common Issues

**Tests not found**
```bash
# Make tests executable
chmod +x tests/**/*.sh
```

**Permission denied**
```bash
# Check file permissions
ls -la tests/
```

**Test failures**
```bash
# Run specific test with verbose output
bash -x tests/unit/test-name.sh
```

**Report not generated**
```bash
# Check reports directory exists
mkdir -p tests/reports
```

## Educational Value

**Technical:** Learn test-driven development, continuous integration patterns, bash scripting for automation, and quality assurance methodologies.

**Simple:** Like learning to be your own quality inspector - you check your work systematically before declaring it done.

**Connection:** These testing skills transfer to any software project - the patterns of validation, automation, and quality assurance are universal in professional development.

## Maintenance

### Adding New Tests
1. Create test file in appropriate directory
2. Use test-utils.sh for assertions
3. Make executable: `chmod +x test-file.sh`
4. Update this README if needed

### Updating Test Framework
1. Modify test-utils.sh for new assertions
2. Update run-all-tests.sh for new test categories
3. Document changes in this README

### Reviewing Test Results
1. Check reports/ directory for latest results
2. Review failed tests in detail
3. Fix issues and re-run tests
4. Commit when all tests pass

---

*Test framework version: 1.0.0*
*Last updated: 2024*
*Uses only Claude Code native capabilities*
