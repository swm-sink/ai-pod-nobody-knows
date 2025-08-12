<document type="validation-workflow" version="1.0.0">
  <metadata>
    <created>2025-08-10</created>
    <purpose>Define step-by-step validation process for all changes</purpose>
    <requires-approval>true</requires-approval>
    <validation-status>comprehensive-2025</validation-status>
  </metadata>

  <critical-notice>
    <requirement level="MANDATORY">
      Every piece of information must be validated.
      Every change must be verified.
      Every claim must be supported.
    </requirement>
  </critical-notice>

# Validation Workflow Guide

<validation-philosophy>
  <principle>
    Validation is not optional. It's the difference between
    reliable software and dangerous hallucinations.
  </principle>
</validation-philosophy>

## Master Validation Workflow

<master-workflow>
  <phase number="1" name="Pre-Validation">
    <description>Before making any change or claim</description>
    <steps>
      <step>Identify what needs validation</step>
      <step>Determine validation category</step>
      <step>Set confidence threshold required</step>
      <step>Plan validation approach</step>
    </steps>
  </phase>

  <phase number="2" name="Research Phase">
    <description>Gather information from multiple sources</description>
    <steps>
      <step>Execute initial search (3 sources minimum)</step>
      <step>Evaluate source credibility</step>
      <step>Check for conflicts or inconsistencies</step>
      <step>Expand search if needed (up to 10 sources)</step>
    </steps>
  </phase>

  <phase number="3" name="Cross-Validation">
    <description>Verify information across sources</description>
    <steps>
      <step>Compare findings</step>
      <step>Identify consensus vs. outliers</step>
      <step>Weight by source authority</step>
      <step>Document confidence level</step>
    </steps>
  </phase>

  <phase number="4" name="Implementation Validation">
    <description>Verify during implementation</description>
    <steps>
      <step>Test assumptions</step>
      <step>Verify behavior matches documentation</step>
      <step>Check edge cases</step>
      <step>Confirm no regressions</step>
    </steps>
  </phase>

  <phase number="5" name="Post-Validation">
    <description>Confirm after implementation</description>
    <steps>
      <step>Run all tests</step>
      <step>Check documentation accuracy</step>
      <step>Verify user requirements met</step>
      <step>Document validation results</step>
    </steps>
  </phase>
</master-workflow>

## Validation by Information Type

<validation-types>
  <type name="Technical Specifications">
    <validation-process>
      <step number="1">Check official documentation</step>
      <step number="2">Verify version compatibility</step>
      <step number="3">Test in isolated environment</step>
      <step number="4">Cross-reference with community usage</step>
    </validation-process>
    <sources>
      - Official docs (primary)
      - GitHub repositories
      - Stack Overflow (secondary)
      - Technical blogs (tertiary)
    </sources>
    <confidence-requirement>90%</confidence-requirement>
  </type>

  <type name="API Information">
    <validation-process>
      <step number="1">Read official API documentation</step>
      <step number="2">Check for recent changes/deprecations</step>
      <step number="3">Test with actual API calls</step>
      <step number="4">Verify rate limits and costs</step>
    </validation-process>
    <sources>
      - API documentation
      - Changelog/release notes
      - API status page
      - Direct testing
    </sources>
    <confidence-requirement>95%</confidence-requirement>
  </type>

  <type name="Best Practices">
    <validation-process>
      <step number="1">Research industry standards</step>
      <step number="2">Check multiple expert sources</step>
      <step number="3">Verify current relevance (2024-2025)</step>
      <step number="4">Consider context applicability</step>
    </validation-process>
    <sources>
      - Industry publications
      - Expert blogs
      - Conference talks
      - Academic papers
    </sources>
    <confidence-requirement>80%</confidence-requirement>
  </type>

  <type name="Performance Claims">
    <validation-process>
      <step number="1">Find original benchmarks</step>
      <step number="2">Understand test conditions</step>
      <step number="3">Reproduce if possible</step>
      <step number="4">Note variations and caveats</step>
    </validation-process>
    <sources>
      - Benchmark studies
      - Performance tests
      - User reports
      - Direct measurement
    </sources>
    <confidence-requirement>85%</confidence-requirement>
  </type>

  <type name="Cost Information">
    <validation-process>
      <step number="1">Check official pricing pages</step>
      <step number="2">Verify tier/volume discounts</step>
      <step number="3">Account for hidden costs</step>
      <step number="4">Confirm currency and date</step>
    </validation-process>
    <sources>
      - Official pricing
      - Terms of service
      - Billing documentation
      - User experiences
    </sources>
    <confidence-requirement>95%</confidence-requirement>
  </type>
