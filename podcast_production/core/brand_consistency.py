"""
Advanced Brand Consistency Engine with ML-based Validation

This module implements sophisticated brand voice validation using
vector embeddings, semantic similarity, and multi-dimensional scoring.

Version: 1.0.0
Date: September 2025
"""

import logging
import numpy as np
from typing import Dict, Any, List, Optional, Tuple
from dataclasses import dataclass, field
from datetime import datetime
import json
from pathlib import Path

# ML imports
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import MinMaxScaler
import nltk
from nltk.tokenize import sent_tokenize, word_tokenize
from nltk.sentiment import SentimentIntensityAnalyzer

# Download required NLTK data
try:
    nltk.data.find('tokenizers/punkt')
except LookupError:
    nltk.download('punkt', quiet=True)

try:
    nltk.data.find('vader_lexicon')
except LookupError:
    nltk.download('vader_lexicon', quiet=True)

logger = logging.getLogger(__name__)


@dataclass
class BrandDimensions:
    """Multi-dimensional brand characteristics"""
    intellectual_humility: float = 0.0  # 0-1 score
    curiosity_quotient: float = 0.0     # 0-1 score
    question_ratio: float = 0.0         # Ratio of questions to statements
    uncertainty_acknowledgment: float = 0.0  # How often uncertainty is expressed
    exploration_language: float = 0.0   # Use of exploratory phrases
    citation_density: float = 0.0       # References per paragraph
    tone_consistency: float = 0.0       # Consistency of tone
    vocabulary_sophistication: float = 0.0  # Vocabulary level
    
    def to_vector(self) -> np.ndarray:
        """Convert dimensions to vector"""
        return np.array([
            self.intellectual_humility,
            self.curiosity_quotient,
            self.question_ratio,
            self.uncertainty_acknowledgment,
            self.exploration_language,
            self.citation_density,
            self.tone_consistency,
            self.vocabulary_sophistication
        ])
    
    def from_vector(self, vector: np.ndarray):
        """Update from vector"""
        self.intellectual_humility = vector[0]
        self.curiosity_quotient = vector[1]
        self.question_ratio = vector[2]
        self.uncertainty_acknowledgment = vector[3]
        self.exploration_language = vector[4]
        self.citation_density = vector[5]
        self.tone_consistency = vector[6]
        self.vocabulary_sophistication = vector[7]


@dataclass
class BrandExemplar:
    """Example of ideal brand content"""
    text: str
    embedding: Optional[np.ndarray] = None
    dimensions: BrandDimensions = field(default_factory=BrandDimensions)
    weight: float = 1.0
    category: str = "general"
    metadata: Dict[str, Any] = field(default_factory=dict)


