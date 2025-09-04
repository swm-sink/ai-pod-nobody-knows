"""
Tests for Provider Failover Manager

Version: 1.0.0
Date: September 2025
"""

import pytest
import asyncio
from unittest.mock import Mock, patch, AsyncMock
import httpx
from datetime import datetime, timedelta

from core.provider_failover import (
    ProviderFailoverManager,
    ProviderConfig,
    ProviderStatus,
    LoadBalancingStrategy,
    ProviderMetrics
)


@pytest.fixture
def mock_providers():
    """Create mock provider configurations"""
    return [
        ProviderConfig(
            name="primary",
            base_url="https://api.primary.com",
            api_key="test_key_1",
            priority=1,
            weight=2.0,
            models=["model-a", "model-b"]
        ),
        ProviderConfig(
            name="secondary",
            base_url="https://api.secondary.com", 
            api_key="test_key_2",
            priority=2,
            weight=1.0,
            models=["model-a", "model-c"]
        ),
        ProviderConfig(
            name="tertiary",
            base_url="https://api.tertiary.com",
            api_key="test_key_3",
            priority=3,
            weight=0.5,
            models=["model-b", "model-c"]
        )
    ]


@pytest.fixture
def failover_manager(mock_providers):
    """Create failover manager instance"""
    return ProviderFailoverManager(
        providers=mock_providers,
        strategy=LoadBalancingStrategy.ADAPTIVE,
        health_check_interval=60,
        enable_health_checks=False  # Disable for tests
    )


class TestProviderMetrics:
    """Test provider metrics calculations"""
    
    def test_health_score_calculation(self):
        """Test health score calculation"""
        metrics = ProviderMetrics(
            latency_ms=1000,
            success_rate=0.95,
            error_count=5,
            request_count=100
        )
        
        score = metrics.calculate_health_score()
        assert 0 <= score <= 1
        assert score > 0.7  # Should be reasonably healthy
    
    def test_health_score_with_high_latency(self):
        """Test health score with high latency"""
        metrics = ProviderMetrics(
            latency_ms=4500,  # Very high
            success_rate=1.0,
            error_count=0,
            request_count=100
        )
        
        score = metrics.calculate_health_score()
        assert score < 0.5  # Should be penalized for latency
    
    def test_health_score_with_failures(self):
        """Test health score with low success rate"""
        metrics = ProviderMetrics(
            latency_ms=500,
            success_rate=0.5,  # 50% failures
            error_count=50,
            request_count=100
        )
        
        score = metrics.calculate_health_score()
        assert score < 0.5  # Should be penalized for failures


