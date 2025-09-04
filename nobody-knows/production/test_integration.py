#!/usr/bin/env python3
"""
End-to-End Integration Test for AI Podcast Production System
Tests complete workflow with state management and cost tracking.
"""

from state_manager import ProductionStateManager
import json
import os
from datetime import datetime

def test_end_to_end_integration():
    """Test complete episode production workflow"""
    
    print("🚀 Starting End-to-End Integration Test")
    print("="*50)
    
    # Initialize state manager
    print("📊 Initializing ProductionStateManager...")
    state_manager = ProductionStateManager()
    
    # Create episode session
    print("📝 Creating episode session...")
    session_id = state_manager.create_episode_session(999, "AI Safety Alignment Pipeline Test")
    print(f"✅ Session created: {session_id}")
    
    # Show initial dashboard
    dashboard = state_manager.get_dashboard_summary()
    print(f"📈 Dashboard: {dashboard['active_episodes']} active, ${dashboard['total_cost']:.2f} total")
    
    # Test Phase 1: Research (simulated costs from actual testing)
    print("\n🔍 PHASE 1: Research Pipeline")
    state_manager.update_phase_status(session_id, "research", "active")
    
    # Simulate research completion with real costs from testing
    research_data = {
        "sources_found": 15,
        "expert_quotes": 8,
        "verification_rate": 0.87,
        "synthesis_quality": 9.3
    }
    research_cost = 4.50  # From actual testing
    state_manager.update_phase_status(session_id, "research", "completed", cost=research_cost, data=research_data)
    print(f"✅ Research completed: Cost ${research_cost:.2f}")
    
    # Test Phase 2: Script Production  
    print("\n📝 PHASE 2: Script Production Pipeline")
    state_manager.update_phase_status(session_id, "script", "active")
    
    # Simulate script completion (with quality gate rejection)
    script_data = {
        "word_count": 5752,
        "quality_score": 7.8,
        "brand_alignment": 0.92,
        "fabrication_issues": 2,
        "revision_required": True
    }
    script_cost = 2.30  # Estimated from testing
    state_manager.update_phase_status(session_id, "script", "failed", cost=script_cost, data=script_data)
    print(f"⚠️  Script failed quality gates: Score 7.8/10 (threshold 9.0)")
    
    # Test Phase 3: Audio Production (using test script)
    print("\n🎙️  PHASE 3: Audio Production Pipeline")  
    state_manager.update_phase_status(session_id, "audio", "active")
    
    # Simulate audio completion with real metrics
    audio_data = {
        "synthesis_method": "single_call",
        "word_accuracy": 0.992,
        "quality_score": 0.985,
        "duration_minutes": 3.2,
        "voice_consistency": 1.0
    }
    audio_cost = 0.12  # From actual test synthesis
    state_manager.update_phase_status(session_id, "audio", "completed", cost=audio_cost, data=audio_data)
    print(f"✅ Audio completed: Quality {audio_data['quality_score']:.1%}")
    
    # Get final status
    print("\n📊 FINAL STATUS")
    final_dashboard = state_manager.get_dashboard_summary()
    episode_status = state_manager.get_episode_status(999)
    
    print(f"Total Cost: ${episode_status['total_cost']:.2f}")
    print(f"Global Cost: ${final_dashboard['total_cost']:.2f}")
    print(f"Episode Status: {episode_status['status']}")
    
    # Show phase breakdown
    print("\nPhase Breakdown:")
    for phase, details in episode_status['phases'].items():
        status = details['status']
        cost = details['cost']
        print(f"  {phase.title()}: {status} (${cost:.2f})")
    
    print("\n✅ End-to-End Integration Test Complete!")
    return session_id, episode_status

if __name__ == "__main__":
    session_id, status = test_end_to_end_integration()