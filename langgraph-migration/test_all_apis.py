#!/usr/bin/env python3
"""
Test all API connections with real API calls.

This script validates that all providers can successfully connect
to their respective APIs with the configured credentials.

Version: 1.0.0
Date: August 2025
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Optional

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / 'src'))

from adapters.openrouter.provider import OpenRouterProvider
from adapters.perplexity.provider import PerplexityProvider
from adapters.elevenlabs.provider import ElevenLabsProvider
from adapters.langfuse.provider import LangFuseProvider


def test_openrouter(api_key: Optional[str] = None) -> Dict[str, Any]:
    """Test OpenRouter API connection."""
    print("\n🔄 Testing OpenRouter API...")

    try:
        config = {
            'api_key': api_key or os.environ.get('OPENROUTER_API_KEY', 'test_key'),
            'model': 'openai/gpt-3.5-turbo'  # Cheapest model for testing
        }

        provider = OpenRouterProvider(config)

        # Test 1: List models
        models = provider.list_models()
        print(f"  ✅ Listed {len(models)} models")

        # Test 2: Generate text (if real API key)
        if api_key and not api_key.startswith('test_'):
            response = provider.generate(
                "Say 'Hello, OpenRouter is working!' in exactly 5 words.",
                max_tokens=20
            )
            print(f"  ✅ Generated response: {response[:50]}...")
        else:
            print(f"  ⚠️  Skipping generation test (no real API key)")

        # Test 3: Estimate cost
        cost = provider.estimate_cost("Test prompt", max_tokens=100)
        print(f"  ✅ Estimated cost: ${cost:.4f}")

        provider.cleanup()

        return {
            'provider': 'OpenRouter',
            'status': 'success',
            'models_found': len(models),
            'api_key_valid': not api_key or not api_key.startswith('test_')
        }

    except Exception as e:
        print(f"  ❌ OpenRouter test failed: {e}")
        return {
            'provider': 'OpenRouter',
            'status': 'failed',
            'error': str(e)
        }


def test_perplexity(api_key: Optional[str] = None) -> Dict[str, Any]:
    """Test Perplexity API connection."""
    print("\n🔍 Testing Perplexity API...")

    try:
        config = {
            'api_key': api_key or os.environ.get('PERPLEXITY_API_KEY', 'test_key'),
            'model': 'sonar'  # Cheapest model
        }

        provider = PerplexityProvider(config)

        # Test 1: Generate research (if real API key)
        if api_key and not api_key.startswith('test_'):
            response = provider.generate(
                "What is the capital of France? Answer in one word.",
                max_tokens=10
            )
            print(f"  ✅ Generated response: {response[:50]}...")
        else:
            print(f"  ⚠️  Skipping generation test (no real API key)")

        # Test 2: Deep research
        results = provider.deep_research(
            topic="Test topic",
            depth="quick",
            sources_required=1
        )
        print(f"  ✅ Deep research completed")

        # Test 3: Fact check
        fact_result = provider.fact_check("The Earth is round")
        print(f"  ✅ Fact check completed")

        # Test 4: Estimate cost
        cost = provider.estimate_cost("Test prompt", max_tokens=100)
        print(f"  ✅ Estimated cost: ${cost:.4f}")

        provider.cleanup()

        return {
            'provider': 'Perplexity',
            'status': 'success',
            'api_key_valid': not api_key or not api_key.startswith('test_')
        }

    except Exception as e:
        print(f"  ❌ Perplexity test failed: {e}")
        return {
            'provider': 'Perplexity',
            'status': 'failed',
            'error': str(e)
        }


def test_elevenlabs(api_key: Optional[str] = None) -> Dict[str, Any]:
    """Test ElevenLabs API connection."""
    print("\n🎙️ Testing ElevenLabs API...")

    try:
        config = {
            'api_key': api_key or os.environ.get('ELEVENLABS_API_KEY', 'test_key'),
            'voice_id': 'ZF6FPAbjXT4488VcRRnw',  # Production voice
            'model_id': 'eleven_turbo_v2_5',
            'output_dir': './test_audio_output'
        }

        provider = ElevenLabsProvider(config)

        # Test 1: Validate production voice
        is_valid = provider.validate_voice('ZF6FPAbjXT4488VcRRnw')
        print(f"  ✅ Production voice validation: {is_valid}")

        # Test 2: Get voices (if real API key)
        if api_key and not api_key.startswith('test_'):
            voices = provider.get_voices()
            print(f"  ✅ Retrieved {len(voices)} voices")

            # Test 3: Get subscription info
            sub_info = provider.get_subscription_info()
            print(f"  ✅ Subscription tier: {sub_info.get('tier', 'unknown')}")

            # Test 4: Generate audio
            audio_file = provider.generate(
                "Hello, this is a test of the ElevenLabs API.",
                voice_id='ZF6FPAbjXT4488VcRRnw'
            )
            print(f"  ✅ Generated audio: {audio_file}")
        else:
            print(f"  ⚠️  Skipping API tests (no real API key)")

        # Test 5: Estimate cost
        cost = provider.estimate_cost("Test text for cost estimation")
        print(f"  ✅ Estimated cost: ${cost:.4f}")

        # Test 6: SSML processing
        processed = provider._process_ssml('<speak>Test <emphasis>text</emphasis></speak>')
        print(f"  ✅ SSML processing working")

        provider.cleanup()

        return {
            'provider': 'ElevenLabs',
            'status': 'success',
            'voice_validated': is_valid,
            'api_key_valid': not api_key or not api_key.startswith('test_')
        }

    except Exception as e:
        print(f"  ❌ ElevenLabs test failed: {e}")
        return {
            'provider': 'ElevenLabs',
            'status': 'failed',
            'error': str(e)
        }


def test_langfuse(public_key: Optional[str] = None, secret_key: Optional[str] = None) -> Dict[str, Any]:
    """Test LangFuse API connection."""
    print("\n📊 Testing LangFuse API...")

    try:
        config = {
            'public_key': public_key or os.environ.get('LANGFUSE_PUBLIC_KEY', 'pk-test'),
            'secret_key': secret_key or os.environ.get('LANGFUSE_SECRET_KEY', 'sk-test'),
            'host': os.environ.get('LANGFUSE_HOST', 'https://us.cloud.langfuse.com')
        }

        provider = LangFuseProvider(config)

        # Test 1: Log execution
        from core.interfaces.provider import AgentState
        state = AgentState(
            agent_id='test-agent',
            stage='testing',
            data={'test': 'data'},
            metadata={'meta': 'data'},
            timestamp=datetime.now(),
            cost_tracking={'llm': 0.01}
        )

        provider.log_execution(
            execution_id='test-exec-123',
            workflow_id='test-workflow-456',
            state=state
        )
        print(f"  ✅ Logged execution")

        # Test 2: Log metric
        provider.log_metric(
            name='test.api.check',
            value=1.0,
            tags={'environment': 'test'}
        )
        print(f"  ✅ Logged metric")

        # Test 3: Log cost
        provider.log_cost(
            execution_id='test-exec-123',
            cost_type='api_test',
            amount=0.001,
            metadata={'provider': 'test'}
        )
        print(f"  ✅ Logged cost")

        # Test 4: Create experiment
        exp_id = provider.create_prompt_experiment(
            name='api_test_experiment',
            variants=[{'template': 'Test variant'}]
        )
        print(f"  ✅ Created experiment: {exp_id}")

        provider.cleanup()

        return {
            'provider': 'LangFuse',
            'status': 'success',
            'api_key_valid': not public_key or not public_key.startswith('pk-test')
        }

    except Exception as e:
        print(f"  ❌ LangFuse test failed: {e}")
        return {
            'provider': 'LangFuse',
            'status': 'failed',
            'error': str(e)
        }


def main():
    """Main test runner."""
    print("=" * 60)
    print("🚀 API Connection Test Suite")
    print("=" * 60)
    print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Testing with August 2025 configurations")

    results = []

    # Check for API keys in environment
    print("\n📋 Checking for API keys in environment...")
    api_keys = {
        'OPENROUTER_API_KEY': os.environ.get('OPENROUTER_API_KEY'),
        'PERPLEXITY_API_KEY': os.environ.get('PERPLEXITY_API_KEY'),
        'ELEVENLABS_API_KEY': os.environ.get('ELEVENLABS_API_KEY'),
        'LANGFUSE_PUBLIC_KEY': os.environ.get('LANGFUSE_PUBLIC_KEY'),
        'LANGFUSE_SECRET_KEY': os.environ.get('LANGFUSE_SECRET_KEY')
    }

    for key, value in api_keys.items():
        if value and not value.startswith('test'):
            masked = f"...{value[-4:]}" if len(value) > 4 else "****"
            print(f"  ✅ {key}: {masked}")
        else:
            print(f"  ⚠️  {key}: Not configured (will use mock mode)")

    # Test each provider
    results.append(test_openrouter(api_keys.get('OPENROUTER_API_KEY')))
    results.append(test_perplexity(api_keys.get('PERPLEXITY_API_KEY')))
    results.append(test_elevenlabs(api_keys.get('ELEVENLABS_API_KEY')))
    results.append(test_langfuse(
        api_keys.get('LANGFUSE_PUBLIC_KEY'),
        api_keys.get('LANGFUSE_SECRET_KEY')
    ))

    # Summary
    print("\n" + "=" * 60)
    print("📊 Test Results Summary")
    print("=" * 60)

    success_count = sum(1 for r in results if r['status'] == 'success')
    total_count = len(results)

    for result in results:
        status_icon = "✅" if result['status'] == 'success' else "❌"
        print(f"{status_icon} {result['provider']}: {result['status']}")
        if result['status'] == 'failed' and 'error' in result:
            print(f"   Error: {result['error'][:100]}...")

    print(f"\nOverall: {success_count}/{total_count} providers tested successfully")

    # Save results to file
    output_file = Path('test_results.json')
    with open(output_file, 'w') as f:
        json.dump({
            'timestamp': datetime.now().isoformat(),
            'results': results,
            'summary': {
                'success': success_count,
                'total': total_count,
                'success_rate': f"{(success_count/total_count)*100:.1f}%"
            }
        }, f, indent=2)

    print(f"\n💾 Results saved to: {output_file}")

    # Exit code based on success
    sys.exit(0 if success_count == total_count else 1)


if __name__ == "__main__":
    main()
