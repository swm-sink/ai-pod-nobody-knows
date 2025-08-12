# 🔄 Git Workflow Guide - Production System

**Technical:** Atomic commit strategy with semantic versioning and automated quality gates  
**Simple:** Like saving your work frequently with good descriptions of what you changed  
**Connection:** This teaches professional version control practices and collaborative development

## Atomic Commit Philosophy

### Core Principle
**One logical change = One commit**

**Technical:** Atomic commits enable clean rollbacks, better debugging, and clear change tracking  
**Simple:** Like organizing photos in albums - each commit contains related changes that make sense together  
**Connection:** This teaches change management and systematic development practices

### Examples of Atomic Commits

#### ✅ Good Atomic Commits
```bash
# Single feature addition
git commit -m "feat(agents): add research coordinator with API integration"

# Single bug fix  
git commit -m "fix(quality): correct brand voice calculation threshold"

# Single configuration change
git commit -m "config(hooks): update pre-commit timeout from 30s to 60s"

# Single documentation update
git commit -m "docs(quick-start): add MCP troubleshooting section"
```

#### ❌ Poor Atomic Commits
```bash
# Multiple unrelated changes
git commit -m "fix bugs and add features and update docs"

# Too granular
git commit -m "fix typo"
git commit -m "fix another typo in same file"

# Too vague
git commit -m "updates"
git commit -m "changes"
```

## Semantic Commit Format

### Required Format
```
<type>(<scope>): <description>

<body>

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Commit Types
- **feat**: New feature
- **fix**: Bug fix  
- **docs**: Documentation changes
- **style**: Formatting, missing semicolons, etc.
- **refactor**: Code changes that neither fix bugs nor add features
- **test**: Adding or updating tests
- **chore**: Updating build tasks, package manager configs, etc.
- **config**: Configuration file changes
- **hooks**: Git hook modifications

### Scope Examples
- **agents**: Pipeline agent modifications
- **tools**: Utility script changes
- **config**: Configuration updates
- **testing**: Test suite changes
- **hooks**: Automation hook changes
- **docs**: Documentation updates

**Technical:** Semantic commits enable automated changelog generation and release management  
**Simple:** Like using categories in your filing system - makes finding specific changes easy  
**Connection:** This teaches structured communication and change categorization

## Production Workflow

### Daily Development Cycle

#### 1. Start Work Session
```bash
# Check current state
git status

# Pull latest changes (if collaborative)
git pull origin main

# Verify clean working directory
git diff --exit-code || echo "Uncommitted changes detected"
```

#### 2. Make Changes
```bash
# Edit files for single logical change
# Test changes work correctly
.claude/level-2-production/tests/test-all-scripts.sh

# Validate specific components
.claude/level-2-production/tools/brand-detector.sh test_file.md
```

#### 3. Commit Changes
```bash
# Add specific files (not git add .)
git add .claude/level-2-production/agents/01_research_coordinator.md

# Write clear commit message
git commit -m "feat(agents): enhance research coordinator with source validation

- Add minimum 3 sources requirement
- Implement credibility scoring
- Add timeout handling for API requests
- Validate source diversity (academic, industry, news)

Technical: Multi-source validation improves research quality
Simple: Like checking multiple opinions before making decisions
Connection: This teaches research methodology and quality assurance

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

#### 4. Session Completion
```bash
# Session completion hook auto-commits remaining changes
.claude/hooks/session-complete.sh

# Creates session summary and final commit
```

**Technical:** Structured workflow ensures consistent quality and traceability across development sessions  
**Simple:** Like following a recipe - each step builds on the previous one for predictable results  
**Connection:** This teaches systematic development methodology and quality control

## Branch Strategy

### Main Branch Only (Current)
- All development on `main` branch
- Atomic commits ensure stability
- Pre-commit hooks prevent broken states
- Session completion creates natural checkpoints

### Future Branching (When Collaborative)
```bash
# Feature branch for new agent
git checkout -b feature/audio-synthesizer-agent

# Work on feature with atomic commits
git commit -m "feat(agents): implement ElevenLabs integration"

# Merge when complete
git checkout main
git merge feature/audio-synthesizer-agent
git branch -d feature/audio-synthesizer-agent
```

## Quality Gates

### Pre-Commit Validation
**Automatically runs on every commit:**
```bash
# Quality checks (via .claude/hooks/pre-commit-quality.sh)
- Backup file detection
- TODO marker scanning  
- Integration test execution
- Commit message format validation
- File size checks
```

