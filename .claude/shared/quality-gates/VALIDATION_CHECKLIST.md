<document type="validation-checklist" version="1.0.0">
  <metadata>
    <created>2025-08-11</created>
    <purpose>Comprehensive validation checklist for all operations</purpose>
    <task-id>0.10</task-id>
    <requires-approval>true</requires-approval>
    <validation-status>comprehensive-2025</validation-status>
  </metadata>

  <critical-notice>
    <requirement level="MANDATORY">
      This validation checklist MUST be used for all operations.
      No agent creation, command creation, file operation, or session
      can proceed without completing appropriate validation checks.
    </requirement>
  </critical-notice>

# Comprehensive Validation Checklist

<validation-philosophy>
  <principle>
    Every operation must be validated before execution.
    Every result must be verified after completion.
    Quality is not optional - it's the foundation of trust.
  </principle>
</validation-philosophy>

## Master Validation Categories

<validation-categories>
  <category name="Agent Operations">Agent creation, modification, execution</category>
  <category name="Command Operations">Command creation, validation, execution</category>
  <category name="File Operations">File creation, modification, validation</category>
  <category name="Session Management">Session tracking, state management, cleanup</category>
  <category name="Cost Management">Cost tracking, alerts, budget compliance</category>
  <category name="Quality Assurance">Metrics validation, threshold compliance</category>
</validation-categories>

## AGENT OPERATIONS VALIDATION

<agent-validation>
  
  ### Pre-Flight Agent Validation
  
  <pre-flight-checklist>
    #### Requirements Validation
    - [ ] **Agent Purpose Defined**
      - **Test:** `grep -E "(purpose|specialization|role)" agent_config.json`
      - **Pass Criteria:** Clear, specific purpose statement present
      - **Error Handling:** If missing, block creation until purpose defined
      - **Recovery:** Use `/agent-purpose-generator` command to create purpose statement
    
    - [ ] **Agent Specialization Verified**
      - **Test:** `validate_specialization.py --agent-config agent_config.json`
      - **Pass Criteria:** Specialization matches one of: research, script, audio, quality, data, development
      - **Error Handling:** If invalid specialization, reject with error message
      - **Recovery:** Provide valid specialization options and examples
    
    - [ ] **Dependencies Validated**
      - **Test:** `check_agent_dependencies.py --requirements requirements.json`
      - **Pass Criteria:** All required APIs, libraries, and configurations available
      - **Error Handling:** List missing dependencies and block creation
      - **Recovery:** Install missing dependencies or provide mock configurations
    
    - [ ] **Configuration Schema Compliance**
      - **Test:** `jsonschema -i agent_config.json agent_schema.json`
      - **Pass Criteria:** Configuration validates against defined schema
      - **Error Handling:** Display schema validation errors with specific field guidance
      - **Recovery:** Auto-correct common errors or provide corrected template
    
    #### Security Validation
    - [ ] **API Key Security Check**
      - **Test:** `scan_for_hardcoded_keys.py --config agent_config.json`
      - **Pass Criteria:** No hardcoded API keys or sensitive data
      - **Error Handling:** Block creation and flag security violation
      - **Recovery:** Move sensitive data to environment variables
    
    - [ ] **Permission Scope Validation**
      - **Test:** `validate_permissions.py --agent-id {agent_id} --requested-permissions {permissions}`
      - **Pass Criteria:** Requested permissions match minimum required for agent function
      - **Error Handling:** Reject excessive permissions with explanation
      - **Recovery:** Provide minimal required permissions configuration
    
    #### Cost Impact Assessment
    - [ ] **Cost Estimation Validation**
      - **Test:** `estimate_agent_costs.py --agent-config agent_config.json --usage-pattern typical`
      - **Pass Criteria:** Estimated costs within acceptable range ($0.10-$2.00 per execution)
      - **Error Handling:** Warn if costs exceed thresholds and require approval
      - **Recovery:** Suggest optimization strategies or usage limits
    
    - [ ] **Rate Limiting Configuration**
      - **Test:** `validate_rate_limits.py --agent-config agent_config.json`
      - **Pass Criteria:** Appropriate rate limits set for external API usage
      - **Error Handling:** Block if no rate limits configured for external APIs
      - **Recovery:** Auto-configure conservative rate limits
  </pre-flight-checklist>
  
  ### Runtime Agent Validation
  
  <runtime-checklist>
    #### Execution Environment
    - [ ] **Resource Availability Check**
      - **Test:** `check_system_resources.py --memory-required {mem} --cpu-required {cpu}`
      - **Pass Criteria:** Sufficient system resources available
      - **Error Handling:** Queue execution or scale down resource requirements
      - **Recovery:** Wait for resources or use resource-optimized execution mode
    
    - [ ] **External Service Health**
      - **Test:** `ping_external_services.py --agent-id {agent_id}`
      - **Pass Criteria:** All required external services responding within 5 seconds
      - **Error Handling:** Use fallback services or cached data
      - **Recovery:** Retry with exponential backoff or graceful degradation
    
    #### Input Validation
    - [ ] **Input Data Schema Validation**
      - **Test:** `validate_input_data.py --schema input_schema.json --data {input_data}`
      - **Pass Criteria:** Input data conforms to expected schema and types
      - **Error Handling:** Reject invalid input with specific error messages
      - **Recovery:** Data sanitization and type coercion where safe
    
    - [ ] **Input Size Limits**
      - **Test:** `check_input_size.py --data {input_data} --max-size {max_size_mb}`
      - **Pass Criteria:** Input data within size limits (typically 10MB max)
      - **Error Handling:** Truncate or reject oversized input
      - **Recovery:** Chunk large inputs or provide size reduction guidance
    
    #### Real-time Monitoring
    - [ ] **Execution Time Monitoring**
      - **Test:** Monitor execution time continuously during runtime
      - **Pass Criteria:** Execution completes within timeout (30 minutes max)
      - **Error Handling:** Terminate long-running executions gracefully
      - **Recovery:** Save partial results and provide continuation options
    
    - [ ] **Error Rate Monitoring**
      - **Test:** Track API errors and retry attempts in real-time
      - **Pass Criteria:** Error rate < 5%, retry success rate > 80%
      - **Error Handling:** Escalate to fallback mechanisms
      - **Recovery:** Switch to alternative service providers or cached responses
  </runtime-checklist>
  
  ### Post-Execution Agent Validation
  
  <post-execution-checklist>
    #### Output Quality Validation
    - [ ] **Output Schema Compliance**
      - **Test:** `validate_output.py --schema output_schema.json --data {output_data}`
      - **Pass Criteria:** Output matches expected structure and data types
      - **Error Handling:** Mark execution as failed and flag for review
      - **Recovery:** Re-execute with corrected parameters or manual intervention
    
    - [ ] **Content Quality Metrics**
      - **Test:** Apply quality gates from `quality_gates.json`
      - **Pass Criteria:** All quality thresholds met (comprehension ≥0.85, etc.)
      - **Error Handling:** Trigger quality improvement workflow
      - **Recovery:** Re-execute with quality optimization flags
    
    - [ ] **Completeness Verification**
      - **Test:** `check_output_completeness.py --expected-fields {fields} --output {output_data}`
      - **Pass Criteria:** All required output fields present and non-empty
      - **Error Handling:** Mark as incomplete and trigger re-execution
      - **Recovery:** Partial result acceptance with flagging for later completion
    
    #### Performance Validation
    - [ ] **Execution Time Analysis**
      - **Test:** Compare actual execution time to baseline and targets
      - **Pass Criteria:** Execution time within 20% of baseline or < 5 minutes
      - **Error Handling:** Flag performance degradation
      - **Recovery:** Performance optimization recommendations
    
    - [ ] **Resource Usage Analysis**
      - **Test:** `analyze_resource_usage.py --execution-id {execution_id}`
      - **Pass Criteria:** Resource usage within expected ranges
      - **Error Handling:** Flag resource anomalies for investigation
      - **Recovery:** Resource optimization suggestions
    
    #### Cost Validation
    - [ ] **Actual Cost Verification**
      - **Test:** `calculate_execution_cost.py --execution-id {execution_id}`
      - **Pass Criteria:** Actual cost within 10% of estimated cost
      - **Error Handling:** Flag cost overruns and investigate causes
      - **Recovery:** Cost optimization recommendations for future executions
  </post-execution-checklist>
  
