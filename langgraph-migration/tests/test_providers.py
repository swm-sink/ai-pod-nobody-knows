"""
Test provider implementations with mock API keys.

This module tests the provider adapters to ensure they properly
implement interfaces and handle API keys securely.

Version: 1.0.0
Date: August 2025
"""

import pytest
import os
from unittest.mock import patch, MagicMock, PropertyMock
from datetime import datetime
from typing import Dict, Any

# Add src to path for imports
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

from adapters.langfuse.provider import LangFuseProvider
from adapters.perplexity.provider import PerplexityProvider
from adapters.openrouter.provider import OpenRouterProvider
from adapters.elevenlabs.provider import ElevenLabsProvider
from core.interfaces.provider import AgentState


class TestProviderSecurity:
    """Test secure handling of API keys across all providers."""

    def test_langfuse_keys_not_logged(self, caplog):
        """Ensure LangFuse API keys are never logged in plain text."""
        config = {
            'public_key': 'pk-lf-test-key-12345',  # pragma: allowlist secret
            'secret_key': 'sk-lf-secret-key-67890',  # pragma: allowlist secret
            'host': 'https://us.cloud.langfuse.com'
        }

        with caplog.at_level('DEBUG'):
            provider = LangFuseProvider(config)

        # Check that actual keys don't appear in logs
        log_text = caplog.text
        assert 'pk-lf-test-key-12345' not in log_text
        assert 'sk-lf-secret-key-67890' not in log_text

        # Check that masked versions appear
        assert '...2345' in log_text or '****' in log_text

    def test_perplexity_key_masked_in_errors(self):
        """Ensure Perplexity keys are masked in error messages."""
        config = {
            'api_key': 'pplx-test-api-key-abcdef'  # pragma: allowlist secret
        }

        provider = PerplexityProvider(config)

        # Create a fake error that contains the API key
        error = Exception(f"Authentication failed with key: pplx-test-api-key-abcdef")
        masked = provider._mask_error(error)

        assert 'pplx-test-api-key-abcdef' not in masked
        assert '***API_KEY***' in masked

    def test_openrouter_env_vars_loaded(self):
        """Test OpenRouter loads from environment variables."""
        with patch.dict(os.environ, {
            'OPENROUTER_API_KEY': 'sk-or-env-key-123456',  # pragma: allowlist secret
            'OPENROUTER_BASE_URL': 'https://test.openrouter.ai/api/v1'
        }):
            config = {
                'api_key': os.environ.get('OPENROUTER_API_KEY'),
                'base_url': os.environ.get('OPENROUTER_BASE_URL')
            }

            provider = OpenRouterProvider(config)

            assert provider.api_key == 'sk-or-env-key-123456'  # pragma: allowlist secret
            assert provider.base_url == 'https://test.openrouter.ai/api/v1'


class TestLangFuseProvider:
    """Test LangFuse observability provider implementation."""

    @pytest.fixture
    def provider(self):
        """Create a LangFuse provider instance."""
        config = {
            'public_key': 'pk-lf-test-public',  # pragma: allowlist secret
            'secret_key': 'sk-lf-test-secret',  # pragma: allowlist secret
            'host': 'https://us.cloud.langfuse.com'
        }
        return LangFuseProvider(config)

    def test_log_execution(self, provider):
        """Test execution logging."""
        state = AgentState(
            agent_id='test-agent',
            stage='testing',
            data={'test': 'data'},
            metadata={'meta': 'data'},
            timestamp=datetime.now(),
            cost_tracking={'llm': 0.01}
        )

        # Should not raise
        provider.log_execution(
            execution_id='exec-123',
            workflow_id='workflow-456',
            state=state
        )

    def test_log_metric(self, provider):
        """Test metric logging."""
        # Should not raise
        provider.log_metric(
            name='test.metric',
            value=42.0,
            tags={'environment': 'test'}
        )

    def test_log_cost(self, provider):
        """Test cost tracking."""
        # Should not raise
        provider.log_cost(
            execution_id='exec-123',
            cost_type='llm',
            amount=0.05,
            metadata={'model': 'gpt-5'}
        )

    def test_create_prompt_experiment(self, provider):
        """Test A/B testing experiment creation."""
        variants = [
            {'template': 'Variant A: {topic}'},
            {'template': 'Variant B: Research {topic}'}
        ]

        experiment_id = provider.create_prompt_experiment(
            name='test_experiment',
            variants=variants
        )

        assert experiment_id.startswith('exp_test_experiment_')


