# /plan - Strategic Implementation Planning

Execute strategic implementation planning for: **$ARGUMENTS**

## Purpose
Create comprehensive, evidence-based implementation plan using structured planning frameworks and systematic risk assessment.

## When to Use
- **REQUIRED for:** All implementation tasks, system changes, feature development based on exploration and research
- **Forbidden without:** Exploration confidence ≥7/10, validated research findings, evidence-based approach selection
- **Quality gate:** Plan confidence ≥8/10, complete architectural design, systematic task breakdown, validated risk mitigation

## Process

### 1. Requirements Analysis
**Using evidence-based requirements framework:**
- **Requirements Traceability:** Extract and validate specific requirements from exploration/research findings with explicit source citations
- **Prioritization Matrix:** Categorize requirements using MoSCoW method (Must/Should/Could/Won't) with business value scoring
- **Success Criteria Definition:** Define measurable acceptance criteria with quantitative thresholds and validation methods
- **Requirements Mapping:** Create traceability matrix linking requirements to exploration insights and research recommendations

**Chain-of-Thought Requirements:** For each requirement, document: "Based on [exploration finding] and [research evidence], requirement [X] is [priority] because [reasoning]"

### 2. Architecture Design
**Using systematic architecture framework:**
- **Architecture Decision Records (ADRs):** Document all architectural decisions with context, options considered, and rationale
- **Component Design:** Define system components with clear interfaces, responsibilities, and interaction patterns
- **Dependency Analysis:** Map all dependencies with version requirements, compatibility matrices, and update strategies
- **Quality Attributes:** Plan for scalability, maintainability, performance, and security with measurable targets

**Design Validation:** Each architectural decision must be validated against requirements and research findings with explicit justification

### 3. Implementation Strategy
**Using structured implementation framework:**
- **Phased Delivery:** Break implementation into logical phases with clear value delivery milestones and risk reduction goals
- **Task Sequencing:** Order tasks using dependency analysis and critical path method to minimize blockers and optimize throughput
- **Parallel Workstreams:** Identify independent work packages that can execute concurrently with clear integration points
- **Integration Strategy:** Plan systematic integration approach with testing gates and rollback procedures

**Implementation Quality Gates:** Each phase must have measurable completion criteria and validation checkpoints

### 4. Risk Assessment and Mitigation
**Using comprehensive risk management framework:**
- **Risk Identification:** Systematically identify technical, operational, and business risks using risk taxonomy and stakeholder input
- **Risk Analysis:** Assess each risk using probability×impact matrix with quantitative scoring and uncertainty ranges
- **Mitigation Planning:** Define specific mitigation strategies with owners, timelines, and success measures for each high-priority risk
- **Contingency Planning:** Create detailed contingency plans for critical failure scenarios with clear trigger conditions and response procedures

**Risk Monitoring:** Establish risk tracking framework with regular assessment intervals and escalation procedures

## Deliverable
Create implementation plan in `.claude/processes/plan-[project]-[date].md` containing:
- **Requirements Framework:** Evidence-based traceability matrix with MoSCoW prioritization and measurable acceptance criteria
- **Architecture Blueprint:** System design with ADRs, component diagrams, and dependency analysis validated against research findings
- **Implementation Roadmap:** Phased delivery plan with critical path analysis, parallel workstreams, and integration strategy
- **Risk Management Framework:** Comprehensive risk register with probability×impact assessment and validated mitigation strategies
- **Resource & Timeline Model:** Detailed resource allocation and timeline estimates with confidence intervals and assumption documentation

**Argument Handoff to Next Step:** Pass implementation plan, architectural decisions, and risk framework to `/decompose` for detailed task breakdown

## Educational Value
**Technical:** Develops strategic planning skills, systems thinking, and risk management essential for leading complex technical projects.

**Simple:** Like being an architect before building a house - you need detailed blueprints, material lists, construction sequence, and backup plans before starting work.

**Connection:** This teaches project planning and systems design skills that scale from personal projects to enterprise architecture.

## Next Steps
- **Flows to:** `/decompose` with comprehensive implementation plan and architectural framework for atomic task breakdown
- **Confidence <8/10:** Refine plan with additional architecture analysis and risk mitigation until implementation path achieves confidence threshold
- **High-Risk Items:** Must resolve critical risks with validated mitigation strategies before proceeding to decomposition
- **Quality Gate:** All planning frameworks must achieve minimum quality standards with validated architectural decisions