### Manual Quality Gates
```bash
# Before major changes
.claude/hooks/pre-production.sh

# After significant work
.claude/level-2-production/tests/test-all-scripts.sh

# Brand voice validation
.claude/level-2-production/tools/brand-detector.sh script.md
```

## Recovery Commands

### Undo Last Commit (Keep Changes)
```bash
git reset --soft HEAD~1
```

### Undo Last Commit (Discard Changes) ⚠️
```bash
git reset --hard HEAD~1
```

### Fix Commit Message
```bash
git commit --amend -m "corrected commit message"
```

### Unstage Files
```bash
# Unstage specific file
git restore --staged filename

# Unstage all files
git restore --staged .
```

### Discard Uncommitted Changes ⚠️
```bash
# Discard specific file changes
git restore filename

# Discard all changes
git restore .
```

### Recover Deleted Files
```bash
# Find when file was deleted
git log --oneline -- path/to/file

# Restore from commit before deletion
git restore --source=COMMIT_HASH -- path/to/file
```

### Advanced Recovery
```bash
# Show reflog (recent HEAD changes)
git reflog

# Recover from reflog entry
git reset --hard HEAD@{2}

# Create branch from lost commit
git checkout -b recovery COMMIT_HASH
```

**Technical:** Recovery commands enable safe experimentation and error correction without data loss  
**Simple:** Like having multiple save files in a game - you can always go back to a working state  
**Connection:** This teaches risk management and system recovery procedures

## Session State Management

### Session Lifecycle
```bash
# 1. Session Start (automatic with hooks)
session_id="session_$(date +%Y%m%d_%H%M)"

# 2. Work with atomic commits
git add specific_files
git commit -m "type(scope): description"

# 3. Session completion (automatic)
.claude/hooks/session-complete.sh
```

### Session Recovery
```bash
# Find incomplete sessions
find .claude/level-2-production/sessions/active -name "*.json"

# Use recovery helper
.claude/level-2-production/tools/recovery-helper.sh session_id

# Check git state for session
git log --oneline --since="1 hour ago"
```

## Cost Tracking Integration

### Git Hooks + Cost Monitoring
```bash
# Pre-commit cost validation
if costs > threshold:
    echo "Cost threshold exceeded, commit blocked"
    exit 1

# Post-commit cost tracking
git log --oneline | head -5
.claude/level-2-production/tools/analyze_sessions.py --recent-costs
```

### Cost-Related Commits
```bash
# Cost optimization changes
git commit -m "perf(agents): reduce token usage by 30% with prompt optimization"

# Cost tracking updates
git commit -m "feat(tools): add real-time cost monitoring dashboard"
```

## Collaborative Features (Future)

### Pull Request Workflow
```bash
# Create feature branch
git checkout -b feature/new-quality-gate

# Make changes with atomic commits
git commit -m "feat(quality): add technical accuracy validation"

# Push and create PR
git push origin feature/new-quality-gate
```

### Code Review Integration
- All commits require semantic format
- Pre-commit hooks ensure quality
- Automated testing validates changes
- Brand voice consistency checks

**Technical:** Collaborative features enable team development while maintaining quality and consistency  
**Simple:** Like having multiple people work on a project with clear rules and automatic checking  
**Connection:** This teaches team collaboration and quality assurance in group settings

## Best Practices Summary

### Do's ✅
- **One logical change per commit**
- **Use semantic commit format**
- **Test before committing**
- **Write descriptive commit messages**
- **Include dual explanations in significant commits**
- **Use atomic operations for related changes**
- **Validate quality gates before pushing**

### Don'ts ❌
- **Don't commit broken code**
- **Don't use `git add .` blindly**
- **Don't commit secrets or API keys**
- **Don't skip pre-commit hooks**
- **Don't create backup files (use git instead)**
- **Don't commit temporary or generated files**
- **Don't use generic commit messages**

### Emergency Procedures
```bash
# System completely broken
git reset --hard origin/main

# Lost important changes
git reflog  # Find lost commits
git cherry-pick COMMIT_HASH

# Accidental secret commit
git filter-branch --tree-filter 'rm -f .env' HEAD
```

---

**Version**: Production Ready | **Atomic Commits**: Enforced | **Quality Gates**: Automated