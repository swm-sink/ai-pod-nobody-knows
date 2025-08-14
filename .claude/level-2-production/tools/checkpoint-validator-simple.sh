#!/usr/bin/env bash

# Simple Checkpoint Validation Script for Nobody Knows Podcast Production
# Compatible with macOS default bash 3.2

set -e

echo "🔍 Nobody Knows Podcast - Checkpoint Validation (Simple)"
echo "======================================================="

# Configuration
BASE_PATH="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/level-2-production/sessions"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Checkpoint specifications (simple arrays)
CHECKPOINT_FILES=(
    "01_deep_research_complete.json"
    "02_questions_complete.json"
    "03_synthesis_complete.json"
    "04_planning_complete.json"
    "05_script_complete.json"
)

CHECKPOINT_COSTS=(
    "7.50"
    "0.50"
    "12.00"
    "0.25"
    "1.50"
)

get_cost_for_file() {
    local filename=$1
    for i in "${!CHECKPOINT_FILES[@]}"; do
        if [ "${CHECKPOINT_FILES[$i]}" = "$filename" ]; then
            echo "${CHECKPOINT_COSTS[$i]}"
            return
        fi
    done
    echo "0"
}

validate_json() {
    local file=$1
    if python3 -m json.tool "$file" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

validate_structure() {
    local file=$1
    python3 -c "
import json, sys
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    required = ['checkpoint_type', 'session_id', 'episode_number', 'status', 'timestamp', 'cost_invested']
    for field in required:
        if field not in data:
            print('Missing field: ' + field)
            sys.exit(1)
    print('Structure valid')
    sys.exit(0)
except Exception as e:
    print('Error: ' + str(e))
    sys.exit(1)" 2>/dev/null
    return $?
}

validate_cost() {
    local file=$1
    local expected=$2
    local actual=$(python3 -c "
import json
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    print('{:.2f}'.format(float(data.get('cost_invested', 0))))
except:
    print('0.00')" 2>/dev/null)

    if [ "$actual" = "$expected" ]; then
        return 0
    else
        echo "Cost mismatch: expected $expected, got $actual"
        return 1
    fi
}

validate_session() {
    local session_path=$1
    local session_name=$(basename "$session_path")

    echo ""
    echo -e "${BLUE}📁 Validating Session: $session_name${NC}"

    if [ ! -d "$session_path" ]; then
        echo -e "${RED}❌ Session directory not found${NC}"
        return 1
    fi

    local files_validated=0
    local total_protection=0
    local validation_passed=true

    for i in "${!CHECKPOINT_FILES[@]}"; do
        local checkpoint_file="${CHECKPOINT_FILES[$i]}"
        local expected_cost="${CHECKPOINT_COSTS[$i]}"
        local full_path="$session_path/$checkpoint_file"

        echo -n "  🔍 $checkpoint_file..."

        if [ ! -f "$full_path" ]; then
            echo -e " ${YELLOW}⚠️  Missing${NC}"
            continue
        fi

        if ! validate_json "$full_path"; then
            echo -e " ${RED}❌ Invalid JSON${NC}"
            validation_passed=false
            continue
        fi

        if ! validate_structure "$full_path"; then
            echo -e " ${RED}❌ Invalid Structure${NC}"
            validation_passed=false
            continue
        fi

        if ! validate_cost "$full_path" "$expected_cost"; then
            echo -e " ${RED}❌ Cost Error${NC}"
            validation_passed=false
            continue
        fi

        echo -e " ${GREEN}✅ Valid${NC}"
        files_validated=$((files_validated + 1))
        total_protection=$(echo "$total_protection + $expected_cost" | bc -l)
    done

    echo ""
    echo "  📊 Session Summary:"
    echo "     Files validated: $files_validated/5"
    echo "     Cost protection: \$$total_protection"

    if [ "$files_validated" -gt 0 ]; then
        local percentage=$(echo "scale=1; $total_protection / 21.75 * 100" | bc -l)
        echo "     Pipeline coverage: ${percentage}%"

        if [ "$total_protection" = "21.75" ]; then
            echo -e "${GREEN}     💰 FULL PROTECTION: Complete pipeline can be skipped${NC}"
        elif [ "$(echo "$total_protection >= 12.00" | bc -l)" = "1" ]; then
            echo -e "${GREEN}     💰 MAJOR SAVINGS: Research synthesis protected (\$12.00)${NC}"
        elif [ "$(echo "$total_protection >= 7.50" | bc -l)" = "1" ]; then
            echo -e "${YELLOW}     💰 GOOD SAVINGS: Deep research protected (\$7.50)${NC}"
        fi
    fi

    if $validation_passed && [ "$files_validated" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

calculate_savings() {
    local session_path=$1
    echo "💰 Cost Analysis: $(basename "$session_path")"

    if [ ! -d "$session_path" ]; then
        echo -e "${RED}Session not found${NC}"
        return 1
    fi

    local total_savings=0
    local files_found=0

    for i in "${!CHECKPOINT_FILES[@]}"; do
        local checkpoint_file="${CHECKPOINT_FILES[$i]}"
        local cost="${CHECKPOINT_COSTS[$i]}"
        local full_path="$session_path/$checkpoint_file"

        if [ -f "$full_path" ]; then
            total_savings=$(echo "$total_savings + $cost" | bc -l)
            files_found=$((files_found + 1))
        fi
    done

    echo "Checkpoint files found: $files_found/5"
    echo "Potential savings: \$$total_savings"

    if [ "$(echo "$total_savings > 0" | bc -l)" = "1" ]; then
        local percentage=$(echo "scale=1; $total_savings / 21.75 * 100" | bc -l)
        echo "Cost reduction: ${percentage}%"

        local remaining_cost=$(echo "21.75 - $total_savings" | bc -l)
        echo "Remaining pipeline cost: \$$remaining_cost"
    fi
}

validate_all() {
    echo "🚀 Validating All Sessions"

    local total_sessions=0
    local valid_sessions=0

    if [ ! -d "$BASE_PATH" ]; then
        echo -e "${RED}❌ Base path not found: $BASE_PATH${NC}"
        return 1
    fi

    for session_dir in "$BASE_PATH"/*; do
        if [ -d "$session_dir" ]; then
            total_sessions=$((total_sessions + 1))
            if validate_session "$session_dir"; then
                valid_sessions=$((valid_sessions + 1))
            fi
        fi
    done

    echo ""
    echo "🎯 System Summary"
    echo "================"
    echo "Sessions found: $total_sessions"
    echo "Sessions valid: $valid_sessions"

    if [ "$total_sessions" -gt 0 ]; then
        local success_rate=$(echo "scale=1; $valid_sessions * 100 / $total_sessions" | bc -l)
        echo "Success rate: ${success_rate}%"
    fi

    if [ "$valid_sessions" = "$total_sessions" ] && [ "$total_sessions" -gt 0 ]; then
        echo -e "${GREEN}🎉 ALL SESSIONS VALID${NC}"
        return 0
    elif [ "$valid_sessions" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  PARTIAL SUCCESS${NC}"
        return 1
    else
        echo -e "${RED}❌ NO VALID SESSIONS${NC}"
        return 2
    fi
}

show_help() {
    echo "Simple Checkpoint Validator"
    echo ""
    echo "Usage: $0 [COMMAND] [SESSION_ID]"
    echo ""
    echo "Commands:"
    echo "  all                   Validate all sessions"
    echo "  validate SESSION_ID   Validate specific session"
    echo "  cost SESSION_ID       Show cost savings"
    echo "  help                  Show this help"
}

# Main execution
case ${1:-all} in
    "all")
        validate_all
        ;;
    "validate")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Session ID required${NC}"
            show_help
            exit 1
        fi
        validate_session "$BASE_PATH/$2"
        ;;
    "cost")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Session ID required${NC}"
            show_help
            exit 1
        fi
        calculate_savings "$BASE_PATH/$2"
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