</agent-validation>

## COMMAND OPERATIONS VALIDATION

<command-validation>
  
  ### Command Creation Validation
  
  <creation-checklist>
    #### Syntax Validation
    - [ ] **Command Structure Validation**
      - **Test:** `validate_command_syntax.py --command-file {command_file}`
      - **Pass Criteria:** Valid command structure with required sections
      - **Error Handling:** Display syntax errors with line numbers
      - **Recovery:** Provide command template and syntax examples
    
    - [ ] **Parameter Schema Validation**
      - **Test:** `validate_parameters.py --command-file {command_file}`
      - **Pass Criteria:** All parameters have types, descriptions, and validation rules
      - **Error Handling:** List missing parameter specifications
      - **Recovery:** Auto-generate parameter specifications from usage examples
    
    #### Dependency Validation
    - [ ] **Agent Dependencies Check**
      - **Test:** `check_command_agents.py --command-file {command_file}`
      - **Pass Criteria:** All referenced agents exist and are accessible
      - **Error Handling:** List missing agent dependencies
      - **Recovery:** Provide agent creation guidance or alternative commands
    
    - [ ] **External Tool Dependencies**
      - **Test:** `check_external_tools.py --command-file {command_file}`
      - **Pass Criteria:** All external tools/APIs available and configured
      - **Error Handling:** List unavailable tools with setup instructions
      - **Recovery:** Provide mock implementations or alternative approaches
    
    #### Security Assessment
    - [ ] **Command Permissions Validation**
      - **Test:** `validate_command_permissions.py --command-file {command_file}`
      - **Pass Criteria:** Command requests only necessary permissions
      - **Error Handling:** Flag excessive permissions and require justification
      - **Recovery:** Provide minimal permission configuration
    
    - [ ] **Input Sanitization Check**
      - **Test:** `check_input_sanitization.py --command-file {command_file}`
      - **Pass Criteria:** All user inputs are properly sanitized and validated
      - **Error Handling:** Flag potential security vulnerabilities
      - **Recovery:** Add input sanitization and validation code
  </creation-checklist>
  
  ### Command Execution Validation
  
  <execution-checklist>
    #### Pre-execution Checks
    - [ ] **Parameter Validation**
      - **Test:** `validate_execution_params.py --command {command} --params {params}`
      - **Pass Criteria:** All required parameters present and valid
      - **Error Handling:** Display parameter errors and expected formats
      - **Recovery:** Provide parameter examples and default values
    
    - [ ] **Resource Requirements Check**
      - **Test:** `check_execution_requirements.py --command {command}`
      - **Pass Criteria:** All required resources available for execution
      - **Error Handling:** List missing resources and wait/queue options
      - **Recovery:** Queue execution or provide alternative resource configurations
    
    #### Execution Monitoring
    - [ ] **Progress Tracking**
      - **Test:** Monitor command execution stages and progress
      - **Pass Criteria:** Regular progress updates and stage completion confirmations
      - **Error Handling:** Detect stalled execution and provide intervention options
      - **Recovery:** Manual intervention points or automatic retry mechanisms
    
    - [ ] **Error Handling Validation**
      - **Test:** Monitor error conditions and recovery attempts
      - **Pass Criteria:** Errors handled gracefully with appropriate fallbacks
      - **Error Handling:** Log unhandled errors and escalate appropriately
      - **Recovery:** Provide manual override options or alternative approaches
  </execution-checklist>
  
  ### Command Success Validation
  
  <success-criteria-checklist>
    #### Output Validation
    - [ ] **Expected Output Format**
      - **Test:** `validate_command_output.py --expected {expected_format} --actual {actual_output}`
      - **Pass Criteria:** Output matches expected format and contains required data
      - **Error Handling:** Flag format mismatches and data deficiencies
      - **Recovery:** Output transformation or re-execution with corrections
    
    - [ ] **Success Criteria Verification**
      - **Test:** Apply command-specific success criteria from command definition
      - **Pass Criteria:** All defined success criteria met
      - **Error Handling:** List unmet criteria and provide remediation steps
      - **Recovery:** Partial success handling or criteria adjustment options
    
    #### Quality Gates
    - [ ] **Quality Metrics Application**
      - **Test:** Apply relevant quality gates based on command output type
      - **Pass Criteria:** Quality metrics meet or exceed defined thresholds
      - **Error Handling:** Quality improvement recommendations
      - **Recovery:** Re-execution with quality optimization parameters
  </success-criteria-checklist>
  
</command-validation>

## FILE OPERATIONS VALIDATION