class BrandConsistencyEngine:
    """
    Advanced brand consistency validation using ML techniques.
    
    Features:
    - Semantic similarity scoring
    - Multi-dimensional brand analysis
    - Real-time drift detection
    - Adaptive learning from feedback
    - Detailed improvement recommendations
    """
    
    # Brand-specific phrases for "Nobody Knows" podcast
    INTELLECTUAL_HUMILITY_MARKERS = [
        "we don't fully understand",
        "scientists are still",
        "remains a mystery",
        "nobody really knows",
        "it's complicated",
        "we're still learning",
        "might be",
        "could be",
        "perhaps",
        "it seems",
        "evidence suggests",
        "current understanding",
        "as far as we know"
    ]
    
    CURIOSITY_MARKERS = [
        "what if",
        "have you ever wondered",
        "let's explore",
        "imagine",
        "consider this",
        "think about",
        "fascinating",
        "intriguing",
        "surprising",
        "unexpected"
    ]
    
    def __init__(
        self,
        model_name: str = "all-MiniLM-L6-v2",
        exemplar_path: Optional[str] = None,
        enable_adaptive_learning: bool = True
    ):
        """
        Initialize brand consistency engine.
        
        Args:
            model_name: Sentence transformer model
            exemplar_path: Path to brand exemplars
            enable_adaptive_learning: Enable learning from feedback
        """
        self.model = SentenceTransformer(model_name)
        self.sentiment_analyzer = SentimentIntensityAnalyzer()
        self.scaler = MinMaxScaler()
        
        self.exemplars: List[BrandExemplar] = []
        self.enable_adaptive_learning = enable_adaptive_learning
        
        # Load exemplars
        if exemplar_path:
            self.load_exemplars(exemplar_path)
        else:
            self._load_default_exemplars()
        
        # Precompute exemplar embeddings
        self._compute_exemplar_embeddings()
        
        # Initialize drift detection
        self.baseline_dimensions = self._compute_baseline_dimensions()
        self.drift_threshold = 0.15  # 15% deviation triggers warning
        
        logger.info(f"Initialized BrandConsistencyEngine with {len(self.exemplars)} exemplars")
    
    def _load_default_exemplars(self):
        """Load default brand exemplars for Nobody Knows podcast"""
        default_exemplars = [
            BrandExemplar(
                text="Have you ever wondered why we dream? Scientists have been studying this "
                     "for decades, and while we have some theories, nobody really knows for certain. "
                     "It's one of those beautiful mysteries that reminds us how much we still have to learn.",
                weight=1.5,
                category="opening"
            ),
            BrandExemplar(
                text="Current research suggests it might be related to memory consolidation, "
                     "but that's just one piece of a much larger puzzle. What's fascinating is that "
                     "every new discovery seems to reveal ten new questions.",
                weight=1.2,
                category="research_discussion"
            ),
            BrandExemplar(
                text="As far as we know, this process involves multiple brain regions working together, "
                     "though we're still piecing together exactly how. It's humbling to realize that "
                     "something we all experience every day remains largely mysterious.",
                weight=1.0,
                category="explanation"
            )
        ]
        
        self.exemplars.extend(default_exemplars)
    
    def load_exemplars(self, path: str):
        """Load brand exemplars from file"""
        exemplar_path = Path(path)
        
        if exemplar_path.exists():
            with open(exemplar_path, 'r') as f:
                data = json.load(f)
                
                for item in data.get("exemplars", []):
                    exemplar = BrandExemplar(
                        text=item["text"],
                        weight=item.get("weight", 1.0),
                        category=item.get("category", "general"),
                        metadata=item.get("metadata", {})
                    )
                    self.exemplars.append(exemplar)
            
            logger.info(f"Loaded {len(self.exemplars)} exemplars from {path}")
    
    def _compute_exemplar_embeddings(self):
        """Compute embeddings for all exemplars"""
        for exemplar in self.exemplars:
            exemplar.embedding = self.model.encode([exemplar.text])[0]
            exemplar.dimensions = self._analyze_dimensions(exemplar.text)
    
    def _compute_baseline_dimensions(self) -> BrandDimensions:
        """Compute baseline brand dimensions from exemplars"""
        if not self.exemplars:
            return BrandDimensions()
        
        dimension_vectors = [ex.dimensions.to_vector() for ex in self.exemplars]
        weights = [ex.weight for ex in self.exemplars]
        
        # Weighted average
        weighted_sum = sum(v * w for v, w in zip(dimension_vectors, weights))
        total_weight = sum(weights)
        
        baseline_vector = weighted_sum / total_weight
        
        baseline = BrandDimensions()
        baseline.from_vector(baseline_vector)
        
        return baseline
    
    async def validate_content(
        self,
        content: str,
        category: str = "general",
        strict_mode: bool = False
    ) -> Dict[str, Any]:
        """
        Validate content against brand standards.
        
        Args:
            content: Content to validate
            category: Content category
            strict_mode: Use stricter thresholds
            
        Returns:
            Validation results with scores and recommendations
        """
        # Compute content embedding
        content_embedding = self.model.encode([content])[0]
        
        # Analyze dimensions
        content_dimensions = self._analyze_dimensions(content)
        
        # Calculate semantic similarity
        semantic_score = self._calculate_semantic_similarity(
            content_embedding,
            category
        )
        
        # Calculate dimensional alignment
        dimensional_score = self._calculate_dimensional_alignment(
            content_dimensions
        )
        
        # Detect brand drift
        drift_detected, drift_details = self._detect_brand_drift(
            content_dimensions
        )
        
        # Calculate composite score
        composite_score = self._calculate_composite_score(
            semantic_score,
            dimensional_score,
            content_dimensions
        )
        
        # Generate recommendations
        recommendations = self._generate_recommendations(
            content,
            content_dimensions,
            semantic_score,
            dimensional_score
        )
        
        # Determine pass/fail
        threshold = 0.9 if strict_mode else 0.85
        passes = composite_score >= threshold
        
        result = {
            "passes": passes,
            "composite_score": round(composite_score, 3),
            "semantic_similarity": round(semantic_score, 3),
            "dimensional_alignment": round(dimensional_score, 3),
            "dimensions": {
                "intellectual_humility": round(content_dimensions.intellectual_humility, 3),
                "curiosity_quotient": round(content_dimensions.curiosity_quotient, 3),
                "question_ratio": round(content_dimensions.question_ratio, 3),
                "uncertainty_acknowledgment": round(content_dimensions.uncertainty_acknowledgment, 3),
                "exploration_language": round(content_dimensions.exploration_language, 3),
                "citation_density": round(content_dimensions.citation_density, 3),
                "tone_consistency": round(content_dimensions.tone_consistency, 3),
                "vocabulary_sophistication": round(content_dimensions.vocabulary_sophistication, 3)
            },
            "drift_detected": drift_detected,
            "drift_details": drift_details if drift_detected else None,
            "recommendations": recommendations[:3],  # Top 3 recommendations
            "category": category,
            "timestamp": datetime.now().isoformat()
        }
        
        # Adaptive learning
        if self.enable_adaptive_learning and passes:
            self._update_exemplars(content, content_embedding, content_dimensions, category)
        
        return result
    
    def _analyze_dimensions(self, text: str) -> BrandDimensions:
        """Analyze text for brand dimensions"""
        dimensions = BrandDimensions()
        
        # Tokenize
        sentences = sent_tokenize(text)
        words = word_tokenize(text.lower())
        
        # Intellectual humility
        humility_count = sum(
            1 for marker in self.INTELLECTUAL_HUMILITY_MARKERS
            if marker in text.lower()
        )
        dimensions.intellectual_humility = min(humility_count / max(len(sentences), 1), 1.0)
        
        # Curiosity quotient
        curiosity_count = sum(
            1 for marker in self.CURIOSITY_MARKERS
            if marker in text.lower()
        )
        dimensions.curiosity_quotient = min(curiosity_count / max(len(sentences), 1), 1.0)
        
        # Question ratio
        question_count = sum(1 for sent in sentences if sent.strip().endswith('?'))
        dimensions.question_ratio = question_count / max(len(sentences), 1)
        
        # Uncertainty acknowledgment
        uncertainty_words = ['might', 'could', 'perhaps', 'possibly', 'maybe', 'seems']
        uncertainty_count = sum(1 for word in words if word in uncertainty_words)
        dimensions.uncertainty_acknowledgment = min(uncertainty_count / max(len(words), 1) * 10, 1.0)
        
        # Exploration language
        exploration_words = ['explore', 'discover', 'investigate', 'examine', 'consider']
        exploration_count = sum(1 for word in words if word in exploration_words)
        dimensions.exploration_language = min(exploration_count / max(len(words), 1) * 20, 1.0)
        
        # Citation density (looking for phrases like "research shows", "studies indicate")
        citation_markers = ['research', 'study', 'studies', 'scientists', 'researchers', 'evidence']
        citation_count = sum(1 for word in words if word in citation_markers)
        dimensions.citation_density = min(citation_count / max(len(sentences), 1), 1.0)
        
        # Tone consistency (using sentiment analysis)
        sentiments = [self.sentiment_analyzer.polarity_scores(sent)['compound'] for sent in sentences]
        if sentiments:
            dimensions.tone_consistency = 1.0 - np.std(sentiments)  # Less variation = higher consistency
        
        # Vocabulary sophistication (average word length as proxy)
        avg_word_length = np.mean([len(word) for word in words if len(word) > 2])
        dimensions.vocabulary_sophistication = min(avg_word_length / 10, 1.0)
        
        return dimensions
    
    def _calculate_semantic_similarity(
        self,
        content_embedding: np.ndarray,
        category: str
    ) -> float:
        """Calculate semantic similarity to exemplars"""
        # Filter exemplars by category if specified
        relevant_exemplars = [
            ex for ex in self.exemplars
            if category == "general" or ex.category == category
        ]
        
        if not relevant_exemplars:
            relevant_exemplars = self.exemplars
        
        # Calculate weighted similarities
        similarities = []
        weights = []
        
        for exemplar in relevant_exemplars:
            similarity = cosine_similarity(
                content_embedding.reshape(1, -1),
                exemplar.embedding.reshape(1, -1)
            )[0][0]
            
            similarities.append(similarity)
            weights.append(exemplar.weight)
        
        # Weighted average
        weighted_similarity = np.average(similarities, weights=weights)
        
        return float(weighted_similarity)
    
    def _calculate_dimensional_alignment(
        self,
        content_dimensions: BrandDimensions
    ) -> float:
        """Calculate alignment with baseline dimensions"""
        content_vector = content_dimensions.to_vector()
        baseline_vector = self.baseline_dimensions.to_vector()
        
        # Calculate cosine similarity
        similarity = cosine_similarity(
            content_vector.reshape(1, -1),
            baseline_vector.reshape(1, -1)
        )[0][0]
        
        return float(similarity)
    
    def _detect_brand_drift(
        self,
        content_dimensions: BrandDimensions
    ) -> Tuple[bool, Optional[Dict[str, Any]]]:
        """Detect if content is drifting from brand standards"""
        content_vector = content_dimensions.to_vector()
        baseline_vector = self.baseline_dimensions.to_vector()
        
        # Calculate deviation for each dimension
        deviations = {}
        drift_detected = False
        
        dimension_names = [
            "intellectual_humility",
            "curiosity_quotient",
            "question_ratio",
            "uncertainty_acknowledgment",
            "exploration_language",
            "citation_density",
            "tone_consistency",
            "vocabulary_sophistication"
        ]
        
        for i, name in enumerate(dimension_names):
            baseline_val = baseline_vector[i]
            content_val = content_vector[i]
            
            if baseline_val > 0:
                deviation = abs(content_val - baseline_val) / baseline_val
                
                if deviation > self.drift_threshold:
                    drift_detected = True
                    deviations[name] = {
                        "baseline": round(baseline_val, 3),
                        "current": round(content_val, 3),
                        "deviation": round(deviation * 100, 1)  # As percentage
                    }
        
        if drift_detected:
            return True, {"deviations": deviations}
        
        return False, None
    
    def _calculate_composite_score(
        self,
        semantic_score: float,
        dimensional_score: float,
        dimensions: BrandDimensions
    ) -> float:
        """Calculate weighted composite score"""
        # Weights for different components
        weights = {
            "semantic": 0.3,
            "dimensional": 0.3,
            "intellectual_humility": 0.15,
            "curiosity": 0.1,
            "questions": 0.1,
            "tone": 0.05
        }
        
        composite = (
            semantic_score * weights["semantic"] +
            dimensional_score * weights["dimensional"] +
            dimensions.intellectual_humility * weights["intellectual_humility"] +
            dimensions.curiosity_quotient * weights["curiosity"] +
            dimensions.question_ratio * weights["questions"] +
            dimensions.tone_consistency * weights["tone"]
        )
        
        return float(composite)
    
    def _generate_recommendations(
        self,
        content: str,
        dimensions: BrandDimensions,
        semantic_score: float,
        dimensional_score: float
    ) -> List[str]:
        """Generate specific improvement recommendations"""
        recommendations = []
        
        # Check intellectual humility
        if dimensions.intellectual_humility < self.baseline_dimensions.intellectual_humility - 0.1:
            recommendations.append(
                "Add more phrases acknowledging uncertainty (e.g., 'scientists are still learning', "
                "'we don't fully understand')"
            )
        
        # Check curiosity
        if dimensions.curiosity_quotient < self.baseline_dimensions.curiosity_quotient - 0.1:
            recommendations.append(
                "Incorporate more curiosity-driven language (e.g., 'Have you ever wondered?', "
                "'What's fascinating is...')"
            )
        
        # Check questions
        if dimensions.question_ratio < 0.1:
            recommendations.append(
                "Include more questions to engage the audience and express wonder"
            )
        
        # Check uncertainty acknowledgment
        if dimensions.uncertainty_acknowledgment < self.baseline_dimensions.uncertainty_acknowledgment - 0.1:
            recommendations.append(
                "Use more tentative language where appropriate (e.g., 'might', 'could', 'perhaps')"
            )
        
        # Check exploration language
        if dimensions.exploration_language < 0.05:
            recommendations.append(
                "Add exploration-focused vocabulary (e.g., 'let's explore', 'consider this')"
            )
        
        # Check semantic similarity
        if semantic_score < 0.7:
            recommendations.append(
                "Review brand exemplars to better match the established voice and style"
            )
        
        # Sort by priority
        return recommendations
    
    def _update_exemplars(
        self,
        content: str,
        embedding: np.ndarray,
        dimensions: BrandDimensions,
        category: str
    ):
        """Update exemplars with successful content (adaptive learning)"""
        # Only add high-quality content as new exemplars
        if len(self.exemplars) < 50:  # Limit total exemplars
            new_exemplar = BrandExemplar(
                text=content[:500],  # Truncate for storage
                embedding=embedding,
                dimensions=dimensions,
                weight=0.5,  # Lower weight for learned exemplars
                category=category,
                metadata={"learned": True, "timestamp": datetime.now().isoformat()}
            )
            
            self.exemplars.append(new_exemplar)
            
            # Recompute baseline
            self.baseline_dimensions = self._compute_baseline_dimensions()
            
            logger.debug(f"Added new exemplar from successful content (total: {len(self.exemplars)})")
    
    def get_brand_report(self) -> Dict[str, Any]:
        """Generate comprehensive brand analysis report"""
        return {
            "baseline_dimensions": {
                "intellectual_humility": round(self.baseline_dimensions.intellectual_humility, 3),
                "curiosity_quotient": round(self.baseline_dimensions.curiosity_quotient, 3),
                "question_ratio": round(self.baseline_dimensions.question_ratio, 3),
                "uncertainty_acknowledgment": round(self.baseline_dimensions.uncertainty_acknowledgment, 3),
                "exploration_language": round(self.baseline_dimensions.exploration_language, 3),
                "citation_density": round(self.baseline_dimensions.citation_density, 3),
                "tone_consistency": round(self.baseline_dimensions.tone_consistency, 3),
                "vocabulary_sophistication": round(self.baseline_dimensions.vocabulary_sophistication, 3)
            },
            "exemplar_count": len(self.exemplars),
            "exemplar_categories": list(set(ex.category for ex in self.exemplars)),
            "learned_exemplars": sum(1 for ex in self.exemplars if ex.metadata.get("learned")),
            "drift_threshold": self.drift_threshold,
            "model": self.model._modules['0'].auto_model.name_or_path if hasattr(self.model, '_modules') else "unknown"
        }