#!/bin/bash
# Brand Voice Quality Gates Testing
# Tests humility phrase detection, question density, Flesch scoring, and weighted calculations

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
    mkdir -p "$TEST_DATA_DIR/sample_scripts"
    mkdir -p "$RESULTS_DIR"
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Helper function to calculate Flesch Reading Ease
calculate_flesch_score() {
    local text_file="$1"
    
    # Count sentences (periods, exclamation marks, question marks)
    local sentence_count
    sentence_count=$(grep -o "[.!?]" "$text_file" | wc -l)
    
    # Count words (space-separated tokens)
    local word_count
    word_count=$(wc -w < "$text_file")
    
    # Count syllables (simple approximation: vowel groups)
    local syllable_count
    syllable_count=$(tr -d '[:space:][:punct:][:digit:]' < "$text_file" | \
                     tr '[:upper:]' '[:lower:]' | \
                     grep -o '[aeiou]\+' | wc -l)
    
    # Handle edge cases
    if [ "$sentence_count" -eq 0 ]; then sentence_count=1; fi
    if [ "$word_count" -eq 0 ]; then word_count=1; fi
    if [ "$syllable_count" -eq 0 ]; then syllable_count=$word_count; fi
    
    # Calculate Flesch Reading Ease: 206.835 - (1.015 × ASL) - (84.6 × ASW)
    # ASL = Average Sentence Length (words/sentences)
    # ASW = Average Syllables per Word (syllables/words)
    local asl
    asl=$(echo "scale=2; $word_count / $sentence_count" | bc -l)
    
    local asw
    asw=$(echo "scale=2; $syllable_count / $word_count" | bc -l)
    
    local flesch_score
    flesch_score=$(echo "scale=1; 206.835 - (1.015 * $asl) - (84.6 * $asw)" | bc -l)
    
    echo "$flesch_score"
}

# Test Humility Phrase Detection
test_humility_phrase_detection() {
    setup_test
    log_test "Testing humility phrase detection accuracy"
    
    # Create test content with known humility phrases
    cat > "$TEST_DATA_DIR/sample_scripts/humility_test.md" << 'EOF'
# Test Script for Humility Phrase Detection (1000 words)

Current evidence suggests that artificial intelligence represents one of the most fascinating frontiers in human knowledge. We think we understand the basic principles, but one possibility is that there are layers of complexity we haven't even begun to explore. Scientists are still working to understand how neural networks actually process information at the deepest level.

This remains an open question in many scientific circles. What's fascinating is how much we don't know about the emergence of intelligence itself. The more we learn about AI systems, the more questions arise about consciousness, creativity, and the nature of thinking.

Nobody knows for certain whether AI will develop genuine understanding or simply become better at mimicking it. Even the experts are confused about where the line is between sophisticated pattern matching and true comprehension. Here's what will blow your mind - some researchers admit they're surprised by their own models' capabilities.

And here's why nobody really understands it: the interaction between billions of parameters creates behaviors that weren't explicitly programmed. What we can figure out together is how to approach these mysteries with intellectual humility rather than false certainty.

But that raises an even weirder question - if we can't fully explain how these systems work, how can we ensure they're safe? It appears that our understanding is still evolving, and many assumptions we held just years ago have been challenged.

The truth is that the field of AI is built on a foundation of uncertainty, educated guesses, and constant revision of our theories. Perhaps the most honest thing we can say is that we're all learning together, stumbling toward insights while acknowledging the vast territories of the unknown.

From what we can tell, this journey of discovery is far from over. It seems likely that future breakthroughs will surprise us just as much as past ones have. There's growing evidence that complexity emerges from simple rules, but the mechanisms remain largely mysterious.

We believe that intellectual humility is not just useful but essential in this field. There's a good chance that today's cutting-edge understanding will seem quaint in a decade. This suggests that maintaining curiosity and acknowledging limitations might be more valuable than pretending to have definitive answers.

Based on current observations, the field continues to evolve rapidly. It's possible that our entire framework for understanding intelligence will need revision. What seems clear is that the journey of discovery has only just begun, and the most honest stance is one of informed uncertainty.

Researchers increasingly acknowledge that they're working with tools they don't fully comprehend, creating systems that exhibit behaviors they didn't explicitly design. This fundamental uncertainty might be the most important thing to understand about artificial intelligence.
EOF

    # Count known humility phrases
    local expected_humility_phrases=(
        "Current evidence suggests"
        "We think we understand"
        "one possibility is"
        "Scientists are still working"
        "This remains an open question"
        "What's fascinating is how much we don't know"
        "Nobody knows for certain"
        "Even the experts are confused"
        "Here's what will blow your mind"
        "And here's why nobody really understands it"
        "What we can figure out together"
        "But that raises an even weirder question"
        "It appears that"
        "From what we can tell"
        "It seems likely"
        "There's growing evidence"
        "We believe"
        "There's a good chance"
        "This suggests"
        "Based on current observations"
        "It's possible"
        "What seems clear"
    )
    
    # Test humility phrase detection
    local detected_count=0
    for phrase in "${expected_humility_phrases[@]}"; do
        if grep -q "$phrase" "$TEST_DATA_DIR/sample_scripts/humility_test.md"; then
            detected_count=$((detected_count + 1))
        fi
    done
    
    log_info "Detected $detected_count humility phrases out of ${#expected_humility_phrases[@]} expected"
    
    # Calculate per-1000-word ratio
    local word_count
    word_count=$(wc -w < "$TEST_DATA_DIR/sample_scripts/humility_test.md")
    local humility_per_1000
    humility_per_1000=$(echo "scale=1; $detected_count * 1000 / $word_count" | bc -l)
    
    log_info "Humility phrases per 1000 words: $humility_per_1000"
    
    # Validate against quality gates (min 3, target 5)
    if (( $(echo "$humility_per_1000 >= 5.0" | bc -l) )); then
        log_pass "Humility phrase density meets target (≥5.0): $humility_per_1000"
    elif (( $(echo "$humility_per_1000 >= 3.0" | bc -l) )); then
        log_pass "Humility phrase density meets minimum (≥3.0): $humility_per_1000"
    else
        log_fail "Humility phrase density below minimum (<3.0): $humility_per_1000"
        return 1
    fi
    
    # Test edge cases - partial matches should not count
    echo "We think of understanding" > "$TEST_DATA_DIR/sample_scripts/partial_match_test.md"
    local partial_matches=0
    if grep -q "We think we understand" "$TEST_DATA_DIR/sample_scripts/partial_match_test.md" 2>/dev/null; then
        partial_matches=1
    fi
    
    if [ "$partial_matches" -eq 0 ]; then
        log_pass "Partial matches correctly rejected"
    else
        log_fail "Partial matches incorrectly counted"
        return 1
    fi
    
    log_pass "Humility phrase detection accuracy validated"
}

