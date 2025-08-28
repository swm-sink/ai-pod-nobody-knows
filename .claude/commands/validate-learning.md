# /validate-learning - Learning Capture & Process Validation

## Purpose
Validate process understanding and capture learning insights to ensure readiness for production deployment and continuous improvement.

## When to Use
- **REQUIRED for:** After system validation, before production validation
- **Forbidden without:** Successful system validation with all tests passing
- **Quality gate:** Learning captured, process validated, improvement actions identified

## Process

### 1. Outcome Analysis and Validation
- Compare actual results vs planned objectives
- Validate that success criteria were met
- Identify what worked well and delivered expected value
- Document what didn't work and analyze root causes
- **Validation Gate:** Confirm objectives achieved within acceptable parameters

### 2. Process Effectiveness Validation
- Review effectiveness of each methodology step (explore→research→plan→decompose→implement→refactor→assess)
- Validate that process decisions led to quality outcomes
- Identify bottlenecks, delays, and inefficiencies in the workflow
- Assess resource utilization and timeline accuracy
- **Validation Gate:** Process effectiveness ≥7/10 for production readiness

### 3. Learning Extraction and Knowledge Validation
- Identify key insights and "aha!" moments from the work cycle
- Validate technical knowledge gained against project requirements
- Capture problem-solving approaches that proved effective
- Document patterns and anti-patterns discovered
- **Validation Gate:** Transferable knowledge documented for future use

### 4. Process Improvement Validation and Planning
- Validate that improvement opportunities are actionable
- Identify tools, skills, or knowledge gaps that must be addressed
- Plan experiments to test improvement hypotheses
- Set learning goals for future work cycles
- **Validation Gate:** Improvement plan validates process evolution

### 5. Production Readiness Learning Assessment
- Validate that all learning supports production deployment confidence
- Assess whether knowledge gaps could impact production success
- Confirm that process improvements enhance rather than risk deployment
- Validate that learning outcomes support operational excellence

## Deliverable
Create learning validation report in `.claude/processes/learning-validation-[project]-[date].md` containing:
- Outcome validation with quantitative success metrics
- Process effectiveness assessment with validation scores
- Learning catalog with transferable insights and knowledge validation
- Process improvement plan with production readiness assessment
- Production deployment confidence rating based on learning analysis

## Educational Value
**Technical:** Develops reflective analysis skills, process validation expertise, and continuous improvement practices essential for reliable system development and operational excellence.

**Simple:** Like reviewing your test answers before submitting - you check what you learned, validate your understanding, and make sure you're ready for what comes next.

**Connection:** This teaches reflection, validation, and continuous improvement skills that turn every experience into validated knowledge and better processes for future success.

## Next Steps
- **Flows to:** `/validate-production` for final production readiness validation
- **Learning gaps identified:** Address critical knowledge gaps before production validation
- **Process issues found:** Implement critical process improvements before deployment
- **Confidence <8/10:** Strengthen learning and process understanding before proceeding
