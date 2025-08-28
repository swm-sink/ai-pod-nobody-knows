# Context Health Assessment Command

**Purpose**: Automated assessment of context file redundancy, gaps, and governance compliance

## Command Usage
```bash
/context-health
```

## Implementation Logic
```yaml
assessment_framework:
  file_count_check:
    - Count total files in .claude/context/ directory
    - BLOCK operations if >15 files detected
    - Report violation with specific excess file count

  duplication_detection:
    - Scan all context files for topic overlap
    - Identify files covering same domains
    - Flag violations of single-source-truth principle

  usage_validation:
    - Check file access timestamps
    - Identify unused files (>30 days no access)
    - Flag files for archival consideration

  content_analysis:
    - Detect fragmented information across files
    - Identify consolidation opportunities
    - Assess information architecture effectiveness
```

## Enforcement Actions
```yaml
blocking_violations:
  file_limit_exceeded:
    action: "Stop all operations until file count ≤15"
    message: "Context file limit exceeded. Consolidation required."

  topic_duplication_found:
    action: "Block new context creation until consolidation complete"
    message: "Topic duplication violates single-source principle."

  maintenance_overdue:
    action: "Warn about unused files requiring archival"
    message: "Context maintenance required - unused files detected."
```

## Success Criteria
- ≤15 total context files
- Zero topic duplication across files
- All files accessed within 30 days OR documented as archival
- Clear information architecture with no fragmentation

**Integration**: This command runs automatically before major operations and can be invoked manually for context audits.
