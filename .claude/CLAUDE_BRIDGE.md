# CLAUDE_BRIDGE.md - Production Bridge Orchestration

<!-- markdownlint-disable-file -->

<!-- PRODUCTION BRIDGE MODE: Claude Code orchestrating LangGraph execution -->
<MANDATORY_CONTEXT>
<!-- This context loads when task="production_orchestration" -->

## 🌉 BRIDGE MISSION

**Purpose**: Enable Claude Code to orchestrate LangGraph production workflows through subprocess execution and monitoring.

**Architecture Pattern**: Claude Code acts as intelligent orchestrator → LangGraph executes production → Results flow back

## 🚀 DUAL EXECUTION MODES

**Mode A: Direct LangGraph** (Automated)
```bash
cd podcast_production
python main.py --topic "Why do we dream?" --episode-id ep001
```

**Mode B: Claude Orchestrated** (Interactive)
```bash
# Via Claude Code slash commands
/prod-episode "Why do we dream?"
# Executes: subprocess → LangGraph → monitoring → results
```

## 🤖 BRIDGE AGENT COORDINATION

<SELECTIVE_CONTEXT_LOADING>
**Bridge Agent Specialization**:
- `@agents/bridge/production-orchestrator.md` - <LOAD_IF task="run_episode">Manages LangGraph subprocess execution</LOAD_IF>
- `@agents/bridge/monitor-agent.md` - <LOAD_IF task="monitor_production">Tracks LangGraph execution progress</LOAD_IF>
- `@agents/bridge/recovery-agent.md` - <LOAD_IF task="handle_failures">Manages failure recovery and retries</LOAD_IF>
- `@agents/bridge/cost-monitor.md` - <LOAD_IF task="track_costs">Real-time cost tracking during production</LOAD_IF>
- `@agents/bridge/quality-gate.md` - <LOAD_IF task="validate_quality">Quality validation of LangGraph output</LOAD_IF>
</SELECTIVE_CONTEXT_LOADING>

## 🎮 PRODUCTION BRIDGE COMMANDS

**Episode Production**:
- `/prod-episode` - Full episode production via LangGraph
- `/prod-research` - Research pipeline only
- `/prod-script` - Script generation and polishing
- `/prod-audio` - Audio synthesis pipeline

**Monitoring & Control**:
- `/prod-monitor` - Monitor running LangGraph process
- `/prod-analyze` - Analyze completed episode costs/quality
- `/prod-recover` - Recover from failed production
- `/prod-status` - Check LangGraph system health

## 📊 SUBPROCESS EXECUTION PATTERNS

**Standard Subprocess Pattern**:
```python
import subprocess
import asyncio
import json

async def execute_langgraph_episode(topic: str, episode_id: str):
    """Execute LangGraph episode production with monitoring"""

    # 1. Prepare execution
    cmd = [
        "python", "podcast_production/main.py",
        "--topic", topic,
        "--episode-id", episode_id,
        "--mode", "production",
        "--output-json"  # Structured output for parsing
    ]

    # 2. Execute with monitoring
    process = await asyncio.create_subprocess_exec(
        *cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
        cwd="podcast_production"
    )

    # 3. Monitor execution
    while process.returncode is None:
        await monitor_progress(process, episode_id)
        await asyncio.sleep(5)

    # 4. Handle results
    stdout, stderr = await process.communicate()
    return parse_langgraph_results(stdout, stderr, process.returncode)
```

## 🔄 STATE SYNCHRONIZATION

**LangGraph State → Claude Context**:
- LangGraph maintains authoritative PodcastState
- Claude Code reads state snapshots for monitoring
- No direct state modification from Claude side
- All production state lives in LangGraph checkpoints

**Communication Patterns**:
1. **Command Flow**: Claude Code → subprocess args → LangGraph
2. **Progress Flow**: LangGraph → stdout/files → Claude monitoring
3. **Result Flow**: LangGraph → JSON output → Claude analysis
4. **Error Flow**: LangGraph → stderr → Claude recovery

## 🚨 ERROR HANDLING & RECOVERY

**Failure Scenarios**:
- LangGraph process crash → subprocess monitoring detects
- API rate limits → retry with exponential backoff
- Budget exhaustion → graceful termination with partial results
- Network failures → checkpoint recovery and resume

**Recovery Mechanisms**:
- Automatic subprocess restart from last checkpoint
- Cost budget recalculation after partial runs
- State recovery from LangGraph persistent storage
- Manual intervention points for critical failures

## 📈 MONITORING & OBSERVABILITY

**Real-time Metrics**:
- Process execution time
- Current cost accumulation
- Quality scores as available
- Resource utilization
- Progress indicators

**Logging Strategy**:
- Claude Code logs orchestration events
- LangGraph logs production events
- Separate log streams for clear debugging
- Structured JSON logs for analysis

## 🎯 QUALITY GATES

**Pre-execution Validation**:
- Verify LangGraph system health
- Check API key availability
- Validate budget sufficiency
- Confirm topic appropriateness

**Post-execution Validation**:
- Cost budget compliance (≤ $5.51)
- Quality score thresholds (≥ 8.0)
- Output file validation
- State consistency checks

## 🔧 CONFIGURATION MANAGEMENT

**Bridge Configuration**:
```yaml
# .claude/config/bridge.yaml
bridge_settings:
  langgraph_timeout: 1800  # 30 minutes max
  monitoring_interval: 5   # seconds
  max_retries: 3
  checkpoint_frequency: 60 # seconds

production_settings:
  default_budget: 5.51
  quality_threshold: 8.0
  output_directory: "episodes/production"
  backup_directory: "episodes/backups"
```

## 📍 INTEGRATION POINTS

**LangGraph Integration**:
- Entry point: `@../podcast_production/main.py`
- State access: `@../podcast_production/core/state.py`
- Checkpoints: `@../podcast_production/checkpoints/`
- Outputs: `@../podcast_production/output/`

**Claude Code Integration**:
- Commands: `@commands/prod/`
- Monitoring: `@agents/bridge/`
- Configuration: `@config/bridge.yaml`
- Logs: `@logs/bridge/`

## 💡 BRIDGE PRINCIPLES

**Technical**:
- Subprocess isolation ensures LangGraph independence
- Asynchronous monitoring prevents blocking
- Structured communication via JSON
- Idempotent operations for reliability

**Simple**:
- Think of this as a smart remote control for the production line
- Claude Code = Remote control with intelligence
- LangGraph = Production line doing the actual work
- Bridge = Communication channel between them

**Connection**:
- This teaches subprocess management and IPC patterns
- Process monitoring and health checking strategies
- Distributed system coordination principles
- Production orchestration and reliability patterns

</MANDATORY_CONTEXT>

---

**Version**: 1.0.0 | **Updated**: 2025-09-01 | **Mode**: Bridge Orchestration
