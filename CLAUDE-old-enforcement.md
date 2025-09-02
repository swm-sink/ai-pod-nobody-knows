# CLAUDE.md - AI Podcast Production Master System 🎓

<!-- markdownlint-disable-file -->

<!-- CLAUDE 4 OPTIMIZED: Token budget 12K, Selective loading enabled -->
<MANDATORY_CONTEXT>
<!-- This block MUST be loaded for all operations -->

## 🎯 MANDATORY SIMPLICITY ENFORCEMENT

<SYSTEM_DIRECTIVE priority="MAXIMUM">
**PROHIBIT OVERCOMPLICATED SOLUTIONS - ENFORCE MINIMUM VIABLE COMPLEXITY**
</SYSTEM_DIRECTIVE>

**Teaching Format:**
- **Technical:** Professional explanation with industry terminology
- **Simple:** "Think of it like..." analogy-based explanation
- **Connection:** "This helps you learn..." learning value and transferable skills

**Brutal Enforcement Rules:**
- IF solution has more than 3 moving parts → REJECTED
- IF solution requires new infrastructure → REJECTED, use existing tools
- IF solution cannot be explained in 2 sentences → REJECTED
- IF solution creates new abstractions → REJECTED, use Claude Code native patterns

## ⚡ CLAUDE CODE NATIVE ENFORCEMENT - ABSOLUTE REQUIREMENTS

<CRITICAL_ENFORCEMENT priority="NUCLEAR">
**THIS IS A CLAUDE CODE NATIVE PROJECT - VIOLATIONS STOP ALL WORK**

**MANDATORY CLAUDE CODE PATTERNS OR IMMEDIATE REJECTION:**
</CRITICAL_ENFORCEMENT>

### 📚 OFFICIAL CLAUDE CODE DOCUMENTATION (REQUIRED READING)

1. **[Claude Code Overview](https://docs.anthropic.com/en/docs/claude-code)** - Core architecture and native patterns. Sub-agents MUST use direct invocation, NOT Task tool delegation.

2. **[MCP Integration](https://docs.anthropic.com/en/docs/claude-code/mcp)** - Model Context Protocol for external tools. ALWAYS inherit MCP tools by omitting `tools` field in agent YAML.

3. **[Slash Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)** - Native command patterns. Commands MUST orchestrate agents, NOT implement logic directly.

4. **[Settings & Hooks](https://docs.anthropic.com/en/docs/claude-code/settings)** - Event-driven automation. Hooks MUST be bash scripts in `.claude/hooks/` directory.

5. **[Memory Management](https://docs.anthropic.com/en/docs/claude-code/memory)** - Context and CLAUDE.md best practices. MAXIMUM 200K context, selective loading REQUIRED.

### 🚫 FORBIDDEN ANTI-PATTERNS (INSTANT REJECTION)

**These patterns are ABSOLUTELY PROHIBITED:**
- ❌ Using `Task` tool for agent invocation → Use direct invocation pattern
- ❌ Hardcoding tools in agent YAML → Omit tools field for MCP inheritance
- ❌ Creating custom frameworks → Use native Claude Code patterns only
- ❌ Implementing logic in commands → Commands orchestrate, agents implement
- ❌ Python/JS hooks → Only bash scripts allowed in hooks
- ❌ Context files >15K tokens → Enforce selective loading
- ❌ Agent files without YAML frontmatter → Required for Claude Code parsing

### ✅ REQUIRED NATIVE PATTERNS

**Every implementation MUST follow:**
```markdown
# Correct Agent Invocation (ONLY PATTERN ALLOWED)
Use the [agent-name] agent to [action]: "specific requirements"

# Correct MCP Tool Usage (INHERIT BY OMISSION)
name: researcher
# NO tools field - inherits all MCP tools automatically

# Correct Command Pattern (ORCHESTRATION ONLY)
/podcast-workflow → chains /research → /production → /audio

# Correct Hook Pattern (BASH ONLY)
#!/bin/bash
# All hooks must be executable bash scripts

# Correct Context Loading (SELECTIVE)
<LOAD_IF task="specific_task">Load only when needed</LOAD_IF>
```

### 🔨 ENFORCEMENT CONSEQUENCES

**Violations trigger IMMEDIATE:**
1. **FULL STOP** - All work ceases instantly
2. **REVERSION** - Changes rolled back completely
3. **RE-EDUCATION** - Must read official docs before continuing
4. **VALIDATION** - Must prove understanding of native patterns
5. **AUDIT** - Full codebase scan for other violations

**NO EXCEPTIONS. NO WORKAROUNDS. NO CUSTOM SOLUTIONS.**

## 🔒 CRITICAL PRODUCTION CONFIGURATION GOVERNANCE

<CRITICAL_CONSTRAINT override="NEVER">
**VOICE ID CHANGES REQUIRE EXPLICIT USER PERMISSION - NO EXCEPTIONS**
</CRITICAL_CONSTRAINT>

**CURRENT PRODUCTION VOICE:** ZF6FPAbjXT4488VcRRnw (Amelia - Episode 1 validated)

**Central Configuration:**
- `.claude/config/production-voice.json` - Single source of truth
- Environment variable: PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw


## 🚀 Quick Start

1. Copy .env.example to .env and add API keys  
2. Run ./setup-mcp.sh
3. Run /init  
4. Run /podcast-workflow "Your Topic"

That's it!

---

**Version:** 2.0.0 Simplified | **Updated:** 2025-09-01

