#!/bin/bash
# Start Claude Code with proper environment variables loaded

# Load environment variables
if [ -f .env ]; then
    source .env
    echo "✅ Environment variables loaded from .env"
else
    echo "❌ .env file not found"
    exit 1
fi

# Verify key variables are set
if [ -z "$ELEVENLABS_API_KEY" ]; then
    echo "❌ ELEVENLABS_API_KEY not set"
    exit 1
fi

if [ -z "$PERPLEXITY_API_KEY" ]; then
    echo "❌ PERPLEXITY_API_KEY not set"
    exit 1
fi

echo "✅ All required API keys are set"
echo "🚀 Starting Claude Code..."

# Start Claude Code
claude code
