"""
Security utilities for API key validation and input sanitization.
Minimum viable security for personal production use.

Version: 1.1.0 (August 2025)
Focus: Pragmatic security without overengineering
"""

import os
import re
import logging
from typing import Dict, Optional, Callable

logger = logging.getLogger(__name__)


def validate_api_keys() -> Dict[str, bool]:
    """
    Validate API keys exist and have correct format.
    
    Returns:
        Dict mapping key_name to is_valid for all configured keys.
        
    Example:
        >>> results = validate_api_keys()
        >>> if not results['OPENAI_API_KEY']:
        ...     print("OpenAI key is invalid")
    """
    validators = {
        'OPENAI_API_KEY': lambda k: k and k.startswith('sk-') and len(k) > 20,
        'ANTHROPIC_API_KEY': lambda k: k and k.startswith('sk-ant-') and len(k) > 20,
        'PERPLEXITY_API_KEY': lambda k: k and k.startswith('pplx-') and len(k) > 20,
        'ELEVENLABS_API_KEY': lambda k: k and len(k) >= 32,
        'GOOGLE_API_KEY': lambda k: k and len(k) >= 39,
        'LANGFUSE_PUBLIC_KEY': lambda k: k and k.startswith('pk-lf-'),
        'LANGFUSE_SECRET_KEY': lambda k: k and k.startswith('sk-lf-'),
    }
    
    results = {}
    for key_name, validator in validators.items():
        value = os.getenv(key_name, '').strip()
        try:
            results[key_name] = validator(value) if value else False
            if not results[key_name]:
                logger.warning(f"❌ Invalid {key_name}: Wrong format or missing")
        except Exception as e:
            logger.error(f"❌ Error validating {key_name}: {e}")
            results[key_name] = False
    
    # Log summary
    valid_count = sum(1 for v in results.values() if v)
    total_count = len(results)
    
    if valid_count == total_count:
        logger.info(f"✅ All {total_count} API keys validated successfully")
    else:
        logger.warning(f"⚠️ Only {valid_count}/{total_count} API keys are valid")
    
    return results


def check_required_keys(required_only: bool = True) -> bool:
    """
    Check if required API keys are present for basic operation.
    
    Args:
        required_only: If True, only check essential keys. If False, check all keys.
        
    Returns:
        True if required keys are valid, False otherwise.
        
    Note:
        Required keys for basic operation:
        - OPENAI_API_KEY: For main LLM operations
        - PERPLEXITY_API_KEY: For research
        - ELEVENLABS_API_KEY: For audio synthesis
    """
    required = ['OPENAI_API_KEY', 'PERPLEXITY_API_KEY', 'ELEVENLABS_API_KEY']
    results = validate_api_keys()
    
    if required_only:
        missing_required = [key for key in required if not results.get(key, False)]
        if missing_required:
            logger.error(f"❌ Missing required keys: {missing_required}")
            return False
        logger.info(f"✅ All required API keys are valid")
        return True
    else:
        return all(results.values())


def sanitize_topic(topic: str, max_length: int = 200) -> str:
    """
    Sanitize user-provided topic to prevent injection attacks.
    
    Args:
        topic: Raw user input
        max_length: Maximum allowed length
        
    Returns:
        Sanitized topic safe for processing
        
    Raises:
        ValueError: If topic is empty or too short after sanitization
        
    Example:
        >>> sanitize_topic("AI & Machine Learning")
        "AI & Machine Learning"
        >>> sanitize_topic("<script>alert('xss')</script>AI")  
        "AI"
    """
    if not topic:
        raise ValueError("Topic cannot be empty")
    
    # Remove potentially dangerous characters
    dangerous_patterns = [
        r'[;&|`$]',  # Command injection
        r'<script[^>]*>.*?</script>',  # Script tags with content (case insensitive)
        r'<[^>]*>',  # HTML/XML tags
        r'\{\{.*?\}\}',  # Template injection
        r'<%.*?%>',  # Server-side injection
        r'<\?.*?\?>',  # PHP tags
    ]
    
    clean = topic
    for pattern in dangerous_patterns:
        clean = re.sub(pattern, '', clean, flags=re.IGNORECASE | re.DOTALL)
    
    # Remove excessive whitespace
    clean = ' '.join(clean.split())
    
    # Enforce length limit
    clean = clean[:max_length]
    
    # Ensure we still have valid content
    if len(clean) < 2:
        raise ValueError(f"Topic too short after sanitization: '{clean}'")
    
    if clean != topic:
        logger.info(f"Topic sanitized: '{topic[:50]}...' -> '{clean[:50]}...'")
    
    return clean


