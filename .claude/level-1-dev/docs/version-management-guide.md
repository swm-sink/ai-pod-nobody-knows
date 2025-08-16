# Version Management System Guide

## Overview

The Level-1-Dev Version Management System provides comprehensive semantic versioning, compatibility tracking, and safe migration capabilities for all components in the meta-development platform.

## Architecture

```
versions/
├── schema.yaml              # Version manifest structure definition
├── compatibility-matrix.yaml # Component relationship tracking
├── manifests/               # Individual component manifests
├── migrations/              # Version migration scripts
│   ├── available/          # Pending migrations
│   ├── applied/            # Completed migrations
│   └── failed/             # Failed migration markers
└── history/                # Version history archive

bin/
├── version-manager.sh       # Core version operations
├── changelog-generator.sh   # Changelog generation
├── compatibility-checker.sh # Compatibility validation
├── migration-runner.sh      # Migration execution
└── version-validator.sh     # System-wide validation
```

## Core Concepts

### Semantic Versioning

All components follow semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes requiring migration
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes and minor improvements

### Component Types

- **agents**: AI agent definitions
- **commands**: Command implementations
- **templates**: Component templates
- **workflows**: Workflow definitions
- **quality**: Quality gate configurations
- **tests**: Test suites
- **hooks**: Event hooks
- **libraries**: Shared libraries

## Quick Start

### 1. Initialize a Component

```bash
# Initialize version tracking for a new component
./bin/version-manager.sh init my-component agent

# This creates a manifest at versions/manifests/my-component.yaml
```

### 2. Update Version

```bash
# Bump version (major|minor|patch)
./bin/version-manager.sh bump my-component minor

# Current: 0.1.0 → New: 0.2.0
```

### 3. Create Git Tag

```bash
# Tag the current version
./bin/version-manager.sh tag my-component "Added new features"

# Creates tag: my-component-v0.2.0
```

### 4. Check Compatibility

```bash
# Check if update is safe
./bin/compatibility-checker.sh check my-component 1.0.0

# Shows impact analysis and warnings
```

### 5. Generate Changelog

```bash
# Generate markdown changelog
./bin/changelog-generator.sh generate my-component

# Output saved to changelogs/my-component.md
```

## Workflows

### Standard Update Workflow

1. **Check current state**
   ```bash
   ./bin/version-manager.sh list
   ./bin/version-validator.sh
   ```

2. **Make changes** to component files

3. **Bump version**
   ```bash
   ./bin/version-manager.sh bump component-name patch
   ```

4. **Validate changes**
   ```bash
   ./bin/compatibility-checker.sh check component-name
   ./bin/version-validator.sh
   ```

5. **Generate changelog**
   ```bash
   ./bin/changelog-generator.sh generate component-name
   ```

6. **Create tag**
   ```bash
   ./bin/version-manager.sh tag component-name
   ```

### Breaking Change Workflow

1. **Create migration script**
   ```bash
   ./bin/migration-runner.sh create component-name
   # Edit the generated migration script
   ```

2. **Test migration**
   ```bash
   ./bin/migration-runner.sh validate
   ```

3. **Bump major version**
   ```bash
   ./bin/version-manager.sh bump component-name major
   ```

4. **Update compatibility matrix**
   - Edit `versions/compatibility-matrix.yaml`
   - Document breaking changes
   - Update dependency requirements

5. **Run migration**
   ```bash
   ./bin/migration-runner.sh run migration-name
   ```

6. **Verify system**
   ```bash
   ./bin/version-validator.sh --strict
   ```

## Compatibility Management

### Compatibility Groups

Components are organized into groups that should be updated together:

- **testing_suite**: Test framework components
- **builder_tools**: Agent and command builders
- **validation_tools**: Validation and checking tools

### Dependency Tracking

The compatibility matrix tracks:
- Direct dependencies between components
- Required tool dependencies
- Breaking change impacts
- Migration requirements

### Checking Compatibility

```bash
# Check specific component
./bin/compatibility-checker.sh impact my-component

# Find all conflicts
./bin/compatibility-checker.sh conflicts

# Validate entire system
./bin/compatibility-checker.sh validate
```

## Migration System

### Creating Migrations

```bash
# Generate migration from template
./bin/migration-runner.sh create component-name

# Prompts for:
# - Target version
# - Breaking change flag
# - Description
```

### Migration Structure

Migrations include:
- **Precondition validation**: Verify current state
- **Backup creation**: Save current configuration
- **Migration logic**: Transform to new version
- **Version update**: Update manifests
- **Post-validation**: Verify success
- **Rollback capability**: Undo if needed

### Running Migrations