<file-validation>
  
  ### File Existence and Permissions
  
  <existence-permissions-checklist>
    #### Pre-operation Validation
    - [ ] **File Existence Check**
      - **Test:** `test -f {file_path}` for modifications, `test -d {parent_dir}` for creation
      - **Pass Criteria:** Target exists for modifications, parent directory exists for creation
      - **Error Handling:** Clear error messages about missing files or directories
      - **Recovery:** Create parent directories or provide alternative paths
    
    - [ ] **Permission Validation**
      - **Test:** `test -r {file_path}` for read, `test -w {file_path}` for write
      - **Pass Criteria:** Appropriate permissions available for intended operation
      - **Error Handling:** Permission denied with specific permission requirements
      - **Recovery:** Permission adjustment commands or alternative approaches
    
    - [ ] **File Lock Check**
      - **Test:** `lsof {file_path}` or platform-specific file lock detection
      - **Pass Criteria:** File not locked by other processes
      - **Error Handling:** Wait for lock release or identify locking process
      - **Recovery:** Wait with timeout or provide override options
    
    #### Size and Space Validation
    - [ ] **Disk Space Check**
      - **Test:** `df -h {target_directory}` and compare with expected file size
      - **Pass Criteria:** Sufficient disk space for operation (at least 20% free space)
      - **Error Handling:** Insufficient space warning with cleanup suggestions
      - **Recovery:** Cleanup procedures or alternative storage locations
    
    - [ ] **File Size Limits**
      - **Test:** Check file size against system and application limits
      - **Pass Criteria:** File size within acceptable ranges (typically < 100MB)
      - **Error Handling:** Size limit exceeded with compression suggestions
      - **Recovery:** File compression, splitting, or alternative storage
  </existence-permissions-checklist>
  
  ### Content Validation
  
  <content-validation-checklist>
    #### Schema and Format Validation
    - [ ] **File Format Validation**
      - **Test:** `file {file_path}` and format-specific validation tools
      - **Pass Criteria:** File format matches expected type (JSON, MD, TXT, etc.)
      - **Error Handling:** Format mismatch with conversion suggestions
      - **Recovery:** Format conversion or alternative handling approaches
    
    - [ ] **Content Schema Validation**
      - **Test:** JSON: `jsonschema`, YAML: `yamllint`, Markdown: `markdownlint`
      - **Pass Criteria:** Content validates against defined schema
      - **Error Handling:** Schema validation errors with specific line numbers
      - **Recovery:** Auto-correction where safe or manual correction guidance
    
    #### Content Quality Validation
    - [ ] **Encoding Validation**
      - **Test:** `file -i {file_path}` to check character encoding
      - **Pass Criteria:** UTF-8 encoding or appropriate encoding for file type
      - **Error Handling:** Encoding issues with conversion suggestions
      - **Recovery:** Encoding conversion with backup preservation
    
    - [ ] **Content Completeness**
      - **Test:** Check for required sections, fields, or markers
      - **Pass Criteria:** All required content elements present
      - **Error Handling:** List missing required content elements
      - **Recovery:** Content completion templates or generation assistance
  </content-validation-checklist>
  
  ### Post-operation Validation
  
  <post-operation-checklist>
    #### Integrity Verification
    - [ ] **File Integrity Check**
      - **Test:** `md5sum {file_path}` or `shasum -a 256 {file_path}` and compare
      - **Pass Criteria:** File integrity maintained (for modifications) or file created successfully
      - **Error Handling:** Integrity check failure with backup restoration options
      - **Recovery:** Restore from backup or re-execute operation
    
    - [ ] **Content Validation Post-write**
      - **Test:** Re-read file and validate content matches intended changes
      - **Pass Criteria:** File content matches expected result
      - **Error Handling:** Content mismatch with diff analysis
      - **Recovery:** Repeat operation or manual correction
    
    #### Backup and Versioning
    - [ ] **Backup Verification**
      - **Test:** Verify backup creation for file modifications
      - **Pass Criteria:** Backup exists and contains previous file version
      - **Error Handling:** Backup creation failure warning
      - **Recovery:** Create manual backup or skip modification
  </post-operation-checklist>
  
</file-validation>

## SESSION MANAGEMENT VALIDATION

<session-validation>
  
  ### Session State Tracking
  
  <state-tracking-checklist>
    #### Session Initialization
    - [ ] **Session ID Validation**
      - **Test:** `validate_session_id.py --session-id {session_id}`
      - **Pass Criteria:** Unique, valid session ID generated or provided
      - **Error Handling:** Duplicate or invalid session ID rejection
      - **Recovery:** Generate new unique session ID
    
    - [ ] **Session Context Setup**
      - **Test:** `validate_session_context.py --context {session_context}`
      - **Pass Criteria:** Valid session context with required metadata
      - **Error Handling:** Missing context elements with setup guidance
      - **Recovery:** Initialize default context or guided context creation
    
    #### State Persistence
    - [ ] **Session Data Integrity**
      - **Test:** `check_session_data.py --session-id {session_id}`
      - **Pass Criteria:** Session data is complete and uncorrupted
      - **Error Handling:** Data corruption detection and recovery options
      - **Recovery:** Session data restoration from checkpoints
    
    - [ ] **State Consistency Check**
      - **Test:** Validate session state against expected state transitions
      - **Pass Criteria:** Session state is consistent and valid
      - **Error Handling:** State inconsistency with reset or correction options
      - **Recovery:** State synchronization or session restart
  </state-tracking-checklist>
  
  ### Session Metrics Tracking
  
  <metrics-tracking-checklist>
    #### Performance Metrics
    - [ ] **Execution Time Tracking**
      - **Test:** Monitor and validate session operation timing
      - **Pass Criteria:** Operations complete within expected time ranges
      - **Error Handling:** Performance degradation alerts
      - **Recovery:** Performance optimization suggestions
    
    - [ ] **Resource Usage Monitoring**
      - **Test:** `monitor_session_resources.py --session-id {session_id}`
      - **Pass Criteria:** Resource usage within normal operating parameters
      - **Error Handling:** Resource usage anomaly detection
      - **Recovery:** Resource optimization or scaling options
    
    #### Quality Metrics
    - [ ] **Success Rate Tracking**
      - **Test:** Calculate operation success rates for session
      - **Pass Criteria:** Success rate ≥ 90% for standard operations
      - **Error Handling:** Low success rate investigation and improvement
      - **Recovery:** Operation retry or alternative approaches
  </metrics-tracking-checklist>
  
  ### Session Cleanup Validation
  
  <cleanup-checklist>
    #### Resource Cleanup
    - [ ] **Temporary File Cleanup**
      - **Test:** `find_temp_files.py --session-id {session_id}`
      - **Pass Criteria:** All temporary files identified and cleaned up
      - **Error Handling:** Orphaned temporary files flagged for manual cleanup
      - **Recovery:** Automated cleanup or manual cleanup instructions
    
    - [ ] **Memory Release Verification**
      - **Test:** Monitor memory usage before and after session cleanup
      - **Pass Criteria:** Memory released within 5% of pre-session baseline
      - **Error Handling:** Memory leak detection and reporting
      - **Recovery:** Force memory release or system restart recommendations
    
    #### Data Archival
    - [ ] **Session Data Archival**
      - **Test:** Verify session data properly archived or disposed
      - **Pass Criteria:** Important data preserved, temporary data removed
      - **Error Handling:** Archival failure with retry options
      - **Recovery:** Manual archival or extended retention options
  </cleanup-checklist>
  
</session-validation>

## COST TRACKING VALIDATION

