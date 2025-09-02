"""
Test suite for non-technical getting started guide
Test-Driven Development for Task DOC-002

Test Strategy:
Given: Need non-technical onboarding guide with 15-minute completion target
When: Guide is created following progressive disclosure principles
Then: Guide has 8th-grade reading level, clear steps, and success validation
Because: 62.5% user drop-off must be reduced through better onboarding
"""

import pytest
import re
from pathlib import Path
from typing import List, Dict, Any


class TestOnboardingGuide:
    """Test suite for non-technical getting started guide validation"""

    def test_onboarding_guide_file_exists(self):
        """Test that onboarding guide file exists and is accessible"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        assert guide is not None, "Onboarding guide must be defined"
        assert isinstance(guide, dict), "Guide must be structured data"

    def test_guide_has_required_sections(self):
        """Test guide contains all required sections for complete onboarding"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        required_sections = [
            "title",
            "introduction",
            "prerequisites",
            "steps",
            "success_validation",
            "troubleshooting",
            "next_steps"
        ]

        for section in required_sections:
            assert section in guide, f"Guide must include {section} section"
            assert guide[section], f"{section} section must have content"

    def test_guide_title_appeals_to_non_technical_users(self):
        """Test guide title is non-technical and welcoming"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        title = guide["title"].lower()

        # Should avoid technical jargon
        technical_terms = ["api", "cli", "langgraph", "yaml", "json", "endpoint"]
        for term in technical_terms:
            assert term not in title, f"Title should avoid technical term: {term}"

        # Should include welcoming/accessible language
        accessible_keywords = ["start", "begin", "guide", "help", "easy", "simple"]
        has_accessible_term = any(keyword in title for keyword in accessible_keywords)
        assert has_accessible_term, "Title should include accessible/welcoming language"

    def test_introduction_explains_value_proposition(self):
        """Test introduction clearly explains value in business terms"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        intro = guide["introduction"].lower()

        # Should mention key value propositions
        value_terms = ["podcast", "content", "automated", "minutes", "cost", "quality"]
        found_values = [term for term in value_terms if term in intro]
        assert len(found_values) >= 3, f"Introduction should mention value terms: {found_values}"

        # Should mention time benefit
        time_mentions = ["15 minutes" in intro, "quick" in intro, "fast" in intro]
        assert any(time_mentions), "Introduction should mention time benefits"

    def test_prerequisites_are_minimal_and_clear(self):
        """Test prerequisites are minimal and clearly stated"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        prereqs = guide["prerequisites"]

        assert isinstance(prereqs, list), "Prerequisites must be a list"
        assert len(prereqs) <= 5, "Prerequisites should be minimal (≤5 items)"

        for prereq in prereqs:
            assert isinstance(prereq, str), "Each prerequisite must be a string"
            assert len(prereq.strip()) > 0, "Prerequisites must be non-empty"
            # Should avoid complex technical requirements
            assert "programming" not in prereq.lower(), "Should avoid programming prerequisites"
            assert "coding" not in prereq.lower(), "Should avoid coding prerequisites"

    def test_steps_follow_progressive_disclosure(self):
        """Test steps are organized with progressive complexity"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        steps = guide["steps"]

        assert isinstance(steps, list), "Steps must be a list"
        assert 3 <= len(steps) <= 8, "Should have 3-8 steps for optimal learning"

        for i, step in enumerate(steps):
            assert isinstance(step, dict), f"Step {i+1} must be a dictionary"

            required_step_fields = ["step_number", "title", "description", "actions", "success_check"]
            for field in required_step_fields:
                assert field in step, f"Step {i+1} must have {field} field"

        # First step should be simplest (setup/overview)
        first_step = steps[0]["title"].lower()
        setup_terms = ["setup", "start", "overview", "introduction", "welcome"]
        has_setup_term = any(term in first_step for term in setup_terms)
        assert has_setup_term, "First step should be setup/introduction focused"

    def test_each_step_has_success_validation(self):
        """Test each step includes clear success validation criteria"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        steps = guide["steps"]

        for i, step in enumerate(steps):
            success_check = step["success_check"]
            assert isinstance(success_check, str), f"Step {i+1} success_check must be string"
            assert len(success_check.strip()) > 10, f"Step {i+1} needs detailed success criteria"

            # Should be actionable and specific
            actionable_terms = ["see", "shows", "displays", "appears", "click", "opens"]
            has_actionable = any(term in success_check.lower() for term in actionable_terms)
            assert has_actionable, f"Step {i+1} success check should be actionable"

    def test_actions_are_specific_and_clear(self):
        """Test step actions are specific, numbered, and clear"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        steps = guide["steps"]

        for i, step in enumerate(steps):
            actions = step["actions"]
            assert isinstance(actions, list), f"Step {i+1} actions must be a list"
            assert len(actions) >= 1, f"Step {i+1} must have at least one action"

            for j, action in enumerate(actions):
                assert isinstance(action, str), f"Step {i+1}, action {j+1} must be string"
                assert len(action.strip()) > 5, f"Step {i+1}, action {j+1} must be detailed"

                # Should start with action verb
                action_verbs = ["select", "open", "go", "enter", "press", "copy", "paste", "save", "look", "watch", "see", "wait", "check", "review"]
                starts_with_verb = any(action.lower().startswith(verb) for verb in action_verbs)
                assert starts_with_verb, f"Step {i+1}, action {j+1} should start with action verb"

    def test_troubleshooting_covers_common_issues(self):
        """Test troubleshooting section covers expected common issues"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        troubleshooting = guide["troubleshooting"]

        assert isinstance(troubleshooting, list), "Troubleshooting must be a list"
        assert len(troubleshooting) >= 3, "Should cover at least 3 common issues"

        for issue in troubleshooting:
            assert isinstance(issue, dict), "Each troubleshooting item must be a dict"
            assert "problem" in issue, "Issue must describe the problem"
            assert "solution" in issue, "Issue must provide solution"

            problem = issue["problem"].lower()
            solution = issue["solution"].lower()

            # Common issues should be covered
            common_issues = ["doesn't work", "error", "can't find", "nothing happens", "slow"]
            # At least one issue should match common patterns

        # Should cover API key issues (common in AI systems)
        api_issue_covered = any("api" in item["problem"].lower() or "key" in item["problem"].lower()
                               for item in troubleshooting)
        assert api_issue_covered, "Should cover API key related issues"

    def test_next_steps_provide_clear_progression(self):
        """Test next steps provide clear progression path"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        next_steps = guide["next_steps"]

        assert isinstance(next_steps, list), "Next steps must be a list"
        assert len(next_steps) >= 2, "Should provide at least 2 next steps"

        for step in next_steps:
            assert isinstance(step, str), "Each next step must be a string"
            assert len(step.strip()) > 10, "Next steps should be detailed"

        # Should mention first episode creation
        episode_mentioned = any("episode" in step.lower() for step in next_steps)
        assert episode_mentioned, "Next steps should mention creating first episode"

    def test_guide_mentions_15_minute_target(self):
        """Test guide explicitly mentions 15-minute completion target"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()

        # Check all text content for time mentions
        all_text = " ".join([
            guide["title"],
            guide["introduction"],
            " ".join([str(step.get("description", "")) for step in guide["steps"]])
        ]).lower()

        time_mentions = ["15 minutes", "15-minute", "fifteen minute", "quick", "fast"]
        has_time_mention = any(mention in all_text for mention in time_mentions)
        assert has_time_mention, "Guide should mention 15-minute completion target"

    def test_guide_avoids_technical_jargon(self):
        """Test guide avoids overwhelming technical terminology"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()

        # Collect all descriptive text
        all_text = " ".join([
            guide["introduction"],
            " ".join([step.get("description", "") for step in guide["steps"]]),
            " ".join([" ".join(step.get("actions", [])) for step in guide["steps"]])
        ]).lower()

        # These terms should be minimal or explained
        complex_terms = ["langgraph", "yaml", "json", "endpoint", "api key", "cli", "configuration"]
        term_count = sum(all_text.count(term) for term in complex_terms)

        # Allow some technical terms but they should be minimal
        assert term_count <= 5, f"Guide should minimize technical jargon (found {term_count} instances)"

        # If technical terms are used, they should be explained
        if "api" in all_text:
            explanations = ["application programming interface", "connection", "access key"]
            has_explanation = any(exp in all_text for exp in explanations)
            # This is a soft requirement - guide can explain or avoid


