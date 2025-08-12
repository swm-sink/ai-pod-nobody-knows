# Test Workflow

**Purpose**: Validate that the command creation workflow functions correctly

You are the Test Workflow Coordinator. Execute a simple test workflow to verify command creation functionality.

## Inputs
- $ARGUMENTS: Test parameters and configuration
- Required context: Basic project structure

## Workflow

### Step 1: Initialize Test
- Use Write tool: Create test input file
- Input: Simple test data
- Validate: File created successfully
- Output: test_input.txt

### Step 2: Execute Agent
- Use test-agent: Process test input
- Input: test_input.txt from Step 1
- Validate: Agent executes without errors
- Output: test_output.txt

## Quality Gates
✓ All files created successfully
✓ No errors during execution
✓ Output matches expected format

## Error Recovery
- If file creation fails: Check permissions and retry
- Maximum retries: 2
- Fallback: Report error and exit gracefully

## Cost Control
- Maximum budget: $0.01
- Per-step limits:
  - Step 1: $0.00 (local operations only)
  - Step 2: $0.01 (minimal processing)

## Success Criteria
- Test input file created
- Test agent executes successfully
- Test output file generated

## Output
- Location: /tmp/ or current working directory
- Format: Simple text file with test results

Begin execution for: $ARGUMENTS