<cost-validation>
  
  ### Cost Limit Enforcement
  
  <limit-enforcement-checklist>
    #### Pre-execution Cost Validation
    - [ ] **Budget Availability Check**
      - **Test:** `check_budget.py --operation-type {type} --estimated-cost {cost}`
      - **Pass Criteria:** Sufficient budget available for estimated operation cost
      - **Error Handling:** Budget exceeded warning with cost reduction options
      - **Recovery:** Cost optimization suggestions or budget approval process
    
    - [ ] **Cost Estimation Accuracy**
      - **Test:** `validate_cost_estimate.py --operation {operation} --estimate {estimate}`
      - **Pass Criteria:** Cost estimate within 10% of historical actuals
      - **Error Handling:** Estimate accuracy warning with revision suggestions
      - **Recovery:** Revised estimation or contingency budget allocation
    
    #### Real-time Cost Monitoring
    - [ ] **Cost Accumulation Tracking**
      - **Test:** Monitor costs during operation execution
      - **Pass Criteria:** Actual costs tracking within 20% of estimates
      - **Error Handling:** Cost overrun alerts with intervention options
      - **Recovery:** Operation termination or budget reallocation
    
    - [ ] **Cost Threshold Alerts**
      - **Test:** Monitor against defined cost thresholds
      - **Pass Criteria:** No threshold violations or appropriate approvals obtained
      - **Error Handling:** Threshold violation with escalation procedures
      - **Recovery:** Emergency stop or expedited approval process
  </limit-enforcement-checklist>
  
  ### Cost Alert System
  
  <alert-system-checklist>
    #### Alert Configuration
    - [ ] **Alert Threshold Validation**
      - **Test:** `validate_cost_alerts.py --thresholds {alert_thresholds}`
      - **Pass Criteria:** Alert thresholds properly configured and reasonable
      - **Error Handling:** Invalid threshold configuration with correction guidance
      - **Recovery:** Default threshold application or guided configuration
    
    - [ ] **Alert Delivery Verification**
      - **Test:** `test_alert_delivery.py --alert-type cost_threshold`
      - **Pass Criteria:** Alerts delivered to correct recipients within 1 minute
      - **Error Handling:** Alert delivery failure with backup notification methods
      - **Recovery:** Alternative alert channels or manual notification
    
    #### Alert Response Validation
    - [ ] **Alert Acknowledgment**
      - **Test:** Verify alert acknowledgment and response procedures
      - **Pass Criteria:** Alerts acknowledged within defined timeframes
      - **Error Handling:** Unacknowledged alerts with escalation procedures
      - **Recovery:** Automated responses or escalation to higher authority
  </alert-system-checklist>
  
  ### Cost Aggregation and Reporting
  
  <aggregation-reporting-checklist>
    #### Cost Data Aggregation
    - [ ] **Cost Data Completeness**
      - **Test:** `validate_cost_data.py --time-period {period}`
      - **Pass Criteria:** All cost data captured and categorized correctly
      - **Error Handling:** Missing cost data identification and recovery
      - **Recovery:** Cost data reconstruction or estimation procedures
    
    - [ ] **Cost Categorization Accuracy**
      - **Test:** `validate_cost_categories.py --cost-data {cost_data}`
      - **Pass Criteria:** Costs properly categorized by operation, agent, and resource type
      - **Error Handling:** Miscategorized costs with correction procedures
      - **Recovery:** Cost recategorization or manual correction
    
    #### Reporting Validation
    - [ ] **Report Accuracy Verification**
      - **Test:** `validate_cost_reports.py --report {cost_report}`
      - **Pass Criteria:** Report data matches source cost data within 1%
      - **Error Handling:** Report accuracy issues with regeneration options
      - **Recovery:** Report regeneration or manual verification
  </aggregation-reporting-checklist>
  
</cost-validation>

## QUALITY METRICS VALIDATION

<quality-metrics-validation>
  
  ### Quality Threshold Compliance
  
  <threshold-compliance-checklist>
    #### Comprehension Quality (≥0.85)
    - [ ] **Reading Ease Validation**
      - **Test:** `calculate_flesch_reading_ease.py --text {content}`
      - **Pass Criteria:** Flesch Reading Ease score 60-80 (target: 70)
      - **Error Handling:** Score outside range with readability improvement suggestions
      - **Recovery:** Text simplification or complexity adjustment recommendations
    
    - [ ] **Grade Level Check**
      - **Test:** `calculate_flesch_kincaid.py --text {content}`
      - **Pass Criteria:** Grade level 8-12 (target: 10)
      - **Error Handling:** Grade level outside target with adjustment guidance
      - **Recovery:** Vocabulary and sentence structure modification suggestions
    
    - [ ] **Sentence Length Analysis**
      - **Test:** `analyze_sentence_length.py --text {content}`
      - **Pass Criteria:** Average sentence length 15-25 words (target: 20)
      - **Error Handling:** Sentence length outside range with restructuring suggestions
      - **Recovery:** Sentence splitting or combination recommendations
    
    #### Brand Consistency Quality (≥0.90)
    - [ ] **Intellectual Humility Validation**
      - **Test:** `count_humility_phrases.py --text {content}`
      - **Pass Criteria:** 3-5 humility phrases per 1000 words (target: 5)
      - **Error Handling:** Insufficient humility phrases with addition suggestions
      - **Recovery:** Humility phrase integration recommendations
    
    - [ ] **Question Density Check**
      - **Test:** `count_questions.py --text {content}`
      - **Pass Criteria:** 2-4 questions per 1000 words (target: 4)
      - **Error Handling:** Question density outside range with adjustment suggestions
      - **Recovery:** Question integration or reduction recommendations
    
    - [ ] **Avoided Terms Check**
      - **Test:** `check_avoided_terms.py --text {content} --terms-list avoided_terms.json`
      - **Pass Criteria:** Maximum 2 avoided terms, target 0
      - **Error Handling:** Avoided terms present with replacement suggestions
      - **Recovery:** Term replacement recommendations
    
    #### Engagement Quality (≥0.80)
    - [ ] **Hook Effectiveness**
      - **Test:** `analyze_hook_effectiveness.py --opening {opening_text}`
      - **Pass Criteria:** Hook effectiveness score ≥0.75 (target: 0.90)
      - **Error Handling:** Low hook effectiveness with improvement suggestions
      - **Recovery:** Hook strengthening recommendations and examples
    
    - [ ] **Sentence Variety Analysis**
      - **Test:** `analyze_sentence_variety.py --text {content}`
      - **Pass Criteria:** Sentence variety score ≥0.70 (target: 0.85)
      - **Error Handling:** Low sentence variety with diversification suggestions
      - **Recovery:** Sentence structure variation recommendations
    
    - [ ] **Engagement Phrase Count**
      - **Test:** `count_engagement_phrases.py --text {content}`
      - **Pass Criteria:** 5-8 engagement phrases present (target: 8)
      - **Error Handling:** Insufficient engagement phrases with addition suggestions
      - **Recovery:** Engagement phrase integration recommendations
    
    #### Technical Quality (≥0.85)
    - [ ] **Duration Accuracy Check**
      - **Test:** `validate_duration.py --script {script} --target-duration 27`
      - **Pass Criteria:** Estimated duration within 2 minutes of 27-minute target
      - **Error Handling:** Duration outside tolerance with adjustment calculations
      - **Recovery:** Script length modification recommendations
    
    - [ ] **Structure Compliance Validation**
      - **Test:** `validate_structure.py --script {script}`
      - **Pass Criteria:** Introduction, main segments, conclusion, transitions all present
      - **Error Handling:** Missing structural elements with template guidance
      - **Recovery:** Structure completion recommendations
    
    - [ ] **Audio Quality Validation**
      - **Test:** `validate_audio_settings.py --config {audio_config}`
      - **Pass Criteria:** Clarity ≥0.90, consistent volume, natural pacing configured
      - **Error Handling:** Audio settings outside quality parameters
      - **Recovery:** Audio configuration optimization suggestions
  </threshold-compliance-checklist>
  
  ### Quality Measurement Validation
  
  <measurement-validation-checklist>
    #### Metric Calculation Accuracy
    - [ ] **Quality Score Calculation**
      - **Test:** `validate_quality_calculations.py --metrics {metrics_data}`
      - **Pass Criteria:** Quality scores calculated correctly with proper weightings
      - **Error Handling:** Calculation errors with correction procedures
      - **Recovery:** Metric recalculation or manual verification
    
    - [ ] **Threshold Application**
      - **Test:** `validate_threshold_application.py --scores {quality_scores}`
      - **Pass Criteria:** Thresholds applied correctly with proper pass/fail determination
      - **Error Handling:** Threshold application errors with correction
      - **Recovery:** Manual threshold verification or recalculation
    
    #### Measurement Consistency
    - [ ] **Cross-validation Check**
      - **Test:** `cross_validate_metrics.py --content {content} --iterations 3`
      - **Pass Criteria:** Metric calculations consistent across multiple runs (variance <5%)
      - **Error Handling:** Inconsistent metrics with investigation procedures
      - **Recovery:** Metric stabilization or alternative calculation methods
  </measurement-validation-checklist>
  
  ### Quality Reporting Validation
  
  <reporting-validation-checklist>
    #### Report Generation
    - [ ] **Quality Report Completeness**
      - **Test:** `validate_quality_report.py --report {quality_report}`
      - **Pass Criteria:** All quality dimensions included with scores and recommendations
      - **Error Handling:** Incomplete reports with missing section identification
      - **Recovery:** Report regeneration or manual completion
    
    - [ ] **Recommendation Accuracy**
      - **Test:** `validate_recommendations.py --scores {scores} --recommendations {recommendations}`
      - **Pass Criteria:** Recommendations appropriate for identified quality issues
      - **Error Handling:** Inappropriate recommendations with correction suggestions
      - **Recovery:** Recommendation regeneration or manual correction
    
    #### Historical Tracking
    - [ ] **Improvement Tracking Validation**
      - **Test:** `validate_improvement_tracking.py --historical-data {data}`
      - **Pass Criteria:** Quality improvements tracked accurately over time
      - **Error Handling:** Tracking inconsistencies with data correction
      - **Recovery:** Data reconciliation or baseline reset procedures
  </reporting-validation-checklist>
  
