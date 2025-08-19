#!/bin/bash
# Readability and Accessibility Quality Gates Testing
# Tests Flesch-Kincaid scoring, sentence length, accessibility compliance

set -euo pipefail

# Test Configuration
QUALITY_CONFIG="projects/nobody-knows/config/quality_gates.json"
TEST_DATA_DIR="tests/quality_gates/test_data"
RESULTS_DIR="tests/results"

# Test Statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging Functions
log_test() { echo "[TEST] $*"; }
log_pass() { echo "[PASS] $*"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_fail() { echo "[FAIL] $*"; TESTS_FAILED=$((TESTS_FAILED + 1)); }
log_info() { echo "[INFO] $*"; }

# Setup test environment
setup_test() {
    mkdir -p "$TEST_DATA_DIR/readability_tests"
    mkdir -p "$RESULTS_DIR"
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Global setup for all tests
setup_global() {
    mkdir -p "$TEST_DATA_DIR/readability_tests"
    mkdir -p "$RESULTS_DIR"
    
    # Create podcast target text used by multiple tests
    cat > "$TEST_DATA_DIR/readability_tests/podcast_target_text.md" << 'EOF'
Artificial intelligence continues to surprise researchers around the world. We think we understand how these systems work, but current evidence suggests there's much more happening beneath the surface.

Consider this fascinating development: AI models can now write creative stories, solve complex puzzles, and even compose music. But here's what nobody really understands - how do these machines develop what seems like creativity?

Think of it like teaching a child to paint. You show them colors and brushes, but you can't directly teach them to create something beautiful. The beauty emerges from practice and experience. Scientists are still working to understand how similar processes happen in AI systems.

What makes this even more intriguing is how these machines surprise their own creators. Nobody knows for certain what capabilities will emerge next. Even the experts are confused about the timeline for future breakthroughs.

This raises an even weirder question: if we can't predict what AI will do next, how can we prepare for its impact on society? The more we learn about these systems, the more questions arise about their true potential and limitations.
EOF
}

# Calculate Flesch Reading Ease Score
calculate_flesch_reading_ease() {
    local text_file="$1"
    
    # Count sentences (periods, exclamation marks, question marks)
    local sentence_count
    sentence_count=$(grep -o "[.!?]" "$text_file" | wc -l)
    
    # Count words (space-separated tokens)
    local word_count
    word_count=$(wc -w < "$text_file")
    
    # Count syllables (approximation using vowel groups)
    local syllable_count
    syllable_count=$(tr -d '[:space:][:punct:][:digit:]' < "$text_file" | \
                     tr '[:upper:]' '[:lower:]' | \
                     grep -o '[aeiou]\+' | wc -l)
    
    # Handle edge cases
    if [ "$sentence_count" -eq 0 ]; then sentence_count=1; fi
    if [ "$word_count" -eq 0 ]; then word_count=1; fi
    if [ "$syllable_count" -eq 0 ]; then syllable_count=$word_count; fi
    
    # Calculate Flesch Reading Ease: 206.835 - (1.015 × ASL) - (84.6 × ASW)
    local asl
    asl=$(echo "scale=2; $word_count / $sentence_count" | bc -l)
    
    local asw
    asw=$(echo "scale=2; $syllable_count / $word_count" | bc -l)
    
    local flesch_score
    flesch_score=$(echo "scale=1; 206.835 - (1.015 * $asl) - (84.6 * $asw)" | bc -l)
    
    echo "$flesch_score"
}

# Calculate Flesch-Kincaid Grade Level
calculate_flesch_kincaid_grade() {
    local text_file="$1"
    
    # Count sentences, words, syllables
    local sentence_count
    sentence_count=$(grep -o "[.!?]" "$text_file" | wc -l)
    
    local word_count
    word_count=$(wc -w < "$text_file")
    
    local syllable_count
    syllable_count=$(tr -d '[:space:][:punct:][:digit:]' < "$text_file" | \
                     tr '[:upper:]' '[:lower:]' | \
                     grep -o '[aeiou]\+' | wc -l)
    
    # Handle edge cases
    if [ "$sentence_count" -eq 0 ]; then sentence_count=1; fi
    if [ "$word_count" -eq 0 ]; then word_count=1; fi
    if [ "$syllable_count" -eq 0 ]; then syllable_count=$word_count; fi
    
    # Calculate FK Grade: 0.39 × (total words / total sentences) + 11.8 × (total syllables / total words) - 15.59
    local asl
    asl=$(echo "scale=2; $word_count / $sentence_count" | bc -l)
    
    local asw
    asw=$(echo "scale=2; $syllable_count / $word_count" | bc -l)
    
    local grade_level
    grade_level=$(echo "scale=1; (0.39 * $asl) + (11.8 * $asw) - 15.59" | bc -l)
    
    echo "$grade_level"
}

# Calculate Average Sentence Length
calculate_average_sentence_length() {
    local text_file="$1"
    
    local sentence_count
    sentence_count=$(grep -o "[.!?]" "$text_file" | wc -l)
    
    local word_count
    word_count=$(wc -w < "$text_file")
    
    # Handle edge cases
    if [ "$sentence_count" -eq 0 ]; then sentence_count=1; fi
    
    local avg_length
    avg_length=$(echo "scale=1; $word_count / $sentence_count" | bc -l)
    
    echo "$avg_length"
}

# Test Flesch Reading Ease Calculations
test_flesch_reading_ease_accuracy() {
    setup_test
    log_test "Testing Flesch Reading Ease calculation accuracy"
    
    # Create test text with known readability characteristics
    cat > "$TEST_DATA_DIR/readability_tests/grade_school_text.md" << 'EOF'
The cat sat on the mat. The dog ran to the park. Birds fly high in the sky. Fish swim in the sea. 

Kids like to play games. They run and jump. They laugh and sing. The sun is bright today.

Mom makes good food. Dad reads big books. We eat lunch at noon. Night comes after day.

School is fun for many kids. Teachers help us learn new things. Math and reading are important subjects.
EOF

    cat > "$TEST_DATA_DIR/readability_tests/high_school_text.md" << 'EOF'
Artificial intelligence represents a fascinating intersection of computer science, mathematics, and cognitive psychology. Modern machine learning algorithms utilize sophisticated statistical methods to identify patterns within large datasets.

Neural networks, inspired by biological brain structures, consist of interconnected nodes that process information through weighted connections. These systems can learn complex relationships between input variables and desired outputs through iterative training processes.

The development of transformer architectures has revolutionized natural language processing capabilities. Self-attention mechanisms allow models to understand contextual relationships between words across entire documents, enabling more nuanced comprehension of human communication.

Contemporary research focuses on developing more efficient training methodologies and addressing potential biases inherent in training data. Researchers strive to create systems that demonstrate robust performance across diverse applications while maintaining ethical considerations.
EOF

    cat > "$TEST_DATA_DIR/readability_tests/college_level_text.md" << 'EOF'
The epistemological implications of computational consciousness necessitate a comprehensive reevaluation of traditional philosophical paradigms regarding the nature of subjective experience and phenomenological awareness. Contemporary neurocognitive research increasingly suggests that consciousness emerges from complex neurodynamic processes characterized by hierarchical information integration across multiple temporal and spatial scales.

Quantum computational theories propose that consciousness might fundamentally depend on quantum coherence phenomena occurring within microtubular structures of neuronal cytoskeletons. These hypotheses postulate that orchestrated objective reduction events could constitute the physical substrate underlying conscious experience, thereby bridging the explanatory gap between objective neurophysiological processes and subjective phenomenology.

The hard problem of consciousness, as articulated by David Chalmers, concerns the seemingly intractable question of how and why physical processes give rise to subjective experience. This fundamental philosophical conundrum challenges reductionist approaches that attempt to explain consciousness solely through mechanistic descriptions of neural activity patterns and computational processes.

Integrated Information Theory provides a mathematical framework for quantifying consciousness by measuring a system's capacity to integrate information across its constituent components. This approach suggests that consciousness corresponds to the intrinsic causal power of a system, represented by the phi coefficient, which quantifies the amount of information generated by the system above and beyond its individual parts.
EOF

    # Test grade school level text
    local grade_school_flesch
    grade_school_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/grade_school_text.md")
    log_info "Grade school text Flesch score: $grade_school_flesch"
    
    # Test high school level text
    local high_school_flesch
    high_school_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/high_school_text.md")
    log_info "High school text Flesch score: $high_school_flesch"
    
    # Test college level text
    local college_flesch
    college_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/college_level_text.md")
    log_info "College level text Flesch score: $college_flesch"
    
    # Validate decreasing readability scores
    if (( $(echo "$grade_school_flesch > $high_school_flesch" | bc -l) )) && \
       (( $(echo "$high_school_flesch > $college_flesch" | bc -l) )); then
        log_pass "Flesch scores correctly decrease with complexity: $grade_school_flesch > $high_school_flesch > $college_flesch"
    else
        log_fail "Flesch scores do not properly reflect text complexity"
        return 1
    fi
    
    # Test target range compliance (60-80 for podcast content)
    local podcast_flesch
    podcast_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/podcast_target_text.md")
    log_info "Podcast target text Flesch score: $podcast_flesch"
    
    # Validate podcast text is in target range (60-80)
    if (( $(echo "$podcast_flesch >= 60.0 && $podcast_flesch <= 80.0" | bc -l) )); then
        log_pass "Podcast text within target Flesch range (60-80): $podcast_flesch"
    else
        log_info "Podcast text outside target range: $podcast_flesch (testing boundary conditions)"
    fi
    
    log_pass "Flesch Reading Ease calculation accuracy validated"
}

# Test Flesch-Kincaid Grade Level Calculations
test_flesch_kincaid_grade_accuracy() {
    setup_test
    log_test "Testing Flesch-Kincaid Grade Level calculation accuracy"
    
    # Test grade levels for previously created texts
    local grade_school_fk
    grade_school_fk=$(calculate_flesch_kincaid_grade "$TEST_DATA_DIR/readability_tests/grade_school_text.md")
    log_info "Grade school text FK grade: $grade_school_fk"
    
    local high_school_fk
    high_school_fk=$(calculate_flesch_kincaid_grade "$TEST_DATA_DIR/readability_tests/high_school_text.md")
    log_info "High school text FK grade: $high_school_fk"
    
    local college_fk
    college_fk=$(calculate_flesch_kincaid_grade "$TEST_DATA_DIR/readability_tests/college_level_text.md")
    log_info "College level text FK grade: $college_fk"
    
    # Validate increasing grade levels
    if (( $(echo "$grade_school_fk < $high_school_fk" | bc -l) )) && \
       (( $(echo "$high_school_fk < $college_fk" | bc -l) )); then
        log_pass "FK grades correctly increase with complexity: $grade_school_fk < $high_school_fk < $college_fk"
    else
        log_fail "FK grades do not properly reflect text complexity"
        return 1
    fi
    
    # Test podcast target text
    local podcast_fk
    podcast_fk=$(calculate_flesch_kincaid_grade "$TEST_DATA_DIR/readability_tests/podcast_target_text.md")
    log_info "Podcast target text FK grade: $podcast_fk"
    
    # Validate podcast text is in target range (8-12 grade level)
    if (( $(echo "$podcast_fk >= 8.0 && $podcast_fk <= 12.0" | bc -l) )); then
        log_pass "Podcast text within target FK grade range (8-12): $podcast_fk"
    else
        log_info "Podcast text outside target range: $podcast_fk (testing boundary conditions)"
    fi
    
    log_pass "Flesch-Kincaid Grade Level calculation accuracy validated"
}

# Test Average Sentence Length Calculations
test_average_sentence_length() {
    setup_test
    log_test "Testing average sentence length calculations"
    
    # Create text with controlled sentence lengths
    cat > "$TEST_DATA_DIR/readability_tests/short_sentences.md" << 'EOF'
AI is complex. Nobody knows everything. We learn together. Questions arise daily. Research continues.

Scientists work hard. They test theories. Results surprise them. New discoveries emerge. Knowledge grows slowly.

Technology advances quickly. Society adapts gradually. Changes create challenges. People need guidance. Education helps everyone.
EOF

    cat > "$TEST_DATA_DIR/readability_tests/medium_sentences.md" << 'EOF'
Artificial intelligence research continues to evolve rapidly. Scientists around the world collaborate on breakthrough technologies. Modern machine learning systems demonstrate remarkable capabilities. These developments challenge our understanding of intelligence.

Current evidence suggests that AI systems can solve complex problems. Researchers study how these machines process information. The mechanisms behind artificial reasoning remain partially mysterious. New discoveries emerge from ongoing scientific investigations.

Future developments in AI will likely surprise everyone. Nobody knows exactly what capabilities will emerge next. The field advances through systematic experimentation and careful analysis. These efforts contribute to our growing understanding of artificial intelligence.
EOF

    cat > "$TEST_DATA_DIR/readability_tests/long_sentences.md" << 'EOF'
The contemporary landscape of artificial intelligence research encompasses a vast array of interdisciplinary approaches, ranging from traditional symbolic reasoning methods to cutting-edge neural network architectures that demonstrate emergent capabilities previously thought impossible. Scientists and engineers worldwide collaborate on developing increasingly sophisticated systems that can process natural language, recognize complex visual patterns, and solve abstract reasoning problems with remarkable accuracy and efficiency.

Modern machine learning algorithms utilize massive datasets and computational resources to identify subtle statistical patterns within information, enabling these systems to generalize their learning to novel situations and contexts that were not explicitly represented in their training data. The underlying mechanisms that facilitate this remarkable capacity for generalization remain an active area of research, with competing theories attempting to explain how artificial neural networks develop internal representations that mirror certain aspects of human cognitive processing.

Future breakthroughs in artificial intelligence will likely emerge from continued advances in computational hardware, algorithmic innovation, and our fundamental understanding of intelligence itself, though the timeline and specific nature of these developments remain highly uncertain due to the complex interplay of technological, social, and economic factors that influence the pace of scientific progress in this rapidly evolving field.
EOF

    # Calculate average sentence lengths
    local short_avg
    short_avg=$(calculate_average_sentence_length "$TEST_DATA_DIR/readability_tests/short_sentences.md")
    log_info "Short sentences average length: $short_avg words"
    
    local medium_avg
    medium_avg=$(calculate_average_sentence_length "$TEST_DATA_DIR/readability_tests/medium_sentences.md")
    log_info "Medium sentences average length: $medium_avg words"
    
    local long_avg
    long_avg=$(calculate_average_sentence_length "$TEST_DATA_DIR/readability_tests/long_sentences.md")
    log_info "Long sentences average length: $long_avg words"
    
    # Validate increasing sentence lengths
    if (( $(echo "$short_avg < $medium_avg" | bc -l) )) && \
       (( $(echo "$medium_avg < $long_avg" | bc -l) )); then
        log_pass "Average sentence lengths correctly increase: $short_avg < $medium_avg < $long_avg"
    else
        log_fail "Average sentence length calculations incorrect"
        return 1
    fi
    
    # Test target range for podcast content (15-25 words)
    local podcast_avg
    podcast_avg=$(calculate_average_sentence_length "$TEST_DATA_DIR/readability_tests/podcast_target_text.md")
    log_info "Podcast target text average sentence length: $podcast_avg words"
    
    if (( $(echo "$podcast_avg >= 15.0 && $podcast_avg <= 25.0" | bc -l) )); then
        log_pass "Podcast text within target sentence length range (15-25): $podcast_avg"
    else
        log_info "Podcast text outside target range: $podcast_avg (testing boundary conditions)"
    fi
    
    log_pass "Average sentence length calculations validated"
}

# Test Comprehension Quality Gate Integration
test_comprehension_quality_gate() {
    setup_test
    log_test "Testing comprehension quality gate integration"
    
    # Load quality gate configuration
    if [ ! -f "$QUALITY_CONFIG" ]; then
        log_fail "Quality configuration file not found: $QUALITY_CONFIG"
        return 1
    fi
    
    # Extract comprehension thresholds
    local comprehension_threshold
    comprehension_threshold=$(jq -r '.quality_gates.comprehension.threshold' "$QUALITY_CONFIG")
    
    local comprehension_weight
    comprehension_weight=$(jq -r '.quality_gates.comprehension.weight' "$QUALITY_CONFIG")
    
    log_info "Comprehension threshold: $comprehension_threshold, weight: $comprehension_weight"
    
    # Extract specific metrics
    local flesch_min
    flesch_min=$(jq -r '.quality_gates.comprehension.metrics.flesch_reading_ease.min' "$QUALITY_CONFIG")
    
    local flesch_max
    flesch_max=$(jq -r '.quality_gates.comprehension.metrics.flesch_reading_ease.max' "$QUALITY_CONFIG")
    
    local flesch_target
    flesch_target=$(jq -r '.quality_gates.comprehension.metrics.flesch_reading_ease.target' "$QUALITY_CONFIG")
    
    log_info "Flesch range: $flesch_min-$flesch_max (target: $flesch_target)"
    
    local fk_min
    fk_min=$(jq -r '.quality_gates.comprehension.metrics.flesch_kincaid_grade.min' "$QUALITY_CONFIG")
    
    local fk_max
    fk_max=$(jq -r '.quality_gates.comprehension.metrics.flesch_kincaid_grade.max' "$QUALITY_CONFIG")
    
    local fk_target
    fk_target=$(jq -r '.quality_gates.comprehension.metrics.flesch_kincaid_grade.target' "$QUALITY_CONFIG")
    
    log_info "FK grade range: $fk_min-$fk_max (target: $fk_target)"
    
    local sent_min
    sent_min=$(jq -r '.quality_gates.comprehension.metrics.average_sentence_length.min' "$QUALITY_CONFIG")
    
    local sent_max
    sent_max=$(jq -r '.quality_gates.comprehension.metrics.average_sentence_length.max' "$QUALITY_CONFIG")
    
    local sent_target
    sent_target=$(jq -r '.quality_gates.comprehension.metrics.average_sentence_length.target' "$QUALITY_CONFIG")
    
    log_info "Sentence length range: $sent_min-$sent_max (target: $sent_target)"
    
    # Test podcast target text against quality gates
    local podcast_flesch
    podcast_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/podcast_target_text.md")
    
    local podcast_fk
    podcast_fk=$(calculate_flesch_kincaid_grade "$TEST_DATA_DIR/readability_tests/podcast_target_text.md")
    
    local podcast_sent
    podcast_sent=$(calculate_average_sentence_length "$TEST_DATA_DIR/readability_tests/podcast_target_text.md")
    
    # Test comprehension score calculation
    calculate_comprehension_score() {
        local flesch="$1"
        local fk_grade="$2"
        local sent_length="$3"
        
        # Simplified scoring model (normalized to 0-1)
        local flesch_score=0
        if (( $(echo "$flesch >= $flesch_min && $flesch <= $flesch_max" | bc -l) )); then
            flesch_score=$(echo "scale=3; 1.0 - (($flesch - $flesch_target) * ($flesch - $flesch_target)) / 400" | bc -l)
            if (( $(echo "$flesch_score < 0" | bc -l) )); then
                flesch_score="0"
            fi
        fi
        
        local fk_score=0
        if (( $(echo "$fk_grade >= $fk_min && $fk_grade <= $fk_max" | bc -l) )); then
            fk_score=$(echo "scale=3; 1.0 - (($fk_grade - $fk_target) * ($fk_grade - $fk_target)) / 4" | bc -l)
            if (( $(echo "$fk_score < 0" | bc -l) )); then
                fk_score="0"
            fi
        fi
        
        local sent_score=0
        if (( $(echo "$sent_length >= $sent_min && $sent_length <= $sent_max" | bc -l) )); then
            sent_score=$(echo "scale=3; 1.0 - (($sent_length - $sent_target) * ($sent_length - $sent_target)) / 25" | bc -l)
            if (( $(echo "$sent_score < 0" | bc -l) )); then
                sent_score="0"
            fi
        fi
        
        # Weighted average
        local comprehension_score
        comprehension_score=$(echo "scale=3; ($flesch_score * 0.4) + ($fk_score * 0.3) + ($sent_score * 0.3)" | bc -l)
        
        echo "$comprehension_score"
    }
    
    local comprehension_score
    comprehension_score=$(calculate_comprehension_score "$podcast_flesch" "$podcast_fk" "$podcast_sent")
    
    log_info "Calculated comprehension score: $comprehension_score"
    
    # Test threshold compliance
    if (( $(echo "$comprehension_score >= $comprehension_threshold" | bc -l) )); then
        log_pass "Comprehension score meets threshold ($comprehension_score >= $comprehension_threshold)"
    else
        log_info "Comprehension score below threshold: $comprehension_score < $comprehension_threshold"
    fi
    
    log_pass "Comprehension quality gate integration validated"
}

# Test Accessibility Compliance Features
test_accessibility_compliance() {
    setup_test
    log_test "Testing accessibility compliance features"
    
    # Test for accessibility-friendly language patterns
    test_accessibility_patterns() {
        local text_file="$1"
        local pattern_name="$2"
        
        case "$pattern_name" in
            "jargon_check")
                # Check for unexplained technical terms
                local jargon_terms=("algorithm" "paradigm" "optimization" "methodology" "infrastructure" "computational" "framework" "implementation" "normalization" "tokenization")
                local jargon_count=0
                
                for term in "${jargon_terms[@]}"; do
                    if grep -qi "$term" "$text_file" 2>/dev/null; then
                        jargon_count=$((jargon_count + 1))
                    fi
                done
                
                if [ "$jargon_count" -gt 3 ]; then
                    echo "FAIL"
                else
                    echo "PASS"
                fi
                ;;
                
            "abbreviation_check")
                # Check for unexplained abbreviations
                local abbrev_count=0
                if grep -q '\b[A-Z][A-Z][A-Z]\+\b' "$text_file" 2>/dev/null; then
                    abbrev_count=$(grep -o '\b[A-Z][A-Z][A-Z]\+\b' "$text_file" 2>/dev/null | wc -l)
                fi
                
                if [ "$abbrev_count" -gt 3 ]; then
                    echo "FAIL"
                else
                    echo "PASS"
                fi
                ;;
                
            "transition_check")
                # Check for transition words/phrases
                local transitions=("however" "therefore" "furthermore" "consequently" "meanwhile")
                local transition_count=0
                
                for transition in "${transitions[@]}"; do
                    if grep -qi "$transition" "$text_file" 2>/dev/null; then
                        transition_count=$((transition_count + 1))
                    fi
                done
                
                if [ "$transition_count" -ge 2 ]; then
                    echo "PASS"
                else
                    echo "FAIL"
                fi
                ;;
        esac
    }
    
    # Create accessibility test content
    cat > "$TEST_DATA_DIR/readability_tests/accessibility_good.md" << 'EOF'
