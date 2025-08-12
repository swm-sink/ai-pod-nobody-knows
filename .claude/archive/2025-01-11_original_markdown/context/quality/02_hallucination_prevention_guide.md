<document type="validation-requirements" version="1.0.0">
  <metadata>
    <created>2025-08-10</created>
    <purpose>Prevent AI hallucinations through mandatory validation</purpose>
    <requires-approval>true</requires-approval>
    <validation-status>researched-verified-2025</validation-status>
  </metadata>

  <critical-notice>
    <requirement level="MANDATORY">
      ALL factual claims MUST be validated through research.
      AI systems MUST acknowledge uncertainty rather than hallucinate.
    </requirement>
  </critical-notice>

# Hallucination Prevention Guide

<anti-hallucination-policy>
  <principle>
    Trust, but verify. Every claim must be backed by evidence.
    When uncertain, acknowledge it. Never fabricate information.
  </principle>
</anti-hallucination-policy>

## Core Prevention Strategies

<prevention-strategies>
  <strategy name="Retrieval-Augmented Generation">
    <description>Always reference trusted sources before generating content</description>
    <implementation>
      - Search for authoritative sources first
      - Extract relevant information
      - Generate based on retrieved facts
      - Cite sources in output
    </implementation>
    <effectiveness>Reduces hallucination by 75% per 2025 research</effectiveness>
  </strategy>

  <strategy name="Uncertainty Acknowledgment">
    <description>Explicitly allow and encourage "I don't know" responses</description>
    <implementation>
      - If confidence &lt; 80%, acknowledge uncertainty
      - Use phrases like "I'm not certain" or "I need to verify"
      - Request additional information when needed
      - Never guess or approximate when precision required
    </implementation>
    <effectiveness>Reduces false information by 40% per Anthropic</effectiveness>
  </strategy>

  <strategy name="Direct Quote Grounding">
    <description>For document-based tasks, extract exact quotes first</description>
    <implementation>
      - Find word-for-word quotes supporting claims
      - If no quote exists, retract the claim
      - Build responses from verified quotes
      - Mark inferences vs. direct information
    </implementation>
    <effectiveness>Critical for documents over 20K tokens</effectiveness>
  </strategy>
</prevention-strategies>

## Mandatory Validation Workflow

<validation-workflow>
  <step number="1">
    <name>Identify Claims</name>
    <action>Mark all statements that assert facts</action>
    <examples>
      - Statistics or numbers
      - Historical events
      - Technical specifications
      - Current states or conditions
      - Cause-effect relationships
    </examples>
  </step>

  <step number="2">
    <name>Research Validation</name>
    <requirements>
      <minimum-searches>3</minimum-searches>
      <maximum-searches>10</maximum-searches>
      <adaptive-rule>
        If conflicting information found, increase to 5+ searches
      </adaptive-rule>
    </requirements>
    <priority>
      - Prefer 2024-2025 sources
      - Official documentation first
      - Academic sources second
      - Community consensus third
    </priority>
  </step>

  <step number="3">
    <name>Cross-Reference</name>
    <action>Compare information across sources</action>
    <decision-tree>
      - All sources agree → High confidence
      - Majority agrees → Medium confidence, note dissent
      - Sources conflict → Low confidence, present alternatives
      - No sources found → Acknowledge uncertainty
    </decision-tree>
  </step>

  <step number="4">
    <name>Citation Required</name>
    <format>
      [Claim] (Source: URL, Date: YYYY-MM-DD)
    </format>
    <requirements>
      - Every factual claim needs citation
      - Include source URL
      - Include access date
      - Note confidence level
    </requirements>
  </step>

  <step number="5">
    <name>Confidence Disclosure</name>
    <levels>
      <high confidence="90-100%">Verified by multiple authoritative sources</high>
      <medium confidence="70-89%">Supported by some sources, minor variations</medium>
      <low confidence="50-69%">Limited sources, conflicting information</low>
      <uncertain confidence="&lt;50%">Cannot verify, acknowledging uncertainty</uncertain>
    </levels>
  </step>
</validation-workflow>

## Research Requirements by Category