</quality-metrics-validation>

## AUTOMATION SUGGESTIONS

<automation-suggestions>
  
  ### Hook-based Automation
  
  <hook-automation>
    #### Pre-operation Hooks
    ```bash
    # .claude/hooks/pre-agent-creation.sh
    #!/bin/bash
    echo "🔍 Running pre-agent validation..."
    .claude/shared/quality-gates/validate_agent_pre_flight.py --config "$1"
    if [ $? -ne 0 ]; then
        echo "❌ Pre-agent validation failed"
        exit 1
    fi
    ```
    
    #### Post-operation Hooks
    ```bash
    # .claude/hooks/post-operation-validation.sh
    #!/bin/bash
    echo "✅ Running post-operation validation..."
    .claude/shared/quality-gates/validate_operation_results.py --operation "$1" --results "$2"
    ```
    
    #### Real-time Monitoring Hooks
    ```bash
    # .claude/hooks/real-time-monitor.sh
    #!/bin/bash
    while [ -f /tmp/operation_active ]; do
        .claude/shared/quality-gates/monitor_operation.py --operation-id "$1"
        sleep 30
    done
    ```
  </hook-automation>
  
  ### Subagent Automation
  
  <subagent-automation>
    #### Parallel Validation Coordination
    ```yaml
    # Validation Subagent Configuration
    validation_coordinator:
      specialization: "Multi-dimensional validation orchestrator"
      thinking_mode: "think hard"
      parallel_processing: true
      tasks:
        - functional_validation
        - quality_validation
        - security_validation
        - performance_validation
      success_criteria:
        - all_validations_pass: true
        - confidence_threshold: 0.85
    ```
    
    #### Quality Gate Enforcement
    ```yaml
    quality_gate_enforcer:
      specialization: "Quality threshold enforcement"
      thinking_mode: "think"
      automated_actions:
        - threshold_checking
        - recommendation_generation
        - improvement_suggestions
      escalation_triggers:
        - critical_failure
        - repeated_failures
        - threshold_violations
    ```
  </subagent-automation>
  
  ### Command-line Validation Tools
  
  <validation-tools>
    #### Quick Validation Commands
    ```bash
    # Quick agent validation
    .claude/shared/quality-gates/quick-validate-agent.sh {agent_id}
    
    # Quick command validation
    .claude/shared/quality-gates/quick-validate-command.sh {command_file}
    
    # Quick quality check
    .claude/shared/quality-gates/quick-quality-check.sh {content_file}
    
    # Complete validation suite
    .claude/shared/quality-gates/run-complete-validation.sh {operation_type} {target}
    ```
    
    #### Validation Report Generation
    ```bash
    # Generate comprehensive validation report
    .claude/shared/quality-gates/generate-validation-report.sh {operation_id} {format}
    
    # Export validation metrics
    .claude/shared/quality-gates/export-validation-metrics.sh {time_period} {format}
    ```
  </validation-tools>
  
</automation-suggestions>

## VALIDATION SCRIPT EXAMPLES

