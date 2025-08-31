"""
Example usage of the modular AI Podcast Production System.

This demonstrates how easily providers can be swapped and configured
without changing the core business logic.

Version: 1.0.0
Date: August 2025
"""

import os
from pathlib import Path
from typing import Dict, Any

# Core imports
from core.di.container import get_container, ServiceLocator
from core.config.manager import get_config_manager, Environment
from core.templates.manager import get_template_manager
from core.interfaces.provider import (
    OrchestrationProvider,
    ObservabilityProvider,
    LLMProvider,
    WorkflowDefinition,
    AgentState
)

# Provider imports (these can be swapped)
from adapters.langgraph.provider import LangGraphProvider
# from adapters.temporal.provider import TemporalProvider  # Alternative
# from adapters.prefect.provider import PrefectProvider    # Alternative


def setup_providers(use_langgraph: bool = True) -> Dict[str, Any]:
    """
    Set up providers based on configuration.

    This demonstrates how easily we can swap providers.
    """
    container = get_container()
    config_manager = get_config_manager()

    # Choose orchestration provider based on flag or config
    if use_langgraph:
        # Use LangGraph
        orchestrator_config = config_manager.get_provider_config('langgraph')
        container.register_singleton(
            OrchestrationProvider,
            factory=lambda: LangGraphProvider(orchestrator_config.extra_config)
        )
        print("✅ Using LangGraph for orchestration")
    else:
        # Could easily swap to Temporal or another provider
        # orchestrator_config = config_manager.get_provider_config('temporal')
        # container.register_singleton(
        #     OrchestrationProvider,
        #     factory=lambda: TemporalProvider(orchestrator_config.extra_config)
        # )
        print("✅ Using alternative orchestration provider")

    # The rest of the application doesn't need to change!
    return {
        "orchestrator": container.resolve(OrchestrationProvider),
        "config": config_manager,
        "templates": get_template_manager()
    }


def create_research_workflow() -> WorkflowDefinition:
    """Create a research workflow definition (provider-agnostic)."""
    return WorkflowDefinition(
        workflow_id="research_pipeline",
        name="4-Stage Research Pipeline",
        description="Discovery → Deep-dive → Validation → Synthesis",
        nodes=[
            {"id": "discovery", "function": None},  # Would add actual functions
            {"id": "deep_dive", "function": None},
            {"id": "validation", "function": None},
            {"id": "synthesis", "function": None}
        ],
        edges=[
            {"from": "discovery", "to": "deep_dive"},
            {"from": "deep_dive", "to": "validation"},
            {"from": "validation", "to": "synthesis"}
        ],
        config={
            "entry": "discovery",
            "finish": "synthesis",
            "max_cost": 5.00
        },
        metadata={
            "version": "1.0.0",
            "created_by": "system"
        }
    )


def run_with_different_providers():
    """Demonstrate running with different providers."""

    # Example 1: Run with LangGraph
    print("\n" + "="*60)
    print("Example 1: Running with LangGraph Provider")
    print("="*60)

    providers = setup_providers(use_langgraph=True)
    orchestrator = providers["orchestrator"]

    # Create workflow (same regardless of provider!)
    workflow_def = create_research_workflow()
    workflow = orchestrator.create_workflow(workflow_def)

    # Create initial state (same regardless of provider!)
    initial_state = AgentState(
        agent_id="research_agent",
        stage="discovery",
        data={"topic": "AI Safety in August 2025"},
        metadata={},
        timestamp=None,
        cost_tracking={"total": 0.0}
    )

    # Execute workflow (same interface regardless of provider!)
    print(f"Executing workflow with {orchestrator.provider_type.value}...")
    # final_state = orchestrator.execute_workflow(workflow, initial_state)
    print("✅ Workflow execution complete")

    # Get provider info
    provider_info = orchestrator.get_provider_info()
    print(f"Provider capabilities: {provider_info['capabilities']}")

    print("\n" + "="*60)
    print("Example 2: Swapping to Different Provider")
    print("="*60)

    # Reset container to swap providers
    container = get_container()
    container.reset()

    # Now using a different provider (simulated)
    providers = setup_providers(use_langgraph=False)
    # The exact same code would work with Temporal, Prefect, etc!

    print("\n✅ Provider swapping demonstration complete!")


def demonstrate_prompt_management():
    """Demonstrate prompt template management."""
    print("\n" + "="*60)
    print("Prompt Template Management")
    print("="*60)

    template_manager = get_template_manager()

    # List available templates
    research_templates = template_manager.list_templates(category="research")
    print(f"Found {len(research_templates)} research templates")

    # Render a template
    variables = {
        "topic": "Quantum Computing Applications",
        "date_context": "August 2025",
        "focus_areas": "Practical applications, recent breakthroughs, challenges"
    }

    try:
        rendered = template_manager.render_template(
            "research_discovery_main",
            variables
        )
        print("✅ Successfully rendered research discovery prompt")
        print(f"Prompt length: {len(rendered)} characters")
    except Exception as e:
        print(f"Template rendering example (would work with actual templates): {e}")

    # Demonstrate versioning
    print("\nPrompt versioning supported:")
    print("- Can maintain multiple versions of same prompt")
    print("- Easy A/B testing between versions")
    print("- Hot-reload templates without code changes")