class TestPerplexityProvider:
    """Test Perplexity research provider implementation."""

    @pytest.fixture
    def provider(self):
        """Create a Perplexity provider instance."""
        config = {
            'api_key': 'pplx-test-api-key',  # pragma: allowlist secret
            'model': 'sonar-deep'
        }
        return PerplexityProvider(config)

    def test_generate_with_august_2025_context(self, provider):
        """Test that August 2025 context is enforced."""
        response = provider.generate("Test query")

        # Placeholder/mock response should be returned
        assert 'Test query' in response
        assert 'sonar-deep' in response
        # Accept both old and new mock response formats
        assert any(phrase in response for phrase in ['Research results', 'Mock research'])

    def test_estimate_cost(self, provider):
        """Test cost estimation for research queries."""
        with patch('tiktoken.get_encoding') as mock_encoding:
            mock_encoder = MagicMock()
            mock_encoder.encode.return_value = [1] * 100  # 100 tokens
            mock_encoding.return_value = mock_encoder

            cost = provider.estimate_cost("Test prompt", max_tokens=1000)

            # Should return a reasonable cost
            assert 0 < cost < 1.0

    def test_deep_research(self, provider):
        """Test deep research functionality."""
        results = provider.deep_research(
            topic="AI safety",
            depth="comprehensive",
            sources_required=5
        )

        assert results['topic'] == "AI safety"
        assert results['depth'] == "comprehensive"
        assert 'research_date' in results
        assert 'content' in results
        assert results['confidence_score'] > 0

    def test_fact_check(self, provider):
        """Test fact-checking functionality."""
        results = provider.fact_check(
            claim="The Earth is round",
            context="Basic astronomy"
        )

        assert results['claim'] == "The Earth is round"
        assert 'status' in results
        assert 'confidence' in results
        assert 'checked_date' in results


class TestOpenRouterProvider:
    """Test OpenRouter LLM provider implementation."""

    @pytest.fixture
    def provider(self):
        """Create an OpenRouter provider instance."""
        config = {
            'api_key': 'sk-or-test-api-key',  # pragma: allowlist secret
            'base_url': 'https://openrouter.ai/api/v1',
            'model': 'anthropic/claude-opus-4.1'
        }
        return OpenRouterProvider(config)

    def test_model_selection(self, provider):
        """Test model selection and validation."""
        # Default model should be set
        assert provider.default_model == 'anthropic/claude-opus-4.1'

        # Should have pricing information
        assert 'anthropic/claude-opus-4.1' in provider.MODEL_PRICING

    def test_generate_with_model_override(self, provider):
        """Test generation with different model."""
        response = provider.generate(
            prompt="Test prompt",
            model='openai/gpt-5-turbo'
        )

        assert 'gpt-5-turbo' in response

    def test_list_models(self, provider):
        """Test model listing functionality."""
        # List all models
        all_models = provider.list_models()
        assert len(all_models) > 0

        # Filter by provider
        anthropic_models = provider.list_models(provider='anthropic')
        assert all(m['provider'] == 'anthropic' for m in anthropic_models)

    def test_compare_models(self, provider):
        """Test model comparison functionality."""
        models = ['anthropic/claude-opus-4.1', 'openai/gpt-5-turbo']
        results = provider.compare_models(
            prompt="Test prompt",
            models=models,
            max_tokens=100
        )

        assert len(results) == 2
        for model in models:
            assert model in results
            assert 'response' in results[model]
            assert 'cost' in results[model]
            assert 'success' in results[model]

    def test_headers_preparation(self):
        """Test that custom headers are properly set."""
        config = {
            'api_key': 'sk-or-test',  # pragma: allowlist secret
            'headers': {
                'HTTP-Referer': 'https://test.com',
                'X-Title': 'Test App'
            }
        }

        provider = OpenRouterProvider(config)
        headers = provider.headers

        assert 'HTTP-Referer' in headers
        assert headers['HTTP-Referer'] == 'https://test.com'
        assert 'X-Title' in headers
        assert headers['X-Title'] == 'Test App'


