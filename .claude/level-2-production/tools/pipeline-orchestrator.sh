#!/usr/bin/env bash

# Pipeline Orchestrator - Nobody Knows Podcast Production
# Smart restart detection with checkpoint-aware execution
# Level 2 Production System - 47-minute episodes with unlimited budget

set -e

# Technical: Master orchestrator implementing checkpoint detection, cost optimization, and agent coordination
# Simple: The smart conductor that runs our entire podcast creation process, picking up where it left off

echo "🎼 Nobody Knows Podcast - Pipeline Orchestrator v2.5"
echo "══════════════════════════════════════════════════════════"
echo "  47-Minute Episodes | Unlimited Budget | Checkpoint Protected"
echo "  11-Agent Pipeline | Smart Restart Detection | Cost Optimized"
echo ""

# Configuration
BASE_PATH="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/level-2-production"
SESSIONS_PATH="${BASE_PATH}/sessions"
TOOLS_PATH="${BASE_PATH}/tools"
AGENTS_PATH="${BASE_PATH}/agents"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Pipeline configuration - 11 agents with checkpoint protection
declare -a PIPELINE_STAGES=(
    "01_deep_research_complete:Deep Research Agent:7.50"
    "02_questions_complete:Research Question Generator:0.50"
    "03_synthesis_complete:Research Synthesizer:12.00"
    "04_coordination_complete:Research Coordinator:0.00"
    "04_planning_complete:Episode Planner:0.25"
    "05_script_complete:Script Writer:1.50"
    "07_tts_optimization_complete:TTS Optimizer:2.25"
    "08_quality_claude_complete:Quality Evaluator (Claude):0.00"
    "09_quality_gemini_complete:Quality Evaluator (Gemini):0.00"
    "10_quality_synthesis_complete:Quality Synthesis:0.00"
    "09_audio_synthesis_complete:Audio Synthesizer:10.50"
)

# Total pipeline cost without checkpoints
TOTAL_PIPELINE_COST="34.50"

# Session validation
validate_session() {
    local session_id="$1"
    
    if [[ -z "$session_id" ]]; then
        echo -e "${RED}❌ Error: Session ID required${NC}"
        echo "Usage: $0 <session_id> [topic]"
        echo "Example: $0 ep_001_20250814_test \"AI for Beginners\""
        exit 1
    fi
    
    local session_path="${SESSIONS_PATH}/${session_id}"
    
    if [[ ! -d "$session_path" ]]; then
        echo -e "${BLUE}📁 Creating new session: ${session_id}${NC}"
        mkdir -p "$session_path"
        
        # Initialize session metadata
        cat > "${session_path}/session_metadata.json" << EOF
{
  "session_id": "$session_id",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "initialized",
  "episode_type": "47-minute",
  "character_target": 35000,
  "voice_model": "eleven_turbo_v2_5",
  "voice_name": "Amelia",
  "voice_id": "ZF6FPAbjXT4488VcRRnw",
  "budget": "unlimited",
  "checkpoint_protection": true,
  "total_pipeline_cost": "$TOTAL_PIPELINE_COST"
}
EOF
    fi
    
    echo "$session_path"
}

