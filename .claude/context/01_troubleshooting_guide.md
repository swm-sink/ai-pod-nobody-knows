# Troubleshooting Guide - When Things Go Wrong

**Phase:** WALK-CRAWL-RUN
**Skill Level:** beginner-to-advanced
**Estimated Time:** 30-60 minutes per issue


## Overview

## Common problems

### Setup Instructions


-

**Installation Issues**: Most problems start with environment setup. Verify Python version (3.11+), virtual environment activation, and package installation.

-

**Server Issues**: Check port conflicts, file existence, and Python path configuration before starting services.

-

**API Issues**: Validate API keys, rate limiting, timeouts, and authentication before making expensive calls.

-

**Agent Issues**: Debug empty responses, quality failures, and coordination problems using Claude Code's agent debugging tools.

**Example:**

**Example:**
pip install fails with "Could not find a version" error

```bash
1. Update pip: `python -m pip install --upgrade pip`
2. Check Python version: `python --version` (need 3.11+)
3. Install one package at a time to isolate issues
4. Use `--no-cache-dir` flag if cache is corrupted
```

Package managers sometimes have version conflicts or cache issues. Installing one at a time helps identify which specific package is causing problems, while updating pip ensures you have the latest dependency resolution.


**Example:**
MCP server connection failures despite correct API keys

```bash
1. Check if API keys are in MCP server environment: `echo "Key exists: $(if [ -n "$PERPLEXITY_API_KEY" ]; then echo 'Yes'; else echo 'No'; fi)"`
2. Load environment before starting Claude: `source .env && claude`
3. Reconfigure MCP with explicit environment variables
4. Create startup script that loads environment automatically
```

MCP servers run as separate processes and need API keys in their execution environment. Claude Code doesn't automatically load .env files for MCP servers, so you must ensure the environment variables are available when the servers start.


```bash
All imports succeed, environment variables loaded, basic connectivity confirmed

## Claude code debugging

**Example:**

**Example:**
Manual debugging of complex multi-agent coordination failures

```bash
Instead, use: `ultrathink the agent coordination patterns` + `/subagent create-diagnostic-team` + automated analysis. Manual debugging of complex AI systems is inefficient and error-prone compared to systematic AI-assisted diagnosis.


## Self healing systems
Quick command reference for troubleshooting tools
MCP server configuration and setup
System architecture understanding for effective debugging
Error codes and standard diagnostic commands

---

*Converted from XML to Markdown for elegant simplicity*
*Original: 01_troubleshooting_guide.xml*
*Conversion: Mon Aug 18 10:47:17 EDT 2025*
