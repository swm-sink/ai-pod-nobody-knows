#!/usr/bin/env bash

# Enhanced Checkpoint Integrity Validator - Nobody Knows Podcast Production
# Comprehensive validation system for checkpoint data integrity and consistency

set -e

echo "🔐 Nobody Knows Podcast - Checkpoint Integrity Validator v2.5"
echo "══════════════════════════════════════════════════════════════"
echo "  Enhanced Validation | Data Integrity | Dependency Checking"
echo ""

# Technical: Advanced checkpoint validation implementing integrity checks, dependency validation, and consistency verification
# Simple: Like a thorough accountant who checks that all the numbers add up and make sense together

# Configuration
BASE_PATH="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/level-2-production"
SESSIONS_PATH="${BASE_PATH}/sessions"
VALIDATION_LOG="/tmp/checkpoint_integrity_$(date +%Y%m%d_%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Checkpoint specifications with dependencies (using arrays for compatibility)
CHECKPOINT_FILES=(
    "01_deep_research_complete.json"
    "02_questions_complete.json"
    "03_synthesis_complete.json"
    "04_planning_complete.json"
    "05_script_complete.json"
    "07_tts_optimization_complete.json"
    "09_audio_synthesis_complete.json"
)

CHECKPOINT_COSTS=(
    "7.50"
    "0.50"
    "12.00"
    "0.25"
    "1.50"
    "2.25"
    "10.50"
)

CHECKPOINT_TYPES=(
    "research"
    "questions"
    "synthesis"
    "planning"
    "script"
    "tts_optimization"
    "audio_synthesis"
)

CHECKPOINT_DEPENDENCIES=(
    "none"
    "01_deep_research_complete.json"
    "02_questions_complete.json"
    "03_synthesis_complete.json"
    "04_planning_complete.json"
    "05_script_complete.json"
    "07_tts_optimization_complete.json"
)

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$VALIDATION_LOG"
    echo "$1"
}

