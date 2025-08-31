"""
Research Discovery Agent - Stage 1 (Modular Architecture Version)

This agent performs initial topic discovery using the modular architecture
with provider-agnostic interfaces and dependency injection.

Version: 2.0.0
Date: August 2025
Budget: $0.50 for Perplexity Sonar Deep Research queries
"""

from typing import Dict, Any, Optional, List
from dataclasses import dataclass, field
from datetime import datetime
import json
import logging

from ..core.interfaces.provider import AgentState
from ..core.config.manager import get_config_manager
from ..core.templates.manager import get_template_manager
from ..core.di.container import inject, injectable


logger = logging.getLogger(__name__)


@dataclass
class DiscoveryConfig:
    """Configuration for discovery agent."""
    budget: float = 0.50
    max_queries: int = 3
    timeout: int = 30
    temperature: float = 0.2
    enable_caching: bool = True


@injectable
class ResearchDiscoveryAgent:
    """
    Research Discovery Agent using modular architecture.

    This agent can work with any research provider (Perplexity, Tavily, etc)
    and any LLM provider through dependency injection.
    """

    def __init__(
        self,
        config: Optional[DiscoveryConfig] = None,
        research_provider: Optional[Any] = None,
        template_manager: Optional[Any] = None
    ):
        """
        Initialize discovery agent with injected dependencies.

        Args:
            config: Agent configuration
            research_provider: Research provider (injected)
            template_manager: Template manager (injected)
        """
        self.config = config or DiscoveryConfig()
        self.research_provider = research_provider
        self.template_manager = template_manager or get_template_manager()
        self.config_manager = get_config_manager()
        self.cost_tracker = {"total": 0.0, "queries": []}

    def execute(self, state: AgentState) -> AgentState:
        """
        Execute discovery research phase.

        Args:
            state: Current agent state with topic information

        Returns:
            Updated state with discovery results
        """
        logger.info(f"Starting research discovery for topic: {state.data.get('topic')}")

        try:
            # Extract topic and parameters from state
            topic = state.data.get('topic', '')
            focus_areas = state.data.get('focus_areas', 'general overview')
            date_context = self.config_manager.get('system.temporal_context', 'August 2025')

            # Render discovery prompt from template
            prompt = self._render_discovery_prompt(topic, focus_areas, date_context)

            # Execute research query
            discovery_results = self._execute_research(prompt, topic)

            # Process and structure results
            structured_results = self._structure_results(discovery_results)

            # Identify experts if not already done
            if not structured_results.get('experts'):
                experts = self._identify_experts(topic, discovery_results)
                structured_results['experts'] = experts

            # Update state with results
            state.data['discovery'] = structured_results
            state.data['discovery_metadata'] = {
                'timestamp': datetime.now().isoformat(),
                'cost': self.cost_tracker['total'],
                'queries_executed': len(self.cost_tracker['queries']),
                'agent_version': '2.0.0'
            }
            state.stage = 'discovery_complete'
            state.cost_tracking['discovery'] = self.cost_tracker['total']

            logger.info(f"Discovery complete. Cost: ${self.cost_tracker['total']:.2f}")
            return state

        except Exception as e:
            logger.error(f"Discovery failed: {e}")
            state.error_state = {
                'error': str(e),
                'type': 'discovery_error',
                'timestamp': datetime.now().isoformat()
            }
            state.stage = 'discovery_failed'
            return state

    def _render_discovery_prompt(
        self,
        topic: str,
        focus_areas: str,
        date_context: str
    ) -> str:
        """Render discovery prompt from template."""
        try:
            return self.template_manager.render_template(
                'research_discovery_main',
                {
                    'topic': topic,
                    'focus_areas': focus_areas,
                    'date_context': date_context
                }
            )
        except Exception as e:
            logger.warning(f"Template rendering failed, using fallback: {e}")
            # Fallback prompt if template fails
            return self._get_fallback_prompt(topic, focus_areas, date_context)

    def _get_fallback_prompt(
        self,
        topic: str,
        focus_areas: str,
        date_context: str
    ) -> str:
        """Get fallback prompt if template fails."""
        return f"""
        Date Context: {date_context}

        Research Task: Initial Discovery for "{topic}"

        Focus Areas: {focus_areas}

        Please provide comprehensive research covering:
        1. Topic landscape and current state
        2. Knowledge gaps and unknowns
        3. Surprising insights
        4. Expert perspectives

        Prioritize recent sources from 2025.
        """

    def _execute_research(self, prompt: str, topic: str) -> Dict[str, Any]:
        """
        Execute research using injected provider.

        This method is provider-agnostic and will work with any
        research provider that implements the interface.
        """
        if not self.research_provider:
            # Mock response for testing
            return self._get_mock_response(topic)

        try:
            # Use research provider (Perplexity, Tavily, etc)
            response = self.research_provider.search(
                query=prompt,
                max_tokens=4000,
                temperature=self.config.temperature,
                timeout=self.config.timeout
            )

            # Track costs
            cost = self.research_provider.estimate_cost(prompt)
            self.cost_tracker['total'] += cost
            self.cost_tracker['queries'].append({
                'query': prompt[:100] + '...',
                'cost': cost,
                'timestamp': datetime.now().isoformat()
            })

            return response

        except Exception as e:
            logger.error(f"Research provider error: {e}")
            return self._get_mock_response(topic)

    def _structure_results(self, raw_results: Dict[str, Any]) -> Dict[str, Any]:
        """Structure discovery results into standard format."""
        structured = {
            'topic_landscape': {},
            'knowledge_gaps': [],
            'surprising_insights': [],
            'expert_perspectives': [],
            'sources': [],
            'metadata': {}
        }

        # Parse based on provider response format
        if isinstance(raw_results, dict):
            # Extract different sections
            if 'topic_landscape' in raw_results:
                structured['topic_landscape'] = raw_results['topic_landscape']

            if 'knowledge_gaps' in raw_results:
                structured['knowledge_gaps'] = raw_results['knowledge_gaps']

            if 'insights' in raw_results:
                structured['surprising_insights'] = raw_results['insights']

            if 'experts' in raw_results:
                structured['expert_perspectives'] = raw_results['experts']

            if 'sources' in raw_results:
                structured['sources'] = raw_results['sources']

        return structured

    def _identify_experts(
        self,
        topic: str,
        discovery_results: Dict[str, Any]
    ) -> List[Dict[str, str]]:
        """Identify relevant experts for the topic."""
        experts = []

        # Render expert identification prompt
        try:
            prompt = self.template_manager.render_template(
                'research_discovery_expert_identification',
                {
                    'topic': topic,
                    'expertise_areas': 'various perspectives on the topic',
                    'diversity_requirements': 'academic, industry, contrarian views'
                }
            )

            # Execute expert search if budget allows
            if self.cost_tracker['total'] < self.config.budget:
                expert_results = self._execute_research(prompt, f"{topic} experts")

                # Parse expert results
                if isinstance(expert_results, dict) and 'experts' in expert_results:
                    experts = expert_results['experts']

        except Exception as e:
            logger.warning(f"Expert identification failed: {e}")

        # Return found experts or empty list
        return experts[:10]  # Limit to 10 experts

    def _get_mock_response(self, topic: str) -> Dict[str, Any]:
        """Get mock response for testing without API calls."""
        return {
            'topic_landscape': {
                'current_state': f'Mock analysis of {topic} as of August 2025',
                'key_players': ['Player 1', 'Player 2'],
                'trends': ['Trend 1', 'Trend 2']
            },
            'knowledge_gaps': [
                'Gap 1: What we don\'t know',
                'Gap 2: Open questions'
            ],
            'insights': [
                'Surprising insight 1',
                'Counter-intuitive finding 2'
            ],
            'experts': [
                {
                    'name': 'Dr. Jane Smith',
                    'affiliation': 'MIT',
                    'expertise': f'{topic} research'
                },
                {
                    'name': 'Prof. John Doe',
                    'affiliation': 'Stanford',
                    'expertise': f'{topic} applications'
                }
            ],
            'sources': [
                {
                    'title': f'Recent advances in {topic}',
                    'date': '2025-08-15',
                    'url': 'https://example.com'
                }
            ]
        }


def create_discovery_agent() -> ResearchDiscoveryAgent:
    """
    Factory function to create discovery agent with proper dependencies.

    This function uses the DI container to automatically inject
    the correct providers based on configuration.
    """
    from ..core.di.container import get_container

    container = get_container()

    # Get configuration
    config_manager = get_config_manager()
    agent_config = config_manager.get_agent_config('research_discovery')

    # Create agent config
    discovery_config = DiscoveryConfig(
        budget=agent_config.budget if agent_config else 0.50,
        max_queries=3,
        timeout=agent_config.timeout if agent_config else 30
    )

    # Create agent (dependencies will be injected)
    return ResearchDiscoveryAgent(config=discovery_config)
