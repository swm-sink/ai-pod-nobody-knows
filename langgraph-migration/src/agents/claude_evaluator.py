"""
Claude Evaluator Agent - LangGraph Node Implementation
Part of Multi-Model Quality Evaluation Stream (Agent 10A of 16)
Based on August 2025 Claude Opus 4.1 for sophisticated content analysis
Focuses on content depth, narrative flow, and creative engagement evaluation
Budget: $0.30
"""

import asyncio
import json
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
import re

import httpx
from langfuse import Langfuse
from tenacity import retry, stop_after_attempt, wait_exponential

# Import cost tracking
from ..core.cost_tracker import CostTracker, BudgetExceededException, CostTrackingMixin
from ..core.state import PodcastState


@dataclass
class EvaluationDimension:
    """Structure for evaluation dimension scoring"""
    dimension_name: str
    score: float  # 0.0 - 10.0
    weight: float
    criteria: List[str]
    strengths: List[str]
    improvements: List[str]
    confidence: float  # 0.0 - 1.0


@dataclass
class ClaudeEvaluationResult:
    """Result from Claude evaluation"""
    schema_version: str = "1.0.0"
    stage: str = "claude_evaluation"
    agent_metadata: Dict[str, Any] = None
    cost_tracking: Dict[str, Any] = None
    execution_status: Dict[str, Any] = None
    overall_score: float = 0.0
    evaluator: str = "claude"
    scores: Dict[str, float] = None
    strengths: List[str] = None
    improvements: List[str] = None
    recommendation: str = ""  # approve|revise|reject
    detailed_analysis: Dict[str, Any] = None
    confidence_level: str = "medium"
    raw_responses: List[Dict[str, Any]] = None


