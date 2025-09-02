# Troubleshooting & System Operations - Native Claude Code Simplified
**Version:** 1.0.0
**Updated:** 2025-09-01
**Purpose:** Complete troubleshooting guide and system operations reference

## 🚨 Quick Diagnosis

### System Status Check
```bash
# Check MCP connections
claude mcp list

# Verify environment
echo $ELEVENLABS_API_KEY
echo $PERPLEXITY_API_KEY

# Test hook functionality
./.claude/hooks/simplified/session-lifecycle.sh status

# Check logs
tail -f .claude/logs/cost-tracking.log
tail -f .claude/logs/error-recovery.log
```

### Official Documentation
- **Claude Code Troubleshooting:** https://docs.anthropic.com/en/docs/claude-code/troubleshooting
- **MCP Debugging:** https://modelcontextprotocol.io/docs/debugging
- **Error Reference:** https://docs.anthropic.com/en/docs/claude-code/cli-reference
- **Support:** https://github.com/anthropics/claude-code/issues

## 🔴 Critical Issues (Immediate Action)

### MCP Authentication Failure
```yaml
symptom: "401 invalid_api_key error from MCP tools"
severity: CRITICAL
impact: "Blocks all production workflows"

diagnosis:
  1. Check MCP server status: "claude mcp list"
  2. Verify API key: "echo $ELEVENLABS_API_KEY"
  3. Test direct API: "curl -H 'xi-api-key: KEY' https://api.elevenlabs.io/v1/models"

solutions:
  immediate:
    - "Restart Claude Code with environment:"
    - "./build/scripts/start-claude.sh"

  permanent:
    - "Configure MCP with API key:"
    - "claude mcp add-json elevenlabs '{...}'"

  fallback:
    - "Use direct API implementation:"
    - "python src/audio/tts_direct_api.py"

validation:
  - "MCP shows ✓ Connected"
  - "Test synthesis succeeds"
  - "No 401 errors in logs"
```

### Budget Exceeded
```yaml
symptom: "Operations blocked due to budget limit"
severity: CRITICAL
impact: "All API operations halted"

diagnosis:
  1. Check current spend: "grep COST .claude/logs/cost-tracking.log | tail"
  2. Review budget: "cat .claude/hooks/simplified/pre-tool-validation.sh | grep BUDGET"
  3. Identify spike: "sort .claude/logs/cost-tracking.log by cost"

solutions:
  immediate:
    - "Increase budget temporarily:"
    - "export BUDGET_LIMIT=50.00"

  investigation:
    - "Review cost attribution logs"
    - "Identify expensive operations"
    - "Check for runaway loops"

  prevention:
    - "Enable shadow mode first"
    - "Test with small batches"
    - "Monitor continuously"

recovery:
  - "Reset daily counter if needed"
  - "Archive cost logs for analysis"
  - "Implement stricter pre-validation"
```

### Voice Configuration Violation
```yaml
symptom: "Wrong voice ID detected"
severity: CRITICAL
impact: "All audio invalid, brand inconsistency"

diagnosis:
  1. Check config: "cat .claude/config/production-voice.json"
  2. Verify ID: "grep voice_id in logs"
  3. Expected: "ZF6FPAbjXT4488VcRRnw (Amelia)"

solutions:
  immediate:
    - "Restore correct voice ID"
    - "Revert any config changes"

  validation:
    - "Config shows correct ID"
    - "Test synthesis uses Amelia"
    - "Hook validates properly"

prevention:
  - "Config protection hook active"
  - "Version control on config"
  - "Automated validation"
```

## 🟡 High Priority Issues

