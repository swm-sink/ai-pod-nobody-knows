# Claude Code Integration - Complete MCP & Sub-Agent Framework

**Created**: 2025-08-27 (Consolidated from 3 files)
**Purpose**: Unified Claude Code integration framework for MCP tools and sub-agent coordination
**Scope**: MCP tool inheritance, sub-agent architecture, and production integration patterns

---

## 🎯 CRITICAL MCP INTEGRATION FINDINGS

**Research Validation**: Sub-agents CAN access MCP tools when properly configured
**Official Documentation Confirms**: "When the tools field is omitted, subagents inherit all MCP tools available to the main thread"
**Root Cause of Confusion**: YAML configuration syntax errors and MCP bugs, NOT architectural limitations

**Key Insight**: Original assumptions about MCP isolation were incorrect. Proper configuration enables full MCP tool inheritance for sub-agents.

---

## 🔧 MCP TOOL INHERITANCE FRAMEWORK

### Validated MCP Architecture
```yaml
mcp_tool_inheritance:
  confirmed_capability:
    tool_access: "Sub-agents inherit ALL MCP tools when tools field omitted"
    task_tool_integration: "Task tool gives sub-agents same access as main agent"
    server_access: "Sub-agents can access MCP tools from configured servers"

  working_configuration:
    yaml_structure: |
      # CORRECT: Omit tools field for MCP inheritance
      subagent_type: "research-deep-dive"
      prompt: "Execute comprehensive research using all available tools"
      # No tools field = inherit all MCP tools

    incorrect_patterns: |
      # INCORRECT: Explicit tools field blocks MCP inheritance
      tools: ["Read", "Write"]  # This BLOCKS MCP tools
```

### MCP Server Configuration
```json
{
  "mcpServers": {
    "elevenlabs": {
      "command": "mcp-server-elevenlabs",
      "args": [],
      "env": {
        "ELEVENLABS_API_KEY": "${ELEVENLABS_API_KEY}"
      }
    },
    "perplexity-ask": {
      "command": "npx",
      "args": ["-y", "@perplexity-ai/mcp-server"],
      "env": {
        "PERPLEXITY_API_KEY": "${PERPLEXITY_API_KEY}"
      }
    }
  }
}
```

### Environment Loading Requirements
```bash
# CRITICAL: Environment variables must be loaded BEFORE Claude Code starts
# MCP servers cannot access environment variables during runtime

# Correct startup sequence:
cd /project/directory
source .env  # Load environment variables first
claude code  # Start with variables already in environment

# Alternative: Use startup script
./start-claude.sh  # Contains proper environment loading sequence
```

---

## 🤖 SUB-AGENT ARCHITECTURE PATTERNS

### Direct Sub-Agent Invocation Pattern
```yaml
correct_invocation_pattern:
  main_orchestrator: "Claude Code session coordinates overall workflow"
  specialized_agents: "Domain-specific agents with full MCP tool inheritance"
  invocation_syntax: |
    Use the [agent-name] agent to [action]: "specific requirements"

  example_usage: |
    Use the research-deep-dive agent to research AI optimization:
    "Comprehensive analysis of cost optimization strategies for AI podcast production"
```

### Agent Configuration Standards
```yaml
agent_yaml_structure:
  correct_configuration: |
    # .claude/agents/research-deep-dive.md
    ```yaml
    subagent_type: research-deep-dive
    description: Comprehensive research with MCP tool access
    # Omit 'tools' field to inherit all MCP tools
    ```

  mcp_tool_access: |
    # Agent can use all configured MCP tools:
    # - mcp__perplexity-ask__perplexity_ask
    # - mcp__elevenlabs__text_to_speech
    # - mcp__elevenlabs__check_subscription
    # - All other configured MCP tools
```

### Multi-Agent Orchestration
```yaml
orchestration_patterns:
  sequential_processing:
    pattern: "Agent A → Process → Agent B → Process → Agent C"
    use_case: "Research → Script → Audio → Quality validation"
    implementation: "Task tool invocation with result passing"

  parallel_processing:
    pattern: "Multiple agents processing simultaneously"
    use_case: "Concurrent research on different aspects"
    implementation: "Multiple Task tool invocations in single message"

  consensus_systems:
    pattern: "Multiple agents evaluate same content"
    use_case: "Three-evaluator quality consensus (Claude, Gemini, Perplexity)"
    implementation: "Parallel evaluation with result synthesis"
```

---

## 🚨 MCP TROUBLESHOOTING FRAMEWORK

### Common MCP Issues and Solutions
```yaml
mcp_troubleshooting:
  issue_1_invalid_api_key:
    symptoms: "MCP tools return 'invalid_api_key' despite valid keys"
    root_cause: "Environment variables not loaded before Claude Code startup"
    solution: "Use ./start-claude.sh or source .env before claude code"
    validation: "mcp__elevenlabs__check_subscription should return data"

  issue_2_tool_not_found:
    symptoms: "MCP tools not available in sub-agents"
    root_cause: "Explicit tools field in agent YAML blocks inheritance"
    solution: "Remove tools field from agent configuration"
    validation: "Agent should access all configured MCP tools"

  issue_3_connection_failures:
    symptoms: "MCP server connection timeouts or failures"
    root_cause: "Server configuration or network issues"
    solution: "Verify .mcp.json configuration and server availability"
    validation: "/mcp command should show all servers connected"
```

