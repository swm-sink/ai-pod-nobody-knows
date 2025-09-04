# Production Validation Troubleshooting Guide 🔧

This guide helps you resolve common issues encountered during production readiness validation.

## Quick Start Checklist ✅

Before running validation, ensure:

1. **You're in the correct directory**: `cd podcast_production`
2. **Python environment is activated**: `source venv/bin/activate` (if using virtual environment)
3. **Dependencies are installed**: `pip install -r requirements.txt`
4. **Environment variables are set**: Check your `.env` file

## Common Issues and Solutions

### Environment Setup Issues 🏗️

#### Issue: Missing Environment Variables
**Error**: `Missing required variables: OPENROUTER_API_KEY, ELEVENLABS_API_KEY`

**Solution**:
1. Create or update your `.env` file:
```bash
# Required API Keys
OPENROUTER_API_KEY=your_openrouter_api_key_here
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
PERPLEXITY_API_KEY=your_perplexity_api_key_here

# Production Configuration
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
MAX_EPISODE_COST=5.51

# Optional Configuration
LANGFUSE_PUBLIC_KEY=your_langfuse_public_key
LANGFUSE_SECRET_KEY=your_langfuse_secret_key
```

2. Verify the file is not tracked by git:
```bash
git status  # .env should NOT appear in untracked files
```

3. Ensure `.env` is in `.gitignore`:
```bash
echo ".env" >> .gitignore
```

#### Issue: Invalid Voice ID
**Error**: `PRODUCTION_VOICE_ID appears invalid (length: X)`

**Solution**:
- ElevenLabs voice IDs are exactly 20 characters long
- Verify your voice ID in ElevenLabs dashboard
- Current production voice: `ZF6FPAbjXT4488VcRRnw`

#### Issue: Config Files Missing
**Error**: `Missing required config files`

**Solution**:
1. Check required config files exist:
```bash
ls -la config/
# Should show: config.yaml, production_config.yaml, providers.yaml, production-voice.json
```

2. If missing, create from templates:
```bash
cp config/config.example.yaml config/config.yaml
cp config/production_config.example.yaml config/production_config.yaml
```

### API Connectivity Issues 🌐

#### Issue: OpenRouter API Connection Failed
**Error**: `OpenRouter connectivity failed: 401 Unauthorized`

**Solutions**:
1. **Verify API key**:
   - Check your OpenRouter dashboard
   - Ensure key has sufficient credits
   - Verify key hasn't expired

2. **Test API key manually**:
```bash
curl -X POST "https://openrouter.ai/api/v1/chat/completions" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -H "HTTP-Referer: https://github.com/ai-podcasts-nobody-knows" \
  -d '{"model": "anthropic/claude-3-haiku", "messages": [{"role": "user", "content": "test"}], "max_tokens": 5}'
```

3. **Check network connectivity**:
```bash
ping openrouter.ai
```

#### Issue: ElevenLabs API Connection Failed
**Error**: `ElevenLabs API error: HTTP 401`

**Solutions**:
1. **Verify API key**:
```bash
curl -H "xi-api-key: YOUR_API_KEY" https://api.elevenlabs.io/v1/voices
```

2. **Check voice access**:
```bash
curl -H "xi-api-key: YOUR_API_KEY" https://api.elevenlabs.io/v1/voices/ZF6FPAbjXT4488VcRRnw
```

3. **Verify subscription status**:
   - Check ElevenLabs dashboard for account status
   - Ensure you have available character credits

#### Issue: Perplexity API Connection Failed
**Error**: `Perplexity connectivity failed`

**Solutions**:
1. **Verify API key**:
```bash
curl -X POST "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "llama-3.1-sonar-small-128k-online", "messages": [{"role": "user", "content": "test"}], "max_tokens": 5}'
```

2. **Note**: Perplexity is optional - validation will pass if key is missing

### Python Dependency Issues 🐍

#### Issue: Module Import Errors
**Error**: `ModuleNotFoundError: No module named 'langgraph'`

