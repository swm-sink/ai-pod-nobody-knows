#!/bin/bash

# Setup script to create .env file with API keys
# Version: 1.0.0
# Date: August 2025

echo "🔐 API Key Setup Script"
echo "======================"
echo ""
echo "This script will create a .env file with your API keys."
echo "The .env file is git-ignored and will not be committed."
echo ""

# Check if .env already exists
if [ -f .env ]; then
    echo "⚠️  Warning: .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting without changes."
        exit 0
    fi
fi

# Create .env file with the provided keys
cat > .env << 'EOF'
# LangGraph/LangFuse Migration Environment Configuration
# Created: August 31, 2025
# Security: This file is git-ignored and should NEVER be committed

# ============================================
# LANGFUSE OBSERVABILITY (Project-Specific)
# ============================================
LANGFUSE_PUBLIC_KEY=pk-lf-267ac86a-f92c-4a6b-bc73-dfdeca69f082
LANGFUSE_SECRET_KEY=sk-lf-bb43c28c-f76a-4796-b426-dbaa16eca9b9
LANGFUSE_HOST=https://us.cloud.langfuse.com

# ============================================
# PERPLEXITY RESEARCH API
# ============================================
PERPLEXITY_API_KEY=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

# ============================================
# OPENROUTER LLM ROUTING
# ============================================
OPENROUTER_API_KEY=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
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1

# ============================================
# EXISTING PROVIDERS (To be populated)
# ============================================
# OpenAI, Anthropic, ElevenLabs keys will be added when available
# OPENAI_API_KEY=
# ANTHROPIC_API_KEY=
# ELEVENLABS_API_KEY=

# ============================================
# PRODUCTION CONFIGURATION
# ============================================
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
MAX_EPISODE_COST=6.00
QUALITY_THRESHOLD=0.85
MAX_RETRIES=3
TIMEOUT_SECONDS=600

# ============================================
# SYSTEM CONFIGURATION
# ============================================
LOG_LEVEL=INFO
ENABLE_A_B_TESTING=true
ENABLE_CACHING=true
ENABLE_METRICS=true
ENABLE_TRACING=true
EOF

# Set proper permissions (read/write for owner only)
chmod 600 .env

echo "✅ .env file created successfully!"
echo ""
echo "File permissions set to 600 (read/write for owner only)"
echo ""
echo "You can now run the validation script:"
echo "  python3 src/validate_api_keys.py"
echo ""
echo "Or run the provider tests:"
echo "  python3 -m pytest tests/test_providers.py -v"
