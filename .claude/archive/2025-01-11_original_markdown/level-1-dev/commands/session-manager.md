# Session Manager

**Purpose**: Manage and track work sessions across all 4 levels of the project.

## Instructions

You are the Session Manager. Track progress, costs, and learnings across development and production sessions.

## Process

1. **Identify Session Type**
   - Command: $ARGUMENTS (start|status|end|report)
   - Which level? (1-Dev, 2-Production, 3-Platform, 4-Coded)
   - What's the session purpose?

2. **Session Operations**

### Start New Session
```bash
/session-manager start [level] [purpose]
```
- Create new session file from template
- Set unique session ID with timestamp
- Initialize tracking metrics
- Log session start

### Check Status
```bash
/session-manager status
```
- Show active sessions across all levels
- Display progress metrics
- Show costs accumulated
- List pending tasks

### End Session
```bash
/session-manager end [session-id]
```
- Calculate final metrics
- Save learnings and patterns
- Archive session data
- Generate summary report

### Generate Report
```bash
/session-manager report [date-range]
```
- Aggregate metrics across sessions
- Identify successful patterns
- Calculate total costs
- Show progress toward goals

## Session File Management

### Level 1: Development Sessions
Location: `.claude/level-1-dev/sessions/dev_YYYYMMDD_HHMM.json`
- Track: Tools created, tests run, documentation written
- Metrics: Development velocity, tool effectiveness

### Level 2: Production Sessions
Location: `.claude/level-2-production/sessions/ep_XXX_YYYYMMDD_HHMM.json`
- Track: Episodes produced, quality scores, costs
- Metrics: Cost per episode, quality trends, production time

### Level 3: Platform Planning Sessions
Location: `.claude/level-3-platform-dev/sessions/plan_YYYYMMDD_HHMM.json`
- Track: Requirements defined, designs created, migration plans
- Metrics: Planning completeness, risk assessment

## Session Metrics

### Cost Tracking
```json
{
  "claude_tokens": 0,
  "api_calls": {
    "perplexity": 0,
    "elevenlabs": 0,
    "web_search": 0
  },
  "total_cost_usd": 0.00
}
```

### Quality Tracking
```json
{
  "quality_scores": {
    "brand_alignment": 0.0,
    "content_quality": 0.0,
    "technical_accuracy": 0.0,
    "overall": 0.0
  }
}
```

### Progress Tracking
```json
{
  "tasks_completed": [],
  "tasks_pending": [],
  "blockers": [],
  "learnings": []
}
```

## Automation Features

### Auto-Save
- Every 5 minutes during active session
- On each major task completion
- Before any error recovery

### Pattern Detection
- Identify recurring issues
- Spot cost optimization opportunities
- Detect quality improvements
- Find workflow enhancements

### Alert Thresholds
- Cost exceeds budget: Alert at 80%
- Quality below target: Alert < 0.85
- Time exceeds estimate: Alert at 120%
- Error rate high: Alert > 10%

## Reports

### Daily Summary
- Sessions conducted
- Total costs
- Episodes produced
- Quality average
- Key learnings

### Weekly Analysis
- Cost trends
- Quality trends
- Velocity metrics
- Optimization opportunities

### Monthly Review
- Total production
- Cost per episode trend
- Quality improvement
- System maturity

## Commands

Execute session management for: $ARGUMENTS

### Quick Commands
- `start dev` - Start development session
- `start prod [episode]` - Start production session
- `status` - Check all active sessions
- `end` - End current session
- `report today` - Today's summary
- `report week` - Weekly analysis
- `report month` - Monthly review

## Integration

### With Todolist
- Auto-update todo items from session progress
- Track task completion in session files
- Generate next session's todo from learnings

### With Quality Gates
- Record quality gate passes/failures
- Track quality trends over sessions
- Identify quality improvement patterns

### With Cost Tracking
- Aggregate costs across all sessions
- Calculate running averages
- Project future costs

Remember: Every session is a learning opportunity. Track not just what happened, but WHY and HOW to improve.
