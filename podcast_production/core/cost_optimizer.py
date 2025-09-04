#!/usr/bin/env python3
"""
Cost Prediction and Optimization Engine
Adaptive model selection and budget management for podcast production
Version: 2.0.0 - September 2025 Production Standards
"""

import os
import json
import asyncio
from typing import Dict, Any, List, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from enum import Enum
import numpy as np
from functools import lru_cache

import redis
from pydantic import BaseModel, Field
import yaml


class ModelProvider(Enum):
    """Supported model providers with pricing"""
    PERPLEXITY_SONAR = "perplexity-sonar"
    CLAUDE_3_OPUS = "claude-3-opus"
    CLAUDE_3_SONNET = "claude-3-sonnet"
    GPT_4_TURBO = "gpt-4-turbo"
    GPT_35_TURBO = "gpt-3.5-turbo"
    GEMINI_PRO = "gemini-pro"
    GEMINI_FLASH = "gemini-flash"
    ELEVENLABS_TTS = "elevenlabs-tts"


@dataclass
class ModelPricing:
    """Pricing structure for a model - September 2025 rates"""
    provider: ModelProvider
    input_cost_per_1k: float  # Cost per 1K input tokens
    output_cost_per_1k: float  # Cost per 1K output tokens
    min_latency_ms: int  # Minimum latency in milliseconds
    max_tokens: int  # Maximum context window
    quality_score: float  # Quality score (0-1)
    

# September 2025 Pricing Matrix
PRICING_MATRIX = {
    ModelProvider.PERPLEXITY_SONAR: ModelPricing(
        provider=ModelProvider.PERPLEXITY_SONAR,
        input_cost_per_1k=0.001,  # $0.001 per 1K tokens
        output_cost_per_1k=0.005,  # $0.005 per 1K tokens  
        min_latency_ms=800,
        max_tokens=32000,
        quality_score=0.92
    ),
    ModelProvider.CLAUDE_3_OPUS: ModelPricing(
        provider=ModelProvider.CLAUDE_3_OPUS,
        input_cost_per_1k=0.015,  # $15 per 1M tokens
        output_cost_per_1k=0.075,  # $75 per 1M tokens
        min_latency_ms=1200,
        max_tokens=200000,
        quality_score=0.98
    ),
    ModelProvider.CLAUDE_3_SONNET: ModelPricing(
        provider=ModelProvider.CLAUDE_3_SONNET,
        input_cost_per_1k=0.003,  # $3 per 1M tokens
        output_cost_per_1k=0.015,  # $15 per 1M tokens
        min_latency_ms=600,
        max_tokens=200000,
        quality_score=0.94
    ),
    ModelProvider.GPT_4_TURBO: ModelPricing(
        provider=ModelProvider.GPT_4_TURBO,
        input_cost_per_1k=0.01,  # $10 per 1M tokens
        output_cost_per_1k=0.03,  # $30 per 1M tokens
        min_latency_ms=900,
        max_tokens=128000,
        quality_score=0.96
    ),
    ModelProvider.GPT_35_TURBO: ModelPricing(
        provider=ModelProvider.GPT_35_TURBO,
        input_cost_per_1k=0.0005,  # $0.50 per 1M tokens
        output_cost_per_1k=0.0015,  # $1.50 per 1M tokens
        min_latency_ms=400,
        max_tokens=16000,
        quality_score=0.85
    ),
    ModelProvider.GEMINI_PRO: ModelPricing(
        provider=ModelProvider.GEMINI_PRO,
        input_cost_per_1k=0.00025,  # $0.25 per 1M tokens
        output_cost_per_1k=0.0005,  # $0.50 per 1M tokens
        min_latency_ms=500,
        max_tokens=32000,
        quality_score=0.92
    ),
    ModelProvider.GEMINI_FLASH: ModelPricing(
        provider=ModelProvider.GEMINI_FLASH,
        input_cost_per_1k=0.00015,  # $0.15 per 1M tokens
        output_cost_per_1k=0.0003,  # $0.30 per 1M tokens
        min_latency_ms=300,
        max_tokens=1000000,
        quality_score=0.88
    ),
    ModelProvider.ELEVENLABS_TTS: ModelPricing(
        provider=ModelProvider.ELEVENLABS_TTS,
        input_cost_per_1k=0.18,  # $0.18 per 1K characters
        output_cost_per_1k=0.0,  # No output tokens
        min_latency_ms=2000,
        max_tokens=5000,  # Characters per request
        quality_score=0.95
    )
}


