# Workflow Template - Standard Structure for Process Documentation


Comprehensive template for documenting workflows with mermaid diagrams, decision points,
quality gates, automation hooks, and troubleshooting guides for reliable process execution.
document type="workflow" version="3.1.0" enhanced="2025-08-13"
2-3 sentence overview of what this workflow accomplishes and when it's used
Primary goal of this workflow
Event or condition that starts this workflow
Alternative trigger
Expected result 1
Expected result 2
Required setup or configuration
Required tools or access
Required knowledge or skills
@[required-file].md exists
@[required-command].md available
[External service] configured
Format and source
Format and source
graph TD
A[Start] --> B{Validation}
B -->|Valid| C[Step 1]
B -->|Invalid| D[Error Handler]
C --> E[Step 2]
E --> F{Quality Check}
F -->|Pass| G[Step 3]
F -->|Fail| H[Remediation]
H --> E
G --> I[Complete]
D --> J[Log &amp; Alert]

- 
          
Validate Prerequisites
/validate-environment
All checks return green
Stop and address missing requirements

- 
          
Load Configuration
/load-config [workflow-name]
Config loaded successfully
Check config file exists and is valid

- 
          
Primary processing action
/[main-command] [arguments]
X-Y minutes
How to verify success
Recovery procedure

- 
          
Secondary processing action
/[secondary-command] [arguments]
X-Y minutes
How to verify success
Recovery procedure

- 
          
Run Quality Checks
/quality-check [output]
Metric 1 ≥ threshold
Metric 2 ≥ threshold
Return to Step 3 with adjustments

- 
          
Generate Output
/generate-output [format]
Where output is saved
Output file exists and is valid

- 
          
Update Tracking
/update-session [workflow-id]
Record time, cost, quality scores
Quality score &lt; threshold
Adjust parameters and reprocess
3
Alert human for manual review
Send to Slack/email
Document known issues and proceed
Explicit approval required
Step that could be automated
Another manual step
Validate all inputs
@hooks/validate-inputs.sh
Archive outputs
@hooks/archive-outputs.sh
Planned automation 1
Planned automation 2
X minutes
Y minutes
95%
successful runs / total runs
$X.XX
API calls + compute + storage
.claude/[level]/sessions/[workflow-name]/
30 days
JSON with timestamps and metrics
Check API connectivity
1. Test API endpoint: curl [endpoint]
2. Verify API keys are valid
3. Check rate limits
Parameters may need adjustment
1. Review recent quality scores
2. Adjust thresholds in config
3. Consider model upgrade
Verbose mode: Add --verbose flag
Dry run: Add --dry-run flag
Step mode: Add --step flag for manual progression
✅ Always validate inputs before processing
✅ Save intermediate outputs for debugging
✅ Log all decisions and quality scores
✅ Test with small samples first
❌ Skip quality checks to save time
❌ Ignore warning messages
❌ Process without checking prerequisites
❌ Modify workflow without testing
💡 Run in dry-run mode for new configurations
💡 Keep backup of last known good configuration
💡 Document any manual interventions
@[related-workflow-1].md - Relationship
@[related-workflow-2].md - Relationship
@[command-1].md - Used in Step 3
@[command-2].md - Used in Step 4
@[quality-standards].md - Quality thresholds
@[troubleshooting-guide].md - Extended debugging
2025-08-13
95%
X minutes
2025-09-13
Visual representation of workflow logic and decision points
Use clear, descriptive node labels
Show all major decision points
Include error handling paths
Keep diagrams readable at medium complexity
Every workflow must have measurable quality checkpoints
Performance metrics (speed, efficiency)
Quality scores (accuracy, completeness)
Business metrics (cost, value)
Connect with Claude Code MCP capabilities
pre-execution validation
post-step verification
error handling
completion notification

```bash

- 
      Replace all placeholder values with workflow-specific content

- 
      Create accurate mermaid diagram reflecting actual flow

- 
      Define specific quality thresholds and metrics

- 
      Map automation hooks to available tools

- 
      Test workflow documentation against actual implementation
All steps have clear success criteria
Error paths are documented with recovery procedures
Quality gates have measurable thresholds
Dependencies are accurately listed and testable
Troubleshooting covers common failure modes
```


---

*Converted from XML to Markdown for elegant simplicity*
*Original: workflow-template.xml*
*Conversion: Mon Aug 18 00:01:18 EDT 2025*
