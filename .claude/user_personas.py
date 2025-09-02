"""
User Personas for AI Podcast Production System
Implementation for Task UX-001: Define Non-Technical User Personas

Based on research findings for progressive disclosure and non-technical onboarding.
Target: 15-minute time-to-success for non-technical users.
"""

from dataclasses import dataclass
from enum import Enum
from typing import List


class TechnicalProficiency(Enum):
    """Technical proficiency levels for user personas"""
    NOVICE = "novice"        # No technical background
    BASIC = "basic"          # Some software usage experience
    INTERMEDIATE = "intermediate"  # Basic technical concepts


@dataclass
class UserPersona:
    """Data structure for user persona definition"""
    name: str
    role: str
    technical_proficiency: TechnicalProficiency
    primary_goals: List[str]
    pain_points: List[str]
    success_criteria: List[str]
    time_constraints: str
    context: str


def get_user_personas() -> List[UserPersona]:
    """
    Get the three core user personas for the AI Podcast Production System.

    Based on user research and progressive disclosure requirements:
    - Business User (Novice): Needs simple, business-focused explanations
    - Content Creator (Basic): Wants creative control with technical assistance
    - Manager (Intermediate): Requires team efficiency and oversight capabilities

    Returns:
        List[UserPersona]: Three distinct user personas with complete attributes
    """

    business_user = UserPersona(
        name="Sarah Chen",
        role="Business Stakeholder",
        technical_proficiency=TechnicalProficiency.NOVICE,
        primary_goals=[
            "Understand how AI podcast system creates business value",
            "Generate podcast content for marketing without technical complexity",
            "Evaluate system ROI and scalability for team adoption"
        ],
        pain_points=[
            "Technical documentation is overwhelming and incomprehensible",
            "Can't assess system capabilities without IT team involvement",
            "Unclear how AI system decisions impact content quality and brand"
        ],
        success_criteria=[
            "Can complete first podcast episode setup in under 15 minutes",
            "Understands system capabilities in business terms without technical jargon",
            "Can explain system value proposition to executive team"
        ],
        time_constraints="Has only 15-20 minutes for initial evaluation, needs immediate value demonstration",
        context="Senior marketing executive evaluating AI tools for content team. No coding background, focuses on business outcomes and team productivity."
    )

    content_creator = UserPersona(
        name="Alex Rodriguez",
        role="Content Creator",
        technical_proficiency=TechnicalProficiency.BASIC,
        primary_goals=[
            "Create high-quality podcast content efficiently with AI assistance",
            "Maintain creative control while leveraging automation",
            "Learn system capabilities to optimize content creation workflow"
        ],
        pain_points=[
            "System complexity interferes with creative flow",
            "Unclear how to customize AI output for specific content style",
            "Worried about losing creative control to automated systems"
        ],
        success_criteria=[
            "Can produce first episode draft within 30 minutes of quick onboarding",
            "Understands how to guide AI for desired content style",
            "Feels confident using system without constant technical support"
        ],
        time_constraints="Needs quick wins to integrate into existing content workflows, limited time for extensive learning",
        context="Independent podcast creator with basic tech skills. Uses various software tools but avoids complex technical setup. Values creative quality and efficiency."
    )

    manager = UserPersona(
        name="David Kim",
        role="Content Team Manager",
        technical_proficiency=TechnicalProficiency.INTERMEDIATE,
        primary_goals=[
            "Deploy system across team to improve content production efficiency",
            "Ensure team adoption and successful onboarding of all skill levels",
            "Monitor system performance and team productivity improvements"
        ],
        pain_points=[
            "Team members have different technical skill levels requiring varied support",
            "Difficult to assess system quality and consistency across team usage",
            "Unclear how to scale system usage and maintain content standards"
        ],
        success_criteria=[
            "Can onboard team members successfully with guided 15-minute process",
            "Has visibility into team usage patterns and content quality metrics",
            "Can troubleshoot common issues and optimize team efficiency"
        ],
        time_constraints="Needs efficient team rollout process, balancing thorough evaluation with rapid deployment",
        context="Manages content production team of 5-8 people with mixed technical abilities. Responsible for team productivity and content quality. Has moderate technical understanding."
    )

    return [business_user, content_creator, manager]


# Additional utility functions for persona analysis

def get_personas_by_proficiency(proficiency: TechnicalProficiency) -> List[UserPersona]:
    """Get personas filtered by technical proficiency level"""
    return [p for p in get_user_personas() if p.technical_proficiency == proficiency]


def get_primary_success_criteria() -> List[str]:
    """Get consolidated success criteria across all personas"""
    return [criterion for persona in get_user_personas()
            for criterion in persona.success_criteria]


def validate_15_minute_goal_alignment() -> bool:
    """Validate that personas align with 15-minute onboarding goal"""
    time_keywords = ["15", "minute", "quick"]

    for persona in get_user_personas():
        success_text = " ".join(persona.success_criteria).lower()
        if any(keyword in success_text for keyword in time_keywords):
            return True

    return False


def get_persona_summary() -> dict:
    """Get summary statistics of defined personas"""
    personas = get_user_personas()
    proficiency_counts = {}

    for persona in personas:
        proficiency = persona.technical_proficiency.value
        proficiency_counts[proficiency] = proficiency_counts.get(proficiency, 0) + 1

    return {
        "total_personas": len(personas),
        "proficiency_distribution": proficiency_counts,
        "fifteen_minute_aligned": validate_15_minute_goal_alignment(),
        "persona_roles": [persona.role for persona in personas]
    }


if __name__ == "__main__":
    """Quick validation when run directly"""
    personas = get_user_personas()
    print(f"Loaded {len(personas)} personas:")

    for persona in personas:
        print(f"\n{persona.name} ({persona.role})")
        print(f"  Technical Level: {persona.technical_proficiency.value}")
        print(f"  Primary Goals: {len(persona.primary_goals)} defined")
        print(f"  Pain Points: {len(persona.pain_points)} identified")
        print(f"  Success Criteria: {len(persona.success_criteria)} specified")

    print(f"\n15-minute goal alignment: {validate_15_minute_goal_alignment()}")
