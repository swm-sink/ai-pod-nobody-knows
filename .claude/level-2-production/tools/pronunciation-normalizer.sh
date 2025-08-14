#!/bin/bash

# ============================================================================
# PRONUNCIATION NORMALIZER
# ============================================================================
# Purpose: Advanced pronunciation normalization for TTS optimization
# Usage: ./pronunciation-normalizer.sh <input_file> <output_file>
# Author: Claude Code AI Assistant
# Version: 1.0.0
# ============================================================================

set -e

INPUT_FILE="${1:-}"
OUTPUT_FILE="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(dirname "$SCRIPT_DIR")/templates"
PRONUNCIATION_DICT="$TEMPLATES_DIR/pronunciation-dictionary.json"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[NORMALIZER]${NC} $1"
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

    if [[ -f "$PRONUNCIATION_DICT" ]]; then
        log_info "Using pronunciation dictionary: $PRONUNCIATION_DICT"
    else
        log_warning "Pronunciation dictionary not found, using built-in rules"
    fi
}

# ============================================================================
# NORMALIZATION FUNCTIONS
# ============================================================================

normalize_numbers() {
    local input_file="$1"
    local temp_file="$input_file.numbers_temp"

    log_info "Normalizing numbers and numeric expressions..."

    cp "$input_file" "$temp_file"

    # Years: 2025 → "twenty twenty-five"
    sed -i.bak 's/\b20\([0-9][0-9]\)\b/twenty \1/g' "$temp_file"

    # Years: 1990s → "nineteen nineties"
    sed -i 's/\b19\([0-9][0-9]\)s\b/nineteen \1s/g' "$temp_file"

    # Large round numbers: 3300 → "thirty-three hundred" (not "three thousand three hundred")
    sed -i 's/\b\([1-9]\)\([1-9]\)00\b/\1-\2 hundred/g' "$temp_file"
    sed -i 's/\b\([1-9]\)000\b/\1 thousand/g' "$temp_file"

    # Percentages: 85% → "eighty-five percent"
    sed -i 's/\b\([0-9]\+\)%/\1 percent/g' "$temp_file"

    # Decimal numbers: 0.85 → "zero point eight five"
    sed -i 's/\b0\.\([0-9]\+\)/zero point \1/g' "$temp_file"

    # Version numbers: v2.5 → "version two point five"
    sed -i 's/\bv\?\([0-9]\+\)\.\([0-9]\+\)/version \1 point \2/g' "$temp_file"

    # Model versions: GPT-4 → "gee-pee-tee four"
    sed -i 's/\bGPT-\([0-9]\+\)/gee-pee-tee \1/g' "$temp_file"

    # Ranges: 3-5 → "three to five"
    sed -i 's/\b\([0-9]\+\)-\([0-9]\+\)/\1 to \2/g' "$temp_file"

    # Temperature: 25°C → "twenty-five degrees celsius"
    sed -i 's/\b\([0-9]\+\)°C/\1 degrees celsius/g' "$temp_file"
    sed -i 's/\b\([0-9]\+\)°F/\1 degrees fahrenheit/g' "$temp_file"

    # File sizes: 1GB → "one gigabyte"
    sed -i 's/\b\([0-9]\+\)GB/\1 gigabyte/g' "$temp_file"
    sed -i 's/\b\([0-9]\+\)MB/\1 megabyte/g' "$temp_file"
    sed -i 's/\b\([0-9]\+\)KB/\1 kilobyte/g' "$temp_file"

    # Time: 3:30 → "three thirty"
    sed -i 's/\b\([0-9]\+\):\([0-9][0-9]\)/\1 \2/g' "$temp_file"

    # Clean up temporary backup
    rm -f "$temp_file.bak"
    mv "$temp_file" "$input_file"

    log_success "Number normalization complete"
}

