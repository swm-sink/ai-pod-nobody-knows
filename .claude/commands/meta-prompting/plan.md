# /plan - Strategic Implementation Planning

## Purpose
Create comprehensive implementation plan after exploration and research phases are complete.

## When to Use
- **REQUIRED for:** All implementation tasks, system changes, feature development
- **Forbidden without:** Exploration confidence ≥7/10, research completeness
- **Quality gate:** Plan confidence ≥8/10, complete task breakdown, risk mitigation

## Process

### 1. Requirements Analysis
- Extract specific requirements from exploration/research
- Identify must-have vs nice-to-have features
- Define success criteria and acceptance tests
- Map requirements to implementation priorities

### 2. Architecture Design
- Design system architecture and component interactions
- Identify interfaces, dependencies, and data flows
- Plan for scalability, maintainability, and performance
- Document architectural decisions and trade-offs

### 3. Implementation Strategy
- Break down into logical implementation phases
- Sequence tasks to minimize dependencies
- Identify parallel work streams
- Plan integration points and testing strategy

### 4. Risk Assessment and Mitigation
- Identify technical risks and blockers
- Plan mitigation strategies for each risk
- Define contingency plans for critical failures
- Assess impact of delays or scope changes

## Deliverable
Create implementation plan in `.claude/processes/plan-[project]-[date].md` containing:
- Requirements traceability matrix
- System architecture diagrams and decisions
- Phase-by-phase implementation roadmap
- Risk register with mitigation strategies
- Resource requirements and timeline estimates

## Educational Value
**Technical:** Develops strategic planning skills, systems thinking, and risk management essential for leading complex technical projects.

**Simple:** Like being an architect before building a house - you need detailed blueprints, material lists, construction sequence, and backup plans before starting work.

**Connection:** This teaches project planning and systems design skills that scale from personal projects to enterprise architecture.

## Next Steps
- **Flows to:** `/decompose` for detailed task breakdown, `/validate` for plan review
- **Confidence <8/10:** Refine plan until implementation path is clear
- **High risk items:** Create detailed mitigation plans before proceeding
