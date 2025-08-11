<document type="control-requirements" version="1.0.0">
  <metadata>
    <created>2025-08-10</created>
    <purpose>Establish mandatory change control and approval workflows</purpose>
    <requires-approval>true</requires-approval>
    <validation-status>verified-2025</validation-status>
  </metadata>

  <critical-notice>
    <requirement level="MANDATORY">
      ANY modification to this project requires explicit user approval.
      AI systems MUST NOT make autonomous changes without consent.
    </requirement>
  </critical-notice>

# Change Approval Requirements

<change-control>
  <principle>
    Every change, no matter how small, requires a structured approval process
    to ensure quality, prevent hallucinations, and maintain user control.
  </principle>
</change-control>

## Mandatory Approval Workflow

<approval-workflow>
  <step number="1">
    <name>Change Request</name>
    <description>User explicitly requests a specific change</description>
    <ai-action>Acknowledge and clarify scope if needed</ai-action>
  </step>
  
  <step number="2">
    <name>Impact Assessment</name>
    <description>AI provides detailed analysis BEFORE implementation</description>
    <ai-action>
      - Identify benefits of the change
      - Identify risks and potential issues
      - Suggest alternative approaches
      - Provide rollback strategy
      - Estimate effort/complexity
    </ai-action>
  </step>
  
  <step number="3">
    <name>User Review</name>
    <description>User reviews assessment and decides</description>
    <options>
      - APPROVE: Proceed with implementation
      - MODIFY: Request different approach
      - REJECT: Cancel the change
      - DEFER: Postpone for more research
    </options>
  </step>
  
  <step number="4">
    <name>Implementation</name>
    <description>Only if approved, AI implements change</description>
    <requirements>
      - Follow TDD principles (test first)
      - Make atomic commits
      - Provide progress updates
    </requirements>
  </step>
  
  <step number="5">
    <name>Validation</name>
    <description>AI validates the implementation</description>
    <checks>
      - All tests pass
      - No regressions introduced
      - Documentation updated
      - Change achieves intended goal
    </checks>
  </step>
  
  <step number="6">
    <name>User Confirmation</name>
    <description>User confirms change is satisfactory</description>
    <final-check>User has final say on acceptance</final-check>
  </step>
</approval-workflow>

## Change Categories and Requirements

<change-categories>
  <category level="1" name="Critical">
    <description>Changes that affect core functionality</description>
    <examples>
      - Modifying agent logic
      - Changing quality thresholds
      - Altering cost limits
      - Updating approval workflows
    </examples>
    <requirements>
      - Detailed impact assessment
      - Alternative approaches required
      - Rollback plan mandatory
      - Testing required before deployment
    </requirements>
  </category>
  
  <category level="2" name="Significant">
    <description>Changes that affect user experience or output</description>
    <examples>
      - Updating documentation structure
      - Modifying prompts
      - Changing episode format
      - Adjusting workflows
    </examples>
    <requirements>
      - Impact assessment required
      - User approval needed
      - Testing recommended
    </requirements>
  </category>
  
  <category level="3" name="Minor">
    <description>Small improvements or fixes</description>
    <examples>
      - Fixing typos in documentation
      - Adding comments to code
      - Formatting improvements
      - Adding examples
    </examples>
    <requirements>
      - Brief explanation needed
      - User approval still required
      - Can be batched for efficiency
    </requirements>
  </category>
</change-categories>

## AI Assessment Template

<assessment-template>
  <section name="Change Summary">
    <field>What is being changed</field>
    <field>Why the change is needed</field>
    <field>Who/what is affected</field>
  </section>
  
  <section name="Benefits Analysis">
    <field>Primary benefits</field>
    <field>Secondary benefits</field>
    <field>Long-term advantages</field>
  </section>
  
  <section name="Risk Analysis">
    <field>Potential failures</field>
    <field>Side effects</field>
    <field>Dependencies affected</field>
    <field>Regression possibilities</field>
  </section>
  
  <section name="Alternatives">
    <field>Alternative approach 1</field>
    <field>Alternative approach 2</field>
    <field>Do-nothing option</field>
  </section>
  
  <section name="Implementation Plan">
    <field>Steps to implement</field>
    <field>Time estimate</field>
    <field>Testing approach</field>
    <field>Rollback procedure</field>
  </section>
