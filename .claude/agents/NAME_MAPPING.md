# Agent Name Mapping - Claude Code Integration

This document tracks the agent file renaming to ensure Claude Code native sub-agent discovery.

## Requirement
Claude Code requires agent names to use `lowercase-with-hyphens` format without number prefixes.

## Research Stream Agents

| Old Name | New Name | Status |
|----------|----------|---------|
| `01_research-orchestrator.md` | `research-orchestrator.md` | Pending |
| `02_deep-research-agent.md` | `deep-research-agent.md` | Pending |
| `03_question-generator.md` | `question-generator.md` | Pending |
| `research-synthesizer.md` | `research-synthesizer.md` | ✅ Already correct |

## Production Stream Agents

| Old Name | New Name | Status |
|----------|----------|---------|
| `01_production-orchestrator.md` | `production-orchestrator.md` | Pending |
| `02_episode-planner.md` | `episode-planner.md` | Pending |
| `03_script-writer.md` | `script-writer.md` | Pending |
| `04_quality-claude.md` | `quality-claude.md` | Pending |
| `05_quality-gemini.md` | `quality-gemini.md` | Pending |
| `06_feedback-synthesizer.md` | `feedback-synthesizer.md` | Pending |
| `07_script-polisher.md` | `script-polisher.md` | Pending |
| `08_final-reviewer.md` | `final-reviewer.md` | Pending |
| `09_tts-optimizer.md` | `tts-optimizer.md` | Pending |
| `10_audio-synthesizer.md` | `audio-synthesizer.md` | Pending |

## Frontmatter Updates Required

All agents need their frontmatter `name:` field updated to match the new filenames.

## Reference Corrections Needed

1. **Commands**: Update references in `.claude/commands/*.md`
2. **Orchestrators**: Fix `audio-producer` → `audio-synthesizer`
3. **Internal**: Verify all agent-to-agent references

## Notes

- **Preserve**: Semantic XML tags in markdown files (for Claude instruction adherence)
- **Remove**: Only `.xml` file extensions, not XML tags in markdown
- **Test**: Agent discovery after changes

Created: 2025-08-18  
Purpose: Claude Code native integration