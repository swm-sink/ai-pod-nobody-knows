#!/usr/bin/env python3
"""
Example usage of the AI Podcast Production System.

This script demonstrates how to use the main.py CLI interface
and shows various command-line options for different scenarios.

Version: 1.0.0
Date: August 2025
"""

import subprocess
import sys
from pathlib import Path


def run_command(command: list) -> None:
    """Run a command and display results."""
    print("\n" + "="*60)
    print(f"Running: {' '.join(command)}")
    print("="*60)

    try:
        result = subprocess.run(command, capture_output=True, text=True, check=False)

        if result.stdout:
            print("STDOUT:")
            print(result.stdout)

        if result.stderr:
            print("STDERR:")
            print(result.stderr)

        print(f"Exit code: {result.returncode}")

    except Exception as e:
        print(f"Error running command: {e}")


def main():
    """Run example usage demonstrations."""

    print("AI Podcast Production System - Example Usage")
    print("August 2025 - LangGraph Migration")

    # Basic dry run examples
    examples = [
        {
            "name": "Basic dry run test",
            "command": ["python3", "main.py", "--topic", "Why do we dream?", "--dry-run"]
        },
        {
            "name": "Verbose dry run with custom budget",
            "command": ["python3", "main.py", "--topic", "Quantum Computing Basics", "--budget", "10.00", "--dry-run", "--verbose"]
        },
        {
            "name": "Custom output directory with state saving",
            "command": ["python3", "main.py", "--topic", "The Future of AI", "--output-dir", "./examples_output", "--dry-run", "--save-state"]
        },
        {
            "name": "Help display",
            "command": ["python3", "main.py", "--help"]
        }
    ]

    for example in examples:
        print(f"\n{'='*60}")
        print(f"Example: {example['name']}")
        run_command(example["command"])

        # Ask if user wants to continue
        if example != examples[-1]:  # Not the last example
            response = input("\nPress Enter to continue to next example, or 'q' to quit: ")
            if response.lower() == 'q':
                break

    print("\n" + "="*60)
    print("Example usage demonstration complete!")
    print("="*60)

    # Show generated files if any
    example_output = Path("examples_output")
    if example_output.exists():
        print(f"\nGenerated files in {example_output}:")
        for file in example_output.iterdir():
            print(f"  - {file.name}")


if __name__ == "__main__":
    main()
