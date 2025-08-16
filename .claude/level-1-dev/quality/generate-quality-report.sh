#!/bin/bash

# Automated Quality Report Generator for Level-1-Dev
# Generates comprehensive quality reports with trends and insights

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
ARCHIVE_DIR="$REPORTS_DIR/archive"

# Report configuration
REPORT_DATE=$(date +%Y%m%d)
REPORT_TIME=$(date +%H%M%S)
REPORT_TIMESTAMP="${REPORT_DATE}_${REPORT_TIME}"

# Create directories
mkdir -p "$REPORTS_DIR" "$METRICS_HISTORY" "$ARCHIVE_DIR"

# Function: Display help
show_help() {
    cat << EOF
Automated Quality Report Generator

Usage: $(basename "$0") [options]

Options:
    -h, --help       Show this help message
    -f, --format     Report format: full, summary, executive (default: full)
    -o, --output     Output format: markdown, json, html, csv (default: markdown)
    -p, --period     Analysis period: daily, weekly, monthly (default: weekly)
    -e, --email      Email report to specified address
    -s, --schedule   Schedule automatic generation (cron format)
    -a, --archive    Archive previous reports

Examples:
    $(basename "$0")                        # Generate full markdown report
    $(basename "$0") --format summary       # Generate summary report
    $(basename "$0") --output json          # Generate JSON report
    $(basename "$0") --period monthly       # Monthly analysis period
    $(basename "$0") --email team@example.com  # Email report

Report Types:
    full       - Complete analysis with all metrics
    summary    - Key metrics and highlights
    executive  - High-level overview for management

EOF
}

