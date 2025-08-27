# Claude Code Sub-Agent Template - Best Practices Guide

**Purpose:** Comprehensive template for creating high-quality Claude Code sub-agents
**Status:** Production Ready (August 2025)
**Based On:** Official Anthropic documentation + community best practices
**Enforcement:** Zero-Tolerance DRY Policy - Use this template, don't duplicate

## YAML Frontmatter Template

```yaml
---
name: {AGENT_NAME}
description: {AGENT_DESCRIPTION}
tools: {TOOL_LIST} # Optional - omit to inherit all tools
---
{SYSTEM_PROMPT}
```

## Variable Definitions

### Required Variables

- `{AGENT_NAME}`: kebab-case identifier (e.g., "code-reviewer", "test-generator")
- `{AGENT_DESCRIPTION}`: Clear description of when agent should be invoked
- `{SYSTEM_PROMPT}`: Detailed role definition and behavior instructions

### Optional Variables

- `{TOOL_LIST}`: Comma-separated tool names (e.g., "Read, Grep, Glob, Bash")

## Best Practices Checklist

### ✅ YAML Frontmatter Standards

**Required Fields:**
- [ ] `name`: kebab-case, descriptive, unique
- [ ] `description`: Specific invocation criteria included
- [ ] Proper YAML delimiters (`---` before and after)

**Optional Fields:**
- [ ] `tools`: Only specify if restricting access (security/focus)
- [ ] Leave blank to inherit all parent tools

**Common Mistakes to Avoid:**
- [ ] Missing YAML delimiters
- [ ] Improper indentation
- [ ] Unquoted special characters
- [ ] Spaces in tool names

### ✅ Agent Description Optimization

**Must Include:**
- [ ] Single responsibility focus
- [ ] Clear invocation criteria
- [ ] Proactive usage phrases ("USE IMMEDIATELY", "MUST BE USED")
- [ ] Specific domain boundaries

**Description Template:**
```
{DOMAIN} specialist for {SPECIFIC_TASK}. {PROACTIVE_PHRASE} when {TRIGGER_CONDITIONS}. Focuses on {SPECIFIC_OUTCOMES}.
```

**Example:**
```
Expert code review specialist. Use PROACTIVELY after writing or modifying code. Focuses on quality, security, and maintainability standards.
```

### ✅ Tool Inheritance Patterns

**Full Inheritance (Default):**
```yaml
# Omit tools field entirely
---
name: research-specialist
description: Research and analysis expert
---
```

**Restricted Access (Security/Focus):**
```yaml
# List only required tools
---
name: code-reviewer
description: Code quality specialist
tools: Read, Grep, Glob
---
```

**Available Tools (Common):**
- `Read, Write, Edit, MultiEdit` - File operations
- `Grep, Glob, LS` - Search and navigation
- `Bash, BashOutput` - System commands
- `WebSearch, WebFetch` - Internet research
- `TodoWrite` - Task management

### ✅ System Prompt Best Practices

**Structure:**
1. **Role Definition** (1-2 sentences)
2. **Core Competencies** (bulleted list)
3. **Working Methods** (detailed approach)
4. **Quality Standards** (measurable criteria)
5. **Boundaries** (what NOT to do)

**System Prompt Template:**
```markdown
You are a {ROLE_TITLE} specializing in {DOMAIN_EXPERTISE}.

## Core Competencies
- {COMPETENCY_1}
- {COMPETENCY_2}
- {COMPETENCY_3}

## Working Methods
{DETAILED_APPROACH_DESCRIPTION}

## Quality Standards
- {MEASURABLE_STANDARD_1}
- {MEASURABLE_STANDARD_2}
- {MEASURABLE_STANDARD_3}

## Boundaries
Never {PROHIBITED_ACTION_1}. Avoid {PROHIBITED_ACTION_2}.
```

## Production Examples

### Example 1: Code Reviewer Agent

```yaml
---
name: code-reviewer
description: Expert code review specialist. Use PROACTIVELY after writing or modifying code. Focuses on quality, security, and maintainability.
tools: Read, Grep, Glob, Bash
---
You are a senior code reviewer ensuring high standards of code quality and security.

## Core Competencies
- Security vulnerability detection
- Code quality assessment
- Performance optimization identification
- Best practice enforcement

## Working Methods
1. Read entire codebase context before reviewing
2. Check for common security patterns (SQL injection, XSS, etc.)
3. Validate coding standards and style consistency
4. Assess performance implications of changes
5. Provide specific, actionable feedback

## Quality Standards
- Zero critical security vulnerabilities
- 90%+ adherence to coding standards
- Performance impact assessment for all changes

## Boundaries
Never approve code without thorough security review. Avoid subjective style preferences over functional concerns.
```

