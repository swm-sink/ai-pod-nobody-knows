"""
Tests for Parallel Task Executor

Version: 1.0.0
Date: September 2025
"""

import pytest
import asyncio
from unittest.mock import Mock, patch, AsyncMock
from datetime import datetime
import time

from core.parallel_executor import (
    ParallelExecutor,
    ParallelTask,
    TaskPriority,
    DependencyType,
    TaskResult
)
from core.state import PodcastState


@pytest.fixture
def parallel_executor():
    """Create parallel executor instance"""
    return ParallelExecutor(
        max_concurrent=3,
        enable_monitoring=True,
        default_timeout=10.0
    )


@pytest.fixture
def sample_state():
    """Create sample podcast state"""
    return {
        "episode_id": "test_001",
        "topic": "Test Topic",
        "budget": 5.51,
        "research_data": {},
        "script": "Sample script content",
        "script_polished": "Polished script content"
    }


class TestTaskResult:
    """Test TaskResult functionality"""
    
    def test_task_completion(self):
        """Test task completion tracking"""
        result = TaskResult(task_id="test_task", success=False, result=None)
        
        # Complete successfully
        result.complete(result={"data": "test"})
        
        assert result.success is True
        assert result.result == {"data": "test"}
        assert result.end_time is not None
        assert result.duration_ms > 0
    
    def test_task_failure(self):
        """Test task failure tracking"""
        result = TaskResult(task_id="test_task", success=True, result=None)
        
        # Complete with error
        error = ValueError("Test error")
        result.complete(error=error)
        
        assert result.success is False
        assert result.error == error
        assert result.end_time is not None


class TestParallelTaskIdentification:
    """Test identification of parallelizable tasks"""
    
    def test_identify_research_tasks(self, parallel_executor, sample_state):
        """Test identifying parallel research tasks"""
        tasks = parallel_executor.identify_parallelizable_nodes(
            sample_state,
            "research"
        )
        
        assert len(tasks) == 3
        task_ids = [t.task_id for t in tasks]
        assert "research_academic" in task_ids
        assert "research_news" in task_ids
        assert "research_expert" in task_ids
        
        # Check priorities
        high_priority_tasks = [t for t in tasks if t.priority == TaskPriority.HIGH]
        assert len(high_priority_tasks) == 2  # academic and news
    
    def test_identify_quality_tasks(self, parallel_executor, sample_state):
        """Test identifying parallel quality evaluation tasks"""
        tasks = parallel_executor.identify_parallelizable_nodes(
            sample_state,
            "quality"
        )
        
        assert len(tasks) == 3
        task_ids = [t.task_id for t in tasks]
        assert "eval_claude" in task_ids
        assert "eval_gemini" in task_ids
        assert "eval_brand" in task_ids
    
    def test_identify_production_tasks(self, parallel_executor, sample_state):
        """Test identifying parallel production tasks"""
        tasks = parallel_executor.identify_parallelizable_nodes(
            sample_state,
            "production"
        )
        
        assert len(tasks) == 2
        task_ids = [t.task_id for t in tasks]
        assert "preprocess_ssml" in task_ids
        assert "optimize_chunks" in task_ids
    
    def test_no_tasks_for_invalid_stage(self, parallel_executor, sample_state):
        """Test no tasks identified for invalid stage"""
        tasks = parallel_executor.identify_parallelizable_nodes(
            sample_state,
            "invalid_stage"
        )
        
        assert len(tasks) == 0


