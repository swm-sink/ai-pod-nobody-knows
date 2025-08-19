# Quality Assurance Constants



## Content quality thresholds
CONTENT_ACCURACY_THRESHOLD
0.95
Minimum accuracy threshold - no hallucinated facts allowed
CONTENT_COMPREHENSION_THRESHOLD
0.85
Minimum comprehension threshold - content must be clearly understandable
CONTENT_ENGAGEMENT_THRESHOLD
0.80
Minimum engagement threshold - content must hold listener attention
BRAND_CONSISTENCY_THRESHOLD
0.90
Minimum brand consistency threshold - must match voice and tone
TECHNICAL_QUALITY_THRESHOLD
0.85
Minimum technical quality threshold - audio and production standards

## Validation score ranges
VALIDATION_MINIMUM_PASSING
0.80
Minimum passing score for validation
VALIDATION_TARGET_SCORE
0.85
Target quality score to aim for
VALIDATION_EXCELLENT_SCORE
0.90
Excellent quality score threshold
VALIDATION_PERFECT_SCORE
0.95
Perfect quality score threshold

## Mandatory compliance requirements
CHANGE_APPROVAL_SCOPE
ALL_CONTENT_MODIFICATIONS
All content modifications require change approval process
HALLUCINATION_PREVENTION_SOURCES_MIN
3
Minimum number of independent sources for fact verification
TDD_COVERAGE_MINIMUM
0.80
Minimum test coverage requirement
TDD_TEST_FIRST_REQUIRED
true
Tests must be written before code implementation

## Test coverage standards
UNIT_TEST_COVERAGE_MINIMUM
0.80
Minimum coverage for unit tests
UNIT_TEST_FRAMEWORK
pytest
Required framework for unit testing
INTEGRATION_TEST_SCOPE
API_CONNECTIONS
Integration tests must cover all API connections
TEST_NAMING_PATTERN
test_[function]_[scenario]
Required naming pattern for test functions

## Error severity classification
CRITICAL_ERROR_RESPONSE_TIME
IMMEDIATE
Response time for critical errors affecting system or safety
HIGH_ERROR_RESPONSE_TIME
SAME_SESSION
Response time for high priority functionality issues
MEDIUM_ERROR_RESPONSE_TIME
NEXT_SESSION
Response time for minor functionality issues
LOW_ERROR_RESPONSE_TIME
FUTURE_ITERATION
Response time for cosmetic or enhancement requests

## Quality measurement standards
AUDIO_QUALITY_STANDARD
PROFESSIONAL_PODCAST_STANDARD
Audio must meet professional podcast production standards
EPISODE_DURATION_TOLERANCE
0.05
Maximum deviation from target episode duration (5%)
SYSTEM_UPTIME_TARGET
0.99
Target system uptime percentage
RESPONSE_TIME_TARGET
5
Maximum acceptable response time in seconds
SCALE_CAPACITY_TARGET
125
System must handle production of 125 episodes

## Monitoring and reporting
REAL_TIME_MONITORING
SYSTEM_PERFORMANCE_ERRORS
System performance and errors monitored in real-time
DAILY_MONITORING
QUALITY_SCORES_COST_TRACKING
Quality scores and cost tracking monitored daily
WEEKLY_MONITORING
TREND_ANALYSIS_IMPROVEMENTS
Trend analysis and improvements reviewed weekly
MONTHLY_MONITORING
OVERALL_SYSTEM_HEALTH
Overall system health assessed monthly

## Validation workflow steps
CONTENT_VALIDATION_STEP_COUNT
5
Number of steps in content validation workflow
CODE_VALIDATION_STEP_COUNT
6
Number of steps in code validation workflow
SYSTEM_VALIDATION_STEP_COUNT
5
Number of steps in system validation workflow
USER_APPROVAL_REQUIRED
true
User approval required for all validation workflows
Global project constants and standards
Change approval workflow implementation
Fact verification and validation processes
Test-driven development quality standards

---

*Converted from XML to Markdown for elegant simplicity*
*Original: 00_quality_constants.xml*
*Conversion: Mon Aug 18 10:47:18 EDT 2025*