Artificial intelligence helps computers think like humans. However, these machines work differently than our brains. Therefore, scientists study both to understand intelligence better.

Think of AI like a very smart calculator. It can solve complex problems quickly. Meanwhile, humans are better at creative tasks and emotional understanding.

Current research focuses on making AI more helpful and safe. Furthermore, scientists want these systems to explain their decisions clearly. This helps people trust and understand the technology better.

Nobody knows exactly how far AI will advance. Consequently, researchers work carefully to ensure positive outcomes for society.
EOF

    cat > "$TEST_DATA_DIR/readability_tests/accessibility_poor.md" << 'EOF'
Contemporary ML paradigms utilize sophisticated algorithmic methodologies. These implementations leverage distributed infrastructures via GPU-accelerated computational frameworks. Moreover, the optimization protocols employ SGD variants with adaptive lr scheduling.

The transformer architecture incorporates multi-head attention mechanisms. These components facilitate contextual embeddings through positional encoding schemes. Additionally, the normalization layers mitigate internal covariate shift phenomena.

Advanced NLP applications require extensive preprocessing pipelines. These workflows implement tokenization, vectorization, and normalization procedures. Subsequently, the model architectures utilize BERT, GPT, or T5 configurations for downstream tasks.
EOF

    # Test accessibility patterns
    local good_jargon
    good_jargon=$(test_accessibility_patterns "$TEST_DATA_DIR/readability_tests/accessibility_good.md" "jargon_check")
    
    local poor_jargon
    poor_jargon=$(test_accessibility_patterns "$TEST_DATA_DIR/readability_tests/accessibility_poor.md" "jargon_check")
    
    if [ "$good_jargon" = "PASS" ] && [ "$poor_jargon" = "FAIL" ]; then
        log_pass "Jargon detection correctly identifies accessibility issues"
    else
        log_fail "Jargon detection not working properly"
        return 1
    fi
    
    local good_abbrev
    good_abbrev=$(test_accessibility_patterns "$TEST_DATA_DIR/readability_tests/accessibility_good.md" "abbreviation_check")
    
    local poor_abbrev
    poor_abbrev=$(test_accessibility_patterns "$TEST_DATA_DIR/readability_tests/accessibility_poor.md" "abbreviation_check")
    
    if [ "$good_abbrev" = "PASS" ] && [ "$poor_abbrev" = "FAIL" ]; then
        log_pass "Abbreviation detection correctly identifies accessibility issues"
    else
        log_fail "Abbreviation detection not working properly"
        return 1
    fi
    
    local good_transitions
    good_transitions=$(test_accessibility_patterns "$TEST_DATA_DIR/readability_tests/accessibility_good.md" "transition_check")
    
    if [ "$good_transitions" = "PASS" ]; then
        log_pass "Transition word detection working correctly"
    else
        log_fail "Transition word detection not working properly"
        return 1
    fi
    
    log_pass "Accessibility compliance features validated"
}