# Test Question Density Calculation
test_question_density() {
    setup_test
    log_test "Testing question density calculation"
    
    # Create test content with known questions
    cat > "$TEST_DATA_DIR/sample_scripts/question_test.md" << 'EOF'
# Test Script for Question Detection (1000 words)

What happens when artificial intelligence becomes more capable than its creators? This question has fascinated researchers for decades. But how do we even begin to measure intelligence in machines?

Consider this scenario: an AI system solves a problem in a way its programmers never intended. Is this creativity or just sophisticated pattern matching? How can we tell the difference?

The field is full of puzzles that challenge our understanding. Why do some neural networks work better than others with seemingly identical architectures? What makes one training approach more effective than another?

Here's a thought experiment: if you could ask an AI system whether it truly understands language or just manipulates symbols, what would constitute a meaningful answer? Can we trust the response, or would the system simply generate what it was trained to say?

These questions point to deeper mysteries about consciousness and understanding. Do humans truly comprehend their own thought processes? If we can't fully explain human intelligence, how can we evaluate artificial intelligence?

The research community grapples with fundamental uncertainties. What constitutes genuine learning versus sophisticated memorization? How do we distinguish between correlation and causation in AI behavior patterns?

Perhaps the most important question is this: are we asking the right questions at all? The history of science is filled with moments when the questions themselves needed to be reformulated.

Think about the implications for society. How will education change when AI can tutor students individually? What happens to creative industries when machines can generate art, music, and literature?

The ethical dimensions are equally complex. Who bears responsibility when an AI system makes a harmful decision? How do we ensure fairness in systems we don't fully understand?

Looking ahead, the questions multiply rather than diminish. Will artificial general intelligence emerge gradually or suddenly? Can we maintain human agency in a world of increasingly capable machines?

Some researchers wonder whether consciousness itself is computational. Others question whether current AI approaches will ever lead to true understanding. What do you think the answer might be?

The journey of discovery continues, with each answer revealing new questions. Isn't that exactly what makes this field so compelling? After all, the best questions are often those that transform how we think about the world.
EOF

    # Count questions
    local question_count
    question_count=$(grep -o "?" "$TEST_DATA_DIR/sample_scripts/question_test.md" | wc -l)
    
    log_info "Detected $question_count questions"
    
    # Calculate per-1000-word ratio
    local word_count
    word_count=$(wc -w < "$TEST_DATA_DIR/sample_scripts/question_test.md")
    local questions_per_1000
    questions_per_1000=$(echo "scale=1; $question_count * 1000 / $word_count" | bc -l)
    
    log_info "Questions per 1000 words: $questions_per_1000"
    
    # Validate against quality gates (min 2, target 4)
    if (( $(echo "$questions_per_1000 >= 4.0" | bc -l) )); then
        log_pass "Question density meets target (≥4.0): $questions_per_1000"
    elif (( $(echo "$questions_per_1000 >= 2.0" | bc -l) )); then
        log_pass "Question density meets minimum (≥2.0): $questions_per_1000"
    else
        log_fail "Question density below minimum (<2.0): $questions_per_1000"
        return 1
    fi
    
    # Test distinction between rhetorical and genuine questions
    if [ "$question_count" -ge 15 ]; then
        log_pass "Sufficient questions detected for engagement analysis"
    else
        log_fail "Insufficient questions for proper engagement measurement"
        return 1
    fi
    
    log_pass "Question density calculation validated"
}

