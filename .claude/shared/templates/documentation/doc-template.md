# Documentation Template - Standard Structure for All Documentation

**Phase:** walk|crawl|run

Standard template for creating consistent, well-structured documentation with XML semantic tagging,
dual explanations (technical + simple), and comprehensive cross-referencing throughout the project.
document type="[guide|reference|tutorial|overview]" version="3.1.0" enhanced="2025-08-13"
Clear, Descriptive Title
numeric-id
foundation|claude-code|ai-orchestration|elevenlabs|operations|quality|prompts
walk|crawl|run
hobbyist|developer|both
high|medium|low
@[previous-file].md
@[related-file-1].md, @[related-file-2].md
@[previous-file].md
@NAVIGATION.md
@[next-file].md
2-3 sentence overview of what this document covers and why it matters.
Include the key learning outcome or purpose.
Main thing reader will understand
Supporting concepts covered
What reader can do after reading

<technical>
Professional description using proper terminology
</technical>
Feynman-style explanation using analogies and everyday language
Clear definition
How it works

**Example:**
Everyday comparison
Clear definition
How it works

**Example:**
Everyday comparison
What you're trying to achieve

-

1. Step with clear action
2. Step with expected result
3. Step with validation
How to know it worked

**Example:**

**Example:**
Simple Example Title
What this demonstrates
Actual code or configuration
What's happening and why


**Example:**
Complex Example Title
What this demonstrates
Actual code or configuration
Detailed breakdown of each part

When to use this
Why it's effective
How to implement
What to watch out for
What goes wrong
Why it happens
How to fix it
How to avoid it
| Command | Purpose | Example |
|---------|---------|---------|
| cmd1 | what it does | example usage |
| cmd2 | what it does | example usage |
- ✅ Important thing to remember
- ⚠️ Common mistake to avoid
- 💡 Pro tip for efficiency
@[must-read-file].md - Why it's important
@[additional-file].md - What it adds
Official docs URL - What to find there
Tutorial URL - What you'll learn
After reading this, proceed to @[next-file].md
Try [specific exercise] to solidify understanding
Consider exploring @[advanced-topic].md when ready
2025-08-13
Template System
Verified against current implementation
Every technical concept must include both technical and simple explanations
**Technical Explanation**: [Professional terminology and implementation details]
**Simple Breakdown**: [Analogies and everyday examples]
Enhance both human readability and LLM comprehension
40% improvement in Claude Code understanding
Structured metadata for automated processing
Consistent navigation and cross-referencing
Use @filename.md format for all internal links
Maintain prev/next/index structure
Include up links to parent directories
All code examples must be tested and working
All external links must be verified and current
All technical claims must be verifiable
All analogies must accurately represent the concept
Step-by-step instructional content
Lookup tables, constants, and specifications
Learning-focused with exercises
High-level conceptual introduction
Accessible language, more context, basic examples
Technical depth, advanced examples, implementation details
Dual-layer explanations with progressive complexity
Foundation concepts, no API dependencies
Basic API integration, limited complexity
Advanced features, full production capabilities

```bash
Replace all placeholder values with actual content
Ensure dual explanations for all technical concepts
Verify all @ file references are correct
Test all code examples for accuracy
Review navigation chains for completeness
Validate XML structure is well-formed

```bash
xmllint --noout filename.xml
grep -o '@[^)]*' filename.xml | sort | uniq
find .claude -name "filename.md" -type f
```


---

*Converted from XML to Markdown for elegant simplicity*
*Original: doc-template.xml*
*Conversion: Mon Aug 18 00:01:18 EDT 2025*
