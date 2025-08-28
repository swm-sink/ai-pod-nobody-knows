# Context Consolidation Command

**Purpose**: Automated consolidation of fragmented documentation using single-source principles

## Command Usage
```bash
/context-consolidate [topic-area]
```

## Topic Areas Available
```yaml
consolidation_targets:
  perplexity: "Merge 9 Perplexity files into 2 comprehensive guides"
  cost_optimization: "Consolidate 3 cost files into unified cost management"
  troubleshooting: "Merge all troubleshooting into single comprehensive guide"
  audio_synthesis: "Unify all audio-related contexts into single guide"
  all: "Execute complete consolidation to achieve ≤15 file limit"
```

## Implementation Framework
```yaml
consolidation_process:
  analysis_phase:
    - Identify all files in target topic area
    - Extract unique content from each file
    - Map content relationships and dependencies
    - Preserve all operational knowledge

  merge_phase:
    - Create single comprehensive file for topic
    - Organize content with clear navigation structure
    - Eliminate all duplication while preserving completeness
    - Update all references to point to consolidated file

  validation_phase:
    - Verify no knowledge loss during consolidation
    - Test all @ references point to correct consolidated content
    - Confirm operational functionality maintained
    - Delete redundant files after successful merge
```

## Enforcement Mechanisms
```yaml
single_source_enforcement:
  content_preservation: "Zero tolerance for knowledge loss during consolidation"
  reference_updates: "All @ references automatically updated to consolidated files"
  redundancy_elimination: "Original fragmented files deleted after successful merge"
  validation_gates: "Operational testing before file deletion approved"
```

## Success Metrics
- Topic covered in exactly 1 file (down from multiple files)
- All unique content preserved in consolidated file
- All system references updated correctly
- Total context file count reduced toward ≤15 limit

## Example Execution
```bash
# Consolidate all Perplexity-related files
/context-consolidate perplexity

# Result:
# - Creates: .claude/context/perplexity_integration.md
# - Merges: 9 separate Perplexity files into single comprehensive guide
# - Deletes: All original fragmented Perplexity files
# - Updates: All @ references to point to consolidated file
```

**Integration**: Used during context maintenance cycles and when file limit violations detected.
