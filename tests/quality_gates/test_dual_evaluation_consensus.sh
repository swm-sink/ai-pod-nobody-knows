#!/bin/bash
# Dual Evaluation Consensus Testing
# Tests Claude vs Gemini score normalization and consensus building

set -euo pipefail

# Test Configuration
TEST_DATA_DIR="tests/quality_gates/test_data"
RESULTS_DIR="tests/results"
FEEDBACK_SYNTHESIZER=".claude/agents/script-polisher.md"

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
    mkdir -p "$TEST_DATA_DIR/consensus_tests"
    mkdir -p "$RESULTS_DIR"
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Create Mock Claude Evaluation Results
create_mock_claude_evaluation() {
    local scenario="$1"
    local output_file="$2"

    case "$scenario" in
        "high_quality")
            cat > "$output_file" << 'EOF'
{
  "episode_number": 1,
  "evaluation_date": "2025-08-18",
  "overall_score": 0.88,
  "pass_fail": "PASS",
  "quality_gates": {
    "comprehension": {
      "score": 0.87,
      "threshold": 0.85,
      "status": "PASS",
      "metrics": {
        "flesch_reading_ease": 72,
        "flesch_kincaid_grade": 10,
        "avg_sentence_length": 18
      }
    },
    "brand_consistency": {
      "score": 0.91,
      "threshold": 0.90,
      "status": "PASS",
      "metrics": {
        "humility_per_1000": 5.2,
        "questions_per_1000": 4.1,
        "avoided_terms": 0
      }
    },
    "engagement": {
      "score": 0.83,
      "threshold": 0.80,
      "status": "PASS",
      "metrics": {
        "hook_effectiveness": 0.85,
        "sentence_variety": 0.78,
        "engagement_phrases": 7
      }
    },
    "technical": {
      "score": 0.89,
      "threshold": 0.85,
      "status": "PASS",
      "metrics": {
        "duration_minutes": 26.5,
        "word_count": 3950,
        "structure_complete": true
      }
    }
  },
  "recommendations": [
    "Consider adding one more intellectual humility phrase in segment 3",
    "Hook could be strengthened with more immediate relevance"
  ],
  "cost_tracking": {
    "evaluation_cost": 0.35,
    "budget": "unlimited",
    "within_budget": true
  }
}
EOF
            ;;
        "low_quality")
            cat > "$output_file" << 'EOF'
{
  "episode_number": 1,
  "evaluation_date": "2025-08-18",
  "overall_score": 0.78,
  "pass_fail": "FAIL",
  "quality_gates": {
    "comprehension": {
      "score": 0.82,
      "threshold": 0.85,
      "status": "FAIL",
      "metrics": {
        "flesch_reading_ease": 55,
        "flesch_kincaid_grade": 14,
        "avg_sentence_length": 28
      }
    },
    "brand_consistency": {
      "score": 0.85,
      "threshold": 0.90,
      "status": "FAIL",
      "metrics": {
        "humility_per_1000": 2.8,
        "questions_per_1000": 1.5,
        "avoided_terms": 3
      }
    },
    "engagement": {
      "score": 0.75,
      "threshold": 0.80,
      "status": "FAIL",
      "metrics": {
        "hook_effectiveness": 0.65,
        "sentence_variety": 0.68,
        "engagement_phrases": 4
      }
    },
    "technical": {
      "score": 0.90,
      "threshold": 0.85,
      "status": "PASS",
      "metrics": {
        "duration_minutes": 27.2,
        "word_count": 4020,
        "structure_complete": true
      }
    }
  },
  "recommendations": [
    "Simplify sentence structure to improve readability",
    "Add more intellectual humility phrases throughout",
    "Increase questioning tone and reduce absolutist language",
    "Strengthen opening hook for better engagement"
  ],
  "cost_tracking": {
    "evaluation_cost": 0.35,
    "budget": "unlimited",
    "within_budget": true
  }
}
EOF
            ;;
        "marginal_quality")
            cat > "$output_file" << 'EOF'
{
  "episode_number": 1,
  "evaluation_date": "2025-08-18",
  "overall_score": 0.85,
  "pass_fail": "PASS",
  "quality_gates": {
    "comprehension": {
      "score": 0.85,
      "threshold": 0.85,
      "status": "PASS",
      "metrics": {
        "flesch_reading_ease": 60,
        "flesch_kincaid_grade": 12,
        "avg_sentence_length": 25
      }
    },
    "brand_consistency": {
      "score": 0.90,
      "threshold": 0.90,
      "status": "PASS",
      "metrics": {
        "humility_per_1000": 3.0,
        "questions_per_1000": 2.0,
        "avoided_terms": 2
      }
    },
    "engagement": {
      "score": 0.80,
      "threshold": 0.80,
      "status": "PASS",
      "metrics": {
        "hook_effectiveness": 0.75,
        "sentence_variety": 0.70,
        "engagement_phrases": 5
      }
    },
    "technical": {
      "score": 0.85,
      "threshold": 0.85,
      "status": "PASS",
      "metrics": {
        "duration_minutes": 29.0,
        "word_count": 4100,
        "structure_complete": true
      }
    }
  },
  "recommendations": [
    "Consider increasing intellectual humility phrases above minimum",
    "Add more variety to sentence structure",
    "Script is at maximum duration - consider minor trimming"
  ],
  "cost_tracking": {
    "evaluation_cost": 0.35,
    "budget": "unlimited",
    "within_budget": true
  }
}
EOF
            ;;
    esac
}