**Solutions**:
1. **Install requirements**:
```bash
pip install -r requirements.txt
```

2. **Check Python version** (requires 3.11+):
```bash
python --version
```

3. **Verify virtual environment**:
```bash
which python  # Should point to your venv if activated
pip list | grep langgraph  # Should show installed version
```

4. **Manual installation of key packages**:
```bash
pip install langgraph langchain anthropic openai elevenlabs pyyaml msgpack psutil
```

#### Issue: Package Version Conflicts
**Error**: `Package issues: X`

**Solutions**:
1. **Update packages**:
```bash
pip install --upgrade -r requirements.txt
```

2. **Clean install**:
```bash
pip uninstall -r requirements.txt -y
pip install -r requirements.txt
```

### Directory Structure Issues 📁

#### Issue: Missing Directories
**Error**: `Missing required directories`

**Solutions**:
1. **Auto-creation** (validator will attempt this):
```bash
mkdir -p logs output reports production_validation_output
```

2. **Verify structure**:
```bash
ls -la
# Should show: logs/, output/, config/, core/, agents/, workflows/, nodes/, monitoring/, scripts/
```

### System Resource Issues 💻

#### Issue: Insufficient System Resources
**Error**: `Low memory: X.XGB available`

**Solutions**:
1. **Check available memory**:
```bash
free -h  # Linux
vm_stat | head -5  # macOS
```

2. **Close unnecessary applications**

3. **Minimum requirements**:
   - RAM: 2GB available
   - Disk: 5GB free
   - CPU: 2+ cores

#### Issue: File Permission Problems
**Error**: `Permission error for logs: [Errno 13] Permission denied`

**Solutions**:
1. **Fix directory permissions**:
```bash
chmod 755 logs output config
chmod 644 config/*.yaml config/*.json
```

2. **Check ownership**:
```bash
ls -la logs/
# Should be owned by your user
```

### Cost and Budget Issues 💰

#### Issue: Budget Exceeded During Validation
**Error**: `Budget exceeded during validation`

**Solutions**:
1. **Use dry-run mode**:
```bash
python validate_production_readiness.py --dry-run
```

2. **Run only critical tests**:
```bash
python validate_production_readiness.py --quick
```

3. **Check current costs**:
```bash
cat logs/costs.csv | tail -10
```

#### Issue: Cost Tracking Not Working
**Error**: `Cost tracker not recording costs correctly`

**Solutions**:
1. **Check logs directory is writable**:
```bash
touch logs/test.txt && rm logs/test.txt
```

2. **Verify CSV file permissions**:
```bash
ls -la logs/costs.csv
```

### Quality Validation Issues ⭐

#### Issue: Quality Scores Below Target
**Error**: `Quality scoring: X.X/10 (FAIL)`

**Solutions**:
1. This is expected in dry-run mode (uses simulated scores)
2. Real quality validation happens during actual episode production
3. Verify quality targets in config:
```yaml
quality:
  minimum_scores:
    brand_alignment: 0.80
    technical_accuracy: 0.80
    engagement: 0.80
  overall_threshold: 8.0
```

## Validation Modes 🎛️

### Dry Run Mode (Recommended First)
```bash
python validate_production_readiness.py --dry-run
```
- **No API costs**
- **No actual API calls**
- **Tests system configuration and setup**
- **Safe to run multiple times**

### Comprehensive Mode (Live API Calls)
```bash
python validate_production_readiness.py --comprehensive
```
- **Makes actual API calls**
- **Incurs small costs (~$0.01-$0.05)**
- **Full production validation**
- **Use after dry-run passes**

### Quick Mode (Critical Tests Only)
```bash
python validate_production_readiness.py --quick
```
- **Only critical tests**
- **Dry-run mode**
- **Fastest validation**

### Category-Specific Testing
```bash
# Test only API connectivity
python validate_production_readiness.py --category api

# Test only environment setup
python validate_production_readiness.py --category environment

# Test only critical severity issues
python validate_production_readiness.py --severity critical
```