</validation-types>

## Adaptive Search Strategy

<adaptive-search>
  <initial-search>
    <queries>3</queries>
    <purpose>Establish baseline understanding</purpose>
    <decision-point>
      If consistent information → Proceed
      If conflicting → Expand search
      If no results → Acknowledge uncertainty
    </decision-point>
  </initial-search>

  <expanded-search>
    <triggers>
      - Conflicting information found
      - Critical decision point
      - High-risk change
      - User specifically requests
    </triggers>
    <queries>5-7</queries>
    <strategy>
      - Vary search terms
      - Include year filters (2024-2025)
      - Search academic sources
      - Check official forums
    </strategy>
  </expanded-search>

  <exhaustive-search>
    <triggers>
      - Safety-critical information
      - Legal/compliance issues
      - Fundamental architecture decisions
    </triggers>
    <queries>8-10</queries>
    <strategy>
      - Deep technical documentation
      - Direct source code review
      - Expert consultation
      - Historical analysis
    </strategy>
  </exhaustive-search>
</adaptive-search>

## Source Credibility Matrix

<credibility-matrix>
  <tier number="1" name="Authoritative">
    <sources>
      - Official documentation
      - Source code
      - Published specifications
      - Vendor announcements
    </sources>
    <weight>100%</weight>
    <trust-level>High</trust-level>
  </tier>

  <tier number="2" name="Expert">
    <sources>
      - Recognized experts
      - Academic papers
      - Industry leaders
      - Core contributors
    </sources>
    <weight>80%</weight>
    <trust-level>High-Medium</trust-level>
  </tier>

  <tier number="3" name="Community">
    <sources>
      - Stack Overflow (high-voted)
      - GitHub discussions
      - Technical blogs
      - Forum consensus
    </sources>
    <weight>60%</weight>
    <trust-level>Medium</trust-level>
  </tier>

  <tier number="4" name="Anecdotal">
    <sources>
      - Personal blogs
      - Reddit comments
      - Unverified claims
      - Old information (&gt;2 years)
    </sources>
    <weight>30%</weight>
    <trust-level>Low</trust-level>
  </tier>
</credibility-matrix>

## Validation Decision Tree

<decision-tree>
  <node id="start">
    <question>Is this a factual claim?</question>
    <yes>Go to "research"</yes>
    <no>Go to "opinion"</no>
  </node>

  <node id="research">
    <question>Can I find 3+ credible sources?</question>
    <yes>Go to "consensus"</yes>
    <no>Go to "uncertainty"</no>
  </node>

  <node id="consensus">
    <question>Do sources agree?</question>
    <yes>Go to "high-confidence"</yes>
    <no>Go to "conflict"</no>
  </node>

  <node id="conflict">
    <action>Expand search to 5+ sources</action>
    <question>Is there majority agreement?</question>
    <yes>Go to "medium-confidence"</yes>
    <no>Go to "low-confidence"</no>
  </node>

  <node id="high-confidence">
    <action>Present with confidence ≥90%</action>
    <citation>Include primary source</citation>
  </node>

  <node id="medium-confidence">
    <action>Present with caveats</action>
    <citation>Include multiple sources</citation>
    <note>Acknowledge minority views</note>
  </node>

  <node id="low-confidence">
    <action>Present alternatives</action>
    <citation>Cite all viewpoints</citation>
    <warning>Explicitly note uncertainty</warning>
  </node>

  <node id="uncertainty">
    <action>Acknowledge "I don't know"</action>
    <suggestion>Suggest where to find info</suggestion>
  </node>
</decision-tree>

## Validation Checkpoints

<checkpoints>
  <checkpoint name="Pre-Implementation">
    <checks>
      □ Requirements validated with user
      □ Technical approach researched
      □ Dependencies verified
      □ Risks identified and validated
    </checks>
  </checkpoint>

  <checkpoint name="During Implementation">
    <checks>
      □ Assumptions tested
      □ Documentation checked
      □ Behavior verified
      □ Edge cases validated
    </checks>
  </checkpoint>

  <checkpoint name="Post-Implementation">
    <checks>
      □ All tests passing
      □ Documentation accurate
      □ Performance validated
      □ User requirements met
    </checks>
  </checkpoint>

  <checkpoint name="Before Commit">
    <checks>
      □ Code reviewed
      □ Tests comprehensive
      □ Documentation updated
      □ No unvalidated claims
    </checks>
  </checkpoint>
