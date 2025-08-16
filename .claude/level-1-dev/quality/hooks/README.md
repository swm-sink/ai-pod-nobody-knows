# Level-1-Dev Quality Hook System

## Overview

The Level-1-Dev Quality Hook System provides automated quality enforcement through Git hooks. It ensures code quality, consistency, and adherence to project standards at multiple points in the development workflow.

## Architecture

**INTEGRATED DESIGN:** Level-1-Dev hooks work alongside the existing pre-commit framework for comprehensive quality enforcement.

```
EXISTING PRE-COMMIT FRAMEWORK:
├── .pre-commit-config.yaml    # Main pre-commit configuration
├── .git/hooks/pre-commit      # Pre-commit framework hook
└── Multiple quality checks    # Secrets, linting, validation, etc.

LEVEL-1-DEV ADDITIONS:
quality/hooks/
├── install-hooks.sh           # Git hooks installer
├── pre-commit-quality.sh      # Level-1-Dev checks (integrated into framework)
├── post-commit-validation.sh  # Comprehensive post-commit validation
├── pre-push-quality.sh        # Thorough pre-push validation
├── prepare-commit-msg.sh      # Commit message formatting
├── hook-manager.sh            # Centralized hook management
└── README.md                  # This documentation

INTEGRATION RESULT:
✅ Pre-commit: Existing framework + Level-1-Dev checks
✅ Post-commit: Level-1-Dev validation system
✅ Pre-push: Level-1-Dev quality gates
✅ Prepare-commit-msg: Level-1-Dev message enhancement
```

## Hook Types

### 1. Pre-commit Hook
**File:** `pre-commit-quality.sh`
**Timing:** Before each commit
**Duration:** <10 seconds
**Purpose:** Fast quality checks to catch obvious issues

**Checks:**
- Script syntax validation
- Security pattern detection
- Version header verification
- File size limits
- Trailing whitespace
- Quick tests (if available)

**Bypass:** `git commit --no-verify`

### 2. Post-commit Hook
**File:** `post-commit-validation.sh`
**Timing:** After each commit
**Duration:** 1-2 minutes
**Purpose:** Comprehensive validation and reporting

**Checks:**
- Full test suite execution
- Code coverage analysis
- Security scanning
- Documentation validation
- Version consistency
- Performance metrics
- Complexity analysis
- Dependency verification

**Output:** Quality reports in `quality/reports/`

### 3. Pre-push Hook
**File:** `pre-push-quality.sh`
**Timing:** Before pushing to remote
**Duration:** 1-2 minutes
**Purpose:** Thorough validation before sharing code

**Checks:**
- Comprehensive test suite
- Version consistency
- Security validation
- Quality metrics validation
- Compatibility checking
- Documentation validation
- Performance validation
- Commit message validation

**Bypass:** `touch .skip-pre-push-checks && git push`

### 4. Prepare Commit Message Hook
**File:** `prepare-commit-msg.sh`
**Timing:** When preparing commit message
**Duration:** <1 second
**Purpose:** Format and enhance commit messages

**Features:**
- Suggests commit type based on changed files
- Provides commit message template
- Validates message format
- Adds task tracking information
- Includes quality status

## Installation

**🎯 INTEGRATION APPROACH:** Level-1-Dev quality hooks integrate with existing
pre-commit framework rather than replacing it. Provides comprehensive quality
enforcement while preserving existing validations.

### Integrated Setup (Recommended)
```bash
# Level-1-Dev pre-commit checks are integrated into .pre-commit-config.yaml
# Just install the additional hooks (post-commit, pre-push, prepare-commit-msg)
./quality/hooks/install-hooks.sh install --backup

# The pre-commit hook remains with the existing framework
# Our checks run as part of the pre-commit framework automatically
```

### Manual Setup
```bash
# Install all hooks with default settings (will warn about pre-commit conflict)
./quality/hooks/install-hooks.sh install

# Or use the hook manager
./quality/hooks/hook-manager.sh install
```