class CostPrediction(BaseModel):
    """Cost prediction for an operation"""
    operation: str
    predicted_cost: float
    confidence: float
    breakdown: Dict[str, float]
    recommended_model: str
    alternative_models: List[Dict[str, Any]]
    budget_remaining: float
    

class OptimizationStrategy(Enum):
    """Optimization strategies"""
    QUALITY_FIRST = "quality_first"  # Prioritize quality
    BUDGET_FIRST = "budget_first"  # Prioritize budget
    BALANCED = "balanced"  # Balance quality and cost
    SPEED_FIRST = "speed_first"  # Prioritize latency


class CostOptimizer:
    """Advanced cost prediction and optimization engine"""
    
    def __init__(self, 
                 budget: float = 5.51,
                 strategy: OptimizationStrategy = OptimizationStrategy.BALANCED):
        """Initialize cost optimizer with budget and strategy"""
        self.budget = budget
        self.strategy = strategy
        self.spent = 0.0
        self.predictions_cache = {}
        self.usage_history = []
        self.redis_client = None
        
        # Initialize Redis for historical data
        try:
            self.redis_client = redis.Redis(
                host=os.getenv("REDIS_HOST", "localhost"),
                port=int(os.getenv("REDIS_PORT", "6379")),
                decode_responses=True
            )
            self.redis_client.ping()
        except Exception:
            # Continue without Redis
            pass
    
    async def predict_cost(self, 
                          operation: str,
                          input_tokens: int,
                          expected_output_tokens: int,
                          required_quality: float = 0.9) -> CostPrediction:
        """
        Predict cost for an operation and recommend optimal model
        
        Args:
            operation: Type of operation (research, writing, evaluation)
            input_tokens: Estimated input tokens
            expected_output_tokens: Expected output tokens
            required_quality: Minimum quality score required
            
        Returns:
            CostPrediction with recommendations
        """
        # Get historical average if available
        historical_avg = await self._get_historical_average(operation)
        
        # Calculate costs for each eligible model
        candidates = []
        for provider, pricing in PRICING_MATRIX.items():
            # Skip if quality too low
            if pricing.quality_score < required_quality:
                continue
                
            # Skip if tokens exceed limit
            if input_tokens > pricing.max_tokens:
                continue
            
            # Calculate cost
            cost = (
                (input_tokens / 1000) * pricing.input_cost_per_1k +
                (expected_output_tokens / 1000) * pricing.output_cost_per_1k
            )
            
            # Apply strategy scoring
            score = self._calculate_model_score(pricing, cost)
            
            candidates.append({
                "provider": provider.value,
                "cost": cost,
                "quality": pricing.quality_score,
                "latency": pricing.min_latency_ms,
                "score": score
            })
        
        # Sort by score
        candidates.sort(key=lambda x: x["score"], reverse=True)
        
        if not candidates:
            raise ValueError(f"No suitable models found for {operation}")
        
        # Select best model
        best_model = candidates[0]
        
        # Calculate confidence based on historical data
        confidence = 0.85  # Base confidence
        if historical_avg and historical_avg > 0:
            # Adjust confidence based on historical accuracy
            variance = abs(best_model["cost"] - historical_avg) / historical_avg
            confidence = max(0.5, confidence - variance)
        
        return CostPrediction(
            operation=operation,
            predicted_cost=best_model["cost"],
            confidence=confidence,
            breakdown={
                "input_cost": (input_tokens / 1000) * PRICING_MATRIX[ModelProvider(best_model["provider"])].input_cost_per_1k,
                "output_cost": (expected_output_tokens / 1000) * PRICING_MATRIX[ModelProvider(best_model["provider"])].output_cost_per_1k
            },
            recommended_model=best_model["provider"],
            alternative_models=candidates[1:4],  # Top 3 alternatives
            budget_remaining=self.budget - self.spent - best_model["cost"]
        )
    
    def _calculate_model_score(self, pricing: ModelPricing, cost: float) -> float:
        """Calculate model score based on optimization strategy"""
        if self.strategy == OptimizationStrategy.QUALITY_FIRST:
            # 70% quality, 20% cost, 10% speed
            return (
                pricing.quality_score * 0.7 +
                (1 - cost / self.budget) * 0.2 +
                (1 - pricing.min_latency_ms / 10000) * 0.1
            )
        elif self.strategy == OptimizationStrategy.BUDGET_FIRST:
            # 20% quality, 70% cost, 10% speed
            return (
                pricing.quality_score * 0.2 +
                (1 - cost / self.budget) * 0.7 +
                (1 - pricing.min_latency_ms / 10000) * 0.1
            )
        elif self.strategy == OptimizationStrategy.SPEED_FIRST:
            # 20% quality, 10% cost, 70% speed
            return (
                pricing.quality_score * 0.2 +
                (1 - cost / self.budget) * 0.1 +
                (1 - pricing.min_latency_ms / 10000) * 0.7
            )
        else:  # BALANCED
            # 40% quality, 40% cost, 20% speed
            return (
                pricing.quality_score * 0.4 +
                (1 - cost / self.budget) * 0.4 +
                (1 - pricing.min_latency_ms / 10000) * 0.2
            )
    
    async def _get_historical_average(self, operation: str) -> Optional[float]:
        """Get historical average cost for an operation"""
        if not self.redis_client:
            return None
            
        try:
            key = f"cost_history:{operation}"
            values = self.redis_client.lrange(key, -100, -1)  # Last 100 values
            if values:
                costs = [float(v) for v in values]
                return np.mean(costs)
        except Exception:
            pass
            
        return None
    
    async def track_actual_cost(self, 
                               operation: str, 
                               actual_cost: float,
                               model_used: str,
                               tokens_used: Dict[str, int]):
        """Track actual cost for learning and optimization"""
        self.spent += actual_cost
        
        # Store in history
        self.usage_history.append({
            "timestamp": datetime.now().isoformat(),
            "operation": operation,
            "cost": actual_cost,
            "model": model_used,
            "tokens": tokens_used
        })
        
        # Store in Redis for persistence
        if self.redis_client:
            try:
                key = f"cost_history:{operation}"
                self.redis_client.rpush(key, actual_cost)
                self.redis_client.ltrim(key, -1000, -1)  # Keep last 1000
                self.redis_client.expire(key, 86400 * 30)  # 30 day retention
            except Exception:
                pass
    
    async def optimize_pipeline(self, 
                               pipeline_stages: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Optimize an entire pipeline for cost and quality
        
        Args:
            pipeline_stages: List of pipeline stages with requirements
            
        Returns:
            Optimized pipeline configuration
        """
        total_predicted_cost = 0
        optimized_stages = []
        budget_per_stage = self.budget / len(pipeline_stages)
        
        for stage in pipeline_stages:
            # Predict cost for stage
            prediction = await self.predict_cost(
                operation=stage["name"],
                input_tokens=stage.get("input_tokens", 1000),
                expected_output_tokens=stage.get("output_tokens", 2000),
                required_quality=stage.get("required_quality", 0.9)
            )
            
            # If over budget, switch to cheaper model
            if prediction.predicted_cost > budget_per_stage:
                # Find cheaper alternative
                for alt in prediction.alternative_models:
                    if alt["cost"] <= budget_per_stage:
                        prediction.recommended_model = alt["provider"]
                        prediction.predicted_cost = alt["cost"]
                        break
            
            total_predicted_cost += prediction.predicted_cost
            optimized_stages.append({
                "stage": stage["name"],
                "model": prediction.recommended_model,
                "predicted_cost": prediction.predicted_cost,
                "confidence": prediction.confidence
            })
        
        return {
            "total_predicted_cost": total_predicted_cost,
            "budget": self.budget,
            "budget_utilization": total_predicted_cost / self.budget,
            "optimized_stages": optimized_stages,
            "strategy": self.strategy.value,
            "warnings": [] if total_predicted_cost <= self.budget else [
                f"Predicted cost ${total_predicted_cost:.2f} exceeds budget ${self.budget:.2f}"
            ]
        }
    
    def get_budget_status(self) -> Dict[str, Any]:
        """Get current budget status"""
        return {
            "budget": self.budget,
            "spent": self.spent,
            "remaining": self.budget - self.spent,
            "utilization": self.spent / self.budget if self.budget > 0 else 0,
            "strategy": self.strategy.value,
            "operations_count": len(self.usage_history)
        }
    
    async def enforce_budget_limit(self, predicted_cost: float) -> bool:
        """
        Enforce hard budget limit
        
        Returns:
            True if operation can proceed, False if would exceed budget
        """
        if self.spent + predicted_cost > self.budget:
            # Log budget violation
            if self.redis_client:
                self.redis_client.incr("budget_violations")
            return False
        return True
    
    @lru_cache(maxsize=128)
    def estimate_tokens(self, text: str, method: str = "simple") -> int:
        """
        Estimate token count from text
        
        Args:
            text: Input text
            method: Estimation method (simple, tiktoken, approximate)
            
        Returns:
            Estimated token count
        """
        if method == "simple":
            # Simple word-based estimation
            words = len(text.split())
            return int(words * 1.3)  # Rough approximation
        elif method == "approximate":
            # Character-based estimation
            chars = len(text)
            return int(chars / 4)  # ~4 chars per token
        else:
            # Default to simple
            return self.estimate_tokens(text, "simple")
    
    def get_recommendations(self) -> List[str]:
        """Get cost optimization recommendations based on usage"""
        recommendations = []
        
        if self.spent > self.budget * 0.8:
            recommendations.append(
                "Budget utilization above 80% - consider switching to budget optimization strategy"
            )
        
        # Analyze usage patterns
        if self.usage_history:
            # Find most expensive operations
            operations_cost = {}
            for entry in self.usage_history:
                op = entry["operation"]
                operations_cost[op] = operations_cost.get(op, 0) + entry["cost"]
            
            # Get top cost drivers
            sorted_ops = sorted(operations_cost.items(), key=lambda x: x[1], reverse=True)
            if sorted_ops:
                top_op, top_cost = sorted_ops[0]
                if top_cost > self.budget * 0.3:
                    recommendations.append(
                        f"'{top_op}' consumes {top_cost/self.budget*100:.1f}% of budget - optimize this stage"
                    )
        
        # Model recommendations
        model_costs = {}
        for entry in self.usage_history:
            model = entry.get("model", "unknown")
            model_costs[model] = model_costs.get(model, 0) + entry["cost"]
        
        for model, cost in model_costs.items():
            if cost > self.budget * 0.4:
                recommendations.append(
                    f"Consider alternatives to {model} - currently {cost/self.budget*100:.1f}% of budget"
                )
        
        return recommendations


# Global cost optimizer instance
cost_optimizer = CostOptimizer()


# Export main components
__all__ = [
    'CostOptimizer',
    'cost_optimizer',
    'CostPrediction',
    'OptimizationStrategy',
    'ModelProvider',
    'ModelPricing',
    'PRICING_MATRIX'
]