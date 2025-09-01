#!/usr/bin/env python3
"""
Cost Analysis Script for Podcast Production

This script analyzes cost data from the CSV logs and generates detailed
reports about spending patterns, efficiency, and budget utilization.

Usage:
    python analyze_costs.py [--episode EPISODE_ID] [--days DAYS] [--format FORMAT]

Examples:
    python analyze_costs.py --episode ep_20250831_120000_abc123
    python analyze_costs.py --days 7 --format json
    python analyze_costs.py > cost_report.txt

Version: 1.0.0
Date: August 2025
"""

import argparse
import csv
import json
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any, Optional
import statistics


def load_cost_data(csv_file: Path, episode_filter: str = None, days_filter: int = None) -> List[Dict[str, Any]]:
    """
    Load cost data from CSV file with optional filtering.

    Args:
        csv_file: Path to costs.csv file
        episode_filter: Filter by specific episode ID
        days_filter: Filter by last N days

    Returns:
        List of cost records
    """
    if not csv_file.exists():
        print(f"Cost data file not found: {csv_file}")
        return []

    costs = []
    cutoff_date = None

    if days_filter:
        cutoff_date = datetime.now() - timedelta(days=days_filter)

    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Convert numeric fields
            try:
                row['input_tokens'] = int(row['input_tokens']) if row['input_tokens'] else 0
                row['output_tokens'] = int(row['output_tokens']) if row['output_tokens'] else 0
                row['characters'] = int(row['characters']) if row['characters'] else 0
                row['cost'] = float(row['cost'])
                row['cumulative_cost'] = float(row['cumulative_cost'])
                row['budget_remaining'] = float(row['budget_remaining'])
                row['timestamp'] = datetime.fromisoformat(row['timestamp'].replace('Z', '+00:00'))
            except (ValueError, TypeError) as e:
                print(f"Warning: Skipping malformed row: {e}")
                continue

            # Apply filters
            if episode_filter and row['episode_id'] != episode_filter:
                continue

            if cutoff_date and row['timestamp'] < cutoff_date:
                continue

            costs.append(row)

    return costs