normalize_acronyms() {
    local input_file="$1"
    local temp_file="$input_file.acronyms_temp"

    log_info "Normalizing acronyms and abbreviations..."

    cp "$input_file" "$temp_file"

    # Load from dictionary if available
    if [[ -f "$PRONUNCIATION_DICT" ]]; then
        # Extract AI/ML terms from dictionary
        local ai_terms=$(jq -r '.ai_ml_terms | to_entries[] | "\(.key):\(.value)"' "$PRONUNCIATION_DICT" 2>/dev/null || echo "")

        if [[ -n "$ai_terms" ]]; then
            while IFS=':' read -r original phonetic; do
                if [[ -n "$original" ]] && [[ -n "$phonetic" ]]; then
                    sed -i "s/\\b$original\\b/$phonetic/g" "$temp_file"
                fi
            done <<< "$ai_terms"
            log_info "Applied dictionary-based AI/ML acronym pronunciations"
        fi

        # Extract technical acronyms from dictionary
        local tech_terms=$(jq -r '.technical_acronyms | to_entries[] | "\(.key):\(.value)"' "$PRONUNCIATION_DICT" 2>/dev/null || echo "")

        if [[ -n "$tech_terms" ]]; then
            while IFS=':' read -r original phonetic; do
                if [[ -n "$original" ]] && [[ -n "$phonetic" ]]; then
                    sed -i "s/\\b$original\\b/$phonetic/g" "$temp_file"
                fi
            done <<< "$tech_terms"
            log_info "Applied dictionary-based technical acronym pronunciations"
        fi

        # Extract company names from dictionary
        local company_terms=$(jq -r '.company_names | to_entries[] | "\(.key):\(.value)"' "$PRONUNCIATION_DICT" 2>/dev/null || echo "")

        if [[ -n "$company_terms" ]]; then
            while IFS=':' read -r original phonetic; do
                if [[ -n "$original" ]] && [[ -n "$phonetic" ]]; then
                    sed -i "s/\\b$original\\b/$phonetic/g" "$temp_file"
                fi
            done <<< "$company_terms"
            log_info "Applied dictionary-based company name pronunciations"
        fi
    else
        # Built-in acronym normalization
        log_info "Using built-in acronym pronunciation rules..."

        # AI/ML Terms
        sed -i 's/\bAI\b/ay-eye/g' "$temp_file"
        sed -i 's/\bML\b/em-el/g' "$temp_file"
        sed -i 's/\bLLM\b/el-el-em/g' "$temp_file"
        sed -i 's/\bGPT\b/gee-pee-tee/g' "$temp_file"
        sed -i 's/\bAPI\b/ay-pee-eye/g' "$temp_file"
        sed -i 's/\bSDK\b/es-dee-kay/g' "$temp_file"
        sed -i 's/\bJSON\b/jay-sohn/g' "$temp_file"
        sed -i 's/\bHTTP\b/h-t-t-p/g' "$temp_file"
        sed -i 's/\bREST\b/rest/g' "$temp_file"
        sed -i 's/\bBERT\b/bert/g' "$temp_file"

        # Technical Terms
        sed -i 's/\bURL\b/u-r-l/g' "$temp_file"
        sed -i 's/\bXML\b/ex-em-el/g' "$temp_file"
        sed -i 's/\bHTML\b/h-t-m-l/g' "$temp_file"
        sed -i 's/\bCSS\b/see-es-es/g' "$temp_file"
        sed -i 's/\bSQL\b/sequel/g' "$temp_file"
        sed -i 's/\bCLI\b/see-el-eye/g' "$temp_file"
        sed -i 's/\bGUI\b/gooey/g' "$temp_file"
        sed -i 's/\bUI\b/u-eye/g' "$temp_file"
        sed -i 's/\bUX\b/u-ex/g' "$temp_file"

        # Cloud Services
        sed -i 's/\bAWS\b/ay-double-you-es/g' "$temp_file"
        sed -i 's/\bGCP\b/gee-see-pee/g' "$temp_file"

        # Hardware
        sed -i 's/\bCPU\b/see-pee-you/g' "$temp_file"
        sed -i 's/\bGPU\b/gee-pee-you/g' "$temp_file"
        sed -i 's/\bRAM\b/ram/g' "$temp_file"
        sed -i 's/\bSSD\b/es-es-dee/g' "$temp_file"

        log_success "Built-in acronym normalization complete"
    fi

    mv "$temp_file" "$input_file"
}

