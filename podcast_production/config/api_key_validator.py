#!/usr/bin/env python3
"""
API Key Validation System for AI Podcast Production
Provides secure validation and format checking for all required API keys.

Security Features:
- Never logs actual key values
- Validates format patterns without exposing keys
- Provides clear error messages for troubleshooting
- Handles deprecation warnings (Google API key format)

Usage:
    from config.api_key_validator import APIKeyValidator
    
    validator = APIKeyValidator()
    results = validator.validate_all()
    if not results['all_valid']:
        print(f"Validation issues: {results['issues']}")
"""

import os
import re
import logging
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum

# Configure logging to never expose sensitive data
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class APIProvider(Enum):
    """Enumeration of supported API providers."""
    OPENAI = "OpenAI"
    ANTHROPIC = "Anthropic"
    PERPLEXITY = "Perplexity"
    ELEVENLABS = "ElevenLabs"
    GOOGLE = "Google"
    LANGFUSE = "Langfuse"

@dataclass
class ValidationResult:
    """Result of API key validation."""
    key_name: str
    provider: APIProvider
    is_valid: bool
    is_present: bool
    format_valid: bool
    security_level: str  # "HIGH", "MEDIUM", "LOW", "DEPRECATED"
    issues: List[str]
    recommendations: List[str]

