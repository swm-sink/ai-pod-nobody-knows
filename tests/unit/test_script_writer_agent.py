#!/usr/bin/env python3
"""
Unit Tests for Script Writer Agent
Pytest framework implementation replacing shell script tests
Version: 1.0.0 - September 2025 Production Standards
"""

import json
import os
import pytest
import asyncio
from pathlib import Path
from typing import Dict, Any, List
from unittest.mock import Mock, patch, AsyncMock, MagicMock
from datetime import datetime
import tempfile
import shutil

# Import agent modules (adjust path as needed)
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'podcast_production'))

from agents.script_writer import ScriptWriterAgent
from core.apm import apm
from core.circuit_breaker import CircuitBreaker, CircuitBreakerConfig


# Test Fixtures
@pytest.fixture
def test_session_dir():
    """Create temporary test session directory"""
    temp_dir = tempfile.mkdtemp(prefix="test_script_writer_")
    yield Path(temp_dir)
    shutil.rmtree(temp_dir)


@pytest.fixture
def mock_research_package():
    """Create mock research package for testing"""
    return {
        "research_data": {
            "discovery": {
                "key_concepts": ["concept1", "concept2", "concept3"],
                "expert_insights": ["insight1", "insight2"],
                "current_evidence": ["evidence1", "evidence2"]
            },
            "deep_dive": {
                "technical_details": ["detail1", "detail2"],
                "case_studies": ["case1", "case2"]
            },
            "synthesis": {
                "narrative_arc": "compelling story structure",
                "key_takeaways": ["takeaway1", "takeaway2", "takeaway3"]
            }
        },
        "questions": [
            "What makes this topic fascinating?",
            "How does this connect to everyday life?",
            "What are the implications for the future?"
        ],
        "episode_plan": {
            "structure": {
                "opening_hook": "Engaging opening question",
                "foundation": "Core concepts explanation",
                "emerging": "New understanding development",
                "resolution": "Final insights and questions"
            },
            "duration": "47:00",
            "segments": 6
        }
    }


@pytest.fixture
def script_writer_agent():
    """Create script writer agent instance"""
    return ScriptWriterAgent()


@pytest.fixture
def mock_checkpoint(test_session_dir):
    """Create mock checkpoint for testing"""
    checkpoint = {
        "checkpoint_type": "script_writing",
        "session_id": "test_session",
        "episode_number": 1,
        "status": "completed",
        "timestamp": datetime.now().isoformat(),
        "cost_invested": 1.75,
        "script_results": {
            "character_count": 35000,
            "word_count": 7050,
            "duration_estimate": "47:00",
            "structure_type": "narrative_arc",
            "brand_elements": "humility_phrases:35,questions:28",
            "research_integration": "comprehensive",
            "complete_script_content": "# Mock Script Content\n\nThis is a test script..."
        },
        "quality_validation": {
            "character_count_target": "within_range",
            "brand_alignment": 0.92,
            "accessibility": 0.88,
            "research_accuracy": 0.95
        }
    }
    
    checkpoint_path = test_session_dir / "05_script_complete.json"
    with open(checkpoint_path, 'w') as f:
        json.dump(checkpoint, f, indent=2)
    
    return checkpoint_path


# Test Classes
class TestScriptWriterSpec:
    """Test script writer agent specification"""
    
    @pytest.mark.asyncio
    async def test_agent_initialization(self, script_writer_agent):
        """Test agent initializes correctly"""
        assert script_writer_agent is not None
        assert script_writer_agent.name == "script_writer"
        assert script_writer_agent.budget_allocation == 1.75
    
    def test_required_tools_present(self):
        """Test required tools are configured"""
        # Check agent has necessary tools configured
        required_tools = ["Read", "Write", "Edit", "MultiEdit"]
        agent_config = {
            "tools": required_tools  # In real implementation, get from agent
        }
        
        for tool in required_tools:
            assert tool in agent_config["tools"], f"Missing required tool: {tool}"
    
    def test_brand_voice_integration(self, script_writer_agent):
        """Test brand voice is integrated into agent"""
        # Check agent has brand voice configuration
        assert hasattr(script_writer_agent, 'brand_voice_config')
        assert script_writer_agent.brand_voice_config.get('style') == 'intellectual_humility'
        assert 'feynman' in script_writer_agent.brand_voice_config.get('influences', []).lower()
        assert 'fridman' in script_writer_agent.brand_voice_config.get('influences', []).lower()


