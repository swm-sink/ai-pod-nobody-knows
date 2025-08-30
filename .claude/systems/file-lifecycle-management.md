# File Lifecycle Management System

**Purpose**: Prevent documentation sprawl and maintain optimal project architecture
**Enforcement**: Automated with pre-commit hooks and governance controls
**Updated**: 2025-08-30

---

## 🎯 Overview

**Technical:** Automated file governance system implementing creation limits, lifecycle tracking, and archival automation to maintain optimal project architecture within Claude 4's 200K token context windows.

**Simple:** Like having a smart librarian that automatically organizes files, prevents clutter, and ensures you never have too much documentation that slows down the system.

**Connection:** This teaches production-grade documentation management and automated governance patterns.

---

## 📊 Current Architecture Status

### File Count Limits (ENFORCED)
```yaml
directory_limits:
  .claude/context/: 15  # MAXIMUM - Zero tolerance
  .claude/processes/: 5  # Active processes only
  .claude/agents/: 20   # Production agents maximum
  .claude/commands/: 40 # User workflows maximum
  .claude/docs/: 15     # Essential documentation
```

### Archive Status (2025-08-30)
- **Process Files Archived**: 53 files → 5 active
- **Context Files Optimized**: Consolidated to 15 maximum
- **Duplicate Detection**: Zero tolerance enforcement active

---

## 🔄 Lifecycle Stages

### 1. Creation Controls
**Triggers**: Any new file creation in governed directories
**Actions**:
- Check directory file count against limits
- Validate file naming conventions
- Prevent "enhanced-*" pattern creation
- Require explicit justification for new files

### 2. Usage Tracking
**Metrics Collected**:
- File access frequency (via git log analysis)
- Reference count in other files
- Last modification timestamp
- Size and token usage

### 3. Staleness Detection
**Criteria for Archival**:
- No access for 30+ days
- Zero references from active files
- Size > 10KB without justification
- Duplicate content detected

### 4. Automated Archival
**Process**:
- Move to `/archive/[category]-[date]/` directory
- Update all references to archived location
- Add to `.claudeignore` for context exclusion
- Log archival decision and rationale

---

## 🛡️ Enforcement Mechanisms

### Pre-Commit Hook Integration
```bash
#!/bin/bash
# File lifecycle enforcement (integrated in .pre-commit-config.yaml)

# Check directory limits
context_count=$(find .claude/context -name "*.md" | wc -l)
if [ "$context_count" -gt 15 ]; then
    echo "ERROR: Context directory has $context_count files (limit: 15)"
    echo "Run: .claude/systems/file-lifecycle-management.sh --archive-stale"
    exit 1
fi

# Prevent enhanced-* patterns
if find . -name "enhanced-*" -not -path "./.git/*" | grep -q .; then
    echo "ERROR: Enhanced-* pattern detected (PROHIBITED)"
    echo "Consolidate into existing architecture"
    exit 1
fi
```

### Automated Archival Script
```bash
#!/bin/bash
# .claude/systems/archive-stale-files.sh

ARCHIVE_DIR="./archive/$(date +%Y-%m-%d)"
mkdir -p "$ARCHIVE_DIR"

# Find stale files (no git activity in 30 days)
find .claude/processes -name "*.md" -type f | while read file; do
    last_modified=$(git log -1 --format=%ct -- "$file" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    days_old=$(( (current_time - last_modified) / 86400 ))

    if [ "$days_old" -gt 30 ]; then
        echo "Archiving stale file: $file (${days_old} days old)"
        mv "$file" "$ARCHIVE_DIR/"
        echo "$file → $ARCHIVE_DIR/" >> archival.log
    fi
done
```

---

## 📋 Governance Controls

### File Creation Review Process
1. **Automatic Check**: Pre-commit hook validates against limits
2. **Manual Override**: Requires explicit documentation of need
3. **Consolidation First**: Must attempt to merge with existing files
4. **Size Justification**: Files >5KB require rationale

### Directory-Specific Rules

#### `.claude/context/` (15 file limit)
- **Purpose**: Core learning materials only
- **Creation**: Requires consolidation attempt first
- **Archival**: Unused files archived after 30 days
- **Exception**: Navigation files always retained

