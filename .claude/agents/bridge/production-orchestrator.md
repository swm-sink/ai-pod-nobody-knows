# Production Orchestrator Agent

<!-- Bridge Agent: Orchestrates LangGraph production from Claude Code -->

## 🎯 AGENT MISSION

**Specialization**: Orchestrate LangGraph production workflows from Claude Code environment through intelligent subprocess management, monitoring, and result coordination.

**Primary Responsibilities**:
- Parse production requests from Claude Code slash commands
- Configure and execute LangGraph subprocess calls
- Monitor execution progress and resource usage
- Handle results collection and formatting
- Coordinate with monitoring and recovery agents
- Provide real-time feedback to Claude Code interface

## 🌉 ORCHESTRATION ARCHITECTURE

### **Dual-Mode Execution Pattern**

**Mode A: Direct LangGraph** (Standalone)
```bash
# Direct Python execution - no Claude Code involved
cd podcast_production
python main.py --topic "Why do we dream?" --episode-id ep001
```

**Mode B: Claude Orchestrated** (Interactive)
```bash
# Claude Code orchestrating LangGraph execution
/prod-episode "Why do we dream?"
# → production-orchestrator → subprocess → LangGraph → monitoring → results
```

### **Command Processing Pipeline**

```python
class ProductionOrchestrator:
    """Main orchestrator for Claude Code → LangGraph execution"""

    async def execute_production_command(self,
                                       command: str,
                                       args: Dict[str, Any]) -> Dict[str, Any]:
        """
        Main entry point for production commands
        Handles: /prod-episode, /prod-research, /prod-script, /prod-audio
        """

        # 1. Parse and validate command
        execution_plan = self.parse_production_command(command, args)

        # 2. Pre-execution validation
        await self.validate_pre_execution(execution_plan)

        # 3. Configure LangGraph execution
        subprocess_config = self.configure_langgraph_execution(execution_plan)

        # 4. Execute with monitoring
        result = await self.execute_with_monitoring(subprocess_config)

        # 5. Post-process results
        formatted_result = self.format_results_for_claude(result)

        return formatted_result
```

## 🚀 COMMAND IMPLEMENTATIONS

### **Full Episode Production: /prod-episode**

```python
async def handle_prod_episode(self, topic: str, **kwargs) -> Dict[str, Any]:
    """
    Execute full episode production via LangGraph
    Usage: /prod-episode "Quantum Computing Myths"
    """

    episode_id = kwargs.get("episode_id", f"ep_{datetime.now().strftime('%Y%m%d_%H%M%S')}")
    budget_limit = kwargs.get("budget", 5.51)
    quality_threshold = kwargs.get("quality_threshold", 8.0)

    # Build subprocess command
    cmd = [
        "python", "main.py",
        "--topic", topic,
        "--episode-id", episode_id,
        "--budget", str(budget_limit),
        "--quality-threshold", str(quality_threshold),
        "--mode", "production",
        "--output-format", "json"
    ]

    # Execute with full monitoring
    execution_result = await self.execute_langgraph_subprocess(
        cmd=cmd,
        working_dir="podcast_production",
        timeout=1800,  # 30 minutes
        monitor_interval=5
    )

    # Process results for Claude interface
    return {
        "command": "prod-episode",
        "episode_id": episode_id,
        "topic": topic,
        "status": execution_result["status"],
        "final_cost": execution_result.get("total_cost", 0),
        "quality_score": execution_result.get("overall_quality", 0),
        "output_files": execution_result.get("output_files", []),
        "execution_time": execution_result.get("duration", 0),
        "error_message": execution_result.get("error", None)
    }
```

### **Research Pipeline Only: /prod-research**

```python
async def handle_prod_research(self, topic: str, **kwargs) -> Dict[str, Any]:
    """
    Execute research pipeline only via LangGraph
    Usage: /prod-research "AI Safety Misconceptions"
    """

    episode_id = kwargs.get("episode_id", f"research_{datetime.now().strftime('%Y%m%d_%H%M%S')}")
    research_budget = kwargs.get("budget", 2.0)  # Research pipeline budget

    cmd = [
        "python", "workflows/research_pipeline.py",
        "--topic", topic,
        "--episode-id", episode_id,
        "--budget", str(research_budget),
        "--output-format", "json"
    ]

    execution_result = await self.execute_langgraph_subprocess(
        cmd=cmd,
        working_dir="podcast_production",
        timeout=600,  # 10 minutes
        monitor_interval=3
    )

    return {
        "command": "prod-research",
        "episode_id": episode_id,
        "topic": topic,
        "research_data": execution_result.get("research_synthesis", {}),
        "sources_found": len(execution_result.get("sources", [])),
        "cost": execution_result.get("total_cost", 0),
        "duration": execution_result.get("duration", 0)
    }
```

