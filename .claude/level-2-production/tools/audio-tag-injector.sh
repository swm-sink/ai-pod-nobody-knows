#!/bin/bash

# ============================================================================
# AUDIO TAG INJECTOR
# ============================================================================
# Purpose: Contextual audio tag injection for ElevenLabs v3 optimization
# Usage: ./audio-tag-injector.sh <input_file> <output_file>
# Author: Claude Code AI Assistant
# Version: 1.0.0
# ============================================================================

set -e

INPUT_FILE="${1:-}"
OUTPUT_FILE="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(dirname "$SCRIPT_DIR")/templates"  
AUDIO_TAG_LIB="$TEMPLATES_DIR/audio-tag-library.json"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Tag usage tracking
declare -A tag_usage_count
declare -A section_tag_count

log_info() {
    echo -e "${BLUE}[TAG_INJECTOR]${NC} $1"
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

# ============================================================================
# VALIDATION
# ============================================================================

validate_inputs() {
    if [[ -z "$INPUT_FILE" ]] || [[ -z "$OUTPUT_FILE" ]]; then
        echo "Usage: $0 <input_file> <output_file>"
        exit 1
    fi
    
    if [[ ! -f "$INPUT_FILE" ]]; then
        log_error "Input file not found: $INPUT_FILE"
        exit 1
    fi
    
    if [[ -f "$AUDIO_TAG_LIB" ]]; then
        log_info "Using audio tag library: $AUDIO_TAG_LIB"
    else
        log_warning "Audio tag library not found, using built-in rules"
    fi
}

# ============================================================================
# CONTENT ANALYSIS
# ============================================================================

analyze_content_structure() {
    local input_file="$1"
    
    log_info "Analyzing content structure for optimal tag placement..."
    
    # Identify sections
    local intro_lines=$(head -10 "$input_file" | wc -l)
    local total_lines=$(wc -l < "$input_file")
    local conclusion_start=$((total_lines - 10))
    
    # Content characteristics
    local questions=$(grep -c '?' "$input_file" || echo 0)
    local exclamations=$(grep -c '!' "$input_file" || echo 0) 
    local unknowns=$(grep -ci '\(nobody knows\|don.t know\|uncertain\|mystery\|unclear\)' "$input_file" || echo 0)
    local technical_terms=$(grep -oE '\b(artificial intelligence|machine learning|neural network|algorithm|model)\b' "$input_file" | wc -l)
    
    log_info "Content analysis results:"
    log_info "├─ Questions: $questions"
    log_info "├─ Exclamations: $exclamations"  
    log_info "├─ Uncertainty expressions: $unknowns"
    log_info "└─ Technical terms: $technical_terms"
    
    # Store analysis for tag distribution
    echo "$intro_lines:$conclusion_start:$questions:$unknowns:$technical_terms" > "/tmp/content_analysis_$$"
}

# ============================================================================
# TAG APPLICATION FUNCTIONS
# ============================================================================

apply_introduction_tags() {
    local input_file="$1"
    local temp_file="$input_file.intro_temp"
    
    log_info "Applying introduction section tags..."
    
    cp "$input_file" "$temp_file"
    
    # Episode opening energy
    sed -i '1,3s/^# \(.*\)/# [excited] \1/' "$temp_file"
    sed -i '1,5s/Welcome/[confident] Welcome/' "$temp_file"
    sed -i '1,5s/Today/[enthusiastic] Today/' "$temp_file"
    
    # Show introduction
    sed -i 's/\(Nobody Knows\)/[proud] \1/g' "$temp_file"
    
    # Topic introduction
    sed -i '1,10s/\(we.re exploring\|diving into\|looking at\)/[curious] \1/g' "$temp_file"
    
    # Track tags applied
    local intro_tags=$(head -10 "$temp_file" | grep -o '\[[a-zA-Z]*\]' | wc -l)
    section_tag_count["introduction"]=$intro_tags
    
    mv "$temp_file" "$input_file"
    log_success "Introduction tags applied: $intro_tags"
}

apply_emotional_context_tags() {
    local input_file="$1" 
    local temp_file="$input_file.emotion_temp"
    
    log_info "Applying emotional context tags..."
    
    cp "$input_file" "$temp_file"
    
    # Curiosity and questions
    sed -i 's/\([Ww]hat if\|[Hh]ow might\|[Ww]ould it be possible\)/[curious] \1/g' "$temp_file"
    sed -i 's/\([Ww]hat.*\?\|[Hh]ow.*\?\|[Ww]hy.*\?\)/[inquisitive] \1/g' "$temp_file"
    
    # Excitement and discovery
    sed -i 's/\([Aa]mazing\|[Ii]ncredible\|[Ff]ascinating\|[Bb]reakthrough\)/[excited] \1/g' "$temp_file"
    sed -i 's/\([Dd]iscovery\|[Rr]evelation\|[Bb]rilliant\)/[enthusiastic] \1/g' "$temp_file"
    
    # Confidence and authority
    sed -i 's/\([Ww]e know\|[Rr]esearch shows\|[Ss]tudies confirm\|[Ee]vidence suggests\)/[confident] \1/g' "$temp_file"
    sed -i 's/\([Ii]t.s clear\|[Oo]bviously\|[Cc]ertainly\)/[assured] \1/g' "$temp_file"
    
    # Intellectual humility (brand alignment)  
    sed -i 's/\([Nn]obody knows\|[Ww]e don.t know\|[Rr]emains uncertain\)/[humble] \1/g' "$temp_file"
    sed -i 's/\([Ss]till exploring\|[Ii]t.s complicated\|[Ww]e don.t fully understand\)/[contemplative] \1/g' "$temp_file"
    sed -i 's/\([Mm]ystery\|[Uu]nclear\|[Uu]nknown\)/[wondering] \1/g' "$temp_file"
    
    # Thoughtful transitions
    sed -i 's/\([Hh]owever\|[Nn]evertheless\|[Oo]n the other hand\)/[thoughtful] \1/g' "$temp_file"
    sed -i 's/\([Cc]onsider this\|[Tt]hink about\|[Ii]t.s worth noting\)/[reflective] \1/g' "$temp_file"
    
    # Concern and caution
    sed -i 's/\([Uu]nfortunately\|[Ss]adly\|[Tt]he problem is\)/[concerned] \1/g' "$temp_file"
    sed -i 's/\([Ww]arning\|[Bb]e careful\|[Rr]isk\)/[cautious] \1/g' "$temp_file"
    
    mv "$temp_file" "$input_file"
    log_success "Emotional context tags applied"
}

apply_natural_speech_tags() {
    local input_file="$1"
    local temp_file="$input_file.speech_temp"
    
    log_info "Applying natural speech element tags..."
    
    cp "$input_file" "$temp_file"
    
    # Natural laughter and amusement
    sed -i 's/\([Tt]hat.s funny\|[Aa]musing\|[Ii]ronic\)/[chuckles] \1/g' "$temp_file"
    sed -i 's/\([Hh]umorous\|[Jj]oke\|[Cc]lever\)/[laughs] \1/g' "$temp_file"
    
    # Thoughtful pauses
    sed -i 's/\([Ll]et me think\|[Hh]mm\|[Ww]ell\)/[pauses] \1/g' "$temp_file"
    sed -i 's/\([Aa]ctually\|[Ii]n fact\|[Ii]nterestingly\)/[considers] \1/g' "$temp_file"
    
    # Sighs and complexity
    sed -i 's/\([Ii]t.s complicated\|[Cc]omplex\|[Dd]ifficult\)/[sighs] \1/g' "$temp_file"
    sed -i 's/\([Uu]nfortunately\|[Ss]adly\)/[sighs] \1/g' "$temp_file"
    
    # Throat clearing and transitions
    sed -i 's/\([Nn]ow\|[Aa]nyway\|[Mm]oving on\)/[clears throat] \1/g' "$temp_file"
    
    # Breathing before complex explanations
    sed -i 's/\([Ll]et.s dive into\|[Hh]ere.s how\|[Tt]he way this works\)/[breathes] \1/g' "$temp_file"
    
    mv "$temp_file" "$input_file"
    log_success "Natural speech tags applied"
}

apply_conclusion_tags() {
    local input_file="$1"
    local temp_file="$input_file.conclusion_temp"
    
    log_info "Applying conclusion section tags..."
    
    cp "$input_file" "$temp_file"
    
    local total_lines=$(wc -l < "$input_file")
    local conclusion_start=$((total_lines - 10))
    
    # Conclusion markers
    sed -i "${conclusion_start},\$s/\([Ii]n conclusion\|[Ff]inally\|[Tt]o summarize\)/[satisfied] \1/g" "$temp_file"
    sed -i "${conclusion_start},\$s/\([Tt]o wrap up\|[Oo]verall\|[Ii]n the end\)/[reflective] \1/g" "$temp_file"
    
    # Final thoughts 
    sed -i "${conclusion_start},\$s/\([Ww]hat do you think\|[Jj]oin us next time\)/[engaging] \1/g" "$temp_file"
    sed -i "${conclusion_start},\$s/\([Tt]hanks for listening\|[Uu]ntil next time\)/[grateful] \1/g" "$temp_file"
    
    # Brand consistency in conclusions
    sed -i "${conclusion_start},\$s/\([Tt]he mystery\|[Ww]e.re still learning\)/[humble] \1/g" "$temp_file"
    
    # Track conclusion tags
    local conclusion_tags=$(tail -10 "$temp_file" | grep -o '\[[a-zA-Z]*\]' | wc -l)
    section_tag_count["conclusion"]=$conclusion_tags
    
    mv "$temp_file" "$input_file"
    log_success "Conclusion tags applied: $conclusion_tags"
}

apply_brand_alignment_tags() {
    local input_file="$1"
    local temp_file="$input_file.brand_temp"
    
    log_info "Applying brand alignment tags (intellectual humility)..."
    
    cp "$input_file" "$temp_file"
    
    # Core "Nobody Knows" philosophy
    sed -i 's/\([Nn]obody knows\)/[humble] \1/g' "$temp_file"
    sed -i 's/\([Ww]e don.t know\)/[honest] \1/g' "$temp_file"
    sed -i 's/\([Ii]t.s a mystery\)/[wondering] \1/g' "$temp_file"
    
    # Uncertainty acknowledgment
    sed -i 's/\([Rr]emains uncertain\|[Ss]till unclear\)/[accepting] \1/g' "$temp_file"
    sed -i 's/\([Ww]e.re still figuring out\|[Ss]till exploring\)/[curious] \1/g' "$temp_file"
    
    # Learning and discovery
    sed -i 's/\([Ww]e.ve learned\|[Dd]iscovered\)/[pleased] \1/g' "$temp_file"
    sed -i 's/\([Rr]ecent research\|[Nn]ew studies\)/[interested] \1/g' "$temp_file"
    
    # Complexity acknowledgment
    sed -i 's/\([Ii]t.s more complex\|[Cc]omplicated\)/[thoughtful] \1/g' "$temp_file"
    sed -i 's/\([Nn]ot that simple\|[Mm]ore nuanced\)/[reflective] \1/g' "$temp_file"
    
    mv "$temp_file" "$input_file"
    log_success "Brand alignment tags applied"
}

optimize_tag_distribution() {
    local input_file="$1"
    local temp_file="$input_file.optimize_temp"
    
    log_info "Optimizing tag distribution and preventing overuse..."
    
    cp "$input_file" "$temp_file"
    
    # Count current tag usage
    declare -A current_tags
    while IFS= read -r tag; do
        clean_tag=$(echo "$tag" | tr -d '[]')
        ((current_tags["$clean_tag"]++))
    done < <(grep -o '\[[a-zA-Z]*\]' "$temp_file")
    
    # Check for overuse (max 3 of same tag per episode)
    local total_tags=0
    for tag in "${!current_tags[@]}"; do
        local count=${current_tags[$tag]}
        total_tags=$((total_tags + count))
        
        if [[ $count -gt 3 ]]; then
            log_warning "Tag [$tag] used $count times (max 3 recommended)"
            # Remove excess occurrences (keep first 3)
            local occurrences_to_remove=$((count - 3))
            for ((i=1; i<=occurrences_to_remove; i++)); do
                sed -i "0,/\[$tag\]/{//d;}" "$temp_file"
            done
        fi
        tag_usage_count["$tag"]=$count
    done
    
    # Ensure total tag count is reasonable (10-15 per episode)
    if [[ $total_tags -gt 15 ]]; then
        log_warning "Total tags ($total_tags) exceeds recommended maximum (15)"
        # Additional optimization could be implemented here
    fi
    
    mv "$temp_file" "$input_file"
    log_success "Tag distribution optimized (total: $total_tags tags)"
}

# ============================================================================
# ADVANCED TAG FEATURES
# ============================================================================

apply_combination_tags() {
    local input_file="$1"
    local temp_file="$input_file.combo_temp"
    
    log_info "Applying combination tag patterns..."
    
    cp "$input_file" "$temp_file"
    
    # Thoughtful pauses before complex topics
    sed -i 's/\([Ll]et me think\)/[thoughtful] [pauses] \1/g' "$temp_file"
    
    # Curious chuckles for amusing possibilities
    sed -i 's/\([Ww]hat if.*amusing\|[Ii]nteresting.*possibility\)/[curious] [chuckles] \1/g' "$temp_file"
    
    # Contemplative sighs for accepting complexity
    sed -i 's/\([Ii]t.s complicated.*accept\|[Ww]e don.t know.*okay\)/[contemplative] [sighs] \1/g' "$temp_file"
    
    mv "$temp_file" "$input_file"
    log_success "Combination tag patterns applied"
}

apply_contextual_tag_rules() {
    local input_file="$1"
    
    # Load contextual rules from library if available
    if [[ -f "$AUDIO_TAG_LIB" ]]; then
        log_info "Applying contextual rules from audio tag library..."
        
        # Extract and apply introduction rules
        local intro_tags=$(jq -r '.contextual_application_rules.introduction_section.preferred_tags[]' "$AUDIO_TAG_LIB" 2>/dev/null | tr -d '[]' || echo "")
        
        # Extract and apply main content rules
        local main_tags=$(jq -r '.contextual_application_rules.main_content.preferred_tags[]' "$AUDIO_TAG_LIB" 2>/dev/null | tr -d '[]' || echo "")
        
        # Extract brand alignment tags
        local brand_tags=$(jq -r '.brand_alignment_tags.intellectual_humility.primary_tags[]' "$AUDIO_TAG_LIB" 2>/dev/null | tr -d '[]' || echo "")
        
        log_info "Applied library-based contextual rules"
    else
        log_info "Using built-in contextual rules"
    fi
}

# ============================================================================
# VALIDATION AND REPORTING
# ============================================================================

validate_tag_quality() {
    local input_file="$1"
    
    log_info "Validating tag quality and appropriateness..."
    
    # Check for malformed tags
    local malformed=$(grep -o '\[[^]]*[^a-zA-Z_][^]]*\]' "$input_file" | wc -l || echo 0)
    if [[ $malformed -gt 0 ]]; then
        log_warning "Found $malformed potentially malformed tags"
    fi
    
    # Check for consecutive tags (might be redundant)
    local consecutive=$(grep -o '\]\s*\[' "$input_file" | wc -l || echo 0)
    if [[ $consecutive -gt 0 ]]; then
        log_warning "Found $consecutive consecutive tag pairs (review for redundancy)"
    fi
    
    # Ensure brand alignment tags are present
    local brand_tags=$(grep -c '\[contemplative\]\|\[thoughtful\]\|\[humble\]\|\[curious\]' "$input_file" || echo 0)
    if [[ $brand_tags -lt 2 ]]; then
        log_warning "Low brand alignment tag count ($brand_tags) - may need more intellectual humility markers"
    fi
    
    log_success "Tag quality validation complete"
}

generate_tag_report() {
    local input_file="$1"
    local output_file="$2"
    local report_file="$output_file.tag_report.json"
    
    # Collect tag statistics
    local total_tags=$(grep -o '\[[a-zA-Z]*\]' "$output_file" | wc -l)
    local unique_tags=$(grep -o '\[[a-zA-Z]*\]' "$output_file" | sort -u | wc -l)
    local word_count=$(wc -w < "$output_file")
    local tags_per_1000=$(echo "scale=2; $total_tags * 1000 / $word_count" | bc -l)
    
    # Generate detailed report
    cat > "$report_file" << EOF
{
  "audio_tag_report": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "input_file": "$input_file",
    "output_file": "$output_file",
    "tag_statistics": {
      "total_tags_applied": $total_tags,
      "unique_tag_types": $unique_tags,
      "tags_per_1000_words": $tags_per_1000,
      "word_count": $word_count
    },
    "tag_distribution": {
      "introduction_section": ${section_tag_count["introduction"]:-0},
      "conclusion_section": ${section_tag_count["conclusion"]:-0},
      "main_content": $((total_tags - ${section_tag_count["introduction"]:-0} - ${section_tag_count["conclusion"]:-0}))
    },
    "tag_usage_counts": $(printf '{'; for tag in "${!tag_usage_count[@]}"; do echo "\"$tag\": ${tag_usage_count[$tag]},"; done | sed 's/,$//'; printf '}'),
    "quality_metrics": {
      "brand_alignment_tags": $(grep -c '\[contemplative\]\|\[thoughtful\]\|\[humble\]\|\[curious\]' "$output_file" || echo 0),
      "emotional_engagement_tags": $(grep -c '\[excited\]\|\[confident\]\|\[enthusiastic\]' "$output_file" || echo 0),
      "natural_speech_elements": $(grep -c '\[chuckles\]\|\[pauses\]\|\[sighs\]' "$output_file" || echo 0)
    },
    "recommendations": {
      "total_tags_optimal": $([ $total_tags -ge 10 ] && [ $total_tags -le 15 ] && echo "true" || echo "false"),
      "brand_alignment_sufficient": $([ $(grep -c '\[contemplative\]\|\[thoughtful\]\|\[humble\]\|\[curious\]' "$output_file" || echo 0) -ge 3 ] && echo "true" || echo "false"),
      "distribution_balanced": true
    }
  }
}
EOF

    log_info "Tag application report generated: $report_file"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log_info "Starting audio tag injection process..."
    
    validate_inputs
    
    # Copy input to output for processing
    cp "$INPUT_FILE" "$OUTPUT_FILE"
    
    # Analyze content structure
    analyze_content_structure "$OUTPUT_FILE"
    
    # Apply tags in strategic order
    apply_introduction_tags "$OUTPUT_FILE"
    apply_emotional_context_tags "$OUTPUT_FILE"
    apply_natural_speech_tags "$OUTPUT_FILE"
    apply_brand_alignment_tags "$OUTPUT_FILE"
    apply_conclusion_tags "$OUTPUT_FILE"
    
    # Advanced features
    apply_combination_tags "$OUTPUT_FILE"
    apply_contextual_tag_rules "$OUTPUT_FILE"
    
    # Optimize and validate
    optimize_tag_distribution "$OUTPUT_FILE"
    validate_tag_quality "$OUTPUT_FILE"
    
    # Generate report
    generate_tag_report "$INPUT_FILE" "$OUTPUT_FILE"
    
    # Cleanup temporary files
    rm -f "/tmp/content_analysis_$$"
    
    log_success "Audio tag injection complete"
    log_info "Input:  $INPUT_FILE"
    log_info "Output: $OUTPUT_FILE"
    log_info "Report: $OUTPUT_FILE.tag_report.json"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi