<document type="constants" version="3.1.0" enhanced="2025-08-11">
  <metadata>
    <title>[Domain] Constants and Configuration</title>
    <scope>[global|domain|component]</scope>
    <category>[foundation|claude-code|ai-orchestration|elevenlabs|operations|quality]</category>
    <mutability>read-only</mutability>
    <validation-frequency>weekly</validation-frequency>
    <navigation>
      <index>@NAVIGATION.md</index>
      <related>@[related-constants].md</related>
    </navigation>
  </metadata>

  <summary>
    Central repository for [domain] constants, configurations, and reference values.
    Single source of truth to eliminate duplication across documentation.
  </summary>
</document>

# [Domain] Constants

## Overview

<purpose>
  This file contains all constants, configurations, and reference values for [domain].
  All documentation should reference these values rather than hardcoding them.
</purpose>

## Project Constants

<project-constants>
  <constant name="PROJECT_NAME" type="string">
    <value>[Project Name]</value>
    <description>Official project identifier</description>
    <usage>Referenced in all project documentation</usage>
  </constant>
  
  <constant name="VERSION" type="string">
    <value>[X.Y.Z]</value>
    <description>Current version number</description>
    <modified>2025-08-11</modified>
  </constant>
  
  <constant name="PHASE" type="enum">
    <value>[walk|crawl|run]</value>
    <options>walk, crawl, run</options>
    <description>Current project phase</description>
  </constant>
</project-constants>

## Configuration Values

<configuration>
  <section name="API Settings">
    <config key="BASE_URL" type="url">
      <value>https://api.example.com/v1</value>
      <description>Primary API endpoint</description>
      <environment>[production|staging|development]</environment>
    </config>
    
    <config key="TIMEOUT" type="integer">
      <value>30</value>
      <unit>seconds</unit>
      <description>Default request timeout</description>
    </config>
    
    <config key="RETRY_ATTEMPTS" type="integer">
      <value>3</value>
      <description>Maximum retry attempts for failed requests</description>
    </config>
  </section>
  
  <section name="Quality Thresholds">
    <config key="MIN_QUALITY_SCORE" type="float">
      <value>0.85</value>
      <range>0.0-1.0</range>
      <description>Minimum acceptable quality score</description>
    </config>
    
    <config key="TARGET_QUALITY_SCORE" type="float">
      <value>0.90</value>
      <range>0.0-1.0</range>
      <description>Target quality score for optimization</description>
    </config>
  </section>
</configuration>

## Cost Parameters

<cost-parameters>
  <parameter name="BUDGET_PER_OPERATION" type="currency">
    <value>5.00</value>
    <currency>USD</currency>
    <description>Maximum cost per operation</description>
  </parameter>
  
  <parameter name="HOURLY_RATE" type="currency">
    <value>0.50</value>
    <currency>USD</currency>
    <description>Estimated hourly operational cost</description>
  </parameter>
  
  <parameter name="API_COST_PER_CALL" type="currency">
    <service name="Service1">
      <value>0.01</value>
      <unit>per request</unit>
    </service>
    <service name="Service2">
      <value>0.001</value>
      <unit>per 1000 tokens</unit>
    </service>
  </parameter>
</cost-parameters>

## Technical Specifications

<specifications>
  <spec name="MAX_TOKENS" type="integer">
    <value>4096</value>
    <description>Maximum tokens per request</description>
    <applies-to>LLM API calls</applies-to>
  </spec>
  
  <spec name="CHUNK_SIZE" type="integer">
    <value>1000</value>
    <unit>characters</unit>
    <description>Text processing chunk size</description>
  </spec>
  
  <spec name="BATCH_SIZE" type="integer">
    <value>10</value>
    <description>Default batch processing size</description>
  </spec>
</specifications>

## File Paths and Locations