class TestProviderSelection:
    """Test provider selection strategies"""
    
    def test_round_robin_selection(self, failover_manager):
        """Test round-robin provider selection"""
        failover_manager.strategy = LoadBalancingStrategy.ROUND_ROBIN
        
        # All providers healthy
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
        
        # Should cycle through providers
        selections = []
        for _ in range(6):
            provider = failover_manager.select_provider()
            selections.append(provider)
        
        # Should have selected each provider twice
        assert selections.count("primary") == 2
        assert selections.count("secondary") == 2
        assert selections.count("tertiary") == 2
    
    def test_priority_selection(self, failover_manager):
        """Test priority-based selection"""
        failover_manager.strategy = LoadBalancingStrategy.PRIORITY
        
        # All providers healthy
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
        
        # Should always select highest priority (lowest number)
        for _ in range(3):
            provider = failover_manager.select_provider()
            assert provider == "primary"
    
    def test_least_latency_selection(self, failover_manager):
        """Test least latency selection"""
        failover_manager.strategy = LoadBalancingStrategy.LEAST_LATENCY
        
        # Set different latencies
        failover_manager.metrics["primary"].latency_ms = 1000
        failover_manager.metrics["secondary"].latency_ms = 500
        failover_manager.metrics["tertiary"].latency_ms = 2000
        
        # All healthy
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
        
        # Should select provider with lowest latency
        provider = failover_manager.select_provider()
        assert provider == "secondary"
    
    def test_adaptive_selection(self, failover_manager):
        """Test adaptive selection based on health scores"""
        failover_manager.strategy = LoadBalancingStrategy.ADAPTIVE
        
        # Set different health metrics
        failover_manager.metrics["primary"] = ProviderMetrics(
            latency_ms=1000,
            success_rate=0.9,
            last_check=datetime.now()
        )
        failover_manager.metrics["secondary"] = ProviderMetrics(
            latency_ms=500,
            success_rate=0.99,
            last_check=datetime.now()
        )
        failover_manager.metrics["tertiary"] = ProviderMetrics(
            latency_ms=2000,
            success_rate=0.7,
            last_check=datetime.now()
        )
        
        # All healthy
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
        
        # Should select provider with best health score
        provider = failover_manager.select_provider()
        assert provider == "secondary"  # Best combination of latency and success
    
    def test_unhealthy_provider_exclusion(self, failover_manager):
        """Test that unhealthy providers are excluded"""
        # Mark primary as unhealthy
        failover_manager.provider_status["primary"] = ProviderStatus.UNHEALTHY
        failover_manager.provider_status["secondary"] = ProviderStatus.HEALTHY
        failover_manager.provider_status["tertiary"] = ProviderStatus.HEALTHY
        
        # Should not select unhealthy provider
        for _ in range(10):
            provider = failover_manager.select_provider()
            assert provider != "primary"
    
    def test_model_filtering(self, failover_manager):
        """Test provider selection with model requirements"""
        # All healthy
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
        
        # Request specific model
        provider = failover_manager.select_provider(model="model-c")
        
        # Should select provider that supports model-c
        assert provider in ["secondary", "tertiary"]
        
        # Request model only in primary
        provider = failover_manager.select_provider(model="model-b")
        assert provider in ["primary", "tertiary"]


class TestHealthChecks:
    """Test health check functionality"""
    
    @pytest.mark.asyncio
    async def test_successful_health_check(self, failover_manager):
        """Test successful health check"""
        with patch('httpx.AsyncClient') as mock_client:
            mock_response = Mock()
            mock_response.raise_for_status = Mock()
            
            mock_client.return_value.__aenter__.return_value.get = AsyncMock(
                return_value=mock_response
            )
            
            # Run health check
            result = await failover_manager._check_provider_health("primary")
            
            assert result is True
            assert failover_manager.provider_status["primary"] == ProviderStatus.HEALTHY
            assert failover_manager.metrics["primary"].consecutive_failures == 0
    
    @pytest.mark.asyncio
    async def test_failed_health_check(self, failover_manager):
        """Test failed health check"""
        with patch('httpx.AsyncClient') as mock_client:
            mock_client.return_value.__aenter__.return_value.get = AsyncMock(
                side_effect=httpx.HTTPError("Connection failed")
            )
            
            # Run health check
            result = await failover_manager._check_provider_health("primary")
            
            assert result is False
            assert failover_manager.metrics["primary"].consecutive_failures == 1
            assert failover_manager.metrics["primary"].last_error is not None
    
    @pytest.mark.asyncio
    async def test_degraded_status_on_high_latency(self, failover_manager):
        """Test degraded status for high latency"""
        with patch('httpx.AsyncClient') as mock_client:
            mock_response = Mock()
            mock_response.raise_for_status = Mock()
            
            # Simulate slow response
            async def slow_get(*args, **kwargs):
                await asyncio.sleep(0.0025)  # 2.5ms simulated delay
                return mock_response
            
            mock_client.return_value.__aenter__.return_value.get = slow_get
            
            with patch('time.time') as mock_time:
                # Simulate 2 second response time
                mock_time.side_effect = [0, 2.0]
                
                result = await failover_manager._check_provider_health("primary")
                
                assert result is True
                # Should be degraded due to high latency (2000ms)
                assert failover_manager.provider_status["primary"] == ProviderStatus.DEGRADED