### Quality Gate Failures
```yaml
symptom: "Episode fails quality thresholds"
severity: HIGH
impact: "Episode cannot be published"

diagnosis:
  1. Check scores: "Review judge agent output"
  2. Identify failures: "Below 0.90 brand, 0.85 technical"
  3. Review feedback: "Specific improvement points"

solutions:
  iteration_1:
    - "Apply judge feedback"
    - "Re-run polisher agent"
    - "Validate improvements"

  iteration_2:
    - "Adjust prompts"
    - "Add more examples"
    - "Increase question density"

  escalation:
    - "Human review required"
    - "Analyze systemic issues"
    - "Update quality gates"

validation:
  - "All scores ≥ thresholds"
  - "3-evaluator consensus"
  - "Brand voice verified"
```

### Duration Discrepancy
```yaml
symptom: "Episode duration off target (28 min)"
severity: HIGH
impact: "Listener experience affected"

diagnosis:
  1. Actual duration: "Check audio file length"
  2. Word count: "Verify script length"
  3. WPM rate: "Calculate actual rate"

solutions:
  too_short:
    - "Add content sections"
    - "Increase SSML pauses"
    - "Expand explanations"

  too_long:
    - "Trim redundant content"
    - "Increase speech rate"
    - "Reduce SSML pauses"

  calibration:
    - "Update WPM constant (206)"
    - "Adjust calculation formula"
    - "Test with samples"

validation:
  - "25-30 minute range"
  - "Natural pacing"
  - "Content completeness"
```

### Cost Overrun
```yaml
symptom: "Episode costs exceed $4.00"
severity: HIGH
impact: "Budget sustainability threatened"

diagnosis:
  1. Cost breakdown: "Review operation logs"
  2. API usage: "Check token counts"
  3. Inefficiencies: "Identify redundant calls"

solutions:
  research_optimization:
    - "Cache common queries"
    - "Reduce search depth"
    - "Reuse prior research"

  synthesis_optimization:
    - "Single-call mode (<40K)"
    - "Avoid regeneration"
    - "Optimize chunking"

  model_selection:
    - "Use appropriate models"
    - "Claude Haiku for simple"
    - "Sonnet for complex only"

validation:
  - "Cost ≤ $4.00"
  - "Quality maintained"
  - "Efficiency improved"
```

## 🟢 Medium Priority Issues

### Slow Processing
```yaml
symptom: "Episode takes >30 minutes"
severity: MEDIUM
impact: "Reduced throughput"

diagnosis:
  1. Bottlenecks: "Time each stage"
  2. API latency: "Check response times"
  3. Sequential vs parallel: "Review workflow"

solutions:
  parallelization:
    - "Run research concurrently"
    - "Batch similar operations"
    - "Pipeline stages"

  caching:
    - "Cache research results"
    - "Store validated scripts"
    - "Reuse audio chunks"

  optimization:
    - "Reduce context size"
    - "Streamline prompts"
    - "Eliminate redundancy"
```

### STT Accuracy Issues
```yaml
symptom: "Word accuracy <90%"
severity: MEDIUM
impact: "Quality validation concerns"

diagnosis:
  1. Problem words: "Identify mismatches"
  2. Technical terms: "Check pronunciation"
  3. Audio quality: "Verify synthesis"

solutions:
  pronunciation:
    - "Add IPA phonetics"
    - "Use SSML phoneme tags"
    - "Custom dictionary"

  synthesis:
    - "Adjust voice settings"
    - "Improve SSML markup"
    - "Test alternatives"

  validation:
    - "Manual spot checks"
    - "Focus on key terms"
    - "Accept minor variations"
```

## 🔧 Common Operational Tasks

### Session Management
```bash
# Start new session
./.claude/hooks/simplified/session-lifecycle.sh init

# Create checkpoint
./.claude/hooks/simplified/session-lifecycle.sh checkpoint "pre-synthesis"

# Restore from checkpoint
./.claude/hooks/simplified/session-lifecycle.sh restore "pre-synthesis"

# Clean up session
./.claude/hooks/simplified/session-lifecycle.sh cleanup
```

