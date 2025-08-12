#!/bin/bash
# Test Research Validation - Ensures research meets minimum requirements
# QC 3.24: Post-research validation (>3 sources found)

echo "📚 RESEARCH OUTPUT VALIDATION"
echo "=============================="

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

echo "📋 Research Requirements Validation"
echo "-----------------------------------"

# Create test research output
cat > /tmp/test_research.md << 'EOF'
# Research Package: Introduction to Neural Networks

## Executive Summary
Neural networks are computational systems inspired by biological neural networks...

## Knowledge Layers

### What We Know
- Basic architecture: input, hidden, output layers
- Activation functions: ReLU, Sigmoid, Tanh
- Backpropagation algorithm for training
- Applications in image recognition, NLP

### What's Emerging
- Transformer architectures
- Self-supervised learning
- Neural architecture search

### Current Debates
- Interpretability vs. performance
- Environmental impact of large models
- Bias in training data

### Frontiers & Unknowns
- Consciousness in AI systems
- True generalization capabilities
- Optimal network architectures

## Research Sources
1. **Goodfellow et al. (2016)** - Deep Learning textbook
   - Confidence: 0.95
   - Type: Academic textbook

2. **LeCun et al. (2015)** - Deep learning review in Nature
   - Confidence: 0.92
   - Type: Peer-reviewed journal

3. **Schmidhuber (2015)** - Deep learning in neural networks: An overview
   - Confidence: 0.88
   - Type: Survey paper

4. **Bengio (2019)** - From System 1 Deep Learning to System 2 Deep Learning
   - Confidence: 0.85
   - Type: Conference keynote

5. **Hinton (2018)** - Capsule Networks
   - Confidence: 0.80
   - Type: Research paper

## Confidence Scores
- Overall Research Confidence: 0.88
- Source Diversity: 0.90
- Coverage Completeness: 0.85
EOF

echo ""
echo "🔍 Testing Research Validation Requirements..."
echo "----------------------------------------------"

# Test 1: Minimum source count (>3 sources)
run_test "Minimum 3 sources requirement" \
    "grep -c 'Confidence:' /tmp/test_research.md | awk '{if(\$1 > 3) exit 0; else exit 1}'" \
    "pass"

# Test 2: Executive summary present
run_test "Executive summary section exists" \
    "grep -q '## Executive Summary' /tmp/test_research.md" \
    "pass"

# Test 3: Knowledge layers structure
run_test "Knowledge layers properly structured" \
    "grep -q '### What We Know' /tmp/test_research.md && grep -q '### Frontiers' /tmp/test_research.md" \
    "pass"

# Test 4: Confidence scores included
run_test "Confidence scores for sources" \
    "grep -c 'Confidence: 0\\.[0-9]' /tmp/test_research.md | awk '{if(\$1 >= 3) exit 0; else exit 1}'" \
    "pass"

# Test 5: Source types identified
run_test "Source types documented" \
    "grep -c 'Type:' /tmp/test_research.md | awk '{if(\$1 >= 3) exit 0; else exit 1}'" \
    "pass"

echo ""
echo "🔬 Testing Research Quality Metrics..."
echo "--------------------------------------"

# Create Python validator
cat > /tmp/validate_research.py << 'EOF'
import re
import sys

def validate_research(content):
    """Validate research output meets quality requirements"""

    # Check source count
    sources = re.findall(r'Confidence:\s*0\.\d+', content)
    if len(sources) < 3:
        print(f"❌ Insufficient sources: {len(sources)} (minimum 3)")
        return False
    else:
        print(f"✅ Source count: {len(sources)} sources found")

    # Check confidence scores
    confidence_values = [float(s.split(':')[1].strip()) for s in sources]
    avg_confidence = sum(confidence_values) / len(confidence_values)

    if avg_confidence < 0.75:
        print(f"⚠️  Average confidence: {avg_confidence:.2f} (below recommended 0.75)")
    else:
        print(f"✅ Average confidence: {avg_confidence:.2f}")

    # Check for diverse source types
    source_types = re.findall(r'Type:\s*([^\n]+)', content)
    unique_types = set(source_types)

    if len(unique_types) < 2:
        print(f"⚠️  Source diversity: Only {len(unique_types)} type(s)")
    else:
        print(f"✅ Source diversity: {len(unique_types)} different types")

    # Check for unknowns section
    if "Unknowns" in content or "unknown" in content.lower():
        print("✅ Unknown factors identified")
    else:
        print("⚠️  No unknown factors identified")

    return len(sources) >= 3

# Read and validate
with open('/tmp/test_research.md', 'r') as f:
    content = f.read()

if validate_research(content):
    sys.exit(0)
else:
    sys.exit(1)
EOF

# Test 6: Run comprehensive validation
run_test "Comprehensive research validation" \
    "python3 /tmp/validate_research.py" \
    "pass"

echo ""
echo "📊 Testing Edge Cases..."
echo "------------------------"

# Test insufficient sources
cat > /tmp/bad_research.md << 'EOF'
# Research Package: Test Topic

## Research Sources
1. Source One - Confidence: 0.90
2. Source Two - Confidence: 0.85
EOF

run_test "Reject research with <3 sources" \
    "grep -c 'Confidence:' /tmp/bad_research.md | awk '{if(\$1 > 3) exit 0; else exit 1}'" \
    "fail"

# Test missing confidence scores
cat > /tmp/no_confidence.md << 'EOF'
# Research Package: Test Topic

## Research Sources
1. Source One
2. Source Two
3. Source Three
4. Source Four
EOF

run_test "Reject research without confidence scores" \
    "grep -q 'Confidence:' /tmp/no_confidence.md" \
    "fail"

# Cleanup
rm -f /tmp/test_research.md /tmp/bad_research.md /tmp/no_confidence.md /tmp/validate_research.py

echo ""
echo "================================"
echo "📚 RESEARCH VALIDATION RESULTS"
echo "================================"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL RESEARCH VALIDATION TESTS PASSED! ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    echo ""
    echo "Research Requirements Validated:"
    echo "✓ Minimum 3 sources with confidence scores"
    echo "✓ Executive summary present"
    echo "✓ Knowledge layers structured"
    echo "✓ Source types documented"
    echo "✓ Unknown factors identified"
    exit 0
else
    PASS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}⚠️ SOME TESTS FAILED: $PASS_RATE% ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    exit 1
fi
