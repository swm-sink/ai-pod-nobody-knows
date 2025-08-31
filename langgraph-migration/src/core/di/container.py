"""
Dependency injection container for modular components.

This module provides a dependency injection system that enables
easy swapping of providers, testing with mocks, and clean architecture.

Version: 1.0.0
Date: August 2025
"""

from typing import Any, Callable, Dict, List, Optional, Type, TypeVar, Union
from dataclasses import dataclass, field
from enum import Enum
import inspect
import logging
from functools import wraps
from threading import Lock


logger = logging.getLogger(__name__)


T = TypeVar('T')


class Scope(Enum):
    """Dependency scope types."""
    SINGLETON = "singleton"  # Single instance for entire application
    TRANSIENT = "transient"  # New instance every time
    REQUEST = "request"      # Single instance per request/workflow


@dataclass
class Dependency:
    """Dependency registration."""
    interface: Type
    implementation: Union[Type, Callable, Any]
    scope: Scope = Scope.SINGLETON
    factory: Optional[Callable] = None
    instance: Optional[Any] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


class DIContainer:
    """
    Dependency injection container.

    Manages component registration, resolution, and lifecycle.
    Supports multiple scopes, factories, and decorator-based injection.
    """

    def __init__(self):
        """Initialize dependency injection container."""
        self._dependencies: Dict[Type, Dependency] = {}
        self._factories: Dict[Type, Callable] = {}
        self._singletons: Dict[Type, Any] = {}
        self._request_cache: Dict[Type, Any] = {}
        self._lock = Lock()
        self._setup_default_bindings()

    def _setup_default_bindings(self) -> None:
        """Set up default component bindings."""
        # Import here to avoid circular dependencies
        from ..config.manager import ConfigManager, get_config_manager
        from ..templates.manager import PromptTemplateManager, get_template_manager

        # Register default singletons
        self.register_singleton(ConfigManager, factory=get_config_manager)
        self.register_singleton(PromptTemplateManager, factory=get_template_manager)

    def register(
        self,
        interface: Type[T],
        implementation: Optional[Union[Type[T], T]] = None,
        scope: Scope = Scope.SINGLETON,
        factory: Optional[Callable[[], T]] = None,
        **metadata
    ) -> None:
        """
        Register a dependency.

        Args:
            interface: Interface or base class
            implementation: Concrete implementation class or instance
            scope: Dependency scope
            factory: Optional factory function
            **metadata: Additional metadata
        """
        with self._lock:
            if implementation is None and factory is None:
                raise ValueError("Either implementation or factory must be provided")

            dependency = Dependency(
                interface=interface,
                implementation=implementation,
                scope=scope,
                factory=factory,
                metadata=metadata
            )

            self._dependencies[interface] = dependency

            # If instance provided and singleton, store it
            if scope == Scope.SINGLETON and not callable(implementation):
                self._singletons[interface] = implementation

    def register_singleton(
        self,
        interface: Type[T],
        implementation: Optional[Union[Type[T], T]] = None,
        factory: Optional[Callable[[], T]] = None,
        **metadata
    ) -> None:
        """Register a singleton dependency."""
        self.register(interface, implementation, Scope.SINGLETON, factory, **metadata)

    def register_transient(
        self,
        interface: Type[T],
        implementation: Type[T],
        factory: Optional[Callable[[], T]] = None,
        **metadata
    ) -> None:
        """Register a transient dependency."""
        self.register(interface, implementation, Scope.TRANSIENT, factory, **metadata)

    def register_request(
        self,
        interface: Type[T],
        implementation: Type[T],
        factory: Optional[Callable[[], T]] = None,
        **metadata
    ) -> None:
        """Register a request-scoped dependency."""
        self.register(interface, implementation, Scope.REQUEST, factory, **metadata)

    def resolve(self, interface: Type[T], **kwargs) -> T:
        """
        Resolve a dependency.

        Args:
            interface: Interface to resolve
            **kwargs: Optional arguments for factory/constructor

        Returns:
            Resolved instance

        Raises:
            ValueError: If dependency not registered
        """
        with self._lock:
            if interface not in self._dependencies:
                raise ValueError(f"No registration found for {interface.__name__}")

            dependency = self._dependencies[interface]

            # Handle different scopes
            if dependency.scope == Scope.SINGLETON:
                return self._resolve_singleton(dependency, **kwargs)
            elif dependency.scope == Scope.TRANSIENT:
                return self._resolve_transient(dependency, **kwargs)
            elif dependency.scope == Scope.REQUEST:
                return self._resolve_request(dependency, **kwargs)
            else:
                raise ValueError(f"Unknown scope: {dependency.scope}")

    def _resolve_singleton(self, dependency: Dependency, **kwargs) -> Any:
        """Resolve singleton dependency."""
        interface = dependency.interface

        # Check if already instantiated
        if interface in self._singletons:
            return self._singletons[interface]

        # Create instance
        instance = self._create_instance(dependency, **kwargs)
        self._singletons[interface] = instance

        return instance

    def _resolve_transient(self, dependency: Dependency, **kwargs) -> Any:
        """Resolve transient dependency."""
        return self._create_instance(dependency, **kwargs)

    def _resolve_request(self, dependency: Dependency, **kwargs) -> Any:
        """Resolve request-scoped dependency."""
        interface = dependency.interface

        # Check request cache
        if interface in self._request_cache:
            return self._request_cache[interface]

        # Create instance for this request
        instance = self._create_instance(dependency, **kwargs)
        self._request_cache[interface] = instance

        return instance

    def _create_instance(self, dependency: Dependency, **kwargs) -> Any:
        """Create an instance of a dependency."""
        # Use factory if provided
        if dependency.factory:
            return dependency.factory(**kwargs)

        # Use implementation
        implementation = dependency.implementation

        # If already an instance, return it
        if not inspect.isclass(implementation):
            return implementation

        # Auto-inject constructor dependencies
        return self._auto_inject_constructor(implementation, **kwargs)

    def _auto_inject_constructor(self, cls: Type, **kwargs) -> Any:
        """Auto-inject constructor dependencies."""
        # Get constructor signature
        sig = inspect.signature(cls.__init__)

        # Prepare arguments
        args = {}
        for param_name, param in sig.parameters.items():
            if param_name == 'self':
                continue

            # Check if provided in kwargs
            if param_name in kwargs:
                args[param_name] = kwargs[param_name]
                continue

            # Try to resolve by type annotation
            if param.annotation != inspect.Parameter.empty:
                try:
                    args[param_name] = self.resolve(param.annotation)
                except ValueError:
                    # If can't resolve and has default, skip
                    if param.default == inspect.Parameter.empty:
                        raise ValueError(
                            f"Cannot resolve parameter {param_name} of type {param.annotation}"
                        )

        return cls(**args)

    def clear_request_cache(self) -> None:
        """Clear request-scoped cache."""
        with self._lock:
            self._request_cache.clear()

    def reset(self) -> None:
        """Reset container to initial state."""
        with self._lock:
            self._dependencies.clear()
            self._singletons.clear()
            self._request_cache.clear()
            self._setup_default_bindings()

    def get_registrations(self) -> Dict[str, Dict[str, Any]]:
        """Get all current registrations."""
        registrations = {}

        for interface, dependency in self._dependencies.items():
            registrations[interface.__name__] = {
                "implementation": (
                    dependency.implementation.__name__
                    if inspect.isclass(dependency.implementation)
                    else str(type(dependency.implementation))
                ),
                "scope": dependency.scope.value,
                "has_factory": dependency.factory is not None,
                "metadata": dependency.metadata
            }

        return registrations

    def has_registration(self, interface: Type) -> bool:
        """Check if interface is registered."""
        return interface in self._dependencies

    def override(
        self,
        interface: Type[T],
        implementation: Union[Type[T], T],
        scope: Optional[Scope] = None
    ) -> None:
        """
        Override an existing registration.

        Useful for testing with mocks.
        """
        with self._lock:
            if interface not in self._dependencies:
                raise ValueError(f"No existing registration for {interface.__name__}")

            existing = self._dependencies[interface]
            self._dependencies[interface] = Dependency(
                interface=interface,
                implementation=implementation,
                scope=scope or existing.scope,
                factory=None,
                metadata=existing.metadata
            )

            # Clear any cached instances
            if interface in self._singletons:
                del self._singletons[interface]
            if interface in self._request_cache:
                del self._request_cache[interface]


