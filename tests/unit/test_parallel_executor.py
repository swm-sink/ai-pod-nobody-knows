"""
Test suite for Parallel Executor functionality.
Tests concurrent task execution and resource management.
September 2025 patterns.
"""

import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
import time
from typing import List, Any

from podcast_production.core.parallel_executor import (
    ParallelExecutor,
    ParallelTask,
    TaskPriority
)


class TestParallelExecutor:
    """Test parallel execution functionality"""
    
    @pytest.fixture
    def executor(self):
        """Create parallel executor instance"""
        return ParallelExecutor(
            max_concurrent=5,
            enable_monitoring=True
        )
    
    @pytest.fixture
    def mock_tasks(self):
        """Create mock tasks for testing"""
        async def task1():
            await asyncio.sleep(0.1)
            return {"result": "task1_complete"}
        
        async def task2():
            await asyncio.sleep(0.2)
            return {"result": "task2_complete"}
        
        async def task3():
            await asyncio.sleep(0.05)
            return {"result": "task3_complete"}
        
        return [
            ParallelTask(name="task1", func=task1, priority=TaskPriority.HIGH),
            ParallelTask(name="task2", func=task2, priority=TaskPriority.MEDIUM),
            ParallelTask(name="task3", func=task3, priority=TaskPriority.LOW)
        ]
    
    @pytest.mark.asyncio
    async def test_executor_initialization(self, executor):
        """Test executor initialization"""
        assert executor.max_concurrent == 5
        assert executor.enable_monitoring == True
        assert executor._active_tasks == 0
    
    @pytest.mark.asyncio
    async def test_single_task_execution(self, executor):
        """Test single task execution"""
        async def test_task():
            return {"status": "success"}
        
        task = ParallelTask(name="test", func=test_task)
        result = await executor.execute_single(task)
        
        assert result == {"status": "success"}
    
    @pytest.mark.asyncio
    async def test_parallel_execution(self, executor, mock_tasks):
        """Test parallel execution of multiple tasks"""
        start_time = time.time()
        results = await executor.execute_batch(mock_tasks)
        execution_time = time.time() - start_time
        
        # All tasks should complete
        assert len(results) == 3
        assert all("result" in r for r in results)
        
        # Should run in parallel (faster than sequential)
        # Sequential would take 0.1 + 0.2 + 0.05 = 0.35s
        # Parallel should take ~0.2s (longest task)
        assert execution_time < 0.3  # Allow some overhead
    
    @pytest.mark.asyncio
    async def test_priority_ordering(self, executor, mock_tasks):
        """Test tasks are executed in priority order"""
        execution_order = []
        
        async def track_execution(name):
            execution_order.append(name)
            await asyncio.sleep(0.01)
            return {"name": name}
        
        tasks = [
            ParallelTask(name="low", func=lambda: track_execution("low"), 
                        priority=TaskPriority.LOW),
            ParallelTask(name="high", func=lambda: track_execution("high"), 
                        priority=TaskPriority.HIGH),
            ParallelTask(name="medium", func=lambda: track_execution("medium"), 
                        priority=TaskPriority.MEDIUM)
        ]
        
        await executor.execute_batch(tasks)
        
        # High priority should start first
        assert execution_order[0] == "high"
    
    @pytest.mark.asyncio
    async def test_concurrent_limit(self, executor):
        """Test max concurrent tasks limit"""
        executor.max_concurrent = 2  # Limit to 2 concurrent
        
        async def slow_task(id):
            await asyncio.sleep(0.1)
            return {"id": id}
        
        tasks = [
            ParallelTask(name=f"task{i}", func=lambda i=i: slow_task(i))
            for i in range(5)
        ]
        
        # Monitor active tasks during execution
        max_active = 0
        
        async def monitor():
            nonlocal max_active
            while executor._active_tasks > 0 or not executor._started:
                max_active = max(max_active, executor._active_tasks)
                await asyncio.sleep(0.01)
        
        # Run tasks with monitoring
        monitor_task = asyncio.create_task(monitor())
        results = await executor.execute_batch(tasks)
        await monitor_task
        
        # Should never exceed concurrent limit
        assert max_active <= 2
        assert len(results) == 5
    
    @pytest.mark.asyncio
    async def test_error_handling(self, executor):
        """Test error handling in parallel execution"""
        async def failing_task():
            raise ValueError("Task failed")
        
        async def successful_task():
            return {"status": "success"}
        
        tasks = [
            ParallelTask(name="fail", func=failing_task),
            ParallelTask(name="success", func=successful_task)
        ]
        
        results = await executor.execute_batch(tasks, return_exceptions=True)
        
        # Should capture exception without failing other tasks
        assert len(results) == 2
        assert isinstance(results[0], ValueError)
        assert results[1] == {"status": "success"}
    
    @pytest.mark.asyncio
    async def test_task_cancellation(self, executor):
        """Test task cancellation"""
        async def long_task():
            try:
                await asyncio.sleep(10)
                return {"status": "complete"}
            except asyncio.CancelledError:
                return {"status": "cancelled"}
        
        task = ParallelTask(name="long", func=long_task)
        
        # Start task and cancel
        execution = asyncio.create_task(executor.execute_single(task))
        await asyncio.sleep(0.1)  # Let it start
        execution.cancel()
        
        try:
            result = await execution
        except asyncio.CancelledError:
            result = {"status": "cancelled"}
        
        assert result["status"] == "cancelled"
    
    @pytest.mark.asyncio
    async def test_metrics_collection(self, executor, mock_tasks):
        """Test metrics collection during execution"""
        await executor.execute_batch(mock_tasks)
        
        metrics = executor.get_metrics()
        
        assert metrics["total_tasks"] == 3
        assert metrics["successful_tasks"] == 3
        assert metrics["failed_tasks"] == 0
        assert "average_execution_time" in metrics
        assert metrics["average_execution_time"] > 0
    
    @pytest.mark.asyncio
    async def test_resource_cleanup(self, executor):
        """Test proper resource cleanup after execution"""
        async def resource_task():
            # Simulate resource allocation
            resource = {"allocated": True}
            try:
                await asyncio.sleep(0.1)
                return resource
            finally:
                # Cleanup
                resource["allocated"] = False
        
        task = ParallelTask(name="resource", func=resource_task)
        result = await executor.execute_single(task)
        
        # Resource should be cleaned up
        assert result["allocated"] == False
        assert executor._active_tasks == 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])