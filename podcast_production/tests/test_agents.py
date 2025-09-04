#!/usr/bin/env python3
"""
Unit Tests for Individual Agents
Comprehensive testing of agent functionality with mocking
Version: 2.0.0 - September 2025 Standards
"""

import pytest
import asyncio
import json
from unittest.mock import Mock, patch, AsyncMock, MagicMock
from datetime import datetime
from pathlib import Path
import tempfile

import httpx
from podcast_production.agents.research_discovery import ResearchDiscoveryAgent
from podcast_production.agents.script_writer import ScriptWriterAgent
from podcast_production.agents.audio_synthesizer import AudioSynthesizerAgent


class TestResearchDiscoveryAgent:
    """Test Research Discovery Agent"""
    
    @pytest.fixture
    def agent(self):
        """Create agent instance"""
        return ResearchDiscoveryAgent()
    
    @pytest.fixture
    def test_state(self):
        """Create test state"""
        return {
            "episode_id": "test_001",
            "topic": "Artificial Intelligence Ethics",
            "budget": 5.51,
            "research_data": {},
            "error_log": [],
            "cost_breakdown": {}
        }
    
    @pytest.mark.asyncio
    @patch('httpx.AsyncClient.post')
    async def test_execute_success(self, mock_post, agent, test_state):
        """Test successful execution"""
        # Mock API response
        mock_response = Mock()
        mock_response.json.return_value = {
            "choices": [{
                "message": {
                    "content": "AI ethics involves complex considerations..."
                }
            }],
            "citations": [
                {"url": "https://example.com/ai-ethics", "title": "AI Ethics Guide"}
            ]
        }
        mock_response.raise_for_status = Mock()
        mock_post.return_value = mock_response
        
        # Execute agent
        result = await agent.execute(test_state)
        
        # Validate results
        assert "research_data" in result
        assert "discovery" in result["research_data"]
        assert result["cost_breakdown"]["research_discovery"] > 0
        assert result["cost_breakdown"]["research_discovery"] <= agent.budget
    
    @pytest.mark.asyncio
    async def test_query_preparation(self, agent):
        """Test query preparation logic"""
        topic = "Quantum Computing"
        queries = agent._prepare_queries(topic)
        
        # Validate query structure
        assert len(queries) >= 3
        for query in queries:
            assert query.query_type
            assert query.query_text
            assert topic.lower() in query.query_text.lower()
            assert "September 2025" in query.query_text or "2025" in query.query_text
    
    @pytest.mark.asyncio
    @patch('httpx.AsyncClient.post')
    async def test_circuit_breaker_activation(self, mock_post, agent, test_state):
        """Test circuit breaker activation on failures"""
        # Mock API failures
        mock_post.side_effect = httpx.HTTPError("API Error")
        
        # First 3 failures should be retried
        for _ in range(3):
            with pytest.raises(Exception):
                await agent.execute(test_state)
        
        # Circuit should now be open, using fallback
        result = await agent.execute(test_state)
        assert "research_data" in result
        # Fallback should have zero cost
        assert result.get("cost_breakdown", {}).get("research_discovery", 0) == 0
    
    @pytest.mark.asyncio
    async def test_cost_tracking(self, agent, test_state):
        """Test cost tracking functionality"""
        with patch('httpx.AsyncClient.post') as mock_post:
            # Mock successful response
            mock_response = Mock()
            mock_response.json.return_value = {
                "choices": [{"message": {"content": "Test content"}}],
                "citations": []
            }
            mock_response.raise_for_status = Mock()
            mock_post.return_value = mock_response
            
            # Execute
            result = await agent.execute(test_state)
            
            # Verify cost tracking
            assert "cost_breakdown" in result
            assert "research_discovery" in result["cost_breakdown"]
            cost = result["cost_breakdown"]["research_discovery"]
            assert 0 < cost <= agent.budget
    
    @pytest.mark.asyncio
    async def test_source_categorization(self, agent):
        """Test source categorization logic"""
        sources = [
            {"url": "https://university.edu/research"},
            {"url": "https://news.com/article"},
            {"url": "https://agency.gov/report"},
            {"url": "https://company.com/blog"}
        ]
        
        categories = agent._categorize_sources(sources)
        
        assert categories["academic"] == 1
        assert categories["news"] == 1
        assert categories["government"] == 1
        assert categories["industry"] == 1


