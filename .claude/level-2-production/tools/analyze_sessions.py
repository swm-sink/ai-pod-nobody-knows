#!/usr/bin/env python3
"""
Simple local analytics for Nobody Knows podcast production sessions.
No external dependencies beyond Python standard library.
Works completely offline.

Technical: Local file-based analytics without external dependencies or network requirements.
Simple: Like creating a report from your notes without needing internet or special software.
Learning: This demonstrates how simple, effective analytics can be without complex infrastructure.
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any
import statistics

class SessionAnalyzer:
    """Analyzes podcast production session files locally."""

    def __init__(self, session_dir: str = None):
        """Initialize analyzer with session directory path."""
        if session_dir is None:
            # Default to relative path from project root
            base_path = Path(__file__).parent.parent.parent.parent
            session_dir = base_path / "projects" / "nobody-knows" / "output" / "sessions"

        self.session_dir = Path(session_dir)
        if not self.session_dir.exists():
            print(f"Warning: Session directory not found: {self.session_dir}")
            self.session_dir.mkdir(parents=True, exist_ok=True)

    def load_sessions(self) -> List[Dict[str, Any]]:
        """Load all session JSON files."""
        sessions = []

        if not self.session_dir.exists():
            return sessions

        for file_path in sorted(self.session_dir.glob("*.json")):
            try:
                with open(file_path, 'r') as f:
                    session_data = json.load(f)
                    session_data['_filename'] = file_path.name
                    sessions.append(session_data)
            except (json.JSONDecodeError, IOError) as e:
                print(f"Warning: Could not load {file_path.name}: {e}")
                continue

        # Sort by episode number if available
        sessions.sort(key=lambda x: x.get('episode_number', 0))
        return sessions

    def calculate_metrics(self, sessions: List[Dict]) -> Dict[str, Any]:
        """Calculate aggregate metrics from sessions."""
        if not sessions:
            return {
                'total_episodes': 0,
                'message': 'No sessions found'
            }

        # Extract costs
        costs = []
        for session in sessions:
            external_costs = session.get('external_costs', {})
            total_cost = external_costs.get('total', 0)
            if total_cost == 0:
                # Try summing individual costs
                perplexity = external_costs.get('perplexity', 0)
                elevenlabs = external_costs.get('elevenlabs', 0)
                total_cost = perplexity + elevenlabs
            costs.append(total_cost)

        # Extract quality scores
        quality_scores = []
        pass_count = 0
        for session in sessions:
            quality = session.get('quality_evaluation', {})
            overall_score = quality.get('overall_score', 0)
            if overall_score > 0:
                quality_scores.append(overall_score)
                if quality.get('pass_fail', '').upper() == 'PASS':
                    pass_count += 1

        # Calculate aggregates
        metrics = {
            'total_episodes': len(sessions),
            'total_cost': sum(costs),
            'average_cost': statistics.mean(costs) if costs else 0,
            'min_cost': min(costs) if costs else 0,
            'max_cost': max(costs) if costs else 0,
            'average_quality': statistics.mean(quality_scores) if quality_scores else 0,
            'pass_rate': (pass_count / len(sessions) * 100) if sessions else 0,
            'episodes_under_budget': sum(1 for c in costs if c <= 5.00),
            'budget_compliance_rate': (sum(1 for c in costs if c <= 5.00) / len(costs) * 100) if costs else 0
        }

        return metrics

    def generate_report(self, last_n: int = None):
        """Generate and print analytics report."""
        sessions = self.load_sessions()

        if last_n:
            sessions = sessions[-last_n:] if len(sessions) > last_n else sessions

        print("\n" + "="*60)
        print("  Nobody Knows Podcast - Local Production Analytics")
        print("="*60)

        if not sessions:
            print("\n❌ No session files found in:")
            print(f"   {self.session_dir}")
            print("\nTo create sessions, run: /produce-episode")
            return

        metrics = self.calculate_metrics(sessions)

        print(f"\n📊 OVERVIEW")
        print(f"├─ Episodes Analyzed: {metrics['total_episodes']}")
        print(f"├─ Total External Cost: ${metrics['total_cost']:.2f}")
        print(f"├─ Average Cost per Episode: ${metrics['average_cost']:.2f}")
        print(f"└─ Pass Rate: {metrics['pass_rate']:.1f}%")

        print(f"\n💰 COST ANALYSIS")
        print(f"├─ Average: ${metrics['average_cost']:.2f}")
        print(f"├─ Range: ${metrics['min_cost']:.2f} - ${metrics['max_cost']:.2f}")
        print(f"├─ Budget Compliance: {metrics['budget_compliance_rate']:.1f}% under $5")
        print(f"└─ Episodes Under Budget: {metrics['episodes_under_budget']}/{metrics['total_episodes']}")

        if metrics['average_quality'] > 0:
            print(f"\n🎯 QUALITY METRICS")
            print(f"├─ Average Quality Score: {metrics['average_quality']:.2f}")
            print(f"└─ Pass Rate: {metrics['pass_rate']:.1f}%")

        print(f"\n📈 EPISODE DETAILS")
        print("─" * 60)
        print(f"{'Episode':<10} {'Cost':<10} {'Quality':<10} {'Status':<10}")
        print("─" * 60)

        for session in sessions[-10:]:  # Show last 10
            ep_num = session.get('episode_number', '?')

            external_costs = session.get('external_costs', {})
            cost = external_costs.get('total', 0)
            if cost == 0:
                cost = external_costs.get('perplexity', 0) + external_costs.get('elevenlabs', 0)

            quality = session.get('quality_evaluation', {})
            score = quality.get('overall_score', 0)
            status = quality.get('pass_fail', 'UNKNOWN')

            status_icon = '✅' if status == 'PASS' else '❌' if status == 'FAIL' else '❓'

            print(f"{ep_num:<10} ${cost:<9.2f} {score:<10.2f} {status_icon} {status:<8}")

        print("\n" + "="*60)
        print("\n💡 Tips:")
        print("  • Sessions are stored in JSON files locally")
        print("  • No external dependencies or API keys needed")
        print("  • Run 'python export_metrics.py' for CSV export")
        print("  • All data stays on your machine")
        print()

def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description='Analyze podcast production sessions')
    parser.add_argument('--last', type=int, help='Analyze last N episodes')
    parser.add_argument('--dir', type=str, help='Custom session directory path')

    args = parser.parse_args()

    analyzer = SessionAnalyzer(session_dir=args.dir)
    analyzer.generate_report(last_n=args.last)

if __name__ == "__main__":
    main()