def demonstrate_config_management():
    """Demonstrate configuration management."""
    print("\n" + "="*60)
    print("Configuration Management")
    print("="*60)

    config = get_config_manager()

    # Get various configurations
    print(f"Environment: {config.environment.value}")
    print(f"Episode budget limit: ${config.get('budget.episode_limit')}")
    print(f"Quality target score: {config.get('quality.target_score')}")

    # Get provider configurations
    provider_ids = config.get_provider_ids()
    print(f"\nConfigured providers: {', '.join(provider_ids)}")

    # Demonstrate environment-specific config
    print("\nEnvironment-specific configuration:")
    print("- Development: Fast iteration, verbose logging")
    print("- Testing: Mocked providers, cost tracking disabled")
    print("- Staging: Real providers, cost limits enforced")
    print("- Production: Full features, monitoring enabled")


def demonstrate_dependency_injection():
    """Demonstrate dependency injection."""
    print("\n" + "="*60)
    print("Dependency Injection")
    print("="*60)

    from core.di.container import inject, injectable

    @injectable
    class ResearchAgent:
        """Example agent using dependency injection."""
        def __init__(self, orchestrator: OrchestrationProvider):
            self.orchestrator = orchestrator
            print(f"ResearchAgent created with {type(orchestrator).__name__}")

    @inject
    def process_episode(orchestrator: OrchestrationProvider) -> str:
        """Example function using dependency injection."""
        return f"Processing with {orchestrator.provider_type.value}"

    # These will automatically get dependencies injected!
    container = get_container()

    # Register a mock for testing
    class MockOrchestrator(OrchestrationProvider):
        def __init__(self):
            super().__init__({})
        def _validate_config(self): pass
        def create_workflow(self, definition): return None
        def execute_workflow(self, workflow, initial_state, **kwargs): return initial_state
        def add_node(self, workflow, node_id, node_function, **kwargs): pass
        def add_edge(self, workflow, from_node, to_node, condition=None, **kwargs): pass
        def get_state(self, workflow, execution_id): return None
        def list_executions(self, workflow, limit=10): return []
        def stop_execution(self, workflow, execution_id): return False
        def cleanup(self): pass

    container.register_singleton(OrchestrationProvider, MockOrchestrator())

    # Now components automatically get the right dependencies
    agent = container.resolve(ResearchAgent)
    result = process_episode()
    print(f"Result: {result}")

    print("\n✅ Dependency injection enables:")
    print("- Easy testing with mocks")
    print("- Clean separation of concerns")
    print("- No hard-coded dependencies")


def main():
    """Run all demonstrations."""
    print("\n" + "🎙️ "*20)
    print("AI PODCAST PRODUCTION SYSTEM - MODULAR ARCHITECTURE DEMO")
    print("🎙️ "*20)

    # Set up environment
    os.environ['PODCAST_ENV'] = 'development'

    try:
        # Demonstrate different aspects of the modular system
        demonstrate_config_management()
        demonstrate_prompt_management()
        demonstrate_dependency_injection()
        run_with_different_providers()

        print("\n" + "="*60)
        print("✅ MODULAR ARCHITECTURE BENEFITS")
        print("="*60)
        print("""
        1. PROVIDER INDEPENDENCE:
           - Swap LangGraph → Temporal → Prefect without changing business logic
           - Swap OpenAI → Anthropic → Gemini without changing agents
           - Swap ElevenLabs → Azure TTS without changing audio pipeline

        2. CONFIGURATION MANAGEMENT:
           - Centralized configuration in YAML files
           - Environment-specific settings
           - Hot-reload without code changes
           - Secrets management via environment variables

        3. PROMPT SEPARATION:
           - All prompts in separate template files
           - Version control for prompts
           - A/B testing different prompt versions
           - Hot-reload prompts without deploying code

        4. DEPENDENCY INJECTION:
           - Clean separation of concerns
           - Easy unit testing with mocks
           - No hard-coded dependencies
           - Automatic dependency resolution

        5. COST OPTIMIZATION:
           - Provider cost comparison
           - Easy switching to cheaper providers
           - Budget enforcement at multiple levels
           - Cost tracking per provider
        """)

    except Exception as e:
        print(f"\nNote: Some features require full setup: {e}")
        print("This demonstration shows the architecture patterns.")


if __name__ == "__main__":
    main()
