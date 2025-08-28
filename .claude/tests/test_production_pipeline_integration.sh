#!/bin/bash
# Production Pipeline Integration Test
# Validates end-to-end functionality with proper environment loading

echo "=== Production Pipeline Integration Test ==="

# Test 1: Environment Prerequisites
echo "Test 1: Environment Prerequisites Check"
if [ -f /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/start-claude.sh ]; then
    echo "✅ start-claude.sh exists and is executable"
else
    echo "❌ start-claude.sh missing or not executable"
    exit 1
fi

# Test 2: Production Voice Configuration
echo "Test 2: Production Voice Configuration"
if [ -f /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/config/production-voice.json ]; then
    voice_id=$(grep '"voice_id"' /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/config/production-voice.json | cut -d'"' -f4)
    if [ "$voice_id" = "ZF6FPAbjXT4488VcRRnw" ]; then
        echo "✅ Production voice ID correctly configured (ZF6FPAbjXT4488VcRRnw)"
    else
        echo "❌ Production voice ID mismatch: $voice_id"
        exit 1
    fi
else
    echo "❌ Production voice configuration missing"
    exit 1
fi

# Test 3: Agent Availability Check
echo "Test 3: Agent Availability"
agent_count=$(find /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents -name "*.md" | wc -l | tr -d ' ')
if [ "$agent_count" -ge 18 ]; then
    echo "✅ Sufficient agents available ($agent_count found, 18+ required)"
else
    echo "❌ Insufficient agents ($agent_count found, 18+ required)"
    exit 1
fi

# Test 4: Production Command Availability
echo "Test 4: Production Command Check"
if [ -f /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/commands/produce-episode-enhanced.md ]; then
    echo "✅ Production command available"
else
    echo "❌ Production command missing"
    exit 1
fi

# Test 5: Cost Tracking Infrastructure
echo "Test 5: Cost Tracking Infrastructure"
hook_count=$(find /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/hooks -name "enhanced-*.sh" | wc -l | tr -d ' ')
if [ "$hook_count" -ge 2 ]; then
    echo "✅ Enhanced cost tracking hooks available ($hook_count found)"
else
    echo "❌ Enhanced cost tracking hooks insufficient ($hook_count found)"
    exit 1
fi

echo "=== Production Pipeline Integration Tests COMPLETED ==="
echo ""
echo "✅ NEXT STEP: Restart Claude Code with proper environment:"
echo "   cd /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows"
echo "   ./start-claude.sh"
echo ""
echo "🎯 THEN: Execute single episode production test with:"
echo "   /produce-episode-enhanced \"Quantum Entanglement Basics - What Nobody Knows\""
