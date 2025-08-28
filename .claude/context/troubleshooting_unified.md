# Troubleshooting - Complete AI Podcast Production Issue Resolution

**Created**: 2025-08-27 (Consolidated from 4 files)
**Purpose**: Unified troubleshooting framework for all AI podcast production issues
**Scope**: MCP integration, API issues, audio synthesis, quality validation, and system diagnostics

---

## 🚨 CRITICAL ISSUE CLASSIFICATION

### Severity Levels
```yaml
severity_classification:
  critical:
    description: "Production-blocking issues requiring immediate attention"
    examples: "MCP failures, API authentication, system crashes"
    response_time: "Immediate (within minutes)"

  high:
    description: "Significant impact on quality, cost, or delivery"
    examples: "Duration discrepancies, quality failures, cost overruns"
    response_time: "Within 1 hour"

  medium:
    description: "Workflow efficiency issues affecting productivity"
    examples: "Slow processing, minor errors, suboptimal performance"
    response_time: "Within 4 hours"

  low:
    description: "Cosmetic or documentation issues"
    examples: "UI improvements, documentation updates, minor enhancements"
    response_time: "Within 24 hours"
```

### Issue Categories
```yaml
issue_categories:
  integration_issues: "MCP server failures, API connectivity problems"
  audio_synthesis: "Duration calculations, SSML processing, voice quality"
  quality_validation: "STT accuracy, brand voice alignment, content quality"
  cost_billing: "Unexpected charges, budget overruns, cost attribution"
  system_infrastructure: "Environment setup, resource constraints, performance"
```

---

## 🔧 CRITICAL ISSUE #1: MCP INTEGRATION FAILURE

### Problem Description
**Severity**: CRITICAL
**Symptoms**: ElevenLabs MCP server returns "invalid_api_key" despite valid API key
**Impact**: Complete blocking of audio synthesis workflow

### Root Cause Analysis
```yaml
root_causes:
  environment_loading: "MCP servers require API keys loaded before Claude Code starts"
  runtime_access: "MCP servers cannot access environment variables during execution"
  configuration_order: ".mcp.json references ${ELEVENLABS_API_KEY} but key not available"
  startup_sequence: "Environment must be loaded before Claude Code initialization"
```

### Diagnostic Steps
```bash
# Step 1: Verify API key exists in environment
echo "ELEVENLABS_API_KEY: $([ ! -z "$ELEVENLABS_API_KEY" ] && echo 'SET' || echo 'NOT SET')"

# Step 2: Check key length and format
echo "API Key Length: ${#ELEVENLABS_API_KEY}"

# Step 3: Test direct API access (outside Claude)
curl -X GET "https://api.elevenlabs.io/v1/subscription" \
  -H "xi-api-key: $ELEVENLABS_API_KEY"

# Step 4: Check MCP server status in Claude
/mcp

# Step 5: Test MCP tool directly
mcp__elevenlabs__check_subscription
```

### Solution Implementation
```bash
# CRITICAL: Proper environment loading sequence
cd /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows

# Step 1: Load environment variables
source .env

# Step 2: Verify all keys loaded
echo "Environment Check:"
echo "ELEVENLABS_API_KEY: $([ ! -z "$ELEVENLABS_API_KEY" ] && echo 'LOADED' || echo 'MISSING')"
echo "PERPLEXITY_API_KEY: $([ ! -z "$PERPLEXITY_API_KEY" ] && echo 'LOADED' || echo 'MISSING')"
echo "GITHUB_PAT: $([ ! -z "$GITHUB_PAT" ] && echo 'LOADED' || echo 'MISSING')"

# Step 3: Start Claude Code with proper environment
./start-claude.sh
```

### Prevention Measures
```yaml
prevention_strategy:
  startup_protocol: "Always use ./start-claude.sh instead of direct 'claude code'"
  environment_validation: "Verify all API keys loaded before starting"
  documentation_updates: "Update all guides to specify proper startup sequence"
  monitoring: "Add hooks to detect MCP authentication failures early"
```

---

## 🎵 CRITICAL ISSUE #2: AUDIO DURATION DISCREPANCIES

### Problem Description
**Severity**: HIGH
**Symptoms**: Generated audio duration significantly different from calculated duration
**Impact**: Episodes too short/long, affecting content planning and cost estimation

### Root Cause Analysis
```yaml
duration_factors:
  wpm_variability: "Words per minute varies by content type and complexity"
  ssml_processing: "SSML tags affect speech timing and pacing"
  voice_characteristics: "Different voices have different speaking rates"
  content_complexity: "Technical terms, numbers, abbreviations affect timing"
```

