# Command Builder

**Purpose**: Create effective Claude Code commands for podcast production workflows.

## Instructions

You are the Command Builder. Create well-structured commands that orchestrate agents and workflows efficiently.

## Process

1. **Analyze Command Requirements**
   - Command name: $ARGUMENTS
   - What workflow does this automate?
   - Which agents does it coordinate?
   - What are the inputs and outputs?
   - What quality gates are needed?

2. **Design Command Flow**
   - Sequential vs parallel operations
   - Dependencies between steps
   - Error handling and recovery
   - Cost and time limits

3. **Write Command Structure**
   ```markdown
   # [Command Name]
   
   **Purpose**: [Clear description]
   
   ## Process
   1. Step 1: [Action]
   2. Step 2: [Action]
   ...
   
   ## Quality Gates
   - [Gate 1]: [Threshold]
   - [Gate 2]: [Threshold]
   
   ## Error Handling
   - [Recovery strategy]
   
   ## Cost Limits
   - Maximum: $[amount]
   ```

4. **Create Command File**
   - Save to `.claude/commands/[command-name].md`
   - Include clear documentation
   - Add usage examples
   - Define success criteria

## Command Template

```markdown
# [Command Name]

**Purpose**: [What this command accomplishes]

You are the [role]. Execute [workflow description].

## Inputs
- $ARGUMENTS: [Description of expected arguments]
- Required context: [Files or data needed]

## Workflow

### Step 1: [Name]
- Use [agent/tool]: [Purpose]
- Input: [Data]
- Validate: [Criteria]
- Output: [Result]

### Step 2: [Name]
- Use [agent/tool]: [Purpose]
- Input: [From Step 1]
- Validate: [Criteria]
- Output: [Result]

## Quality Gates
✓ [Metric 1]: [Threshold]
✓ [Metric 2]: [Threshold]
✓ [Metric 3]: [Threshold]

## Error Recovery
- If [step] fails: [Recovery action]
- Maximum retries: [number]
- Fallback: [Alternative approach]

## Cost Control
- Maximum budget: $[amount]
- Per-step limits:
  - Step 1: $[amount]
  - Step 2: $[amount]

## Success Criteria
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]

## Output
- Location: [Where results are saved]
- Format: [Structure of output]

Begin execution for: $ARGUMENTS
```

## Quality Checklist
✅ Single, clear purpose
✅ Explicit step sequence
✅ Quality gates defined
✅ Error handling specified
✅ Cost limits set
✅ Success criteria measurable
✅ Output location clear

Begin building command for: $ARGUMENTS