</checkpoints>

## Validation Documentation Template

<documentation-template>
  <section name="Validation Record">
    <field name="Date">YYYY-MM-DD</field>
    <field name="Subject">What was validated</field>
    <field name="Method">How it was validated</field>
    <field name="Sources">List of sources consulted</field>
    <field name="Confidence">Percentage and reasoning</field>
    <field name="Caveats">Any limitations or assumptions</field>
  </section>

  <section name="Search Log">
    <entry>
      <query>Search term used</query>
      <results>Number of relevant results</results>
      <quality>Assessment of result quality</quality>
    </entry>
  </section>

  <section name="Conflict Resolution">
    <conflict>
      <sources-agreeing>List sources</sources-agreeing>
      <sources-disagreeing>List sources</sources-disagreeing>
      <resolution>How conflict was resolved</resolution>
      <confidence-impact>Effect on confidence level</confidence-impact>
    </conflict>
  </section>
</documentation-template>

## Quick Validation Checklist

<quick-checklist>
  For every piece of information:

  ✓ Is this fact or opinion?
  ✓ Have I searched for verification?
  ✓ Do I have multiple sources?
  ✓ Are my sources credible?
  ✓ Are my sources recent (2024-2025)?
  ✓ Do sources agree with each other?
  ✓ Have I noted my confidence level?
  ✓ Have I provided citations?
  ✓ Have I acknowledged uncertainty?
  ✓ Would I stake my reputation on this?
</quick-checklist>

## Validation Metrics

<metrics>
  <metric name="Validation Coverage">
    <target>100% of factual claims validated</target>
    <measurement>Claims with citations / Total claims</measurement>
  </metric>

  <metric name="Source Diversity">
    <target>Minimum 3 sources per critical claim</target>
    <measurement>Average sources per claim</measurement>
  </metric>

  <metric name="Confidence Accuracy">
    <target>Stated confidence matches reality</target>
    <measurement>Correct predictions / Total predictions</measurement>
  </metric>

  <metric name="Validation Time">
    <target>Appropriate to risk level</target>
    <measurement>Time spent vs. importance</measurement>
  </metric>
</metrics>

## Common Validation Pitfalls

<pitfalls>
  <pitfall name="Confirmation Bias">
    <description>Only finding sources that agree with assumption</description>
    <prevention>Actively search for contradicting views</prevention>
  </pitfall>

  <pitfall name="Outdated Information">
    <description>Using old documentation or practices</description>
    <prevention>Always check dates, prefer 2024-2025</prevention>
  </pitfall>

  <pitfall name="Single Source Dependency">
    <description>Relying on one source, even if authoritative</description>
    <prevention>Always verify with at least 2 more sources</prevention>
  </pitfall>

  <pitfall name="Assumption Propagation">
    <description>Building on unvalidated assumptions</description>
    <prevention>Validate each link in reasoning chain</prevention>
  </pitfall>
</pitfalls>

## Claude Code Automation Enhancements