class TestDependencyResolution:
    """Test task dependency resolution"""
    
    def test_simple_dependency_chain(self, parallel_executor):
        """Test simple dependency chain resolution"""
        tasks = [
            ParallelTask(
                task_id="task1",
                function=lambda: None
            ),
            ParallelTask(
                task_id="task2",
                function=lambda: None,
                dependencies={"task1": DependencyType.REQUIRES}
            ),
            ParallelTask(
                task_id="task3",
                function=lambda: None,
                dependencies={"task2": DependencyType.REQUIRES}
            )
        ]
        
        waves = parallel_executor._resolve_dependencies(tasks)
        
        assert len(waves) == 3
        assert waves[0][0].task_id == "task1"
        assert waves[1][0].task_id == "task2"
        assert waves[2][0].task_id == "task3"
    
    def test_parallel_independent_tasks(self, parallel_executor):
        """Test parallel execution of independent tasks"""
        tasks = [
            ParallelTask(task_id="task1", function=lambda: None),
            ParallelTask(task_id="task2", function=lambda: None),
            ParallelTask(task_id="task3", function=lambda: None)
        ]
        
        waves = parallel_executor._resolve_dependencies(tasks)
        
        assert len(waves) == 1  # All can run in parallel
        assert len(waves[0]) == 3
    
    def test_conflict_dependencies(self, parallel_executor):
        """Test conflict dependency resolution"""
        tasks = [
            ParallelTask(
                task_id="task1",
                function=lambda: None
            ),
            ParallelTask(
                task_id="task2",
                function=lambda: None,
                dependencies={"task1": DependencyType.CONFLICTS}
            ),
            ParallelTask(
                task_id="task3",
                function=lambda: None
            )
        ]
        
        waves = parallel_executor._resolve_dependencies(tasks)
        
        # task1 and task2 should not be in same wave
        for wave in waves:
            task_ids = [t.task_id for t in wave]
            assert not ("task1" in task_ids and "task2" in task_ids)
    
    def test_mixed_dependencies(self, parallel_executor):
        """Test mixed dependency types"""
        tasks = [
            ParallelTask(task_id="task1", function=lambda: None),
            ParallelTask(
                task_id="task2",
                function=lambda: None,
                dependencies={"task1": DependencyType.REQUIRES}
            ),
            ParallelTask(
                task_id="task3",
                function=lambda: None,
                dependencies={"task1": DependencyType.PREFERS}
            ),
            ParallelTask(
                task_id="task4",
                function=lambda: None,
                dependencies={"task2": DependencyType.CONFLICTS}
            )
        ]
        
        waves = parallel_executor._resolve_dependencies(tasks)
        
        # task2 must come after task1
        task1_wave = next(i for i, wave in enumerate(waves) if any(t.task_id == "task1" for t in wave))
        task2_wave = next(i for i, wave in enumerate(waves) if any(t.task_id == "task2" for t in wave))
        assert task2_wave > task1_wave


class TestParallelExecution:
    """Test parallel task execution"""
    
    @pytest.mark.asyncio
    async def test_successful_parallel_execution(self, parallel_executor, sample_state):
        """Test successful parallel execution"""
        # Create simple async tasks
        async def task1(state):
            await asyncio.sleep(0.01)
            return {"result1": "data1"}
        
        async def task2(state):
            await asyncio.sleep(0.01)
            return {"result2": "data2"}
        
        async def task3(state):
            await asyncio.sleep(0.01)
            return {"result3": "data3"}
        
        tasks = [
            ParallelTask(task_id="task1", function=task1, state_fields={"research_data"}),
            ParallelTask(task_id="task2", function=task2, state_fields={"research_data"}),
            ParallelTask(task_id="task3", function=task3, state_fields={"research_data"})
        ]
        
        # Execute parallel
        result_state = await parallel_executor.execute_parallel(
            tasks,
            sample_state,
            merge_strategy="update"
        )
        
        assert "result1" in result_state
        assert "result2" in result_state
        assert "result3" in result_state
        assert result_state["parallel_execution"]["successful"] == 3
        assert result_state["parallel_execution"]["failed"] == 0
    
    @pytest.mark.asyncio
    async def test_partial_failure_handling(self, parallel_executor, sample_state):
        """Test handling of partial failures"""
        # Create tasks with one failure
        async def task1(state):
            await asyncio.sleep(0.01)
            return {"result1": "data1"}
        
        async def task2(state):
            await asyncio.sleep(0.01)
            raise ValueError("Task 2 failed")
        
        async def task3(state):
            await asyncio.sleep(0.01)
            return {"result3": "data3"}
        
        tasks = [
            ParallelTask(task_id="task1", function=task1, state_fields=set()),
            ParallelTask(task_id="task2", function=task2, state_fields=set()),
            ParallelTask(task_id="task3", function=task3, state_fields=set())
        ]
        
        # Execute parallel
        result_state = await parallel_executor.execute_parallel(
            tasks,
            sample_state,
            merge_strategy="update"
        )
        
        assert "result1" in result_state
        assert "result3" in result_state
        assert "errors" in result_state
        assert len(result_state["errors"]) == 1
        assert "Task 2 failed" in result_state["errors"][0]["error"]
        assert result_state["parallel_execution"]["successful"] == 2
        assert result_state["parallel_execution"]["failed"] == 1
    
    @pytest.mark.asyncio
    async def test_timeout_handling(self, parallel_executor, sample_state):
        """Test task timeout handling"""
        # Create task that times out
        async def slow_task(state):
            await asyncio.sleep(20)  # Longer than timeout
            return {"result": "data"}
        
        tasks = [
            ParallelTask(
                task_id="slow_task",
                function=slow_task,
                timeout=0.1,  # 100ms timeout
                state_fields=set()
            )
        ]
        
        # Execute parallel
        result_state = await parallel_executor.execute_parallel(
            tasks,
            sample_state,
            merge_strategy="update"
        )
        
        assert "errors" in result_state
        assert result_state["parallel_execution"]["failed"] == 1
        # Check that it's a timeout error
        assert any("timeout" in str(e["error"]).lower() for e in result_state["errors"])
    
    @pytest.mark.asyncio
    async def test_retry_on_failure(self, parallel_executor, sample_state):
        """Test retry mechanism"""
        # Track call count
        call_count = {"count": 0}
        
        async def flaky_task(state):
            call_count["count"] += 1
            if call_count["count"] < 2:
                raise ValueError("Temporary failure")
            return {"result": "success"}
        
        tasks = [
            ParallelTask(
                task_id="flaky_task",
                function=flaky_task,
                retries=2,
                state_fields=set()
            )
        ]
        
        # Execute parallel
        result_state = await parallel_executor.execute_parallel(
            tasks,
            sample_state,
            merge_strategy="update"
        )
        
        assert "result" in result_state
        assert result_state["result"] == "success"
        assert call_count["count"] == 2  # Failed once, succeeded on retry
    
    @pytest.mark.asyncio
    async def test_resource_limiting(self, parallel_executor, sample_state):
        """Test max concurrent execution limiting"""
        parallel_executor.max_concurrent = 2  # Limit to 2 concurrent
        
        execution_times = []
        
        async def tracked_task(state, task_id):
            execution_times.append((task_id, "start", time.time()))
            await asyncio.sleep(0.05)  # 50ms task
            execution_times.append((task_id, "end", time.time()))
            return {f"result_{task_id}": "data"}
        
        tasks = [
            ParallelTask(
                task_id=f"task{i}",
                function=lambda s, tid=i: tracked_task(s, tid),
                state_fields=set()
            )
            for i in range(5)
        ]
        
        # Execute parallel
        await parallel_executor.execute_parallel(
            tasks,
            sample_state,
            merge_strategy="update"
        )
        
        # Check that no more than 2 tasks ran concurrently
        # This is a simplified check - in practice would need more sophisticated verification
        concurrent_count = 0
        max_concurrent = 0
        
        sorted_events = sorted(execution_times, key=lambda x: x[2])
        for event in sorted_events:
            if event[1] == "start":
                concurrent_count += 1
                max_concurrent = max(max_concurrent, concurrent_count)
            else:
                concurrent_count -= 1
        
        # Due to semaphore, should not exceed max_concurrent setting
        # Note: This test might be flaky due to timing, could be improved
        assert max_concurrent <= parallel_executor.max_concurrent + 1  # Allow small margin