<paths>
  <path name="CONFIG_DIR" type="directory">
    <value>.claude/[level]/config/</value>
    <description>Configuration files location</description>
    <pattern>[level] = level-1-dev | level-2-production | level-3-platform</pattern>
  </path>
  
  <path name="OUTPUT_DIR" type="directory">
    <value>.claude/[level]/output/</value>
    <description>Generated output location</description>
  </path>
  
  <path name="SESSIONS_DIR" type="directory">
    <value>.claude/[level]/sessions/</value>
    <description>Session tracking location</description>
  </path>
</paths>

## Error Codes

<error-codes>
  <error code="E001">
    <name>VALIDATION_ERROR</name>
    <description>Input validation failed</description>
    <severity>warning</severity>
  </error>
  
  <error code="E002">
    <name>API_ERROR</name>
    <description>External API call failed</description>
    <severity>error</severity>
  </error>
  
  <error code="E003">
    <name>QUALITY_THRESHOLD_NOT_MET</name>
    <description>Output quality below minimum threshold</description>
    <severity>warning</severity>
  </error>
</error-codes>

## Status Values

<status-values>
  <status-set name="Workflow Status">
    <status value="pending">Not yet started</status>
    <status value="in_progress">Currently executing</status>
    <status value="completed">Successfully finished</status>
    <status value="failed">Execution failed</status>
    <status value="cancelled">Manually cancelled</status>
  </status-set>
  
  <status-set name="Quality Status">
    <status value="excellent">Score ≥ 0.95</status>
    <status value="good">Score ≥ 0.85</status>
    <status value="acceptable">Score ≥ 0.75</status>
    <status value="poor">Score < 0.75</status>
  </status-set>
</status-values>

## Reference Tables

<reference-tables>
  <table name="Model Capabilities">
    | Model | Context Window | Cost/1K Tokens | Best For |
    |-------|----------------|----------------|----------|
    | model-1 | 8K | $0.01 | Quick tasks |
    | model-2 | 32K | $0.03 | Complex analysis |
    | model-3 | 128K | $0.10 | Long documents |
  </table>
  
  <table name="Quality Metrics">
    | Metric | Weight | Threshold | Target |
    |--------|--------|-----------|--------|
    | Accuracy | 0.3 | 0.80 | 0.90 |
    | Completeness | 0.3 | 0.85 | 0.95 |
    | Consistency | 0.2 | 0.90 | 0.95 |
    | Clarity | 0.2 | 0.85 | 0.90 |
  </table>
</reference-tables>

## Usage Examples

<usage>
  <example language="markdown">
    <!-- Instead of hardcoding: -->
    The project "Nobody Knows" has a budget of $5.00 per episode.
    
    <!-- Use references: -->
    The project "{PROJECT_NAME}" has a budget of ${BUDGET_PER_OPERATION} per episode.
    
    <!-- Or with explicit reference: -->
    See BUDGET_PER_OPERATION in @00_[domain]_constants.md
  </example>
  
  <example language="python">
    # Import constants
    from constants import BUDGET_PER_OPERATION, MAX_TOKENS
    
    # Use in code
    if cost > BUDGET_PER_OPERATION:
        raise BudgetExceededError(f"Cost ${cost} exceeds budget ${BUDGET_PER_OPERATION}")
  </example>
</usage>

## Validation Rules

<validation>
  <rule name="Immutability">
    Constants should never be modified directly in consuming files
  </rule>
  
  <rule name="Single Source">
    Each constant should be defined in exactly one location
  </rule>
  
  <rule name="Documentation">
    Every constant must have a description and usage example
  </rule>
  
  <rule name="Versioning">
    Changes to constants require version increment and changelog entry
  </rule>
</validation>

## Change Log

<changelog>
  <entry date="2025-08-11" version="3.1.0">
    <change>Initial constants definition</change>
    <author>Enhancement System</author>
  </entry>
</changelog>

---

<maintenance>
  <review-frequency>Weekly</review-frequency>
  <last-validated>2025-08-11</last-validated>
  <next-review>2025-08-18</next-review>
  <owner>[Team/Person responsible]</owner>
</maintenance>