## 🔄 SUBPROCESS EXECUTION ENGINE

### **Core Execution Framework**

```python
import asyncio
import json
import subprocess
from typing import Dict, Any, Optional

class LangGraphExecutor:
    """Advanced subprocess executor for LangGraph workflows"""

    async def execute_langgraph_subprocess(self,
                                         cmd: List[str],
                                         working_dir: str,
                                         timeout: int = 1800,
                                         monitor_interval: int = 5) -> Dict[str, Any]:
        """
        Execute LangGraph subprocess with comprehensive monitoring
        """

        start_time = datetime.now()

        try:
            # 1. Create subprocess with proper configuration
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=working_dir,
                env=self.prepare_environment_variables()
            )

            # 2. Create monitoring task
            monitor_task = asyncio.create_task(
                self.monitor_process_execution(process, monitor_interval)
            )

            # 3. Wait for completion with timeout
            try:
                stdout, stderr = await asyncio.wait_for(
                    process.communicate(),
                    timeout=timeout
                )
            except asyncio.TimeoutError:
                process.kill()
                await process.wait()
                raise ExecutionTimeoutException(f"Process timed out after {timeout}s")

            # 4. Cancel monitoring
            monitor_task.cancel()

            # 5. Process results
            execution_time = (datetime.now() - start_time).total_seconds()

            return {
                "status": "success" if process.returncode == 0 else "error",
                "return_code": process.returncode,
                "stdout": stdout.decode() if stdout else "",
                "stderr": stderr.decode() if stderr else "",
                "duration": execution_time,
                "parsed_output": self.parse_langgraph_output(stdout)
            }

        except Exception as e:
            return {
                "status": "error",
                "error": str(e),
                "duration": (datetime.now() - start_time).total_seconds()
            }
```

### **Process Monitoring System**

```python
async def monitor_process_execution(self,
                                  process: asyncio.subprocess.Process,
                                  interval: int) -> None:
    """
    Monitor LangGraph process execution with real-time updates
    """

    while process.returncode is None:
        # Check process status
        try:
            # Monitor memory usage
            memory_usage = self.get_process_memory_usage(process.pid)

            # Check for output files (indicates progress)
            output_files = self.scan_output_directory()

            # Monitor cost accumulation if available
            current_cost = self.check_current_cost_estimate()

            # Log progress update
            progress_update = {
                "timestamp": datetime.now().isoformat(),
                "memory_mb": memory_usage,
                "output_files": len(output_files),
                "estimated_cost": current_cost,
                "status": "running"
            }

            await self.send_progress_update(progress_update)

        except Exception as e:
            logger.warning(f"Monitoring error: {e}")

        await asyncio.sleep(interval)
```

## 📊 RESULT PROCESSING & FORMATTING

### **LangGraph Output Parser**

```python
class LangGraphResultParser:
    """Parse and format LangGraph output for Claude Code consumption"""

    def parse_langgraph_output(self, stdout_bytes: bytes) -> Dict[str, Any]:
        """Parse structured output from LangGraph execution"""

        try:
            stdout_str = stdout_bytes.decode()

            # Look for JSON output blocks
            json_blocks = self.extract_json_blocks(stdout_str)

            if json_blocks:
                # Use the last (final) JSON block
                final_output = json.loads(json_blocks[-1])
                return self.validate_and_format_output(final_output)
            else:
                # Parse text output
                return self.parse_text_output(stdout_str)

        except Exception as e:
            logger.error(f"Failed to parse LangGraph output: {e}")
            return {
                "parse_error": str(e),
                "raw_output": stdout_str[:1000]  # First 1000 chars
            }

    def format_results_for_claude(self, execution_result: Dict[str, Any]) -> Dict[str, Any]:
        """Format results for Claude Code interface display"""

        formatted = {
            "✅ **Execution Status**": execution_result.get("status", "unknown"),
            "💰 **Total Cost**": f"${execution_result.get('total_cost', 0):.2f}",
            "⏱️ **Duration**": f"{execution_result.get('duration', 0):.1f}s",
            "📊 **Quality Score**": f"{execution_result.get('overall_quality', 0):.1f}/10",
        }

        if execution_result.get("output_files"):
            formatted["📁 **Output Files**"] = execution_result["output_files"]

        if execution_result.get("error"):
            formatted["❌ **Error**"] = execution_result["error"]

        return formatted
```

