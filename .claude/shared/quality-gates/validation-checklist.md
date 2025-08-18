# Comprehensive Validation Checklist


This validation checklist MUST be used for all operations.
No agent creation, command creation, file operation, or session
can proceed without completing appropriate validation checks.
Every operation must be validated before execution.
Every result must be verified after completion.
Quality is not optional - it's the foundation of trust.

## Validation categories
Master Validation Categories
Agent creation, modification, execution
Command creation, validation, execution
File creation, modification, validation
Session tracking, state management, cleanup
Cost tracking, alerts, budget compliance
Metrics validation, threshold compliance

## Agent operations validation
Agent Operations Validation
Pre-Flight Agent Validation
Requirements Validation
Agent Purpose Defined
grep -E "(purpose|specialization|role)" agent_config.json
Clear, specific purpose statement present
If missing, block creation until purpose defined
Use /agent-purpose-generator command to create purpose statement
Agent Specialization Verified
validate_specialization.py --agent-config agent_config.json
Specialization matches one of: research, script, audio, quality, data, development
If invalid specialization, reject with error message
Provide valid specialization options and examples
Dependencies Validated
check_agent_dependencies.py --requirements requirements.json
All required APIs, libraries, and configurations available
List missing dependencies and block creation
Install missing dependencies or provide mock configurations
Configuration Schema Compliance
jsonschema -i agent_config.json agent_schema.json
Configuration validates against defined schema
Display schema validation errors with specific field guidance
Auto-correct common errors or provide corrected template
Security Validation
API Key Security Check
scan_for_hardcoded_keys.py --config agent_config.json
No hardcoded API keys or sensitive data
Block creation and flag security violation
Move sensitive data to environment variables
Permission Scope Validation
validate_permissions.py --agent-id {agent_id} --requested-permissions {permissions}
Requested permissions match minimum required for agent function
Reject excessive permissions with explanation
Provide minimal required permissions configuration
Cost Impact Assessment
Cost Estimation Validation
estimate_agent_costs.py --agent-config agent_config.json --usage-pattern typical
Estimated costs within acceptable range ($0.10-$2.00 per execution)
Warn if costs exceed thresholds and require approval
Suggest optimization strategies or usage limits
Rate Limiting Configuration
validate_rate_limits.py --agent-config agent_config.json
Appropriate rate limits set for external API usage
Block if no rate limits configured for external APIs
Auto-configure conservative rate limits
Runtime Agent Validation
Execution Environment
Resource Availability Check
check_system_resources.py --memory-required {mem} --cpu-required {cpu}
Sufficient system resources available
Queue execution or scale down resource requirements
Wait for resources or use resource-optimized execution mode
External Service Health
ping_external_services.py --agent-id {agent_id}
All required external services responding within 5 seconds
Use fallback services or cached data
Retry with exponential backoff or graceful degradation
Input Validation
Input Data Schema Validation
validate_input_data.py --schema input_schema.json --data {input_data}
Input data conforms to expected schema and types
Reject invalid input with specific error messages
Data sanitization and type coercion where safe
Input Size Limits
check_input_size.py --data {input_data} --max-size {max_size_mb}
Input data within size limits (typically 10MB max)
Truncate or reject oversized input
Chunk large inputs or provide size reduction guidance
Real-time Monitoring
Execution Time Monitoring
Monitor execution time continuously during runtime
Execution completes within timeout (30 minutes max)
Terminate long-running executions gracefully
Save partial results and provide continuation options
Error Rate Monitoring
Track API errors and retry attempts in real-time
Error rate &lt; 5%, retry success rate > 80%
Escalate to fallback mechanisms
Switch to alternative service providers or cached responses
Post-Execution Agent Validation
Output Quality Validation
Output Schema Compliance
validate_output.py --schema output_schema.json --data {output_data}
Output matches expected structure and data types
Mark execution as failed and flag for review
Re-execute with corrected parameters or manual intervention
Content Quality Metrics
Apply quality gates from quality_gates.json
All quality thresholds met (comprehension ≥0.85, etc.)
Trigger quality improvement workflow
Re-execute with quality optimization flags
Completeness Verification
check_output_completeness.py --expected-fields {fields} --output {output_data}
All required output fields present and non-empty
Mark as incomplete and trigger re-execution
Partial result acceptance with flagging for later completion

