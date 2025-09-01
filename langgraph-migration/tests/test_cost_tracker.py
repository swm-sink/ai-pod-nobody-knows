"""
Comprehensive tests for the cost tracking system.

Tests cover all functionality including cost estimation, tracking,
CSV logging, budget enforcement, and analysis capabilities.

Version: 1.0.0
Date: August 2025
"""

import pytest
import tempfile
import csv
import json
import os
from pathlib import Path
from datetime import datetime, timedelta
import statistics

# Adjust imports based on your actual project structure
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

from core.cost_tracker import (
    CostTracker,
    BudgetExceededException,
    create_cost_tracker,
    CostTrackingMixin
)


class TestCostTracker:
    """Test suite for CostTracker class."""

    def setup_method(self):
        """Set up test environment."""
        # Create temporary directory for test logs
        self.temp_dir = tempfile.mkdtemp()
        self.original_cwd = os.getcwd()
        os.chdir(self.temp_dir)

        # Create cost tracker
        self.cost_tracker = CostTracker(budget_limit=10.0, episode_id="test_episode")

    def teardown_method(self):
        """Clean up test environment."""
        os.chdir(self.original_cwd)
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_initialization(self):
        """Test cost tracker initialization."""
        tracker = CostTracker(budget_limit=5.51, episode_id="test_ep")

        assert tracker.budget_limit == 5.51
        assert tracker.episode_id == "test_ep"
        assert tracker.total_cost == 0.0
        assert len(tracker.costs) == 0
        assert len(tracker.cost_by_agent) == 0
        assert len(tracker.cost_by_provider) == 0

    def test_cost_estimation(self):
        """Test cost estimation for different providers."""
        tracker = CostTracker()

        # Test OpenAI pricing
        cost = tracker.estimate_cost('openai', 'gpt-4o', 1000, 500)
        expected = (1000/1000 * 0.0025) + (500/1000 * 0.01)  # $0.0025 + $0.005 = $0.0075
        assert abs(cost - expected) < 0.0001

        # Test ElevenLabs pricing
        cost = tracker.estimate_cost('elevenlabs', 'any_model', characters=1000)
        expected = 1000 * 0.0001  # $0.1
        assert abs(cost - expected) < 0.0001

        # Test unknown provider (should use default)
        cost = tracker.estimate_cost('unknown_provider', 'unknown_model', 1000, 1000)
        expected = 2000 * 0.001  # Default $0.001 per 1K tokens
        assert abs(cost - expected) < 0.0001

    def test_cost_tracking(self):
        """Test basic cost tracking functionality."""
        tracker = CostTracker(budget_limit=1.0)

        # Track a cost
        cost = tracker.track_cost(
            agent_name="test_agent",
            provider="openai",
            model="gpt-4o-mini",
            input_tokens=1000,
            output_tokens=500,
            operation="test_operation"
        )

        assert cost > 0
        assert tracker.total_cost == cost
        assert "test_agent" in tracker.cost_by_agent
        assert tracker.cost_by_agent["test_agent"] == cost
        assert "openai" in tracker.cost_by_provider
        assert tracker.cost_by_provider["openai"] == cost
        assert len(tracker.costs) == 1

    def test_budget_enforcement(self):
        """Test budget limit enforcement."""
        tracker = CostTracker(budget_limit=0.001)  # Very low budget

        # This should exceed budget and raise exception
        with pytest.raises(BudgetExceededException):
            tracker.track_cost(
                agent_name="expensive_agent",
                provider="openai",
                model="gpt-4o",
                input_tokens=10000,  # Large token count
                output_tokens=10000
            )

    def test_csv_logging(self):
        """Test CSV logging functionality."""
        tracker = CostTracker()

        # Track some costs
        tracker.track_cost("agent1", "openai", "gpt-4o-mini", 1000, 500, operation="test1")
        tracker.track_cost("agent2", "anthropic", "claude-3-haiku-20240307", 2000, 1000, operation="test2")

        # Verify CSV file exists and has correct content
        csv_file = Path("logs/costs.csv")
        assert csv_file.exists()

        with open(csv_file, 'r') as f:
            reader = csv.DictReader(f)
            rows = list(reader)

            assert len(rows) == 2
            assert rows[0]['agent'] == 'agent1'
            assert rows[0]['provider'] == 'openai'
            assert rows[1]['agent'] == 'agent2'
            assert rows[1]['provider'] == 'anthropic'

    def test_budget_checking(self):
        """Test budget checking functionality."""
        tracker = CostTracker(budget_limit=1.0)

        # Initially should have full budget remaining
        assert tracker.check_budget_remaining() == 1.0

        # Track some cost
        tracker.track_cost("test_agent", "openai", "gpt-4o-mini", 1000, 500)

        # Should have less remaining
        remaining = tracker.check_budget_remaining()
        assert remaining < 1.0
        assert remaining > 0

    def test_can_afford(self):
        """Test budget affordability checking."""
        tracker = CostTracker(budget_limit=0.01)

        # Should be able to afford small operation
        assert tracker.can_afford('openai', 'gpt-4o-mini', 100, 100)

        # Should not be able to afford large operation
        assert not tracker.can_afford('openai', 'gpt-4o', 100000, 100000)

    def test_cost_breakdown(self):
        """Test cost breakdown generation."""
        tracker = CostTracker(budget_limit=10.0)

        # Track multiple costs
        tracker.track_cost("agent1", "openai", "gpt-4o-mini", 1000, 500)
        tracker.track_cost("agent1", "openai", "gpt-4o-mini", 500, 250)
        tracker.track_cost("agent2", "anthropic", "claude-3-haiku-20240307", 2000, 1000)

        breakdown = tracker.get_cost_breakdown()

        assert 'total_cost' in breakdown
        assert 'budget_remaining' in breakdown
        assert 'cost_by_agent' in breakdown
        assert 'cost_by_provider' in breakdown
        assert 'operation_count' in breakdown
        assert breakdown['operation_count'] == 3
        assert len(breakdown['cost_by_agent']) == 2
        assert len(breakdown['cost_by_provider']) == 2

    def test_model_recommendations(self):
        """Test model recommendation system."""
        tracker = CostTracker(budget_limit=1.0)

        # With low usage, should recommend premium models
        recs = tracker.get_model_recommendations()
        assert recs['openai'] == 'gpt-4o'
        assert recs['anthropic'] == 'claude-3-5-sonnet-20241022'

        # After high usage, should recommend cheaper models
        tracker.track_cost("test_agent", "openai", "gpt-4o", cost=0.85)  # 85% of budget
        recs = tracker.get_model_recommendations()
        assert recs['openai'] == 'gpt-4o-mini'
        assert recs['anthropic'] == 'claude-3-haiku-20240307'

    def test_report_generation(self):
        """Test report generation in different formats."""
        tracker = CostTracker()

        # Track some costs
        tracker.track_cost("agent1", "openai", "gpt-4o-mini", 1000, 500)
        tracker.track_cost("agent2", "elevenlabs", "eleven_turbo_v2_5", characters=1000)

        # Test JSON report
        json_report = tracker.export_report('json')
        report_data = json.loads(json_report)
        assert 'total_cost' in report_data
        assert 'cost_by_agent' in report_data

        # Test text report
        text_report = tracker.export_report('text')
        assert 'COST TRACKING REPORT' in text_report
        assert 'agent1' in text_report
        assert 'agent2' in text_report

    def test_reset_functionality(self):
        """Test tracker reset functionality."""
        tracker = CostTracker()

        # Track some costs
        tracker.track_cost("agent1", "openai", "gpt-4o-mini", 1000, 500)
        assert tracker.total_cost > 0
        assert len(tracker.costs) == 1

        # Reset tracker
        original_episode = tracker.episode_id
        tracker.reset("new_episode")

        assert tracker.episode_id == "new_episode"
        assert tracker.episode_id != original_episode
        assert tracker.total_cost == 0.0
        assert len(tracker.costs) == 0
        assert len(tracker.cost_by_agent) == 0


