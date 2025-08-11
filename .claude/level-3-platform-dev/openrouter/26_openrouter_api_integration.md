# OpenRouter API Integration Guide

## Quick Start

### Prerequisites
```bash
# Install OpenAI SDK (OpenRouter is compatible)
pip install openai
```

### Basic Configuration
```python
import os
from openai import OpenAI

# Initialize client with OpenRouter base URL
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.getenv("OPENROUTER_API_KEY"),
    default_headers={
        "HTTP-Referer": "https://github.com/your-repo",  # Required
        "X-Title": "AI Podcast Nobody Knows"  # Optional, for dashboard
    }
)
```

## Core Integration Patterns

### 1. Research Agent Integration
```python
class ResearchAgent:
    def __init__(self):
        self.client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=os.getenv("OPENROUTER_API_KEY")
        )
        
    def gather_information(self, topic):
        """Use cost-optimized model for research"""
        try:
            response = self.client.chat.completions.create(
                model="mistralai/mixtral-8x7b-instruct:floor",  # Cost optimized
                messages=[
                    {"role": "system", "content": "You are a research assistant."},
                    {"role": "user", "content": f"Research: {topic}"}
                ],
                max_tokens=2000,
                temperature=0.7
            )
            return response.choices[0].message.content
        except Exception as e:
            # Automatic failover handled by OpenRouter
            print(f"Research request handled with failover: {e}")
            return None
```

### 2. Script Generation Integration
```python
class ScriptWriter:
    def __init__(self):
        self.client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=os.getenv("OPENROUTER_API_KEY")
        )
    
    def generate_dialogue(self, research_content):
        """Use premium model for creative writing"""
        response = self.client.chat.completions.create(
            model="anthropic/claude-3-opus",  # Premium quality
            messages=[
                {"role": "system", "content": self.get_system_prompt()},
                {"role": "user", "content": research_content}
            ],
            max_tokens=4000,
            temperature=0.8
        )
        return response.choices[0].message.content
    
    def get_system_prompt(self):
        return """You are a podcast script writer creating engaging dialogue 
        between two hosts exploring topics with intellectual humility."""
```

### 3. Quality Evaluator Integration
```python
class QualityEvaluator:
    def __init__(self):
        self.client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=os.getenv("OPENROUTER_API_KEY")
        )
    
    def evaluate_script(self, script):
        """Use fast model for quality checks"""
        response = self.client.chat.completions.create(
            model="openai/gpt-4-turbo:nitro",  # Speed optimized
            messages=[
                {"role": "system", "content": "Evaluate podcast script quality."},
                {"role": "user", "content": script}
            ],
            max_tokens=1000,
            temperature=0.3
        )
        return self.parse_evaluation(response.choices[0].message.content)
```

## Advanced Features

### Dynamic Model Selection
```python
def select_model_for_task(task_type, priority="balanced"):
    """Dynamically select best model for task"""
    
    model_matrix = {
        "research": {
            "speed": "mistralai/mixtral-8x7b:nitro",
            "balanced": "anthropic/claude-instant",
            "quality": "anthropic/claude-3-sonnet"
        },
        "creative": {
            "speed": "openai/gpt-3.5-turbo",
            "balanced": "anthropic/claude-3-sonnet",
            "quality": "anthropic/claude-3-opus"
        },
        "evaluation": {
            "speed": "openai/gpt-3.5-turbo:nitro",
            "balanced": "openai/gpt-4-turbo",
            "quality": "openai/gpt-4"
        }
    }
    
    return model_matrix.get(task_type, {}).get(priority, "openai/gpt-3.5-turbo")
```

### Cost Tracking
```python
class CostTracker:
    def __init__(self):
        self.costs = []
    
    def track_request(self, model, input_tokens, output_tokens):
        """Track costs per request"""
        # OpenRouter provides token counts in response
        cost = self.calculate_cost(model, input_tokens, output_tokens)
        self.costs.append({
            "model": model,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cost": cost
        })
        return cost
    
    def calculate_cost(self, model, input_tokens, output_tokens):
        """Calculate cost based on model pricing"""
        # Pricing would come from OpenRouter API or constants
        pricing = self.get_model_pricing(model)
        return (input_tokens * pricing["input"] + 
                output_tokens * pricing["output"]) / 1000000
```