normalize_abbreviations() {
    local input_file="$1"
    local temp_file="$input_file.abbrev_temp"

    log_info "Normalizing common abbreviations..."

    cp "$input_file" "$temp_file"

    # Common abbreviations that should be expanded
    sed -i 's/\betc\b/et cetera/g' "$temp_file"
    sed -i 's/\be\.g\./for example/g' "$temp_file"
    sed -i 's/\bi\.e\./that is/g' "$temp_file"
    sed -i 's/\bvs\b/versus/g' "$temp_file"
    sed -i 's/\bvs\./versus/g' "$temp_file"
    sed -i 's/\bw\//with/g' "$temp_file"
    sed -i 's/\bw\/o\b/without/g' "$temp_file"

    # Business terms
    sed -i 's/\bB2B\b/business to business/g' "$temp_file"
    sed -i 's/\bB2C\b/business to consumer/g' "$temp_file"
    sed -i 's/\bCEO\b/see-ee-oh/g' "$temp_file"
    sed -i 's/\bCTO\b/see-tee-oh/g' "$temp_file"
    sed -i 's/\bCFO\b/see-eff-oh/g' "$temp_file"

    # Titles
    sed -i 's/\bDr\./Doctor/g' "$temp_file"
    sed -i 's/\bMr\./Mister/g' "$temp_file"
    sed -i 's/\bMrs\./Missis/g' "$temp_file"
    sed -i 's/\bMs\./Miss/g' "$temp_file"

    # Education
    sed -i 's/\bPhD\b/pee-h-dee/g' "$temp_file"
    sed -i 's/\bMSc\b/master of science/g' "$temp_file"
    sed -i 's/\bBSc\b/bachelor of science/g' "$temp_file"

    # Common internet/text abbreviations
    sed -i 's/\bFAQ\b/eff-ay-queue/g' "$temp_file"
    sed -i 's/\bFYI\b/eff-why-eye/g' "$temp_file"
    sed -i 's/\bBTW\b/by the way/g' "$temp_file"
    sed -i 's/\bASAP\b/ay-es-ay-pee/g' "$temp_file"

    mv "$temp_file" "$input_file"

    log_success "Abbreviation normalization complete"
}

normalize_compound_terms() {
    local input_file="$1"
    local temp_file="$input_file.compound_temp"

    log_info "Normalizing compound technical terms..."

    cp "$input_file" "$temp_file"

    # AI/ML compound expansions
    sed -i 's/\bAI\/ML\b/artificial intelligence and machine learning/g' "$temp_file"
    sed -i 's/\bML\/AI\b/machine learning and artificial intelligence/g' "$temp_file"
    sed -i 's/\bNLP\/NLU\b/natural language processing and understanding/g' "$temp_file"
    sed -i 's/\bASR\/TTS\b/automatic speech recognition and text-to-speech/g' "$temp_file"
    sed -i 's/\bCV\/NLP\b/computer vision and natural language processing/g' "$temp_file"

    # Protocol combinations
    sed -i 's/\bHTTP\/HTTPS\b/h-t-t-p and h-t-t-p-s/g' "$temp_file"
    sed -i 's/\bTCP\/IP\b/t-c-p eye-pee/g' "$temp_file"

    # Hyphenated technical terms
    sed -i 's/\bCOVID-19\b/COVID nineteen/g' "$temp_file"
    sed -i 's/\bWeb-scale\b/web scale/g' "$temp_file"
    sed -i 's/\bReal-time\b/real time/g' "$temp_file"
    sed -i 's/\bEnd-to-end\b/end to end/g' "$temp_file"
    sed -i 's/\bState-of-the-art\b/state of the art/g' "$temp_file"

    mv "$temp_file" "$input_file"

    log_success "Compound term normalization complete"
}

normalize_special_characters() {
    local input_file="$1"
    local temp_file="$input_file.special_temp"

    log_info "Normalizing special characters and symbols..."

    cp "$input_file" "$temp_file"

    # Mathematical symbols
    sed -i 's/π/pi/g' "$temp_file"
    sed -i 's/∞/infinity/g' "$temp_file"
    sed -i 's/±/plus or minus/g' "$temp_file"
    sed -i 's/≈/approximately/g' "$temp_file"
    sed -i 's/≠/not equal to/g' "$temp_file"
    sed -i 's/≤/less than or equal to/g' "$temp_file"
    sed -i 's/≥/greater than or equal to/g' "$temp_file"

    # Common symbols
    sed -i 's/@/at/g' "$temp_file"
    sed -i 's/#/hash/g' "$temp_file"
    sed -i 's/&/and/g' "$temp_file"
    sed -i 's/©/copyright/g' "$temp_file"
    sed -i 's/®/registered/g' "$temp_file"
    sed -i 's/™/trademark/g' "$temp_file"

    # Currency (be careful not to replace mid-word)
    sed -i 's/\$\([0-9]\)/\1 dollars/g' "$temp_file"
    sed -i 's/€\([0-9]\)/\1 euros/g' "$temp_file"
    sed -i 's/£\([0-9]\)/\1 pounds/g' "$temp_file"

    mv "$temp_file" "$input_file"

    log_success "Special character normalization complete"
}

