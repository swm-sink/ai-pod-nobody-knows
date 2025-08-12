# ⛑️ Git Recovery Commands Quick Reference

**Technical:** Emergency git operations for system recovery and data preservation  
**Simple:** Like having first aid instructions - quick help when things go wrong  
**Connection:** This teaches crisis management and recovery procedures in production systems

## 🚨 Emergency Recovery Commands

### Immediate Actions (When in Trouble)

#### Check Current Status
```bash
# See what's happening
git status

# Check recent commits
git log --oneline -10

# See what files changed
git diff --name-only
```

#### Safe Information Gathering
```bash
# Show commit history with files
git log --stat -5

# Show who changed what when
git log --oneline --graph --all -10

# Find specific changes
git log --grep="keyword" --oneline
```

## 🔄 Undo Operations (Safe)

### Unstage Files (Keep Changes)
```bash
# Unstage specific file
git restore --staged filename.md

# Unstage all files
git restore --staged .

# See what would be unstaged
git diff --cached
```

### Discard Working Changes ⚠️
```bash
# Discard changes to specific file
git restore filename.md

# Discard all working changes (CAREFUL!)
git restore .

# Discard specific directory changes
git restore path/to/directory/
```

### Undo Last Commit (Keep Changes)
```bash
# Move HEAD back one commit, keep changes staged
git reset --soft HEAD~1

# Move HEAD back one commit, keep changes unstaged
git reset HEAD~1

# Check what happened
git status
```

## 🚨 Emergency Recovery (Destructive)

### Reset to Previous Commit ⚠️
```bash
# DESTROYS CHANGES - moves to previous commit
git reset --hard HEAD~1

# DESTROYS CHANGES - moves to specific commit
git reset --hard COMMIT_HASH

# DESTROYS CHANGES - moves to last known good state
git reset --hard origin/main
```

### Reset to Specific Point ⚠️
```bash
# Find the commit you want
git log --oneline -20

# Reset to that commit (DESTROYS later commits)
git reset --hard COMMIT_HASH

# Force push if needed (BE VERY CAREFUL)
git push --force-with-lease origin main
```

## 🔍 Finding Lost Work

### Reflog (Recent Actions)
```bash
# Show recent HEAD movements
git reflog

# Show reflog with timestamps
git reflog --date=iso

# Recover from reflog entry
git reset --hard HEAD@{5}
```

### Finding Deleted Files
```bash
# Find when file was deleted
git log --oneline --follow -- path/to/file

# Restore file from before deletion
git restore --source=COMMIT_HASH -- path/to/file

# Show file content from specific commit
git show COMMIT_HASH:path/to/file
```

### Cherry-Pick Lost Commits
```bash
# Apply specific commit to current branch
git cherry-pick COMMIT_HASH

# Apply multiple commits
git cherry-pick HASH1 HASH2 HASH3

# Apply range of commits
git cherry-pick HASH1..HASH2
```

## 🏥 Specific Recovery Scenarios

### Committed Wrong Files
```bash
# Amend last commit
git add correct_file.md
git commit --amend -m "Fixed commit message"

# Remove file from last commit but keep in working tree
git reset --soft HEAD~1
git restore --staged wrong_file.md
git commit -m "Corrected commit"
```

### Committed Secrets/Sensitive Data
```bash
# Remove from last commit only
git reset --soft HEAD~1
git restore --staged .env
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Remove sensitive data and update gitignore"

# Remove from entire history (NUCLEAR OPTION)
git filter-branch --tree-filter 'rm -f .env' HEAD
git push --force-with-lease origin main
```

### Corrupted Working Directory
```bash
# Clean untracked files
git clean -fd

# Reset everything to last commit
git reset --hard HEAD

# Verify clean state
git status
```

### Merge Conflicts
```bash
# Abort merge and return to pre-merge state
git merge --abort

# Reset merge conflicts and start over
git reset --hard HEAD

# Show conflicts
git diff --name-only --diff-filter=U
```

## 🔧 Session Recovery Specific

### Session State Recovery
```bash
# Find session-related commits
git log --grep="session" --oneline -10

# Restore session files
git restore --source=HEAD~1 -- .claude/level-2-production/sessions/

# Check session integrity
.claude/level-2-production/tests/test-session-recovery.sh
```

