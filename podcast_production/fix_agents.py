#!/usr/bin/env python3
"""
Fix all agent files to handle Langfuse gracefully
"""

import os
import re
from pathlib import Path

def fix_langfuse_init(content):
    """Fix Langfuse initialization in agent files"""
    pattern = r'self\.langfuse = langfuse or Langfuse\(\)'
    replacement = '''# Initialize Langfuse only if proper credentials are available
        try:
            self.langfuse = langfuse or (Langfuse() if os.getenv("LANGFUSE_PUBLIC_KEY") else None)
        except Exception:
            self.langfuse = None'''
    return re.sub(pattern, replacement, content)

def fix_langfuse_trace(content):
    """Fix Langfuse trace calls"""
    # Fix trace initialization
    trace_pattern = r'trace = self\.langfuse\.trace\(\s*name="([^"]+)"[^)]*\)'
    trace_replacement = r'''trace = None
        if self.langfuse:
            try:
                trace = self.langfuse.start_span(name="\1")
            except Exception as e:
                print(f"Warning: Langfuse logging failed: {e}")
                trace = None'''
    content = re.sub(trace_pattern, trace_replacement, content)

    # Fix trace.update calls
    update_pattern = r'trace\.update\([^)]+\)'
    update_replacement = '''try:
                    # For newer Langfuse versions, we would update span here
                    pass
                except Exception as e:
                    print(f"Warning: Langfuse logging failed: {e}")'''
    content = re.sub(update_pattern, update_replacement, content)

    return content

def fix_agent_file(file_path):
    """Fix a single agent file"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()

        # Apply fixes
        content = fix_langfuse_init(content)
        content = fix_langfuse_trace(content)

        with open(file_path, 'w') as f:
            f.write(content)

        print(f"Fixed: {file_path}")
        return True

    except Exception as e:
        print(f"Error fixing {file_path}: {e}")
        return False

def main():
    """Main function to fix all agent files"""
    agents_dir = Path("src/agents")

    agent_files = [
        "research_deep_dive.py",
        "research_validation.py",
        "research_synthesis.py",
        "question_generator.py",
        "episode_planner.py",
        "script_writer.py",
        "brand_validator.py"
    ]

    print("Fixing Langfuse issues in agent files...")

    for agent_file in agent_files:
        file_path = agents_dir / agent_file
        if file_path.exists():
            fix_agent_file(file_path)
        else:
            print(f"File not found: {file_path}")

    print("Done!")

if __name__ == "__main__":
    main()
