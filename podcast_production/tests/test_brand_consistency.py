"""
Tests for Brand Consistency Engine

Version: 1.0.0
Date: September 2025
"""

import pytest
import numpy as np
from unittest.mock import Mock, patch
from datetime import datetime

from core.brand_consistency import (
    BrandConsistencyEngine,
    BrandDimensions,
    BrandExemplar
)


@pytest.fixture
def brand_engine():
    """Create brand consistency engine instance"""
    with patch('core.brand_consistency.SentenceTransformer'):
        engine = BrandConsistencyEngine(
            model_name="all-MiniLM-L6-v2",
            enable_adaptive_learning=True
        )
        # Mock the model encode method
        engine.model.encode = Mock(return_value=np.array([[0.5, 0.5, 0.5]]))
        return engine


@pytest.fixture
def sample_content():
    """Sample content for testing"""
    return {
        "good": "Have you ever wondered why we dream? Scientists have been studying this "
                "for decades, and while we have some theories, nobody really knows for certain. "
                "It's one of those beautiful mysteries that reminds us how much we still have to learn.",
        "bad": "Dreams are caused by REM sleep. This is a well-established fact that has been "
               "proven by numerous studies. There is no mystery here.",
        "mixed": "Current research definitively shows that dreams might be related to memory. "
                 "We know exactly how this works, or perhaps we don't."
    }


class TestBrandDimensions:
    """Test brand dimension calculations"""
    
    def test_dimension_to_vector(self):
        """Test converting dimensions to vector"""
        dims = BrandDimensions(
            intellectual_humility=0.8,
            curiosity_quotient=0.7,
            question_ratio=0.3,
            uncertainty_acknowledgment=0.6,
            exploration_language=0.4,
            citation_density=0.5,
            tone_consistency=0.9,
            vocabulary_sophistication=0.7
        )
        
        vector = dims.to_vector()
        
        assert len(vector) == 8
        assert vector[0] == 0.8  # intellectual_humility
        assert vector[6] == 0.9  # tone_consistency
    
    def test_dimension_from_vector(self):
        """Test updating dimensions from vector"""
        dims = BrandDimensions()
        vector = np.array([0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2])
        
        dims.from_vector(vector)
        
        assert dims.intellectual_humility == 0.9
        assert dims.curiosity_quotient == 0.8
        assert dims.vocabulary_sophistication == 0.2


class TestDimensionAnalysis:
    """Test text dimension analysis"""
    
    def test_intellectual_humility_detection(self, brand_engine):
        """Test detection of intellectual humility markers"""
        text = "We don't fully understand this yet. Scientists are still learning about it."
        
        dims = brand_engine._analyze_dimensions(text)
        
        assert dims.intellectual_humility > 0.5  # Should detect humility markers
    
    def test_curiosity_detection(self, brand_engine):
        """Test detection of curiosity markers"""
        text = "Have you ever wondered what makes this fascinating phenomenon happen?"
        
        dims = brand_engine._analyze_dimensions(text)
        
        assert dims.curiosity_quotient > 0.5  # Should detect curiosity markers
    
    def test_question_ratio_calculation(self, brand_engine):
        """Test question ratio calculation"""
        text = "What is this? How does it work? This is interesting. Why does it matter?"
        
        dims = brand_engine._analyze_dimensions(text)
        
        # 3 questions out of 4 sentences
        assert dims.question_ratio == 0.75
    
    def test_uncertainty_acknowledgment(self, brand_engine):
        """Test uncertainty language detection"""
        text = "This might be related. It could perhaps be caused by that. Maybe it's something else."
        
        dims = brand_engine._analyze_dimensions(text)
        
        assert dims.uncertainty_acknowledgment > 0.3  # Should detect uncertainty words
    
    def test_exploration_language(self, brand_engine):
        """Test exploration language detection"""
        text = "Let's explore this topic and discover what we can investigate."
        
        dims = brand_engine._analyze_dimensions(text)
        
        assert dims.exploration_language > 0.3  # Should detect exploration words
    
    def test_citation_density(self, brand_engine):
        """Test citation marker detection"""
        text = "Research shows this. Studies indicate that. Scientists have found evidence."
        
        dims = brand_engine._analyze_dimensions(text)
        
        assert dims.citation_density > 0.5  # Should detect citation markers