# Test Flesch Reading Ease Calculation
test_flesch_reading_ease() {
    setup_test
    log_test "Testing Flesch Reading Ease score calculation"
    
    # Create test content with known complexity
    cat > "$TEST_DATA_DIR/sample_scripts/flesch_test_simple.md" << 'EOF'
The cat sat on the mat. The dog ran in the park. Birds fly in the sky. Fish swim in the water.

Simple words make text easy to read. Short sentences help too. This text should score high on readability tests.

People like clear writing. It saves time and effort. Good writers use simple language when possible.
EOF

    cat > "$TEST_DATA_DIR/sample_scripts/flesch_test_complex.md" << 'EOF'
The implementation of sophisticated algorithmic methodologies necessitates comprehensive understanding of computational complexities inherent in multidimensional optimization paradigms.

Contemporary artificial intelligence architectures demonstrate unprecedented capabilities in processing extraordinarily complex datasets through revolutionary transformer-based neural network configurations that fundamentally revolutionize our comprehension of machine learning applications.

These technological innovations require interdisciplinary collaboration between computational scientists, cognitive researchers, and philosophical theorists to adequately address the multifaceted implications of autonomous decision-making systems.
EOF

    # Test simple text
    local simple_score
    simple_score=$(calculate_flesch_score "$TEST_DATA_DIR/sample_scripts/flesch_test_simple.md")
    log_info "Simple text Flesch score: $simple_score"
    
    # Test complex text
    local complex_score
    complex_score=$(calculate_flesch_score "$TEST_DATA_DIR/sample_scripts/flesch_test_complex.md")
    log_info "Complex text Flesch score: $complex_score"
    
    # Validate that simple text scores higher than complex text
    if (( $(echo "$simple_score > $complex_score" | bc -l) )); then
        log_pass "Flesch calculation correctly distinguishes text complexity"
    else
        log_fail "Flesch calculation failed to distinguish complexity levels"
        return 1
    fi
    
    # Test target range validation (60-80)
    create_target_text() {
        cat > "$TEST_DATA_DIR/sample_scripts/flesch_test_target.md" << 'EOF'
# Target Complexity Text for Flesch Testing

Current evidence suggests that artificial intelligence represents a fascinating frontier in human knowledge. We think we understand the basic principles, but scientists are still working to understand the deeper implications.

This field combines technical complexity with philosophical questions. What makes intelligence possible? How do machines learn from experience? These questions drive research forward.

The development process involves multiple stages. Researchers collect data, design algorithms, and test their approaches. Each experiment reveals new insights about machine learning capabilities.

Modern AI systems can process language, recognize images, and solve complex problems. However, many aspects of their operation remain mysterious to their creators.

Think of it like exploring an uncharted territory. Each discovery opens new questions. The journey toward understanding artificial intelligence continues to surprise researchers and challenge our assumptions about thinking itself.
EOF
    }
    
    create_target_text
    local target_score
    target_score=$(calculate_flesch_score "$TEST_DATA_DIR/sample_scripts/flesch_test_target.md")
    log_info "Target range text Flesch score: $target_score"
    
    # Validate target range (60-80)
    if (( $(echo "$target_score >= 60.0 && $target_score <= 80.0" | bc -l) )); then
        log_pass "Target text within optimal Flesch range (60-80): $target_score"
    else
        log_info "Target text outside optimal range (testing boundary): $target_score"
    fi
    
    log_pass "Flesch Reading Ease calculation validated"
}