### Advanced Installation
```bash
# Install with backup of existing hooks
./quality/hooks/install-hooks.sh install --backup

# Install specific hook only
./quality/hooks/hook-manager.sh install pre-commit

# Force installation (overwrite existing)
./quality/hooks/install-hooks.sh install --force
```

## Management

### Hook Manager
The `hook-manager.sh` script provides comprehensive hook management:

```bash
# Show status of all hooks
./quality/hooks/hook-manager.sh status

# List available hooks
./quality/hooks/hook-manager.sh list

# Test all hooks
./quality/hooks/hook-manager.sh test

# Diagnose and fix issues
./quality/hooks/hook-manager.sh doctor

# Enable/disable specific hooks
./quality/hooks/hook-manager.sh enable pre-push
./quality/hooks/hook-manager.sh disable post-commit
```

### Configuration
Edit `quality/hook-config.yaml` to customize behavior:

```yaml
# General Settings
max_execution_time: 120
bypass_enabled: true
strict_mode: false
auto_fix: false

# Hook-specific Settings
hooks:
  pre-commit:
    enabled: true
    timeout: 30
    required: true

  pre-push:
    enabled: true
    timeout: 120
    required: false

# Quality Thresholds
thresholds:
  test_pass_rate: 90
  coverage_minimum: 70
  security_issues: 0
```

## Usage Workflows

### Standard Development Workflow
```bash
# 1. Make changes
vim some-file.sh

# 2. Stage changes
git add some-file.sh

# 3. Commit (pre-commit hook runs)
git commit -m "feat(tools): add new utility script"

# 4. Post-commit validation runs automatically
# Check reports in quality/reports/

# 5. Push (pre-push hook runs)
git push origin feature-branch
```

### Emergency Bypass Procedures
```bash
# Skip pre-commit checks
git commit --no-verify -m "emergency fix"

# Skip pre-push checks
touch .skip-pre-push-checks
git push origin main

# Emergency push (bypass all quality checks)
EMERGENCY_PUSH=true git push origin hotfix
```

### Quality Check Without Committing
```bash
# Run pre-commit checks manually
./quality/hooks/pre-commit-quality.sh

# Run comprehensive validation
./quality/hooks/post-commit-validation.sh

# Generate quality report
./quality/generate-quality-report.sh
```

## Troubleshooting

### Common Issues

#### 1. Hook Installation Fails
```bash
# Check git repository
git status

# Check permissions
ls -la .git/hooks/

# Reinstall with force
./quality/hooks/hook-manager.sh install --force
```

#### 2. Pre-commit Takes Too Long
```bash
# Check which checks are slow
./quality/hooks/pre-commit-quality.sh --verbose

# Temporarily disable time-consuming checks
# Edit pre-commit-quality.sh and add time limits
```

#### 3. False Positives in Security Scan
```bash
# Check specific patterns
grep -n "password=" your-file.sh

# Add exception in security scanner
# Edit security scanning patterns
```

#### 4. Version Validation Fails
```bash
# Check version consistency
./bin/version-validator.sh

# Fix version issues
./bin/version-validator.sh --fix
```

### Diagnostic Commands
```bash
# Comprehensive system check
./quality/hooks/hook-manager.sh doctor

# Test individual hooks
./quality/hooks/hook-manager.sh test pre-commit

# Check hook status
./quality/hooks/hook-manager.sh status

# Validate configuration
./quality/hooks/hook-manager.sh validate
```

### Performance Optimization

#### Reduce Hook Execution Time
1. **Parallel Execution** - Enable in configuration
2. **Selective Testing** - Run only affected tests
3. **Caching** - Cache validation results
4. **Incremental Checks** - Check only changed files

#### Configuration for Speed
```yaml
# Enable performance optimizations
advanced:
  parallel_execution: true
  cache_results: true
  incremental_checks: true

# Reduce timeouts for faster feedback
hooks:
  pre-commit:
    timeout: 15  # Reduced from 30
```