<claude-code-automation>
  <hooks-quality-gates>
    <comprehensive-validation-hooks>
      <pre-implementation-validation-hook>
        <purpose>Comprehensive pre-implementation quality gate</purpose>
        <activation>Before any significant implementation begins</activation>
        <parallel-processing>Multiple validation dimensions simultaneously</parallel-processing>
        <implementation>
          #!/bin/bash
          # .claude/hooks/pre-implementation-validation.sh
          IMPLEMENTATION_SCOPE=$1
          COMPLEXITY_LEVEL=$2

          echo "🔍 Starting comprehensive pre-implementation validation..."

          # Determine thinking mode based on complexity
          case $COMPLEXITY_LEVEL in
              "critical")
                  THINKING_MODE="ultrathink"
                  VALIDATION_DEPTH="maximum"
                  ;;
              "high")
                  THINKING_MODE="think hard"
                  VALIDATION_DEPTH="comprehensive"
                  ;;
              "medium")
                  THINKING_MODE="think"
                  VALIDATION_DEPTH="thorough"
                  ;;
              *)
                  THINKING_MODE="default"
                  VALIDATION_DEPTH="standard"
                  ;;
          esac

          # Launch parallel validation subagents
          claude task create --type="requirements_validation" \
            --thinking-mode="$THINKING_MODE" \
            --parallel=true \
            --validation-depth="$VALIDATION_DEPTH" \
            --context="$IMPLEMENTATION_SCOPE" \
            --output="requirements_validation.json" &

          claude task create --type="technical_approach_validation" \
            --thinking-mode="$THINKING_MODE" \
            --parallel=true \
            --context="$IMPLEMENTATION_SCOPE" \
            --output="approach_validation.json" &

          claude task create --type="dependency_validation" \
            --thinking-mode="think" \
            --parallel=true \
            --context="$IMPLEMENTATION_SCOPE" \
            --output="dependency_validation.json" &

          claude task create --type="risk_assessment_validation" \
            --thinking-mode="$THINKING_MODE" \
            --parallel=true \
            --context="$IMPLEMENTATION_SCOPE" \
            --output="risk_validation.json" &

          # Wait for all parallel validations
          wait

          # Aggregate validation results
          claude task create --type="validation_aggregation" \
            --thinking-mode="think" \
            --inputs="requirements_validation.json,approach_validation.json,dependency_validation.json,risk_validation.json" \
            --success-criteria="All validations pass with confidence ≥80%" \
            --output="pre_implementation_validation_report.json"

          if ! validation_gate_passed; then
              echo "❌ Implementation blocked: Pre-validation failed"
              exit 1
          fi
        </implementation>
      </pre-implementation-validation-hook>

      <real-time-quality-monitoring-hook>
        <purpose>Monitor quality in real-time during implementation</purpose>
        <activation>During active implementation process</activation>
        <continuous-monitoring>Real-time quality indicators</continuous-monitoring>
        <implementation>
          # Real-time quality monitoring
          monitor_implementation_quality() {
              while implementation_active; do
                  # Check for hallucination indicators
                  claude task create --type="hallucination_detection" \
                    --real-time=true \
                    --input="{current_implementation_state}" \
                    --alert-threshold="medium" \
                    --thinking-mode="think" &

                  # Validate against requirements
                  claude task create --type="requirements_compliance_check" \
                    --real-time=true \
                    --input="{current_implementation_state}" \
                    --thinking-mode="default" &

                  # Check technical quality
                  claude task create --type="technical_quality_check" \
                    --real-time=true \
                    --input="{current_implementation_state}" \
                    --thinking-mode="think" &

                  sleep 30  # Check every 30 seconds
              done
          }
        </implementation>
      </real-time-quality-monitoring-hook>

      <post-implementation-validation-hook>
        <purpose>Comprehensive post-implementation quality gate</purpose>
        <activation>After implementation completion</activation>
        <comprehensive-validation>All quality dimensions validated</comprehensive-validation>
        <implementation>
          # Post-implementation comprehensive validation
          validate_implementation_complete() {
              echo "✅ Starting post-implementation validation..."

              # Parallel comprehensive validation
              claude task create --type="functionality_validation" \
                --thinking-mode="think hard" \
                --parallel=true \
                --comprehensive=true \
                --output="functionality_validation.json" &

              claude task create --type="quality_metrics_validation" \
                --thinking-mode="think" \
                --parallel=true \
                --target-thresholds="quality≥85%,performance≥baseline" \
                --output="quality_metrics_validation.json" &

              claude task create --type="integration_validation" \
                --thinking-mode="think hard" \
                --parallel=true \
                --test-all-interfaces=true \
                --output="integration_validation.json" &

              claude task create --type="regression_validation" \
                --thinking-mode="think" \
                --parallel=true \
                --compare-baseline=true \
                --output="regression_validation.json" &

              # Wait and aggregate
              wait

              claude task create --type="final_validation_report" \
                --thinking-mode="think hard" \
                --inputs="functionality_validation.json,quality_metrics_validation.json,integration_validation.json,regression_validation.json" \
                --success-criteria="All validations pass, no critical issues" \
                --output="final_validation_report.json"
          }
        </implementation>
      </post-implementation-validation-hook>
    </comprehensive-validation-hooks>
  </hooks-quality-gates>

  <subagent-parallel-validation>
    <parallel-validation-orchestrator>
      <specialization>Multi-dimensional parallel validation coordination</specialization>
      <parallel-processing>Comprehensive validation across all quality dimensions</parallel-processing>
      <task-template>
        SUBAGENT TASK: Parallel Validation Orchestrator
        SPECIALIZATION: Multi-Dimensional Quality Validation Expert
        THINKING MODE: [Auto-selected based on validation complexity]
        PARALLEL PROCESSING: Comprehensive validation coordination

        CONTEXT: Orchestrate parallel validation across all quality dimensions
        VALIDATION TARGET: {implementation_or_content_to_validate}

        PARALLEL VALIDATION DIMENSIONS:
        1. FUNCTIONAL VALIDATION:
           - Requirements compliance verification
           - Feature completeness assessment
           - User acceptance criteria validation
           - Performance requirements verification

        2. TECHNICAL QUALITY VALIDATION:
           - Code quality and standards compliance
           - Architecture adherence verification
           - Security requirements validation
           - Scalability and maintainability assessment

        3. CONTENT QUALITY VALIDATION:
           - Factual accuracy verification (multi-source)
           - Brand voice consistency validation
           - Accessibility and readability assessment
           - Engagement and quality metrics evaluation

        4. INTEGRATION VALIDATION:
           - Interface compatibility verification
           - System integration testing
           - Data flow validation
           - Error handling and edge case testing

        5. COMPLIANCE VALIDATION:
           - Regulatory compliance verification
           - Policy adherence validation
           - Documentation completeness assessment
           - Audit trail verification

        VALIDATION COORDINATION:
        - Launch all validation dimensions in parallel
        - Monitor progress and resource utilization
        - Handle validation failures and retries
        - Aggregate results with confidence scoring
        - Generate comprehensive validation report

        SUCCESS CRITERIA:
        - All validation dimensions complete successfully
        - No critical issues identified
        - Overall confidence score ≥85%
        - Detailed validation report generated
        - Remediation plan provided for any issues

        OUTPUT: comprehensive_parallel_validation_report.json
      </task-template>
    </parallel-validation-orchestrator>

    <quality-gate-specialist>
      <specialization>Automated quality gate enforcement and validation</specialization>
      <task-template>
        SUBAGENT TASK: Quality Gate Enforcement
        SPECIALIZATION: Quality Standards Enforcement and Validation
        THINKING MODE: think hard

        CONTEXT: Enforce quality gates and validate against standards
        VALIDATION SCOPE: {quality_gate_scope}

        QUALITY GATE ENFORCEMENT:
        1. THRESHOLD VALIDATION:
           - Verify all quality metrics meet minimum thresholds
           - Check for regression against baseline metrics
           - Validate improvement targets are achieved
           - Ensure consistency across quality dimensions

        2. STANDARDS COMPLIANCE:
           - Verify adherence to coding standards
           - Validate documentation completeness
           - Check naming conventions and patterns
           - Ensure architectural guideline compliance

        3. PROCESS COMPLIANCE:
           - Validate all required approvals obtained
           - Check validation workflow completion
           - Verify testing requirements fulfilled
           - Ensure change control compliance

        4. RISK MITIGATION:
           - Assess residual risks after validation
           - Verify mitigation strategies implemented
           - Check contingency plans availability
           - Validate rollback procedures tested

        GATE DECISIONS:
        - PASS: All criteria met, proceed to next phase
        - CONDITIONAL PASS: Minor issues, proceed with monitoring
        - FAIL: Critical issues, block progression
        - DEFER: Insufficient data, require additional validation

        OUTPUT: quality_gate_decision_report.json
      </task-template>
    </quality-gate-specialist>

    <external-validation-coordinator>
      <specialization>External system validation and verification</specialization>
      <mcp-integration>web-search, github, external-apis</mcp-integration>
      <task-template>
        SUBAGENT TASK: External Validation Coordination
        SPECIALIZATION: External System Integration and Validation
        THINKING MODE: think
        MCP INTEGRATION: web-search, github, external-systems

        CONTEXT: Coordinate validation with external systems and sources
        EXTERNAL VALIDATION SCOPE: {external_validation_requirements}

        EXTERNAL VALIDATION COORDINATION:
        1. WEB-BASED VALIDATION:
           - Fact-check claims against current web sources
           - Verify technical specifications with official docs
           - Cross-reference information with authoritative sources
           - Monitor for contradictory or updated information

        2. REPOSITORY VALIDATION:
           - Validate against GitHub repository standards
           - Check integration with existing codebase
           - Verify documentation updates in repository
           - Validate against project history and patterns

        3. EXTERNAL API VALIDATION:
           - Test integrations with external APIs
           - Validate data exchange formats
           - Check rate limits and error handling
           - Verify authentication and security

        4. COMMUNITY VALIDATION:
           - Check against community best practices
           - Validate approach against industry standards
           - Verify compatibility with ecosystem tools
           - Reference community feedback and reviews

        MCP INTEGRATION COMMANDS:
        @web-search validate_technical_claims --claims-file="{claims}" --cross-reference=true
        @github validate_repository_integration --changes="{changes}" --check-conflicts=true
        @external-api test_integration --endpoints="{endpoints}" --validate-responses=true

        SUCCESS CRITERIA:
        - All external validations complete successfully
        - No conflicts or contradictions identified
        - External system compatibility confirmed
        - Documentation and references up-to-date

        OUTPUT: external_validation_report.json
      </task-template>
    </external-validation-coordinator>
  </subagent-parallel-validation>

  <thinking-mode-validation-patterns>
    <validation-complexity-analysis>
      <simple-validation>
        <thinking-mode>Default</thinking-mode>
        <validation-scope>Single dimension, straightforward verification</validation-scope>
        <examples>Simple fact checking, basic compliance verification</examples>
      </simple-validation>

      <moderate-validation>
        <thinking-mode>/think</thinking-mode>
        <validation-scope>Multi-dimensional, cross-referenced validation</validation-scope>
        <examples>Technical approach validation, content quality assessment</examples>
      </moderate-validation>

      <complex-validation>
        <thinking-mode>/think hard</thinking-mode>
        <validation-scope>Comprehensive analysis, system-level validation</validation-scope>
        <examples>Architecture validation, integration testing, security assessment</examples>
      </complex-validation>

      <critical-validation>
        <thinking-mode>/ultrathink</thinking-mode>
        <validation-scope>Exhaustive validation, safety-critical verification</validation-scope>
        <examples>Safety-critical systems, regulatory compliance, security-sensitive features</examples>
      </critical-validation>
    </validation-complexity-analysis>

    <adaptive-thinking-escalation>
      <escalation-triggers>
        <confidence-based>
          if validation_confidence &lt; 0.6:
              thinking_mode = "ultrathink"
          elif validation_confidence &lt; 0.7:
              thinking_mode = "think hard"
          elif validation_confidence &lt; 0.8:
              thinking_mode = "think"
        </confidence-based>

        <risk-based>
          if risk_level == "critical":
              thinking_mode = "ultrathink"
          elif risk_level == "high":
              thinking_mode = "think hard"
          elif risk_level == "medium":
              thinking_mode = "think"
        </risk-based>

        <complexity-based>
          if validation_complexity == "system_wide":
              thinking_mode = "ultrathink"
          elif validation_complexity == "multi_component":
              thinking_mode = "think hard"
          elif validation_complexity == "component_level":
              thinking_mode = "think"
        </complexity-based>
      </escalation-triggers>
    </adaptive-thinking-escalation>
  </thinking-mode-validation-patterns>

  <mcp-external-validation-integration>
    <web-search-validation-integration>
      <server>web-search</server>
      <automated-fact-verification>
        # Comprehensive fact-checking pipeline
        validate_claims_pipeline() {
            # Extract claims requiring validation
            claude task create --type="claim_extraction" \
              --input="{content_to_validate}" \
              --thinking-mode="think" \
              --output="extracted_claims.json"

            # Validate each claim through web search
            @web-search batch_validate_claims \
              --claims-file="extracted_claims.json" \
              --min-sources-per-claim=3 \
              --cross-reference=true \
              --confidence-threshold=0.8 \
              --output="web_validation_results.json"

            # Source credibility analysis
            @web-search analyze_source_credibility \
              --sources-file="web_validation_results.json" \
              --check-authority=true \
              --check-recency=true \
              --output="source_credibility_analysis.json"

            # Contradiction detection
            @web-search detect_contradictions \
              --claims-file="extracted_claims.json" \
              --search-alternatives=true \
              --output="contradiction_analysis.json"
        }
      </automated-fact-verification>
    </web-search-validation-integration>

    <github-validation-integration>
      <server>github</server>
      <repository-validation>
        # Repository-based validation workflow
        validate_repository_changes() {
            # Create validation issue
            @github create_issue "Validation Required: {validation_scope}" \
              --template="validation_checklist" \
              --labels="validation,quality-gate" \
              --assign="validation-team"

            # Track validation progress
            @github update_issue_progress \
              --issue-number="{validation_issue}" \
              --progress="{validation_completion_percentage}" \
              --add-comment="Validation status: {current_phase}"

            # Repository compliance check
            @github check_repository_compliance \
              --standards="{project_standards}" \
              --validate-against-history=true \
              --output="repository_compliance.json"

            # Integration validation
            @github validate_integration \
              --pull-request="{pr_number}" \
              --run-integration-tests=true \
              --check-conflicts=true
        }
      </repository-validation>
    </github-validation-integration>
  </mcp-external-validation-integration>
