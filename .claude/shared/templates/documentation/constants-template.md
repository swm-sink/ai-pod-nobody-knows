# Constants Template - Domain Constants and Configuration


Template for creating domain-specific constants files with proper XML structure,
validation rules, and DRY principle enforcement across the documentation system.
This file contains all constants, configurations, and reference values for [domain].
All documentation should reference these values rather than hardcoding them.
[Project Name]
Official project identifier
Referenced in all project documentation
[X.Y.Z]
Current version number
2025-08-11
[walk|crawl|run]
walk, crawl, run
Current project phase

## Section
https://api.example.com/v1
Primary API endpoint
[production|staging|development]
30
seconds
Default request timeout
3
Maximum retry attempts for failed requests

## Section
0.85
0.0-1.0
Minimum acceptable quality score
0.90
0.0-1.0
Target quality score for optimization
5.00
USD
Maximum cost per operation
0.50
USD
Estimated hourly operational cost
0.01
per request
0.001
per 1000 tokens
4096
Maximum tokens per request
LLM API calls
1000
characters
Text processing chunk size
10
Default batch processing size
.claude/[level]/config/
Configuration files location
[level] = level-1-dev | level-2-production | level-3-platform
.claude/[level]/output/
Generated output location
.claude/[level]/sessions/
Session tracking location
VALIDATION_ERROR
Input validation failed
warning
API_ERROR
External API call failed
error
QUALITY_THRESHOLD_NOT_MET
Output quality below minimum threshold
warning
Not yet started
Currently executing
Successfully finished
Execution failed
Manually cancelled
Score ≥ 0.95
Score ≥ 0.85
Score ≥ 0.75
Score &lt; 0.75
| Model | Context Window | Cost/1K Tokens | Best For |
|-------|----------------|----------------|----------|
| model-1 | 8K | $0.01 | Quick tasks |
| model-2 | 32K | $0.03 | Complex analysis |
| model-3 | 128K | $0.10 | Long documents |
| Metric | Weight | Threshold | Target |
|--------|--------|-----------|--------|
| Accuracy | 0.3 | 0.80 | 0.90 |
| Completeness | 0.3 | 0.85 | 0.95 |
| Consistency | 0.2 | 0.90 | 0.95 |
| Clarity | 0.2 | 0.85 | 0.90 |

**Example:**
The project "Nobody Knows" has a budget of $5.00 per episode.
The project "{PROJECT_NAME}" has a budget of ${BUDGET_PER_OPERATION} per episode.
See BUDGET_PER_OPERATION in @00_[domain]_constants.md


**Example:**
# Import constants
from constants import BUDGET_PER_OPERATION, MAX_TOKENS
# Use in code
if cost > BUDGET_PER_OPERATION:
raise BudgetExceededError(f"Cost ${cost} exceeds budget ${BUDGET_PER_OPERATION}")

Constants should never be modified directly in consuming files
Each constant should be defined in exactly one location
Every constant must have a description and usage example
Changes to constants require version increment and changelog entry
Converted to XML format per file format policy
Batch 3 Conversion Agent
Initial constants template definition
Enhancement System
Weekly
2025-08-13
2025-08-20
Template Maintenance Team

---

*Converted from XML to Markdown for elegant simplicity*
*Original: constants-template.xml*
*Conversion: Mon Aug 18 00:01:18 EDT 2025*
