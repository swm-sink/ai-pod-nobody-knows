#!/bin/bash
# AI Podcast System - Configuration Validator
# Validates all configuration files and settings for consistency

set -e

echo "🔍 AI Podcast System - Configuration Validator"
echo "==============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to print validation result
validate() {
    local item="$1"
    local status="$2"
    local message="$3"
    
    case $status in
        "OK")
            echo -e "✅ ${GREEN}OK${NC}    $item"
            ;;
        "WARN")
            echo -e "⚠️  ${YELLOW}WARN${NC}  $item"
            if [ -n "$message" ]; then
                echo "       $message"
            fi
            ((WARNINGS++))
            ;;
        "ERROR")
            echo -e "❌ ${RED}ERROR${NC} $item"
            if [ -n "$message" ]; then
                echo "       $message"
            fi
            ((ERRORS++))
            ;;
    esac
}

echo "📋 Checking Core Configuration Files..."
echo

# Check .env file
if [ -f .env ]; then
    validate ".env file exists" "OK"
    
    # Source and check required variables
    source .env
    
    if [ -n "$ELEVENLABS_API_KEY" ] && [ "$ELEVENLABS_API_KEY" != "your-elevenlabs-api-key-here" ]; then
        validate "ElevenLabs API key configured" "OK"
    else
        validate "ElevenLabs API key configured" "ERROR" "Missing or placeholder value"
    fi
    
    if [ -n "$PERPLEXITY_API_KEY" ] && [ "$PERPLEXITY_API_KEY" != "pplx-your-perplexity-api-key-here" ]; then
        validate "Perplexity API key configured" "OK"
    else
        validate "Perplexity API key configured" "ERROR" "Missing or placeholder value"
    fi
    
    if [ -n "$PRODUCTION_VOICE_ID" ] && [ "$PRODUCTION_VOICE_ID" = "ZF6FPAbjXT4488VcRRnw" ]; then
        validate "Production voice ID correct" "OK"
    else
        validate "Production voice ID correct" "ERROR" "Must be ZF6FPAbjXT4488VcRRnw"
    fi
    
else
    validate ".env file exists" "ERROR" "Create .env file from .env.example"
fi

echo
echo "🎤 Checking Voice Configuration..."

# Check production voice configuration
if [ -f .claude/config/production-voice.json ]; then
    validate "Production voice config exists" "OK"
    
    # Parse JSON and check voice ID
    if command -v jq >/dev/null 2>&1; then
        voice_id=$(jq -r '.production_voice.voice_id' .claude/config/production-voice.json 2>/dev/null)
        if [ "$voice_id" = "ZF6FPAbjXT4488VcRRnw" ]; then
            validate "Voice ID in JSON matches standard" "OK"
        else
            validate "Voice ID in JSON matches standard" "ERROR" "Voice ID mismatch: $voice_id"
        fi
        
        voice_name=$(jq -r '.production_voice.voice_name' .claude/config/production-voice.json 2>/dev/null)
        if [ "$voice_name" = "Amelia" ]; then
            validate "Voice name is correct" "OK"
        else
            validate "Voice name is correct" "WARN" "Expected 'Amelia', got '$voice_name'"
        fi
    else
        validate "jq available for JSON parsing" "WARN" "Install jq for better JSON validation"
    fi
else
    validate "Production voice config exists" "ERROR" "Missing .claude/config/production-voice.json"
fi

echo
echo "🏗️ Checking Project Structure..."

