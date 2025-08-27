#!/bin/bash

# Agent Architecture Validator Hook
# Ensures all agent modifications comply with correct sub-agent patterns
# Auto-loads architecture documentation for compliance

set -euo pipefail

HOOK_NAME="agent-architecture-validator"
LOG_FILE=".claude/logs/hooks.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$HOOK_NAME] $1" | tee -a "$LOG_FILE"
}

# Check if we're modifying agent-related files
check_agent_modifications() {
    local modified_files="$1"

    # Check for agent file modifications
    if echo "$modified_files" | grep -qE "\\.claude/(agents|commands)/.*\\.md$"; then
        return 0  # Agent files being modified
    fi

    return 1  # No agent files being modified
}

# Validate agent architecture patterns
validate_agent_patterns() {
    local file="$1"
    local errors=""

    # Check for incorrect Task tool delegation patterns
    if grep -q "Use Task tool.*delegate.*agent" "$file"; then
        errors+="❌ INCORRECT: Found Task tool delegation pattern in $file\n"
        errors+="   Use direct invocation: 'Use the [agent-name] agent to...'\n"
    fi

    # Check for agent YAML with restricted tools
    if [[ "$file" =~ \.claude/agents/.*\.md$ ]] && grep -q "^tools:" "$file"; then
        errors+="⚠️  WARNING: Agent $file has tools restriction - may block MCP inheritance\n"
        errors+="   Consider removing 'tools:' field for full MCP access\n"
    fi

    # Check for missing direct invocation patterns in commands
    if [[ "$file" =~ \.claude/commands/.*\.md$ ]] && ! grep -q "Use the .* agent to" "$file"; then
        errors+="⚠️  WARNING: Command $file may not use direct sub-agent invocation\n"
        errors+="   Ensure proper 'Use the [agent-name] agent to...' patterns\n"
    fi

    echo -e "$errors"
}

# Main validation function
main() {
    local modified_files="${1:-}"

    if [ -z "$modified_files" ]; then
        log "No modified files provided"
        return 0
    fi

    log "Checking for agent modifications..."

    if check_agent_modifications "$modified_files"; then
        log "🚨 AGENT MODIFICATIONS DETECTED - Loading architecture context..."

        # Display critical architecture reminder
        cat << 'EOF'

🚨 CRITICAL ARCHITECTURE REMINDER 🚨

You are modifying agent or command files. MANDATORY requirements:

📖 REQUIRED READING: @.claude/context/sub-agent-architecture.md
🔧 MCP INTEGRATION: @.claude/context/mcp-tool-inheritance.md

✅ CORRECT PATTERN:
   Use the [agent-name] agent to [action]: "requirements"

❌ INCORRECT PATTERN:
   Use Task tool to delegate to [agent-name]

🔍 VALIDATION CHECKLIST:
- [ ] Uses direct sub-agent invocation (NOT Task tool)
- [ ] Agent YAML omits 'tools:' field for MCP inheritance
- [ ] Commands specify MCP tool requirements
- [ ] Expected result: >0 tool uses (not simulation)

EOF

        # Validate each modified agent/command file
        local validation_errors=""
        while IFS= read -r file; do
            if [[ "$file" =~ \\.claude/(agents|commands)/.*\\.md$ ]] && [[ -f "$file" ]]; then
                log "Validating: $file"
                local file_errors
                file_errors=$(validate_agent_patterns "$file")
                if [[ -n "$file_errors" ]]; then
                    validation_errors+="$file_errors"
                fi
            fi
        done <<< "$modified_files"

        # Report validation results
        if [[ -n "$validation_errors" ]]; then
            log "🚨 ARCHITECTURE VIOLATIONS DETECTED:"
            echo -e "$validation_errors"

            cat << 'EOF'

🔧 REQUIRED ACTIONS:
1. Load architecture context: @.claude/context/sub-agent-architecture.md
2. Fix identified pattern violations
3. Test with real sub-agent execution (verify >0 tool uses)
4. Ensure MCP tool inheritance is working

EOF
        else
            log "✅ Architecture patterns look compliant"
        fi

        # Always remind about the documentation
        echo ""
        echo "📚 Before proceeding, ensure you've reviewed:"
        echo "   @.claude/context/sub-agent-architecture.md"
        echo "   @.claude/context/mcp-tool-inheritance.md"
        echo ""

    else
        log "No agent modifications detected"
    fi
}

# Run the hook
main "$@"
