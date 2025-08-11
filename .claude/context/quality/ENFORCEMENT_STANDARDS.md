# Quality Enforcement Standards - MANDATORY

<document type="quality-standards" version="3.0.0" claude-code-optimized="true">
  <metadata>
    <critical-importance>MANDATORY FOR ALL OPERATIONS</critical-importance>
    <enforcement-level>STRICT - NO EXCEPTIONS</enforcement-level>
    <created>2025-08-11</created>
    <moved-from>CLAUDE.md lines 557-785</moved-from>
  </metadata>
</document>

<QUALITY-ENFORCEMENT-STANDARDS>
  <critical-importance>
    THESE STANDARDS ARE MANDATORY FOR ALL OPERATIONS.
    FAILURE TO FOLLOW THESE STANDARDS INVALIDATES ANY WORK PERFORMED.
    STRICT ENFORCEMENT IS REQUIRED - NO EXCEPTIONS.
  </critical-importance>

  <anti-hallucination-requirements>
    <verification-mandate>
      <rule type="MANDATORY">VERIFY before claiming: Every statement must be verifiable through actual tools or research</rule>
      <rule type="MANDATORY">RESEARCH before documenting: Use Grep, Read, LS, or other verification tools to confirm information</rule>
      <rule type="MANDATORY">TEST before implementing: Run actual validation commands to ensure functionality</rule>
      <rule type="MANDATORY">SOURCE attribution required: Cite specific files, line numbers, or tool outputs for every claim</rule>
      <rule type="MANDATORY">NO assumptions: If uncertain, explicitly state "UNVERIFIED - requires validation"</rule>
      <rule type="MANDATORY">VALIDATION commands: Include specific test commands for every technical claim</rule>
      <rule type="MANDATORY">ERROR acknowledgment: Admit immediately when something cannot be verified</rule>
    </verification-mandate>
    
    <validation-examples>
      <example type="file-existence">
        WRONG: "The config file exists at .claude/config.json"
        RIGHT: "Verification needed: ls .claude/config.json || echo 'File not found'"
      </example>
      <example type="directory-structure">
        WRONG: "The sessions directory contains tracking files"
        RIGHT: "Directory contents verified: ls -la .claude/level-2-production/sessions/"
      </example>
      <example type="command-functionality">
        WRONG: "This command will work: python script.py"
        RIGHT: "Command validation: python -c 'import sys; print(sys.executable)' && python --version"
      </example>
    </validation-examples>
    
    <uncertainty-handling>
      <when-uncertain>Use phrases like "UNVERIFIED", "REQUIRES VALIDATION", "CANNOT CONFIRM WITHOUT TESTING"</when-uncertain>
      <verification-first>Always attempt verification through tools before making claims</verification-first>
      <explicit-limitations>State clearly what cannot be verified and why</explicit-limitations>
    </uncertainty-handling>
  </anti-hallucination-requirements>

  <directory-organization-principles>
    <separation-mandate>
      <rule type="MANDATORY">One purpose per directory: Each directory serves exactly one function</rule>
      <rule type="MANDATORY">Clear naming conventions: Use descriptive-lowercase-hyphenated names</rule>
      <rule type="MANDATORY">No cross-level dependencies: Level 1 cannot import from Level 2, etc.</rule>
      <rule type="MANDATORY">Separation of concerns: Development tools separate from production tools</rule>
      <rule type="MANDATORY">File placement rules: Config in root, templates in templates/, sessions in sessions/</rule>
      <rule type="MANDATORY">No orphan files: Every file must have a clearly defined organizational home</rule>
      <rule type="MANDATORY">Documentation location: All documentation in context/ directory, organized by topic</rule>
    </separation-mandate>
    
    <directory-structure-enforcement>
      <level-1-dev>
        <purpose>Development platform tools ONLY</purpose>
        <allowed-contents>agents/, commands/, sessions/, templates/</allowed-contents>
        <forbidden-contents>Production data, episode content, API integrations</forbidden-contents>
      </level-1-dev>
      <level-2-production>
        <purpose>Podcast production ONLY</purpose>
        <allowed-contents>agents/, commands/, sessions/, output/</allowed-contents>
        <forbidden-contents>Development tools, platform code, planning documents</forbidden-contents>
      </level-2-production>
      <level-3-platform-dev>
        <purpose>Platform planning ONLY</purpose>
        <allowed-contents>requirements/, architecture/, migration/</allowed-contents>
        <forbidden-contents>Actual code, production data, current tools</forbidden-contents>
      </level-3-platform-dev>
      <level-4-coded>
        <purpose>Future implementation ONLY</purpose>
        <allowed-contents>documentation/ ONLY until approval granted</allowed-contents>
        <forbidden-contents>ANY CODE without explicit user approval</forbidden-contents>
      </level-4-coded>
    </directory-structure-enforcement>
    
    <naming-standards>
      <directories>lowercase-with-hyphens (e.g., level-2-production, context-management)</directories>
      <files>descriptive-lowercase-with-extension (e.g., episode-production-session.json)</files>
      <commands>verb-noun-format (e.g., produce-episode, validate-quality)</commands>
      <agents>role-descriptor-format (e.g., research-coordinator, quality-evaluator)</agents>
    </naming-standards>
  </directory-organization-principles>

  <dry-enforcement>
    <single-source-truth>
      <rule type="MANDATORY">One canonical location: Each piece of information exists in exactly one authoritative place</rule>
      <rule type="MANDATORY">Shared resources: Common elements must be placed in .claude/shared/ directory</rule>
      <rule type="MANDATORY">Template usage: Use templates for repetitive structures instead of copying</rule>
      <rule type="MANDATORY">Variable extraction: Common values must be stored in configuration files</rule>
      <rule type="MANDATORY">Reference over duplication: Link to existing documentation rather than copying content</rule>
      <rule type="MANDATORY">Configuration inheritance: Base configurations with level-specific overrides</rule>
    </single-source-truth>
    
    <duplication-exceptions>
      <exception type="prompts">Agent prompts may repeat context for clarity and effectiveness</exception>
      <exception type="validation">Critical validation steps may be repeated for safety</exception>
      <exception type="learning">Educational examples may repeat concepts for comprehension</exception>
      <note>ALL exceptions must be explicitly justified and documented</note>
    </duplication-exceptions>
    
    <reference-patterns>
      <pattern type="internal">See .claude/shared/context/XX_topic_name.md for details</pattern>
      <pattern type="configuration">Reference: .claude/config/base-settings.json</pattern>
      <pattern type="template">Template: .claude/shared/templates/agent-template.md</pattern>
    </reference-patterns>
  </dry-enforcement>

  <anti-pattern-prevention>
    <forbidden-patterns>
      <pattern type="status-tracking">NO status="pending"/"completed" attributes in markdown documentation</pattern>
      <pattern type="hardcoded-progress">NO hardcoded progress indicators - use dynamic JSON session files</pattern>
      <pattern type="circular-dependencies">NO circular dependencies - maintain clear dependency hierarchy</pattern>
      <pattern type="vague-criteria">NO vague success criteria - all outcomes must be measurable</pattern>
      <pattern type="untestable-claims">NO untestable claims - everything must be verifiable</pattern>
      <pattern type="mixed-responsibilities">NO mixed responsibilities - one component serves one purpose</pattern>
      <pattern type="hidden-state">NO hidden state - all state must be visible in session files</pattern>
    </forbidden-patterns>
    
    <required-patterns>
      <pattern type="state-tracking">Use JSON session files in appropriate level directories</pattern>
      <pattern type="progress-indication">Dynamic progress calculation from session data</pattern>
      <pattern type="clear-hierarchy">Level 1 -> Level 2 -> Level 3 -> Level 4 dependency flow</pattern>
      <pattern type="measurable-outcomes">Specific metrics with thresholds (e.g., "<$5 per episode")</pattern>
      <pattern type="testable-functionality">Include validation commands for every feature</pattern>
      <pattern type="single-responsibility">Each agent/command/tool has one clear purpose</pattern>
      <pattern type="visible-state">All progress/state tracked in .claude/*/sessions/ files</pattern>
    </required-patterns>
  </anti-pattern-prevention>

  <validation-requirements>
    <operation-validation>
      <rule type="MANDATORY">Every operation must include specific validation steps</rule>
      <rule type="MANDATORY">Every file reference must be tested for existence before use</rule>
      <rule type="MANDATORY">Every command must have clearly defined success criteria</rule>
      <rule type="MANDATORY">Every workflow must include checkpoint validations</rule>
      <rule type="MANDATORY">Every claim must include verification method</rule>
      <rule type="MANDATORY">Every integration must have comprehensive test coverage</rule>
      <rule type="MANDATORY">Every session must track measurable metrics</rule>
    </operation-validation>
    
    <validation-commands>
      <file-existence>ls -la [file-path] || echo "File not found: [file-path]"</file-existence>
      <directory-structure>find .claude -type d -name "*" | sort</directory-structure>
      <command-availability>which [command] || echo "Command not found: [command]"</command-availability>
      <api-connectivity>[specific API test command] || echo "API connection failed"</api-connectivity>
      <dependency-check>pip list | grep [package] || echo "Package not installed: [package]"</dependency-check>
    </validation-commands>
    
    <checkpoint-requirements>
      <before-major-operations>Validate environment state and prerequisites</before-major-operations>
      <during-execution>Confirm each step completes successfully before proceeding</during-execution>
      <after-completion>Verify all expected outputs exist and are valid</after-completion>
      <error-handling>Document specific error conditions and recovery steps</error-handling>
    </checkpoint-requirements>
  </validation-requirements>

  <attention-to-detail-requirements>
    <precision-mandate>
      <rule type="MANDATORY">File paths must be exact and case-sensitive</rule>
      <rule type="MANDATORY">Command syntax must be precisely correct</rule>
      <rule type="MANDATORY">No placeholder values in production configurations</rule>
      <rule type="MANDATORY">Version numbers must be tracked and documented</rule>
      <rule type="MANDATORY">Dependencies must be explicitly listed with versions</rule>
      <rule type="MANDATORY">Error messages must be actionable and specific</rule>
      <rule type="MANDATORY">Documentation must match actual implementation exactly</rule>
    </precision-mandate>
    
    <accuracy-standards>
      <file-paths>Use absolute paths consistently, verify case sensitivity</file-paths>
      <commands>Test all commands in target environment before documenting</commands>
      <configurations>No [PLACEHOLDER] or TODO values in working systems</configurations>
      <versions>Specify exact version numbers (e.g., Python 3.11.5, not just Python 3)</versions>
      <dependencies>Include specific package versions in requirements files</dependencies>
      <errors>Provide exact error text and step-by-step resolution</errors>
      <docs>Keep documentation synchronized with code changes immediately</docs>
    </accuracy-standards>
    
    <quality-checkpoints>
      <checkpoint type="syntax">All commands and code snippets must be syntax-valid</checkpoint>
      <checkpoint type="paths">All file and directory references must be verified</checkpoint>
      <checkpoint type="consistency">Naming conventions must be applied consistently</checkpoint>
      <checkpoint type="completeness">No incomplete configurations or partial implementations</checkpoint>
      <checkpoint type="testability">All instructions must be executable and testable</checkpoint>
    </quality-checkpoints>
  </attention-to-detail-requirements>

  <enforcement-procedures>
    <pre-operation-checks>
      <step number="1">Validate all file paths and directory structure</step>
      <step number="2">Confirm all dependencies and prerequisites</step>
      <step number="3">Test all commands in appropriate environment</step>
      <step number="4">Verify no anti-patterns are present</step>
      <step number="5">Ensure all claims are verifiable</step>
    </pre-operation-checks>
    
    <during-operation-monitoring>
      <monitor>Track each step completion status</monitor>
      <validate>Confirm outputs match expectations</validate>
      <document>Record all validation commands and results</document>
      <checkpoint>Pause at defined validation points</checkpoint>
      <recover>Have explicit error recovery procedures</recover>
    </during-operation-monitoring>
    
    <post-operation-verification>
      <verify>All expected files and directories created</verify>
      <test>All functionality works as documented</test>
      <measure>All success criteria are met</measure>
      <record>All metrics and outcomes documented</record>
      <validate>All references and links are functional</validate>
    </post-operation-verification>
  </enforcement-procedures>

  <quality-metrics>
    <measurable-standards>
      <accuracy>File path accuracy: 100% (zero broken references)</accuracy>
      <completeness>Operation completeness: 100% (all steps executable)</completeness>
      <consistency>Naming consistency: 100% (all conventions followed)</consistency>
      <verifiability>Claim verifiability: 100% (all statements testable)</verifiability>
      <organization>Directory organization: 100% (no misplaced files)</organization>
    </measurable-standards>
    
    <failure-handling>
      <immediate-stop>Stop all operations if quality standards are not met</immediate-stop>
      <root-cause-analysis>Identify why standards were violated</root-cause-analysis>
      <corrective-action>Fix all issues before proceeding</corrective-action>
      <prevention-update>Update procedures to prevent recurrence</prevention-update>
    </failure-handling>
  </quality-metrics>
</QUALITY-ENFORCEMENT-STANDARDS>

## Navigation

**Back to Main**: @CLAUDE.md
**Quality Domain**: @quality/NAVIGATION.md
**Validation Workflow**: @14_validation_workflow.md