class TestScriptWriterAgent:
    """Test Script Writer Agent"""
    
    @pytest.fixture
    def agent(self):
        """Create agent instance"""
        return ScriptWriterAgent()
    
    @pytest.fixture
    def test_state(self):
        """Create test state with research data"""
        return {
            "episode_id": "test_002",
            "topic": "Space Exploration",
            "budget": 5.51,
            "research_data": {
                "discovery": {
                    "discovery_insights": {
                        "main_themes": ["Mars colonization", "SpaceX missions"],
                        "recent_developments": ["Starship test flight"],
                        "consensus_areas": ["Need for international cooperation"]
                    }
                }
            },
            "questions": [
                "How will we terraform Mars?",
                "What are the psychological challenges?",
                "When will the first colony be established?"
            ],
            "episode_plan": {
                "sections": [
                    {"title": "Introduction", "duration": 5},
                    {"title": "Main Discussion", "duration": 35},
                    {"title": "Conclusion", "duration": 7}
                ]
            },
            "error_log": [],
            "cost_breakdown": {}
        }
    
    @pytest.mark.asyncio
    @patch('httpx.AsyncClient.post')
    async def test_script_generation(self, mock_post, agent, test_state):
        """Test script generation"""
        # Mock Claude API response
        mock_response = Mock()
        mock_response.json.return_value = {
            "content": [{
                "text": "Welcome to Nobody Knows! Today we're exploring space..."
            }]
        }
        mock_response.raise_for_status = Mock()
        mock_post.return_value = mock_response
        
        # Execute
        result = await agent.execute(test_state)
        
        # Validate script
        assert "script" in result
        assert len(result["script"]) > 0
        assert "cost_breakdown" in result
        assert "script_writer" in result["cost_breakdown"]
    
    @pytest.mark.asyncio
    async def test_brand_voice_validation(self, agent):
        """Test brand voice validation"""
        # Test script with good brand voice
        good_script = """
        You know, there's something fascinating about what we don't know.
        I wonder if we're asking the right questions here.
        Scientists are still trying to understand this phenomenon.
        What we don't know might be more important than what we do.
        """
        
        score = agent._calculate_brand_score(good_script)
        assert score > 0.8, "Good script should have high brand score"
        
        # Test script with poor brand voice
        bad_script = """
        Here are the definitive facts about this topic.
        We know everything there is to know.
        This is the complete truth with no uncertainty.
        There are no questions left to answer.
        """
        
        score = agent._calculate_brand_score(bad_script)
        assert score < 0.5, "Bad script should have low brand score"
    
    @pytest.mark.asyncio
    async def test_character_count_validation(self, agent, test_state):
        """Test character count constraints"""
        with patch('httpx.AsyncClient.post') as mock_post:
            # Mock response with correct length
            long_script = "A" * 35000  # Target length
            mock_response = Mock()
            mock_response.json.return_value = {
                "content": [{"text": long_script}]
            }
            mock_response.raise_for_status = Mock()
            mock_post.return_value = mock_response
            
            result = await agent.execute(test_state)
            
            # Verify length constraints
            script_length = len(result["script"])
            assert 33000 <= script_length <= 37000, "Script should be within target range"


class TestAudioSynthesizerAgent:
    """Test Audio Synthesizer Agent"""
    
    @pytest.fixture
    def agent(self):
        """Create agent instance"""
        return AudioSynthesizerAgent()
    
    @pytest.fixture
    def test_state(self):
        """Create test state with script"""
        return {
            "episode_id": "test_003",
            "topic": "Ocean Mysteries",
            "budget": 5.51,
            "script": "Welcome to Nobody Knows! " * 1000,  # ~5000 chars
            "error_log": [],
            "cost_breakdown": {}
        }
    
    @pytest.mark.asyncio
    @patch('httpx.AsyncClient.post')
    async def test_audio_synthesis(self, mock_post, agent, test_state):
        """Test audio synthesis"""
        # Mock ElevenLabs API response
        mock_response = Mock()
        mock_response.content = b"fake_audio_data"
        mock_response.raise_for_status = Mock()
        mock_post.return_value = mock_response
        
        # Execute
        result = await agent.execute(test_state)
        
        # Validate results
        assert "audio_url" in result or "audio_file" in result
        assert "cost_breakdown" in result
        assert "audio_synthesis" in result["cost_breakdown"]
        
        # Verify cost is reasonable for TTS
        cost = result["cost_breakdown"]["audio_synthesis"]
        assert 0 < cost <= 15.0, "Audio synthesis cost should be reasonable"
    
    @pytest.mark.asyncio
    async def test_chunked_synthesis(self, agent):
        """Test script chunking for synthesis"""
        # Create long script
        long_script = "This is a test sentence. " * 500
        
        chunks = agent._chunk_script(long_script)
        
        # Validate chunking
        assert len(chunks) > 1, "Long script should be chunked"
        for chunk in chunks:
            assert len(chunk) <= agent.max_chunk_size
            assert chunk.strip(), "Chunks should not be empty"
    
    @pytest.mark.asyncio
    async def test_ssml_optimization(self, agent):
        """Test SSML optimization for better speech"""
        raw_script = """
        Welcome to Nobody Knows!
        
        Today we're exploring... the mysteries of the ocean.
        Did you know - and this is fascinating - that we've explored less than 5% of it?
        """
        
        optimized = agent._optimize_for_tts(raw_script)
        
        # Check for SSML tags
        assert "<speak>" in optimized or "<p>" in optimized
        assert "<pause" in optimized or "<break" in optimized
        
        # Verify readability improvements
        assert "..." in raw_script
        if "..." in optimized:
            # Should be replaced with pause tags
            assert "<pause" in optimized or "<break" in optimized


