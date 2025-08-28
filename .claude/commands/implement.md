# /implement - Test-Driven Development Implementation

Execute systematic TDD implementation for: **$ARGUMENTS**

## Purpose
Execute atomic tasks using systematic Test-Driven Development (TDD) methodology with structured Red→Green→Refactor cycles and comprehensive quality validation.

## When to Use
- **REQUIRED for:** All code implementation, feature development, bug fixes based on atomic task decomposition
- **Forbidden without:** Atomic task specifications with clear acceptance criteria, dependency validation, and testing strategy
- **Quality gate:** All tests pass, code coverage ≥80%, clean implementation, integration validation complete

## Process

### 1. RED Phase - Write Failing Test
**Using structured test-first approach:**
- **Behavior-Driven Test Design:** Write test that captures desired behavior from atomic task acceptance criteria with explicit assertions
- **Failure Validation:** Ensure test fails for correct reason (feature not implemented) with clear, actionable error messages
- **Test Minimalism:** Keep test minimal and focused on single atomic behavior with isolated test environment
- **Test Quality Gates:** Verify test failure message provides actionable guidance for implementation with debugging context

**Chain-of-Thought Testing:** For each test, document: "Given [precondition], when [action], then [expected outcome] because [business rule]"

### 2. GREEN Phase - Make Test Pass
**Using minimal implementation strategy:**
- **Minimal Code Strategy:** Write absolute minimum code required to make test pass without implementing unnecessary features
- **Quality Deferral:** Temporarily ignore code quality concerns (focus purely on functionality) with explicit technical debt documentation
- **Scope Control:** Implement only features explicitly required by failing test without gold-plating or feature creep
- **Consistency Validation:** Ensure test passes consistently across multiple runs with stable test environment

**Implementation Tracking:** Document implementation decisions and temporary quality compromises for refactoring phase

### 3. REFACTOR Phase - Improve Code Quality
**Using systematic refactoring framework:**
- **Structure Improvement:** Enhance code structure using design principles (SOLID, DRY, YAGNI) while maintaining green tests
- **Pattern Application:** Apply appropriate design patterns and architectural best practices with explicit pattern documentation
- **Quality Enhancement:** Remove duplication, improve readability, and enhance maintainability with measurable quality metrics
- **Regression Prevention:** Ensure all tests remain green throughout refactoring with continuous test execution

**Refactoring Quality Gates:** Each refactoring must improve at least one quality metric without degrading others

### 4. Integration and Validation
**Using comprehensive validation framework:**
- **Regression Testing:** Execute full test suite including unit, integration, and acceptance tests with coverage analysis
- **Acceptance Validation:** Verify implementation fully satisfies original atomic task acceptance criteria with stakeholder validation
- **Integration Testing:** Validate integration with existing codebase using integration test suite and compatibility checks
- **Documentation Update:** Document implementation decisions, assumptions, and limitations with architecture decision records

**Integration Quality Gates:** All validation checkpoints must pass before considering task complete

## Deliverable
For each atomic task implementation, produce:
- **Test Suite Portfolio:** Comprehensive test coverage ≥80% including unit, integration, and acceptance tests with coverage analysis
- **Production-Ready Implementation:** Clean, well-structured code following SOLID principles with design pattern documentation
- **Architecture Decision Log:** Documentation of implementation decisions, design trade-offs, and technical debt with rationale
- **Integration Validation Report:** Complete validation results including regression testing, acceptance criteria verification, and compatibility confirmation

**Argument Handoff to Next Step:** Pass implementation artifacts, test results, and technical debt documentation to `/refactor` for systematic quality improvement

## Educational Value
**Technical:** Masters Test-Driven Development methodology, quality-first development practices, and systematic approach to building reliable software.

**Simple:** Like learning to drive with an instructor - you practice the right habits from the beginning, catch mistakes immediately, and build confidence through repetition.

**Connection:** TDD teaches discipline, quality mindset, and systematic problem-solving that applies to any field requiring precision and reliability.

## Next Steps
- **Flows to:** `/refactor` with implementation artifacts and technical debt documentation for systematic quality enhancement
- **Test Failures:** Debug and resolve all failing tests with root cause analysis before proceeding
- **Coverage <80%:** Add comprehensive tests to achieve minimum coverage threshold with quality assessment
- **Quality Gate:** All TDD cycles must achieve completion criteria and integration validation before progression
