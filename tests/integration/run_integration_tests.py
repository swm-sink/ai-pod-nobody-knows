#!/usr/bin/env python3
"""
Integration Test Runner for Podcast Production Pipeline

This script provides a convenient way to run the integration test suite
with various configuration options and reporting.

Usage:
    python run_integration_tests.py [options]

Options:
    --quick: Run only fast tests (< 30s each)
    --full: Run complete test suite including slow tests
    --cost-limit: Set maximum cost for cost-sensitive tests
    --no-mock: Run with real APIs (WARNING: Will incur costs!)
    --performance: Run performance benchmarks
    --report: Generate detailed HTML report
    --verbose: Enable verbose output
"""

import sys
import argparse
import subprocess
import json
import time
from pathlib import Path
from typing import List, Dict, Any
import os


class IntegrationTestRunner:
    """
    Manages execution of integration tests with various configurations.
    """

    def __init__(self):
        self.test_dir = Path(__file__).parent
        self.results_dir = self.test_dir / "test_results"
        self.results_dir.mkdir(exist_ok=True)

    def run_tests(self, test_config: Dict[str, Any]) -> Dict[str, Any]:
        """Run tests with specified configuration."""
        start_time = time.time()

        # Build pytest command
        pytest_args = self._build_pytest_args(test_config)

        print(f"Running integration tests with configuration:")
        for key, value in test_config.items():
            print(f"  {key}: {value}")
        print()

        # Execute tests
        try:
            result = subprocess.run(
                pytest_args,
                cwd=self.test_dir.parent.parent,  # Run from project root
                capture_output=True,
                text=True,
                timeout=test_config.get('timeout', 1800)  # 30 minute default timeout
            )

            execution_time = time.time() - start_time

            # Parse results
            test_results = {
                'success': result.returncode == 0,
                'execution_time': execution_time,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'return_code': result.returncode,
                'configuration': test_config,
                'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
            }

            # Save results
            self._save_results(test_results)

            # Print summary
            self._print_summary(test_results)

            return test_results

        except subprocess.TimeoutExpired:
            print(f"❌ Tests timed out after {test_config.get('timeout', 1800)} seconds")
            return {
                'success': False,
                'error': 'timeout',
                'execution_time': time.time() - start_time
            }
        except Exception as e:
            print(f"❌ Error running tests: {e}")
            return {
                'success': False,
                'error': str(e),
                'execution_time': time.time() - start_time
            }

    def _build_pytest_args(self, config: Dict[str, Any]) -> List[str]:
        """Build pytest command arguments from configuration."""
        args = ['python', '-m', 'pytest']

        # Test selection
        if config.get('quick'):
            args.extend(['-m', 'not slow and not expensive'])
        elif config.get('performance'):
            args.extend(['-m', 'performance'])
        elif config.get('cost_sensitive'):
            args.extend(['-m', 'cost_sensitive'])

        # Verbosity
        if config.get('verbose'):
            args.append('-vv')
        else:
            args.append('-v')

        # Reporting
        if config.get('report'):
            report_file = self.results_dir / f"test_report_{int(time.time())}.html"
            args.extend(['--html', str(report_file)])

        # Coverage
        if config.get('coverage'):
            args.extend(['--cov=podcast_production', '--cov-report=term-missing'])

        # Parallel execution
        if config.get('parallel') and config['parallel'] > 1:
            args.extend(['-n', str(config['parallel'])])

        # Test directory
        args.append('tests/integration')

        # Additional pytest args
        if config.get('pytest_args'):
            args.extend(config['pytest_args'])

        return args

    def _save_results(self, results: Dict[str, Any]):
        """Save test results to file."""
        timestamp = int(time.time())
        results_file = self.results_dir / f"integration_test_results_{timestamp}.json"

        # Remove large stdout/stderr for JSON storage
        json_results = results.copy()
        if len(json_results.get('stdout', '')) > 10000:
            json_results['stdout'] = json_results['stdout'][:10000] + '\n... (truncated)'
        if len(json_results.get('stderr', '')) > 5000:
            json_results['stderr'] = json_results['stderr'][:5000] + '\n... (truncated)'

        with open(results_file, 'w') as f:
            json.dump(json_results, f, indent=2)

        print(f"📄 Results saved to: {results_file}")

    def _print_summary(self, results: Dict[str, Any]):
        """Print test execution summary."""
        print("\n" + "="*50)
        print("INTEGRATION TEST SUMMARY")
        print("="*50)

        if results['success']:
            print("✅ Status: PASSED")
        else:
            print("❌ Status: FAILED")

        print(f"⏱️  Execution Time: {results['execution_time']:.2f} seconds")
        print(f"🔧 Configuration: {results['configuration']}")

        # Parse stdout for test counts if available
        stdout = results.get('stdout', '')
        if 'passed' in stdout or 'failed' in stdout:
            # Extract test counts from pytest output
            lines = stdout.split('\n')
            for line in lines:
                if 'passed' in line and ('failed' in line or 'error' in line):
                    print(f"📊 Results: {line.strip()}")
                    break

        # Show warnings/errors if any
        stderr = results.get('stderr', '')
        if stderr.strip():
            print(f"⚠️  Warnings/Errors:")
            print(stderr[:500] + ('...' if len(stderr) > 500 else ''))

        print("="*50 + "\n")