# Checkpoint detection and analysis
analyze_checkpoints() {
    local session_path="$1"
    local session_id=$(basename "$session_path")
    
    echo -e "${PURPLE}🔍 CHECKPOINT ANALYSIS: ${session_id}${NC}"
    echo "─────────────────────────────────────────────────────────"
    
    local total_savings=0
    local completed_stages=0
    local next_stage=""
    local protection_level=""
    
    # Check each pipeline stage for checkpoints
    for stage_info in "${PIPELINE_STAGES[@]}"; do
        IFS=':' read -r stage_key stage_name stage_cost <<< "$stage_info"
        
        local checkpoint_file="${session_path}/${stage_key}.json"
        
        if [[ -f "$checkpoint_file" ]]; then
            # Validate checkpoint integrity
            if jq -e . "$checkpoint_file" >/dev/null 2>&1; then
                local checkpoint_status=$(jq -r '.status' "$checkpoint_file" 2>/dev/null)
                if [[ "$checkpoint_status" == "completed" ]]; then
                    echo -e "  ✅ ${stage_name}: ${GREEN}Completed${NC} (Protected: \$${stage_cost})"
                    total_savings=$(echo "$total_savings + $stage_cost" | bc -l)
                    ((completed_stages++))
                else
                    echo -e "  ⚠️  ${stage_name}: ${YELLOW}Incomplete${NC} (Status: $checkpoint_status)"
                fi
            else
                echo -e "  ❌ ${stage_name}: ${RED}Corrupted checkpoint${NC}"
            fi
        else
            if [[ -z "$next_stage" ]]; then
                next_stage="$stage_key:$stage_name"
            fi
            echo -e "  ⭕ ${stage_name}: ${YELLOW}Pending${NC} (Cost: \$${stage_cost})"
        fi
    done
    
    echo ""
    echo -e "${BLUE}📊 CHECKPOINT SUMMARY${NC}"
    echo "─────────────────────────────────────────────────────────"
    echo -e "  Completed Stages:     ${completed_stages}/11"
    echo -e "  💰 Total Savings:      \$${total_savings} (${TOTAL_PIPELINE_COST} max)"
    
    if [[ "$completed_stages" -eq 11 ]]; then
        protection_level="COMPLETE"
        echo -e "  🎉 Protection Level:   ${GREEN}COMPLETE PIPELINE${NC}"
        echo -e "  📱 Status:            ${GREEN}Episode fully produced!${NC}"
    elif [[ $(echo "$total_savings >= 12.00" | bc -l) -eq 1 ]]; then
        protection_level="MAJOR"
        echo -e "  💎 Protection Level:   ${GREEN}MAJOR SAVINGS${NC} (Research protected)"
    elif [[ $(echo "$total_savings >= 7.50" | bc -l) -eq 1 ]]; then
        protection_level="GOOD"
        echo -e "  💚 Protection Level:   ${YELLOW}GOOD SAVINGS${NC} (Deep research protected)"
    elif [[ "$total_savings" != "0" ]]; then
        protection_level="PARTIAL"
        echo -e "  💛 Protection Level:   ${YELLOW}PARTIAL SAVINGS${NC}"
    else
        protection_level="NONE"
        echo -e "  💭 Protection Level:   ${RED}NO PROTECTION${NC} (Full pipeline needed)"
    fi
    
    local remaining_cost=$(echo "$TOTAL_PIPELINE_COST - $total_savings" | bc -l)
    echo -e "  💸 Remaining Cost:     \$${remaining_cost}"
    
    if [[ -n "$next_stage" ]]; then
        IFS=':' read -r next_key next_name <<< "$next_stage"
        echo -e "  ▶️  Next Stage:         ${BLUE}${next_name}${NC} (${next_key})"
    fi
    
    echo ""
    
    # Return values for pipeline execution
    echo "CHECKPOINT_ANALYSIS_COMPLETE"
    echo "TOTAL_SAVINGS:$total_savings"
    echo "COMPLETED_STAGES:$completed_stages"
    echo "PROTECTION_LEVEL:$protection_level"
    echo "REMAINING_COST:$remaining_cost"
    echo "NEXT_STAGE:$next_stage"
}

