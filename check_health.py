#!/usr/bin/env python3
"""
Health Check Script for AI Podcast Production System
Verifies API connections and system readiness for new users.
"""

import os
import asyncio
import httpx
from datetime import datetime
import json
from pathlib import Path

class HealthChecker:
    """System health verification for first-time users"""
    
    def __init__(self):
        self.results = {}
        self.load_environment()
    
    def load_environment(self):
        """Load environment variables from .env file"""
        env_file = Path('.env')
        if env_file.exists():
            with open(env_file, 'r') as f:
                for line in f:
                    if line.strip() and not line.startswith('#'):
                        key, value = line.strip().split('=', 1)
                        os.environ[key] = value
    
    async def check_elevenlabs(self) -> dict:
        """Test ElevenLabs API connection"""
        api_key = os.getenv('ELEVEN_LABS_API_KEY')
        if not api_key:
            return {"status": "❌", "message": "API key not found in .env file"}
        
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(
                    "https://api.elevenlabs.io/v1/models",
                    headers={"xi-api-key": api_key}
                )
                if response.status_code == 200:
                    return {"status": "✅", "message": "Connected successfully"}
                else:
                    return {"status": "❌", "message": f"API error: {response.status_code}"}
        except Exception as e:
            return {"status": "❌", "message": f"Connection failed: {str(e)[:50]}"}
    
    async def check_perplexity(self) -> dict:
        """Test Perplexity API connection"""
        api_key = os.getenv('PERPLEXITY_API_KEY')
        if not api_key:
            return {"status": "❌", "message": "API key not found in .env file"}
        
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(
                    "https://api.perplexity.ai/chat/completions",
                    headers={
                        "Authorization": f"Bearer {api_key}",
                        "Content-Type": "application/json"
                    },
                    json={
                        "model": "llama-3.1-sonar-small-128k-online",
                        "messages": [{"role": "user", "content": "Test connection"}],
                        "max_tokens": 1
                    }
                )
                if response.status_code == 200:
                    return {"status": "✅", "message": "Connected successfully"}
                else:
                    return {"status": "❌", "message": f"API error: {response.status_code}"}
        except Exception as e:
            return {"status": "❌", "message": f"Connection failed: {str(e)[:50]}"}
    
    def check_anthropic(self) -> dict:
        """Check Anthropic API key presence"""
        api_key = os.getenv('ANTHROPIC_API_KEY')
        if not api_key:
            return {"status": "❌", "message": "API key not found in .env file"}
        if api_key.startswith('sk-ant-'):
            return {"status": "✅", "message": "API key format valid"}
        else:
            return {"status": "⚠️", "message": "API key format may be incorrect"}
    
    def check_google(self) -> dict:
        """Check Google API key presence"""
        api_key = os.getenv('GOOGLE_API_KEY')
        if not api_key:
            return {"status": "❌", "message": "API key not found in .env file"}
        if api_key.startswith('AIza'):
            return {"status": "✅", "message": "API key format valid"}
        else:
            return {"status": "⚠️", "message": "API key format may be incorrect"}
    
    def check_environment(self) -> dict:
        """Check environment configuration"""
        env_file = Path('.env')
        if not env_file.exists():
            return {"status": "❌", "message": ".env file not found - create one with your API keys"}
        
        required_vars = [
            'ELEVEN_LABS_API_KEY',
            'ANTHROPIC_API_KEY', 
            'GOOGLE_API_KEY',
            'PERPLEXITY_API_KEY'
        ]
        
        missing = [var for var in required_vars if not os.getenv(var)]
        if missing:
            return {"status": "❌", "message": f"Missing variables: {', '.join(missing)}"}
        
        return {"status": "✅", "message": "All required environment variables present"}
    
    def check_directories(self) -> dict:
        """Check required directory structure"""
        required_dirs = [
            'output',
            'output/scripts',
            'output/audio', 
            'output/quality',
            'output/sessions',
            'episodes',
            'episodes/active',
            'episodes/recent', 
            'episodes/archive'
        ]
        
        missing = []
        for dir_path in required_dirs:
            if not Path(dir_path).exists():
                Path(dir_path).mkdir(parents=True, exist_ok=True)
        
        return {"status": "✅", "message": "Directory structure verified/created"}
    
    def check_voice_config(self) -> dict:
        """Check voice configuration"""
        voice_id = os.getenv('PRODUCTION_VOICE_ID')
        if voice_id == 'ZF6FPAbjXT4488VcRRnw':
            return {"status": "✅", "message": "Production voice configured (Amelia)"}
        elif voice_id:
            return {"status": "⚠️", "message": f"Custom voice ID: {voice_id}"}
        else:
            return {"status": "❌", "message": "No voice ID configured"}
    
    async def run_all_checks(self):
        """Run all health checks"""
        print("🏥 AI Podcast Production System - Health Check")
        print("=" * 50)
        print(f"Timestamp: {datetime.now().isoformat()}")
        print()
        
        # Basic environment checks
        print("📋 Environment Configuration:")
        env_result = self.check_environment()
        print(f"   Environment File: {env_result['status']} {env_result['message']}")
        
        dir_result = self.check_directories()
        print(f"   Directory Structure: {dir_result['status']} {dir_result['message']}")
        
        voice_result = self.check_voice_config()
        print(f"   Voice Configuration: {voice_result['status']} {voice_result['message']}")
        print()
        
        # API connectivity checks
        print("🔌 API Connectivity:")
        
        # Check APIs that don't require actual calls
        claude_result = self.check_anthropic()
        print(f"   Anthropic (Claude): {claude_result['status']} {claude_result['message']}")
        
        google_result = self.check_google()
        print(f"   Google (Gemini): {google_result['status']} {google_result['message']}")
        
        # Check APIs with actual calls
        print("   Testing live connections...")
        elevenlabs_result = await self.check_elevenlabs()
        print(f"   ElevenLabs: {elevenlabs_result['status']} {elevenlabs_result['message']}")
        
        perplexity_result = await self.check_perplexity()
        print(f"   Perplexity: {perplexity_result['status']} {perplexity_result['message']}")
        print()
        
        # Overall assessment
        all_results = [
            env_result, dir_result, voice_result,
            claude_result, google_result, 
            elevenlabs_result, perplexity_result
        ]
        
        success_count = sum(1 for r in all_results if r['status'] == '✅')
        warning_count = sum(1 for r in all_results if r['status'] == '⚠️')
        error_count = sum(1 for r in all_results if r['status'] == '❌')
        
        print("🎯 Overall System Status:")
        if error_count == 0:
            print("   🚀 System Ready for Production!")
            print("   You can start creating episodes with /produce-episode")
        elif error_count <= 2 and warning_count == 0:
            print("   ⚠️  System Mostly Ready")
            print(f"   Fix {error_count} issues before production")
        else:
            print("   ❌ System Not Ready")
            print(f"   Address {error_count} errors and {warning_count} warnings")
        
        print()
        print(f"✅ Passed: {success_count}/7")
        print(f"⚠️  Warnings: {warning_count}/7") 
        print(f"❌ Errors: {error_count}/7")
        print()
        
        if error_count > 0:
            print("📚 Next Steps:")
            print("   1. Check your .env file has all required API keys")
            print("   2. Verify API keys are correct and have active billing")
            print("   3. See docs/USER_GETTING_STARTED.md for setup help")
        else:
            print("🎉 Ready to Start!")
            print("   1. Use /init to start a session")
            print("   2. Try /research 'your topic' for a FREE test")
            print("   3. Use /produce-episode 'your topic' to create an episode")
        
        print("\n📖 Documentation:")
        print("   • User Guide: docs/USER_GETTING_STARTED.md")
        print("   • Quick Reference: docs/QUICK_REFERENCE.md")
        print("   • System Overview: CLAUDE.md")

async def main():
    """Main health check execution"""
    checker = HealthChecker()
    await checker.run_all_checks()

if __name__ == "__main__":
    asyncio.run(main())