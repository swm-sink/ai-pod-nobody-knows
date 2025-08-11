# Validate Project Structure

**Purpose**: Comprehensive validation of the 4-level project architecture ensuring all directories, files, and naming conventions are correct.

You are the Project Structure Validator. Execute comprehensive validation of the entire project organization.

## Process

### Step 1: Directory Structure Validation
- Use file-validator agent: Verify all 4 levels exist
- Input: Project root directory path
- Validate: All required subdirectories present
- Output: Directory structure compliance report

### Step 2: File Placement Validation  
- Use file-validator agent: Check each file is in correct level
- Input: All files in .claude/ directory
- Validate: Level assignment matches file purpose
- Output: File placement compliance report

### Step 3: Naming Convention Validation
- Use file-validator agent: Verify naming standards
- Input: All directories and files
- Validate: lowercase-with-hyphens pattern compliance
- Output: Naming convention compliance report

### Step 4: Reference Integrity Check
- Use file-validator agent: Validate all internal links
- Input: All markdown files with references
- Validate: All paths and links are functional
- Output: Reference integrity report

## Quality Gates
✓ **Directory Structure**: All 4 levels + subdirectories exist (100%)
✓ **File Placement**: All files in correct level (100%)  
✓ **Naming Standards**: All names follow conventions (100%)
✓ **Reference Integrity**: All links functional (100%)

## Error Recovery
- If directory missing: Create with proper structure
- If file misplaced: Move to correct level with explanation
- If naming violation: Suggest correct name and rename
- If broken reference: Fix path or flag for manual attention

## Validation Commands

```bash
# Directory structure check
find .claude -type d | sort

# File placement verification  
find .claude -name "*.md" -o -name "*.json" -o -name "*.yaml" | sort

# Naming convention check
find .claude -type f -name "*[A-Z]*" -o -name "*_*" -o -name "* *" | head -5

# Reference integrity
grep -r "\.claude/" .claude/ | grep -E "\[(.*)\]\(.*\.md\)" | head -10
```

## Success Criteria
- All validation checks complete successfully
- Comprehensive report generated with specific findings
- All issues identified with actionable fixes
- Project structure 100% compliant or fix instructions provided

## Output
- Location: `.claude/level-1-dev/validation-reports/`
- Format: JSON report with detailed findings
- Include: All validation results, specific issues, fix recommendations

Execute comprehensive project structure validation and provide detailed compliance report.