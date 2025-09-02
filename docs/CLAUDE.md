# Documentation Memory - Knowledge Base 📖

<document type="documentation-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>docs</domain>
    <scope>Technical documentation, guides, reports, and knowledge management</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>documentation work, guide creation, knowledge management</loads-when>
    <triggers>documentation|guide|manual|knowledge|reference</triggers>
  </metadata>
</document>

## 🎯 DOCUMENTATION CONTEXT

**Technical:** Documentation system memory implementing knowledge base organization, technical guide management, assessment report tracking, and comprehensive reference systems for AI podcast production education and operation.

**Simple:** Like having a complete library of manuals, guides, and references that help you understand and use every part of the system.

**Connection:** This teaches technical writing, knowledge management, and documentation architecture essential for maintainable AI systems.

---

## 📖 DOCUMENTATION ARCHITECTURE

### **Architecture Documentation** - `@architecture/`
<LOAD_IF task="architecture|system|design|technical">
```yaml
architecture_guides:
  system_architecture: "Overall system design and component relationships"
  agent_patterns: "AI agent design and coordination patterns"
  workflow_design: "Production pipeline architecture"
  integration_patterns: "MCP and external service integration"
```
</LOAD_IF>

### **Deployment Guides** - `@deployment/`
<LOAD_IF task="deployment|setup|installation|configuration">
```yaml
deployment_documentation:
  installation_guide: "Complete system setup and configuration"
  environment_setup: "Development and production environments"
  api_configuration: "External service integration setup"
  troubleshooting: "Common deployment issues and solutions"
```
</LOAD_IF>

### **Development Guides** - `@development/`
<LOAD_IF task="development|implementation|coding|patterns">
```yaml
development_resources:
  implementation_guides: "Step-by-step development instructions"
  coding_standards: "Python and markdown style guidelines"
  testing_procedures: "Quality assurance and validation methods"
  contribution_guidelines: "How to extend and modify the system"
```
</LOAD_IF>

### **Assessment Reports** - `@reports/`
<LOAD_IF task="reports|assessment|analysis|metrics">
```yaml
reporting_system:
  system_assessments: "Comprehensive system analysis reports"
  performance_metrics: "Cost, quality, and efficiency analysis"
  production_reports: "Episode production summaries"
  learning_outcomes: "Educational effectiveness assessments"
```
</LOAD_IF>

---

## 📚 KNOWLEDGE MANAGEMENT

### **Documentation Standards**
```yaml
documentation_patterns:
  technical_simple_connection: "Every concept explained in 3 ways"
  evidence_based: "All claims supported by research or testing"
  practical_focus: "Actionable guidance over theoretical discussion"
  maintenance: "Regular updates to reflect system evolution"
  
quality_standards:
  clarity: "Clear, jargon-free explanations"
  completeness: "Comprehensive coverage of topics"
  accuracy: "Factually correct and up-to-date"
  accessibility: "Usable by different skill levels"
```

### **Reference Architecture**
- **Internal Links**: @ references for seamless navigation
- **External Sources**: URL references to official documentation
- **Cross-References**: Links between related concepts
- **Index Systems**: Master navigation for complex topics

---

*Documentation memory: Load when working with guides, technical writing, or knowledge management*
