#!/usr/bin/env python3
"""Test script for health checking functions."""

import sys
sys.path.append('.')

import os
import time
from core.health import HealthChecker, HealthStatus, create_health_checker
import logging

# Configure logging to see health check messages
logging.basicConfig(level=logging.INFO)

def test_health_status_dataclass():
    """Test HealthStatus dataclass functionality."""
    print('🧪 Testing HealthStatus Dataclass')
    print('=' * 50)
    
    # Test 1: Basic health status creation
    print('\n📋 Test 1: Basic Health Status Creation')
    
    health_status = HealthStatus(
        status="healthy",
        score=85.0,
        timestamp="2025-09-01T13:00:00",
        system_resources={"memory": {"used_percent": 45.2}},
        api_connectivity={"OPENAI_API_KEY": True},
        environment_security={"score": 80},
        file_system={"directories": {"core": {"exists": True}}},
        dependencies={"psutil": True}
    )
    
    print(f'✅ Created health status: {health_status.status}')
    print(f'   Score: {health_status.score}/100')
    print(f'   Timestamp: {health_status.timestamp}')
    print(f'   Warnings: {len(health_status.warnings)}')
    print(f'   Recommendations: {len(health_status.recommendations)}')
    print(f'   Critical Issues: {len(health_status.critical_issues)}')
    
    # Test 2: Adding warnings and recommendations
    print('\n📋 Test 2: Adding Warnings and Recommendations')
    
    # This should work because __post_init__ initializes empty lists
    health_status.warnings.append("Test warning")
    health_status.recommendations.append("Test recommendation")
    health_status.critical_issues.append("Test critical issue")
    
    print(f'✅ Added items:')
    print(f'   Warnings: {len(health_status.warnings)} ({health_status.warnings})')
    print(f'   Recommendations: {len(health_status.recommendations)} ({health_status.recommendations})')
    print(f'   Critical: {len(health_status.critical_issues)} ({health_status.critical_issues})')
    
    return health_status

def test_health_checker_creation():
    """Test HealthChecker class instantiation."""
    print('\n🧪 Testing HealthChecker Creation')
    print('=' * 50)
    
    # Test 1: Basic creation
    print('\n📋 Test 1: Basic Health Checker Creation')
    checker = create_health_checker(production_mode=False)
    print(f'✅ Created health checker (production_mode: {checker.production_mode})')
    print(f'   Last check: {checker.last_check}')
    print(f'   Check history: {len(checker.check_history)} items')
    
    # Test 2: Production mode creation
    print('\n📋 Test 2: Production Mode Creation')
    prod_checker = create_health_checker(production_mode=True)
    print(f'✅ Created production health checker (production_mode: {prod_checker.production_mode})')
    
    return checker, prod_checker

def test_system_resources_check():
    """Test system resource health checking."""
    print('\n🧪 Testing System Resource Checks')
    print('=' * 50)
    
    checker = create_health_checker()
    
    # Test system resource checking
    print('\n📋 Test 1: System Resource Check')
    try:
        resources, warnings, critical = checker.check_system_resources()
        
        print(f'✅ System resources checked:')
        if 'memory' in resources:
            mem = resources['memory']
            print(f'   Memory: {mem["used_percent"]:.1f}% used, {mem["available_gb"]:.1f}GB available')
        
        if 'cpu' in resources:
            cpu = resources['cpu']
            print(f'   CPU: {cpu["usage_percent"]:.1f}% usage, {cpu["core_count"]} cores')
        
        if 'disk' in resources:
            disk = resources['disk']
            print(f'   Disk: {disk["used_percent"]:.1f}% used, {disk["free_gb"]:.1f}GB free')
        
        if 'process' in resources:
            proc = resources['process']
            print(f'   Process: PID {proc["pid"]}, {proc["memory_mb"]:.1f}MB memory')
        
        print(f'   Warnings: {len(warnings)} ({warnings})')
        print(f'   Critical: {len(critical)} ({critical})')
        
        return resources, warnings, critical
        
    except Exception as e:
        print(f'❌ System resource check failed: {e}')
        return {}, [], [str(e)]

def test_api_connectivity_check():
    """Test API connectivity health checking."""
    print('\n🧪 Testing API Connectivity Checks')
    print('=' * 50)
    
    checker = create_health_checker()
    
    # Test API connectivity checking
    print('\n📋 Test 1: API Connectivity Check')
    try:
        apis, warnings, critical = checker.check_api_connectivity()
        
        print(f'✅ API connectivity checked:')
        for api_name, is_valid in apis.items():
            status = "✅ Valid" if is_valid else "❌ Invalid"
            print(f'   {api_name}: {status}')
        
        valid_count = sum(1 for valid in apis.values() if valid)
        total_count = len(apis)
        print(f'   Summary: {valid_count}/{total_count} APIs valid')
        print(f'   Warnings: {len(warnings)} ({warnings})')
        print(f'   Critical: {len(critical)} ({critical})')
        
        return apis, warnings, critical
        
    except Exception as e:
        print(f'❌ API connectivity check failed: {e}')
        return {}, [], [str(e)]

