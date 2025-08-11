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

## Enforcement

<enforcement>
  <mandatory-rules>
    1. No claims without validation
    2. No validation without documentation
    3. No high confidence without multiple sources
    4. No implementation without validated approach
    5. No commit without validation complete
  </mandatory-rules>
  
  <consequences>
    - Unvalidated claim → Must acknowledge uncertainty
    - Failed validation → Cannot proceed with change
    - Incomplete validation → Block until complete
    - False validation → Immediate correction required
  </consequences>
</enforcement>

## Remember

<core-principles>
  - Validation protects users from misinformation
  - Uncertainty is better than false confidence
  - Every claim needs evidence
  - When in doubt, research more
  - User trust depends on our validation
</core-principles>

<final-reminder>
  Validation is not bureaucracy. It's professionalism.
  It's the difference between "I think" and "I know."
  Always validate. Always verify. Always be certain.
</final-reminder>

</document>