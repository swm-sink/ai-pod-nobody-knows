# Environment and API Key Management Guide



## Security approach
Security-First Approach

<technical>
Multi-layered secret management with environment isolation, key rotation policies, and audit trails
</technical>

<simple>
Like having different safes for different valuables - each with its own combination and access log
</simple>

This teaches enterprise-grade security practices essential for production systems

## Configuration structure
Configuration Structure

## Api key management
API Key Management
CRITICAL: API keys must NEVER be stored in documentation or committed to version control.
Store all keys in .env file and reference them via environment variables.
All API keys stored in .env file only
Use environment variables: process.env.KEY_NAME
Never hardcode keys in code or documentation

-
        Generate new key from provider dashboard

-
        Update .env file locally

-
        Test with minimal API call

-
        Update Claude Code MCP config

-
        Archive old key (mark as rotated)

-
        Update team documentation

## Scalability patterns
Scalability Patterns
Single .env file with all keys
Simple setup, quick iteration
All keys in one place
Separate .env files per environment
Environment isolation
More files to manage
Secret management service (AWS Secrets, Vault)
Centralized, audited, rotatable
More complex setup

## Claude code integration
Claude Code MCP Integration

-
        Configure MCP servers in mcp-config.json

-
        Set environment variables in .env

-
        Restart Claude Code to load new config

-
        Verify with claude mcp list

**Example:**
{
"mcpServers": {
"perplexity": {
"command": "node",
"args": ["perplexity-server.js"],
"env": {
"PERPLEXITY_API_KEY": "${PERPLEXITY_API_KEY}"
}
}
}
}


## Best practices
Environment Management Best Practices
Never commit .env files
Always provide .env.example
Use descriptive key names
Document required keys in README
Implement key rotation reminders
Use different keys per environment
Monitor API usage and costs
Set up alerts for unusual activity
MCP Quick Setup Guide
Cost Management
Security Validation

---

*Converted from XML to Markdown for elegant simplicity*
*Original: environment-management.md*
*Conversion: Mon Aug 18 00:01:17 EDT 2025*
