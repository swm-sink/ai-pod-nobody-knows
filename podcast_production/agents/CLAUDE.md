# Production Agents Context - Implementation Patterns
<!-- Context Level: Component | Inherits: Production Domain | Token Budget: 3K -->

## 🤖 AGENT IMPLEMENTATION STANDARDS

**Pattern**: Async-first with September 2025 best practices
**State**: Immutable PodcastState transformations
**Error Handling**: Retry with exponential backoff
**Cost Tracking**: Integrated with every operation

## 📋 AGENT INTERFACE PATTERN

```python
from typing import Dict, Any
from core.state import PodcastState
import httpx
import asyncio

class BaseAgent:
    """September 2025 agent pattern"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.cost_tracker = CostTracker()
        self.retry_handler = RetryHandler()
        
    async def execute(self, state: PodcastState) -> PodcastState:
        """Main execution with cost tracking"""
        try:
            # Pre-operation hook
            await self.cost_tracker.start_operation(self.__class__.__name__)
            
            # Execute with retry logic
            result = await self.retry_handler.execute(
                self._perform_operation,
                state
            )
            
            # Post-operation hook
            cost = await self.cost_tracker.end_operation(result)
            
            # Return updated state
            return {
                **state,
                **result,
                "cost_tracking": {
                    **state.get("cost_tracking", {}),
                    self.__class__.__name__: cost
                }
            }
        except Exception as e:
            return {...state, "error_state": {"agent": self.__class__.__name__, "error": str(e)}}
    
    async def _perform_operation(self, state: PodcastState) -> Dict[str, Any]:
        """Override in subclasses"""
        raise NotImplementedError
```

## 🔬 RESEARCH AGENTS PATTERNS

### Concurrent HTTP Pattern (September 2025)
```python
async def execute_concurrent_queries(queries: List[Query]) -> List[Response]:
    """Optimized concurrent execution"""
    timeout = httpx.Timeout(30.0, connect=10.0)
    limits = httpx.Limits(max_keepalive_connections=5, max_connections=10)
    
    async with httpx.AsyncClient(timeout=timeout, limits=limits) as client:
        tasks = [
            asyncio.create_task(execute_single_query(client, query))
            for query in queries
        ]
        
        # 10-30x performance improvement
        responses = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Handle exceptions gracefully
        return [
            response if not isinstance(response, Exception)
            else create_fallback_response(query)
            for query, response in zip(queries, responses)
        ]
```

### Research Agent Specifications
```yaml
research_discovery:
  batch_size: 5 queries
  timeout: 30s
  retry: 3 attempts
  fallback: Generic response

research_deep_dive:
  depth: 3 levels
  perspectives: 5 experts
  validation: Cross-reference

research_validation:
  confidence_threshold: 0.8
  source_minimum: 3
  fact_checking: Enabled

research_synthesis:
  structure: Narrative
  length: 5000-8000 words
  coherence_check: Required
```

## 📝 CONTENT AGENTS PATTERNS

### Script Writing Pattern
```python
class ScriptWriterAgent(BaseAgent):
    """35K character script generation"""
    
    CHAR_RANGE = (33000, 37000)
    
    async def _perform_operation(self, state: PodcastState) -> Dict[str, Any]:
        # Extract research
        research = state["research_data"]
        plan = state["episode_plan"]
        
        # Generate script sections
        sections = await self._generate_sections(research, plan)
        
        # Combine with transitions
        script = await self._combine_with_transitions(sections)
        
        # Validate length
        if not self.CHAR_RANGE[0] <= len(script) <= self.CHAR_RANGE[1]:
            script = await self._adjust_length(script)
        
        return {"script": script}
```

### Brand Validation Pattern
```python
class BrandValidatorAgent(BaseAgent):
    """Intellectual humility scoring"""
    
    METRICS = {
        "wonder": 0.3,        # Celebrating curiosity
        "acknowledgment": 0.3, # What we don't know
        "exploration": 0.4     # Journey of discovery
    }
    
    async def score_brand_alignment(self, text: str) -> float:
        scores = {}
        for metric, weight in self.METRICS.items():
            score = await self._score_metric(text, metric)
            scores[metric] = score * weight
        
        total = sum(scores.values())
        return total  # Must be >= 0.85
```

## 🎯 QUALITY AGENTS PATTERNS

### Multi-Evaluator Consensus
```python
async def achieve_consensus(claude_score: float, gemini_score: float) -> Dict[str, Any]:
    """Require agreement between evaluators"""
    
    consensus = {
        "claude": claude_score,
        "gemini": gemini_score,
        "average": (claude_score + gemini_score) / 2,
        "variance": abs(claude_score - gemini_score)
    }
    
    # Require scores > 8.0 and low variance
    consensus["passed"] = (
        consensus["average"] >= 8.0 and
        consensus["variance"] <= 1.5
    )
    
    return consensus
```

## 🔊 AUDIO AGENTS PATTERNS

### Chunked Synthesis Pattern
```python
class AudioSynthesizerAgent(BaseAgent):
    """ElevenLabs TTS optimization"""
    
    CHUNK_SIZE = 5000  # Characters per chunk
    
    async def synthesize_audio(self, script: str) -> str:
        chunks = self._split_into_chunks(script)
        audio_segments = []
        
        async with httpx.AsyncClient() as client:
            # Parallel synthesis
            tasks = [
                self._synthesize_chunk(client, chunk)
                for chunk in chunks
            ]
            audio_segments = await asyncio.gather(*tasks)
        
        # Combine segments
        final_audio = await self._combine_audio_segments(audio_segments)
        return final_audio
```

## 🔧 COMMON PATTERNS

### State Update Pattern
```python
def update_state(state: PodcastState, **updates) -> PodcastState:
    """Immutable state update"""
    return {
        **state,
        **updates,
        "timestamp": datetime.now().isoformat()
    }
```

### Error Recovery Pattern
```python
async def with_recovery(operation, state, fallback):
    """Execute with automatic recovery"""
    try:
        return await operation(state)
    except RecoverableError as e:
        # Log and retry
        return await fallback(state, e)
    except NonRecoverableError as e:
        # Update error state
        return {...state, "error_state": {"fatal": True, "error": str(e)}}
```

### Cost Attribution Pattern
```python
def track_cost(provider: str, operation: str, amount: float):
    """Granular cost tracking"""
    return {
        "provider": provider,
        "operation": operation,
        "amount": amount,
        "timestamp": datetime.now().isoformat()
    }
```

## 📊 PERFORMANCE METRICS

| Agent | Avg Time | Success Rate | Avg Cost |
|-------|----------|--------------|----------|
| research_discovery | 8s | 98% | $0.15 |
| research_deep_dive | 12s | 97% | $0.20 |
| script_writer | 15s | 96% | $1.20 |
| brand_validator | 3s | 99% | $0.05 |
| audio_synthesizer | 45s | 95% | $2.50 |

## 🔄 INHERITANCE

**Inherits From**: `../CLAUDE.md` (Production Domain)
**Sibling Contexts**:
- `../workflows/CLAUDE.md` - Workflow patterns
- `../config/CLAUDE.md` - Configuration rules

---

**Token Budget**: 3K | **Focus**: Agent implementation | **Status**: Production