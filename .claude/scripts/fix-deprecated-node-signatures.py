#!/usr/bin/env python3
"""
Fix Deprecated LangGraph Node Signatures
Automatically updates node function signatures to August 2025 patterns
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Tuple


def find_deprecated_signatures(directory: Path) -> List[Tuple[Path, int, str]]:
    """
    Find deprecated node function signatures in Python files.
    
    Returns:
        List of tuples: (file_path, line_number, line_content)
    """
    deprecated_patterns = [
        r'async def \w*_node\(.*state.*RunnableConfig.*\)',
        r'async def \w*_node\(.*PodcastState.*config.*=.*None\)',
    ]
    
    deprecated_signatures = []
    
    for py_file in directory.glob('**/*.py'):
        if py_file.name.startswith('.') or 'test' in py_file.name:
            continue
            
        try:
            with open(py_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            for i, line in enumerate(lines, 1):
                for pattern in deprecated_patterns:
                    if re.search(pattern, line):
                        deprecated_signatures.append((py_file, i, line.strip()))
                        break
                        
        except (UnicodeDecodeError, PermissionError):
            print(f"Warning: Could not read {py_file}")
            continue
    
    return deprecated_signatures


def fix_node_signature(file_path: Path) -> bool:
    """
    Fix deprecated node signatures in a single file.
    
    Returns:
        True if any changes were made
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Pattern 1: Basic node signature with PodcastState and optional RunnableConfig
        pattern1 = r'async def (\w+_node)\(self, state: PodcastState, config: RunnableConfig = None\) -> PodcastState:'
        replacement1 = r'async def \1(self, state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:'
        content = re.sub(pattern1, replacement1, content)
        
        # Pattern 2: Node signature without self parameter
        pattern2 = r'async def (\w+_node)\(state: PodcastState, config: RunnableConfig = None\) -> PodcastState:'
        replacement2 = r'async def \1(state: InjectedState, *, store: InjectedStore, config: Optional[RunnableConfig] = None) -> InjectedState:'
        content = re.sub(pattern2, replacement2, content)
        
        # Add required imports if they're not present
        import_additions = []
        
        if 'InjectedState' in content and 'from langgraph.types import InjectedState' not in content:
            import_additions.append('from langgraph.types import InjectedState')
        
        if 'InjectedStore' in content and 'from langgraph.store.base import InjectedStore' not in content:
            import_additions.append('from langgraph.store.base import InjectedStore')
        
        if 'Optional[RunnableConfig]' in content and 'from typing import Optional' not in content:
            # Check if typing import exists and add Optional
            if 'from typing import' in content:
                content = re.sub(
                    r'from typing import ([^n]*)',
                    r'from typing import \1, Optional',
                    content
                )
            else:
                import_additions.append('from typing import Optional')
        
        # Add imports after existing imports
        if import_additions:
            # Find the last import line
            import_lines = []
            lines = content.split('\n')
            last_import_idx = -1
            
            for i, line in enumerate(lines):
                if line.startswith('import ') or line.startswith('from '):
                    last_import_idx = i
            
            if last_import_idx >= 0:
                for addition in import_additions:
                    lines.insert(last_import_idx + 1, addition)
                    last_import_idx += 1
                
                content = '\n'.join(lines)
        
        # Update return type hints in function bodies if needed
        content = re.sub(
            r'return state  # PodcastState',
            r'return state  # InjectedState',
            content
        )
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
            
    except Exception as e:
        print(f"Error fixing {file_path}: {e}")
        return False
    
    return False


def main():
    """Main execution function"""
    print("🔧 Fixing Deprecated LangGraph Node Signatures")
    print("=" * 50)
    
    # Find project root
    current_dir = Path.cwd()
    podcast_production_dir = current_dir / "podcast_production"
    
    if not podcast_production_dir.exists():
        print("❌ Error: podcast_production directory not found")
        print(f"Current directory: {current_dir}")
        sys.exit(1)
    
    # Find deprecated signatures
    print("🔍 Scanning for deprecated node signatures...")
    deprecated_signatures = find_deprecated_signatures(podcast_production_dir)
    
    if not deprecated_signatures:
        print("✅ No deprecated signatures found!")
        return
    
    print(f"📋 Found {len(deprecated_signatures)} deprecated signatures:")
    for file_path, line_num, line_content in deprecated_signatures:
        rel_path = file_path.relative_to(current_dir)
        print(f"  {rel_path}:{line_num} - {line_content[:80]}...")
    
    print("\n🔨 Applying fixes...")
    
    # Group by file and fix
    files_to_fix = set(file_path for file_path, _, _ in deprecated_signatures)
    fixed_files = []
    
    for file_path in files_to_fix:
        print(f"  Fixing {file_path.name}...", end=" ")
        if fix_node_signature(file_path):
            print("✅ Fixed")
            fixed_files.append(file_path)
        else:
            print("⏭️  No changes needed")
    
    print(f"\n📊 Summary:")
    print(f"  Files scanned: {len(list(podcast_production_dir.glob('**/*.py')))}")
    print(f"  Deprecated signatures found: {len(deprecated_signatures)}")
    print(f"  Files fixed: {len(fixed_files)}")
    
    if fixed_files:
        print(f"\n📝 Fixed files:")
        for file_path in fixed_files:
            rel_path = file_path.relative_to(current_dir)
            print(f"  - {rel_path}")
        
        print(f"\n⚠️  Important Notes:")
        print(f"  1. Review changes before committing")
        print(f"  2. Test updated functions with new signatures")
        print(f"  3. Ensure all imports are correctly added")
        print(f"  4. Run tests to verify compatibility")
    
    print("\n✅ Node signature update complete!")


if __name__ == "__main__":
    main()