<validation-scripts>
  
  ### Agent Validation Script
  
  <agent-validation-script>
    ```python
    #!/usr/bin/env python3
    # validate_agent_pre_flight.py
    
    import json
    import sys
    from pathlib import Path
    
    def validate_agent_config(config_path):
        """Comprehensive agent configuration validation."""
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
            
            # Required fields validation
            required_fields = ['agent_id', 'specialization', 'purpose', 'configuration']
            missing_fields = [field for field in required_fields if field not in config]
            if missing_fields:
                print(f"❌ Missing required fields: {missing_fields}")
                return False
            
            # Specialization validation
            valid_specializations = ['research', 'script', 'audio', 'quality', 'data', 'development']
            if config['specialization'] not in valid_specializations:
                print(f"❌ Invalid specialization. Must be one of: {valid_specializations}")
                return False
            
            # Purpose validation
            if len(config['purpose']) < 10:
                print("❌ Purpose must be at least 10 characters")
                return False
            
            # Configuration validation
            if 'max_retries' not in config['configuration']:
                config['configuration']['max_retries'] = 3
                print("ℹ️ Added default max_retries: 3")
            
            if 'timeout_seconds' not in config['configuration']:
                config['configuration']['timeout_seconds'] = 1800
                print("ℹ️ Added default timeout_seconds: 1800")
            
            # Security validation - check for hardcoded secrets
            config_str = json.dumps(config).lower()
            sensitive_patterns = ['api_key', 'secret', 'password', 'token']
            for pattern in sensitive_patterns:
                if pattern in config_str and 'env:' not in config_str:
                    print(f"❌ Potential hardcoded secret detected: {pattern}")
                    return False
            
            print("✅ Agent configuration validation passed")
            return True
            
        except json.JSONDecodeError as e:
            print(f"❌ Invalid JSON in config file: {e}")
            return False
        except Exception as e:
            print(f"❌ Validation error: {e}")
            return False
    
    if __name__ == "__main__":
        if len(sys.argv) != 2:
            print("Usage: validate_agent_pre_flight.py <config_path>")
            sys.exit(1)
        
        success = validate_agent_config(sys.argv[1])
        sys.exit(0 if success else 1)
    ```
  </agent-validation-script>
  
  ### Quality Validation Script
  
  <quality-validation-script>
    ```python
    #!/usr/bin/env python3
    # validate_quality_metrics.py
    
    import json
    import sys
    import re
    from textstat import flesch_reading_ease, flesch_kincaid_grade
    
    def validate_content_quality(content, quality_gates_path):
        """Validate content against quality gates."""
        try:
            with open(quality_gates_path, 'r') as f:
                gates = json.load(f)['quality_gates']
            
            results = {}
            
            # Comprehension validation
            comprehension = validate_comprehension(content, gates['comprehension'])
            results['comprehension'] = comprehension
            
            # Brand consistency validation
            brand = validate_brand_consistency(content, gates['brand_consistency'])
            results['brand_consistency'] = brand
            
            # Engagement validation
            engagement = validate_engagement(content, gates['engagement'])
            results['engagement'] = engagement
            
            # Calculate overall score
            overall_score = calculate_overall_score(results, gates)
            results['overall_score'] = overall_score
            
            # Check if passes minimum threshold
            min_threshold = gates.get('overall_requirements', {}).get('minimum_overall_score', 0.85)
            results['passes_threshold'] = overall_score >= min_threshold
            
            print(json.dumps(results, indent=2))
            
            return results['passes_threshold']
            
        except Exception as e:
            print(f"❌ Quality validation error: {e}")
            return False
    
    def validate_comprehension(content, gates):
        """Validate comprehension metrics."""
        flesch_ease = flesch_reading_ease(content)
        grade_level = flesch_kincaid_grade(content)
        avg_sentence_length = calculate_avg_sentence_length(content)
        
        metrics = gates['metrics']
        score = 0.0
        
        # Flesch Reading Ease (60-80, target 70)
        if metrics['flesch_reading_ease']['min'] <= flesch_ease <= metrics['flesch_reading_ease']['max']:
            ease_score = 1.0 - abs(flesch_ease - metrics['flesch_reading_ease']['target']) / 20
            score += ease_score * 0.4
        
        # Grade Level (8-12, target 10)
        if metrics['flesch_kincaid_grade']['min'] <= grade_level <= metrics['flesch_kincaid_grade']['max']:
            grade_score = 1.0 - abs(grade_level - metrics['flesch_kincaid_grade']['target']) / 4
            score += grade_score * 0.4
        
        # Sentence Length (15-25, target 20)
        if metrics['average_sentence_length']['min'] <= avg_sentence_length <= metrics['average_sentence_length']['max']:
            length_score = 1.0 - abs(avg_sentence_length - metrics['average_sentence_length']['target']) / 10
            score += length_score * 0.2
        
        return {
            'score': min(score, 1.0),
            'flesch_reading_ease': flesch_ease,
            'flesch_kincaid_grade': grade_level,
            'average_sentence_length': avg_sentence_length,
            'passes_threshold': score >= gates['threshold']
        }
    
    def validate_brand_consistency(content, gates):
        """Validate brand consistency metrics."""
        word_count = len(content.split())
        words_per_1000 = word_count / 1000
        
        # Count humility phrases
        humility_phrases = [
            r"we don't (fully )?know", r"it's unclear", r"remains uncertain",
            r"we're still learning", r"might be", r"could be", r"perhaps",
            r"it seems", r"appears to", r"suggests that"
        ]
        humility_count = sum(len(re.findall(pattern, content, re.IGNORECASE)) 
                           for pattern in humility_phrases)
        humility_per_1000 = humility_count / words_per_1000 if words_per_1000 > 0 else 0
        
        # Count questions
        question_count = len(re.findall(r'\?', content))
        questions_per_1000 = question_count / words_per_1000 if words_per_1000 > 0 else 0
        
        # Check avoided terms (implement based on your avoided terms list)
        avoided_count = 0  # Implement based on your specific terms
        
        metrics = gates['metrics']
        score = 0.0
        
        # Evaluate each metric
        if humility_per_1000 >= metrics['humility_phrases_per_1000_words']['min']:
            score += 0.4
        if questions_per_1000 >= metrics['questions_per_1000_words']['min']:
            score += 0.4
        if avoided_count <= metrics['avoided_terms_count']['max']:
            score += 0.2
        
        return {
            'score': min(score, 1.0),
            'humility_phrases_per_1000': humility_per_1000,
            'questions_per_1000': questions_per_1000,
            'avoided_terms_count': avoided_count,
            'passes_threshold': score >= gates['threshold']
        }
    
    def validate_engagement(content, gates):
        """Validate engagement metrics."""
        # Simplified engagement validation
        # In practice, you'd implement more sophisticated analysis
        
        # Hook effectiveness (simplified)
        hook_effectiveness = 0.8  # Placeholder
        
        # Sentence variety (simplified)
        sentences = re.split(r'[.!?]+', content)
        sentence_lengths = [len(s.split()) for s in sentences if s.strip()]
        if sentence_lengths:
            variety = 1.0 - (max(sentence_lengths) - min(sentence_lengths)) / max(sentence_lengths)
        else:
            variety = 0.0
        
        # Engagement phrases count
        engagement_phrases = [
            r"imagine", r"consider", r"think about", r"fascinating",
            r"remarkable", r"intriguing", r"surprising"
        ]
        engagement_count = sum(len(re.findall(pattern, content, re.IGNORECASE)) 
                             for pattern in engagement_phrases)
        
        metrics = gates['metrics']
        score = 0.0
        
        if hook_effectiveness >= metrics['hook_effectiveness']['min']:
            score += 0.4
        if variety >= metrics['sentence_variety']['min']:
            score += 0.4
        if engagement_count >= metrics['engagement_phrases_count']['min']:
            score += 0.2
        
        return {
            'score': min(score, 1.0),
            'hook_effectiveness': hook_effectiveness,
            'sentence_variety': variety,
            'engagement_phrases_count': engagement_count,
            'passes_threshold': score >= gates['threshold']
        }
    
    def calculate_avg_sentence_length(content):
        """Calculate average sentence length."""
        sentences = re.split(r'[.!?]+', content)
        sentence_lengths = [len(s.split()) for s in sentences if s.strip()]
        return sum(sentence_lengths) / len(sentence_lengths) if sentence_lengths else 0
    
    def calculate_overall_score(results, gates):
        """Calculate weighted overall score."""
        total_score = 0.0
        
        for dimension, result in results.items():
            if dimension in gates and 'score' in result:
                weight = gates[dimension]['weight']
                score = result['score']
                total_score += weight * score
        
        return total_score
    
    if __name__ == "__main__":
        if len(sys.argv) != 3:
            print("Usage: validate_quality_metrics.py <content_file> <quality_gates_file>")
            sys.exit(1)
        
        with open(sys.argv[1], 'r') as f:
            content = f.read()
        
        success = validate_content_quality(content, sys.argv[2])
        sys.exit(0 if success else 1)
    ```
  </quality-validation-script>
  
  ### Cost Validation Script
  
  <cost-validation-script>
    ```python
    #!/usr/bin/env python3
    # validate_cost_tracking.py
    
    import json
    import sys
    from datetime import datetime, timedelta
    from pathlib import Path
    
    def validate_cost_tracking(operation_type, estimated_cost, budget_file):
        """Validate cost tracking and budget compliance."""
        try:
            # Load budget configuration
            with open(budget_file, 'r') as f:
                budget = json.load(f)
            
            # Get operation limits
            operation_limits = budget.get('operation_limits', {})
            daily_limits = budget.get('daily_limits', {})
            monthly_limits = budget.get('monthly_limits', {})
            
            results = {
                'timestamp': datetime.now().isoformat(),
                'operation_type': operation_type,
                'estimated_cost': estimated_cost,
                'validations': {}
            }
            
            # Single operation limit check
            if operation_type in operation_limits:
                max_cost = operation_limits[operation_type]
                passes = estimated_cost <= max_cost
                results['validations']['operation_limit'] = {
                    'passes': passes,
                    'max_allowed': max_cost,
                    'estimated_cost': estimated_cost
                }
                if not passes:
                    print(f"❌ Operation cost ${estimated_cost:.2f} exceeds limit ${max_cost:.2f}")
                    return False
            
            # Daily limit check
            daily_usage = calculate_daily_usage()
            daily_limit = daily_limits.get('total', float('inf'))
            if daily_usage + estimated_cost > daily_limit:
                print(f"❌ Daily limit exceeded: ${daily_usage + estimated_cost:.2f} > ${daily_limit:.2f}")
                results['validations']['daily_limit'] = {
                    'passes': False,
                    'current_usage': daily_usage,
                    'estimated_additional': estimated_cost,
                    'daily_limit': daily_limit
                }
                return False
            
            # Monthly limit check
            monthly_usage = calculate_monthly_usage()
            monthly_limit = monthly_limits.get('total', float('inf'))
            if monthly_usage + estimated_cost > monthly_limit:
                print(f"❌ Monthly limit exceeded: ${monthly_usage + estimated_cost:.2f} > ${monthly_limit:.2f}")
                results['validations']['monthly_limit'] = {
                    'passes': False,
                    'current_usage': monthly_usage,
                    'estimated_additional': estimated_cost,
                    'monthly_limit': monthly_limit
                }
                return False
            
            # All validations passed
            results['validations']['operation_limit']['passes'] = True
            results['validations']['daily_limit'] = {
                'passes': True,
                'current_usage': daily_usage,
                'estimated_total': daily_usage + estimated_cost,
                'daily_limit': daily_limit
            }
            results['validations']['monthly_limit'] = {
                'passes': True,
                'current_usage': monthly_usage,
                'estimated_total': monthly_usage + estimated_cost,
                'monthly_limit': monthly_limit
            }
            
            print("✅ Cost validation passed")
            print(json.dumps(results, indent=2))
            return True
            
        except Exception as e:
            print(f"❌ Cost validation error: {e}")
            return False
    
    def calculate_daily_usage():
        """Calculate current daily cost usage."""
        # Implementation would read from cost tracking logs
        # Placeholder implementation
        today = datetime.now().strftime('%Y-%m-%d')
        cost_log_path = Path(f'logs/costs_{today}.json')
        
        if cost_log_path.exists():
            with open(cost_log_path, 'r') as f:
                costs = json.load(f)
            return sum(cost['amount'] for cost in costs.get('operations', []))
        
        return 0.0
    
    def calculate_monthly_usage():
        """Calculate current monthly cost usage."""
        # Implementation would read from monthly cost tracking
        # Placeholder implementation
        current_month = datetime.now().strftime('%Y-%m')
        cost_log_path = Path(f'logs/costs_{current_month}.json')
        
        if cost_log_path.exists():
            with open(cost_log_path, 'r') as f:
                costs = json.load(f)
            return costs.get('total_cost', 0.0)
        
        return 0.0
    
    if __name__ == "__main__":
        if len(sys.argv) != 4:
            print("Usage: validate_cost_tracking.py <operation_type> <estimated_cost> <budget_file>")
            sys.exit(1)
        
        operation_type = sys.argv[1]
        estimated_cost = float(sys.argv[2])
        budget_file = sys.argv[3]
        
        success = validate_cost_tracking(operation_type, estimated_cost, budget_file)
        sys.exit(0 if success else 1)
    ```
  </cost-validation-script>
  
