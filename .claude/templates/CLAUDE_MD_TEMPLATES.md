# CLAUDE.md Templates - Memory Creation Templates 📝

<document type="template-system" version="1.0.0">
  <metadata>
    <purpose>Templates for creating hierarchical CLAUDE.md memory files</purpose>
    <coverage>All memory types and inheritance levels</coverage>
    <usage>Copy template, customize for specific context</usage>
    <optimization>Consistent structure and token efficiency</optimization>
  </metadata>
</document>

## 🎯 TEMPLATE SYSTEM PURPOSE

**Technical:** Standardized templates for creating hierarchical CLAUDE.md memory files across all inheritance levels, ensuring consistent structure, proper metadata configuration, and optimal token utilization while maintaining educational dual explanation requirements.

**Simple:** Like having a collection of blueprints for building different types of memory files - you pick the right blueprint for what you're building and fill in the specific details.

**Connection:** Learning template systems teaches standardization principles and consistency management that are essential for maintaining quality across large, complex projects.

---

## 📋 TEMPLATE CATEGORIES

### **Memory Inheritance Levels**
```
Tier 2: Project Memory (/.claude/CLAUDE.md)
Tier 3: Domain Memory (/.claude/level-*/CLAUDE.md, /.claude/context/*/CLAUDE.md)
Tier 4: Component Memory (/.claude/*/*/CLAUDE.md, /projects/*/CLAUDE.md)
```

