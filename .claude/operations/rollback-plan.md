# Rollback Plan - AI Podcast Production System Recovery Procedures

## Emergency Contact & Quick Reference

**EMERGENCY STOP COMMAND:** `/clear` + stop all active agents immediately
**COST LIMIT BREACH:** Check `.claude/sessions/*/costs.json` for current spending
**DATA CORRUPTION:** Session backups available in `.claude/sessions/*/backups/`

---

## Failure Scenarios & Recovery Procedures

### 1. Agent Failure During Research Stream

**Symptoms:** Agent stops responding, incomplete data files, Perplexity API errors

**Immediate Actions:**
1. **Preserve partial data:** `cp -r .claude/sessions/[session_id] .claude/sessions/[session_id]_backup_$(date +%Y%m%d_%H%M%S)`
2. **Check cost tracking:** Review `.claude/sessions/[session_id]/costs.json` for current spend
3. **Identify failure point:** Look for incomplete `.json` files in session directory

**Recovery Options:**
- **Option A - Resume from checkpoint:** Use completed agent data, restart from failed step
- **Option B - Rollback to research start:** Clear session, restart research with saved topic/requirements
- **Option C - Manual completion:** Complete failed step manually, then continue automated flow

**Cost Impact:** Partial research data saves $7.50-$19.50 vs full restart

---

### 2. Agent Failure During Production Stream

**Symptoms:** Script generation stops, quality evaluation fails, TTS optimization errors

**Immediate Actions:**
1. **Stop production pipeline:** Send stop signal to all active production agents
2. **Preserve research investment:** Ensure research data remains intact and accessible
3. **Document failure point:** Record which production agent failed and error details

**Recovery Options:**
- **Option A - Resume from checkpoint:** Use completed production data, restart from failed agent
- **Option B - Rollback to research package:** Return to user review, restart production fresh
- **Option C - Partial manual intervention:** Complete failed step manually, continue automation

**Cost Safeguards:** Production failures limited to $3-4 loss vs $7.50-19.50 research loss

---

### 3. Configuration Corruption

**Symptoms:** Agents can't load settings, budget limits ignored, file paths broken

**Immediate Actions:**
1. **Stop all active processes:** Prevent further damage with incorrect configuration
2. **Backup current state:** Save any partial work before restoration
3. **Identify corruption scope:** Check which config files are affected

**Recovery Procedure:**
```bash
# Restore known-good configuration
cp .claude/config/backup/*.yaml .claude/config/
cp .claude/config/backup/settings.local.json .claude/config/

# Validate configuration integrity
python -c "import yaml; yaml.safe_load(open('.claude/config/episode-config.yaml'))"

# Test agent loading
claude task "Test configuration loading" --context ".claude/config/" --output "/dev/null"
```

**Prevention:** Configuration backups created automatically before major changes

---

### 4. Data Corruption in Session Files

**Symptoms:** JSON parse errors, missing session data, incomplete agent outputs

**Immediate Actions:**
1. **Isolate corrupted session:** Move to `.claude/sessions/corrupted/[session_id]_$(date)`
2. **Check automatic backups:** Look for `.claude/sessions/[session_id]/backups/auto_*`
3. **Assess data recovery options:** Determine what can be salvaged vs restarted

**Recovery Procedure:**
```bash
# Create isolation directory
mkdir -p .claude/sessions/corrupted/
mv .claude/sessions/[corrupted_session] .claude/sessions/corrupted/

# Attempt data recovery from backups
if [ -d ".claude/sessions/corrupted/[session]/backups/" ]; then
    echo "Automatic backups found - attempting recovery"
    cp -r .claude/sessions/corrupted/[session]/backups/latest/* .claude/sessions/[session]/
fi

# Validate recovered data
python -c "import json; json.load(open('.claude/sessions/[session]/[file].json'))"
```

---

### 5. Budget Limit Exceeded

**Symptoms:** Unexpected high costs, API spending beyond $9.00 episode limit

**Immediate Actions:**
1. **EMERGENCY STOP:** Halt all API-calling agents immediately
2. **Cost audit:** Sum all recorded costs in session files and logs
3. **Identify cost source:** Determine which API calls caused overage

