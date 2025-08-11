# Environment and API Key Management Guide

## 🔐 Security-First Approach

**Technical:** Multi-layered secret management with environment isolation, key rotation policies, and audit trails
**Simple:** Like having different safes for different valuables - each with its own combination and access log
**Connection:** This teaches enterprise-grade security practices essential for production systems

## 📁 Configuration Structure

```
.
├── .env                    # Local development keys (NEVER commit)
├── .env.example           # Template for team (safe to commit)
├── .env.development       # Dev environment settings (optional)
├── .env.production        # Production settings (managed separately)
├── .claude/
│   ├── config/
│   │   ├── mcp-config.json     # MCP server configurations
│   │   ├── cost-limits.json    # Cost management rules
│   │   └── quality-gates.json  # Quality thresholds
│   └── settings/
│       └── local.json          # Claude Code local settings
```

## 🔑 API Key Management

### Current Keys (Development)
```bash
# Perplexity API
PERPLEXITY_API_KEY=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

# ElevenLabs API  
ELEVENLABS_API_KEY=sk_50caa9b149cb87deffeeec4483de8de13ebd7f97fac88cd2
```

### Key Rotation Schedule
- **Development Keys**: Every 90 days
- **Production Keys**: Every 30 days
- **Compromised Keys**: Immediately

### Key Rotation Process
1. Generate new key from provider dashboard
2. Update .env file locally
3. Test with minimal API call
4. Update Claude Code MCP config
5. Archive old key (mark as rotated)
6. Update team documentation

## 🚀 Scalability Patterns

### 1. Environment Segregation
```bash
# Development (low limits, verbose logging)
ENVIRONMENT=development
MAX_COST_PER_EPISODE=5.00
LOG_LEVEL=DEBUG

# Staging (production-like, moderate limits)
ENVIRONMENT=staging
MAX_COST_PER_EPISODE=6.00
LOG_LEVEL=INFO

# Production (optimized, strict limits)
ENVIRONMENT=production
MAX_COST_PER_EPISODE=8.00
LOG_LEVEL=WARNING
```

### 2. Team Collaboration

#### Using .env.vault (Recommended for Teams)
```bash
# Install dotenv-vault
npm install -g dotenv-vault

# Login to vault
npx dotenv-vault login

# Push development keys
npx dotenv-vault push development

# Team member pulls keys
npx dotenv-vault pull development
```

#### Manual Secure Sharing
1. Use password manager (1Password, Bitwarden)
2. Share via encrypted channels only
3. Never use email, Slack, or git
4. Rotate after sharing

### 3. Cost Management

#### Per-Environment Budgets
```javascript
// .claude/config/cost-limits.json
{
  "development": {
    "daily_limit": 10.00,
    "episode_limit": 2.00,
    "alert_threshold": 1.50
  },
  "staging": {
    "daily_limit": 25.00,
    "episode_limit": 4.00,
    "alert_threshold": 3.00
  },
  "production": {
    "daily_limit": 50.00,
    "episode_limit": 5.00,
    "alert_threshold": 4.00
  }
}
```

#### Cost Tracking Implementation
```python
# .claude/scripts/track_costs.py
import os
import json
from datetime import datetime

class CostTracker:
    def __init__(self):
        self.environment = os.getenv('ENVIRONMENT', 'development')
        self.limits = self.load_cost_limits()
        
    def track_api_call(self, service, cost):
        """Track individual API call costs"""
        timestamp = datetime.now().isoformat()
        
        # Log to file
        with open(f'logs/costs_{self.environment}.jsonl', 'a') as f:
            json.dump({
                'timestamp': timestamp,
                'service': service,
                'cost': cost,
                'environment': self.environment
            }, f)
            f.write('\n')
        
        # Check limits
        if cost > self.limits['alert_threshold']:
            self.send_cost_alert(service, cost)
```

## 🔧 Claude Code MCP Configuration

### Local MCP Setup
```bash
# Configure Perplexity MCP
claude mcp add perplexity \
  --env PERPLEXITY_API_KEY="${PERPLEXITY_API_KEY}" \
  --env PERPLEXITY_MODEL="sonar-pro"

# Configure ElevenLabs MCP
claude mcp add elevenlabs \
  --env ELEVENLABS_API_KEY="${ELEVENLABS_API_KEY}" \
  --env ELEVENLABS_VOICE_ID="default"
```

