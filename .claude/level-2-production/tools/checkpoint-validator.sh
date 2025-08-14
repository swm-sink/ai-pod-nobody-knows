#!/usr/bin/env bash

# Checkpoint Validation Script for Nobody Knows Podcast Production
# Level 2 Production System - Native Claude Code Implementation

# Technical: Validates checkpoint file integrity, format, and cost calculations
# Simple: Checks if all our checkpoint files are working properly

set -e

echo "🔍 Nobody Knows Podcast - Checkpoint Validation System"
echo "======================================================"

# Configuration
BASE_PATH="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/level-2-production/sessions"
VALIDATION_LOG="/tmp/checkpoint_validation_$(date +%Y%m%d_%H%M%S).log"

# Checkpoint file specifications
declare -A CHECKPOINT_SPECS
CHECKPOINT_SPECS["01_deep_research_complete.json"]="7.50"
CHECKPOINT_SPECS["02_questions_complete.json"]="0.50"
CHECKPOINT_SPECS["03_synthesis_complete.json"]="12.00"
CHECKPOINT_SPECS["04_planning_complete.json"]="0.25"
CHECKPOINT_SPECS["05_script_complete.json"]="1.50"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$VALIDATION_LOG"
    echo "$1"
}

# Validation functions
validate_json_syntax() {
    local file=$1
    if python3 -m json.tool "$file" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

validate_checkpoint_structure() {
    local file=$1
    local required_fields=("checkpoint_type" "session_id" "episode_number" "status" "timestamp" "cost_invested")
    
    for field in "${required_fields[@]}"; do
        if ! python3 -c "
import json, sys
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    if '$field' not in data:
        sys.exit(1)
    sys.exit(0)
except:
    sys.exit(1)" 2>/dev/null; then
            return 1
        fi
    done
    return 0
}

validate_cost_accuracy() {
    local file=$1
    local expected_cost=$2
    
    local actual_cost=$(python3 -c "
import json
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    print(data.get('cost_invested', 0))
except:
    print(0)" 2>/dev/null)
    
    if [ "$(echo "$actual_cost == $expected_cost" | bc -l)" == "1" ]; then
        return 0
    else
        return 1
    fi
}

calculate_session_savings() {
    local session_path=$1
    local total_savings=0
    local files_found=0
    
    for checkpoint_file in "${!CHECKPOINT_SPECS[@]}"; do
        local full_path="$session_path/$checkpoint_file"
        if [ -f "$full_path" ]; then
            local cost=${CHECKPOINT_SPECS[$checkpoint_file]}
            total_savings=$(echo "$total_savings + $cost" | bc -l)
            ((files_found++))
        fi
    done
    
    echo "$total_savings:$files_found"
}

# Main validation function
validate_session() {
    local session_path=$1
    local session_name=$(basename "$session_path")
    
    echo ""
    log "${BLUE}📁 Validating Session: $session_name${NC}"
    
    local validation_passed=true
    local files_validated=0
    local total_protection=0
    
    # Check if session directory exists
    if [ ! -d "$session_path" ]; then
        log "${RED}❌ Session directory not found: $session_path${NC}"
        return 1
    fi
    
    # Validate each expected checkpoint file
    for checkpoint_file in "${!CHECKPOINT_SPECS[@]}"; do
        local full_path="$session_path/$checkpoint_file"
        local expected_cost=${CHECKPOINT_SPECS[$checkpoint_file]}
        
        echo -n "  🔍 $checkpoint_file..."
        
        if [ ! -f "$full_path" ]; then
            echo -e " ${YELLOW}⚠️  Missing${NC}"
            log "   Missing: $checkpoint_file"
            continue
        fi
        
        # JSON syntax validation
        if ! validate_json_syntax "$full_path"; then
            echo -e " ${RED}❌ Invalid JSON${NC}"
            log "   ERROR: Invalid JSON syntax in $checkpoint_file"
            validation_passed=false
            continue
        fi
        
        # Structure validation
        if ! validate_checkpoint_structure "$full_path"; then
            echo -e " ${RED}❌ Invalid Structure${NC}"
            log "   ERROR: Missing required fields in $checkpoint_file"
            validation_passed=false
            continue
        fi
        
        # Cost validation
        if ! validate_cost_accuracy "$full_path" "$expected_cost"; then
            echo -e " ${RED}❌ Cost Mismatch${NC}"
            log "   ERROR: Cost mismatch in $checkpoint_file (expected: $expected_cost)"
            validation_passed=false
            continue
        fi
        
        echo -e " ${GREEN}✅ Valid${NC}"
        log "   SUCCESS: $checkpoint_file validated (protects \$$expected_cost)"
        ((files_validated++))
        total_protection=$(echo "$total_protection + $expected_cost" | bc -l)
    done
    
    # Session summary
    echo ""
    log "  📊 Session Summary:"
    log "     Files validated: $files_validated/5"
    log "     Cost protection: \$$total_protection"
    
    if [ "$files_validated" -gt 0 ]; then
        local percentage=$(echo "scale=1; $total_protection / 21.75 * 100" | bc -l)
        log "     Pipeline coverage: ${percentage}%"
        
        # Identify restart optimization
        if [ "$total_protection" == "21.75" ]; then
            log "${GREEN}     💰 FULL PROTECTION: Complete pipeline can be skipped${NC}"
        elif [ "$(echo "$total_protection >= 12.00" | bc -l)" == "1" ]; then
            log "${GREEN}     💰 MAJOR SAVINGS: Research synthesis protected${NC}"
        elif [ "$(echo "$total_protection >= 7.50" | bc -l)" == "1" ]; then
            log "${YELLOW}     💰 GOOD SAVINGS: Deep research protected${NC}"
        fi
    fi
    
    if $validation_passed && [ "$files_validated" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# System-wide validation
validate_all_sessions() {
    log "🚀 Starting System-Wide Checkpoint Validation"
    
    local total_sessions=0
    local valid_sessions=0
    local total_files=0
    local system_protection=0
    
    # Find all session directories
    if [ ! -d "$BASE_PATH" ]; then
        log "${RED}❌ Base sessions path not found: $BASE_PATH${NC}"
        return 1
    fi
    
    for session_dir in "$BASE_PATH"/*; do
        if [ -d "$session_dir" ]; then
            ((total_sessions++))
            if validate_session "$session_dir"; then
                ((valid_sessions++))
                # Calculate this session's protection
                local savings_info=$(calculate_session_savings "$session_dir")
                local session_savings=$(echo "$savings_info" | cut -d: -f1)
                local session_files=$(echo "$savings_info" | cut -d: -f2)
                system_protection=$(echo "$system_protection + $session_savings" | bc -l)
                total_files=$((total_files + session_files))
            fi
        fi
    done
    
    # System summary
    echo ""
    log "🎯 System-Wide Validation Results"
    log "================================="
    log "Sessions found: $total_sessions"
    log "Sessions valid: $valid_sessions"
    log "Total checkpoint files: $total_files"
    log "Total cost protection: \$$system_protection"
    
    if [ "$total_sessions" -gt 0 ]; then
        local success_rate=$(echo "scale=1; $valid_sessions * 100 / $total_sessions" | bc -l)
        log "Validation success rate: ${success_rate}%"
    fi
    
    # System health assessment
    if [ "$valid_sessions" == "$total_sessions" ] && [ "$total_sessions" -gt 0 ]; then
        log "${GREEN}🎉 SYSTEM HEALTHY: All sessions validated successfully${NC}"
        return 0
    elif [ "$valid_sessions" -gt 0 ]; then
        log "${YELLOW}⚠️  PARTIAL SUCCESS: Some sessions have issues${NC}"
        return 1
    else
        log "${RED}❌ SYSTEM ISSUES: No valid sessions found${NC}"
        return 2
    fi
}

# Quick validation (single session)
quick_validate() {
    local session_id=$1
    local session_path="$BASE_PATH/$session_id"
    
    echo "🔍 Quick Validation: $session_id"
    if validate_session "$session_path"; then
        echo -e "${GREEN}✅ Session valid and ready for production${NC}"
        return 0
    else
        echo -e "${RED}❌ Session has validation issues${NC}"
        return 1
    fi
}

# Cost calculator
calculate_potential_savings() {
    local session_id=$1
    local session_path="$BASE_PATH/$session_id"
    
    echo "💰 Cost Analysis: $session_id"
    
    if [ ! -d "$session_path" ]; then
        echo -e "${RED}Session not found: $session_id${NC}"
        return 1
    fi
    
    local savings_info=$(calculate_session_savings "$session_path")
    local total_savings=$(echo "$savings_info" | cut -d: -f1)
    local files_count=$(echo "$savings_info" | cut -d: -f2)
    
    echo "Checkpoint files found: $files_count/5"
    echo "Potential savings: \$$total_savings"
    
    if [ "$(echo "$total_savings > 0" | bc -l)" == "1" ]; then
        local percentage=$(echo "scale=1; $total_savings / 21.75 * 100" | bc -l)
        echo "Cost reduction: ${percentage}%"
        
        local remaining_cost=$(echo "21.75 - $total_savings" | bc -l)
        echo "Remaining pipeline cost: \$$remaining_cost"
    fi
}

# Help function
show_help() {
    echo "Checkpoint Validation Tool - Nobody Knows Podcast"
    echo ""
    echo "Usage: $0 [COMMAND] [SESSION_ID]"
    echo ""
    echo "Commands:"
    echo "  validate-all          Validate all sessions in system"
    echo "  validate SESSION_ID   Validate specific session"
    echo "  cost SESSION_ID       Calculate cost savings for session"
    echo "  help                  Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 validate-all"
    echo "  $0 validate ep_001_20250814_test"
    echo "  $0 cost ep_001_20250814_test"
}

# Main execution
main() {
    case ${1:-validate-all} in
        "validate-all")
            validate_all_sessions
            ;;
        "validate")
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Session ID required${NC}"
                show_help
                exit 1
            fi
            quick_validate "$2"
            ;;
        "cost")
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Session ID required${NC}"
                show_help
                exit 1
            fi
            calculate_potential_savings "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Initialize logging
echo "Checkpoint validation started at $(date)" > "$VALIDATION_LOG"
log "Validation log: $VALIDATION_LOG"

# Run main function with all arguments
main "$@"
exit_code=$?

log "Checkpoint validation completed with exit code: $exit_code"
echo ""
echo "📄 Detailed log: $VALIDATION_LOG"

exit $exit_code