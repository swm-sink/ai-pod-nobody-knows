#!/usr/bin/env python3
"""
Mock API Responses for Integration Testing

This module provides comprehensive mock responses for all API integrations
to enable cost-effective testing without actual API calls.

Features:
- Realistic mock data for all major APIs
- Variable response quality for testing scenarios
- Cost simulation for budget testing
- Error simulation for failure testing
- Performance simulation for benchmarking

APIs Mocked:
- Perplexity search and research
- OpenAI/Anthropic script generation
- ElevenLabs audio synthesis
- Quality evaluation services
- Cost tracking services
"""

from config.voice_config import get_production_voice_id

from typing import Dict, Any, List, Optional
from datetime import datetime, timezone
import json


# Research Response Mocks (Perplexity)
MOCK_RESEARCH_RESPONSES = {
    'quantum_computing': {
        "expert_insights": [
            "Quantum computers leverage quantum mechanical phenomena like superposition and entanglement to perform computations",
            "Current quantum computers are in the NISQ (Noisy Intermediate-Scale Quantum) era with limited qubit counts and high error rates",
            "Quantum advantage for cryptography breaking may require 1000-4000 logical qubits, potentially achievable in 10-20 years",
            "Major tech companies like IBM, Google, and Microsoft are investing billions in quantum research",
            "Post-quantum cryptography standards are being developed proactively by NIST and other organizations"
        ],
        "recent_developments": [
            "IBM unveiled its 1000+ qubit Condor processor in 2023, though logical qubits remain the key metric",
            "Google claimed quantum error correction breakthrough in 2023 with reduced error rates",
            "NIST published post-quantum cryptography standards in August 2024",
            "European Union launched €7 billion quantum technologies flagship program",
            "China reported achieving 66-qubit quantum advantage in photonic quantum computing"
        ],
        "sources": [
            {
                "url": "https://research.ibm.com/quantum-computing",
                "title": "IBM Quantum Computing Research",
                "relevance_score": 0.95,
                "publication_date": "2024-01-15"
            },
            {
                "url": "https://ai.googleblog.com/quantum",
                "title": "Google Quantum AI Breakthrough",
                "relevance_score": 0.92,
                "publication_date": "2024-02-20"
            },
            {
                "url": "https://www.nist.gov/post-quantum-cryptography",
                "title": "NIST Post-Quantum Cryptography Standards",
                "relevance_score": 0.89,
                "publication_date": "2024-08-13"
            }
        ],
        "questions": [
            "What makes quantum computing fundamentally different from classical computing?",
            "How will quantum computers impact current cryptographic systems?",
            "What timeline do experts predict for quantum advantage in cryptography?",
            "What are the biggest technical challenges in building fault-tolerant quantum computers?",
            "How are organizations preparing for the post-quantum cryptography transition?"
        ],
        "confidence_score": 0.94,
        "research_depth": "comprehensive",
        "estimated_cost": 1.25
    },

    'ai_ethics': {
        "expert_insights": [
            "AI systems in healthcare require human oversight due to high-stakes decision making",
            "Algorithmic bias in medical AI can perpetuate health disparities across demographic groups",
            "Explainable AI (XAI) is crucial for medical applications where transparency affects patient trust",
            "FDA approval processes for AI medical devices are evolving to balance innovation with safety",
            "Medical liability and responsibility frameworks are still being developed for AI-assisted diagnoses"
        ],
        "recent_developments": [
            "EU AI Act includes specific provisions for high-risk AI applications in healthcare",
            "FDA approved 500+ AI/ML medical devices as of 2024, with new guidance on continuous learning",
            "American Medical Association published AI ethics guidelines for healthcare practitioners",
            "World Health Organization released ethics framework for AI in health and medicine",
            "Several high-profile cases of AI bias in healthcare led to improved fairness testing protocols"
        ],
        "sources": [
            {
                "url": "https://www.fda.gov/medical-devices/software-medical-device-samd/artificial-intelligence-and-machine-learning-aiml-enabled-medical-devices",
                "title": "FDA AI/ML Medical Device Regulation",
                "relevance_score": 0.96,
                "publication_date": "2024-03-10"
            },
            {
                "url": "https://www.nature.com/articles/s41746-024-01011-x",
                "title": "Nature Digital Medicine - AI Ethics in Healthcare",
                "relevance_score": 0.93,
                "publication_date": "2024-04-22"
            }
        ],
        "questions": [
            "How should AI systems make healthcare decisions while maintaining human accountability?",
            "What ethical frameworks should guide medical AI development and deployment?",
            "Who is responsible when AI makes incorrect medical diagnoses or recommendations?",
            "How can we ensure AI healthcare systems are fair across all patient populations?"
        ],
        "confidence_score": 0.91,
        "research_depth": "comprehensive",
        "estimated_cost": 1.30
    },

    'complex_topic': {
        "expert_insights": [
            "Quantum field theory provides the mathematical framework for understanding particle physics",
            "Computational biology increasingly relies on quantum mechanical principles for protein folding prediction",
            "Quantum effects in biological systems remain controversial but show promise in photosynthesis and enzyme catalysis",
            "Machine learning approaches are being applied to solve quantum many-body problems",
            "Interdisciplinary collaboration between physicists and biologists is essential for this field"
        ],
        "recent_developments": [
            "DeepMind's AlphaFold revolutionized protein structure prediction using deep learning",
            "Quantum sensing techniques are being applied to study biological processes at molecular scales",
            "New computational methods combine quantum chemistry with biological modeling",
            "Evidence for quantum coherence in avian navigation systems has been strengthened"
        ],
        "sources": [
            {
                "url": "https://www.nature.com/articles/s41586-021-03819-2",
                "title": "Nature - Quantum Biology Applications",
                "relevance_score": 0.88,
                "publication_date": "2024-01-30"
            }
        ],
        "questions": [
            "How do quantum effects influence biological processes?",
            "What computational tools are needed to model quantum biological systems?",
            "Where is the boundary between quantum and classical behavior in living systems?"
        ],
        "confidence_score": 0.85,
        "research_depth": "specialized",
        "estimated_cost": 1.45
    },

    'performance': {
        "expert_insights": [
            "Pipeline optimization requires balancing latency, throughput, and resource utilization",
            "Distributed systems benefit from careful caching strategies and load balancing",
            "Monitoring and observability are crucial for identifying performance bottlenecks",
            "Auto-scaling mechanisms help maintain performance under variable load conditions"
        ],
        "recent_developments": [
            "Serverless architectures are changing how we think about pipeline scaling",
            "Container orchestration platforms like Kubernetes improve deployment efficiency",
            "Edge computing reduces latency for geographically distributed systems"
        ],
        "sources": [
            {
                "url": "https://cloud.google.com/architecture/best-practices-for-pipeline-performance",
                "title": "Google Cloud - Pipeline Performance Best Practices",
                "relevance_score": 0.89,
                "publication_date": "2024-02-15"
            }
        ],
        "questions": [
            "What are the key metrics for measuring pipeline performance?",
            "How can caching strategies improve response times without increasing costs?",
            "What role does system architecture play in scalability?"
        ],
        "confidence_score": 0.87,
        "research_depth": "practical",
        "estimated_cost": 1.15
    },

    'fallback_research': {
        "expert_insights": [
            "Complex systems exhibit emergent properties that cannot be predicted from individual components",
            "Technology adoption follows predictable patterns but with significant variance",
            "Interdisciplinary approaches often yield breakthrough insights"
        ],
        "recent_developments": [
            "Cross-domain research collaborations are increasing",
            "New analytical tools are being developed for complex system modeling"
        ],
        "sources": [
            {
                "url": "https://example.com/complex-systems",
                "title": "Complex Systems Research",
                "relevance_score": 0.75,
                "publication_date": "2024-01-01"
            }
        ],
        "questions": [
            "How do complex systems behave differently than simple systems?",
            "What tools help us understand emergent properties?"
        ],
        "confidence_score": 0.72,
        "research_depth": "basic",
        "estimated_cost": 0.45
    }
}

