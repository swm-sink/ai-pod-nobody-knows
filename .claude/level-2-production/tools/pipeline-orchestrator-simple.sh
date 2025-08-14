#!/usr/bin/env bash

# Simple Pipeline Orchestrator - Nobody Knows Podcast Production
# Smart checkpoint detection and restart coordination

set -e

echo "🎼 Nobody Knows Podcast - Pipeline Orchestrator v2.5"
echo "══════════════════════════════════════════════════════════"
echo "  47-Minute Episodes | Unlimited Budget | Checkpoint Protected"
echo ""

# Configuration
BASE_PATH="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/level-2-production"
SESSIONS_PATH="${BASE_PATH}/sessions"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Session validation
if [[ -z "$1" ]]; then
    echo -e "${RED}❌ Error: Session ID required${NC}"
    echo "Usage: $0 <session_id> [topic]"
    echo "Example: $0 ep_001_20250814_test \"AI for Beginners\""
    exit 1
fi

SESSION_ID="$1"
TOPIC="${2:-AI for Beginners}"
SESSION_PATH="${SESSIONS_PATH}/${SESSION_ID}"

echo "Session: $SESSION_ID"
echo "Topic: $TOPIC"
echo ""

# Create session directory if it doesn't exist
if [[ ! -d "$SESSION_PATH" ]]; then
    echo -e "${BLUE}📁 Creating new session: ${SESSION_ID}${NC}"
    mkdir -p "$SESSION_PATH"
fi

echo -e "${BLUE}🔍 CHECKPOINT ANALYSIS${NC}"
echo "─────────────────────────────────────────────────────────"

# Check each checkpoint file and calculate savings
TOTAL_SAVINGS=0
COMPLETED=0

# Check checkpoints in order
checkpoints=(
    "01_deep_research_complete.json:7.50:Deep Research Agent"
    "02_questions_complete.json:0.50:Research Question Generator"
    "03_synthesis_complete.json:12.00:Research Synthesizer"
    "04_planning_complete.json:0.25:Episode Planner"
    "05_script_complete.json:1.50:Script Writer"
    "07_tts_optimization_complete.json:2.25:TTS Optimizer"
    "09_audio_synthesis_complete.json:10.50:Audio Synthesizer"
)

# Check each checkpoint
for checkpoint_info in "${checkpoints[@]}"; do
    IFS=':' read -r checkpoint_file cost name <<< "$checkpoint_info"
    file_path="${SESSION_PATH}/${checkpoint_file}"

    if [[ -f "$file_path" ]]; then
        if jq -e . "$file_path" >/dev/null 2>&1; then
            status=$(jq -r '.status' "$file_path" 2>/dev/null)
            if [[ "$status" == "completed" ]]; then
                echo -e "  ✅ ${name}: ${GREEN}Completed${NC} (Protected: \$${cost})"
                TOTAL_SAVINGS=$(echo "$TOTAL_SAVINGS + $cost" | bc -l)
                ((COMPLETED++))
            else
                echo -e "  ⚠️  ${name}: ${YELLOW}Status: $status${NC}"
            fi
        else
            echo -e "  ❌ ${name}: ${RED}Invalid checkpoint${NC}"
        fi
    else
        echo -e "  ⭕ ${name}: ${YELLOW}Pending${NC} (Cost: \$${cost})"
    fi
done

echo ""
echo -e "${BLUE}📊 SUMMARY${NC}"
echo "─────────────────────────────────────────────────────────"
echo -e "  Completed Stages:     ${COMPLETED}/7"
echo -e "  💰 Total Savings:      \$${TOTAL_SAVINGS}"

REMAINING_COST=$(echo "34.50 - $TOTAL_SAVINGS" | bc -l)
echo -e "  💸 Remaining Cost:     \$${REMAINING_COST}"

# Determine next action
if [[ "$COMPLETED" -eq 7 ]]; then
    echo -e "  🎉 Status:            ${GREEN}EPISODE COMPLETE!${NC}"
elif [[ $(echo "$TOTAL_SAVINGS >= 12.00" | bc -l) -eq 1 ]]; then
    echo -e "  💎 Protection Level:   ${GREEN}MAJOR SAVINGS${NC} (Research protected)"