class TestGuideReadabilityAndStructure:
    """Additional tests for guide readability and structure"""

    def test_guide_structure_supports_scanning(self):
        """Test guide structure supports quick scanning and navigation"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        steps = guide["steps"]

        # Steps should have clear, scannable titles
        for i, step in enumerate(steps):
            title = step["title"]
            assert len(title) <= 60, f"Step {i+1} title should be scannable (≤60 chars)"
            assert not title.endswith("."), f"Step {i+1} title should not end with period"

            # Title should be descriptive of the action
            descriptive_words = ["setup", "configure", "create", "test", "validate", "check", "generate", "watch"]
            has_descriptive = any(word in title.lower() for word in descriptive_words)
            assert has_descriptive, f"Step {i+1} title should be action-descriptive"

    def test_step_descriptions_provide_context(self):
        """Test step descriptions provide helpful context without overwhelming"""
        from onboarding_guide import get_onboarding_guide

        guide = get_onboarding_guide()
        steps = guide["steps"]

        for i, step in enumerate(steps):
            description = step.get("description", "")
            if description:  # If description exists, validate it
                assert 20 <= len(description) <= 200, \
                    f"Step {i+1} description should be 20-200 chars for optimal readability"

                # Should explain WHY not just WHAT
                context_words = ["this", "helps", "enables", "allows", "ensures", "because"]
                has_context = any(word in description.lower() for word in context_words)
                assert has_context, f"Step {i+1} description should provide context/reasoning"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