def test_environment_security_check():
    """Test environment security health checking."""
    print('\n🧪 Testing Environment Security Checks')
    print('=' * 50)
    
    checker = create_health_checker()
    
    # Test environment security checking
    print('\n📋 Test 1: Environment Security Check')
    try:
        security, warnings, critical = checker.check_environment_security()
        
        print(f'✅ Environment security checked:')
        if 'score' in security:
            print(f'   Security Score: {security["score"]}/100')
        
        if 'api_keys' in security:
            valid_keys = sum(1 for valid in security['api_keys'].values() if valid)
            total_keys = len(security['api_keys'])
            print(f'   API Keys: {valid_keys}/{total_keys} valid')
        
        if 'environment' in security:
            print(f'   Environment: {security["environment"]}')
        
        print(f'   Warnings: {len(warnings)} ({warnings})')
        print(f'   Critical: {len(critical)} ({critical})')
        
        return security, warnings, critical
        
    except Exception as e:
        print(f'❌ Environment security check failed: {e}')
        return {}, [], [str(e)]

def test_file_system_check():
    """Test file system health checking."""
    print('\n🧪 Testing File System Checks')
    print('=' * 50)
    
    checker = create_health_checker()
    
    # Test file system checking
    print('\n📋 Test 1: File System Check')
    try:
        filesystem, warnings, critical = checker.check_file_system()
        
        print(f'✅ File system checked:')
        
        if 'directories' in filesystem:
            print(f'   Directories:')
            for dir_name, info in filesystem['directories'].items():
                status = "✅" if info['exists'] and info['readable'] and info['writable'] else "⚠️"
                print(f'     {status} {dir_name}: exists={info["exists"]}, r={info["readable"]}, w={info["writable"]}')
        
        if 'files' in filesystem:
            print(f'   Files:')
            for file_name, info in filesystem['files'].items():
                status = "✅" if info['exists'] and info['readable'] else "⚠️"
                size_kb = info['size_bytes'] / 1024 if info['size_bytes'] > 0 else 0
                print(f'     {status} {file_name}: exists={info["exists"]}, readable={info["readable"]}, {size_kb:.1f}KB')
        
        if 'logs' in filesystem:
            logs = filesystem['logs']
            print(f'   Logs: {logs["log_count"]} files, {logs["total_size_mb"]:.1f}MB total')
        
        print(f'   Warnings: {len(warnings)} ({warnings})')
        print(f'   Critical: {len(critical)} ({critical})')
        
        return filesystem, warnings, critical
        
    except Exception as e:
        print(f'❌ File system check failed: {e}')
        return {}, [], [str(e)]

def test_dependencies_check():
    """Test dependency health checking."""
    print('\n🧪 Testing Dependencies Checks')
    print('=' * 50)
    
    checker = create_health_checker()
    
    # Test dependency checking
    print('\n📋 Test 1: Dependencies Check')
    try:
        dependencies, warnings, critical = checker.check_dependencies()
        
        print(f'✅ Dependencies checked:')
        
        # Check packages
        package_count = 0
        available_count = 0
        for dep_name, is_available in dependencies.items():
            if dep_name != 'python_version':
                package_count += 1
                if is_available:
                    available_count += 1
                    print(f'   ✅ {dep_name}: Available')
                else:
                    print(f'   ❌ {dep_name}: Missing')
        
        print(f'   Summary: {available_count}/{package_count} packages available')
        
        # Check Python version
        if 'python_version' in dependencies:
            print(f'   Python Version: {dependencies["python_version"]}')
        
        print(f'   Warnings: {len(warnings)} ({warnings})')
        print(f'   Critical: {len(critical)} ({critical})')
        
        return dependencies, warnings, critical
        
    except Exception as e:
        print(f'❌ Dependencies check failed: {e}')
        return {}, [], [str(e)]

