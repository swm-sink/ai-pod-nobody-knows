#!/usr/bin/env python3
"""
Export session metrics to CSV for spreadsheet analysis.
No external dependencies - uses Python standard library only.

Technical: CSV export enables analysis in Excel/Sheets without custom tooling.
Simple: Like creating a spreadsheet from your notes that you can analyze anywhere.
Learning: This shows how to bridge simple scripts with professional analytics tools.
"""

import csv
import json
import sys
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any

def load_sessions(session_dir: Path) -> List[Dict[str, Any]]:
    """Load all session JSON files from directory."""
    sessions = []

    if not session_dir.exists():
        print(f"Error: Session directory not found: {session_dir}", file=sys.stderr)
        return sessions

    for file_path in sorted(session_dir.glob("*.json")):
        try:
            with open(file_path, 'r') as f:
                session_data = json.load(f)
                session_data['_filename'] = file_path.name
                sessions.append(session_data)
        except (json.JSONDecodeError, IOError) as e:
            print(f"Warning: Could not load {file_path.name}: {e}", file=sys.stderr)
            continue

    return sorted(sessions, key=lambda x: x.get('episode_number', 0))

def export_to_csv(sessions: List[Dict[str, Any]], output_file: str = None):
    """Export sessions to CSV format."""

    if not sessions:
        print("No sessions to export", file=sys.stderr)
        return

    # Define CSV columns
    fieldnames = [
        'episode_number',
        'session_id',
        'date',
        'topic',
        'complexity_level',
        'status',
        'perplexity_cost',
        'elevenlabs_cost',
        'total_cost',
        'overall_quality',
        'brand_consistency',
        'comprehension',
        'engagement',
        'technical_accuracy',
        'pass_fail',
        'retry_count',
        'research_duration',
        'script_duration',
        'quality_duration',
        'audio_duration',
        'total_duration',
        'filename'
    ]

    # Prepare output
    output = sys.stdout if output_file is None else open(output_file, 'w', newline='')

    try:
        writer = csv.DictWriter(output, fieldnames=fieldnames)
        writer.writeheader()

        for session in sessions:
            # Extract nested data
            external_costs = session.get('external_costs', {})
            quality_eval = session.get('quality_evaluation', {})
            quality_scores = quality_eval.get('scores', {})
            timing = session.get('timing', {})
            phase_durations = timing.get('phase_durations', {})

            # Calculate total cost if not present
            total_cost = external_costs.get('total', 0)
            if total_cost == 0:
                total_cost = external_costs.get('perplexity', 0) + external_costs.get('elevenlabs', 0)

            # Calculate total duration
            total_duration = sum([
                phase_durations.get('research', 0),
                phase_durations.get('script', 0),
                phase_durations.get('quality', 0),
                phase_durations.get('audio', 0)
            ])

            # Extract date from session_id if available
            session_id = session.get('session_id', '')
            date_str = ''
            if session_id:
                # Format: ep_001_20240811_1430
                parts = session_id.split('_')
                if len(parts) >= 3:
                    date_str = parts[2]  # YYYYMMDD format

            # Build row
            row = {
                'episode_number': session.get('episode_number', ''),
                'session_id': session_id,
                'date': date_str,
                'topic': session.get('topic', ''),
                'complexity_level': session.get('complexity_level', ''),
                'status': session.get('status', ''),
                'perplexity_cost': external_costs.get('perplexity', 0),
                'elevenlabs_cost': external_costs.get('elevenlabs', 0),
                'total_cost': total_cost,
                'overall_quality': quality_eval.get('overall_score', ''),
                'brand_consistency': quality_scores.get('brand_consistency', ''),
                'comprehension': quality_scores.get('comprehension', ''),
                'engagement': quality_scores.get('engagement', ''),
                'technical_accuracy': quality_scores.get('technical_accuracy', ''),
                'pass_fail': quality_eval.get('pass_fail', ''),
                'retry_count': session.get('retry_count', 0),
                'research_duration': phase_durations.get('research', ''),
                'script_duration': phase_durations.get('script', ''),
                'quality_duration': phase_durations.get('quality', ''),
                'audio_duration': phase_durations.get('audio', ''),
                'total_duration': total_duration if total_duration > 0 else '',
                'filename': session.get('_filename', '')
            }

            writer.writerow(row)

        if output_file:
            print(f"✅ Exported {len(sessions)} sessions to {output_file}", file=sys.stderr)
        else:
            print(f"\n# Exported {len(sessions)} sessions", file=sys.stderr)

    finally:
        if output_file and output != sys.stdout:
            output.close()

def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Export podcast production metrics to CSV'
    )
    parser.add_argument(
        '--dir',
        type=str,
        help='Session directory path (default: projects/nobody-knows/output/sessions)'
    )
    parser.add_argument(
        '--output',
        type=str,
        help='Output CSV file (default: stdout)'
    )
    parser.add_argument(
        '--last',
        type=int,
        help='Export only last N episodes'
    )

    args = parser.parse_args()

    # Determine session directory
    if args.dir:
        session_dir = Path(args.dir)
    else:
        # Default to relative path from project root
        base_path = Path(__file__).parent.parent.parent.parent
        session_dir = base_path / "projects" / "nobody-knows" / "output" / "sessions"

    # Load sessions
    sessions = load_sessions(session_dir)

    # Filter if requested
    if args.last and len(sessions) > args.last:
        sessions = sessions[-args.last:]
        print(f"# Filtering to last {args.last} episodes", file=sys.stderr)

    # Export
    export_to_csv(sessions, args.output)

    if not args.output:
        print("\n# Tip: Redirect to file with: python export_metrics.py > metrics.csv", file=sys.stderr)
        print("# Or specify output: python export_metrics.py --output metrics.csv", file=sys.stderr)

if __name__ == "__main__":
    main()
