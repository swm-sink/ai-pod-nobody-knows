# Testing Memory - Quality Assurance Systems 🧪

<document type="testing-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>tests</domain>
    <scope>Testing frameworks, quality validation, and system verification</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>testing work, quality validation, system verification</loads-when>
    <triggers>test|testing|validation|verification|quality|qa</triggers>
  </metadata>
</document>

## 🎯 TESTING SYSTEM CONTEXT

**Technical:** Testing system memory implementing quality validation frameworks, automated verification protocols, integration testing patterns, and comprehensive system reliability testing for podcast production quality assurance.

**Simple:** Like having a comprehensive testing lab that checks every part of the system to make sure it works perfectly.

**Connection:** This teaches quality assurance, testing methodologies, and reliability engineering essential for production AI systems.

---

## 🧪 TESTING ARCHITECTURE

### **Unit Testing** - `@unit/`
<LOAD_IF task="unit|component|function|module">
```yaml
unit_testing:
  python_utilities: "Test all src/ utility functions"
  agent_components: "Test individual agent capabilities"  
  configuration: "Test config validation and loading"
  
testing_standards:
  coverage: "≥80% code coverage minimum"
  isolation: "Each test runs independently"
  speed: "Unit tests complete in <30 seconds"
```
</LOAD_IF>

### **Integration Testing** - `@integration/`
<LOAD_IF task="integration|workflow|pipeline|e2e">
```yaml
integration_testing:
  workflow_testing: "Complete workflow execution validation"
  mcp_integration: "External API integration testing"
  agent_coordination: "Multi-agent workflow verification"
  
integration_patterns:
  end_to_end: "Full episode production testing"
  component_integration: "Agent and command integration"
  external_services: "MCP server and API validation"
```
</LOAD_IF>

### **Quality Gates** - `@quality_gates/`
<LOAD_IF task="quality|gates|validation|standards">
```yaml
quality_validation:
  brand_consistency: "Intellectual humility validation"
  technical_accuracy: "Fact verification and source validation"
  engagement_metrics: "Content quality and audience appeal"
  
validation_data:
  test_scripts: "Sample scripts for quality validation"
  consensus_tests: "Multi-evaluator consensus verification"
  readability_tests: "Content accessibility validation"
```
</LOAD_IF>

### **Error Scenarios** - `@error_scenarios/`
<LOAD_IF task="error|failure|recovery|reliability">
```yaml
error_testing:
  api_failures: "MCP connection failure recovery"
  cost_overruns: "Budget exceeded scenarios"
  quality_failures: "Below-threshold content handling"
  
recovery_validation:
  checkpoint_restore: "State recovery from failure points"
  graceful_degradation: "System behavior under stress"
  error_reporting: "Clear error communication"
```
</LOAD_IF>

---

## 📊 TESTING COORDINATION

### **Validation Pipeline**
```yaml
testing_workflow:
  pre_production: "Validate all components before episode creation"
  runtime_validation: "Real-time quality checking during production"
  post_production: "Comprehensive validation of final output"
  
continuous_validation:
  automated_testing: "Regular system health verification"
  regression_testing: "Ensure changes don't break existing functionality"
  performance_testing: "Monitor cost and speed efficiency"
```

### **Quality Standards**
- **System Tests**: All major workflows must pass automated testing
- **Integration Tests**: External API integrations validated regularly
- **Quality Gates**: Content quality validation before publication
- **Performance Tests**: Cost and speed efficiency monitoring

---

*Testing memory: Load when working with quality assurance, system validation, or reliability testing*
