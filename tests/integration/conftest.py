#!/usr/bin/env python3
"""
Pytest Configuration and Fixtures for Integration Testing

This module provides comprehensive test fixtures and utilities for integration testing
of the podcast production pipeline, including:
- Mock state management classes
- Test data constants
- API response management
- Cost tracking utilities
- Quality validation helpers

Features:
- Comprehensive mocking to minimize API costs
- Realistic test data for various scenarios
- Configurable cost budgets and quality thresholds
- State persistence testing utilities
"""

import pytest
import asyncio
import json
import tempfile
import time
from pathlib import Path
from typing import Dict, Any, List, Optional, Union
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from unittest.mock import Mock, AsyncMock, MagicMock
import sys
import os

# Test Configuration Constants
COST_BUDGETS = {
    'strict': 5.51,      # Target budget for production
    'development': 8.00,  # Development/testing budget
    'emergency': 10.00   # Emergency override budget
}

QUALITY_THRESHOLDS = {
    'minimum': 6.0,      # Minimum acceptable quality
    'target': 8.0,       # Target quality standard
    'excellent': 9.0     # Excellence threshold
}

TEST_TOPICS = {
    'quantum_computing': "The Future of Quantum Computing and Its Impact on Cryptography",
    'ai_ethics': "AI Ethics in Healthcare Decision Making",
    'complex_topic': "Advanced Quantum Field Theory Applications in Computational Biology",
    'performance': "Performance Optimization in AI Pipeline Architectures",
    'fallback': "Understanding Complex Systems in Modern Technology"
}

# Mock Classes
@dataclass
class MockPodcastState:
    """
    Mock implementation of PodcastState for testing.

    Provides all the functionality of the real PodcastState but with
    simplified serialization and no external dependencies.
    """
    episode_id: str
    topic: str
    budget_limit: float
    current_cost: float = 0.0
    phase: str = 'initialized'
    research_data: Dict[str, Any] = None
    questions: List[str] = None
    episode_plan: Dict[str, Any] = None
    script: str = ''
    script_metadata: Dict[str, Any] = None
    quality_scores: Dict[str, float] = None
    audio_file: Optional[str] = None
    audio_metadata: Dict[str, Any] = None
    checkpoint_data: Dict[str, Any] = None

    def __post_init__(self):
        if self.research_data is None:
            self.research_data = {}
        if self.questions is None:
            self.questions = []
        if self.episode_plan is None:
            self.episode_plan = {}
        if self.script_metadata is None:
            self.script_metadata = {}
        if self.quality_scores is None:
            self.quality_scores = {}
        if self.audio_metadata is None:
            self.audio_metadata = {}
        if self.checkpoint_data is None:
            self.checkpoint_data = {}

    def to_dict(self) -> Dict[str, Any]:
        """Serialize state to dictionary."""
        return asdict(self)

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'MockPodcastState':
        """Deserialize state from dictionary."""
        return cls(**data)

    def add_checkpoint(self, stage: str, cost: float, metadata: Dict[str, Any] = None):
        """Add a checkpoint for cost and progress tracking."""
        self.checkpoint_data[stage] = {
            'cost': cost,
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'metadata': metadata or {}
        }
        self.current_cost += cost

    def get_total_cost(self) -> float:
        """Get total cost from checkpoints."""
        return sum(cp.get('cost', 0) for cp in self.checkpoint_data.values())

    def is_over_budget(self) -> bool:
        """Check if current cost exceeds budget limit."""
        return self.current_cost > self.budget_limit


class MockCostTracker:
    """
    Mock implementation of CostTracker for testing.

    Provides cost tracking functionality without external dependencies
    and with configurable cost simulation.
    """

    def __init__(self, initial_cost: float = 0.0):
        self.total_cost = initial_cost
        self.operations = []
        self.budget_limit = None

    def add_cost(self, amount: float, operation: str = "unknown"):
        """Add cost for an operation."""
        self.total_cost += amount
        self.operations.append({
            'operation': operation,
            'cost': amount,
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'running_total': self.total_cost
        })

        if self.budget_limit and self.total_cost > self.budget_limit:
            raise ValueError(f"Budget exceeded: ${self.total_cost:.2f} > ${self.budget_limit:.2f}")

    async def track_operation(self, operation: str, cost: float) -> float:
        """Async operation tracking."""
        self.add_cost(cost, operation)
        return cost

    def get_total_cost(self) -> float:
        """Get total accumulated cost."""
        return self.total_cost

    def set_budget_limit(self, limit: float):
        """Set budget limit for enforcement."""
        self.budget_limit = limit

    def get_operations_summary(self) -> Dict[str, Any]:
        """Get summary of all operations."""
        return {
            'total_cost': self.total_cost,
            'operation_count': len(self.operations),
            'operations': self.operations
        }

    def reset(self):
        """Reset cost tracker for new test."""
        self.total_cost = 0.0
        self.operations = []


