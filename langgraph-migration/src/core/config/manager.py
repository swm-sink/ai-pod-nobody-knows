"""
Centralized configuration management system.

This module provides a unified configuration system that supports
multiple environments, hot-reloading, and provider-agnostic settings.

Version: 1.0.0
Date: August 2025
"""

import os
import json
import yaml
from pathlib import Path
from typing import Any, Dict, Optional, List, Union
from dataclasses import dataclass, field, asdict
from enum import Enum
import logging
from datetime import datetime


logger = logging.getLogger(__name__)


class Environment(Enum):
    """Supported environments."""
    DEVELOPMENT = "development"
    TESTING = "testing"
    STAGING = "staging"
    PRODUCTION = "production"


@dataclass
class ProviderConfig:
    """Provider-specific configuration."""
    provider_type: str
    enabled: bool = True
    api_key: Optional[str] = None
    endpoint: Optional[str] = None
    timeout: int = 30
    retry_attempts: int = 3
    extra_config: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary, excluding sensitive data."""
        data = asdict(self)
        if self.api_key:
            data['api_key'] = "***REDACTED***"
        return data


@dataclass
class AgentConfig:
    """Agent-specific configuration."""
    agent_id: str
    name: str
    description: str
    enabled: bool = True
    budget: float = 1.0
    timeout: int = 60
    retry_policy: Dict[str, Any] = field(default_factory=dict)
    prompt_template_id: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class WorkflowConfig:
    """Workflow configuration."""
    workflow_id: str
    name: str
    description: str
    agents: List[str]
    orchestrator: str = "langgraph"
    observability: str = "langfuse"
    cost_limit: float = 10.0
    timeout: int = 300
    metadata: Dict[str, Any] = field(default_factory=dict)


class ConfigManager:
    """
    Centralized configuration manager.

    Handles all configuration loading, validation, and hot-reloading
    for the modular podcast production system.
    """

    def __init__(
        self,
        config_dir: Optional[Path] = None,
        environment: Optional[Environment] = None
    ):
        """
        Initialize configuration manager.

        Args:
            config_dir: Configuration directory path
            environment: Target environment
        """
        self.config_dir = config_dir or Path("config")
        self.environment = environment or self._detect_environment()
        self._config_cache: Dict[str, Any] = {}
        self._load_configurations()

    def _detect_environment(self) -> Environment:
        """Detect current environment from env variable or default."""
        env_str = os.getenv("PODCAST_ENV", "development").lower()
        try:
            return Environment(env_str)
        except ValueError:
            logger.warning(f"Unknown environment: {env_str}, defaulting to development")
            return Environment.DEVELOPMENT

    def _load_configurations(self) -> None:
        """Load all configuration files."""
        # Load base configuration
        base_config = self._load_file("config.yaml")

        # Load environment-specific configuration
        env_config = self._load_file(f"config.{self.environment.value}.yaml")

        # Load provider configurations
        providers_config = self._load_file("providers.yaml")

        # Load agent configurations
        agents_config = self._load_file("agents.yaml")

        # Load workflow configurations
        workflows_config = self._load_file("workflows.yaml")

        # Load prompt templates
        prompts_config = self._load_file("prompts.yaml")

        # Merge configurations with precedence
        self._config_cache = self._merge_configs(
            base_config,
            env_config,
            {
                "providers": providers_config,
                "agents": agents_config,
                "workflows": workflows_config,
                "prompts": prompts_config
            }
        )

        # Load secrets from environment variables
        self._load_secrets()

        # Validate configuration
        self._validate_configuration()

    def _load_file(self, filename: str) -> Dict[str, Any]:
        """Load configuration file."""
        filepath = self.config_dir / filename

        if not filepath.exists():
            logger.debug(f"Configuration file not found: {filepath}")
            return {}

        try:
            with open(filepath, 'r') as f:
                if filepath.suffix in ['.yaml', '.yml']:
                    return yaml.safe_load(f) or {}
                elif filepath.suffix == '.json':
                    return json.load(f)
                else:
                    logger.warning(f"Unknown config file type: {filepath}")
                    return {}
        except Exception as e:
            logger.error(f"Error loading config file {filepath}: {e}")
            return {}

    def _merge_configs(self, *configs: Dict[str, Any]) -> Dict[str, Any]:
        """Merge multiple configuration dictionaries."""
        result = {}
        for config in configs:
            result = self._deep_merge(result, config)
        return result

    def _deep_merge(self, base: Dict[str, Any], override: Dict[str, Any]) -> Dict[str, Any]:
        """Deep merge two dictionaries."""
        result = base.copy()

        for key, value in override.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = self._deep_merge(result[key], value)
            else:
                result[key] = value

        return result

    def _load_secrets(self) -> None:
        """Load secrets from environment variables."""
        # Load API keys
        for provider_id in self.get_provider_ids():
            env_key = f"{provider_id.upper()}_API_KEY"
            if env_value := os.getenv(env_key):
                self._set_nested(
                    self._config_cache,
                    f"providers.{provider_id}.api_key",
                    env_value
                )

        # Load other secrets
        secret_mappings = {
            "OPENAI_API_KEY": "providers.openai.api_key",  # pragma: allowlist secret
            "ANTHROPIC_API_KEY": "providers.anthropic.api_key",  # pragma: allowlist secret
            "PERPLEXITY_API_KEY": "providers.perplexity.api_key",  # pragma: allowlist secret
            "ELEVENLABS_API_KEY": "providers.elevenlabs.api_key",  # pragma: allowlist secret
            "LANGFUSE_PUBLIC_KEY": "providers.langfuse.public_key",  # pragma: allowlist secret
            "LANGFUSE_SECRET_KEY": "providers.langfuse.secret_key",  # pragma: allowlist secret
        }

        for env_key, config_path in secret_mappings.items():
            if env_value := os.getenv(env_key):
                self._set_nested(self._config_cache, config_path, env_value)

    def _set_nested(self, data: Dict[str, Any], path: str, value: Any) -> None:
        """Set a nested dictionary value using dot notation."""
        keys = path.split('.')
        current = data

        for key in keys[:-1]:
            if key not in current:
                current[key] = {}
            current = current[key]

        current[keys[-1]] = value

    def _get_nested(self, data: Dict[str, Any], path: str, default: Any = None) -> Any:
        """Get a nested dictionary value using dot notation."""
        keys = path.split('.')
        current = data

        for key in keys:
            if isinstance(current, dict) and key in current:
                current = current[key]
            else:
                return default

        return current

    def _validate_configuration(self) -> None:
        """Validate configuration integrity."""
        errors = []
        warnings = []

        # Validate required providers (warnings for missing, not errors)
        required_providers = ['langgraph', 'langfuse', 'perplexity']
        for provider in required_providers:
            if not self.get_provider_config(provider):
                warnings.append(f"Provider not configured: {provider}")

        # Validate agent configurations (if any exist)
        for agent_id in self.get_agent_ids():
            agent_config = self.get_agent_config(agent_id)
            if not agent_config:
                warnings.append(f"Invalid agent configuration: {agent_id}")
            elif agent_config.budget <= 0:
                errors.append(f"Invalid budget for agent {agent_id}: {agent_config.budget}")

        # Validate workflow configurations (if any exist)
        for workflow_id in self.get_workflow_ids():
            workflow_config = self.get_workflow_config(workflow_id)
            if not workflow_config:
                warnings.append(f"Invalid workflow configuration: {workflow_id}")
            elif workflow_config.cost_limit <= 0:
                errors.append(f"Invalid cost limit for workflow {workflow_id}")

        # Log warnings
        for warning in warnings:
            logger.warning(warning)

        # Only fail on actual errors, not missing optional configurations
        if errors:
            error_msg = "Configuration validation failed:\n" + "\n".join(errors)
            logger.error(error_msg)
            raise ValueError(error_msg)

    def get(self, path: str, default: Any = None) -> Any:
        """Get configuration value by path."""
        return self._get_nested(self._config_cache, path, default)

    def set(self, path: str, value: Any) -> None:
        """Set configuration value by path."""
        self._set_nested(self._config_cache, path, value)

    def get_provider_config(self, provider_id: str) -> Optional[ProviderConfig]:
        """Get provider configuration."""
        # Check all provider categories
        for category in ['orchestration', 'observability', 'llm', 'research', 'audio', 'vectordb']:
            config_data = self.get(f"{category}.providers.{provider_id}")
            if config_data:
                return ProviderConfig(
                    provider_type=provider_id,
                    enabled=config_data.get('enabled', True),
                    api_key=config_data.get('config', {}).get('api_key') or config_data.get('api_key'),
                    endpoint=config_data.get('config', {}).get('endpoint') or config_data.get('endpoint'),
                    timeout=config_data.get('config', {}).get('timeout', 30),
                    retry_attempts=config_data.get('config', {}).get('retry_attempts', 3),
                    extra_config=config_data.get('config', {})
                )

        return None

    def get_agent_config(self, agent_id: str) -> Optional[AgentConfig]:
        """Get agent configuration."""
        config_data = self.get(f"agents.{agent_id}")
        if not config_data:
            return None

        return AgentConfig(
            agent_id=agent_id,
            name=config_data.get('name', agent_id),
            description=config_data.get('description', ''),
            enabled=config_data.get('enabled', True),
            budget=config_data.get('budget', 1.0),
            timeout=config_data.get('timeout', 60),
            retry_policy=config_data.get('retry_policy', {}),
            prompt_template_id=config_data.get('prompt_template'),
            metadata=config_data.get('metadata', {})
        )

    def get_workflow_config(self, workflow_id: str) -> Optional[WorkflowConfig]:
        """Get workflow configuration."""
        config_data = self.get(f"workflows.{workflow_id}")
        if not config_data:
            return None

        return WorkflowConfig(
            workflow_id=workflow_id,
            name=config_data.get('name', workflow_id),
            description=config_data.get('description', ''),
            agents=config_data.get('agents', []),
            orchestrator=config_data.get('orchestrator', 'langgraph'),
            observability=config_data.get('observability', 'langfuse'),
            cost_limit=config_data.get('cost_limit', 10.0),
            timeout=config_data.get('timeout', 300),
            metadata=config_data.get('metadata', {})
        )

    def get_prompt_template(self, template_id: str) -> Optional[str]:
        """Get prompt template."""
        return self.get(f"prompts.{template_id}")

    def get_provider_ids(self) -> List[str]:
        """Get all configured provider IDs."""
        providers = self.get('providers', {})
        return list(providers.keys())

    def get_agent_ids(self) -> List[str]:
        """Get all configured agent IDs."""
        agents = self.get('agents', {})
        return list(agents.keys())

    def get_workflow_ids(self) -> List[str]:
        """Get all configured workflow IDs."""
        workflows = self.get('workflows', {})
        return list(workflows.keys())

    def reload(self) -> None:
        """Reload configuration from files."""
        logger.info("Reloading configuration...")
        self._config_cache = {}
        self._load_configurations()
        logger.info("Configuration reloaded successfully")

    def export(self, filepath: Path, include_secrets: bool = False) -> None:
        """Export current configuration to file."""
        config_copy = self._config_cache.copy()

        if not include_secrets:
            # Redact sensitive information
            self._redact_secrets(config_copy)

        with open(filepath, 'w') as f:
            if filepath.suffix in ['.yaml', '.yml']:
                yaml.safe_dump(config_copy, f, default_flow_style=False)
            else:
                json.dump(config_copy, f, indent=2)

        logger.info(f"Configuration exported to {filepath}")

    def _redact_secrets(self, config: Dict[str, Any]) -> None:
        """Redact sensitive information from configuration."""
        secret_keys = ['api_key', 'secret_key', 'password', 'token']

        def redact_recursive(data: Union[Dict, List, Any]) -> None:
            if isinstance(data, dict):
                for key, value in data.items():
                    if any(secret in key.lower() for secret in secret_keys):
                        data[key] = "***REDACTED***"
                    else:
                        redact_recursive(value)
            elif isinstance(data, list):
                for item in data:
                    redact_recursive(item)

        redact_recursive(config)


# Singleton instance
_config_manager: Optional[ConfigManager] = None


def get_config_manager() -> ConfigManager:
    """Get or create configuration manager singleton."""
    global _config_manager
    if _config_manager is None:
        _config_manager = ConfigManager()
    return _config_manager


def reset_config_manager() -> None:
    """Reset configuration manager singleton."""
    global _config_manager
    _config_manager = None
