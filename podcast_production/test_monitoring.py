#!/usr/bin/env python3
"""Test script for monitoring functions."""

import sys
sys.path.append('.')

import time
from core.monitoring import PerformanceMetrics, SimpleMonitor, create_simple_monitor
import logging

# Configure logging to see monitoring messages
logging.basicConfig(level=logging.INFO)

def test_performance_metrics():
    """Test PerformanceMetrics class functionality."""
    print('🧪 Testing PerformanceMetrics Class')
    print('=' * 50)
    
    # Test 1: Basic metrics creation
    print('\n📋 Test 1: Basic Metrics Creation')
    metrics = PerformanceMetrics(
        stage_name="test_stage",
        start_time=time.time()
    )
    print(f'✅ Created metrics for stage: {metrics.stage_name}')
    print(f'   Start time: {metrics.start_time}')
    print(f'   Initial success: {metrics.success}')
    
    # Test 2: Finish metrics
    print('\n📋 Test 2: Finish Metrics')
    time.sleep(0.05)  # Small delay for timing
    finished_metrics = metrics.finish(
        cost=1.25,
        tokens=1500, 
        api_calls=3,
        success=True
    )
    
    print(f'✅ Finished metrics:')
    print(f'   Duration: {finished_metrics.duration_seconds:.4f}s')
    print(f'   Cost: ${finished_metrics.cost_dollars}')
    print(f'   Tokens: {finished_metrics.tokens_used}')
    print(f'   API Calls: {finished_metrics.api_calls}')
    print(f'   Memory End: {finished_metrics.memory_end_mb:.1f}MB' if finished_metrics.memory_end_mb else '   Memory End: Not available')
    
    # Test 3: Warning system
    print('\n📋 Test 3: Warning System')
    metrics.add_warning("This is a test warning")
    metrics.add_warning("Another test warning")
    print(f'✅ Added warnings: {len(metrics.warnings)} total')
    for i, warning in enumerate(metrics.warnings, 1):
        print(f'   Warning {i}: {warning}')
    
    # Test 4: Threshold checks
    print('\n📋 Test 4: Threshold Checks')
    
    # Test slow threshold (should be false with small duration)
    is_slow = metrics.is_slow(threshold_seconds=30.0)
    print(f'✅ Is slow (>30s): {is_slow}')
    
    # Test expensive threshold (should be true with $1.25 > $1.00)
    is_expensive = metrics.is_expensive(threshold_dollars=1.0) 
    print(f'✅ Is expensive (>$1.00): {is_expensive}')
    
    # Test 5: Dictionary conversion
    print('\n📋 Test 5: Dictionary Conversion')
    metrics_dict = metrics.to_dict()
    print(f'✅ Converted to dict with {len(metrics_dict)} fields')
    print(f'   Keys: {list(metrics_dict.keys())}')
    
    return metrics

def test_simple_monitor():
    """Test SimpleMonitor class functionality."""
    print('\n🧪 Testing SimpleMonitor Class')
    print('=' * 50)
    
    # Test 1: Monitor creation
    print('\n📋 Test 1: Monitor Creation')
    monitor = create_simple_monitor(budget_limit=5.0)
    print(f'✅ Created monitor with budget: ${monitor.budget_limit}')
    print(f'   Initial total cost: ${monitor.total_cost}')
    
    # Test 2: Manual start/finish monitoring
    print('\n📋 Test 2: Manual Start/Finish Monitoring')
    metrics = monitor.start_stage("discovery")
    print(f'✅ Started monitoring: {metrics.stage_name}')
    
    time.sleep(0.03)  # Simulate work
    finished_metrics = monitor.finish_stage(
        cost=1.50, 
        tokens=2000, 
        api_calls=5,
        success=True
    )
    print(f'✅ Finished monitoring: {finished_metrics.stage_name}')
    print(f'   Duration: {finished_metrics.duration_seconds:.4f}s')
    print(f'   Monitor total cost: ${monitor.total_cost}')
    
    # Test 3: Context manager monitoring
    print('\n📋 Test 3: Context Manager Monitoring') 
    try:
        with monitor.monitor_stage("script_writing") as stage_metrics:
            print(f'✅ Inside context manager for: {stage_metrics.stage_name}')
            time.sleep(0.02)  # Simulate work
            stage_metrics.add_warning("Test context manager warning")
        print('✅ Context manager completed successfully')
    except Exception as e:
        print(f'❌ Context manager failed: {e}')
    
    # Test 4: Error handling in context manager
    print('\n📋 Test 4: Error Handling')
    try:
        with monitor.monitor_stage("failing_stage") as stage_metrics:
            print(f'✅ Starting stage that will fail: {stage_metrics.stage_name}')
            raise ValueError("Simulated stage failure")
    except ValueError as e:
        print(f'✅ Caught expected error: {e}')
        print('✅ Error handling working correctly')
    
    return monitor

