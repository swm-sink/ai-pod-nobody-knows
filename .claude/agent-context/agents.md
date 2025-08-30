# Agents Directory Context

## Purpose
This directory contains all specialized sub-agents for the AI podcast production system. Each agent handles a specific aspect of the production pipeline with full MCP tool inheritance.

## Agent Categories

### Research Agents
- `research-discovery.md` - Strategic research planning and expert discovery
- `research-deep-dive.md` - Comprehensive multi-query investigation
- `research-validate.md` - Fact-checking and source verification
- `research-synthesis.md` - Production-ready knowledge package creation

### Content Creation Agents
- `episode-planner.md` - Episode structure and timing design
- `script-writer.md` - Script creation optimized for Claude 4.1 Opus
- `question-generator.md` - Strategic research question generation

### Quality Assurance Agents
- `claude.md` - Creative content and brand voice evaluation (35% weight)
- `gemini.md` - Technical production and format compliance (30% weight)
- `perplexity.md` - Research accuracy and fact verification (35% weight)
- `brand-validator.md` - Brand consistency and intellectual humility validation
- `ai-quality-predictor.md` - Real-time predictive quality assessment

### Production Agents
- `optimizer.md` - TTS optimization and script preparation
- `polisher.md` - Three-evaluator consensus integration and refinement
- `synthesizer.md` - Professional ElevenLabs audio synthesis
- `synthesizer-direct.md` - Direct API audio synthesis
- `audio-validator.md` - Speech-to-text quality validation

## Native Claude Code Architecture

**Invocation Pattern:**
```
Use the [agent-name] agent to [action]: "specific requirements"
```

**NOT Task Tool Delegation:**
- Agents are invoked directly by the main chat orchestrator
- Each agent has full MCP tool inheritance
- Clean context isolation between agents
- Direct communication for optimal performance

## Agent Standards

### Quality Thresholds
- Overall quality target: ≥9.0/10
- Brand consistency: ≥90%
- Research accuracy: ≥95%
- Cost efficiency: Within allocated budget per phase

### Voice Configuration
- Production Voice ID: ZF6FPAbjXT4488VcRRnw
- Settings: stability=0.65, similarity=0.8, style=0.3
- Duration target: 25-30 minutes

### Brand Voice Requirements
- Intellectual humility integration
- Learning celebration and wonder
- Expert uncertainty acknowledgment
- Accessible complexity management

## Integration with Production Pipeline

All agents work together in the complete production workflow orchestrated by `/produce-episode-native` command with quality validation at each stage.