### Error Handling
```python
import time
from typing import Optional

class RobustClient:
    def __init__(self):
        self.client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=os.getenv("OPENROUTER_API_KEY")
        )
        self.max_retries = 3
        self.base_delay = 1.0
    
    def make_request(self, **kwargs) -> Optional[str]:
        """Make request with exponential backoff"""
        for attempt in range(self.max_retries):
            try:
                response = self.client.chat.completions.create(**kwargs)
                return response.choices[0].message.content
            except Exception as e:
                if attempt == self.max_retries - 1:
                    print(f"Failed after {self.max_retries} attempts: {e}")
                    return None
                
                delay = self.base_delay * (2 ** attempt)
                print(f"Attempt {attempt + 1} failed, retrying in {delay}s")
                time.sleep(delay)
        
        return None
```

### Streaming Responses
```python
def stream_generation(prompt, model="openai/gpt-3.5-turbo"):
    """Stream responses for real-time display"""
    client = OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=os.getenv("OPENROUTER_API_KEY")
    )
    
    stream = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        stream=True
    )
    
    full_response = ""
    for chunk in stream:
        if chunk.choices[0].delta.content:
            content = chunk.choices[0].delta.content
            full_response += content
            print(content, end="", flush=True)
    
    return full_response
```

## Environment Configuration

### Development (.env.development)
```bash
OPENROUTER_API_KEY=sk-or-v1-dev-xxxxx
OPENROUTER_MAX_TOKENS=2000
OPENROUTER_DEFAULT_MODEL=openai/gpt-3.5-turbo
OPENROUTER_TEMPERATURE=0.7
```

### Production (.env.production)
```bash
OPENROUTER_API_KEY=sk-or-v1-prod-xxxxx
OPENROUTER_MAX_TOKENS=4000
OPENROUTER_DEFAULT_MODEL=anthropic/claude-3-sonnet
OPENROUTER_TEMPERATURE=0.8
OPENROUTER_FALLBACK_ENABLED=true
```

## Testing Integration

### Unit Test Example
```python
import unittest
from unittest.mock import patch, MagicMock

class TestOpenRouterIntegration(unittest.TestCase):
    @patch('openai.OpenAI')
    def test_research_agent(self, mock_client):
        """Test research agent with mocked OpenRouter"""
        mock_response = MagicMock()
        mock_response.choices = [MagicMock(message=MagicMock(content="Research results"))]
        mock_client.return_value.chat.completions.create.return_value = mock_response
        
        agent = ResearchAgent()
        result = agent.gather_information("quantum computing")
        
        self.assertIsNotNone(result)
        self.assertEqual(result, "Research results")
```

### Integration Test
```python
def test_openrouter_connection():
    """Test actual OpenRouter API connection"""
    client = OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=os.getenv("OPENROUTER_API_KEY")
    )
    
    try:
        response = client.chat.completions.create(
            model="openai/gpt-3.5-turbo",
            messages=[{"role": "user", "content": "Say 'test passed'"}],
            max_tokens=10
        )
        assert "test passed" in response.choices[0].message.content.lower()
        print("✓ OpenRouter connection successful")
        return True
    except Exception as e:
        print(f"✗ OpenRouter connection failed: {e}")
        return False
```

## Migration from Direct APIs

### Before (Direct Anthropic)
```python
import anthropic

client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
response = client.messages.create(
    model="claude-3-opus-20240229",
    messages=[{"role": "user", "content": "Hello"}]
)
```

### After (OpenRouter)
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.getenv("OPENROUTER_API_KEY")
)
response = client.chat.completions.create(
    model="anthropic/claude-3-opus",
    messages=[{"role": "user", "content": "Hello"}]
)
```

## Performance Monitoring

```python
class PerformanceMonitor:
    def __init__(self):
        self.metrics = []
    
    def log_request(self, start_time, end_time, model, tokens):
        """Log performance metrics"""
        latency = end_time - start_time
        self.metrics.append({
            "timestamp": start_time,
            "latency": latency,
            "model": model,
            "tokens": tokens,
            "tokens_per_second": tokens / latency if latency > 0 else 0
        })
    
    def get_statistics(self):
        """Calculate performance statistics"""
        if not self.metrics:
            return {}
        
        latencies = [m["latency"] for m in self.metrics]
        return {
            "avg_latency": sum(latencies) / len(latencies),
            "p95_latency": sorted(latencies)[int(len(latencies) * 0.95)],
            "total_requests": len(self.metrics),
            "total_tokens": sum(m["tokens"] for m in self.metrics)
        }
```

## Security Best Practices

1. **Never hardcode API keys**
2. **Use environment variables**
3. **Implement request signing**
4. **Monitor for unusual usage**
5. **Set spending limits**
6. **Use separate keys for dev/prod**
7. **Rotate keys regularly**
8. **Implement rate limiting**