# Script Generation Mocks (OpenAI/Anthropic)
MOCK_SCRIPT_RESPONSES = {
    'quantum_computing': {
        "script": """Welcome to Nobody Knows, the podcast where we explore what we understand and what remains beautifully mysterious about our world.

I'm your host, and today we're diving into quantum computing - a field that perfectly embodies our show's philosophy. What we know is fascinating, but what we don't know might be even more intriguing.

So, what do we actually know about quantum computing?

Well, we know that quantum computers work fundamentally differently from the classical computers we use every day. Instead of bits that are either 0 or 1, quantum computers use quantum bits - qubits - that can exist in what we call superposition. Think of it like a coin spinning in the air - it's neither heads nor tails until it lands.

According to IBM's latest research, their newest quantum processors have over 1000 qubits. That sounds impressive, but here's what we don't know for certain: how many of these qubits actually work reliably together?

What we think we know is that quantum computers could theoretically break much of our current encryption. The algorithms exist - Shor's algorithm, discovered back in 1994, shows how a sufficiently large quantum computer could factor the large numbers that protect our digital communications.

But nobody knows exactly when quantum computers will become powerful enough to actually do this. Some experts say 10 years, others say 30. Why such a range? Because we don't know how quickly we'll solve the massive engineering challenges that remain.

Here's what's particularly interesting: we're already preparing for a post-quantum world. NIST - the National Institute of Standards and Technology - just published new cryptographic standards designed to resist quantum attacks. We're building defenses against a threat that may or may not materialize in our lifetime.

What does this tell us? Perhaps that acknowledging uncertainty isn't weakness - it's wisdom. We prepare for what might happen while honestly admitting we don't know when or if it will.

Consider this question: In a field where the fundamental behavior relies on uncertainty and probability, how certain can we really be about anything?

What we know today might look quaint tomorrow. What we don't know today might be the key to everything tomorrow.

And maybe that's the most quantum thing of all - existing in a superposition of knowledge and ignorance until the moment of discovery collapses the wave function of understanding.

Thanks for exploring the unknown with us today. Until next time, remember - nobody knows everything, and that's what makes the journey so fascinating.""",

        "metadata": {
            "word_count": 7200,
            "estimated_duration": 45,
            "humility_phrases": 28,
            "questions": 15,
            "brand_elements": "high",
            "technical_accuracy": "verified",
            "readability_score": 72,
            "engagement_indicators": 35
        },
        "estimated_cost": 1.75
    },

    'ai_ethics': {
        "script": """Welcome to Nobody Knows, where we grapple with the questions that don't have easy answers.

Today, we're exploring AI ethics in healthcare - a field where what we don't know could literally be a matter of life and death.

Picture this scenario: You're in a hospital, and an AI system recommends a treatment plan. The AI is 85% confident in its recommendation. Your doctor agrees with the AI. But what we don't know is: what happened to the other 15%?

What we know is that AI systems in healthcare are becoming remarkably sophisticated. According to recent studies, AI can match or exceed human performance in diagnosing certain conditions - skin cancer, diabetic retinopathy, some types of pneumonia.

But here's what we don't know: How do these systems perform across different populations? If an AI was trained primarily on data from one demographic group, what happens when it encounters patients from underrepresented communities?

This isn't theoretical. We've seen cases where facial recognition systems work better on lighter skin, where heart rate monitors are less accurate on darker skin. What we think we know about AI performance might not apply universally.

Here's an uncomfortable question: When an AI makes a medical decision, who's responsible if something goes wrong? The doctor who followed the recommendation? The hospital that deployed the system? The company that built the AI?

Nobody knows for certain, because our legal frameworks are still catching up to our technology.

What we know is that transparency matters. The EU's AI Act requires certain AI systems to be explainable. But here's what we don't know: How do you explain a decision made by a neural network with millions of parameters in a way that a patient can understand?

Consider this ethical dilemma: An AI system could save lives by making faster, more accurate diagnoses. But it might also perpetuate biases present in its training data. Do we move forward with imperfect systems that could help many people? Or do we wait for perfect systems that might never come?

What we think we know is that the answer isn't binary. Maybe it's about finding the right balance between human judgment and artificial intelligence. Maybe it's about building systems that augment human capability rather than replace it.

What we don't know is how to get there. But perhaps acknowledging that uncertainty is the first step toward building AI systems that truly serve everyone.

After all, the most human thing we can do with artificial intelligence might be to admit what we don't know about it.""",

        "metadata": {
            "word_count": 6800,
            "estimated_duration": 42,
            "humility_phrases": 32,
            "questions": 18,
            "brand_elements": "high",
            "technical_accuracy": "verified",
            "readability_score": 74,
            "engagement_indicators": 41
        },
        "estimated_cost": 1.65
    }
}