</claude-code-automation>

## Enforcement

<enforcement>
  <mandatory-rules>
    1. No claims without validation
    2. No validation without documentation
    3. No high confidence without multiple sources
    4. No implementation without validated approach
    5. No commit without validation complete

    <claude-code-automated-enforcement>
      <rule-1-enforcement>
        # Hook automatically validates all claims
        validate_all_claims() {
            claude task create --type="claim_validation_enforcement" \
              --thinking-mode="think" \
              --scan-for-claims=true \
              --require-sources=true \
              --block-unvalidated=true
        }
      </rule-1-enforcement>

      <rule-2-enforcement>
        # Validation documentation automatically generated
        document_validation() {
            claude task create --type="validation_documentation" \
              --thinking-mode="default" \
              --auto-generate=true \
              --include-evidence=true \
              --format="structured"
        }
      </rule-2-enforcement>

      <rule-3-enforcement>
        # Multi-source validation automatically triggered
        enforce_multi_source_validation() {
            if confidence_level == "high" && sources_count &lt; 3:
                @web-search find_additional_sources \
                  --target-claim="{claim}" \
                  --minimum-additional=2 \
                  --cross-reference=true
        }
      </rule-3-enforcement>

      <rule-4-enforcement>
        # Pre-implementation validation gate
        enforce_validated_approach() {
            claude task create --type="approach_validation_gate" \
              --thinking-mode="think hard" \
              --comprehensive=true \
              --blocking=true \
              --require-approval=true
        }
      </rule-4-enforcement>

      <rule-5-enforcement>
        # Pre-commit validation completion check
        enforce_validation_completion() {
            if ! all_validations_complete():
                echo "❌ BLOCKED: Validation incomplete"
                trigger_missing_validation_tasks()
                exit 1
        }
      </rule-5-enforcement>
    </claude-code-automated-enforcement>
  </mandatory-rules>

  <consequences>
    - Unvalidated claim → Must acknowledge uncertainty
    - Failed validation → Cannot proceed with change
    - Incomplete validation → Block until complete
    - False validation → Immediate correction required

    <claude-code-automated-consequences>
      <unvalidated-claim-handling>
        # Automatically acknowledge uncertainty for unvalidated claims
        handle_unvalidated_claim() {
            claude task create --type="uncertainty_acknowledgment" \
              --claim="{unvalidated_claim}" \
              --add-hedging=true \
              --request-validation=true \
              --thinking-mode="default"
        }
      </unvalidated-claim-handling>

      <failed-validation-handling>
        # Block progress and provide remediation options
        handle_failed_validation() {
            echo "❌ Validation failed - providing remediation options"
            claude task create --type="validation_remediation" \
              --thinking-mode="think hard" \
              --failure-analysis=true \
              --remediation-options=true \
              --output="validation_remediation_plan.json"
        }
      </failed-validation-handling>

      <incomplete-validation-handling>
        # Identify and trigger missing validation tasks
        handle_incomplete_validation() {
            claude task create --type="validation_gap_analysis" \
              --thinking-mode="think" \
              --identify-missing=true \
              --auto-trigger-missing=true \
              --priority-order=true
        }
      </incomplete-validation-handling>
    </claude-code-automated-consequences>
  </consequences>