apply_contextual_rules() {
    local input_file="$1"
    local temp_file="$input_file.context_temp"

    log_info "Applying contextual pronunciation rules..."

    cp "$input_file" "$temp_file"

    # Context-dependent pronunciations
    # "API" - prefer full expansion on first mention in technical context
    sed -i '0,/ay-pee-eye/{s/ay-pee-eye/application programming interface, or ay-pee-eye/}' "$temp_file"

    # "AI" - prefer full expansion on first mention
    sed -i '0,/ay-eye/{s/ay-eye/artificial intelligence, or ay-eye/}' "$temp_file"

    # "ML" - prefer full expansion on first mention
    sed -i '0,/em-el/{s/em-el/machine learning, or em-el/}' "$temp_file"

    # Numbers in context - prefer natural pronunciation
    # "24/7" → "twenty-four seven"
    sed -i 's/24\/7/twenty-four seven/g' "$temp_file"

    # "365" in context → "three sixty-five"
    sed -i 's/\b365\b/three sixty-five/g' "$temp_file"

    # "404" → "four oh four" (HTTP status)
    sed -i 's/\b404\b/four oh four/g' "$temp_file"

    # "200" → "two hundred" (HTTP status)
    sed -i 's/\b200 OK\b/two hundred OK/g' "$temp_file"

    mv "$temp_file" "$input_file"

    log_success "Contextual rules applied"
}

generate_normalization_report() {
    local input_file="$1"
    local output_file="$2"
    local report_file="$output_file.normalization_report.json"

    # Count changes made
    local original_acronyms=$(grep -oE '\b[A-Z]{2,}\b' "$input_file" | wc -l)
    local original_numbers=$(grep -oE '\b[0-9]+(\.[0-9]+)?\b' "$input_file" | wc -l)
    local optimized_acronyms=$(grep -oE '\b[A-Z]{2,}\b' "$output_file" | wc -l)
    local optimized_numbers=$(grep -oE '\b[0-9]+(\.[0-9]+)?\b' "$output_file" | wc -l)

    local acronyms_normalized=$((original_acronyms - optimized_acronyms))
    local numbers_normalized=$((original_numbers - optimized_numbers))

    # Generate report
    cat > "$report_file" << EOF
{
  "normalization_report": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "input_file": "$input_file",
    "output_file": "$output_file",
    "processing_steps": [
      "number_normalization",
      "acronym_normalization",
      "abbreviation_expansion",
      "compound_term_handling",
      "special_character_conversion",
      "contextual_rule_application"
    ],
    "statistics": {
      "original_acronyms": $original_acronyms,
      "original_numbers": $original_numbers,
      "acronyms_normalized": $acronyms_normalized,
      "numbers_normalized": $numbers_normalized,
      "improvement_percentage": $(echo "scale=2; ($acronyms_normalized + $numbers_normalized) * 100 / ($original_acronyms + $original_numbers + 1)" | bc -l)
    },
    "dictionary_usage": {
      "pronunciation_dictionary_available": $([ -f "$PRONUNCIATION_DICT" ] && echo "true" || echo "false"),
      "custom_rules_applied": true,
      "contextual_expansions": true
    }
  }
}
EOF

    log_info "Normalization report generated: $report_file"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log_info "Starting pronunciation normalization process..."

    validate_inputs

    # Copy input to output for processing
    cp "$INPUT_FILE" "$OUTPUT_FILE"

    # Apply normalization steps in sequence
    normalize_numbers "$OUTPUT_FILE"
    normalize_acronyms "$OUTPUT_FILE"
    normalize_abbreviations "$OUTPUT_FILE"
    normalize_compound_terms "$OUTPUT_FILE"
    normalize_special_characters "$OUTPUT_FILE"
    apply_contextual_rules "$OUTPUT_FILE"

    # Generate report
    generate_normalization_report "$INPUT_FILE" "$OUTPUT_FILE"

    log_success "Pronunciation normalization complete"
    log_info "Input:  $INPUT_FILE"
    log_info "Output: $OUTPUT_FILE"
    log_info "Report: $OUTPUT_FILE.normalization_report.json"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