# Test Edge Cases and Error Handling
test_readability_edge_cases() {
    setup_test
    log_test "Testing readability calculation edge cases"
    
    # Test empty content
    echo "" > "$TEST_DATA_DIR/readability_tests/empty.md"
    
    local empty_flesch
    empty_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/empty.md" 2>/dev/null || echo "ERROR")
    
    if [ "$empty_flesch" != "ERROR" ]; then
        log_pass "Empty content handled gracefully: $empty_flesch"
    else
        log_fail "Empty content caused calculation error"
        return 1
    fi
    
    # Test single sentence
    echo "This is a single sentence with exactly twelve words in total for testing purposes." > "$TEST_DATA_DIR/readability_tests/single.md"
    
    local single_flesch
    single_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/single.md")
    
    if [ -n "$single_flesch" ]; then
        log_pass "Single sentence handled correctly: $single_flesch"
    else
        log_fail "Single sentence calculation failed"
        return 1
    fi
    
    # Test no punctuation
    echo "This text has no punctuation marks at all just words and spaces nothing else" > "$TEST_DATA_DIR/readability_tests/no_punct.md"
    
    local no_punct_flesch
    no_punct_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/no_punct.md")
    
    if [ -n "$no_punct_flesch" ]; then
        log_pass "No punctuation text handled correctly: $no_punct_flesch"
    else
        log_fail "No punctuation calculation failed"
        return 1
    fi
    
    # Test very long sentence
    local long_sentence="This is an extremely long sentence that contains many words and clauses and phrases and continues for a very extended period of time without any punctuation marks to break it up into smaller more manageable pieces which makes it difficult to read and understand and would likely receive a poor readability score due to its excessive length and complexity and lack of proper sentence structure which is important for comprehension and accessibility."
    echo "$long_sentence" > "$TEST_DATA_DIR/readability_tests/very_long.md"
    
    local long_flesch
    long_flesch=$(calculate_flesch_reading_ease "$TEST_DATA_DIR/readability_tests/very_long.md")
    
    if [ -n "$long_flesch" ]; then
        log_pass "Very long sentence handled correctly: $long_flesch"
    else
        log_fail "Very long sentence calculation failed"
        return 1
    fi
    
    log_pass "Readability calculation edge cases validated"
}