### Agent Pipeline Recovery
```bash
# Restore all agents to last working state
git restore .claude/level-2-production/agents/

# Verify pipeline integrity
.claude/level-2-production/tests/test-circular-dependencies.sh

# Check for circular dependencies
git log --grep="circular" --oneline
```

### Configuration Recovery
```bash
# Restore config files
git restore .claude/level-2-production/config/

# Validate configuration
python3 -c "import yaml; yaml.safe_load(open('.claude/level-2-production/config/environment.yaml'))"

# Test system readiness
.claude/hooks/pre-production.sh
```

## 📊 Branch Management Recovery

### Create Recovery Branch
```bash
# Create branch from current state
git checkout -b recovery-$(date +%Y%m%d-%H%M)

# Create branch from specific commit
git checkout -b recovery-point COMMIT_HASH

# Switch back to main
git checkout main
```

### Compare and Merge Recovery
```bash
# Compare branches
git diff main recovery-branch

# Merge specific files from recovery
git checkout recovery-branch -- specific/file.md

# Merge entire recovery branch
git merge recovery-branch
```

## 🚀 Production System Recovery

### Hooks Recovery
```bash
# Restore hooks to working state
git restore .claude/hooks/

# Make hooks executable
chmod +x .claude/hooks/*.sh

# Test hooks
.claude/hooks/pre-production.sh
```

### Test Suite Recovery
```bash
# Restore test suite
git restore .claude/level-2-production/tests/

# Make tests executable
chmod +x .claude/level-2-production/tests/*.sh

# Run comprehensive validation
.claude/level-2-production/tests/test-all-scripts.sh
```

### Tools Recovery
```bash
# Restore production tools
git restore .claude/level-2-production/tools/

# Make tools executable
chmod +x .claude/level-2-production/tools/*.sh

# Test critical tools
.claude/level-2-production/tools/brand-detector.sh test-file.md
```

## ⚡ Quick Recovery Workflows

### Standard Recovery Process
```bash
# 1. Assess situation
git status
git log --oneline -5

# 2. Create safety branch
git checkout -b emergency-backup-$(date +%Y%m%d-%H%M)

# 3. Return to main and fix
git checkout main
git reset --hard origin/main

# 4. Verify system
.claude/level-2-production/tests/test-all-scripts.sh

# 5. Clean up if successful
git branch -D emergency-backup-*
```

### Nuclear Recovery (Last Resort)
```bash
# 1. Backup current work
git stash push -m "Emergency backup $(date)"

# 2. Reset to known good state
git reset --hard origin/main

# 3. Verify everything works
.claude/level-2-production/tests/test-all-scripts.sh
.claude/hooks/pre-production.sh

# 4. Review stashed work later
git stash list
git stash show stash@{0}
```

## 📞 Help and Verification

### Verify Recovery Success
```bash
# System health check
.claude/level-2-production/tests/test-all-scripts.sh

# Pipeline integrity
.claude/level-2-production/tests/test-circular-dependencies.sh

# Session recovery
.claude/level-2-production/tests/test-session-recovery.sh

# MCP connectivity
.claude/level-2-production/tests/test-mcp-connectivity.sh

# Pre-production readiness
.claude/hooks/pre-production.sh
```

### Get Help
```bash
# Show git help for command
git help reset
git help reflog
git help cherry-pick

# Show recent actions
git reflog --all --graph --decorate --oneline

# Get status of everything
git status --ignored --porcelain
```

---

## 🚫 NEVER Commands (Dangerous)

```bash
# DON'T: Delete .git directory
rm -rf .git

# DON'T: Force push without lease
git push --force origin main

# DON'T: Reset without backup
git reset --hard HEAD~10

# DON'T: Delete remote branches
git push origin --delete branch-name

# DON'T: Rewrite shared history
git rebase -i HEAD~10
```

---

**Emergency Contact**: Run `git reflog` and `git status` - these commands are always safe and show what happened.

**Version**: Production Ready | **Updated**: 2025-08-12 | **Purpose**: Crisis Recovery