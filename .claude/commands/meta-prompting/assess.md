# /assess - Comprehensive Quality Assessment

## Purpose
Evaluate implementation quality against requirements, standards, and best practices before integration.

## When to Use
- **REQUIRED for:** Before any commits, integration, or production deployment
- **Forbidden without:** Complete implementation with full test coverage
- **Quality gate:** All acceptance criteria met, quality standards satisfied

## Process

### 1. Functional Assessment
- Verify all acceptance criteria are satisfied
- Test all user-facing functionality end-to-end
- Validate edge cases and error conditions
- Confirm integration with existing systems

### 2. Technical Quality Assessment
- Code quality metrics (complexity, maintainability, readability)
- Test coverage analysis (line, branch, path coverage)
- Performance benchmarks against requirements
- Security vulnerability assessment

### 3. Standards Compliance
- Coding standards and style guide adherence
- Documentation completeness and accuracy
- Architecture pattern compliance
- Dependency and licensing compliance

### 4. Risk and Impact Analysis
- Identify potential failure modes and impacts
- Assess deployment risks and mitigation strategies
- Evaluate maintenance burden and technical debt
- Consider scalability and future extensibility

## Deliverable
Create assessment report in `.claude/processes/assessment-[task]-[date].md` containing:
- Functional validation results with evidence
- Technical quality metrics and benchmarks
- Standards compliance checklist
- Risk assessment with severity ratings
- Go/no-go recommendation with justification

## Educational Value
**Technical:** Develops quality assurance mindset, systematic evaluation skills, and comprehensive testing practices essential for reliable software delivery.

**Simple:** Like a thorough inspection before buying a house - you check everything works, meets codes, has no hidden problems, and will serve you well long-term.

**Connection:** This teaches critical evaluation and quality assurance skills valuable in any field requiring reliability, compliance, and risk management.

## Next Steps
- **Flows to:** `/validate` for integration testing, `/commit` if quality approved
- **Quality issues found:** Return to appropriate earlier phase for fixes
- **Risk level too high:** Implement additional mitigation before proceeding