# Audio Synthesis Mocks (ElevenLabs)
MOCK_AUDIO_RESPONSES = {
    'success': {
        "audio_file": "/tmp/mock_audio_synthesis_success.mp3",
        "audio_url": "https://api.elevenlabs.io/v1/audio/mock-file-id",
        "metadata": {
            "duration": 45.2,
            "file_size_mb": 43.1,
            "voice_used": "Amelia",
            "voice_id": get_production_voice_id(),
            "model_used": "eleven_turbo_v2_5",
            "character_count": 35000,
            "audio_quality": "high",
            "sample_rate": 22050,
            "format": "mp3",
            "estimated_cost": 1.66
        },
        "synthesis_time": 125.5,
        "status": "completed"
    },

    'failure': {
        "error": "Audio synthesis failed due to quota exceeded",
        "error_code": "quota_exceeded",
        "retry_suggested": True,
        "estimated_cost_saved": 2.50,
        "fallback_options": {
            "reduced_quality": {
                "estimated_cost": 1.25,
                "quality_impact": "minimal"
            },
            "different_voice": {
                "estimated_cost": 1.66,
                "voice_suggestion": "Adam"
            }
        }
    },

    'partial_success': {
        "audio_file": "/tmp/mock_audio_synthesis_partial.mp3",
        "metadata": {
            "duration": 32.1,  # Shorter than expected
            "file_size_mb": 30.5,
            "voice_used": "Amelia",
            "model_used": "eleven_turbo_v2_5",
            "character_count": 25000,  # Less than input
            "audio_quality": "medium",
            "warnings": ["Some text segments were truncated due to length limits"],
            "estimated_cost": 1.18
        },
        "status": "completed_with_warnings"
    }
}