# Smart restart detection
determine_restart_strategy() {
    local analysis_output="$1"
    local session_path="$2"
    
    # Parse analysis output
    local total_savings=$(echo "$analysis_output" | grep "TOTAL_SAVINGS:" | cut -d: -f2)
    local completed_stages=$(echo "$analysis_output" | grep "COMPLETED_STAGES:" | cut -d: -f2)
    local protection_level=$(echo "$analysis_output" | grep "PROTECTION_LEVEL:" | cut -d: -f2)
    local next_stage=$(echo "$analysis_output" | grep "NEXT_STAGE:" | cut -d: -f2)
    
    echo -e "${PURPLE}🧠 SMART RESTART STRATEGY${NC}"
    echo "─────────────────────────────────────────────────────────"
    
    # Determine optimal restart approach
    case "$protection_level" in
        "COMPLETE")
            echo -e "  🎯 Strategy: ${GREEN}EPISODE COMPLETE${NC}"
            echo -e "  📁 Action: Validate final outputs and provide summary"
            echo -e "  💰 Benefit: \$${total_savings} already saved"
            return 0
            ;;
        "MAJOR")
            echo -e "  🎯 Strategy: ${GREEN}SKIP RESEARCH PIPELINE${NC}"
            echo -e "  📁 Action: Start from Episode Planner or later"
            echo -e "  💰 Benefit: Research synthesis protected (\$12.00+ saved)"
            ;;
        "GOOD")
            echo -e "  🎯 Strategy: ${YELLOW}SKIP DEEP RESEARCH${NC}"
            echo -e "  📁 Action: Start from Question Generator or Synthesis"
            echo -e "  💰 Benefit: Deep research protected (\$7.50+ saved)"
            ;;
        "PARTIAL")
            echo -e "  🎯 Strategy: ${YELLOW}PARTIAL RESTART${NC}"
            echo -e "  📁 Action: Resume from first incomplete stage"
            echo -e "  💰 Benefit: \$${total_savings} saved from completed work"
            ;;
        *)
            echo -e "  🎯 Strategy: ${RED}FULL PIPELINE${NC}"
            echo -e "  📁 Action: Execute complete 11-agent pipeline"
            echo -e "  💰 Cost: \$${TOTAL_PIPELINE_COST} (no existing protection)"
            ;;
    esac
    
    if [[ -n "$next_stage" && "$protection_level" != "COMPLETE" ]]; then
        IFS=':' read -r next_key next_name <<< "$next_stage"
        echo -e "  ▶️  Next Action: Execute ${BLUE}${next_name}${NC}"
        echo -e "  📋 Stage Key: ${next_key}"
    fi
    
    echo ""
    return 1
}