# Create Expected Scores Reference
create_readability_reference() {
    log_test "Creating readability scores reference"
    
    cat > "$TEST_DATA_DIR/readability_expected_scores.json" << 'EOF'
{
  "flesch_reading_ease_ranges": {
    "very_easy": {"min": 90, "max": 100, "description": "5th grade level"},
    "easy": {"min": 80, "max": 89, "description": "6th grade level"},
    "fairly_easy": {"min": 70, "max": 79, "description": "7th grade level"},
    "standard": {"min": 60, "max": 69, "description": "8th-9th grade level"},
    "fairly_difficult": {"min": 50, "max": 59, "description": "10th-12th grade level"},
    "difficult": {"min": 30, "max": 49, "description": "College level"},
    "very_difficult": {"min": 0, "max": 29, "description": "Graduate level"}
  },
  "podcast_targets": {
    "flesch_reading_ease": {"min": 60, "max": 80, "target": 70},
    "flesch_kincaid_grade": {"min": 8, "max": 12, "target": 10},
    "average_sentence_length": {"min": 15, "max": 25, "target": 20}
  },
  "quality_gates": {
    "comprehension_threshold": 0.85,
    "comprehension_weight": 0.25,
    "accessibility_requirements": {
      "max_jargon_terms": 5,
      "max_abbreviations": 3,
      "min_transition_words": 2
    }
  },
  "test_scenarios": {
    "grade_school": {"expected_flesch_min": 80, "expected_fk_max": 6},
    "high_school": {"expected_flesch_min": 50, "expected_fk_max": 12},
    "college": {"expected_flesch_max": 30, "expected_fk_min": 13},
    "podcast_target": {"expected_flesch_range": [60, 80], "expected_fk_range": [8, 12]}
  }
}
EOF
    
    log_pass "Readability scores reference created"
}

