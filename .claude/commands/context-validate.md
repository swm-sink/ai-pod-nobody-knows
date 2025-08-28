# Context Validation Command

**Purpose**: Ensure all context files serve unique operational purpose with clear usage documentation

## Command Usage
```bash
/context-validate
```

## Validation Framework
```yaml
validation_criteria:
  operational_purpose:
    - Every context file must have documented operational use case
    - Files without clear purpose flagged for removal
    - Usage patterns tracked and validated

  uniqueness_verification:
    - Each context file covers unique topic domain
    - No overlap or duplication between files
    - Single-source-truth principle enforced

  maintenance_status:
    - All files updated within maintenance cycle
    - Outdated content identified and flagged
    - References validated and functional

  architecture_compliance:
    - File organization follows streamlined architecture
    - Navigation structure clear and logical
    - Information findability optimized
```

## Validation Checks
```yaml
automated_checks:
  file_purpose_documentation:
    check: "Each file has clear purpose statement in header"
    failure_action: "Flag file for documentation or removal"

  topic_uniqueness:
    check: "No topic covered in multiple files"
    failure_action: "Block operations until consolidation complete"

  usage_tracking:
    check: "File accessed within operational timeframe"
    failure_action: "Flag for archival consideration"

  reference_integrity:
    check: "All @ references point to existing, current files"
    failure_action: "Update references or remove broken links"
```

## Enforcement Actions
```yaml
compliance_enforcement:
  purpose_violation:
    action: "Require operational purpose documentation or file removal"
    timeline: "24 hours to document purpose or file archived"

  duplication_violation:
    action: "Block all operations until single-source compliance achieved"
    resolution: "Must consolidate duplicate content into single file"

  maintenance_violation:
    action: "Flag files requiring updates or archival"
    resolution: "Update content or move to archive within 7 days"

  architecture_violation:
    action: "Reorganize files to comply with streamlined architecture"
    resolution: "Follow 15-file maximum structure with clear domains"
```

## Success Criteria
- Every context file has documented operational purpose
- Zero topic duplication across all files
- All files within maintenance windows
- Clear information architecture followed
- ≤15 total context files maintained

## Reporting
```yaml
validation_report_format:
  compliance_summary:
    - "Total files: X/15 (within limit: Y/N)"
    - "Files with clear purpose: X/Y"
    - "Topic duplication violations: X"
    - "Maintenance violations: X"

  action_items:
    - "Files requiring purpose documentation: [list]"
    - "Files requiring consolidation: [list]"
    - "Files requiring maintenance: [list]"
    - "Files recommended for archival: [list]"
```

**Integration**: Runs automatically during system health checks and can be manually invoked for compliance audits.