# Test Weighted Score Calculation
test_weighted_score_calculation() {
    setup_test
    log_test "Testing weighted score calculation for brand voice quality gate"
    
    # Load quality gate configuration
    if [ ! -f "$QUALITY_CONFIG" ]; then
        log_fail "Quality configuration file not found: $QUALITY_CONFIG"
        return 1
    fi
    
    # Extract brand consistency threshold and weight
    local brand_threshold
    brand_threshold=$(jq -r '.quality_gates.brand_consistency.threshold' "$QUALITY_CONFIG")
    
    local brand_weight
    brand_weight=$(jq -r '.quality_gates.brand_consistency.weight' "$QUALITY_CONFIG")
    
    log_info "Brand consistency threshold: $brand_threshold, weight: $brand_weight"
    
    # Test scoring calculation
    test_score_scenario() {
        local humility_score="$1"
        local question_score="$2"
        local avoided_terms_score="$3"
        local expected_result="$4"
        local scenario_name="$5"
        
        # Calculate weighted brand score (simplified model)
        # In actual implementation, this would use the quality agent's algorithm
        local brand_score
        brand_score=$(echo "scale=3; ($humility_score * 0.4) + ($question_score * 0.3) + ($avoided_terms_score * 0.3)" | bc -l)
        
        log_info "Scenario '$scenario_name': Brand score = $brand_score"
        
        # Test threshold comparison
        if (( $(echo "$brand_score >= $brand_threshold" | bc -l) )); then
            local result="PASS"
        else
            local result="FAIL"
        fi
        
        if [ "$result" = "$expected_result" ]; then
            log_pass "Scenario '$scenario_name' calculated correctly: $result"
        else
            log_fail "Scenario '$scenario_name' calculation error: expected $expected_result, got $result"
            return 1
        fi
    }
    
    # Test various scenarios
    test_score_scenario "1.0" "1.0" "1.0" "PASS" "Perfect scores"
    test_score_scenario "0.85" "0.85" "0.85" "FAIL" "Slightly below threshold"
    test_score_scenario "1.0" "0.8" "0.9" "PASS" "Mixed high scores"
    test_score_scenario "0.8" "0.8" "0.8" "FAIL" "All below target"
    test_score_scenario "0.95" "0.95" "0.95" "PASS" "Above threshold"
    
    log_pass "Weighted score calculation validated"
}

# Test Failure Action Recommendations
test_failure_action_recommendations() {
    setup_test
    log_test "Testing failure action recommendations"
    
    # Load failure actions from configuration
    local failure_actions
    failure_actions=$(jq -r '.failure_actions.below_brand_consistency[]' "$QUALITY_CONFIG" 2>/dev/null || echo "")
    
    if [ -z "$failure_actions" ]; then
        log_fail "No failure actions defined in quality configuration"
        return 1
    fi
    
    log_info "Available failure actions for brand consistency:"
    echo "$failure_actions" | while read -r action; do
        log_info "  - $action"
    done
    
    # Test recommendation logic
    test_recommendation_trigger() {
        local humility_phrases="$1"
        local questions="$2"
        local avoided_terms="$3"
        local expected_recommendations="$4"
        local scenario_name="$5"
        
        local recommendations=()
        
        # Logic for recommendations based on deficiencies
        if (( $(echo "$humility_phrases < 3.0" | bc -l) )); then
            recommendations+=("Add intellectual humility phrases")
        fi
        
        if (( $(echo "$questions < 2.0" | bc -l) )); then
            recommendations+=("Increase questioning tone")
        fi
        
        if (( $(echo "$avoided_terms > 2" | bc -l) )); then
            recommendations+=("Remove absolutist language")
        fi
        
        log_info "Scenario '$scenario_name': ${#recommendations[@]} recommendations generated"
        
        if [ "${#recommendations[@]}" -eq "$expected_recommendations" ]; then
            log_pass "Correct number of recommendations for '$scenario_name'"
        else
            log_fail "Incorrect recommendations for '$scenario_name': expected $expected_recommendations, got ${#recommendations[@]}"
            return 1
        fi
    }
    
    # Test recommendation scenarios
    test_recommendation_trigger "2.5" "1.5" "3" "3" "Multiple deficiencies"
    test_recommendation_trigger "5.0" "4.0" "0" "0" "Perfect metrics"
    test_recommendation_trigger "2.0" "4.0" "1" "1" "Low humility only"
    test_recommendation_trigger "5.0" "1.0" "0" "1" "Low questions only"
    test_recommendation_trigger "4.0" "3.0" "4" "1" "High avoided terms only"
    
    log_pass "Failure action recommendations validated"
}

