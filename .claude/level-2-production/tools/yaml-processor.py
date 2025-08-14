#!/usr/bin/env python3

"""
YAML Processor - Alternative to yq for configuration loading
Provides yq-compatible interface using Python's PyYAML
"""

import sys
import yaml
import json
import argparse
from pathlib import Path

def load_yaml_file(file_path):
    """Load YAML file and return parsed data"""
    try:
        with open(file_path, 'r') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: File not found: {file_path}", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error: Invalid YAML syntax in {file_path}: {e}", file=sys.stderr)
        sys.exit(1)

def get_nested_value(data, path):
    """Get nested value from data using dot notation path"""
    try:
        keys = path.split('.')
        current = data

        for key in keys:
            if isinstance(current, dict) and key in current:
                current = current[key]
            else:
                return None

        return current
    except Exception:
        return None

def format_output(value, output_format):
    """Format output value according to specified format"""
    if value is None:
        return ""

    if output_format == "shell":
        # Shell-compatible output for environment variables
        if isinstance(value, bool):
            return "true" if value else "false"
        elif isinstance(value, (int, float)):
            return str(value)
        elif isinstance(value, str):
            # Quote strings that contain spaces or special characters
            if ' ' in value or any(c in value for c in '"$`\\'):
                escaped = value.replace('\\', '\\\\').replace('"', '\\"').replace('$', '\\$').replace('`', '\\`')
                return f'"{escaped}"'
            else:
                return value
        else:
            return str(value)
    else:
        # Default: return as-is
        return str(value)

def check_has_key(data, key):
    """Check if data has the specified key"""
    keys = key.split('.')
    current = data

    try:
        for k in keys:
            if isinstance(current, dict) and k in current:
                current = current[k]
            else:
                return False
        return True
    except Exception:
        return False

def main():
    parser = argparse.ArgumentParser(description='YAML Processor - yq alternative')
    parser.add_argument('expression', help='YAML query expression')
    parser.add_argument('file', help='YAML file to process')
    parser.add_argument('-o', '--output', choices=['json', 'shell', 'yaml'],
                       default='yaml', help='Output format')

    args = parser.parse_args()

    # Load YAML data
    data = load_yaml_file(args.file)

    # Process expression
    if args.expression == '.':
        # Return entire document
        result = data
    elif args.expression.startswith('has("') and args.expression.endswith('")'):
        # Handle has("key") expressions
        key = args.expression[5:-2]  # Remove has(" and ")
        result = check_has_key(data, key)
    elif args.expression.startswith('.'):
        # Handle .key.subkey expressions
        path = args.expression[1:]  # Remove leading dot
        result = get_nested_value(data, path)
    else:
        print(f"Error: Unsupported expression: {args.expression}", file=sys.stderr)
        sys.exit(1)

    # Format and output result
    if args.output == 'json':
        print(json.dumps(result, indent=2))
    elif args.output == 'shell':
        print(format_output(result, 'shell'))
    else:
        if isinstance(result, bool):
            print("true" if result else "false")
        elif result is not None:
            print(result)

if __name__ == '__main__':
    main()