# Execute pipeline stage
execute_stage() {
    local stage_key="$1"
    local stage_name="$2" 
    local session_id="$3"
    local topic="${4:-AI for Beginners}"
    
    echo -e "${BLUE}🎬 EXECUTING: ${stage_name}${NC}"
    echo "─────────────────────────────────────────────────────────"
    echo "  Stage: $stage_key"
    echo "  Session: $session_id"
    echo "  Topic: $topic"
    echo ""
    
    local agent_file=""
    local execution_success=false
    
    # Map stage to agent file
    case "$stage_key" in
        "01_deep_research")
            agent_file="01_deep_research_agent.md"
            echo "🔬 Executing deep research on '$topic' using Perplexity API"
            echo "   Expected duration: 8-12 minutes"
            echo "   Cost protection: \$7.50 on completion"
            ;;
        "02_questions")
            agent_file="02_research_question_generator.md"
            echo "❓ Generating 50+ targeted research questions"
            echo "   Expected duration: 3-5 minutes"
            echo "   Cost protection: \$0.50 on completion"
            ;;
        "03_synthesis")
            agent_file="03_research_synthesizer.md"
            echo "🧩 Executing comprehensive research synthesis (100-150 Perplexity calls)"
            echo "   Expected duration: 15-20 minutes"
            echo "   Cost protection: \$12.00 on completion (HIGHEST SAVINGS)"
            ;;
        "04_coordination")
            agent_file="04_research_coordinator.md"
            echo "🎯 Coordinating research pipeline with checkpoint awareness"
            echo "   Expected duration: 2-3 minutes"
            ;;
        "05_planning")
            agent_file="02_episode_planner.md"
            echo "📋 Creating 47-minute episode structure (35k characters)"
            echo "   Expected duration: 5-8 minutes"
            echo "   Cost protection: \$0.25 on completion"
            ;;
        "06_writing")
            agent_file="03_script_writer.md"
            echo "✍️  Writing comprehensive 35k+ character script"
            echo "   Expected duration: 12-18 minutes"
            echo "   Cost protection: \$1.50 on completion"
            ;;
        "07_tts_optimization")
            agent_file="07_tts_optimizer.md"
            echo "🎭 Optimizing script for eleven_turbo_v2_5 and Amelia voice"
            echo "   Expected duration: 8-12 minutes"
            echo "   Cost protection: \$2.25 on completion"
            ;;
        "08_quality_claude")
            agent_file="04_quality_claude.md"
            echo "🔍 Claude quality evaluation for brand and narrative"
            echo "   Expected duration: 5-8 minutes"
            ;;
        "09_quality_gemini")
            agent_file="05_quality_gemini.md"
            echo "💎 Gemini quality evaluation for technical accuracy"
            echo "   Expected duration: 3-5 minutes"
            ;;
        "10_synthesis")
            agent_file="06_feedback_synthesizer.md"
            echo "🔄 Synthesizing quality feedback and improvements"
            echo "   Expected duration: 5-8 minutes"
            ;;
        "11_audio_generation")
            agent_file="09_audio_synthesizer.md"
            echo "🎵 Generating 47-minute audio with Amelia voice"
            echo "   Expected duration: 18-25 minutes"
            echo "   Cost protection: \$10.50 on completion (MAJOR SAVINGS)"
            ;;
        *)
            echo -e "${RED}❌ Unknown stage: $stage_key${NC}"
            return 1
            ;;
    esac
    
    if [[ -n "$agent_file" ]]; then
        local agent_path="${AGENTS_PATH}/${agent_file}"
        if [[ -f "$agent_path" ]]; then
            echo "   Agent: $agent_file"
            echo "   Status: Ready for execution"
            echo ""
            echo -e "${GREEN}✅ Stage configured for execution${NC}"
            echo "   Manual execution required: Use Claude Code to run agent"
            echo "   Command: Run agent with session_id='$session_id' and topic='$topic'"
            execution_success=true
        else
            echo -e "${RED}❌ Agent file not found: $agent_path${NC}"
            return 1
        fi
    fi
    
    echo ""
    return $([ "$execution_success" = true ] && echo 0 || echo 1)
}

# Pipeline execution coordinator
execute_pipeline() {
    local session_path="$1"
    local session_id="$2"
    local topic="${3:-AI for Beginners}"
    
    echo -e "${PURPLE}🎼 PIPELINE EXECUTION COORDINATOR${NC}"
    echo "═══════════════════════════════════════════════════════════"
    
    # Run checkpoint analysis
    local analysis_output=$(analyze_checkpoints "$session_path")
    
    # Determine restart strategy
    if determine_restart_strategy "$analysis_output" "$session_path"; then
        # Episode complete
        echo -e "${GREEN}🎉 Episode production complete!${NC}"
        return 0
    fi
    
    # Parse next stage
    local next_stage=$(echo "$analysis_output" | grep "NEXT_STAGE:" | cut -d: -f2)
    
    if [[ -z "$next_stage" || "$next_stage" == "" ]]; then
        echo -e "${RED}❌ Unable to determine next stage${NC}"
        return 1
    fi
    
    IFS=':' read -r stage_key stage_name <<< "$next_stage"
    
    echo -e "${BLUE}🚀 READY FOR EXECUTION${NC}"
    echo "─────────────────────────────────────────────────────────"
    echo -e "  Next Stage: ${BLUE}${stage_name}${NC}"
    echo -e "  Stage Key: ${stage_key}"
    echo -e "  Session: ${session_id}"
    echo -e "  Topic: ${topic}"
    echo ""
    
    # Execute the next stage
    if execute_stage "$stage_key" "$stage_name" "$session_id" "$topic"; then
        echo -e "${GREEN}✅ Stage ready for execution${NC}"
        echo ""
        echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
        echo "1. Use Claude Code to execute the configured agent"
        echo "2. Monitor checkpoint creation for cost protection"
        echo "3. Re-run this orchestrator to continue pipeline"
        echo "4. Validate quality at each checkpoint"
        echo ""
    else
        echo -e "${RED}❌ Stage execution configuration failed${NC}"
        return 1
    fi
    
    return 0
}