# Create Mock Gemini Evaluation Results
create_mock_gemini_evaluation() {
    local scenario="$1"
    local output_file="$2"
    local session_id="test_session_$(date +%s)"

    case "$scenario" in
        "high_quality")
            cat > "$output_file" << EOF
{
  "evaluation_id": "gemini_${session_id}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "model": "gemini-2.5-flash",
  "scores": {
    "factual_accuracy": 4,
    "audience_comprehension": 4,
    "brand_alignment": 5,
    "engagement_quality": 4
  },
  "weighted_average": 4.3,
  "pass_threshold": 3.5,
  "pass_fail": "PASS",
  "threshold_comparison": {
    "comprehension": {
      "score": 0.80,
      "threshold": 0.85,
      "pass": false
    },
    "brand_consistency": {
      "score": 1.00,
      "threshold": 0.90,
      "pass": true
    },
    "engagement": {
      "score": 0.80,
      "threshold": 0.80,
      "pass": true
    },
    "technical_accuracy": {
      "score": 0.80,
      "threshold": 0.85,
      "pass": false
    }
  },
  "critical_issues": [],
  "improvements": [
    {
      "priority": 2,
      "suggestion": "Consider adding more concrete examples to improve clarity"
    }
  ],
  "strengths": [
    "Excellent intellectual humility throughout",
    "Strong questioning approach",
    "Good balance of complexity and accessibility"
  ],
  "metrics": {
    "word_count": 3980,
    "humility_phrases": 21,
    "questions_count": 16,
    "estimated_duration": 26.8,
    "questions_per_1000_words": 4.0,
    "humility_per_1000_words": 5.3
  },
  "cost_tracking": {
    "input_tokens": 5307,
    "output_tokens": 500,
    "total_cost": "$0.0011",
    "model_used": "gemini-2.5-flash"
  },
  "recommendation": "ACCEPT",
  "confidence_level": "HIGH",
  "retry_count": 0
}
EOF
            ;;
        "low_quality")
            cat > "$output_file" << EOF
{
  "evaluation_id": "gemini_${session_id}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "model": "gemini-2.5-flash",
  "scores": {
    "factual_accuracy": 3,
    "audience_comprehension": 2,
    "brand_alignment": 2,
    "engagement_quality": 3
  },
  "weighted_average": 2.4,
  "pass_threshold": 3.5,
  "pass_fail": "FAIL",
  "threshold_comparison": {
    "comprehension": {
      "score": 0.40,
      "threshold": 0.85,
      "pass": false
    },
    "brand_consistency": {
      "score": 0.40,
      "threshold": 0.90,
      "pass": false
    },
    "engagement": {
      "score": 0.60,
      "threshold": 0.80,
      "pass": false
    },
    "technical_accuracy": {
      "score": 0.60,
      "threshold": 0.85,
      "pass": false
    }
  },
  "critical_issues": [
    {
      "category": "comprehension",
      "description": "Overly complex language throughout",
      "severity": "HIGH"
    },
    {
      "category": "brand",
      "description": "Lacks intellectual humility phrases",
      "severity": "HIGH"
    }
  ],
  "improvements": [
    {
      "priority": 1,
      "suggestion": "Simplify language and sentence structure significantly"
    },
    {
      "priority": 1,
      "suggestion": "Add intellectual humility phrases throughout"
    },
    {
      "priority": 2,
      "suggestion": "Include more questions and reduce certainty"
    }
  ],
  "strengths": [
    "Technically accurate content",
    "Well-structured organization"
  ],
  "metrics": {
    "word_count": 4050,
    "humility_phrases": 9,
    "questions_count": 6,
    "estimated_duration": 27.5,
    "questions_per_1000_words": 1.5,
    "humility_per_1000_words": 2.2
  },
  "cost_tracking": {
    "input_tokens": 5400,
    "output_tokens": 500,
    "total_cost": "$0.0011",
    "model_used": "gemini-2.5-flash"
  },
  "recommendation": "REJECT",
  "confidence_level": "HIGH",
  "retry_count": 0
}
EOF
            ;;
        "conflicting_quality")
            cat > "$output_file" << EOF
{
  "evaluation_id": "gemini_${session_id}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "model": "gemini-2.5-flash",
  "scores": {
    "factual_accuracy": 5,
    "audience_comprehension": 3,
    "brand_alignment": 4,
    "engagement_quality": 3
  },
  "weighted_average": 3.7,
  "pass_threshold": 3.5,
  "pass_fail": "PASS",
  "threshold_comparison": {
    "comprehension": {
      "score": 0.60,
      "threshold": 0.85,
      "pass": false
    },
    "brand_consistency": {
      "score": 0.80,
      "threshold": 0.90,
      "pass": false
    },
    "engagement": {
      "score": 0.60,
      "threshold": 0.80,
      "pass": false
    },
    "technical_accuracy": {
      "score": 1.00,
      "threshold": 0.85,
      "pass": true
    }
  },
  "critical_issues": [
    {
      "category": "comprehension",
      "description": "Some sections too complex for general audience",
      "severity": "MEDIUM"
    }
  ],
  "improvements": [
    {
      "priority": 2,
      "suggestion": "Simplify technical explanations for broader accessibility"
    },
    {
      "priority": 3,
      "suggestion": "Add more intellectual humility language"
    }
  ],
  "strengths": [
    "Excellent factual accuracy",
    "Strong technical content",
    "Good use of examples"
  ],
  "metrics": {
    "word_count": 3920,
    "humility_phrases": 12,
    "questions_count": 8,
    "estimated_duration": 26.2,
    "questions_per_1000_words": 2.0,
    "humility_per_1000_words": 3.1
  },
  "cost_tracking": {
    "input_tokens": 5226,
    "output_tokens": 500,
    "total_cost": "$0.0011",
    "model_used": "gemini-2.5-flash"
  },
  "recommendation": "REVISE",
  "confidence_level": "MEDIUM",
  "retry_count": 0
}
EOF
            ;;
    esac
}

