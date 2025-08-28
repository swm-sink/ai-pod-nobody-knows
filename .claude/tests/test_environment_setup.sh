#!/bin/bash
# Environment Setup Test - Validates proper Claude Code startup with environment loading

echo "=== Environment Setup Test ==="

# Test 1: Check .env file exists
echo "Test 1: .env file existence"
if [ -f /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.env ]; then
    echo "✅ .env file exists"
else
    echo "❌ .env file not found"
    exit 1
fi

# Test 2: Load environment variables
echo "Test 2: Environment variable loading"
source /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.env

# Test 3: Verify API keys are set
echo "Test 3: API key validation"
if [ ! -z "$ELEVENLABS_API_KEY" ] && [ ${#ELEVENLABS_API_KEY} -gt 20 ]; then
    echo "✅ ELEVENLABS_API_KEY is properly set (length: ${#ELEVENLABS_API_KEY})"
else
    echo "❌ ELEVENLABS_API_KEY is not properly set"
    exit 1
fi

if [ ! -z "$PERPLEXITY_API_KEY" ] && [ ${#PERPLEXITY_API_KEY} -gt 20 ]; then
    echo "✅ PERPLEXITY_API_KEY is properly set (length: ${#PERPLEXITY_API_KEY})"
else
    echo "❌ PERPLEXITY_API_KEY is not properly set"
    exit 1
fi

# Test 4: Check start-claude.sh script
echo "Test 4: Start script validation"
if [ -f /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/start-claude.sh ] && [ -x /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/start-claude.sh ]; then
    echo "✅ start-claude.sh script exists and is executable"
else
    echo "❌ start-claude.sh script issue"
    exit 1
fi

echo "=== All Environment Tests PASSED ==="
echo ""
echo "⚠️  IMPORTANT: To fix MCP connections, restart Claude Code using:"
echo "   ./start-claude.sh"
echo ""
echo "This will properly load environment variables before starting Claude Code."