def sanitize_filename(filename: str) -> str:
    """
    Sanitize filename to prevent directory traversal and file system issues.
    
    Args:
        filename: Raw filename
        
    Returns:
        Safe filename for file system use
        
    Example:
        >>> sanitize_filename("../../../etc/passwd")
        "passwd"
        >>> sanitize_filename("my file.txt")
        "my_file.txt"
    """
    # Remove path components
    filename = os.path.basename(filename)
    
    # Remove dangerous characters, keep alphanumeric, dash, underscore, dot
    filename = re.sub(r'[^\w\-_\.]', '_', filename)
    
    # Prevent hidden files
    filename = filename.lstrip('.')
    
    # Ensure we have something
    return filename or "unnamed"


def mask_sensitive_data(data: str, mask_char: str = '*', show_chars: int = 4) -> str:
    """
    Mask sensitive data for logging (like API keys).
    
    Args:
        data: Sensitive string to mask
        mask_char: Character to use for masking
        show_chars: Number of characters to show at end
        
    Returns:
        Masked string safe for logging
        
    Example:
        >>> mask_sensitive_data("sk-1234567890abcdef")
        "***cdef"
        >>> mask_sensitive_data("very-long-api-key-here", show_chars=6)
        "***ey-here"
    """
    if not data or len(data) <= show_chars:
        return mask_char * 4
    
    return mask_char * 3 + data[-show_chars:]


def validate_environment_security() -> Dict[str, any]:
    """
    Perform comprehensive environment security validation.
    
    Returns:
        Dict with validation results and recommendations
        
    Example:
        >>> results = validate_environment_security()
        >>> print(f"Security score: {results['score']}/100")
    """
    results = {
        'api_keys': validate_api_keys(),
        'required_keys_valid': check_required_keys(),
        'environment': os.getenv('ENVIRONMENT', 'unknown'),
        'recommendations': [],
        'warnings': [],
        'score': 0
    }
    
    # Score API key validation
    api_score = sum(1 for v in results['api_keys'].values() if v)
    total_keys = len(results['api_keys'])
    results['score'] += (api_score / total_keys) * 60  # 60 points for API keys
    
    # Score environment configuration
    if results['environment'] in ['development', 'production']:
        results['score'] += 20  # 20 points for proper environment
    else:
        results['warnings'].append("ENVIRONMENT not set to 'development' or 'production'")
    
    # Check for development security issues
    if results['environment'] == 'production':
        debug_mode = os.getenv('DEBUG', 'false').lower() == 'true'
        if debug_mode:
            results['warnings'].append("DEBUG mode enabled in production")
        else:
            results['score'] += 10  # 10 points for production security
            
        verbose_logging = os.getenv('VERBOSE_LOGGING', 'false').lower() == 'true'
        if verbose_logging:
            results['warnings'].append("VERBOSE_LOGGING enabled in production")
        else:
            results['score'] += 10  # 10 points for production logging
    
    # Generate recommendations
    invalid_keys = [k for k, v in results['api_keys'].items() if not v]
    if invalid_keys:
        results['recommendations'].append(f"Fix invalid API keys: {', '.join(invalid_keys)}")
    
    if results['score'] < 70:
        results['recommendations'].append("Review security configuration before production use")
    
    if results['score'] < 50:
        results['recommendations'].append("CRITICAL: Security issues must be resolved")
    
    logger.info(f"🔒 Security validation score: {results['score']:.0f}/100")
    
    return results


# Convenience functions for common use cases
def is_production_ready() -> bool:
    """Quick check if system is ready for production use."""
    return validate_environment_security()['score'] >= 80


def get_api_key_status() -> str:
    """Get human-readable API key status."""
    results = validate_api_keys()
    valid_count = sum(1 for v in results.values() if v)
    total_count = len(results)
    
    if valid_count == total_count:
        return f"✅ All {total_count} API keys valid"
    elif valid_count >= 3:  # Minimum required
        return f"⚠️ {valid_count}/{total_count} keys valid (sufficient for basic operation)"
    else:
        return f"❌ Only {valid_count}/{total_count} keys valid (insufficient for operation)"


if __name__ == "__main__":
    # Quick security check when run directly
    print("🔒 Security Validation Report")
    print("=" * 40)
    
    print(f"API Keys: {get_api_key_status()}")
    
    security_results = validate_environment_security()
    print(f"Overall Score: {security_results['score']:.0f}/100")
    
    if security_results['warnings']:
        print("\n⚠️ Warnings:")
        for warning in security_results['warnings']:
            print(f"  - {warning}")
    
    if security_results['recommendations']:
        print("\n💡 Recommendations:")
        for rec in security_results['recommendations']:
            print(f"  - {rec}")
    
    print(f"\nProduction Ready: {'✅ Yes' if is_production_ready() else '❌ No'}")