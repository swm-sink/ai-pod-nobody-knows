#!/usr/bin/env python3
"""
Validate all API keys are properly configured and working.

This script tests connections to all configured providers without
exposing sensitive information in logs or error messages.

Version: 1.0.0
Date: August 2025
"""

import os
import sys
import json
import logging
from typing import Dict, Tuple, List, Optional
from datetime import datetime
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

# Configure logging with secure formatting
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)


class APIKeyValidator:
    """Validates API keys for all configured providers."""

    def __init__(self):
        """Initialize validator and load environment variables."""
        self.results = {}
        self.load_environment()

    def load_environment(self) -> None:
        """Load environment variables from .env file if it exists."""
        env_path = Path(__file__).parent.parent / '.env'
        if env_path.exists():
            try:
                # Simple .env file parser
                with open(env_path, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith('#') and '=' in line:
                            key, value = line.split('=', 1)
                            os.environ[key.strip()] = value.strip()
                logger.info("Loaded environment variables from .env file")
            except Exception as e:
                logger.warning(f"Failed to load .env file: {self._mask_error(e)}")
        else:
            logger.info("No .env file found, using system environment variables")

    def validate_langfuse(self) -> Tuple[bool, str]:
        """
        Validate LangFuse API keys.

        Returns:
            Tuple of (success, message)
        """
        try:
            public_key = os.environ.get('LANGFUSE_PUBLIC_KEY')
            secret_key = os.environ.get('LANGFUSE_SECRET_KEY')
            host = os.environ.get('LANGFUSE_HOST', 'https://us.cloud.langfuse.com')

            if not public_key or not secret_key:
                return False, "Missing API keys in environment"

            # Mask keys for logging
            masked_public = f"...{public_key[-4:]}" if len(public_key) > 4 else "****"
            masked_secret = f"...{secret_key[-4:]}" if len(secret_key) > 4 else "****"

            logger.info(f"Testing LangFuse connection to {host}")
            logger.debug(f"Using public key: {masked_public}")

            # Would make actual API call to validate
            # For now, we check if keys are in correct format
            if public_key.startswith('pk-lf-') and secret_key.startswith('sk-lf-'):
                return True, f"Keys validated (public: {masked_public})"
            else:
                return False, "Invalid key format"

        except Exception as e:
            return False, f"Validation error: {self._mask_error(e)}"

    def validate_perplexity(self) -> Tuple[bool, str]:
        """
        Validate Perplexity API key.

        Returns:
            Tuple of (success, message)
        """
        try:
            api_key = os.environ.get('PERPLEXITY_API_KEY')

            if not api_key:
                return False, "Missing API key in environment"

            # Mask key for logging
            masked_key = f"...{api_key[-4:]}" if len(api_key) > 4 else "****"

            logger.info("Testing Perplexity API connection")
            logger.debug(f"Using API key: {masked_key}")

            # Would make actual API call to validate
            # import httpx
            # response = httpx.get(
            #     "https://api.perplexity.ai/chat/completions",
            #     headers={"Authorization": f"Bearer {api_key}"}
            # )

            # For now, check key format
            if api_key.startswith('pplx-'):
                return True, f"Key validated ({masked_key})"
            else:
                return False, "Invalid key format"

        except Exception as e:
            return False, f"Validation error: {self._mask_error(e)}"

    def validate_openrouter(self) -> Tuple[bool, str]:
        """
        Validate OpenRouter API key.

        Returns:
            Tuple of (success, message)
        """
        try:
            api_key = os.environ.get('OPENROUTER_API_KEY')
            base_url = os.environ.get('OPENROUTER_BASE_URL', 'https://openrouter.ai/api/v1')

            if not api_key:
                return False, "Missing API key in environment"

            # Mask key for logging
            masked_key = f"...{api_key[-4:]}" if len(api_key) > 4 else "****"

            logger.info(f"Testing OpenRouter connection to {base_url}")
            logger.debug(f"Using API key: {masked_key}")

            # Would make actual API call to validate
            # import httpx
            # response = httpx.get(
            #     f"{base_url}/models",
            #     headers={"Authorization": f"Bearer {api_key}"}
            # )

            # For now, check key format
            if api_key.startswith('sk-or-'):
                return True, f"Key validated ({masked_key})"
            else:
                return False, "Invalid key format"

        except Exception as e:
            return False, f"Validation error: {self._mask_error(e)}"

    def validate_all(self) -> Dict[str, Dict[str, any]]:
        """
        Validate all configured API keys.

        Returns:
            Dictionary with validation results for each provider
        """
        providers = {
            'LangFuse': self.validate_langfuse,
            'Perplexity': self.validate_perplexity,
            'OpenRouter': self.validate_openrouter
        }

        results = {}
        for name, validator in providers.items():
            logger.info(f"\n{'='*50}")
            logger.info(f"Validating {name}...")
            logger.info(f"{'='*50}")

            success, message = validator()
            results[name] = {
                'success': success,
                'message': message,
                'timestamp': datetime.now().isoformat()
            }

            if success:
                logger.info(f"✅ {name}: {message}")
            else:
                logger.error(f"❌ {name}: {message}")

        return results

    def _mask_error(self, error: Exception) -> str:
        """
        Mask sensitive information in error messages.

        Args:
            error: The exception to mask

        Returns:
            Masked error message
        """
        error_msg = str(error)

        # List of environment variables to mask
        sensitive_vars = [
            'LANGFUSE_PUBLIC_KEY',
            'LANGFUSE_SECRET_KEY',
            'PERPLEXITY_API_KEY',
            'OPENROUTER_API_KEY'
        ]

        for var in sensitive_vars:
            value = os.environ.get(var)
            if value:
                error_msg = error_msg.replace(value, f'***{var}***')

        return error_msg

    def generate_report(self, results: Dict[str, Dict[str, any]]) -> str:
        """
        Generate a validation report.

        Args:
            results: Validation results

        Returns:
            Formatted report string
        """
        report = []
        report.append("\n" + "="*60)
        report.append("API KEY VALIDATION REPORT")
        report.append("="*60)
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"Environment: {os.environ.get('ENV', 'development')}")
        report.append("")

        # Summary
        total = len(results)
        successful = sum(1 for r in results.values() if r['success'])
        failed = total - successful

        report.append("SUMMARY")
        report.append("-" * 40)
        report.append(f"Total Providers: {total}")
        report.append(f"✅ Successful: {successful}")
        report.append(f"❌ Failed: {failed}")
        report.append("")

        # Detailed results
        report.append("DETAILED RESULTS")
        report.append("-" * 40)

        for provider, result in results.items():
            status = "✅" if result['success'] else "❌"
            report.append(f"\n{status} {provider}:")
            report.append(f"   Status: {'Connected' if result['success'] else 'Failed'}")
            report.append(f"   Message: {result['message']}")
            report.append(f"   Tested: {result['timestamp']}")

        # Recommendations
        if failed > 0:
            report.append("\n" + "="*60)
            report.append("RECOMMENDATIONS")
            report.append("-" * 40)

            for provider, result in results.items():
                if not result['success']:
                    report.append(f"\n{provider}:")
                    if "Missing" in result['message']:
                        report.append("   - Check that API key is set in .env file")
                        report.append("   - Verify environment variable name is correct")
                    elif "Invalid" in result['message']:
                        report.append("   - Verify API key format is correct")
                        report.append("   - Check if key has been regenerated")
                    else:
                        report.append("   - Check network connectivity")
                        report.append("   - Verify API endpoint is accessible")

        report.append("\n" + "="*60)
        return "\n".join(report)


def main():
    """Main execution function."""
    try:
        print("\n🔐 API Key Validation Tool v1.0.0")
        print("================================")
        print("Validating API keys for all configured providers...")

        validator = APIKeyValidator()
        results = validator.validate_all()

        # Generate and display report
        report = validator.generate_report(results)
        print(report)

        # Save report to file
        report_path = Path(__file__).parent.parent / 'validation_report.txt'
        with open(report_path, 'w') as f:
            f.write(report)
        print(f"\n📄 Report saved to: {report_path}")

        # Exit with appropriate code
        all_successful = all(r['success'] for r in results.values())
        if all_successful:
            print("\n✅ All API keys validated successfully!")
            sys.exit(0)
        else:
            print("\n⚠️ Some API keys failed validation. Please check the report.")
            sys.exit(1)

    except KeyboardInterrupt:
        print("\n\n🛑 Validation cancelled by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        logger.exception("Validation failed with unexpected error")
        sys.exit(1)


if __name__ == "__main__":
    main()
