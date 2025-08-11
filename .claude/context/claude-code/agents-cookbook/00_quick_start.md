# 🚀 Claude Code Agents Quick Start Guide

**Get your first agent running in 5 minutes!**

## What Are Claude Code Agents?

Agents (also called subagents) are specialized AI assistants that handle specific tasks with their own:
- 🧠 Custom system prompts
- 🛠️ Specific tool permissions  
- 🎨 Visual identifiers
- 📦 Separate context windows

## Your First Agent in 3 Steps

### Step 1: Create the Agent File

Create a file in `.claude/agents/` with a `.md` extension:

```bash
mkdir -p .claude/agents
touch .claude/agents/code-reviewer.md
```

### Step 2: Add the Agent Configuration

Copy this template into your agent file:

```markdown
---
name: code-reviewer
description: Expert code review specialist. Use PROACTIVELY after writing or modifying code.
tools: Read, Grep, Glob, Edit
model: sonnet
color: Cyan
---

You are a senior code reviewer ensuring high standards of code quality.

Your responsibilities:
1. Review code for bugs, security issues, and performance problems
2. Check for proper error handling and edge cases
3. Verify code follows project conventions
4. Suggest improvements for readability and maintainability

Always provide:
- Specific line-by-line feedback
- Security vulnerability assessment
- Performance optimization suggestions
- Code quality score (1-10)

Be constructive and educational in your feedback.
```

### Step 3: Use Your Agent

In Claude Code, your agent will be automatically available:

```bash
# Claude will automatically use your agent when appropriate
"Review the code I just wrote"

# Or explicitly invoke it
"Use the code-reviewer agent to check my recent changes"
```

## Quick Agent Templates

### 🔍 Debugger Agent (30 seconds to create)

```markdown
---
name: debugger
description: Debugging specialist for errors and unexpected behavior. Use when encountering bugs.
tools: Read, Edit, Bash, Grep
model: opus
---

You are an expert debugger who excels at finding and fixing bugs.

Focus on:
- Root cause analysis
- Step-by-step debugging approach
- Clear explanations of why bugs occur
- Multiple solution options when available
```

### ✅ Test Writer Agent (30 seconds to create)

```markdown
---
name: test-writer
description: Comprehensive test creation specialist. Use PROACTIVELY after implementing features.
tools: Read, Edit, Write, Bash
model: sonnet
---

You are a test automation expert who writes comprehensive test suites.

Create tests that:
- Cover happy paths and edge cases
- Include unit, integration, and e2e tests
- Follow testing best practices
- Achieve high code coverage
```

## Key Configuration Options

| Field | Required | Options | Purpose |
|-------|----------|---------|---------|
| `name` | ✅ | Any unique identifier | Agent's unique name |
| `description` | ✅ | Clear, directive text | When to use this agent |
| `tools` | ❌ | Read, Edit, Write, Bash, etc. | Available tools (inherits all if omitted) |
| `model` | ❌ | haiku, sonnet, opus | AI model (defaults to sonnet) |
| `color` | ❌ | Any color name | Visual identifier in terminal |

## Pro Tips for Effective Agents

### 1. Use Directive Language in Descriptions
✅ Good: "Use PROACTIVELY after writing code"
❌ Weak: "Can review code if needed"

### 2. Limit Tool Access
Give agents only the tools they need:
- Code reviewer: Read, Grep (no Edit)
- Test writer: Read, Edit, Write, Bash
- Documentation: Read, Write (no Bash)

### 3. Choose the Right Model
- `haiku`: Fast, simple tasks (formatting, linting)
- `sonnet`: Balanced (most agents)
- `opus`: Complex reasoning (debugging, architecture)

### 4. Storage Locations
- **Project agents**: `.claude/agents/` (shared with team)
- **Personal agents**: `~/.claude/agents/` (just for you)
- Project agents override personal ones with same name

## Common Use Cases

### Development Workflow
1. **code-writer**: Initial implementation
2. **test-writer**: Create tests
3. **code-reviewer**: Review quality
4. **debugger**: Fix issues

### Data Analysis Workflow
1. **data-explorer**: Initial analysis
2. **data-validator**: Check quality
3. **insight-generator**: Find patterns
4. **report-writer**: Document findings

## Parallel Processing

Run multiple agents simultaneously (up to 10):

```python
# Claude automatically manages parallel execution when appropriate
"Analyze all Python files for security issues and performance problems"
# Spawns multiple agents to work in parallel
```

## Verification Commands

```bash
# List all available agents
ls .claude/agents/
ls ~/.claude/agents/

# Check if agent is recognized
# Just ask Claude: "What agents do I have available?"
```

## Next Steps

1. ✅ Create your first agent (code-reviewer)
2. ✅ Test it on your code
3. 📚 Explore agent templates in `development/`, `quality/`, `data/`
4. 🎯 Create custom agents for your specific needs
5. 🔄 Combine agents with hooks for automation

## Quick Reference

```yaml
---
name: [unique-identifier]
description: [when-to-use with DIRECTIVE language]
tools: [comma-separated list or omit for all]
model: haiku|sonnet|opus
color: [visual identifier]
---
[System prompt defining role and instructions]
```

**Remember**: Agents are stateless - each invocation starts fresh with no memory of previous interactions.