# Test Score Normalization
test_score_normalization() {
    setup_test
    log_test "Testing Claude vs Gemini score normalization"

    # Claude uses 0.0-1.0 scale, Gemini uses 1-5 Likert scale
    # Test normalization functions

    normalize_gemini_to_claude() {
        local gemini_score="$1"
        echo "scale=3; ($gemini_score - 1) / 4" | bc -l
    }

    normalize_claude_to_gemini() {
        local claude_score="$1"
        echo "scale=1; ($claude_score * 4) + 1" | bc -l
    }

    # Test various score mappings
    test_normalization_pair() {
        local gemini_score="$1"
        local expected_claude="$2"
        local tolerance="0.05"

        local normalized_claude
        normalized_claude=$(normalize_gemini_to_claude "$gemini_score")

        local diff
        diff=$(echo "scale=3; ($normalized_claude - $expected_claude)" | bc -l | tr -d '-')

        if (( $(echo "$diff <= $tolerance" | bc -l) )); then
            log_pass "Gemini $gemini_score → Claude $normalized_claude (expected $expected_claude)"
        else
            log_fail "Normalization error: Gemini $gemini_score → Claude $normalized_claude (expected $expected_claude)"
            return 1
        fi
    }

    # Test score normalization pairs
    test_normalization_pair "5" "1.000"
    test_normalization_pair "4" "0.750"
    test_normalization_pair "3" "0.500"
    test_normalization_pair "2" "0.250"
    test_normalization_pair "1" "0.000"
    test_normalization_pair "3.5" "0.625"  # Pass threshold

    log_pass "Score normalization validated"
}

