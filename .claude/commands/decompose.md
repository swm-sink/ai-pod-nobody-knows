# /decompose - Task Decomposition and Sequencing

Execute systematic task decomposition for: **$ARGUMENTS**

## Purpose
Break complex implementation plans into atomic, testable, independently executable tasks using structured decomposition frameworks and dependency optimization.

## When to Use
- **REQUIRED for:** Any task >2 hours, complex features, multi-component changes based on validated implementation plans
- **Forbidden without:** Complete implementation plan with ≥8/10 confidence, architectural decisions, and risk mitigation strategies
- **Quality gate:** All tasks <4 hours, clear dependencies mapped, testable outcomes defined, parallel execution optimized

## Process

### 1. Task Identification
**Using atomic decomposition framework:**
- **Work Item Extraction:** Systematically extract all work items from implementation plan with explicit traceability to architectural components
- **Atomic Unit Definition:** Define atomic units using single responsibility principle with clear input/output boundaries and isolated testing capability
- **Outcome Specification:** Ensure each task has single, measurable, testable outcome with explicit acceptance criteria and validation methods
- **Complexity Validation:** Eliminate compound tasks by decomposing multi-skill requirements into single-skill atomic units

**Task Quality Gates:** All tasks must pass atomicity test: "Can this task be completed independently by one person with one skillset in <4 hours?"

### 2. Dependency Mapping
**Using systematic dependency analysis:**
- **Prerequisite Identification:** Map all task prerequisites using dependency taxonomy (data, functional, resource, temporal dependencies)
- **Dependency Graphing:** Create directed acyclic graph (DAG) showing all inter-task relationships with blocking/enabling relationships
- **Parallel Opportunity Analysis:** Identify independent task clusters that can execute concurrently without conflicts
- **Integration Point Planning:** Define explicit handoff protocols and integration testing requirements between dependent tasks

**Critical Path Analysis:** Identify critical path through dependency graph with float time calculation and bottleneck identification

### 3. Task Specification
**Using structured task definition framework:**
- **Task Description Template:** Write clear descriptions using standardized template (Purpose, Inputs, Process, Outputs, Acceptance Criteria)
- **Input/Output Specification:** Define explicit inputs, outputs, and transformation rules with data format and quality requirements
- **Effort Estimation:** Apply evidence-based estimation techniques (historical data, expert judgment, three-point estimation) with confidence intervals
- **Skill Mapping:** Identify required competencies and tools with proficiency level requirements and availability validation

**Testing Strategy Definition:** Specify validation approach for each task (unit tests, integration tests, acceptance tests) with coverage requirements

### 4. Sequencing Optimization
**Using advanced scheduling framework:**
- **Schedule Optimization:** Order tasks using critical path method (CPM) and resource leveling to minimize project duration and resource conflicts
- **Task Clustering:** Group related tasks using affinity analysis to maximize efficiency and minimize context switching overhead
- **Bottleneck Management:** Identify and mitigate potential bottlenecks using theory of constraints and resource buffering strategies
- **Resource Planning:** Optimize resource allocation using capacity planning and skills matrix with workload balancing across team members

**Performance Optimization:** Minimize total project time while maintaining quality gates and resource constraints

## Deliverable
Create task breakdown in `.claude/processes/decomposition-[project]-[date].md` containing:
- **Atomic Task Registry:** Complete task list with unique IDs, standardized descriptions, and traceability to implementation plan components
- **Dependency Architecture:** Visual dependency graph (DAG) with critical path analysis, parallel execution clusters, and bottleneck identification
- **Task Specifications:** Detailed specifications per task including acceptance criteria, testing approach, input/output definitions, and skill requirements
- **Execution Framework:** Optimized execution plan with resource allocation, timeline estimates, and integration strategy
- **Quality Assurance Plan:** Validation approach for each task with coverage requirements and quality gates

**Argument Handoff to Next Step:** Pass atomic task breakdown, dependency graph, and execution framework to `/implement` for systematic TDD-based execution

## Educational Value
**Technical:** Develops work breakdown structure skills, dependency analysis, and project decomposition essential for managing complex software projects.

**Simple:** Like organizing a complex recipe - you need to break it into individual steps, figure out what can be done in parallel, and ensure nothing is forgotten.

**Connection:** This teaches project management and systems analysis skills valuable in any role requiring complex work coordination.

## Next Steps
- **Flows to:** `/implement` with atomic task specifications and dependency framework for systematic TDD-based execution
- **Non-Atomic Tasks:** Further decompose any tasks >4 hours using atomic decomposition framework until all pass atomicity gates
- **Complex Dependencies:** Create detailed integration testing plan with validation protocols before proceeding
- **Quality Gate:** All decomposition frameworks must achieve minimum atomicity and dependency mapping standards
