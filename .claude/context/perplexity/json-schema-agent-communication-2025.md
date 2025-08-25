# JSON Schema Design for AI Agent Communication 2024-2025

*Research conducted via Perplexity Sonar Deep Research - August 22, 2025*

## Research Summary

Current best practices for JSON schema design for AI agent communication (2024–2025) center on **interoperability**, **robust validation**, **extensibility**, and **production-grade observability**. These practices are shaped by protocol evolution (Google A2A, MCP), multi-agent orchestration needs, and advanced validation tooling.

## 1. Schema Design Principles

### Layered Structure Approach
Use clear separation of message metadata, intent, and payload with standardized fields:

**Core Required Fields:**
- `id`: Unique message or request ID
- `timestamp`: ISO 8601 format
- `intent`: Describes action (e.g., "query.weather", "evaluate.quality")
- `sender`/`recipient`: Agent identity objects with id, name, type
- `payload`: Task- or domain-specific schema
- Optional: `thread`, `in_reply_to` for conversational context

### Modern Protocol Alignment
- Align with emerging protocols (A2A, MCP) that encourage base schemas with extensible payloads
- **Intention Tagging**: Every message includes explicit `intent`
- **Threading Support**: Multi-turn or stateful dialogues via thread identifiers
- **Agent Discovery**: Metadata for routing and capability discovery

### General Agent Message Schema
```json
{
  "id": "msg-1234",
  "timestamp": "2025-08-22T06:14:26Z",
  "intent": "evaluate.script_quality",
  "sender": { "id": "quality-claude", "name": "Claude Quality Evaluator", "type": "LLM" },
  "recipient": { "id": "consensus-coordinator", "name": "Consensus Coordinator", "type": "Orchestrator" },
  "thread": "episode-001-evaluation",
  "payload": {
    "script_content": "...",
    "evaluation_criteria": ["brand_voice", "technical_accuracy", "engagement"]
  }
}
```

### Design Principles Checklist
- ✅ Layered structure (metadata + intent + payload)
- ✅ Protocol compatibility (A2A/MCP alignment)
- ✅ Explicit intent tagging for all messages
- ✅ Threading support for multi-turn conversations
- ✅ Agent metadata for discovery and routing
- ✅ Extensible payload structure for domain-specific data

## 2. Type Safety and Validation

### Strict JSON Schema Enforcement
Use comprehensive schemas with:
- `type` definitions for all fields (object, string, number, array, boolean)
- `required` arrays for mandatory fields
- Field-specific constraints (format, minimum, maximum, enum values)
- `oneOf`, `anyOf`, `allOf` for complex/heterogeneous payloads
- Pattern validation for structured data (IDs, timestamps, etc.)

### Validation Schema Example
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Agent Message Schema",
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^msg-[a-zA-Z0-9]{8,}$",
      "description": "Unique message identifier"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp"
    },
    "intent": {
      "type": "string",
      "enum": [
        "research.query", "research.synthesize",
        "script.write", "script.polish",
        "quality.evaluate", "consensus.coordinate",
        "audio.synthesize"
      ]
    },
    "sender": {
      "type": "object",
      "properties": {
        "id": { "type": "string" },
        "name": { "type": "string" },
        "type": { "type": "string", "enum": ["LLM", "Tool", "Orchestrator", "Validator"] }
      },
      "required": ["id", "name", "type"]
    },
    "payload": { "type": "object" }
  },
  "required": ["id", "timestamp", "intent", "sender", "payload"]
}
```

### Production Validation Strategy
- **Schema-driven validation libraries**: Use Ajv (JavaScript), Pydantic (Python), Zod (TypeScript)
- **Fail fast on violations**: Return detailed machine-readable error responses
- **Validation at boundaries**: Enforce at every agent interface
- **Runtime schema enforcement**: Use structured output modes when available

### Type Safety Implementation
```python
# Example with Pydantic
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Dict, Any, Literal

class AgentIdentity(BaseModel):
    id: str
    name: str
    type: Literal["LLM", "Tool", "Orchestrator", "Validator"]