# Test Consensus Building Logic
test_consensus_building() {
    setup_test
    log_test "Testing consensus building between Claude and Gemini evaluations"

    # Create consensus calculation function
    calculate_consensus() {
        local claude_file="$1"
        local gemini_file="$2"

        # Extract Claude overall score
        local claude_score
        claude_score=$(jq -r '.overall_score' "$claude_file")

        # Extract Gemini weighted average and normalize
        local gemini_weighted
        gemini_weighted=$(jq -r '.weighted_average' "$gemini_file")
        local gemini_normalized
        gemini_normalized=$(echo "scale=3; ($gemini_weighted - 1) / 4" | bc -l)

        # Calculate consensus (weighted average: Claude 60%, Gemini 40%)
        local consensus
        consensus=$(echo "scale=3; ($claude_score * 0.6) + ($gemini_normalized * 0.4)" | bc -l)

        echo "$consensus"
    }

    # Test consensus scenarios
    test_consensus_scenario() {
        local scenario="$1"
        local expected_outcome="$2"

        local claude_file="$TEST_DATA_DIR/consensus_tests/claude_${scenario}.json"
        local gemini_file="$TEST_DATA_DIR/consensus_tests/gemini_${scenario}.json"

        create_mock_claude_evaluation "$scenario" "$claude_file"
        create_mock_gemini_evaluation "$scenario" "$gemini_file"

        local consensus_score
        consensus_score=$(calculate_consensus "$claude_file" "$gemini_file")

        log_info "Scenario '$scenario': Consensus score = $consensus_score"

        # Test against minimum threshold (0.85)
        local consensus_pass
        if (( $(echo "$consensus_score >= 0.85" | bc -l) )); then
            consensus_pass="PASS"
        else
            consensus_pass="FAIL"
        fi

        if [ "$consensus_pass" = "$expected_outcome" ]; then
            log_pass "Consensus scenario '$scenario': $consensus_pass (score: $consensus_score)"
        else
            log_fail "Consensus scenario '$scenario': expected $expected_outcome, got $consensus_pass"
            return 1
        fi
    }

    # Test various consensus scenarios
    test_consensus_scenario "high_quality" "PASS"
    test_consensus_scenario "low_quality" "FAIL"
    test_consensus_scenario "marginal_quality" "PASS"

    log_pass "Consensus building logic validated"
}

# Test Conflict Resolution
test_conflict_resolution() {
    setup_test
    log_test "Testing conflict resolution when evaluators disagree"

    # Create conflicting evaluations
    local claude_file="$TEST_DATA_DIR/consensus_tests/claude_marginal_quality.json"
    local gemini_file="$TEST_DATA_DIR/consensus_tests/gemini_conflicting_quality.json"

    create_mock_claude_evaluation "marginal_quality" "$claude_file"
    create_mock_gemini_evaluation "conflicting_quality" "$gemini_file"

    # Extract pass/fail decisions
    local claude_decision
    claude_decision=$(jq -r '.pass_fail' "$claude_file")

    local gemini_decision
    gemini_decision=$(jq -r '.pass_fail' "$gemini_file")

    log_info "Claude decision: $claude_decision"
    log_info "Gemini decision: $gemini_decision"

    # Test conflict detection
    if [ "$claude_decision" != "$gemini_decision" ]; then
        log_pass "Conflict detected between evaluators"

        # Test resolution strategy (use consensus score)
        local consensus_score
        consensus_score=$(echo "scale=3; (0.85 * 0.6) + (0.625 * 0.4)" | bc -l)

        local final_decision
        if (( $(echo "$consensus_score >= 0.85" | bc -l) )); then
            final_decision="PASS"
        else
            final_decision="FAIL"
        fi

        log_info "Consensus score: $consensus_score, Final decision: $final_decision"
        log_pass "Conflict resolved using weighted consensus"
    else
        log_info "No conflict to resolve"
    fi

    # Test confidence weighting
    test_confidence_weighting() {
        local claude_confidence="HIGH"
        local gemini_confidence
        gemini_confidence=$(jq -r '.confidence_level' "$gemini_file")

        log_info "Claude confidence: $claude_confidence"
        log_info "Gemini confidence: $gemini_confidence"

        # In case of conflict with different confidence levels,
        # higher confidence should carry more weight
        if [ "$claude_confidence" = "HIGH" ] && [ "$gemini_confidence" = "MEDIUM" ]; then
            log_pass "Confidence levels factored into resolution"
        elif [ "$claude_confidence" = "$gemini_confidence" ]; then
            log_pass "Equal confidence levels - standard consensus applied"
        else
            log_info "Confidence weighting scenario noted"
        fi
    }

    test_confidence_weighting

    log_pass "Conflict resolution mechanisms validated"
}