<research-categories>
  <category name="Technical Specifications">
    <sources>Official documentation, GitHub repos, technical papers</sources>
    <minimum-validation>3 sources</minimum-validation>
    <recency-requirement>Within last 2 years</recency-requirement>
  </category>

  <category name="Statistics and Data">
    <sources>Primary sources, research papers, official reports</sources>
    <minimum-validation>2 primary sources</minimum-validation>
    <requirement>Must cite original study/source</requirement>
  </category>

  <category name="Best Practices">
    <sources>Industry standards, official guides, expert consensus</sources>
    <minimum-validation>3-5 sources</minimum-validation>
    <requirement>Note if practices vary by context</requirement>
  </category>

  <category name="Historical Information">
    <sources>Academic sources, verified databases, official records</sources>
    <minimum-validation>2 authoritative sources</minimum-validation>
    <requirement>Cross-check dates and details</requirement>
  </category>
</research-categories>

## Hallucination Red Flags

<red-flags>
  <flag name="Specific Numbers Without Source">
    <example>Stating "increases performance by 40%" without citation</example>
    <action>Always verify and cite specific metrics</action>
  </flag>

  <flag name="Absolute Statements">
    <example>Using "always," "never," "all," "none" without qualification</example>
    <action>Add nuance and acknowledge exceptions</action>
  </flag>

  <flag name="Future Predictions as Facts">
    <example>Stating what "will" happen vs. what "may" happen</example>
    <action>Use conditional language for predictions</action>
  </flag>

  <flag name="Fabricated Examples">
    <example>Creating code examples without testing</example>
    <action>Only provide tested or documented examples</action>
  </flag>

  <flag name="False Attribution">
    <example>Claiming someone said something without verification</example>
    <action>Only quote with verifiable sources</action>
  </flag>
</red-flags>

## Uncertainty Phrases to Use

<uncertainty-language>
  <high-uncertainty>
    - "I don't have reliable information about..."
    - "I cannot verify this claim..."
    - "I need to research this further..."
    - "This is outside my area of confidence..."
  </high-uncertainty>

  <medium-uncertainty>
    - "Based on limited information..."
    - "Sources suggest but don't confirm..."
    - "This appears to be the case, but..."
    - "Current understanding indicates..."
  </medium-uncertainty>

  <qualified-statements>
    - "According to [source]..."
    - "As of [date], the situation was..."
    - "In some contexts..."
    - "Generally speaking..."
  </qualified-statements>
</uncertainty-language>

## Validation Tools and Techniques

<validation-tools>
  <technique name="Multiple Search Queries">
    <description>Use varied search terms to find diverse sources</description>
    <example>
      Query 1: "fastapi testing best practices 2025"
      Query 2: "pytest fastapi TDD examples"
      Query 3: "test driven development REST API python"
    </example>
  </technique>

  <technique name="Source Evaluation">
    <criteria>
      - Authority: Is the source credible?
      - Recency: Is the information current?
      - Relevance: Does it apply to this context?
      - Consistency: Does it align with other sources?
    </criteria>
  </technique>

  <technique name="Fact Chain Verification">
    <description>Verify each link in a chain of reasoning</description>
    <process>
      1. Identify each claim in the reasoning
      2. Verify each claim independently
      3. Ensure logical connections are valid
      4. Document confidence at each step
    </process>
  </technique>
</validation-tools>

## Continuous Monitoring

<monitoring>
  <self-check>
    Before finalizing any response:
    1. Have I validated all factual claims?
    2. Have I cited sources appropriately?
    3. Have I acknowledged uncertainties?
    4. Have I avoided absolute statements?
    5. Have I checked for red flags?
  </self-check>

  <user-feedback>
    If user identifies potential hallucination:
    1. Thank user for correction
    2. Immediately research the claim
    3. Provide corrected information with sources
    4. Document the error for improvement
  </user-feedback>
</monitoring>

## Special Contexts

<special-contexts>
  <context name="Code Generation">
    <requirement>Never generate untested code patterns</requirement>
    <requirement>Always note if code is conceptual vs. tested</requirement>
    <requirement>Cite documentation for APIs and methods</requirement>
  </context>

  <context name="Cost Estimates">
    <requirement>Base on actual pricing documentation</requirement>
    <requirement>Include date of pricing information</requirement>
    <requirement>Note if prices may vary</requirement>
  </context>

  <context name="Performance Claims">
    <requirement>Cite benchmarks or studies</requirement>
    <requirement>Specify test conditions</requirement>
    <requirement>Acknowledge variability</requirement>
  </context>
