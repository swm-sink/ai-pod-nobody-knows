#!/usr/bin/env python3
"""
Feature Flag System - Minimal Implementation (GREEN PHASE)
===========================================================

This is the minimal implementation to make tests pass.
Focus: Make tests pass, not optimize or add extra features.

Educational: This demonstrates TDD GREEN phase - implement just enough
to make tests pass, no more.
"""

import json
import os
import hashlib
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List
import logging

logger = logging.getLogger(__name__)


class FeatureFlagException(Exception):
    """Custom exception for feature flag operations"""
    pass


class FeatureFlag:
    """
    Simple feature flag representation
    
    Educational: Start with minimal data structure, enhance later
    """
    def __init__(self, name: str, enabled: bool, description: str = ""):
        self.name = name
        self.enabled = enabled
        self.description = description
        self.created_at = datetime.now().isoformat()
        self.updated_at = self.created_at


class ABTestConfig:
    """
    A/B test configuration
    
    Educational: Define interface first, implement logic to pass tests
    """
    def __init__(self, feature_name: str, control_percentage: int, 
                 treatment_percentage: int, metrics_to_track: List[str] = None):
        if control_percentage + treatment_percentage != 100:
            raise ValueError("Control and treatment percentages must sum to 100")
            
        self.feature_name = feature_name
        self.control_percentage = control_percentage
        self.treatment_percentage = treatment_percentage
        self.metrics_to_track = metrics_to_track or []


class ShadowModeConfig:
    """
    Shadow mode testing configuration
    
    Educational: Shadow mode allows testing without affecting production
    """
    def __init__(self, feature_name: str, shadow_percentage: int,
                 comparison_metrics: List[str], alert_threshold_difference: float = 0.1):
        self.feature_name = feature_name
        self.shadow_percentage = shadow_percentage
        self.comparison_metrics = comparison_metrics
        self.alert_threshold_difference = alert_threshold_difference


class CostOptimizationFlags:
    """
    Cost optimization feature flag controls
    
    Educational: Feature flags enable safe cost optimization experimentation
    """
    def __init__(self, manager: 'FeatureFlagManager'):
        self.manager = manager
        self.episode_costs: Dict[str, float] = {}
        self.budget_limits: Dict[str, float] = {}
        
    def can_use_advanced_optimization(self) -> bool:
        """Check if advanced optimization is allowed"""
        # Advanced requires basic to be enabled first
        return (self.manager.is_enabled("basic_cost_optimization") and 
                self.manager.is_enabled("advanced_cost_optimization"))
    
    def set_episode_budget_limit(self, limit: float):
        """Set budget limit for episodes"""
        self.budget_limits["default"] = limit
        
    def track_episode_cost(self, episode_id: str, cost: float):
        """Track cost for an episode"""
        if episode_id not in self.episode_costs:
            self.episode_costs[episode_id] = 0.0
        self.episode_costs[episode_id] += cost
        
    def can_continue_optimization(self, episode_id: str) -> bool:
        """Check if we can continue optimization without exceeding budget"""
        current_cost = self.episode_costs.get(episode_id, 0.0)
        budget_limit = self.budget_limits.get("default", float('inf'))
        return current_cost <= budget_limit