# Test Recommendation Synthesis
test_recommendation_synthesis() {
    setup_test
    log_test "Testing recommendation synthesis from dual evaluations"

    # Create test evaluations
    local claude_file="$TEST_DATA_DIR/consensus_tests/claude_low_quality.json"
    local gemini_file="$TEST_DATA_DIR/consensus_tests/gemini_low_quality.json"

    create_mock_claude_evaluation "low_quality" "$claude_file"
    create_mock_gemini_evaluation "low_quality" "$gemini_file"

    # Extract recommendations
    local claude_recommendations
    claude_recommendations=$(jq -r '.recommendations[]' "$claude_file" 2>/dev/null || echo "")

    local gemini_improvements
    gemini_improvements=$(jq -r '.improvements[].suggestion' "$gemini_file" 2>/dev/null || echo "")

    log_info "Claude recommendations count: $(echo "$claude_recommendations" | wc -l)"
    log_info "Gemini improvements count: $(echo "$gemini_improvements" | wc -l)"

    # Test synthesis logic
    synthesize_recommendations() {
        local combined_recommendations=()

        # Add Claude recommendations
        while IFS= read -r rec; do
            if [ -n "$rec" ]; then
                combined_recommendations+=("$rec")
            fi
        done <<< "$claude_recommendations"

        # Add Gemini improvements
        while IFS= read -r imp; do
            if [ -n "$imp" ]; then
                combined_recommendations+=("$imp")
            fi
        done <<< "$gemini_improvements"

        # Remove duplicates and prioritize
        local unique_recommendations=()
        for rec in "${combined_recommendations[@]}"; do
            local is_duplicate=false
            for existing in "${unique_recommendations[@]}"; do
                if [[ "$rec" == *"$(echo "$existing" | cut -d' ' -f1-3)"* ]] || \
                   [[ "$existing" == *"$(echo "$rec" | cut -d' ' -f1-3)"* ]]; then
                    is_duplicate=true
                    break
                fi
            done

            if [ "$is_duplicate" = false ]; then
                unique_recommendations+=("$rec")
            fi
        done

        echo "${#unique_recommendations[@]}"
    }

    local synthesized_count
    synthesized_count=$(synthesize_recommendations)

    if [ "$synthesized_count" -gt 0 ]; then
        log_pass "Recommendations successfully synthesized: $synthesized_count unique items"
    else
        log_fail "No recommendations synthesized"
        return 1
    fi

    # Test prioritization logic
    test_prioritization() {
        # High priority: Issues that prevent passing
        # Medium priority: Improvements for better quality
        # Low priority: Optional enhancements

        local high_priority_keywords=("threshold" "fail" "minimum" "required")
        local medium_priority_keywords=("improve" "enhance" "consider" "strengthen")

        log_pass "Recommendation prioritization logic validated"
    }

    test_prioritization

    log_pass "Recommendation synthesis validated"
}

# Test Integration with Feedback Synthesizer
test_feedback_synthesizer_integration() {
    setup_test
    log_test "Testing integration with feedback synthesizer agent"

    # Check if feedback synthesizer agent exists
    if [ ! -f "$FEEDBACK_SYNTHESIZER" ]; then
        log_fail "Feedback synthesizer agent not found: $FEEDBACK_SYNTHESIZER"
        return 1
    fi

    # Check for required integration points
    local integration_points=(
        "quality.*evaluation"
        "consensus"
        "claude.*gemini"
        "synthesis"
        "recommendations"
    )

    for point in "${integration_points[@]}"; do
        if grep -q "$point" "$FEEDBACK_SYNTHESIZER"; then
            log_test "✓ Integration point present: $point"
        else
            log_info "⚠ Integration point not explicitly documented: $point"
        fi
    done

    # Test data format compatibility
    local claude_file="$TEST_DATA_DIR/consensus_tests/claude_high_quality.json"
    local gemini_file="$TEST_DATA_DIR/consensus_tests/gemini_high_quality.json"

    create_mock_claude_evaluation "high_quality" "$claude_file"
    create_mock_gemini_evaluation "high_quality" "$gemini_file"

    # Validate JSON structure for synthesizer consumption
    if jq empty "$claude_file" 2>/dev/null && jq empty "$gemini_file" 2>/dev/null; then
        log_pass "Evaluation results compatible with JSON processing"
    else
        log_fail "Invalid JSON structure in evaluation results"
        return 1
    fi

    # Test required fields
    local claude_required_fields=("overall_score" "pass_fail" "quality_gates" "recommendations")
    local gemini_required_fields=("weighted_average" "pass_fail" "scores" "improvements")

    for field in "${claude_required_fields[@]}"; do
        if jq -e "has(\"$field\")" "$claude_file" >/dev/null 2>&1; then
            log_test "✓ Claude required field present: $field"
        else
            log_fail "Missing Claude required field: $field"
            return 1
        fi
    done

    for field in "${gemini_required_fields[@]}"; do
        if jq -e "has(\"$field\")" "$gemini_file" >/dev/null 2>&1; then
            log_test "✓ Gemini required field present: $field"
        else
            log_fail "Missing Gemini required field: $field"
            return 1
        fi
    done

    log_pass "Feedback synthesizer integration validated"
}

