"""
Test suite for user personas definition and validation
Test-Driven Development for Task UX-001

Test Strategy:
Given: Need to define 3 non-technical user personas
When: Personas are created with specified attributes
Then: Personas have clear characteristics, proficiency levels, and success paths
Because: User personas guide all subsequent UX design decisions
"""

import pytest
from typing import Dict, List, Optional
from user_personas import TechnicalProficiency, UserPersona


class TestUserPersonas:
    """Test suite for user persona validation"""

    def test_persona_collection_exists(self):
        """Test that persona collection is defined and accessible"""
        from user_personas import get_user_personas

        personas = get_user_personas()
        assert personas is not None, "User personas collection must be defined"
        assert isinstance(personas, list), "Personas must be returned as a list"

    def test_three_distinct_personas_defined(self):
        """Test that exactly 3 distinct personas are defined"""
        from user_personas import get_user_personas

        personas = get_user_personas()
        assert len(personas) == 3, "Must define exactly 3 user personas"

        # Verify all personas are distinct
        names = [p.name for p in personas]
        assert len(set(names)) == 3, "All personas must have distinct names"

        roles = [p.role for p in personas]
        assert len(set(roles)) == 3, "All personas must have distinct roles"

    def test_business_user_persona_requirements(self):
        """Test business user persona meets specification requirements"""
        from user_personas import get_user_personas

        personas = get_user_personas()
        business_user = next((p for p in personas if "business" in p.role.lower()), None)

        assert business_user is not None, "Must include business user persona"
        assert business_user.technical_proficiency == TechnicalProficiency.NOVICE, \
            "Business user should be technical novice"
        assert len(business_user.primary_goals) >= 2, \
            "Business user must have at least 2 primary goals"
        assert len(business_user.pain_points) >= 2, \
            "Business user must have at least 2 pain points identified"
        assert "podcast" in " ".join(business_user.primary_goals).lower(), \
            "Business user goals must relate to podcast production"

    def test_content_creator_persona_requirements(self):
        """Test content creator persona meets specification requirements"""
        from user_personas import get_user_personas

        personas = get_user_personas()
        content_creator = next((p for p in personas if "content" in p.role.lower() or "creator" in p.role.lower()), None)

        assert content_creator is not None, "Must include content creator persona"
        assert content_creator.technical_proficiency in [TechnicalProficiency.NOVICE, TechnicalProficiency.BASIC], \
            "Content creator should be novice or basic technical proficiency"
        assert len(content_creator.primary_goals) >= 2, \
            "Content creator must have at least 2 primary goals"
        assert "content" in " ".join(content_creator.primary_goals).lower(), \
            "Content creator goals must relate to content creation"

    def test_manager_persona_requirements(self):
        """Test manager persona meets specification requirements"""
        from user_personas import get_user_personas

        personas = get_user_personas()
        manager = next((p for p in personas if "manager" in p.role.lower()), None)

        assert manager is not None, "Must include manager persona"
        assert manager.technical_proficiency in [TechnicalProficiency.BASIC, TechnicalProficiency.INTERMEDIATE], \
            "Manager should be basic or intermediate technical proficiency"
        assert len(manager.primary_goals) >= 2, \
            "Manager must have at least 2 primary goals"
        assert any(goal for goal in manager.primary_goals if "team" in goal.lower() or "efficiency" in goal.lower()), \
            "Manager goals must include team or efficiency concerns"

    def test_personas_have_complete_attributes(self):
        """Test all personas have complete required attributes"""
        from user_personas import get_user_personas

        personas = get_user_personas()

        for persona in personas:
            assert persona.name, f"Persona must have non-empty name: {persona}"
            assert persona.role, f"Persona must have defined role: {persona.name}"
            assert isinstance(persona.technical_proficiency, TechnicalProficiency), \
                f"Persona must have valid technical proficiency: {persona.name}"
            assert len(persona.primary_goals) >= 2, \
                f"Persona must have at least 2 primary goals: {persona.name}"
            assert len(persona.pain_points) >= 2, \
                f"Persona must have at least 2 pain points: {persona.name}"
            assert len(persona.success_criteria) >= 1, \
                f"Persona must have success criteria: {persona.name}"
            assert persona.time_constraints, \
                f"Persona must have time constraints defined: {persona.name}"
            assert persona.context, \
                f"Persona must have context description: {persona.name}"

    def test_personas_address_15_minute_onboarding_goal(self):
        """Test personas consider 15-minute onboarding success target"""
        from user_personas import get_user_personas

        personas = get_user_personas()

        # At least one persona should have 15-minute related success criteria
        has_time_success_criteria = False
        for persona in personas:
            success_text = " ".join(persona.success_criteria).lower()
            if "15" in success_text or "minute" in success_text or "quick" in success_text:
                has_time_success_criteria = True
                break

        assert has_time_success_criteria, \
            "At least one persona must have time-related success criteria for 15-minute onboarding goal"

    def test_personas_cover_different_technical_proficiency_levels(self):
        """Test personas cover diverse technical proficiency levels"""
        from user_personas import get_user_personas

        personas = get_user_personas()
        proficiency_levels = [p.technical_proficiency for p in personas]

        # Should cover at least 2 different proficiency levels
        unique_levels = set(proficiency_levels)
        assert len(unique_levels) >= 2, \
            "Personas must cover at least 2 different technical proficiency levels"

        # Should include at least one novice (critical for non-technical onboarding)
        assert TechnicalProficiency.NOVICE in proficiency_levels, \
            "Must include at least one novice-level persona for non-technical onboarding"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
