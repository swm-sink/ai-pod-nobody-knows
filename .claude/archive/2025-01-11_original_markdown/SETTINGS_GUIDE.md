# Settings Files Guide - IMPORTANT

## ⚠️ CRITICAL: Only ONE Settings File

**There should be ONLY ONE settings file:**
- **Location**: `.claude/settings.local.json`
- **Purpose**: Store local Claude Code permissions
- **Git Status**: IGNORED (in .gitignore)

## ❌ DO NOT CREATE

Never create these files:
- `/settings.local.json` (root directory)
- `/settings.json` (root directory)
- `/.claude/settings.json` (non-local version)
- Any other variants

## 📁 Other JSON Files (NOT Settings)

These JSON files serve different purposes:
- `.mcp.json` - MCP server configuration (root)
- `.claude/config/mcp-config.json` - MCP integration config
- `.claude/shared/templates/sessions/*.json` - Session templates
- `.claude/test-data/*.json` - Test/mock data

## 🛡️ Why This Matters

Multiple settings files cause:
- Configuration conflicts
- Git tracking issues
- Permission confusion
- Claude Code errors

## ✅ Verification

To verify only one settings file exists:
```bash
find . -name "*settings*.json" -o -name "*local*.json" | grep -v node_modules
# Should ONLY show: ./.claude/settings.local.json
```

---
**Remember**: ONE settings file in `.claude/` directory only!