# Quality Evaluation Mocks
MOCK_QUALITY_EVALUATIONS = {
    'high_quality': {
        "scores": {
            "brand_consistency": 8.7,
            "technical_accuracy": 8.4,
            "engagement": 8.6,
            "readability": 8.3
        },
        "overall_score": 8.5,
        "confidence": 0.92,
        "feedback": {
            "strengths": [
                "Excellent use of humility phrases and uncertainty language",
                "Strong technical accuracy with credible sources",
                "Engaging conversational style with appropriate questions",
                "Clear, accessible language for complex topics"
            ],
            "areas_for_improvement": [
                "Could include one more expert quote for additional credibility"
            ]
        },
        "brand_analysis": {
            "humility_phrases_per_1000": 4.8,
            "questions_per_1000": 3.2,
            "uncertainty_language": "appropriate",
            "brand_voice_alignment": "strong"
        },
        "estimated_cost": 0.25
    },

    'marginal_quality': {
        "scores": {
            "brand_consistency": 7.2,
            "technical_accuracy": 7.8,
            "engagement": 6.9,
            "readability": 7.4
        },
        "overall_score": 7.3,
        "confidence": 0.78,
        "feedback": {
            "strengths": [
                "Good technical content with some credible sources",
                "Reasonable readability level"
            ],
            "areas_for_improvement": [
                "Needs more humility phrases and uncertainty language",
                "Could be more engaging with additional questions",
                "Brand voice could be stronger"
            ]
        },
        "brand_analysis": {
            "humility_phrases_per_1000": 2.1,
            "questions_per_1000": 1.8,
            "uncertainty_language": "insufficient",
            "brand_voice_alignment": "weak"
        },
        "estimated_cost": 0.25
    },

    'low_quality': {
        "scores": {
            "brand_consistency": 5.2,
            "technical_accuracy": 5.8,
            "engagement": 5.1,
            "readability": 5.7
        },
        "overall_score": 5.45,
        "confidence": 0.85,
        "feedback": {
            "strengths": [
                "Basic technical content present"
            ],
            "areas_for_improvement": [
                "Lacks brand voice elements - no humility phrases",
                "Technical accuracy questionable - needs credible sources",
                "Low engagement - needs more questions and conversational elements",
                "Readability could be improved with shorter sentences"
            ]
        },
        "brand_analysis": {
            "humility_phrases_per_1000": 0.3,
            "questions_per_1000": 0.5,
            "uncertainty_language": "absent",
            "brand_voice_alignment": "poor"
        },
        "estimated_cost": 0.20
    },

    'excellent_quality': {
        "scores": {
            "brand_consistency": 9.2,
            "technical_accuracy": 9.0,
            "engagement": 9.1,
            "readability": 8.8
        },
        "overall_score": 9.03,
        "confidence": 0.96,
        "feedback": {
            "strengths": [
                "Outstanding brand voice with perfect humility/uncertainty balance",
                "Exceptional technical accuracy with multiple credible sources",
                "Highly engaging with thought-provoking questions",
                "Excellent readability while maintaining intellectual depth"
            ],
            "areas_for_improvement": [
                "Content exceeds all quality thresholds"
            ]
        },
        "brand_analysis": {
            "humility_phrases_per_1000": 5.2,
            "questions_per_1000": 4.1,
            "uncertainty_language": "optimal",
            "brand_voice_alignment": "excellent"
        },
        "estimated_cost": 0.30
    }
}

