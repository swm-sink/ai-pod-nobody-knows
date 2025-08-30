# Commands Directory Context

## Purpose
This directory contains slash commands that provide user-facing interfaces to the AI podcast production system. Commands orchestrate multiple agents and provide complete workflows.

## Command Categories

### Production Commands
- `produce-native.md` - Complete episode production with native Claude Code orchestration
- `research.md` - Enhanced multi-stage research pipeline with quality validation
- `research-optimized.md` - Optimized research workflow for efficiency

### Batch Operations
- `batch-research.md` - Batch research for multiple episodes
- `batch-produce.md` - Batch production workflow
- `batch-10.md` - 10-episode batch processing

### Meta-Programming Workflow
- `explore.md` - Initial exploration and discovery
- `plan.md` - Strategic planning and architecture
- `decompose.md` - Task decomposition and breakdown
- `implement.md` - Implementation execution
- `assess.md` - Quality assessment and validation
- `commit.md` - Change commitment and documentation
- `retrospect.md` - Learning integration and improvement

### System Commands
- `status.md` - System health and operational status
- `health.md` - System health monitoring
- `cost-check.md` - Cost tracking and budget analysis
- `simple.md` - Simplified production workflow
- `consolidate.md` - System consolidation utilities

### Validation Commands
- `validate-context.md` - Context file validation
- `validate-integration.md` - Integration testing
- `validate-learning.md` - Learning validation
- `validate-production.md` - Production readiness validation
- `validate-system.md` - System validation
- `context-validate.md` - Context validation utilities
- `episode-validate.md` - Episode validation

### Utility Commands
- `query.md` - System querying and information retrieval
- `refactor.md` - Code refactoring utilities
- `meta-chain.md` - Meta-chaining operations

## Command Standards

### Native Claude Code Patterns
Commands use proper orchestration:
```
Main Chat → Direct Agent Invocation → Specialized agents
```

NOT Task tool delegation patterns.

### Quality Gates
- All production commands validate quality at each stage
- Minimum quality thresholds: 90% overall, 90% brand consistency, 95% accuracy
- Cost tracking and budget management integrated
- Error recovery and resilience built-in

### Budget Management
- Episode production target: $8.00
- Research allocation: $1.35
- Quality validation: $1.50
- Audio synthesis: $3.50
- Validation and packaging: $1.25

### Integration Points
- All commands integrate with hook system for observability
- MCP tool inheritance for external service access
- Session management for complete traceability
- Quality metrics and cost tracking throughout

## Usage Patterns

Commands are invoked with `/command-name` syntax and support various parameters for customization and optimization.