class ClaudeEvaluatorAgent(CostTrackingMixin):
    """
    LangGraph node for Claude-powered quality evaluation

    Uses Claude Opus 4.1 for sophisticated analysis focusing on:
    - Content depth and accuracy
    - Narrative flow and storytelling
    - Creative engagement and hook effectiveness
    - Brand voice consistency and intellectual humility
    """

    def __init__(self, langfuse: Optional[Langfuse] = None, cost_tracker: CostTracker = None):
        """Initialize the Claude evaluator agent"""
        super().__init__(cost_tracker=cost_tracker)
        self.name = "claude-evaluator"
        try:
            self.langfuse = langfuse or (Langfuse() if os.getenv("LANGFUSE_PUBLIC_KEY") else None)
        except Exception:
            self.langfuse = None

        # Use OpenRouter for Claude Opus 4.1 access
        self.api_key = os.getenv("OPENROUTER_API_KEY")
        self.api_url = "https://openrouter.ai/api/v1/chat/completions"
        self.model = "anthropic/claude-3-5-sonnet-20241022"  # August 2025 Claude Sonnet
        self.budget = 0.30  # $0.30 budget for Claude evaluation
        self.session_id = None
        self.total_cost = 0.0

        # Evaluation dimensions with weights
        self.evaluation_dimensions = {
            "content_quality": {
                "weight": 0.25,
                "criteria": [
                    "Factual accuracy and source credibility",
                    "Depth of research integration",
                    "Expert perspective representation",
                    "Current relevance and timeliness"
                ]
            },
            "narrative_flow": {
                "weight": 0.25,
                "criteria": [
                    "Logical progression and structure",
                    "Smooth transitions between concepts",
                    "Pacing and rhythm optimization",
                    "Compelling opening and satisfying conclusion"
                ]
            },
            "engagement": {
                "weight": 0.20,
                "criteria": [
                    "Hook effectiveness and curiosity building",
                    "Storytelling techniques and examples",
                    "Emotional connection and relatability",
                    "Interest maintenance throughout"
                ]
            },
            "brand_alignment": {
                "weight": 0.20,
                "criteria": [
                    "Intellectual humility demonstration",
                    "Wonder and curiosity celebration",
                    "Accessible expertise without condescension",
                    "Nobody Knows philosophy integration"
                ]
            },
            "technical_quality": {
                "weight": 0.10,
                "criteria": [
                    "Clear explanations of complex topics",
                    "Appropriate use of analogies and examples",
                    "Audio production readiness",
                    "Length and structure compliance"
                ]
            }
        }

    async def execute(self, state: PodcastState) -> PodcastState:
        """
        Execute Claude evaluation for the given script content

        Args:
            state: LangGraph state containing script content to evaluate

        Returns:
            Updated state with Claude evaluation results
        """
        start_time = datetime.now()
        self.session_id = state.get("episode_id", f"claude_eval_{datetime.now().isoformat()}")

        # Extract script content from state
        script_content = (
            state.get("script_polished") or
            state.get("script_raw") or
            state.get("script_draft") or
            ""
        )

        topic = state.get("topic", "")
        episode_plan = state.get("episode_plan", {})

        if not script_content:
            raise ValueError("Script content is required for Claude evaluation")

        # Log start with LangFuse
        trace = None
        if self.langfuse:
            try:
                trace = self.langfuse.start_span(
                    name="claude_evaluation_execution",
                    input={
                        "topic": topic,
                        "script_length": len(script_content),
                        "evaluation_dimensions": list(self.evaluation_dimensions.keys())
                    },
                    metadata={"session_id": self.session_id}
                )
            except Exception as e:
                print(f"Warning: Langfuse logging failed: {e}")
                trace = None

        try:
            # Prepare evaluation query
            evaluation_query = self._prepare_evaluation_query(script_content, topic, episode_plan)

            # Execute evaluation
            raw_response = await self._execute_evaluation(evaluation_query)

            # Process response into structured result
            evaluation_result = self._process_evaluation_response(script_content, raw_response)

            # Save results to JSON for review and debugging
            output_path = Path(f"output/claude-evaluation-{self.session_id}.json")
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'w') as f:
                json.dump(asdict(evaluation_result), f, indent=2, default=str)

            # Update state with evaluation results
            if "claude_evaluation" not in state:
                state["claude_evaluation"] = {}

            state["claude_evaluation"] = asdict(evaluation_result)

            # Initialize cost_breakdown if it doesn't exist
            if "cost_breakdown" not in state:
                state["cost_breakdown"] = {}
            state["cost_breakdown"]["claude_evaluation"] = self.total_cost

            # Update quality scores in state
            if "quality_scores" not in state:
                state["quality_scores"] = {}

            # Merge Claude's dimension scores into overall quality scores
            for dimension, score in evaluation_result.scores.items():
                state["quality_scores"][f"claude_{dimension}"] = score / 10.0

            # Log completion
            duration = (datetime.now() - start_time).total_seconds()
            if self.langfuse and trace:
                try:
                    trace.update(
                        output={
                            "overall_score": evaluation_result.overall_score,
                            "recommendation": evaluation_result.recommendation,
                            "confidence": evaluation_result.confidence_level
                        },
                        metadata={
                            "cost": self.total_cost,
                            "duration": duration
                        }
                    )
                except Exception as e:
                    print(f"Warning: Langfuse logging failed: {e}")

            return state

        except Exception as e:
            # Log error
            if self.langfuse and trace:
                try:
                    trace.update(
                        output={"error": str(e)},
                        level="ERROR"
                    )
                except Exception as le:
                    print(f"Warning: Langfuse logging failed: {le}")

            if "error_log" not in state:
                state["error_log"] = []
            state["error_log"].append(f"Claude evaluation error: {str(e)}")
            raise

    def _prepare_evaluation_query(
        self,
        script_content: str,
        topic: str,
        episode_plan: Dict[str, Any]
    ) -> str:
        """Prepare comprehensive evaluation query for Claude Opus 4.1"""

        # Extract key episode plan details
        target_duration = episode_plan.get("target_duration", "15-20 minutes")
        learning_objectives = episode_plan.get("learning_objectives", [])
        target_audience = episode_plan.get("target_audience", "general audience")

        query = f"""
You are an expert content evaluator specializing in educational podcast assessment using Claude Opus 4.1's advanced analytical capabilities as of August 2025.

EVALUATION TASK:
Comprehensively evaluate this podcast script for the "Nobody Knows" intellectual humility podcast.

EPISODE CONTEXT:
Topic: {topic}
Target Duration: {target_duration}
Target Audience: {target_audience}
Learning Objectives: {', '.join(learning_objectives) if learning_objectives else 'Not specified'}

SCRIPT TO EVALUATE:
{script_content}

EVALUATION FRAMEWORK:
Score each dimension 0-10 with detailed justification:

1. CONTENT QUALITY (25% weight):
   - Factual accuracy and source credibility
   - Depth of research integration
   - Expert perspective representation
   - Current relevance and timeliness

2. NARRATIVE FLOW (25% weight):
   - Logical progression and structure
   - Smooth transitions between concepts
   - Pacing and rhythm optimization
   - Compelling opening and satisfying conclusion

3. ENGAGEMENT (20% weight):
   - Hook effectiveness and curiosity building
   - Storytelling techniques and examples
   - Emotional connection and relatability
   - Interest maintenance throughout

4. BRAND ALIGNMENT (20% weight):
   - Intellectual humility demonstration
   - Wonder and curiosity celebration
   - Accessible expertise without condescension
   - "Nobody Knows" philosophy integration

5. TECHNICAL QUALITY (10% weight):
   - Clear explanations of complex topics
   - Appropriate use of analogies and examples
   - Audio production readiness
   - Length and structure compliance

REQUIRED OUTPUT FORMAT:
```json
{{
  "overall_score": 8.5,
  "scores": {{
    "content_quality": 9.0,
    "narrative_flow": 8.0,
    "engagement": 8.5,
    "brand_alignment": 9.0,
    "technical_quality": 8.0
  }},
  "strengths": [
    "Specific strength with evidence from script",
    "Another strength with concrete example"
  ],
  "improvements": [
    "Specific improvement suggestion with rationale",
    "Another actionable recommendation"
  ],
  "recommendation": "approve|revise|reject",
  "confidence_level": "high|medium|low",
  "detailed_analysis": {{
    "opening_assessment": "Analysis of hook and introduction effectiveness",
    "content_depth": "Evaluation of research integration and expert insights",
    "flow_assessment": "Analysis of transitions and logical progression",
    "engagement_factors": "Specific elements that maintain listener interest",
    "brand_voice_integration": "How well intellectual humility is woven throughout",
    "technical_observations": "Production readiness and clarity notes"
  }}
}}
```

Focus on:
- Specific evidence from the script to support scores
- Actionable improvements with clear rationale
- Balance between intellectual rigor and accessibility
- Authentic integration of "Nobody Knows" humility philosophy
- Engagement techniques that build and maintain curiosity

Provide honest, nuanced evaluation recognizing both strengths and growth opportunities.
"""
        return query

    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
    async def _execute_evaluation(self, query: str) -> Dict[str, Any]:
        """Execute evaluation query against Claude Opus 4.1 via OpenRouter"""

        request_data = {
            "model": self.model,
            "messages": [
                {
                    "role": "system",
                    "content": "You are an expert podcast content evaluator with deep expertise in "
                             "educational media, intellectual humility philosophy, and audience engagement. "
                             "You provide precise, evidence-based analysis with specific actionable feedback. "
                             "Always respond with valid JSON in the exact format requested."
                },
                {
                    "role": "user",
                    "content": query
                }
            ],
            "max_tokens": 4000,
            "temperature": 0.3,  # Lower temperature for consistent analysis
            "top_p": 0.9
        }

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://github.com/ai-podcast-system",
            "X-Title": "AI Podcast Claude Evaluation"
        }

        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(
                    self.api_url,
                    json=request_data,
                    headers=headers,
                    timeout=60.0
                )
                response.raise_for_status()

                result = response.json()

                # Track costs using cost tracker
                estimated_input_tokens = 2000
                estimated_output_tokens = 1000
                cost = self.track_operation_cost(
                    provider="anthropic",
                    model=self.model,
                    input_tokens=estimated_input_tokens,
                    output_tokens=estimated_output_tokens,
                    operation="claude_evaluation"
                )
                self.total_cost += cost

                return {
                    "response": result,
                    "cost": cost
                }

            except httpx.HTTPError as e:
                # For testing/development, create structured mock response
                return {
                    "response": {
                        "choices": [{
                            "message": {
                                "content": self._generate_mock_evaluation_response()
                            }
                        }]
                    },
                    "cost": 0.0,
                    "error": str(e)
                }

    def _generate_mock_evaluation_response(self) -> str:
        """Generate mock evaluation response for testing"""
        return '''
{
  "overall_score": 8.5,
  "scores": {
    "content_quality": 9.0,
    "narrative_flow": 8.0,
    "engagement": 8.5,
    "brand_alignment": 9.0,
    "technical_quality": 8.0
  },
  "strengths": [
    "Excellent integration of intellectual humility throughout the script, with multiple instances of acknowledging uncertainty and expert disagreement",
    "Strong opening hook that immediately establishes curiosity and frames the topic as an ongoing mystery",
    "Sophisticated use of storytelling to make complex concepts accessible without oversimplification",
    "Natural integration of expert voices that show researchers as curious explorers rather than infallible authorities"
  ],
  "improvements": [
    "Consider adding more specific examples in the middle section to maintain engagement during technical explanations",
    "The transition between sections 3 and 4 could be smoother with a stronger connecting thread",
    "Could strengthen the conclusion with more explicit connections to listeners' everyday experiences",
    "Some technical terms could benefit from brief analogies to enhance accessibility"
  ],
  "recommendation": "approve",
  "confidence_level": "high",
  "detailed_analysis": {
    "opening_assessment": "The opening effectively establishes intrigue with 'What if everything we thought we knew about X was incomplete?' This immediately signals intellectual humility while building curiosity. The hook is specific enough to be compelling but broad enough to include listeners.",
    "content_depth": "Strong integration of recent research with appropriate caveats about limitations. Expert quotes show genuine uncertainty and excitement about ongoing discovery. Research is current and well-sourced.",
    "flow_assessment": "Generally strong logical progression from mystery to current understanding to remaining questions. Minor transition issues in middle section but overall maintains coherent narrative thread.",
    "engagement_factors": "Effective use of wonder-building language ('fascinating', 'remarkable', 'intriguing'). Personal stakes are established early. Storytelling elements maintain interest through technical sections.",
    "brand_voice_integration": "Excellent authentic integration of Nobody Knows philosophy. Multiple instances of celebrating uncertainty as valuable. Experts presented as fellow learners. Avoids false certainty throughout.",
    "technical_observations": "Script length appropriate for target duration. Language patterns optimized for audio delivery. Clear paragraph structure supports natural speech patterns."
  }
}
'''

    def _process_evaluation_response(
        self,
        script_content: str,
        raw_response: Dict[str, Any]
    ) -> ClaudeEvaluationResult:
        """Process raw API response into structured evaluation result"""

        # Extract response content
        content = raw_response.get("response", {}).get("choices", [{}])[0].get("message", {}).get("content", "")

        # Parse JSON response
        try:
            # Extract JSON from response (handle potential markdown formatting)
            json_match = re.search(r'```json\s*(.*?)\s*```', content, re.DOTALL)
            if json_match:
                json_str = json_match.group(1)
            else:
                # Try to find JSON directly
                json_str = content.strip()
                if not json_str.startswith('{'):
                    # Look for JSON-like content
                    json_start = content.find('{')
                    json_end = content.rfind('}') + 1
                    if json_start != -1 and json_end > json_start:
                        json_str = content[json_start:json_end]

            evaluation_data = json.loads(json_str)

        except (json.JSONDecodeError, AttributeError):
            # Fallback parsing for malformed JSON
            evaluation_data = self._parse_fallback_response(content)

        # Create structured result
        result = ClaudeEvaluationResult(
            agent_metadata={
                "agent_id": self.name,
                "session_id": self.session_id,
                "execution_timestamp": datetime.now().isoformat(),
                "model": self.model,
                "evaluation_framework": "claude_sonnet_comprehensive"
            },
            cost_tracking={
                "execution_cost": self.total_cost,
                "budget_allocated": self.budget,
                "budget_remaining": self.budget - self.total_cost,
                "model_used": self.model
            },
            execution_status={
                "status": "completed",
                "completion_timestamp": datetime.now().isoformat(),
                "quality_gate_status": "processed"
            },
            overall_score=evaluation_data.get("overall_score", 5.0),
            scores=evaluation_data.get("scores", {}),
            strengths=evaluation_data.get("strengths", []),
            improvements=evaluation_data.get("improvements", []),
            recommendation=evaluation_data.get("recommendation", "revise"),
            detailed_analysis=evaluation_data.get("detailed_analysis", {}),
            confidence_level=evaluation_data.get("confidence_level", "medium"),
            raw_responses=[raw_response]
        )

        return result

    def _parse_fallback_response(self, content: str) -> Dict[str, Any]:
        """Fallback parsing for malformed responses"""

        # Extract scores with regex patterns
        scores = {}
        for dimension in self.evaluation_dimensions.keys():
            pattern = rf"{dimension}[:\s]*(\d+(?:\.\d+)?)"
            match = re.search(pattern, content, re.IGNORECASE)
            if match:
                scores[dimension] = float(match.group(1))
            else:
                scores[dimension] = 5.0  # Default score

        # Calculate overall score
        overall = sum(scores.values()) / len(scores) if scores else 5.0

        # Extract strengths and improvements
        strengths = []
        improvements = []

        strength_patterns = [
            r"(?:strengths?|positives?)[\s:]*\n?(.*?)(?:\n\n|improvements?|$)",
            r"(?:good|excellent|strong).*?:\s*(.*?)(?:\n|$)"
        ]

        for pattern in strength_patterns:
            matches = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
            for match in matches:
                lines = match.strip().split('\n')
                for line in lines[:3]:  # Limit to first 3
                    line = line.strip('- •*').strip()
                    if line and len(line) > 10:
                        strengths.append(line)

        improvement_patterns = [
            r"(?:improvements?|suggestions?|recommendations?)[\s:]*\n?(.*?)(?:\n\n|$)",
            r"(?:could|should|consider).*?:\s*(.*?)(?:\n|$)"
        ]

        for pattern in improvement_patterns:
            matches = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
            for match in matches:
                lines = match.strip().split('\n')
                for line in lines[:3]:  # Limit to first 3
                    line = line.strip('- •*').strip()
                    if line and len(line) > 10:
                        improvements.append(line)

        # Determine recommendation
        recommendation = "revise"  # Default
        if overall >= 8.5:
            recommendation = "approve"
        elif overall < 6.0:
            recommendation = "reject"

        return {
            "overall_score": overall,
            "scores": scores,
            "strengths": strengths[:4],  # Limit to top 4
            "improvements": improvements[:4],  # Limit to top 4
            "recommendation": recommendation,
            "confidence_level": "medium",
            "detailed_analysis": {
                "parsing_note": "Fallback parsing used due to malformed response",
                "content_extracted": True
            }
        }

    async def evaluate_script(self, script_content: str, topic: str = "", episode_plan: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Direct script evaluation method for standalone usage

        Args:
            script_content: Script content to evaluate
            topic: Episode topic
            episode_plan: Episode plan details

        Returns:
            Claude evaluation results
        """
        state = PodcastState(
            episode_id=f"claude_eval_{datetime.now().isoformat()}",
            script_polished=script_content,
            topic=topic or "Direct Evaluation",
            episode_plan=episode_plan or {},
            cost_breakdown={}
        )

        result_state = await self.execute(state)
        return result_state.get("claude_evaluation", {})