</assessment-template>

## Special Requirements

<special-requirements>
  <code-changes>
    <requirement>ALL code must follow TDD principles</requirement>
    <requirement>Tests must be written BEFORE implementation</requirement>
    <requirement>No production code without failing test first</requirement>
  </code-changes>
  
  <documentation-changes>
    <requirement>Must maintain XML semantic structure</requirement>
    <requirement>Validation required for factual claims</requirement>
    <requirement>Version tracking in metadata</requirement>
  </documentation-changes>
  
  <configuration-changes>
    <requirement>Impact on existing functionality assessed</requirement>
    <requirement>Backward compatibility considered</requirement>
    <requirement>Migration path provided if breaking</requirement>
  </configuration-changes>
</special-requirements>

## Rejection and Rollback Procedures

<rollback-procedures>
  <scenario name="User Rejects Assessment">
    <action>AI acknowledges and asks for clarification</action>
    <action>AI can suggest modified approach</action>
    <action>No implementation occurs</action>
  </scenario>
  
  <scenario name="Implementation Fails">
    <action>AI immediately stops work</action>
    <action>AI reports failure details</action>
    <action>AI suggests remediation options</action>
    <action>User decides next steps</action>
  </scenario>
  
  <scenario name="User Requests Rollback">
    <action>AI explains rollback procedure</action>
    <action>AI implements rollback with user approval</action>
    <action>AI validates system state after rollback</action>
    <action>AI documents lessons learned</action>
  </scenario>
</rollback-procedures>

## Compliance and Audit

<compliance>
  <audit-trail>
    Every change must be documented with:
    - Timestamp of request
    - User approval record
    - AI assessment provided
    - Implementation details
    - Validation results
    - User confirmation
  </audit-trail>
  
  <traceability>
    All changes must be traceable through:
    - Git commit history
    - Documentation updates
    - Test additions/modifications
    - User approval records
  </traceability>
</compliance>

## Claude Code Automation Enhancements