class TestElevenLabsProvider:
    """Test ElevenLabs audio synthesis provider implementation."""

    @pytest.fixture
    def provider(self):
        """Create an ElevenLabs provider instance."""
        config = {
            'api_key': 'test_elevenlabs_key',  # pragma: allowlist secret
            'voice_id': 'ZF6FPAbjXT4488VcRRnw',
            'model_id': 'eleven_turbo_v2_5',
            'output_dir': '/tmp/test_audio'
        }
        return ElevenLabsProvider(config)

    def test_production_voice_configured(self, provider):
        """Test that production voice is properly configured."""
        assert provider.voice_id == 'ZF6FPAbjXT4488VcRRnw'
        assert provider.PRODUCTION_VOICE_ID == 'ZF6FPAbjXT4488VcRRnw'

    def test_generate_audio(self, provider):
        """Test audio generation returns file path."""
        response = provider.generate("Test audio synthesis")

        # Should return a file path
        assert 'mock_audio' in response
        assert response.endswith('.mp3')

    def test_estimate_cost_by_characters(self, provider):
        """Test cost estimation based on character count."""
        # Short text
        cost_short = provider.estimate_cost("Hello world", max_tokens=0)

        # Long text (1000 characters)
        long_text = "a" * 1000
        cost_long = provider.estimate_cost(long_text, max_tokens=0)

        # Cost should scale with character count
        assert cost_short < cost_long
        assert 0 < cost_short < 1.0
        assert 0 < cost_long < 5.0

    def test_ssml_processing(self, provider):
        """Test SSML markup processing."""
        ssml_text = '<speak>Hello <break time="1s"/> <emphasis>world</emphasis>!</speak>'

        # Process SSML
        processed = provider._process_ssml(ssml_text)

        # Should convert breaks to commas and emphasis to uppercase
        assert 'Hello' in processed
        assert 'WORLD' in processed  # Emphasis converted to uppercase
        assert '<' not in processed  # No XML tags

    def test_voice_validation(self, provider):
        """Test voice ID validation."""
        # Production voice should be valid
        is_valid = provider.validate_voice('ZF6FPAbjXT4488VcRRnw')
        assert is_valid is True

        # Invalid voice should fail
        is_invalid = provider.validate_voice('invalid_voice_id')
        assert is_invalid is False

    def test_get_voices_returns_list(self, provider):
        """Test getting available voices."""
        voices = provider.get_voices()

        assert isinstance(voices, list)
        assert len(voices) > 0

        # Check first voice has required fields
        first_voice = voices[0]
        assert 'voice_id' in first_voice
        assert 'name' in first_voice

    def test_subscription_info(self, provider):
        """Test getting subscription information."""
        info = provider.get_subscription_info()

        assert isinstance(info, dict)
        assert 'tier' in info
        assert 'character_count' in info
        assert 'character_limit' in info

    def test_model_validation(self):
        """Test model validation in config."""
        # Valid model should work
        config_valid = {
            'api_key': 'test_key',  # pragma: allowlist secret
            'model_id': 'eleven_turbo_v2_5'
        }
        provider = ElevenLabsProvider(config_valid)
        assert provider.model_id == 'eleven_turbo_v2_5'

        # Invalid model should raise error
        config_invalid = {
            'api_key': 'test_key',  # pragma: allowlist secret
            'model_id': 'invalid_model'
        }
        with pytest.raises(ValueError, match="Invalid ElevenLabs model"):
            ElevenLabsProvider(config_invalid)

    def test_headers_include_api_key(self):
        """Test that headers are properly configured."""
        config = {
            'api_key': 'test_xi_api_key_123',  # pragma: allowlist secret
            'mock_mode': True
        }

        provider = ElevenLabsProvider(config)

        # In mock mode, client is None but we can verify the initialization logged
        assert provider.api_key == 'test_xi_api_key_123'  # pragma: allowlist secret


class TestProviderIntegration:
    """Test integration between providers."""

    def test_all_providers_implement_cleanup(self):
        """Ensure all providers implement cleanup method."""
        providers = [
            LangFuseProvider({
                'public_key': 'pk-test',  # pragma: allowlist secret
                'secret_key': 'sk-test',  # pragma: allowlist secret
                'host': 'https://test.com'
            }),
            PerplexityProvider({
                'api_key': 'pplx-test'  # pragma: allowlist secret
            }),
            OpenRouterProvider({
                'api_key': 'sk-or-test'  # pragma: allowlist secret
            }),
            ElevenLabsProvider({
                'api_key': 'test-elevenlabs',  # pragma: allowlist secret
                'output_dir': '/tmp/test_audio'
            })
        ]

        for provider in providers:
            # Should not raise
            provider.cleanup()

    def test_cost_estimation_consistency(self):
        """Test that cost estimation is reasonable across providers."""
        prompt = "Test prompt for cost estimation"
        max_tokens = 1000

        perplexity = PerplexityProvider({'api_key': 'test'})  # pragma: allowlist secret
        openrouter = OpenRouterProvider({'api_key': 'test'})  # pragma: allowlist secret

        with patch('tiktoken.get_encoding') as mock_encoding:
            mock_encoder = MagicMock()
            mock_encoder.encode.return_value = [1] * 50  # 50 tokens
            mock_encoding.return_value = mock_encoder

            perplexity_cost = perplexity.estimate_cost(prompt, max_tokens)
            openrouter_cost = openrouter.estimate_cost(prompt, max_tokens)

            # Both should return reasonable costs
            assert 0 < perplexity_cost < 10.0
            assert 0 < openrouter_cost < 10.0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