</enforcement>

## Claude Code Integration Commands

<claude-code-validation-commands>
  <comprehensive-validation-commands>
    <command purpose="Start comprehensive validation workflow">
      claude /validate-comprehensive --target="{validation_target}" --thinking-mode="think hard" --parallel=true
    </command>

    <command purpose="Run parallel quality gates">
      claude task create --type="parallel_quality_gates" --dimensions="functional,technical,content,integration" --blocking=true
    </command>

    <command purpose="Execute external validation">
      @web-search validate_external --claims="{claims}" --github validate_repository --cross-reference=true
    </command>

    <command purpose="Monitor validation progress">
      claude /validation-status --workflow-id="{validation_id}" --detailed=true --real-time=true
    </command>

    <command purpose="Generate validation report">
      claude task create --type="validation_report" --thinking-mode="think" --comprehensive=true --format="executive"
    </command>
  </comprehensive-validation-commands>

  <automated-quality-gate-commands>
    <command purpose="Setup automated quality gates">
      claude /setup-quality-gates --dimensions="{quality_dimensions}" --thresholds="{quality_thresholds}" --auto-enforce=true
    </command>

    <command purpose="Run thinking mode escalation">
      claude /escalate-thinking --current-confidence="{confidence}" --complexity="{complexity}" --auto-select=true
    </command>

    <command purpose="Coordinate parallel validation">
      claude task create --type="parallel_validation_coordinator" --max-parallel=5 --thinking-mode="think hard"
    </command>

    <command purpose="Track validation metrics">
      @podcast-analytics record_validation_metrics --completion-rate="{rate}" --quality-scores="{scores}"
    </command>
  </automated-quality-gate-commands>
