# /validate-system - End-to-End System Validation

Execute comprehensive system validation for: **$ARGUMENTS**

## Purpose
Validate complete system functionality in production-like environments using systematic testing frameworks and performance benchmarking to ensure end-to-end system reliability and operational excellence.

## When to Use
- **REQUIRED for:** After context validation, before learning validation
- **Forbidden without:** Successful context architecture validation (100% compliant)
- **Quality gate:** All system tests pass, performance benchmarks met

## Process

### 1. Staging Environment Deployment
- Deploy to staging environment identical to production
- Verify all components deployed correctly
- Confirm environment configuration matches production
- Validate resource allocation and scaling parameters

### 2. End-to-End System Testing
- Run complete system tests in production-like conditions
- Test full user workflows and business processes
- Validate cross-component data flows and interactions
- Confirm system behavior under normal operating conditions

### 3. Performance and Load Validation
- Validate performance under expected load conditions
- Test system responsiveness and throughput benchmarks
- Verify resource utilization within acceptable limits
- Confirm scalability patterns work as designed

### 4. Monitoring and Observability Testing
- Test monitoring, logging, and alerting systems
- Verify metric collection and dashboard functionality
- Validate alert thresholds and notification channels
- Confirm observability stack captures system health

### 5. Data Integrity and Consistency Testing
- Validate data integrity across system components
- Test data consistency and synchronization mechanisms
- Verify backup and recovery procedures work correctly
- Confirm data validation and error handling

## Deliverable
Create system validation report in `.claude/processes/system-validation-[date].md` containing:
- **Production Environment Certification:** Complete staging deployment verification with environment parity validation and configuration compliance
- **System Integration Validation:** Comprehensive end-to-end test results with workflow verification and cross-component interaction validation
- **Performance Certification:** Performance benchmarks, load testing outcomes, and scalability validation with quantitative metrics
- **Observability Validation:** Complete monitoring, alerting, and logging system verification with dashboard functionality confirmation
- **Data Integrity Assurance:** Data consistency validation, backup verification, and recovery procedure testing with integrity confirmation

**Argument Handoff to Next Step:** Pass system validation results and performance certification to `/validate-learning` for learning capture and process validation

## Educational Value
**Technical:** Develops end-to-end testing expertise, performance validation skills, and production environment management essential for reliable system operations.

**Simple:** Like test-driving a car on all types of roads before buying it - you want to make sure everything works perfectly in real-world conditions.

**Connection:** This teaches comprehensive system validation and performance testing skills valuable for ensuring reliable, scalable systems in any technical environment.

## Next Steps
- **Flows to:** `/validate-learning` for learning capture and process validation
- **System failures:** Debug and fix system issues before proceeding
- **Performance issues:** Address performance gaps before learning validation
- **Monitoring problems:** Fix observability issues before proceeding
