#!/bin/bash
# AI Podcast System - MCP Setup Script
# Configures Model Context Protocol servers for the podcast system

set -e  # Exit on error

echo "🚀 AI Podcast System - MCP Setup"
echo "=================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "   Please create .env file with your API keys first."
    echo "   Copy .env.example to .env and fill in your keys."
    exit 1
fi

# Source environment variables
echo "📋 Loading environment variables..."
source .env

# Verify required API keys
missing_keys=()

if [ -z "$ELEVENLABS_API_KEY" ] || [ "$ELEVENLABS_API_KEY" = "your-elevenlabs-api-key-here" ]; then  # pragma: allowlist secret
    missing_keys+=("ELEVENLABS_API_KEY")
fi

if [ -z "$PERPLEXITY_API_KEY" ] || [ "$PERPLEXITY_API_KEY" = "pplx-your-perplexity-api-key-here" ]; then  # pragma: allowlist secret
    missing_keys+=("PERPLEXITY_API_KEY")
fi

if [ ${#missing_keys[@]} -gt 0 ]; then
    echo "❌ Missing required API keys:"
    for key in "${missing_keys[@]}"; do
        echo "   - $key"
    done
    echo ""
    echo "Please update your .env file with valid API keys."
    exit 1
fi

echo "✅ API keys found"

# Function to check if MCP server is already configured
check_mcp_server() {
    local server_name=$1
    if claude mcp list 2>/dev/null | grep -q "$server_name"; then
        return 0  # Server exists
    else
        return 1  # Server doesn't exist
    fi
}

# Configure Perplexity MCP Server
echo ""
echo "🔍 Configuring Perplexity MCP Server..."
if check_mcp_server "perplexity"; then
    echo "   ℹ️  Perplexity MCP server already configured"
else
    echo "   📦 Adding Perplexity MCP server..."
    claude mcp add perplexity-ask '{
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-perplexity"],
        "env": {
            "PERPLEXITY_API_KEY": "'$PERPLEXITY_API_KEY'"
        }
    }'
    echo "   ✅ Perplexity MCP server configured"
fi

# Configure ElevenLabs MCP Server
echo ""
echo "🎵 Configuring ElevenLabs MCP Server..."
if check_mcp_server "elevenlabs"; then
    echo "   ℹ️  ElevenLabs MCP server already configured"
else
    echo "   📦 Adding ElevenLabs MCP server..."
    claude mcp add elevenlabs '{
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-elevenlabs"],
        "env": {
            "ELEVENLABS_API_KEY": "'$ELEVENLABS_API_KEY'"
        }
    }'
    echo "   ✅ ElevenLabs MCP server configured"
fi

# Test MCP connections
echo ""
echo "🧪 Testing MCP connections..."
echo "   Listing configured MCP servers:"
claude mcp list

echo ""
echo "🎉 MCP Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Restart Claude Code to load the new MCP servers"
echo "2. Run ./test-mcp-connections.sh to verify everything works"
echo "3. Try creating your first episode: /podcast 'Your Topic'"
echo ""
echo "Happy podcasting! 🎙️"
