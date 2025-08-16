# Code Review Checklist

## Overview

This checklist ensures consistent, thorough code reviews aligned with Level-1-Dev quality standards.

**Review Priority**: 🔴 Critical | 🟡 Important | 🟢 Nice-to-have

---

## Pre-Review Verification

- [ ] **PR Description** - Clear problem statement and solution approach
- [ ] **Linked Issues** - References related issues/tickets
- [ ] **Tests Pass** - All automated tests are green
- [ ] **No Conflicts** - Branch is up-to-date with target

---

## 1. Functional Correctness 🔴

### Logic & Implementation
- [ ] **Solves the Problem** - Code addresses the stated requirements
- [ ] **Edge Cases** - Handles boundary conditions and error states
- [ ] **No Regressions** - Doesn't break existing functionality
- [ ] **Algorithm Efficiency** - Uses appropriate algorithms/data structures

### Error Handling
- [ ] **Error Propagation** - Errors are properly caught and handled
- [ ] **Meaningful Messages** - Error messages help debugging
- [ ] **Graceful Degradation** - System remains stable on failures
- [ ] **Exit Codes** - Scripts return appropriate exit codes (0=success, 1=error, 2=fatal)

---

## 2. Code Quality 🔴

### Shell Script Standards
- [ ] **Error Handling** - Uses `set -euo pipefail`
- [ ] **Variable Quoting** - All variables are properly quoted: `"$var"`
- [ ] **No Hardcoded Paths** - Uses variables for paths
- [ ] **Function Comments** - Each function has descriptive comment
- [ ] **Consistent Style** - Follows project conventions

### Best Practices
- [ ] **DRY Principle** - No unnecessary duplication
- [ ] **Single Responsibility** - Functions/scripts do one thing well
- [ ] **Readable Names** - Variables and functions clearly named
- [ ] **Magic Numbers** - Constants are named and documented
- [ ] **Code Comments** - Complex logic is explained

---

## 3. Testing 🔴

### Test Coverage
- [ ] **New Tests** - New functionality has tests
- [ ] **Test Quality** - Tests are meaningful, not just coverage
- [ ] **Edge Cases** - Tests cover boundary conditions
- [ ] **Negative Tests** - Tests verify error handling
- [ ] **Test Independence** - Tests don't depend on each other

### Test Execution
- [ ] **Fast Tests** - Tests complete in reasonable time
- [ ] **Deterministic** - Tests produce consistent results
- [ ] **Clean State** - Tests clean up after themselves

---

## 4. Security 🔴

### Security Patterns
- [ ] **No eval $** - No dynamic code execution
- [ ] **No Injection** - Input is sanitized/validated
- [ ] **No Secrets** - No hardcoded passwords/tokens/keys
- [ ] **Safe Commands** - No dangerous operations (rm -rf /)
- [ ] **Path Traversal** - File paths are sanitized

### Permissions
- [ ] **File Permissions** - Appropriate chmod settings
- [ ] **Least Privilege** - Scripts run with minimal permissions
- [ ] **No Sudo** - Avoids unnecessary privilege escalation

---

## 5. Documentation 🟡

### Code Documentation
- [ ] **Version Header** - Component has version information
- [ ] **Usage Examples** - Clear examples provided
- [ ] **Parameter Docs** - Function parameters documented
- [ ] **Return Values** - Return values/exit codes documented

### User Documentation
- [ ] **README Updated** - Changes reflected in README
- [ ] **Changelog Entry** - Notable changes documented
- [ ] **API Changes** - Breaking changes clearly noted
- [ ] **Migration Guide** - Instructions for breaking changes

---

## 6. Performance 🟡

### Efficiency
- [ ] **Resource Usage** - Reasonable CPU/memory consumption
- [ ] **No Busy Loops** - Avoids unnecessary polling
- [ ] **Caching** - Expensive operations are cached
- [ ] **Batch Operations** - Groups operations when possible

### Optimization
- [ ] **Built-in Commands** - Prefers built-ins over external tools
- [ ] **Minimal I/O** - Reduces file system operations
- [ ] **Pipeline Efficiency** - Efficient command pipelines

---

## 7. Maintainability 🟡

### Code Structure
- [ ] **Modular Design** - Code is well-organized
- [ ] **Clear Dependencies** - Dependencies are explicit
- [ ] **Consistent Patterns** - Follows existing patterns
- [ ] **Future-Proof** - Consider future requirements

### Technical Debt
- [ ] **No Quick Hacks** - Proper solutions, not workarounds
- [ ] **TODO Comments** - Temporary code is marked
- [ ] **Deprecation** - Old code properly deprecated
- [ ] **Refactoring** - Improves existing code when touched

---

## 8. Version Management 🟢

### Versioning
- [ ] **Version Bump** - Version updated appropriately
- [ ] **Semantic Version** - Follows MAJOR.MINOR.PATCH
- [ ] **Compatibility** - Breaking changes noted
- [ ] **Migration Script** - Provided for breaking changes

---

## 9. Integration 🟢

### Compatibility
- [ ] **Backward Compatible** - Or breaking changes documented
- [ ] **Dependencies Met** - All dependencies available
- [ ] **Platform Support** - Works on target platforms
- [ ] **Tool Versions** - Compatible with required tools

---

## Review Comments Guide

### Effective Comments

✅ **Good Comment**:
```
"This function could cause a race condition if called concurrently.
Consider adding a lock mechanism or documenting single-threaded usage."
```

❌ **Poor Comment**:
```
"This doesn't look right."
```

### Comment Types

- **🐛 Bug** - Will cause incorrect behavior
- **🔒 Security** - Security vulnerability
- **⚡ Performance** - Performance issue
- **📝 Documentation** - Missing/incorrect docs
- **💡 Suggestion** - Improvement opportunity
- **❓ Question** - Needs clarification
- **✨ Praise** - Good practice to highlight

---

## Review Decision Matrix

| Issues Found | Action |
|-------------|--------|
| Critical bugs/security | **Request Changes** - Must fix |
| Major quality issues | **Request Changes** - Should fix |
| Minor issues only | **Approve with Comments** - Fix in follow-up |
| Style/preference only | **Approve** - Optional improvements |
| No issues | **Approve** - Ready to merge |

---

## Quick Review Commands

```bash
# Check syntax of all shell scripts
find . -name "*.sh" -exec bash -n {} \;

# Run security scan
./quality/hooks/pre-commit-quality.sh

# Check test coverage
./quality/hooks/post-commit-validation.sh

# Generate quality dashboard
./quality/quality-dashboard.sh

# Validate versions
./bin/version-validator.sh

# Check compatibility
./bin/compatibility-checker.sh validate
```

---

## Review Checklist Summary

**Minimum for Approval:**
- [ ] Functional correctness verified
- [ ] No security vulnerabilities
- [ ] Tests pass and provide coverage
- [ ] No breaking changes (or properly handled)
- [ ] Code follows project standards

**Signs of Excellent Code:**
- [ ] Comprehensive test coverage
- [ ] Clear, helpful documentation
- [ ] Thoughtful error handling
- [ ] Performance considered
- [ ] Future maintainability addressed

---

## Time Guidelines

- **Small PR** (<100 lines): 15-30 minutes
- **Medium PR** (100-500 lines): 30-60 minutes
- **Large PR** (500+ lines): 60+ minutes, consider splitting

---

## Remember

> "Code review is about improving code quality and sharing knowledge, not finding fault."

- Be constructive and respectful
- Explain the "why" behind suggestions
- Acknowledge good practices
- Learn from the code you review
- Ask questions when unsure

---

*Last Updated: 2025-01-16*
*Version: 1.0.0*
