#!/bin/bash
# AI Podcast System - MCP Connection Test Script
# Validates that all MCP servers are properly configured and working

set -e

echo "🧪 AI Podcast System - MCP Connection Test"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test result
print_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"

    if [ "$result" = "PASS" ]; then
        echo -e "✅ ${GREEN}PASS${NC}: $test_name"
        if [ -n "$message" ]; then
            echo "   $message"
        fi
        ((TESTS_PASSED++))
    else
        echo -e "❌ ${RED}FAIL${NC}: $test_name"
        if [ -n "$message" ]; then
            echo "   $message"
        fi
        ((TESTS_FAILED++))
    fi
    echo
}

# Test 1: Check if .env file exists
echo "🔍 Test 1: Environment Configuration"
if [ -f .env ]; then
    source .env
    print_result "Environment file exists" "PASS" "Found .env file"
else
    print_result "Environment file exists" "FAIL" "No .env file found. Please create one first."
    exit 1
fi

# Test 2: Check required API keys
echo "🔑 Test 2: API Key Configuration"
missing_keys=()

if [ -z "$ELEVENLABS_API_KEY" ] || [ "$ELEVENLABS_API_KEY" = "your-elevenlabs-api-key-here" ]; then  # pragma: allowlist secret
    missing_keys+=("ELEVENLABS_API_KEY")
fi

if [ -z "$PERPLEXITY_API_KEY" ] || [ "$PERPLEXITY_API_KEY" = "pplx-your-perplexity-api-key-here" ]; then  # pragma: allowlist secret
    missing_keys+=("PERPLEXITY_API_KEY")
fi

if [ ${#missing_keys[@]} -eq 0 ]; then
    print_result "API keys configured" "PASS" "All required API keys found"
else
    key_list=$(IFS=', '; echo "${missing_keys[*]}")
    print_result "API keys configured" "FAIL" "Missing keys: $key_list"
fi

# Test 3: Check MCP server configuration
echo "🔧 Test 3: MCP Server Configuration"
if command -v claude >/dev/null 2>&1; then
    print_result "Claude CLI available" "PASS" "Claude command line tool found"

    # List MCP servers
    echo "   Checking MCP server configuration..."
    if claude mcp list >/dev/null 2>&1; then
        mcp_output=$(claude mcp list 2>/dev/null)
        echo "   MCP Servers:"
        echo "$mcp_output" | sed 's/^/     /'

        # Check for specific servers
        if echo "$mcp_output" | grep -q "perplexity\|elevenlabs"; then
            print_result "MCP servers configured" "PASS" "Found MCP servers"
        else
            print_result "MCP servers configured" "FAIL" "No podcast-related MCP servers found"
        fi
    else
        print_result "MCP servers accessible" "FAIL" "Cannot access MCP configuration"
    fi
else
    print_result "Claude CLI available" "FAIL" "Claude command not found. Please install Claude Code."
fi

# Test 4: Test Perplexity API directly
echo "🔍 Test 4: Perplexity API Connection"
if [ -n "$PERPLEXITY_API_KEY" ] && [ "$PERPLEXITY_API_KEY" != "pplx-your-perplexity-api-key-here" ]; then
    echo "   Testing Perplexity API connection..."
    if curl -s -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
            -H "Content-Type: application/json" \
            https://api.perplexity.ai/chat/completions >/dev/null 2>&1; then
        print_result "Perplexity API connection" "PASS" "API key works"
    else
        print_result "Perplexity API connection" "FAIL" "API connection failed - check key validity"
    fi
else
    print_result "Perplexity API connection" "FAIL" "API key not configured"
fi

# Test 5: Test ElevenLabs API directly
echo "🎵 Test 5: ElevenLabs API Connection"
if [ -n "$ELEVENLABS_API_KEY" ] && [ "$ELEVENLABS_API_KEY" != "your-elevenlabs-api-key-here" ]; then
    echo "   Testing ElevenLabs API connection..."
    if curl -s -H "xi-api-key: $ELEVENLABS_API_KEY" \
            https://api.elevenlabs.io/v1/models >/dev/null 2>&1; then
        print_result "ElevenLabs API connection" "PASS" "API key works"
    else
        print_result "ElevenLabs API connection" "FAIL" "API connection failed - check key validity"
    fi
else
    print_result "ElevenLabs API connection" "FAIL" "API key not configured"
fi

# Test 6: Check voice configuration
echo "🎤 Test 6: Voice Configuration"
expected_voice_id="ZF6FPAbjXT4488VcRRnw"
if [ -n "$PRODUCTION_VOICE_ID" ] && [ "$PRODUCTION_VOICE_ID" = "$expected_voice_id" ]; then
    print_result "Production voice ID" "PASS" "Correct Amelia voice configured"
else
    print_result "Production voice ID" "FAIL" "Voice ID mismatch or not configured"
fi

# Test 7: Check basic file structure
echo "📁 Test 7: File Structure"
required_dirs=(".claude/agents/simplified" ".claude/commands/simplified" ".claude/hooks/simplified")
missing_dirs=()

for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        missing_dirs+=("$dir")
    fi
done

if [ ${#missing_dirs[@]} -eq 0 ]; then
    print_result "Required directories" "PASS" "All required directories found"
else
    dir_list=$(IFS=', '; echo "${missing_dirs[*]}")
    print_result "Required directories" "FAIL" "Missing directories: $dir_list"
fi

# Final results
echo "======================================"
echo "📊 Test Results Summary"
echo "======================================"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests:  $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "🎉 ${GREEN}All tests passed!${NC}"
    echo "Your AI Podcast System is ready for use."
    echo ""
    echo "Next steps:"
    echo "1. Try creating your first episode:"
    echo "   /podcast 'Your Topic Here'"
    echo ""
    echo "2. Check system status anytime with:"
    echo "   /status"
else
    echo ""
    echo -e "⚠️  ${YELLOW}Some tests failed.${NC}"
    echo "Please fix the issues above before using the system."
    echo ""
    echo "Common fixes:"
    echo "1. Run ./setup-mcp.sh to configure MCP servers"
    echo "2. Check your .env file has valid API keys"
    echo "3. Restart Claude Code after configuration changes"
    exit 1
fi