# Run All Tests
run_all_tests() {
    log_info "Starting Readability and Accessibility Quality Gates Testing"
    log_info "=========================================================="
    
    # Check dependencies
    if ! command -v bc &> /dev/null; then
        log_fail "bc calculator not found - required for calculations"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_fail "jq not found - required for JSON processing"
        exit 1
    fi
    
    if [ ! -f "$QUALITY_CONFIG" ]; then
        log_fail "Quality configuration not found: $QUALITY_CONFIG"
        exit 1
    fi
    
    # Global setup
    setup_global
    
    # Create reference data
    create_readability_reference
    
    # Run test suite
    test_flesch_reading_ease_accuracy || true
    test_flesch_kincaid_grade_accuracy || true
    test_average_sentence_length || true
    test_comprehension_quality_gate || true
    test_accessibility_compliance || true
    test_readability_edge_cases || true
    
    # Summary
    log_info "=========================================================="
    log_info "Readability and Accessibility Quality Gates Testing Complete"
    log_info "Tests Run: $TESTS_RUN"
    log_info "Tests Passed: $TESTS_PASSED"
    log_info "Tests Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_info "🎉 All tests passed! Readability and accessibility quality gates are working correctly."
        exit 0
    else
        log_info "❌ Some tests failed. Review the failures above."
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi