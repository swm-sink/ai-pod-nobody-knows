# /validate-context - Context Architecture Validation & Mandatory Consolidation

## Purpose
Validate context architecture compliance and execute mandatory consolidation to ensure clean governance state before proceeding with system validation.

## When to Use
- **REQUIRED for:** After integration validation, before system validation
- **Forbidden without:** Successful integration validation results
- **Quality gate:** Context governance 100% compliant, ≤15 files, zero duplication

## Process

### 1. Context Health Assessment
- Execute `/health` to validate context governance compliance
- Verify ≤15 total context files in .claude/context/ directory
- Identify any topic duplication violations
- Assess context maintenance status and unused file detection
- **BLOCKING:** Stop all operations if file limit exceeded

### 2. Context Architecture Validation
- Execute `/context-validate` to verify architecture compliance
- Validate operational purpose documentation for all context files
- Verify zero topic duplication across context architecture
- Confirm context maintenance status and reference integrity
- Check all @ references point to existing, current files

### 3. Mandatory Context Consolidation
- Execute `/consolidate` if ANY context issues identified in steps 1-2
- **MANDATORY:** Cannot skip consolidation if violations found
- Consolidate fragmented documentation using single-source principles
- Update all @ references to point to consolidated files
- Delete redundant files after successful merge validation

### 4. Post-Consolidation Verification
- Re-execute `/health` to confirm consolidation success
- Verify all consolidation targets achieved
- Confirm ≤15 file limit compliance
- Validate zero duplication enforcement
- **FINAL GATE:** Must achieve 100% context compliance

## Deliverable
Create context validation report in `.claude/processes/context-validation-[date].md` containing:
- Context health assessment results
- Architecture compliance verification
- Consolidation actions taken (if any)
- Post-consolidation compliance confirmation
- Context governance certification

## Educational Value
**Technical:** Develops information architecture management, governance automation, and documentation consolidation skills essential for maintainable knowledge systems.

**Simple:** Like organizing your workspace before starting important work - you clean up, put everything in its proper place, and make sure you have what you need to succeed.

**Connection:** This teaches information management and governance skills valuable in any environment requiring organized knowledge and clear documentation standards.

## Next Steps
- **Flows to:** `/validate-system` for end-to-end system validation
- **Context violations found:** MUST resolve violations before proceeding
- **Consolidation required:** Execute mandatory cleanup, cannot be skipped
- **Compliance achieved:** Context architecture ready for system validation

## Critical Requirements
- **Non-negotiable:** Context consolidation MUST be executed if any violations found
- **Zero tolerance:** Cannot proceed to system validation with context violations
- **Mandatory gates:** All context quality gates must pass before continuing
