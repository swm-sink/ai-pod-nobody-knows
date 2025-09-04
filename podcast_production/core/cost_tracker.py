"""
Comprehensive cost tracking system for podcast production.

This module provides real-time cost tracking, CSV logging, budget enforcement,
and cost analysis for all providers and models used in the production pipeline.

Version: 1.0.0
Date: August 2025
"""

import csv
import json
import logging
import os
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
from pathlib import Path
import statistics

logger = logging.getLogger(__name__)


class BudgetExceededException(Exception):
    """Raised when budget limit is exceeded."""
    pass


class CostTracker:
    """
    Comprehensive cost tracking system with real-time monitoring and CSV logging.
    
    Features:
    - Real-time cost tracking per agent and provider
    - CSV logging for analysis
    - Budget enforcement with warnings and hard stops
    - Cost estimation before execution
    - Model-specific pricing calculations
    """
    
    # Provider pricing (per 1K tokens unless specified)
    PRICING = {
        'openai': {
            'gpt-4o': {'input': 0.0025, 'output': 0.01},
            'gpt-4o-mini': {'input': 0.00015, 'output': 0.0006},
            'gpt-3.5-turbo': {'input': 0.0005, 'output': 0.0015},
            'text-embedding-3-small': {'input': 0.00002, 'output': 0.0},
        },
        'anthropic': {
            'claude-3-5-sonnet-20241022': {'input': 0.003, 'output': 0.015},
            'claude-3-haiku-20240307': {'input': 0.00025, 'output': 0.00125},
            'claude-3-opus-20240229': {'input': 0.015, 'output': 0.075},
        },
        'perplexity': {
            'llama-3.1-sonar-small-128k-online': {'input': 0.0002, 'output': 0.0002},
            'llama-3.1-sonar-large-128k-online': {'input': 0.001, 'output': 0.001},
            'llama-3.1-sonar-huge-128k-online': {'input': 0.005, 'output': 0.005},
        },
        'google': {
            'gemini-pro-1.5': {'input': 0.00125, 'output': 0.005},
            'gemini-flash-1.5': {'input': 0.000075, 'output': 0.0003},
        },
        'elevenlabs': {
            # Per character pricing
            'characters': 0.0001,  # $0.0001 per character
        }
    }
    
    def __init__(self, budget_limit: float = 5.51, episode_id: str = None):
        """
        Initialize cost tracker.
        
        Args:
            budget_limit: Maximum budget for episode production
            episode_id: Episode identifier for tracking
        """
        self.budget_limit = budget_limit
        self.episode_id = episode_id or f"ep_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        # Cost tracking
        self.costs: List[Dict[str, Any]] = []
        self.total_cost = 0.0
        self.cost_by_agent: Dict[str, float] = {}
        self.cost_by_provider: Dict[str, float] = {}
        
        # CSV logging setup
        self.logs_dir = Path("logs")
        self.logs_dir.mkdir(exist_ok=True)
        self.csv_file = self.logs_dir / "costs.csv"
        
        # Initialize CSV file if it doesn't exist
        self._initialize_csv()
        
        logger.info(f"CostTracker initialized - Budget: ${budget_limit:.2f}, Episode: {self.episode_id}")
    
    def _initialize_csv(self):
        """Initialize CSV file with headers if it doesn't exist."""
        if not self.csv_file.exists():
            with open(self.csv_file, 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow([
                    'timestamp', 'episode_id', 'agent', 'provider', 'model',
                    'input_tokens', 'output_tokens', 'characters', 'cost',
                    'cumulative_cost', 'budget_remaining', 'operation'
                ])
    
    def estimate_cost(
        self,
        provider: str,
        model: str,
        input_tokens: int = 0,
        output_tokens: int = 0,
        characters: int = 0
    ) -> float:
        """
        Estimate cost for an operation before execution.
        
        Args:
            provider: Provider name (openai, anthropic, perplexity, elevenlabs)
            model: Model name
            input_tokens: Estimated input tokens
            output_tokens: Estimated output tokens
            characters: Character count for TTS services
            
        Returns:
            Estimated cost in dollars
        """
        provider_lower = provider.lower()
        
        if provider_lower == 'elevenlabs':
            return characters * self.PRICING['elevenlabs']['characters']
        
        if provider_lower not in self.PRICING:
            logger.warning(f"Unknown provider: {provider}, using default pricing")
            return (input_tokens + output_tokens) * 0.001  # Default $0.001 per 1K tokens
        
        provider_pricing = self.PRICING[provider_lower]
        if model not in provider_pricing:
            logger.warning(f"Unknown model: {model} for provider {provider}")
            # Use average pricing for provider
            models = list(provider_pricing.values())
            if models:
                avg_input = statistics.mean([m['input'] for m in models])
                avg_output = statistics.mean([m['output'] for m in models])
                model_pricing = {'input': avg_input, 'output': avg_output}
            else:
                model_pricing = {'input': 0.001, 'output': 0.001}
        else:
            model_pricing = provider_pricing[model]
        
        # Calculate cost per 1K tokens
        input_cost = (input_tokens / 1000) * model_pricing['input']
        output_cost = (output_tokens / 1000) * model_pricing['output']
        
        return input_cost + output_cost
    
    def track_cost(
        self,
        agent_name: str,
        provider: str,
        model: str,
        input_tokens: int = 0,
        output_tokens: int = 0,
        characters: int = 0,
        cost: float = None,
        operation: str = ""
    ) -> float:
        """
        Track cost for an operation.
        
        Args:
            agent_name: Name of the agent making the call
            provider: Provider name
            model: Model name
            input_tokens: Input tokens used
            output_tokens: Output tokens used
            characters: Character count for TTS
            cost: Actual cost (if known), otherwise calculated
            operation: Description of operation
            
        Returns:
            Actual cost tracked
            
        Raises:
            BudgetExceededException: If budget would be exceeded
        """
        # Calculate cost if not provided
        if cost is None:
            cost = self.estimate_cost(provider, model, input_tokens, output_tokens, characters)
        
        # Check if this would exceed budget
        projected_total = self.total_cost + cost
        if projected_total > self.budget_limit:
            raise BudgetExceededException(
                f"Operation would exceed budget: ${projected_total:.4f} > ${self.budget_limit:.2f}"
            )
        
        # Update tracking
        self.total_cost += cost
        
        # Update by-agent tracking
        if agent_name not in self.cost_by_agent:
            self.cost_by_agent[agent_name] = 0.0
        self.cost_by_agent[agent_name] += cost
        
        # Update by-provider tracking
        provider_key = provider.lower()
        if provider_key not in self.cost_by_provider:
            self.cost_by_provider[provider_key] = 0.0
        self.cost_by_provider[provider_key] += cost
        
        # Create cost entry
        cost_entry = {
            'timestamp': datetime.now().isoformat(),
            'episode_id': self.episode_id,
            'agent': agent_name,
            'provider': provider,
            'model': model,
            'input_tokens': input_tokens,
            'output_tokens': output_tokens,
            'characters': characters,
            'cost': cost,
            'cumulative_cost': self.total_cost,
            'budget_remaining': self.budget_limit - self.total_cost,
            'operation': operation
        }
        
        # Add to memory
        self.costs.append(cost_entry)
        
        # Log to CSV
        self._log_to_csv(cost_entry)
        
        # Check budget warnings
        self._check_budget_warnings()
        
        logger.info(
            f"Cost tracked: {agent_name} via {provider}/{model} - "
            f"${cost:.4f} (Total: ${self.total_cost:.4f})"
        )
        
        return cost
    
    def _log_to_csv(self, cost_entry: Dict[str, Any]):
        """Log cost entry to CSV file."""
        try:
            with open(self.csv_file, 'a', newline='') as f:
                writer = csv.writer(f)
                writer.writerow([
                    cost_entry['timestamp'],
                    cost_entry['episode_id'],
                    cost_entry['agent'],
                    cost_entry['provider'],
                    cost_entry['model'],
                    cost_entry['input_tokens'],
                    cost_entry['output_tokens'],
                    cost_entry['characters'],
                    cost_entry['cost'],
                    cost_entry['cumulative_cost'],
                    cost_entry['budget_remaining'],
                    cost_entry['operation']
                ])
        except Exception as e:
            logger.error(f"Failed to log to CSV: {e}")
    
    def _check_budget_warnings(self):
        """Check and issue budget warnings."""
        budget_used_percent = (self.total_cost / self.budget_limit) * 100
        
        if budget_used_percent >= 90:
            logger.warning(f"CRITICAL: {budget_used_percent:.1f}% of budget used!")
        elif budget_used_percent >= 80:
            logger.warning(f"WARNING: {budget_used_percent:.1f}% of budget used")
        elif budget_used_percent >= 60:
            logger.info(f"INFO: {budget_used_percent:.1f}% of budget used")
    
    def check_budget_remaining(self) -> float:
        """
        Get remaining budget.
        
        Returns:
            Remaining budget in dollars
        """
        return max(0.0, self.budget_limit - self.total_cost)
    
    def can_afford(
        self,
        provider: str,
        model: str,
        input_tokens: int = 0,
        output_tokens: int = 0,
        characters: int = 0
    ) -> bool:
        """
        Check if an operation can be afforded within budget.
        
        Returns:
            True if operation can be afforded
        """
        estimated_cost = self.estimate_cost(provider, model, input_tokens, output_tokens, characters)
        return (self.total_cost + estimated_cost) <= self.budget_limit
    
    def get_cost_breakdown(self) -> Dict[str, Any]:
        """
        Get detailed cost breakdown.
        
        Returns:
            Dictionary with cost analysis
        """
        return {
            'total_cost': self.total_cost,
            'budget_limit': self.budget_limit,
            'budget_remaining': self.check_budget_remaining(),
            'budget_used_percent': (self.total_cost / self.budget_limit) * 100,
            'cost_by_agent': dict(self.cost_by_agent),
            'cost_by_provider': dict(self.cost_by_provider),
            'operation_count': len(self.costs),
            'average_cost_per_operation': self.total_cost / len(self.costs) if self.costs else 0.0
        }
    
    def export_report(self, format: str = 'json') -> str:
        """
        Export cost report in specified format.
        
        Args:
            format: Report format ('json', 'text')
            
        Returns:
            Formatted report string
        """
        breakdown = self.get_cost_breakdown()
        
        if format == 'json':
            return json.dumps(breakdown, indent=2)
        
        elif format == 'text':
            report = f"""
=== COST TRACKING REPORT ===
Episode: {self.episode_id}
Timestamp: {datetime.now().isoformat()}

BUDGET SUMMARY:
- Total Cost: ${breakdown['total_cost']:.4f}
- Budget Limit: ${breakdown['budget_limit']:.2f}
- Budget Remaining: ${breakdown['budget_remaining']:.4f}
- Budget Used: {breakdown['budget_used_percent']:.1f}%

COST BY AGENT:
"""
            for agent, cost in breakdown['cost_by_agent'].items():
                report += f"- {agent}: ${cost:.4f}\n"
            
            report += "\nCOST BY PROVIDER:\n"
            for provider, cost in breakdown['cost_by_provider'].items():
                report += f"- {provider}: ${cost:.4f}\n"
            
            report += f"""
OPERATIONS:
- Total Operations: {breakdown['operation_count']}
- Average Cost/Operation: ${breakdown['average_cost_per_operation']:.4f}

RECENT OPERATIONS:
"""
            # Show last 5 operations
            for cost_entry in self.costs[-5:]:
                report += f"- {cost_entry['timestamp']}: {cost_entry['agent']} via {cost_entry['provider']}/{cost_entry['model']} - ${cost_entry['cost']:.4f}\n"
            
            return report.strip()
        
        else:
            raise ValueError(f"Unsupported format: {format}")
    
    def reset(self, new_episode_id: str = None):
        """
        Reset tracker for new episode.
        
        Args:
            new_episode_id: New episode ID
        """
        if new_episode_id:
            self.episode_id = new_episode_id
        else:
            self.episode_id = f"ep_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        self.costs.clear()
        self.total_cost = 0.0
        self.cost_by_agent.clear()
        self.cost_by_provider.clear()
        
        logger.info(f"CostTracker reset for episode: {self.episode_id}")
    
    def get_model_recommendations(self) -> Dict[str, str]:
        """
        Get model recommendations based on current budget usage.
        
        Returns:
            Dictionary with recommended models by provider
        """
        budget_used_percent = (self.total_cost / self.budget_limit) * 100
        
        if budget_used_percent >= 80:
            # High budget usage - recommend cheapest models
            return {
                'openai': 'gpt-4o-mini',
                'anthropic': 'claude-3-haiku-20240307',
                'perplexity': 'llama-3.1-sonar-small-128k-online'
            }
        elif budget_used_percent >= 60:
            # Medium budget usage - balanced models
            return {
                'openai': 'gpt-4o-mini',
                'anthropic': 'claude-3-5-sonnet-20241022',
                'perplexity': 'llama-3.1-sonar-large-128k-online'
            }
        else:
            # Low budget usage - premium models allowed
            return {
                'openai': 'gpt-4o',
                'anthropic': 'claude-3-5-sonnet-20241022',
                'perplexity': 'llama-3.1-sonar-huge-128k-online'
            }
    
    def to_dict(self) -> Dict[str, Any]:
        """
        Convert CostTracker to serializable dictionary for msgpack.
        Following August 2025 LangGraph best practices.
        
        Returns:
            Serializable dictionary representation
        """
        return {
            'budget_limit': self.budget_limit,
            'episode_id': self.episode_id,
            'total_cost': self.total_cost,
            'cost_by_agent': dict(self.cost_by_agent),
            'cost_by_provider': dict(self.cost_by_provider),
            'operation_count': len(self.costs),
            # Don't serialize full cost history to keep state lightweight
            'last_5_operations': self.costs[-5:] if self.costs else []
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'CostTracker':
        """
        Reconstruct CostTracker from serialized dictionary.
        Following August 2025 LangGraph best practices.
        
        Args:
            data: Serialized dictionary from to_dict()
            
        Returns:
            Reconstructed CostTracker instance
        """
        tracker = cls(
            budget_limit=data.get('budget_limit', 5.51),
            episode_id=data.get('episode_id')
        )
        tracker.total_cost = data.get('total_cost', 0.0)
        tracker.cost_by_agent = data.get('cost_by_agent', {})
        tracker.cost_by_provider = data.get('cost_by_provider', {})
        # Restore recent operations if available
        if 'last_5_operations' in data:
            tracker.costs = data['last_5_operations']
        return tracker


def create_cost_tracker(budget_limit: float = 5.51, episode_id: str = None) -> CostTracker:
    """
    Factory function to create a cost tracker instance.
    
    Args:
        budget_limit: Maximum budget for episode
        episode_id: Episode identifier
        
    Returns:
        Configured CostTracker instance
    """
    return CostTracker(budget_limit=budget_limit, episode_id=episode_id)


class CostTrackingMixin:
    """
    Mixin class to add cost tracking capabilities to agents.
    """
    
    def __init__(self, cost_tracker: CostTracker = None, *args, **kwargs):
        """
        Initialize with cost tracking.
        
        Args:
            cost_tracker: CostTracker instance
        """
        super().__init__(*args, **kwargs)
        self.cost_tracker = cost_tracker or create_cost_tracker()
    
    def track_operation_cost(
        self,
        provider: str,
        model: str,
        input_tokens: int = 0,
        output_tokens: int = 0,
        characters: int = 0,
        operation: str = ""
    ) -> float:
        """
        Track cost for an operation performed by this agent.
        
        Args:
            provider: Provider name
            model: Model name
            input_tokens: Input tokens used
            output_tokens: Output tokens used
            characters: Character count for TTS
            operation: Description of operation
            
        Returns:
            Cost tracked
        """
        agent_name = getattr(self, 'name', self.__class__.__name__)
        return self.cost_tracker.track_cost(
            agent_name=agent_name,
            provider=provider,
            model=model,
            input_tokens=input_tokens,
            output_tokens=output_tokens,
            characters=characters,
            operation=operation
        )
    
    def check_budget_before_operation(
        self,
        provider: str,
        model: str,
        estimated_tokens: int = 1000
    ) -> bool:
        """
        Check if operation can be performed within budget.
        
        Args:
            provider: Provider name
            model: Model name
            estimated_tokens: Estimated token usage
            
        Returns:
            True if operation can be afforded
        """
        return self.cost_tracker.can_afford(
            provider=provider,
            model=model,
            input_tokens=estimated_tokens,
            output_tokens=estimated_tokens
        )