def analyze_by_agent(costs: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Analyze costs by agent."""
    agent_stats = defaultdict(lambda: {
        'total_cost': 0.0,
        'operation_count': 0,
        'avg_cost_per_operation': 0.0,
        'providers_used': set(),
        'models_used': set(),
        'total_tokens': 0,
        'total_characters': 0
    })

    for cost in costs:
        agent = cost['agent']
        stats = agent_stats[agent]

        stats['total_cost'] += cost['cost']
        stats['operation_count'] += 1
        stats['providers_used'].add(cost['provider'])
        stats['models_used'].add(f"{cost['provider']}/{cost['model']}")
        stats['total_tokens'] += cost['input_tokens'] + cost['output_tokens']
        stats['total_characters'] += cost['characters']

    # Calculate averages and convert sets to lists
    for agent, stats in agent_stats.items():
        if stats['operation_count'] > 0:
            stats['avg_cost_per_operation'] = stats['total_cost'] / stats['operation_count']
        stats['providers_used'] = list(stats['providers_used'])
        stats['models_used'] = list(stats['models_used'])

    return dict(agent_stats)


def analyze_by_provider(costs: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Analyze costs by provider."""
    provider_stats = defaultdict(lambda: {
        'total_cost': 0.0,
        'operation_count': 0,
        'avg_cost_per_operation': 0.0,
        'models_used': set(),
        'agents_using': set(),
        'total_tokens': 0,
        'total_characters': 0,
        'avg_cost_per_token': 0.0
    })

    for cost in costs:
        provider = cost['provider']
        stats = provider_stats[provider]

        stats['total_cost'] += cost['cost']
        stats['operation_count'] += 1
        stats['models_used'].add(cost['model'])
        stats['agents_using'].add(cost['agent'])
        stats['total_tokens'] += cost['input_tokens'] + cost['output_tokens']
        stats['total_characters'] += cost['characters']

    # Calculate averages and convert sets to lists
    for provider, stats in provider_stats.items():
        if stats['operation_count'] > 0:
            stats['avg_cost_per_operation'] = stats['total_cost'] / stats['operation_count']

        if stats['total_tokens'] > 0:
            stats['avg_cost_per_token'] = stats['total_cost'] / stats['total_tokens']

        stats['models_used'] = list(stats['models_used'])
        stats['agents_using'] = list(stats['agents_using'])

    return dict(provider_stats)


def analyze_by_episode(costs: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Analyze costs by episode."""
    episode_stats = defaultdict(lambda: {
        'total_cost': 0.0,
        'operation_count': 0,
        'agents_used': set(),
        'providers_used': set(),
        'start_time': None,
        'end_time': None,
        'duration_minutes': 0,
        'final_budget_remaining': 0.0,
        'max_cumulative_cost': 0.0
    })

    for cost in costs:
        episode = cost['episode_id']
        stats = episode_stats[episode]

        stats['total_cost'] += cost['cost']
        stats['operation_count'] += 1
        stats['agents_used'].add(cost['agent'])
        stats['providers_used'].add(cost['provider'])
        stats['max_cumulative_cost'] = max(stats['max_cumulative_cost'], cost['cumulative_cost'])
        stats['final_budget_remaining'] = cost['budget_remaining']  # Last entry wins

        # Track time range
        timestamp = cost['timestamp']
        if stats['start_time'] is None or timestamp < stats['start_time']:
            stats['start_time'] = timestamp
        if stats['end_time'] is None or timestamp > stats['end_time']:
            stats['end_time'] = timestamp

    # Calculate duration and convert sets to lists
    for episode, stats in episode_stats.items():
        if stats['start_time'] and stats['end_time']:
            duration = stats['end_time'] - stats['start_time']
            stats['duration_minutes'] = duration.total_seconds() / 60

        stats['agents_used'] = list(stats['agents_used'])
        stats['providers_used'] = list(stats['providers_used'])

        # Convert timestamps to ISO strings for JSON serialization
        if stats['start_time']:
            stats['start_time'] = stats['start_time'].isoformat()
        if stats['end_time']:
            stats['end_time'] = stats['end_time'].isoformat()

    return dict(episode_stats)


def calculate_efficiency_metrics(costs: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Calculate efficiency and optimization metrics."""
    if not costs:
        return {}

    total_costs = [c['cost'] for c in costs]
    cumulative_costs = [c['cumulative_cost'] for c in costs]

    # Most expensive operations
    expensive_ops = sorted(costs, key=lambda x: x['cost'], reverse=True)[:5]

    # Token efficiency (cost per token)
    token_costs = []
    for cost in costs:
        total_tokens = cost['input_tokens'] + cost['output_tokens']
        if total_tokens > 0:
            token_costs.append(cost['cost'] / total_tokens)

    # Character efficiency for TTS
    char_costs = []
    for cost in costs:
        if cost['characters'] > 0:
            char_costs.append(cost['cost'] / cost['characters'])

    metrics = {
        'total_operations': len(costs),
        'total_cost': sum(total_costs),
        'avg_cost_per_operation': statistics.mean(total_costs) if total_costs else 0,
        'median_cost_per_operation': statistics.median(total_costs) if total_costs else 0,
        'max_cost_operation': max(total_costs) if total_costs else 0,
        'min_cost_operation': min(total_costs) if total_costs else 0,
        'cost_std_deviation': statistics.stdev(total_costs) if len(total_costs) > 1 else 0,
        'max_cumulative_cost': max(cumulative_costs) if cumulative_costs else 0,
        'most_expensive_operations': [
            {
                'agent': op['agent'],
                'provider': op['provider'],
                'model': op['model'],
                'cost': op['cost'],
                'operation': op['operation'],
                'timestamp': op['timestamp'].isoformat()
            }
            for op in expensive_ops
        ]
    }

    if token_costs:
        metrics.update({
            'avg_cost_per_token': statistics.mean(token_costs),
            'median_cost_per_token': statistics.median(token_costs),
            'token_efficiency_operations': len(token_costs)
        })

    if char_costs:
        metrics.update({
            'avg_cost_per_character': statistics.mean(char_costs),
            'median_cost_per_character': statistics.median(char_costs),
            'tts_operations': len(char_costs)
        })

    return metrics


def generate_recommendations(costs: List[Dict[str, Any]], analysis: Dict[str, Any]) -> List[str]:
    """Generate cost optimization recommendations."""
    recommendations = []

    if not costs:
        return ["No cost data available for analysis."]

    # Analyze agent efficiency
    agent_analysis = analysis.get('by_agent', {})
    if agent_analysis:
        most_expensive_agent = max(agent_analysis.items(), key=lambda x: x[1]['total_cost'])
        least_efficient_agent = max(agent_analysis.items(),
                                  key=lambda x: x[1].get('avg_cost_per_operation', 0))

        recommendations.append(
            f"Most expensive agent: {most_expensive_agent[0]} "
            f"(${most_expensive_agent[1]['total_cost']:.4f} total)"
        )

        recommendations.append(
            f"Least efficient agent: {least_efficient_agent[0]} "
            f"(${least_efficient_agent[1].get('avg_cost_per_operation', 0):.4f} per operation)"
        )

    # Analyze provider efficiency
    provider_analysis = analysis.get('by_provider', {})
    if provider_analysis:
        most_expensive_provider = max(provider_analysis.items(), key=lambda x: x[1]['total_cost'])
        recommendations.append(
            f"Most expensive provider: {most_expensive_provider[0]} "
            f"(${most_expensive_provider[1]['total_cost']:.4f} total)"
        )

    # Budget efficiency
    episode_analysis = analysis.get('by_episode', {})
    if episode_analysis:
        episodes = list(episode_analysis.values())
        if episodes:
            avg_cost_per_episode = statistics.mean([e['total_cost'] for e in episodes])
            recommendations.append(f"Average cost per episode: ${avg_cost_per_episode:.4f}")

            under_budget = [e for e in episodes if e['final_budget_remaining'] > 0]
            over_budget = [e for e in episodes if e['final_budget_remaining'] < 0]

            if over_budget:
                recommendations.append(f"⚠️  {len(over_budget)} episodes exceeded budget")

            if under_budget:
                avg_savings = statistics.mean([e['final_budget_remaining'] for e in under_budget])
                recommendations.append(f"✅ Average budget savings: ${avg_savings:.4f}")

    # Token efficiency recommendations
    efficiency = analysis.get('efficiency_metrics', {})
    if efficiency.get('avg_cost_per_token'):
        cost_per_token = efficiency['avg_cost_per_token']
        if cost_per_token > 0.00001:  # $0.01 per 1K tokens
            recommendations.append("⚠️  High cost per token - consider using smaller models")
        else:
            recommendations.append("✅ Good token efficiency achieved")

    return recommendations


def format_analysis_report(analysis: Dict[str, Any], format_type: str = 'text') -> str:
    """Format analysis results as a report."""
    if format_type == 'json':
        # Convert datetime objects to strings for JSON serialization
        serializable_analysis = json.loads(json.dumps(analysis, default=str))
        return json.dumps(serializable_analysis, indent=2)

    # Text format
    report = []
    report.append("=" * 60)
    report.append("PODCAST PRODUCTION COST ANALYSIS REPORT")
    report.append("=" * 60)
    report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append("")

    # Summary
    if 'efficiency_metrics' in analysis:
        metrics = analysis['efficiency_metrics']
        report.append("COST SUMMARY:")
        report.append(f"- Total Operations: {metrics.get('total_operations', 0)}")
        report.append(f"- Total Cost: ${metrics.get('total_cost', 0):.4f}")
        report.append(f"- Average Cost/Operation: ${metrics.get('avg_cost_per_operation', 0):.4f}")
        report.append(f"- Maximum Single Operation: ${metrics.get('max_cost_operation', 0):.4f}")

        if 'avg_cost_per_token' in metrics:
            report.append(f"- Average Cost/Token: ${metrics['avg_cost_per_token']:.6f}")

        if 'avg_cost_per_character' in metrics:
            report.append(f"- Average Cost/Character: ${metrics['avg_cost_per_character']:.6f}")

        report.append("")

    # By Agent Analysis
    if 'by_agent' in analysis:
        report.append("COST BY AGENT:")
        agent_data = sorted(analysis['by_agent'].items(),
                          key=lambda x: x[1]['total_cost'], reverse=True)

        for agent, stats in agent_data:
            report.append(f"- {agent}:")
            report.append(f"  * Total Cost: ${stats['total_cost']:.4f}")
            report.append(f"  * Operations: {stats['operation_count']}")
            report.append(f"  * Avg/Operation: ${stats['avg_cost_per_operation']:.4f}")
            report.append(f"  * Providers: {', '.join(stats['providers_used'])}")
        report.append("")

    # By Provider Analysis
    if 'by_provider' in analysis:
        report.append("COST BY PROVIDER:")
        provider_data = sorted(analysis['by_provider'].items(),
                             key=lambda x: x[1]['total_cost'], reverse=True)

        for provider, stats in provider_data:
            report.append(f"- {provider}:")
            report.append(f"  * Total Cost: ${stats['total_cost']:.4f}")
            report.append(f"  * Operations: {stats['operation_count']}")
            report.append(f"  * Avg/Operation: ${stats['avg_cost_per_operation']:.4f}")
            report.append(f"  * Models: {', '.join(stats['models_used'])}")
            if stats.get('avg_cost_per_token', 0) > 0:
                report.append(f"  * Cost/Token: ${stats['avg_cost_per_token']:.6f}")
        report.append("")

    # By Episode Analysis
    if 'by_episode' in analysis:
        report.append("COST BY EPISODE:")
        episode_data = sorted(analysis['by_episode'].items(),
                            key=lambda x: x[1]['total_cost'], reverse=True)

        for episode, stats in episode_data[:10]:  # Show top 10
            report.append(f"- {episode}:")
            report.append(f"  * Total Cost: ${stats['total_cost']:.4f}")
            report.append(f"  * Budget Remaining: ${stats['final_budget_remaining']:.4f}")
            report.append(f"  * Operations: {stats['operation_count']}")
            report.append(f"  * Duration: {stats['duration_minutes']:.1f} minutes")
            report.append(f"  * Agents: {', '.join(stats['agents_used'])}")
        report.append("")

    # Recommendations
    if 'recommendations' in analysis:
        report.append("OPTIMIZATION RECOMMENDATIONS:")
        for rec in analysis['recommendations']:
            report.append(f"- {rec}")
        report.append("")

    # Most Expensive Operations
    if 'efficiency_metrics' in analysis and 'most_expensive_operations' in analysis['efficiency_metrics']:
        report.append("MOST EXPENSIVE OPERATIONS:")
        for i, op in enumerate(analysis['efficiency_metrics']['most_expensive_operations'], 1):
            report.append(f"{i}. {op['agent']} via {op['provider']}/{op['model']} - ${op['cost']:.4f}")
            if op['operation']:
                report.append(f"   Operation: {op['operation']}")
        report.append("")

    report.append("=" * 60)

    return "\n".join(report)


def main():
    """Main function for cost analysis CLI."""
    parser = argparse.ArgumentParser(
        description="Analyze podcast production costs",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        '--episode', '-e',
        help='Filter by specific episode ID'
    )

    parser.add_argument(
        '--days', '-d',
        type=int,
        help='Filter by last N days'
    )

    parser.add_argument(
        '--format', '-f',
        choices=['text', 'json'],
        default='text',
        help='Output format (default: text)'
    )

    parser.add_argument(
        '--csv-file',
        type=Path,
        default=Path('logs/costs.csv'),
        help='Path to CSV cost data file (default: logs/costs.csv)'
    )

    args = parser.parse_args()

    # Load cost data
    costs = load_cost_data(
        csv_file=args.csv_file,
        episode_filter=args.episode,
        days_filter=args.days
    )

    if not costs:
        print("No cost data found matching the specified criteria.")
        return

    # Perform analysis
    analysis = {
        'by_agent': analyze_by_agent(costs),
        'by_provider': analyze_by_provider(costs),
        'by_episode': analyze_by_episode(costs),
        'efficiency_metrics': calculate_efficiency_metrics(costs)
    }

    # Generate recommendations
    analysis['recommendations'] = generate_recommendations(costs, analysis)

    # Output report
    report = format_analysis_report(analysis, args.format)
    print(report)


if __name__ == '__main__':
    main()