### Cost Tracking
```bash
# View today's costs
grep "$(date +%Y-%m-%d)" .claude/logs/cost-tracking.log | \
  awk -F'Cost=' '{sum += $2} END {print "Total: $" sum}'

# Reset cost tracking (use carefully)
> .claude/logs/cost-tracking.log

# Generate cost report
./.claude/hooks/simplified/post-tool-tracking.sh reconcile
```

### Error Recovery
```bash
# Check error logs
tail -50 .claude/logs/error-recovery.log

# Retry last operation
./.claude/hooks/simplified/session-lifecycle.sh error 1 "retry"

# Skip failed step
./.claude/hooks/simplified/session-lifecycle.sh error 2 "skip"

# Abort and cleanup
./.claude/hooks/simplified/session-lifecycle.sh error 3 "abort"
```

## 📊 System Health Monitoring

### Health Check Script
```bash
#!/bin/bash
# health-check.sh

echo "=== System Health Check ==="

# MCP Status
echo -n "MCP Servers: "
claude mcp list | grep -c "✓ Connected"

# API Keys
echo -n "API Keys Configured: "
env | grep -c "_API_KEY"

# Recent Errors
echo -n "Errors (last hour): "
find .claude/logs -name "*.log" -mmin -60 -exec grep -c ERROR {} \; | \
  awk '{sum += $1} END {print sum}'

# Cost Status
echo -n "Today's Spend: "
grep "$(date +%Y-%m-%d)" .claude/logs/cost-tracking.log | \
  awk -F'Cost=' '{sum += $2} END {print "$" sum}'

# Active Sessions
echo -n "Active Sessions: "
ls .claude/state/session-state.json 2>/dev/null | wc -l

echo "======================="
```

### Performance Metrics
```yaml
monitoring_points:
  api_latency:
    perplexity: "< 3 seconds"
    elevenlabs: "< 30 seconds"
    claude: "< 5 seconds"

  processing_time:
    research: "5-10 minutes"
    script: "5-10 minutes"
    audio: "5-10 minutes"

  error_rates:
    target: "< 5%"
    critical: "< 1%"

  cost_efficiency:
    target: "$2.80/episode"
    maximum: "$4.00/episode"
```

## 🚀 Optimization Recommendations

### Immediate Optimizations
1. **Enable caching** for research results
2. **Use single-call synthesis** for scripts <40K
3. **Parallel process** independent tasks
4. **Clear context** between major operations
5. **Monitor costs** continuously

### Long-term Improvements
1. **Build research database** for common topics
2. **Create script templates** for efficiency
3. **Optimize voice settings** empirically
4. **Implement predictive scaling**
5. **Automate quality iterations**

## 📝 Diagnostic Commands

### Quick Diagnostics
```bash
# Full system diagnostic
find .claude -name "*.log" -exec tail -1 {} \; | grep -E "ERROR|WARNING"

# MCP diagnostic
claude mcp list && echo "All MCP servers connected"

# Cost diagnostic
awk -F'Cost=' '{sum += $2} END {print "Total: $" sum}' .claude/logs/cost-tracking.log

# Quality diagnostic
grep "quality_score" .claude/logs/*.log | tail -5

# Performance diagnostic
grep "duration" .claude/logs/*.log | awk '{sum += $2; count++} END {print "Avg: " sum/count}'
```

## 🆘 Emergency Procedures

### Production Failure
1. **Stop all operations** immediately
2. **Check error logs** for root cause
3. **Verify API status** and connectivity
4. **Review recent changes** in git
5. **Rollback if needed** to last known good
6. **Test in isolation** before resuming
7. **Document incident** for prevention

### Data Recovery
1. **Check checkpoints** in state directory
2. **Review session archives** by date
3. **Restore from git** if code affected
4. **Rebuild from logs** if data lost
5. **Validate integrity** before continuing

---

**Support Resources:**
- Claude Code Issues: https://github.com/anthropics/claude-code/issues
- MCP Community: https://modelcontextprotocol.io/community
- API Status Pages: Check provider dashboards
- Internal Logs: `.claude/logs/` directory
