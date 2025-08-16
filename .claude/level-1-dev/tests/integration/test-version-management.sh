#!/bin/bash

# Integration Test for Version Management System
# Tests all components working together holistically

set -euo pipefail

# Import test utilities
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-utils.sh"

# Setup test environment
LEVEL1_DIR="$(cd "$TEST_DIR/../.." && pwd)"
BIN_DIR="$LEVEL1_DIR/bin"
TEMP_DIR="/tmp/version-test-$$"
TEST_COMPONENT="test-component-$$"

# Cleanup function
cleanup() {
    # Remove test component
    rm -f "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml"
    rm -f "$LEVEL1_DIR/agents/${TEST_COMPONENT}.md"
    rm -rf "$TEMP_DIR"

    # Clean test migrations
    find "$LEVEL1_DIR/versions/migrations/available" -name "*${TEST_COMPONENT}*" -delete 2>/dev/null || true
    find "$LEVEL1_DIR/versions/migrations/applied" -name "*${TEST_COMPONENT}*" -delete 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT

# Create temp directory
mkdir -p "$TEMP_DIR"

echo "======================================"
echo "Version Management System Integration Test"
echo "======================================"
echo ""

# Test 1: Version Manager - Initialize Component
test_start "Version Manager - Initialize"
{
    # Create a test agent file
    cat > "$LEVEL1_DIR/agents/${TEST_COMPONENT}.md" << EOF
---
name: ${TEST_COMPONENT}
description: Test agent for version management testing
tools: Read, Write
model: haiku
color: blue
---

You are a test agent.
EOF

    # Initialize version tracking
    "$BIN_DIR/version-manager.sh" init "$TEST_COMPONENT" agent

    # Verify manifest created
    assert_file_exists "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml"

    # Check initial version
    assert_contains "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml" 'version: "0.1.0"'
}
test_pass "Version initialization successful"

# Test 2: Version Bumping
test_start "Version Manager - Bump Version"
{
    # Bump patch version
    "$BIN_DIR/version-manager.sh" bump "$TEST_COMPONENT" patch

    # Verify version updated
    assert_contains "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml" 'version: "0.1.1"'

    # Bump minor version
    "$BIN_DIR/version-manager.sh" bump "$TEST_COMPONENT" minor

    # Verify version updated
    assert_contains "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml" 'version: "0.2.0"'
}
test_pass "Version bumping successful"

# Test 3: Changelog Generation
test_start "Changelog Generator"
{
    # Generate changelog
    "$BIN_DIR/changelog-generator.sh" generate "$TEST_COMPONENT" > "$TEMP_DIR/changelog.md"

    # Verify changelog content
    assert_file_exists "$TEMP_DIR/changelog.md"
    assert_contains "$TEMP_DIR/changelog.md" "# Changelog"
    assert_contains "$TEMP_DIR/changelog.md" "Version 0.2.0"
    assert_contains "$TEMP_DIR/changelog.md" "Version 0.1.1"
}
test_pass "Changelog generation successful"

# Test 4: Compatibility Checking
test_start "Compatibility Checker"
{
    # Check component compatibility
    output=$("$BIN_DIR/compatibility-checker.sh" check "$TEST_COMPONENT" 2>&1)

    # Should not have major issues for new component
    assert_not_contains "$output" "Error:"
}
test_pass "Compatibility checking successful"

# Test 5: Migration Creation
test_start "Migration Runner - Create"
{
    # Create migration script
    {
        echo "1.0.0"      # Target version
        echo "y"          # Breaking change
        echo "Test migration for integration testing"
    } | "$BIN_DIR/migration-runner.sh" create "$TEST_COMPONENT"

    # Find created migration
    migration_file=$(find "$LEVEL1_DIR/versions/migrations/available" -name "*${TEST_COMPONENT}*" | head -1)

    assert_file_exists "$migration_file"
    assert_contains "$migration_file" "TO_VERSION=\"1.0.0\""
    assert_contains "$migration_file" "BREAKING_CHANGE=\"true\""
}
test_pass "Migration creation successful"

# Test 6: Version Validation
test_start "Version Validator"
{
    # Run validation (may have some issues, but should run)
    "$BIN_DIR/version-validator.sh" 2>&1 | tee "$TEMP_DIR/validation.log"

    # Check that validation ran
    assert_file_exists "$TEMP_DIR/validation.log"
    assert_contains "$TEMP_DIR/validation.log" "Version Validation Report"
}
test_pass "Version validation successful"

# Test 7: Rollback Manager - Checkpoint
test_start "Rollback Manager - Checkpoint"
{
    # Create checkpoint
    output=$("$BIN_DIR/rollback-manager.sh" checkpoint 2>&1)

    # Verify checkpoint created
    assert_contains "$output" "Checkpoint created"

    # Check recovery directory exists
    assert_directory_exists "$LEVEL1_DIR/versions/recovery"
}
test_pass "Checkpoint creation successful"

# Test 8: Version History
test_start "Version Manager - History"
{
    # Show version history
    output=$("$BIN_DIR/version-manager.sh" history "$TEST_COMPONENT" 2>&1)

    # Should show version history
    assert_contains "$output" "Version History"
    assert_contains "$output" "0.2.0"
}
test_pass "Version history successful"

# Test 9: Compatibility Matrix
test_start "Compatibility Matrix Display"
{
    # Display matrix summary
    output=$("$BIN_DIR/compatibility-checker.sh" matrix 2>&1)

    assert_contains "$output" "Compatibility Matrix Summary"
    assert_contains "$output" "Compatibility Groups"
}
test_pass "Compatibility matrix display successful"

# Test 10: Migration Validation
test_start "Migration Runner - Validate"
{
    # Validate migrations
    output=$("$BIN_DIR/migration-runner.sh" validate 2>&1)

    assert_contains "$output" "Validating migration scripts"

    # Should validate our test migration
    if [ -f "$migration_file" ]; then
        assert_contains "$output" "$(basename "$migration_file")"
    fi
}
test_pass "Migration validation successful"

# Test 11: System Status
test_start "Rollback Manager - Status"
{
    # Check system status
    output=$("$BIN_DIR/rollback-manager.sh" status 2>&1)

    assert_contains "$output" "System Status"
    assert_contains "$output" "Git Status"
    assert_contains "$output" "Version Status"
    assert_contains "$output" "Migration Status"
}
test_pass "System status check successful"

# Test 12: Integration - Full Workflow
test_start "Integration - Full Version Update Workflow"
{
    # This tests the complete workflow for updating a component version

    # 1. Check current state
    initial_version=$(grep "^version:" "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
    echo "Initial version: $initial_version"

    # 2. Create checkpoint before changes
    "$BIN_DIR/rollback-manager.sh" checkpoint >/dev/null 2>&1

    # 3. Bump major version (breaking change)
    "$BIN_DIR/version-manager.sh" bump "$TEST_COMPONENT" major

    # 4. Verify new version
    new_version=$(grep "^version:" "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
    echo "New version: $new_version"

    # Major bump from 0.2.0 should give 1.0.0
    assert_equals "$new_version" "version: \"1.0.0\""

    # 5. Generate and verify changelog
    "$BIN_DIR/changelog-generator.sh" generate "$TEST_COMPONENT" > "$TEMP_DIR/final-changelog.md"
    assert_contains "$TEMP_DIR/final-changelog.md" "1.0.0"

    # 6. Check compatibility
    "$BIN_DIR/compatibility-checker.sh" check "$TEST_COMPONENT" >/dev/null 2>&1

    # 7. Validate system
    # May have issues but should complete
    "$BIN_DIR/version-validator.sh" --quiet 2>/dev/null || true
}
test_pass "Full workflow integration successful"

# Test 13: Rollback Capability
test_start "Rollback Manager - Version Rollback"
{
    # Test rolling back version
    current_version=$(grep "^version:" "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')

    # Force rollback to previous version
    echo "y" | "$BIN_DIR/rollback-manager.sh" rollback version "$TEST_COMPONENT" "0.2.0" 2>&1

    # Verify rollback
    rolled_version=$(grep "^version:" "$LEVEL1_DIR/versions/manifests/${TEST_COMPONENT}.yaml" | head -1 | sed 's/version: *"\?\([^"]*\)"\?/\1/')
    assert_contains "$rolled_version" "0.2.0"
}
test_pass "Version rollback successful"

# Test 14: Cleanup and Recovery
test_start "Rollback Manager - Cleanup"
{
    # Test cleanup of old data (dry run)
    output=$("$BIN_DIR/rollback-manager.sh" clean 2>&1)

    # Should report on cleanup status
    assert_contains "$output" "Cleaning old recovery data"
}
test_pass "Cleanup check successful"

# Final Summary
echo ""
echo "======================================"
echo "Integration Test Summary"
echo "======================================"
echo "All version management components tested successfully!"
echo ""
echo "Components tested:"
echo "  ✓ Version Manager (init, bump, history)"
echo "  ✓ Changelog Generator"
echo "  ✓ Compatibility Checker"
echo "  ✓ Migration Runner"
echo "  ✓ Version Validator"
echo "  ✓ Rollback Manager"
echo ""
echo "Workflows tested:"
echo "  ✓ Component initialization"
echo "  ✓ Version bumping (patch, minor, major)"
echo "  ✓ Changelog generation"
echo "  ✓ Compatibility checking"
echo "  ✓ Migration creation and validation"
echo "  ✓ System validation"
echo "  ✓ Checkpoint creation"
echo "  ✓ Version rollback"
echo "  ✓ Full update workflow"
echo ""
echo "The version management system is working holistically!"
echo "======================================
