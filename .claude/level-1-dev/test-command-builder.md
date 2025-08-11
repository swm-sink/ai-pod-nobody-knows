# Testing Command-Builder-Dev Command

**Purpose**: Validate that our command-builder-dev command works correctly by creating a sample development command.

Using command-builder-dev to create: validate-project-structure

## Command Requirements Analysis

**Command name**: validate-project-structure  
**Workflow it automates**: Comprehensive validation of the 4-level project structure
**Agents it coordinates**: file-validator (created above)
**Quality gates needed**: All directories exist, all files are properly placed, naming conventions followed
**Cost limits**: Free (uses only local file operations)

## Command Design

This command will:
1. Check all 4 levels exist with proper directory structure
2. Validate file placement according to level architecture
3. Check naming conventions compliance
4. Generate comprehensive validation report
5. Provide specific fixing instructions for any issues

Quality gates:
- Directory structure: 100% compliance
- File placement: 100% correct level assignment  
- Naming conventions: 100% consistency
- Reference integrity: All links valid

Now creating the actual command file...