# Function: Collect all metrics
collect_all_metrics() {
    local period=${1:-"weekly"}

    echo "Collecting metrics for $period report..."

    # Test metrics
    local test_results=$("$LEVEL1_DIR/tests/run-all-tests.sh" 2>&1 || true)
    local tests_total=$(echo "$test_results" | grep -c "Test:" || echo 0)
    local tests_passed=$(echo "$test_results" | grep -c "✓\|PASS" || echo 0)
    local tests_failed=$((tests_total - tests_passed))
    local test_pass_rate=$((tests_total > 0 ? tests_passed * 100 / tests_total : 0))

    # Coverage metrics
    local total_files=$(find "$LEVEL1_DIR" -name "*.sh" | wc -l)
    local files_with_tests=0
    for file in "$LEVEL1_DIR/bin"/*.sh; do
        if [ -f "$file" ]; then
            local basename=$(basename "$file" .sh)
            if [ -f "$LEVEL1_DIR/tests/test-${basename}.sh" ] || \
               [ -f "$LEVEL1_DIR/tests/unit/test-${basename}.sh" ]; then
                ((files_with_tests++))
            fi
        fi
    done
    local coverage_percent=$((total_files > 0 ? files_with_tests * 100 / total_files : 0))

    # Security metrics
    local security_issues=0
    local security_scan=$("$QUALITY_DIR/hooks/pre-commit-quality.sh" 2>&1 || true)
    security_issues=$(echo "$security_scan" | grep -c "Security pattern:" || echo 0)

    # Documentation metrics
    local doc_files=$(find "$LEVEL1_DIR" -name "*.md" | wc -l)
    local readme_files=$(find "$LEVEL1_DIR" -name "README.md" | wc -l)
    local doc_ratio=$((doc_files > 0 ? readme_files * 100 / doc_files : 0))

    # Version metrics
    local version_issues=0
    if [ -x "$LEVEL1_DIR/bin/version-validator.sh" ]; then
        version_issues=$("$LEVEL1_DIR/bin/version-validator.sh" --quiet 2>&1 | grep -c "Error\|Warning" || echo 0)
    fi

    # Commit metrics (for period)
    local period_days=7
    case $period in
        daily) period_days=1 ;;
        weekly) period_days=7 ;;
        monthly) period_days=30 ;;
    esac

    local commits_count=$(git log --oneline --since="${period_days} days ago" 2>/dev/null | wc -l)
    local contributors=$(git log --format="%an" --since="${period_days} days ago" 2>/dev/null | sort -u | wc -l)

    # Quality score calculation
    local quality_score=$((
        (test_pass_rate * 30 +
         coverage_percent * 20 +
         (security_issues == 0 ? 100 : 80) * 25 +
         doc_ratio * 15 +
         (version_issues == 0 ? 100 : 90) * 10) / 100
    ))

    # Store metrics
    cat > "$METRICS_HISTORY/metrics-${REPORT_TIMESTAMP}.json" << EOF
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "period": "$period",
    "metrics": {
        "tests": {
            "total": $tests_total,
            "passed": $tests_passed,
            "failed": $tests_failed,
            "pass_rate": $test_pass_rate
        },
        "coverage": {
            "total_files": $total_files,
            "covered_files": $files_with_tests,
            "coverage_percent": $coverage_percent
        },
        "security": {
            "issues": $security_issues,
            "status": "$([ $security_issues -eq 0 ] && echo "secure" || echo "at_risk")"
        },
        "documentation": {
            "total_docs": $doc_files,
            "readme_files": $readme_files,
            "doc_ratio": $doc_ratio
        },
        "version": {
            "issues": $version_issues,
            "status": "$([ $version_issues -eq 0 ] && echo "healthy" || echo "needs_attention")"
        },
        "activity": {
            "commits": $commits_count,
            "contributors": $contributors
        },
        "quality_score": $quality_score
    }
}
EOF

    echo "$quality_score"
}

# Function: Calculate trends
calculate_trends() {
    local current_score=$1
    local period=${2:-"weekly"}

    # Find previous report for comparison
    local previous_score=0
    local previous_file=$(find "$METRICS_HISTORY" -name "metrics-*.json" -mtime -${period_days} | sort | tail -2 | head -1)

    if [ -f "$previous_file" ]; then
        previous_score=$(grep "quality_score" "$previous_file" | grep -o "[0-9]*" | head -1)
    fi

    local trend="stable"
    local change=$((current_score - previous_score))

    if [ $change -gt 5 ]; then
        trend="improving"
    elif [ $change -lt -5 ]; then
        trend="declining"
    fi

    echo "$trend|$change"
}

# Function: Generate full report
generate_full_report() {
    local output_file="$REPORTS_DIR/quality-report-${REPORT_TIMESTAMP}.md"
    local period=${1:-"weekly"}

    echo -e "${BLUE}Generating full quality report...${NC}"

    # Collect metrics
    local quality_score=$(collect_all_metrics "$period")

    # Load metrics
    local metrics_file="$METRICS_HISTORY/metrics-${REPORT_TIMESTAMP}.json"

    # Calculate trends
    local trend_data=$(calculate_trends "$quality_score" "$period")
    IFS='|' read -r trend change <<< "$trend_data"

    cat > "$output_file" << 'EOF'
# Level-1-Dev Quality Report

**Report Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Analysis Period:** Last $(echo $period | tr '[:lower:]' '[:upper:]')
**Report Type:** Full Analysis

---

## Executive Summary

### Overall Quality Score: ${quality_score}/100

**Trend:** $([ "$trend" = "improving" ] && echo "📈 Improving" || [ "$trend" = "declining" ] && echo "📉 Declining" || echo "➡️ Stable") (${change:+$change}%)

### Key Highlights

$([ $quality_score -ge 90 ] && echo "✅ **Excellent Quality** - System meets all quality standards")
$([ $quality_score -ge 80 ] && [ $quality_score -lt 90 ] && echo "🟢 **Good Quality** - Minor improvements needed")
$([ $quality_score -ge 70 ] && [ $quality_score -lt 80 ] && echo "🟡 **Acceptable Quality** - Several areas need attention")
$([ $quality_score -lt 70 ] && echo "🔴 **Poor Quality** - Immediate action required")

---

## Detailed Metrics Analysis

### 📊 Testing Metrics

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Total Tests | ${tests_total} | - | - |
| Tests Passed | ${tests_passed} | - | $([ $test_pass_rate -ge 90 ] && echo "✅" || echo "⚠️") |
| Tests Failed | ${tests_failed} | 0 | $([ $tests_failed -eq 0 ] && echo "✅" || echo "❌") |
| Pass Rate | ${test_pass_rate}% | ≥90% | $([ $test_pass_rate -ge 90 ] && echo "✅" || echo "❌") |

### 📈 Code Coverage

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Total Files | ${total_files} | - | - |
| Files with Tests | ${files_with_tests} | - | - |
| Coverage | ${coverage_percent}% | ≥70% | $([ $coverage_percent -ge 70 ] && echo "✅" || echo "⚠️") |

### 🔒 Security Analysis

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Security Issues | ${security_issues} | 0 | $([ $security_issues -eq 0 ] && echo "✅" || echo "❌") |
| Vulnerable Files | $([ $security_issues -gt 0 ] && echo "$security_issues" || echo "0") | 0 | $([ $security_issues -eq 0 ] && echo "✅" || echo "❌") |
| Last Scan | $(date '+%Y-%m-%d') | Daily | ✅ |

### 📚 Documentation Status

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Documentation Files | ${doc_files} | - | - |
| README Files | ${readme_files} | - | - |
| Documentation Ratio | ${doc_ratio}% | ≥80% | $([ $doc_ratio -ge 80 ] && echo "✅" || echo "⚠️") |

### 📦 Version Management

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Version Issues | ${version_issues} | 0 | $([ $version_issues -eq 0 ] && echo "✅" || echo "⚠️") |
| Components Tracked | $(find "$LEVEL1_DIR/versions/manifests" -name "*.yaml" 2>/dev/null | wc -l) | All | - |

### 📈 Development Activity

| Metric | Value | Period |
|--------|-------|--------|
| Commits | ${commits_count} | Last ${period_days} days |
| Contributors | ${contributors} | Last ${period_days} days |
| Avg Commits/Day | $((commits_count / period_days)) | - |

---

## Historical Trends

### Quality Score History

\`\`\`
$(tail -5 "$METRICS_HISTORY"/metrics-*.json 2>/dev/null | grep "quality_score" | grep -o "[0-9]*" | while read score; do
    printf "%3d | " $score
    printf "%${score}s\n" | tr ' ' '█'
done)
\`\`\`

### Metric Trends (Last 5 Reports)

| Date | Quality | Tests | Coverage | Security | Version |
|------|---------|-------|----------|----------|---------|
$(tail -5 "$METRICS_HISTORY"/metrics-*.json 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        date=$(basename "$file" | cut -d- -f2)
        quality=$(grep "quality_score" "$file" | grep -o "[0-9]*" | head -1)
        tests=$(grep "pass_rate" "$file" | grep -o "[0-9]*" | head -1)
        coverage=$(grep "coverage_percent" "$file" | grep -o "[0-9]*" | head -1)
        security=$(grep '"security":' -A2 "$file" | grep "issues" | grep -o "[0-9]*" | head -1)
        version=$(grep '"version":' -A2 "$file" | grep "issues" | grep -o "[0-9]*" | head -1)
        echo "| $date | $quality% | $tests% | $coverage% | $security | $version |"
    fi
done)

---

## Risk Assessment

### Current Risks

$([ $test_pass_rate -lt 90 ] && echo "⚠️ **Testing Risk** - Pass rate below 90% threshold")
$([ $coverage_percent -lt 70 ] && echo "⚠️ **Coverage Risk** - Code coverage below 70% minimum")
$([ $security_issues -gt 0 ] && echo "🔴 **Security Risk** - Active security vulnerabilities detected")
$([ $version_issues -gt 5 ] && echo "⚠️ **Version Risk** - Multiple version management issues")

### Risk Mitigation

$([ $test_pass_rate -lt 90 ] && echo "1. Fix failing tests immediately")
$([ $coverage_percent -lt 70 ] && echo "2. Add tests for uncovered components")
$([ $security_issues -gt 0 ] && echo "3. Address security vulnerabilities")
$([ $version_issues -gt 0 ] && echo "4. Resolve version management issues")

---

## Recommendations

### Immediate Actions

$([ $security_issues -gt 0 ] && echo "- [ ] Fix $security_issues security vulnerabilities")
$([ $tests_failed -gt 0 ] && echo "- [ ] Fix $tests_failed failing tests")
$([ $version_issues -gt 5 ] && echo "- [ ] Resolve version management issues")

### Short-term Improvements (This Week)

$([ $coverage_percent -lt 80 ] && echo "- [ ] Increase test coverage to 80%")
$([ $doc_ratio -lt 90 ] && echo "- [ ] Improve documentation coverage")
$([ $test_pass_rate -lt 95 ] && echo "- [ ] Achieve 95% test pass rate")

### Long-term Goals (This Month)

- [ ] Achieve and maintain 90+ quality score
- [ ] Implement automated performance testing
- [ ] Complete documentation for all components
- [ ] Zero security vulnerabilities
- [ ] 100% version compliance

---

## Component Health Matrix

| Component | Tests | Coverage | Security | Version | Overall |
|-----------|-------|----------|----------|---------|---------|
$(for component in "$LEVEL1_DIR/bin"/*.sh; do
    if [ -f "$component" ]; then
        name=$(basename "$component" .sh)
        has_test=$([ -f "$LEVEL1_DIR/tests/test-${name}.sh" ] && echo "✅" || echo "❌")
        has_version=$(grep -q "version" "$component" && echo "✅" || echo "⚠️")
        echo "| $name | $has_test | - | ✅ | $has_version | $([ "$has_test" = "✅" ] && [ "$has_version" = "✅" ] && echo "✅" || echo "⚠️") |"
    fi
done | head -10)

---

## Quality Gates Status

| Gate | Threshold | Current | Status | Action |
|------|-----------|---------|--------|--------|
| Pre-commit | All checks pass | $([ -x "$QUALITY_DIR/hooks/pre-commit-quality.sh" ] && echo "Active" || echo "Inactive") | $([ -x "$QUALITY_DIR/hooks/pre-commit-quality.sh" ] && echo "✅" || echo "❌") | - |
| Test Suite | 90% pass rate | ${test_pass_rate}% | $([ $test_pass_rate -ge 90 ] && echo "✅" || echo "❌") | $([ $test_pass_rate -lt 90 ] && echo "Fix tests" || echo "-") |
| Coverage | 70% minimum | ${coverage_percent}% | $([ $coverage_percent -ge 70 ] && echo "✅" || echo "❌") | $([ $coverage_percent -lt 70 ] && echo "Add tests" || echo "-") |
| Security | 0 issues | ${security_issues} | $([ $security_issues -eq 0 ] && echo "✅" || echo "❌") | $([ $security_issues -gt 0 ] && echo "Fix now" || echo "-") |
| Release | All gates pass | - | $([ $quality_score -ge 85 ] && echo "✅" || echo "❌") | $([ $quality_score -lt 85 ] && echo "Not ready" || echo "Ready") |

---

## Action Plan

### Priority 1 - Critical (Today)
$([ $security_issues -gt 0 ] && echo "1. Fix security vulnerabilities")
$([ $tests_failed -gt 5 ] && echo "2. Fix critical test failures")

### Priority 2 - Important (This Week)
$([ $coverage_percent -lt 70 ] && echo "1. Increase test coverage")
$([ $version_issues -gt 0 ] && echo "2. Fix version management")
$([ $doc_ratio -lt 80 ] && echo "3. Update documentation")

### Priority 3 - Maintenance (This Month)
1. Refactor complex components
2. Optimize performance bottlenecks
3. Update dependencies
4. Archive old reports

---

## Appendix

### Report Configuration
- **Generated By:** $(whoami)
- **Report Period:** ${period}
- **Analysis Depth:** Full
- **Data Sources:** All available metrics

### Next Report
- **Scheduled:** $(date -d "+${period_days} days" '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d')
- **Type:** ${period} analysis

### Report Archive
- Previous reports: $ARCHIVE_DIR
- Metrics history: $METRICS_HISTORY
- Raw data: $REPORTS_DIR

---

*End of Report - Generated by Automated Quality Report System v1.0*
EOF

    echo -e "${GREEN}✓ Report generated: $output_file${NC}"

    # Archive if requested
    if [ "${ARCHIVE:-false}" = "true" ]; then
        cp "$output_file" "$ARCHIVE_DIR/"
        echo -e "${GREEN}✓ Report archived${NC}"
    fi
}

# Function: Generate summary report
generate_summary_report() {
    local output_file="$REPORTS_DIR/quality-summary-${REPORT_TIMESTAMP}.md"

    echo -e "${BLUE}Generating summary report...${NC}"

    local quality_score=$(collect_all_metrics "weekly")

    cat > "$output_file" << EOF
# Quality Summary Report

**Date:** $(date '+%Y-%m-%d')
**Quality Score:** ${quality_score}/100

## Key Metrics
- Test Pass Rate: ${test_pass_rate}%
- Code Coverage: ${coverage_percent}%
- Security Issues: ${security_issues}
- Version Issues: ${version_issues}

## Status
$([ $quality_score -ge 85 ] && echo "✅ System Healthy" || echo "⚠️ Attention Required")

## Top Actions
$([ $security_issues -gt 0 ] && echo "1. Fix security issues")
$([ $test_pass_rate -lt 90 ] && echo "2. Fix failing tests")
$([ $coverage_percent -lt 70 ] && echo "3. Increase coverage")

---
*Summary Report - $(date '+%H:%M:%S')*
EOF

    echo -e "${GREEN}✓ Summary generated: $output_file${NC}"
}

# Function: Generate executive report
generate_executive_report() {
    local output_file="$REPORTS_DIR/executive-report-${REPORT_TIMESTAMP}.md"

    echo -e "${BLUE}Generating executive report...${NC}"

    local quality_score=$(collect_all_metrics "monthly")

    cat > "$output_file" << EOF
# Executive Quality Report

**Period:** $(date '+%B %Y')

## Overall Health: ${quality_score}/100

## Business Impact
- **Risk Level:** $([ $quality_score -ge 85 ] && echo "Low" || [ $quality_score -ge 70 ] && echo "Medium" || echo "High")
- **Release Readiness:** $([ $quality_score -ge 85 ] && echo "Yes" || echo "No")
- **Technical Debt:** $([ $quality_score -ge 90 ] && echo "Minimal" || [ $quality_score -ge 75 ] && echo "Manageable" || echo "Significant")

## Investment Areas
$([ $coverage_percent -lt 80 ] && echo "- Testing infrastructure")
$([ $doc_ratio -lt 80 ] && echo "- Documentation")
$([ $security_issues -gt 0 ] && echo "- Security remediation")

## Recommendation
$([ $quality_score -ge 85 ] && echo "Continue current practices" || echo "Increase quality focus")

---
*Executive Report*
EOF

    echo -e "${GREEN}✓ Executive report generated: $output_file${NC}"
}

# Function: Schedule reports
schedule_report() {
    local schedule=$1

    echo -e "${BLUE}Scheduling automatic report generation...${NC}"

    # Add to crontab
    local cron_entry="$schedule $0 --format full --archive"

    (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -

    echo -e "${GREEN}✓ Report scheduled: $schedule${NC}"
}

# Main execution
main() {
    local format="full"
    local output="markdown"
    local period="weekly"
    local email=""
    local schedule=""
    local archive=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--format)
                format="$2"
                shift 2
                ;;
            -o|--output)
                output="$2"
                shift 2
                ;;
            -p|--period)
                period="$2"
                shift 2
                ;;
            -e|--email)
                email="$2"
                shift 2
                ;;
            -s|--schedule)
                schedule="$2"
                shift 2
                ;;
            -a|--archive)
                archive=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # Generate report based on format
    case "$format" in
        full)
            generate_full_report "$period"
            ;;
        summary)
            generate_summary_report
            ;;
        executive)
            generate_executive_report
            ;;
        *)
            echo "Unknown format: $format"
            exit 1
            ;;
    esac

    # Schedule if requested
    if [ -n "$schedule" ]; then
        schedule_report "$schedule"
    fi

    # Email if requested
    if [ -n "$email" ]; then
        echo "Email functionality not implemented"
    fi

    echo -e "\n${GREEN}✓ Report generation complete!${NC}"
}

# Run main
main "$@"