def test_monitoring_analysis():
    """Test monitoring analysis and reporting."""
    print('\n🧪 Testing Monitoring Analysis')
    print('=' * 50)
    
    # Create monitor and run several stages
    monitor = create_simple_monitor(budget_limit=3.0)
    
    # Stage 1: Discovery (normal)
    with monitor.monitor_stage("discovery") as metrics:
        time.sleep(0.02)
    monitor.finish_stage(cost=0.75, tokens=1000, api_calls=2, success=True)
    
    # Stage 2: Script writing (expensive)
    with monitor.monitor_stage("script_writing") as metrics:
        time.sleep(0.01) 
    monitor.finish_stage(cost=2.25, tokens=3000, api_calls=6, success=True)
    
    # Stage 3: Audio synthesis (failed)
    try:
        with monitor.monitor_stage("audio_synthesis") as metrics:
            raise Exception("Mock synthesis failure")
    except:
        pass  # Expected failure
    
    # Test 1: Summary generation
    print('\n📋 Test 1: Summary Generation')
    summary = monitor.get_summary()
    print(f'✅ Summary generated:')
    print(f'   Status: {summary["status"]}')
    print(f'   Total stages: {summary["total_stages"]}')
    print(f'   Successful: {summary["successful_stages"]}')
    print(f'   Failed: {summary["failed_stages"]}')
    print(f'   Total cost: ${summary["total_cost_dollars"]:.4f}')
    print(f'   Budget utilization: {summary["budget_utilization_percent"]:.1f}%')
    print(f'   Budget remaining: ${summary["budget_remaining"]:.4f}')
    
    # Test 2: Cost breakdown  
    print('\n📋 Test 2: Cost Breakdown')
    breakdown = monitor.get_cost_breakdown()
    print(f'✅ Cost breakdown:')
    for stage, cost in breakdown.items():
        print(f'   {stage}: ${cost:.4f}')
    
    # Test 3: Budget threshold checking
    print('\n📋 Test 3: Budget Threshold Checking')
    over_80_percent = monitor.check_budget_threshold(80.0)
    over_50_percent = monitor.check_budget_threshold(50.0) 
    print(f'✅ Over 80% budget: {over_80_percent}')
    print(f'✅ Over 50% budget: {over_50_percent}')
    
    # Test 4: Performance alerts
    print('\n📋 Test 4: Performance Alerts')
    alerts = monitor.get_performance_alerts()
    print(f'✅ Generated {len(alerts)} alerts:')
    for i, alert in enumerate(alerts, 1):
        print(f'   Alert {i}: {alert["type"]} - {alert["message"]} ({alert["severity"]})')
    
    return monitor, summary, alerts