### WPM Discovery Results
```yaml
empirical_wpm_data:
  amelia_voice: "Base WPM approximately 150-160 words per minute"
  content_factors:
    technical_content: "20% slower (120-130 WPM)"
    narrative_content: "Standard rate (150-160 WPM)"
    conversational_content: "10% faster (165-175 WPM)"
  ssml_impact:
    pauses: "Explicit pauses add to total duration"
    emphasis: "Emphasis tags may slow speech slightly"
    speed_modifications: "Direct impact on timing calculations"
```

### Diagnostic Steps
```bash
# Step 1: Test duration calculation
python3 -c "
words = 1500
base_wpm = 155
duration_minutes = words / base_wpm
print(f'Calculated: {duration_minutes:.2f} minutes')
print(f'Expected range: {(duration_minutes * 0.8):.2f}-{(duration_minutes * 1.2):.2f} minutes')
"

# Step 2: Analyze actual vs expected
# Compare generated audio duration with calculations
# Identify content factors affecting timing

# Step 3: Optimize SSML for consistency
# Review SSML tags for timing impact
# Adjust pause durations and speaking rates
```

### Solution Implementation
```yaml
duration_optimization:
  calculation_improvement:
    base_wpm: "Use empirically determined 155 WPM for Amelia voice"
    content_adjustment: "Apply content-type multipliers"
    ssml_accounting: "Include estimated SSML timing impact"

  content_optimization:
    ssml_standardization: "Consistent pause and emphasis patterns"
    content_structuring: "Balance technical and narrative content"
    duration_targets: "Plan content to specific duration goals"

  validation_process:
    duration_checking: "Validate audio duration against targets"
    feedback_loop: "Adjust calculations based on actual results"
    quality_gates: "Duration validation before final production"
```

---

## 🎯 QUALITY VALIDATION ISSUES

### STT Validation Accuracy Problems
**Problem**: Speech-to-text validation shows discrepancies with source script
**Impact**: Quality assurance false positives/negatives

#### Diagnostic Framework
```yaml
stt_validation_analysis:
  accuracy_factors:
    voice_quality: "Higher quality voices improve STT accuracy"
    content_complexity: "Technical terms reduce STT accuracy"
    pronunciation: "Mispronunciations create validation failures"
    audio_quality: "Professional audio settings improve STT results"

  validation_metrics:
    word_accuracy: "Target >95% word-level accuracy"
    semantic_accuracy: "Target >98% meaning preservation"
    technical_accuracy: "Target >90% for technical terms"
```

#### Solution Approach
```yaml
stt_optimization:
  audio_quality:
    lufs_target: "-16 LUFS for professional broadcast quality"
    sample_rate: "48kHz for maximum clarity"
    bit_depth: "24-bit for professional standard"

  content_optimization:
    technical_terms: "Phonetic spelling in SSML for complex terms"
    pronunciation_guide: "Custom pronunciation dictionaries"
    content_review: "Technical accuracy validation before synthesis"

  validation_framework:
    multi_pass_checking: "Multiple validation approaches for accuracy"
    semantic_comparison: "Meaning-based validation vs literal matching"
    quality_thresholds: "Adjustable accuracy thresholds by content type"
```

---

## 💰 COST & BILLING ISSUES

### Unexpected Cost Overruns
**Problem**: Episode production costs exceed budget estimates
**Impact**: Project budget management and scalability concerns

#### Cost Tracking Framework
```yaml
cost_monitoring:
  real_time_tracking:
    pre_tool_hooks: "Budget validation before API calls"
    post_tool_hooks: "Cost accumulation and attribution"
    phase_budgets: "Per-phase cost limits and alerts"

  cost_attribution:
    research_costs: "Perplexity, web search, content gathering"
    script_costs: "LLM usage for content generation"
    audio_costs: "ElevenLabs TTS synthesis"
    validation_costs: "Quality assurance and review processes"

  budget_controls:
    episode_limit: "$15.00 maximum per episode"
    target_cost: "$5.51 optimized production cost"
    alert_thresholds: "75% warning, 90% critical, 100% blocking"
```

#### Cost Optimization Solutions
```yaml
cost_reduction_strategies:
  research_efficiency:
    caching: "Store and reuse research results"
    strategic_queries: "Optimize Perplexity usage patterns"
    free_resources: "Prioritize included/free research tools"

  script_optimization:
    templates: "Standardized structures reduce iteration"
    quality_gates: "Prevent expensive rewrites"
    efficient_prompts: "Reduce token usage through optimization"

  audio_efficiency:
    voice_consistency: "Single production voice reduces costs"
    ssml_optimization: "Efficient markup reduces character count"
    batch_processing: "Optimize API usage patterns"
```

---

## 🖥️ SYSTEM & INFRASTRUCTURE ISSUES

### Environment Setup Problems
**Problem**: Installation, configuration, and environment issues
**Impact**: Unable to start or use the podcast production system

