# OpenRouter Model Routing Guide

## Dynamic Routing Strategies

OpenRouter's power lies in intelligent model selection based on task requirements, cost constraints, and quality targets. This guide provides comprehensive routing strategies for podcast production.

## Model Categories & Capabilities

### Tier 1: Premium Models (Highest Quality)
| Model | Strengths | Cost/1M | Use Case |
|-------|-----------|---------|----------|
| `anthropic/claude-3-opus` | Deep reasoning, creativity | $15/$75 | Final script writing |
| `openai/gpt-4` | Broad knowledge, consistency | $30/$60 | Complex analysis |
| `google/gemini-pro-1.5` | Multimodal, long context | $7/$21 | Research synthesis |

### Tier 2: Balanced Models (Quality/Cost)
| Model | Strengths | Cost/1M | Use Case |
|-------|-----------|---------|----------|
| `anthropic/claude-3-sonnet` | Efficient reasoning | $3/$15 | Script drafts |
| `openai/gpt-4-turbo` | Fast, capable | $10/$30 | Quality checks |
| `mistralai/mixtral-8x7b` | Open source, reliable | $0.6/$0.6 | Research |

### Tier 3: Efficiency Models (Cost-Optimized)
| Model | Strengths | Cost/1M | Use Case |
|-------|-----------|---------|----------|
| `anthropic/claude-instant` | Quick responses | $0.8/$2.4 | Summaries |
| `openai/gpt-3.5-turbo` | Versatile, cheap | $0.5/$1.5 | Basic tasks |
| `meta-llama/llama-3-70b` | Free tier available | $0.8/$0.8 | Bulk processing |

## Routing Suffixes

### :online (Web-Enhanced)
```python
# Adds web search results to context
model = "anthropic/claude-3-sonnet:online"
# Use for: Current events, fact-checking, recent research
```

### :nitro (Speed-Optimized)
```python
# Prioritizes lowest latency providers
model = "openai/gpt-4-turbo:nitro"
# Use for: Real-time interactions, quick iterations
```

### :floor (Cost-Optimized)
```python
# Routes to cheapest available provider
model = "mistralai/mixtral-8x7b:floor"
# Use for: Bulk processing, initial drafts
```

### :extended (Long Context)
```python
# Enables maximum context window
model = "google/gemini-pro-1.5:extended"
# Use for: Full episode scripts, comprehensive research
```

## Task-Specific Routing

### Research Phase Routing
```python
class ResearchRouter:
    def route_research_task(self, complexity, budget_remaining):
        """Smart routing for research tasks"""

        if complexity == "simple":
            # Simple lookups and summaries
            return "meta-llama/llama-3-70b:floor"

        elif complexity == "moderate":
            # Standard research with synthesis
            if budget_remaining > 2.00:
                return "anthropic/claude-instant"
            else:
                return "mistralai/mixtral-8x7b:floor"

        else:  # complex
            # Deep research requiring reasoning
            if budget_remaining > 5.00:
                return "anthropic/claude-3-sonnet:online"
            else:
                return "openai/gpt-4-turbo"
```

### Script Generation Routing
```python
class ScriptRouter:
    def route_script_task(self, draft_number, quality_target):
        """Progressive quality improvement through drafts"""

        routing_map = {
            1: {  # First draft
                "high": "anthropic/claude-3-sonnet",
                "medium": "openai/gpt-3.5-turbo",
                "low": "mistralai/mixtral-8x7b"
            },
            2: {  # Revision
                "high": "anthropic/claude-3-opus",
                "medium": "anthropic/claude-3-sonnet",
                "low": "openai/gpt-3.5-turbo"
            },
            3: {  # Final polish
                "high": "anthropic/claude-3-opus",
                "medium": "openai/gpt-4-turbo",
                "low": "anthropic/claude-3-sonnet"
            }
        }

        return routing_map.get(draft_number, {}).get(
            quality_target,
            "openai/gpt-3.5-turbo"
        )
```

### Quality Evaluation Routing
```python
class QualityRouter:
    def route_evaluation_task(self, evaluation_type):
        """Route based on evaluation requirements"""

        routes = {
            "factual_accuracy": "openai/gpt-4:online",  # Web search for fact-check
            "dialogue_quality": "anthropic/claude-3-sonnet",  # Nuanced evaluation
            "technical_review": "openai/gpt-4-turbo",  # Comprehensive analysis
            "quick_check": "openai/gpt-3.5-turbo:nitro",  # Fast validation
            "brand_consistency": "anthropic/claude-instant"  # Style check
        }

        return routes.get(evaluation_type, "openai/gpt-3.5-turbo")
```

## Fallback Chains

### Reliability-First Chain
```python
RELIABILITY_CHAIN = [
    "openai/gpt-4-turbo",  # Most reliable
    "anthropic/claude-3-sonnet",  # Excellent fallback
    "openai/gpt-3.5-turbo",  # Always available
    "mistralai/mixtral-8x7b"  # Open source backup
]
```

### Quality-First Chain
```python
QUALITY_CHAIN = [
    "anthropic/claude-3-opus",  # Highest quality
    "openai/gpt-4",  # Excellent alternative
    "anthropic/claude-3-sonnet",  # Good quality/cost
    "openai/gpt-4-turbo"  # Fast quality option
]
```

### Cost-First Chain
```python
COST_CHAIN = [
    "meta-llama/llama-3-70b:floor",  # Cheapest
    "mistralai/mixtral-8x7b:floor",  # Very affordable
    "openai/gpt-3.5-turbo",  # Reliable and cheap
    "anthropic/claude-instant"  # Good value
]
```

## Intelligent Routing Logic

