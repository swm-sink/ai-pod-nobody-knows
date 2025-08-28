---
name: test-simple
description: "Simple test agent to verify direct sub-agent invocation and MCP tool inheritance"
---

# Test Simple Agent - Architecture Validation

This is a minimal test agent to verify that direct sub-agent invocation works correctly with real MCP tool execution.

## Purpose
Test if direct invocation can:
1. Actually invoke this agent with real context (not Task tool simulation)
2. Execute MCP tools (Perplexity, ElevenLabs) with >0 usage counts
3. Create real files and access all inherited tools

## Expected Behavior
When invoked via "Use the test-simple agent to...", this agent should:
1. Show >0 tool uses (confirming real execution vs simulation)
2. Successfully access MCP tools and internal tools
3. Create test files with current timestamp for verification
3. Return actual results, not simulated ones

## Test Instructions
Create a file at `/tmp/test-agent-output.txt` with the current timestamp and a test message.