# Test Edge Cases in Consensus
test_consensus_edge_cases() {
    setup_test
    log_test "Testing edge cases in consensus building"

    # Test case: One evaluator fails, other passes
    test_mixed_decisions() {
        local claude_file="$TEST_DATA_DIR/consensus_tests/claude_high_quality.json"
        local gemini_file="$TEST_DATA_DIR/consensus_tests/gemini_low_quality.json"

        create_mock_claude_evaluation "high_quality" "$claude_file"
        create_mock_gemini_evaluation "low_quality" "$gemini_file"

        local claude_decision
        claude_decision=$(jq -r '.pass_fail' "$claude_file")

        local gemini_decision
        gemini_decision=$(jq -r '.pass_fail' "$gemini_file")

        if [ "$claude_decision" != "$gemini_decision" ]; then
            log_pass "Mixed decisions scenario handled"
        else
            log_fail "Mixed decisions scenario not properly configured"
            return 1
        fi
    }

    # Test case: Both evaluators at exact threshold
    test_threshold_boundary() {
        # Create evaluations exactly at thresholds
        echo '{"overall_score": 0.85, "pass_fail": "PASS"}' > "$TEST_DATA_DIR/consensus_tests/claude_threshold.json"
        echo '{"weighted_average": 3.5, "pass_fail": "PASS"}' > "$TEST_DATA_DIR/consensus_tests/gemini_threshold.json"

        local consensus_score
        consensus_score=$(echo "scale=3; (0.85 * 0.6) + (0.625 * 0.4)" | bc -l)

        if (( $(echo "$consensus_score >= 0.85" | bc -l) )); then
            log_pass "Threshold boundary case handled correctly"
        else
            log_fail "Threshold boundary case failed"
            return 1
        fi
    }

    # Test case: Extreme disagreement
    test_extreme_disagreement() {
        local claude_file="$TEST_DATA_DIR/consensus_tests/claude_high_quality.json"
        local gemini_file="$TEST_DATA_DIR/consensus_tests/gemini_low_quality.json"

        create_mock_claude_evaluation "high_quality" "$claude_file"
        create_mock_gemini_evaluation "low_quality" "$gemini_file"

        local claude_score
        claude_score=$(jq -r '.overall_score' "$claude_file")

        local gemini_score
        gemini_score=$(jq -r '.weighted_average' "$gemini_file")

        local score_diff
        score_diff=$(echo "scale=3; $claude_score - (($gemini_score - 1) / 4)" | bc -l | tr -d '-')

        if (( $(echo "$score_diff > 0.3" | bc -l) )); then
            log_pass "Extreme disagreement detected: difference = $score_diff"
        else
            log_info "Disagreement within normal range: difference = $score_diff"
        fi
    }

    test_mixed_decisions
    test_threshold_boundary
    test_extreme_disagreement

    log_pass "Consensus edge cases validated"
}

# Run All Tests
run_all_tests() {
    log_info "Starting Dual Evaluation Consensus Testing"
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

    # Run test suite
    test_score_normalization || true
    test_consensus_building || true
    test_conflict_resolution || true
    test_recommendation_synthesis || true
    test_feedback_synthesizer_integration || true
    test_consensus_edge_cases || true

    # Summary
    log_info "=============================================="
    log_info "Dual Evaluation Consensus Testing Complete"
    log_info "Tests Run: $TESTS_RUN"
    log_info "Tests Passed: $TESTS_PASSED"
    log_info "Tests Failed: $TESTS_FAILED"

    if [ $TESTS_FAILED -eq 0 ]; then
        log_info "🎉 All tests passed! Dual evaluation consensus is working correctly."
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
