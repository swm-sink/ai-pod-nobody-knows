"""
Test suite for Brand Consistency Engine functionality.
Tests semantic similarity validation and brand alignment scoring.
September 2025 patterns.
"""

import pytest
import numpy as np
from unittest.mock import Mock, patch
from typing import List, Dict

from podcast_production.core.brand_consistency import BrandConsistencyEngine


class TestBrandConsistency:
    """Test brand consistency validation"""
    
    @pytest.fixture
    def brand_engine(self):
        """Create brand consistency engine instance"""
        return BrandConsistencyEngine(
            model_name="all-MiniLM-L6-v2",
            exemplar_path="tests/fixtures/brand_exemplars.json",
            enable_adaptive_learning=True
        )
    
    @pytest.fixture
    def sample_script(self):
        """Sample script for testing"""
        return """
        Welcome to Nobody Knows, where we explore the mysteries that keep us curious.
        Today, we're diving into something fascinating - and I'll be honest, 
        we don't have all the answers. That's what makes it exciting!
        
        Scientists are still puzzled by this phenomenon. We used to think we knew,
        but recent discoveries have shown us how much we still have to learn.
        It's humbling, really, to realize the limits of our understanding.
        
        What's your take on this? We'd love to hear your thoughts, because
        honestly, nobody knows for sure. And that's perfectly okay.
        """
    
    @pytest.fixture
    def brand_guidelines(self):
        """Brand voice guidelines"""
        return {
            "intellectual_humility": [
                "acknowledge uncertainty",
                "embrace not knowing",
                "celebrate questions over answers"
            ],
            "curiosity": [
                "explore mysteries",
                "ask open questions",
                "wonder about possibilities"
            ],
            "accessibility": [
                "conversational tone",
                "relatable examples",
                "avoid jargon"
            ]
        }
    
    def test_engine_initialization(self, brand_engine):
        """Test engine initialization"""
        assert brand_engine.model_name == "all-MiniLM-L6-v2"
        assert brand_engine.enable_adaptive_learning == True
        assert brand_engine._embeddings_cache is not None
    
    def test_brand_score_calculation(self, brand_engine, sample_script, brand_guidelines):
        """Test brand alignment score calculation"""
        with patch.object(brand_engine, '_load_guidelines', return_value=brand_guidelines):
            score = brand_engine.calculate_brand_score(sample_script)
            
            assert 0 <= score <= 1.0
            assert score > 0.7  # Should score well for aligned script
    
    def test_intellectual_humility_detection(self, brand_engine, sample_script):
        """Test detection of intellectual humility markers"""
        markers = brand_engine.detect_humility_markers(sample_script)
        
        expected_markers = [
            "don't have all the answers",
            "still puzzled",
            "how much we still have to learn",
            "nobody knows for sure"
        ]
        
        for marker in expected_markers:
            assert any(marker.lower() in m.lower() for m in markers)
    
    def test_curiosity_indicators(self, brand_engine, sample_script):
        """Test detection of curiosity indicators"""
        indicators = brand_engine.detect_curiosity_indicators(sample_script)
        
        assert "mysteries" in sample_script.lower()
        assert "fascinating" in sample_script.lower()
        assert "What's your take" in sample_script
        
        assert len(indicators) >= 3
    
    def test_semantic_similarity(self, brand_engine):
        """Test semantic similarity calculation"""
        text1 = "We don't know everything, and that's okay"
        text2 = "It's fine to admit we have limited knowledge"
        text3 = "We have all the answers you need"
        
        # Similar texts should score high
        similarity_1_2 = brand_engine.calculate_semantic_similarity(text1, text2)
        assert similarity_1_2 > 0.7
        
        # Different texts should score lower
        similarity_1_3 = brand_engine.calculate_semantic_similarity(text1, text3)
        assert similarity_1_3 < 0.5
    
    def test_embedding_generation(self, brand_engine):
        """Test text embedding generation"""
        text = "This is a test sentence for embedding"
        
        with patch.object(brand_engine, '_generate_embedding') as mock_embed:
            mock_embed.return_value = np.random.rand(384)  # MiniLM output size
            
            embedding = brand_engine._generate_embedding(text)
            
            assert embedding.shape == (384,)
            assert mock_embed.called_once_with(text)
    
    def test_adaptive_learning(self, brand_engine):
        """Test adaptive learning from feedback"""
        initial_threshold = brand_engine.threshold
        
        # Provide positive feedback
        for _ in range(5):
            brand_engine.record_feedback(
                script="Good script",
                score=0.9,
                human_validation=True
            )
        
        # Threshold should adapt based on feedback
        brand_engine.update_threshold()
        assert brand_engine.threshold != initial_threshold
    
    def test_brand_validation_pass(self, brand_engine, sample_script):
        """Test script passing brand validation"""
        with patch.object(brand_engine, 'calculate_brand_score', return_value=0.88):
            result = brand_engine.validate_script(sample_script)
            
            assert result["passed"] == True
            assert result["score"] == 0.88
            assert result["score"] >= 0.85  # Threshold
    
    def test_brand_validation_fail(self, brand_engine):
        """Test script failing brand validation"""
        bad_script = """
        We have all the answers. Trust us, we're experts.
        There's nothing mysterious about this - it's simple.
        Don't question our authority on this topic.
        """
        
        with patch.object(brand_engine, 'calculate_brand_score', return_value=0.3):
            result = brand_engine.validate_script(bad_script)
            
            assert result["passed"] == False
            assert result["score"] == 0.3
            assert "suggestions" in result
    
    def test_revision_suggestions(self, brand_engine):
        """Test generation of revision suggestions"""
        script = "We know exactly how this works."
        
        suggestions = brand_engine.generate_suggestions(script, score=0.4)
        
        assert len(suggestions) > 0
        assert any("uncertainty" in s.lower() or "humility" in s.lower() 
                  for s in suggestions)
    
    def test_cache_performance(self, brand_engine):
        """Test embedding cache for performance"""
        text = "This text will be embedded multiple times"
        
        # First call - generates embedding
        with patch.object(brand_engine, '_compute_embedding') as mock_compute:
            mock_compute.return_value = np.random.rand(384)
            
            embedding1 = brand_engine._get_or_compute_embedding(text)
            assert mock_compute.call_count == 1
            
            # Second call - uses cache
            embedding2 = brand_engine._get_or_compute_embedding(text)
            assert mock_compute.call_count == 1  # Not called again
            
            # Same embedding returned
            assert np.array_equal(embedding1, embedding2)
    
    def test_batch_validation(self, brand_engine):
        """Test batch script validation"""
        scripts = [
            "We don't know, but let's explore",
            "Here are the definitive answers",
            "It's a mystery worth pondering"
        ]
        
        with patch.object(brand_engine, 'calculate_brand_score') as mock_score:
            mock_score.side_effect = [0.9, 0.3, 0.85]
            
            results = brand_engine.validate_batch(scripts)
            
            assert len(results) == 3
            assert results[0]["passed"] == True
            assert results[1]["passed"] == False
            assert results[2]["passed"] == True
    
    def test_exemplar_comparison(self, brand_engine):
        """Test comparison against brand exemplars"""
        script = "We're curious about the unknown"
        exemplars = [
            "Let's explore what we don't understand",
            "The mystery deepens as we learn more"
        ]
        
        with patch.object(brand_engine, '_load_exemplars', return_value=exemplars):
            similarity_scores = brand_engine.compare_to_exemplars(script)
            
            assert len(similarity_scores) == 2
            assert all(0 <= s <= 1 for s in similarity_scores)
            assert max(similarity_scores) > 0.5  # Should be somewhat similar


if __name__ == "__main__":
    pytest.main([__file__, "-v"])