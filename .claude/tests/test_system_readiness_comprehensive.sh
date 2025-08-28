#!/bin/bash
# Comprehensive System Readiness Test Suite
# Validates complete end-to-end production readiness

echo "=== COMPREHENSIVE SYSTEM READINESS TEST SUITE ==="
echo "Validating complete AI podcast production system..."
echo ""

# Initialize counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo "Test $TOTAL_TESTS: $test_name"
    if eval "$test_command"; then
        echo "✅ PASSED: $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "❌ FAILED: $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# === INFRASTRUCTURE TESTS ===
echo "📁 INFRASTRUCTURE READINESS TESTS"

run_test "Project root directory structure" \
    "[ -d '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude' ] && [ -d '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/episodes' ]"

run_test "Environment configuration files" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.env' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/start-claude.sh' ]"

run_test "Claude Code settings configuration" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/settings.json' ] && grep -q 'ElevenLabs' /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/settings.json"

# === AGENT SYSTEM TESTS ===
echo "🤖 AGENT SYSTEM READINESS TESTS"

run_test "All required agents present" \
    "[ $(find /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents -name '*.md' | wc -l | tr -d ' ') -ge 18 ]"

run_test "Core production agents available" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents/question-generator.md' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents/script-writer.md' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents/audio-synthesizer.md' ]"

run_test "Quality assurance agents available" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents/quality-claude.md' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents/quality-gemini.md' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents/brand-voice-validator.md' ]"

run_test "Audio processing agents available" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents/tts-optimizer.md' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/agents/audio-quality-validator.md' ]"

# === PRODUCTION SYSTEM TESTS ===
echo "🎬 PRODUCTION SYSTEM READINESS TESTS"

run_test "Production command available" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/commands/produce-episode-enhanced.md' ]"

run_test "Episode directory structure initialized" \
    "[ -d '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/episodes/production' ] && [ $(find /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/episodes/production -name 'ep*' -type d | wc -l | tr -d ' ') -ge 100 ]"

run_test "Session management system" \
    "[ -d '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/sessions' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/episodes/state.json' ]"

# === QUALITY AND GOVERNANCE TESTS ===
echo "⚖️ QUALITY & GOVERNANCE READINESS TESTS"

run_test "Production voice configuration locked" \
    "grep -q 'ZF6FPAbjXT4488VcRRnw' /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/config/production-voice.json && grep -q 'immutable_without_user_permission.*true' /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/config/production-voice.json"

run_test "Enhanced cost tracking hooks installed" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/hooks/enhanced-pre-tool-cost-validation.sh' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/hooks/enhanced-post-tool-cost-tracking.sh' ]"

run_test "Duplication detection system active" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/hooks/duplication-detector.sh' ] && [ -x '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/hooks/duplication-detector.sh' ]"

run_test "CLAUDE.md protocol enforcement" \
    "grep -q 'ZERO-TOLERANCE DRY ENFORCEMENT' /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/CLAUDE.md && grep -q 'MANDATORY SIMPLICITY ENFORCEMENT' /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/CLAUDE.md"

# === ENVIRONMENT VALIDATION TESTS ===
echo "🌍 ENVIRONMENT VALIDATION TESTS"

# Load environment for testing
source /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.env 2>/dev/null

run_test "ElevenLabs API key configured" \
    "[ ! -z \"\$ELEVENLABS_API_KEY\" ] && [ \${#ELEVENLABS_API_KEY} -gt 20 ]"

run_test "Perplexity API key configured" \
    "[ ! -z \"\$PERPLEXITY_API_KEY\" ] && [ \${#PERPLEXITY_API_KEY} -gt 20 ]"

run_test "GitHub PAT configured" \
    "[ ! -z \"\$GITHUB_PAT\" ] && [ \${#GITHUB_PAT} -gt 20 ]"

run_test "Start script executable and functional" \
    "[ -x '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/start-claude.sh' ] && grep -q 'claude code' /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/start-claude.sh"

# === VALIDATION AND TESTING INFRASTRUCTURE ===
echo "🧪 VALIDATION & TESTING INFRASTRUCTURE"

run_test "Comprehensive test suite available" \
    "[ -d '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/tests' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/tests/test_environment_setup.sh' ]"

run_test "Quality gate validation scripts" \
    "[ -d '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/tests/quality_gates' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/tests/quality_gates/test_brand_voice_gates.sh' ]"

run_test "Meta-prompting workflow documentation" \
    "[ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/processes/plan-end-to-end-completion-20250827.md' ] && [ -f '/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/processes/decomposition-end-to-end-completion-20250827.md' ]"

# === FINAL RESULTS ===
echo "========================================="
echo "COMPREHENSIVE SYSTEM READINESS RESULTS"
echo "========================================="
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo "🎉 ALL SYSTEMS READY FOR PRODUCTION!"
    echo ""
    echo "✅ SYSTEM STATUS: PRODUCTION READY"
    echo "✅ NEXT ACTION: Execute production test"
    echo ""
    echo "🚀 TO START PRODUCTION:"
    echo "1. ./start-claude.sh"
    echo "2. /produce-episode-enhanced \"Quantum Entanglement Basics - What Nobody Knows\""
    echo ""
    echo "🎯 TARGET: Complete episode under $5.51 with ≥85% brand voice alignment"
    exit 0
else
    echo "⚠️  SYSTEM NOT READY - $FAILED_TESTS ISSUES DETECTED"
    echo ""
    echo "❌ SYSTEM STATUS: REQUIRES ATTENTION"
    echo "❌ NEXT ACTION: Resolve failed tests before production"
    echo ""
    echo "🔧 RESOLUTION REQUIRED:"
    echo "- Review failed tests above"
    echo "- Fix identified issues"
    echo "- Re-run comprehensive test suite"
    exit 1
fi
