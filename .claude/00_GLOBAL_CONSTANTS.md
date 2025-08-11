# Global Constants and Standards

> **⚠️ DRY PRINCIPLE**: This file contains ONLY constants that don't exist in primary sources.
> For episode data, see: `projects/nobody-knows/series_plan/episodes_master.json`
> For production config, see: `projects/nobody-knows/config/project_config.json`
> For architecture details, see: `.claude/ARCHITECTURE.md`

## 4-Level Architecture Constants

### Level Definitions
- **LEVEL_1_DEV**: `.claude/level-1-dev/` - Development Platform
- **LEVEL_2_PRODUCTION**: `.claude/level-2-production/` - Podcast Production
- **LEVEL_3_PLATFORM**: `.claude/level-3-platform-dev/` - Platform Planning
- **LEVEL_4_CODED**: `.claude/level-4-coded/` - Future Implementation (REQUIRES APPROVAL)

### File Naming Conventions
- Development tools: `*-dev.md`
- Production tools: `*-production.md`
- Sessions: `[type]_YYYYMMDD_HHMM.json`
- Episodes: `ep_XXX_*` (where XXX is episode number)

### Quality Standards
- **BRAND_VOICE_TARGET**: 0.90
- **QUALITY_SCORE_TARGET**: 0.85
- **EPISODE_DURATION_MINUTES**: 27 (target)
- **EPISODE_WORD_COUNT**: 3900-4100 words
- **COST_LIMIT_PER_EPISODE**: $9.00
- **READABILITY_SCORE**: 60-70 (Flesch-Kincaid)

### Production Pipeline Stages
1. **RESEARCH**: Gather and validate information
2. **SCRIPT_WRITING**: Create narrative structure
3. **AUDIO_SYNTHESIS**: Generate speech from script
4. **QUALITY_EVALUATION**: Validate all outputs

### MCP Server Standards
- **PERPLEXITY_LIMIT**: $3.00 per episode
- **ELEVENLABS_LIMIT**: $2.00 per episode
- **WEB_SEARCH_LIMIT**: Free tier only initially

### Error Recovery Constants
- **MAX_RETRIES**: 3
- **RETRY_BACKOFF**: [30s, 60s, 120s]
- **SAVE_PROGRESS_INTERVAL**: Every stage completion
- **SESSION_TIMEOUT**: 60 minutes

### Thinking Mode Usage
- **BASIC**: "think" - Simple analysis
- **ENHANCED**: "think hard" - Complex reasoning
- **DEEP**: "think harder" - Multi-perspective analysis  
- **MAXIMUM**: "ultrathink" - Comprehensive evaluation