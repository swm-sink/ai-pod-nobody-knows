# /commit - Production Deployment and Change Management

## Purpose
Deploy validated implementations to production with proper change management and documentation.

## When to Use
- **REQUIRED for:** All production deployments and system changes
- **Forbidden without:** Complete validation and stakeholder approval
- **Quality gate:** Zero-downtime deployment, full rollback capability

## Process

### 1. Pre-Deployment Verification
- Confirm all validation gates have passed
- Verify rollback procedures are tested and ready
- Check deployment window and stakeholder notifications
- Ensure monitoring and support teams are ready

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
- Pre-deployment checklist with verification results
- Step-by-step deployment log with timestamps
- Post-deployment validation results
- Change documentation and stakeholder communications

## Educational Value
**Technical:** Masters production deployment practices, change management procedures, and operational discipline essential for reliable system operations.

**Simple:** Like launching a rocket - you follow every procedure exactly, monitor everything carefully, have abort procedures ready, and document everything for future missions.

**Connection:** This teaches operational excellence and change management skills valuable in any environment requiring reliability, accountability, and systematic execution.

## Next Steps
- **Flows to:** `/retrospect` for learning capture and process improvement
- **Deployment issues:** Execute rollback procedures immediately
- **Success confirmed:** Begin monitoring period and support handoff