#### Common Setup Issues
```yaml
environment_problems:
  python_version:
    issue: "Incompatible Python version"
    solution: "Use Python 3.11+ with virtual environment"
    verification: "python3 --version && which python3"

  virtual_environment:
    issue: "Virtual environment not activated or configured"
    solution: "Create and activate proper virtual environment"
    verification: "which python && pip list"

  package_installation:
    issue: "Missing or incompatible packages"
    solution: "Install requirements in clean virtual environment"
    verification: "pip install -r requirements.txt"

  api_configuration:
    issue: "API keys not properly configured"
    solution: "Create .env file with all required keys"
    verification: "source .env && env | grep -E '(ELEVENLABS|PERPLEXITY|GITHUB)'"
```

#### System Diagnostic Checklist
```bash
#!/bin/bash
# System readiness diagnostic

echo "=== AI Podcast System Diagnostics ==="

# Check Python environment
echo "1. Python Environment:"
python3 --version
which python3

# Check virtual environment
echo "2. Virtual Environment:"
if [[ "$VIRTUAL_ENV" ]]; then
    echo "✅ Virtual environment active: $VIRTUAL_ENV"
else
    echo "❌ No virtual environment detected"
fi

# Check API keys
echo "3. API Key Configuration:"
if [[ -f .env ]]; then
    echo "✅ .env file exists"
    source .env
    echo "ELEVENLABS_API_KEY: $([ ! -z "$ELEVENLABS_API_KEY" ] && echo 'SET' || echo 'NOT SET')"
    echo "PERPLEXITY_API_KEY: $([ ! -z "$PERPLEXITY_API_KEY" ] && echo 'SET' || echo 'NOT SET')"
    echo "GITHUB_PAT: $([ ! -z "$GITHUB_PAT" ] && echo 'SET' || echo 'NOT SET')"
else
    echo "❌ .env file missing"
fi

# Check Claude Code installation
echo "4. Claude Code:"
if command -v claude &> /dev/null; then
    echo "✅ Claude Code installed"
else
    echo "❌ Claude Code not found"
fi

# Check directory structure
echo "5. Project Structure:"
for dir in .claude/agents .claude/commands .claude/context; do
    if [[ -d "$dir" ]]; then
        echo "✅ $dir exists"
    else
        echo "❌ $dir missing"
    fi
done
```

---

## 🔍 DIAGNOSTIC WORKFLOWS

### Quick MCP Diagnostics
```bash
# Step 1: Check MCP server status
/mcp

# Expected output:
# ⎿ MCP Server Status ⎿
# ⎿ • perplexity-ask: connected ⎿
# ⎿ • ElevenLabs: connected ⎿

# Step 2: Test MCP tools directly
mcp__elevenlabs__check_subscription
mcp__perplexity-ask__perplexity_ask

# Step 3: Verify agent MCP inheritance
# Use Task tool with agent requiring MCP access
```

### Agent Configuration Validation
```bash
# Check agent YAML syntax
python3 -c "
import yaml
import sys
try:
    with open('.claude/agents/audio-synthesizer.md', 'r') as f:
        content = f.read()
    # Extract YAML from markdown
    yaml_start = content.find('```yaml')
    yaml_end = content.find('```', yaml_start + 7)
    yaml_content = content[yaml_start+7:yaml_end]
    yaml.safe_load(yaml_content)
    print('✅ Valid YAML configuration')
except Exception as e:
    print(f'❌ YAML Error: {e}')
"
```

### Performance Monitoring
```yaml
performance_diagnostics:
  system_metrics:
    memory_usage: "Monitor RAM consumption during processing"
    cpu_utilization: "Track processing load during synthesis"
    disk_space: "Ensure adequate storage for audio files"
    network_latency: "Monitor API response times"

  application_metrics:
    api_response_times: "Track ElevenLabs and Perplexity response speeds"
    error_rates: "Monitor failure rates across different operations"
    cost_per_operation: "Track spending efficiency"
    quality_scores: "Monitor output quality consistency"
```

---

## 🛠️ EMERGENCY PROCEDURES

### System Recovery Protocol
```yaml
emergency_recovery:
  mcp_failure_recovery:
    step_1: "Restart Claude Code with proper environment loading"
    step_2: "Verify all API keys accessible to MCP servers"
    step_3: "Test individual MCP tools before agent usage"
    step_4: "Clear any cached configurations that might be corrupted"

  production_halt_recovery:
    step_1: "Identify root cause using diagnostic scripts"
    step_2: "Implement temporary workaround if available"
    step_3: "Execute systematic fix based on issue classification"
    step_4: "Validate fix with comprehensive testing"

  cost_overrun_emergency:
    step_1: "Immediately halt all API operations"
    step_2: "Analyze cost attribution to identify source"
    step_3: "Implement cost controls and budget limits"
    step_4: "Resume operations with enhanced monitoring"
```

This unified troubleshooting guide consolidates all troubleshooting knowledge while providing systematic diagnostic and resolution procedures for all common issues in the AI podcast production system.
