#!/usr/bin/env python3
"""Test script for security functions."""

import sys
sys.path.append('.')

from core.security import (
    validate_api_keys, 
    check_required_keys, 
    get_api_key_status,
    sanitize_topic, 
    sanitize_filename, 
    mask_sensitive_data,
    validate_environment_security
)
import os

def test_api_validation():
    """Test API key validation with mock keys."""
    print('🧪 Testing API Key Validation with Mock Keys')
    print('=' * 50)

    # Test 1: Valid mock keys
    print('\n📋 Test 1: Valid Mock Keys')
    test_env = {
        'OPENAI_API_KEY': 'sk-1234567890abcdefghijk1234567890',
        'ANTHROPIC_API_KEY': 'sk-ant-1234567890abcdefghijk1234567890',
        'PERPLEXITY_API_KEY': 'pplx-1234567890abcdefghijk1234567890',
        'ELEVENLABS_API_KEY': '1234567890abcdefghijk1234567890abcdef',
        'GOOGLE_API_KEY': '1234567890abcdefghijk1234567890abcdefghijk',
        'LANGFUSE_PUBLIC_KEY': 'pk-lf-1234567890abcdefghijk',
        'LANGFUSE_SECRET_KEY': 'sk-lf-1234567890abcdefghijk'
    }

    # Temporarily set environment
    original_env = {}
    for key in test_env:
        original_env[key] = os.getenv(key)
        os.environ[key] = test_env[key]

    results = validate_api_keys()
    print(f'Results: {results}')
    print(f'All valid: {all(results.values())}')
    print(f'Status: {get_api_key_status()}')

    # Test 2: Invalid mock keys
    print('\n📋 Test 2: Invalid Mock Keys')
    invalid_env = {
        'OPENAI_API_KEY': 'invalid-key',
        'ANTHROPIC_API_KEY': 'sk-wrong-format',
        'PERPLEXITY_API_KEY': 'pplx-too-short',
        'ELEVENLABS_API_KEY': 'short',
        'GOOGLE_API_KEY': '123',
        'LANGFUSE_PUBLIC_KEY': 'pk-wrong',
        'LANGFUSE_SECRET_KEY': 'sk-wrong'
    }

    for key, value in invalid_env.items():
        os.environ[key] = value

    results = validate_api_keys()
    print(f'Results: {results}')
    print(f'Required keys check: {check_required_keys()}')
    print(f'Status: {get_api_key_status()}')

    # Restore original environment
    for key, value in original_env.items():
        if value is None:
            os.environ.pop(key, None)
        else:
            os.environ[key] = value

def test_sanitization():
    """Test input sanitization functions."""
    print('\n🧪 Testing Input Sanitization Functions')
    print('=' * 50)

    # Test sanitize_topic function
    print('\n📋 Test 1: Topic Sanitization')
    test_topics = [
        'AI & Machine Learning',  # Normal case
        '<script>alert("xss")</script>AI Topic',  # XSS attempt
        '<SCRIPT>ALERT("XSS")</SCRIPT>Topic',  # XSS attempt uppercase
        'AI; rm -rf /',  # Command injection
        'Topic {{template}} injection',  # Template injection
        'PHP <?php echo "test"; ?> topic',  # PHP injection
        '   Multiple   spaces   here   ',  # Whitespace
        'Very long topic that exceeds the maximum length limit and should be truncated to ensure it fits within boundaries' * 3,  # Long topic
        'ab',  # Short but should now be valid
        'a',   # Too short - should still fail
    ]

    for topic in test_topics:
        try:
            clean = sanitize_topic(topic)
            print(f'✅ "{topic[:30]}..." -> "{clean}"')
        except ValueError as e:
            print(f'❌ "{topic[:30]}..." -> ERROR: {e}')

    # Test sanitize_filename function
    print('\n📋 Test 2: Filename Sanitization')
    test_filenames = [
        'normal_file.txt',
        '../../../etc/passwd',  # Directory traversal
        'file with spaces.txt',
        'file@#$%^&*().txt',  # Special characters
        '.hidden_file',  # Hidden file
        '',  # Empty
        'file\\with\\backslashes.txt',
    ]

    for filename in test_filenames:
        clean = sanitize_filename(filename)
        print(f'✅ "{filename}" -> "{clean}"')

    # Test mask_sensitive_data function
    print('\n📋 Test 3: Sensitive Data Masking')
    test_data = [
        'sk-1234567890abcdefghijk1234567890',  # OpenAI key
        'very-short',  # Short data
        '',  # Empty
        'a' * 50,  # Long data
    ]

    for data in test_data:
        masked = mask_sensitive_data(data)
        print(f'✅ "{data[:20]}..." -> "{masked}"')

def test_environment_security():
    """Test environment security validation."""
    print('\n🧪 Testing Environment Security Validation')
    print('=' * 50)
    
    # Set up test environment
    os.environ['ENVIRONMENT'] = 'development'
    os.environ['DEBUG'] = 'false'
    os.environ['VERBOSE_LOGGING'] = 'false'
    
    results = validate_environment_security()
    print(f'Security Score: {results["score"]:.0f}/100')
    print(f'Valid API Keys: {sum(1 for v in results["api_keys"].values() if v)}/{len(results["api_keys"])}')
    print(f'Environment: {results["environment"]}')
    
    if results['warnings']:
        print('\n⚠️ Warnings:')
        for warning in results['warnings']:
            print(f'  - {warning}')
    
    if results['recommendations']:
        print('\n💡 Recommendations:')
        for rec in results['recommendations']:
            print(f'  - {rec}')

if __name__ == '__main__':
    test_api_validation()
    test_sanitization()
    test_environment_security()
    print('\n✅ All Security Tests Complete')