class TestQualityGates:
    """Test quality gate implementations"""
    
    @pytest.mark.asyncio
    async def test_brand_voice_gate(self):
        """Test brand voice quality gate"""
        from podcast_production.quality.brand_validator import validate_brand_voice
        
        # Test passing script
        good_script = """
        I wonder about this fascinating topic.
        What we don't know is perhaps more interesting.
        Scientists are still discovering new things.
        There's so much uncertainty here, and that's exciting!
        """
        
        result = validate_brand_voice(good_script)
        assert result["passed"] == True
        assert result["score"] >= 0.85
        
        # Test failing script
        bad_script = """
        Here are the facts. This is definitive.
        We know everything. No questions remain.
        This is the absolute truth.
        """
        
        result = validate_brand_voice(bad_script)
        assert result["passed"] == False
        assert result["score"] < 0.85
    
    @pytest.mark.asyncio
    async def test_consensus_evaluation(self):
        """Test multi-evaluator consensus"""
        from podcast_production.quality.consensus import calculate_consensus
        
        # Test agreement scenario
        claude_scores = {"content": 9.0, "structure": 8.5, "engagement": 9.2}
        gemini_scores = {"content": 8.8, "structure": 8.7, "engagement": 9.0}
        
        consensus = calculate_consensus(claude_scores, gemini_scores)
        
        assert consensus["passed"] == True
        assert consensus["average"] >= 8.0
        assert consensus["agreement"] > 0.9
        
        # Test disagreement scenario
        claude_scores = {"content": 9.0, "structure": 8.5, "engagement": 9.2}
        gemini_scores = {"content": 6.0, "structure": 5.5, "engagement": 6.2}
        
        consensus = calculate_consensus(claude_scores, gemini_scores)
        
        assert consensus["passed"] == False
        assert consensus["agreement"] < 0.7


# Performance and Load Tests
class TestPerformance:
    """Performance and load testing"""
    
    @pytest.mark.slow
    @pytest.mark.asyncio
    async def test_concurrent_agent_execution(self):
        """Test concurrent execution of multiple agents"""
        agents = [
            ResearchDiscoveryAgent(),
            ResearchDiscoveryAgent(),
            ResearchDiscoveryAgent()
        ]
        
        states = [
            {"episode_id": f"perf_{i}", "topic": f"Topic {i}", "research_data": {}, "error_log": [], "cost_breakdown": {}}
            for i in range(3)
        ]
        
        with patch('httpx.AsyncClient.post') as mock_post:
            mock_response = Mock()
            mock_response.json.return_value = {"choices": [{"message": {"content": "Test"}}], "citations": []}
            mock_response.raise_for_status = Mock()
            mock_post.return_value = mock_response
            
            # Execute concurrently
            start_time = asyncio.get_event_loop().time()
            tasks = [agent.execute(state) for agent, state in zip(agents, states)]
            results = await asyncio.gather(*tasks)
            duration = asyncio.get_event_loop().time() - start_time
            
            # Validate all completed
            assert len(results) == 3
            for result in results:
                assert "research_data" in result
            
            # Should complete faster than sequential (< 3x single execution)
            assert duration < 3.0, "Concurrent execution should be efficient"
    
    @pytest.mark.asyncio
    async def test_memory_efficiency(self):
        """Test memory efficiency with large data"""
        import sys
        
        agent = ResearchDiscoveryAgent()
        
        # Create large state
        large_state = {
            "episode_id": "memory_test",
            "topic": "Large Topic",
            "research_data": {
                f"key_{i}": "x" * 1000 for i in range(100)  # 100KB of data
            },
            "error_log": [],
            "cost_breakdown": {}
        }
        
        # Check memory usage doesn't explode
        initial_size = sys.getsizeof(large_state)
        
        with patch('httpx.AsyncClient.post') as mock_post:
            mock_response = Mock()
            mock_response.json.return_value = {"choices": [{"message": {"content": "Test"}}], "citations": []}
            mock_response.raise_for_status = Mock()
            mock_post.return_value = mock_response
            
            result = await agent.execute(large_state)
            
            final_size = sys.getsizeof(result)
            
            # Memory shouldn't grow more than 2x
            assert final_size < initial_size * 2, "Memory usage should be controlled"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--asyncio-mode=auto"])