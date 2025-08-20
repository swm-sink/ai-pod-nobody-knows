# /explore - Problem Domain Investigation

## Purpose
Comprehensive investigation of unfamiliar or complex problem domains before planning implementation.

## When to Use
- **REQUIRED for:** Unknown domains, new technologies, unclear requirements
- **Forbidden without:** Understanding of problem scope and stakeholder needs
- **Quality gate:** Problem confidence ≥7/10, multiple approaches identified

## Process

### 1. Problem Space Analysis
- Define the core problem clearly
- Identify all stakeholders and their needs
- Map the current state vs desired state
- Research existing solutions and approaches

### 2. Domain Research
- Study relevant technologies and frameworks
- Understand industry best practices
- Identify potential risks and challenges
- Gather expert opinions and case studies

### 3. Constraint Identification
- Technical constraints (performance, compatibility)
- Business constraints (budget, timeline, resources)
- Regulatory or compliance requirements
- User experience requirements

### 4. Approach Evaluation
- List 3+ possible implementation approaches
- Evaluate pros/cons of each approach
- Identify dependencies and prerequisites
- Estimate complexity and effort

## Deliverable
Create exploration document in `.claude/processes/exploration-[topic]-[date].md` containing:
- Problem definition and stakeholder analysis
- Domain research findings with sources
- Constraint analysis
- Recommended approaches with justification
- Confidence assessment (must be ≥7/10)

## Educational Value
**Technical:** Teaches systematic problem analysis, domain research methodology, and stakeholder-driven requirements gathering essential for complex software projects.

**Simple:** Like being a detective before building something - you need to understand the mystery completely before you can solve it properly.

**Connection:** This develops critical thinking and research skills that apply to any technical challenge you'll face in your career.

## Next Steps
- **Flows to:** `/research` for knowledge gaps, `/plan` for implementation planning
- **Confidence <7/10:** Continue exploration until understanding is sufficient
- **Confidence ≥7/10:** Proceed to detailed research or planning phase
