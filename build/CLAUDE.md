# Build System Memory - Deployment & Infrastructure 🏭

<document type="build-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>build</domain>
    <scope>Build automation, deployment tools, and infrastructure management</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>build system work, deployment, infrastructure automation</loads-when>
    <triggers>build|deploy|infrastructure|automation|ci</triggers>
  </metadata>
</document>

## 🎯 BUILD SYSTEM CONTEXT

**Technical:** Build system memory implementing deployment automation, infrastructure provisioning, continuous integration patterns, and production environment management for scalable AI podcast system deployment.

**Simple:** Like having an automated factory that packages everything up and deploys it perfectly every time.

**Connection:** This teaches DevOps practices, deployment automation, and infrastructure as code essential for production AI applications.

---

## 🏭 BUILD ARCHITECTURE

### **Deployment Scripts** - `@scripts/`
<LOAD_IF task="deploy|deployment|production|release">
```yaml
deployment_automation:
  start_claude_script: "Launch Claude Code with proper environment"
  environment_setup: "Production environment initialization"
  dependency_management: "Python and Node.js dependency installation"
  
production_deployment:
  environment_validation: "Verify all required components"
  api_key_verification: "Test all external service connections"
  system_health_check: "Comprehensive pre-deployment validation"
```
</LOAD_IF>

### **Development Tools** - `@tools/`
<LOAD_IF task="tools|development|utilities|helpers">
```yaml
development_tools:
  local_setup: "Developer environment configuration"
  testing_helpers: "Development testing and validation"
  debugging_tools: "System debugging and diagnostics"
  
developer_experience:
  quick_start: "Rapid development environment setup"
  hot_reload: "Development workflow optimization"
  debug_mode: "Enhanced debugging and logging"
```
</LOAD_IF>

### **Infrastructure Scripts**
<LOAD_IF task="infrastructure|provisioning|management|ops">
```yaml
infrastructure_management:
  system_provisioning: "Automated system setup and configuration"
  monitoring_setup: "System monitoring and alerting configuration"
  backup_automation: "Automated backup and recovery systems"
  
operational_excellence:
  health_monitoring: "Continuous system health validation"
  performance_optimization: "Automated performance tuning"
  security_hardening: "Security configuration and validation"
```
</LOAD_IF>

---

## 🔧 BUILD COORDINATION

### **CI/CD Integration**
```yaml
continuous_integration:
  automated_testing: "Run all test suites on changes"
  security_scanning: "Automated secret detection and security validation"
  quality_validation: "Code quality and documentation standards"
  
deployment_pipeline:
  staging_deployment: "Automated staging environment deployment"
  production_validation: "Pre-production system validation"
  rollback_capability: "Automated rollback on deployment failures"
```

### **Environment Management**
- **Development**: Local development environment setup and management
- **Staging**: Staging environment for testing and validation
- **Production**: Production environment deployment and monitoring
- **Disaster Recovery**: Backup and recovery automation

---

*Build memory: Load when working with deployment, infrastructure, or build automation*
