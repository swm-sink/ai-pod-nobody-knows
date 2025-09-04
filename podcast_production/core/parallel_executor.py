"""
Parallel Task Executor for LangGraph Workflows

This module provides production-grade parallel execution capabilities
for LangGraph workflows with state management and synchronization.

Version: 1.0.0
Date: September 2025
"""

import asyncio
import logging
import time
from typing import Dict, Any, List, Callable, Optional, Set, TypeVar, Union
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
import inspect

from core.state import PodcastState

logger = logging.getLogger(__name__)

T = TypeVar('T')


class TaskPriority(Enum):
    """Task execution priority levels"""
    CRITICAL = 1
    HIGH = 2
    NORMAL = 3
    LOW = 4
    BACKGROUND = 5


class DependencyType(Enum):
    """Types of task dependencies"""
    REQUIRES = "requires"  # Must complete before
    CONFLICTS = "conflicts"  # Cannot run simultaneously
    PREFERS = "prefers"  # Soft dependency


@dataclass
class TaskResult:
    """Result of a parallel task execution"""
    task_id: str
    success: bool
    result: Any
    error: Optional[Exception] = None
    start_time: datetime = field(default_factory=datetime.now)
    end_time: Optional[datetime] = None
    duration_ms: float = 0.0
    
    def complete(self, result: Any = None, error: Exception = None):
        """Mark task as complete"""
        self.end_time = datetime.now()
        self.duration_ms = (self.end_time - self.start_time).total_seconds() * 1000
        
        if error:
            self.success = False
            self.error = error
        else:
            self.success = True
            self.result = result


@dataclass
class ParallelTask:
    """Definition of a parallelizable task"""
    task_id: str
    function: Callable
    args: tuple = field(default_factory=tuple)
    kwargs: dict = field(default_factory=dict)
    priority: TaskPriority = TaskPriority.NORMAL
    dependencies: Dict[str, DependencyType] = field(default_factory=dict)
    timeout: Optional[float] = None
    retries: int = 0
    state_fields: Set[str] = field(default_factory=set)  # State fields this task reads/writes