class TestContentValidation:
    """Test content validation"""
    
    @pytest.mark.asyncio
    async def test_good_content_validation(self, brand_engine, sample_content):
        """Test validation of good brand-aligned content"""
        result = await brand_engine.validate_content(
            content=sample_content["good"],
            category="episode_script"
        )
        
        assert result["passes"] is True
        assert result["composite_score"] > 0.7
        assert "intellectual_humility" in result["dimensions"]
        assert len(result["recommendations"]) <= 3
    
    @pytest.mark.asyncio
    async def test_poor_content_validation(self, brand_engine, sample_content):
        """Test validation of poor brand-aligned content"""
        result = await brand_engine.validate_content(
            content=sample_content["bad"],
            category="episode_script"
        )
        
        # Should fail or have low score
        assert result["composite_score"] < 0.7
        assert len(result["recommendations"]) > 0
    
    @pytest.mark.asyncio
    async def test_strict_mode_validation(self, brand_engine, sample_content):
        """Test strict mode validation"""
        result = await brand_engine.validate_content(
            content=sample_content["mixed"],
            category="episode_script",
            strict_mode=True
        )
        
        # Strict mode has higher threshold (0.9)
        if result["composite_score"] < 0.9:
            assert result["passes"] is False
    
    @pytest.mark.asyncio
    async def test_category_specific_validation(self, brand_engine, sample_content):
        """Test category-specific validation"""
        # Test different categories
        categories = ["opening", "research_discussion", "explanation", "general"]
        
        for category in categories:
            result = await brand_engine.validate_content(
                content=sample_content["good"],
                category=category
            )
            
            assert "category" in result
            assert result["category"] == category


class TestSemanticSimilarity:
    """Test semantic similarity calculations"""
    
    def test_semantic_similarity_calculation(self, brand_engine):
        """Test semantic similarity to exemplars"""
        # Create mock embedding
        content_embedding = np.array([0.4, 0.5, 0.6])
        
        # Add mock exemplar
        exemplar = BrandExemplar(
            text="Test exemplar",
            embedding=np.array([0.5, 0.5, 0.5]),
            weight=1.0
        )
        brand_engine.exemplars = [exemplar]
        
        similarity = brand_engine._calculate_semantic_similarity(
            content_embedding,
            "general"
        )
        
        assert 0 <= similarity <= 1
        assert similarity > 0.9  # Should be high for similar vectors
    
    def test_weighted_similarity(self, brand_engine):
        """Test weighted semantic similarity"""
        content_embedding = np.array([0.5, 0.5, 0.5])
        
        # Add exemplars with different weights
        exemplars = [
            BrandExemplar(
                text="High weight",
                embedding=np.array([0.5, 0.5, 0.5]),
                weight=2.0
            ),
            BrandExemplar(
                text="Low weight",
                embedding=np.array([0.1, 0.1, 0.1]),
                weight=0.5
            )
        ]
        brand_engine.exemplars = exemplars
        
        similarity = brand_engine._calculate_semantic_similarity(
            content_embedding,
            "general"
        )
        
        # Should be influenced more by high-weight exemplar
        assert similarity > 0.7


class TestDriftDetection:
    """Test brand drift detection"""
    
    def test_no_drift_detection(self, brand_engine):
        """Test when no drift is detected"""
        # Set baseline
        brand_engine.baseline_dimensions = BrandDimensions(
            intellectual_humility=0.8,
            curiosity_quotient=0.7,
            question_ratio=0.3
        )
        
        # Similar content dimensions
        content_dims = BrandDimensions(
            intellectual_humility=0.75,  # Within threshold
            curiosity_quotient=0.72,
            question_ratio=0.28
        )
        
        drift_detected, details = brand_engine._detect_brand_drift(content_dims)
        
        assert drift_detected is False
        assert details is None
    
    def test_drift_detection(self, brand_engine):
        """Test drift detection"""
        # Set baseline
        brand_engine.baseline_dimensions = BrandDimensions(
            intellectual_humility=0.8,
            curiosity_quotient=0.7,
            question_ratio=0.3
        )
        
        # Significantly different content
        content_dims = BrandDimensions(
            intellectual_humility=0.2,  # Major deviation
            curiosity_quotient=0.7,
            question_ratio=0.1  # Major deviation
        )
        
        drift_detected, details = brand_engine._detect_brand_drift(content_dims)
        
        assert drift_detected is True
        assert details is not None
        assert "deviations" in details
        assert "intellectual_humility" in details["deviations"]
        assert "question_ratio" in details["deviations"]


