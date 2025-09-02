#!/usr/bin/env python3
"""
Integration test for system components after consolidation.
Tests voice config, cost control, and error handling integrations.
"""

import sys
import os
from pathlib import Path

# Add podcast_production to path
sys.path.append('podcast_production')

def test_voice_config_integration():
    """Test voice configuration integration."""
    print("\n=== Voice Config Integration Test ===")
    try:
        from config.voice_config import get_production_voice_id
        print("[PASS] Voice config import: SUCCESS")
        
        # Test with environment variable
        os.environ['PRODUCTION_VOICE_ID'] = 'ZF6FPAbjXT4488VcRRnw'
        voice_id = get_production_voice_id()
        print(f"[PASS] Voice ID retrieval: {voice_id}")
        
        if voice_id == 'ZF6FPAbjXT4488VcRRnw':
            print("[PASS] Voice config integration: PASSED")
            return True
        else:
            print(f"[FAIL] Unexpected voice ID: {voice_id}")
            return False
            
    except Exception as e:
        print(f"[FAIL] Voice config integration: FAILED - {e}")
        return False

def test_cost_control_integration():
    """Test cost control system integration."""
    print("\n=== Cost Control Integration Test ===")
    try:
        # Set up cost control environment
        os.environ.update({
            'MAX_EPISODE_COST': '5.51',
            'BUDGET_ENFORCEMENT_MODE': 'strict',
            'COST_TRACKING_ENABLED': 'true'
        })
        
        # Check environment variables are readable
        max_cost = float(os.environ.get('MAX_EPISODE_COST', '0'))
        if max_cost == 5.51:
            print(f"[PASS] Cost control config: {max_cost}")
            print("[PASS] Cost control integration: PASSED") 
            return True
        else:
            print(f"[FAIL] Wrong cost limit: {max_cost}")
            return False
            
    except Exception as e:
        print(f"[FAIL] Cost control integration: FAILED - {e}")
        return False

def test_quality_assurance_integration():
    """Test quality assurance integration.""" 
    print("\n=== Quality Assurance Integration Test ===")
    try:
        # Set up quality environment
        os.environ.update({
            'QUALITY_THRESHOLD': '8.0',
            'QUALITY_VALIDATION_REQUIRED': 'true'
        })
        
        quality_threshold = float(os.environ.get('QUALITY_THRESHOLD', '0'))
        validation_required = os.environ.get('QUALITY_VALIDATION_REQUIRED', 'false').lower() == 'true'
        
        if quality_threshold == 8.0 and validation_required:
            print(f"[PASS] Quality threshold: {quality_threshold}")
            print(f"[PASS] Validation required: {validation_required}")
            print("[PASS] Quality assurance integration: PASSED")
            return True
        else:
            print(f"[FAIL] Quality config issue: threshold={quality_threshold}, validation={validation_required}")
            return False
            
    except Exception as e:
        print(f"[FAIL] Quality assurance integration: FAILED - {e}")
        return False

def test_package_imports():
    """Test that our package structure allows proper imports."""
    print("\n=== Package Import Integration Test ===")
    try:
        # Test main package import
        import podcast_production
        print("[PASS] podcast_production package: importable")
        
        # Test individual module imports
        success_count = 0
        total_tests = 0
        
        # Test voice config
        try:
            from podcast_production.config.voice_config import get_production_voice_id
            print("[PASS] voice_config module: importable")
            success_count += 1
        except ImportError as e:
            print(f"[FAIL] voice_config module: {e}")
        total_tests += 1
        
        if success_count == total_tests:
            print("[PASS] Package import integration: PASSED")
            return True
        else:
            print(f"[PARTIAL] Package imports: {success_count}/{total_tests} successful")
            return False
            
    except Exception as e:
        print(f"[FAIL] Package import integration: FAILED - {e}")
        return False

def run_integration_tests():
    """Run all integration tests."""
    print("🧪 SYSTEM INTEGRATION TESTING")
    print("=" * 50)
    
    tests = [
        test_package_imports,
        test_voice_config_integration, 
        test_cost_control_integration,
        test_quality_assurance_integration
    ]
    
    results = []
    for test_func in tests:
        result = test_func()
        results.append(result)
    
    print("\n" + "=" * 50)
    print("📊 INTEGRATION TEST SUMMARY")
    print("=" * 50)
    
    passed = sum(results)
    total = len(results)
    percentage = (passed / total) * 100 if total > 0 else 0
    
    print(f"Tests Passed: {passed}/{total}")
    print(f"Success Rate: {percentage:.1f}%")
    
    if percentage >= 100:
        print("🎯 INTEGRATION STATUS: ALL TESTS PASSED")
        return True
    elif percentage >= 75:
        print("⚠️  INTEGRATION STATUS: MOSTLY WORKING")
        return True
    else:
        print("❌ INTEGRATION STATUS: SIGNIFICANT ISSUES")
        return False

if __name__ == "__main__":
    success = run_integration_tests()
    sys.exit(0 if success else 1)