</special-contexts>

## Claude Code Automation Enhancements

<claude-code-automation>
  <thinking-mode-escalation>
    <validation-thinking-modes>
      <basic-validation>
        <thinking-mode>Default</thinking-mode>
        <use-cases>Simple facts, well-established information</use-cases>
        <requirements>Single source verification, basic confidence check</requirements>
      </basic-validation>

      <enhanced-validation>
        <thinking-mode>/think</thinking-mode>
        <use-cases>Technical specifications, recent developments, contested topics</use-cases>
        <requirements>Multiple source verification, cross-reference analysis</requirements>
        <escalation-trigger>Conflicting information found OR confidence &lt; 80%</escalation-trigger>
      </enhanced-validation>

      <deep-validation>
        <thinking-mode>/think hard</thinking-mode>
        <use-cases>Complex scientific claims, controversial topics, critical decisions</use-cases>
        <requirements>Comprehensive source analysis, expert opinion integration</requirements>
        <escalation-trigger>Major contradictions OR confidence &lt; 70%</escalation-trigger>
      </deep-validation>

      <maximum-validation>
        <thinking-mode>/ultrathink</thinking-mode>
        <use-cases>Safety-critical information, legal claims, foundational assumptions</use-cases>
        <requirements>Exhaustive validation, multiple expert sources, chain-of-reasoning verification</requirements>
        <escalation-trigger>Safety implications OR confidence &lt; 60%</escalation-trigger>
      </maximum-validation>
    </validation-thinking-modes>

    <automated-escalation-rules>
      <rule name="confidence-based-escalation">
        if confidence &lt; 0.6:
            thinking_mode = "ultrathink"
        elif confidence &lt; 0.7:
            thinking_mode = "think hard"
        elif confidence &lt; 0.8:
            thinking_mode = "think"
        else:
            thinking_mode = "default"
      </rule>

      <rule name="claim-complexity-escalation">
        if claim_complexity == "safety_critical":
            thinking_mode = "ultrathink"
        elif claim_complexity == "high":
            thinking_mode = "think hard"
        elif claim_complexity == "medium":
            thinking_mode = "think"
      </rule>
    </automated-escalation-rules>
  </thinking-mode-escalation>

  <mcp-web-search-integration>
    <real-time-fact-checking>
      <server>web-search</server>
      <automated-validation-workflow>
        # Extract claims requiring validation
        extract_claims() {
            claude task create --type="claim_extraction" \
              --input="{content_to_validate}" \
              --instructions="Extract all factual claims requiring validation" \
              --output="extracted_claims.json"
        }

        # Validate each claim through web search
        validate_claims() {
            for claim in extracted_claims; do
                @web-search validate_claim "$claim" \
                  --min-sources=3 \
                  --cross-reference=true \
                  --confidence-threshold=0.8 \
                  --output="claim_validation_${claim_id}.json"
            done
        }

        # Aggregate validation results
        aggregate_validation() {
            claude task create --type="validation_aggregation" \
              --thinking-mode="think" \
              --input="claim_validation_*.json" \
              --instructions="Aggregate validation results and identify issues" \
              --output="validation_summary.json"
        }
      </automated-validation-workflow>
    </real-time-fact-checking>

    <source-credibility-analysis>
      <automated-source-verification>
        @web-search verify_source "{source_url}" \
          --check-authority=true \
          --check-recency=true \
          --check-bias=true \
          --output="source_credibility.json"

        @web-search cross_verify_claim "{claim}" \
          --exclude-source="{original_source}" \
          --min-alternative-sources=2 \
          --output="cross_verification.json"
      </automated-source-verification>
    </source-credibility-analysis>

    <trend-monitoring>
      <automated-topic-monitoring>
        # Set up monitoring for active research topics
        @web-search setup_topic_monitoring \
          --topics="{research_topics}" \
          --frequency="daily" \
          --alert-on-contradictions=true

        # Check for recent developments
        @web-search check_topic_updates \
          --topic="{specific_topic}" \
          --since="last-check" \
          --filter="peer-reviewed,authoritative"
      </automated-topic-monitoring>
    </trend-monitoring>
  </mcp-web-search-integration>

  <hooks-automation>
    <validation-hooks>
      <pre-content-generation-hook>
        <purpose>Validate research and sources before content generation</purpose>
        <activation>Before script generation or content creation</activation>
        <implementation>
          #!/bin/bash
          # .claude/hooks/pre-content-validation.sh
          RESEARCH_FILE=$1

          echo "🔍 Starting pre-content validation..."

          # Extract claims from research
          claude task create --type="claim_extraction" \
            --input="$RESEARCH_FILE" \
            --thinking-mode="think" \
            --output="research_claims.json"

          # Validate high-risk claims
          python3 .claude/scripts/validate_high_risk_claims.py "research_claims.json"

          # Check source credibility
          @web-search batch_verify_sources \
            --sources-file="$RESEARCH_FILE" \
            --output="source_validation.json"

          if ! validation_passed; then
              echo "❌ Content generation blocked: Validation failed"
              exit 1
          fi
        </implementation>
      </pre-content-generation-hook>

      <post-content-validation-hook>
        <purpose>Validate generated content for factual accuracy</purpose>
        <activation>After content generation</activation>
        <subagent-delegation>fact_checking_specialist</subagent-delegation>
        <implementation>
          # Delegate comprehensive fact-checking to specialist subagent
          claude task create --type="comprehensive_fact_check" \
            --specialization="fact_checking_expert" \
            --thinking-mode="think hard" \
            --input="{generated_content}" \
            --instructions="Verify all factual claims with multiple sources" \
            --success-criteria="95%+ claims validated, all uncertainties flagged" \
            --output="fact_check_report.json"
        </implementation>
      </post-content-validation-hook>

      <real-time-monitoring-hook>
        <purpose>Monitor content during generation for hallucination indicators</purpose>
        <activation>During content generation process</activation>
        <real-time-checks>
          - Absolute statement detection
          - Specific number verification
          - Source attribution validation
          - Confidence level monitoring
        </real-time-checks>
      </real-time-monitoring-hook>
    </validation-hooks>
  </hooks-automation>

  <subagent-multi-source-verification>
    <parallel-fact-checking>
      <fact-checking-specialist-subagent>
        <specialization>Multi-source fact verification and analysis</specialization>
        <parallel-processing>Enabled for claim verification</parallel-processing>
        <task-template>
          SUBAGENT TASK: Multi-Source Fact Verification
          SPECIALIZATION: Fact-Checking and Source Validation Expert
          THINKING MODE: [Auto-escalated based on claim complexity]
          PARALLEL PROCESSING: Enabled

          CONTEXT: Verify factual accuracy of claims using multiple independent sources
          CLAIMS TO VERIFY: {extracted_claims}

          PARALLEL VERIFICATION TASKS:
          1. Primary source validation - Verify against authoritative sources
          2. Cross-reference verification - Check claims against independent sources
          3. Temporal validation - Ensure information currency and relevance
          4. Expert consensus analysis - Check for scientific/expert agreement
          5. Contradiction detection - Identify conflicting information

          VERIFICATION STANDARDS:
          - Minimum 3 independent sources per claim
          - Authoritative sources prioritized
          - Recent information preferred (2024-2025)
          - Expert consensus weighted heavily
          - Uncertainties explicitly acknowledged

          SUCCESS CRITERIA:
          - Each claim verified or flagged for revision
          - Source credibility assessed and documented
          - Confidence levels assigned with justification
          - Contradictions identified and analyzed
          - Recommendations for claim modification provided

          OUTPUT: multi_source_verification_report.json
        </task-template>
      </fact-checking-specialist-subagent>

      <source-credibility-specialist>
        <specialization>Source authority and credibility analysis</specialization>
        <task-template>
          SUBAGENT TASK: Source Credibility Analysis
          SPECIALIZATION: Information Source Evaluation Expert
          THINKING MODE: think hard

          CONTEXT: Evaluate credibility and reliability of information sources
          SOURCES TO EVALUATE: {source_list}

          CREDIBILITY ANALYSIS FRAMEWORK:
          1. AUTHORITY ASSESSMENT:
             - Author expertise and credentials
             - Institution or publication reputation
             - Peer review status and process
             - Editorial oversight and standards

          2. RECENCY AND RELEVANCE:
             - Publication date and currency
             - Information update frequency
             - Relevance to current context
             - Superseding information existence

          3. BIAS AND OBJECTIVITY:
             - Funding sources and conflicts of interest
             - Editorial stance and perspective
             - Balance and fairness of presentation
             - Acknowledgment of limitations

          4. VERIFICATION STANDARDS:
             - Citation of primary sources
             - Methodology transparency
             - Replication and validation
             - Independent corroboration

          CREDIBILITY SCORING:
          - Assign numerical credibility scores (0-100)
          - Provide qualitative assessments
          - Identify red flags and concerns
          - Recommend usage guidelines

          OUTPUT: source_credibility_analysis.json
        </task-template>
      </source-credibility-specialist>
    </parallel-fact-checking>

    <uncertainty-analysis-subagent>
      <specialization>Uncertainty identification and intellectual humility integration</specialization>
      <task-template>
        SUBAGENT TASK: Uncertainty Analysis and Intellectual Humility
        SPECIALIZATION: Uncertainty Identification and Epistemological Analysis
        THINKING MODE: think hard

        CONTEXT: Identify areas of genuine uncertainty and integrate intellectual humility
        CONTENT: {content_to_analyze}

        UNCERTAINTY ANALYSIS:
        1. KNOWLEDGE BOUNDARIES:
           - Identify limits of current understanding
           - Distinguish between facts and theories
           - Recognize evolving knowledge areas
           - Highlight contested or debated topics

        2. CONFIDENCE GRADATIONS:
           - Assess confidence levels for different claims
           - Identify high vs. low confidence statements
           - Recommend appropriate hedging language
           - Suggest uncertainty acknowledgments

        3. INTELLECTUAL HUMILITY INTEGRATION:
           - Identify opportunities for "nobody knows" framing
           - Suggest curiosity-driven language
           - Recommend humble uncertainty expressions
           - Balance confidence with appropriate caution

        4. EPISTEMOLOGICAL ANALYSIS:
           - Evaluate strength of evidence for claims
           - Assess methodological limitations
           - Consider alternative interpretations
           - Identify areas needing more research

        OUTPUT: uncertainty_analysis_with_recommendations.json
      </task-template>
    </uncertainty-analysis-subagent>
  </subagent-multi-source-verification>
