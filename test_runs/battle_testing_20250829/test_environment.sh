#!/bin/bash
# Battle Testing Environment Setup Script

# Set test mode environment variables
export BATTLE_TESTING_MODE=true
export BATTLE_TESTING_SESSION="battle_testing_20250829"
export TEST_OUTPUT_DIR="test_runs/battle_testing_20250829"
export PRODUCTION_PROTECTION=true

# Cost and quality monitoring
export COST_TRACKING_ENABLED=true
export QUALITY_VALIDATION_ENABLED=true
export PERFORMANCE_MONITORING=true

# Agent configuration overrides for test mode
export AGENT_TEST_MODE=true
export AGENT_OUTPUT_OVERRIDE="$TEST_OUTPUT_DIR"

# Quality thresholds
export MIN_RESEARCH_QUALITY=7.0
export MIN_BRAND_CONSISTENCY=7.0
export MIN_AUDIO_QUALITY=7.0
export MAX_COST_PER_EPISODE=10.0
export MIN_SUCCESS_RATE=0.95

echo "Battle Testing Environment Configured"
echo "Session ID: $BATTLE_TESTING_SESSION"
echo "Output Directory: $TEST_OUTPUT_DIR"
echo "Production Protection: $PRODUCTION_PROTECTION"
echo ""
echo "Use this environment for all battle testing activities."
echo "All outputs will be isolated to the test directory."
