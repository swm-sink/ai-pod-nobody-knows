#!/usr/bin/env python3
"""
AI Podcast Production System - Health Check Script

Standalone health check utility that validates system status, API connectivity,
and production readiness using the core health module.

Usage:
    python check_health.py
    python check_health.py --verbose
    python check_health.py --output-file ./reports/health_report.json

Version: 1.0.0
Date: September 2025
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Dict, Any

# Load environment variables
from dotenv import load_dotenv
load_dotenv()

from core.health import HealthChecker, HealthStatus


def setup_logging(verbose: bool = False) -> None:
    """Configure logging for health check."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )


def format_health_report(health_status: HealthStatus, verbose: bool = False) -> str:
    """Format health status for console output."""
    lines = []
    
    # Header
    lines.append("=" * 60)
    lines.append("PODCAST PRODUCTION SYSTEM HEALTH CHECK")
    lines.append("=" * 60)
    
    # Overall status
    status_emoji = "✅" if health_status.status == "healthy" else "❌"
    lines.append(f"Overall Status: {status_emoji} {health_status.status.upper()}")
    lines.append(f"Health Score: {health_status.score:.1f}/100")
    lines.append(f"Check Time: {health_status.timestamp}")
    lines.append("")
    
    # Component status
    lines.append("COMPONENT STATUS:")
    lines.append("-" * 20)
    component_health = getattr(health_status, 'component_health', {})
    for component, status in component_health.items():
        emoji = "✅" if status else "❌"
        lines.append(f"  {emoji} {component.replace('_', ' ').title()}")
    
    # Warnings
    warnings = getattr(health_status, 'warnings', [])
    if warnings:
        lines.append("")
        lines.append("WARNINGS:")
        lines.append("-" * 10)
        for warning in warnings:
            lines.append(f"  ⚠️  {warning}")
    
    # Critical issues
    critical_issues = getattr(health_status, 'critical_issues', [])
    if critical_issues:
        lines.append("")
        lines.append("CRITICAL ISSUES:")
        lines.append("-" * 16)
        for issue in critical_issues:
            lines.append(f"  🚨 {issue}")
    
    # Recommendations
    recommendations = getattr(health_status, 'recommendations', [])
    if recommendations and verbose:
        lines.append("")
        lines.append("RECOMMENDATIONS:")
        lines.append("-" * 15)
        for recommendation in recommendations:
            lines.append(f"  💡 {recommendation}")
    
    lines.append("=" * 60)
    return "\n".join(lines)


def save_health_report(health_status: HealthStatus, output_path: Path) -> None:
    """Save health report to JSON file."""
    report_data = {
        "overall_status": health_status.status,
        "health_score": health_status.score,
        "check_timestamp": health_status.timestamp,
        "component_health": getattr(health_status, 'component_health', {}),
        "warnings": getattr(health_status, 'warnings', []),
        "critical_issues": getattr(health_status, 'critical_issues', []),
        "recommendations": getattr(health_status, 'recommendations', [])
    }
    
    # Ensure output directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w') as f:
        json.dump(report_data, f, indent=2)
    
    print(f"Health report saved to: {output_path}")


def parse_arguments() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="AI Podcast Production System Health Check",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python check_health.py
  python check_health.py --verbose
  python check_health.py --output-file ./reports/health.json
        """
    )
    
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose output with detailed information"
    )
    
    parser.add_argument(
        "--output-file", "-o",
        type=Path,
        help="Save health report to JSON file"
    )
    
    parser.add_argument(
        "--quiet", "-q",
        action="store_true",
        help="Minimal output - only show overall status"
    )
    
    return parser.parse_args()


def main() -> None:
    """Main health check entry point."""
    args = parse_arguments()
    
    # Setup logging
    setup_logging(args.verbose)
    logger = logging.getLogger(__name__)
    
    try:
        # Initialize health checker
        health_checker = HealthChecker()
        logger.info("Starting comprehensive health check...")
        
        # Perform health check
        health_status = health_checker.perform_full_health_check()
        
        # Display results
        if args.quiet:
            status_emoji = "✅" if health_status.status == "healthy" else "❌"
            print(f"{status_emoji} {health_status.status.upper()} ({health_status.score:.1f}/100)")
        else:
            report = format_health_report(health_status, args.verbose)
            print(report)
        
        # Save to file if requested
        if args.output_file:
            save_health_report(health_status, args.output_file)
        
        # Exit with appropriate code
        if health_status.status == "healthy":
            sys.exit(0)
        elif health_status.status == "warning":
            sys.exit(1)
        else:
            sys.exit(2)
    
    except KeyboardInterrupt:
        print("\nHealth check interrupted by user")
        sys.exit(130)
    
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        print(f"Error: Health check failed - {e}")
        sys.exit(3)


if __name__ == "__main__":
    main()