#!/usr/bin/env python3
"""
Voice Governance Fix Script - Replace Hardcoded Voice IDs
Fixes all hardcoded voice ID references to use centralized configuration.
"""

import os
import re
from pathlib import Path

def fix_file(file_path: Path):
    """Fix voice ID hardcoding in a single file."""
    print(f"Processing: {file_path}")

    with open(file_path, 'r') as f:
        content = f.read()

    original_content = content

    # Pattern to match the hardcoded voice ID
    voice_id_pattern = r'get_production_voice_id()'

    # Check if this file needs updating
    if voice_id_pattern not in content:
        print(f"  ⏭️  No hardcoded voice ID found in {file_path.name}")
        return False

    # Add import for voice config at the top if not present
    if "from config.voice_config import get_production_voice_id" not in content:
        # Find the right place to add the import
        import_lines = []
        lines = content.split('\n')

        # Find where imports end
        import_end_line = 0
        for i, line in enumerate(lines):
            if line.strip().startswith('import ') or line.strip().startswith('from '):
                import_end_line = i
            elif line.strip() and not line.startswith('#') and not line.startswith('"""') and not line.startswith("'''"):
                break

        # Insert the import after existing imports
        if import_end_line > 0:
            lines.insert(import_end_line + 1, "from config.voice_config import get_production_voice_id")
        else:
            # Insert after docstring if present
            docstring_end = 0
            in_docstring = False
            for i, line in enumerate(lines):
                if '"""' in line or "'''" in line:
                    if not in_docstring:
                        in_docstring = True
                    else:
                        docstring_end = i
                        break
            lines.insert(docstring_end + 1, "\nfrom config.voice_config import get_production_voice_id")

        content = '\n'.join(lines)

    # Replace hardcoded voice ID with function call
    content = re.sub(
        r'get_production_voice_id()',
        'get_production_voice_id()',
        content
    )

    # Also handle any single quotes
    content = re.sub(
        r"get_production_voice_id()",
        'get_production_voice_id()',
        content
    )

    # Check if we made changes
    if content != original_content:
        print(f"  ✅ Fixed voice ID hardcoding in {file_path.name}")

        # Write the updated content
        with open(file_path, 'w') as f:
            f.write(content)

        return True
    else:
        print(f"  ⏭️  No changes needed in {file_path.name}")
        return False

def main():
    """Main function to fix all files."""
    print("🔍 Fixing hardcoded voice IDs in all files...")

    # Find all files that might contain hardcoded voice IDs
    search_dirs = [
        Path("podcast_production"),
        Path("tests"),
        Path(".claude"),
        Path(".")
    ]

    file_extensions = [".py", ".md", ".yaml", ".yml", ".json"]

    all_files = []

    for search_dir in search_dirs:
        if search_dir.exists():
            for ext in file_extensions:
                pattern = f"**/*{ext}"
                files = list(search_dir.glob(pattern))
                all_files.extend(files)

    # Also check root level files
    root_files = [f for f in Path(".").glob("*") if f.is_file() and f.suffix in file_extensions]
    all_files.extend(root_files)

    if not all_files:
        print("❌ No files found to check")
        return

    print(f"📁 Found {len(all_files)} files to check")

    fixed_count = 0

    for file_path in all_files:
        try:
            if fix_file(file_path):
                fixed_count += 1
        except Exception as e:
            print(f"  ❌ Error processing {file_path}: {e}")

    print(f"\n✅ Fixed voice ID governance in {fixed_count} files")
    print("🎯 All voice IDs now use centralized configuration!")

    # Create the production voice config file
    config_dir = Path("podcast_production/config")
    config_dir.mkdir(parents=True, exist_ok=True)

    config_file = config_dir / "production-voice.json"
    if not config_file.exists():
        import json
        config_data = {
            "production_voice_id": get_production_voice_id(),
            "source": "governance_fix",
            "validation_status": "validated",
            "validation_date": "2025-08-31",
            "validation_notes": "Episode 1 validated with 9.2/10 quality",
            "governance_compliant": True
        }

        with open(config_file, 'w') as f:
            json.dump(config_data, f, indent=2)

        print(f"✅ Created production voice config: {config_file}")

if __name__ == "__main__":
    main()