class MockAPIResponseManager:
    """
    Manages mock API responses to minimize costs during testing.

    Provides cached responses for various API calls and scenarios,
    allowing comprehensive testing without API costs.
    """

    def __init__(self):
        self.response_cache = {}
        self.call_count = {}

    def get_perplexity_response(self, query: str, topic_key: str = 'quantum_computing') -> Dict[str, Any]:
        """Get mock Perplexity search response."""
        responses = {
            'quantum_computing': {
                "expert_insights": [
                    "Quantum computers use quantum bits (qubits) that can exist in superposition",
                    "Current quantum computers are noisy and error-prone",
                    "Quantum advantage for cryptography may arrive in 10-15 years"
                ],
                "recent_developments": [
                    "IBM's 1000-qubit processor announced in 2023",
                    "Google's error correction breakthrough",
                    "Post-quantum cryptography standards published"
                ],
                "sources": [
                    {"url": "https://quantum.example.com", "title": "Quantum Computing Progress"},
                    {"url": "https://crypto.example.com", "title": "Post-Quantum Cryptography"}
                ],
                "questions": [
                    "What makes quantum computing fundamentally different?",
                    "When will quantum computers break current encryption?",
                    "How are we preparing for quantum threats?"
                ]
            },
            'ai_ethics': {
                "expert_insights": [
                    "AI healthcare decisions require human oversight",
                    "Bias in medical AI can perpetuate health disparities",
                    "Transparency in AI medical decisions is crucial"
                ],
                "recent_developments": [
                    "New AI ethics guidelines for healthcare",
                    "FDA approval process for AI medical devices",
                    "Legal frameworks for AI liability in medicine"
                ],
                "sources": [
                    {"url": "https://aiethics.example.com", "title": "AI Ethics in Healthcare"},
                    {"url": "https://medical.example.com", "title": "Medical AI Regulations"}
                ]
            },
            'performance': {
                "expert_insights": [
                    "Pipeline optimization reduces costs and latency",
                    "Caching strategies improve response times",
                    "Load balancing essential for scalability"
                ],
                "recent_developments": [
                    "New pipeline optimization frameworks",
                    "Advanced caching algorithms",
                    "Distributed processing improvements"
                ]
            }
        }

        self._increment_call_count('perplexity', query)
        return responses.get(topic_key, responses['quantum_computing'])

    def get_script_response(self, topic_key: str = 'quantum_computing') -> Dict[str, Any]:
        """Get mock script generation response."""
        scripts = {
            'quantum_computing': {
                "script": """Welcome to Nobody Knows, where we explore what we know and what we don't.

I'm your host, and today we're diving into quantum computing and its impact on cryptography.

What we know: Quantum computers use quantum bits that can exist in multiple states simultaneously. This gives them theoretical advantages over classical computers for certain problems.

What we don't know: When exactly quantum computers will become powerful enough to break current encryption methods. Estimates range from 10 to 30 years.

But here's what we think we know: The threat is real enough that we're already developing post-quantum cryptography. The question isn't if quantum computers will challenge our current security - it's when.

So we prepare, we research, and we acknowledge the uncertainty while working with what we do know.""",
                "metadata": {
                    "word_count": 7200,
                    "estimated_duration": 45,
                    "humility_phrases": 28,
                    "questions": 15,
                    "brand_elements": "high"
                }
            }
        }

        self._increment_call_count('script_generation', topic_key)
        return scripts.get(topic_key, scripts['quantum_computing'])

    def get_quality_evaluation(self, quality_level: str = 'high') -> Dict[str, Any]:
        """Get mock quality evaluation response."""
        evaluations = {
            'high': {
                "scores": {
                    "brand_consistency": 8.5,
                    "technical_accuracy": 8.2,
                    "engagement": 8.7,
                    "readability": 8.3
                },
                "overall_score": 8.4,
                "confidence": 0.92,
                "feedback": "Excellent adherence to brand voice and technical accuracy"
            },
            'marginal': {
                "scores": {
                    "brand_consistency": 7.2,
                    "technical_accuracy": 7.8,
                    "engagement": 6.9,
                    "readability": 7.4
                },
                "overall_score": 7.3,
                "confidence": 0.78,
                "feedback": "Good content but needs improvement in engagement"
            },
            'low': {
                "scores": {
                    "brand_consistency": 5.8,
                    "technical_accuracy": 6.2,
                    "engagement": 5.5,
                    "readability": 6.1
                },
                "overall_score": 5.9,
                "confidence": 0.65,
                "feedback": "Significant improvements needed across all metrics"
            }
        }

        self._increment_call_count('quality_evaluation', quality_level)
        return evaluations.get(quality_level, evaluations['high'])

    def get_audio_synthesis_response(self, success: bool = True) -> Dict[str, Any]:
        """Get mock audio synthesis response."""
        if success:
            response = {
                "audio_file": "/tmp/mock_audio.mp3",
                "metadata": {
                    "duration": 45.2,
                    "file_size_mb": 43.1,
                    "voice_used": "Amelia",
                    "model_used": "eleven_turbo_v2_5",
                    "character_count": 35000,
                    "quality": "high"
                }
            }
        else:
            response = {
                "error": "Audio synthesis failed",
                "retry_suggested": True,
                "estimated_cost_saved": 2.50
            }

        self._increment_call_count('audio_synthesis', 'success' if success else 'failure')
        return response

    def _increment_call_count(self, service: str, operation: str):
        """Track API call counts for analysis."""
        key = f"{service}_{operation}"
        self.call_count[key] = self.call_count.get(key, 0) + 1

    def get_call_statistics(self) -> Dict[str, int]:
        """Get API call statistics."""
        return self.call_count.copy()

    def reset_statistics(self):
        """Reset call count statistics."""
        self.call_count = {}