### Adaptive Router Implementation
```python
class AdaptiveRouter:
    def __init__(self):
        self.performance_history = {}
        self.cost_tracker = {}

    def select_model(self, task_type, constraints):
        """Intelligently select model based on multiple factors"""

        factors = self.calculate_factors(task_type, constraints)

        # Weight different factors
        score_weights = {
            "quality": constraints.get("quality_weight", 0.4),
            "cost": constraints.get("cost_weight", 0.3),
            "speed": constraints.get("speed_weight", 0.2),
            "reliability": constraints.get("reliability_weight", 0.1)
        }

        best_model = None
        best_score = -1

        for model in self.get_available_models():
            score = self.calculate_model_score(model, factors, score_weights)
            if score > best_score:
                best_score = score
                best_model = model

        return best_model

    def calculate_model_score(self, model, factors, weights):
        """Calculate weighted score for model selection"""
        scores = {
            "quality": self.get_quality_score(model),
            "cost": self.get_cost_score(model),
            "speed": self.get_speed_score(model),
            "reliability": self.get_reliability_score(model)
        }

        total = sum(scores[k] * weights[k] for k in scores)
        return total
```

### Context-Aware Routing
```python
class ContextAwareRouter:
    def __init__(self):
        self.context_limits = {
            "openai/gpt-3.5-turbo": 4096,
            "openai/gpt-4-turbo": 128000,
            "anthropic/claude-3-opus": 200000,
            "google/gemini-pro-1.5:extended": 1000000
        }

    def route_by_context(self, input_tokens):
        """Select model based on context requirements"""

        suitable_models = []
        for model, limit in self.context_limits.items():
            if input_tokens < limit * 0.8:  # 80% safety margin
                suitable_models.append(model)

        # Return cheapest suitable model
        return self.get_cheapest_model(suitable_models)
```

## Production Routing Patterns

### Episode Production Pipeline
```python
class EpisodeProductionRouter:
    def __init__(self, episode_budget=4.00):
        self.budget = episode_budget
        self.spent = 0.0

    def get_research_model(self):
        """Route research phase"""
        budget_available = self.budget - self.spent

        if budget_available > 3.00:
            return "anthropic/claude-instant"
        elif budget_available > 2.00:
            return "mistralai/mixtral-8x7b"
        else:
            return "meta-llama/llama-3-70b:floor"

    def get_script_model(self, draft_num):
        """Route script generation"""
        budget_available = self.budget - self.spent

        if draft_num == 1 and budget_available > 2.50:
            return "anthropic/claude-3-sonnet"
        elif draft_num == 2 and budget_available > 1.50:
            return "anthropic/claude-3-opus"
        else:
            return "openai/gpt-3.5-turbo"

    def get_quality_model(self):
        """Route quality evaluation"""
        budget_available = self.budget - self.spent

        if budget_available > 1.00:
            return "openai/gpt-4-turbo:nitro"
        else:
            return "openai/gpt-3.5-turbo:nitro"
```

### A/B Testing Router
```python
class ABTestRouter:
    def __init__(self):
        self.test_groups = {
            "A": "anthropic/claude-3-sonnet",
            "B": "openai/gpt-4-turbo"
        }
        self.results = {"A": [], "B": []}

    def route_for_test(self, test_id):
        """Route requests for A/B testing"""
        import hashlib

        # Deterministic assignment based on test_id
        group = "A" if int(hashlib.md5(test_id.encode()).hexdigest(), 16) % 2 == 0 else "B"
        return self.test_groups[group]

    def record_result(self, group, quality_score, cost):
        """Track results for analysis"""
        self.results[group].append({
            "quality": quality_score,
            "cost": cost
        })
```

## Monitoring & Optimization

### Performance Tracker
```python
class RoutePerformanceTracker:
    def __init__(self):
        self.metrics = {}

    def track_route(self, task_type, model, latency, cost, quality):
        """Track routing performance"""
        if task_type not in self.metrics:
            self.metrics[task_type] = {}

        if model not in self.metrics[task_type]:
            self.metrics[task_type][model] = {
                "count": 0,
                "total_latency": 0,
                "total_cost": 0,
                "total_quality": 0
            }

        m = self.metrics[task_type][model]
        m["count"] += 1
        m["total_latency"] += latency
        m["total_cost"] += cost
        m["total_quality"] += quality

    def get_best_route(self, task_type, optimize_for="balanced"):
        """Get best performing route"""
        if task_type not in self.metrics:
            return None

        best_model = None
        best_score = -1

        for model, stats in self.metrics[task_type].items():
            if stats["count"] == 0:
                continue

            avg_latency = stats["total_latency"] / stats["count"]
            avg_cost = stats["total_cost"] / stats["count"]
            avg_quality = stats["total_quality"] / stats["count"]

            if optimize_for == "quality":
                score = avg_quality
            elif optimize_for == "cost":
                score = 1 / avg_cost if avg_cost > 0 else 0
            elif optimize_for == "speed":
                score = 1 / avg_latency if avg_latency > 0 else 0
            else:  # balanced
                score = avg_quality / (avg_cost * avg_latency)

            if score > best_score:
                best_score = score
                best_model = model

        return best_model
```

## Best Practices

1. **Start Conservative**: Begin with cheaper models, upgrade based on quality needs
2. **Monitor Continuously**: Track performance per model per task type
3. **Use Fallbacks Wisely**: Don't cascade through too many models
4. **Cache Routing Decisions**: Reuse successful routing patterns
5. **Test Regularly**: Models improve over time, re-evaluate routing
6. **Budget Awareness**: Always track cumulative costs
7. **Quality Gates**: Set minimum quality thresholds
8. **Document Decisions**: Log why specific routes were chosen