</claude-code-validation-commands>

<automated-validation-workflows>
  <complete-validation-pipeline>
    # End-to-end validation workflow
    run_complete_validation() {
        # Phase 1: Pre-validation setup
        claude task create --type="validation_setup" \
          --thinking-mode="think" \
          --scope-analysis=true \
          --resource-planning=true \
          --output="validation_plan.json"

        # Phase 2: Parallel validation execution
        claude task create --type="parallel_validation_orchestrator" \
          --thinking-mode="think hard" \
          --dimensions="functional,technical,content,integration,compliance" \
          --parallel=true \
          --output="parallel_validation_results.json"

        # Phase 3: External validation
        @web-search validate_claims_comprehensive \
          --extracted-claims="validation_plan.json" \
          --min-sources=3 \
          --output="external_validation.json"

        @github validate_repository_integration \
          --changes="current" \
          --check-standards=true \
          --output="repository_validation.json"

        # Phase 4: Validation aggregation
        claude task create --type="validation_aggregation" \
          --thinking-mode="think hard" \
          --inputs="parallel_validation_results.json,external_validation.json,repository_validation.json" \
          --confidence-calculation=true \
          --output="final_validation_report.json"

        # Phase 5: Quality gate decision
        claude task create --type="quality_gate_decision" \
          --thinking-mode="think" \
          --validation-report="final_validation_report.json" \
          --enforce-thresholds=true \
          --output="quality_gate_decision.json"
    }
  </complete-validation-pipeline>

  <continuous-validation-monitoring>
    # Continuous validation during active development
    monitor_continuous_validation() {
        while development_active; do
            # Real-time quality monitoring
            claude task create --type="real_time_quality_check" \
              --thinking-mode="default" \
              --current-state="{current_development_state}" \
              --alert-on-issues=true &

            # Periodic comprehensive validation
            if should_run_full_validation; then
                claude task create --type="periodic_full_validation" \
                  --thinking-mode="think hard" \
                  --comprehensive=true \
                  --comparison-baseline=true &
            fi

            # External validation monitoring
            @web-search monitor_claim_validity \
              --active-claims="{active_claims}" \
              --check-for-updates=true &

            sleep 300  # Check every 5 minutes
        done
    }
  </continuous-validation-monitoring>
</automated-validation-workflows>

## Remember

<core-principles>
  - Validation protects users from misinformation
  - Uncertainty is better than false confidence
  - Every claim needs evidence
  - When in doubt, research more
  - User trust depends on our validation
  - Automation accelerates validation without sacrificing thoroughness
  - Claude Code subagents enable comprehensive parallel validation
  - Thinking modes ensure appropriate validation depth for complexity
  - External validation through MCP provides real-world verification
</core-principles>

<final-reminder>
  Validation is not bureaucracy. It's professionalism.
  It's the difference between "I think" and "I know."
  Always validate. Always verify. Always be certain.

  <claude-code-validation-enhancement>
    Claude Code transforms validation from manual checklist to automated quality assurance:
    - Hooks enforce validation requirements automatically
    - Subagents provide comprehensive parallel validation across all dimensions
    - Thinking modes ensure appropriate analysis depth for validation complexity
    - MCP integration enables real-time external verification
    - Quality gates prevent progression without proper validation

    The principle remains unchanged: validate everything.
    The capability is transformed: validation is now comprehensive, parallel, and automated.
  </claude-code-validation-enhancement>
</final-reminder>

</document>