class TestFailoverExecution:
    """Test failover execution"""
    
    @pytest.mark.asyncio
    async def test_successful_execution(self, failover_manager):
        """Test successful API execution"""
        # Mark all healthy
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
        
        # Mock circuit breaker
        mock_response = Mock()
        mock_response.json.return_value = {"result": "success"}
        
        for name in failover_manager.providers:
            failover_manager.circuit_breakers[name] = AsyncMock(
                return_value=mock_response
            )
        
        # Execute operation
        result = await failover_manager.execute_with_failover(
            operation="test",
            payload={"data": "test"}
        )
        
        assert result == {"result": "success"}
    
    @pytest.mark.asyncio
    async def test_failover_on_primary_failure(self, failover_manager):
        """Test failover when primary fails"""
        failover_manager.strategy = LoadBalancingStrategy.PRIORITY
        
        # All healthy
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
        
        # Primary fails, secondary succeeds
        failover_manager.circuit_breakers["primary"] = AsyncMock(
            side_effect=httpx.HTTPError("Primary failed")
        )
        
        mock_response = Mock()
        mock_response.json.return_value = {"result": "from_secondary"}
        failover_manager.circuit_breakers["secondary"] = AsyncMock(
            return_value=mock_response
        )
        failover_manager.circuit_breakers["tertiary"] = AsyncMock(
            return_value=mock_response
        )
        
        # Execute - should failover to secondary
        result = await failover_manager.execute_with_failover(
            operation="test",
            payload={"data": "test"}
        )
        
        assert result == {"result": "from_secondary"}
        assert failover_manager.metrics["primary"].error_count > 0
    
    @pytest.mark.asyncio
    async def test_fallback_when_all_fail(self, failover_manager):
        """Test fallback function when all providers fail"""
        # All healthy initially
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
            failover_manager.circuit_breakers[name] = AsyncMock(
                side_effect=httpx.HTTPError("Provider failed")
            )
        
        # Define fallback
        async def fallback(payload):
            return {"fallback": True, "original": payload}
        
        # Execute with fallback
        result = await failover_manager.execute_with_failover(
            operation="test",
            payload={"data": "test"},
            fallback=fallback
        )
        
        assert result["fallback"] is True
        assert result["original"] == {"data": "test"}
    
    @pytest.mark.asyncio
    async def test_exception_when_no_fallback(self, failover_manager):
        """Test exception raised when all fail and no fallback"""
        # All providers fail
        for name in failover_manager.providers:
            failover_manager.provider_status[name] = ProviderStatus.HEALTHY
            failover_manager.circuit_breakers[name] = AsyncMock(
                side_effect=httpx.HTTPError("Provider failed")
            )
        
        # Should raise exception
        with pytest.raises(Exception) as exc_info:
            await failover_manager.execute_with_failover(
                operation="test",
                payload={"data": "test"}
            )
        
        assert "All providers failed" in str(exc_info.value)


class TestProviderStats:
    """Test provider statistics"""
    
    def test_get_provider_stats(self, failover_manager):
        """Test getting provider statistics"""
        # Set some metrics
        failover_manager.metrics["primary"] = ProviderMetrics(
            latency_ms=1000,
            success_rate=0.95,
            error_count=5,
            request_count=100,
            last_check=datetime.now()
        )
        failover_manager.provider_status["primary"] = ProviderStatus.HEALTHY
        
        # Get stats
        stats = failover_manager.get_provider_stats()
        
        assert "primary" in stats
        assert stats["primary"]["status"] == "healthy"
        assert stats["primary"]["success_rate"] == 0.95
        assert stats["primary"]["error_count"] == 5
        assert stats["primary"]["request_count"] == 100
        assert "health_score" in stats["primary"]
        assert 0 <= stats["primary"]["health_score"] <= 1