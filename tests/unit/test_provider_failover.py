"""
Test suite for Provider Failover Manager functionality.
Tests primary/secondary provider switching and circuit breaker patterns.
September 2025 patterns.
"""

import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime
import httpx

from podcast_production.core.provider_failover import (
    ProviderFailoverManager,
    ProviderConfig,
    LoadBalancingStrategy
)


class TestProviderFailover:
    """Test provider failover functionality"""
    
    @pytest.fixture
    def mock_providers(self):
        """Create mock provider configurations"""
        return [
            ProviderConfig(
                name="perplexity",
                base_url="https://api.perplexity.ai",
                api_key="test-key-1",
                priority=1,
                weight=2.0,
                models=["llama-3.1-sonar-large-128k-online"],
                health_endpoint="/v1/models"
            ),
            ProviderConfig(
                name="openrouter",
                base_url="https://openrouter.ai/api/v1",
                api_key="test-key-2",
                priority=2,
                weight=1.5,
                models=["anthropic/claude-3-opus"],
                health_endpoint="/models"
            )
        ]
    
    @pytest.mark.asyncio
    async def test_provider_initialization(self, mock_providers):
        """Test provider manager initialization"""
        manager = ProviderFailoverManager(
            providers=mock_providers,
            strategy=LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN,
            health_check_interval=60,
            enable_circuit_breaker=True,
            enable_monitoring=True
        )
        
        assert manager is not None
        assert len(manager.providers) == 2
        assert manager.strategy == LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN
        assert manager.enable_circuit_breaker == True
    
    @pytest.mark.asyncio
    async def test_primary_provider_selection(self, mock_providers):
        """Test that primary provider is selected first"""
        manager = ProviderFailoverManager(
            providers=mock_providers,
            strategy=LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN
        )
        
        selected = await manager.select_provider()
        assert selected.name == "perplexity"  # Priority 1 provider
    
    @pytest.mark.asyncio
    async def test_failover_to_secondary(self, mock_providers):
        """Test failover to secondary provider on primary failure"""
        manager = ProviderFailoverManager(
            providers=mock_providers,
            strategy=LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN,
            enable_circuit_breaker=True
        )
        
        # Simulate primary provider failure
        with patch.object(manager, '_check_provider_health', return_value=False):
            # Mark primary as unhealthy
            await manager.mark_provider_unhealthy("perplexity")
            
            # Should select secondary
            selected = await manager.select_provider()
            assert selected.name == "openrouter"
    
    @pytest.mark.asyncio
    async def test_circuit_breaker_opens_on_failures(self, mock_providers):
        """Test circuit breaker opens after threshold failures"""
        manager = ProviderFailoverManager(
            providers=mock_providers,
            strategy=LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN,
            enable_circuit_breaker=True
        )
        
        # Simulate multiple failures
        for _ in range(5):
            await manager.record_failure("perplexity")
        
        # Circuit should be open
        assert await manager.is_circuit_open("perplexity") == True
    
    @pytest.mark.asyncio
    async def test_weighted_round_robin_distribution(self, mock_providers):
        """Test weighted round robin load balancing"""
        manager = ProviderFailoverManager(
            providers=mock_providers,
            strategy=LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN
        )
        
        # Track selections
        selections = {"perplexity": 0, "openrouter": 0}
        
        # Make 100 selections
        for _ in range(100):
            provider = await manager.select_provider()
            selections[provider.name] += 1
        
        # Perplexity (weight 2.0) should be selected ~57% of the time
        # OpenRouter (weight 1.5) should be selected ~43% of the time
        perplexity_ratio = selections["perplexity"] / 100
        assert 0.50 <= perplexity_ratio <= 0.65  # Allow some variance
    
    @pytest.mark.asyncio
    async def test_health_check_recovery(self, mock_providers):
        """Test provider recovery after health check passes"""
        manager = ProviderFailoverManager(
            providers=mock_providers,
            strategy=LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN,
            enable_circuit_breaker=True
        )
        
        # Mark provider as unhealthy
        await manager.mark_provider_unhealthy("perplexity")
        assert await manager.is_provider_healthy("perplexity") == False
        
        # Simulate successful health check
        with patch.object(manager, '_check_provider_health', return_value=True):
            await manager.check_provider_health("perplexity")
            
            # Provider should be healthy again
            assert await manager.is_provider_healthy("perplexity") == True
    
    @pytest.mark.asyncio
    async def test_all_providers_down_fallback(self, mock_providers):
        """Test behavior when all providers are down"""
        manager = ProviderFailoverManager(
            providers=mock_providers,
            strategy=LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN
        )
        
        # Mark all providers as unhealthy
        await manager.mark_provider_unhealthy("perplexity")
        await manager.mark_provider_unhealthy("openrouter")
        
        # Should raise exception or return fallback
        with pytest.raises(Exception) as exc_info:
            await manager.select_provider()
        
        assert "No healthy providers available" in str(exc_info.value)
    
    @pytest.mark.asyncio
    async def test_monitoring_metrics(self, mock_providers):
        """Test monitoring metrics collection"""
        manager = ProviderFailoverManager(
            providers=mock_providers,
            strategy=LoadBalancingStrategy.WEIGHTED_ROUND_ROBIN,
            enable_monitoring=True
        )
        
        # Record some operations
        await manager.record_success("perplexity", response_time=0.5)
        await manager.record_failure("perplexity")
        await manager.record_success("openrouter", response_time=0.3)
        
        # Check metrics
        metrics = await manager.get_metrics()
        assert metrics["perplexity"]["successes"] == 1
        assert metrics["perplexity"]["failures"] == 1
        assert metrics["openrouter"]["successes"] == 1
        assert metrics["openrouter"]["avg_response_time"] == 0.3


if __name__ == "__main__":
    pytest.main([__file__, "-v"])