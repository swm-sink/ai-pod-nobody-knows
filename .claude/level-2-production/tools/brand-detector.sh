#!/bin/bash
# Brand Voice Detection Tool for "Nobody Knows" Podcast
# Detects and scores intellectual humility and curiosity markers

# Input file (script to analyze)
SCRIPT_FILE="$1"

if [ -z "$SCRIPT_FILE" ]; then
    echo "Usage: ./brand-detector.sh <script_file>"
    exit 1
fi

if [ ! -f "$SCRIPT_FILE" ]; then
    echo "Error: File '$SCRIPT_FILE' not found"
    exit 1
fi

echo "🎯 Brand Voice Analysis for: $SCRIPT_FILE"
echo "========================================="
echo ""

# Count total lines for percentage calculations
TOTAL_LINES=$(wc -l < "$SCRIPT_FILE")
TOTAL_WORDS=$(wc -w < "$SCRIPT_FILE")

# 1. INTELLECTUAL HUMILITY DETECTION
echo "📊 Intellectual Humility Markers:"
echo "---------------------------------"

# Uncertainty phrases
UNCERTAIN_COUNT=$(grep -i -c "we don't know\|nobody knows\|uncertain\|might be\|could be\|perhaps\|maybe\|it seems\|appears to be\|possibly" "$SCRIPT_FILE")
echo "Uncertainty expressions: $UNCERTAIN_COUNT"

# Acknowledgment of limitations
LIMITATION_COUNT=$(grep -i -c "still learning\|don't understand\|mystery\|unknown\|not sure\|hard to say\|complicated\|complex" "$SCRIPT_FILE")
echo "Limitation acknowledgments: $LIMITATION_COUNT"

# Openness to being wrong
OPENNESS_COUNT=$(grep -i -c "might be wrong\|could be mistaken\|open to\|different perspective\|another way\|alternative" "$SCRIPT_FILE")
echo "Openness to alternatives: $OPENNESS_COUNT"

HUMILITY_TOTAL=$((UNCERTAIN_COUNT + LIMITATION_COUNT + OPENNESS_COUNT))
echo "Total humility markers: $HUMILITY_TOTAL"
echo ""

# 2. CURIOSITY AND WONDER DETECTION
echo "🔍 Curiosity and Wonder Markers:"
echo "---------------------------------"

# Questions
QUESTION_COUNT=$(grep -c "?" "$SCRIPT_FILE")
echo "Questions asked: $QUESTION_COUNT"

# Wonder expressions
WONDER_COUNT=$(grep -i -c "wonder\|curious\|fascinating\|interesting\|amazing\|explore\|discover\|let's find out" "$SCRIPT_FILE")
echo "Wonder expressions: $WONDER_COUNT"

# Invitation to think
INVITATION_COUNT=$(grep -i -c "what if\|imagine\|consider\|think about\|let's explore\|have you ever" "$SCRIPT_FILE")
echo "Invitations to think: $INVITATION_COUNT"

CURIOSITY_TOTAL=$((QUESTION_COUNT + WONDER_COUNT + INVITATION_COUNT))
echo "Total curiosity markers: $CURIOSITY_TOTAL"
echo ""

# 3. OVERCONFIDENCE DETECTION (things to avoid)
echo "⚠️  Overconfidence Markers (should be low):"
echo "--------------------------------------------"

# Absolute statements
ABSOLUTE_COUNT=$(grep -i -c "definitely\|absolutely\|certainly\|obviously\|clearly\|without doubt\|for sure\|no question" "$SCRIPT_FILE")
echo "Absolute statements: $ABSOLUTE_COUNT"

# Know-it-all phrases
KNOWITALL_COUNT=$(grep -i -c "the fact is\|everyone knows\|it's simple\|the truth is\|you should\|you must" "$SCRIPT_FILE")
echo "Know-it-all phrases: $KNOWITALL_COUNT"

OVERCONFIDENCE_TOTAL=$((ABSOLUTE_COUNT + KNOWITALL_COUNT))
echo "Total overconfidence markers: $OVERCONFIDENCE_TOTAL"
echo ""

# 4. CALCULATE BRAND VOICE SCORE
echo "🎯 Brand Voice Score Calculation:"
echo "---------------------------------"

# Calculate scores (using bc for decimal math)
HUMILITY_SCORE=$(echo "scale=2; ($HUMILITY_TOTAL / $TOTAL_WORDS) * 100" | bc)
CURIOSITY_SCORE=$(echo "scale=2; ($CURIOSITY_TOTAL / $TOTAL_WORDS) * 100" | bc)
OVERCONFIDENCE_PENALTY=$(echo "scale=2; ($OVERCONFIDENCE_TOTAL / $TOTAL_WORDS) * 100" | bc)

# Overall brand score (0-100)
BRAND_SCORE=$(echo "scale=2; (($HUMILITY_TOTAL + $CURIOSITY_TOTAL - $OVERCONFIDENCE_TOTAL) / $TOTAL_WORDS) * 100" | bc)

echo "Humility score: ${HUMILITY_SCORE}%"
echo "Curiosity score: ${CURIOSITY_SCORE}%"
echo "Overconfidence penalty: -${OVERCONFIDENCE_PENALTY}%"
echo ""
echo "📈 OVERALL BRAND VOICE SCORE: ${BRAND_SCORE}%"
echo ""

# 5. RECOMMENDATIONS
echo "💡 Recommendations:"
echo "-----------------"

if (( $(echo "$BRAND_SCORE < 5" | bc -l) )); then
    echo "⚠️  Low brand voice score. Consider:"
    echo "  • Add more questions and wonder expressions"
    echo "  • Include uncertainty phrases like 'we don't know' or 'perhaps'"
    echo "  • Remove absolute statements"
elif (( $(echo "$BRAND_SCORE < 10" | bc -l) )); then
    echo "✅ Good brand voice, but could be stronger:"
    echo "  • Add more intellectual humility markers"
    echo "  • Increase questions and invitations to think"
else
    echo "🎉 Excellent brand voice alignment!"
    echo "  • Strong intellectual humility"
    echo "  • Good curiosity and wonder"
    echo "  • Minimal overconfidence"
fi

echo ""
echo "========================================="
echo "Analysis complete!"
