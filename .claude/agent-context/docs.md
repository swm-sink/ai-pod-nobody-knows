# Documentation Directory Context

## Purpose
This directory contains comprehensive documentation for the AI podcast production system, organized by functional areas and concerns.

## Documentation Structure

### Architecture Documentation (`architecture/`)
- `architecture.md` - Complete system architecture overview
- Component interactions and data flow
- Native Claude Code patterns and orchestration
- MCP integration architecture

### Reference Documentation (`reference/`)
- `CLAUDE_CODE_PERMISSION_PATTERNS.md` - Permission and security patterns
- `MAINTENANCE_PROCEDURES.md` - System maintenance and operations
- API references and integration guides
- Tool usage patterns and best practices

### Cost Management (`cost/`)
- `COST_TRACKING_SYSTEM.md` - Complete cost tracking implementation
- Budget allocation and optimization strategies
- Real-time monitoring and analytics
- Financial intelligence and reporting

### Development Documentation (`development/`)
- `CLAUDE_CODE_EXECUTION_PLAN.md` - Development and execution planning
- Implementation guidelines and standards
- Quality assurance procedures
- Testing and validation frameworks

### Navigation and Discovery
- `NAVIGATION_INDEX.md` - Master navigation for all documentation
- `README.md` - Documentation overview and quick start
- Cross-references and integration points

## Documentation Standards

### Format Requirements
- Markdown format with consistent structure
- Teaching format: Technical/Simple/Connection explanations
- Code examples and usage patterns
- Cross-references using @ notation

### Content Principles
- Avoid duplication - single source of truth
- Focus on actionable guidance
- Include real examples and patterns
- Maintain current and accurate information

### Integration Points
- Referenced from CLAUDE.md using @ notation
- Integrated with context management system
- Supports on-demand loading patterns
- Links to implementation files and examples

## Usage Patterns

Documentation is loaded on-demand using:
- `@.claude/docs/[category]/[file].md` - Direct file reference
- Context-aware loading based on current task
- Navigation index for discovery and exploration
- Cross-reference following for related information

## Quality Standards

All documentation must:
- Be accurate and up-to-date
- Provide clear actionable guidance
- Include relevant examples
- Maintain consistency with system architecture
- Support the single-source-of-truth principle
