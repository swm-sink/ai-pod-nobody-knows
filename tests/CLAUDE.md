# Testing & Quality Assurance Context
<!-- Context Level: Domain | Inherits: Project Root | Token Budget: 2K -->

## 🧪 TESTING ARCHITECTURE

**Framework**: pytest with async support
**Coverage Target**: 95% for critical paths
**Quality Gates**: Multi-dimensional validation
**Performance**: Benchmarking on every commit

## 📋 TEST CATEGORIES

### Unit Tests
```bash
# Individual agent testing
pytest tests/unit/test_research_discovery.py -v
pytest tests/unit/test_script_writer.py -v

# Pattern
async def test_agent_execution():
    agent = ResearchDiscoveryAgent()
    state = create_test_state()
    result = await agent.execute(state)
    assert "research_data" in result
    assert result["cost_tracking"]["total"] < 0.20
```

### Integration Tests
```bash
# Full pipeline testing
pytest tests/integration/test_complete_workflow.py -v
pytest tests/integration/test_research_pipeline.py -v

# Pattern
async def test_full_production():
    state = {"topic": "Test topic", "budget": 5.51}
    result = await app.ainvoke(state)
    assert result["audio_url"]
    assert result["cost_tracking"]["total"] <= 5.51
```

### Quality Gates
```bash
# Brand voice validation
./tests/quality_gates/test_brand_voice_gates.sh

# Consensus scoring
./tests/quality_gates/test_dual_evaluation_consensus.sh

# Pattern
def test_brand_alignment():
    score = validate_brand_voice(script)
    assert score >= 0.85
```

## 🎯 QUALITY VALIDATION FRAMEWORK

### Multi-Dimensional Assessment
```yaml
dimensions:
  technical:
    - Correctness
    - Performance
    - Security
    
  functional:
    - Feature completeness
    - User experience
    - Error handling
    
  production:
    - Cost efficiency
    - Reliability
    - Scalability
```

### Validation Patterns
```python
class QualityValidator:
    """Comprehensive quality checks"""
    
    def validate_episode(self, episode_data):
        validations = {
            "script_length": self._check_script_length,
            "brand_voice": self._check_brand_alignment,
            "audio_quality": self._check_audio_quality,
            "cost_compliance": self._check_cost_limits,
            "consensus_score": self._check_evaluator_consensus
        }
        
        results = {}
        for name, validator in validations.items():
            results[name] = validator(episode_data)
        
        return all(results.values()), results
```

## 🔬 TESTING PATTERNS

### Async Test Pattern
```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_concurrent_operations():
    """Test parallel execution"""
    tasks = [
        research_discovery(),
        research_deep_dive(),
        research_validation()
    ]
    
    results = await asyncio.gather(*tasks)
    assert len(results) == 3
    assert all(r["success"] for r in results)
```

### Mock Pattern
```python
from unittest.mock import AsyncMock, patch

@patch("agents.research_discovery.httpx.AsyncClient")
async def test_with_mock_api(mock_client):
    """Test without real API calls"""
    mock_client.return_value.__aenter__.return_value.post = AsyncMock(
        return_value=create_mock_response()
    )
    
    agent = ResearchDiscoveryAgent()
    result = await agent.execute(test_state)
    assert result["research_data"]
```

### Fixture Pattern
```python
@pytest.fixture
async def production_state():
    """Reusable test state"""
    return {
        "episode_id": "test_001",
        "topic": "Test Topic",
        "budget": 5.51,
        "research_data": create_test_research(),
        "cost_tracking": {"total": 0}
    }

@pytest.fixture
async def test_app():
    """Test workflow app"""
    return create_test_workflow()
```

## 📊 PERFORMANCE BENCHMARKS

### Benchmark Targets
```yaml
benchmarks:
  research_pipeline: 45s
  script_generation: 30s
  quality_evaluation: 20s
  audio_synthesis: 60s
  total_production: 180s
  
cost_targets:
  research: 0.60
  content: 1.50
  quality: 1.00
  audio: 2.50
  total: 5.51
```

### Performance Test
```python
import time

async def test_performance():
    """Validate performance targets"""
    start = time.time()
    
    result = await run_full_production()
    
    duration = time.time() - start
    assert duration < 180  # 3 minutes max
    assert result["cost_tracking"]["total"] <= 5.51
```

## 🛡️ SECURITY TESTING

### API Key Protection
```python
def test_no_api_keys_in_logs():
    """Ensure no keys leaked"""
    logs = read_production_logs()
    
    patterns = [
        r"sk-[a-zA-Z0-9]+",  # OpenAI style
        r"pplx-[a-zA-Z0-9]+",  # Perplexity
        r"AIza[a-zA-Z0-9]+",  # Google
    ]
    
    for pattern in patterns:
        assert not re.search(pattern, logs)
```

### Input Validation
```python
def test_input_sanitization():
    """Test malicious input handling"""
    malicious_inputs = [
        "'; DROP TABLE episodes; --",
        "<script>alert('xss')</script>",
        "../../../etc/passwd",
        "{{7*7}}",  # Template injection
    ]
    
    for input in malicious_inputs:
        result = process_topic(input)
        assert result["sanitized"] == True
```

## 🔄 CONTINUOUS INTEGRATION

### Test Pipeline
```yaml
name: Production Tests
on: [push, pull_request]

jobs:
  test:
    steps:
      - name: Unit Tests
        run: pytest tests/unit/ -v --cov=podcast_production
        
      - name: Integration Tests
        run: pytest tests/integration/ -v
        
      - name: Quality Gates
        run: ./tests/quality_gates/run_all.sh
        
      - name: Performance Tests
        run: pytest tests/performance/ -v
        
      - name: Security Scan
        run: bandit -r podcast_production/
```

## 📈 TEST METRICS

| Test Suite | Tests | Coverage | Avg Time | Success Rate |
|------------|-------|----------|----------|--------------|
| Unit | 145 | 96% | 0.5s | 99% |
| Integration | 28 | 89% | 15s | 97% |
| Quality | 15 | 100% | 5s | 100% |
| Performance | 8 | N/A | 30s | 95% |
| **Total** | **196** | **94%** | **50s** | **98%** |

## 🔄 INHERITANCE

**Inherits From**: `/CLAUDE.md` (Project Root)
**Child Contexts**:
- `quality_gates/CLAUDE.md` - Validation specifics
- `integration/CLAUDE.md` - E2E patterns

---

**Token Budget**: 2K | **Focus**: Testing & QA | **Status**: Active