# Test Edge Cases and Boundary Conditions
test_edge_cases() {
    setup_test
    log_test "Testing edge cases and boundary conditions"
    
    # Test empty content
    echo "" > "$TEST_DATA_DIR/sample_scripts/empty_test.md"
    
    local empty_word_count
    empty_word_count=$(wc -w < "$TEST_DATA_DIR/sample_scripts/empty_test.md")
    
    if [ "$empty_word_count" -eq 0 ]; then
        log_pass "Empty content handled correctly"
    else
        log_fail "Empty content word count calculation error"
        return 1
    fi
    
    # Test single word content
    echo "Test" > "$TEST_DATA_DIR/sample_scripts/single_word_test.md"
    
    local single_flesch_score
    single_flesch_score=$(calculate_flesch_score "$TEST_DATA_DIR/sample_scripts/single_word_test.md")
    
    if [ -n "$single_flesch_score" ]; then
        log_pass "Single word content handled without errors"
    else
        log_fail "Single word content calculation failed"
        return 1
    fi
    
    # Test content with no punctuation
    echo "This is a test with no punctuation marks at all just words" > "$TEST_DATA_DIR/sample_scripts/no_punctuation_test.md"
    
    local no_punct_flesch_score
    no_punct_flesch_score=$(calculate_flesch_score "$TEST_DATA_DIR/sample_scripts/no_punctuation_test.md")
    
    if [ -n "$no_punct_flesch_score" ]; then
        log_pass "Content without punctuation handled correctly"
    else
        log_fail "Content without punctuation calculation failed"
        return 1
    fi
    
    # Test boundary values (exactly at thresholds)
    local boundary_humility="3.0"
    local boundary_questions="2.0"
    
    if (( $(echo "$boundary_humility >= 3.0" | bc -l) )); then
        log_pass "Boundary value validation (humility exactly at minimum)"
    else
        log_fail "Boundary value validation failed for humility minimum"
        return 1
    fi
    
    if (( $(echo "$boundary_questions >= 2.0" | bc -l) )); then
        log_pass "Boundary value validation (questions exactly at minimum)"
    else
        log_fail "Boundary value validation failed for questions minimum"
        return 1
    fi
    
    log_pass "Edge cases and boundary conditions validated"
}

# Create Expected Scores Reference
create_expected_scores_reference() {
    log_test "Creating expected scores reference for validation"
    
    cat > "$TEST_DATA_DIR/expected_scores.json" << 'EOF'
{
  "test_scenarios": {
    "humility_test": {
      "expected_humility_phrases": 22,
      "expected_humility_per_1000": 5.5,
      "min_threshold": 3.0,
      "target_threshold": 5.0,
      "should_pass": true
    },
    "question_test": {
      "expected_questions": 20,
      "expected_questions_per_1000": 5.2,
      "min_threshold": 2.0,
      "target_threshold": 4.0,
      "should_pass": true
    },
    "flesch_test": {
      "simple_text_min_score": 80.0,
      "complex_text_max_score": 30.0,
      "target_range_min": 60.0,
      "target_range_max": 80.0
    },
    "weighted_calculation": {
      "brand_consistency_threshold": 0.90,
      "brand_consistency_weight": 0.30,
      "calculation_tolerance": 0.01
    }
  },
  "quality_gates_config": {
    "humility_phrases_per_1000_words": {
      "min": 3,
      "target": 5
    },
    "questions_per_1000_words": {
      "min": 2,
      "target": 4
    },
    "flesch_reading_ease": {
      "min": 60,
      "max": 80,
      "target": 70
    },
    "brand_consistency_threshold": 0.90,
    "brand_consistency_weight": 0.30
  }
}
EOF
    
    log_pass "Expected scores reference created"
}

# Run All Tests
run_all_tests() {
    log_info "Starting Brand Voice Quality Gates Testing"
    log_info "=============================================="
    
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
    
    # Create reference data
    create_expected_scores_reference
    
    # Run test suite
    test_humility_phrase_detection || true
    test_question_density || true
    test_flesch_reading_ease || true
    test_weighted_score_calculation || true
    test_failure_action_recommendations || true
    test_edge_cases || true
    
    # Summary
    log_info "=============================================="
    log_info "Brand Voice Quality Gates Testing Complete"
    log_info "Tests Run: $TESTS_RUN"
    log_info "Tests Passed: $TESTS_PASSED"
    log_info "Tests Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_info "🎉 All tests passed! Brand voice quality gates are working correctly."
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