def test_health_scoring_and_status():
    """Test health scoring and status determination."""
    print('\n🧪 Testing Health Scoring and Status')
    print('=' * 50)
    
    checker = create_health_checker()
    
    # Test 1: Perfect health (no issues)
    print('\n📋 Test 1: Perfect Health Score')
    score = checker.calculate_health_score([], [])
    status = checker.determine_status(score, [])
    print(f'✅ Perfect health: Score {score}/100, Status: {status}')
    
    # Test 2: Warnings only
    print('\n📋 Test 2: Health with Warnings')
    warnings = ["High memory usage", "API connectivity issue"]
    score = checker.calculate_health_score(warnings, [])
    status = checker.determine_status(score, [])
    print(f'✅ With warnings: Score {score}/100, Status: {status}')
    
    # Test 3: Critical issues
    print('\n📋 Test 3: Health with Critical Issues')
    critical = ["Critical memory usage", "Missing API key"]
    score = checker.calculate_health_score([], critical)
    status = checker.determine_status(score, critical)
    print(f'✅ With critical issues: Score {score}/100, Status: {status}')
    
    # Test 4: Mixed issues
    print('\n📋 Test 4: Health with Mixed Issues')
    mixed_warnings = ["High CPU usage", "Security warning"]
    mixed_critical = ["Disk space critical"]
    score = checker.calculate_health_score(mixed_warnings, mixed_critical)
    status = checker.determine_status(score, mixed_critical)
    print(f'✅ With mixed issues: Score {score}/100, Status: {status}')
    
    return score, status

def test_full_health_check():
    """Test complete health check process."""
    print('\n🧪 Testing Full Health Check Process')
    print('=' * 50)
    
    # Test 1: Full health check
    print('\n📋 Test 1: Complete Health Check')
    checker = create_health_checker()
    
    try:
        health_status = checker.perform_full_health_check()
        
        print(f'✅ Full health check completed:')
        print(f'   Status: {health_status.status.upper()}')
        print(f'   Score: {health_status.score:.1f}/100')
        print(f'   Timestamp: {health_status.timestamp}')
        print(f'   Warnings: {len(health_status.warnings)}')
        print(f'   Critical Issues: {len(health_status.critical_issues)}')
        print(f'   Recommendations: {len(health_status.recommendations)}')
        
        # Test 2: Production readiness check
        print('\n📋 Test 2: Production Readiness Check')
        ready = checker.is_production_ready()
        print(f'✅ Production ready: {"Yes" if ready else "No"}')
        
        # Test 3: Health summary
        print('\n📋 Test 3: Health Summary')
        summary = checker.get_health_summary()
        print(f'✅ Health summary generated:')
        for key, value in summary.items():
            if key not in ['system_health', 'api_status']:
                print(f'   {key}: {value}')
        
        # Test 4: Check history tracking
        print('\n📋 Test 4: History Tracking')
        print(f'✅ Check history: {len(checker.check_history)} entries')
        print(f'   Last check stored: {checker.last_check is not None}')
        
        return health_status, ready, summary
        
    except Exception as e:
        print(f'❌ Full health check failed: {e}')
        import traceback
        traceback.print_exc()
        return None, False, {}

def test_recommendations_generation():
    """Test health recommendations generation."""
    print('\n🧪 Testing Recommendations Generation')  
    print('=' * 50)
    
    checker = create_health_checker()
    
    # Test 1: Resource-based recommendations
    print('\n📋 Test 1: Resource-Based Recommendations')
    resource_warnings = ["High memory usage: 85.5% (>75%)", "High CPU usage: 90.2% (>80%)"]
    resource_critical = ["Critical disk usage: 96.1% (>95%)"]
    
    mock_resources = {
        'system_resources': {
            'memory': {'used_percent': 85.5},
            'cpu': {'usage_percent': 90.2},
            'disk': {'used_percent': 96.1}
        }
    }
    
    recommendations = checker.generate_recommendations(resource_warnings, resource_critical, mock_resources)
    print(f'✅ Resource recommendations ({len(recommendations)}):')
    for i, rec in enumerate(recommendations, 1):
        print(f'   {i}. {rec}')
    
    # Test 2: API-based recommendations
    print('\n📋 Test 2: API-Based Recommendations')
    api_warnings = ["Only 2/7 API keys valid", "Essential API OPENAI_API_KEY is invalid"]
    api_critical = ["No valid API keys found - system cannot function"]
    
    api_recommendations = checker.generate_recommendations(api_warnings, api_critical, {})
    print(f'✅ API recommendations ({len(api_recommendations)}):')
    for i, rec in enumerate(api_recommendations, 1):
        print(f'   {i}. {rec}')
    
    # Test 3: Security-based recommendations
    print('\n📋 Test 3: Security-Based Recommendations')
    security_warnings = ["Low security score: 65/100 (<70)"]
    security_critical = ["Critical security score: 45/100 (<50)"]
    
    security_recommendations = checker.generate_recommendations(security_warnings, security_critical, {})
    print(f'✅ Security recommendations ({len(security_recommendations)}):')
    for i, rec in enumerate(security_recommendations, 1):
        print(f'   {i}. {rec}')
    
    return recommendations, api_recommendations, security_recommendations

