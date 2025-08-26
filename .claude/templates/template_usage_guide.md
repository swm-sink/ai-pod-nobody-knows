# Template Usage Guide - Single Source Documentation

**Purpose:** Eliminate documentation duplication through centralized template system
**Status:** Production Ready
**Enforcement:** Zero Tolerance DRY Policy Active

## Available Templates

### 1. Script Template
**File:** `@.claude/templates/script_template.md`
**Usage:** All episode script generation
**Variables:** {EPISODE_NUMBER}, {EPISODE_TOPIC}, {TARGET_DURATION}, {TIMESTAMP}, {HOST_NAME}, etc.

### 2. Quality Evaluation Template
**File:** `@.claude/templates/quality_evaluation_template.md`
**Usage:** All quality evaluations (Claude, Gemini, Perplexity)
**Variables:** {EVALUATOR_NAME}, {EVALUATOR_TYPE}, {EPISODE_NUMBER}, etc.

### 3. Production Summary Template
**File:** `@.claude/templates/production_summary_template.md`
**Usage:** Episode production completion summaries
**Variables:** {EPISODE_NUMBER}, {EPISODE_TOPIC}, {PRODUCTION_DATE}, etc.

## Cross-Reference Usage Pattern

**Instead of creating new templates:**
```markdown
# WRONG - Creating duplicate template
# Episode 5 Script Draft
Welcome to Nobody Knows...
```

**Use cross-references:**
```markdown
# CORRECT - Reference central template
# @.claude/templates/script_template.md with variables:
# {EPISODE_NUMBER} = "005"
# {EPISODE_TOPIC} = "AI Regulation 2025"
# {TARGET_DURATION} = "27"
```

## Agent Instructions

### Script Writer Agent
- ALWAYS reference `@.claude/templates/script_template.md`
- Replace variables with episode-specific values
- NEVER create new script templates

### Quality Evaluation Agents
- ALWAYS reference `@.claude/templates/quality_evaluation_template.md`
- Customize {EVALUATOR_TYPE} field appropriately
- NEVER duplicate evaluation structure

### Production Summary
- ALWAYS reference `@.claude/templates/production_summary_template.md`
- Populate all cost and quality metrics
- NEVER create new summary formats

## Template Variable System

**Standard Variables:**
- `{EPISODE_NUMBER}` - Format: "001", "002", etc.
- `{EPISODE_TOPIC}` - Human-readable topic title
- `{TIMESTAMP}` - ISO 8601 format timestamp
- `{TARGET_DURATION}` - Target duration in minutes
- `{TOTAL_COST}` - Cost in USD format: "$2.77"

**Quality Variables:**
- `{BRAND_SCORE}` - Brand alignment percentage
- `{TECHNICAL_SCORE}` - Technical quality percentage
- `{COMPOSITE_SCORE}` - Overall composite score

## Validation Rules

1. **No Template Duplication:** Any new template creation requires elimination of existing duplicates
2. **Variable Consistency:** Use standardized variable names across all templates
3. **Cross-Reference Only:** Always use `@` references, never copy template content
4. **Version Control:** Templates are versioned in git, no local modifications

## Benefits Achieved

✅ **Single Source of Truth:** One template per document type
✅ **Consistency:** All episodes use identical structure
✅ **Maintainability:** Changes propagate across all episodes automatically
✅ **Quality:** Standardized quality metrics and evaluation criteria
✅ **Cost Efficiency:** No duplicate template development time

---

**This system is enforced by the Zero-Tolerance DRY policy - NO EXCEPTIONS**
