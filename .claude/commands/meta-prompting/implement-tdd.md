# /implement-tdd - Test-Driven Development Implementation

## Purpose
Execute tasks using Test-Driven Development (TDD) cycle: Red → Green → Refactor.

## When to Use
- **REQUIRED for:** All code implementation, feature development, bug fixes
- **Forbidden without:** Atomic task definition with clear acceptance criteria
- **Quality gate:** All tests pass, code coverage ≥80%, clean implementation

## Process

### 1. RED Phase - Write Failing Test
- Write test that captures desired behavior
- Ensure test fails for right reason (feature not implemented)
- Keep test minimal and focused on single behavior
- Verify test failure message is clear and actionable

### 2. GREEN Phase - Make Test Pass
- Write minimal code to make test pass
- Ignore code quality temporarily (focus on functionality)
- Don't implement features not required by test
- Ensure test passes consistently

### 3. REFACTOR Phase - Improve Code Quality
- Improve code structure while keeping tests green
- Apply design patterns and best practices
- Remove duplication and improve readability
- Ensure all tests still pass after refactoring

### 4. Integration and Validation
- Run full test suite to ensure no regressions
- Validate against original acceptance criteria
- Check integration with existing codebase
- Document any assumptions or limitations

## Deliverable
For each task, produce:
- Comprehensive test suite with ≥80% coverage
- Clean, well-structured implementation
- Documentation of design decisions
- Integration validation results

## Educational Value
**Technical:** Masters Test-Driven Development methodology, quality-first development practices, and systematic approach to building reliable software.

**Simple:** Like learning to drive with an instructor - you practice the right habits from the beginning, catch mistakes immediately, and build confidence through repetition.

**Connection:** TDD teaches discipline, quality mindset, and systematic problem-solving that applies to any field requiring precision and reliability.

## Next Steps
- **Flows to:** `/refactor-tdd` for code improvement, `/assess` for quality validation
- **Test failures:** Debug and fix before proceeding
- **Coverage <80%:** Add missing tests before moving on
