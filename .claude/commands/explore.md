# /explore - Problem Domain Investigation

Execute comprehensive problem domain investigation for: **$ARGUMENTS**

## Purpose
Systematic investigation of unfamiliar or complex problem domains using structured analysis patterns and chain-of-thought reasoning.

## When to Use
- **REQUIRED for:** Unknown domains, new technologies, unclear requirements
- **Forbidden without:** Understanding of problem scope and stakeholder needs
- **Quality gate:** Problem confidence ≥7/10, multiple approaches identified, structured analysis complete

## Process

### 1. Problem Space Analysis
**Using structured investigation framework:**
- **Problem Definition:** Define the core problem with specific, measurable criteria
- **Stakeholder Mapping:** Identify ALL stakeholders using RACI matrix (Responsible, Accountable, Consulted, Informed)
- **Current vs Future State:** Create detailed state maps showing gaps and transition requirements
- **Solution Landscape:** Research existing solutions with pros/cons analysis and adoption patterns

**Chain-of-Thought Reasoning:** For each analysis point, document: "Given [context], I analyze [factor] because [reasoning], leading to [conclusion]"

### 2. Domain Research
**Using multi-source validation approach:**
- **Technology Assessment:** Study frameworks using compatibility matrix and performance benchmarks
- **Best Practices Research:** Gather industry standards from minimum 5 credible sources with validation scores
- **Risk & Challenge Matrix:** Identify risks with probability×impact scoring and mitigation strategies
- **Expert Opinion Synthesis:** Collect expert insights with source credibility assessment and consensus analysis

**Evidence-Based Documentation:** Every claim must include source, date, and confidence level (High/Medium/Low)

### 3. Constraint Identification
**Using systematic constraint analysis:**
- **Technical Constraints:** Performance requirements, compatibility matrices, scalability limits
- **Business Constraints:** Budget envelopes, timeline dependencies, resource allocation models
- **Regulatory Requirements:** Compliance frameworks, audit requirements, certification needs
- **User Experience Constraints:** Accessibility standards, usability benchmarks, device compatibility

**Impact Assessment:** Rate each constraint's impact on solution options (Blocking/High/Medium/Low)

### 4. Approach Evaluation
**Using structured decision framework:**
- **Minimum 3 Approaches:** List solutions with detailed implementation paths and success criteria
- **Multi-Criteria Analysis:** Evaluate using weighted criteria matrix (feasibility, cost, timeline, risk, maintainability)
- **Dependency Mapping:** Create dependency graphs showing prerequisites, blockers, and critical path
- **Effort Estimation:** T-shirt sizing (S/M/L/XL) with confidence intervals and assumption documentation

**Decision Support Matrix:** Create comparison table with quantitative scoring for objective decision making

## Deliverable
Create exploration document in `.claude/processes/exploration-[topic]-[date].md` containing:
- **Problem Definition Matrix:** Stakeholder analysis with RACI mapping and current/future state documentation
- **Evidence-Based Research:** Domain findings with source validation, credibility scores, and multi-source synthesis
- **Constraint Analysis:** Systematic constraint assessment with impact ratings and mitigation strategies
- **Decision Support Framework:** Minimum 3 approaches with weighted criteria analysis and quantitative scoring
- **Confidence Certification:** Overall confidence ≥7/10 with supporting evidence and assumption validation

**Argument Handoff to Next Step:** Pass exploration findings and recommended approach to `/research` for detailed investigation

## Educational Value
**Technical:** Teaches systematic problem analysis, domain research methodology, and stakeholder-driven requirements gathering essential for complex software projects.

**Simple:** Like being a detective before building something - you need to understand the mystery completely before you can solve it properly.

**Connection:** This develops critical thinking and research skills that apply to any technical challenge you'll face in your career.

## Next Steps
- **Flows to:** `/research` with structured knowledge gap analysis and investigation priorities
- **Confidence <7/10:** Continue structured exploration with specific gap analysis until understanding is sufficient
- **Confidence ≥7/10:** Proceed to `/research` with exploration findings and focused research questions
- **Quality Gate:** All structured analysis frameworks must be complete before progression
