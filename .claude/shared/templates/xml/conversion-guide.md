# XML Conversion Guide

## Overview
This guide explains how to convert existing markdown documentation to XML format using the templates and schema provided.

## Template Usage

### 1. Learning Guide Template
**Use for:** Educational content, tutorials, step-by-step guides
**File:** `learning-guide-template.xml`
**Key Features:**
- Dual explanations (technical + simple)
- Step-by-step instructions with validation
- Examples (basic, advanced, anti-pattern)
- Learning outcomes and prerequisites

### 2. Reference Template  
**Use for:** Quick reference, API docs, command references
**File:** `reference-template.xml`
**Key Features:**
- Quick reference sections
- Troubleshooting examples
- Advanced usage patterns
- Validation commands

### 3. Constants Template
**Use for:** Configuration values, quality thresholds, system limits
**File:** `constants-template.xml`
**Key Features:**
- Structured constant definitions
- Quality gates and thresholds
- System limits and constraints
- File naming conventions

### 4. Navigation Template
**Use for:** Domain navigation, learning paths, directory guides
**File:** `navigation-template.xml`
**Key Features:**
- Learning path organization
- Priority-based links
- Quick start guidance
- Cross-domain references

## Conversion Process

### Step 1: Identify Document Type
- **Learning Guide**: Has educational content with explanations
- **Reference**: Primarily lookup information and commands
- **Constants**: Contains configuration values and thresholds
- **Navigation**: Directory structure and learning paths

### Step 2: Extract Content
1. **Title and Metadata**: Extract from headers and frontmatter
2. **Technical/Simple Explanations**: Look for dual explanation patterns
3. **Instructions**: Extract step-by-step procedures
4. **Examples**: Identify code examples and use cases
5. **Cross-references**: Note links to other documents

### Step 3: Map to Template
1. Copy appropriate template
2. Replace `{PLACEHOLDER}` values with extracted content
3. Preserve dual explanation structure
4. Maintain validation commands where present
5. Update cross-references to point to `.xml` files

### Step 4: Validate Structure
1. Ensure XML is well-formed
2. Check against schema if possible
3. Verify all required sections are present
4. Confirm dual explanations are maintained

## Common Patterns

### Dual Explanations
Convert from markdown patterns like:
```markdown
**Technical:** Professional explanation...
**Simple:** Analogy-based explanation...
```

To XML:
```xml
<technical-explanation>
Professional explanation...
</technical-explanation>
<simple-explanation>
Analogy-based explanation...
</simple-explanation>
```

### Code Examples
Convert from:
```markdown
```python
code_example()
```
```

To XML:
```xml
<example type="basic">
    <scenario>What this example demonstrates</scenario>
    <implementation>code_example()</implementation>
    <explanation>Why this works and what it teaches</explanation>
</example>
```

### Cross-references
Convert from:
```markdown
See [Other Guide](../path/other-guide.md)
```

To XML:
```xml
<cross-references>
    <reference file="other-guide.xml" section="relevant-section" type="related">
        Other Guide reference description
    </reference>
</cross-references>
```

## Quality Checklist
- [ ] Document type correctly identified
- [ ] All placeholders replaced with actual content
- [ ] Dual explanations preserved (technical + simple)
- [ ] Validation commands included where applicable
- [ ] Examples categorized appropriately (basic/advanced/anti-pattern)
- [ ] Cross-references updated to `.xml` files
- [ ] XML is well-formed and validates against schema
- [ ] Educational requirements maintained