# Error Simulation Responses
MOCK_ERROR_RESPONSES = {
    'api_timeout': {
        "error": "Request timeout after 30 seconds",
        "error_code": "timeout",
        "retry_recommended": True,
        "estimated_retry_cost": 0.0
    },

    'rate_limit': {
        "error": "Rate limit exceeded",
        "error_code": "rate_limit",
        "retry_after": 60,
        "retry_recommended": True
    },

    'quota_exceeded': {
        "error": "Monthly quota exceeded",
        "error_code": "quota_exceeded",
        "retry_recommended": False,
        "alternative_approaches": [
            "Use cached responses",
            "Reduce quality settings",
            "Wait for quota reset"
        ]
    },

    'invalid_input': {
        "error": "Input validation failed",
        "error_code": "invalid_input",
        "details": "Content contains unsupported characters",
        "retry_recommended": False
    }
}

# Cost Simulation Data
MOCK_COST_DATA = {
    'operation_costs': {
        'research_discovery': 1.25,
        'research_deep_dive': 0.85,
        'question_generation': 0.35,
        'episode_planning': 0.25,
        'script_writing': 1.75,
        'script_revision': 0.65,
        'quality_evaluation': 0.25,
        'quality_re_evaluation': 0.25,
        'audio_synthesis': 1.66,
        'audio_retry': 1.66
    },

    'cost_variations': {
        'topic_complexity_multiplier': {
            'simple': 0.8,
            'moderate': 1.0,
            'complex': 1.3,
            'expert_level': 1.6
        },
        'quality_level_multiplier': {
            'basic': 0.7,
            'standard': 1.0,
            'premium': 1.4,
            'enterprise': 2.0
        },
        'urgency_multiplier': {
            'standard': 1.0,
            'priority': 1.2,
            'urgent': 1.5,
            'emergency': 2.0
        }
    },

    'budget_scenarios': {
        'strict': 5.51,
        'standard': 8.00,
        'flexible': 12.00,
        'premium': 20.00
    }
}

# Performance Simulation Data
MOCK_PERFORMANCE_DATA = {
    'response_times': {
        'research_discovery': {'min': 15.2, 'avg': 22.7, 'max': 45.3},
        'question_generation': {'min': 8.1, 'avg': 12.4, 'max': 28.7},
        'episode_planning': {'min': 5.5, 'avg': 9.2, 'max': 18.6},
        'script_writing': {'min': 45.3, 'avg': 67.8, 'max': 120.4},
        'quality_evaluation': {'min': 12.7, 'avg': 18.9, 'max': 35.2},
        'audio_synthesis': {'min': 85.6, 'avg': 125.3, 'max': 180.9}
    },

    'throughput_metrics': {
        'concurrent_requests': {'max': 5, 'recommended': 3},
        'requests_per_minute': {'max': 20, 'sustained': 12},
        'daily_quota': {'requests': 500, 'cost_limit': 100.00}
    },

    'reliability_metrics': {
        'success_rate': 0.95,
        'retry_success_rate': 0.98,
        'error_recovery_time': 45.6,
        'uptime_percentage': 99.2
    }
}


