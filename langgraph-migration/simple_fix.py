#!/usr/bin/env python3
"""Simple fix to disable Langfuse"""

from pathlib import Path

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

for agent_file in agent_files:
    file_path = agents_dir / agent_file
    if file_path.exists():
        with open(file_path, 'r') as f:
            content = f.read()

        # Disable langfuse for testing
        content = content.replace(
            'self.langfuse = langfuse or Langfuse()',
            'self.langfuse = None  # Disabled for testing'
        )
        content = content.replace(
            'if self.langfuse:',
            'if False:  # Langfuse disabled'
        )

        with open(file_path, 'w') as f:
            f.write(content)

        print(f'Simplified fix applied to {agent_file}')

print("All agents fixed!")
