# 🔐 API Key Configuration Guide for AI Podcast Production

**Current Date:** September 3, 2025  
**System Status:** Production-Ready  
**Security Level:** High

## 🚀 Quick Start (5 Minutes)

1. **Copy the template**: `cp .env.example .env`
2. **Get your API keys** (see detailed instructions below)
3. **Add keys to `.env` file** (never commit this file!)
4. **Validate setup**: `python -m config.api_key_validator`
5. **Test system**: `python check_health.py`

## 📋 Required API Keys

### 1. OpenAI API Key (REQUIRED)
**Cost Impact:** $2-3 per episode  
**Usage:** Primary language model for research and script generation

**How to Get:**
1. Visit [OpenAI Platform](https://platform.openai.com/account/api-keys)
2. Sign in or create account
3. Navigate to "API Keys" section
4. Click "Create new secret key"
5. Choose "Project" type for better security
6. Copy the key (starts with `sk-proj-...` or `sk-...`)

**Add to .env:**
```bash
OPENAI_API_KEY=sk-proj-your-actual-key-here
```

### 2. Anthropic API Key (REQUIRED)
**Cost Impact:** $1-2 per episode  
**Usage:** Claude models for quality validation and script polishing

**How to Get:**
1. Visit [Anthropic Console](https://console.anthropic.com/)
2. Sign in or create account
3. Go to "API Keys" section
4. Click "Create Key"
5. Copy the key (starts with `sk-ant-api03-...`)

**Add to .env:**
```bash
ANTHROPIC_API_KEY=sk-ant-api03-your-actual-key-here
```

### 3. Perplexity API Key (REQUIRED)
**Cost Impact:** $0.50-1 per episode  
**Usage:** Real-time research and fact-checking

**How to Get:**
1. Visit [Perplexity API](https://docs.perplexity.ai/)
2. Sign up for API access
3. Navigate to your dashboard
4. Generate new API key
5. Copy the key (starts with `pplx-...`)

**Add to .env:**
```bash
PERPLEXITY_API_KEY=pplx-your-actual-key-here
```

### 4. ElevenLabs API Key (REQUIRED)
**Cost Impact:** $1-2 per episode  
**Usage:** High-quality text-to-speech generation

**How to Get:**
1. Visit [ElevenLabs](https://elevenlabs.io/)
2. Sign in or create account
3. Go to "Speech Synthesis" > "Settings"
4. Copy your API key
5. Key is typically 32+ characters

**Add to .env:**
```bash
ELEVENLABS_API_KEY=your-actual-elevenlabs-key-here
```

## 🔄 Google Authentication Migration (IMPORTANT)

**⚠️ DEPRECATION NOTICE:** Google API keys (`AIza...`) are being phased out for production use. We're migrating to OAuth 2.0 service accounts.

### Option 1: Skip Google Integration (Simplest)
If you don't need Google services, simply omit the Google API key. The system will work without it.

### Option 2: Migrate to OAuth 2.0 (Recommended for Production)
**Follow these steps:**

1. **Create Service Account:**
   ```bash
   python -m config.google_auth_setup --setup-guide
   ```

2. **Download Credentials:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create service account
   - Download JSON credentials

3. **Configure Environment:**
   ```bash
   # Add to .env
   GOOGLE_SERVICE_ACCOUNT_JSON=/path/to/your/credentials.json
   ```

4. **Test Setup:**
   ```bash
   python -m config.google_auth_setup --test
   ```

### Option 3: Temporary API Key (Development Only)
**DEPRECATED - For development/testing only:**
```bash
GOOGLE_API_KEY=AIza-your-temporary-api-key-here  # Will show deprecation warning
```

## 📊 Optional Observability (Recommended)

### Langfuse Keys (RECOMMENDED)
**Cost:** Free tier available  
**Usage:** Track costs, performance, and quality metrics

**How to Get:**
1. Visit [Langfuse Cloud](https://cloud.langfuse.com/)
2. Sign up for free account
3. Create new project
4. Get public and secret keys

**Add to .env:**
```bash
LANGFUSE_PUBLIC_KEY=pk-lf-your-public-key-here
LANGFUSE_SECRET_KEY=sk-lf-your-secret-key-here
LANGFUSE_HOST=https://cloud.langfuse.com
```

## 🛡️ Security Best Practices

### File Security
```bash
# Set secure permissions on .env file
chmod 600 .env

# Verify .env is in .gitignore (it already is)
grep "\.env" .gitignore
```

### Key Management
- **Never commit** `.env` file to git
- **Use unique keys** for each environment (dev/staging/prod)
- **Rotate keys regularly** (quarterly recommended)
- **Monitor usage** through provider dashboards
- **Set budget alerts** in provider consoles

### Budget Controls
Add these budget safeguards to your `.env`:
```bash
# Cost controls (highly recommended)
MAX_EPISODE_COST=5.51
COST_WARNING_THRESHOLD=4.41
COST_CRITICAL_THRESHOLD=4.96

# Quality thresholds
QUALITY_THRESHOLD=8.0
```

## ✅ Validation & Testing

### Step 1: Validate Configuration
```bash
# Run comprehensive validation
python -m config.api_key_validator

# Should show:
# ✅ Required Keys: True
# 🚀 Production Ready: True
```

### Step 2: Health Check
```bash
# Test system health
python check_health.py

# Check specific components
python check_health.py --verbose
```

### Step 3: Dry Run Test
```bash
# Test without API calls (free)
python main.py --topic "Test Episode" --dry-run

# Test with minimal API usage
python main.py --topic "Test Episode" --budget-limit 1.00
```

## 📊 Expected Costs

| Provider | Cost per Episode | Usage |
|----------|------------------|--------|
| OpenAI | $2.00-3.00 | Script generation, research |
| Anthropic | $1.00-2.00 | Quality validation |
| Perplexity | $0.50-1.00 | Fact-checking |
| ElevenLabs | $1.00-2.00 | Audio synthesis |
| **TOTAL** | **$4.50-8.00** | **Per episode** |

**Target:** ≤$5.51 per episode (our validated production cost)

## 🚨 Troubleshooting

### Common Issues

**❌ "API key invalid" errors:**
```bash
# Check key format
python -m config.api_key_validator

# Test individual keys
curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models
```

**❌ "Rate limit exceeded":**
- Check your usage limits in provider dashboards
- Consider upgrading to paid tiers
- Implement backoff in production

**❌ "Budget exceeded":**
- Check `MAX_EPISODE_COST` setting
- Review cost tracking logs: `cat logs/costs.csv`
- Adjust budget controls if needed

**❌ Google authentication issues:**
```bash
# Run Google auth diagnostics
python -m config.google_auth_setup --test

# Show complete setup guide
python -m config.google_auth_setup --setup-guide
```

### Getting Help

1. **Run diagnostics:**
   ```bash
   python check_health.py --verbose
   python -m config.api_key_validator
   ```

2. **Check logs:**
   ```bash
   tail -f logs/podcast_production_$(date +%Y%m%d).log
   ```

3. **Validate environment:**
   ```bash
   python -c "import os; print({k:v for k,v in os.environ.items() if 'API' in k})"
   ```

## 🎯 Next Steps

After completing API key setup:

1. **✅ Validate everything works:**
   ```bash
   python -m config.api_key_validator
   python check_health.py
   ```

2. **🧪 Run first test episode:**
   ```bash
   python main.py --topic "Test Episode" --budget-limit 5.00
   ```

3. **📊 Check results and costs:**
   ```bash
   cat output/ep_*_cost_report.json
   ```

4. **🚀 Start production:**
   ```bash
   python main.py --topic "Your First Episode"
   ```

---

**Remember:** The system is designed to be cost-effective (≤$5.51/episode) and high-quality (≥8.0/10). Your API key configuration is the foundation for both goals.

**Security Note:** Never share your `.env` file or commit it to git. Each API key should be unique and regularly rotated for security.

**Support:** If you encounter issues, run the diagnostic tools above and check the troubleshooting section. The system includes comprehensive error handling and guidance.