class MockResponseGenerator:
    """
    Utility class for generating mock responses with configurable parameters.

    Allows for dynamic response generation based on test scenarios,
    quality requirements, and cost constraints.
    """

    def __init__(self):
        self.response_history = []
        self.error_simulation_enabled = False
        self.cost_multiplier = 1.0

    def generate_research_response(self, topic: str, quality: str = 'high',
                                 complexity: str = 'moderate') -> Dict[str, Any]:
        """Generate research response with specified parameters."""
        # Select base response
        if topic in MOCK_RESEARCH_RESPONSES:
            base_response = MOCK_RESEARCH_RESPONSES[topic].copy()
        else:
            base_response = MOCK_RESEARCH_RESPONSES['fallback_research'].copy()

        # Apply quality adjustments
        if quality == 'low':
            base_response['confidence_score'] *= 0.7
            base_response['expert_insights'] = base_response['expert_insights'][:2]
        elif quality == 'high':
            base_response['confidence_score'] = min(0.98, base_response['confidence_score'] * 1.1)

        # Apply complexity cost adjustments
        complexity_multiplier = MOCK_COST_DATA['cost_variations']['topic_complexity_multiplier'].get(complexity, 1.0)
        base_response['estimated_cost'] *= complexity_multiplier * self.cost_multiplier

        self.response_history.append({
            'type': 'research',
            'topic': topic,
            'quality': quality,
            'complexity': complexity,
            'cost': base_response['estimated_cost']
        })

        return base_response

    def generate_quality_evaluation(self, content_type: str = 'standard',
                                  evaluator: str = 'claude') -> Dict[str, Any]:
        """Generate quality evaluation response."""
        if content_type in MOCK_QUALITY_EVALUATIONS:
            evaluation = MOCK_QUALITY_EVALUATIONS[content_type].copy()
        else:
            evaluation = MOCK_QUALITY_EVALUATIONS['marginal_quality'].copy()

        # Add evaluator-specific variations
        if evaluator == 'gemini':
            # Slightly different scoring tendencies
            for score_type in evaluation['scores']:
                evaluation['scores'][score_type] += 0.1 * (hash(score_type) % 3 - 1)
        elif evaluator == 'perplexity':
            # Focus more on technical accuracy
            evaluation['scores']['technical_accuracy'] += 0.15
            evaluation['scores']['engagement'] -= 0.1

        # Recalculate overall score
        scores = list(evaluation['scores'].values())
        evaluation['overall_score'] = sum(scores) / len(scores)

        evaluation['estimated_cost'] *= self.cost_multiplier

        return evaluation

    def simulate_error(self, error_type: str = 'random') -> Dict[str, Any]:
        """Simulate various error conditions."""
        if error_type == 'random':
            error_types = list(MOCK_ERROR_RESPONSES.keys())
            error_type = error_types[hash(str(self.response_history)) % len(error_types)]

        return MOCK_ERROR_RESPONSES.get(error_type, MOCK_ERROR_RESPONSES['api_timeout'])

    def get_cost_estimate(self, operation: str, adjustments: Dict[str, Any] = None) -> float:
        """Get cost estimate for an operation with optional adjustments."""
        base_cost = MOCK_COST_DATA['operation_costs'].get(operation, 1.00)

        if adjustments:
            if 'complexity' in adjustments:
                complexity_mult = MOCK_COST_DATA['cost_variations']['topic_complexity_multiplier'].get(
                    adjustments['complexity'], 1.0)
                base_cost *= complexity_mult

            if 'quality' in adjustments:
                quality_mult = MOCK_COST_DATA['cost_variations']['quality_level_multiplier'].get(
                    adjustments['quality'], 1.0)
                base_cost *= quality_mult

            if 'urgency' in adjustments:
                urgency_mult = MOCK_COST_DATA['cost_variations']['urgency_multiplier'].get(
                    adjustments['urgency'], 1.0)
                base_cost *= urgency_mult

        return base_cost * self.cost_multiplier

    def set_cost_multiplier(self, multiplier: float):
        """Set global cost multiplier for testing scenarios."""
        self.cost_multiplier = multiplier

    def enable_error_simulation(self, enabled: bool = True):
        """Enable or disable error simulation."""
        self.error_simulation_enabled = enabled

    def get_response_history(self) -> List[Dict[str, Any]]:
        """Get history of generated responses."""
        return self.response_history.copy()

    def reset_history(self):
        """Reset response history."""
        self.response_history = []


# Export main data structures for easy import
__all__ = [
    'MOCK_RESEARCH_RESPONSES',
    'MOCK_SCRIPT_RESPONSES',
    'MOCK_AUDIO_RESPONSES',
    'MOCK_QUALITY_EVALUATIONS',
    'MOCK_ERROR_RESPONSES',
    'MOCK_COST_DATA',
    'MOCK_PERFORMANCE_DATA',
    'MockResponseGenerator'
]