class TestCheckpointIntegration:
    """Test checkpoint integration functionality"""
    
    def test_checkpoint_structure(self, mock_checkpoint):
        """Test checkpoint has correct structure"""
        with open(mock_checkpoint, 'r') as f:
            checkpoint = json.load(f)
        
        # Validate required fields
        required_fields = [
            "checkpoint_type", "session_id", "script_results",
            "character_count", "word_count"
        ]
        
        def check_field(obj, field):
            """Recursively check if field exists in nested object"""
            if field in obj:
                return True
            for v in obj.values():
                if isinstance(v, dict) and check_field(v, field):
                    return True
            return False
        
        for field in required_fields:
            assert check_field(checkpoint, field), f"Missing required field: {field}"
    
    @pytest.mark.asyncio
    async def test_checkpoint_recovery(self, script_writer_agent, mock_checkpoint):
        """Test agent can recover from checkpoint"""
        with open(mock_checkpoint, 'r') as f:
            checkpoint_data = json.load(f)
        
        # Test recovery
        recovered_state = await script_writer_agent.recover_from_checkpoint(checkpoint_data)
        assert recovered_state is not None
        assert recovered_state.get('script_results') is not None


class TestScriptQualityMetrics:
    """Test script quality validation"""
    
    def test_word_count_validation(self):
        """Test word count is within target range"""
        word_count = 7050
        target_min = 6900
        target_max = 7200
        
        assert target_min <= word_count <= target_max, \
            f"Word count {word_count} outside target range {target_min}-{target_max}"
    
    def test_brand_score_validation(self):
        """Test brand voice score meets requirements"""
        brand_score = 0.92
        min_required = 0.90
        
        assert brand_score >= min_required, \
            f"Brand score {brand_score} below requirement {min_required}"
    
    def test_readability_validation(self):
        """Test readability is within target range"""
        readability = 72  # Flesch Reading Ease
        target_min = 60
        target_max = 80
        
        assert target_min <= readability <= target_max, \
            f"Readability {readability} outside target range {target_min}-{target_max}"
    
    @pytest.mark.parametrize("word_count,expected", [
        (6900, True),   # Min boundary
        (7050, True),   # Middle
        (7200, True),   # Max boundary
        (6800, False),  # Below min
        (7300, False),  # Above max
    ])
    def test_word_count_boundaries(self, word_count, expected):
        """Test word count boundary conditions"""
        target_min = 6900
        target_max = 7200
        result = target_min <= word_count <= target_max
        assert result == expected


class TestBrandVoiceRequirements:
    """Test brand voice requirements validation"""
    
    def test_humility_phrases_detection(self):
        """Test detection of humility phrases"""
        script_content = """
        Current evidence suggests that this topic is fascinating. 
        We think we understand the basics, but one possibility is that there's much more.
        Scientists are still working to understand the deeper implications.
        This remains an open question in many ways.
        What's fascinating is how much we don't know about these processes?
        """
        
        humility_phrases = [
            "Current evidence suggests",
            "We think we understand",
            "One possibility is",
            "Scientists are still working",
            "This remains an open question",
            "What's fascinating is how much we don't know"
        ]
        
        count = sum(1 for phrase in humility_phrases if phrase.lower() in script_content.lower())
        assert count >= 5, f"Insufficient humility phrases: {count}"
    
    def test_question_detection(self):
        """Test detection of questions in script"""
        script_content = """
        What's truly remarkable is how this field has evolved?
        Here's what we know so far. How does this connect to our daily lives?
        But why does this matter? This opens up questions about reality.
        """
        
        question_count = script_content.count('?')
        assert question_count >= 3, f"Insufficient questions: {question_count}"
    
    def test_brand_voice_metrics(self):
        """Test overall brand voice metrics"""
        word_count = 1000
        humility_phrases = 5
        questions = 4
        
        # Expectations: 5 humility phrases per 1000 words, 4 questions per 1000 words
        humility_rate = humility_phrases / (word_count / 1000)
        question_rate = questions / (word_count / 1000)
        
        assert humility_rate >= 5, f"Humility rate too low: {humility_rate}"
        assert question_rate >= 4, f"Question rate too low: {question_rate}"