</validation-scripts>

## CLAUDE CODE AUTOMATION INTEGRATION

<claude-code-integration>
  
  ### Automated Validation Commands
  
  <validation-commands>
    ```bash
    # Command: /validate-comprehensive
    # Purpose: Run comprehensive validation across all dimensions
    # Usage: /validate-comprehensive --target="{validation_target}" --thinking-mode="think hard"
    
    claude task create --type="comprehensive_validation" \
      --thinking-mode="think hard" \
      --parallel=true \
      --dimensions="agent,command,file,session,cost,quality" \
      --target="$1" \
      --blocking=true \
      --success-criteria="all_validations_pass" \
      --output="comprehensive_validation_report.json"
    ```
    
    ```bash
    # Command: /quality-gate-check
    # Purpose: Quick quality gate validation
    # Usage: /quality-gate-check --content="{content_file}"
    
    .claude/shared/quality-gates/validate_quality_metrics.py "$1" \
      projects/nobody-knows/config/quality_gates.json
    ```
    
    ```bash
    # Command: /validate-operation
    # Purpose: Validate specific operation before execution
    # Usage: /validate-operation --type="{operation_type}" --config="{config_file}"
    
    case "$1" in
        "agent")
            .claude/shared/quality-gates/validate_agent_pre_flight.py "$2"
            ;;
        "command")
            .claude/shared/quality-gates/validate_command.py "$2"
            ;;
        "cost")
            .claude/shared/quality-gates/validate_cost_tracking.py "$2" "$3" budget.json
            ;;
        *)
            echo "Unknown operation type: $1"
            exit 1
            ;;
    esac
    ```
  </validation-commands>
  
  ### Hook Integration Examples
  
  <hook-integration>
    ```bash
    # .claude/hooks/pre-agent-creation.sh
    #!/bin/bash
    echo "🔍 Pre-agent validation starting..."
    
    # Run comprehensive pre-flight validation
    .claude/shared/quality-gates/validate_agent_pre_flight.py "$1"
    if [ $? -ne 0 ]; then
        echo "❌ Agent pre-flight validation failed"
        echo "💡 Review agent configuration and fix issues before proceeding"
        exit 1
    fi
    
    # Check cost implications
    estimated_cost=$(python3 -c "import json; print(json.load(open('$1'))['estimated_cost'])" 2>/dev/null || echo "1.0")
    .claude/shared/quality-gates/validate_cost_tracking.py "agent_creation" "$estimated_cost" "budget.json"
    if [ $? -ne 0 ]; then
        echo "❌ Cost validation failed for agent creation"
        exit 1
    fi
    
    echo "✅ Pre-agent validation completed successfully"
    ```
    
    ```bash
    # .claude/hooks/post-operation-validation.sh
    #!/bin/bash
    echo "✅ Post-operation validation starting..."
    
    OPERATION_TYPE="$1"
    OPERATION_RESULTS="$2"
    
    # Validate operation results
    case "$OPERATION_TYPE" in
        "episode_production")
            # Quality gate validation for produced content
            if [ -f "$OPERATION_RESULTS" ]; then
                .claude/shared/quality-gates/validate_quality_metrics.py \
                    "$OPERATION_RESULTS" \
                    "projects/nobody-knows/config/quality_gates.json"
                
                if [ $? -ne 0 ]; then
                    echo "❌ Quality validation failed for episode"
                    echo "💡 Check quality report for improvement suggestions"
                    # Don't exit - allow manual review
                fi
            fi
            ;;
        *)
            echo "ℹ️ No specific post-validation for operation type: $OPERATION_TYPE"
            ;;
    esac
    
    echo "✅ Post-operation validation completed"
    ```
  </hook-integration>
  
  ### Subagent Task Templates
  
  <subagent-templates>
    ```yaml
    # Comprehensive Validation Coordinator Template
    task_template: |
      SUBAGENT TASK: Comprehensive Validation Coordinator
      SPECIALIZATION: Multi-dimensional validation orchestration
      THINKING MODE: think hard
      PARALLEL PROCESSING: Enabled for all validation dimensions
      
      CONTEXT: Coordinate comprehensive validation across all quality dimensions
      VALIDATION TARGET: {validation_target}
      VALIDATION SCOPE: {validation_scope}
      
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
         - Scalability assessment
      
      3. CONTENT QUALITY VALIDATION:
         - Quality metrics threshold compliance
         - Brand consistency verification
         - Engagement metrics validation
         - Technical quality standards
      
      4. OPERATIONAL VALIDATION:
         - Cost compliance verification
         - Resource usage validation
         - Performance benchmarks
         - Error handling verification
      
      5. PROCESS VALIDATION:
         - Workflow compliance verification
         - Documentation completeness
         - Approval requirements validation
         - Change control compliance
      
      VALIDATION COORDINATION:
      - Execute all validation dimensions in parallel
      - Aggregate results with confidence scoring
      - Generate comprehensive validation report
      - Provide specific remediation recommendations
      - Track validation completion and success rates
      
      SUCCESS CRITERIA:
      - All validation dimensions complete successfully
      - No critical issues identified
      - Overall confidence score ≥85%
      - Remediation plan provided for any issues
      - Validation report generated
      
      OUTPUT: comprehensive_validation_report.json
    ```
  </subagent-templates>
  
