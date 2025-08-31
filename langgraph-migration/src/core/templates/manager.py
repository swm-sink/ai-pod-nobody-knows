"""
Prompt template management system.

This module provides a centralized system for managing, versioning,
and rendering prompt templates across all agents and providers.

Version: 1.0.0
Date: August 2025
"""

import re
import json
import yaml
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from dataclasses import dataclass, field
from datetime import datetime
from jinja2 import Template, Environment, FileSystemLoader, select_autoescape
import logging


logger = logging.getLogger(__name__)


@dataclass
class PromptTemplate:
    """Prompt template definition."""
    template_id: str
    name: str
    description: str
    content: str
    variables: List[str]
    version: str = "1.0.0"
    category: str = "general"
    tags: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)

    def validate_variables(self, provided: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """Validate that all required variables are provided."""
        missing = [var for var in self.variables if var not in provided]
        return len(missing) == 0, missing

    def render(self, variables: Dict[str, Any]) -> str:
        """Render template with variables."""
        template = Template(self.content)
        return template.render(**variables)


class PromptTemplateManager:
    """
    Centralized prompt template manager.

    Manages all prompt templates, supports versioning, A/B testing,
    and hot-reloading of templates.
    """

    def __init__(
        self,
        template_dir: Optional[Path] = None,
        cache_templates: bool = True
    ):
        """
        Initialize prompt template manager.

        Args:
            template_dir: Directory containing template files
            cache_templates: Whether to cache templates in memory
        """
        self.template_dir = template_dir or Path("prompts")
        self.cache_templates = cache_templates
        self._template_cache: Dict[str, PromptTemplate] = {}
        self._jinja_env = self._setup_jinja_environment()
        self._load_templates()

    def _setup_jinja_environment(self) -> Environment:
        """Set up Jinja2 environment for advanced templating."""
        return Environment(
            loader=FileSystemLoader(self.template_dir),
            autoescape=select_autoescape(['html', 'xml']),
            trim_blocks=True,
            lstrip_blocks=True
        )

    def _load_templates(self) -> None:
        """Load all templates from directory."""
        if not self.template_dir.exists():
            logger.warning(f"Template directory not found: {self.template_dir}")
            return

        # Load YAML templates
        for yaml_file in self.template_dir.glob("**/*.yaml"):
            self._load_yaml_templates(yaml_file)

        # Load JSON templates
        for json_file in self.template_dir.glob("**/*.json"):
            self._load_json_templates(json_file)

        # Load raw text templates
        for txt_file in self.template_dir.glob("**/*.txt"):
            self._load_text_template(txt_file)

        logger.info(f"Loaded {len(self._template_cache)} prompt templates")

    def _load_yaml_templates(self, filepath: Path) -> None:
        """Load templates from YAML file."""
        try:
            with open(filepath, 'r') as f:
                data = yaml.safe_load(f)

            if isinstance(data, dict):
                # Single template or multiple templates
                if 'templates' in data:
                    for template_data in data['templates']:
                        self._add_template_from_dict(template_data)
                else:
                    self._add_template_from_dict(data)
            elif isinstance(data, list):
                # List of templates
                for template_data in data:
                    self._add_template_from_dict(template_data)
        except Exception as e:
            logger.error(f"Error loading YAML templates from {filepath}: {e}")

    def _load_json_templates(self, filepath: Path) -> None:
        """Load templates from JSON file."""
        try:
            with open(filepath, 'r') as f:
                data = json.load(f)

            if isinstance(data, dict):
                if 'templates' in data:
                    for template_data in data['templates']:
                        self._add_template_from_dict(template_data)
                else:
                    self._add_template_from_dict(data)
            elif isinstance(data, list):
                for template_data in data:
                    self._add_template_from_dict(template_data)
        except Exception as e:
            logger.error(f"Error loading JSON templates from {filepath}: {e}")

    def _load_text_template(self, filepath: Path) -> None:
        """Load a raw text template."""
        try:
            with open(filepath, 'r') as f:
                content = f.read()

            # Extract template ID from filename
            template_id = filepath.stem

            # Extract variables from content
            variables = self._extract_variables(content)

            # Create template
            template = PromptTemplate(
                template_id=template_id,
                name=template_id.replace('_', ' ').title(),
                description=f"Template from {filepath.name}",
                content=content,
                variables=variables,
                category=filepath.parent.name if filepath.parent != self.template_dir else "general"
            )

            self._template_cache[template_id] = template
        except Exception as e:
            logger.error(f"Error loading text template from {filepath}: {e}")

    def _add_template_from_dict(self, data: Dict[str, Any]) -> None:
        """Add template from dictionary data."""
        try:
            # Extract variables if not provided
            variables = data.get('variables', [])
            if not variables and 'content' in data:
                variables = self._extract_variables(data['content'])

            template = PromptTemplate(
                template_id=data['id'],
                name=data.get('name', data['id']),
                description=data.get('description', ''),
                content=data['content'],
                variables=variables,
                version=data.get('version', '1.0.0'),
                category=data.get('category', 'general'),
                tags=data.get('tags', []),
                metadata=data.get('metadata', {})
            )

            self._template_cache[template.template_id] = template
        except KeyError as e:
            logger.error(f"Missing required field in template data: {e}")
        except Exception as e:
            logger.error(f"Error creating template from dict: {e}")

    def _extract_variables(self, content: str) -> List[str]:
        """Extract variable names from template content."""
        # Look for Jinja2 variables: {{ variable_name }}
        jinja_vars = re.findall(r'\{\{\s*(\w+)\s*\}\}', content)

        # Look for Python format strings: {variable_name}
        format_vars = re.findall(r'\{(\w+)\}', content)

        # Look for percent formatting: %(variable_name)s
        percent_vars = re.findall(r'%\((\w+)\)[sdfr]', content)

        # Combine and deduplicate
        all_vars = list(set(jinja_vars + format_vars + percent_vars))

        return all_vars

    def get_template(
        self,
        template_id: str,
        version: Optional[str] = None
    ) -> Optional[PromptTemplate]:
        """
        Get a prompt template by ID.

        Args:
            template_id: Template identifier
            version: Optional version (for versioned templates)

        Returns:
            PromptTemplate if found, None otherwise
        """
        if version:
            versioned_id = f"{template_id}_v{version}"
            if versioned_id in self._template_cache:
                return self._template_cache[versioned_id]

        return self._template_cache.get(template_id)

    def render_template(
        self,
        template_id: str,
        variables: Dict[str, Any],
        version: Optional[str] = None,
        validate: bool = True
    ) -> str:
        """
        Render a template with variables.

        Args:
            template_id: Template identifier
            variables: Variables to inject
            version: Optional version
            validate: Whether to validate variables

        Returns:
            Rendered template string

        Raises:
            ValueError: If template not found or validation fails
        """
        template = self.get_template(template_id, version)
        if not template:
            raise ValueError(f"Template not found: {template_id}")

        if validate:
            valid, missing = template.validate_variables(variables)
            if not valid:
                raise ValueError(f"Missing required variables: {missing}")

        return template.render(variables)

    def add_template(self, template: PromptTemplate) -> None:
        """Add or update a template."""
        template.updated_at = datetime.now()
        self._template_cache[template.template_id] = template

        # Optionally persist to disk
        if self.template_dir:
            self._save_template(template)

    def _save_template(self, template: PromptTemplate) -> None:
        """Save template to disk."""
        filepath = self.template_dir / f"{template.category}" / f"{template.template_id}.yaml"
        filepath.parent.mkdir(parents=True, exist_ok=True)

        data = {
            'id': template.template_id,
            'name': template.name,
            'description': template.description,
            'content': template.content,
            'variables': template.variables,
            'version': template.version,
            'category': template.category,
            'tags': template.tags,
            'metadata': template.metadata,
            'updated_at': template.updated_at.isoformat()
        }

        with open(filepath, 'w') as f:
            yaml.safe_dump(data, f, default_flow_style=False)

    def list_templates(
        self,
        category: Optional[str] = None,
        tags: Optional[List[str]] = None
    ) -> List[PromptTemplate]:
        """
        List available templates.

        Args:
            category: Filter by category
            tags: Filter by tags

        Returns:
            List of matching templates
        """
        templates = list(self._template_cache.values())

        if category:
            templates = [t for t in templates if t.category == category]

        if tags:
            templates = [
                t for t in templates
                if any(tag in t.tags for tag in tags)
            ]

        return templates

    def get_categories(self) -> List[str]:
        """Get all template categories."""
        categories = set(t.category for t in self._template_cache.values())
        return sorted(list(categories))

    def get_tags(self) -> List[str]:
        """Get all template tags."""
        tags = set()
        for template in self._template_cache.values():
            tags.update(template.tags)
        return sorted(list(tags))

    def reload(self) -> None:
        """Reload all templates from disk."""
        logger.info("Reloading prompt templates...")
        self._template_cache = {}
        self._load_templates()
        logger.info(f"Reloaded {len(self._template_cache)} templates")

    def export_template(
        self,
        template_id: str,
        filepath: Path,
        format: str = "yaml"
    ) -> None:
        """Export a template to file."""
        template = self.get_template(template_id)
        if not template:
            raise ValueError(f"Template not found: {template_id}")

        data = {
            'id': template.template_id,
            'name': template.name,
            'description': template.description,
            'content': template.content,
            'variables': template.variables,
            'version': template.version,
            'category': template.category,
            'tags': template.tags,
            'metadata': template.metadata
        }

        with open(filepath, 'w') as f:
            if format == "yaml":
                yaml.safe_dump(data, f, default_flow_style=False)
            elif format == "json":
                json.dump(data, f, indent=2)
            else:
                f.write(template.content)

    def validate_all_templates(self) -> Dict[str, List[str]]:
        """Validate all templates and return any errors."""
        errors = {}

        for template_id, template in self._template_cache.items():
            template_errors = []

            # Check for empty content
            if not template.content:
                template_errors.append("Empty template content")

            # Check for undefined variables in content
            content_vars = self._extract_variables(template.content)
            undefined = [v for v in content_vars if v not in template.variables]
            if undefined:
                template_errors.append(f"Undefined variables in content: {undefined}")

            # Check for unused declared variables
            unused = [v for v in template.variables if v not in content_vars]
            if unused:
                template_errors.append(f"Declared but unused variables: {unused}")

            if template_errors:
                errors[template_id] = template_errors

        return errors


# Singleton instance
_template_manager: Optional[PromptTemplateManager] = None


def get_template_manager() -> PromptTemplateManager:
    """Get or create template manager singleton."""
    global _template_manager
    if _template_manager is None:
        _template_manager = PromptTemplateManager()
    return _template_manager


def reset_template_manager() -> None:
    """Reset template manager singleton."""
    global _template_manager
    _template_manager = None