<claude-code-automation>
  <hooks-integration>
    <pre-change-hooks>
      <hook name="pre-change-analysis">
        <purpose>Automatically trigger change impact assessment</purpose>
        <activation>Before any file modification or system change</activation>
        <actions>
          - Load project context and change history
          - Trigger thinking mode analysis based on change complexity
          - Delegate impact assessment to specialized subagent
          - Initialize change tracking in project memory
        </actions>
        <implementation>
          #!/bin/bash
          # .claude/hooks/pre-change-analysis.sh
          CHANGE_TYPE=$1
          CHANGE_SCOPE=$2
          
          # Determine thinking mode based on change impact
          if [[ $CHANGE_SCOPE == "critical" ]]; then
              THINKING_MODE="ultrathink"
          elif [[ $CHANGE_SCOPE == "significant" ]]; then
              THINKING_MODE="think hard"
          else
              THINKING_MODE="think"
          fi
          
          # Delegate to impact assessment subagent
          claude task create --type="change_impact_analysis" \
            --thinking-mode="$THINKING_MODE" \
            --context="$CHANGE_TYPE,$CHANGE_SCOPE" \
            --instructions="Analyze change impact with enhanced reasoning" \
            --success-criteria="Risk assessment, alternatives, rollback plan" \
            --output="change_impact_$(date +%s).json"
        </implementation>
      </hook>
      
      <hook name="github-change-tracking">
        <purpose>Automatically track changes in GitHub</purpose>
        <activation>When change approval workflow starts</activation>
        <mcp-integration>github</mcp-integration>
        <actions>
          - Create GitHub issue for change tracking
          - Add change to project board with appropriate labels
          - Set up automated status updates
          - Initialize approval checklist
        </actions>
        <implementation>
          @github create_issue "Change Request: $CHANGE_DESCRIPTION" \
            --template="change_approval_template" \
            --labels="change-request,requires-approval" \
            --assign="change-reviewer"
          
          @github add_to_project "Change Management" issue_number
        </implementation>
      </hook>
    </pre-change-hooks>
    
    <post-change-hooks>
      <hook name="change-validation">
        <purpose>Validate change implementation</purpose>
        <activation>After change implementation</activation>
        <subagent-delegation>validation_specialist</subagent-delegation>
        <actions>
          - Run automated tests and validations
          - Check for regressions
          - Validate documentation updates
          - Update change tracking status
        </actions>
      </hook>
      
      <hook name="lessons-learned-capture">
        <purpose>Capture insights from change process</purpose>
        <activation>After change completion</activation>
        <actions>
          - Analyze change process effectiveness
          - Extract lessons for future changes
          - Update change patterns in memory
          - Generate improvement recommendations
        </actions>
      </hook>
    </post-change-hooks>
  </hooks-integration>
  
  <thinking-mode-integration>
    <change-complexity-analysis>
      <basic-changes>
        <thinking-mode>Default</thinking-mode>
        <examples>Documentation updates, minor configuration changes</examples>
        <assessment-requirements>Basic impact review, simple alternatives</assessment-requirements>
      </basic-changes>
      
      <moderate-changes>
        <thinking-mode>/think</thinking-mode>
        <examples>Workflow modifications, prompt optimizations, feature additions</examples>
        <assessment-requirements>Enhanced analysis, multiple alternatives, risk assessment</assessment-requirements>
      </moderate-changes>
      
      <complex-changes>
        <thinking-mode>/think hard</thinking-mode>
        <examples>Agent redesign, system architecture changes, integration modifications</examples>
        <assessment-requirements>Deep analysis, comprehensive alternatives, detailed risk modeling</assessment-requirements>
      </complex-changes>
      
      <critical-changes>
        <thinking-mode>/ultrathink</thinking-mode>
        <examples>Core system changes, security modifications, data structure changes</examples>
        <assessment-requirements>Maximum analysis depth, extensive scenario modeling, comprehensive impact assessment</assessment-requirements>
      </critical-changes>
    </change-complexity-analysis>
    
    <automated-thinking-triggers>
      <trigger name="complexity-escalation">
        <condition>Change affects multiple components or systems</condition>
        <action>Automatically escalate to higher thinking mode</action>
        <implementation>
          # Automatic thinking mode escalation
          if complexity_score > 0.8:
              thinking_mode = "ultrathink"
          elif complexity_score > 0.6:
              thinking_mode = "think hard"
          elif complexity_score > 0.3:
              thinking_mode = "think"
          else:
              thinking_mode = "default"
        </implementation>
      </trigger>
    </automated-thinking-triggers>
  </thinking-mode-integration>
  
  <subagent-delegation-patterns>
    <impact-assessment-subagent>
      <specialization>Change impact analysis and risk assessment</specialization>
      <capabilities>
        - Multi-dimensional impact analysis
        - Risk probability and severity assessment
        - Alternative approach generation
        - Rollback plan development
      </capabilities>
      <task-template>
        SUBAGENT TASK: Change Impact Assessment
        SPECIALIZATION: Change Management and Risk Analysis
        THINKING MODE: [Auto-selected based on change complexity]
        
        CONTEXT: Analyze impact of proposed change: {change_description}
        
        INSTRUCTIONS:
        1. IMPACT ANALYSIS:
           - Identify all affected components and systems
           - Assess direct and indirect consequences
           - Evaluate stakeholder impact
           - Calculate complexity and effort scores
        
        2. RISK ASSESSMENT:
           - Identify potential failure modes
           - Assess probability and severity of risks
           - Evaluate mitigation strategies
           - Create risk matrix and scoring
        
        3. ALTERNATIVE ANALYSIS:
           - Generate 3+ alternative approaches
           - Compare approaches across key dimensions
           - Recommend optimal approach with justification
           - Identify hybrid or phased implementation options
        
        4. ROLLBACK PLANNING:
           - Design comprehensive rollback procedures
           - Identify rollback triggers and criteria
           - Plan rollback testing and validation
           - Document rollback communication plan
        
        SUCCESS CRITERIA:
        - Comprehensive impact analysis completed
        - Risk assessment with mitigation strategies
        - Alternative approaches evaluated and ranked
        - Detailed rollback plan created
        
        OUTPUT: change_impact_assessment.json
      </task-template>
    </impact-assessment-subagent>
    
    <change-validation-subagent>
      <specialization>Post-implementation change validation</specialization>
      <parallel-processing>Enabled for multi-component validation</parallel-processing>
      <task-template>
        SUBAGENT TASK: Change Implementation Validation
        SPECIALIZATION: Quality Assurance and Change Verification
        PARALLEL PROCESSING: Enabled
        
        CONTEXT: Validate implemented change meets requirements and standards
        
        PARALLEL VALIDATION TASKS:
        1. Functional validation - Verify intended functionality works
        2. Regression testing - Ensure no unintended side effects
        3. Documentation validation - Confirm documentation accuracy
        4. Performance validation - Check performance impact
        5. Security validation - Verify security requirements met
        
        AGGREGATION CRITERIA:
        - All parallel validations must pass
        - No critical issues identified
        - Documentation complete and accurate
        - Performance within acceptable thresholds
        
        OUTPUT: change_validation_report.json
      </task-template>
    </change-validation-subagent>
  </subagent-delegation-patterns>
  
  <mcp-integration>
    <github-change-management>
      <server>github</server>
      <capabilities>
        - Automated issue creation for change requests
        - Change approval workflow management
        - Progress tracking and status updates
        - Change history and audit trail
      </capabilities>
      <automated-workflows>
        # Create change request issue
        @github create_issue "Change Request: {title}" \
          --body="{change_description}" \
          --template="change_request" \
          --labels="change-request,requires-approval,{priority}" \
          --milestone="{target_milestone}"
        
        # Update change status throughout approval process
        @github update_issue_status {issue_number} \
          --status="{current_phase}" \
          --add-comment="{phase_completion_summary}"
        
        # Track change implementation
        @github add_issue_comment {issue_number} \
          --comment="Implementation started: {implementation_details}"
      </automated-workflows>
    </github-change-management>
    
    <web-search-validation>
      <server>web-search</server>
      <purpose>Validate change approaches against current best practices</purpose>
      <automated-research>
        # Research current best practices for proposed change
        @web-search query "{change_type} best practices 2025" \
          --max-results=5 \
          --output="best_practices_research.json"
        
        # Validate change approach against industry standards
        @web-search validate_approach "{change_description}" \
          --cross-reference=3 \
          --output="approach_validation.json"
      </automated-research>
    </web-search-validation>
  </mcp-integration>
