# Hallucination Prevention Guide

**Phase:** walk
**Skill Level:** intermediate
**Estimated Time:** 45 minutes

## Anti-Hallucination Policy

**Technical:** Implement systematic verification protocols that require source citation for all factual claims, confidence level disclosure for uncertain information, and multiple-source validation for technical specifications. Use automated thinking mode escalation and parallel fact-checking subagents for complex queries.

**Simple:** Like being a careful journalist - always check your sources, admit when you're not sure, and get multiple opinions on important facts. Never guess when you can look it up.

**Connection:** This teaches information verification skills and source validation essential for any professional work involving research and communication.

## Prevention Strategies

### RAG Implementation for API Documentation

**Technical:** Use Retrieval-Augmented Generation to ground all API and technical documentation claims in current, authoritative sources. Implement automated source retrieval before generating technical responses.

**Simple:** Like doing homework by reading the textbook first instead of guessing - much more accurate results.

### Uncertainty Acknowledgment for Performance Claims

**Technical:** Explicitly disclose confidence levels using standard ranges (90-100%, 70-89%, 50-69%, <50%) and avoid making performance claims without benchmark data from reliable sources.

**Simple:** Like a good teacher saying "Let me look that up" instead of guessing wrong information.

### Direct Quote Grounding for Technical Specifications

**Technical:** Require direct quotes and source URLs for all technical specifications, version numbers, and compatibility information. Implement systematic citation tracking.

**Simple:** Like being a detective who only draws conclusions from actual evidence you can point to.

## Validation Workflow

### Process Steps

1. **Fact Identification**: Identify all statements that assert facts (statistics, events, specifications)
2. **Source Research**: Conduct 3-10 searches with adaptive rules for conflicting information
3. **Source Comparison**: Compare information across sources using decision tree logic
4. **Citation Requirements**: Ensure every factual claim includes source URL and access date
5. **Confidence Disclosure**: Disclose confidence levels using standard ranges

### Success Criteria

- All factual claims have source citations
- Confidence levels disclosed for uncertain information
- Minimum 3 sources for technical specifications
- Uncertainty acknowledged when confidence < 80%

## Research Categories

### Technical Specifications Validation

**Technical:** Current technical documentation from primary sources (official docs, GitHub repositories, API specifications) with version-specific validation and deprecation awareness.

**Simple:** Technology changes fast, so you need current sources from the people who built it.

### Statistics and Data Validation

**Technical:** Original research sources, methodology transparency, sample size disclosure, and statistical significance validation before citing any numerical claims.

**Simple:** Numbers can be misleading, so you need to see how they were calculated originally.

## Hallucination Red Flags

### Specific Numbers Without Source

**Technical:** Any precise numerical claim (percentages, performance metrics, version numbers) without direct source attribution should be flagged for verification.

**Simple:** Specific numbers sound authoritative but are often the most likely to be hallucinated.

### Absolute Statements

**Technical:** Statements using "always," "never," "all," "none" without qualifying conditions or exceptions should be reviewed for accuracy and nuance.

**Simple:** Real world rarely has absolutes - adding nuance makes claims more accurate.

## Claude Code Automation

### Automated Thinking Mode Escalation

**Technical:** Implement automated `ultrathink` mode triggering for queries involving factual claims, technical specifications, or performance assertions.

**Simple:** Like automatically calling in experts when dealing with difficult or dangerous situations.

### Parallel Fact-Checking Subagents

**Technical:** Deploy specialized subagents for concurrent source validation, cross-reference checking, and confidence assessment on complex factual queries.

**Simple:** Like having a team of specialists each check different parts of the information at the same time.

## Uncertainty Language

### High Uncertainty Expression

**Examples:**
- "Based on available sources, this appears to..."
- "According to [Source] as of [Date], the specification indicates..."
- "Multiple sources suggest, though with some variation..."

**Simple:** Better to admit you don't know than to guess and be wrong.

### Qualified Statement with Source

**Format:** "[Claim] according to [Specific Source] accessed [Date]. Confidence level: [X%]"

**Simple:** Shows exactly where the information comes from and when it was accurate.

## Additional Resources

- Change approval workflow validation requirements
- Behavioral testing approaches for AI validation
- Systematic debugging and problem resolution

---

**Version:** 1.0.0 | **Updated:** 2025-08-19 | **Format:** Markdown