# Check required directories
required_dirs=(
    ".claude"
    ".claude/agents/simplified"
    ".claude/commands/simplified"
    ".claude/hooks/simplified"
    ".claude/context/simplified"
    ".claude/config"
    "episodes"
    "sessions"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        validate "Directory $dir" "OK"
    else
        validate "Directory $dir" "ERROR" "Required directory missing"
    fi
done

# Check critical files
critical_files=(
    ".claude/settings.json"
    ".claude/config/production-voice.json"
    "CLAUDE.md"
    "README.md"
    "setup-mcp.sh"
    "test-mcp-connections.sh"
)

for file in "${critical_files[@]}"; do
    if [ -f "$file" ]; then
        validate "File $file" "OK"
    else
        validate "File $file" "ERROR" "Critical file missing"
    fi
done

echo
echo "🤖 Checking Simplified Agents..."

# Check simplified agents
agent_files=(
    ".claude/agents/simplified/researcher.md"
    ".claude/agents/simplified/fact-checker.md" 
    ".claude/agents/simplified/synthesizer.md"
    ".claude/agents/simplified/writer.md"
    ".claude/agents/simplified/polisher.md"
    ".claude/agents/simplified/judge.md"
    ".claude/agents/simplified/audio-producer.md"
    ".claude/agents/simplified/audio-validator.md"
    ".claude/agents/simplified/batch-processor.md"
    ".claude/agents/simplified/cost-monitor.md"
)

for file in "${agent_files[@]}"; do
    if [ -f "$file" ]; then
        validate "Agent $(basename "$file" .md)" "OK"
    else
        validate "Agent $(basename "$file" .md)" "WARN" "Agent file missing: $file"
    fi
done

echo
echo "⚙️ Checking Simplified Commands..."

# Check simplified commands
command_files=(
    ".claude/commands/simplified/podcast-workflow.md"
    ".claude/commands/simplified/research-workflow.md"
    ".claude/commands/simplified/production-workflow.md"
    ".claude/commands/simplified/audio-workflow.md"
    ".claude/commands/simplified/meta-chain.md"
)

for file in "${command_files[@]}"; do
    if [ -f "$file" ]; then
        validate "Command $(basename "$file" .md)" "OK"
    else
        validate "Command $(basename "$file" .md)" "WARN" "Command file missing: $file"
    fi
done

echo
echo "🪝 Checking Simplified Hooks..."

# Check simplified hooks
hook_files=(
    ".claude/hooks/simplified/pre-tool-validation.sh"
    ".claude/hooks/simplified/post-tool-tracking.sh"
    ".claude/hooks/simplified/session-lifecycle.sh"
    ".claude/hooks/error-recovery.sh"
)

for file in "${hook_files[@]}"; do
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            validate "Hook $(basename "$file" .sh)" "OK"
        else
            validate "Hook $(basename "$file" .sh)" "WARN" "Hook file not executable"
        fi
    else
        validate "Hook $(basename "$file" .sh)" "ERROR" "Hook file missing: $file"
    fi
done

echo
echo "📚 Checking Context Files..."

# Check simplified context files
context_files=(
    ".claude/context/simplified/workflow.md"
    ".claude/context/simplified/agents.md"
    ".claude/context/simplified/quality.md"
    ".claude/context/simplified/troubleshooting.md"
    ".claude/context/simplified/CONTEXT_INDEX.md"
)

for file in "${context_files[@]}"; do
    if [ -f "$file" ]; then
        validate "Context $(basename "$file" .md)" "OK"
    else
        validate "Context $(basename "$file" .md)" "WARN" "Context file missing: $file"
    fi
done

echo
echo "🧹 Checking for Legacy Files..."

# Check for files that should have been cleaned up
legacy_patterns=(
    ".claude/agents/enhanced-*"
    ".claude/commands/enhanced-*"
    ".claude/hooks/enhanced-*"
    "**/archive/**"
    ".claude/governance/**"
    ".claude/systems/**"
    ".claude/templates/**"
    ".claude/workflows/**"
)

legacy_found=0
for pattern in "${legacy_patterns[@]}"; do
    if compgen -G "$pattern" > /dev/null 2>&1; then
        legacy_found=1
        validate "No legacy files ($pattern)" "WARN" "Legacy files found, consider cleanup"
    fi
done

if [ $legacy_found -eq 0 ]; then
    validate "Legacy file cleanup" "OK"
fi

echo
echo "==============================================="
echo "📊 Configuration Validation Summary"
echo "==============================================="
echo -e "Errors:   ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "\n🎉 ${GREEN}Perfect configuration!${NC}"
        echo "Your AI Podcast System is properly configured."
    else
        echo -e "\n✅ ${GREEN}Configuration valid${NC} (with warnings)"
        echo "System will work but consider addressing warnings."
    fi
    echo ""
    echo "Ready to use:"
    echo "- Run ./test-mcp-connections.sh to test MCP setup"
    echo "- Create your first episode with: /podcast 'Your Topic'"
    exit 0
else
    echo -e "\n❌ ${RED}Configuration has errors${NC}"
    echo "Please fix the errors above before using the system."
    echo ""
    echo "Common fixes:"
    echo "- Create or update .env file with valid API keys"
    echo "- Run ./setup-mcp.sh to restore missing files"
    echo "- Check file permissions for hooks"
    exit 1
fi