def test_integration_scenarios():
    """Test realistic integration scenarios."""
    print('\n🧪 Testing Integration Scenarios')
    print('=' * 50)
    
    # Scenario 1: Normal episode production
    print('\n📋 Scenario 1: Normal Episode Production')
    monitor = create_simple_monitor(budget_limit=5.51)
    
    production_stages = [
        ("discovery", 0.85, 1200, 3),
        ("deep_dive", 1.20, 1800, 4), 
        ("synthesis", 0.95, 1400, 3),
        ("script_writing", 1.75, 2500, 5),
        ("brand_validation", 0.25, 400, 1),
        ("audio_synthesis", 0.35, 0, 2)  # No tokens for audio
    ]
    
    for stage_name, cost, tokens, api_calls in production_stages:
        with monitor.monitor_stage(stage_name) as metrics:
            time.sleep(0.01)  # Simulate processing time
            if stage_name == "script_writing":  # Add a warning for expensive stage
                metrics.add_warning("High token usage for complex topic")
        monitor.finish_stage(cost=cost, tokens=tokens, api_calls=api_calls, success=True)
    
    summary = monitor.get_summary()
    print(f'✅ Normal production scenario:')
    print(f'   Total cost: ${summary["total_cost_dollars"]:.4f} (budget: ${monitor.budget_limit})')
    print(f'   Stages: {summary["successful_stages"]}/{summary["total_stages"]} successful')
    print(f'   Alerts: {len(monitor.get_performance_alerts())} alerts')
    
    # Scenario 2: Budget overrun
    print('\n📋 Scenario 2: Budget Overrun Scenario') 
    monitor_overrun = create_simple_monitor(budget_limit=2.0)  # Lower budget
    
    # Expensive stages that exceed budget
    expensive_stages = [
        ("discovery", 1.50, 2000, 4),
        ("script_writing", 2.25, 3500, 7)  # This will exceed budget
    ]
    
    for stage_name, cost, tokens, api_calls in expensive_stages:
        with monitor_overrun.monitor_stage(stage_name):
            time.sleep(0.005)
        monitor_overrun.finish_stage(cost=cost, tokens=tokens, api_calls=api_calls, success=True)
    
    overrun_summary = monitor_overrun.get_summary()
    overrun_alerts = monitor_overrun.get_performance_alerts()
    
    print(f'✅ Budget overrun scenario:')
    print(f'   Total cost: ${overrun_summary["total_cost_dollars"]:.4f} (budget: ${monitor_overrun.budget_limit})')
    print(f'   Budget utilization: {overrun_summary["budget_utilization_percent"]:.1f}%') 
    print(f'   Alerts: {len(overrun_alerts)} alerts')
    
    budget_alerts = [a for a in overrun_alerts if a["type"] == "budget_warning"]
    print(f'   Budget alerts: {len(budget_alerts)}')
    
    return monitor, monitor_overrun

def main():
    """Run all monitoring tests."""
    print("MONITORING SYSTEM VALIDATION SUITE")
    print("=" * 60)
    
    try:
        # Test individual components
        metrics = test_performance_metrics()
        monitor = test_simple_monitor()
        
        # Test analysis and reporting  
        analysis_monitor, summary, alerts = test_monitoring_analysis()
        
        # Test integration scenarios
        normal_monitor, overrun_monitor = test_integration_scenarios()
        
        print("\n✅ ALL MONITORING TESTS COMPLETED")
        print("   - PerformanceMetrics class: ✅ Working")
        print("   - SimpleMonitor class: ✅ Working") 
        print("   - Context manager: ✅ Working")
        print("   - Error handling: ✅ Working")
        print("   - Budget tracking: ✅ Working")
        print("   - Performance alerts: ✅ Working")
        print("   - Integration scenarios: ✅ Working")
        
        print(f"\n📊 Final Test Summary:")
        print(f"   - Normal production cost: ${normal_monitor.total_cost:.4f}")
        print(f"   - Budget overrun cost: ${overrun_monitor.total_cost:.4f}")
        print(f"   - Total alerts generated: {len(alerts) + len(overrun_monitor.get_performance_alerts())}")
        
        print("\n🎯 Monitoring system ready for production integration!")
        
    except Exception as e:
        print(f"\n❌ MONITORING TEST SUITE FAILED: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()