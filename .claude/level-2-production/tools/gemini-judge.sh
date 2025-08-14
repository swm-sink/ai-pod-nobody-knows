#!/bin/bash

# ============================================================================
# GEMINI CLI QUALITY JUDGE UTILITY
# ============================================================================
# Purpose: Reusable script for evaluating podcast scripts with Gemini CLI
# Usage: ./gemini-judge.sh <script_file> [episode_number] [output_dir]
# Author: Claude Code AI Assistant
# Version: 1.0.0
# ============================================================================

set -e

# Configuration
SCRIPT_FILE="${1:-}"
EPISODE_NUM="${2:-001}"
OUTPUT_DIR="${3:-.claude/level-2-production/sessions}"
TEMPLATE_FILE=".claude/level-2-production/templates/gemini-evaluation-prompt.txt"
MAX_RETRIES=3
TIMEOUT_SECONDS=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# FUNCTIONS
# ============================================================================

show_usage() {
    cat << EOF
${BOLD}GEMINI CLI QUALITY JUDGE${NC}

${BOLD}Usage:${NC}
    $0 <script_file> [episode_number] [output_dir]

${BOLD}Arguments:${NC}
    script_file     Path to the podcast script (required)
    episode_number  Episode number for tracking (default: 001)
    output_dir      Output directory for results (default: .claude/level-2-production/sessions)

${BOLD}Examples:${NC}
    $0 script.md
    $0 script.md 042
    $0 script.md 042 ./output

${BOLD}Output:${NC}
    - JSON evaluation results
    - Quality scores (1-5 Likert scale)
    - Pass/Fail determination
    - Cost tracking

EOF
    exit 1
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_dependencies() {
    # Check Gemini CLI
    if ! command -v gemini &> /dev/null; then
        log_error "Gemini CLI not found!"
        echo "Install with: npm install -g @google/gemini-cli"
        echo "Documentation: .claude/context/tools/gemini-cli-quality-judge-guide.xml"
        exit 1
    fi
    
    # Check jq for JSON processing
    if ! command -v jq &> /dev/null; then
        log_warning "jq not found - JSON validation will be limited"
    fi
    
    # Check bc for calculations
    if ! command -v bc &> /dev/null; then
        log_warning "bc not found - cost calculations will be skipped"
    fi
}

validate_inputs() {
    if [[ -z "$SCRIPT_FILE" ]]; then
        log_error "Script file not provided"
        show_usage
    fi
    
    if [[ ! -f "$SCRIPT_FILE" ]]; then
        log_error "Script file not found: $SCRIPT_FILE"
        exit 1
    fi
    
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        log_warning "Template file not found: $TEMPLATE_FILE"
        log_info "Using inline prompt instead"
    fi
    
    # Create output directory if needed
    mkdir -p "$OUTPUT_DIR"
}

create_evaluation_prompt() {
    local temp_prompt="/tmp/gemini_prompt_$$.txt"
    
    if [[ -f "$TEMPLATE_FILE" ]]; then
        cp "$TEMPLATE_FILE" "$temp_prompt"
    else
        # Inline prompt if template not found
        cat > "$temp_prompt" << 'EOF'
Evaluate this podcast script using a 1-5 Likert scale.
Output ONLY valid JSON with these exact fields:
{
  "evaluation_id": "gemini_evaluation",
  "timestamp": "2025-01-14T00:00:00Z",
  "model": "gemini-2.5-flash",
  "scores": {
    "factual_accuracy": [1-5],
    "audience_comprehension": [1-5],
    "brand_alignment": [1-5],
    "engagement_quality": [1-5]
  },
  "weighted_average": [float],
  "pass_threshold": 3.5,
  "pass_fail": "PASS or FAIL",
  "critical_issues": [],
  "improvements": [],
  "strengths": [],
  "metrics": {
    "word_count": 0,
    "humility_phrases": 0,
    "questions_count": 0,
    "estimated_duration": 0.0
  }
}
SCRIPT TO EVALUATE:
EOF
    fi
    
    echo "$temp_prompt"
}

execute_gemini_evaluation() {
    local prompt_file="$1"
    local output_file="$2"
    local attempt=0
    local success=false
    
    while [[ $attempt -lt $MAX_RETRIES ]] && [[ "$success" == "false" ]]; do
        if [[ $attempt -gt 0 ]]; then
            local wait_time=$((2 ** attempt))
            log_info "Retry attempt $((attempt + 1)) after ${wait_time}s wait..."
            sleep $wait_time
        fi
        
        log_info "Executing Gemini evaluation (attempt $((attempt + 1))/$MAX_RETRIES)..."
        
        # Execute with timeout
        if timeout $TIMEOUT_SECONDS bash -c "cat '$prompt_file' '$SCRIPT_FILE' | gemini -p - 2>/dev/null" > "$output_file"; then
            # Try to validate JSON
            if command -v jq &> /dev/null; then
                if jq empty "$output_file" 2>/dev/null; then
                    success=true
                    log_success "Valid JSON response received"
                else
                    # Try to extract JSON from mixed output
                    sed -n '/^{/,/^}/p' "$output_file" > "${output_file}.clean"
                    if jq empty "${output_file}.clean" 2>/dev/null; then
                        mv "${output_file}.clean" "$output_file"
                        success=true
                        log_success "JSON extracted from response"
                    else
                        log_warning "Invalid JSON response"
                    fi
                fi
            else
                # Without jq, just check if we got something
                if [[ -s "$output_file" ]]; then
                    success=true
                    log_info "Response received (JSON validation skipped)"
                fi
            fi
        else
            log_warning "Evaluation timed out or failed"
        fi
        
        attempt=$((attempt + 1))
    done
    
    if [[ "$success" == "false" ]]; then
        log_error "All evaluation attempts failed"
        return 1
    fi
    
    return 0
}

process_results() {
    local result_file="$1"
    
    if command -v jq &> /dev/null; then
        # Extract and display key metrics
        local weighted_avg=$(jq -r '.weighted_average // "N/A"' "$result_file" 2>/dev/null)
        local pass_fail=$(jq -r '.pass_fail // "ERROR"' "$result_file" 2>/dev/null)
        local factual=$(jq -r '.scores.factual_accuracy // 0' "$result_file" 2>/dev/null)
        local comprehension=$(jq -r '.scores.audience_comprehension // 0' "$result_file" 2>/dev/null)
        local brand=$(jq -r '.scores.brand_alignment // 0' "$result_file" 2>/dev/null)
        local engagement=$(jq -r '.scores.engagement_quality // 0' "$result_file" 2>/dev/null)
        
        echo ""
        echo "╔════════════════════════════════════════════════════════╗"
        echo "║          GEMINI QUALITY EVALUATION RESULTS            ║"
        echo "╚════════════════════════════════════════════════════════╝"
        echo ""
        echo "  Episode:              $EPISODE_NUM"
        echo "  Overall Score:        ${weighted_avg}/5.0"
        echo "  Status:               $pass_fail"
        echo ""
        echo "  Individual Scores (1-5 scale):"
        echo "  ├─ Factual Accuracy:     $factual"
        echo "  ├─ Comprehension:        $comprehension"
        echo "  ├─ Brand Alignment:      $brand"
        echo "  └─ Engagement:           $engagement"
        echo ""
        
        if [[ "$pass_fail" == "PASS" ]]; then
            echo -e "  ${GREEN}✓ Quality threshold met${NC}"
        elif [[ "$pass_fail" == "FAIL" ]]; then
            echo -e "  ${RED}✗ Below quality threshold${NC}"
        else
            echo -e "  ${YELLOW}⚠ Evaluation inconclusive${NC}"
        fi
    else
        echo "Results saved (install jq for detailed display)"
    fi
}

calculate_cost() {
    local script_file="$1"
    
    if command -v bc &> /dev/null; then
        local word_count=$(wc -w < "$script_file")
        local input_tokens=$((word_count * 4 / 3))
        local output_tokens=500
        
        # Gemini 2.5 Flash pricing
        local input_cost=$(echo "scale=8; $input_tokens * 0.00000015" | bc)
        local output_cost=$(echo "scale=8; $output_tokens * 0.0000006" | bc)
        local total_cost=$(echo "scale=8; $input_cost + $output_cost" | bc)
        
        echo ""
        echo "  Cost Analysis:"
        echo "  ├─ Input tokens:  ~$input_tokens"
        echo "  ├─ Output tokens: ~$output_tokens"
        echo "  └─ Total cost:    \$$total_cost"
        
        # Log to cost file if directory exists
        if [[ -d ".claude/logs" ]]; then
            echo "$(date -Iseconds),gemini_evaluation,$total_cost" >> .claude/logs/api_costs.csv
        fi
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo -e "${BOLD}GEMINI CLI QUALITY JUDGE v1.0.0${NC}"
    echo "════════════════════════════════════════"
    
    # Check dependencies
    check_dependencies
    
    # Validate inputs
    validate_inputs
    
    # Prepare files
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local session_id="${EPISODE_NUM}_${timestamp}"
    local prompt_file=$(create_evaluation_prompt)
    local output_file="$OUTPUT_DIR/gemini_evaluation_${session_id}.json"
    
    log_info "Evaluating script: $SCRIPT_FILE"
    log_info "Episode: $EPISODE_NUM"
    log_info "Output: $output_file"
    
    # Execute evaluation
    if execute_gemini_evaluation "$prompt_file" "$output_file"; then
        # Process and display results
        process_results "$output_file"
        
        # Calculate cost
        calculate_cost "$SCRIPT_FILE"
        
        echo ""
        log_success "Evaluation complete!"
        echo "  Results saved to: $output_file"
        
        # Cleanup
        rm -f "$prompt_file"
        
        exit 0
    else
        log_error "Evaluation failed after $MAX_RETRIES attempts"
        
        # Create error output
        cat > "$output_file" << EOF
{
  "evaluation_id": "gemini_${session_id}_error",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "error": "Evaluation failed after $MAX_RETRIES attempts",
  "pass_fail": "ERROR"
}
EOF
        
        # Cleanup
        rm -f "$prompt_file"
        
        exit 1
    fi
}

# Run main function
main "$@"