</claude-code-integration>

## ENFORCEMENT AND COMPLIANCE

<enforcement-compliance>
  
  ### Mandatory Validation Rules
  
  <mandatory-rules>
    1. **No Operation Without Validation**
       - Every agent creation must pass pre-flight validation
       - Every command execution must pass parameter validation
       - Every file operation must pass existence and permission validation
       - Every session must have validated state tracking
    
    2. **Quality Gate Compliance**
       - All content must meet minimum quality thresholds
       - Quality reports must be generated for all productions
       - Quality failures must trigger improvement workflows
    
    3. **Cost Control Enforcement**
       - All operations must have cost estimates validated
       - Cost limits must be enforced with automatic blocking
       - Cost tracking must be complete and accurate
    
    4. **Documentation Requirements**
       - All validation results must be documented
       - Validation failures must include remediation steps
       - Validation history must be maintained for analysis
  </mandatory-rules>
  
  ### Automated Enforcement
  
  <automated-enforcement>
    ```bash
    # Pre-commit hook for validation enforcement
    #!/bin/bash
    # .git/hooks/pre-commit
    
    echo "🔍 Running pre-commit validation..."
    
    # Check if any validation checklists have been updated
    if git diff --cached --name-only | grep -E "(validation|quality)" > /dev/null; then
        echo "📋 Validation configuration changes detected"
        
        # Validate the validation configuration itself
        .claude/shared/quality-gates/validate_validation_config.py
        if [ $? -ne 0 ]; then
            echo "❌ Validation configuration is invalid"
            exit 1
        fi
    fi
    
    # Run quick validation suite on changed files
    changed_files=$(git diff --cached --name-only)
    for file in $changed_files; do
        case "$file" in
            *.json)
                echo "📄 Validating JSON: $file"
                python3 -m json.tool "$file" > /dev/null
                if [ $? -ne 0 ]; then
                    echo "❌ Invalid JSON in $file"
                    exit 1
                fi
                ;;
            *.py)
                echo "🐍 Validating Python: $file"
                python3 -m py_compile "$file"
                if [ $? -ne 0 ]; then
                    echo "❌ Python syntax error in $file"
                    exit 1
                fi
                ;;
        esac
    done
    
    echo "✅ Pre-commit validation passed"
    ```
  </automated-enforcement>
  
</enforcement-compliance>

## USAGE INSTRUCTIONS

<usage-instructions>
  
  ### Daily Operations
  
  <daily-operations>
    1. **Before starting any operation:**
       ```bash
       # Run appropriate validation checklist
       .claude/shared/quality-gates/quick-validate-operation.sh {operation_type}
       ```
    
    2. **During operation execution:**
       - Monitor validation status through real-time hooks
       - Address validation failures immediately
       - Document any validation exceptions
    
    3. **After operation completion:**
       ```bash
       # Verify operation results
       .claude/shared/quality-gates/validate_operation_results.py {operation_id}
       
       # Generate validation report
       .claude/shared/quality-gates/generate-validation-report.sh {operation_id}
       ```
  </daily-operations>
  
  ### Weekly Reviews
  
  <weekly-reviews>
    - Review validation metrics and trends
    - Identify recurring validation failures
    - Update validation thresholds based on performance
    - Optimize validation processes for efficiency
  </weekly-reviews>
  
  ### Emergency Procedures
  
  <emergency-procedures>
    1. **Critical Validation Failure:**
       - Stop all operations immediately
       - Review validation logs
       - Implement fixes before resuming
    
    2. **Cost Limit Exceeded:**
       - Immediate operation halt
       - Review cost tracking accuracy
       - Adjust budgets or optimize operations
    
    3. **Quality Gate Failure:**
       - Quarantine problematic output
       - Run comprehensive quality analysis
       - Implement quality improvements
  </emergency-procedures>
  
</usage-instructions>

## CONTINUOUS IMPROVEMENT

<continuous-improvement>
  
  ### Validation Metrics Analysis
  
  <metrics-analysis>
    - Track validation success rates over time
    - Identify most common validation failures
    - Measure validation process efficiency
    - Analyze cost-benefit of validation steps
  </metrics-analysis>
  
  ### Process Optimization
  
  <process-optimization>
    - Streamline frequently used validation procedures
    - Automate routine validation tasks
    - Implement predictive validation based on patterns
    - Optimize validation performance and resource usage
  </process-optimization>
  
  ### Validation Evolution
  
  <validation-evolution>
    - Regular review and update of validation criteria
    - Integration of new validation techniques
    - Adaptation to changing project requirements
    - Incorporation of lessons learned from failures
  </validation-evolution>
  
</continuous-improvement>

## REMEMBER

<core-principles>
  - Validation is protection, not obstruction
  - Every validation step serves a specific quality purpose
  - Automated validation enables consistent quality at scale
  - Comprehensive validation builds trust and reliability
  - Continuous improvement ensures validation stays relevant
</core-principles>

<final-reminder>
  This validation checklist is your quality assurance foundation.
  Use it consistently, trust its guidance, and improve it continuously.
  Quality is not accidental - it's the result of systematic validation.
  
  **EVERY OPERATION. EVERY TIME. NO EXCEPTIONS.**
</final-reminder>

</document>