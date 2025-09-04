#!/usr/bin/env python3
"""
Context Hierarchy Validation Script
Tests the hierarchical CLAUDE.md context system
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Set

class ContextValidator:
    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir)
        self.context_files = {}
        self.references = {}
        self.inheritance_chains = {}
        
    def find_context_files(self) -> Dict[str, Path]:
        """Find all CLAUDE.md files in hierarchy"""
        context_files = {}
        for file_path in self.root_dir.rglob("CLAUDE.md"):
            if "backup" not in str(file_path):
                relative_path = file_path.relative_to(self.root_dir)
                context_files[str(relative_path)] = file_path
        return context_files
    
    def extract_references(self, file_path: Path) -> Set[str]:
        """Extract @references from a context file"""
        references = set()
        try:
            content = file_path.read_text()
            # Find @references
            pattern = r'@([a-zA-Z_\-/]+(?:/[a-zA-Z_\-]+)*)/CLAUDE\.md'
            matches = re.findall(pattern, content)
            references.update(matches)
            
            # Also find simple @references
            pattern2 = r'@(podcast_production|\.claude|tests|docs)(?:/\w+)*'
            matches2 = re.findall(pattern2, content)
            references.update(matches2)
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
        return references
    
    def validate_hierarchy(self):
        """Validate the context hierarchy"""
        print("=" * 60)
        print("CONTEXT HIERARCHY VALIDATION")
        print("=" * 60)
        
        # Find all context files
        self.context_files = self.find_context_files()
        print(f"\n✅ Found {len(self.context_files)} CLAUDE.md files:")
        for path in sorted(self.context_files.keys()):
            file_path = self.context_files[path]
            size = file_path.stat().st_size
            lines = len(file_path.read_text().splitlines())
            print(f"  - {path} ({lines} lines, {size:,} bytes)")
        
        # Check line limits
        print("\n📏 Line Count Validation (max 500):")
        all_under_limit = True
        for path, file_path in self.context_files.items():
            lines = len(file_path.read_text().splitlines())
            if lines > 500:
                print(f"  ❌ {path}: {lines} lines (OVER LIMIT)")
                all_under_limit = False
            else:
                print(f"  ✅ {path}: {lines} lines")
        
        # Extract references
        print("\n🔗 Reference Extraction:")
        for path, file_path in self.context_files.items():
            refs = self.extract_references(file_path)
            self.references[path] = refs
            if refs:
                print(f"  {path} references:")
                for ref in sorted(refs):
                    print(f"    → @{ref}")
        
        # Validate loading strategies
        print("\n📦 Loading Strategy Validation:")
        root_content = self.context_files["CLAUDE.md"].read_text()
        
        # Extract loading strategies
        strategies = {
            "task_production": ["podcast_production", "podcast_production/agents"],
            "task_development": [".claude", ".claude/agents/dev"],
            "task_testing": ["tests"],
            "task_research": ["podcast_production/workflows", "podcast_production/agents"]
        }
        
        for task, expected_contexts in strategies.items():
            print(f"  {task}:")
            for context in expected_contexts:
                if context in root_content:
                    print(f"    ✅ Loads @{context}/CLAUDE.md")
                else:
                    print(f"    ⚠️  Missing reference to @{context}/CLAUDE.md")
        
        # Calculate token estimates
        print("\n💾 Token Budget Analysis:")
        token_budgets = {
            "CLAUDE.md": 8000,
            "podcast_production/CLAUDE.md": 5000,
            ".claude/CLAUDE.md": 3000,
            "podcast_production/agents/CLAUDE.md": 3000,
            "podcast_production/workflows/CLAUDE.md": 3000,
            "podcast_production/config/CLAUDE.md": 2000,
            "tests/CLAUDE.md": 2000,
            "docs/CLAUDE.md": 1000
        }
        
        total_allocated = 0
        for path, budget in token_budgets.items():
            if path in self.context_files:
                file_path = self.context_files[path]
                # Rough estimate: 4 chars per token
                chars = len(file_path.read_text())
                estimated_tokens = chars // 4
                total_allocated += estimated_tokens
                
                status = "✅" if estimated_tokens <= budget else "⚠️"
                print(f"  {status} {path}: ~{estimated_tokens:,} tokens (budget: {budget:,})")
        
        print(f"\n  Total Estimated Tokens: ~{total_allocated:,} (Target: <15,000)")
        
        # Test common workflows
        print("\n🔄 Workflow Context Loading Simulation:")
        
        workflows = {
            "Episode Production": ["CLAUDE.md", "podcast_production/CLAUDE.md", "podcast_production/agents/CLAUDE.md"],
            "Development": ["CLAUDE.md", ".claude/CLAUDE.md", ".claude/agents/dev/CLAUDE.md"],
            "Testing": ["CLAUDE.md", "tests/CLAUDE.md"],
            "Documentation": ["CLAUDE.md", "docs/CLAUDE.md"]
        }
        
        for workflow, required_contexts in workflows.items():
            print(f"\n  {workflow} Workflow:")
            total_tokens = 0
            for context in required_contexts:
                if context in self.context_files:
                    chars = len(self.context_files[context].read_text())
                    tokens = chars // 4
                    total_tokens += tokens
                    print(f"    ✅ Load {context} (~{tokens:,} tokens)")
                else:
                    context_path = self.root_dir / context
                    if not context_path.exists():
                        print(f"    ⚠️  Missing: {context} (create if needed)")
            print(f"    Total: ~{total_tokens:,} tokens")
        
        print("\n" + "=" * 60)
        print("VALIDATION COMPLETE")
        print("=" * 60)

if __name__ == "__main__":
    validator = ContextValidator("/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.conductor/real-agents")
    validator.validate_hierarchy()