class AgentMessage(BaseModel):
    id: str = Field(pattern=r'^msg-[a-zA-Z0-9]{8,}$')
    timestamp: datetime
    intent: str
    sender: AgentIdentity
    recipient: AgentIdentity
    thread: str = None
    payload: Dict[str, Any]
```

## 3. Multi-Agent Communication Patterns

### Standardized Performatives
Adopt intent/action tags aligned with FIPA and modern Agentic AI protocols:

**Research Stream Intents:**
- `research.query`: Perplexity search requests
- `research.synthesize`: Knowledge synthesis tasks
- `question.generate`: Strategic question creation

**Production Stream Intents:**
- `script.write`: Initial script creation
- `script.polish`: Script refinement based on feedback
- `quality.evaluate`: Quality assessment tasks
- `consensus.coordinate`: Multi-evaluator consensus

**System Intents:**
- `cost.track`: Budget monitoring
- `error.handle`: Error recovery
- `status.report`: Progress updates

### Message Threading and Context
```json
{
  "id": "msg-5678",
  "timestamp": "2025-08-22T06:15:30Z",
  "intent": "quality.evaluate",
  "thread": "episode-001-evaluation",
  "in_reply_to": "msg-1234",
  "sender": { "id": "quality-gemini", "name": "Gemini Quality Evaluator", "type": "LLM" },
  "recipient": { "id": "consensus-coordinator", "name": "Consensus Coordinator", "type": "Orchestrator" },
  "payload": {
    "evaluation_results": {
      "technical_accuracy": 0.92,
      "content_structure": 0.88,
      "format_compliance": 0.95
    },
    "feedback": "Strong technical content with minor structural improvements needed"
  }
}
```

### Agent Metadata for Discovery
```json
{
  "agent_registry": {
    "id": "quality-claude",
    "name": "Claude Quality Evaluator",
    "type": "LLM",
    "version": "1.2.0",
    "capabilities": ["brand_voice_evaluation", "creative_assessment"],
    "tools": ["quality_rubric", "brand_voice_analyzer"],
    "cost_per_request": 0.05,
    "average_response_time": "15s"
  }
}
```

## 4. Performance Optimization

### Structural Optimization
- **Flat JSON structures**: Minimize nesting depth to reduce parse time
- **Batch processing**: Array-based payloads for bulk operations
- **Schema reuse**: Use `$ref` in JSON Schema for common definitions
- **Incremental validation**: Stream validation for large payloads

### Batch Processing Example
```json
{
  "intent": "quality.evaluate_batch",
  "payload": {
    "evaluations": [
      {
        "item_id": "script-001",
        "content": "...",
        "criteria": ["brand_voice", "technical_accuracy"]
      },
      {
        "item_id": "script-002",
        "content": "...",
        "criteria": ["engagement", "clarity"]
      }
    ]
  }
}
```

### Schema Reuse Pattern
```json
{
  "$defs": {
    "QualityMetrics": {
      "type": "object",
      "properties": {
        "brand_voice": { "type": "number", "minimum": 0, "maximum": 1 },
        "technical_accuracy": { "type": "number", "minimum": 0, "maximum": 1 },
        "engagement": { "type": "number", "minimum": 0, "maximum": 1 }
      }
    }
  },
  "properties": {
    "claude_evaluation": { "$ref": "#/$defs/QualityMetrics" },
    "gemini_evaluation": { "$ref": "#/$defs/QualityMetrics" },
    "perplexity_evaluation": { "$ref": "#/$defs/QualityMetrics" }
  }
}
```

## 5. Error Handling

### Standard Error Object Structure
Every error response should include:
- `code`: Machine-friendly error identifier
- `message`: Human-readable description
- `details`: Optional additional context (failed field path, validation errors)
- `recoverable`: Boolean indicating if operation can be retried

### Error Classification
**Recoverable Errors:**
- `RATE_LIMIT_EXCEEDED`: API rate limiting
- `TEMPORARY_FAILURE`: Transient service issues
- `VALIDATION_ERROR`: Fixable input problems

**Fatal Errors:**
- `AUTHENTICATION_FAILED`: Invalid credentials
- `INSUFFICIENT_PERMISSIONS`: Access denied
- `MALFORMED_REQUEST`: Unfixable request structure

### Error Response Schema
```json
{
  "id": "msg-1234",
  "timestamp": "2025-08-22T06:16:00Z",
  "intent": "error.response",
  "sender": { "id": "quality-claude", "name": "Claude Quality Evaluator", "type": "LLM" },
  "recipient": { "id": "consensus-coordinator", "name": "Consensus Coordinator", "type": "Orchestrator" },
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Required field 'evaluation_criteria' is missing",
    "details": {
      "field": "payload.evaluation_criteria",
      "expected": "array",
      "received": "undefined"
    },
    "recoverable": true,
    "retry_after": 0
  }
}
```

### Recovery Mechanism Schema
```json
{
  "error_handling": {
    "fallback_agents": ["quality-gemini", "quality-perplexity"],
    "retry_strategy": {
      "max_attempts": 3,
      "backoff_multiplier": 2,
      "base_delay": "1s"
    },
    "escalation": {
      "threshold": 3,
      "target": "human-reviewer"
    }
  }
}
```

## 6. Monitoring and Logging

### Structured Log Schema
Ensure observability with consistent log structure:

```json
{
  "event": "agent-message",
  "timestamp": "2025-08-22T06:14:26Z",
  "message_id": "msg-1234",
  "thread": "episode-001-evaluation",
  "correlation_id": "corr-5678",
  "agent": {
    "id": "quality-claude",
    "name": "Claude Quality Evaluator",
    "type": "LLM"
  },
  "intent": "quality.evaluate",
  "status": "success",
  "duration_ms": 15420,
  "cost": 0.05,
  "payload_size_bytes": 2048,
  "metadata": {
    "model": "claude-4-1-opus",
    "input_tokens": 1500,
    "output_tokens": 800
  }
}
```

### Event Schema for Different Log Types
```json
{
  "event_types": {
    "agent-message": "Standard message between agents",
    "agent-error": "Error occurred during agent processing",
    "consensus-decision": "Multi-agent consensus reached",
    "cost-tracking": "Budget and cost monitoring",
    "quality-gate": "Quality threshold validation",
    "system-status": "Overall system health check"
  }
}
```

### Observability Pattern
- **Correlation IDs**: Track requests across agent interactions
- **Thread IDs**: Group related conversation messages
- **Performance Metrics**: Duration, cost, token usage
- **Error Context**: Full error details with stack traces
- **Business Metrics**: Quality scores, consensus results

## 7. Consensus Systems JSON Patterns

### Three-Evaluator Response Schema
For our Claude/Gemini/Perplexity consensus system:

```json
{
  "intent": "consensus.coordinate",
  "payload": {
    "evaluation_request": {
      "content": "podcast script content...",
      "criteria": ["brand_voice", "technical_accuracy", "engagement"]
    },
    "individual_responses": [
      {
        "evaluator": {
          "id": "quality-claude",
          "model": "claude-4-1-opus",
          "weight": 0.35
        },
        "evaluation": {
          "brand_voice": 0.92,
          "technical_accuracy": 0.88,
          "engagement": 0.85
        },
        "confidence": 0.91,
        "reasoning": "Strong brand voice alignment with minor technical clarifications needed",
        "cost": 0.05,
        "duration_ms": 15200
      },
      {
        "evaluator": {
          "id": "quality-gemini",
          "model": "gemini-pro-2-5",
          "weight": 0.30
        },
        "evaluation": {
          "brand_voice": 0.85,
          "technical_accuracy": 0.94,
          "engagement": 0.82
        },
        "confidence": 0.89,
        "reasoning": "Excellent technical accuracy, engagement could be enhanced",
        "cost": 0.03,
        "duration_ms": 12800
      },
      {
        "evaluator": {
          "id": "quality-perplexity",
          "model": "perplexity-sonar",
          "weight": 0.35
        },
        "evaluation": {
          "brand_voice": 0.88,
          "technical_accuracy": 0.91,
          "engagement": 0.87
        },
        "confidence": 0.93,
        "reasoning": "Well-balanced content with good factual accuracy",
        "cost": 0.02,
        "duration_ms": 8500
      }
    ],
    "consensus": {
      "method": "weighted_average",
      "final_scores": {
        "brand_voice": 0.89,
        "technical_accuracy": 0.91,
        "engagement": 0.85
      },
      "overall_score": 0.88,
      "decision": "approve",
      "confidence": 0.91,
      "agreement_level": 0.85,
      "justification": "Strong consensus across evaluators with weighted average of 0.88",
      "total_cost": 0.10,
      "total_duration_ms": 36500
    }
  }
}
```

### Disagreement Handling Schema
```json
{
  "consensus": {
    "method": "weighted_average",
    "disagreement_detected": true,
    "disagreement_analysis": {
      "variance": 0.23,
      "outlier_evaluator": "quality-claude",
      "conflicting_criteria": ["engagement"],
      "resolution_strategy": "secondary_evaluation",
      "escalation_required": false
    },
    "resolution": {
      "tie_breaker": "confidence_weighted",
      "additional_evaluations": [],
      "final_decision": "conditional_approve",
      "human_review_required": false
    }
  }
}
```

## Implementation Recommendations for Our System

### Agent Response Standardization
All agents should output structured JSON following our schema:

```json
{
  "agent_response": {
    "status": "success|error|partial",
    "intent_completion": "quality.evaluate",
    "result": {
      "primary_output": "...",
      "metadata": {
        "confidence": 0.92,
        "processing_time": "15.2s",
        "model_used": "claude-4-1-opus"
      }
    },
    "cost_tracking": {
      "input_tokens": 1500,
      "output_tokens": 800,
      "total_cost": 0.05
    },
    "quality_metrics": {
      "brand_voice": 0.92,
      "technical_accuracy": 0.88,
      "engagement": 0.85
    },
    "next_actions": [
      {
        "agent": "script-polisher",
        "intent": "script.polish",
        "priority": "high"
      }
    ],
    "errors": [],
    "warnings": []
  }
}
```

### Validation Framework Implementation
1. **Schema Registry**: Central repository for all agent schemas
2. **Runtime Validation**: Validate all inputs and outputs
3. **Error Standardization**: Consistent error response format
4. **Monitoring Integration**: Structured logging for all interactions

### Production Considerations
- **Schema Versioning**: Version all schemas for backward compatibility
- **Performance Monitoring**: Track validation overhead and optimization opportunities
- **Error Analytics**: Aggregate error patterns for system improvement
- **Cost Tracking**: Integrate cost metrics into all agent responses

## Key Benefits for Our Three-Evaluator System

### Structured Communication
- **Clear intent specification**: Every agent interaction has explicit purpose
- **Type safety**: Validation prevents runtime errors and data corruption
- **Threading support**: Track complex multi-agent workflows
- **Error recovery**: Graceful handling of API failures and disagreements

### Consensus Optimization
- **Weighted evaluation**: Structured support for different model weights
- **Disagreement detection**: Automatic identification of evaluation conflicts
- **Performance tracking**: Cost and timing metrics for optimization
- **Quality assurance**: Validation of consensus logic and thresholds

### Production Readiness
- **Observability**: Complete visibility into agent interactions
- **Debugging**: Structured logs for troubleshooting issues
- **Scalability**: Efficient parsing and validation for high throughput
- **Maintenance**: Schema evolution and backward compatibility

## Citations
[1] https://dev.to/arber/we-called-it-how-our-2024-agent-communication-proposal-mirrors-googles-a2a-protocol-108m
[2] https://dev.to/stephenc222/introducing-json-schemas-for-ai-data-integrity-611
[3] https://arxiv.org/html/2508.10146v1
[4] https://microsoft.github.io/ai-agents-for-beginners/04-tool-use/
[5] https://aicompetence.org/json-prompting-supercharges-multi-agent-ai-systems/
