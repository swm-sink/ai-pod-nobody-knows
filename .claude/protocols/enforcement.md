# Enforcement Protocols

## ⚠️ BRUTAL ENFORCEMENT PROTOCOLS - ZERO TOLERANCE

### Anti-Hallucination Protocol

**Critical Mandate:**
EVERY TECHNICAL CLAIM MUST BE TOOL-VERIFIED OR EXPLICITLY MARKED UNVERIFIED
FAILURE TO VERIFY INVALIDATES ALL WORK AND REQUIRES IMMEDIATE STOP
NO EXCEPTIONS - NO BYPASS - NO ESTIMATES WITHOUT EXPLICIT UNCERTAINTY

**Verification Requirements:**

**File Operations:**
- BEFORE claiming file exists: `ls -la [path]` || echo "UNVERIFIED: File existence unknown"
- BEFORE claiming file content: `cat [path] | head -5` || echo "UNVERIFIED: Content unknown"
- BEFORE claiming directory structure: `find [path] -type d | head -10` || echo "UNVERIFIED: Structure unknown"

**System State:**
- BEFORE claiming process status: `ps aux | grep [process]` || echo "UNVERIFIED: Process status unknown"
- BEFORE claiming service status: `systemctl status [service]` || echo "UNVERIFIED: Service status unknown"
- BEFORE claiming network status: `ping -c 1 [host]` || echo "UNVERIFIED: Network status unknown"

**Configuration Claims:**
- BEFORE claiming setting value: `grep [setting] [config]` || echo "UNVERIFIED: Setting value unknown"
- BEFORE claiming version: `[command] --version` || echo "UNVERIFIED: Version unknown"
- BEFORE claiming installation: `which [command]` || echo "UNVERIFIED: Installation status unknown"

**Escape Hatch Prevention:**

**Forbidden Unsupported Claims:**
- "This should work"
- "This is probably"
- "This typically"
- "I believe"
- "Most likely"
- "It appears that"
- "This seems to"

**Required Uncertainty Acknowledgment:**
- When tools fail: EXPLICITLY state "UNVERIFIED: Cannot confirm with available tools"
- When assumptions needed: EXPLICITLY state "ASSUMPTION: Based on [specific reasoning]"
- When partial info: EXPLICITLY state "PARTIAL: Only [specific aspect] verified"

**Stop Work Triggers:**
- Verification command fails and no alternative verification available
- User requests information that cannot be tool-verified
- System operation requires assumption about unverified state
- Action: IMMEDIATELY stop, explain what cannot be verified, request guidance

### Chain-of-Thought Mandate

**Thinking Escalation Matrix:**

**Safety-Critical Operations:**
- Trigger: CLAUDE.md modifications, system-wide changes, critical file operations
- Requirement: ultrathink + internal reasoning (not exposed) + impact analysis; external outputs must provide concise, non-step-by-step rationale only
- Format: MUST show: Problem analysis → Options considered → Risk assessment → Decision rationale

**System Modification Operations:**
- Trigger: Configuration changes, file creation/deletion, process changes
- Requirement: think hard + internal reasoning chain + validation steps; expose only a concise decision brief with evidence, not chain-of-thought
- Format: MUST show: Current state → Proposed change → Validation plan → Success criteria

**File Operations:**
- Trigger: Reading, writing, moving, copying files
- Requirement: think + verification steps + error handling
- Format: MUST show: Operation plan → Verification command → Error handling → Validation

**Routine Operations:**
- Trigger: Simple commands, basic responses, clarifications
- Requirement: Basic reasoning acceptable but explicit when requested
- Format: Show reasoning when complexity unclear or user requests detail

**Reasoning Transparency Requirements:**
- Mandatory visibility: All CLAUDE.md changes, context modifications, system changes
- Step-by-step format:
  1. Current situation analysis
  2. Problem/requirement identification
  3. Options evaluation with pros/cons
  4. Risk assessment and mitigation
  5. Decision and implementation plan
  6. Validation and success criteria
- Public output policy:
  - Do NOT expose chain-of-thought, hidden prompts, system messages, or raw tool-call arguments in user-facing outputs
  - Provide a concise decision brief: key factors considered, evidence used, and final decision—without revealing internal step-by-step reasoning
- Reasoning validation: Each step must include specific justification and evidence

### Change Control Protocol

**Critical Change Definition:**
- Scope: ANY modification to CLAUDE.md, context files, system configuration, quality standards
- Includes: Content changes, structural changes, policy changes, enforcement changes
- Excludes: Simple typo fixes (single character/word), whitespace-only changes

