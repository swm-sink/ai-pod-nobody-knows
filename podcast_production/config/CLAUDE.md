# Configuration Governance Context
<!-- Context Level: Component | Inherits: Production Domain | Token Budget: 2K -->

## 🔒 CONFIGURATION HIERARCHY

**Immutable**: Voice ID, temporal constraints
**Protected**: API keys, production settings
**Flexible**: Retry limits, timeouts, batch sizes

## 📋 CONFIGURATION FILES

### production-voice.json (PROTECTED)
```json
{
  "voice_id": "ZF6FPAbjXT4488VcRRnw",
  "voice_name": "Amelia",
  "provider": "elevenlabs",
  "settings": {
    "stability": 0.75,
    "similarity_boost": 0.85,
    "style": 0.0,
    "use_speaker_boost": true
  },
  "validated": "2025-09-01",
  "episodes_produced": 125,
  "lock": true
}
```
**RULE**: Changes require explicit user permission

### config.yaml
```yaml
system:
  environment: production
  version: 1.0.0
  date_context: "September 2025"

production:
  budget: 5.51
  retry_limit: 3
  checkpoint_enabled: true
  parallel_research: true
  
quality_gates:
  brand_threshold: 0.85
  consensus_minimum: 8.0
  audio_duration: [1560, 1680]  # 26-28 minutes in seconds
  script_length: [33000, 37000]  # characters

monitoring:
  dashboard_port: 3000
  websocket_enabled: true
  metrics_retention: 30  # days
  
cost_limits:
  research: 0.60
  script: 1.50
  evaluation: 1.00
  audio: 3.00
  total_max: 6.00
```

### providers.yaml
```yaml
perplexity:
  api_endpoint: "https://api.perplexity.ai"
  model: "sonar-deep-research"
  timeout: 30
  max_tokens: 4000
  temperature: 0.7

elevenlabs:
  api_endpoint: "https://api.elevenlabs.io/v1"
  model_id: "eleven_multilingual_v2"
  output_format: "mp3_44100_128"
  chunk_size: 5000

claude:
  provider: "mcp"
  model: "claude-3-sonnet"
  max_tokens: 8000
  temperature: 0.7

gemini:
  api_endpoint: "https://generativelanguage.googleapis.com"
  model: "gemini-1.5-pro"
  max_tokens: 8000
  temperature: 0.7
```

## 🔑 ENVIRONMENT VARIABLES

### Required APIs
```bash
# Core APIs (Required)
ELEVEN_LABS_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-...
GOOGLE_API_KEY=AIza...
PERPLEXITY_API_KEY=pplx-...

# Production Settings (Required)
PRODUCTION_VOICE_ID=ZF6FPAbjXT4488VcRRnw
PRODUCTION_BUDGET=5.51
PRODUCTION_ENVIRONMENT=production

# Optional Overrides
PRODUCTION_RETRY_LIMIT=3
PRODUCTION_TIMEOUT=30
PRODUCTION_PARALLEL=true

# Monitoring (Optional)
LANGFUSE_PUBLIC_KEY=...
LANGFUSE_SECRET_KEY=...
DASHBOARD_PORT=3000
```

### Configuration Loading Order
1. Environment variables (highest priority)
2. config.yaml
3. providers.yaml
4. Default values (lowest priority)

## ⚙️ DYNAMIC CONFIGURATION

### Runtime Adjustments
```python
class ConfigManager:
    """Dynamic configuration management"""
    
    def __init__(self):
        self.base_config = self.load_yaml("config.yaml")
        self.providers = self.load_yaml("providers.yaml")
        self.voice = self.load_json("production-voice.json")
        
    def get_setting(self, path: str, default=None):
        """Get setting with fallback"""
        # Check env vars first
        env_key = path.upper().replace(".", "_")
        if env_value := os.getenv(env_key):
            return env_value
            
        # Check config files
        value = self.navigate_path(self.base_config, path)
        return value if value is not None else default
    
    def validate_constraints(self):
        """Enforce configuration rules"""
        # Voice ID must match
        assert self.voice["voice_id"] == os.getenv("PRODUCTION_VOICE_ID")
        
        # Budget must be reasonable
        assert 0 < float(self.get_setting("production.budget")) <= 10.0
        
        # Quality thresholds
        assert self.get_setting("quality_gates.brand_threshold") >= 0.8
```

### Feature Flags
```yaml
features:
  parallel_research:
    enabled: true
    max_concurrent: 5
    
  experimental_tts:
    enabled: false
    provider: "experimental"
    
  cost_optimization:
    enabled: true
    mode: "aggressive"
    
  quality_enhancement:
    enabled: true
    dual_evaluation: true
    consensus_required: true
```

## 📊 CONFIGURATION VALIDATION

### Startup Validation
```python
def validate_production_config():
    """Validate all configuration on startup"""
    
    checks = {
        "voice_locked": voice_config["lock"] == True,
        "apis_configured": all([
            os.getenv("ELEVEN_LABS_API_KEY"),
            os.getenv("ANTHROPIC_API_KEY"),
            os.getenv("GOOGLE_API_KEY"),
            os.getenv("PERPLEXITY_API_KEY")
        ]),
        "budget_valid": 0 < config["production"]["budget"] <= 10,
        "quality_gates": all([
            config["quality_gates"]["brand_threshold"] >= 0.8,
            config["quality_gates"]["consensus_minimum"] >= 7.0
        ])
    }
    
    if not all(checks.values()):
        failed = [k for k, v in checks.items() if not v]
        raise ConfigurationError(f"Failed checks: {failed}")
```

## 🔄 CONFIGURATION UPDATES

### Safe Update Pattern
```python
def update_config_safely(key: str, value: Any):
    """Update configuration with validation"""
    
    # Check if immutable
    if key in IMMUTABLE_KEYS:
        raise PermissionError(f"Cannot modify {key}")
    
    # Validate new value
    if not validate_config_value(key, value):
        raise ValueError(f"Invalid value for {key}: {value}")
    
    # Create backup
    backup_config()
    
    # Apply update
    config[key] = value
    
    # Test configuration
    if not test_config():
        restore_backup()
        raise ConfigurationError("Configuration test failed")
    
    # Save
    save_config()
```

## 🎯 CONFIGURATION BEST PRACTICES

1. **Never hardcode**: Use config files or env vars
2. **Validate early**: Check all settings on startup
3. **Fail fast**: Stop if critical config missing
4. **Audit changes**: Log all configuration updates
5. **Version control**: Track config file changes
6. **Secure storage**: Never commit API keys

## 🔄 INHERITANCE

**Inherits From**: `../CLAUDE.md` (Production Domain)
**Sibling Contexts**:
- `../agents/CLAUDE.md` - Agent implementations
- `../workflows/CLAUDE.md` - Workflow patterns

---

**Token Budget**: 2K | **Focus**: Configuration governance | **Status**: Protected