elif [[ $(echo "$TOTAL_SAVINGS >= 7.50" | bc -l) -eq 1 ]]; then
    echo -e "  💚 Protection Level:   ${YELLOW}GOOD SAVINGS${NC} (Deep research protected)"
elif [[ "$TOTAL_SAVINGS" != "0" ]]; then
    echo -e "  💛 Protection Level:   ${YELLOW}PARTIAL SAVINGS${NC}"
else
    echo -e "  💭 Protection Level:   ${RED}NO PROTECTION${NC} (Full pipeline needed)"
fi

echo ""

# Determine next steps
if [[ ! -f "${SESSION_PATH}/01_deep_research_complete.json" ]]; then
    echo -e "${BLUE}🚀 NEXT STEP: Deep Research Agent${NC}"
    echo "   Agent: 01_deep_research_agent.md"
    echo "   Cost: \$7.50"
    echo "   Duration: 8-12 minutes"
elif [[ ! -f "${SESSION_PATH}/02_questions_complete.json" ]]; then
    echo -e "${BLUE}🚀 NEXT STEP: Research Question Generator${NC}"
    echo "   Agent: 02_research_question_generator.md"
    echo "   Cost: \$0.50"
    echo "   Duration: 3-5 minutes"
elif [[ ! -f "${SESSION_PATH}/03_synthesis_complete.json" ]]; then
    echo -e "${BLUE}🚀 NEXT STEP: Research Synthesizer${NC}"
    echo "   Agent: 03_research_synthesizer.md"
    echo "   Cost: \$12.00 (HIGHEST COST)"
    echo "   Duration: 15-20 minutes"
elif [[ ! -f "${SESSION_PATH}/04_planning_complete.json" ]]; then
    echo -e "${BLUE}🚀 NEXT STEP: Episode Planner${NC}"
    echo "   Agent: 02_episode_planner.md"
    echo "   Cost: \$0.25"
    echo "   Duration: 5-8 minutes"
elif [[ ! -f "${SESSION_PATH}/05_script_complete.json" ]]; then
    echo -e "${BLUE}🚀 NEXT STEP: Script Writer${NC}"
    echo "   Agent: 03_script_writer.md"
    echo "   Cost: \$1.50"
    echo "   Duration: 12-18 minutes"
elif [[ ! -f "${SESSION_PATH}/07_tts_optimization_complete.json" ]]; then
    echo -e "${BLUE}🚀 NEXT STEP: TTS Optimizer${NC}"
    echo "   Agent: 07_tts_optimizer.md"
    echo "   Cost: \$2.25"
    echo "   Duration: 8-12 minutes"
elif [[ ! -f "${SESSION_PATH}/09_audio_synthesis_complete.json" ]]; then
    echo -e "${BLUE}🚀 NEXT STEP: Audio Synthesizer${NC}"
    echo "   Agent: 09_audio_synthesizer.md"
    echo "   Cost: \$10.50 (MAJOR COST)"
    echo "   Duration: 18-25 minutes"
else
    echo -e "${GREEN}🎉 EPISODE PRODUCTION COMPLETE!${NC}"
    echo -e "   All checkpoints found and validated"
    echo -e "   Total savings: \$${TOTAL_SAVINGS}"
    exit 0
fi

echo ""
echo -e "${YELLOW}📋 INSTRUCTIONS:${NC}"
echo "1. Use Claude Code to run the specified agent"
echo "2. Monitor checkpoint creation for cost protection"
echo "3. Re-run this orchestrator to continue pipeline"
echo "4. Session: $SESSION_ID"
echo "5. Topic: $TOPIC"

# Generate status report
cat > "${SESSION_PATH}/pipeline_status.json" << EOF
{
  "session_id": "$SESSION_ID",
  "topic": "$TOPIC",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "completed_stages": $COMPLETED,
  "total_stages": 7,
  "total_savings": "$TOTAL_SAVINGS",
  "remaining_cost": "$REMAINING_COST",
  "completion_percentage": $(echo "scale=1; $COMPLETED * 100 / 7" | bc -l)
}
EOF

echo ""
echo -e "${GREEN}✅ Pipeline analysis complete!${NC}"
