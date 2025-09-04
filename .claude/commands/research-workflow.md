# /research-workflow - MCP-Native Research Pipeline

Execute comprehensive research using native Claude Code MCP integration for current, verified information with zero training data reliance.

## Usage

```bash
/research-workflow [episode_number] [topic]
```

## Example

```bash
/research-workflow 1 "The Dirty Secret: Even the Experts Are Making It Up"
```

## Purpose

Execute zero-training-data research pipeline using MCP tools for current, verified information with automatic source citation and fact-checking.

## MCP Research Pipeline

Streamlined research orchestration using native MCP integration:

### Step 1: MCP Deep Investigation
```yaml
agent: researcher
mcp_tool: "mcp__perplexity-ask__perplexity_ask"

research_execution:
  discovery_queries: "2 broad landscape exploration queries"
  investigation_queries: "3 focused technical analysis queries"
  verification_queries: "1-2 fact-checking and validation queries"
  source_requirement: "2024-2025 current information ONLY"
  
benefits:
  - No API key management required
  - Built-in source verification and dating
  - Automatic citation generation
  - Real-time access to current expert statements
  - Native Claude Code integration reliability
```

### Step 2: MCP Fact Verification
```yaml
agent: fact-checker
mcp_tool: "mcp__perplexity-ask__perplexity_ask"

verification_process:
  triangulation: "Cross-reference claims across multiple current sources"
  contradiction_detection: "Identify conflicting expert positions"
  quote_authentication: "Verify exact quotations and institutional context"
  statistical_validation: "Confirm numerical claims with official data"
  
benefits:
  - Automatic multi-source cross-referencing
  - Built-in credibility assessment
  - Real-time verification against current sources
  - Integrated citation management
```

### Step 3: Knowledge Synthesis
```yaml
agent: synthesizer
input_sources: "MCP-verified research findings"

synthesis_approach:
  intellectual_humility: "Balance known/unknown/uncertain elements"
  narrative_coherence: "Production-ready knowledge packaging"
  expert_integration: "Verified quotes with current credentials"
  uncertainty_mapping: "Explicit documentation of research gaps"
```

## Session Management

```yaml
session_structure:
  directory: nobody-knows/production/ep_{number}_{timestamp}/research/
  outputs:
    - research_findings.json
    - validation_report.json
    - synthesis_package.json
    - research_metrics.json
```

## Quality Gates

- **Research Depth**: ≥9.0/10 comprehensive coverage
- **Source Authority**: ≥90% verification rate
- **Expert Diversity**: 10+ sources from multiple institutions
- **Fact Accuracy**: 100% verified claims
- **Brand Alignment**: Intellectual humility integrated

## Cost Tracking

- **Budget Allocation**: $1.35 research phase
- **Perplexity Queries**: 3-5 Sonar-Deep calls
- **WebSearch Validation**: 2-3 verification searches
- **Cost Monitoring**: Real-time via hooks

## Error Handling

```yaml
retry_strategy:
  max_attempts: 3
  backoff: exponential
  fallback: alternative_sources

recovery_points:
  - After each agent completion
  - Session state preserved
  - Partial results saved
```

## Output Schema

```json
{
  "episode_number": 1,
  "topic": "...",
  "research_quality": 9.2,
  "sources_count": 15,
  "expert_quotes": 12,
  "knowledge_gaps": 3,
  "cost": 1.25,
  "session_id": "ep_001_20250901_1000"
}
```

## Native Claude Code Pattern

This command demonstrates proper orchestration where:
- The command coordinates workflow
- Agents handle specialized tasks
- Direct invocation (not Task delegation)
- Clean separation of concerns

---

**Technical**: Command-level orchestration with specialized agent invocation for comprehensive research pipeline execution.

**Simple**: Like a research coordinator who assigns specific tasks to expert researchers, fact-checkers, and editors.

**Connection**: This teaches workflow orchestration and specialization patterns essential for complex AI systems.
