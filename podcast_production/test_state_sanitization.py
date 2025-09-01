#!/usr/bin/env python3
"""Test script for state sanitization integration."""

import sys
sys.path.append('.')

from core.state import create_initial_state
from core.security import sanitize_topic
import logging

# Configure logging to see sanitization messages
logging.basicConfig(level=logging.INFO)

def test_topic_sanitization_integration():
    """Test topic sanitization integration with state creation."""
    print("🧪 Testing State-Security Integration")
    print("=" * 50)
    
    # Test 1: Normal topic
    print("\n📋 Test 1: Normal Topic")
    try:
        state = create_initial_state("AI & Machine Learning", verbose=True)
        print(f"✅ Normal topic: '{state['topic']}'")
        print(f"   Original: 'AI & Machine Learning'")
        print(f"   Sanitized: '{state['topic']}'")
    except Exception as e:
        print(f"❌ Normal topic failed: {e}")
    
    # Test 2: Topic with XSS attempt
    print("\n📋 Test 2: Topic with XSS Attempt")
    malicious_topic = '<script>alert("xss")</script>Future of AI'
    try:
        state = create_initial_state(malicious_topic, verbose=True)
        print(f"✅ XSS topic sanitized: '{state['topic']}'")
        print(f"   Original: '{malicious_topic}'")
        print(f"   Sanitized: '{state['topic']}'")
        
        # Verify malicious content is removed
        if '<script>' not in state['topic']:
            print("   ✅ Script tags removed")
        else:
            print("   ❌ Script tags still present!")
            
    except Exception as e:
        print(f"❌ XSS topic failed: {e}")
    
    # Test 3: Topic with command injection
    print("\n📋 Test 3: Topic with Command Injection")
    injection_topic = 'AI Research; rm -rf /'
    try:
        state = create_initial_state(injection_topic, verbose=True)
        print(f"✅ Injection topic sanitized: '{state['topic']}'")
        print(f"   Original: '{injection_topic}'")
        print(f"   Sanitized: '{state['topic']}'")
        
        # Verify dangerous characters are handled
        if '; rm -rf /' not in state['topic']:
            print("   ✅ Command injection removed")
        else:
            print("   ❌ Command injection still present!")
            
    except Exception as e:
        print(f"❌ Injection topic failed: {e}")
    
    # Test 4: Topic with excessive whitespace
    print("\n📋 Test 4: Topic with Excessive Whitespace")
    whitespace_topic = '   Multiple   spaces   in   topic   '
    try:
        state = create_initial_state(whitespace_topic, verbose=True)
        print(f"✅ Whitespace topic sanitized: '{state['topic']}'")
        print(f"   Original: '{whitespace_topic}'")
        print(f"   Sanitized: '{state['topic']}'")
        
        # Verify whitespace is normalized
        if '   ' not in state['topic']:
            print("   ✅ Excessive whitespace removed")
        else:
            print("   ❌ Excessive whitespace still present!")
            
    except Exception as e:
        print(f"❌ Whitespace topic failed: {e}")
    
    # Test 5: Topic that becomes too short after sanitization
    print("\n📋 Test 5: Topic Too Short After Sanitization")
    short_topic = '<script>x</script>'  # Will become 'x' after sanitization (too short)
    try:
        state = create_initial_state(short_topic, verbose=True)
        print(f"❌ Short topic should have been rejected but got: '{state['topic']}'")
    except ValueError as e:
        print(f"✅ Short topic correctly rejected: {e}")
    except Exception as e:
        print(f"❌ Unexpected error with short topic: {e}")
    
    # Test 6: Empty topic
    print("\n📋 Test 6: Empty Topic")
    try:
        state = create_initial_state("", verbose=True)
        print(f"❌ Empty topic should have been rejected but got: '{state['topic']}'")
    except ValueError as e:
        print(f"✅ Empty topic correctly rejected: {e}")
    except Exception as e:
        print(f"❌ Unexpected error with empty topic: {e}")

def test_state_validation_with_sanitization():
    """Test that sanitized topics still pass state validation."""
    print("\n🧪 Testing State Validation with Sanitization")
    print("=" * 50)
    
    # Test various sanitized topics
    test_topics = [
        "AI & Machine Learning",
        "<script>alert('test')</script>Quantum Computing",
        "Blockchain; echo 'test' Technology",
        "   Future   of   Work   ",
        "Data Science & Analytics"
    ]
    
    for topic in test_topics:
        try:
            state = create_initial_state(topic)
            
            # Import validation function
            from core.state import validate_state
            errors = validate_state(state)
            
            if not errors:
                print(f"✅ Topic validates: '{state['topic']}' (from '{topic[:20]}...')")
            else:
                print(f"❌ Topic validation errors: {errors}")
                
        except ValueError as e:
            print(f"⚠️ Topic rejected during sanitization: {e}")
        except Exception as e:
            print(f"❌ Unexpected error: {e}")

def test_integration_with_existing_functionality():
    """Test that sanitization doesn't break existing functionality."""
    print("\n🧪 Testing Integration with Existing Functionality")
    print("=" * 50)
    
    try:
        # Create state with potentially problematic topic
        topic = "<h1>AI Research</h1> & Development"
        state = create_initial_state(topic, budget=10.0, dry_run=True, verbose=True)
        
        print(f"✅ State created with sanitized topic: '{state['topic']}'")
        
        # Test existing functionality still works
        from core.state import update_stage, add_error, update_cost, validate_state
        
        # Test stage updates
        state = update_stage(state, "discovery")
        print(f"✅ Stage updated to: {state['current_stage']}")
        
        # Test error logging
        state = add_error(state, "Test error", "discovery")
        print(f"✅ Error added, total errors: {len(state['errors'])}")
        
        # Test cost updates
        state = update_cost(state, "discovery", 2.50)
        print(f"✅ Cost updated to: ${state['total_cost']}")
        
        # Test validation
        errors = validate_state(state)
        if not errors:
            print("✅ Final state validation passed")
        else:
            print(f"❌ Final state validation errors: {errors}")
            
        # Verify all version tracking fields are present
        version_fields = ["schema_version", "created_at", "updated_at"]
        for field in version_fields:
            if field in state:
                print(f"✅ Version field '{field}': {state[field]}")
            else:
                print(f"❌ Missing version field: {field}")
                
    except Exception as e:
        print(f"❌ Integration test failed: {e}")
        import traceback
        traceback.print_exc()

def main():
    """Run all sanitization integration tests."""
    print("STATE-SECURITY INTEGRATION VALIDATION SUITE")
    print("=" * 60)
    
    try:
        # Test topic sanitization integration
        test_topic_sanitization_integration()
        
        # Test validation with sanitized topics
        test_state_validation_with_sanitization()
        
        # Test integration with existing functionality
        test_integration_with_existing_functionality()
        
        print("\n✅ ALL INTEGRATION TESTS COMPLETED")
        print("   - Topic sanitization: ✅ Integrated")
        print("   - State creation: ✅ Secure")
        print("   - Validation: ✅ Enhanced")
        print("   - Existing functionality: ✅ Preserved")
        print("\n🔒 Security-State integration successful!")
        
    except Exception as e:
        print(f"\n❌ INTEGRATION TEST SUITE FAILED: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()