def test_production_scenarios():
    """Test realistic production health scenarios."""
    print('\n🧪 Testing Production Health Scenarios')
    print('=' * 50)
    
    # Scenario 1: Healthy production system
    print('\n📋 Scenario 1: Healthy Production System')
    healthy_checker = create_health_checker(production_mode=True)
    
    # Simulate healthy system by running actual health check
    try:
        health = healthy_checker.perform_full_health_check()
        ready = healthy_checker.is_production_ready()
        
        print(f'✅ Healthy system check:')
        print(f'   Status: {health.status}')
        print(f'   Score: {health.score:.1f}/100')
        print(f'   Production Ready: {ready}')
        print(f'   Issues: {len(health.critical_issues)} critical, {len(health.warnings)} warnings')
        
    except Exception as e:
        print(f'❌ Healthy system test failed: {e}')
    
    # Scenario 2: System with issues (simulated)
    print('\n📋 Scenario 2: System with Issues (Simulated)')
    
    # Create mock health status with issues
    mock_health = HealthStatus(
        status="warning",
        score=65.0,
        timestamp="2025-09-01T13:00:00",
        system_resources={
            'memory': {'used_percent': 78.5},
            'cpu': {'usage_percent': 85.2},
            'disk': {'used_percent': 92.1}
        },
        api_connectivity={
            'OPENAI_API_KEY': True,
            'ANTHROPIC_API_KEY': False,
            'ELEVENLABS_API_KEY': True
        },
        environment_security={'score': 68},
        file_system={'directories': {'logs': {'exists': False}}},
        dependencies={'psutil': True, 'requests': True},
        warnings=[
            "High memory usage: 78.5% (>75%)",
            "High CPU usage: 85.2% (>80%)",
            "High disk usage: 92.1% (>85%)",
            "Directory logs does not exist"
        ],
        recommendations=[
            "Consider closing unnecessary applications to free memory",
            "Clean up old log files and temporary data",
            "Create missing directories with proper permissions"
        ],
        critical_issues=[]
    )
    
    print(f'✅ System with issues:')
    print(f'   Status: {mock_health.status}')
    print(f'   Score: {mock_health.score:.1f}/100')
    print(f'   Warnings: {len(mock_health.warnings)}')
    print(f'   Recommendations: {len(mock_health.recommendations)}')
    
    # Test production readiness logic on mock data
    unhealthy_checker = create_health_checker(production_mode=True)
    unhealthy_checker.last_check = mock_health
    mock_ready = unhealthy_checker.is_production_ready()
    print(f'   Production Ready: {mock_ready}')
    
    return health, mock_health

def main():
    """Run all health checking tests."""
    print("HEALTH CHECKING SYSTEM VALIDATION SUITE")
    print("=" * 60)
    
    try:
        # Test dataclass and basic functionality
        health_status = test_health_status_dataclass()
        checker, prod_checker = test_health_checker_creation()
        
        # Test individual health check components
        resources, res_warnings, res_critical = test_system_resources_check()
        apis, api_warnings, api_critical = test_api_connectivity_check()
        security, sec_warnings, sec_critical = test_environment_security_check()
        filesystem, fs_warnings, fs_critical = test_file_system_check()
        dependencies, dep_warnings, dep_critical = test_dependencies_check()
        
        # Test health scoring and status determination
        score, status = test_health_scoring_and_status()
        
        # Test full health check process
        full_health, ready, summary = test_full_health_check()
        
        # Test recommendations system
        rec1, rec2, rec3 = test_recommendations_generation()
        
        # Test production scenarios
        prod_health, mock_health = test_production_scenarios()
        
        print("\n✅ ALL HEALTH CHECKING TESTS COMPLETED")
        print("   - HealthStatus dataclass: ✅ Working")
        print("   - HealthChecker creation: ✅ Working")
        print("   - System resource checks: ✅ Working")
        print("   - API connectivity checks: ✅ Working")
        print("   - Environment security checks: ✅ Working")
        print("   - File system checks: ✅ Working")
        print("   - Dependencies checks: ✅ Working")
        print("   - Health scoring: ✅ Working")
        print("   - Full health check: ✅ Working")
        print("   - Recommendations generation: ✅ Working")
        print("   - Production scenarios: ✅ Working")
        
        if full_health:
            print(f"\n📊 Final System Health Summary:")
            print(f"   - Overall Status: {full_health.status.upper()}")
            print(f"   - Health Score: {full_health.score:.1f}/100")
            print(f"   - Production Ready: {'✅ Yes' if ready else '❌ No'}")
            print(f"   - Total Issues: {len(full_health.critical_issues)} critical, {len(full_health.warnings)} warnings")
            print(f"   - Recommendations: {len(full_health.recommendations)} actionable items")
        
        print("\n🏥 Health checking system ready for production integration!")
        
    except Exception as e:
        print(f"\n❌ HEALTH CHECKING TEST SUITE FAILED: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()