**Recovery Procedure:**
```bash
# Emergency cost audit
find .claude/sessions/ -name "costs.json" -exec cat {} \; | jq -s 'map(.cost) | add'

# Check for runaway API calls
grep -r "COST:" .claude/sessions/ | sort -t: -k3 -nr | head -10

# Document lessons learned
echo "Cost overrun incident: $(date)" >> .claude/incidents/cost_overruns.log
```

**Prevention:** Cost monitoring alerts built into each agent

---

### 6. Complete System Failure

**Symptoms:** Multiple agents failing, widespread configuration issues, infrastructure problems

**Immediate Actions:**
1. **Save all partial work:** Comprehensive backup of current state
2. **Document failure context:** Record what was attempted when failure occurred
3. **Switch to manual mode:** Complete episode manually while diagnosing issues

**Nuclear Rollback Procedure:**
```bash
# Complete system backup
tar -czf .claude/backups/emergency_backup_$(date +%Y%m%d_%H%M%S).tar.gz .claude/

# Restore to last known good state
git stash  # Save any uncommitted changes
git checkout main  # Return to stable codebase
git pull origin main  # Ensure latest stable version

# Validate system integrity
.claude/operations/system-health-check.sh

# Restart with minimal configuration
.claude/operations/safe-mode-startup.sh
```

---

## Recovery Decision Matrix

| Failure Type | Time Investment | Cost Investment | Recommended Action |
|--------------|----------------|-----------------|-------------------|
| Research Agent Failure | <1 hour | <$2 | Resume from checkpoint |
| Production Agent Failure | 1-3 hours | $2-5 | Resume from checkpoint |
| Data Corruption | Any | Any | Restore from backup |
| Config Corruption | Any | <$1 | Restore config, restart |
| Budget Exceeded | Any | >$9 | Stop, audit, manual completion |
| System Failure | Any | Any | Nuclear rollback |

---

## Backup Strategy

### Automatic Backups
- **When:** Before each agent starts, after each agent completes
- **What:** Complete session state, configuration files, cost tracking
- **Where:** `.claude/sessions/[session_id]/backups/auto_[timestamp]/`
- **Retention:** Keep 5 most recent backups per session

### Manual Backups
- **When:** Before major system changes, before production episodes
- **What:** Complete `.claude/` directory snapshot
- **Where:** `.claude/backups/manual_[description]_[timestamp].tar.gz`
- **Retention:** Keep indefinitely, user decides when to clean up

### Emergency Snapshots
- **When:** On any error or unexpected behavior
- **What:** Current session state + system configuration
- **Where:** `.claude/emergency/[timestamp]/`
- **Retention:** Keep until incident resolved

---

## Testing Rollback Procedures

### Monthly Rollback Drills
1. **Simulate agent failure** during test episode
2. **Practice data recovery** from backups
3. **Test configuration restoration** procedures
4. **Validate cost tracking** accuracy after rollback
5. **Document lessons learned** and procedure improvements

### Rollback Validation Checklist
- [ ] Can restore session from any checkpoint
- [ ] Cost tracking remains accurate after rollback
- [ ] Configuration corruption is recoverable
- [ ] Data integrity maintained through process
- [ ] User work and investment protected
- [ ] System returns to stable operation

---

## Communication During Incidents

### User Notification
- **Immediate:** Notify user of failure detection and automatic preservation actions
- **Progress:** Update user on recovery options and recommended approach
- **Resolution:** Confirm successful recovery and any lost work/costs

### Incident Documentation
- **Context:** What was being attempted when failure occurred
- **Impact:** What work/costs were lost or preserved
- **Resolution:** How the issue was resolved
- **Prevention:** What changes prevent recurrence

---

## Post-Incident Improvements

### System Hardening
- Add monitoring for identified failure patterns
- Improve backup frequency for vulnerable operations
- Enhance error detection and early warning systems
- Strengthen configuration validation and safeguards

### Process Improvements
- Update agent prompts to handle edge cases better
- Improve cost monitoring and budget enforcement
- Enhance session state management and persistence
- Streamline recovery procedures based on lessons learned

---

## Success Criteria for Rollback Plan

✅ **Recovery Time:** <15 minutes for most failures
✅ **Data Preservation:** 100% of user investment protected
✅ **Cost Protection:** Limited losses to <$2 for most failures
✅ **System Stability:** Return to known-good state guaranteed
✅ **User Confidence:** Clear communication and reliable recovery

**Remember:** The best rollback is the one you never need - but when you do need it, it should be fast, reliable, and preserve user investment.