#### `.claude/processes/` (5 file limit)
- **Purpose**: Active validation and procedure documentation
- **Creation**: Must replace existing file or provide compelling need
- **Archival**: Completed processes archived immediately
- **Retention**: Only current validation results kept

#### `.claude/agents/` (20 file limit)
- **Purpose**: Production agent specifications only
- **Creation**: Requires architectural justification
- **Archival**: Deprecated agents archived, not deleted
- **Quality**: Must include educational dual explanations

---

## 🔍 Monitoring and Reporting

### Weekly Audit Report
```bash
# Generate file lifecycle report
.claude/systems/generate-lifecycle-report.sh

# Output includes:
# - File count by directory
# - Stale file candidates
# - Usage statistics
# - Archive recommendations
```

### Dashboard Integration
```yaml
metrics_tracking:
  file_counts: "Track against limits daily"
  staleness: "Identify archival candidates weekly"
  references: "Map file dependency relationships"
  size_growth: "Monitor for documentation bloat"
```

---

## 🚀 Implementation Status

### ✅ Completed Components
- **Pre-commit Hook**: File limit enforcement active
- **Archival System**: 53 processes successfully archived
- **Context Optimization**: 15-file limit achieved
- **Duplicate Detection**: Zero tolerance enforcement

### 🔄 Active Processes
- **Usage Tracking**: Git log analysis for access patterns
- **Reference Mapping**: Automated dependency detection
- **Size Monitoring**: Token usage optimization
- **Quality Gates**: Educational standard enforcement

### 📋 Future Enhancements
- **Automated Summarization**: Convert old files to brief summaries
- **Smart Merging**: AI-assisted file consolidation
- **Predictive Archival**: ML-based staleness prediction
- **Cross-Reference Analysis**: Dependency impact assessment

---

## 📝 Usage Examples

### Check System Status
```bash
# View current file counts
.claude/systems/file-lifecycle-status.sh

# Output:
# .claude/context/: 15/15 files (AT LIMIT)
# .claude/processes/: 3/5 files (HEALTHY)
# .claude/agents/: 19/20 files (NEAR LIMIT)
```

### Force Archive Stale Files
```bash
# Archive files unused for 30+ days
.claude/systems/archive-stale-files.sh --force

# With preview (recommended)
.claude/systems/archive-stale-files.sh --preview
```

### Create New File (Governed)
```bash
# Attempt to create new context file
echo "New content" > .claude/context/new-file.md

# Pre-commit hook triggers:
# ERROR: Context directory at limit (15/15)
# Suggestion: Archive unused files first
```

---

## 🎯 Success Metrics

### Quantitative Targets
- **Context Directory**: Maintain exactly 15 files
- **Process Files**: Keep under 5 active files
- **Archive Rate**: 95% of stale files archived within 35 days
- **Duplicate Detection**: 0 violations detected

### Qualitative Indicators
- **Fast Navigation**: Context loading <2 seconds
- **Clear Architecture**: Each file has specific purpose
- **Maintainability**: Easy to find relevant information
- **Educational Value**: All files teach transferable skills

---

## 📚 Integration Points

### Pre-Commit Hooks (`.pre-commit-config.yaml`)
```yaml
- repo: local
  hooks:
    - id: file-lifecycle-enforcement
      name: File lifecycle management enforcement
      entry: .claude/systems/file-lifecycle-hook.sh
      language: script
      pass_filenames: false
      always_run: true
```

### CLAUDE.md Integration
```markdown
# Context Management (automatically enforced)
- Maximum 15 context files (lifecycle-managed)
- Automated archival of stale documentation
- Zero duplication tolerance with pre-commit enforcement
```

### GitHub Actions Integration
```yaml
- name: File Lifecycle Audit
  run: |
    .claude/systems/file-lifecycle-audit.sh
    if [ $? -ne 0 ]; then
      echo "File lifecycle violations detected"
      exit 1
    fi
```

---

**This system ensures the project remains maintainable, navigable, and optimized for Claude 4's advanced context management capabilities while teaching production-grade documentation governance.**
