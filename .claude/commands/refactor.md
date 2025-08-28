# /refactor - Test-Driven Refactoring

Execute systematic quality-driven refactoring for: **$ARGUMENTS**

## Purpose
Systematically improve code quality, architecture, and maintainability while preserving functionality using evidence-based refactoring frameworks and continuous validation.

## When to Use
- **REQUIRED for:** After implementation phase, before quality assessment, based on technical debt analysis
- **Forbidden without:** Working implementation with ≥80% test coverage, technical debt documentation, and baseline quality metrics
- **Quality gate:** Measurable quality improvement, maintained/improved test coverage ≥80%, zero regressions, architectural consistency

## Process

### 1. Establish Refactoring Baseline
**Using comprehensive baseline establishment:**
- **Test Suite Validation:** Execute complete test suite to establish verified green baseline with coverage analysis and performance benchmarks
- **Quality Metrics Assessment:** Document current design metrics using automated analysis tools (complexity, coupling, cohesion, maintainability index)
- **Technical Debt Analysis:** Identify refactoring opportunities using technical debt assessment and priority matrix based on impact and effort
- **Improvement Target Setting:** Define specific, measurable improvement targets for each quality metric with success criteria and validation methods

**Baseline Documentation:** Create comprehensive baseline report with current state assessment and improvement roadmap

### 2. Systematic Refactoring
**Using disciplined refactoring methodology:**
- **Single-Change Principle:** Apply one refactoring technique per iteration to isolate impact and enable precise regression detection
- **Continuous Validation:** Run automated test suite after each change with immediate rollback capability for regression detection
- **Focused Improvement Areas:** Target one quality dimension per refactoring cycle with measurable improvement validation:
  - **Single Responsibility:** Extract methods/classes using SRP analysis with clear interface definition
  - **Complexity Reduction:** Reduce cyclomatic complexity using structured decomposition and control flow optimization
  - **Duplication Elimination:** Remove code duplication using DRY principle with shared abstraction patterns
  - **Readability Enhancement:** Improve naming, structure, and documentation using readability metrics and code review standards

**Refactoring Quality Gates:** Each refactoring iteration must improve target metric without degrading others

### 3. Design Pattern Application
**Using pattern-driven architecture improvement:**
- **Pattern Opportunity Analysis:** Identify design pattern opportunities using systematic code analysis and architectural assessment
- **Strategic Pattern Application:** Apply patterns that demonstrably improve maintainability, extensibility, and testability with measurable benefits
- **Problem-Solution Validation:** Ensure patterns solve real architectural problems with evidence-based justification, not theoretical improvements
- **Pattern Documentation:** Document pattern choices with architectural decision records including rationale, alternatives, and consequences

**Pattern Quality Gates:** Each pattern application must improve architectural quality metrics with validated benefits

### 4. Performance and Quality Optimization
**Using comprehensive optimization framework:**
- **Performance Profiling:** Profile code using systematic performance analysis to identify actual bottlenecks with measurement data
- **Optimization Strategy:** Optimize performance hotspots while maintaining code readability using evidence-based optimization techniques
- **Robustness Enhancement:** Improve error handling and edge case coverage using fault analysis and defensive programming principles
- **Documentation Excellence:** Enhance code documentation using documentation standards and automated documentation validation

**Optimization Quality Gates:** All optimizations must improve performance metrics without degrading maintainability

## Deliverable
For each systematic refactoring session, produce:
- **Quality-Enhanced Codebase:** Measurably improved code with validated quality metrics (complexity, coupling, maintainability) and architectural consistency
- **Test Suite Excellence:** Maintained or improved test coverage ≥80% with enhanced test quality and regression validation
- **Performance Profile:** Comprehensive performance analysis with benchmarks, optimization results, and performance regression prevention
- **Refactoring Documentation:** Complete documentation including baseline analysis, refactoring decisions, design patterns applied, and architectural improvements with evidence

**Argument Handoff to Next Step:** Pass refactored implementation, quality metrics, and technical debt resolution to `/assess` for comprehensive quality validation

## Educational Value
**Technical:** Masters continuous improvement practices, design pattern application, and quality-driven development essential for maintainable software systems.

**Simple:** Like renovating a house while people still live in it - you improve one room at a time, ensuring everything still works, and make it better without breaking what's already good.

**Connection:** This teaches iterative improvement skills and quality mindset that apply to any system or process requiring ongoing enhancement and maintenance.

## Next Steps
- **Flows to:** `/assess` with enhanced implementation and quality metrics for comprehensive quality assessment and validation
- **Regression Detected:** Immediately halt refactoring, analyze root cause, apply fixes, and verify complete test suite before continuing
- **Quality Targets Not Achieved:** Continue systematic refactoring with focused improvement strategies until all quality targets met with validation
- **Quality Gate:** All refactoring frameworks must achieve improvement targets and quality standards before progression
