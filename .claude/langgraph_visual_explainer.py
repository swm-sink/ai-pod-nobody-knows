#!/usr/bin/env python3
"""
LangGraph Visual Explanation System
Creates visual explanations of LangGraph architecture using "Map Navigator" analogy
for non-technical users to understand AI workflow orchestration.

Targets ≥80% comprehension for non-technical users through:
- Map Navigator analogy system
- Visual workflow diagrams for all 5 pipeline stages
- Interactive learning checkpoints
- Comprehension assessment and validation
"""

from typing import Dict, List, Any, Optional
from dataclasses import dataclass


@dataclass
class WorkflowStage:
    """Represents a single stage in the LangGraph workflow with visual explanation."""
    name: str
    description: str
    analogy_explanation: str
    visual_diagram: str
    learning_checkpoint: Dict[str, str]


class LangGraphVisualExplainer:
    """
    Main class for explaining LangGraph architecture using visual analogies.
    Uses "Map Navigator" metaphor to make complex AI workflows understandable.
    """

    def __init__(self):
        """Initialize the visual explainer with all 5 workflow stages."""
        self.workflow_stages = self._create_workflow_stages()

    def _create_workflow_stages(self) -> List[WorkflowStage]:
        """Create all 5 workflow stages with Map Navigator analogies."""
        stages = []

        # Stage 0: Research Discovery
        stages.append(WorkflowStage(
            name="Research Discovery",
            description="Finding and planning what information we need to gather",
            analogy_explanation=(
                "Think of this like planning a road trip to somewhere you've never been. "
                "Before you start driving, you need to understand where you want to go and "
                "what routes might get you there. A smart traveler looks at different maps, "
                "asks locals for advice, and figures out the best places to stop for information. "
                "In our podcast system, this step is like being a research detective - we figure out "
                "what questions to ask, where to find the best experts, and how to gather "
                "the most interesting information about our topic."
            ),
            visual_diagram=(
                "Visual: A traveler at a crossroads with multiple signposts pointing to different "
                "destinations. The traveler holds a compass (representing research strategy) and "
                "has a backpack full of tools (research methods). Speech bubbles show questions "
                "like 'Which path leads to the best information?' and 'Who are the expert guides?' "
                "Arrows flow from the traveler to various information sources like libraries, "
                "expert interviews, and research databases."
            ),
            learning_checkpoint={
                'question': "If you were planning to research 'Why do we dream?', what would be your first step?",
                'expected_answer': "Figure out what questions to ask and find expert sources",
                'feedback': "Great! Just like a traveler planning routes, research starts with planning your information journey."
            }
        ))

        # Stage 1: Research Deep Dive
        stages.append(WorkflowStage(
            name="Research Deep Dive",
            description="Actually gathering detailed information from expert sources",
            analogy_explanation=(
                "Now you're on the road, following your planned route and stopping at the best "
                "information spots you identified. Like a traveler who stops at scenic overlooks "
                "to take photos and talk to local experts, this step involves actually collecting "
                "all the detailed information. You visit multiple sources - like stopping at "
                "different towns along your route - to get a complete picture. Each workflow node "
                "processes information like a specialized guide, with edges connecting different "
                "research stations, while our state preserves all discoveries. Some stops give you "
                "amazing insights, others confirm what you already knew, and sometimes you discover "
                "completely unexpected information that changes your whole understanding of the topic. "
                "The workflow automatically saves checkpoints so you can resume your research journey "
                "if anything goes wrong."
            ),
            visual_diagram=(
                "Visual: A traveler moving along a winding path with multiple stops - each stop "
                "represents a different expert source. At each stop, there are information kiosks "
                "showing expert quotes, research findings, and interesting facts. The traveler "
                "collects items (representing knowledge) in a growing backpack. Some paths connect "
                "different stops, showing how information from one source leads to discoveries at another."
            ),
            learning_checkpoint={
                'question': "Why is it important to visit multiple 'information stops' rather than just one?",
                'expected_answer': "To get a complete picture and avoid missing important perspectives",
                'feedback': "Exactly! Like visiting multiple towns on a trip, multiple sources give you the full story."
            }
        ))

        # Stage 2: Research Validation
        stages.append(WorkflowStage(
            name="Research Validation",
            description="Checking that our information is accurate and reliable",
            analogy_explanation=(
                "This is like double-checking your route with multiple maps and asking different "
                "people if you're heading in the right direction. Smart travelers don't just trust "
                "one source - they verify important information by checking with multiple reliable "
                "guides. If three different local experts tell you the same thing about the best "
                "route to take, you can be confident in that direction. In research, this means "
                "making sure our facts are correct by checking them against multiple trustworthy sources "
                "and looking for any contradictions or mistakes that might have crept in."
            ),
            visual_diagram=(
                "Visual: A traveler at a checkpoint with multiple validation stations. Each station "
                "has a different expert (scientist, historian, local guide) holding up verification "
                "stamps. The traveler's collected information flows through fact-checking filters, "
                "with green checkmarks for verified facts and red X marks for questionable information. "
                "A 'reliability meter' shows the trustworthiness score of each piece of information."
            ),
            learning_checkpoint={
                'question': "What should you do if two expert sources give you conflicting information?",
                'expected_answer': "Check with additional sources and document the disagreement",
                'feedback': "Perfect! Like getting a third opinion on directions, more sources help resolve conflicts."
            }
        ))

        # Stage 3: Research Synthesis
        stages.append(WorkflowStage(
            name="Research Synthesis",
            description="Organizing all our verified information into a clear, complete story",
            analogy_explanation=(
                "After your journey, you sit down with all your photos, notes, and souvenirs to "
                "create a beautiful travel album that tells the complete story of your trip. Like a "
                "navigator organizing their maps and route notes, you organize everything in the right "
                "order, connect related experiences, and present it in a way that helps others understand "
                "your amazing adventure. The synthesis nodes work like expert storytellers, connected "
                "by edges that route information through organization and narrative flow steps, while "
                "our state holds all the story elements. You highlight the most interesting discoveries, "
                "explain how different pieces fit together, and create a narrative that flows from "
                "beginning to end. The workflow ensures smooth transitions between organizing, connecting, "
                "and structuring phases with automatic checkpoints."
            ),
            visual_diagram=(
                "Visual: A traveler at a large organizing table with all their collected information "
                "spread out. They're arranging pieces into a flowing storyboard - connecting related "
                "facts with lines, grouping similar topics together, and creating a logical sequence. "
                "The final product shows a beautiful, organized display that flows from left to right, "
                "with the most important insights highlighted and everything connected in a clear narrative."
            ),
            learning_checkpoint={
                'question': "Why do we organize information instead of just sharing everything we collected?",
                'expected_answer': "To create a clear, understandable story that flows logically",
                'feedback': "Excellent! Like organizing photos in an album, structure helps people follow and understand the story."
            }
        ))

        # Stage 4: Script Generation
        stages.append(WorkflowStage(
            name="Script Generation",
            description="Creating the final podcast script that shares our story",
            analogy_explanation=(
                "This is like creating the final guidebook for other travelers who want to take a "
                "similar journey. You take your beautifully organized travel story and turn it into "
                "a practical route guide that others can follow. You write clear navigation directions, "
                "highlight the most interesting stops, include helpful tips from experts you met, and "
                "structure everything so future travelers can have their own amazing adventure. Like a "
                "master navigator creating the perfect map, the script generation nodes work through the "
                "workflow with edges connecting writing, editing, and polishing steps, while our state "
                "holds the evolving script. The guidebook isn't just a list of facts - it's an engaging "
                "story that makes people excited to explore and discover for themselves, with automatic "
                "checkpoints preserving each version, while celebrating both what we know and what "
                "mysteries still remain to be explored."
            ),
            visual_diagram=(
                "Visual: A traveler at a writing desk, transforming their organized storyboard into "
                "a beautiful guidebook. The desk shows the transformation process - research synthesis "
                "on the left flowing into script pages on the right. Speech bubbles show engaging "
                "language being crafted, question marks represent mysteries to highlight, and a "
                "'curiosity meter' ensures the final script inspires others to explore and learn."
            ),
            learning_checkpoint={
                'question': "What makes a good guidebook different from just a collection of facts?",
                'expected_answer': "It tells an engaging story that inspires people to explore and learn",
                'feedback': "Wonderful! Like the best travel guides, great scripts make people excited about the journey of discovery."
            }
        ))

        return stages

    def assess_comprehension(self, user_response: str) -> float:
        """
        Assess user comprehension based on their response.
        Returns percentage score (0-100) using multi-factor assessment.
        """
        if not user_response or len(user_response.strip()) < 3:
            return 0.0

        response_lower = user_response.lower()
        score = 0.0

        # Factor 1: Engagement level (30 points)
        score += self._assess_engagement_level(response_lower)

        # Factor 2: Concept understanding (40 points)
        score += self._assess_concept_understanding(response_lower)

        # Factor 3: Analogy comprehension (20 points)
        score += self._assess_analogy_comprehension(response_lower)

        # Factor 4: Reasoning quality (10 points)
        score += self._assess_reasoning_quality(response_lower)

        return min(score, 100.0)

    def _assess_engagement_level(self, response_lower: str) -> float:
        """Assess level of user engagement based on response depth."""
        if len(response_lower) > 50:
            return 30.0
        elif len(response_lower) > 20:
            return 20.0
        elif len(response_lower) > 10:
            return 10.0
        return 0.0

    def _assess_concept_understanding(self, response_lower: str) -> float:
        """Assess understanding of core research workflow concepts."""
        understanding_keywords = [
            'plan', 'gather', 'check', 'organize', 'share',
            'information', 'source', 'expert', 'story', 'journey'
        ]
        keyword_matches = sum(1 for keyword in understanding_keywords if keyword in response_lower)
        return min(keyword_matches * 4, 40.0)

    def _assess_analogy_comprehension(self, response_lower: str) -> float:
        """Assess comprehension of travel/navigation analogies."""
        analogy_keywords = ['like', 'similar', 'travel', 'map', 'route', 'journey', 'guide']
        analogy_matches = sum(1 for keyword in analogy_keywords if keyword in response_lower)
        return min(analogy_matches * 3, 20.0)

    def _assess_reasoning_quality(self, response_lower: str) -> float:
        """Assess quality of reasoning in user response."""
        reasoning_indicators = ['because', 'so that', 'in order to', 'this helps', 'therefore']
        if any(phrase in response_lower for phrase in reasoning_indicators):
            return 10.0
        return 0.0

    def validate_comprehension_target(self, user_scores: Dict[str, float]) -> float:
        """
        Validate that comprehension target of ≥80% is achieved.
        Returns average comprehension score.
        """
        if not user_scores:
            return 0.0

        total_scores = sum(user_scores.values())
        average_score = total_scores / len(user_scores)
        return average_score

    def get_complete_visual_explanation(self) -> Dict[str, Any]:
        """
        Get complete visual explanation system for LangGraph architecture.
        Returns comprehensive explanation package for non-technical users.
        """
        return {
            'introduction': (
                "Welcome to understanding how AI creates podcasts! Think of this like learning "
                "how a GPS navigation system plans and executes a perfect road trip. Our AI "
                "workflow is like a smart navigator that knows how to research any topic, "
                "organize information, and create engaging content automatically."
            ),
            'map_navigator_analogy': get_map_navigator_analogy(),
            'workflow_stages': [
                {
                    'stage_id': i,
                    'stage_info': stage,
                    'visual_diagram': get_visual_workflow_diagram(i),
                    'learning_checkpoint': create_interactive_learning_checkpoint(i)
                }
                for i, stage in enumerate(self.workflow_stages)
            ],
            'comprehension_target': 80,
            'next_steps': (
                "Ready to try it yourself? Start with our 15-minute getting started guide "
                "to create your first AI-powered podcast episode!"
            )
        }


