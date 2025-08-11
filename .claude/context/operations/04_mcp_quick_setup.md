<document type="quick-setup-guide" id="04">
  <metadata>
    <title>MCP Quick Setup Guide - Get Connected Fast</title>
    <created>2025-08-11</created>
    <requires-approval>false</requires-approval>
    <validation-status>setup-verified-2025</validation-status>
    <enhanced-version>claude-code-mcp-integrated</enhanced-version>
  </metadata>

# MCP Quick Setup Guide - Connect Your AI to External Services 🔌

**Technical Explanation**: This guide covers Model Context Protocol (MCP) server setup, including API key management, environment configuration, and connection troubleshooting for Claude Code's external service integrations.

**Simple Breakdown**: Think of this as your "quick connect" guide - like setting up a new smart TV to connect to streaming services. You need the right passwords (API keys), the right connections (environment setup), and a way to test everything works.

## 🚀 Quick Start (5 Minutes)

### Step 1: Get Your API Keys

**Where to get them:**
- **Perplexity**: https://www.perplexity.ai/settings/api
- **ElevenLabs**: https://elevenlabs.io/api-keys
- **GitHub**: https://github.com/settings/tokens

### Step 2: Create Your .env File

```bash
# Create .env file in project root
cat > .env << 'EOF'
# AI Podcast Production API Keys
PERPLEXITY_API_KEY=pplx-YOUR-KEY-HERE
ELEVENLABS_API_KEY=sk_YOUR-KEY-HERE
GITHUB_TOKEN=ghp_YOUR-TOKEN-HERE
EOF
```

**⚠️ IMPORTANT**: Never commit .env to git! It's already in .gitignore.

### Step 3: Create Startup Script

```bash
# Create start-claude.sh
cat > start-claude.sh << 'EOF'
#!/bin/bash
# Start Claude Code with proper environment

# Color output for clarity
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🚀 Starting Claude Code with MCP servers..."

# Load environment variables
if [ -f .env ]; then
    source .env
    echo -e "${GREEN}✓ Environment loaded from .env${NC}"
    
    # Verify critical keys
    if [ -n "$PERPLEXITY_API_KEY" ]; then
        echo -e "${GREEN}✓ Perplexity API key loaded${NC}"
    else
        echo -e "${RED}✗ Perplexity API key missing${NC}"
    fi
    
    if [ -n "$ELEVENLABS_API_KEY" ]; then
        echo -e "${GREEN}✓ ElevenLabs API key loaded${NC}"
    else
        echo -e "${RED}✗ ElevenLabs API key missing${NC}"
    fi
else
    echo -e "${RED}✗ .env file not found!${NC}"
    echo "Please create .env file with your API keys"
    exit 1
fi

# Start Claude Code
echo "Starting Claude Code..."
claude
EOF

chmod +x start-claude.sh
```

### Step 4: Configure MCP Servers

```bash
# Start Claude with proper environment
./start-claude.sh

# Once Claude is running, configure MCP servers
# (Run these commands inside Claude Code)
```

Inside Claude Code:
```bash
# Add Perplexity for research
claude mcp add-json perplexity '{
  "command": "node",
  "args": [".claude/mcp-servers/perplexity-mcp/perplexity-ask/dist/index.js"],
  "env": {"PERPLEXITY_API_KEY": "'$PERPLEXITY_API_KEY'"}
}'

# Add ElevenLabs for audio
claude mcp add-json elevenlabs '{
  "command": "python3",
  "args": ["-m", "elevenlabs_mcp"],
  "env": {"ELEVENLABS_API_KEY": "'$ELEVENLABS_API_KEY'"}
}'

# Check status
claude mcp list
```

### Step 5: Verify Everything Works

```bash
# Inside Claude Code, test the connections
/mcp

# You should see:
# elevenlabs: ✓ Connected
# perplexity: ✓ Connected
```

## 🔧 Detailed Setup Instructions

### Understanding the Three Layers

**Technical Explanation**: MCP setup involves three configuration layers: file storage (.env), shell environment (export), and subprocess environment (MCP server context).

**Simple Breakdown**: It's like a relay race with three runners:
1. **Runner 1** (.env file): Holds the baton (API keys)
2. **Runner 2** (your shell): Takes the baton when you `source .env`
3. **Runner 3** (MCP servers): Gets the baton when Claude starts them

### API Key Management Best Practices

#### Option 1: Project-Specific (.env file) - RECOMMENDED

**Pros:**
- Keys stay with project
- Easy to update
- Never accidentally committed (if in .gitignore)
- Different keys for different projects

