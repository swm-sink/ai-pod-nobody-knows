#!/usr/bin/env bash
set -euo pipefail

blocked=$(git diff --name-only --cached | grep -E '(^|/)(\.env(\..*)?$|\.mcp\.json$|\.claude/mcp-servers/|mcp-servers/|.*/elevenlabs-mcp/|.*/perplexity-mcp/|\.claude/scripts/)' || true)
if [ -n "${blocked}" ]; then
    echo "Blocked: do not commit secret config or local MCP dirs/files:" >&2
    echo "$blocked" >&2
    echo "If you intended to share config, commit the .example files instead." >&2
    exit 1
fi
