#!/usr/bin/env python3
"""
Production Health Check
AI Podcast Production System
"""

import asyncio
import json
import redis
from datetime import datetime, timezone
from pathlib import Path
import sys
sys.path.append('.')

from core.state_manager import StateManager
from core.cost_tracker import CostTracker

async def health_check():
    """Comprehensive system health check"""
    results = {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'status': 'healthy',
        'checks': {}
    }
    
    try:
        # Test Redis connection
        r = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)
        r.ping()
        results['checks']['redis'] = 'healthy'
    except Exception as e:
        results['checks']['redis'] = f'unhealthy: {str(e)}'
        results['status'] = 'degraded'
    
    try:
        # Test StateManager
        state_manager = StateManager()
        test_state = state_manager.get_state()
        results['checks']['state_manager'] = 'healthy'
    except Exception as e:
        results['checks']['state_manager'] = f'unhealthy: {str(e)}'
        results['status'] = 'degraded'
    
    try:
        # Test CostTracker
        cost_tracker = CostTracker(budget_limit=10.0)
        results['checks']['cost_tracker'] = 'healthy'
    except Exception as e:
        results['checks']['cost_tracker'] = f'unhealthy: {str(e)}'
        results['status'] = 'degraded'
    
    # Check disk space
    import shutil
    free_space_gb = shutil.disk_usage('.').free / (1024**3)
    if free_space_gb < 1.0:  # Less than 1GB
        results['checks']['disk_space'] = f'warning: {free_space_gb:.1f}GB remaining'
        results['status'] = 'degraded'
    else:
        results['checks']['disk_space'] = f'healthy: {free_space_gb:.1f}GB remaining'
    
    # Save health check result
    Path('logs/health_checks').mkdir(exist_ok=True)
    with open(f'logs/health_checks/health_{datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")}.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    return results

if __name__ == '__main__':
    result = asyncio.run(health_check())
    print(json.dumps(result, indent=2))
    
    if result['status'] != 'healthy':
        sys.exit(1)