# Pytest Fixtures

@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for async tests."""
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    yield loop
    loop.close()


@pytest.fixture(scope="session")
def test_data_dir() -> Path:
    """Directory for test data files."""
    return Path(__file__).parent / "test_data"


@pytest.fixture(scope="session")
def mock_env_vars():
    """Set up mock environment variables for testing."""
    env_vars = {
        "OPENAI_API_KEY": "test-openai-key-integration",  # pragma: allowlist secret
        "ANTHROPIC_API_KEY": "test-anthropic-key-integration",  # pragma: allowlist secret
        "ELEVENLABS_API_KEY": "test-elevenlabs-key-integration",  # pragma: allowlist secret
        "PERPLEXITY_API_KEY": "test-perplexity-key-integration",  # pragma: allowlist secret
        "LANGFUSE_PUBLIC_KEY": "test-public-key-integration",  # pragma: allowlist secret
        "LANGFUSE_SECRET_KEY": "test-secret-key-integration",  # pragma: allowlist secret
        "PRODUCTION_VOICE_ID": "test-voice-id-integration",
        "MAX_EPISODE_COST": str(COST_BUDGETS['strict']),
        "QUALITY_THRESHOLD": str(QUALITY_THRESHOLDS['target'])
    }

    # Save original env vars
    original = {k: os.environ.get(k) for k in env_vars}

    # Set test env vars
    os.environ.update(env_vars)

    yield env_vars

    # Restore original env vars
    for k, v in original.items():
        if v is None:
            os.environ.pop(k, None)
        else:
            os.environ[k] = v


@pytest.fixture
def temp_dir():
    """Create a temporary directory for test files."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


@pytest.fixture
def mock_cost_tracker():
    """Create a mock cost tracker for testing."""
    return MockCostTracker()


@pytest.fixture
def mock_api_manager():
    """Create a mock API response manager."""
    return MockAPIResponseManager()


@pytest.fixture
def sample_test_topics():
    """Provide test topics for various scenarios."""
    return TEST_TOPICS


@pytest.fixture
def cost_budgets():
    """Provide cost budget configurations."""
    return COST_BUDGETS


@pytest.fixture
def quality_thresholds():
    """Provide quality threshold configurations."""
    return QUALITY_THRESHOLDS


@pytest.fixture
def mock_podcast_state():
    """Create a mock podcast state for testing."""
    return MockPodcastState(
        episode_id="test_episode_001",
        topic=TEST_TOPICS['quantum_computing'],
        budget_limit=COST_BUDGETS['strict']
    )


