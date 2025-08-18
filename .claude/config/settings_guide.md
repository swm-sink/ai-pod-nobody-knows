# Settings Files Guide - IMPORTANT


type="configuration-guide"
version="1.0">
CRITICAL: Only ONE Settings File
⚠️
.claude/settings.local.json
Store local Claude Code permissions
IGNORED (in .gitignore)
There should be ONLY ONE settings file
DO NOT CREATE
/settings.local.json
root directory
/settings.json
root directory
/.claude/settings.json
non-local version
Any other variants
all other naming patterns
Other JSON Files (NOT Settings)
These JSON files serve different purposes:
.mcp.json
MCP server configuration (root)
.claude/config/mcp-config.json
MCP integration config
.claude/shared/templates/sessions/*.json
Session templates
.claude/test-data/*.json
Test/mock data
Why This Matters
Configuration conflicts
Git tracking issues
Permission confusion
Claude Code errors
Multiple settings files cause these serious problems
Verification
To verify only one settings file exists:
find . -name "*settings*.json" -o -name "*local*.json" | grep -v node_modules
# Should ONLY show: ./.claude/settings.local.json
Remember: ONE settings file in .claude/ directory only!

---

*Converted from XML to Markdown for elegant simplicity*
*Original: settings_guide.xml*
*Conversion: Mon Aug 18 00:01:17 EDT 2025*
