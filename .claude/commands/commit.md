# /commit - Production Deployment and Change Management

Execute final production deployment for: **$ARGUMENTS**

## Purpose
Deploy validated implementations to production using systematic change management protocols and comprehensive deployment documentation with zero-downtime deployment strategies.

## When to Use
- **REQUIRED for:** All production deployments and system changes
- **Forbidden without:** Complete 5-step validation pipeline success and stakeholder approval
- **Quality gate:** Zero-downtime deployment, full rollback capability

## Process

### 1. Pre-Deployment Verification
- Confirm ALL 5-step validation pipeline has passed (integration→context→system→learning→production)
- Verify rollback procedures are tested and ready
- Check deployment window and stakeholder notifications
- Ensure monitoring and support teams are ready
- **ASSUMPTION:** All context operations completed during validation pipeline

### 2. Deployment Execution
- Follow documented deployment procedures exactly
- Monitor system health throughout deployment
- Validate each deployment step before proceeding
- Document any deviations or issues encountered

### 3. Post-Deployment Validation
- Run smoke tests to verify system functionality
- Monitor performance metrics and error rates
- Confirm all integrations are working correctly
- Validate user-facing features are operational

### 4. Change Documentation
- Create detailed deployment record with timestamps
- Document any configuration changes made
- Update system documentation and runbooks
- Notify stakeholders of successful deployment

## Deliverable
Create deployment record in `.claude/processes/deployment-[release]-[date].md` containing:
- **Deployment Certification:** Complete pre-deployment validation with 5-step validation pipeline confirmation and stakeholder approval documentation
- **Deployment Execution Log:** Step-by-step deployment record with timestamps, system health monitoring, and deviation documentation
- **Production Validation Results:** Post-deployment verification including smoke tests, performance validation, and operational readiness confirmation
- **Change Management Documentation:** Complete change record with stakeholder communications, configuration changes, and operational handoff

**Final Workflow Completion:** All validation pipeline requirements satisfied - deployment complete with operational excellence certification

## Educational Value
**Technical:** Masters production deployment practices, change management procedures, and operational discipline essential for reliable system operations.

**Simple:** Like launching a rocket - you follow every procedure exactly, monitor everything carefully, have abort procedures ready, and document everything for future missions.

**Connection:** This teaches operational excellence and change management skills valuable in any environment requiring reliability, accountability, and systematic execution.

## Next Steps
- **Flows to:** Begin monitoring period and support handoff (learning captured in validation pipeline)
- **Deployment issues:** Execute rollback procedures immediately
- **Success confirmed:** Complete workflow cycle, begin next iteration with learned improvements