### **Template Types**
- **Project Infrastructure Template**: For .claude directory root
- **Domain Memory Template**: For level-* and context/* directories
- **Component Memory Template**: For subdirectories (agents, commands, config)
- **Project Context Template**: For projects/* directories
- **Learning Domain Template**: For educational contexts
- **Production Context Template**: For production-specific contexts

---

## 📝 TEMPLATE 1: PROJECT INFRASTRUCTURE

```markdown
# {DIRECTORY_NAME} - Project Infrastructure Memory 🏗️

<document type="project-infrastructure-memory" version="1.0.0" inherits="/CLAUDE.md">
  <metadata>
    <domain>{directory_path}</domain>
    <scope>Project-wide infrastructure context</scope>
    <inheritance-level>Tier 2 - Project Memory</inheritance-level>
    <selective-loading>false</selective-loading>
    <loads-automatically>true</loads-automatically>
  </metadata>
</document>

## 🎯 INHERITANCE CONTEXT

**Technical:** {Technical description of purpose and scope}

**Simple:** {Simple analogy-based explanation}

**Connection:** {Learning value and transferable skills}

---

## 🏗️ {SYSTEM_NAME} ARCHITECTURE

### **{System Component} Overview**
```
{directory_structure_visualization}
```

### **Memory Inheritance Hierarchy**
```
Master System (/CLAUDE.md)
├── Project Infrastructure (.claude/CLAUDE.md) ← THIS FILE
│   ├── {Subdomain 1} ({path}/CLAUDE.md)
│   └── {Subdomain 2} ({path}/CLAUDE.md)
```

---

## 📋 CORE PRINCIPLES & STANDARDS

@import ../imports/core/project-principles.md
@import ../imports/core/quality-standards.md

---

## {SECTION_TITLE}

{Domain-specific content sections}

---

## ⚡ QUICK ACTIONS

### **Common Tasks**
- **{Task 1}**: @{navigation_link}
- **{Task 2}**: @{navigation_link}

### **Navigation to Components**
- **{Component 1}**: @{path}/CLAUDE.md
- **{Component 2}**: @{path}/CLAUDE.md

---

## 🎓 EDUCATIONAL VALUE

**Technical:** {Technical learning description}

**Simple:** {Simple learning analogy}

**Connection:** {Learning value and skill development}

---

*Navigate {system} efficiently: @{primary_navigation_link} for {purpose}*
```

---

## 📝 TEMPLATE 2: DOMAIN MEMORY

```markdown
# {DOMAIN_NAME} - {PURPOSE} Memory {EMOJI}

<document type="domain-memory" version="1.0.0" inherits="/.claude/CLAUDE.md">
  <metadata>
    <domain>{domain_path}</domain>
    <scope>{Domain-specific scope description}</scope>
    <inheritance-level>Tier 3 - Domain Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>Working in {directory_path} directory</loads-when>
    <{custom_metadata_key}>{custom_metadata_value}</{custom_metadata_key}>
  </metadata>
</document>

## 🎯 DOMAIN CONTEXT

**Technical:** {Comprehensive technical description of domain purpose, architecture, and integration}

**Simple:** {Accessible analogy explaining the domain's role in the larger system}

**Connection:** {Educational value and learning objectives for this domain}

---

## 🏗️ {DOMAIN_NAME} ARCHITECTURE

### **Purpose & Philosophy**
- **Primary Goal**: {Main objective}
- **{Key Aspect 1}**: {Description}
- **{Key Aspect 2}**: {Description}

### **Directory Structure**
```
{domain_directory}/
├── CLAUDE.md                 → This file (domain context)
├── {subdirectory1}/          → {Purpose}
│   ├── CLAUDE.md            → {Specific context}
│   └── {files...}           → {Description}
└── {subdirectory2}/          → {Purpose}
    ├── CLAUDE.md            → {Specific context}
    └── {files...}           → {Description}
```

---

## 📋 CORE PRINCIPLES & STANDARDS

@import ../imports/core/project-principles.md
@import ../imports/core/quality-standards.md
@import ../imports/domain/{domain-specific-import}.md

---

## {DOMAIN_SPECIFIC_SECTIONS}

{Include 2-4 domain-specific sections covering:
- Key concepts and workflows
- Integration patterns
- Quality requirements
- Performance metrics}

---

## 🔗 INTEGRATION POINTS

### **With {Related Domain 1}**
- {Integration description}

### **With {Related Domain 2}**
- {Integration description}

---

## 🎯 LEARNING OBJECTIVES

### **{Skill Category 1}**
- **Technical**: {Technical skill description}
- **Simple**: {Simple skill explanation}
- **Connection**: {Learning value and application}

### **{Skill Category 2}**
- **Technical**: {Technical skill description}
- **Simple**: {Simple skill explanation}
- **Connection**: {Learning value and application}

---

## ⚡ QUICK ACTIONS

### **{Action Category 1}**
- **{Action 1}**: @{link}
- **{Action 2}**: @{link}

### **Navigation to Components**
- **{Component 1}**: @{path}/CLAUDE.md
- **{Component 2}**: @{path}/CLAUDE.md

---

## 🎓 EDUCATIONAL VALUE

**Technical:** {Comprehensive technical learning description}

**Simple:** {Accessible learning analogy}

**Connection:** {Learning value, skill development, and transferability}

---

*Access specialized contexts: @{component1}/CLAUDE.md for {purpose}, @{component2}/CLAUDE.md for {purpose}*
```

---

## 📝 TEMPLATE 3: COMPONENT MEMORY

```markdown
# {COMPONENT_NAME} - {SPECIFIC_PURPOSE} Memory {EMOJI}

<document type="component-memory" version="1.0.0" inherits="/.claude/{parent_domain}/CLAUDE.md">
  <metadata>
    <domain>{full_component_path}</domain>
    <scope>{Component-specific scope}</scope>
    <inheritance-level>Tier 4 - Component Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>Working in {full_directory_path} directory</loads-when>
    <{component_specific_metadata}>{value}</{component_specific_metadata}>
  </metadata>
</document>

## 🎯 COMPONENT CONTEXT

**Technical:** {Detailed technical description of component purpose, functionality, and integration}

**Simple:** {Clear analogy explaining the component's specific role}

**Connection:** {Learning value specific to this component}

---

## 🤖 {COMPONENT_TYPE} ARCHITECTURE

### **{Component} Structure**
```
{component_visualization_or_list}
```

### **{Key Concept 1}**
{Detailed explanation of core component concept}

### **{Key Concept 2}**
{Detailed explanation of secondary component concept}

---

## 📋 CORE STANDARDS

@import ../../imports/core/quality-standards.md
@import ../../imports/templates/{component-type}-standards.md

---

## {COMPONENT_SPECIFIC_SECTIONS}

{Include 2-3 sections covering:
- Component operations
- Integration patterns
- Quality requirements}

---

## 🎯 LEARNING OBJECTIVES

### **{Component Skill 1}**
- **Technical**: {Technical skill for this component}
- **Simple**: {Simple explanation of skill}
- **Connection**: {Why this skill matters}

---

## ⚡ QUICK ACTIONS

### **{Component Operations}**
- **{Operation 1}**: {Description or link}
- **{Operation 2}**: {Description or link}

---

## 🎓 EDUCATIONAL VALUE

**Technical:** {Component-specific technical learning}

**Simple:** {Component-specific simple explanation}

**Connection:** {Component learning value and transferability}

---

*{Component-specific navigation guidance}*
```

---

## 🔧 TEMPLATE CUSTOMIZATION GUIDE

### **Variable Replacements**
```markdown
{DIRECTORY_NAME}     → Actual directory name (e.g., "Level 1 Development Platform")
{DOMAIN_NAME}        → Domain identifier (e.g., "level-2-production")
{PURPOSE}            → Primary purpose (e.g., "Agent Orchestration")
{EMOJI}              → Relevant emoji (e.g., 🤖, 🎙️, 📚)
{directory_path}     → Full path to directory
{domain_path}        → Domain-specific path
{SYSTEM_NAME}        → System or architecture name
```

### **Content Customization**
```markdown
# Required sections for all templates:
- Inheritance context with technical/simple/connection
- Architecture or structure overview
- Core principles & standards (via imports)
- Domain/component-specific content (2-4 sections)
- Learning objectives with dual explanations
- Quick actions and navigation
- Educational value summary
```

### **Import Selection**
```markdown
# Always include:
@import core/project-principles.md      # For all contexts
@import core/quality-standards.md       # For all contexts

# Context-specific imports:
@import domain/{domain-name}.md         # For domain-specific context
@import templates/{component-type}.md   # For component standards
@import technical/{technology}.md       # For technical context
```

---

## 🎓 EDUCATIONAL VALUE

**Technical:** Template system demonstrates standardization patterns, metadata management, and inheritance architecture for scalable documentation systems with consistent structure and optimal token utilization.

**Simple:** Like having a set of forms to fill out - each type of memory file has its own form that ensures you include all the important information in the right format.

**Connection:** This teaches standardization principles, template-driven development, and consistency management that are essential for maintaining quality and efficiency in large-scale software projects.

---

*Use templates for consistency: Copy appropriate template, customize variables and content, maintain dual explanation format throughout*