### Diagnostic Workflow
```bash
#!/bin/bash
# MCP Diagnostic Script

echo "=== MCP Integration Diagnostics ==="

# Step 1: Check MCP server status
echo "1. MCP Server Status:"
echo "Run in Claude: /mcp"
echo "Expected: All configured servers show 'connected'"

# Step 2: Test direct MCP access
echo "2. Direct MCP Tool Test:"
echo "Run: mcp__elevenlabs__check_subscription"
echo "Expected: Subscription data returned (not 401 error)"

# Step 3: Test sub-agent MCP inheritance
echo "3. Sub-Agent MCP Test:"
echo "Use Task tool with agent requiring MCP access"
echo "Expected: Agent can access inherited MCP tools"

# Step 4: Environment validation
echo "4. Environment Check:"
if [[ -f .env ]]; then
    echo "✅ .env file exists"
    source .env
    echo "ELEVENLABS_API_KEY: $([ ! -z "$ELEVENLABS_API_KEY" ] && echo 'LOADED' || echo 'MISSING')"
    echo "PERPLEXITY_API_KEY: $([ ! -z "$PERPLEXITY_API_KEY" ] && echo 'LOADED' || echo 'MISSING')"
else
    echo "❌ .env file missing"
fi
```

---

## 🏗️ PRODUCTION INTEGRATION PATTERNS

### Episode Production Workflow
```yaml
production_mcp_integration:
  phase_1_research:
    agents: "question-generator, research-discovery, research-deep-dive"
    mcp_tools: "perplexity-ask for comprehensive research"
    pattern: "Sequential agent invocation with MCP tool inheritance"

  phase_2_script_development:
    agents: "episode-planner, script-writer, script-polisher"
    mcp_tools: "Perplexity for fact verification, research validation"
    pattern: "Collaborative script development with research access"

  phase_3_audio_production:
    agents: "optimizer, synthesizer, audio-validator"
    mcp_tools: "ElevenLabs for audio synthesis and validation"
    pattern: "Audio production pipeline with quality validation"
```

### Quality Assurance Integration
```yaml
quality_mcp_integration:
  three_evaluator_consensus:
    claude_evaluation: "Native Claude analysis and scoring"
    gemini_evaluation: "MCP Gemini integration for technical analysis"
    perplexity_evaluation: "MCP Perplexity for fact verification"
    synthesis: "Consensus building across all evaluations"

  automated_validation:
    stt_validation: "ElevenLabs MCP STT for audio quality validation"
    content_analysis: "Perplexity MCP for content accuracy verification"
    brand_consistency: "Claude analysis with MCP research support"
```

---

## 📋 AGENT CONFIGURATION VALIDATION

### Configuration Validation Script
```python
#!/usr/bin/env python3
"""Agent Configuration Validator"""

import yaml
import os
import glob

def validate_agent_configurations():
    """Validate all agent YAML configurations for MCP compatibility"""

    agent_dir = ".claude/agents/"
    issues = []

    for agent_file in glob.glob(f"{agent_dir}*.md"):
        with open(agent_file, 'r') as f:
            content = f.read()

        # Extract YAML from markdown
        if '```yaml' in content:
            yaml_start = content.find('```yaml') + 7
            yaml_end = content.find('```', yaml_start)
            yaml_content = content[yaml_start:yaml_end].strip()

            try:
                config = yaml.safe_load(yaml_content)

                # Check for MCP-blocking configurations
                if 'tools' in config:
                    issues.append(f"{agent_file}: Explicit 'tools' field blocks MCP inheritance")

                # Validate required fields
                if 'subagent_type' not in config:
                    issues.append(f"{agent_file}: Missing 'subagent_type' field")

            except yaml.YAMLError as e:
                issues.append(f"{agent_file}: YAML syntax error - {e}")

    return issues

def main():
    issues = validate_agent_configurations()

    if issues:
        print("❌ Agent Configuration Issues Found:")
        for issue in issues:
            print(f"  - {issue}")
        return 1
    else:
        print("✅ All agent configurations valid for MCP inheritance")
        return 0

if __name__ == "__main__":
    exit(main())
```

---

## 🎯 BEST PRACTICES & OPTIMIZATION

### MCP Integration Best Practices
```yaml
mcp_best_practices:
  configuration_management:
    environment_loading: "Always load environment before Claude Code startup"
    agent_yaml_structure: "Omit tools field for MCP inheritance"
    server_configuration: "Use proper .mcp.json with environment variables"

  error_handling:
    graceful_degradation: "Fallback mechanisms when MCP tools unavailable"
    retry_logic: "Exponential backoff for transient MCP failures"
    error_reporting: "Clear error messages for MCP configuration issues"

  performance_optimization:
    connection_pooling: "Reuse MCP connections across sub-agent invocations"
    rate_limiting: "Respect API limits for MCP-integrated tools"
    caching: "Cache MCP results where appropriate to reduce API calls"
```

### Production Deployment Considerations
```yaml
production_deployment:
  environment_setup:
    startup_scripts: "Use ./start-claude.sh for consistent environment loading"
    configuration_validation: "Validate MCP setup before production use"
    monitoring: "Monitor MCP server health and connectivity"

  scalability_factors:
    concurrent_agents: "Manage concurrent sub-agent invocations"
    resource_limits: "Monitor API usage across all MCP integrations"
    error_recovery: "Implement robust error recovery for MCP failures"
```

This consolidated framework provides complete understanding and implementation guidance for Claude Code MCP integration and sub-agent coordination in production environments.
