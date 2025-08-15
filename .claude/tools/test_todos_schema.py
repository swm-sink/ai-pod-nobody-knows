#!/usr/bin/env python3
"""
Test cases for TODOS.yaml schema validation
Task: todos_003
Purpose: Comprehensive TDD test suite for TODOS.yaml structure
"""

import yaml
import sys
import os
from datetime import datetime
from typing import Dict, Any, List

class TodosSchemaValidator:
    """Validates TODOS.yaml schema against requirements"""
    
    REQUIRED_ROOT_FIELDS = [
        'version', 'last_updated', 'current_phase', 
        'active_session_id', 'recovery_context', 
        'categories', 'tasks', 'statistics', 'validation'
    ]
    
    REQUIRED_TASK_FIELDS = [
        'id', 'category', 'type', 'status', 
        'title', 'description', 'context', 'progress'
    ]
    
    VALID_TYPES = [
        'EXPLORE', 'PLAN', 'TEST', 
        'IMPLEMENT', 'VERIFY', 'COMMIT'
    ]
    
    VALID_STATUSES = [
        'pending', 'in_progress', 'completed', 
        'blocked', 'failed'
    ]
    
    VALID_PHASES = ['WALK', 'CRAWL', 'RUN']
    
    def __init__(self, yaml_path: str):
        self.yaml_path = yaml_path
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.data: Dict[Any, Any] = {}
        
    def load_yaml(self) -> bool:
        """Load and parse YAML file"""
        try:
            with open(self.yaml_path, 'r') as f:
                self.data = yaml.safe_load(f)
            return True
        except yaml.YAMLError as e:
            self.errors.append(f"YAML parsing error: {e}")
            return False
        except FileNotFoundError:
            self.errors.append(f"File not found: {self.yaml_path}")
            return False
            
    def validate_structure(self) -> bool:
        """Validate overall YAML structure"""
        if not self.data:
            self.errors.append("Empty YAML file")
            return False
            
        # Check root fields
        for field in self.REQUIRED_ROOT_FIELDS:
            if field not in self.data:
                self.errors.append(f"Missing required root field: {field}")
                
        # Validate version format
        if 'version' in self.data:
            if not isinstance(self.data['version'], str):
                self.errors.append("Version must be a string")
            elif not self.data['version'].count('.') == 2:
                self.warnings.append("Version should follow semantic versioning (x.y.z)")
                
        # Validate phase
        if 'current_phase' in self.data:
            if self.data['current_phase'] not in self.VALID_PHASES:
                self.errors.append(f"Invalid phase: {self.data['current_phase']}")
                
        return len(self.errors) == 0
        
    def validate_tasks(self) -> bool:
        """Validate task entries"""
        if 'tasks' not in self.data:
            return False
            
        tasks = self.data['tasks']
        if not isinstance(tasks, list):
            self.errors.append("Tasks must be a list")
            return False
            
        task_ids = set()
        for idx, task in enumerate(tasks):
            # Check required fields
            for field in self.REQUIRED_TASK_FIELDS:
                if field not in task:
                    self.errors.append(f"Task {idx}: Missing required field '{field}'")
                    
            # Check unique IDs
            if 'id' in task:
                if task['id'] in task_ids:
                    self.errors.append(f"Duplicate task ID: {task['id']}")
                task_ids.add(task['id'])
                
            # Validate type
            if 'type' in task and task['type'] not in self.VALID_TYPES:
                self.errors.append(f"Task {task.get('id', idx)}: Invalid type '{task['type']}'")
                
            # Validate status
            if 'status' in task and task['status'] not in self.VALID_STATUSES:
                self.errors.append(f"Task {task.get('id', idx)}: Invalid status '{task['status']}'")
                
            # Validate dependencies
            if 'context' in task and 'dependencies' in task['context']:
                for dep in task['context']['dependencies']:
                    if 'task_id' not in dep:
                        self.warnings.append(f"Task {task.get('id', idx)}: Dependency missing task_id")
                        
            # Validate progress fields
            if 'progress' in task:
                progress = task['progress']
                if task.get('status') == 'completed':
                    if not progress.get('completed_at'):
                        self.warnings.append(f"Task {task.get('id', idx)}: Completed task missing completion time")
                    if task.get('type') == 'COMMIT' and not progress.get('commit_sha'):
                        self.errors.append(f"Task {task.get('id', idx)}: COMMIT task missing commit_sha")
                        
        return len(self.errors) == 0
        
    def validate_recovery_context(self) -> bool:
        """Validate recovery context for session restoration"""
        if 'recovery_context' not in self.data:
            return False
            
        context = self.data['recovery_context']
        required_fields = ['last_working_directory', 'last_commit', 'environment']
        
        for field in required_fields:
            if field not in context:
                self.errors.append(f"Recovery context missing: {field}")
                
        # Validate git commit SHA format
        if 'last_commit' in context:
            commit = context['last_commit']
            if commit and not (len(commit) == 7 or len(commit) == 40):
                self.warnings.append("Git commit SHA should be 7 or 40 characters")
                
        return len(self.errors) == 0
        
    def validate_statistics(self) -> bool:
        """Validate statistics consistency"""
        if 'statistics' not in self.data or 'tasks' not in self.data:
            return False
            
        stats = self.data['statistics']
        tasks = self.data['tasks']
        
        # Count actual task statuses
        actual_counts = {
            'completed': sum(1 for t in tasks if t.get('status') == 'completed'),
            'in_progress': sum(1 for t in tasks if t.get('status') == 'in_progress'),
            'pending': sum(1 for t in tasks if t.get('status') == 'pending'),
            'blocked': sum(1 for t in tasks if t.get('status') == 'blocked'),
            'failed': sum(1 for t in tasks if t.get('status') == 'failed'),
        }
        
        # Verify counts match
        for status, count in actual_counts.items():
            if stats.get(status, 0) != count:
                self.warnings.append(f"Statistics mismatch for {status}: expected {count}, got {stats.get(status, 0)}")
                
        # Verify total
        actual_total = len(tasks)
        if stats.get('total_tasks', 0) != actual_total:
            self.warnings.append(f"Total tasks mismatch: expected {actual_total}, got {stats.get('total_tasks', 0)}")
            
        return True
        
    def run_all_validations(self) -> bool:
        """Run all validation tests"""
        if not self.load_yaml():
            return False
            
        validations = [
            ("Structure", self.validate_structure),
            ("Tasks", self.validate_tasks),
            ("Recovery Context", self.validate_recovery_context),
            ("Statistics", self.validate_statistics),
        ]
        
        all_valid = True
        for name, validator in validations:
            print(f"Validating {name}...")
            if not validator():
                all_valid = False
                print(f"  ❌ {name} validation failed")
            else:
                print(f"  ✅ {name} validation passed")
                
        return all_valid
        
    def print_report(self):
        """Print validation report"""
        print("\n" + "="*60)
        print("TODOS.yaml Validation Report")
        print("="*60)
        
        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            for error in self.errors:
                print(f"  • {error}")
        else:
            print("\n✅ No errors found")
            
        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  • {warning}")
        else:
            print("\n✅ No warnings")
            
        print("\n" + "="*60)
        if not self.errors:
            print("✅ TODOS.yaml is valid!")
        else:
            print("❌ TODOS.yaml has validation errors")
        print("="*60)
        

def main():
    """Main test runner"""
    yaml_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
        'TODOS.yaml'
    )
    
    print(f"Testing TODOS.yaml at: {yaml_path}")
    
    validator = TodosSchemaValidator(yaml_path)
    is_valid = validator.run_all_validations()
    validator.print_report()
    
    # Return appropriate exit code
    sys.exit(0 if is_valid else 1)


if __name__ == "__main__":
    main()