def get_map_navigator_analogy() -> Dict[str, str]:
    """
    Get the complete Map Navigator analogy system.
    Maps travel concepts to LangGraph concepts.
    """
    return {
        'destination': (
            "Your destination is the final podcast episode - a complete, engaging story "
            "that helps people understand a fascinating topic while celebrating the joy of learning."
        ),
        'route_planning': (
            "Route planning is like research strategy - figuring out the best path to gather "
            "information, identifying the most reliable expert sources, and planning how to "
            "verify everything you discover along the way."
        ),
        'navigation_tools': (
            "Your navigation tools are the AI agents - specialized helpers that excel at "
            "different parts of the journey, like one agent that's great at finding experts, "
            "another that's excellent at fact-checking, and another that creates engaging stories."
        ),
        'checkpoints': (
            "Checkpoints are places where you can pause, save your progress, and make sure "
            "you're still on the right track. If something goes wrong, you can return to your "
            "last checkpoint and try a different approach without losing all your work."
        ),
        'arrival': (
            "Arrival is when you have a complete, high-quality podcast episode that tells an "
            "engaging story, shares fascinating insights from experts, and inspires listeners "
            "to appreciate both what we know and what we're still discovering."
        )
    }


def get_visual_workflow_diagram(stage_id: int) -> str:
    """
    Generate a visual workflow diagram description for a specific stage.
    """
    if stage_id == 0:
        return (
            "Workflow starts with a 'Planning Hub' where multiple information paths branch out. "
            "Decision diamonds ask 'What questions need answers?' and 'Where are the best sources?' "
            "Arrows lead to research strategy boxes, expert identification circles, and source "
            "validation checkpoints. The flow converges into a 'Research Plan Ready' end state."
        )
    elif stage_id == 1:
        return (
            "Process flows from 'Research Plan' through parallel execution paths for different "
            "information sources. Each path has collection boxes for 'Expert Interviews', "
            "'Academic Sources', and 'Field Research'. Arrows merge collected information into "
            "a 'Comprehensive Information Repository' with quality indicators and completeness meters."
        )
    elif stage_id == 2:
        return (
            "Information flows through multiple validation gates - 'Source Credibility Check', "
            "'Cross-Reference Verification', and 'Fact Accuracy Review'. Each gate has approval "
            "decision diamonds with green (pass) and red (review) paths. Validated information "
            "flows to 'Verified Knowledge Base' while questionable items loop back for additional checking."
        )
    elif stage_id == 3:
        return (
            "Verified information enters an 'Organization Engine' with sorting and connection processes. "
            "Related facts group together, themes emerge, and narrative threads connect different "
            "elements. The flow shows information being structured into logical sequences, with "
            "priority ranking and story arc development leading to 'Organized Research Synthesis'."
        )
    elif stage_id == 4:
        return (
            "Organized synthesis flows into 'Script Creation Engine' with multiple processing stages - "
            "'Engaging Language Generation', 'Curiosity Enhancement', and 'Brand Voice Integration'. "
            "The workflow shows quality checks for readability, engagement scoring, and brand consistency. "
            "Final output flows to 'Complete Podcast Script' ready for audio production."
        )
    else:
        return "Invalid stage ID. Valid stages are 0-4."