</claude-code-automation>

## Enforcement and Compliance

<enforcement>
  <mandatory-compliance>
    This guide represents MANDATORY requirements for AI systems.
    Failure to validate information should trigger:
    1. Immediate acknowledgment of uncertainty
    2. Research to validate claims
    3. Correction of any misinformation
    4. Documentation of the incident

    <claude-code-enforcement-automation>
      <automated-compliance-monitoring>
        # Real-time hallucination detection
        monitor_hallucination_indicators() {
            claude task create --type="hallucination_detection" \
              --real-time=true \
              --input="{content_stream}" \
              --alert-on="absolute_statements,unsourced_claims,specific_numbers" \
              --blocking=true
        }

        # Automated correction workflow
        trigger_correction_workflow() {
            @web-search validate_flagged_claim "$FLAGGED_CLAIM" \
              --urgent=true \
              --min-sources=5

            claude task create --type="claim_correction" \
              --thinking-mode="think hard" \
              --instructions="Correct misinformation with validated sources"
        }
      </automated-compliance-monitoring>
    </claude-code-enforcement-automation>
  </mandatory-compliance>

  <quality-metrics>
    Target metrics for compliance:
    - Hallucination rate: &lt; 5%
    - Citation rate: &gt; 95% for factual claims
    - Uncertainty acknowledgment: 100% when confidence &lt; 80%
    - Validation compliance: 100%

    <claude-code-metrics-automation>
      <automated-metrics-tracking>
        # Track validation metrics automatically
        @podcast-analytics track_validation_metrics \
          --episode="{episode_num}" \
          --metrics="hallucination_rate,citation_rate,uncertainty_acknowledgment" \
          --alert-thresholds="hallucination&gt;0.05,citation&lt;0.95"

        # Generate validation dashboard
        claude task create --type="validation_dashboard" \
          --thinking-mode="think" \
          --aggregation-period="weekly" \
          --output="validation_metrics_dashboard.json"
      </automated-metrics-tracking>
    </claude-code-metrics-automation>
  </quality-metrics>
