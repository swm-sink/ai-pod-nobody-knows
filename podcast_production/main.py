#!/usr/bin/env python3
"""
AI Podcast Production System - Main CLI Entry Point

Command-line interface for the LangGraph-based podcast production workflow.
Provides a simple, unified interface for creating high-quality podcast episodes.

Usage:
    python main.py --topic "Why do we dream?" --budget 5.51
    python main.py --topic "Quantum Computing Basics" --budget 10.00 --dry-run
    python main.py --topic "AI Ethics" --output-dir "./episodes" --verbose

Version: 1.0.0
Date: August 2025
"""

import argparse
import asyncio
import json
import logging
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, Any

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

from core.config.manager import ConfigManager, get_config_manager
from core.state import create_initial_state, validate_state
from core.logging_config import setup_logging as setup_app_logging
from workflows.main_workflow import execute_workflow


def setup_logging(verbose: bool = False) -> None:
    """Configure logging for the application."""
    setup_app_logging(verbose=verbose, component="main")


def load_configuration() -> ConfigManager:
    """Load and validate configuration."""
    try:
        config_manager = get_config_manager()
        logger = logging.getLogger(__name__)
        logger.info("Configuration loaded successfully")
        return config_manager
    except Exception as e:
        print(f"Configuration loading failed: {e}")
        sys.exit(1)


def validate_environment() -> None:
    """Validate environment and dependencies."""
    logger = logging.getLogger(__name__)

    # Check required environment variables for non-dry runs
    required_envs = {
        "PERPLEXITY_API_KEY": "Required for research stages",  # pragma: allowlist secret
        "LANGFUSE_PUBLIC_KEY": "Required for observability",  # pragma: allowlist secret
        "LANGFUSE_SECRET_KEY": "Required for observability"  # pragma: allowlist secret
    }

    missing = []
    for env_var, description in required_envs.items():
        if not os.getenv(env_var):
            missing.append(f"{env_var}: {description}")

    if missing:
        logger.warning("Missing environment variables (use --dry-run to test without APIs):")
        for item in missing:
            logger.warning(f"  - {item}")


def parse_arguments() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="AI Podcast Production System - Generate high-quality podcast episodes",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python main.py --topic "Why do we dream?"
  python main.py --topic "Quantum Computing" --budget 10.00
  python main.py --topic "AI Ethics" --dry-run --verbose
  python main.py --topic "Climate Science" --output-dir "./episodes"

For more information, see the documentation in ./docs/
        """
    )

    # Required arguments
    parser.add_argument(
        "--topic",
        required=True,
        help="The topic for the podcast episode (required)"
    )

    # Optional arguments
    parser.add_argument(
        "--budget",
        type=float,
        default=5.51,
        help="Maximum budget for episode production (default: $5.51)"
    )

    parser.add_argument(
        "--output-dir",
        default="./output",
        help="Directory for output files (default: ./output)"
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run without making API calls (for testing)"
    )

    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose logging"
    )

    parser.add_argument(
        "--config-dir",
        default="./config",
        help="Configuration directory (default: ./config)"
    )

    parser.add_argument(
        "--save-state",
        action="store_true",
        help="Save final state to JSON file"
    )

    return parser.parse_args()


async def main() -> None:
    """Main application entry point."""

    # Parse arguments
    args = parse_arguments()

    # Setup logging
    setup_logging(args.verbose)
    logger = logging.getLogger(__name__)

    logger.info("=" * 60)
    logger.info("AI Podcast Production System - August 2025")
    logger.info("=" * 60)
    logger.info(f"Topic: {args.topic}")
    logger.info(f"Budget: ${args.budget:.2f}")
    logger.info(f"Output Directory: {args.output_dir}")
    logger.info(f"Dry Run: {args.dry_run}")
    logger.info("=" * 60)

    try:
        # Load configuration
        config_manager = load_configuration()

        # Validate environment
        validate_environment()

        # Create output directory
        output_dir = Path(args.output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        logger.info(f"Output directory created: {output_dir}")

        # Create initial state
        initial_state = create_initial_state(
            topic=args.topic,
            budget=args.budget,
            output_dir=str(output_dir),
            dry_run=args.dry_run,
            verbose=args.verbose
        )

        # Validate initial state
        validation_errors = validate_state(initial_state)
        if validation_errors:
            logger.error("State validation failed:")
            for error in validation_errors:
                logger.error(f"  - {error}")
            sys.exit(1)

        logger.info(f"Episode ID: {initial_state['episode_id']}")

        # Execute workflow
        logger.info("Starting podcast production workflow...")
        final_state = await execute_workflow(
            topic=args.topic,
            budget=args.budget,
            output_dir=str(output_dir),
            dry_run=args.dry_run,
            verbose=args.verbose,
            config=config_manager._config_cache
        )

        # Report results
        print("\n" + "=" * 60)
        print("PODCAST PRODUCTION COMPLETE")
        print("=" * 60)
        print(f"Episode ID: {final_state['episode_id']}")
        print(f"Topic: {final_state['topic']}")
        print(f"Final Stage: {final_state.get('current_stage', 'unknown')}")
        print(f"Total Cost: ${final_state.get('total_cost', 0.0):.2f}")
        print(f"Budget Used: {(final_state.get('total_cost', 0.0) / args.budget * 100):.1f}%")

        # Show cost breakdown
        cost_breakdown = final_state.get("cost_breakdown", {})
        if cost_breakdown:
            print("\nCost Breakdown:")
            for stage, cost in cost_breakdown.items():
                print(f"  {stage}: ${cost:.2f}")

        # Show quality scores
        quality_scores = final_state.get("quality_scores", {})
        if quality_scores:
            print("\nQuality Scores:")
            for metric, score in quality_scores.items():
                if metric != "mock":
                    print(f"  {metric}: {score}/10")

        # Show errors if any
        errors = final_state.get("errors", [])
        if errors:
            print("\nErrors Encountered:")
            for error in errors:
                print(f"  [{error.get('stage', 'unknown')}] {error.get('error', 'Unknown error')}")

        # Show outputs
        outputs = []
        if final_state.get("script_polished"):
            outputs.append("Script generated")
        if final_state.get("audio_file_path"):
            outputs.append(f"Audio: {final_state['audio_file_path']}")

        if outputs:
            print("\nOutputs Generated:")
            for output in outputs:
                print(f"  ✓ {output}")

        # Save state if requested
        if args.save_state:
            state_path = output_dir / f"{final_state['episode_id']}_final_state.json"
            with open(state_path, 'w') as f:
                json.dump(final_state, f, indent=2, default=str)
            print(f"\nFinal state saved to: {state_path}")

        print("=" * 60)

        # Exit with appropriate code
        if final_state.get("current_stage") == "completed":
            logger.info("Workflow completed successfully")
            sys.exit(0)
        else:
            logger.error("Workflow failed or incomplete")
            sys.exit(1)

    except KeyboardInterrupt:
        logger.info("Production interrupted by user")
        print("\nProduction interrupted by user")
        sys.exit(130)

    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        print(f"\nError: {e}")
        sys.exit(1)


def run_sync() -> None:
    """Synchronous wrapper for async main function."""
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nInterrupted by user")
        sys.exit(130)


if __name__ == "__main__":
    run_sync()