# Global container instance
_container: Optional[DIContainer] = None
_container_lock = Lock()


def get_container() -> DIContainer:
    """Get or create global DI container."""
    global _container
    with _container_lock:
        if _container is None:
            _container = DIContainer()
        return _container


def reset_container() -> None:
    """Reset global DI container."""
    global _container
    with _container_lock:
        if _container:
            _container.reset()
        _container = None


def inject(func: Callable) -> Callable:
    """
    Decorator for dependency injection.

    Automatically injects dependencies based on type annotations.
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        container = get_container()
        sig = inspect.signature(func)

        # Inject missing parameters
        for param_name, param in sig.parameters.items():
            if param_name in kwargs:
                continue

            if param.annotation != inspect.Parameter.empty:
                if container.has_registration(param.annotation):
                    kwargs[param_name] = container.resolve(param.annotation)

        return func(*args, **kwargs)

    return wrapper


def injectable(cls: Type[T]) -> Type[T]:
    """
    Class decorator for dependency injection.

    Marks a class as injectable and auto-registers it.
    """
    container = get_container()

    # Auto-register as transient by default
    container.register_transient(cls, cls)

    # Modify __init__ to support injection
    original_init = cls.__init__

    @wraps(original_init)
    def new_init(self, *args, **kwargs):
        # Auto-inject dependencies
        sig = inspect.signature(original_init)
        for param_name, param in sig.parameters.items():
            if param_name == 'self':
                continue
            if param_name not in kwargs and param.annotation != inspect.Parameter.empty:
                if container.has_registration(param.annotation):
                    kwargs[param_name] = container.resolve(param.annotation)

        original_init(self, *args, **kwargs)

    cls.__init__ = new_init
    return cls


class ServiceLocator:
    """
    Service locator pattern for dependency resolution.

    Alternative to constructor injection for legacy code.
    """

    @staticmethod
    def get(interface: Type[T]) -> T:
        """Get a service by interface."""
        return get_container().resolve(interface)

    @staticmethod
    def register(
        interface: Type[T],
        implementation: Union[Type[T], T],
        scope: Scope = Scope.SINGLETON
    ) -> None:
        """Register a service."""
        get_container().register(interface, implementation, scope)

    @staticmethod
    def reset() -> None:
        """Reset service locator."""
        reset_container()
