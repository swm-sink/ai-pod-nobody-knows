#!/usr/bin/env python3
import os
print("Environment Check:")
required_vars = ["PERPLEXITY_API_KEY", "LANGFUSE_PUBLIC_KEY", "LANGFUSE_SECRET_KEY", "ELEVENLABS_API_KEY"]
for var in required_vars:
    status = "SET" if os.getenv(var) else "MISSING"
    print(f"  {var}: {status}")