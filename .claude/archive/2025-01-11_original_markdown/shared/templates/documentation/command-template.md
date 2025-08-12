---
name: [command-name]
description: [Clear description of what the command does]
category: [development|production|utility|workflow]
level: [1-dev|2-production|3-platform]
complexity: [simple|moderate|complex]
time-estimate: [X-Y minutes]
---

<command-metadata>
  <version>3.1.0</version>
  <created>2025-08-11</created>
  <status>[active|testing|deprecated]</status>
  <agents-used>
    <agent>@[agent-name].md</agent>
  </agents-used>
  <dependencies>
    <commands>@[prerequisite-command].md</commands>
    <configs>@[config-file].yaml</configs>
  </dependencies>
</command-metadata>

# /[command-name] - [Primary Purpose]

## Quick Reference

```bash
/[command-name] [required-arg] [optional-arg]
```

<parameters>
  <required>
    <param name="[arg1]" type="[string|number|boolean]">
      <description>[What this parameter does]</description>
      <validation>[Validation rules]</validation>
      <example>[Example value]</example>
    </param>
  </required>

  <optional>
    <param name="[arg2]" type="[string|number|boolean]" default="[default-value]">
      <description>[What this parameter does]</description>
      <validation>[Validation rules]</validation>
      <example>[Example value]</example>
    </param>
  </optional>
</parameters>

## Purpose & Context

<purpose>
  <primary>[Main goal of this command]</primary>
  <use-cases>
    - [Scenario 1 where this is useful]
    - [Scenario 2 where this is useful]
    - [Scenario 3 where this is useful]
  </use-cases>
  <not-for>
    - [Scenario where this shouldn't be used]
    - [Alternative command for that scenario]
  </not-for>
</purpose>

## Workflow Integration

<workflow>
  <prerequisites>
    <step>1. [What must be done first]</step>
    <step>2. [What state must exist]</step>
  </prerequisites>

  <execution>
    <step>1. [What happens when command runs]</step>
    <step>2. [Key processing step]</step>
    <step>3. [Output generation]</step>
  </execution>

  <followup>
    <typical>After completion, run @[next-command].md</typical>
    <validation>Verify with @[validation-command].md</validation>
  </followup>
</workflow>

## Examples

<examples>
  <example type="basic">
    <title>Simple Usage</title>
    <command>/[command-name] "basic-argument"</command>
    <context>[When you'd use this]</context>
    <output>
[Expected output or behavior]
    </output>
  </example>

  <example type="advanced">
    <title>Complex Usage with Options</title>
    <command>/[command-name] "main-arg" --option1 value --flag</command>
    <context>[When you'd use this configuration]</context>
    <output>
[Expected output or behavior]
    </output>
  </example>

  <example type="pipeline">
    <title>In a Workflow</title>
    <commands>
/[prep-command]
/[command-name] "{{output-from-prep}}"
/[followup-command]
    </commands>
    <context>[Typical workflow scenario]</context>
  </example>
</examples>

## Output Specification

<output>
  <format>[json|text|markdown|file]</format>
  <structure>
```[json|yaml|text]
{
  "field1": "[description]",
  "field2": "[description]",
  "metadata": {
    "timestamp": "[ISO-8601]",
    "status": "[success|partial|failure]"
  }
}
```
  </structure>
  <location>[Where output is saved/displayed]</location>
</output>

## Error Handling

<errors>
  <error code="[ERROR_CODE]">
    <message>[User-friendly error message]</message>
    <cause>[What causes this error]</cause>
    <resolution>[How to fix it]</resolution>
  </error>

  <error code="[ERROR_CODE_2]">
    <message>[User-friendly error message]</message>
    <cause>[What causes this error]</cause>
    <resolution>[How to fix it]</resolution>
  </error>
</errors>

## Performance Considerations

<performance>
  <timing>
    <typical>[X-Y seconds/minutes]</typical>
    <factors>[What affects execution time]</factors>
  </timing>

  <resources>
    <memory>[Typical memory usage]</memory>
    <api-calls>[Number and type of API calls]</api-calls>
    <cost>[Estimated cost if applicable]</cost>
  </resources>

  <optimization>
    - [Tip 1 for faster execution]
    - [Tip 2 for cost reduction]
  </optimization>
</performance>

## Quality Gates

<quality>
  <validations>
    - ✅ [What is checked before execution]
    - ✅ [What is validated during execution]
    - ✅ [What is verified after completion]
  </validations>

  <thresholds>
    <metric name="[quality-metric]">
      <minimum>[threshold]</minimum>
      <target>[ideal-value]</target>
    </metric>
  </thresholds>
</quality>

## Troubleshooting

<troubleshooting>
  <issue symptom="[Common problem]">
    <diagnosis>[How to identify the issue]</diagnosis>
    <solution>[Step-by-step fix]</solution>
    <prevention>[How to avoid in future]</prevention>
  </issue>

  <debugging>
    <verbose>/[command-name] --verbose [args]</verbose>
    <dry-run>/[command-name] --dry-run [args]</dry-run>
    <logs>[Where to find logs]</logs>
  </debugging>
</troubleshooting>

## Related Commands

<related>
  <similar>
    - @[similar-command-1].md - [How it differs]
    - @[similar-command-2].md - [When to use instead]
  </similar>

  <workflow-chain>
    <before>@[prep-command].md</before>
    <after>@[followup-command].md</after>
  </workflow-chain>

  <alternatives>
    <scenario>[Specific scenario]</scenario>
    <use-instead>@[alternative-command].md</use-instead>
  </alternatives>
</related>

## Implementation Notes

<implementation>
  <agents-involved>
    - @[agent-1].md: [Role in execution]
    - @[agent-2].md: [Role in execution]
  </agents-involved>

  <technical-details>
    [Any important implementation details for maintainers]
  </technical-details>

  <future-improvements>
    - [Planned enhancement 1]
    - [Planned enhancement 2]
  </future-improvements>
</implementation>

---

<validation>
  <tested>2025-08-11</tested>
  <test-coverage>[X%]</test-coverage>
  <last-update>2025-08-11</last-update>
</validation>
