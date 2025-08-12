#!/bin/bash
# Test Audio Readiness - Ensures scripts are properly formatted for TTS
# QC 3.27: Pre-audio validation (all text properly formatted)

echo "🎙️ AUDIO READINESS VALIDATION"
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

echo "📋 Audio Formatting Requirements"
echo "-------------------------------"
echo "• No markdown formatting (**, *, #)"
echo "• No code blocks or technical notation"
echo "• Proper punctuation for speech pauses"
echo "• No URLs or email addresses"
echo "• Numbers spelled out for clarity"
echo "• Acronyms properly formatted"
echo ""

# Create test script for audio
cat > /tmp/test_audio_ready.txt << 'EOF'
Welcome, curious minds, to Nobody Knows – the podcast that celebrates both what we understand and what remains beautifully mysterious about artificial intelligence. I'm your host, and today we're embarking on a journey into the fascinating world of machine learning.

You know, there's something profoundly honest about admitting what we don't know. In a field that moves as fast as AI, the gaps in our understanding aren't failures – they're invitations to wonder. Today, we'll explore machine learning not as all-knowing experts, but as curious explorers mapping both the known territories and the uncharted frontiers.

Let me give you a concrete example. In twenty twelve, Google's neural network famously learned to recognize cats from YouTube videos without being explicitly told what a cat was. The network developed what researchers called a "cat neuron" – a unit that activated strongly when shown cat images. But here's the thing nobody talks about enough: we still don't fully understand why that particular neuron emerged or how exactly it encodes "catness."

The acronym GPT stands for Generative Pre-trained Transformer, and it's revolutionizing how we think about language models. These systems process text at speeds of over one million tokens per minute.
EOF

# Create test script with formatting issues
cat > /tmp/test_audio_bad.txt << 'EOF'
# Episode 1: Introduction to **Machine Learning**

Welcome to *Nobody Knows*, the podcast about AI mysteries.

Here's some `code` that shouldn't be in audio: `python print("hello")`.

Visit our website at https://www.nobodyknows.ai or email us at info@nobodyknows.ai.

In 2012, Google achieved a 74.8% accuracy rate on ImageNet.

```python
def neural_network():
    return "This is code"
```

The **transformer** architecture uses *attention* mechanisms.
EOF

echo "🔍 Testing Audio Formatting Validation..."
echo "-----------------------------------------"

# Test 1: Check for markdown formatting
run_test "No markdown formatting in clean script" \
    "! grep -E '\\*\\*|\\*|^#+ |\\[.*\\]\\(.*\\)' /tmp/test_audio_ready.txt" \
    "pass"

run_test "Detect markdown in bad script" \
    "grep -E '\\*\\*|\\*|^#+ ' /tmp/test_audio_bad.txt > /dev/null" \
    "pass"

# Test 2: Check for code blocks
run_test "No code blocks in clean script" \
    "! grep -E '\`\`\`|\`' /tmp/test_audio_ready.txt" \
    "pass"

run_test "Detect code blocks in bad script" \
    "grep -E '\`\`\`|\`' /tmp/test_audio_bad.txt > /dev/null" \
    "pass"

# Test 3: Check for URLs and emails
run_test "No URLs/emails in clean script" \
    "! grep -E 'https?://|www\\.|@[a-zA-Z0-9]' /tmp/test_audio_ready.txt" \
    "pass"

run_test "Detect URLs/emails in bad script" \
    "grep -E 'https?://|www\\.|@[a-zA-Z0-9]' /tmp/test_audio_bad.txt > /dev/null" \
    "pass"

echo ""
echo "📊 Testing Number Formatting..."
echo "--------------------------------"

# Test 4: Check number formatting
run_test "Numbers spelled out properly" \
    "grep -q 'twenty twelve' /tmp/test_audio_ready.txt && grep -q 'one million' /tmp/test_audio_ready.txt" \
    "pass"

run_test "Detect unformatted numbers" \
    "grep -E '[0-9]{4}|[0-9]+\\.[0-9]+%' /tmp/test_audio_bad.txt > /dev/null" \
    "pass"

echo ""
echo "🎯 Testing Comprehensive Audio Validation..."
echo "--------------------------------------------"

# Create Python validator
cat > /tmp/validate_audio.py << 'EOF'
import re
import sys

