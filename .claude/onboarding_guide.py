"""
Non-Technical Getting Started Guide for AI Podcast Production System
Implementation for Task DOC-002: Write Non-Technical Getting Started Guide

Based on research findings for progressive disclosure and 15-minute onboarding success.
Target: 8th-grade reading level, <15 minute completion, >80% success rate.
"""

from typing import Dict, List, Any


def get_onboarding_guide() -> Dict[str, Any]:
    """
    Get the complete non-technical getting started guide.

    Designed for business users, content creators, and managers with
    minimal technical background. Follows progressive disclosure principles
    with clear success validation at each step.

    Returns:
        Dict[str, Any]: Complete onboarding guide with all required sections
    """

    return {
        "title": "Start Creating AI Podcasts in 15 Minutes - Simple Setup Guide",

        "introduction": """
        Welcome! This guide helps you start creating professional podcast content in just 15 minutes.

        Our AI podcast system automatically researches topics, writes scripts, and creates audio content
        for you. Instead of spending hours writing and producing, you can create quality podcast episodes
        in minutes at a fraction of traditional costs ($5.51 per episode vs $800-3500 traditional methods).

        No technical experience needed - just follow these simple steps to get your first episode running.
        This quick guide gets you from initial setup to your first completed podcast draft fast.
        """,

        "prerequisites": [
            "A computer with internet connection",
            "Basic email and web browsing skills",
            "About 15 minutes of focused time",
            "A topic idea for your first podcast episode"
        ],

        "steps": [
            {
                "step_number": 1,
                "title": "Welcome Setup Overview",
                "description": "This helps you understand what the system does and confirms everything is working before we start creating content.",
                "actions": [
                    "Open the AI Podcast System in your web browser",
                    "Select 'Health Check' to make sure everything is connected",
                    "Check for green checkmarks showing the system is ready"
                ],
                "success_check": "You see green checkmarks and 'System Healthy' message displays on your screen"
            },

            {
                "step_number": 2,
                "title": "Create Your First Topic",
                "description": "This enables the system to research and create content specifically about something you find interesting.",
                "actions": [
                    "Select 'Create New Episode' button",
                    "Enter a topic you're curious about (examples: 'Why do we dream?' or 'How do birds migrate?')",
                    "Press 'Start Research' to begin the automated process"
                ],
                "success_check": "The system shows 'Research Starting' and displays a progress indicator moving forward"
            },

            {
                "step_number": 3,
                "title": "Check Automated Research",
                "description": "This allows you to see how the AI finds expert information and fact-checks content automatically.",
                "actions": [
                    "Watch the research progress bar fill up (takes 3-5 minutes)",
                    "See research results appear showing sources and key facts",
                    "Select 'Review Research' to see what information was found"
                ],
                "success_check": "Research section shows completed with sources listed and 'Research Complete' appears"
            },

            {
                "step_number": 4,
                "title": "Generate Script Draft",
                "description": "This creates your podcast script automatically based on the research, saving you hours of writing time.",
                "actions": [
                    "Press 'Create Script' button to start writing",
                    "Wait for the script generation (takes 2-4 minutes)",
                    "Select 'Preview Script' to read your generated content"
                ],
                "success_check": "Full script text appears in the preview window with introduction, main content, and conclusion sections"
            },

            {
                "step_number": 5,
                "title": "Check Content Quality",
                "description": "This ensures your podcast meets high standards and sounds professional before creating audio.",
                "actions": [
                    "Select 'Quality Check' to validate your content",
                    "Review the quality score (should be 8.0 or higher)",
                    "Look at any suggestions for improvements if provided"
                ],
                "success_check": "Quality score shows 8.0+ and 'Content Approved for Audio' message displays"
            },

            {
                "step_number": 6,
                "title": "Create Audio Preview",
                "description": "This turns your script into spoken audio so you can hear how your podcast will sound.",
                "actions": [
                    "Select 'Generate Audio Preview' button",
                    "Wait for audio creation (takes 3-5 minutes)",
                    "Press play button to listen to your podcast"
                ],
                "success_check": "Audio player appears with your podcast and plays clear, professional-sounding content when pressed"
            },

            {
                "step_number": 7,
                "title": "Validate Your Success",
                "description": "This confirms everything worked correctly and your first episode is complete and ready to use.",
                "actions": [
                    "Check that total cost is under $6.00 (shown in cost tracker)",
                    "Save your episode by selecting 'Save Complete Episode'",
                    "Go to 'My Episodes' to see your finished content"
                ],
                "success_check": "Episode appears in 'My Episodes' list with complete status and download options available"
            }
        ],

        "success_validation": {
            "completion_criteria": [
                "Episode appears in your episodes list",
                "Audio file plays properly",
                "Script content makes sense and is well-written",
                "Total cost is under $6.00",
                "Quality score is 8.0 or higher"
            ],
            "time_target": "Completed in 15 minutes or less",
            "next_milestone": "Create your second episode in under 10 minutes"
        },

        "troubleshooting": [
            {
                "problem": "Health check shows red X marks or error message",
                "solution": "Wait 2 minutes and refresh the page. If still not working, check your internet connection is stable and try again."
            },
            {
                "problem": "System says 'access key error' or connection problems",
                "solution": "Contact your system administrator or the person who set up your access. This usually means login credentials need to be refreshed."
            },
            {
                "problem": "Research doesn't start or stays at 0%",
                "solution": "Try a different topic that's more specific (like 'Why do cats purr?' instead of 'cats'). Make sure your topic is a question or clear subject."
            },
            {
                "problem": "Script generation fails or produces nonsense",
                "solution": "Go back and check that research completed successfully first. If research looks good, try clicking 'Create Script' again - sometimes it takes a second try."
            },
            {
                "problem": "Nothing happens when I click buttons",
                "solution": "Refresh your browser page and start over. Make sure you have a stable internet connection and try using Chrome or Firefox browsers."
            },
            {
                "problem": "Audio doesn't play or sounds garbled",
                "solution": "Check your computer speakers are working with other audio first. If other audio works, try generating the audio preview again."
            }
        ],

        "next_steps": [
            "Create your second episode with a different topic to get comfortable with the process",
            "Try editing the generated script before creating audio to customize the content",
            "Explore the episode library to see what topics work best for your audience",
            "Set up a regular schedule like creating 2 episodes per week once you're comfortable",
            "Share your first episode with colleagues to get feedback and improve your topic choices"
        ]
    }