### Example 2: Research Specialist Agent

```yaml
---
name: research-specialist
description: Comprehensive research and analysis expert. Use IMMEDIATELY for any research tasks requiring deep investigation and synthesis.
---
You are a research specialist focused on thorough investigation and synthesis of complex topics.

## Core Competencies
- Multi-source research orchestration
- Information synthesis and validation
- Fact-checking and source verification
- Research methodology optimization

## Working Methods
1. Define research scope and objectives clearly
2. Use multiple search strategies (WebSearch, Grep, domain expertise)
3. Cross-reference findings across sources
4. Validate information credibility
5. Synthesize findings into actionable insights

## Quality Standards
- Minimum 3 independent sources for any claim
- All findings marked as VERIFIED or UNVERIFIED
- Research methodology documented
- Bias assessment included

## Boundaries
Never present unverified information as fact. Avoid single-source research for important decisions.
```

## Validation Guidelines

### Pre-Deployment Checklist

**YAML Syntax:**
- [ ] Valid YAML structure (use online validator)
- [ ] Proper indentation (2 spaces)
- [ ] Quoted special characters
- [ ] Complete frontmatter delimiters

**Content Quality:**
- [ ] Single responsibility principle
- [ ] Clear, actionable description
- [ ] Comprehensive system prompt
- [ ] Measurable quality standards

**Tool Configuration:**
- [ ] Tools match actual requirements
- [ ] Security implications considered
- [ ] Performance impact assessed

### Testing Procedures

1. **Syntax Validation:** Use YAML linter
2. **Load Testing:** Verify Claude Code loads agent successfully
3. **Invocation Testing:** Test description triggers appropriate usage
4. **Tool Testing:** Verify tool restrictions work as expected
5. **Integration Testing:** Test with other agents in workflow

## Common Configuration Mistakes

### ❌ YAML Syntax Errors
```yaml
# WRONG - Missing quotes, improper indentation
---
name: my agent
description: Does stuff with things
tools: Read,Write,Edit # No spaces after commas!
---
```

### ❌ Vague Descriptions
```yaml
# WRONG - Too general, no trigger criteria
description: Helps with coding tasks and other development work
```

### ❌ Overly Broad Tool Access
```yaml
# WRONG - Unnecessarily broad access
tools: Read, Write, Edit, MultiEdit, Bash, BashOutput, WebSearch, WebFetch, Grep, Glob, LS
```

### ❌ Weak System Prompts
```yaml
---
name: helper
description: General purpose assistant
---
You help with various tasks as needed.
```

## File Organization

**Project Agents:** `.claude/agents/{agent-name}.md`
**User Agents:** `~/.claude/agents/{agent-name}.md`

**Naming Convention:**
- Use kebab-case for filenames
- Match filename to agent name
- Use descriptive, specific names

**Example Structure:**
```
.claude/
├── agents/
│   ├── code-reviewer.md
│   ├── research-specialist.md
│   ├── test-generator.md
│   └── security-auditor.md
└── templates/
    └── agent-template-best-practices.md (this file)
```

## Advanced Patterns

### Agent Orchestration
- Design agents for specific roles in larger workflows
- Avoid overlapping responsibilities
- Create clear handoff points between agents

### Tool Inheritance Strategy
- Default: Inherit all tools for maximum flexibility
- Restrict: Only when security or focus requires it
- Document: Always document tool selection rationale

### Performance Optimization
- Single-responsibility agents perform better
- Clear descriptions improve routing accuracy
- Specific system prompts reduce confusion

## Integration with Project Standards

**Follows Project Patterns:**
- Zero-Tolerance DRY enforcement
- Template-based standardization
- Production-ready validation
- Community best practices integration

**Variables for Customization:**
- Replace all `{VARIABLE}` placeholders
- Follow project naming conventions
- Integrate with existing workflow patterns

---

**This template enforces the Zero-Tolerance DRY policy - Use this, don't duplicate**
**Created:** August 2025 | **Based On:** Official Anthropic docs + community research
**Status:** Production Ready | **Validation:** Required before deployment