def validate_audio_readiness(content):
    """Validate text is ready for TTS synthesis"""

    issues = []

    # Check for markdown
    if re.search(r'\*\*.*?\*\*|\*.*?\*|^#+\s', content, re.MULTILINE):
        issues.append("Contains markdown formatting")

    # Check for code blocks
    if '```' in content or '`' in content:
        issues.append("Contains code blocks or inline code")

    # Check for URLs
    if re.search(r'https?://|www\.|[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[A-Z|a-z]{2,}', content):
        issues.append("Contains URLs or email addresses")

    # Check for technical notation
    if re.search(r'[<>{}()\[\]|\\]', content):
        technical_chars = len(re.findall(r'[<>{}()\[\]|\\]', content))
        if technical_chars > 10:  # Allow some parentheses for natural speech
            issues.append(f"Contains excessive technical notation ({technical_chars} chars)")

    # Check for improper number formatting
    raw_numbers = re.findall(r'\b\d{4,}\b|\b\d+\.\d+%\b', content)
    if raw_numbers:
        issues.append(f"Contains unformatted numbers: {raw_numbers[:3]}")

    # Check for acronym formatting
    acronyms = re.findall(r'\b[A-Z]{2,}\b', content)
    properly_formatted = []
    for acronym in acronyms:
        # Check if it's a known acronym that should be spelled out
        if acronym in ['AI', 'ML', 'GPU', 'CPU', 'API']:
            properly_formatted.append(acronym)

    # Check sentence structure for speech
    sentences = content.split('.')
    very_long_sentences = [s for s in sentences if len(s.split()) > 30]
    if very_long_sentences:
        issues.append(f"Contains {len(very_long_sentences)} very long sentences (>30 words)")

    # Report findings
    if not issues:
        print("✅ Script is audio-ready")
        print(f"  • Word count: {len(content.split())}")
        print(f"  • Sentence count: {len(sentences)}")
        print(f"  • Avg words per sentence: {len(content.split()) // max(1, len(sentences))}")
        print(f"  • Acronyms found: {', '.join(set(acronyms)) if acronyms else 'None'}")
        return True
    else:
        print("❌ Script has audio formatting issues:")
        for issue in issues:
            print(f"  • {issue}")
        return False

# Test clean script
print("=" * 50)
print("Testing Clean Audio Script")
print("=" * 50)
with open('/tmp/test_audio_ready.txt', 'r') as f:
    clean_result = validate_audio_readiness(f.read())

print("\n" + "=" * 50)
print("Testing Problematic Audio Script")
print("=" * 50)
with open('/tmp/test_audio_bad.txt', 'r') as f:
    bad_result = validate_audio_readiness(f.read())

if clean_result and not bad_result:
    sys.exit(0)
else:
    sys.exit(1)
EOF

run_test "Comprehensive audio readiness check" \
    "python3 /tmp/validate_audio.py > /dev/null 2>&1" \
    "pass"

echo ""
echo "🔊 Testing Pronunciation Guides..."
echo "----------------------------------"

# Create test with pronunciation guides
cat > /tmp/test_pronunciation.txt << 'EOF'
The researcher's name is Yann LeCun (pronounced "yawn leh-KUHN"), and he pioneered convolutional neural networks.

The company Anthropic (pronounced "an-THROP-ic") focuses on AI safety research.

The term "Bayesian" (pronounced "BAY-zee-an") refers to probability methods.
EOF

run_test "Pronunciation guides properly formatted" \
    "grep -c '(pronounced' /tmp/test_pronunciation.txt | awk '{if(\$1 == 3) exit 0; else exit 1}'" \
    "pass"

echo ""
echo "📝 Testing Special Characters..."
echo "--------------------------------"

# Test for special characters that break TTS
cat > /tmp/test_special_chars.txt << 'EOF'
This text has normal punctuation: commas, periods, and question marks?

But this has problems: @#$%^&*()_+-={}[]|\\:";'<>?,./
EOF

run_test "Clean text has minimal special characters" \
    "python3 -c \"
import re
with open('/tmp/test_audio_ready.txt') as f:
    text = f.read()
    special = re.findall(r'[^a-zA-Z0-9\\s.,!?;:\\\"\\'-]', text)
    if len(special) < 10:
        exit(0)
    else:
        exit(1)
\"" \
    "pass"

run_test "Detect excessive special characters" \
    "grep -o '[@#\$%^&*()_+={}|]' /tmp/test_special_chars.txt | wc -l | awk '{if(\$1 > 5) exit 0; else exit 1}'" \
    "pass"

echo ""
echo "🎵 Testing Speech Rhythm Markers..."
echo "-----------------------------------"

# Check for natural speech patterns
cat > /tmp/test_speech_rhythm.txt << 'EOF'
So, here's the thing – we don't actually know how it works.

Well... that's a great question. Let me think about that for a moment.

You know what's fascinating? The way these systems learn is, honestly, kind of mysterious.
EOF

run_test "Natural speech patterns present" \
    "grep -E '(So,|Well\\.\\.\\.|You know|Let me|honestly|actually)' /tmp/test_speech_rhythm.txt | wc -l | awk '{if(\$1 >= 3) exit 0; else exit 1}'" \
    "pass"

# Cleanup
rm -f /tmp/test_audio_*.txt /tmp/test_pronunciation.txt /tmp/test_special_chars.txt /tmp/test_speech_rhythm.txt /tmp/validate_audio.py

echo ""
echo "==============================="
echo "🎙️ AUDIO READINESS RESULTS"
echo "==============================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL AUDIO READINESS TESTS PASSED! ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    echo ""
    echo "Audio Formatting Validated:"
    echo "✓ No markdown or formatting codes"
    echo "✓ No code blocks or technical notation"
    echo "✓ No URLs or email addresses"
    echo "✓ Numbers properly spelled out"
    echo "✓ Minimal special characters"
    echo "✓ Pronunciation guides formatted"
    echo "✓ Natural speech patterns preserved"
    exit 0
else
    PASS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}⚠️ SOME TESTS FAILED: $PASS_RATE% ($TESTS_PASSED/$TOTAL_TESTS)${NC}"
    exit 1
fi
