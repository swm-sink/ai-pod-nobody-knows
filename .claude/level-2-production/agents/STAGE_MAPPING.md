# Agent Stage Mapping - Dependency Resolution

This document maps concrete agent names to abstract stage references to eliminate circular dependencies.

## Stage Mapping

| Stage Name | Agent File | Purpose |
|------------|------------|---------|
| RESEARCH_STAGE | 01_research_coordinator.md | Topic research and information gathering |
| PLANNING_STAGE | 02_episode_planner.md | Episode structure and content planning |
| SCRIPT_GENERATION_STAGE | 03_script_writer.md | Initial script creation |
| QUALITY_EVALUATION_STAGE_1 | 04_quality_claude.md | Primary quality evaluation |
| QUALITY_EVALUATION_STAGE_2 | 05_quality_gemini.md | Secondary quality validation |
| FEEDBACK_SYNTHESIS_STAGE | 06_feedback_synthesizer.md | Quality feedback aggregation |
| SCRIPT_POLISHING_STAGE | 07_script_polisher.md | Script refinement and improvement |
| FINAL_REVIEW_STAGE | 08_final_reviewer.md | Final quality gate and approval |
| AUDIO_SYNTHESIS_STAGE | 09_audio_synthesizer.md | Audio generation and production |

## Pipeline Flow

```text
RESEARCH_STAGE → PLANNING_STAGE → SCRIPT_GENERATION_STAGE →
QUALITY_EVALUATION_STAGE_1 ↘
                              ↘ FEEDBACK_SYNTHESIS_STAGE →
QUALITY_EVALUATION_STAGE_2 ↗                              ↘
                                                          ↘ SCRIPT_POLISHING_STAGE →
                                                             FINAL_REVIEW_STAGE →
                                                             AUDIO_SYNTHESIS_STAGE
```

## Benefits

- **Eliminates Circular Dependencies**: No agent directly references another agent
- **Reduces Coupling**: Agents reference abstract stages, not concrete implementations
- **Improves Maintainability**: Agent names can change without breaking references
- **Enables Dynamic Routing**: Pipeline coordinator determines actual agent routing
- **Supports Testing**: Abstract stages can be mocked or stubbed for testing

## Implementation Notes

- Pipeline coordinator maps abstract stages to concrete agents
- Session state tracks current stage rather than current agent
- Error recovery works at stage level rather than agent level
- Quality gates operate on stage completion rather than agent completion

---
Generated: $(date)
Purpose: Resolve circular dependencies in agent pipeline