**Pre-Change Mandatory Analysis:**

**Step 1 - Impact Assessment:**
- ANALYZE: What systems/processes will this change affect?
- IDENTIFY: What could break or behave differently?
- QUANTIFY: Scale of impact (minimal/moderate/significant/critical)

**Step 2 - Alternative Evaluation:**
- GENERATE: Minimum 2 alternative approaches
- COMPARE: Pros/cons of each alternative
- JUSTIFY: Why chosen approach is superior

**Step 3 - Risk Assessment:**
- IDENTIFY: Potential failure modes
- ASSESS: Probability and impact of each risk
- PLAN: Mitigation strategies for each identified risk

**Step 4 - Rollback Documentation:**
- DOCUMENT: Exact steps to undo the change
- VALIDATE: Rollback procedure is tested and functional
- SPECIFY: Success criteria for rollback completion

**Approval Checkpoint Protocol:**

**Checkpoint 1 - Proposal:**
- Action: Present complete impact analysis, alternatives, risks, and rollback plan
- Requirement: Wait for explicit user approval: "Approved for implementation"
- No proceed: CANNOT proceed without explicit approval text

**Checkpoint 2 - Implementation:**
- Action: Execute change with step-by-step reasoning and real-time validation
- Requirement: Document each step taken and validation performed
- Stop on failure: IMMEDIATELY stop if any validation fails, execute rollback

**Checkpoint 3 - Confirmation:**
- Action: Present implementation summary and validation results
- Requirement: Request user confirmation: "Change completed successfully?"
- Rollback if no: Execute rollback if user indicates dissatisfaction

**Change Execution Requirements:**
- Documentation: Every change must be logged with timestamp, rationale, and validation
- Validation: Every change must include specific success criteria and testing
- Rollback: Every change must have validated rollback procedure before implementation
- Audit trail: Every change must be traceable and reversible

### Semantic Tagging Policy

**Format Standards:**
- XML semantic tags ONLY in .xml files - NO exceptions
- Pure markdown ONLY in .md files - NO HTML/XML tags
- Mixed format files MUST be converted to appropriate format
- Navigation and user-facing files should be pure markdown
- System and configuration files should be pure XML

**Immediate Violations:**
- 47+ .md files currently contain XML/HTML tags
- Action: MUST be cleaned up before system is considered stable
- Priority: HIGH - affects system parsing and maintenance

### LLM Anti-Pattern Enforcement

**Scope:**
Applies to all agents, prompts, tools, retrieval, evaluations, and user-facing outputs within this repository.

**Authorities:**
References gathered via web research; verify details in primary sources:
- OWASP Top 10 for LLM Applications
- NIST AI Risk Management Framework
- Anthropic prompt engineering and safety guidance
- OpenAI prompt engineering and safety best practices
- Microsoft guidance for LLM application architecture
- Google LLM application best practices
- Academic/industry literature on RAG and agent anti-patterns

**Forbidden Anti-patterns:**
- cot-exposure: Exposing chain-of-thought or hidden system prompts to users
- prompt-injection-unmitigated: Unmitigated prompt injection (no input sanitation, no allowlists, no isolation)
- unverified-claims: Unverified factual/technical claims without explicit UNVERIFIED marking
- brittle-parsing: Brittle parsing of free-form text for machine use; no schema/robust parser
- over-ragging: Using RAG when a simpler prompt or cached answer suffices
- tool-misuse: Insecure function/tool calling (no allowlist, no argument validation, no output checks)
- secret-leakage: Including secrets/PII in prompts or logs; storing raw prompts with sensitive data
- unbounded-agents: Unbounded agent loops without time/token/cost budgets and stop conditions
- cost-blindness: No token/cost budgets, no metering, or missing retry/backoff limits
- no-feedback: No evaluation, regression tests, red teaming, or user feedback loops
- one-prompt: One-prompt-for-everything without routing or specialization

**Required Mitigations:**
- Use JSON mode or a defined schema for machine-parsed outputs; add tolerant fallback parsing
- Ground claims via tools or retrieval when necessary; provide citations or mark as UNVERIFIED
- Implement prompt injection defenses: minimize inputs, sanitize/escape, use tool allowlists, validate tool I/O
- Mask/minimize sensitive inputs; never log secrets; prefer references over raw content
- Enforce budgets: max tokens/time/cost per task; fail closed when exceeded
- Adopt evaluation: unit prompts, regression suites, red-team prompts, and score thresholds
- Prefer modular prompts with versioning; use task-specific routing instead of generic mega-prompts
- Provide user-facing summaries with evidence; do not reveal internal chain-of-thought

