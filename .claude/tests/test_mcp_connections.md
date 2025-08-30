# MCP Connection Diagnostics Test

## Test Objective
Verify that all MCP servers (ElevenLabs, Perplexity, GitHub) are properly connected and accessible from Claude Code.

## Test Cases

### TC1.1: ElevenLabs MCP Server Connection
**Expected**: ElevenLabs API calls succeed without authentication errors
**Test Method**: Direct MCP tool invocation
```
WHEN: Direct_API_elevenlabs_check_subscription is called
THEN: Should return subscription data without 401 error
AND: Should show valid API key status
```

### TC1.2: Perplexity MCP Server Connection
**Expected**: Perplexity API accessible for research queries
**Test Method**: Simple query execution
```
WHEN: mcp__perplexity-ask__perplexity_ask is called with test message
THEN: Should return response without authentication failure
AND: Should demonstrate working connection
```

### TC1.3: GitHub MCP Server Connection
**Expected**: GitHub integration functional for repository access
**Test Method**: Repository information retrieval
```
WHEN: GitHub MCP tools are invoked
THEN: Should access repository information successfully
AND: Should authenticate with provided PAT
```

### TC1.4: Voice Configuration Access
**Expected**: Production voice ID accessible and verified
**Test Method**: Voice metadata retrieval
```
WHEN: Production voice ID ZF6FPAbjXT4488VcRRnw is queried
THEN: Should return voice metadata successfully
AND: Should match production configuration
```

## Current Status: EXPECTED TO FAIL
- ElevenLabs connection currently returns 401 authentication errors
- Need to resolve MCP environment variable propagation
- May require Claude Code restart with proper environment loading

## Success Criteria
- [ ] All MCP servers respond successfully
- [ ] No 401 authentication errors
- [ ] Production voice accessible
- [ ] Environment variables properly loaded
