# /decompose - Task Decomposition and Sequencing

## Purpose
Break complex implementation plans into atomic, testable, independently executable tasks.

## When to Use
- **REQUIRED for:** Any task >2 hours, complex features, multi-component changes
- **Forbidden without:** Complete implementation plan with ≥8/10 confidence
- **Quality gate:** All tasks <4 hours, clear dependencies, testable outcomes

## Process

### 1. Task Identification
- Extract all work items from implementation plan
- Identify atomic units of work (single responsibility)
- Ensure each task has single, testable outcome
- Remove compound tasks requiring multiple skills

### 2. Dependency Mapping
- Identify prerequisites for each task
- Map inter-task dependencies and blockers
- Identify parallel execution opportunities
- Plan integration points and handoffs

### 3. Task Specification
- Write clear task descriptions with acceptance criteria
- Define inputs, outputs, and validation steps
- Estimate effort and identify required skills
- Specify testing approach for each task

### 4. Sequencing Optimization
- Order tasks to minimize idle time and blockers
- Group related tasks for efficiency
- Identify critical path and potential bottlenecks
- Plan resource allocation and workload distribution

## Deliverable
Create task breakdown in `.claude/processes/decomposition-[project]-[date].md` containing:
- Task list with unique IDs and clear descriptions
- Dependency graph with critical path highlighted
- Acceptance criteria and testing approach per task
- Effort estimates and resource requirements
- Parallel execution plan and integration strategy

## Educational Value
**Technical:** Develops work breakdown structure skills, dependency analysis, and project decomposition essential for managing complex software projects.

**Simple:** Like organizing a complex recipe - you need to break it into individual steps, figure out what can be done in parallel, and ensure nothing is forgotten.

**Connection:** This teaches project management and systems analysis skills valuable in any role requiring complex work coordination.

## Next Steps
- **Flows to:** `/implement-tdd` for task execution, `/assess` for progress validation
- **Tasks >4 hours:** Further decompose until atomic
- **Complex dependencies:** Create integration testing plan