class FeatureFlagManager:
    """
    Core Feature Flag Manager - Minimal Implementation
    
    Educational: Implement just enough to pass tests, optimize later
    """
    
    def __init__(self, config_file: str = "feature_flags.json"):
        self.config_file = config_file
        self.flags: Dict[str, FeatureFlag] = {}
        self.ab_tests: Dict[str, ABTestConfig] = {}
        self.shadow_configs: Dict[str, ShadowModeConfig] = {}
        self.flag_history: Dict[str, List[Dict]] = {}
        self.failure_tracking: Dict[str, List[Dict]] = {}
        self.auto_rollback_configs: Dict[str, Dict] = {}
        self.shadow_results: Dict[str, Dict] = {}
        
        self._load_config()
        
    def _load_config(self):
        """Load configuration from file"""
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r') as f:
                    data = json.load(f)
                    
                # Load flags
                for name, flag_data in data.get("flags", {}).items():
                    flag = FeatureFlag(name, flag_data["enabled"], flag_data.get("description", ""))
                    self.flags[name] = flag
                    
            except Exception as e:
                logger.error(f"Failed to load config: {e}")
        else:
            # Create default configuration
            self._create_default_config()
            
    def _create_default_config(self):
        """Create safe default configuration"""
        defaults = {
            "cost_optimization": True,      # Safe, enables cost tracking
            "shadow_mode_testing": False,   # Safe default - disabled
            "experimental_features": False  # Safe default - disabled
        }
        
        for name, enabled in defaults.items():
            self.flags[name] = FeatureFlag(name, enabled, f"Default {name} configuration")
            
        self._save_config()
        
    def _save_config(self):
        """Save configuration to file"""
        data = {
            "flags": {},
            "last_updated": datetime.now().isoformat()
        }
        
        for name, flag in self.flags.items():
            data["flags"][name] = {
                "enabled": flag.enabled,
                "description": flag.description,
                "created_at": flag.created_at,
                "updated_at": flag.updated_at
            }
            
        with open(self.config_file, 'w') as f:
            json.dump(data, f, indent=2)
            
    def is_enabled(self, flag_name: str) -> bool:
        """Check if a feature flag is enabled"""
        if flag_name not in self.flags:
            return False
        return self.flags[flag_name].enabled
        
    def set_flag(self, flag_name: str, enabled: bool, description: str = ""):
        """Set a feature flag value"""
        if flag_name in self.flags:
            self.flags[flag_name].enabled = enabled
            self.flags[flag_name].updated_at = datetime.now().isoformat()
        else:
            self.flags[flag_name] = FeatureFlag(flag_name, enabled, description)
            
        # Record in history
        if flag_name not in self.flag_history:
            self.flag_history[flag_name] = []
            
        self.flag_history[flag_name].append({
            "action": "set_flag",
            "enabled": enabled,
            "description": description,
            "timestamp": datetime.now().isoformat()
        })
        
        self._save_config()
        
    def emergency_disable(self, flag_name: str, reason: str):
        """Emergency disable a feature flag"""
        if flag_name in self.flags:
            self.flags[flag_name].enabled = False
            self.flags[flag_name].updated_at = datetime.now().isoformat()
            
        # Record emergency disable in history
        if flag_name not in self.flag_history:
            self.flag_history[flag_name] = []
            
        self.flag_history[flag_name].append({
            "action": "emergency_disable",
            "reason": reason,
            "timestamp": datetime.now().isoformat()
        })
        
        self._save_config()
        
    def get_flag_history(self, flag_name: str) -> List[Dict]:
        """Get history of changes for a flag"""
        return self.flag_history.get(flag_name, [])
        
    def configure_ab_test(self, config: ABTestConfig):
        """Configure an A/B test"""
        self.ab_tests[config.feature_name] = config
        
    def is_in_treatment_group(self, feature_name: str, episode_id: str) -> bool:
        """Determine if episode is in treatment group (deterministic)"""
        if feature_name not in self.ab_tests:
            return False
            
        # Use hash for deterministic assignment
        hash_input = f"{feature_name}_{episode_id}".encode()
        hash_value = int(hashlib.md5(hash_input).hexdigest(), 16)
        percentage = hash_value % 100
        
        treatment_threshold = self.ab_tests[feature_name].treatment_percentage
        return percentage < treatment_threshold
        
    def configure_shadow_mode(self, config: ShadowModeConfig):
        """Configure shadow mode testing"""
        self.shadow_configs[config.feature_name] = config
        
    def should_run_shadow_test(self, feature_name: str, episode_id: str) -> bool:
        """Determine if shadow test should run for episode"""
        if feature_name not in self.shadow_configs:
            return False
            
        # Use hash for deterministic assignment
        hash_input = f"shadow_{feature_name}_{episode_id}".encode()
        hash_value = int(hashlib.md5(hash_input).hexdigest(), 16)
        percentage = hash_value % 100
        
        shadow_threshold = self.shadow_configs[feature_name].shadow_percentage
        return percentage < shadow_threshold
        
    def record_production_results(self, feature_name: str, episode_id: str, results: Dict[str, Any]):
        """Record production results for comparison"""
        key = f"{feature_name}_{episode_id}"
        if key not in self.shadow_results:
            self.shadow_results[key] = {}
        self.shadow_results[key]["production"] = results
        
    def record_shadow_results(self, feature_name: str, episode_id: str, results: Dict[str, Any]):
        """Record shadow test results"""
        key = f"{feature_name}_{episode_id}"
        if key not in self.shadow_results:
            self.shadow_results[key] = {}
        self.shadow_results[key]["shadow"] = results
        
    def get_shadow_comparison(self, feature_name: str, episode_id: str) -> Dict[str, float]:
        """Get comparison between production and shadow results"""
        key = f"{feature_name}_{episode_id}"
        if key not in self.shadow_results:
            return {}
            
        results = self.shadow_results[key]
        if "production" not in results or "shadow" not in results:
            return {}
            
        comparison = {}
        prod_results = results["production"]
        shadow_results = results["shadow"]
        
        for metric in prod_results:
            if metric in shadow_results:
                prod_value = prod_results[metric]
                shadow_value = shadow_results[metric]
                
                if prod_value != 0:
                    improvement = (shadow_value - prod_value) / prod_value
                    
                    # Map metrics to improvement names
                    if "quality" in metric:
                        comparison[f"{metric}_improvement"] = improvement
                    elif "cost" in metric:
                        comparison["cost_savings"] = -improvement  # Lower cost is better
                    elif "speed" in metric or "time" in metric:
                        comparison["speed_improvement"] = -improvement  # Lower time is better
                        
        return comparison
        
    def emergency_kill_all_experimental(self, reason: str):
        """Emergency disable all experimental features"""
        experimental_flags = [
            "experimental_voice_model",
            "beta_cost_optimization", 
            "new_script_format"
        ]
        
        for flag_name in experimental_flags:
            if flag_name in self.flags:
                self.emergency_disable(flag_name, f"Kill switch: {reason}")
                
    def configure_auto_rollback(self, feature_name: str, failure_threshold: int, time_window_minutes: int):
        """Configure automatic rollback on failures"""
        self.auto_rollback_configs[feature_name] = {
            "failure_threshold": failure_threshold,
            "time_window_minutes": time_window_minutes
        }
        
    def report_feature_failure(self, feature_name: str, error_message: str):
        """Report a feature failure"""
        if feature_name not in self.failure_tracking:
            self.failure_tracking[feature_name] = []
            
        self.failure_tracking[feature_name].append({
            "error": error_message,
            "timestamp": datetime.now()
        })
        
        # Check if we should auto-rollback
        if feature_name in self.auto_rollback_configs:
            config = self.auto_rollback_configs[feature_name]
            recent_failures = self._get_recent_failures(feature_name, config["time_window_minutes"])
            
            if len(recent_failures) >= config["failure_threshold"]:
                self.emergency_disable(feature_name, f"Auto-rollback: {config['failure_threshold']} failures in {config['time_window_minutes']} minutes")
                
                # Add to history
                if feature_name not in self.flag_history:
                    self.flag_history[feature_name] = []
                    
                self.flag_history[feature_name].append({
                    "action": "auto_rollback",
                    "reason": f"Failure threshold exceeded: {len(recent_failures)} failures",
                    "timestamp": datetime.now().isoformat()
                })
                
    def _get_recent_failures(self, feature_name: str, time_window_minutes: int) -> List[Dict]:
        """Get recent failures within time window"""
        if feature_name not in self.failure_tracking:
            return []
            
        cutoff_time = datetime.now() - timedelta(minutes=time_window_minutes)
        recent_failures = []
        
        for failure in self.failure_tracking[feature_name]:
            if failure["timestamp"] > cutoff_time:
                recent_failures.append(failure)
                
        return recent_failures
        
    def is_enabled_for_episode(self, flag_name: str, episode_id: str) -> bool:
        """Check if flag is enabled for specific episode (with episode tracking)"""
        # For now, just return the global flag status
        # In REFACTOR phase, we can add per-episode logic
        return self.is_enabled(flag_name)
        
    def should_use_pro_model(self, tool_name: str) -> bool:
        """Check if should use pro model for MCP tool"""
        return self.is_enabled(f"use_{tool_name}_pro_model")
        
    def should_enable_caching(self, tool_name: str) -> bool:
        """Check if should enable caching for MCP tool"""
        return self.is_enabled(f"enable_{tool_name}_caching")
        
    def should_batch_queries(self) -> bool:
        """Check if should batch MCP queries"""
        return self.is_enabled("batch_mcp_queries")


# Educational Notes:
"""
GREEN PHASE IMPLEMENTATION PRINCIPLES:

1. **Just Enough**: Only implement what makes tests pass
2. **Simple Data Structures**: Use basic dict/list, optimize later
3. **Minimal Logic**: Simple if/else, complex algorithms in REFACTOR
4. **Placeholder Methods**: Some methods just return basic values
5. **No Premature Optimization**: Focus on correctness, not performance

WHAT'S MISSING (intentionally, for REFACTOR phase):
- Advanced error handling
- Performance optimizations  
- Complex validation logic
- Monitoring and metrics
- Database persistence
- Distributed coordination

This is exactly what TDD teaches - build incrementally!
"""