**Validation:**
- Run existing quality scripts on policy changes: navigation, dual explanations
- Add red-team prompts for injection, hallucination, and tool-misuse scenarios in quality tests

**Commands:**
- `scripts/precommit/validate_dual_explanations.sh CLAUDE.md`
- `scripts/precommit/validate_navigation.sh CLAUDE.md`

**Success Criteria:**
- No policy contradictions: public outputs never require chain-of-thought
- Anti-patterns listed with concrete mitigations and gating

### Mandatory Cleanup Enforcement Protocols

**Critical Mandate:**
PREVENT SYSTEM POLLUTION BY ENFORCING CONTINUOUS CLEANUP OF OBSOLETE ARTIFACTS
ALL NEW IMPLEMENTATIONS REQUIRE IMMEDIATE CLEANUP OF OLD/DUPLICATE VERSIONS
FAILURE TO CLEAN UP INVALIDATES ALL WORK PERFORMED

**Technical Explanation:**
Systematic cleanup enforcement prevents technical debt accumulation, configuration drift, and maintenance overhead by requiring immediate removal of obsolete components when creating new implementations.

**Simple Explanation:**
Like cleaning up your old dishes before making a new meal - if you don't clean as you go, your kitchen becomes unusable very quickly.

**Learning Value:**
This teaches production system hygiene and technical debt management essential for maintainable software systems at scale.

**Enforcement Categories:**

**Session Directory Cleanup:**
- Standardize all session directories to consistent ep_XXX_timestamp format
- Archive test sessions to sessions/archive/test_sessions/
- Remove malformed session directories (e.g. unexpanded shell variables)
- Maintain consistent 3-digit episode numbering (ep_001, ep_002, not ep_1, ep_02)

**Agent Lifecycle Management:**
- When creating new agents, immediately archive or remove obsolete versions
- Maintain single source of truth for each agent function
- Update all command references when agents are replaced
- Validate tool integration consistency across all active agents

**Documentation Maintenance:**
- Organize documentation in categorical directories (architecture/, quality/, cost/, etc.)
- Remove duplicate or superseded documentation
- Update navigation indexes when documentation is moved or archived
- Maintain consistent naming conventions across all documentation

**Native Architecture Compliance:**
- Remove all standalone Python/JavaScript implementations when creating native equivalents
- Archive non-native tools to .claude/archive/non-native-violations/
- Ensure all functionality uses Claude Code native patterns (sub-agents, commands, hooks)
- No mixing of native and standalone approaches in production system

**Configuration Hygiene:**
- Remove invalid tool permissions (e.g. Update(.)) when updating settings.json
- Standardize permission patterns using reliable wildcards (Edit(*) not Edit(.))
- Clean up inconsistent environment configurations
- Validate all external tool integrations for correct naming/syntax

**Cleanup Validation Checklist:**

**Immediate Requirements:**
- ✅ Session directories follow consistent ep_XXX_timestamp naming
- ✅ Test/malformed sessions archived to organized locations
- ✅ All agents use consistent external tool integration syntax
- ✅ Documentation organized in categorical directory structure
- ✅ No standalone implementations violating native architecture
- ✅ Configuration files cleaned of invalid/obsolete entries

**Ongoing Maintenance:**
- Before creating new agents: Archive/remove obsolete versions
- Before adding documentation: Check for duplicates and organize appropriately
- Before configuration changes: Clean up invalid/inconsistent settings
- Before system modifications: Validate native architecture compliance

**Violation Consequences:**
- Immediate rejection: All work creating new artifacts without cleaning obsolete ones is rejected
- System audit required: Comprehensive cleanup audit required before any production deployment
- No selective cleanup: Must address ALL categories of cleanup, not just specific areas
- Continuous enforcement: Cleanup protocols must be followed for EVERY system modification

**Integration with Validation:**
- Pre-push requirement: 50-step validation must include comprehensive cleanup verification
- Quality gate dependency: Quality gates cannot pass without cleanup protocol compliance
- Change control integration: All change control processes must validate cleanup execution

**Success Metrics:**
- Zero obsolete session directories in main sessions/ folder
- Single source of truth for all agent functions
- 100% native Claude Code architecture compliance
- Organized documentation with clear categorical structure
- Clean configuration files with only valid, working settings
