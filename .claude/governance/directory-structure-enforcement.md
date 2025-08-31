# Directory Structure Enforcement Rules

**Created**: 2025-08-30
**Version**: 1.0.0
**Purpose**: Enforce professional standard directory organization for AI Podcast Production System

## 🚨 MANDATORY DIRECTORY STRUCTURE

### Root Directory Constraints (ABSOLUTE MAXIMUM: 8 FILES)
```bash
# ALLOWED FILES ONLY (no exceptions)
/README.md                      # Project overview
/ARCHITECTURE.md               # System architecture
/CONTRIBUTING.md               # Contribution guidelines
/CLAUDE.md                     # Master configuration
/LICENSE                       # Project license
/.env.example                  # Environment template
/requirements.txt              # Consolidated dependencies
/package.json                  # Node.js dependencies for MCP servers
```

### MANDATORY Directory Organization
```
/src/                          # Python source code
├── audio/                     # Audio processing scripts (tts_*.py)
├── validation/                # Validation scripts (stt_*.py, ssml_*.py)
└── utils/                     # Utility scripts (test_*.py)

/docs/                         # All documentation organized by purpose
├── architecture/              # Detailed architecture documents
├── deployment/                # Deployment guides and procedures
├── development/               # Implementation guides and roadmaps
├── reports/                   # Assessment and analysis reports
└── legacy/                    # Outdated documentation

/tests/                        # Test files and validation
├── validation/                # Validation test files (validation_*.md)
├── unit/                      # Unit test files
└── integration/               # Integration test files

/config/                       # Configuration files and templates
├── environments/              # Environment-specific configurations
└── templates/                 # Configuration templates

/build/                        # Build and deployment tools
├── scripts/                   # Build scripts (start-claude.sh, etc.)
└── tools/                     # Development and build tools
```

## 🚫 PROHIBITED PATTERNS

### Root Directory Violations (ZERO TOLERANCE)
- ❌ Any .py files in root → Must move to src/ subdirectories
- ❌ Any .md files except approved 8 → Must move to docs/ subdirectories
- ❌ Any .sh scripts in root → Must move to build/scripts/
- ❌ Multiple requirements*.txt files → Must consolidate to single requirements.txt
- ❌ Documentation files scattered in root → Must categorize in docs/
- ❌ Test files in root → Must organize in tests/ subdirectories
- ❌ Configuration files in root → Must organize in config/

### File Organization Violations (IMMEDIATE BLOCKING)
- ❌ Code mixed with documentation
- ❌ Tests scattered across multiple locations
- ❌ Configuration files not centralized
- ❌ Build tools not properly organized
- ❌ Legacy files mixed with current files

## 🔧 ENFORCEMENT MECHANISMS

### Pre-Commit Hooks (MANDATORY)
```yaml
# .pre-commit-config.yaml additions required:
- repo: local
  hooks:
    - id: directory-structure-validation
      name: Validate Directory Structure
      entry: .claude/governance/validate-directory-structure.sh
      language: system
      always_run: true
      stages: [commit]

    - id: root-directory-limit
      name: Enforce Root Directory Limit (≤8 files)
      entry: .claude/governance/validate-root-limit.sh
      language: system
      always_run: true
      stages: [commit]

    - id: file-categorization-check
      name: Verify File Categorization
      entry: .claude/governance/validate-file-categories.sh
      language: system
      always_run: true
      stages: [commit]
```

### Validation Scripts (REQUIRED IMPLEMENTATION)

#### 1. Root Directory Limit Validator
```bash
#!/bin/bash
# .claude/governance/validate-root-limit.sh

ROOT_FILES=$(find . -maxdepth 1 -type f -not -path "./.*" | wc -l)
MAX_FILES=8

if [ $ROOT_FILES -gt $MAX_FILES ]; then
    echo "❌ ROOT DIRECTORY VIOLATION: $ROOT_FILES files found, maximum $MAX_FILES allowed"
    echo "Files in root:"
    find . -maxdepth 1 -type f -not -path "./.*" | sort
    echo ""
    echo "REQUIRED ACTION: Move files to appropriate subdirectories:"
    echo "  - .py files → src/"
    echo "  - .md files → docs/"
    echo "  - .sh files → build/scripts/"
    echo "  - Config files → config/"
    exit 1
fi

echo "✅ Root directory compliance: $ROOT_FILES/$MAX_FILES files"
```

#### 2. File Categorization Validator
```bash
#!/bin/bash
# .claude/governance/validate-file-categories.sh

VIOLATIONS=0

# Check for Python files in root
PY_IN_ROOT=$(find . -maxdepth 1 -name "*.py" | wc -l)
if [ $PY_IN_ROOT -gt 0 ]; then
    echo "❌ PYTHON FILES IN ROOT: Move to src/ subdirectories"
    find . -maxdepth 1 -name "*.py"
    VIOLATIONS=$((VIOLATIONS + 1))
fi

# Check for shell scripts in root
SH_IN_ROOT=$(find . -maxdepth 1 -name "*.sh" | wc -l)
if [ $SH_IN_ROOT -gt 0 ]; then
    echo "❌ SHELL SCRIPTS IN ROOT: Move to build/scripts/"
    find . -maxdepth 1 -name "*.sh"
    VIOLATIONS=$((VIOLATIONS + 1))
fi

# Check for documentation files in root (except approved)
APPROVED_DOCS="README.md ARCHITECTURE.md CONTRIBUTING.md"
for file in *.md; do
    if [[ -f "$file" ]] && ! echo "$APPROVED_DOCS" | grep -q "$file"; then
        echo "❌ DOCUMENTATION FILE IN ROOT: $file → Move to docs/ subdirectory"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
done

# Check for multiple requirements files
REQ_COUNT=$(find . -maxdepth 1 -name "*requirements*.txt" | wc -l)
if [ $REQ_COUNT -gt 1 ]; then
    echo "❌ MULTIPLE REQUIREMENTS FILES: Consolidate to single requirements.txt"
    find . -maxdepth 1 -name "*requirements*.txt"
    VIOLATIONS=$((VIOLATIONS + 1))
fi

if [ $VIOLATIONS -gt 0 ]; then
    echo ""
    echo "❌ $VIOLATIONS DIRECTORY STRUCTURE VIOLATIONS FOUND"
    echo "COMMIT BLOCKED - Fix violations before proceeding"
    exit 1
fi

echo "✅ Directory structure compliance validated"
```

#### 3. Directory Structure Validator
```bash
#!/bin/bash
# .claude/governance/validate-directory-structure.sh

REQUIRED_DIRS="src docs tests config build"
MISSING_DIRS=""

# Check required directories exist
for dir in $REQUIRED_DIRS; do
    if [ ! -d "$dir" ]; then
        MISSING_DIRS="$MISSING_DIRS $dir"
    fi
done

if [ -n "$MISSING_DIRS" ]; then
    echo "❌ MISSING REQUIRED DIRECTORIES:$MISSING_DIRS"
    echo "Create missing directories with proper subdirectory structure"
    exit 1
fi

# Check required subdirectories
REQUIRED_SUBDIRS="src/audio src/validation src/utils docs/architecture docs/deployment docs/development docs/reports docs/legacy tests/validation tests/unit tests/integration config/environments config/templates build/scripts build/tools"

for subdir in $REQUIRED_SUBDIRS; do
    if [ ! -d "$subdir" ]; then
        echo "❌ MISSING REQUIRED SUBDIRECTORY: $subdir"
        exit 1
    fi
done

echo "✅ Directory structure validation passed"
```

## 📋 VIOLATION RECOVERY PROCEDURES

### Automatic File Organization Script
```bash
#!/bin/bash
# .claude/governance/auto-organize-files.sh

echo "🔧 Auto-organizing files into proper directory structure..."

# Move Python files
find . -maxdepth 1 -name "*.py" -exec sh -c '
    file="$1"
    if [[ "$file" == *tts*.py ]]; then
        mv "$file" src/audio/
    elif [[ "$file" == *stt*.py ]] || [[ "$file" == *ssml*.py ]] || [[ "$file" == *validation*.py ]]; then
        mv "$file" src/validation/
    else
        mv "$file" src/utils/
    fi
' _ {} \;

# Move shell scripts
find . -maxdepth 1 -name "*.sh" -exec mv {} build/scripts/ \;

# Move documentation (except approved)
for file in *.md; do
    if [[ -f "$file" ]] && ! echo "README.md ARCHITECTURE.md CONTRIBUTING.md" | grep -q "$file"; then
        if [[ "$file" == *ROADMAP* ]] || [[ "$file" == *IMPLEMENTATION* ]]; then
            mv "$file" docs/development/
        elif [[ "$file" == *ASSESSMENT* ]] || [[ "$file" == *REPORT* ]]; then
            mv "$file" docs/reports/
        elif [[ "$file" == *DEPLOYMENT* ]]; then
            mv "$file" docs/deployment/
        else
            mv "$file" docs/
        fi
    fi
done

# Move validation files
find . -maxdepth 1 -name "validation_*.md" -exec mv {} tests/validation/ \;

echo "✅ File organization complete"
```

## 🎯 COMPLIANCE MONITORING

### Daily Compliance Check
```bash
# Add to CI/CD pipeline or cron job
#!/bin/bash
# .claude/governance/daily-compliance-check.sh

echo "📊 Daily Directory Structure Compliance Report"
echo "=============================================="

# Count files in root
ROOT_COUNT=$(find . -maxdepth 1 -type f -not -path "./.*" | wc -l)
echo "Root directory files: $ROOT_COUNT/8"

# Check for violations
if ! .claude/governance/validate-directory-structure.sh; then
    echo "❌ COMPLIANCE VIOLATIONS DETECTED"
    exit 1
fi

if ! .claude/governance/validate-root-limit.sh; then
    echo "❌ ROOT LIMIT VIOLATIONS DETECTED"
    exit 1
fi

if ! .claude/governance/validate-file-categories.sh; then
    echo "❌ CATEGORIZATION VIOLATIONS DETECTED"
    exit 1
fi

echo "✅ Full compliance achieved"
```

## 🚀 IMPLEMENTATION CHECKLIST

- [ ] Create all validation scripts in .claude/governance/
- [ ] Make all scripts executable: `chmod +x .claude/governance/*.sh`
- [ ] Update .pre-commit-config.yaml with new hooks
- [ ] Test validation scripts: `bash .claude/governance/validate-*.sh`
- [ ] Run pre-commit install to activate hooks
- [ ] Verify commit blocking works with test violations
- [ ] Document compliance procedures in CONTRIBUTING.md
- [ ] Add compliance monitoring to CI/CD pipeline

## ⚠️ CRITICAL NOTES

**ZERO TOLERANCE POLICY**: Any violations of directory structure immediately block all commits until resolved.

**NO EXCEPTIONS**: The 8-file root limit and directory organization rules have no bypass mechanisms.

**AUTOMATED ENFORCEMENT**: Pre-commit hooks ensure compliance is maintained automatically.

**PROFESSIONAL STANDARDS**: This structure follows industry best practices for maintainable, scalable projects.

This enforcement system ensures the project maintains professional standards and organized structure for all contributors and maintainers.
