# /validate-production - Production Readiness Final Validation

## Purpose
Final validation of complete production readiness including operational procedures, stakeholder approval, and deployment certification.

## When to Use
- **REQUIRED for:** After learning validation, before final commit
- **Forbidden without:** Successful learning validation with all insights captured
- **Quality gate:** Production readiness certified, stakeholder approval obtained

## Process

### 1. Operational Readiness Validation
- Verify deployment procedures and rollback plans are tested and ready
- Confirm disaster recovery and backup systems are operational
- Validate monitoring dashboards and alert configurations
- Ensure support team knowledge and procedures are documented and trained

### 2. Production Environment Certification
- Verify production environment configuration matches staging
- Confirm all security controls and access policies are in place
- Validate resource allocation and scaling configurations
- Ensure compliance with production standards and policies

### 3. Business Requirements Final Validation
- Conduct final user acceptance testing with stakeholders
- Validate all business requirements and use cases are satisfied
- Confirm compliance with regulatory and governance requirements
- Verify performance benchmarks meet business expectations

### 4. Risk Assessment and Mitigation Validation
- Final assessment of production deployment risks
- Validate all identified risks have appropriate mitigation strategies
- Confirm rollback procedures can be executed if needed
- Ensure business continuity plans are ready

### 5. Stakeholder Approval and Sign-off
- Present complete validation results to stakeholders
- Obtain formal production deployment approval
- Document stakeholder sign-off and deployment authorization
- Confirm deployment window and communication plan

## Deliverable
Create production readiness report in `.claude/processes/production-readiness-[release]-[date].md` containing:
- Operational readiness verification checklist
- Production environment certification results
- Business requirements final validation outcomes
- Risk assessment and mitigation plan validation
- Formal stakeholder approval and deployment authorization

## Educational Value
**Technical:** Masters production readiness assessment, operational excellence validation, and stakeholder management essential for enterprise-grade system deployments.

**Simple:** Like the final safety check before a rocket launch - everything must be perfect, everyone must agree, and all systems must be go before the final commitment.

**Connection:** This teaches production readiness validation and stakeholder management skills essential for any high-stakes deployment requiring operational excellence and business confidence.

## Next Steps
- **Flows to:** `/commit` for pure final production deployment
- **Readiness issues:** Address operational gaps before commit authorization
- **Stakeholder concerns:** Resolve approval blockers before proceeding
- **Risk levels too high:** Implement additional mitigation before deployment

## Critical Requirements
- **Production certification:** All operational readiness gates must pass
- **Stakeholder approval:** Formal sign-off required before commit
- **Risk mitigation:** All high-severity risks must have validated mitigation plans
