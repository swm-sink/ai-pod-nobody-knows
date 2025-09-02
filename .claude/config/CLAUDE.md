# Configuration Memory - System Settings & Environment 🔧

<document type="configuration-memory" version="1.0.0" inherits="/.claude/CLAUDE.md">
  <metadata>
    <domain>.claude/config</domain>
    <scope>System configuration, environment management, and production settings</scope>
    <inheritance-level>Tier 4 - Component Memory</inheritance-level>
    <selective-loading>true</selective-loading>
    <loads-when>configuration work, environment setup, production settings</loads-when>
    <triggers>config|environment|setup|production|voice|settings</triggers>
  </metadata>
</document>

## 🎯 CONFIGURATION CONTEXT

**Technical:** Configuration management memory implementing environment variable systems, production voice protection, quality gate configuration, cost control settings, and MCP server management for reliable podcast production operations.

**Simple:** Like having a detailed manual for all the system settings and configurations that make everything work reliably.

**Connection:** This teaches configuration management, environment design, and production system reliability patterns essential for deploying AI applications.

---

## ⚙️ CONFIGURATION ARCHITECTURE

### **Production Voice Configuration** - `@production-voice.json`
<LOAD_IF task="voice|audio|production|elevenlabs">
```yaml
voice_protection:
  voice_id: "ZF6FPAbjXT4488VcRRnw"  # IMMUTABLE
  voice_name: "Amelia"
  change_policy: "Requires explicit user approval"
  validation: "Episode 1 validated performance"
  
empirical_settings:
  stability: 0.65
  similarity_boost: 0.8
  style: 0.3
  use_speaker_boost: true
  model_id: "eleven_turbo_v2_5"
  
performance_metrics:
  processing_rate: "206 WPM"
  cost_per_episode: "$2.77"
  word_accuracy: "94.89%"
  character_accuracy: "91.23%"
```
</LOAD_IF>

### **Quality Gates Configuration** - `@quality_gates.yaml`
<LOAD_IF task="quality|validation|gates|standards">
```yaml
quality_thresholds:
  brand_consistency: 0.90
  technical_accuracy: 0.85
  engagement_score: 0.80
  comprehension: 0.85
  audio_quality: 0.85
  
validation_system:
  evaluators: ["claude", "gemini", "perplexity"]
  consensus_weights: {"claude": 0.55, "gemini": 0.45}
  minimum_threshold: 0.85
  retry_limit: 3
```
</LOAD_IF>

### **MCP Server Configuration** - `@claude-code-mcp.json`
<LOAD_IF task="mcp|server|api|integration">
```yaml
mcp_servers:
  perplexity:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-perplexity"]
    environment: "PERPLEXITY_API_KEY"
    
  elevenlabs:
    command: "npx" 
    args: ["-y", "@modelcontextprotocol/server-elevenlabs"]
    environment: "ELEVENLABS_API_KEY"
    
connection_validation:
  health_check: "claude mcp list"
  test_script: "./test-mcp-connections.sh"
  setup_script: "./setup-mcp.sh"
```
</LOAD_IF>

---

## 🛡️ CONFIGURATION PROTECTION

### **Environment Security**
```yaml
security_patterns:
  api_keys: "Stored in .env (git-ignored)"
  production_voice: "Immutable without approval"
  cost_limits: "Enforced through budget controls"
  access_control: "MCP permissions via settings.json"
  
validation_scripts:
  setup: "./setup-mcp.sh"
  testing: "./test-mcp-connections.sh"
  validation: "./validate-config.sh"
```

### **Configuration Consistency**
- **Single Source Truth**: All configs centralized in .claude/config/
- **Environment Variables**: Managed through .env template system
- **Version Control**: All configs tracked except .env files
- **Validation**: Automated checking before production operations

---

*Configuration memory: Load when working with system setup, environment configuration, or production settings*
