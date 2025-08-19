#!/bin/bash
# This script loads environment variables and starts Claude Code with MCP servers

# Set default environment variables for portability
export PWD="$(pwd)"
export NODE_EXTRA_CA_CERTS="${NODE_EXTRA_CA_CERTS:-/Library/Frameworks/Python.framework/Versions/3.13/lib/python3.13/site-packages/certifi/cacert.pem}"
export CLAUDE_CODE_BUILDER_PATH="${CLAUDE_CODE_BUILDER_PATH:-/Users/smenssink/Documents/GitHub/claude-code-builder}"

# Load environment variables from .env if it exists
if [ -f .env ]; then
    echo "Loading API keys from .env file..."
    # Load .env safely without exporting unrelated variables
    set -a
    source .env
    set +a

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
    echo "Create one quickly with:\n  cp .env.example .env && $EDITOR .env"
    exit 1
fi

# Start Claude Code
echo "Starting Claude Code with MCP servers..."
claude
exit $?
