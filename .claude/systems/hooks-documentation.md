# Claude Code Hooks System Documentation

## 🪝 CLAUDE CODE HOOKS SYSTEM DOCUMENTATION

### Critical Importance
HOOKS PROVIDE NATIVE OBSERVABILITY AND AUTOMATION FOR CLAUDE CODE
ALL AUTOMATION MUST USE HOOKS - NO STANDALONE MONITORING SYSTEMS
VALID EVENT TYPES STRICTLY ENFORCED - NO CUSTOM EVENT NAMES

### Technical Explanation
Claude Code hooks system provides event-driven automation through shell command execution at specific lifecycle points, enabling cost tracking, validation, state management, and workflow orchestration without external dependencies.

### Simple Explanation
Think of hooks like automatic triggers in a smart home - when you enter a room (event), the lights turn on (action). Hooks watch for specific Claude Code events and run commands automatically.

### Learning Value
This teaches event-driven architecture, lifecycle management, and automated observability patterns essential for production AI systems.

### Valid Hook Events

#### PreToolUse
**Description:** Executes after Claude creates tool parameters, before processing the tool call
**Use Cases:** Cost validation, permission checks, input sanitization, rate limiting
**Matchers:** Task, Bash, Glob, Grep, Read, Edit, Write, WebFetch, or wildcard (*)
**Environment Variables:** $CLAUDE_TOOL_NAME, $CLAUDE_TOOL_ARGS

#### PostToolUse
**Description:** Executes immediately after a tool completes successfully
**Use Cases:** Cost tracking, result validation, checkpoint creation, logging
**Matchers:** Same as PreToolUse
**Environment Variables:** $CLAUDE_TOOL_NAME, $CLAUDE_TOKEN_COUNT, $CLAUDE_TOOL_RESULT

#### UserPromptSubmit
**Description:** Executes when user submits a prompt to Claude
**Use Cases:** Input validation, context injection, prompt enhancement, blocking malicious input
**Environment Variables:** $CLAUDE_USER_PROMPT

#### Notification
**Description:** Triggers for permission requests or 60+ second idle prompts
**Use Cases:** Custom notifications, alerting, user engagement tracking
**Environment Variables:** $CLAUDE_NOTIFICATION_TYPE, $CLAUDE_NOTIFICATION_MESSAGE

#### Stop
**Description:** Executes when main Claude Code agent finishes responding
**Use Cases:** Session cleanup, final logging, state persistence, cost summary
**Environment Variables:** $CLAUDE_SESSION_ID, $CLAUDE_TOTAL_TOKENS

#### SubagentStop
**Description:** Executes when a subagent (Task tool call) finishes
**Use Cases:** Subagent cost tracking, result validation, performance monitoring
**Environment Variables:** $CLAUDE_SUBAGENT_NAME, $CLAUDE_SUBAGENT_RESULT

#### SessionStart
**Description:** Executes when starting or resuming a session
**Use Cases:** Environment setup, state restoration, configuration loading
**Matchers:** startup, resume, clear
**Environment Variables:** $CLAUDE_SESSION_TYPE

#### SessionEnd
**Description:** Executes when session ends
**Use Cases:** Cleanup, final reports, state archival, resource deallocation
**Matchers:** clear, logout, prompt_input_exit
**Environment Variables:** $CLAUDE_SESSION_END_REASON

#### PreCompact
**Description:** Executes before context compaction
**Use Cases:** State preservation, important context flagging, pre-compact validation
**Matchers:** manual (from /compact), auto (context window full)
**Environment Variables:** $CLAUDE_COMPACT_REASON

### Invalid Events Warning

**CRITICAL:** The following are NOT valid event types and will cause configuration errors:
- **Error** - Use PostToolUse with error detection instead
- **PrePrompt** - Use UserPromptSubmit instead
- **PostPrompt** - Use Stop instead
- **Custom event names** - Only the 9 documented events are valid

### Configuration Example

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/pre-tool-cost-validation.sh \"$CLAUDE_TOOL_NAME\"",
          "timeout": 5
        }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Task",
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/post-agent-tracking.sh",
          "timeout": 10
        }
      ]
    }
  ]
}
```

### Best Practices

- **Use specific matchers** instead of wildcards when possible for performance
- **Set appropriate timeouts** (default 30s, max 300s) to prevent hanging
- **Return JSON** for structured communication between hooks and Claude
- **Log to .claude/logs/** for debugging and audit trails
- **Use environment variables** for dynamic configuration
- **Implement error handling** within hook scripts

### Error Recovery Pattern

Since "Error" is not a valid event type, implement error recovery through existing hooks:

1. **In PostToolUse:** Check $CLAUDE_TOOL_RESULT for errors
2. **In Stop:** Perform session-level error recovery
3. **In hooks scripts:** Use exit codes and JSON responses for error signaling
4. **Keep error-recovery-handler.sh** as a utility called by other hooks

### Documentation Reference

- **Official Docs:** https://docs.anthropic.com/en/docs/claude-code/hooks
- **Hooks Guide:** https://docs.anthropic.com/en/docs/claude-code/hooks-guide
- **Configuration Schema:** https://json.schemastore.org/claude-code-settings.json

### Hook Implementation Examples

#### Cost Validation Hook
```bash
#!/bin/bash
# .claude/hooks/pre-tool-cost-validation.sh

TOOL_NAME="$1"
BUDGET_LIMIT=100.00

current_cost=$(cat .claude/state/session_cost.txt 2>/dev/null || echo "0.00")

if (( $(echo "$current_cost > $BUDGET_LIMIT" | bc -l) )); then
    echo '{"block": true, "message": "Budget exceeded"}'
    exit 1
fi

echo '{"allow": true}'
exit 0
```

#### Agent Tracking Hook
```bash
#!/bin/bash
# .claude/hooks/post-agent-tracking.sh

AGENT_NAME="$CLAUDE_SUBAGENT_NAME"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "{\"agent\": \"$AGENT_NAME\", \"completed\": \"$TIMESTAMP\"}" >> .claude/logs/agent-usage.log

exit 0
```

### Security Considerations

- **Validate all inputs** in hook scripts
- **Use absolute paths** for all file operations
- **Sanitize environment variables** before use
- **Implement timeout handling** to prevent hanging
- **Log all hook executions** for audit trails
- **Restrict hook permissions** to minimum required access