class TestCostTrackingMixin:
    """Test suite for CostTrackingMixin."""

    def setup_method(self):
        """Set up test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.original_cwd = os.getcwd()
        os.chdir(self.temp_dir)

    def teardown_method(self):
        """Clean up test environment."""
        os.chdir(self.original_cwd)
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_mixin_initialization(self):
        """Test mixin initialization."""

        class TestAgent(CostTrackingMixin):
            def __init__(self):
                super().__init__()
                self.name = "TestAgent"

        agent = TestAgent()
        assert hasattr(agent, 'cost_tracker')
        assert isinstance(agent.cost_tracker, CostTracker)

    def test_mixin_cost_tracking(self):
        """Test mixin cost tracking methods."""

        class TestAgent(CostTrackingMixin):
            def __init__(self):
                super().__init__(cost_tracker=CostTracker(budget_limit=1.0))
                self.name = "TestAgent"

        agent = TestAgent()

        # Test cost tracking
        cost = agent.track_operation_cost(
            provider="openai",
            model="gpt-4o-mini",
            input_tokens=1000,
            output_tokens=500,
            operation="test_operation"
        )

        assert cost > 0
        assert agent.cost_tracker.total_cost == cost

        # Test budget checking
        can_afford = agent.check_budget_before_operation(
            provider="openai",
            model="gpt-4o-mini",
            estimated_tokens=1000
        )
        assert isinstance(can_afford, bool)


class TestFactoryFunction:
    """Test suite for factory functions."""

    def setup_method(self):
        """Set up test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.original_cwd = os.getcwd()
        os.chdir(self.temp_dir)

    def teardown_method(self):
        """Clean up test environment."""
        os.chdir(self.original_cwd)
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_create_cost_tracker(self):
        """Test cost tracker factory function."""
        tracker = create_cost_tracker(budget_limit=2.5, episode_id="factory_test")

        assert isinstance(tracker, CostTracker)
        assert tracker.budget_limit == 2.5
        assert tracker.episode_id == "factory_test"