@pytest.fixture
def comprehensive_test_data():
    """Provide comprehensive test data for various scenarios."""
    return {
        'research_data': {
            'quantum_computing': {
                'expert_insights': ['insight1', 'insight2'],
                'sources': ['source1', 'source2'],
                'confidence': 0.95
            },
            'ai_ethics': {
                'expert_insights': ['ethics1', 'ethics2'],
                'sources': ['ethics_source1', 'ethics_source2'],
                'confidence': 0.88
            }
        },
        'script_samples': {
            'high_quality': "Welcome to Nobody Knows... [high quality content]",
            'marginal_quality': "Today we talk about... [marginal content]",
            'low_quality': "So anyway... [low quality content]"
        },
        'quality_scores': {
            'excellent': {'brand': 9.2, 'technical': 9.0, 'engagement': 9.1},
            'good': {'brand': 8.1, 'technical': 8.3, 'engagement': 7.9},
            'marginal': {'brand': 7.2, 'technical': 7.1, 'engagement': 6.8},
            'poor': {'brand': 5.9, 'technical': 6.1, 'engagement': 5.7}
        }
    }


@pytest.fixture
def cost_validation_helper():
    """Helper function for cost validation."""
    def validate_cost(actual_cost: float, budget: float, tolerance: float = 0.01) -> bool:
        return actual_cost <= budget + tolerance
    return validate_cost


@pytest.fixture
def quality_validation_helper():
    """Helper function for quality validation."""
    def validate_quality(scores: Dict[str, float], threshold: float = 8.0) -> bool:
        if not scores:
            return False
        avg_score = sum(scores.values()) / len(scores)
        return avg_score >= threshold
    return validate_quality


@pytest.fixture
def state_persistence_helper():
    """Helper for testing state persistence."""
    def create_test_state_file(temp_dir: Path, state: MockPodcastState) -> Path:
        state_file = temp_dir / "test_state.json"
        with open(state_file, 'w') as f:
            json.dump(state.to_dict(), f, indent=2, default=str)
        return state_file
    return create_test_state_file


@pytest.fixture
def performance_monitor():
    """Monitor for performance testing."""
    class PerformanceMonitor:
        def __init__(self):
            self.start_time = None
            self.end_time = None
            self.checkpoints = {}

        def start(self):
            self.start_time = time.time()

        def checkpoint(self, name: str):
            if self.start_time:
                self.checkpoints[name] = time.time() - self.start_time

        def end(self):
            self.end_time = time.time()

        def get_duration(self) -> float:
            if self.start_time and self.end_time:
                return self.end_time - self.start_time
            return 0.0

        def get_checkpoint_times(self) -> Dict[str, float]:
            return self.checkpoints.copy()

    return PerformanceMonitor()


@pytest.fixture
def error_simulation_helper():
    """Helper for simulating various error conditions."""
    class ErrorSimulator:
        @staticmethod
        def api_failure():
            """Simulate API failure."""
            raise ConnectionError("Mock API connection failed")

        @staticmethod
        def budget_exceeded(current_cost: float, limit: float):
            """Simulate budget exceeded error."""
            raise ValueError(f"Budget exceeded: ${current_cost:.2f} > ${limit:.2f}")

        @staticmethod
        def quality_failure():
            """Simulate quality check failure."""
            return {
                "scores": {"brand": 4.5, "technical": 5.2, "engagement": 4.8},
                "passed": False,
                "message": "Quality below acceptable threshold"
            }

        @staticmethod
        def state_corruption():
            """Simulate state corruption."""
            return "{ invalid json content }"

    return ErrorSimulator()


# Test Markers Configuration
def pytest_configure(config):
    """Configure pytest with custom markers for integration tests."""
    config.addinivalue_line(
        "markers", "integration: mark test as integration test"
    )
    config.addinivalue_line(
        "markers", "cost_sensitive: mark test as cost-sensitive (uses real APIs)"
    )
    config.addinivalue_line(
        "markers", "performance: mark test as performance benchmark"
    )
    config.addinivalue_line(
        "markers", "state_management: mark test as state management test"
    )
    config.addinivalue_line(
        "markers", "error_scenario: mark test as error scenario simulation"
    )


# Test Collection Configuration
def pytest_collection_modifyitems(config, items):
    """Modify test collection to add automatic markers."""
    for item in items:
        # Mark all tests in this file as integration tests
        if "integration" in str(item.fspath):
            item.add_marker(pytest.mark.integration)

        # Add cost-sensitive marker for tests that might use real APIs
        if "cost" in item.name.lower():
            item.add_marker(pytest.mark.cost_sensitive)

        # Add performance marker for benchmark tests
        if "performance" in item.name.lower() or "benchmark" in item.name.lower():
            item.add_marker(pytest.mark.performance)
