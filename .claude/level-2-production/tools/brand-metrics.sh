#!/bin/bash
# Brand Metrics Counter - Automated measurement tool
# Counts specific brand voice metrics across multiple scripts

SCRIPTS_DIR="${1:-projects/nobody-knows/output/scripts}"
OUTPUT_FILE="${2:-brand-metrics-report.txt}"

echo "📊 Brand Metrics Analysis Report" > "$OUTPUT_FILE"
echo "================================" >> "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Initialize counters
TOTAL_SCRIPTS=0
TOTAL_HUMILITY=0
TOTAL_CURIOSITY=0
TOTAL_OVERCONFIDENCE=0

# Process each script
for script in "$SCRIPTS_DIR"/*.md "$SCRIPTS_DIR"/*.txt; do
    if [ -f "$script" ]; then
        TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
        echo "Processing: $(basename "$script")" >> "$OUTPUT_FILE"

        # Count markers
        HUMILITY=$(grep -i -c "we don't know\|nobody knows\|uncertain\|might be\|perhaps" "$script")
        CURIOSITY=$(grep -c "?" "$script")
        OVERCONFIDENCE=$(grep -i -c "definitely\|absolutely\|certainly\|obviously" "$script")

        TOTAL_HUMILITY=$((TOTAL_HUMILITY + HUMILITY))
        TOTAL_CURIOSITY=$((TOTAL_CURIOSITY + CURIOSITY))
        TOTAL_OVERCONFIDENCE=$((TOTAL_OVERCONFIDENCE + OVERCONFIDENCE))

        echo "  Humility: $HUMILITY | Curiosity: $CURIOSITY | Overconfidence: $OVERCONFIDENCE" >> "$OUTPUT_FILE"
    fi
done

# Summary
echo "" >> "$OUTPUT_FILE"
echo "SUMMARY" >> "$OUTPUT_FILE"
echo "-------" >> "$OUTPUT_FILE"
echo "Scripts analyzed: $TOTAL_SCRIPTS" >> "$OUTPUT_FILE"
echo "Total humility markers: $TOTAL_HUMILITY" >> "$OUTPUT_FILE"
echo "Total curiosity markers: $TOTAL_CURIOSITY" >> "$OUTPUT_FILE"
echo "Total overconfidence markers: $TOTAL_OVERCONFIDENCE" >> "$OUTPUT_FILE"

if [ $TOTAL_SCRIPTS -gt 0 ]; then
    AVG_HUMILITY=$((TOTAL_HUMILITY / TOTAL_SCRIPTS))
    AVG_CURIOSITY=$((TOTAL_CURIOSITY / TOTAL_SCRIPTS))
    AVG_OVERCONFIDENCE=$((TOTAL_OVERCONFIDENCE / TOTAL_SCRIPTS))

    echo "" >> "$OUTPUT_FILE"
    echo "AVERAGES PER SCRIPT" >> "$OUTPUT_FILE"
    echo "-------------------" >> "$OUTPUT_FILE"
    echo "Avg humility: $AVG_HUMILITY" >> "$OUTPUT_FILE"
    echo "Avg curiosity: $AVG_CURIOSITY" >> "$OUTPUT_FILE"
    echo "Avg overconfidence: $AVG_OVERCONFIDENCE" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "Report saved to: $OUTPUT_FILE" >> "$OUTPUT_FILE"

cat "$OUTPUT_FILE"