</enforcement>

## Claude Code Integration Commands

<claude-code-validation-commands>
  <fact-checking-commands>
    <command purpose="Start comprehensive fact-checking">
      claude /fact-check --content="{content_path}" --thinking-mode="think hard" --min-sources=3
    </command>

    <command purpose="Validate specific claim with web search">
      @web-search validate_claim "{specific_claim}" --cross-reference=3 --output="claim_validation.json"
    </command>

    <command purpose="Check source credibility">
      @web-search verify_source "{source_url}" --comprehensive=true --output="source_analysis.json"
    </command>

    <command purpose="Monitor topic for new information">
      @web-search setup_monitoring --topic="{research_topic}" --frequency="weekly" --alert-on-changes=true
    </command>

    <command purpose="Extract claims from content">
      claude task create --type="claim_extraction" --input="{content}" --output="extracted_claims.json"
    </command>

    <command purpose="Analyze uncertainty levels">
      claude /analyze-uncertainty --content="{content}" --thinking-mode="think" --intellectual-humility=true
    </command>
  </fact-checking-commands>

  <validation-workflow-commands>
    <command purpose="Run parallel fact-checking">
      claude task create --type="parallel_fact_check" --parallel=true --max-parallel=5 --claims="{claim_list}"
    </command>

    <command purpose="Escalate validation thinking mode">
      claude /escalate-validation --current-confidence="{confidence}" --auto-select-thinking-mode=true
    </command>

    <command purpose="Generate validation report">
      claude task create --type="validation_report" --aggregation=true --format="comprehensive"
    </command>
  </validation-workflow-commands>