## Advanced Troubleshooting 🔬

### Debug Mode
Enable detailed logging:
```bash
export PYTHONPATH="." 
python -m logging --level DEBUG validate_production_readiness.py --dry-run
```

### Check System Health
```bash
# Check Python environment
python check_health.py

# Check system resources
python -c "import psutil; print(f'Memory: {psutil.virtual_memory().available/1024**3:.1f}GB, Disk: {psutil.disk_usage(\".\").free/1024**3:.1f}GB')"

# Test core imports
python -c "from core.cost_tracker import CostTracker; from core.state import PodcastState; print('Core imports OK')"
```

### Manual API Testing
Test APIs individually:

```python
# Test OpenRouter
import os, requests
headers = {
    "Authorization": f"Bearer {os.getenv('OPENROUTER_API_KEY')}",
    "Content-Type": "application/json"
}
response = requests.post(
    "https://openrouter.ai/api/v1/chat/completions",
    headers=headers,
    json={"model": "anthropic/claude-3-haiku", "messages": [{"role": "user", "content": "test"}], "max_tokens": 5}
)
print(f"Status: {response.status_code}, Response: {response.json()}")
```

### Log Analysis
Check validation logs:
```bash
# Latest validation log
ls -lt logs/production_validation_*.log | head -1

# View errors only
grep ERROR logs/production_validation_*.log

# View test results
grep "✅\|❌" logs/production_validation_*.log
```

## Getting Help 🆘

### Self-Diagnosis Steps
1. Run quick validation: `python validate_production_readiness.py --quick`
2. Check logs: `tail -20 logs/production_validation_*.log`
3. Verify environment: Check `.env` file and API keys
4. Test core imports: `python -c "from main import *"`

### Common Error Patterns

| Error Pattern | Likely Cause | Solution |
|--------------|--------------|----------|
| `ModuleNotFoundError` | Missing dependencies | Run `pip install -r requirements.txt` |
| `HTTP 401` | Invalid API key | Check API key in `.env` |
| `Permission denied` | File permissions | Run `chmod 755 logs output` |
| `Budget exceeded` | Cost limit reached | Use `--dry-run` mode |
| `Config file missing` | Setup incomplete | Copy from templates in `config/` |

### Success Criteria
A successful validation should show:
- ✅ All critical tests passed
- ✅ API connectivity working
- ✅ Budget under $5.51 target
- ✅ Quality targets configured
- 🏆 PRODUCTION_READY certification

## Next Steps After Successful Validation 🚀

1. **First Episode Test**:
```bash
python main.py --topic "Test Episode: AI Fundamentals" --budget 2.00
```

2. **Monitor Production**:
```bash
python monitoring/production_monitor.py
```

3. **Regular Health Checks**:
```bash
# Run weekly
python validate_production_readiness.py --dry-run --quick
```

## Emergency Procedures 🚨

### If Validation Keeps Failing
1. **Reset to known good state**:
```bash
git stash  # Save current changes
git checkout main  # Switch to main branch
python validate_production_readiness.py --dry-run
```

2. **Check system requirements**:
   - Python 3.11+
   - 4GB+ RAM available
   - 10GB+ disk space
   - Active internet connection

3. **Minimal test**:
```bash
python -c "
import sys
print(f'Python: {sys.version}')
import yaml, json, requests
print('Core modules OK')
from core.cost_tracker import CostTracker
print('Project imports OK')
"
```

### Recovery Commands
```bash
# Clean slate
rm -rf logs/*.log production_validation_output/*
mkdir -p logs output reports

# Reinstall dependencies
pip install --force-reinstall -r requirements.txt

# Test basic functionality
python -m pytest tests/unit/ -v
```

Remember: The validation framework is designed to help ensure production readiness. If you're encountering persistent issues, it's better to resolve them now than discover problems during actual episode production! 🎯