# /validate - Integration and Production Validation

## Purpose
Ensure implementation integrates correctly with existing systems and meets production readiness standards.

## When to Use
- **REQUIRED for:** Before any production deployment or system integration
- **Forbidden without:** Complete quality assessment with passing results
- **Quality gate:** All integration tests pass, production readiness confirmed

## Process

### 1. Integration Testing
- Test interactions with all dependent systems
- Validate API contracts and data formats
- Verify backward compatibility requirements
- Test failure modes and recovery procedures

### 2. Production Environment Validation
- Deploy to staging environment identical to production
- Run full system tests in production-like conditions
- Validate performance under expected load
- Test monitoring, logging, and alerting systems

### 3. Operational Readiness
- Verify deployment procedures and rollback plans
- Test disaster recovery and backup systems
- Validate monitoring dashboards and alerts
- Confirm support team knowledge and procedures

### 4. Acceptance Testing
- Conduct final user acceptance testing
- Validate business requirements and use cases
- Confirm compliance with regulatory requirements
- Get stakeholder sign-off for production deployment

## Deliverable
Create validation report in `.claude/processes/validation-[system]-[date].md` containing:
- Integration test results with coverage analysis
- Production readiness checklist with verification
- Performance benchmarks and load test results
- Stakeholder approval and sign-off documentation

## Educational Value
**Technical:** Develops production deployment skills, integration testing expertise, and operational readiness practices essential for enterprise software delivery.

**Simple:** Like a final dress rehearsal before opening night - you run through everything exactly as it will be in the real performance to catch any last-minute issues.

**Connection:** This teaches validation and verification skills that apply to any high-stakes situation requiring reliability, preparation, and stakeholder confidence.

## Next Steps
- **Flows to:** `/commit` for production deployment, `/retrospect` for learning capture
- **Integration failures:** Debug and fix integration issues before proceeding
- **Production concerns:** Address operational readiness gaps before deployment