# Enhanced JSON validation
validate_json_structure() {
    local file="$1"
    local required_fields="$2"
    local checkpoint_type="$3"
    
    log "  🔍 Validating JSON structure for $checkpoint_type"
    
    # Basic JSON syntax
    if ! jq -e . "$file" >/dev/null 2>&1; then
        log "    ❌ Invalid JSON syntax"
        return 1
    fi
    
    # Required field validation
    local missing_fields=()
    IFS=',' read -ra fields <<< "$required_fields"
    for field in "${fields[@]}"; do
        if ! jq -e ".$field" "$file" >/dev/null 2>&1; then
            missing_fields+=("$field")
        fi
    done
    
    if [[ ${#missing_fields[@]} -gt 0 ]]; then
        log "    ❌ Missing required fields: ${missing_fields[*]}"
        return 1
    fi
    
    # Checkpoint-specific validation
    local status=$(jq -r '.status' "$file" 2>/dev/null)
    if [[ "$status" != "completed" ]]; then
        log "    ⚠️  Checkpoint status: $status (expected: completed)"
        return 1
    fi
    
    # Timestamp validation
    local timestamp=$(jq -r '.timestamp' "$file" 2>/dev/null)
    if [[ "$timestamp" == "null" || -z "$timestamp" ]]; then
        log "    ❌ Invalid or missing timestamp"
        return 1
    fi
    
    # Cost validation
    local cost_invested=$(jq -r '.cost_invested' "$file" 2>/dev/null)
    if [[ "$cost_invested" == "null" || "$cost_invested" == "0" ]]; then
        log "    ⚠️  No cost investment recorded"
    fi
    
    log "    ✅ JSON structure valid"
    return 0
}

# Content integrity validation
validate_content_integrity() {
    local file="$1"
    local checkpoint_type="$2"
    
    log "  🧩 Validating content integrity for $checkpoint_type"
    
    case "$checkpoint_type" in
        "research")
            # Validate research-specific content
            local research_depth=$(jq -r '.research_results.depth_score // 0' "$file" 2>/dev/null)
            local topic_coverage=$(jq -r '.research_results.topic_coverage // 0' "$file" 2>/dev/null)
            local perplexity_calls=$(jq -r '.research_results.perplexity_calls // 0' "$file" 2>/dev/null)
            
            if [[ $(echo "$research_depth < 0.7" | bc -l) -eq 1 ]]; then
                log "    ⚠️  Low research depth: $research_depth (expected ≥0.7)"
            fi
            
            if [[ $(echo "$topic_coverage < 0.8" | bc -l) -eq 1 ]]; then
                log "    ⚠️  Low topic coverage: $topic_coverage (expected ≥0.8)"
            fi
            
            if [[ "$perplexity_calls" -lt 50 ]]; then
                log "    ⚠️  Low API call count: $perplexity_calls (expected ≥50)"
            fi
            ;;
            
        "questions")
            # Validate question generation content
            local question_count=$(jq -r '.question_results.total_questions // 0' "$file" 2>/dev/null)
            local high_priority=$(jq -r '.question_results.high_priority // 0' "$file" 2>/dev/null)
            
            if [[ "$question_count" -lt 30 ]]; then
                log "    ❌ Insufficient questions: $question_count (expected ≥30)"
                return 1
            fi
            
            if [[ "$high_priority" -lt 10 ]]; then
                log "    ⚠️  Few high-priority questions: $high_priority (expected ≥10)"
            fi
            ;;
            
        "synthesis")
            # Validate synthesis content
            local perplexity_calls=$(jq -r '.synthesis_results.perplexity_calls // 0' "$file" 2>/dev/null)
            local research_words=$(jq -r '.synthesis_results.total_research_words // 0' "$file" 2>/dev/null)
            local coverage_score=$(jq -r '.quality_validation.research_completeness // 0' "$file" 2>/dev/null)
            
            if [[ "$perplexity_calls" -lt 100 ]]; then
                log "    ❌ Insufficient research calls: $perplexity_calls (expected ≥100)"
                return 1
            fi
            
            if [[ "$research_words" -lt 15000 ]]; then
                log "    ⚠️  Low research content: $research_words words (expected ≥15,000)"
            fi
            
            if [[ $(echo "$coverage_score < 0.85" | bc -l) -eq 1 ]]; then
                log "    ⚠️  Low coverage score: $coverage_score (expected ≥0.85)"
            fi
            ;;
            
        "planning")
            # Validate episode planning content
            local duration_target=$(jq -r '.planning_results.duration_target // ""' "$file" 2>/dev/null)
            local segment_count=$(jq -r '.planning_results.segment_count // 0' "$file" 2>/dev/null)
            
            if [[ "$duration_target" != "47+ minutes" && "$duration_target" != "47 minutes" ]]; then
                log "    ❌ Incorrect duration target: $duration_target (expected: 47+ minutes)"
                return 1
            fi
            
            if [[ "$segment_count" -lt 8 ]]; then
                log "    ⚠️  Few content segments: $segment_count (expected ≥8 for 47-minute episode)"
            fi
            ;;
            
        "script")
            # Validate script content
            local character_count=$(jq -r '.script_results.character_count // 0' "$file" 2>/dev/null)
            local word_count=$(jq -r '.script_results.word_count // 0' "$file" 2>/dev/null)
            local duration_estimate=$(jq -r '.script_results.estimated_duration // 0' "$file" 2>/dev/null)
            
            if [[ "$character_count" -lt 30000 ]]; then
                log "    ❌ Script too short: $character_count chars (expected ≥30,000 for 47 minutes)"
                return 1
            fi
            
            if [[ "$word_count" -lt 6000 ]]; then
                log "    ❌ Script too short: $word_count words (expected ≥6,000 for 47 minutes)"
                return 1
            fi
            
            if [[ $(echo "$duration_estimate < 40" | bc -l) -eq 1 ]]; then
                log "    ⚠️  Short duration estimate: $duration_estimate minutes (expected ≥40)"
            fi
            ;;
            
        "tts_optimization")
            # Validate TTS optimization content
            local audio_tags=$(jq -r '.optimization_results.audio_tags_applied // 0' "$file" 2>/dev/null)
            local optimization_ratio=$(jq -r '.quality_metrics.optimization_ratio // 0' "$file" 2>/dev/null)
            local voice_model=$(jq -r '.optimization_results.target_model // ""' "$file" 2>/dev/null)
            
            if [[ "$audio_tags" -lt 20 ]]; then
                log "    ⚠️  Few audio tags: $audio_tags (expected ≥20 for 47-minute episode)"
            fi
            
            if [[ "$voice_model" != "eleven_turbo_v2_5" ]]; then
                log "    ❌ Wrong voice model: $voice_model (expected: eleven_turbo_v2_5)"
                return 1
            fi
            ;;
            
        "audio_synthesis")
            # Validate audio synthesis content
            local duration_minutes=$(jq -r '.synthesis_results.duration_minutes // 0' "$file" 2>/dev/null)
            local voice_used=$(jq -r '.synthesis_results.voice_used // ""' "$file" 2>/dev/null)
            local model_used=$(jq -r '.synthesis_results.model_used // ""' "$file" 2>/dev/null)
            
            if [[ $(echo "$duration_minutes < 40" | bc -l) -eq 1 ]]; then
                log "    ❌ Audio too short: $duration_minutes minutes (expected ≥40)"
                return 1
            fi
            
            if [[ "$voice_used" != "Amelia" ]]; then
                log "    ❌ Wrong voice: $voice_used (expected: Amelia)"
                return 1
            fi
            
            if [[ "$model_used" != "eleven_turbo_v2_5" ]]; then
                log "    ❌ Wrong model: $model_used (expected: eleven_turbo_v2_5)"
                return 1
            fi
            ;;
    esac
    
    log "    ✅ Content integrity validated"
    return 0
}