class TestIntegrationScenarios:
    """Integration tests simulating real usage scenarios."""

    def setup_method(self):
        """Set up test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.original_cwd = os.getcwd()
        os.chdir(self.temp_dir)

    def teardown_method(self):
        """Clean up test environment."""
        os.chdir(self.original_cwd)
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_full_episode_production_simulation(self):
        """Test simulating a full episode production workflow."""
        tracker = CostTracker(budget_limit=5.51, episode_id="integration_test")

        # Simulate research phase
        discovery_cost = tracker.track_cost(
            "research_discovery", "perplexity", "llama-3.1-sonar-large-128k-online",
            input_tokens=2000, output_tokens=1500, operation="research_discovery"
        )

        deep_dive_cost = tracker.track_cost(
            "research_deep_dive", "perplexity", "llama-3.1-sonar-large-128k-online",
            input_tokens=3000, output_tokens=2000, operation="research_deep_dive"
        )

        # Simulate script generation
        script_cost = tracker.track_cost(
            "script_generator", "anthropic", "claude-3-5-sonnet-20241022",
            input_tokens=5000, output_tokens=3000, operation="script_generation"
        )

        # Simulate audio generation
        audio_cost = tracker.track_cost(
            "audio_generator", "elevenlabs", "eleven_turbo_v2_5",
            characters=15000, operation="audio_synthesis"
        )

        # Verify total cost is reasonable
        assert tracker.total_cost < 5.51  # Should be within budget
        assert tracker.total_cost > 0

        # Verify all stages tracked
        assert len(tracker.cost_by_agent) == 4
        assert "research_discovery" in tracker.cost_by_agent
        assert "audio_generator" in tracker.cost_by_agent

        # Generate final report
        breakdown = tracker.get_cost_breakdown()
        assert breakdown['operation_count'] == 4
        assert breakdown['budget_used_percent'] < 100

        # Verify CSV logging
        csv_file = Path("logs/costs.csv")
        assert csv_file.exists()

        with open(csv_file, 'r') as f:
            reader = csv.DictReader(f)
            rows = list(reader)
            assert len(rows) == 4

    def test_budget_exceeded_scenario(self):
        """Test handling of budget exceeded scenarios."""
        tracker = CostTracker(budget_limit=0.10)  # Very small budget

        # First operation should succeed
        cost1 = tracker.track_cost(
            "agent1", "openai", "gpt-4o-mini",
            input_tokens=100, output_tokens=50
        )
        assert cost1 > 0

        # Large operation should fail
        with pytest.raises(BudgetExceededException):
            tracker.track_cost(
                "agent2", "openai", "gpt-4o",
                input_tokens=10000, output_tokens=10000
            )

        # Verify partial state
        assert len(tracker.costs) == 1  # Only first operation recorded
        assert tracker.total_cost == cost1

    def test_cost_optimization_workflow(self):
        """Test cost optimization recommendations workflow."""
        tracker = CostTracker(budget_limit=2.0)

        # Start with expensive operations
        tracker.track_cost("agent1", "openai", "gpt-4o", cost=1.0)

        # Check recommendations after high usage (50%)
        recs = tracker.get_model_recommendations()
        assert recs['openai'] == 'gpt-4o'  # Still premium at 50%

        # Add more cost to trigger cheaper recommendations
        tracker.track_cost("agent2", "anthropic", "claude-3-opus-20240229", cost=0.70)

        # Now at 85% budget usage - should recommend cheaper models
        recs = tracker.get_model_recommendations()
        assert recs['openai'] == 'gpt-4o-mini'
        assert recs['anthropic'] == 'claude-3-haiku-20240307'

        # Verify budget warnings in breakdown
        breakdown = tracker.get_cost_breakdown()
        assert breakdown['budget_used_percent'] >= 80


if __name__ == '__main__':
    # Run tests if script is executed directly
    pytest.main([__file__, '-v'])