</claude-code-automation>

## Emergency Procedures

<emergency-procedures>
  <urgent-fix>
    Even urgent fixes require:
    1. User acknowledgment of urgency
    2. Abbreviated but present assessment
    3. Implementation with careful monitoring
    4. Full documentation afterward
    
    <claude-code-emergency-automation>
      <emergency-hooks>
        # Emergency change tracking
        @github create_issue "URGENT: {emergency_description}" \
          --labels="emergency,urgent-fix,requires-immediate-attention" \
          --priority="critical"
        
        # Accelerated impact assessment
        claude task create --type="emergency_impact_analysis" \
          --thinking-mode="think hard" \
          --context="{emergency_context}" \
          --instructions="Rapid but thorough emergency impact analysis" \
          --timeout="15min" \
          --output="emergency_impact.json"
      </emergency-hooks>
    </claude-code-emergency-automation>
  </urgent-fix>
  
  <system-compromise>
    If system integrity compromised:
    1. Immediately notify user
    2. Stop all operations
    3. Provide recovery options
    4. Wait for user direction
    
    <claude-code-compromise-automation>
      <automated-alerts>
        # GitHub emergency notification
        @github create_issue "SYSTEM COMPROMISE DETECTED" \
          --labels="security,emergency,system-compromise" \
          --assign="security-team" \
          --priority="critical"
        
        # System analysis subagent
        claude task create --type="security_analysis" \
          --thinking-mode="ultrathink" \
          --instructions="Analyze system compromise and recovery options" \
          --urgent=true \
          --output="security_analysis.json"
      </automated-alerts>
    </claude-code-compromise-automation>
  </system-compromise>