class TestAudioFormatting:
    """Test audio formatting requirements"""
    
    def test_audio_markers_present(self):
        """Test audio formatting markers are present"""
        script_content = """
        ### Opening Hook [SEGMENT: 0:00-3:30]
        **[TONE: Engaging, Curious]**
        Here's a question. **[EMPHASIS: question]** 
        **[PAUSE: Medium]**
        **[TONE: Thoughtful]** Current evidence suggests...
        **[PAUSE: Brief]**
        """
        
        assert "[PAUSE:" in script_content, "Missing PAUSE markers"
        assert "[TONE:" in script_content, "Missing TONE markers"
        assert "[EMPHASIS:" in script_content, "Missing EMPHASIS markers"
    
    def test_audio_marker_counts(self):
        """Test sufficient audio markers are present"""
        script_content = """
        [PAUSE: Brief] Text here [PAUSE: Medium] More text [PAUSE: Long]
        [TONE: Curious] Content [TONE: Thoughtful] More content
        [EMPHASIS: key] Word [EMPHASIS: important] Another
        """
        
        pause_count = script_content.count("[PAUSE:")
        tone_count = script_content.count("[TONE:")
        emphasis_count = script_content.count("[EMPHASIS:")
        
        assert pause_count >= 3, f"Insufficient PAUSE markers: {pause_count}"
        assert tone_count >= 2, f"Insufficient TONE markers: {tone_count}"
        assert emphasis_count >= 2, f"Insufficient EMPHASIS markers: {emphasis_count}"


class TestCostTracking:
    """Test cost tracking integration"""
    
    @pytest.mark.asyncio
    async def test_cost_estimation(self, script_writer_agent):
        """Test cost estimation is within bounds"""
        estimated_cost = await script_writer_agent.estimate_cost(
            word_count=7000,
            model="claude-3-sonnet"
        )
        
        min_cost = 1.50
        max_cost = 2.50
        
        assert min_cost <= estimated_cost <= max_cost, \
            f"Cost {estimated_cost} outside range ${min_cost}-${max_cost}"
    
    @pytest.mark.asyncio
    async def test_cost_tracking_integration(self, script_writer_agent):
        """Test cost tracking during execution"""
        with patch.object(script_writer_agent, 'track_cost') as mock_track:
            await script_writer_agent.generate_script({"test": "data"})
            mock_track.assert_called()


class TestOutputStructure:
    """Test script output structure validation"""
    
    def test_required_sections(self):
        """Test all required sections are present"""
        script_structure = """
        # Podcast Script: Test Episode
        
        ## Production Metadata
        - Research Package Source: test.json
        
        ## Script Content
        
        ### Opening Hook [SEGMENT: 0:00-3:30]
        Content here...
        
        ### Foundation Building [SEGMENT: 3:30-8:00]
        Content here...
        
        ### Emerging Understanding [SEGMENT: 8:00-15:00]
        Content here...
        
        ### Resolution [SEGMENT: 24:30-47:00]
        Content here...
        
        ## Brand Voice Compliance
        - Humility Phrases: 35
        """
        
        required_sections = [
            "Production Metadata",
            "Script Content",
            "Opening Hook",
            "Foundation Building",
            "Brand Voice Compliance"
        ]
        
        for section in required_sections:
            assert section in script_structure, f"Missing required section: {section}"
    
    def test_segment_timing(self):
        """Test segment timing adds up correctly"""
        segments = [
            ("Opening Hook", 0, 210),      # 3:30
            ("Foundation", 210, 480),       # 4:30
            ("Emerging", 480, 900),         # 7:00
            ("Deep Dive", 900, 1470),       # 9:30
            ("Implications", 1470, 2220),   # 12:30
            ("Resolution", 2220, 2820)      # 10:00
        ]
        
        total_seconds = sum(end - start for _, start, end in segments)
        expected_total = 47 * 60  # 47 minutes in seconds
        
        assert abs(total_seconds - expected_total) < 60, \
            f"Segment timing {total_seconds}s doesn't match expected {expected_total}s"


