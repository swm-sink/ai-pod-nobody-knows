#!/usr/bin/env python3
"""Test LangFuse connection and configuration."""

import os
from pathlib import Path
from dotenv import load_dotenv
from langfuse import Langfuse

# Load environment variables
env_path = Path(__file__).parent / '.env'
if env_path.exists():
    load_dotenv(env_path)
    print(f"✓ Loaded .env from {env_path}")

# Get LangFuse configuration
public_key = os.getenv('LANGFUSE_PUBLIC_KEY')
secret_key = os.getenv('LANGFUSE_SECRET_KEY')
host = os.getenv('LANGFUSE_HOST', 'https://cloud.langfuse.com')

# Verify configuration
if not public_key or not secret_key:
    print("✗ LangFuse keys not configured")
    exit(1)

print(f"✓ LangFuse configuration found")
print(f"  Public key: ...{public_key[-4:] if len(public_key) > 4 else '****'}")
print(f"  Secret key: ...{secret_key[-4:] if len(secret_key) > 4 else '****'}")
print(f"  Host: {host}")

# Test connection
try:
    # Initialize LangFuse client
    langfuse = Langfuse(
        public_key=public_key,
        secret_key=secret_key,
        host=host
    )

    # Test auth check first
    auth_result = langfuse.auth_check()
    print(f"✓ Authentication check: {auth_result}")

    # Create a test event (simpler than generation)
    langfuse.create_event(
        name="sdk_test_event",
        input="Testing LangFuse SDK",
        output="SDK operational",
        metadata={"sdk_version": "3.2.1", "test": True}
    )

    # Flush to ensure data is sent
    langfuse.flush()

    print("✓ LangFuse connection successful")
    print("✓ Test event created")
    print("✓ LangFuse SDK fully operational")

except Exception as e:
    print(f"✗ LangFuse connection failed: {e}")
    exit(1)
