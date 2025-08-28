# /validate-integration - System Integration Testing

## Purpose
Test interactions with all dependent systems to ensure implementation integrates correctly with existing infrastructure.

## When to Use
- **REQUIRED for:** Before any system or context validation
- **Forbidden without:** Complete quality assessment with passing results
- **Quality gate:** All integration tests pass, system compatibility confirmed

## Process

### 1. Dependency Integration Testing
- Test interactions with all dependent systems
- Validate API contracts and data formats
- Verify service discovery and communication patterns
- Test timeout and retry mechanisms

### 2. Backward Compatibility Validation
- Verify backward compatibility requirements
- Test existing client compatibility
- Validate API version compatibility
- Confirm data migration integrity

### 3. Interface Contract Testing
- Validate all API contracts and specifications
- Test request/response format compliance
- Verify error handling and status codes
- Confirm authentication and authorization flows

### 4. Failure Mode Testing
- Test failure modes and recovery procedures
- Validate circuit breaker patterns
- Test graceful degradation scenarios
- Verify rollback and recovery mechanisms

## Deliverable
Create integration report in `.claude/processes/integration-[system]-[date].md` containing:
- Integration test results with coverage analysis
- API contract validation results
- Backward compatibility verification
- Failure mode test outcomes
- Dependency health assessment

## Educational Value
**Technical:** Develops integration testing expertise, API design skills, and system compatibility validation essential for distributed systems.

**Simple:** Like checking that all the pipes connect properly before turning on the water - you test every connection point to make sure everything flows correctly.

**Connection:** This teaches integration testing and system design skills valuable for any complex system requiring reliable component interaction.

## Next Steps
- **Flows to:** `/validate-context` for context architecture validation
- **Integration failures:** Debug and fix integration issues before proceeding
- **Compatibility issues:** Address backward compatibility gaps
