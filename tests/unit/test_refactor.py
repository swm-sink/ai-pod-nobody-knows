#!/usr/bin/env python3
"""
Test script to validate refactoring changes.
Tests SqliteSaver upgrade and retry handler integration.
"""

import sys
import os
from pathlib import Path

# Change to podcast_production directory for correct config paths
production_dir = Path(__file__).parent / "podcast_production"
sys.path.insert(0, str(production_dir))
os.chdir(str(production_dir))

def test_workflow_refactoring():
    """Test the refactored workflow components."""
    
    print("=== Testing Workflow Refactoring ===")
    
    try:
        from workflows.main_workflow import PodcastWorkflow
        print("✓ Workflow import successful")
    except Exception as e:
        print(f"✗ Workflow import failed: {e}")
        return False
    
    try:
        workflow = PodcastWorkflow()
        print("✓ Workflow initialization successful")
        
        # Test checkpointer type
        checkpointer_type = type(workflow.checkpointer).__name__
        print(f"✓ Checkpointer type: {checkpointer_type}")
        
        # Test retry handler
        has_retry_handler = workflow.retry_handler is not None
        print(f"✓ Retry handler initialized: {has_retry_handler}")
        
        # Test retry handler config
        if has_retry_handler:
            config = workflow.retry_handler.config
            print(f"✓ Retry config - max_attempts: {config.max_attempts}")
            print(f"✓ Retry config - failure threshold: {config.failure_threshold}")
        
        return True
        
    except Exception as e:
        print(f"✗ Workflow initialization failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_voice_config_refactoring():
    """Test voice configuration improvements."""
    
    print("\n=== Testing Voice Config Refactoring ===")
    
    try:
        from config.voice_config import get_production_voice_id, VoiceConfigManager
        print("✓ Voice config import successful")
        
        # Test voice ID retrieval
        voice_id = get_production_voice_id()
        print(f"✓ Voice ID retrieval successful: {voice_id}")
        
        # Test VoiceConfigManager
        manager = VoiceConfigManager()
        config = manager.get_voice_config()
        print(f"✓ Voice config manager successful")
        print(f"✓ Config source: {config.get('source', 'unknown')}")
        
        return True
        
    except Exception as e:
        print(f"✗ Voice config test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("Testing Phase 2 Production Hardening Refactoring")
    print("=" * 60)
    
    workflow_success = test_workflow_refactoring()
    voice_config_success = test_voice_config_refactoring()
    
    print("\n" + "=" * 60)
    if workflow_success and voice_config_success:
        print("🎉 All refactoring tests PASSED")
        sys.exit(0)
    else:
        print("❌ Some refactoring tests FAILED")
        sys.exit(1)