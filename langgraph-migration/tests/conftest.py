"""
Pytest configuration and shared fixtures for LangGraph testing
Based on 2024 best practices for testing LLM agents
"""

import pytest
import asyncio
import os
import sys
from pathlib import Path
from unittest.mock import MagicMock, AsyncMock
from typing import Dict, Any, Generator
import json
import tempfile

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))


# ============================================================================
# Pytest Configuration
# ============================================================================

def pytest_configure(config):
    """Configure pytest with custom markers"""
    config.addinivalue_line(
        "markers", "integration: mark test as integration test (deselect with '-m \"not integration\"')"
    )
    config.addinivalue_line(
        "markers", "unit: mark test as unit test"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )
    config.addinivalue_line(
        "markers", "expensive: mark test that uses API calls (costs money)"
    )


# ============================================================================
# Session-Level Fixtures
# ============================================================================

@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for async tests"""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
def test_data_dir() -> Path:
    """Directory containing test data files"""
    return Path(__file__).parent / "test_data"


@pytest.fixture(scope="session")
def mock_env_vars():
    """Set up mock environment variables for testing"""
    env_vars = {
        "OPENAI_API_KEY": "test-openai-key",  # pragma: allowlist secret
        "ANTHROPIC_API_KEY": "test-anthropic-key",  # pragma: allowlist secret
        "ELEVENLABS_API_KEY": "test-elevenlabs-key",  # pragma: allowlist secret
        "PERPLEXITY_API_KEY": "test-perplexity-key",  # pragma: allowlist secret
        "LANGFUSE_PUBLIC_KEY": "test-public-key",  # pragma: allowlist secret
        "LANGFUSE_SECRET_KEY": "test-secret-key",  # pragma: allowlist secret
        "PRODUCTION_VOICE_ID": "test-voice-id",
        "MAX_EPISODE_COST": "6.00",
        "QUALITY_THRESHOLD": "0.85"
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


# ============================================================================
# Module-Level Fixtures
# ============================================================================

@pytest.fixture
def temp_dir():
    """Create a temporary directory for test files"""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


@pytest.fixture
def mock_redis_client():
    """Mock Redis client for testing"""
    mock = MagicMock()
    mock.get = MagicMock(return_value=None)
    mock.set = MagicMock(return_value=True)
    mock.delete = MagicMock(return_value=1)
    mock.exists = MagicMock(return_value=False)
    return mock


@pytest.fixture
def mock_llm_response():
    """Mock LLM response generator"""
    def _generate_response(prompt: str, model: str = "gpt-4") -> str:
        responses = {
            "research": "Mock research findings about the topic",
            "script": "Mock script content for podcast episode",
            "evaluation": "Mock quality evaluation results"
        }

        for key in responses:
            if key in prompt.lower():
                return responses[key]

        return "Mock generic LLM response"

    return _generate_response


@pytest.fixture
def mock_api_client():
    """Mock API client for external services"""
    client = MagicMock()

    # Mock Perplexity search
    client.search = AsyncMock(return_value={
        "results": [
            {"url": "http://example1.com", "snippet": "Result 1"},
            {"url": "http://example2.com", "snippet": "Result 2"}
        ]
    })

    # Mock ElevenLabs synthesis
    client.synthesize = AsyncMock(return_value={
        "audio_url": "https://audio.example.com/test.mp3",
        "duration": 120.5
    })

    return client


# ============================================================================
# Test Data Fixtures
# ============================================================================

@pytest.fixture
def sample_research_data() -> Dict[str, Any]:
    """Sample research data for testing"""
    return {
        "topic": "AI Safety",
        "sources": [
            {
                "url": "https://example.com/ai-safety",
                "title": "AI Safety Research",
                "relevance": 0.95,
                "summary": "Key findings about AI safety"
            }
        ],
        "key_points": [
            "Point 1: AI alignment is crucial",
            "Point 2: Safety research is accelerating",
            "Point 3: International cooperation needed"
        ],
        "synthesis": "Comprehensive overview of AI safety landscape"
    }


@pytest.fixture
def sample_script() -> str:
    """Sample podcast script for testing"""
    return """
    Welcome to Nobody Knows, where we explore what we know and what we don't.

    Today's topic: AI Safety

    [Introduction]
    We think we understand AI, but do we really?

    [Main Content]
    Recent developments in AI safety research reveal...

    [Conclusion]
    What we know: AI is powerful.
    What we don't: How to ensure it remains beneficial.
    """


@pytest.fixture
def sample_quality_scores() -> Dict[str, float]:
    """Sample quality scores for testing"""
    return {
        "brand_alignment": 0.92,
        "technical_quality": 0.88,
        "engagement_potential": 0.90,
        "overall": 0.90,
        "confidence": 0.95
    }


# ============================================================================
# Cached Response Fixtures (for integration tests)
# ============================================================================

@pytest.fixture
def cached_responses(temp_dir):
    """Cache for API responses to avoid costs in testing"""
    cache_file = temp_dir / "response_cache.json"
    cache = {}

    if cache_file.exists():
        with open(cache_file, 'r') as f:
            cache = json.load(f)

    class ResponseCache:
        def get(self, key: str) -> Any:
            return cache.get(key)

        def set(self, key: str, value: Any) -> None:
            cache[key] = value
            with open(cache_file, 'w') as f:
                json.dump(cache, f)

        def has(self, key: str) -> bool:
            return key in cache

    return ResponseCache()


# ============================================================================
# Utility Fixtures
# ============================================================================

@pytest.fixture
def assert_cost_within_limit():
    """Assertion helper for cost validation"""
    def _assert(actual_cost: float, max_cost: float = 6.00):
        assert actual_cost <= max_cost, f"Cost ${actual_cost:.2f} exceeds limit ${max_cost:.2f}"
        return True
    return _assert


@pytest.fixture
def assert_quality_above_threshold():
    """Assertion helper for quality validation"""
    def _assert(quality_score: float, threshold: float = 0.85):
        assert quality_score >= threshold, f"Quality {quality_score:.2f} below threshold {threshold}"
        return True
    return _assert


# ============================================================================
# Async Utilities
# ============================================================================

@pytest.fixture
def async_timeout():
    """Timeout utility for async tests"""
    async def _timeout(coro, seconds=5):
        try:
            return await asyncio.wait_for(coro, timeout=seconds)
        except asyncio.TimeoutError:
            pytest.fail(f"Async operation timed out after {seconds} seconds")
    return _timeout


# ============================================================================
# Mock Orchestrator Components
# ============================================================================

@pytest.fixture
def mock_workflow():
    """Mock LangGraph workflow for testing"""
    workflow = MagicMock()
    workflow.invoke = AsyncMock()
    workflow.ainvoke = AsyncMock()
    workflow.compile = MagicMock(return_value=workflow)
    return workflow


@pytest.fixture
def mock_message_store():
    """Mock message store for agent communication"""
    store = MagicMock()
    store.add = MagicMock()
    store.get = MagicMock(return_value=[])
    store.clear = MagicMock()
    return store
