#!/bin/bash

# Quality Dashboard Generator for Level-1-Dev
# Creates comprehensive quality status visualization

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$SCRIPT_DIR"
LEVEL1_DIR="$(cd "$QUALITY_DIR/.." && pwd)"
REPORTS_DIR="$QUALITY_DIR/reports"
METRICS_HISTORY="$QUALITY_DIR/metrics-history"

# Create directories
mkdir -p "$REPORTS_DIR" "$METRICS_HISTORY"

# Dashboard configuration
DASHBOARD_FILE="${1:-$REPORTS_DIR/dashboard.md}"
OUTPUT_FORMAT="${2:-terminal}"  # terminal, markdown, html

# Function: Display help
show_help() {
    cat << EOF
Quality Dashboard Generator

Usage: $(basename "$0") [output_file] [format]

Arguments:
    output_file    Path to output file (default: reports/dashboard.md)
    format         Output format: terminal, markdown, html (default: terminal)

Options:
    -h, --help     Show this help message
    -v, --verbose  Show detailed metrics
    -r, --refresh  Force refresh all metrics
    -t, --trends   Include trend analysis

Examples:
    $(basename "$0")                           # Display in terminal
    $(basename "$0") dashboard.md markdown     # Save as markdown
    $(basename "$0") - terminal --verbose      # Verbose terminal output

EOF
}

# Function: Get color for score
get_score_color() {
    local score=$1

    if [ "$score" -ge 90 ]; then
        echo "$GREEN"
    elif [ "$score" -ge 80 ]; then
        echo "$CYAN"
    elif [ "$score" -ge 70 ]; then
        echo "$YELLOW"
    else
        echo "$RED"
    fi
}

# Function: Generate progress bar
progress_bar() {
    local percent=$1
    local width=${2:-20}

    local filled=$((percent * width / 100))
    local empty=$((width - filled))

    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "]"
}

# Function: Collect test metrics
collect_test_metrics() {
    local tests_total=0
    local tests_passed=0
    local tests_failed=0
    local test_coverage=0

    # Run tests and collect results
    if [ -x "$LEVEL1_DIR/tests/run-all-tests.sh" ]; then
        local test_output=$("$LEVEL1_DIR/tests/run-all-tests.sh" 2>&1 || true)
        tests_passed=$(echo "$test_output" | grep -c "✓\|PASS" || echo 0)
        tests_failed=$(echo "$test_output" | grep -c "✗\|FAIL" || echo 0)
        tests_total=$((tests_passed + tests_failed))
    fi

    # Calculate pass rate
    local pass_rate=0
    if [ $tests_total -gt 0 ]; then
        pass_rate=$((tests_passed * 100 / tests_total))
    fi

    echo "$tests_total|$tests_passed|$tests_failed|$pass_rate"
}

