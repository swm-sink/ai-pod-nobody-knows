#!/bin/bash
# This script loads environment variables and starts Claude Code with MCP servers

# Load environment variables from .env if it exists
if [ -f .env ]; then
    echo "Loading API keys from .env file..."
    # Source the .env file to load variables
    source .env
    
    # Verify keys are loaded
    if [ -n "$PERPLEXITY_API_KEY" ]; then
        echo "✓ Perplexity API key loaded"
    else
        echo "✗ Perplexity API key not found in .env"
    fi
    
    if [ -n "$ELEVENLABS_API_KEY" ]; then
        echo "✓ ElevenLabs API key loaded"
    else
        echo "✗ ElevenLabs API key not found in .env"
    fi
else
    echo "Warning: .env file not found. MCP servers may not connect."
    echo "Copy .env.example to .env and add your API keys."
    exit 1
fi

# Start Claude Code
echo "Starting Claude Code with MCP servers..."
claude