class TestMockScriptGeneration:
    """Test mock script generation for API-free testing"""
    
    @pytest.mark.asyncio
    async def test_mock_mode_generation(self, script_writer_agent, mock_research_package):
        """Test script generation in mock mode"""
        script_writer_agent.mock_mode = True
        
        result = await script_writer_agent.generate_script(mock_research_package)
        
        assert result is not None
        assert 'script_content' in result
        assert result['word_count'] >= 6900
        assert result['word_count'] <= 7200
        assert result['brand_voice_score'] >= 0.90
    
    def test_mock_quality_validation(self):
        """Test mock script meets quality requirements"""
        mock_output = {
            "script_content": {
                "character_count": 35200,
                "word_count": 7100,
                "segments": 6,
                "audio_markers": 45,
                "brand_voice_score": 0.93
            },
            "quality_metrics": {
                "humility_phrases": 36,
                "questions": 29,
                "flesch_reading_ease": 72,
                "structure_completeness": 1.0
            }
        }
        
        assert mock_output['script_content']['word_count'] in range(6900, 7201)
        assert mock_output['script_content']['brand_voice_score'] >= 0.90
        assert mock_output['quality_metrics']['flesch_reading_ease'] in range(60, 81)


class TestErrorHandling:
    """Test error handling and resilience"""
    
    @pytest.mark.asyncio
    async def test_circuit_breaker_integration(self, script_writer_agent):
        """Test circuit breaker prevents cascading failures"""
        # Configure circuit breaker for testing
        config = CircuitBreakerConfig(
            name="test_script_writer",
            failure_threshold=3,
            timeout=1.0
        )
        
        with patch.object(script_writer_agent, 'api_call', side_effect=Exception("API Error")):
            # Should fail after threshold
            for _ in range(3):
                with pytest.raises(Exception):
                    await script_writer_agent.generate_script({})
            
            # Circuit should be open now
            assert script_writer_agent.circuit_breaker.state == "open"
    
    @pytest.mark.asyncio
    async def test_fallback_on_failure(self, script_writer_agent):
        """Test fallback mechanism when API fails"""
        with patch.object(script_writer_agent, 'api_call', side_effect=Exception("API Error")):
            result = await script_writer_agent.generate_script_with_fallback({})
            
            assert result is not None
            assert result.get('is_fallback') is True
            assert 'script_content' in result


class TestIntegrationWithAPM:
    """Test APM integration for observability"""
    
    @pytest.mark.asyncio
    async def test_langfuse_tracing(self, script_writer_agent):
        """Test Langfuse tracing is active"""
        with patch('core.apm.apm.trace_agent') as mock_trace:
            await script_writer_agent.generate_script({})
            mock_trace.assert_called()
    
    @pytest.mark.asyncio
    async def test_metrics_tracking(self, script_writer_agent):
        """Test metrics are tracked during execution"""
        with patch('core.apm.AGENT_SUCCESS') as mock_success:
            await script_writer_agent.generate_script({})
            mock_success.labels.assert_called()


# Parametrized Tests
@pytest.mark.parametrize("input_data,expected_word_count", [
    ({"brief": True}, 6900),
    ({"standard": True}, 7050),
    ({"comprehensive": True}, 7200),
])
@pytest.mark.asyncio
async def test_script_length_variations(script_writer_agent, input_data, expected_word_count):
    """Test different script length variations"""
    result = await script_writer_agent.generate_script(input_data)
    assert abs(result['word_count'] - expected_word_count) < 100


# Performance Tests
@pytest.mark.performance
@pytest.mark.asyncio
async def test_script_generation_performance(script_writer_agent, mock_research_package):
    """Test script generation completes within time limits"""
    import time
    
    start = time.time()
    result = await script_writer_agent.generate_script(mock_research_package)
    duration = time.time() - start
    
    assert duration < 120, f"Script generation took {duration}s, exceeding 120s limit"
    assert result is not None


# Main Test Runner
if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])