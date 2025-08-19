---
name: run-validation
description: Interactive 50-step validation guide for pre-push verification
---

# Pre-Push Validation Runner

Execute the complete 50-step validation checklist interactively with progress tracking and report generation.

## Usage

```
/run-validation [--automated-only] [--report-file path]
```

## Options

- `--automated-only`: Run only automated checks, skip manual verification
- `--report-file path`: Specify custom report output location

## Execution

This command guides you through the complete validation process:

### Phase 1: Automated Checks
**Technical:** Execute programmatic validation script covering environment, structure, security, and git status verification.
**Simple:** Like running a diagnostic tool that checks all the technical stuff automatically.
**Connection:** This teaches automated testing and continuous integration practices.

1. Run automated validation script: `./scripts/validate_pre_push.sh`
2. Review automated check results
3. Fix any failures before proceeding

### Phase 2: Manual Verification Guide
**Technical:** Interactive verification of complex system behaviors requiring human judgment and testing.
**Simple:** Like having a co-pilot check the things that need human eyes and decision-making.
**Connection:** This teaches quality assurance processes and manual testing methodologies.

For each manual check category:
- **Agent Integration**: Test agent discovery and execution
- **Command Functionality**: Verify command workflows
- **Quality Standards**: Validate brand voice and content quality
- **Performance Validation**: Test cost controls and efficiency
- **Documentation Accuracy**: Verify docs match implementation

### Phase 3: Report Generation
**Technical:** Generate comprehensive validation report with timestamp, results, and sign-off section for audit trail.
**Simple:** Like creating a flight log that proves everything was checked and works correctly.
**Connection:** This teaches documentation practices and audit trail maintenance.

## Interactive Validation Process

When you run this command, I will:

1. **Initialize Validation Session**
   - Create timestamped validation session
   - Set up progress tracking
   - Prepare report template

2. **Execute Automated Checks**
   - Run all programmatic validations
   - Display real-time results
   - Stop on critical failures

3. **Guide Manual Verification**
   - Present each manual check with clear instructions
   - Wait for your confirmation before proceeding
   - Document any issues or exceptions

4. **Perform Integration Tests**
   - Guide through agent invocation tests
   - Verify end-to-end workflow functionality
   - Test critical system components

5. **Validate Quality Standards**
   - Check brand voice consistency
   - Verify dual explanations present
   - Test quality gates operational

6. **Generate Final Report**
   - Compile complete validation results
   - Create sign-off document
   - Save audit trail

## Validation Workflow

### Step-by-Step Execution

I will systematically work through each validation category:

#### A. Environment Setup (Steps 1-5)
- Verify Python/Node environments
- Check API key configuration
- Validate dependencies
- Test MCP server setup

#### B. File Structure (Steps 6-10)
- Check naming conventions
- Verify directory structure
- Find duplicate files
- Check for temporary files

#### C. Agent Configuration (Steps 11-15)
- Validate agent frontmatter
- Test Claude Code discovery
- Check agent dependencies
- Verify tool specifications

#### D. Command Integrity (Steps 16-20)
- Test command references
- Verify execution paths
- Check documentation accuracy
- Test error handling

#### E. Integration Testing (Steps 21-25)
- Test research stream
- Test production stream
- Run end-to-end episode test
- Verify checkpoint functionality

#### F. Quality & Brand (Steps 26-30)
- Run brand voice tests
- Check dual explanations
- Test quality gates
- Verify intellectual humility

#### G. Security & Credentials (Steps 31-35)
- Check for exposed credentials
- Verify .env configuration
- Test file permissions
- Scan for sensitive data

#### H. Performance & Costs (Steps 36-40)
- Test cost tracking
- Verify budget limits
- Check token monitoring
- Test checkpoint optimization

#### I. Documentation (Steps 41-45)
- Verify CLAUDE.md accuracy
- Check README current
- Test navigation links
- Validate agent descriptions

#### J. Git & Deployment (Steps 46-50)
- Check working directory clean
- Run pre-commit hooks
- Verify no merge conflicts
- Test complete test suite

## Report Generation

**Technical:** Generate comprehensive validation report documenting all checks performed, results achieved, issues found, and remediation actions taken.
**Simple:** Like creating a detailed inspection report that proves everything was thoroughly checked.
**Connection:** This teaches professional documentation and audit trail practices.

### Report Contents
- Validation session metadata
- Complete checklist with pass/fail status
- Issues found and resolution steps
- Manual verification confirmations
- Sign-off section with validator identity

### Report Location
Default: `.claude/validation/reports/validation_YYYYMMDD_HHMMSS.md`
Custom: Specified via `--report-file` option

## Failure Protocol

**Critical:** If ANY validation step fails:
1. STOP immediately - no proceeding to next steps
2. Document failure in detail
3. Fix the underlying issue completely
4. RESTART entire 50-step validation from beginning
5. NO partial validations or shortcuts allowed

## Benefits

**Technical:** Systematic pre-deployment verification prevents defect propagation, ensures system reliability, and maintains production quality standards.
**Simple:** Like having a thorough pre-flight checklist that catches problems before they cause bigger issues.
**Connection:** This teaches professional quality assurance and risk management practices essential for production systems.

### Quality Assurance
- Prevents regression introduction
- Ensures complete functionality
- Maintains brand consistency
- Protects security standards

### Risk Management
- Catches issues before deployment
- Prevents costly production failures
- Maintains system reliability
- Protects against data loss

### Professional Practice
- Creates audit trail
- Documents validation process
- Enables reproducible verification
- Supports continuous improvement

## Examples

```bash
# Complete interactive validation
/run-validation

# Automated checks only
/run-validation --automated-only

# Custom report location
/run-validation --report-file ./validation_reports/pre_release_check.md
```

This validation runner ensures systematic verification of all critical system components before any production deployment, maintaining the high quality standards essential for the AI Podcasts system.