# Dependency chain validation
validate_dependencies() {
    local session_path="$1"
    local checkpoint_file="$2"
    local dependencies="$3"
    
    if [[ "$dependencies" == "none" ]]; then
        log "  🔗 No dependencies for $checkpoint_file"
        return 0
    fi
    
    log "  🔗 Validating dependencies for $checkpoint_file"
    
    IFS=',' read -ra deps <<< "$dependencies"
    for dep in "${deps[@]}"; do
        local dep_path="${session_path}/${dep}"
        
        if [[ ! -f "$dep_path" ]]; then
            log "    ❌ Missing dependency: $dep"
            return 1
        fi
        
        # Validate dependency is completed
        if ! jq -e . "$dep_path" >/dev/null 2>&1; then
            log "    ❌ Invalid dependency JSON: $dep"
            return 1
        fi
        
        local dep_status=$(jq -r '.status' "$dep_path" 2>/dev/null)
        if [[ "$dep_status" != "completed" ]]; then
            log "    ❌ Dependency not completed: $dep (status: $dep_status)"
            return 1
        fi
        
        log "    ✅ Dependency validated: $dep"
    done
    
    return 0
}

# Cross-checkpoint consistency validation
validate_consistency() {
    local session_path="$1"
    local session_id="$2"
    
    log "🔄 Validating cross-checkpoint consistency"
    
    # Check session ID consistency across all checkpoints
    local session_ids=()
    for checkpoint_file in "${CHECKPOINT_FILES[@]}"; do
        local file_path="${session_path}/${checkpoint_file}"
        if [[ -f "$file_path" ]]; then
            local checkpoint_session=$(jq -r '.session_id' "$file_path" 2>/dev/null)
            if [[ "$checkpoint_session" != "$session_id" ]]; then
                log "  ❌ Session ID mismatch in $checkpoint_file: $checkpoint_session vs $session_id"
                return 1
            fi
            session_ids+=("$checkpoint_session")
        fi
    done
    
    # Check episode number consistency
    local episode_numbers=()
    for checkpoint_file in "${CHECKPOINT_FILES[@]}"; do
        local file_path="${session_path}/${checkpoint_file}"
        if [[ -f "$file_path" ]]; then
            local episode_num=$(jq -r '.episode_number' "$file_path" 2>/dev/null)
            if [[ "$episode_num" != "null" ]]; then
                episode_numbers+=("$episode_num")
            fi
        fi
    done
    
    # Validate all episode numbers are the same
    if [[ ${#episode_numbers[@]} -gt 1 ]]; then
        local first_episode="${episode_numbers[0]}"
        for episode_num in "${episode_numbers[@]}"; do
            if [[ "$episode_num" != "$first_episode" ]]; then
                log "  ❌ Episode number inconsistency: $episode_num vs $first_episode"
                return 1
            fi
        done
    fi
    
    # Check timestamp sequence (simplified)
    log "  ⏰ Validating timestamp sequence"
    
    # Basic timestamp validation - check that files exist in logical order
    local research_ts=""
    local questions_ts=""
    local planning_ts=""
    local script_ts=""
    
    if [[ -f "${session_path}/01_deep_research_complete.json" ]]; then
        research_ts=$(jq -r '.timestamp' "${session_path}/01_deep_research_complete.json" 2>/dev/null)
    fi
    
    if [[ -f "${session_path}/02_questions_complete.json" ]]; then
        questions_ts=$(jq -r '.timestamp' "${session_path}/02_questions_complete.json" 2>/dev/null)
    fi
    
    if [[ -f "${session_path}/04_planning_complete.json" ]]; then
        planning_ts=$(jq -r '.timestamp' "${session_path}/04_planning_complete.json" 2>/dev/null)
    fi
    
    if [[ -f "${session_path}/05_script_complete.json" ]]; then
        script_ts=$(jq -r '.timestamp' "${session_path}/05_script_complete.json" 2>/dev/null)
    fi
    
    # Basic sequence checks
    if [[ -n "$research_ts" && -n "$questions_ts" ]]; then
        if [[ "$research_ts" > "$questions_ts" ]]; then
            log "  ❌ Timestamp sequence error: research after questions"
            return 1
        fi
    fi
    
    if [[ -n "$planning_ts" && -n "$script_ts" ]]; then
        if [[ "$planning_ts" > "$script_ts" ]]; then
            log "  ❌ Timestamp sequence error: planning after script"
            return 1
        fi
    fi
    
    log "  ✅ Cross-checkpoint consistency validated"
    return 0
}

# Comprehensive session validation
validate_session_integrity() {
    local session_path="$1"
    local session_id="$2"
    
    log ""
    log "${BLUE}🔐 COMPREHENSIVE INTEGRITY VALIDATION: $session_id${NC}"
    log "═══════════════════════════════════════════════════════════"
    
    local total_files=0
    local valid_files=0
    local total_cost_protected=0
    local validation_errors=0
    
    # Validate each checkpoint file
    for i in "${!CHECKPOINT_FILES[@]}"; do
        local checkpoint_file="${CHECKPOINT_FILES[$i]}"
        local cost="${CHECKPOINT_COSTS[$i]}"
        local checkpoint_type="${CHECKPOINT_TYPES[$i]}"
        local dependencies="${CHECKPOINT_DEPENDENCIES[$i]}"
        local file_path="${session_path}/${checkpoint_file}"
        
        log ""
        log "${PURPLE}📋 Validating: $checkpoint_file${NC}"
        log "─────────────────────────────────────────────────────────"
        
        if [[ ! -f "$file_path" ]]; then
            log "  ⭕ File not found (expected for incomplete pipeline)"
            continue
        fi
        
        ((total_files++))
        
        # Run all validation checks
        local file_valid=true
        
        if ! validate_json_structure "$file_path" "checkpoint_type,session_id,status,timestamp,cost_invested" "$checkpoint_type"; then
            file_valid=false
            ((validation_errors++))
        fi
        
        if ! validate_content_integrity "$file_path" "$checkpoint_type"; then
            file_valid=false
            ((validation_errors++))
        fi
        
        if ! validate_dependencies "$session_path" "$checkpoint_file" "$dependencies"; then
            file_valid=false
            ((validation_errors++))
        fi
        
        if [[ "$file_valid" == true ]]; then
            log "  ${GREEN}✅ CHECKPOINT VALID${NC} (Protected: \$${cost})"
            ((valid_files++))
            total_cost_protected=$(echo "$total_cost_protected + $cost" | bc -l)
        else
            log "  ${RED}❌ CHECKPOINT INVALID${NC}"
        fi
    done
    
    # Cross-checkpoint consistency validation
    if [[ "$total_files" -gt 1 ]]; then
        if ! validate_consistency "$session_path" "$session_id"; then
            ((validation_errors++))
        fi
    fi
    
    log ""
    log "${BLUE}📊 INTEGRITY VALIDATION SUMMARY${NC}"
    log "═══════════════════════════════════════════════════════════"
    log "  Session: $session_id"
    log "  Checkpoint files found: $total_files"
    log "  Valid checkpoints: $valid_files"
    log "  Validation errors: $validation_errors"
    log "  Cost protected: \$${total_cost_protected}"
    
    if [[ "$validation_errors" -eq 0 && "$total_files" -gt 0 ]]; then
        log "  ${GREEN}🎉 INTEGRITY STATUS: EXCELLENT${NC}"
        log "  All found checkpoints passed comprehensive validation"
        return 0
    elif [[ "$valid_files" -gt 0 ]]; then
        log "  ${YELLOW}⚠️  INTEGRITY STATUS: PARTIAL${NC}"
        log "  Some checkpoints have issues requiring attention"
        return 1
    else
        log "  ${RED}❌ INTEGRITY STATUS: FAILED${NC}"
        log "  No valid checkpoints or serious integrity issues found"
        return 2
    fi
}

# Main execution
main() {
    case "${1:-}" in
        "help"|"-h"|"--help")
            echo "Enhanced Checkpoint Integrity Validator"
            echo ""
            echo "Usage: $0 [COMMAND] [SESSION_ID]"
            echo ""
            echo "Commands:"
            echo "  validate SESSION_ID   Comprehensive integrity validation"
            echo "  all                   Validate all sessions"
            echo "  help                  Show this help"
            echo ""
            echo "Features:"
            echo "  • JSON structure and syntax validation"
            echo "  • Content integrity and completeness checks"
            echo "  • Dependency chain validation"
            echo "  • Cross-checkpoint consistency verification"
            echo "  • Timestamp sequence validation"
            echo "  • Cost protection verification"
            ;;
        "validate")
            if [[ -z "$2" ]]; then
                echo -e "${RED}Error: Session ID required${NC}"
                exit 1
            fi
            local session_path="${SESSIONS_PATH}/$2"
            if [[ ! -d "$session_path" ]]; then
                echo -e "${RED}Error: Session not found: $2${NC}"
                exit 1
            fi
            validate_session_integrity "$session_path" "$2"
            exit_code=$?
            log ""
            log "📄 Detailed validation log: $VALIDATION_LOG"
            exit $exit_code
            ;;
        "all")
            local total_sessions=0
            local valid_sessions=0
            
            for session_dir in "$SESSIONS_PATH"/*; do
                if [[ -d "$session_dir" ]]; then
                    local session_name=$(basename "$session_dir")
                    ((total_sessions++))
                    
                    if validate_session_integrity "$session_dir" "$session_name"; then
                        ((valid_sessions++))
                    fi
                fi
            done
            
            log ""
            log "${BLUE}🎯 SYSTEM-WIDE INTEGRITY REPORT${NC}"
            log "═══════════════════════════════════════════════════════════"
            log "  Total sessions: $total_sessions"
            log "  Sessions with valid checkpoints: $valid_sessions"
            
            if [[ "$valid_sessions" -eq "$total_sessions" && "$total_sessions" -gt 0 ]]; then
                log "  ${GREEN}🎉 SYSTEM INTEGRITY: EXCELLENT${NC}"
                exit 0
            else
                log "  ${YELLOW}⚠️  SYSTEM INTEGRITY: NEEDS ATTENTION${NC}"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Unknown command: ${1:-validate}${NC}"
            echo "Use: $0 help"
            exit 1
            ;;
    esac
}

# Initialize logging
echo "Enhanced checkpoint integrity validation started at $(date)" > "$VALIDATION_LOG"

# Run main function
main "$@"