</emergency-procedures>

## Claude Code Integration Commands

<claude-code-commands>
  <change-management-commands>
    <command purpose="Start change approval process">
      claude /start-change-approval --type="{change_type}" --scope="{change_scope}" --description="{change_description}"
    </command>
    
    <command purpose="Analyze change impact with thinking modes">
      claude /analyze-change-impact --thinking-mode="{auto_selected}" --change="{change_details}"
    </command>
    
    <command purpose="Track change in GitHub">
      @github create_change_request "{title}" --template="change_approval" --priority="{priority}"
    </command>
    
    <command purpose="Validate change implementation">
      claude task create --type="change_validation" --parallel=true --components="{affected_components}"
    </command>
    
    <command purpose="Generate rollback plan">
      claude /generate-rollback-plan --change="{change_id}" --thinking-mode="think hard"
    </command>
  </change-management-commands>
  
  <monitoring-commands>
    <command purpose="Monitor active changes">
      @github list_issues --label="change-request" --state="open" --format="dashboard"
    </command>
    
    <command purpose="Check change approval status">
      claude /check-change-status --change-id="{change_id}" --detailed=true
    </command>
    
    <command purpose="Review change history">
      @github get_change_history --timeframe="last-30-days" --format="summary"
    </command>
  </monitoring-commands>
</claude-code-commands>

<automated-enforcement>
  <hook-enforcement>
    # Pre-change hooks automatically enforce approval requirements
    pre_change_hook() {
        if ! user_approval_verified; then
            echo "❌ Change blocked: User approval required"
            exit 1
        fi
        
        if ! impact_assessment_complete; then
            echo "❌ Change blocked: Impact assessment incomplete"
            trigger_impact_assessment_subagent
            exit 1
        fi
    }
  </hook-enforcement>
  
  <quality-gates>
    # Automated quality gates using subagents
    validate_change_quality() {
        claude task create --type="quality_gate_validation" \
          --thinking-mode="think" \
          --success-criteria="All approval requirements met" \
          --blocking=true
    }
  </quality-gates>
</automated-enforcement>

## Remember

<key-principles>
  - User autonomy is paramount
  - No changes without consent
  - Transparency in all assessments
  - Quality over speed
  - When in doubt, ask the user
  - Automation enhances but never replaces human judgment
  - Claude Code features accelerate approval workflows while maintaining rigor
</key-principles>

<enforcement>
  This document establishes MANDATORY requirements.
  Any AI system working with this project MUST comply.
  Non-compliance should result in operation suspension.
  
  <claude-code-enforcement>
    - Hooks automatically enforce approval workflows
    - Subagents provide comprehensive impact assessments
    - MCP integration ensures external tracking and validation
    - Thinking modes guarantee appropriate analysis depth
    - Quality gates prevent unapproved changes from proceeding
  </claude-code-enforcement>
</enforcement>

</document>