### MCP Config File (.claude/settings/local.json)
```json
{
  "mcp_servers": {
    "perplexity": {
      "enabled": true,
      "api_key_env": "PERPLEXITY_API_KEY",
      "model": "sonar-pro",
      "rate_limit": 20,
      "timeout": 30000
    },
    "elevenlabs": {
      "enabled": true,
      "api_key_env": "ELEVENLABS_API_KEY",
      "voice_id": "default",
      "model": "eleven_turbo_v2",
      "rate_limit": 10,
      "timeout": 60000
    }
  },
  "cost_tracking": {
    "enabled": true,
    "log_path": "./logs/mcp_costs.jsonl",
    "alert_threshold": 4.00
  }
}
```

## 📊 Monitoring and Observability

### API Usage Dashboard
```python
# .claude/scripts/usage_dashboard.py
def generate_usage_report():
    """Generate daily API usage report"""
    
    report = {
        'date': datetime.now().date().isoformat(),
        'environment': os.getenv('ENVIRONMENT'),
        'api_calls': {
            'perplexity': count_api_calls('perplexity'),
            'elevenlabs': count_api_calls('elevenlabs')
        },
        'total_cost': calculate_daily_cost(),
        'episodes_produced': count_daily_episodes(),
        'average_cost_per_episode': calculate_average_cost()
    }
    
    # Save report
    with open(f'reports/daily_{report["date"]}.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    return report
```

## 🛡️ Security Best Practices

### 1. Never Commit Keys
```bash
# Verify .env is ignored
git check-ignore .env  # Should return .env

# Check for accidental commits
git log --all --full-history -- "**/.env"
```

### 2. Use Environment Variables
```python
# Always use environment variables, never hardcode
import os

PERPLEXITY_KEY = os.getenv('PERPLEXITY_API_KEY')
if not PERPLEXITY_KEY:
    raise ValueError("PERPLEXITY_API_KEY not found in environment")
```

### 3. Implement Key Rotation Reminders
```python
# .claude/scripts/key_rotation_check.py
from datetime import datetime, timedelta

def check_key_age():
    """Check if keys need rotation"""
    
    key_created = datetime(2025, 8, 11)  # Today
    days_old = (datetime.now() - key_created).days
    
    if days_old > 85:
        print("⚠️ WARNING: API keys are due for rotation soon!")
    elif days_old > 90:
        print("🚨 CRITICAL: API keys must be rotated immediately!")
```

## 🚀 Scaling to Production

### Migration Path
1. **Current State**: Local .env file with development keys
2. **Next Step**: Implement .env.vault for team sharing
3. **Future**: Integrate with cloud secret managers

### Cloud Secret Managers (Future)
```python
# Future implementation with AWS Secrets Manager
import boto3

def get_secret(secret_name):
    """Retrieve secret from AWS Secrets Manager"""
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# Usage
secrets = get_secret('podcast-production/api-keys')
os.environ['PERPLEXITY_API_KEY'] = secrets['perplexity']
os.environ['ELEVENLABS_API_KEY'] = secrets['elevenlabs']
```

## 📝 Quick Reference

### Check Current Environment
```bash
# View current environment
echo $ENVIRONMENT

# View all podcast-related env vars
env | grep -E "(PERPLEXITY|ELEVENLABS|MAX_COST)"
```

### Test API Keys
```bash
# Test Perplexity
curl -X POST https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"sonar","messages":[{"role":"user","content":"test"}]}'

# Test ElevenLabs
curl -X GET https://api.elevenlabs.io/v1/user \
  -H "xi-api-key: $ELEVENLABS_API_KEY"
```

## 🎯 Action Items

1. ✅ Created .env with API keys
2. ✅ Verified .gitignore includes .env
3. ⏳ Set up MCP servers with these keys
4. ⏳ Implement cost tracking
5. ⏳ Create monitoring dashboard
6. ⏳ Document rotation schedule

## ⚠️ Important Reminders

- **NEVER** share .env file directly
- **ALWAYS** use environment variables in code
- **ROTATE** keys every 90 days (dev) or 30 days (prod)
- **MONITOR** API usage daily
- **ALERT** on unusual activity or high costs

---

**Last Updated**: 2025-08-11
**Environment**: Development
**Next Key Rotation**: 2025-09-09 (90 days)