## Command operations validation
Command Operations Validation
Command Creation Validation
Syntax Validation
Command Structure Validation
validate_command_syntax.py --command-file {command_file}
Valid command structure with required sections
Display syntax errors with line numbers
Provide command template and syntax examples
Parameter Schema Validation
validate_parameters.py --command-file {command_file}
All parameters have types, descriptions, and validation rules
List missing parameter specifications
Auto-generate parameter specifications from usage examples

## File operations validation
File Operations Validation
File Existence and Permissions
Pre-operation Validation
File Existence Check
test -f {file_path} for modifications, test -d {parent_dir} for creation
Target exists for modifications, parent directory exists for creation
Clear error messages about missing files or directories
Create parent directories or provide alternative paths
Permission Validation
test -r {file_path} for read, test -w {file_path} for write
Appropriate permissions available for intended operation
Permission denied with specific permission requirements
Permission adjustment commands or alternative approaches
File Lock Check
lsof {file_path} or platform-specific file lock detection
File not locked by other processes
Wait for lock release or identify locking process
Wait with timeout or provide override options
Size and Space Validation
Disk Space Check
df -h {target_directory} and compare with expected file size
Sufficient disk space for operation (at least 20% free space)
Insufficient space warning with cleanup suggestions
Cleanup procedures or alternative storage locations
File Size Limits
Check file size against system and application limits
File size within acceptable ranges (typically &lt; 100MB)
Size limit exceeded with compression suggestions
File compression, splitting, or alternative storage
Content Validation
Schema and Format Validation
File Format Validation
file {file_path} and format-specific validation tools
File format matches expected type (JSON, MD, TXT, etc.)
Format mismatch with conversion suggestions
Format conversion or alternative handling approaches
Content Schema Validation
JSON: jsonschema, YAML: yamllint, Markdown: markdownlint
Content validates against defined schema
Schema validation errors with specific line numbers
Auto-correction where safe or manual correction guidance

## Quality metrics validation
Quality Metrics Validation
Quality Threshold Compliance
Comprehension Quality (≥0.85)
Reading Ease Validation
calculate_flesch_reading_ease.py --text {content}
Flesch Reading Ease score 60-80 (target: 70)
Score outside range with readability improvement suggestions
Text simplification or complexity adjustment recommendations
Grade Level Check
calculate_flesch_kincaid.py --text {content}
Grade level 8-12 (target: 10)
Grade level outside target with adjustment guidance
Vocabulary and sentence structure modification suggestions
Sentence Length Analysis
analyze_sentence_length.py --text {content}
Average sentence length 15-25 words (target: 20)
Sentence length outside range with restructuring suggestions
Sentence splitting or combination recommendations
Brand Consistency Quality (≥0.90)
Intellectual Humility Validation
count_humility_phrases.py --text {content}
3-5 humility phrases per 1000 words (target: 5)
Insufficient humility phrases with addition suggestions
Humility phrase integration recommendations
Question Density Check
count_questions.py --text {content}
2-4 questions per 1000 words (target: 4)
Question density outside range with adjustment suggestions
Question integration or reduction recommendations
Avoided Terms Check
check_avoided_terms.py --text {content} --terms-list avoided_terms.json
Maximum 2 avoided terms, target 0
Avoided terms present with replacement suggestions
Term replacement recommendations
Engagement Quality (≥0.80)
Hook Effectiveness
analyze_hook_effectiveness.py --opening {opening_text}
Hook effectiveness score ≥0.75 (target: 0.90)
Low hook effectiveness with improvement suggestions
Hook strengthening recommendations and examples
Sentence Variety Analysis
analyze_sentence_variety.py --text {content}
Sentence variety score ≥0.70 (target: 0.85)
Low sentence variety with diversification suggestions
Sentence structure variation recommendations
Engagement Phrase Count
count_engagement_phrases.py --text {content}
5-8 engagement phrases present (target: 8)
Insufficient engagement phrases with addition suggestions
Engagement phrase integration recommendations
Technical Quality (≥0.85)
Duration Accuracy Check
validate_duration.py --script {script} --target-duration 27
Estimated duration within 2 minutes of 27-minute target
Duration outside tolerance with adjustment calculations
Script length modification recommendations
Structure Compliance Validation
validate_structure.py --script {script}
Introduction, main segments, conclusion, transitions all present
Missing structural elements with template guidance
Structure completion recommendations
Audio Quality Validation
validate_audio_settings.py --config {audio_config}
Clarity ≥0.90, consistent volume, natural pacing configured
Audio settings outside quality parameters
Audio configuration optimization suggestions

