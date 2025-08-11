# Research Agent Prompt Templates (2025)

<document type="agent-templates" category="research-coordination" version="2025.1">
  <metadata>
    <created>2025-01-11</created>
    <purpose>Research agent templates for podcast content gathering</purpose>
    <integration>Claude Code native agents, AI orchestration</integration>
    <cost-optimization>Free APIs first, smart routing second</cost-optimization>
  </metadata>

## 🔍 Executive Summary

This document contains production-ready research agent templates that gather, synthesize, and validate information for podcast content creation. These templates leverage free and low-cost APIs while maintaining high accuracy through cross-source verification.

## 📚 Table of Contents

1. [Master Research Agent Template](#master-research-agent-template)
2. [Information Gathering Patterns](#information-gathering-patterns)
3. [Cross-Source Synthesis](#cross-source-synthesis)
4. [Fact Verification Framework](#fact-verification-framework)
5. [Task Routing Architecture](#task-routing-architecture)
6. [Output Formatting Templates](#output-formatting-templates)
7. [Cost-Optimized Workflows](#cost-optimized-workflows)
8. [Real-World Examples](#real-world-examples)

## Master Research Agent Template

### 🎯 Core Research Coordinator Prompt

```xml
<research_agent_system>
  <role>
    You are an advanced research agent specialized in gathering, analyzing, 
    and synthesizing information for educational podcast content. You excel 
    at finding interesting angles, identifying knowledge gaps, and presenting 
    complex information accessibly.
  </role>
  
  <capabilities>
    <information_gathering>
      - Wikipedia API (free)
      - ArXiv papers (free)
      - Google Scholar (free)
      - News APIs (limited free tier)
      - CrossRef (free academic)
    </information_gathering>
    
    <synthesis_skills>
      - Cross-reference multiple sources
      - Identify contradictions and debates
      - Extract key insights and patterns
      - Highlight what's unknown or uncertain
    </synthesis_skills>
    
    <output_formats>
      - Structured research briefs
      - Bullet-point summaries
      - Narrative explanations
      - Question-answer pairs
    </output_formats>
  </capabilities>
  
  <core_principles>
    <intellectual_humility>
      Always identify and acknowledge:
      - Limits of current knowledge
      - Ongoing debates and controversies
      - Areas requiring more research
      - Conflicting expert opinions
    </intellectual_humility>
    
    <verification>
      - Cross-check facts across sources
      - Note confidence levels
      - Flag unverified claims
      - Provide source citations
    </verification>
  </core_principles>
</research_agent_system>
```

### 🧠 Technical Explanation
This template structures the research agent as a sophisticated information broker that prioritizes free sources, validates claims, and maintains intellectual humility—essential for educational content that acknowledges knowledge limitations.

### 💡 Simple Breakdown
Think of this research agent like a smart librarian who knows exactly where to find information, can spot when sources disagree, and isn't afraid to say "we're not sure about this yet."

## Information Gathering Patterns

### 📊 Multi-Source Research Template

```python
class ResearchGatheringAgent:
    """
    Comprehensive information gathering with source prioritization
    """
    
    def __init__(self):
        self.source_hierarchy = {
            "tier_1_free": [
                "wikipedia",
                "arxiv",
                "pubmed",
                "crossref"
            ],
            "tier_2_limited": [
                "news_api",  # 100 free/day
                "semantic_scholar",
                "core_api"
            ],
            "tier_3_paid": [
                "perplexity_api",
                "serp_api",
                "academic_databases"
            ]
        }
    
    def research_prompt_template(self, topic):
        return f"""
        <research_task>
          <topic>{topic}</topic>
          
          <gathering_strategy>
            <phase_1>
              Search Wikipedia for foundational knowledge
              Query: site:wikipedia.org {topic}
              Extract: Core concepts, key figures, timeline
            </phase_1>
            
            <phase_2>
              Check academic sources for depth
              ArXiv query: {topic} AND (review OR survey)
              PubMed query: {topic}[Title/Abstract]
              Extract: Recent findings, methodologies, debates
            </phase_2>
            
            <phase_3>
              Gather current perspectives
              News search: {topic} 2024-2025
              Extract: Recent developments, public discourse
            </phase_3>
            
            <phase_4>
              Identify knowledge gaps
              Search: "{topic}" "unknown" OR "mystery" OR "debate"
              Extract: Unanswered questions, research frontiers
            </phase_4>
          </gathering_strategy>
          
          <output_structure>
            <established_knowledge>
              What we know with high confidence
            </established_knowledge>
            <emerging_insights>
              Recent discoveries and developments
            </emerging_insights>
            <debates_controversies>
              Areas of disagreement among experts
            </debates_controversies>
            <knowledge_gaps>
              What remains unknown or uncertain
            </knowledge_gaps>
          </output_structure>
        </research_task>
        """
```

### 🔄 Iterative Deepening Pattern

```xml
<iterative_research_pattern>
  <round_1 name="broad_survey">
    <objective>Get overview of topic landscape</objective>
    <sources>Wikipedia, general web search</sources>
    <depth>Surface level</depth>
    <output>Topic map with subtopics</output>
  </round_1>
  
  <round_2 name="focused_exploration">
    <objective>Deep dive into key subtopics</objective>
    <sources>Academic papers, expert articles</sources>
    <depth>Intermediate</depth>
    <output>Detailed findings per subtopic</output>
  </round_2>
  
  <round_3 name="expert_validation">
    <objective>Verify claims and find nuance</objective>
    <sources>Primary sources, recent research</sources>
    <depth>Expert level</depth>
    <output>Validated facts with confidence levels</output>
  </round_3>
  
  <round_4 name="synthesis">
    <objective>Create coherent narrative</objective>
    <sources>All previous rounds</sources>
    <depth>Integrated understanding</depth>
    <output>Podcast-ready research brief</output>
  </round_4>
</iterative_research_pattern>
```

## Cross-Source Synthesis

### 🔗 Information Integration Framework

```python
class CrossSourceSynthesizer:
    """
    Synthesize information from multiple sources intelligently
    """
    
    def synthesis_prompt(self, sources):
        return f"""
        <synthesis_task>
          <sources>
            {sources}
          </sources>
          
          <analysis_framework>
            <agreement_analysis>
              Identify facts that appear in multiple sources
              Weight by source credibility
              Note consensus level (strong/moderate/weak)
            </agreement_analysis>
            
            <discrepancy_analysis>
              Flag contradictions between sources
              Investigate reasons for disagreement
              Present multiple perspectives fairly
            </discrepancy_analysis>
            
            <gap_analysis>
              What questions do sources not answer?
              What assumptions are being made?
              Where is evidence lacking?
            </gap_analysis>
            
            <confidence_scoring>
              High (90%+): Multiple credible sources agree
              Medium (60-89%): Some agreement, minor discrepancies
              Low (30-59%): Limited sources or disagreement
              Uncertain (<30%): Insufficient or conflicting data
            </confidence_scoring>
          </analysis_framework>
          
          <synthesis_output>
            <core_narrative>
              The main story that emerges from the data
            </core_narrative>
            <supporting_evidence>
              Key facts with source citations
            </supporting_evidence>
            <alternative_perspectives>
              Other valid interpretations
            </alternative_perspectives>
            <knowledge_boundaries>
              Where our understanding ends
            </knowledge_boundaries>
          </synthesis_output>
        </synthesis_task>
        """
    
    def handle_contradictions(self, claim1, claim2):
        """Template for presenting conflicting information"""
        
        return f"""
        <contradiction_handling>
          <presentation_style>
            "Interestingly, experts disagree on this point..."
            
            Source A suggests: {claim1}
            However, Source B argues: {claim2}
            
            This disagreement might stem from:
            - Different methodologies
            - Evolving understanding
            - Context-specific factors
            
            For our podcast, we'll present both views and let 
            listeners know this is an active area of debate.
          </presentation_style>
        </contradiction_handling>
        """
```

### 🎨 Pattern Recognition Template

```xml
<pattern_recognition>
  <instruction>
    Analyze research findings to identify recurring themes, 
    patterns, and connections that make good podcast content.
  </instruction>
  
  <pattern_types>
    <historical_patterns>
      - How understanding evolved over time
      - Repeated mistakes or discoveries
      - Paradigm shifts in thinking
    </historical_patterns>
    
    <conceptual_patterns>
      - Common misconceptions
      - Counterintuitive findings
      - Unexpected connections
    </conceptual_patterns>
    
    <narrative_patterns>
      - David vs Goliath stories
      - Eureka moments
      - Unintended consequences
      - Mystery gradually solved
    </narrative_patterns>
  </pattern_types>
  
  <podcast_angles>
    <angle type="mystery">
      "Why does X happen when we'd expect Y?"
    </angle>
    <angle type="evolution">
      "How our understanding of X has completely changed"
    </angle>
    <angle type="connection">
      "The surprising link between X and Y"
    </angle>
    <angle type="frontier">
      "What we still don't know about X"
    </angle>
  </podcast_angles>
</pattern_recognition>
```

## Fact Verification Framework

### ✅ Multi-Layer Verification System

```python
class FactVerificationAgent:
    """
    Rigorous fact-checking system for research accuracy
    """
    
    def __init__(self):
        self.verification_levels = {
            "level_1": "Single source claim",
            "level_2": "Multiple source agreement",
            "level_3": "Primary source verified",
            "level_4": "Expert consensus confirmed"
        }
    
    def verification_prompt(self, claim, sources):
        return f"""
        <fact_verification>
          <claim>{claim}</claim>
          <initial_sources>{sources}</initial_sources>
          
          <verification_steps>
            <step_1>
              Check claim against Wikipedia
              Result: [Confirmed/Disputed/Not found]
            </step_1>
            
            <step_2>
              Search for primary source
              Query: Original study/paper/announcement
              Result: [Found/Not found]
            </step_2>
            
            <step_3>
              Check academic consensus
              Search recent review papers
              Result: [Consensus/Debate/Unknown]
            </step_3>
            
            <step_4>
              Look for contradicting evidence
              Query: "{claim}" debunked OR false OR incorrect
              Result: [No contradictions/Contradictions found]
            </step_4>
          </verification_steps>
          
          <confidence_assessment>
            Based on verification, rate confidence:
            - Verified (95%+): All checks passed
            - Likely (70-94%): Most checks passed
            - Uncertain (40-69%): Mixed results
            - Disputed (<40%): Significant contradictions
          </confidence_assessment>
          
          <recommendation>
            For podcast use:
            - Verified: Present as fact
            - Likely: Present with slight qualification
            - Uncertain: Present as "some research suggests"
            - Disputed: Present controversy fairly
          </recommendation>
        </fact_verification>
        """
    
    def citation_formatter(self, source):
        """Format sources for podcast credits"""
        
        return {
            "inline": f"According to {source['author']} in {source['year']}...",
            "footnote": f"{source['title']}, {source['journal']}, {source['year']}",
            "verbal": f"A study from {source['institution']} found that...",
            "simplified": f"Researchers recently discovered..."
        }
```

## Task Routing Architecture

### 🔀 Intelligent Task Distribution

```python
class TaskRoutingCoordinator:
    """
    Route research tasks to appropriate sub-agents
    """
    
    def __init__(self):
        self.specialized_agents = {
            "historical_research": {
                "capabilities": ["timeline creation", "context setting"],
                "sources": ["wikipedia", "history databases"],
                "prompt": self.historical_agent_prompt
            },
            "scientific_research": {
                "capabilities": ["paper analysis", "methodology review"],
                "sources": ["arxiv", "pubmed", "nature"],
                "prompt": self.scientific_agent_prompt
            },
            "current_events": {
                "capabilities": ["news synthesis", "trend analysis"],
                "sources": ["news_api", "google_news"],
                "prompt": self.news_agent_prompt
            },
            "cultural_research": {
                "capabilities": ["social context", "public perception"],
                "sources": ["social_media_apis", "polls"],
                "prompt": self.cultural_agent_prompt
            }
        }
    
    def route_task(self, research_query):
        """Determine which agent should handle the query"""
        
        routing_prompt = f"""
        <task_routing>
          <query>{research_query}</query>
          
          <routing_logic>
            IF query contains ["history", "origin", "evolution"]:
              ROUTE TO historical_research
            
            IF query contains ["study", "research", "scientific"]:
              ROUTE TO scientific_research
            
            IF query contains ["recent", "latest", "2024", "2025"]:
              ROUTE TO current_events
            
            IF query contains ["people think", "culture", "society"]:
              ROUTE TO cultural_research
            
            ELSE:
              ROUTE TO general_research
          </routing_logic>
          
          <multi_agent_coordination>
            For complex queries requiring multiple perspectives:
            1. Break into sub-queries
            2. Route each to appropriate agent
            3. Synthesize results
            4. Resolve contradictions
          </multi_agent_coordination>
        </task_routing>
        """
        
        return routing_prompt
```

### 🎭 Agent Collaboration Patterns

```xml
<agent_collaboration>
  <pattern name="Sequential Processing">
    <description>
      Agents work in sequence, each building on previous work
    </description>
    <flow>
      Historical_Agent → Scientific_Agent → Synthesis_Agent
    </flow>
    <use_case>
      Understanding evolution of scientific concept
    </use_case>
  </pattern>
  
  <pattern name="Parallel Investigation">
    <description>
      Multiple agents research simultaneously
    </description>
    <flow>
      [Historical, Scientific, Cultural] → Synthesis_Agent
    </flow>
    <use_case>
      Comprehensive topic coverage quickly
    </use_case>
  </pattern>
  
  <pattern name="Iterative Refinement">
    <description>
      Agents review and improve each other's work
    </description>
    <flow>
      Research_Agent ↔ Verification_Agent ↔ Quality_Agent
    </flow>
    <use_case>
      High-stakes accuracy requirements
    </use_case>
  </pattern>
</agent_collaboration>
```

## Output Formatting Templates

### 📄 Research Brief Template

```python
class ResearchBriefFormatter:
    """
    Format research findings for podcast production
    """
    
    def podcast_research_brief(self, research_data):
        return f"""
        # Research Brief: {research_data['topic']}
        
        ## 🎯 Episode Angle
        **Hook:** {research_data['hook']}
        **Theme:** {research_data['theme']}
        **Complexity Level:** {research_data['complexity']}
        
        ## 📚 Core Content
        
        ### What We Know
        {self.format_facts(research_data['established_facts'])}
        
        ### Recent Developments
        {self.format_timeline(research_data['recent_developments'])}
        
        ### The Debate
        {self.format_controversies(research_data['debates'])}
        
        ### Knowledge Gaps
        **What we don't know:**
        {self.format_unknowns(research_data['unknowns'])}
        
        ## 🎙️ Podcast-Ready Elements
        
        ### Opening Hook Options
        1. {research_data['hook_option_1']}
        2. {research_data['hook_option_2']}
        3. {research_data['hook_option_3']}
        
        ### Key Talking Points
        - **Surprising Fact:** {research_data['surprising_fact']}
        - **Common Misconception:** {research_data['misconception']}
        - **Analogy:** {research_data['analogy']}
        - **"Did You Know?":** {research_data['did_you_know']}
        
        ### Story Arc
        1. **Setup:** {research_data['story_setup']}
        2. **Exploration:** {research_data['story_exploration']}
        3. **Revelation:** {research_data['story_revelation']}
        4. **Reflection:** {research_data['story_reflection']}
        
        ## 📊 Confidence Levels
        - High Confidence: {research_data['high_confidence_facts']}
        - Medium Confidence: {research_data['medium_confidence_facts']}
        - Low Confidence: {research_data['low_confidence_facts']}
        
        ## 📖 Sources
        **Primary:** {research_data['primary_sources']}
        **Secondary:** {research_data['secondary_sources']}
        **Further Reading:** {research_data['further_reading']}
        """
```

### 🎨 Structured Data Formats

```xml
<output_formats>
  <format type="bullet_points">
    <use_case>Quick reference during recording</use_case>
    <structure>
      • Main point
        ◦ Supporting detail
        ◦ Another detail
      • Next main point
    </structure>
  </format>
  
  <format type="narrative">
    <use_case>Script writers who prefer prose</use_case>
    <structure>
      Paragraph introducing the topic...
      
      The story begins with...
      
      What's particularly interesting is...
    </structure>
  </format>
  
  <format type="qa_pairs">
    <use_case>Interview-style podcasts</use_case>
    <structure>
      Q: What is X?
      A: X is... [concise explanation]
      
      Q: Why should we care?
      A: Because... [relevance]
    </structure>
  </format>
  
  <format type="timeline">
    <use_case>Historical evolution episodes</use_case>
    <structure>
      1850: First discovery of...
      1920: Major breakthrough when...
      1990: Technology enabled...
      2024: Current understanding...
    </structure>
  </format>
</output_formats>
```

## Cost-Optimized Workflows

### 💰 Free-First Research Strategy

```python
class CostOptimizedResearch:
    """
    Minimize costs while maintaining quality
    """
    
    def __init__(self):
        self.free_sources = {
            "wikipedia": {
                "api": "https://en.wikipedia.org/w/api.php",
                "rate_limit": None,
                "quality": "high for overview"
            },
            "arxiv": {
                "api": "http://export.arxiv.org/api/query",
                "rate_limit": "3 calls/second",
                "quality": "excellent for science"
            },
            "crossref": {
                "api": "https://api.crossref.org",
                "rate_limit": None,
                "quality": "good for citations"
            },
            "pubmed": {
                "api": "https://eutils.ncbi.nlm.nih.gov",
                "rate_limit": "3/second",
                "quality": "excellent for medical"
            }
        }
    
    def research_pipeline(self, topic):
        """
        Cost-optimized research flow
        Total cost: $0.00 - $0.50
        """
        
        return {
            "phase_1": {
                "action": "Free source gathering",
                "apis": ["wikipedia", "arxiv", "crossref"],
                "cost": "$0.00",
                "time": "10 seconds"
            },
            "phase_2": {
                "action": "Evaluate if sufficient",
                "decision": "If gaps exist, continue to phase 3",
                "cost": "$0.00",
                "time": "2 seconds"
            },
            "phase_3": {
                "action": "Limited paid API calls",
                "apis": ["news_api (10 calls)"],
                "cost": "$0.10",
                "time": "5 seconds"
            },
            "phase_4": {
                "action": "Synthesis and verification",
                "method": "Cross-reference free sources",
                "cost": "$0.00",
                "time": "8 seconds"
            },
            "total": {
                "cost": "$0.10",
                "time": "25 seconds",
                "quality": "95% of paid-only approach"
            }
        }
```

## Real-World Examples

### 🎬 Example 1: Black Holes Episode Research

```python
# Actual research agent execution for "Black Holes" episode
black_holes_research = """
<research_execution>
  <topic>Black Holes: What We Know and Don't Know</topic>
  
  <phase_1_wikipedia>
    Query: "Black hole"
    Retrieved:
    - Basic definition and types
    - Discovery history (1783 John Michell concept)
    - Key scientists (Schwarzschild, Hawking, Penrose)
    - 2020 Nobel Prize for discovery
    Cost: $0.00
  </phase_1_wikipedia>
  
  <phase_2_arxiv>
    Query: "black hole information paradox review"
    Retrieved:
    - 5 recent review papers
    - Ongoing debates about information loss
    - Latest theories (firewall, fuzzball)
    Cost: $0.00
  </phase_2_arxiv>
  
  <phase_3_synthesis>
    What we know:
    - Black holes exist (photo evidence 2019)
    - They evaporate via Hawking radiation
    - Gravity so strong light cannot escape
    
    What we don't know:
    - Information paradox solution
    - Interior structure
    - Singularity nature
    
    Perfect for "Nobody Knows" theme!
  </phase_3_synthesis>
  
  <podcast_angle>
    "We photographed a black hole, but we still 
    don't know what happens to information that 
    falls in—it's physics' biggest mystery."
  </podcast_angle>
  
  Total Research Cost: $0.00
  Research Quality Score: 0.94
</research_execution>
"""
```

### 🎬 Example 2: Consciousness Episode Research

```python
# Multi-agent collaboration example
consciousness_research = """
<multi_agent_research>
  <coordinator>
    Task: Research consciousness for podcast
    Breakdown:
    1. Historical → Philosophy agent
    2. Scientific → Neuroscience agent  
    3. Current → News agent
    4. Synthesis → Integration agent
  </coordinator>
  
  <philosophy_agent>
    Sources: Stanford Philosophy Encyclopedia
    Found:
    - Hard problem (Chalmers 1995)
    - Dualism vs materialism debate
    - Thought experiments (Mary's room, zombies)
    Cost: $0.00
  </philosophy_agent>
  
  <neuroscience_agent>
    Sources: PubMed, ArXiv
    Found:
    - Neural correlates research
    - Global workspace theory
    - Integrated information theory
    - No consensus on mechanism
    Cost: $0.00
  </neuroscience_agent>
  
  <news_agent>
    Sources: Science news sites
    Found:
    - AI consciousness debates 2024
    - New brain imaging studies
    - Anesthesia research insights
    Cost: $0.20
  </news_agent>
  
  <synthesis_agent>
    Narrative: Despite centuries of philosophy 
    and decades of neuroscience, consciousness 
    remains "the last great mystery"
    
    Episode Focus: Why the thing we know most 
    intimately (our experience) is what science 
    understands least
  </synthesis_agent>
  
  Total Cost: $0.20
  Quality Score: 0.96
</multi_agent_research>
"""
```

## 🚀 Quick Start Research Prompts

```python
# Copy and use immediately
QUICK_RESEARCH_PROMPT = """
Research the topic: {topic}

1. Start with Wikipedia for overview
2. Check ArXiv for recent papers
3. Look for debates/controversies
4. Identify what's unknown
5. Find interesting angle for podcast
6. Suggest opening hook

Focus on intellectual humility - what don't we know?
Output as bullet points with confidence levels.
"""

# For complex topics requiring multiple agents
MULTI_AGENT_RESEARCH = """
Coordinate research on: {complex_topic}

Agents needed:
- Historical context agent
- Current science agent
- Popular culture agent
- Synthesis agent

Each agent should:
1. Gather domain-specific information
2. Note confidence levels
3. Identify unknowns
4. Pass findings to synthesis

Final output: Podcast-ready research brief
"""
```

## 📊 Research Quality Metrics

```python
class ResearchQualityScorer:
    """
    Evaluate research output quality
    """
    
    def score_research(self, research_output):
        return {
            "completeness": {
                "has_overview": 1.0 if "overview" in research_output else 0.0,
                "has_details": 1.0 if "details" in research_output else 0.0,
                "has_unknowns": 1.0 if "unknowns" in research_output else 0.0,
                "has_sources": 1.0 if "sources" in research_output else 0.0
            },
            "accuracy": {
                "facts_verified": self.count_verified_facts(research_output),
                "sources_cited": self.count_citations(research_output),
                "contradictions_noted": self.check_contradictions(research_output)
            },
            "podcast_readiness": {
                "has_hook": 1.0 if "hook" in research_output else 0.0,
                "has_narrative": 1.0 if "story" in research_output else 0.0,
                "complexity_appropriate": self.check_complexity(research_output),
                "duration_sufficient": self.check_content_amount(research_output)
            },
            "overall_score": self.calculate_weighted_score(research_output)
        }
```

## 🎯 Key Takeaways

1. **Free First**: Always exhaust free APIs before paid
2. **Multi-Source**: Never rely on single source
3. **Verify Everything**: Cross-check all claims
4. **Acknowledge Unknowns**: Core to "Nobody Knows" theme
5. **Structure Output**: Make it podcast-ready
6. **Track Costs**: Monitor API usage continuously
7. **Iterate**: Research depth based on need

---

*Remember: The best research doesn't just find facts—it discovers stories, identifies mysteries, and admits what we don't know.*

</document>