def main():
    """Main entry point for test runner."""
    parser = argparse.ArgumentParser(
        description="Run integration tests for podcast production pipeline",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    # Test selection options
    parser.add_argument(
        '--quick', action='store_true',
        help='Run only quick tests (exclude slow and expensive tests)'
    )
    parser.add_argument(
        '--full', action='store_true',
        help='Run complete test suite including slow tests'
    )
    parser.add_argument(
        '--performance', action='store_true',
        help='Run performance benchmark tests'
    )
    parser.add_argument(
        '--cost-sensitive', action='store_true',
        help='Run cost-sensitive tests (may incur API charges)'
    )

    # Configuration options
    parser.add_argument(
        '--cost-limit', type=float, default=10.0,
        help='Maximum cost limit for cost-sensitive tests (default: $10.00)'
    )
    parser.add_argument(
        '--no-mock', action='store_true',
        help='Run with real APIs instead of mocks (WARNING: Will incur costs!)'
    )
    parser.add_argument(
        '--parallel', type=int, default=1,
        help='Number of parallel test workers (requires pytest-xdist)'
    )
    parser.add_argument(
        '--timeout', type=int, default=1800,
        help='Test timeout in seconds (default: 1800)'
    )

    # Output options
    parser.add_argument(
        '--verbose', '-v', action='store_true',
        help='Enable verbose output'
    )
    parser.add_argument(
        '--report', action='store_true',
        help='Generate HTML test report (requires pytest-html)'
    )
    parser.add_argument(
        '--coverage', action='store_true',
        help='Include code coverage analysis (requires pytest-cov)'
    )

    # Additional pytest arguments
    parser.add_argument(
        '--pytest-args', nargs='*',
        help='Additional arguments to pass to pytest'
    )

    args = parser.parse_args()

    # Validate arguments
    if args.no_mock and not args.cost_sensitive:
        print("⚠️  WARNING: --no-mock flag set but --cost-sensitive not specified.")
        print("This may result in unexpected API charges.")
        response = input("Continue? (y/N): ")
        if response.lower() != 'y':
            print("Aborted.")
            return 1

    # Build test configuration
    test_config = {
        'quick': args.quick,
        'full': args.full,
        'performance': args.performance,
        'cost_sensitive': args.cost_sensitive,
        'cost_limit': args.cost_limit,
        'use_mocks': not args.no_mock,
        'parallel': args.parallel,
        'timeout': args.timeout,
        'verbose': args.verbose,
        'report': args.report,
        'coverage': args.coverage,
        'pytest_args': args.pytest_args or []
    }

    # Set environment variables for test configuration
    if test_config['use_mocks']:
        os.environ['USE_MOCK_APIS'] = 'true'
    else:
        os.environ['USE_MOCK_APIS'] = 'false'

    os.environ['MAX_TEST_COST'] = str(test_config['cost_limit'])

    # Run tests
    runner = IntegrationTestRunner()
    results = runner.run_tests(test_config)

    # Return appropriate exit code
    return 0 if results['success'] else 1


if __name__ == '__main__':
    sys.exit(main())