**Setup:**
```bash
# 1. Create .env file with your keys
nano .env  # or your preferred editor

# 2. Add your keys:
PERPLEXITY_API_KEY=pplx-abc123...
ELEVENLABS_API_KEY=sk_def456...

# 3. Always start Claude with:
./start-claude.sh
```

#### Option 2: Shell Profile (~/.zshrc or ~/.bash_profile)

**Pros:**
- Keys always available
- Works across all projects
- No need for startup script

**Cons:**
- Same keys for all projects
- Risk of exposing in screenshots/recordings

**Setup:**
```bash
# Add to ~/.zshrc or ~/.bash_profile
echo 'export PERPLEXITY_API_KEY="your-key"' >> ~/.zshrc
echo 'export ELEVENLABS_API_KEY="your-key"' >> ~/.zshrc
source ~/.zshrc

# Then just run:
claude
```

#### Option 3: Session-Only (temporary)

**Pros:**
- Most secure (gone when terminal closes)
- Good for testing

**Cons:**
- Must re-enter every session

**Setup:**
```bash
# Set for current session only
export PERPLEXITY_API_KEY="your-key"
export ELEVENLABS_API_KEY="your-key"
claude
```

## 🔍 Troubleshooting Common Issues

### Issue 1: "Failed to connect" Even With Keys Set

**Symptom:**
```
/mcp
⎿ Failed to reconnect to elevenlabs.
⎿ Failed to reconnect to perplexity.
```

**Diagnosis:**
```bash
# Check if keys are in environment
echo "Perplexity length: ${#PERPLEXITY_API_KEY}"
echo "ElevenLabs length: ${#ELEVENLABS_API_KEY}"

# If length is 0, keys are empty
# If "unbound variable", keys don't exist
```

**Fix:**
1. Exit Claude Code (Ctrl+C)
2. Source your .env file: `source .env`
3. Restart with: `./start-claude.sh`

### Issue 2: "API Key Invalid" Errors

**Diagnosis:**
```bash
# Test Perplexity key directly
curl -X POST "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"sonar","messages":[{"role":"user","content":"test"}]}'

# If you get an auth error, key is wrong
```

**Fix:**
1. Double-check key from provider's website
2. Ensure no extra spaces or quotes in .env
3. Make sure key hasn't expired

### Issue 3: MCP Server Path Not Found

**Symptom:**
```
Error: Cannot find module '/path/to/index.js'
```

**Fix:**
```bash
# Find the correct path
find . -name "perplexity-mcp" -type d
find . -name "index.js" | grep perplexity

# Update MCP configuration with absolute path
claude mcp remove perplexity
claude mcp add-json perplexity '{
  "command": "node",
  "args": ["/absolute/path/to/index.js"],
  "env": {"PERPLEXITY_API_KEY": "'$PERPLEXITY_API_KEY'"}
}'
```

## 📋 Complete Setup Checklist

- [ ] API keys obtained from providers
- [ ] .env file created with keys
- [ ] .env added to .gitignore
- [ ] start-claude.sh script created and executable
- [ ] Claude Code started with script
- [ ] MCP servers configured with claude mcp add-json
- [ ] Connection verified with /mcp command
- [ ] Test query successful

## 🎯 Quick Commands Reference

```bash
# Start Claude with environment
./start-claude.sh

# Check MCP status (inside Claude)
/mcp
claude mcp list

# Remove and re-add MCP server
claude mcp remove perplexity
claude mcp add-json perplexity '...'

# Test environment variables
echo "Keys loaded: P:${#PERPLEXITY_API_KEY} E:${#ELEVENLABS_API_KEY}"

# Emergency reset
claude mcp remove elevenlabs
claude mcp remove perplexity
source .env
# Then re-add servers
```

## 💡 Pro Tips

1. **Always use the startup script** - It ensures consistent environment
2. **Keep .env.example updated** - Shows others what keys are needed
3. **Test after updates** - Run /mcp after any configuration change
4. **Use absolute paths** - Prevents "file not found" errors
5. **Check key expiration** - Some API keys expire; rotate regularly

## 🔗 Related Documentation

- **Troubleshooting**: `.claude/context/operations/01_troubleshooting_guide.md`
- **Full MCP Guide**: `.claude/context/claude-code/21_mcp_integration_guide.md`
- **Perplexity Setup**: `.claude/mcp-servers/perplexity-mcp/README.md`
- **ElevenLabs Setup**: `.claude/mcp-servers/elevenlabs-mcp/README.md`

---

**Remember**: The most common issue is forgetting to load the environment variables before starting Claude. When in doubt, exit Claude, run `./start-claude.sh`, and try again!
</document>