# Validation and status reporting
generate_status_report() {
    local session_path="$1"
    local session_id="$2"
    
    local report_file="${session_path}/pipeline_status_report.json"
    local analysis_output=$(analyze_checkpoints "$session_path")
    
    # Parse analysis results
    local total_savings=$(echo "$analysis_output" | grep "TOTAL_SAVINGS:" | cut -d: -f2)
    local completed_stages=$(echo "$analysis_output" | grep "COMPLETED_STAGES:" | cut -d: -f2)
    local protection_level=$(echo "$analysis_output" | grep "PROTECTION_LEVEL:" | cut -d: -f2)
    local remaining_cost=$(echo "$analysis_output" | grep "REMAINING_COST:" | cut -d: -f2)
    local next_stage=$(echo "$analysis_output" | grep "NEXT_STAGE:" | cut -d: -f2)
    
    cat > "$report_file" << EOF
{
  "pipeline_status": {
    "session_id": "$session_id",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "total_stages": 11,
    "completed_stages": $completed_stages,
    "completion_percentage": $(echo "scale=1; $completed_stages * 100 / 11" | bc -l),
    "protection_level": "$protection_level",
    "cost_analysis": {
      "total_pipeline_cost": "$TOTAL_PIPELINE_COST",
      "total_savings": "$total_savings",
      "remaining_cost": "$remaining_cost",
      "savings_percentage": $(echo "scale=1; $total_savings * 100 / $TOTAL_PIPELINE_COST" | bc -l)
    },
    "next_action": {
      "stage": "$next_stage",
      "ready_for_execution": true
    },
    "episode_specs": {
      "target_duration": "47 minutes",
      "character_count": "35,000+",
      "voice_model": "eleven_turbo_v2_5",
      "voice_name": "Amelia"
    }
  }
}
EOF
    
    echo -e "${GREEN}📄 Status report generated: ${report_file}${NC}"
}

# Help and usage
show_help() {
    echo "Pipeline Orchestrator - Nobody Knows Podcast Production"
    echo ""
    echo "Usage: $0 <session_id> [topic]"
    echo ""
    echo "Arguments:"
    echo "  session_id    Episode session identifier (e.g., ep_001_20250814_test)"
    echo "  topic         Episode topic (default: 'AI for Beginners')"
    echo ""
    echo "Examples:"
    echo "  $0 ep_001_20250814_test \"AI for Beginners\""
    echo "  $0 ep_002_20250814_1500 \"Machine Learning Fundamentals\""
    echo ""
    echo "Features:"
    echo "  • Smart checkpoint detection and analysis"
    echo "  • Cost-aware restart optimization (\$34.50 max protection)"
    echo "  • 11-agent pipeline coordination"
    echo "  • 47-minute episode production"
    echo "  • Unlimited budget with checkpoint savings"
    echo ""
}

# Main execution
main() {
    case "${1:-}" in
        "help"|"-h"|"--help")
            show_help
            exit 0
            ;;
        "")
            echo -e "${RED}Error: Session ID required${NC}"
            show_help
            exit 1
            ;;
        *)
            local session_id="$1"
            local topic="${2:-AI for Beginners}"
            
            echo "Starting pipeline orchestration..."
            echo "Session: $session_id"
            echo "Topic: $topic"
            echo ""
            
            # Validate and prepare session
            local session_path=$(validate_session "$session_id")
            
            # Execute pipeline coordination
            if execute_pipeline "$session_path" "$session_id" "$topic"; then
                # Generate status report
                generate_status_report "$session_path" "$session_id"
                
                echo -e "${GREEN}🎼 Pipeline orchestration complete!${NC}"
                echo -e "   Use Claude Code to execute the next configured stage"
                exit 0
            else
                echo -e "${RED}❌ Pipeline orchestration failed${NC}"
                exit 1
            fi
            ;;
    esac
}

# Run main function with all arguments
main "$@"