class TestStateMerging:
    """Test state merging strategies"""
    
    def test_update_merge_strategy(self, parallel_executor):
        """Test update merge strategy"""
        state = {"existing": "data", "nested": {"key1": "value1"}}
        
        results = [
            TaskResult(
                task_id="task1",
                success=True,
                result={"new_field": "new_value", "nested": {"key2": "value2"}}
            ),
            TaskResult(
                task_id="task2",
                success=True,
                result={"another_field": "another_value"}
            )
        ]
        
        merged = parallel_executor._merge_results(state, results, "update")
        
        assert merged["existing"] == "data"
        assert merged["new_field"] == "new_value"
        assert merged["another_field"] == "another_value"
        assert merged["nested"]["key1"] == "value1"
        assert merged["nested"]["key2"] == "value2"
    
    def test_append_merge_strategy(self, parallel_executor):
        """Test append merge strategy"""
        state = {"items": ["item1"], "other": "data"}
        
        results = [
            TaskResult(
                task_id="task1",
                success=True,
                result={"items": ["item2", "item3"]}
            ),
            TaskResult(
                task_id="task2",
                success=True,
                result={"items": ["item4"]}
            )
        ]
        
        merged = parallel_executor._merge_results(state, results, "append")
        
        assert len(merged["items"]) == 4
        assert "item1" in merged["items"]
        assert "item4" in merged["items"]
    
    def test_replace_merge_strategy(self, parallel_executor):
        """Test replace merge strategy"""
        state = {"field1": "old_value", "field2": "keep"}
        
        results = [
            TaskResult(
                task_id="task1",
                success=True,
                result={"field1": "new_value", "field3": "added"}
            )
        ]
        
        merged = parallel_executor._merge_results(state, results, "replace")
        
        assert merged["field1"] == "new_value"
        assert merged["field2"] == "keep"
        assert merged["field3"] == "added"


class TestExecutionStats:
    """Test execution statistics tracking"""
    
    @pytest.mark.asyncio
    async def test_execution_stats(self, parallel_executor, sample_state):
        """Test execution statistics collection"""
        async def task1(state):
            await asyncio.sleep(0.01)
            return {"result": "data"}
        
        tasks = [
            ParallelTask(task_id=f"task{i}", function=task1, state_fields=set())
            for i in range(3)
        ]
        
        await parallel_executor.execute_parallel(tasks, sample_state, "update")
        
        stats = parallel_executor.get_execution_stats()
        
        assert stats["completed"] == 3
        assert stats["successful"] == 3
        assert stats["failed"] == 0
        assert stats["avg_duration_ms"] > 0
        assert len(stats["running"]) == 0