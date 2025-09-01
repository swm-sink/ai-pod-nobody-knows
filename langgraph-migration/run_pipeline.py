#!/usr/bin/env python3
"""
Run Pipeline Demo Script

This script demonstrates the complete end-to-end podcast production pipeline
connecting all 9 migrated agents with proper state passing and cost tracking.

Usage:
    python run_pipeline.py --topic "quantum computing" --budget 5.51
    python run_pipeline.py --topic "artificial intelligence ethics" --dry-run
    python run_pipeline.py --help

Features:
- Research Pipeline: discovery → deep_dive → validation → synthesis
- Production Pipeline: question_generation → episode_planning → script_writing → brand_validation
- Cost Tracking: Real-time budget monitoring and reporting
- Error Handling: Graceful failure recovery and detailed error reporting
- Dry Run Mode: Test pipeline structure without API calls

Version: 1.0.0
Date: August 2025
"""

import asyncio
import argparse
import json
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, Any

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent / "src"))

from src.core.cost_tracker import create_cost_tracker
from src.core.state import create_initial_state
from src.workflows.main_workflow import execute_workflow
from src.workflows.research_pipeline import run_research_pipeline
from src.workflows.production_pipeline import run_production_pipeline


def create_parser() -> argparse.ArgumentParser:
    """Create command line argument parser."""
    parser = argparse.ArgumentParser(
        description="Run complete podcast production pipeline",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --topic "quantum computing"
  %(prog)s --topic "artificial intelligence ethics" --budget 3.00
  %(prog)s --topic "climate change solutions" --dry-run --verbose
  %(prog)s --topic "space exploration" --output-dir ./episodes/space
        """
    )

    parser.add_argument(
        "--topic",
        required=True,
        help="Podcast episode topic"
    )

    parser.add_argument(
        "--budget",
        type=float,
        default=5.51,
        help="Maximum budget in dollars (default: 5.51)"
    )

    parser.add_argument(
        "--output-dir",
        default="./pipeline_output",
        help="Output directory for results (default: ./pipeline_output)"
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run pipeline without making API calls (for testing)"
    )

    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose logging"
    )

    parser.add_argument(
        "--research-only",
        action="store_true",
        help="Run only research pipeline (for testing)"
    )

    parser.add_argument(
        "--production-only",
        action="store_true",
        help="Run only production pipeline (requires existing research data)"
    )

    parser.add_argument(
        "--research-data",
        help="Path to existing research data JSON file (for production-only mode)"
    )

    return parser


def setup_logging(verbose: bool = False):
    """Setup logging configuration."""
    import logging

    level = logging.DEBUG if verbose else logging.INFO

    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('pipeline_run.log')
        ]
    )


def save_results(results: Dict[str, Any], output_dir: str, filename: str):
    """Save results to JSON file."""
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    file_path = output_path / f"{filename}.json"
    with open(file_path, 'w') as f:
        json.dump(results, f, indent=2, default=str)

    print(f"📄 Results saved to: {file_path}")
    return file_path


def print_cost_summary(results: Dict[str, Any]):
    """Print cost summary from results."""
    cost_data = results.get('cost', {})

    print("\n💰 Cost Summary:")
    print("=" * 50)

    total = cost_data.get('total', 0)
    print(f"Total Cost: ${total:.4f}")

    # Print breakdown by stage
    for stage, cost in cost_data.items():
        if stage != 'total' and isinstance(cost, (int, float)):
            percentage = (cost / total * 100) if total > 0 else 0
            print(f"  {stage}: ${cost:.4f} ({percentage:.1f}%)")

    print("=" * 50)


def print_pipeline_summary(results: Dict[str, Any]):
    """Print pipeline execution summary."""
    stage = results.get('stage', 'unknown')
    error = results.get('error')

    print(f"\n📊 Pipeline Status: {stage.upper()}")

    if error:
        print(f"❌ Error: {error}")
        return False

    # Print key results
    pipeline_results = results.get('results', {})

    if 'research_data' in pipeline_results:
        research_data = pipeline_results['research_data']
        sources = len(research_data.get('discovery', {}).get('source_diversity', {}).get('sources', []))
        print(f"🔍 Research Sources: {sources}")

    if 'research_questions' in pipeline_results:
        questions = len(pipeline_results.get('research_questions', []))
        print(f"❓ Generated Questions: {questions}")

    if 'episode_plan' in pipeline_results:
        plan = pipeline_results['episode_plan']
        duration = plan.get('estimated_duration', 'unknown')
        print(f"⏱️  Estimated Duration: {duration} minutes")

    if 'script_raw' in pipeline_results:
        script_length = len(pipeline_results.get('script_raw', ''))
        print(f"📝 Script Length: {script_length} characters")

    if 'quality_scores' in pipeline_results:
        scores = pipeline_results['quality_scores']
        overall = scores.get('overall', 0)
        print(f"⭐ Overall Quality Score: {overall}/10")

    return True


async def run_research_pipeline_demo(topic: str, dry_run: bool = False) -> Dict[str, Any]:
    """Run research pipeline demonstration."""
    print(f"\n🔬 Starting Research Pipeline for: {topic}")
    print("=" * 60)

    start_time = time.time()

    try:
        results = await run_research_pipeline(topic)
        duration = time.time() - start_time

        print(f"✅ Research Pipeline completed in {duration:.1f} seconds")
        return results

    except Exception as e:
        duration = time.time() - start_time
        print(f"❌ Research Pipeline failed after {duration:.1f} seconds: {e}")
        return {'error': str(e), 'stage': 'research_failed'}


async def run_production_pipeline_demo(
    topic: str,
    research_data: Dict[str, Any],
    dry_run: bool = False
) -> Dict[str, Any]:
    """Run production pipeline demonstration."""
    print(f"\n🏭 Starting Production Pipeline for: {topic}")
    print("=" * 60)

    start_time = time.time()

    try:
        results = await run_production_pipeline(topic, research_data)
        duration = time.time() - start_time

        print(f"✅ Production Pipeline completed in {duration:.1f} seconds")
        return results

    except Exception as e:
        duration = time.time() - start_time
        print(f"❌ Production Pipeline failed after {duration:.1f} seconds: {e}")
        return {'error': str(e), 'stage': 'production_failed'}


async def run_complete_pipeline_demo(
    topic: str,
    budget: float,
    output_dir: str,
    dry_run: bool = False,
    verbose: bool = False
) -> Dict[str, Any]:
    """Run complete pipeline demonstration using main workflow."""
    print(f"\n🚀 Starting Complete Pipeline for: {topic}")
    print("=" * 60)

    start_time = time.time()

    try:
        # Create initial state
        initial_state = create_initial_state(
            topic=topic,
            budget=budget,
            output_dir=output_dir,
            dry_run=dry_run,
            verbose=verbose
        )

        # Execute complete workflow
        final_state = await execute_workflow(
            topic=topic,
            budget=budget,
            output_dir=output_dir,
            dry_run=dry_run,
            verbose=verbose
        )

        duration = time.time() - start_time

        # Convert final_state to dict format for consistency
        results = {
            'topic': topic,
            'stage': final_state.get('current_stage', 'completed'),
            'results': dict(final_state),
            'cost': final_state.get('cost_tracking', {}),
            'error': final_state.get('errors')
        }

        print(f"✅ Complete Pipeline finished in {duration:.1f} seconds")
        return results

    except Exception as e:
        duration = time.time() - start_time
        print(f"❌ Complete Pipeline failed after {duration:.1f} seconds: {e}")
        return {'error': str(e), 'stage': 'pipeline_failed'}


async def main():
    """Main execution function."""
    parser = create_parser()
    args = parser.parse_args()

    # Setup logging
    setup_logging(args.verbose)

    print("🎙️  Podcast Production Pipeline Demo")
    print("=" * 60)
    print(f"Topic: {args.topic}")
    print(f"Budget: ${args.budget}")
    print(f"Output Directory: {args.output_dir}")
    print(f"Dry Run: {args.dry_run}")
    print(f"Verbose: {args.verbose}")

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    try:
        if args.research_only:
            # Run only research pipeline
            results = await run_research_pipeline_demo(args.topic, args.dry_run)
            filename = f"research_results_{timestamp}"

        elif args.production_only:
            # Run only production pipeline
            if not args.research_data:
                print("❌ Error: --research-data required for production-only mode")
                sys.exit(1)

            with open(args.research_data, 'r') as f:
                research_data = json.load(f)

            results = await run_production_pipeline_demo(
                args.topic,
                research_data.get('results', {}),
                args.dry_run
            )
            filename = f"production_results_{timestamp}"

        else:
            # Run complete pipeline
            results = await run_complete_pipeline_demo(
                args.topic,
                args.budget,
                args.output_dir,
                args.dry_run,
                args.verbose
            )
            filename = f"complete_results_{timestamp}"

        # Save results
        save_results(results, args.output_dir, filename)

        # Print summaries
        success = print_pipeline_summary(results)
        print_cost_summary(results)

        if success:
            print("\n🎉 Pipeline execution completed successfully!")
            sys.exit(0)
        else:
            print("\n💥 Pipeline execution failed!")
            sys.exit(1)

    except KeyboardInterrupt:
        print("\n🛑 Pipeline execution interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n💥 Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    # Run the async main function
    asyncio.run(main())