class ParallelExecutor:
    """
    Manages parallel task execution for LangGraph workflows.
    
    Features:
    - Dependency resolution
    - Priority-based scheduling
    - State isolation and merging
    - Resource management
    - Progress tracking
    """
    
    def __init__(
        self,
        max_concurrent: int = 5,
        enable_monitoring: bool = True,
        default_timeout: float = 60.0
    ):
        """
        Initialize parallel executor.
        
        Args:
            max_concurrent: Maximum concurrent tasks
            enable_monitoring: Enable task monitoring
            default_timeout: Default task timeout
        """
        self.max_concurrent = max_concurrent
        self.enable_monitoring = enable_monitoring
        self.default_timeout = default_timeout
        
        # Execution state
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.running_tasks: Set[str] = set()
        self.completed_tasks: Dict[str, TaskResult] = {}
        self.task_queue: List[ParallelTask] = []
        
        logger.info(f"Initialized ParallelExecutor with max_concurrent={max_concurrent}")
    
    def identify_parallelizable_nodes(
        self,
        state: PodcastState,
        workflow_stage: str
    ) -> List[ParallelTask]:
        """
        Identify tasks that can be executed in parallel.
        
        Args:
            state: Current workflow state
            workflow_stage: Current workflow stage
            
        Returns:
            List of parallelizable tasks
        """
        tasks = []
        
        # Research phase parallelization
        if workflow_stage == "research" and state.get("topic"):
            # Multiple research queries can run in parallel
            tasks.extend([
                ParallelTask(
                    task_id="research_academic",
                    function=self._research_academic_sources,
                    kwargs={"topic": state["topic"]},
                    priority=TaskPriority.HIGH,
                    state_fields={"research_data"}
                ),
                ParallelTask(
                    task_id="research_news",
                    function=self._research_news_sources,
                    kwargs={"topic": state["topic"]},
                    priority=TaskPriority.HIGH,
                    state_fields={"research_data"}
                ),
                ParallelTask(
                    task_id="research_expert",
                    function=self._research_expert_opinions,
                    kwargs={"topic": state["topic"]},
                    priority=TaskPriority.NORMAL,
                    state_fields={"research_data"}
                )
            ])
        
        # Quality evaluation parallelization
        elif workflow_stage == "quality" and state.get("script"):
            tasks.extend([
                ParallelTask(
                    task_id="eval_claude",
                    function=self._evaluate_with_claude,
                    kwargs={"script": state["script"]},
                    priority=TaskPriority.HIGH,
                    state_fields={"quality_scores"}
                ),
                ParallelTask(
                    task_id="eval_gemini",
                    function=self._evaluate_with_gemini,
                    kwargs={"script": state["script"]},
                    priority=TaskPriority.HIGH,
                    state_fields={"quality_scores"}
                ),
                ParallelTask(
                    task_id="eval_brand",
                    function=self._evaluate_brand_consistency,
                    kwargs={"script": state["script"]},
                    priority=TaskPriority.NORMAL,
                    state_fields={"brand_scores"}
                )
            ])
        
        # Audio preprocessing parallelization
        elif workflow_stage == "production" and state.get("script_polished"):
            tasks.extend([
                ParallelTask(
                    task_id="preprocess_ssml",
                    function=self._preprocess_ssml,
                    kwargs={"script": state["script_polished"]},
                    priority=TaskPriority.HIGH,
                    state_fields={"ssml_script"}
                ),
                ParallelTask(
                    task_id="optimize_chunks",
                    function=self._optimize_audio_chunks,
                    kwargs={"script": state["script_polished"]},
                    priority=TaskPriority.NORMAL,
                    state_fields={"audio_chunks"}
                )
            ])
        
        return tasks
    
    async def execute_parallel(
        self,
        tasks: List[ParallelTask],
        state: PodcastState,
        merge_strategy: str = "update"
    ) -> PodcastState:
        """
        Execute tasks in parallel with state management.
        
        Args:
            tasks: List of tasks to execute
            state: Current state
            merge_strategy: How to merge results ("update", "append", "replace")
            
        Returns:
            Updated state with merged results
        """
        if not tasks:
            return state
        
        logger.info(f"Executing {len(tasks)} tasks in parallel")
        
        # Sort tasks by priority
        tasks.sort(key=lambda t: t.priority.value)
        
        # Resolve dependencies and create execution plan
        execution_plan = self._resolve_dependencies(tasks)
        
        # Execute tasks in waves based on dependencies
        results = []
        for wave in execution_plan:
            wave_results = await self._execute_wave(wave, state)
            results.extend(wave_results)
        
        # Merge results back into state
        updated_state = self._merge_results(state, results, merge_strategy)
        
        # Log execution summary
        self._log_execution_summary(results)
        
        return updated_state
    
    def _resolve_dependencies(self, tasks: List[ParallelTask]) -> List[List[ParallelTask]]:
        """
        Resolve task dependencies and create execution waves.
        
        Returns:
            List of task waves (tasks in same wave can run in parallel)
        """
        waves = []
        remaining = tasks.copy()
        completed_ids = set()
        
        while remaining:
            current_wave = []
            
            for task in remaining[:]:
                # Check if all dependencies are satisfied
                can_execute = True
                
                for dep_id, dep_type in task.dependencies.items():
                    if dep_type == DependencyType.REQUIRES:
                        if dep_id not in completed_ids:
                            can_execute = False
                            break
                    elif dep_type == DependencyType.CONFLICTS:
                        # Check if conflicting task is in current wave
                        if any(t.task_id == dep_id for t in current_wave):
                            can_execute = False
                            break
                
                if can_execute:
                    current_wave.append(task)
                    remaining.remove(task)
            
            if current_wave:
                waves.append(current_wave)
                completed_ids.update(t.task_id for t in current_wave)
            else:
                # Circular dependency or unresolvable conflict
                logger.warning(f"Could not resolve dependencies for tasks: {[t.task_id for t in remaining]}")
                waves.append(remaining)  # Execute remaining as best effort
                break
        
        return waves
    
    async def _execute_wave(
        self,
        tasks: List[ParallelTask],
        state: PodcastState
    ) -> List[TaskResult]:
        """
        Execute a wave of parallel tasks.
        
        Args:
            tasks: Tasks to execute in parallel
            state: Current state
            
        Returns:
            List of task results
        """
        logger.info(f"Executing wave with {len(tasks)} parallel tasks")
        
        # Create coroutines for all tasks
        coroutines = []
        for task in tasks:
            coro = self._execute_single_task(task, state)
            coroutines.append(coro)
        
        # Execute all tasks concurrently
        results = await asyncio.gather(*coroutines, return_exceptions=True)
        
        # Convert to TaskResult objects
        task_results = []
        for task, result in zip(tasks, results):
            if isinstance(result, Exception):
                task_result = TaskResult(
                    task_id=task.task_id,
                    success=False,
                    result=None,
                    error=result
                )
            else:
                task_result = result
            
            task_result.complete()
            task_results.append(task_result)
            self.completed_tasks[task.task_id] = task_result
        
        return task_results
    
    async def _execute_single_task(
        self,
        task: ParallelTask,
        state: PodcastState
    ) -> TaskResult:
        """
        Execute a single task with resource management.
        
        Args:
            task: Task to execute
            state: Current state
            
        Returns:
            Task result
        """
        async with self.semaphore:  # Limit concurrent executions
            task_result = TaskResult(task_id=task.task_id, success=False, result=None)
            
            try:
                self.running_tasks.add(task.task_id)
                logger.debug(f"Starting task: {task.task_id}")
                
                # Apply timeout if specified
                timeout = task.timeout or self.default_timeout
                
                # Create isolated state slice for task
                task_state = self._create_task_state(state, task.state_fields)
                
                # Execute with timeout
                if inspect.iscoroutinefunction(task.function):
                    result = await asyncio.wait_for(
                        task.function(*task.args, state=task_state, **task.kwargs),
                        timeout=timeout
                    )
                else:
                    # Run sync function in executor
                    result = await asyncio.wait_for(
                        asyncio.get_event_loop().run_in_executor(
                            None,
                            task.function,
                            *task.args,
                            task_state,
                            *task.kwargs.values()
                        ),
                        timeout=timeout
                    )
                
                task_result.result = result
                task_result.success = True
                logger.debug(f"Completed task: {task.task_id}")
                
            except asyncio.TimeoutError:
                task_result.error = TimeoutError(f"Task {task.task_id} timed out after {timeout}s")
                logger.error(f"Task timeout: {task.task_id}")
                
            except Exception as e:
                task_result.error = e
                logger.error(f"Task failed: {task.task_id} - {e}")
                
                # Retry if configured
                if task.retries > 0:
                    logger.info(f"Retrying task {task.task_id} ({task.retries} retries left)")
                    task.retries -= 1
                    return await self._execute_single_task(task, state)
            
            finally:
                self.running_tasks.discard(task.task_id)
                task_result.complete()
            
            return task_result
    
    def _create_task_state(self, state: PodcastState, fields: Set[str]) -> Dict[str, Any]:
        """
        Create isolated state slice for task.
        
        Args:
            state: Full state
            fields: Fields the task needs access to
            
        Returns:
            Isolated state slice
        """
        task_state = {}
        
        # Copy only required fields
        for field in fields:
            if field in state:
                # Deep copy to prevent mutations
                import copy
                task_state[field] = copy.deepcopy(state[field])
        
        # Add read-only fields
        task_state["episode_id"] = state.get("episode_id")
        task_state["topic"] = state.get("topic")
        
        return task_state
    
    def _merge_results(
        self,
        state: PodcastState,
        results: List[TaskResult],
        strategy: str
    ) -> PodcastState:
        """
        Merge task results back into state.
        
        Args:
            state: Current state
            results: Task results
            strategy: Merge strategy
            
        Returns:
            Updated state
        """
        updated_state = state.copy()
        
        for result in results:
            if not result.success:
                # Track errors
                if "errors" not in updated_state:
                    updated_state["errors"] = []
                updated_state["errors"].append({
                    "task": result.task_id,
                    "error": str(result.error),
                    "timestamp": result.end_time.isoformat() if result.end_time else None
                })
                continue
            
            # Merge successful results
            if isinstance(result.result, dict):
                if strategy == "update":
                    # Update existing fields
                    for key, value in result.result.items():
                        if key in updated_state and isinstance(updated_state[key], dict):
                            updated_state[key].update(value)
                        else:
                            updated_state[key] = value
                            
                elif strategy == "append":
                    # Append to lists
                    for key, value in result.result.items():
                        if key in updated_state and isinstance(updated_state[key], list):
                            updated_state[key].extend(value if isinstance(value, list) else [value])
                        else:
                            updated_state[key] = value
                            
                elif strategy == "replace":
                    # Replace entirely
                    updated_state.update(result.result)
        
        # Update execution metadata
        updated_state["parallel_execution"] = {
            "tasks_executed": len(results),
            "successful": sum(1 for r in results if r.success),
            "failed": sum(1 for r in results if not r.success),
            "total_duration_ms": sum(r.duration_ms for r in results),
            "max_duration_ms": max((r.duration_ms for r in results), default=0)
        }
        
        return updated_state
    
    def _log_execution_summary(self, results: List[TaskResult]):
        """Log execution summary"""
        successful = sum(1 for r in results if r.success)
        failed = sum(1 for r in results if not r.success)
        total_time = sum(r.duration_ms for r in results)
        
        logger.info(
            f"Parallel execution complete: "
            f"{successful} successful, {failed} failed, "
            f"total time: {total_time:.2f}ms"
        )
        
        if failed > 0:
            for result in results:
                if not result.success:
                    logger.error(f"Task {result.task_id} failed: {result.error}")
    
    # Placeholder task functions (would be actual agent calls)
    async def _research_academic_sources(self, state: Dict, topic: str) -> Dict[str, Any]:
        """Placeholder for academic research"""
        await asyncio.sleep(0.1)  # Simulate work
        return {"research_data": {"academic": f"Academic data for {topic}"}}
    
    async def _research_news_sources(self, state: Dict, topic: str) -> Dict[str, Any]:
        """Placeholder for news research"""
        await asyncio.sleep(0.1)  # Simulate work
        return {"research_data": {"news": f"News data for {topic}"}}
    
    async def _research_expert_opinions(self, state: Dict, topic: str) -> Dict[str, Any]:
        """Placeholder for expert research"""
        await asyncio.sleep(0.1)  # Simulate work
        return {"research_data": {"expert": f"Expert opinions for {topic}"}}
    
    async def _evaluate_with_claude(self, state: Dict, script: str) -> Dict[str, Any]:
        """Placeholder for Claude evaluation"""
        await asyncio.sleep(0.1)  # Simulate work
        return {"quality_scores": {"claude": 8.5}}
    
    async def _evaluate_with_gemini(self, state: Dict, script: str) -> Dict[str, Any]:
        """Placeholder for Gemini evaluation"""
        await asyncio.sleep(0.1)  # Simulate work
        return {"quality_scores": {"gemini": 8.2}}
    
    async def _evaluate_brand_consistency(self, state: Dict, script: str) -> Dict[str, Any]:
        """Placeholder for brand evaluation"""
        await asyncio.sleep(0.1)  # Simulate work
        return {"brand_scores": {"consistency": 0.87}}
    
    async def _preprocess_ssml(self, state: Dict, script: str) -> Dict[str, Any]:
        """Placeholder for SSML preprocessing"""
        await asyncio.sleep(0.1)  # Simulate work
        return {"ssml_script": f"<speak>{script}</speak>"}
    
    async def _optimize_audio_chunks(self, state: Dict, script: str) -> Dict[str, Any]:
        """Placeholder for audio chunk optimization"""
        await asyncio.sleep(0.1)  # Simulate work
        return {"audio_chunks": ["chunk1", "chunk2", "chunk3"]}
    
    def get_execution_stats(self) -> Dict[str, Any]:
        """Get execution statistics"""
        return {
            "running": list(self.running_tasks),
            "completed": len(self.completed_tasks),
            "successful": sum(1 for t in self.completed_tasks.values() if t.success),
            "failed": sum(1 for t in self.completed_tasks.values() if not t.success),
            "avg_duration_ms": sum(t.duration_ms for t in self.completed_tasks.values()) / max(len(self.completed_tasks), 1)
        }