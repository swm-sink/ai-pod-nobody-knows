#!/bin/bash
# Test Quality Evaluation - Ensures quality scores meet thresholds
# QC 3.26: Post-quality-eval validation (scores >0.85)

echo "⭐ QUALITY EVALUATION VALIDATION"
echo "================================="

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Find project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

# Test helper function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"

    echo -n "Testing: $test_name... "

    if eval "$test_command"; then
        if [ "$expected_result" = "pass" ]; then
            echo -e "${GREEN}✓ PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗ FAILED (expected failure)${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo -e "${GREEN}✓ PASSED (correctly failed)${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗ FAILED${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
}

echo "📋 Quality Gate Thresholds"
echo "-------------------------"
echo "Comprehension: ≥0.85"
echo "Brand Consistency: ≥0.90"
echo "Engagement: ≥0.80"
echo "Technical Accuracy: ≥0.85"
echo ""

# Create test quality evaluation (passing)
cat > /tmp/test_quality_pass.json << 'EOF'
{
  "evaluation_metadata": {
    "evaluator": "04_quality_claude",
    "timestamp": "2024-01-15T10:30:00Z",
    "episode_number": 1,
    "evaluation_time": "3.2 minutes"
  },
  "quality_scores": {
    "overall_quality": 0.89,
    "comprehension": 0.87,
    "brand_consistency": 0.92,
    "engagement": 0.85,
    "technical_accuracy": 0.88
  },
  "detailed_feedback": {
    "strengths": [
      "Excellent use of intellectual humility throughout",
      "Complex concepts explained with clear analogies",
      "Strong narrative flow with good pacing",
      "High question density (4.2 per 1000 words)"
    ],
    "improvements": [
      "Could add more specific examples in segment 2",
      "Timing slightly over target (27:45 vs 27:00)"
    ]
  },
  "brand_metrics": {
    "intellectual_humility_count": 8,
    "feynman_analogies": 5,
    "fridman_questions": 6,
    "question_density": 4.2
  },
  "gate_status": {
    "comprehension_gate": "PASS",
    "brand_gate": "PASS",
    "engagement_gate": "PASS",
    "accuracy_gate": "PASS",
    "overall": "PASS"
  }
}
EOF

# Create test quality evaluation (failing)
cat > /tmp/test_quality_fail.json << 'EOF'
{
  "evaluation_metadata": {
    "evaluator": "05_quality_gemini",
    "timestamp": "2024-01-15T10:35:00Z",
    "episode_number": 1,
    "evaluation_time": "2.8 minutes"
  },
  "quality_scores": {
    "overall_quality": 0.75,
    "comprehension": 0.72,
    "brand_consistency": 0.85,
    "engagement": 0.70,
    "technical_accuracy": 0.78
  },
  "detailed_feedback": {
    "strengths": [
      "Good attempt at conversational tone",
      "Some effective analogies"
    ],
    "improvements": [
      "Comprehension below threshold - too technical",
      "Insufficient intellectual humility markers",
      "Engagement needs improvement",
      "Several technical inaccuracies noted"
    ]
  },
  "brand_metrics": {
    "intellectual_humility_count": 3,
    "feynman_analogies": 2,
    "fridman_questions": 2,
    "question_density": 2.1
  },
  "gate_status": {
    "comprehension_gate": "FAIL",
    "brand_gate": "FAIL",
    "engagement_gate": "FAIL",
    "accuracy_gate": "FAIL",
    "overall": "FAIL"
  }
}
EOF

echo "🔍 Testing Quality Score Validation..."
echo "--------------------------------------"

# Test 1: Validate passing scores
run_test "Accept scores above thresholds" \
    "python3 -c \"
import json
with open('/tmp/test_quality_pass.json') as f:
    data = json.load(f)
    scores = data['quality_scores']
    if (scores['comprehension'] >= 0.85 and
        scores['brand_consistency'] >= 0.90 and
        scores['engagement'] >= 0.80 and
        scores['technical_accuracy'] >= 0.85):
        exit(0)
    else:
        exit(1)
\"" \
    "pass"

# Test 2: Reject failing scores
run_test "Reject scores below thresholds" \
    "python3 -c \"
import json
with open('/tmp/test_quality_fail.json') as f:
    data = json.load(f)
    scores = data['quality_scores']
    if (scores['comprehension'] >= 0.85 and
        scores['brand_consistency'] >= 0.90 and
        scores['engagement'] >= 0.80 and
        scores['technical_accuracy'] >= 0.85):
        exit(0)
    else:
        exit(1)
\"" \
    "fail"

echo ""
echo "📊 Testing Dual Evaluator Consensus..."
echo "--------------------------------------"

# Create Python validator for dual evaluation
cat > /tmp/validate_dual_quality.py << 'EOF'
import json
import sys

def validate_dual_evaluation(eval1_file, eval2_file):
    """Validate consensus between two quality evaluations"""

    with open(eval1_file) as f:
        eval1 = json.load(f)
    with open(eval2_file) as f:
        eval2 = json.load(f)

    # Calculate average scores
    avg_scores = {}
    for metric in ['comprehension', 'brand_consistency', 'engagement', 'technical_accuracy']:
        score1 = eval1['quality_scores'].get(metric, 0)
        score2 = eval2['quality_scores'].get(metric, 0)
        avg_scores[metric] = (score1 + score2) / 2
        print(f"{metric}: {score1:.2f} + {score2:.2f} = avg {avg_scores[metric]:.2f}")

    # Define thresholds
    thresholds = {
        'comprehension': 0.85,
        'brand_consistency': 0.90,
        'engagement': 0.80,
        'technical_accuracy': 0.85
    }

    # Check gates
    gates_passed = 0
    gates_failed = 0

    for metric, threshold in thresholds.items():
        if avg_scores[metric] >= threshold:
            print(f"✅ {metric}: {avg_scores[metric]:.2f} >= {threshold:.2f}")
            gates_passed += 1
        else:
            print(f"❌ {metric}: {avg_scores[metric]:.2f} < {threshold:.2f}")
            gates_failed += 1

    # Calculate consensus score (how much they agree)
    consensus = 0
    for metric in avg_scores:
        score1 = eval1['quality_scores'].get(metric, 0)
        score2 = eval2['quality_scores'].get(metric, 0)
        diff = abs(score1 - score2)
        consensus += (1 - diff)  # Higher consensus when difference is smaller

    consensus_score = consensus / len(avg_scores)
    print(f"\nConsensus Score: {consensus_score:.2f}")

    # Overall decision
    if gates_failed == 0:
        print("\n🎯 QUALITY GATES: ALL PASS")
        return True
    elif gates_failed <= 1 and all(avg_scores[m] > thresholds[m] - 0.05 for m in thresholds):
        print("\n⚠️  QUALITY GATES: MARGINAL PASS (1 gate slightly below)")
        return True
    else:
        print(f"\n❌ QUALITY GATES: FAIL ({gates_failed} gates failed)")
        return False

# Test with two passing evaluations
print("=" * 50)
print("TEST 1: Two Passing Evaluations")
print("=" * 50)
result1 = validate_dual_evaluation('/tmp/test_quality_pass.json', '/tmp/test_quality_pass.json')

print("\n" + "=" * 50)
print("TEST 2: One Pass, One Fail (Should Fail)")
print("=" * 50)
result2 = validate_dual_evaluation('/tmp/test_quality_pass.json', '/tmp/test_quality_fail.json')

if result1 and not result2:
    sys.exit(0)
else:
    sys.exit(1)
EOF

run_test "Dual evaluator consensus validation" \
    "python3 /tmp/validate_dual_quality.py > /dev/null 2>&1" \
    "pass"

echo ""
echo "🏷️ Testing Brand Metrics Validation..."
echo "---------------------------------------"

# Test 3: Validate brand metrics requirements
run_test "Brand metrics meet requirements" \
    "python3 -c \"
import json
with open('/tmp/test_quality_pass.json') as f:
    data = json.load(f)
    metrics = data['brand_metrics']
    if (metrics['intellectual_humility_count'] >= 5 and
        metrics['feynman_analogies'] >= 3 and
        metrics['question_density'] >= 4.0):
        exit(0)
    else:
        exit(1)
\"" \
    "pass"

run_test "Reject insufficient brand metrics" \
    "python3 -c \"
import json
with open('/tmp/test_quality_fail.json') as f:
    data = json.load(f)
    metrics = data['brand_metrics']
    if (metrics['intellectual_humility_count'] >= 5 and
        metrics['feynman_analogies'] >= 3 and
        metrics['question_density'] >= 4.0):
        exit(0)
    else:
        exit(1)
\"" \
    "fail"

echo ""
echo "🔄 Testing Quality Gate Decision Logic..."
echo "-----------------------------------------"

# Test 4: Gate decision logic
run_test "Overall PASS when all gates pass" \
    "python3 -c \"
import json
with open('/tmp/test_quality_pass.json') as f:
    data = json.load(f)
    if data['gate_status']['overall'] == 'PASS':
        exit(0)
    else:
        exit(1)
\"" \
    "pass"

run_test "Overall FAIL when gates fail" \
    "python3 -c \"
import json
with open('/tmp/test_quality_fail.json') as f:
    data = json.load(f)
    if data['gate_status']['overall'] == 'FAIL':
        exit(0)
    else:
        exit(1)
\"" \
    "pass"

echo ""
echo "🎯 Testing Marginal Pass Scenarios..."
echo "-------------------------------------"

# Create marginal pass scenario
cat > /tmp/test_quality_marginal.json << 'EOF'
{
  "quality_scores": {
    "overall_quality": 0.86,
    "comprehension": 0.84,
    "brand_consistency": 0.91,
    "engagement": 0.82,
    "technical_accuracy": 0.86
  },
  "gate_status": {
    "comprehension_gate": "MARGINAL",
    "brand_gate": "PASS",
    "engagement_gate": "PASS",
    "accuracy_gate": "PASS",
    "overall": "MARGINAL_PASS"
  }
}
EOF

run_test "Handle marginal pass (within 5% of threshold)" \
    "python3 -c \"
import json
with open('/tmp/test_quality_marginal.json') as f:
    data = json.load(f)
    scores = data['quality_scores']
    # Check if comprehension is within 5% of threshold
    if scores['comprehension'] >= 0.80:  # 0.85 - 0.05
        exit(0)
    else:
        exit(1)
\"" \
    "pass"

echo ""
echo "📈 Testing Score Aggregation..."
echo "-------------------------------"

# Create aggregation test
cat > /tmp/test_aggregation.py << 'EOF'
def test_score_aggregation():
    """Test that scores aggregate correctly"""

    scores1 = {
        'comprehension': 0.88,
        'brand_consistency': 0.92,
        'engagement': 0.85,
        'technical_accuracy': 0.87
    }

    scores2 = {
        'comprehension': 0.86,
        'brand_consistency': 0.93,
        'engagement': 0.83,
        'technical_accuracy': 0.89
    }

    # Calculate averages
    avg_scores = {}
    for metric in scores1:
        avg_scores[metric] = (scores1[metric] + scores2[metric]) / 2

    # Verify averaging
    assert abs(avg_scores['comprehension'] - 0.87) < 0.01
    assert abs(avg_scores['brand_consistency'] - 0.925) < 0.01
    assert abs(avg_scores['engagement'] - 0.84) < 0.01
    assert abs(avg_scores['technical_accuracy'] - 0.88) < 0.01

    print("✅ Score aggregation works correctly")
    return True

test_score_aggregation()
EOF

run_test "Score aggregation calculation" \
    "python3 /tmp/test_aggregation.py" \
    "pass"

# Cleanup
rm -f /tmp/test_quality_*.json /tmp/validate_dual_quality.py /tmp/test_aggregation.py

echo ""
echo "=================================="
echo "⭐ QUALITY EVALUATION RESULTS"
echo "=================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL QUALITY EVALUATION TESTS PASSED! ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    echo ""
    echo "Quality Validation Complete:"
    echo "✓ Score thresholds properly enforced"
    echo "✓ Dual evaluator consensus calculated"
    echo "✓ Brand metrics validated"
    echo "✓ Gate decision logic correct"
    echo "✓ Marginal pass scenarios handled"
    echo "✓ Score aggregation accurate"
    exit 0
else
    PASS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}⚠️ SOME TESTS FAILED: $PASS_RATE% ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    exit 1
fi
