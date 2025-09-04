#!/usr/bin/env python3
"""
Enhanced ML-Based Cost Prediction Engine
Extends cost optimizer with machine learning predictions and real-time alerts
Version: 1.0.0 - September 2025 Production Standards
"""

import os
import json
import pickle
import asyncio
from typing import Dict, Any, List, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime, timedelta
import numpy as np
from collections import deque

import redis
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
import joblib

from core.cost_optimizer import CostOptimizer, CostPrediction, OptimizationStrategy
from core.apm import apm


@dataclass
class CostForecast:
    """Enhanced cost forecast with confidence intervals"""
    point_estimate: float
    lower_bound: float  # 95% confidence interval
    upper_bound: float
    confidence: float
    risk_level: str  # low, medium, high
    recommendations: List[str]


class MLCostPredictor:
    """Machine learning-based cost predictor"""
    
    def __init__(self, base_optimizer: Optional[CostOptimizer] = None):
        """Initialize ML predictor with base optimizer"""
        self.base_optimizer = base_optimizer or CostOptimizer()
        self.redis_client = None
        self.model_cache = {}
        self.feature_buffer = deque(maxlen=1000)
        self.prediction_history = deque(maxlen=100)
        
        # Initialize ML models
        self.models = {
            "linear": LinearRegression(),
            "forest": RandomForestRegressor(n_estimators=50, max_depth=10, random_state=42)
        }
        self.scaler = StandardScaler()
        self.is_trained = False
        
        # Initialize Redis
        try:
            self.redis_client = redis.Redis(
                host=os.getenv("REDIS_HOST", "localhost"),
                port=int(os.getenv("REDIS_PORT", "6379")),
                decode_responses=False  # For binary data (model storage)
            )
            self.redis_client.ping()
            self._load_models()
        except Exception as e:
            print(f"Redis initialization failed: {e}")
    
    def _extract_features(self, operation_data: Dict[str, Any]) -> np.ndarray:
        """Extract features from operation data for ML prediction"""
        features = []
        
        # Time-based features
        now = datetime.now()
        features.append(now.hour)  # Hour of day
        features.append(now.weekday())  # Day of week
        features.append(now.day)  # Day of month
        
        # Operation features
        features.append(operation_data.get("input_tokens", 0))
        features.append(operation_data.get("expected_output_tokens", 0))
        features.append(operation_data.get("required_quality", 0.9))
        
        # Historical features
        features.append(self.base_optimizer.spent)  # Current spend
        features.append(self.base_optimizer.budget - self.base_optimizer.spent)  # Remaining budget
        features.append(len(self.base_optimizer.usage_history))  # Operations count
        
        # Operation type encoding (one-hot)
        operation_types = ["research", "writing", "evaluation", "synthesis", "audio"]
        operation = operation_data.get("operation", "").lower()
        for op_type in operation_types:
            features.append(1.0 if op_type in operation else 0.0)
        
        return np.array(features).reshape(1, -1)
    
    async def train_models(self, min_samples: int = 30) -> bool:
        """Train ML models on historical data"""
        if not self.redis_client:
            return False
        
        try:
            # Load historical data
            historical_data = await self._load_historical_data()
            
            if len(historical_data) < min_samples:
                return False
            
            # Prepare training data
            X = []
            y = []
            
            for record in historical_data:
                features = self._extract_features(record["input"])
                X.append(features[0])
                y.append(record["actual_cost"])
            
            X = np.array(X)
            y = np.array(y)
            
            # Fit scaler
            X_scaled = self.scaler.fit_transform(X)
            
            # Train models
            for name, model in self.models.items():
                model.fit(X_scaled, y)
            
            self.is_trained = True
            
            # Save models to Redis
            await self._save_models()
            
            return True
            
        except Exception as e:
            print(f"Model training failed: {e}")
            return False
    
    async def predict_with_ml(self, operation_data: Dict[str, Any]) -> CostForecast:
        """Predict cost using ML models with confidence intervals"""
        
        # Get base prediction
        base_prediction = await self.base_optimizer.predict_cost(
            operation=operation_data.get("operation", "unknown"),
            input_tokens=operation_data.get("input_tokens", 1000),
            expected_output_tokens=operation_data.get("expected_output_tokens", 2000),
            required_quality=operation_data.get("required_quality", 0.9)
        )
        
        if not self.is_trained:
            # Fall back to base prediction
            return CostForecast(
                point_estimate=base_prediction.predicted_cost,
                lower_bound=base_prediction.predicted_cost * 0.9,
                upper_bound=base_prediction.predicted_cost * 1.1,
                confidence=base_prediction.confidence,
                risk_level="medium",
                recommendations=[]
            )
        
        # Extract features
        features = self._extract_features(operation_data)
        features_scaled = self.scaler.transform(features)
        
        # Get predictions from all models
        predictions = []
        for name, model in self.models.items():
            pred = model.predict(features_scaled)[0]
            predictions.append(pred)
        
        # Ensemble prediction
        ml_estimate = np.mean(predictions)
        std_dev = np.std(predictions)
        
        # Weighted average with base prediction
        final_estimate = (ml_estimate * 0.6 + base_prediction.predicted_cost * 0.4)
        
        # Calculate confidence intervals
        lower_bound = max(0, final_estimate - 1.96 * std_dev)
        upper_bound = final_estimate + 1.96 * std_dev
        
        # Assess risk level
        budget_remaining = self.base_optimizer.budget - self.base_optimizer.spent
        risk_level = self._assess_risk_level(final_estimate, upper_bound, budget_remaining)
        
        # Generate recommendations
        recommendations = await self._generate_recommendations(
            final_estimate, 
            base_prediction,
            risk_level
        )
        
        # Track prediction for learning
        self.prediction_history.append({
            "timestamp": datetime.now().isoformat(),
            "predicted": final_estimate,
            "confidence": base_prediction.confidence,
            "operation": operation_data.get("operation")
        })
        
        return CostForecast(
            point_estimate=final_estimate,
            lower_bound=lower_bound,
            upper_bound=upper_bound,
            confidence=base_prediction.confidence,
            risk_level=risk_level,
            recommendations=recommendations
        )
    
    def _assess_risk_level(self, estimate: float, upper_bound: float, budget_remaining: float) -> str:
        """Assess risk level based on estimates and budget"""
        if upper_bound > budget_remaining:
            return "high"
        elif estimate > budget_remaining * 0.8:
            return "medium"
        else:
            return "low"
    
    async def _generate_recommendations(self, 
                                       estimate: float, 
                                       base_prediction: CostPrediction,
                                       risk_level: str) -> List[str]:
        """Generate actionable recommendations"""
        recommendations = []
        
        if risk_level == "high":
            recommendations.append(f"⚠️ High risk of budget overrun. Consider {base_prediction.alternative_models[0]['provider']} to save ${estimate - base_prediction.alternative_models[0]['cost']:.2f}")
        
        if estimate > self.base_optimizer.budget * 0.15:
            recommendations.append(f"This operation consumes {estimate/self.base_optimizer.budget*100:.1f}% of budget - consider optimization")
        
        # Model-specific recommendations
        if base_prediction.recommended_model == "claude-3-opus" and risk_level != "low":
            recommendations.append("Consider Claude 3 Sonnet for 80% cost reduction with minimal quality impact")
        
        if base_prediction.recommended_model == "gpt-4-turbo" and estimate > 1.0:
            recommendations.append("GPT-3.5 Turbo could handle this task at 10% of the cost")
        
        return recommendations
    
    async def real_time_alert(self, threshold: float = 0.8):
        """Real-time budget alerting system"""
        utilization = self.base_optimizer.spent / self.base_optimizer.budget
        
        if utilization >= threshold:
            alert = {
                "severity": "high" if utilization > 0.95 else "medium",
                "message": f"Budget utilization at {utilization*100:.1f}%",
                "remaining": self.base_optimizer.budget - self.base_optimizer.spent,
                "recommendations": self.base_optimizer.get_recommendations()
            }
            
            # Send to APM
            await apm.track_cost(
                episode_id="current",
                stage="alert",
                cost=self.base_optimizer.spent
            )
            
            # Log to Redis
            if self.redis_client:
                self.redis_client.rpush(
                    "budget_alerts",
                    json.dumps(alert)
                )
            
            return alert
        
        return None
    
    async def forecast_episode_cost(self, pipeline_config: Dict[str, Any]) -> Dict[str, Any]:
        """Forecast total episode cost with ML predictions"""
        total_forecast = 0
        stage_forecasts = []
        max_upper_bound = 0
        
        for stage in pipeline_config.get("stages", []):
            forecast = await self.predict_with_ml(stage)
            total_forecast += forecast.point_estimate
            max_upper_bound += forecast.upper_bound
            
            stage_forecasts.append({
                "stage": stage["name"],
                "forecast": forecast.point_estimate,
                "confidence": forecast.confidence,
                "risk": forecast.risk_level,
                "recommendations": forecast.recommendations
            })
        
        # Overall risk assessment
        overall_risk = "high" if max_upper_bound > self.base_optimizer.budget else \
                      "medium" if total_forecast > self.base_optimizer.budget * 0.9 else "low"
        
        return {
            "total_forecast": total_forecast,
            "confidence_interval": {
                "lower": total_forecast * 0.9,
                "upper": max_upper_bound
            },
            "budget": self.base_optimizer.budget,
            "risk_level": overall_risk,
            "stage_forecasts": stage_forecasts,
            "proceed": total_forecast <= self.base_optimizer.budget,
            "savings_opportunity": self._identify_savings(stage_forecasts)
        }
    
    def _identify_savings(self, stage_forecasts: List[Dict]) -> List[Dict[str, Any]]:
        """Identify cost saving opportunities"""
        savings = []
        
        for stage in stage_forecasts:
            if stage["risk"] != "low":
                # Suggest cheaper alternatives
                savings.append({
                    "stage": stage["stage"],
                    "potential_savings": stage["forecast"] * 0.3,  # Estimate 30% savings possible
                    "method": "Switch to budget-optimized model",
                    "impact": "Minimal quality impact for this stage"
                })
        
        return savings
    
    async def update_with_actual(self, 
                                operation: str,
                                predicted_cost: float,
                                actual_cost: float,
                                metadata: Dict[str, Any]):
        """Update models with actual cost data for continuous learning"""
        # Track in base optimizer
        await self.base_optimizer.track_actual_cost(
            operation=operation,
            actual_cost=actual_cost,
            model_used=metadata.get("model", "unknown"),
            tokens_used=metadata.get("tokens", {})
        )
        
        # Store for retraining
        self.feature_buffer.append({
            "input": {
                "operation": operation,
                "input_tokens": metadata.get("input_tokens", 0),
                "expected_output_tokens": metadata.get("output_tokens", 0),
                "required_quality": metadata.get("quality", 0.9)
            },
            "actual_cost": actual_cost,
            "predicted_cost": predicted_cost,
            "timestamp": datetime.now().isoformat()
        })
        
        # Retrain periodically
        if len(self.feature_buffer) >= 50 and len(self.feature_buffer) % 10 == 0:
            await self.train_models()
    
    async def _load_historical_data(self) -> List[Dict[str, Any]]:
        """Load historical cost data from Redis"""
        if not self.redis_client:
            return list(self.feature_buffer)
        
        try:
            data = self.redis_client.lrange("cost_training_data", 0, -1)
            historical = []
            for item in data:
                historical.append(json.loads(item))
            
            # Combine with buffer
            historical.extend(list(self.feature_buffer))
            return historical
            
        except Exception as e:
            print(f"Failed to load historical data: {e}")
            return list(self.feature_buffer)
    
    async def _save_models(self):
        """Save trained models to Redis"""
        if not self.redis_client or not self.is_trained:
            return
        
        try:
            # Serialize models
            for name, model in self.models.items():
                model_bytes = pickle.dumps(model)
                self.redis_client.set(f"cost_model:{name}", model_bytes)
            
            # Save scaler
            scaler_bytes = pickle.dumps(self.scaler)
            self.redis_client.set("cost_scaler", scaler_bytes)
            
            # Save training timestamp
            self.redis_client.set("cost_models_updated", datetime.now().isoformat())
            
        except Exception as e:
            print(f"Failed to save models: {e}")
    
    def _load_models(self):
        """Load trained models from Redis"""
        if not self.redis_client:
            return
        
        try:
            # Load models
            for name in self.models.keys():
                model_bytes = self.redis_client.get(f"cost_model:{name}")
                if model_bytes:
                    self.models[name] = pickle.loads(model_bytes)
            
            # Load scaler
            scaler_bytes = self.redis_client.get("cost_scaler")
            if scaler_bytes:
                self.scaler = pickle.loads(scaler_bytes)
                self.is_trained = True
            
        except Exception as e:
            print(f"Failed to load models: {e}")
    
    def get_analytics_dashboard(self) -> Dict[str, Any]:
        """Get analytics dashboard data"""
        return {
            "current_status": self.base_optimizer.get_budget_status(),
            "ml_status": {
                "is_trained": self.is_trained,
                "training_samples": len(self.feature_buffer),
                "prediction_count": len(self.prediction_history)
            },
            "recent_predictions": list(self.prediction_history)[-10:],
            "recommendations": self.base_optimizer.get_recommendations()
        }


# Global ML predictor instance
ml_predictor = MLCostPredictor()


# Export main components
__all__ = [
    'MLCostPredictor',
    'ml_predictor',
    'CostForecast'
]