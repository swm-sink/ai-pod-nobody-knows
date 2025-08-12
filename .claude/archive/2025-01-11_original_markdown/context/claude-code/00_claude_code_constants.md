<document type="constants" version="3.1.0" enhanced="2025-08-11">
  <metadata>
    <title>Claude Code Constants and Configuration</title>
    <scope>claude-code-domain</scope>
    <category>claude-code</category>
    <mutability>read-only</mutability>
    <validation-frequency>weekly</validation-frequency>
    <navigation>
      <index>@NAVIGATION.md</index>
      <related>@../../00_GLOBAL_CONSTANTS.md</related>
    </navigation>
  </metadata>

  <summary>
    Central repository for Claude Code commands, configurations, and feature specifications.
    Single source of truth for all Claude Code documentation to reference instead of duplicating values.
  </summary>
</document>

# Claude Code Constants and Configuration

## Overview

<purpose>
  This file contains all constants, commands, and configuration values for the Claude Code domain.
  All Claude Code documentation should reference these values rather than hardcoding them.
</purpose>

---

## 🎯 Claude Code Commands

```yaml
CONTEXT_MANAGEMENT:
  init:
    command: "/init"
    purpose: "Initialize project memory"
  clear:
    command: "/clear"
    purpose: "Clear conversation"
  compact:
    command: "/compact"
    purpose: "Compact conversation"
  memory_add:
    command: "# [note]"
    purpose: "Add quick memory"
  memory_open:
    command: "/memory"
    purpose: "Open memory file"

THINKING_MODES:
  basic:
    trigger: "think"
    level: 1
    purpose: "Basic reasoning"
  enhanced:
    trigger: "think hard"
    level: 2
    purpose: "Enhanced analysis"
  deep:
    trigger: "think harder"
    level: 3
    purpose: "Deep exploration"
  maximum:
    trigger: "ultrathink"
    level: 4
    purpose: "Maximum thinking budget"

MCP_COMMANDS:
  add_server: "claude mcp add [server-name]"
  list_servers: "claude mcp list"
  use_resource: "@[resource-name]"
  mcp_slash: "/mcp__servername__promptname"

PRODUCTIVITY:
  tab_completion: "[Tab]"
  interrupt: "[Escape]"
  edit_previous: "[Escape][Escape]"
  file_reference: "@filename.py"
```

---

## 🔧 Claude Code Configuration

```yaml
MEMORY_HIERARCHY:
  level_1:
    path: "~/.claude/CLAUDE.md"
    scope: "global"
    priority: 1
  level_2:
    path: "./CLAUDE.md"
    scope: "project"
    priority: 2
  level_3:
    path: "subdirectory/CLAUDE.md"
    scope: "directory"
    priority: 3
  level_4:
    path: "CLAUDE.local.md"
    scope: "personal"
    priority: 4

PERFORMANCE:
  xml_semantic_boost: "40%"
  context_window: "optimized"
  thinking_budget:
    basic: "standard"
    enhanced: "2x"
    deep: "4x"
    maximum: "unlimited"
```

---

## 🪝 Hooks System

```yaml
HOOK_EVENTS:
  pre_tool_use: "Before file changes"
  post_tool_use: "After code modifications"
  session_complete: "End of session"

COMMON_HOOKS:
  pre_commit:
    event: "pre-tool-use"
    command: "ruff check . && black . && pytest tests/"
  session_summary:
    event: "session-complete"
    command: "git add . && git commit -m 'Session: $(date)'"
  cost_tracker:
    event: "post-tool-use"
    command: "echo '$(date): Tool used' >> logs/usage.log"
```

---

## 🔌 MCP Integration

```yaml
MCP_SERVERS:
  github:
    priority: "high"
    capabilities: ["issues", "PRs", "repos"]
    setup: "claude mcp add github"
  filesystem:
    priority: "medium"
    capabilities: ["enhanced file ops"]
    setup: "claude mcp add filesystem"
  web_search:
    priority: "medium"
    capabilities: ["real-time search"]
    setup: "claude mcp add web-search"
  elevenlabs:
    priority: "high"
    capabilities: ["TTS", "voice clone", "transcribe"]
    setup: "claude mcp add elevenlabs"
```

---

## 📁 Claude Directory Structure

```yaml
CLAUDE_DIRS:
  commands: ".claude/commands/"
  hooks: ".claude/hooks/"
  memory: ".claude/"
  context: ".claude/context/"
  sessions: ".claude/sessions/"

FILE_PATTERNS:
  command: "[name].md"
  hook: "[event]-[name].sh"
  memory: "CLAUDE.md"
  local: "CLAUDE.local.md"
  ignore: ".claudeignore"
```

---

## 🚀 Features & Capabilities

```yaml
FEATURES:
  memory_management: "enabled"
  xml_semantic_tagging: "enabled"
  hooks_integration: "configured"
  mcp_servers: "enabled"
  custom_commands: "enabled"
  thinking_modes: "ultrathink-available"
  tab_completion: "enabled"
  escape_interruption: "enabled"
  session_continuity: "enabled"
```

---

## 📊 Optimization Settings

```yaml
CONTEXT_OPTIMIZATION:
  clear_frequency: "Every 3-5 major tasks"
  compact_when: "Context > 50% full"
  claudeignore_patterns:
    - "node_modules/"
    - ".git/"
    - "__pycache__/"
    - "*.log"
    - ".DS_Store"
    - ".env"
    - "dist/"
    - "build/"
    - "venv/"
```

---

## 🔗 Cross-References

- **Global Project**: [00_GLOBAL_CONSTANTS.md](../../00_GLOBAL_CONSTANTS.md)
- **Memory Guide**: [16_memory_management_system.md](./16_memory_management_system.md)
- **Commands Guide**: [17_command_reference_guide.md](./17_command_reference_guide.md)
- **Thinking Modes**: [19_thinking_modes_guide.md](./19_thinking_modes_guide.md)
- **Hooks Guide**: [20_hooks_automation_system.md](./20_hooks_automation_system.md)

---

*Version 1.0.0 - Single source of truth for Claude Code specifications*