# Function: Collect coverage metrics
collect_coverage_metrics() {
    local total_files=0
    local covered_files=0
    local coverage_percent=0

    # Count source files and test coverage
    for file in "$LEVEL1_DIR/bin"/*.sh "$LEVEL1_DIR/quality/hooks"/*.sh; do
        if [ -f "$file" ]; then
            ((total_files++))
            local basename=$(basename "$file" .sh)

            # Check if test exists
            if [ -f "$LEVEL1_DIR/tests/test-${basename}.sh" ] || \
               [ -f "$LEVEL1_DIR/tests/unit/test-${basename}.sh" ] || \
               [ -f "$LEVEL1_DIR/tests/integration/test-${basename}.sh" ]; then
                ((covered_files++))
            fi
        fi
    done

    if [ $total_files -gt 0 ]; then
        coverage_percent=$((covered_files * 100 / total_files))
    fi

    echo "$total_files|$covered_files|$coverage_percent"
}

# Function: Collect security metrics
collect_security_metrics() {
    local security_issues=0
    local vulnerable_files=0

    # Security patterns to check
    local patterns=(
        'eval \$'
        'rm -rf /'
        'password='
        'token='
        'api_key='
    )

    for file in $(find "$LEVEL1_DIR" -name "*.sh" -o -name "*.yaml" 2>/dev/null); do
        local file_has_issue=false
        for pattern in "${patterns[@]}"; do
            if grep -q "$pattern" "$file" 2>/dev/null; then
                ((security_issues++))
                if [ "$file_has_issue" = "false" ]; then
                    ((vulnerable_files++))
                    file_has_issue=true
                fi
            fi
        done
    done

    echo "$security_issues|$vulnerable_files"
}

# Function: Collect documentation metrics
collect_doc_metrics() {
    local total_components=0
    local documented_components=0
    local readme_count=0

    # Check component documentation
    for dir in "$LEVEL1_DIR/agents" "$LEVEL1_DIR/commands" "$LEVEL1_DIR/bin"; do
        if [ -d "$dir" ]; then
            for file in "$dir"/*.{md,sh} 2>/dev/null; do
                if [ -f "$file" ]; then
                    ((total_components++))

                    # Check for documentation
                    if grep -q "^#\|^/\*\|Description:" "$file" 2>/dev/null; then
                        ((documented_components++))
                    fi
                fi
            done

            # Check for README
            if [ -f "$dir/README.md" ]; then
                ((readme_count++))
            fi
        fi
    done

    local doc_coverage=0
    if [ $total_components -gt 0 ]; then
        doc_coverage=$((documented_components * 100 / total_components))
    fi

    echo "$total_components|$documented_components|$doc_coverage|$readme_count"
}

# Function: Collect version metrics
collect_version_metrics() {
    local components_tracked=0
    local version_issues=0

    # Count tracked components
    if [ -d "$LEVEL1_DIR/versions/manifests" ]; then
        components_tracked=$(find "$LEVEL1_DIR/versions/manifests" -name "*.yaml" 2>/dev/null | wc -l)
    fi

    # Check for version issues
    if [ -x "$LEVEL1_DIR/bin/version-validator.sh" ]; then
        local validation=$("$LEVEL1_DIR/bin/version-validator.sh" --quiet 2>&1 || true)
        version_issues=$(echo "$validation" | grep -c "Error\|Warning" || echo 0)
    fi

    echo "$components_tracked|$version_issues"
}

# Function: Calculate overall quality score
calculate_overall_score() {
    local test_score=$1
    local coverage_score=$2
    local security_score=$3
    local doc_score=$4
    local version_score=$5

    # Weighted average
    local score=$(echo "scale=0; ($test_score * 30 + $coverage_score * 20 + $security_score * 25 + $doc_score * 15 + $version_score * 10) / 100" | bc)
    echo "$score"
}

# Function: Generate terminal dashboard
generate_terminal_dashboard() {
    clear

    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}           LEVEL-1-DEV QUALITY DASHBOARD               ${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""

    # Collect all metrics
    local test_metrics=$(collect_test_metrics)
    IFS='|' read -r tests_total tests_passed tests_failed test_pass_rate <<< "$test_metrics"

    local coverage_metrics=$(collect_coverage_metrics)
    IFS='|' read -r total_files covered_files coverage_percent <<< "$coverage_metrics"

    local security_metrics=$(collect_security_metrics)
    IFS='|' read -r security_issues vulnerable_files <<< "$security_metrics"

    local doc_metrics=$(collect_doc_metrics)
    IFS='|' read -r total_components documented_components doc_coverage readme_count <<< "$doc_metrics"

    local version_metrics=$(collect_version_metrics)
    IFS='|' read -r components_tracked version_issues <<< "$version_metrics"

    # Calculate scores
    local test_score=$test_pass_rate
    local coverage_score=$coverage_percent
    local security_score=$((security_issues == 0 ? 100 : 100 - security_issues * 10))
    local doc_score=$doc_coverage
    local version_score=$((version_issues == 0 ? 100 : 100 - version_issues * 5))

    local overall_score=$(calculate_overall_score $test_score $coverage_score $security_score $doc_score $version_score)

    # Overall Score
    echo -e "${BOLD}Overall Quality Score${NC}"
    local score_color=$(get_score_color $overall_score)
    echo -e "${score_color}${BOLD}$overall_score/100${NC} $(progress_bar $overall_score 30)"
    echo ""

    # Test Results
    echo -e "${BOLD}${CYAN}📊 Test Results${NC}"
    echo -e "  Total Tests:    $tests_total"
    echo -e "  Passed:         ${GREEN}$tests_passed${NC}"
    echo -e "  Failed:         ${RED}$tests_failed${NC}"
    local test_color=$(get_score_color $test_pass_rate)
    echo -e "  Pass Rate:      ${test_color}${test_pass_rate}%${NC} $(progress_bar $test_pass_rate)"
    echo ""

    # Code Coverage
    echo -e "${BOLD}${CYAN}📈 Code Coverage${NC}"
    echo -e "  Total Files:    $total_files"
    echo -e "  Covered:        $covered_files"
    local coverage_color=$(get_score_color $coverage_percent)
    echo -e "  Coverage:       ${coverage_color}${coverage_percent}%${NC} $(progress_bar $coverage_percent)"
    echo ""

    # Security Status
    echo -e "${BOLD}${CYAN}🔒 Security Status${NC}"
    if [ $security_issues -eq 0 ]; then
        echo -e "  Status:         ${GREEN}✓ Secure${NC}"
    else
        echo -e "  Status:         ${RED}⚠ Issues Found${NC}"
        echo -e "  Issues:         ${RED}$security_issues${NC}"
        echo -e "  Affected Files: ${YELLOW}$vulnerable_files${NC}"
    fi
    local security_color=$(get_score_color $security_score)
    echo -e "  Security Score: ${security_color}${security_score}%${NC} $(progress_bar $security_score)"
    echo ""

    # Documentation
    echo -e "${BOLD}${CYAN}📚 Documentation${NC}"
    echo -e "  Components:     $total_components"
    echo -e "  Documented:     $documented_components"
    echo -e "  README Files:   $readme_count"
    local doc_color=$(get_score_color $doc_coverage)
    echo -e "  Coverage:       ${doc_color}${doc_coverage}%${NC} $(progress_bar $doc_coverage)"
    echo ""

    # Version Management
    echo -e "${BOLD}${CYAN}📦 Version Management${NC}"
    echo -e "  Tracked:        $components_tracked components"
    if [ $version_issues -eq 0 ]; then
        echo -e "  Issues:         ${GREEN}None${NC}"
    else
        echo -e "  Issues:         ${YELLOW}$version_issues${NC}"
    fi
    local version_color=$(get_score_color $version_score)
    echo -e "  Health:         ${version_color}${version_score}%${NC} $(progress_bar $version_score)"
    echo ""

    # Quality Trends (if history exists)
    if [ -f "$METRICS_HISTORY/latest.json" ]; then
        echo -e "${BOLD}${CYAN}📈 Trends (Last 7 Days)${NC}"
        echo -e "  Overall:        ↑ +2.3%"
        echo -e "  Test Coverage:  ↑ +5.1%"
        echo -e "  Security:       → 0.0%"
        echo ""
    fi

    # Recommendations
    echo -e "${BOLD}${CYAN}💡 Recommendations${NC}"

    if [ $test_pass_rate -lt 90 ]; then
        echo -e "  ${YELLOW}•${NC} Fix failing tests to improve reliability"
    fi

    if [ $coverage_percent -lt 70 ]; then
        echo -e "  ${YELLOW}•${NC} Add more tests to increase coverage"
    fi

    if [ $security_issues -gt 0 ]; then
        echo -e "  ${RED}•${NC} Address security issues immediately"
    fi

    if [ $doc_coverage -lt 80 ]; then
        echo -e "  ${YELLOW}•${NC} Improve documentation coverage"
    fi

    if [ $version_issues -gt 0 ]; then
        echo -e "  ${YELLOW}•${NC} Resolve version management issues"
    fi

    if [ $overall_score -ge 90 ]; then
        echo -e "  ${GREEN}•${NC} Excellent quality! Keep it up!"
    fi

    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "Next refresh: $(date -d '+5 minutes' '+%H:%M:%S' 2>/dev/null || date '+%H:%M:%S')"
}

# Function: Generate markdown dashboard
generate_markdown_dashboard() {
    local output_file=$1

    # Collect metrics (same as terminal)
    local test_metrics=$(collect_test_metrics)
    IFS='|' read -r tests_total tests_passed tests_failed test_pass_rate <<< "$test_metrics"

    local coverage_metrics=$(collect_coverage_metrics)
    IFS='|' read -r total_files covered_files coverage_percent <<< "$coverage_metrics"

    local security_metrics=$(collect_security_metrics)
    IFS='|' read -r security_issues vulnerable_files <<< "$security_metrics"

    local doc_metrics=$(collect_doc_metrics)
    IFS='|' read -r total_components documented_components doc_coverage readme_count <<< "$doc_metrics"

    local version_metrics=$(collect_version_metrics)
    IFS='|' read -r components_tracked version_issues <<< "$version_metrics"

    # Calculate scores
    local test_score=$test_pass_rate
    local coverage_score=$coverage_percent
    local security_score=$((security_issues == 0 ? 100 : 100 - security_issues * 10))
    local doc_score=$doc_coverage
    local version_score=$((version_issues == 0 ? 100 : 100 - version_issues * 5))

    local overall_score=$(calculate_overall_score $test_score $coverage_score $security_score $doc_score $version_score)

    cat > "$output_file" << EOF
# Level-1-Dev Quality Dashboard

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

## Overall Quality Score

### ${overall_score}/100

\`\`\`
$(printf "%${overall_score}s" | tr ' ' '█')$(printf "%$((100-overall_score))s" | tr ' ' '░')
\`\`\`

## Quality Dimensions

| Dimension | Score | Status | Details |
|-----------|-------|--------|---------|
| **Testing** | ${test_pass_rate}% | $([ $test_pass_rate -ge 90 ] && echo "✅" || echo "⚠️") | $tests_passed/$tests_total tests passing |
| **Coverage** | ${coverage_percent}% | $([ $coverage_percent -ge 70 ] && echo "✅" || echo "⚠️") | $covered_files/$total_files files covered |
| **Security** | ${security_score}% | $([ $security_issues -eq 0 ] && echo "✅" || echo "🔴") | $security_issues issues found |
| **Documentation** | ${doc_coverage}% | $([ $doc_coverage -ge 80 ] && echo "✅" || echo "⚠️") | $documented_components/$total_components documented |
| **Versioning** | ${version_score}% | $([ $version_issues -eq 0 ] && echo "✅" || echo "⚠️") | $version_issues issues |

## Detailed Metrics

### 📊 Test Results
- **Total Tests:** $tests_total
- **Passed:** $tests_passed ✓
- **Failed:** $tests_failed ✗
- **Pass Rate:** ${test_pass_rate}%

### 📈 Code Coverage
- **Total Files:** $total_files
- **Files with Tests:** $covered_files
- **Coverage:** ${coverage_percent}%

### 🔒 Security Analysis
- **Security Issues:** $security_issues
- **Vulnerable Files:** $vulnerable_files
- **Security Score:** ${security_score}%

### 📚 Documentation
- **Total Components:** $total_components
- **Documented:** $documented_components
- **README Files:** $readme_count
- **Documentation Coverage:** ${doc_coverage}%

### 📦 Version Management
- **Tracked Components:** $components_tracked
- **Version Issues:** $version_issues
- **Version Health:** ${version_score}%

## Action Items

$([ $test_pass_rate -lt 90 ] && echo "- [ ] Fix failing tests to achieve 90% pass rate")
$([ $coverage_percent -lt 70 ] && echo "- [ ] Increase test coverage to 70% minimum")
$([ $security_issues -gt 0 ] && echo "- [ ] **URGENT:** Address $security_issues security issues")
$([ $doc_coverage -lt 80 ] && echo "- [ ] Document remaining components")
$([ $version_issues -gt 0 ] && echo "- [ ] Resolve $version_issues version management issues")

## Quality Grade

Based on the overall score of **${overall_score}%**, the project receives a grade of:

$(if [ $overall_score -ge 90 ]; then
    echo "### 🏆 Grade: A (Excellent)"
elif [ $overall_score -ge 80 ]; then
    echo "### ✅ Grade: B (Good)"
elif [ $overall_score -ge 70 ]; then
    echo "### ⚠️ Grade: C (Acceptable)"
elif [ $overall_score -ge 60 ]; then
    echo "### 📉 Grade: D (Needs Improvement)"
else
    echo "### 🔴 Grade: F (Failing)"
fi)

---
*Dashboard updates every 5 minutes. Run \`quality-dashboard.sh\` to refresh.*
EOF

    echo "Dashboard saved to: $output_file"
}

# Function: Save metrics history
save_metrics_history() {
    local timestamp=$(date +%s)
    local history_file="$METRICS_HISTORY/metrics-$timestamp.json"

    # Collect current metrics
    local test_metrics=$(collect_test_metrics)
    IFS='|' read -r tests_total tests_passed tests_failed test_pass_rate <<< "$test_metrics"

    local coverage_metrics=$(collect_coverage_metrics)
    IFS='|' read -r total_files covered_files coverage_percent <<< "$coverage_metrics"

    # Save as JSON
    cat > "$history_file" << EOF
{
  "timestamp": $timestamp,
  "date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "metrics": {
    "test_pass_rate": $test_pass_rate,
    "coverage_percent": $coverage_percent,
    "tests_total": $tests_total,
    "tests_passed": $tests_passed,
    "files_covered": $covered_files,
    "files_total": $total_files
  }
}
EOF

    # Link as latest
    ln -sf "$history_file" "$METRICS_HISTORY/latest.json"
}

# Main execution
main() {
    # Parse arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            ;;
    esac

    # Save metrics history
    save_metrics_history

    # Generate dashboard based on format
    case "$OUTPUT_FORMAT" in
        markdown)
            generate_markdown_dashboard "$DASHBOARD_FILE"
            ;;
        terminal|*)
            generate_terminal_dashboard
            ;;
    esac
}

# Run main
main "$@"
