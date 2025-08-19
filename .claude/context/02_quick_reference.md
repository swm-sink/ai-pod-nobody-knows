# Quick Reference Guide - Essential Commands and Patterns

**Estimated Time:** 5-10 minutes for lookup


## Overview

## Essential commands

### Setup Instructions


- 
                
**Project Setup**: Create virtual environment, install dependencies, configure API keys

- 
                
**Daily Operations**: Start server, run tests, check code quality, view logs

- 
                
**Claude Code Integration**: Memory management, thinking modes, MCP servers, file operations

- 
                
**Emergency Recovery**: Context overflow, performance issues, cost spikes, quality degradation

**Example:**

**Example:**
Start daily development workflow

```bash
```bash
source venv/bin/activate
/init  # Claude Code memory initialization
uvicorn core.orchestration.server:app --reload
curl localhost:8000/health &amp;&amp; echo "Server OK"
```
```

This sequence activates your Python environment, initializes Claude Code's project memory system, starts the FastAPI server with auto-reload, and verifies everything is working correctly.


**Example:**
Debug complex multi-agent coordination issue

```bash
```bash
# Progressive analysis with Claude Code
ultrathink the agent coordination patterns and failure points
/subagent create-diagnostic-team --components="research,script,quality,audio"
/mcp__health__comprehensive-check --include-latency
/hooks validate-all --safe-mode
```
```

Uses Claude Code's advanced debugging features: deep thinking mode for analysis, specialized subagents for component testing, MCP health checks for external services, and hook validation for automation systems.


## Emergency procedures

**Example:**

**Example:**
Context window overflow during long debugging session

```bash
Solution: Use `/compact` to summarize conversation, `/clear` to reset (save important info to memory first), or add key information to permanent memory with `# Remember: [key insight]` before clearing.


```bash
No critical errors in recent logs, all services responding

## Automation patterns

**Example:**

**Example:**
Self-healing quality assurance system

```bash
```python
# .claude/hooks/pre-tool-use.py
def pre_synthesis_quality_check(context):
if context.operation == "audio_synthesis":
script_quality = evaluate_script_quality(context.script)
if script_quality &lt; 0.8:
# Auto-regenerate with improved prompts
context.script = improve_script(context.script)
return context
```
```

Automated hook that checks script quality before expensive audio synthesis, automatically improving low-quality scripts to prevent wasted costs and poor episodes.

Detailed troubleshooting procedures for complex issues
Step-by-step production workflow procedures
Claude Code memory system details and best practices
Complete command definitions and configurations

---

*Converted from XML to Markdown for elegant simplicity*
*Original: 02_quick_reference.xml*
*Conversion: Mon Aug 18 10:47:18 EDT 2025*
