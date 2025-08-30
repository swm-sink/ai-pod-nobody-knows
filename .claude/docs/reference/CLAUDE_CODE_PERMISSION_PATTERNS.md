# Claude Code Permission Patterns Reference

**Research Date**: August 2025
**Purpose**: Document correct permission patterns to prevent edit prompts

## ✅ Valid Tool Names (Case Sensitive)

- `Edit` - Modify existing file content
- `Write` - Create new files or overwrite existing
- `MultiEdit` - Batch edit multiple files atomically
- `Bash` - Execute shell commands
- `Read` - Read files and directories
- `Grep` - Search within files
- `Glob` - Pattern-based file matching
- `LS` - List directory contents
- `WebFetch` - Web content retrieval
- `WebSearch` - Web search operations
- `Task` - Delegate to sub-agents
- `TodoWrite` - Todo list management

## 🎯 Recommended Permission Patterns

### For Unrestricted Development Access:
```json
"allow": [
  "Edit(*)",
  "Write(*)",
  "MultiEdit(*)",
  "Read(*)",
  "Bash(*)",
  "Grep(*)",
  "Glob(*)",
  "LS(*)"
]
```

### Pattern Meaning:
- `Edit(*)` - Allow editing ANY file recursively
- `Edit(.)` - Allow editing ONLY current directory files
- `Edit(**/*.md)` - Allow editing only markdown files anywhere

## ❌ Invalid/Non-Existent Tools
- `Update` - Does not exist, causes permission prompts
- `Modify` - Does not exist
- `Change` - Does not exist

## 🚫 Unreliable Patterns (August 2025)
- `*` wildcard at top of allow array - Documented as unreliable
- Mixed `(.)` and `(**)` patterns - Use consistent `(*)` instead

## 🔧 MCP Tool Integration
```json
"mcp__perplexity-ask__perplexity_ask",
"Direct_API_elevenlabs_text_to_speech"
```

## 🏗️ Best Practices
1. Use explicit tool names, not generic wildcards
2. Use `(*)` for recursive directory access
3. Remove any non-existent tools like `Update(.)`
4. Test permission changes by attempting file edits
5. Check Claude Code logs for permission errors

## 🔍 Troubleshooting
If still getting permission prompts:
1. Check for typos in tool names (case sensitive)
2. Ensure no conflicting `deny` rules
3. Restart Claude Code after settings changes
4. Use specific patterns instead of broad wildcards

---
**Source**: Based on comprehensive Perplexity research and Claude Code documentation August 2025