</claude-code-validation-commands>

<automated-validation-workflows>
  <research-validation-pipeline>
    # Complete research validation workflow
    validate_research_pipeline() {
        # 1. Extract claims
        claude task create --type="claim_extraction" \
          --input="research.json" \
          --output="claims.json"

        # 2. Parallel source verification
        claude task create --type="source_verification" \
          --parallel=true \
          --input="claims.json" \
          --thinking-mode="think" \
          --output="verified_sources.json"

        # 3. Cross-reference validation
        @web-search batch_validate \
          --claims-file="claims.json" \
          --min-sources-per-claim=3 \
          --output="web_validation.json"

        # 4. Uncertainty analysis
        claude task create --type="uncertainty_analysis" \
          --thinking-mode="think hard" \
          --input="verified_sources.json,web_validation.json" \
          --output="uncertainty_report.json"

        # 5. Final validation report
        claude task create --type="validation_aggregation" \
          --thinking-mode="think" \
          --inputs="claims.json,verified_sources.json,web_validation.json,uncertainty_report.json" \
          --output="final_validation_report.json"
    }
  </research-validation-pipeline>
</automated-validation-workflows>

## Remember

<key-principles>
  - Truth over completeness
  - Uncertainty over fabrication
  - Citations over assumptions
  - Validation over speculation
  - User trust is paramount
  - Automation accelerates but never replaces thorough validation
  - Claude Code thinking modes ensure appropriate analysis depth
  - Multiple validation sources provide confidence and accuracy
</key-principles>

<golden-rule>
  If you cannot verify it, do not assert it as fact.
  When in doubt, research more or acknowledge uncertainty.

  <claude-code-golden-rule-automation>
    # Automated uncertainty acknowledgment
    if confidence &lt; threshold:
        trigger_uncertainty_acknowledgment()
        escalate_thinking_mode()
        request_additional_validation()

    # Automated fact-checking requirement
    if contains_factual_claim(content):
        require_source_validation()
        enable_web_search_verification()
        delegate_to_fact_checking_subagent()
  </claude-code-golden-rule-automation>
</golden-rule>

</document>
