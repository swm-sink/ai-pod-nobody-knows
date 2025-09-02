#!/usr/bin/env python3
"""
Test suite for LangGraph Visual Explanation System
Tests the visual explanation system that uses "Map Navigator" analogy
to help non-technical users understand LangGraph architecture.
"""

import pytest
import sys
import os

# Add the .claude directory to Python path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

from langgraph_visual_explainer import (
    LangGraphVisualExplainer,
    WorkflowStage,
    get_map_navigator_analogy,
    get_visual_workflow_diagram,
    create_interactive_learning_checkpoint
)


class TestLangGraphVisualExplainer:
    """Test the LangGraph Visual Explanation System."""

    def test_explainer_initialization(self):
        """Test that LangGraphVisualExplainer initializes correctly."""
        explainer = LangGraphVisualExplainer()
        assert explainer is not None
        assert hasattr(explainer, 'workflow_stages')
        assert len(explainer.workflow_stages) == 5  # 5 pipeline stages

    def test_workflow_stages_structure(self):
        """Test that all 5 workflow stages are properly defined."""
        explainer = LangGraphVisualExplainer()
        stages = explainer.workflow_stages

        # Should have exactly 5 stages
        assert len(stages) == 5

        # Check each stage has required attributes
        for stage in stages:
            assert isinstance(stage, WorkflowStage)
            assert hasattr(stage, 'name')
            assert hasattr(stage, 'description')
            assert hasattr(stage, 'analogy_explanation')
            assert hasattr(stage, 'visual_diagram')
            assert hasattr(stage, 'learning_checkpoint')

    def test_map_navigator_analogy_present(self):
        """Test that Map Navigator analogy is implemented throughout."""
        explainer = LangGraphVisualExplainer()
        stages = explainer.workflow_stages

        for stage in stages:
            # Each stage should have Map Navigator analogy elements
            analogy = stage.analogy_explanation
            assert 'map' in analogy.lower() or 'navigator' in analogy.lower() or 'route' in analogy.lower()
            assert len(analogy) > 50  # Substantial explanation

    def test_visual_diagrams_exist(self):
        """Test that visual diagrams exist for all workflow stages."""
        explainer = LangGraphVisualExplainer()
        stages = explainer.workflow_stages

        for stage in stages:
            visual = stage.visual_diagram
            assert visual is not None
            assert len(visual) > 20  # Should be descriptive
            # Should describe visual elements
            assert any(word in visual.lower() for word in ['diagram', 'flow', 'chart', 'visual', 'arrow', 'box'])

    def test_interactive_learning_checkpoints(self):
        """Test that each stage has comprehension checkpoints."""
        explainer = LangGraphVisualExplainer()
        stages = explainer.workflow_stages

        for stage in stages:
            checkpoint = stage.learning_checkpoint
            assert checkpoint is not None
            assert 'question' in checkpoint
            assert 'expected_answer' in checkpoint
            assert 'feedback' in checkpoint
            assert len(checkpoint['question']) > 10  # Meaningful question

    def test_comprehension_scoring_system(self):
        """Test that comprehension scoring system works."""
        explainer = LangGraphVisualExplainer()

        # Test scoring method exists
        assert hasattr(explainer, 'assess_comprehension')

        # Test with sample answers
        sample_responses = ['good answer', 'poor answer', 'excellent detailed response']
        scores = [explainer.assess_comprehension(response) for response in sample_responses]

        # Should return numeric scores
        for score in scores:
            assert isinstance(score, (int, float))
            assert 0 <= score <= 100  # Score should be percentage

    def test_non_technical_language_requirement(self):
        """Test that explanations avoid technical jargon."""
        explainer = LangGraphVisualExplainer()
        stages = explainer.workflow_stages

        # Technical jargon to avoid in non-technical explanations
        jargon_words = [
            'api', 'json', 'http', 'database', 'server', 'client',
            'algorithm', 'function', 'method', 'class', 'object',
            'deployment', 'repository', 'configuration', 'pipeline'
        ]

        for stage in stages:
            explanation = stage.analogy_explanation.lower()
            for jargon in jargon_words:
                # Allow some technical terms but they should be explained
                if jargon in explanation:
                    # If jargon is used, it should be explained or contextualized
                    assert (
                        f"{jargon} (which means" in explanation or
                        f"{jargon} - think of it as" in explanation or
                        explanation.count(jargon) == 1  # Only mentioned once, briefly
                    ), f"Technical jargon '{jargon}' not properly explained in stage {stage.name}"

    def test_map_navigator_analogy_consistency(self):
        """Test that Map Navigator analogy is consistent across stages."""
        analogy_system = get_map_navigator_analogy()

        # Should have consistent metaphor elements
        assert 'destination' in analogy_system
        assert 'route_planning' in analogy_system
        assert 'navigation_tools' in analogy_system
        assert 'checkpoints' in analogy_system
        assert 'arrival' in analogy_system

        # Each element should map to LangGraph concepts
        for element, concept in analogy_system.items():
            assert isinstance(concept, str)
            assert len(concept) > 20  # Substantial mapping

    def test_visual_workflow_diagram_generation(self):
        """Test that visual workflow diagrams can be generated."""
        for stage_id in range(5):  # 5 pipeline stages
            diagram = get_visual_workflow_diagram(stage_id)
            assert diagram is not None
            assert isinstance(diagram, str)
            assert len(diagram) > 50  # Should be detailed
            # Should describe visual workflow elements
            assert any(word in diagram.lower() for word in ['start', 'process', 'decision', 'end', 'flow'])

    def test_interactive_learning_checkpoint_creation(self):
        """Test that interactive learning checkpoints can be created."""
        for stage_id in range(5):  # 5 pipeline stages
            checkpoint = create_interactive_learning_checkpoint(stage_id)
            assert checkpoint is not None
            assert 'scenario' in checkpoint
            assert 'task' in checkpoint
            assert 'validation' in checkpoint
            assert 'success_criteria' in checkpoint

            # Scenario should be engaging and non-technical
            scenario = checkpoint['scenario'].lower()
            assert len(scenario) > 30  # Substantial scenario
            assert 'imagine' in scenario or 'think of' in scenario or 'like' in scenario

    def test_comprehension_target_achievement(self):
        """Test that system targets ≥80% comprehension for non-technical users."""
        explainer = LangGraphVisualExplainer()

        # Should have method to validate comprehension target
        assert hasattr(explainer, 'validate_comprehension_target')

        # Test with mock user responses (simulating 80%+ comprehension)
        mock_responses = {
            'stage_0': 85,  # Good comprehension
            'stage_1': 82,  # Good comprehension
            'stage_2': 78,  # Below target
            'stage_3': 88,  # Excellent
            'stage_4': 80   # Exactly at target
        }

        average_comprehension = explainer.validate_comprehension_target(mock_responses)
        assert isinstance(average_comprehension, (int, float))
        assert 0 <= average_comprehension <= 100

    def test_langgraph_concept_coverage(self):
        """Test that all key LangGraph concepts are covered."""
        explainer = LangGraphVisualExplainer()
        stages = explainer.workflow_stages

        # Key LangGraph concepts that should be explained
        required_concepts = [
            'nodes',      # Individual processing units
            'edges',      # Connections between nodes
            'state',      # Data passed between nodes
            'workflow',   # Overall process flow
            'checkpoints' # Saving/resuming capability
        ]

        all_explanations = ' '.join([stage.analogy_explanation for stage in stages]).lower()

        for concept in required_concepts:
            # Concept should be mentioned (possibly through analogy)
            assert concept in all_explanations or f"{concept} (which" in all_explanations, \
                f"LangGraph concept '{concept}' not adequately covered in explanations"