```bash
# Run specific migration
./bin/migration-runner.sh run 20250816_120000_component

# Run all pending
./bin/migration-runner.sh run-all

# Rollback if needed
./bin/migration-runner.sh rollback 20250816_120000_component
```

## Validation

### Comprehensive Validation

```bash
# Run all validation checks
./bin/version-validator.sh

# Checks:
# - Version headers present
# - Semantic versioning compliance
# - Manifest-component sync
# - Schema compliance
# - Compatibility rules
# - Dependencies satisfied
# - Migration coverage
```

### Auto-Fix Issues

```bash
# Attempt automatic fixes
./bin/version-validator.sh --fix

# Fixes:
# - Missing version headers
# - Version sync issues
# - Simple format problems
```

### Strict Mode

```bash
# Treat warnings as errors
./bin/version-validator.sh --strict
```

## Best Practices

### Version Bumping

1. **Patch**: Bug fixes, documentation updates
2. **Minor**: New features, non-breaking improvements
3. **Major**: Breaking API changes, major refactors

### Commit Messages

Include version in commit messages:
```
feat(agent-builder): bump to v1.2.0 - add template validation
fix(test-utils): bump to v0.1.1 - fix assertion error messages
```

### Testing Before Release

1. Run version validator
2. Check compatibility matrix
3. Test migrations in development
4. Generate and review changelog
5. Create git tag only after validation

### Documentation

Always update when making version changes:
- Component documentation
- Compatibility matrix
- Migration guides
- Changelog entries

## Troubleshooting

### Common Issues

**Version mismatch between manifest and component**
```bash
./bin/version-validator.sh --fix
```

**Compatibility conflicts**
```bash
./bin/compatibility-checker.sh conflicts
# Review and resolve conflicts
```

**Failed migration**
```bash
./bin/migration-runner.sh rollback migration-name
# Fix issues and retry
```

**Orphaned manifests**
```bash
./bin/version-validator.sh
# Remove manifests for deleted components
```

### Emergency Rollback

If system is broken after updates:

1. **Check recent changes**
   ```bash
   git log --oneline -10
   ```

2. **Rollback migrations**
   ```bash
   ./bin/migration-runner.sh list
   # Find and rollback recent migrations
   ```

3. **Reset versions**
   ```bash
   git checkout HEAD~1 -- versions/manifests/
   ```

4. **Validate system**
   ```bash
   ./bin/version-validator.sh
   ```

## Command Reference

### version-manager.sh

```bash
init <component> <type>    # Initialize version tracking
bump <component> <level>   # Bump version (major|minor|patch)
tag <component> [message]  # Create git tag
check <component>         # Check compatibility
list                     # List all components
history <component>      # Show version history
validate                 # Validate all manifests
```

### compatibility-checker.sh

```bash
check <component> [version]  # Check compatibility
validate                    # Validate all components
conflicts                   # Find conflicts
impact <component>          # Show update impact
matrix                      # Display matrix summary
```

### migration-runner.sh

```bash
list                    # List migrations
status                  # Show migration status
run <migration>         # Run specific migration
run-all                 # Run all pending
rollback <migration>    # Rollback migration
create <component>      # Create new migration
validate                # Validate scripts
clean                   # Clean old backups
```

### changelog-generator.sh

```bash
generate <component>     # Generate changelog
generate-all            # Generate all changelogs
markdown <component>    # Markdown format
json <component>        # JSON format
summary                 # Recent changes summary
```

### version-validator.sh

```bash
# Options:
--verbose              # Detailed output
--quiet               # Suppress non-errors
--fix                 # Auto-fix issues
--skip-migrations     # Skip migration checks
--strict              # Warnings as errors
```

## Integration with CI/CD

### Pre-commit Hooks

Add to `.pre-commit-config.yaml`:
```yaml
- id: version-validation
  name: Validate versions
  entry: .claude/level-1-dev/bin/version-validator.sh
  language: script
  pass_filenames: false
```

### GitHub Actions

```yaml
- name: Version Validation
  run: |
    cd .claude/level-1-dev
    ./bin/version-validator.sh --strict
```

### Automated Changelog

```yaml
- name: Generate Changelog
  run: |
    cd .claude/level-1-dev
    ./bin/changelog-generator.sh generate-all
```

## Summary

The Version Management System provides:
- ✅ Semantic versioning for all components
- ✅ Compatibility tracking and validation
- ✅ Safe migration with rollback capability
- ✅ Automated changelog generation
- ✅ Comprehensive validation and auto-fix
- ✅ Git integration with tagging
- ✅ Emergency recovery procedures

This ensures reliable, traceable, and safe evolution of the Level-1-Dev platform.