def get_guide_metadata() -> Dict[str, Any]:
    """Get metadata about the onboarding guide for validation and tracking"""
    guide = get_onboarding_guide()

    return {
        "total_steps": len(guide["steps"]),
        "estimated_completion_time": "15 minutes",
        "reading_level": "8th grade",
        "target_success_rate": "80%",
        "technical_terms_count": count_technical_terms(guide),
        "prerequisite_count": len(guide["prerequisites"]),
        "troubleshooting_issues": len(guide["troubleshooting"])
    }


def count_technical_terms(guide: Dict[str, Any]) -> int:
    """Count technical terms in the guide content"""
    technical_terms = ["api", "langgraph", "yaml", "json", "endpoint", "cli", "configuration"]

    all_text = " ".join([
        guide["introduction"],
        " ".join([step.get("description", "") for step in guide["steps"]]),
        " ".join([" ".join(step.get("actions", [])) for step in guide["steps"]])
    ]).lower()

    return sum(all_text.count(term) for term in technical_terms)


def validate_guide_requirements() -> Dict[str, bool]:
    """Validate that guide meets all requirements from user research"""
    guide = get_onboarding_guide()

    return {
        "has_15_minute_mention": "15 minutes" in guide["title"] or "15 minutes" in guide["introduction"],
        "minimal_prerequisites": len(guide["prerequisites"]) <= 5,
        "optimal_step_count": 3 <= len(guide["steps"]) <= 8,
        "covers_troubleshooting": len(guide["troubleshooting"]) >= 3,
        "provides_next_steps": len(guide["next_steps"]) >= 2,
        "avoids_programming_requirements": not any("programming" in p.lower() for p in guide["prerequisites"]),
        "includes_success_validation": all(step.get("success_check") for step in guide["steps"]),
        "mentions_episode_creation": any("episode" in step.lower() for step in guide["next_steps"])
    }


if __name__ == "__main__":
    """Quick validation when run directly"""
    guide = get_onboarding_guide()
    metadata = get_guide_metadata()
    requirements = validate_guide_requirements()

    print("Non-Technical Onboarding Guide Created")
    print(f"Title: {guide['title']}")
    print(f"Steps: {metadata['total_steps']}")
    print(f"Estimated time: {metadata['estimated_completion_time']}")
    print(f"Prerequisites: {metadata['prerequisite_count']}")
    print(f"Troubleshooting items: {metadata['troubleshooting_issues']}")
    print(f"Technical terms: {metadata['technical_terms_count']}")

    print("\nRequirements validation:")
    for requirement, met in requirements.items():
        status = "✅" if met else "❌"
        print(f"  {status} {requirement}")

    if all(requirements.values()):
        print("\n✅ All requirements met - Guide ready for user testing!")
    else:
        print("\n❌ Some requirements not met - Review and adjust")
