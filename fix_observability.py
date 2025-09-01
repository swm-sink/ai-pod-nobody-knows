#!/usr/bin/env python3
"""
Fix Observability Script - Enable All Langfuse Integration
Replaces all "if False:" blocks that disable observability with proper conditional checks.
"""

import os
import re
from pathlib import Path

def fix_file(file_path: Path):
    """Fix observability in a single file."""
    print(f"Processing: {file_path}")

    with open(file_path, 'r') as f:
        content = f.read()

    original_content = content

    # Pattern 1: if False:  # Langfuse disabled
    pattern1 = r'if False:\s*# Langfuse disabled'
    replacement1 = 'if self.langfuse:'
    content = re.sub(pattern1, replacement1, content)

    # Pattern 2: if False:  # Langfuse disabled (with extra spaces)
    pattern2 = r'if False:\s*#\s*Langfuse disabled'
    replacement2 = 'if self.langfuse:'
    content = re.sub(pattern2, replacement2, content)

    # Pattern 3: Any remaining if False: related to langfuse
    pattern3 = r'if False:\s*.*[Ll]angfuse.*'
    replacement3 = 'if self.langfuse:'
    content = re.sub(pattern3, replacement3, content)

    # Check if we made changes
    if content != original_content:
        print(f"  ✅ Fixed observability blocks in {file_path.name}")

        # Write the updated content
        with open(file_path, 'w') as f:
            f.write(content)

        return True
    else:
        print(f"  ⏭️  No changes needed in {file_path.name}")
        return False

def main():
    """Main function to fix all files."""
    print("🔍 Fixing disabled observability in all agent files...")

    # Find all Python files in agents directory
    agents_dir = Path("podcast_production/agents")
    if not agents_dir.exists():
        print(f"❌ Agents directory not found: {agents_dir}")
        return

    python_files = list(agents_dir.glob("*.py"))

    if not python_files:
        print("❌ No Python files found in agents directory")
        return

    fixed_count = 0

    for file_path in python_files:
        if fix_file(file_path):
            fixed_count += 1

    print(f"\n✅ Fixed observability in {fixed_count}/{len(python_files)} files")
    print("🎯 All Langfuse observability is now enabled!")

    # Also check and fix simple_fix.py if it exists
    simple_fix_path = Path("podcast_production/simple_fix.py")
    if simple_fix_path.exists():
        if fix_file(simple_fix_path):
            print("✅ Also fixed simple_fix.py")

if __name__ == "__main__":
    main()
