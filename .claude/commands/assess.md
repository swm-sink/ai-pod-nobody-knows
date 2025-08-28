# /assess - Comprehensive Quality Assessment

Execute comprehensive quality assessment for: **$ARGUMENTS**

## Purpose
Systematically evaluate implementation quality against requirements, standards, and best practices using multi-dimensional assessment frameworks before entering validation pipeline.

## When to Use
- **REQUIRED for:** Before 5-step validation pipeline and production deployment, after complete implementation and refactoring
- **Forbidden without:** Complete implementation with ≥80% test coverage, refactored code, and technical documentation
- **Quality gate:** All acceptance criteria validated, quality standards exceeded, comprehensive assessment complete

## Process

### 1. Functional Assessment
**Using comprehensive functional validation framework:**
- **Acceptance Criteria Validation:** Systematically verify all atomic task acceptance criteria using evidence-based validation with quantitative success metrics
- **End-to-End Testing:** Execute complete user journey testing including happy path, alternative flows, and error scenarios with comprehensive coverage
- **Edge Case Validation:** Test boundary conditions, data limits, and exceptional scenarios using structured edge case analysis and validation protocols
- **System Integration Verification:** Confirm seamless integration with existing systems using integration test suites and compatibility validation

**Functional Quality Gates:** All functional requirements must demonstrate 100% compliance with measurable evidence

### 2. Technical Quality Assessment
**Using multi-dimensional quality analysis:**
- **Code Quality Metrics:** Analyze complexity, maintainability, readability using automated tools with industry benchmark comparison and trend analysis
- **Test Coverage Analysis:** Comprehensive coverage assessment including line, branch, path, and mutation testing with quality threshold validation ≥80%
- **Performance Benchmarking:** Execute performance testing against requirements with load testing, stress testing, and resource utilization analysis
- **Security Assessment:** Conduct vulnerability analysis using automated security scanning, dependency analysis, and security best practice validation

**Technical Quality Gates:** All technical metrics must meet or exceed industry standards with documented evidence

### 3. Standards Compliance
**Using systematic compliance validation:**
- **Coding Standards Audit:** Verify adherence to coding standards and style guides using automated linting and manual review with compliance scoring
- **Documentation Quality Assessment:** Validate completeness, accuracy, and maintainability of technical documentation using documentation standards and review criteria
- **Architecture Compliance:** Confirm implementation follows architectural patterns and design principles using architecture decision record validation
- **Dependency Governance:** Assess dependency management, licensing compliance, and security posture using dependency analysis and compliance frameworks

**Compliance Quality Gates:** 100% compliance with organizational standards and industry best practices required

### 4. Risk and Impact Analysis
**Using comprehensive risk assessment framework:**
- **Failure Mode Analysis:** Identify potential failure modes using systematic FMEA analysis with probability, impact, and detection scoring
- **Deployment Risk Assessment:** Evaluate deployment risks using risk matrix analysis with mitigation strategy validation and contingency planning
- **Technical Debt Evaluation:** Assess maintenance burden and technical debt using quantitative debt analysis and remediation priority matrix
- **Scalability Assessment:** Analyze system scalability and extensibility using capacity planning and architectural scalability patterns

**Risk Quality Gates:** All high-priority risks must have validated mitigation strategies with acceptable residual risk levels

## Deliverable
Create assessment report in `.claude/processes/assessment-[task]-[date].md` containing:
- **Comprehensive Functional Validation:** Complete acceptance criteria validation with quantitative evidence, end-to-end test results, and integration verification
- **Technical Quality Profile:** Multi-dimensional quality metrics analysis with industry benchmarks, coverage reports, performance data, and security assessment
- **Compliance Certification:** Standards compliance audit with scoring, documentation quality assessment, and governance validation
- **Risk Management Report:** Complete risk analysis with failure mode assessment, deployment risk evaluation, and technical debt analysis
- **Quality Gate Decision:** Evidence-based go/no-go recommendation with detailed justification and quality certification

**Argument Handoff to Next Step:** Pass comprehensive quality assessment and certification to 5-step validation pipeline (`/validate-integration`)

## Educational Value
**Technical:** Develops quality assurance mindset, systematic evaluation skills, and comprehensive testing practices essential for reliable software delivery.

**Simple:** Like a thorough inspection before buying a house - you check everything works, meets codes, has no hidden problems, and will serve you well long-term.

**Connection:** This teaches critical evaluation and quality assurance skills valuable in any field requiring reliability, compliance, and risk management.

## Next Steps
- **Flows to:** 5-step validation pipeline starting with `/validate-integration` for systematic integration testing and validation
- **Quality Gates Failed:** Return to appropriate earlier phase (implement/refactor) with specific remediation requirements before reassessment
- **Risk Levels Excessive:** Implement validated additional mitigation strategies and conduct risk reassessment before validation pipeline entry
- **Assessment Complete:** Proceed to validation pipeline with comprehensive quality certification and assessment documentation
