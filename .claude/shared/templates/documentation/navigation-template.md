<document type="navigation" version="3.1.0" enhanced="2025-08-11">
  <metadata>
    <title>[Domain] Navigation Guide</title>
    <category>[domain-name]</category>
    <scope>domain-level</scope>
    <file-count>[X] files</file-count>
    <navigation>
      <up>@../NAVIGATION_INDEX.md</up>
      <home>@../../CLAUDE.md</home>
    </navigation>
  </metadata>

  <summary>
    Complete navigation guide for [Domain] documentation with @ file hopping.
    Part of the hierarchical navigation system for efficient documentation traversal.
  </summary>
</document>

# [Domain] Navigation Guide

## Quick Jump Menu

<quick-links>
  <essential>
    🏠 @../../CLAUDE.md - Project home
    🧭 @../NAVIGATION_INDEX.md - Master navigation
    📊 @00_[domain]_constants.md - Domain constants
  </essential>
  
  <related-domains>
    📚 @../foundation/NAVIGATION.md - Foundation concepts
    🛠️ @../claude-code/NAVIGATION.md - Claude Code tools
    🤖 @../ai-orchestration/NAVIGATION.md - AI orchestration
  </related-domains>
</quick-links>

## Domain Overview

<overview>
  <purpose>[What this domain covers]</purpose>
  <audience>[Who should read these files]</audience>
  <prerequisites>@[prerequisite-domain]/NAVIGATION.md</prerequisites>
  <total-files>[X] documents</total-files>
</overview>

## Learning Path

<learning-path>
  <phase name="Foundation" level="beginner">
    <step number="1">
      <file>@[01_first_file].md</file>
      <purpose>[What you'll learn]</purpose>
      <time>10-15 minutes</time>
    </step>
    
    <step number="2">
      <file>@[02_second_file].md</file>
      <purpose>[What you'll learn]</purpose>
      <time>15-20 minutes</time>
    </step>
  </phase>
  
  <phase name="Core Concepts" level="intermediate">
    <step number="3">
      <file>@[03_third_file].md</file>
      <purpose>[What you'll learn]</purpose>
      <time>20-25 minutes</time>
    </step>
  </phase>
  
  <phase name="Advanced Topics" level="advanced">
    <step number="4">
      <file>@[04_fourth_file].md</file>
      <purpose>[What you'll learn]</purpose>
      <time>25-30 minutes</time>
    </step>
  </phase>
</learning-path>

## File Directory

<directory>
  <section name="Constants & Configuration">
    <file id="00">
      @00_[domain]_constants.md
      <description>Central constants repository</description>
      <importance>high</importance>
    </file>
  </section>
  
  <section name="Core Documentation">
    <file id="01">
      @01_[topic_name].md
      <description>[Brief description]</description>
      <importance>high</importance>
      <prerequisites>none</prerequisites>
    </file>
    
    <file id="02">
      @02_[topic_name].md
      <description>[Brief description]</description>
      <importance>high</importance>
      <prerequisites>@01_[topic_name].md</prerequisites>
    </file>
    
    <file id="03">
      @03_[topic_name].md
      <description>[Brief description]</description>
      <importance>medium</importance>
      <prerequisites>@02_[topic_name].md</prerequisites>
    </file>
  </section>
  
  <section name="Advanced Topics">
    <file id="04">
      @04_[advanced_topic].md
      <description>[Brief description]</description>
      <importance>medium</importance>
      <prerequisites>@03_[topic_name].md</prerequisites>
    </file>
  </section>
  
  <section name="Reference">
    <file id="README">
      @README.md
      <description>Domain overview and index</description>
      <importance>high</importance>
    </file>
    
    <file id="NAVIGATION">
      @NAVIGATION.md
      <description>This file - navigation guide</description>
      <importance>high</importance>
    </file>
  </section>
</directory>

## Navigation Chains

<chains>
  <chain name="Complete Learning Path">
    @01_[first].md → @02_[second].md → @03_[third].md → @04_[fourth].md
  </chain>
  
  <chain name="Quick Start">
    @00_constants.md → @01_[intro].md → @03_[practical].md
  </chain>
  
  <chain name="Advanced Path">
    @03_[intermediate].md → @04_[advanced].md → @../[next-domain]/NAVIGATION.md
  </chain>
  
  <chain name="Reference Path">
    @README.md → @NAVIGATION.md → @00_constants.md
  </chain>
</chains>

## Cross-Domain References

<cross-references>
  <dependency domain="foundation">
    <reason>[Why this domain depends on foundation]</reason>
    <key-files>
      - @../foundation/01_project_overview.md
      - @../foundation/02_walk_crawl_run_phases.md
    </key-files>
  </dependency>
  
  <related domain="claude-code">
    <reason>[How this relates to Claude Code]</reason>
    <key-files>
      - @../claude-code/15_claude_code_introduction.md
      - @../claude-code/16_memory_management_system.md
    </key-files>
  </related>
  
  <output-to domain="[target-domain]">
    <reason>[What this domain provides to target]</reason>
    <integration-points>
      - @../[target]/[file].md
    </integration-points>
  </output-to>
</cross-references>

## Task-Based Navigation

<tasks>
  <task goal="Learn the basics">
    <path>
      1. Start: @01_[introduction].md
      2. Concepts: @02_[concepts].md
      3. Practice: @03_[examples].md
    </path>
  </task>
  
  <task goal="Implement [feature]">
    <path>
      1. Requirements: @[requirements].md
      2. Configuration: @00_constants.md
      3. Implementation: @[implementation].md
      4. Testing: @[testing].md
    </path>
  </task>
  
  <task goal="Troubleshoot issues">
    <path>
      1. Common issues: @[troubleshooting].md
      2. Error codes: @00_constants.md#error-codes
      3. Support: @../operations/01_troubleshooting_guide.md
    </path>
  </task>
</tasks>

## Search Helpers

<search-keywords>
  <topic name="[Topic 1]">
    <keywords>[keyword1, keyword2, keyword3]</keywords>
    <files>@[file1].md, @[file2].md</files>
  </topic>
  
  <topic name="[Topic 2]">
    <keywords>[keyword4, keyword5, keyword6]</keywords>
    <files>@[file3].md, @[file4].md</files>
  </topic>
</search-keywords>

## Domain Statistics

<statistics>
  <metrics>
    <total-files>[X]</total-files>
    <total-words>[Y]</total-words>
    <average-read-time>[Z] minutes</average-read-time>
    <last-updated>2025-08-11</last-updated>
  </metrics>
  
  <coverage>
    <topic name="[Topic]" coverage="100%"/>
    <topic name="[Topic]" coverage="80%"/>
    <topic name="[Topic]" coverage="60%"/>
  </coverage>
  
  <quality>
    <enhanced-files>[X] of [Y]</enhanced-files>
    <xml-tagged>[X] of [Y]</xml-tagged>
    <validated>[X] of [Y]</validated>
  </quality>
</statistics>

## Maintenance Notes

<maintenance>
  <update-frequency>Weekly</update-frequency>
  <last-review>2025-08-11</last-review>
  <next-review>2025-08-18</next-review>
  
  <pending-updates>
    - [ ] [File] needs [update type]
    - [ ] [File] needs [update type]
  </pending-updates>
  
  <broken-links>
    - [ ] All links verified ✅
  </broken-links>
</maintenance>

---

<validation>
  <navigation-tested>2025-08-11</navigation-tested>
  <all-files-present>true</all-files-present>
  <cross-references-valid>true</cross-references-valid>
</validation>