## Cost tracking validation
Cost Tracking Validation
Cost Limit Enforcement
Pre-execution Cost Validation
Budget Availability Check
check_budget.py --operation-type {type} --estimated-cost {cost}
Sufficient budget available for estimated operation cost
Budget exceeded warning with cost reduction options
Cost optimization suggestions or budget approval process
Cost Estimation Accuracy
validate_cost_estimate.py --operation {operation} --estimate {estimate}
Cost estimate within 10% of historical actuals
Estimate accuracy warning with revision suggestions
Revised estimation or contingency budget allocation
Real-time Cost Monitoring
Cost Accumulation Tracking
Monitor costs during operation execution
Actual costs tracking within 20% of estimates
Cost overrun alerts with intervention options
Operation termination or budget reallocation
Cost Threshold Alerts
Monitor against defined cost thresholds
No threshold violations or appropriate approvals obtained
Threshold violation with escalation procedures
Emergency stop or expedited approval process

## Automation suggestions
Automation Suggestions
Hook-based Automation
Pre-operation Hooks
#!/bin/bash
# .claude/hooks/pre-agent-creation.sh
echo "🔍 Running pre-agent validation..."
.claude/shared/quality-gates/validate_agent_pre_flight.py --config "$1"
if [ $? -ne 0 ]; then
echo "❌ Pre-agent validation failed"
exit 1
fi
Post-operation Hooks
#!/bin/bash
# .claude/hooks/post-operation-validation.sh
echo "✅ Running post-operation validation..."
.claude/shared/quality-gates/validate_operation_results.py --operation "$1" --results "$2"
Command-line Validation Tools
.claude/shared/quality-gates/quick-validate-agent.sh {agent_id}
Quick agent validation
.claude/shared/quality-gates/quick-validate-command.sh {command_file}
Quick command validation
.claude/shared/quality-gates/quick-quality-check.sh {content_file}
Quick quality check
.claude/shared/quality-gates/run-complete-validation.sh {operation_type} {target}
Complete validation suite

## Enforcement compliance
Enforcement and Compliance
Mandatory Validation Rules
No Operation Without Validation - Every agent creation must pass pre-flight validation
Quality Gate Compliance - All content must meet minimum quality thresholds
Cost Control Enforcement - All operations must have cost estimates validated
Documentation Requirements - All validation results must be documented
Automated Enforcement
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
echo "✅ Pre-commit validation passed"

## Usage instructions
Usage Instructions
Daily Operations

- 
        

- 
          Before starting any operation: Run appropriate validation checklist

- 
          During operation execution: Monitor validation status through real-time hooks

- 
          After operation completion: Verify operation results and generate validation report
Emergency Procedures

- 
            

- 
              Stop all operations immediately

- 
              Review validation logs

- 
              Implement fixes before resuming

- 
            

- 
              Immediate operation halt

- 
              Review cost tracking accuracy

- 
              Adjust budgets or optimize operations

- 
            

- 
              Quarantine problematic output

- 
              Run comprehensive quality analysis

- 
              Implement quality improvements

## Continuous improvement
Continuous Improvement
Validation Metrics Analysis
Track validation success rates over time
Identify most common validation failures
Measure validation process efficiency
Analyze cost-benefit of validation steps
Process Optimization
Streamline frequently used validation procedures
Automate routine validation tasks
Implement predictive validation based on patterns
Optimize validation performance and resource usage
Validation Evolution
Regular review and update of validation criteria
Integration of new validation techniques
Adaptation to changing project requirements
Incorporation of lessons learned from failures

## Core principles
Core Principles
Validation is protection, not obstruction
Every validation step serves a specific quality purpose
Automated validation enables consistent quality at scale
Comprehensive validation builds trust and reliability
Continuous improvement ensures validation stays relevant
This validation checklist is your quality assurance foundation.
Use it consistently, trust its guidance, and improve it continuously.
Quality is not accidental - it's the result of systematic validation.
**EVERY OPERATION. EVERY TIME. NO EXCEPTIONS.**
Enhancement Progress Report
File Reference Validation
Quality Standards

---

*Converted from XML to Markdown for elegant simplicity*
*Original: validation-checklist.xml*
*Conversion: Mon Aug 18 00:01:17 EDT 2025*
