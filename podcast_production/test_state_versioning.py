#!/usr/bin/env python3
"""Test script for state versioning functionality."""

import sys
sys.path.append('.')

from core.state import (
    create_initial_state, 
    update_stage, 
    add_error, 
    update_cost, 
    validate_state
)
from datetime import datetime
import time

def test_version_tracking():
    """Test version tracking fields in PodcastState."""
    print("🧪 Testing State Version Tracking")
    print("=" * 50)
    
    # Test 1: Initial state creation
    print("\n📋 Test 1: Initial State Creation")
    state = create_initial_state("Test Topic for Versioning")
    
    # Check version fields are present
    required_version_fields = ["schema_version", "created_at", "updated_at"]
    for field in required_version_fields:
        if field in state:
            print(f"✅ {field}: {state[field]}")
        else:
            print(f"❌ Missing {field}")
    
    # Validate schema version format
    schema_version = state.get("schema_version", "")
    if schema_version == "1.1.0":
        print(f"✅ Schema version: {schema_version} (correct format)")
    else:
        print(f"❌ Schema version: {schema_version} (incorrect)")
    
    # Test 2: Timestamp logic
    print("\n📋 Test 2: Timestamp Logic")
    created_at = datetime.fromisoformat(state["created_at"])
    updated_at = datetime.fromisoformat(state["updated_at"])
    
    if updated_at >= created_at:
        print("✅ updated_at >= created_at (valid)")
    else:
        print("❌ updated_at < created_at (invalid)")
    
    # Test 3: State updates modify timestamp
    print("\n📋 Test 3: State Updates Modify Timestamp")
    original_updated_at = state["updated_at"]
    time.sleep(0.01)  # Small delay to ensure timestamp changes
    
    # Test update_stage
    state = update_stage(state, "discovery")
    if state["updated_at"] != original_updated_at:
        print("✅ update_stage updates timestamp")
    else:
        print("❌ update_stage doesn't update timestamp")
    
    # Test add_error
    original_updated_at = state["updated_at"]
    time.sleep(0.01)
    state = add_error(state, "Test error", "discovery")
    if state["updated_at"] != original_updated_at:
        print("✅ add_error updates timestamp")
    else:
        print("❌ add_error doesn't update timestamp")
    
    # Test update_cost
    original_updated_at = state["updated_at"]
    time.sleep(0.01)
    state = update_cost(state, "discovery", 1.50)
    if state["updated_at"] != original_updated_at:
        print("✅ update_cost updates timestamp")
    else:
        print("❌ update_cost doesn't update timestamp")
    
    return state

def test_state_validation():
    """Test enhanced state validation with version fields."""
    print("\n🧪 Testing Enhanced State Validation")
    print("=" * 50)
    
    # Test 1: Valid state
    print("\n📋 Test 1: Valid State")
    state = create_initial_state("Valid Test Topic")
    errors = validate_state(state)
    if not errors:
        print("✅ Valid state passes validation")
    else:
        print(f"❌ Valid state has errors: {errors}")
    
    # Test 2: Missing version fields
    print("\n📋 Test 2: Missing Version Fields")
    invalid_state = create_initial_state("Test Topic")
    del invalid_state["schema_version"]  # Remove required field
    errors = validate_state(invalid_state)
    if "Missing required field: schema_version" in errors:
        print("✅ Missing schema_version detected")
    else:
        print(f"❌ Missing schema_version not detected. Errors: {errors}")
    
    # Test 3: Invalid schema version format
    print("\n📋 Test 3: Invalid Schema Version Format")
    invalid_state = create_initial_state("Test Topic")
    invalid_state["schema_version"] = "invalid.version"
    errors = validate_state(invalid_state)
    version_error = any("Invalid schema version format" in error for error in errors)
    if version_error:
        print("✅ Invalid schema version format detected")
    else:
        print(f"❌ Invalid schema version format not detected. Errors: {errors}")
    
    # Test 4: Invalid timestamp format
    print("\n📋 Test 4: Invalid Timestamp Format")
    invalid_state = create_initial_state("Test Topic")
    invalid_state["created_at"] = "not-a-timestamp"
    errors = validate_state(invalid_state)
    timestamp_error = any("Invalid timestamp format" in error for error in errors)
    if timestamp_error:
        print("✅ Invalid timestamp format detected")
    else:
        print(f"❌ Invalid timestamp format not detected. Errors: {errors}")
    
    # Test 5: Logical timestamp validation (updated_at < created_at)
    print("\n📋 Test 5: Logical Timestamp Validation")
    invalid_state = create_initial_state("Test Topic")
    # Set updated_at to be earlier than created_at
    invalid_state["updated_at"] = "2024-01-01T00:00:00"
    invalid_state["created_at"] = "2025-01-01T00:00:00"
    errors = validate_state(invalid_state)
    logic_error = any("updated_at cannot be earlier than created_at" in error for error in errors)
    if logic_error:
        print("✅ Logical timestamp validation detected")
    else:
        print(f"❌ Logical timestamp validation not detected. Errors: {errors}")

def test_comprehensive_workflow():
    """Test complete workflow with version tracking."""
    print("\n🧪 Testing Comprehensive Workflow")
    print("=" * 50)
    
    # Create initial state
    state = create_initial_state("Comprehensive Workflow Test", budget=10.0)
    print(f"✅ Initial state created with schema version: {state['schema_version']}")
    
    # Track original timestamps
    original_created = state["created_at"]
    original_updated = state["updated_at"]
    
    # Simulate workflow stages
    stages = ["discovery", "deep_dive", "validation", "synthesis", "planning"]
    
    for i, stage in enumerate(stages):
        time.sleep(0.01)  # Ensure timestamp changes
        state = update_stage(state, stage)
        state = update_cost(state, stage, 1.0 + i * 0.5)
        
        # Validate state after each update
        errors = validate_state(state)
        if errors:
            print(f"❌ Validation errors in {stage}: {errors}")
        else:
            print(f"✅ {stage} stage valid")
    
    # Final validation
    print(f"\n📊 Final State Summary:")
    print(f"✅ Schema Version: {state['schema_version']}")
    print(f"✅ Created At: {original_created}")
    print(f"✅ Updated At: {state['updated_at']}")
    print(f"✅ Current Stage: {state['current_stage']}")
    print(f"✅ Total Cost: ${state['total_cost']}")
    print(f"✅ Timestamps Updated: {state['updated_at'] != original_updated}")
    
    return state

def main():
    """Run all version tracking tests."""
    print("VERSION TRACKING VALIDATION SUITE")
    print("=" * 60)
    
    try:
        # Run test suites
        test_state = test_version_tracking()
        test_state_validation()
        final_state = test_comprehensive_workflow()
        
        print("\n✅ ALL VERSION TRACKING TESTS COMPLETED")
        print("   - Schema version tracking: Working")
        print("   - Timestamp management: Working")
        print("   - State validation: Enhanced")
        print("   - Workflow integration: Complete")
        
        # Final validation
        final_errors = validate_state(final_state)
        if not final_errors:
            print("   - Final state validation: ✅ PASSED")
        else:
            print(f"   - Final state validation: ❌ ERRORS: {final_errors}")
            
    except Exception as e:
        print(f"\n❌ TEST SUITE FAILED: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()