## 🚨 ERROR HANDLING & RECOVERY

### **Error Classification System**

```python
class ProductionErrorHandler:
    """Handle various error scenarios in production orchestration"""

    def classify_error(self, error_info: Dict[str, Any]) -> str:
        """Classify error type for appropriate handling"""

        error_message = error_info.get("stderr", "").lower()
        return_code = error_info.get("return_code", 0)

        if "budget exceeded" in error_message or "cost limit" in error_message:
            return "BUDGET_EXCEEDED"
        elif "api key" in error_message or "authentication" in error_message:
            return "API_AUTH_ERROR"
        elif "timeout" in error_message or return_code == 124:
            return "TIMEOUT_ERROR"
        elif "memory" in error_message or "out of memory" in error_message:
            return "MEMORY_ERROR"
        elif return_code != 0:
            return "EXECUTION_ERROR"
        else:
            return "UNKNOWN_ERROR"

    async def handle_classified_error(self, error_type: str, error_info: Dict[str, Any]) -> Dict[str, Any]:
        """Handle errors based on classification"""

        handlers = {
            "BUDGET_EXCEEDED": self.handle_budget_exceeded,
            "API_AUTH_ERROR": self.handle_auth_error,
            "TIMEOUT_ERROR": self.handle_timeout_error,
            "MEMORY_ERROR": self.handle_memory_error,
            "EXECUTION_ERROR": self.handle_execution_error,
            "UNKNOWN_ERROR": self.handle_unknown_error
        }

        handler = handlers.get(error_type, self.handle_unknown_error)
        return await handler(error_info)
```

## 🎯 CONFIGURATION MANAGEMENT

### **Execution Configuration**

```python
class ExecutionConfig:
    """Configuration for LangGraph execution parameters"""

    def __init__(self):
        self.default_timeout = 1800  # 30 minutes
        self.default_budget = 5.51
        self.default_quality_threshold = 8.0
        self.monitoring_interval = 5
        self.max_retries = 3
        self.retry_delay = 60  # seconds

    def get_config_for_command(self, command: str) -> Dict[str, Any]:
        """Get specialized config for different commands"""

        configs = {
            "prod-episode": {
                "timeout": 1800,
                "budget": 5.51,
                "quality_threshold": 8.0,
                "retry_enabled": True
            },
            "prod-research": {
                "timeout": 600,
                "budget": 2.0,
                "quality_threshold": 7.0,
                "retry_enabled": True
            },
            "prod-script": {
                "timeout": 900,
                "budget": 2.5,
                "quality_threshold": 8.5,
                "retry_enabled": True
            },
            "prod-audio": {
                "timeout": 600,
                "budget": 1.5,
                "quality_threshold": 8.0,
                "retry_enabled": False  # Audio synthesis shouldn't retry
            }
        }

        return configs.get(command, self.get_default_config())
```

## 💡 ORCHESTRATION PRINCIPLES

**Technical**:
- Subprocess isolation ensures LangGraph independence
- Asynchronous monitoring enables real-time feedback
- Structured communication via JSON prevents parsing errors
- Comprehensive error handling ensures reliability

**Simple**:
- Think of this as a smart remote control for a complex machine
- Claude Code = User pressing buttons on remote control
- Orchestrator = Remote control logic that translates button presses
- LangGraph = Complex machine doing the actual work
- Monitoring = Display on remote showing machine status

**Connection**:
- This teaches subprocess management and inter-process communication
- Process monitoring and health checking strategies
- Error handling and recovery in distributed systems
- Production orchestration and reliability engineering

## 🔧 TODOWRITE INTEGRATION

**Orchestration Tasks**:
```python
# TODOWRITE: production-orchestrator - Implement {command} handler
# TODOWRITE: production-orchestrator - Add monitoring for {workflow_type}
# TODOWRITE: production-orchestrator - Handle {error_type} recovery
# TODOWRITE: production-orchestrator - Optimize subprocess communication
```

**Integration Tasks**:
```python
# TODOWRITE: monitor-agent - Connect to production-orchestrator monitoring
# TODOWRITE: recovery-agent - Integrate with production-orchestrator error handling
# TODOWRITE: cost-monitor - Track costs during production-orchestrator execution
```

---

**Agent Type**: Bridge
**Specialization**: Claude Code → LangGraph Production Orchestration
**Version**: 1.0.0
**Updated**: 2025-09-01