class APIKeyValidator:
    """
    Comprehensive API key validation system with security best practices.
    
    Features:
    - Format validation using regex patterns
    - Security level assessment
    - Deprecation warnings
    - Secure validation (never logs actual keys)
    - Comprehensive recommendations
    """
    
    def __init__(self):
        """Initialize validator with API key patterns and security metadata."""
        self.validation_patterns = {
            # OpenAI API Keys - Two current formats
            "OPENAI_API_KEY": {
                "provider": APIProvider.OPENAI,
                "patterns": [
                    r"^sk-proj-[a-zA-Z0-9]{20,}T3BlbkFJ[a-zA-Z0-9]{20,}$",  # Project keys
                    r"^sk-[a-zA-Z0-9]{20,}$"  # Legacy format (still valid)
                ],
                "security_level": "HIGH",
                "required": True,
                "description": "OpenAI API key for GPT and other OpenAI models"
            },
            
            # Anthropic Claude API Keys
            "ANTHROPIC_API_KEY": {
                "provider": APIProvider.ANTHROPIC,
                "patterns": [
                    r"^sk-ant-api03-[a-zA-Z0-9_-]{95}$"  # Current Anthropic format
                ],
                "security_level": "HIGH",
                "required": True,
                "description": "Anthropic API key for Claude models"
            },
            
            # Perplexity API Keys
            "PERPLEXITY_API_KEY": {
                "provider": APIProvider.PERPLEXITY,
                "patterns": [
                    r"^pplx-[a-f0-9]{64}$"  # Perplexity standard format
                ],
                "security_level": "HIGH",
                "required": True,
                "description": "Perplexity API key for research and fact-checking"
            },
            
            # ElevenLabs API Keys
            "ELEVENLABS_API_KEY": {
                "provider": APIProvider.ELEVENLABS,
                "patterns": [
                    r"^[a-f0-9]{32}$",  # 32-character hex string (most common)
                    r"^[a-zA-Z0-9]{20,50}$"  # Flexible format for ElevenLabs variations
                ],
                "security_level": "HIGH", 
                "required": True,
                "description": "ElevenLabs API key for text-to-speech generation"
            },
            
            # Google API Keys (with deprecation warning)
            "GOOGLE_API_KEY": {
                "provider": APIProvider.GOOGLE,
                "patterns": [
                    r"^AIza[0-9A-Za-z_-]{35}$"  # Standard Google API key format
                ],
                "security_level": "DEPRECATED",
                "required": False,
                "description": "Google API key (DEPRECATED - migrate to OAuth 2.0 service account)",
                "deprecation_warning": "Google API keys are deprecated for production use. Migrate to OAuth 2.0 with service accounts."
            },
            
            # Langfuse Keys (Observability - Optional but recommended)
            "LANGFUSE_PUBLIC_KEY": {
                "provider": APIProvider.LANGFUSE,
                "patterns": [
                    r"^pk-lf-[a-f0-9]{24}$"  # Langfuse public key format
                ],
                "security_level": "MEDIUM",
                "required": False,
                "description": "Langfuse public key for observability and tracing"
            },
            
            "LANGFUSE_SECRET_KEY": {
                "provider": APIProvider.LANGFUSE,
                "patterns": [
                    r"^sk-lf-[a-f0-9]{48}$"  # Langfuse secret key format
                ],
                "security_level": "HIGH",
                "required": False,
                "description": "Langfuse secret key for observability and tracing"
            }
        }
    
    def _mask_key(self, key: str) -> str:
        """
        Safely mask API key for logging/display.
        Shows only first 4 and last 4 characters.
        """
        if not key or len(key) < 8:
            return "***INVALID***"
        return f"{key[:4]}...{key[-4:]}"
    
    def _validate_key_format(self, key_name: str, key_value: Optional[str]) -> ValidationResult:
        """
        Validate individual API key format and security.
        
        Args:
            key_name: Environment variable name
            key_value: API key value (can be None)
            
        Returns:
            ValidationResult with detailed validation information
        """
        config = self.validation_patterns.get(key_name, {})
        provider = config.get("provider", APIProvider.GOOGLE)
        security_level = config.get("security_level", "UNKNOWN")
        patterns = config.get("patterns", [])
        required = config.get("required", False)
        description = config.get("description", f"API key for {key_name}")
        
        issues = []
        recommendations = []
        is_present = key_value is not None and key_value.strip() != ""
        format_valid = False
        
        # Check if key is present
        if not is_present:
            if required:
                issues.append(f"Required API key {key_name} is missing")
                recommendations.append(f"Set {key_name} in your .env file")
            else:
                recommendations.append(f"Optional: Consider setting {key_name} for enhanced functionality")
        else:
            # Validate format against patterns
            key_value = key_value.strip()
            format_valid = any(re.match(pattern, key_value) for pattern in patterns)
            
            if not format_valid:
                issues.append(f"{key_name} format appears invalid")
                recommendations.append(f"Verify {key_name} format matches expected pattern")
                logger.warning(f"Invalid format for {key_name}: {self._mask_key(key_value)}")
            else:
                logger.info(f"{key_name} format validation passed: {self._mask_key(key_value)}")
        
        # Add deprecation warnings
        if "deprecation_warning" in config:
            issues.append(f"DEPRECATION WARNING: {config['deprecation_warning']}")
            recommendations.append(f"Plan migration strategy for {key_name}")
        
        # Security recommendations
        if security_level == "DEPRECATED":
            recommendations.append(f"Migrate {key_name} to more secure authentication method")
        elif security_level == "HIGH" and is_present and format_valid:
            recommendations.append(f"Regularly rotate {key_name} for security")
        
        is_valid = (not required or (is_present and format_valid)) and security_level != "DEPRECATED"
        
        return ValidationResult(
            key_name=key_name,
            provider=provider,
            is_valid=is_valid,
            is_present=is_present,
            format_valid=format_valid,
            security_level=security_level,
            issues=issues,
            recommendations=recommendations
        )
    
    def validate_all(self) -> Dict:
        """
        Validate all configured API keys.
        
        Returns:
            Dictionary with validation results and summary
        """
        results = {}
        all_issues = []
        all_recommendations = []
        required_missing = []
        deprecated_keys = []
        valid_keys = []
        
        logger.info("Starting comprehensive API key validation...")
        
        for key_name in self.validation_patterns.keys():
            key_value = os.getenv(key_name)
            validation_result = self._validate_key_format(key_name, key_value)
            
            results[key_name] = validation_result
            
            # Collect summary information
            all_issues.extend(validation_result.issues)
            all_recommendations.extend(validation_result.recommendations)
            
            if validation_result.security_level == "DEPRECATED":
                deprecated_keys.append(key_name)
            
            if self.validation_patterns[key_name]["required"] and not validation_result.is_valid:
                required_missing.append(key_name)
            elif validation_result.is_valid:
                valid_keys.append(key_name)
        
        # Overall validation status
        all_valid = len(required_missing) == 0
        ready_for_production = all_valid and len(deprecated_keys) == 0
        
        summary = {
            "all_valid": all_valid,
            "ready_for_production": ready_for_production,
            "total_keys": len(self.validation_patterns),
            "valid_keys": len(valid_keys),
            "required_missing": required_missing,
            "deprecated_keys": deprecated_keys,
            "issues": list(set(all_issues)),  # Remove duplicates
            "recommendations": list(set(all_recommendations)),
            "detailed_results": results
        }
        
        logger.info(f"Validation complete: {len(valid_keys)}/{len(self.validation_patterns)} keys valid")
        
        return summary
    
    def print_validation_report(self, results: Dict) -> None:
        """
        Print a comprehensive validation report to console.
        
        Args:
            results: Results from validate_all()
        """
        print("\n" + "="*80)
        print("🔒 API KEY VALIDATION REPORT")
        print("="*80)
        
        # Overall status
        status_emoji = "✅" if results["all_valid"] else "❌"
        prod_emoji = "🚀" if results["ready_for_production"] else "⚠️"
        
        print(f"\n📊 OVERALL STATUS:")
        print(f"   {status_emoji} Required Keys: {results['all_valid']}")
        print(f"   {prod_emoji} Production Ready: {results['ready_for_production']}")
        print(f"   📈 Valid Keys: {results['valid_keys']}/{results['total_keys']}")
        
        # Issues section
        if results["issues"]:
            print(f"\n🚨 ISSUES FOUND ({len(results['issues'])}):")
            for i, issue in enumerate(results["issues"], 1):
                print(f"   {i}. {issue}")
        
        # Recommendations section
        if results["recommendations"]:
            print(f"\n💡 RECOMMENDATIONS ({len(results['recommendations'])}):")
            for i, rec in enumerate(results["recommendations"], 1):
                print(f"   {i}. {rec}")
        
        # Detailed results
        print(f"\n📋 DETAILED VALIDATION RESULTS:")
        for key_name, result in results["detailed_results"].items():
            status = "✅" if result.is_valid else "❌"
            security_emoji = {
                "HIGH": "🔒",
                "MEDIUM": "🔓", 
                "LOW": "⚠️",
                "DEPRECATED": "🚫"
            }.get(result.security_level, "❓")
            
            print(f"   {status} {key_name}")
            print(f"      Provider: {result.provider.value}")
            print(f"      Security: {security_emoji} {result.security_level}")
            print(f"      Present: {'Yes' if result.is_present else 'No'}")
            print(f"      Valid Format: {'Yes' if result.format_valid else 'No'}")
            
            if result.issues:
                for issue in result.issues:
                    print(f"      ⚠️  {issue}")
        
        print("\n" + "="*80)
        
        # Quick setup guidance
        if not results["all_valid"]:
            print("🚀 QUICK SETUP GUIDANCE:")
            print("   1. Copy .env.example to .env: cp .env.example .env")
            print("   2. Edit .env and add your API keys")
            print("   3. Run validation again: python -m config.api_key_validator")
            print("   4. Test system health: python check_health.py")

def main():
    """Command-line interface for API key validation."""
    print("🔒 AI Podcast Production - API Key Validator")
    
    validator = APIKeyValidator()
    results = validator.validate_all()
    validator.print_validation_report(results)
    
    # Exit with appropriate code
    exit_code = 0 if results["all_valid"] else 1
    if exit_code != 0:
        print(f"\n❌ Validation failed. Fix the issues above and try again.")
    else:
        print(f"\n✅ All required API keys are valid!")
        if not results["ready_for_production"]:
            print("⚠️  Consider addressing deprecated keys for production deployment.")
    
    exit(exit_code)

if __name__ == "__main__":
    main()