def create_interactive_learning_checkpoint(stage_id: int) -> Dict[str, str]:
    """
    Create an interactive learning checkpoint for a specific workflow stage.
    """
    if stage_id == 0:
        return {
            'scenario': (
                "Imagine you want to create a podcast episode about 'Why do cats purr?' "
                "You're standing at the starting point of your research journey."
            ),
            'task': (
                "Your task is to plan your research route. What would be your first three steps "
                "to ensure you gather the most interesting and accurate information?"
            ),
            'validation': (
                "Good planning includes: identifying key questions to answer, finding expert sources "
                "(like veterinarians or animal behavior researchers), and planning how to verify "
                "the information you collect."
            ),
            'success_criteria': (
                "Success means having a clear research strategy that identifies what to learn, "
                "where to learn it, and how to make sure it's accurate."
            )
        }
    elif stage_id == 1:
        return {
            'scenario': (
                "Imagine you're now on your research journey, following your plan to gather information "
                "about why cats purr. You have multiple 'stops' to visit for information."
            ),
            'task': (
                "At each information stop, you need to collect detailed insights. If you visit "
                "a veterinary research center, what specific questions would you ask to get "
                "the most complete picture?"
            ),
            'validation': (
                "Great information gathering includes asking about the physical mechanism of purring, "
                "different reasons cats purr, recent research discoveries, and what questions "
                "scientists are still trying to answer."
            ),
            'success_criteria': (
                "Success means collecting comprehensive, detailed information from multiple "
                "expert sources that gives you a complete understanding of the topic."
            )
        }
    elif stage_id == 2:
        return {
            'scenario': (
                "Imagine you've collected lots of information about cat purring from different sources. "
                "Now you're at the 'verification checkpoint' to make sure everything is accurate."
            ),
            'task': (
                "You notice that two different sources give slightly different explanations "
                "for how purring works physically. How would you resolve this discrepancy?"
            ),
            'validation': (
                "Good verification means checking with additional authoritative sources, looking "
                "for the most recent research, and documenting where experts disagree rather "
                "than ignoring conflicting information."
            ),
            'success_criteria': (
                "Success means having verified, trustworthy information where conflicts are "
                "resolved or acknowledged, and questionable claims are either confirmed or removed."
            )
        }
    elif stage_id == 3:
        return {
            'scenario': (
                "Imagine you have a collection of verified facts about cat purring spread out like "
                "photos from your research journey. Now you need to organize them into a clear story."
            ),
            'task': (
                "How would you organize your verified information to create a logical, engaging "
                "flow that takes listeners on a discovery journey from basic understanding to "
                "fascinating insights?"
            ),
            'validation': (
                "Good organization starts with basics (what is purring), moves through mechanisms "
                "(how it works), explores purposes (why cats do it), and ends with ongoing "
                "mysteries (what we're still learning)."
            ),
            'success_criteria': (
                "Success means having a logical narrative structure that builds understanding "
                "progressively and connects related concepts in an engaging flow."
            )
        }
    elif stage_id == 4:
        return {
            'scenario': (
                "Imagine you're ready to create the final podcast script - like writing the ultimate "
                "guidebook for others who want to understand the fascinating world of cat purring."
            ),
            'task': (
                "How would you transform your organized research into script language that makes "
                "people excited to learn while acknowledging both what we know and what remains mysterious?"
            ),
            'validation': (
                "Great scripts use engaging storytelling, include expert quotes, ask thought-provoking "
                "questions, celebrate discoveries, and honestly acknowledge what we still don't understand."
            ),
            'success_criteria': (
                "Success means creating a script that educates, entertains, and inspires curiosity "
                "while maintaining intellectual humility about the limits of current knowledge."
            )
        }
    else:
        return {
            'scenario': "Invalid stage ID",
            'task': "Please specify a valid stage (0-4)",
            'validation': "Valid stages are 0-4 corresponding to the 5 workflow stages",
            'success_criteria': "Use stage IDs 0-4 for proper checkpoint creation"
        }
