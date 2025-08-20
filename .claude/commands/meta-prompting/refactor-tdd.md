# /refactor-tdd - Test-Driven Refactoring

## Purpose
Improve code quality, design, and maintainability while preserving functionality through comprehensive test coverage.

## When to Use
- **REQUIRED for:** After initial TDD implementation, before final assessment
- **Forbidden without:** ≥80% test coverage, all tests passing
- **Quality gate:** Improved design metrics, zero regression, maintained test coverage

## Process

### 1. Establish Refactoring Baseline
- Run complete test suite to establish green baseline
- Document current design metrics (complexity, coupling, cohesion)
- Identify refactoring opportunities and priorities
- Set improvement targets for each metric

### 2. Systematic Refactoring
- Apply single refactoring technique per iteration
- Run tests after each change to detect regressions
- Focus on one improvement area at a time:
  - Extract methods/classes for single responsibility
  - Reduce cyclomatic complexity
  - Eliminate duplication
  - Improve naming and readability

### 3. Design Pattern Application
- Identify opportunities for standard design patterns
- Apply patterns that improve maintainability and extensibility
- Ensure patterns solve real problems, not theoretical ones
- Document pattern choices and their benefits

### 4. Performance and Quality Optimization
- Profile code for performance bottlenecks
- Optimize hot paths while maintaining readability
- Improve error handling and edge case coverage
- Enhance documentation and code comments

## Deliverable
For each refactoring session, produce:
- Improved codebase with better design metrics
- Maintained or improved test coverage
- Performance benchmarks (if applicable)
- Documentation of refactoring decisions and patterns used

## Educational Value
**Technical:** Masters continuous improvement practices, design pattern application, and quality-driven development essential for maintainable software systems.

**Simple:** Like renovating a house while people still live in it - you improve one room at a time, ensuring everything still works, and make it better without breaking what's already good.

**Connection:** This teaches iterative improvement skills and quality mindset that apply to any system or process requiring ongoing enhancement and maintenance.

## Next Steps
- **Flows to:** `/assess` for quality validation, `/validate` for integration testing
- **Regression detected:** Stop immediately, fix, verify tests
- **Quality targets missed:** Continue refactoring until targets achieved