class TestRecommendations:
    """Test recommendation generation"""
    
    def test_humility_recommendations(self, brand_engine):
        """Test recommendations for low humility"""
        content = "This is definitely how it works. We know everything about it."
        
        dims = brand_engine._analyze_dimensions(content)
        dims.intellectual_humility = 0.1  # Force low humility
        
        recommendations = brand_engine._generate_recommendations(
            content,
            dims,
            semantic_score=0.8,
            dimensional_score=0.6
        )
        
        # Should recommend adding uncertainty phrases
        assert any("uncertainty" in r.lower() or "scientists" in r.lower() 
                  for r in recommendations)
    
    def test_curiosity_recommendations(self, brand_engine):
        """Test recommendations for low curiosity"""
        content = "This is the information. Here are the facts."
        
        dims = brand_engine._analyze_dimensions(content)
        dims.curiosity_quotient = 0.1  # Force low curiosity
        
        recommendations = brand_engine._generate_recommendations(
            content,
            dims,
            semantic_score=0.8,
            dimensional_score=0.6
        )
        
        # Should recommend adding curiosity language
        assert any("curious" in r.lower() or "wonder" in r.lower() 
                  for r in recommendations)
    
    def test_question_recommendations(self, brand_engine):
        """Test recommendations for low question ratio"""
        content = "This is statement one. This is statement two. This is statement three."
        
        dims = brand_engine._analyze_dimensions(content)
        
        recommendations = brand_engine._generate_recommendations(
            content,
            dims,
            semantic_score=0.8,
            dimensional_score=0.6
        )
        
        # Should recommend adding questions
        assert any("question" in r.lower() for r in recommendations)


class TestAdaptiveLearning:
    """Test adaptive learning functionality"""
    
    @pytest.mark.asyncio
    async def test_exemplar_learning(self, brand_engine):
        """Test learning from successful content"""
        initial_count = len(brand_engine.exemplars)
        
        # Validate high-quality content
        good_content = "Have you ever wondered about this mystery? Scientists are still exploring..."
        
        # Mock high scores to trigger learning
        with patch.object(brand_engine, '_calculate_semantic_similarity', return_value=0.9):
            with patch.object(brand_engine, '_calculate_dimensional_alignment', return_value=0.9):
                result = await brand_engine.validate_content(
                    content=good_content,
                    category="test"
                )
        
        # Should add new exemplar if passes threshold
        if result["passes"]:
            assert len(brand_engine.exemplars) > initial_count
            
            # Check new exemplar
            new_exemplar = brand_engine.exemplars[-1]
            assert new_exemplar.metadata.get("learned") is True
            assert new_exemplar.weight < 1.0  # Lower weight for learned
    
    def test_exemplar_limit(self, brand_engine):
        """Test exemplar count limit"""
        # Add many exemplars
        for i in range(60):
            brand_engine.exemplars.append(
                BrandExemplar(text=f"Test {i}", weight=0.5)
            )
        
        initial_count = len(brand_engine.exemplars)
        
        # Try to add more through learning
        brand_engine._update_exemplars(
            "New content",
            np.array([0.5, 0.5]),
            BrandDimensions(),
            "test"
        )
        
        # Should not exceed limit (50 in implementation)
        assert len(brand_engine.exemplars) <= 50


class TestBrandReport:
    """Test brand report generation"""
    
    def test_brand_report_generation(self, brand_engine):
        """Test comprehensive brand report"""
        report = brand_engine.get_brand_report()
        
        assert "baseline_dimensions" in report
        assert "exemplar_count" in report
        assert "exemplar_categories" in report
        assert "drift_threshold" in report
        
        # Check baseline dimensions
        dims = report["baseline_dimensions"]
        assert "intellectual_humility" in dims
        assert "curiosity_quotient" in dims
        assert all(0 <= v <= 1 for v in dims.values())
        
        # Check counts
        assert report["exemplar_count"] >= 0
        assert isinstance(report["exemplar_categories"], list)