## Integration with CI/CD

### GitHub Actions
```yaml
name: Quality Checks
on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Hooks
        run: ./quality/hooks/install-hooks.sh install
      - name: Run Quality Checks
        run: ./quality/hooks/post-commit-validation.sh
```

### Pre-commit Framework Integration
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: level-1-dev-quality
        name: Level-1-Dev Quality Checks
        entry: ./quality/hooks/pre-commit-quality.sh
        language: script
        pass_filenames: false
```

## Customization

### Adding Custom Checks
1. Edit the appropriate hook script
2. Add your validation logic
3. Follow existing patterns for logging
4. Test thoroughly
5. Update documentation

### Creating New Hooks
1. Create script in `quality/hooks/`
2. Add to `HOOK_INFO` in `hook-manager.sh`
3. Update `install-hooks.sh` configuration
4. Add tests and documentation

### Hook Script Template
```bash
#!/bin/bash
# Custom Hook for Level-1-Dev
set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Your validation logic here
validate_custom_requirement() {
    # Implementation
    if [ "condition" ]; then
        echo -e "${GREEN}✓ Custom check passed${NC}"
        return 0
    else
        echo -e "${RED}✗ Custom check failed${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo "Running custom validation..."
    validate_custom_requirement
}

main "$@"
```

## Security Considerations

### What the Hooks Check
- No hardcoded secrets (passwords, API keys, tokens)
- No dangerous command patterns (`eval $`, `rm -rf /`)
- No unsafe remote execution (`curl | bash`)
- File permissions are appropriate
- No world-writable files

### Security Best Practices
1. **Regular Updates** - Keep hooks updated
2. **Review Changes** - Review hook modifications carefully
3. **Limit Bypass** - Use emergency bypass sparingly
4. **Monitor Logs** - Check validation logs regularly
5. **Audit Access** - Control who can modify hooks

## Maintenance

### Regular Tasks
```bash
# Weekly: Check hook health
./quality/hooks/hook-manager.sh doctor

# Monthly: Update hooks
./quality/hooks/hook-manager.sh update

# Quarterly: Review configuration
vim quality/hook-config.yaml
```

### Backup and Recovery
```bash
# Create backup
./quality/hooks/hook-manager.sh backup

# Restore from backup
./quality/hooks/hook-manager.sh restore backup-name

# Reset to defaults
./quality/hooks/hook-manager.sh reset
```

## Advanced Features

### Parallel Hook Execution
Enable in configuration for faster execution:
```yaml
advanced:
  parallel_execution: true
```

### Result Caching
Cache validation results to avoid repeated work:
```yaml
advanced:
  cache_results: true
  cache_duration: 3600  # 1 hour
```

### Custom Notifications
Configure notifications for failures:
```yaml
notifications:
  enabled: true
  email: "team@example.com"
  slack_webhook: "https://hooks.slack.com/..."
```

## FAQ

**Q: Can I skip hooks for urgent fixes?**
A: Yes, use `git commit --no-verify` or emergency bypass procedures, but use sparingly.

**Q: Why are my commits taking so long?**
A: Check pre-commit hook timing. Consider reducing checks or optimizing scripts.

**Q: How do I add project-specific validations?**
A: Edit the hook scripts or create custom hooks following the template pattern.

**Q: Can I run hooks manually?**
A: Yes, all hook scripts can be executed directly for testing and validation.

**Q: How do I disable a specific check?**
A: Edit the hook configuration file or temporarily disable the hook.

## Support

For issues with the hook system:

1. Run diagnostics: `./quality/hooks/hook-manager.sh doctor`
2. Check logs in `quality/reports/`
3. Review configuration in `quality/hook-config.yaml`
4. Consult troubleshooting section above

---

*Part of the Level-1-Dev Quality System - Ensuring code quality at every step.*
