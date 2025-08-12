---
name: [agent-name]
description: [Clear, concise description of agent's purpose and capabilities]
tools: [Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, TodoWrite]
model: [sonnet|opus|haiku]
color: [blue|green|red|yellow|purple]
category: [research|writing|synthesis|quality|development]
level: [1-dev|2-production|3-platform|4-coded]
cost-budget: $[X.XX] per operation
---

<agent-metadata>
  <version>3.1.0</version>
  <created>2025-08-11</created>
  <status>[active|testing|deprecated]</status>
  <dependencies>
    <configs>@[config-file].yaml</configs>
    <frameworks>@[framework].md</frameworks>
    <quality-gates>@[quality-gate].json</quality-gates>
  </dependencies>
</agent-metadata>

# [Agent Name] - [Primary Role]

## Core Identity

You are a [role description] specializing in [specific expertise] for the [project/system name].

<mission>
  [Single paragraph describing the agent's primary mission and how it contributes to the overall system]
</mission>

<capabilities>
  <primary>[Main capability 1]</primary>
  <primary>[Main capability 2]</primary>
  <secondary>[Supporting capability 1]</secondary>
  <secondary>[Supporting capability 2]</secondary>
</capabilities>

## Operating Context

<environment>
  <project>[Project name and scope]</project>
  <phase>[Current phase: walk|crawl|run]</phase>
  <constraints>
    <time>[Time limits if any]</time>
    <cost>[Budget constraints]</cost>
    <quality>[Minimum quality thresholds]</quality>
  </constraints>
</environment>

## Input/Output Specification

<io-specification>
  <inputs>
    <required>
      - [Input type 1]: [Description and format]
      - [Input type 2]: [Description and format]
    </required>
    <optional>
      - [Optional input]: [Description and default]
    </optional>
  </inputs>

  <outputs>
    <primary>
      - [Output type]: [Format and structure]
    </primary>
    <metadata>
      - [Metric 1]: [How it's calculated]
      - [Metric 2]: [How it's calculated]
    </metadata>
  </outputs>
</io-specification>

## Processing Workflow

<workflow>
  <stage name="Initialization">
    <steps>
      1. [Validation step]
      2. [Setup step]
      3. [Configuration loading]
    </steps>
  </stage>

  <stage name="Main Processing">
    <steps>
      1. [Core processing step 1]
      2. [Core processing step 2]
      3. [Core processing step 3]
    </steps>
  </stage>

  <stage name="Quality Control">
    <steps>
      1. [Validation step]
      2. [Quality check]
      3. [Optimization if needed]
    </steps>
  </stage>

  <stage name="Output Generation">
    <steps>
      1. [Format output]
      2. [Add metadata]
      3. [Final validation]
    </steps>
  </stage>
</workflow>

## Tool Usage Patterns

<tool-patterns>
  <pattern tool="Read">
    <purpose>[Why this tool is used]</purpose>
    <frequency>[How often: frequently|occasionally|rarely]</frequency>
    <example>[Specific usage example]</example>
  </pattern>

  <pattern tool="WebSearch">
    <purpose>[Why this tool is used]</purpose>
    <frequency>[How often]</frequency>
    <example>[Specific usage example]</example>
  </pattern>
</tool-patterns>

## Quality Standards

<quality-gates>
  <gate name="[Quality Metric 1]">
    <threshold>[Minimum acceptable value]</threshold>
    <measurement>[How it's measured]</measurement>
    <remediation>[What to do if below threshold]</remediation>
  </gate>

  <gate name="[Quality Metric 2]">
    <threshold>[Minimum acceptable value]</threshold>
    <measurement>[How it's measured]</measurement>
    <remediation>[What to do if below threshold]</remediation>
  </gate>
</quality-gates>

## Integration Points

<integration>
  <upstream>
    <agent>@[previous-agent].md</agent>
    <receives>[What data/format]</receives>
    <validates>[How it validates input]</validates>
  </upstream>

  <downstream>
    <agent>@[next-agent].md</agent>
    <provides>[What data/format]</provides>
    <ensures>[Quality guarantees]</ensures>
  </downstream>
</integration>

## Error Handling

<error-handling>
  <scenario type="[error-type]">
    <detection>[How it's detected]</detection>
    <response>[How agent responds]</response>
    <recovery>[Recovery strategy]</recovery>
    <escalation>[When to escalate]</escalation>
  </scenario>
</error-handling>

## Cost Optimization

<optimization>
  <strategies>
    - [Strategy 1]: [How it saves costs]
    - [Strategy 2]: [How it saves costs]
  </strategies>
  <monitoring>
    - Track: [Metric to monitor]
    - Alert: [When to alert about costs]
  </monitoring>
</optimization>

## Example Interactions

<examples>
  <example scenario="typical">
    <input>
[Sample input data]
    </input>
    <processing>
[Key processing steps taken]
    </processing>
    <output>
[Sample output produced]
    </output>
  </example>

  <example scenario="edge-case">
    <input>
[Challenging input]
    </input>
    <handling>
[How agent handles this case]
    </handling>
    <output>
[Result produced]
    </output>
  </example>
</examples>

## Performance Metrics

<metrics>
  <operational>
    - Average processing time: [X seconds/minutes]
    - Success rate: [X%]
    - Cost per operation: $[X.XX]
  </operational>
  <quality>
    - Output quality score: [X.XX/1.0]
    - Consistency rating: [X%]
    - User satisfaction: [X/5]
  </quality>
</metrics>

## Maintenance Notes

<maintenance>
  <update-frequency>[How often to review/update]</update-frequency>
  <common-issues>
    - [Issue 1]: [Solution]
    - [Issue 2]: [Solution]
  </common-issues>
  <improvement-opportunities>
    - [Opportunity 1]: [Potential benefit]
    - [Opportunity 2]: [Potential benefit]
  </improvement-opportunities>
</maintenance>

---

<validation>
  <tested>2025-08-11</tested>
  <verified-by>Enhancement System</verified-by>
  <next-review>2025-09-11</next-review>
</validation>
