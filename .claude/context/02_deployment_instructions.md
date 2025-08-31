# Deployment Instructions - AI Podcast Production System

**Created**: 2025-08-27
**System Phase**: Production Ready - Runtime Validation Required
**Critical Requirement**: Proper Environment Initialization

## 🚨 CRITICAL DEPLOYMENT REQUIREMENTS

### MANDATORY Environment Initialization
The current Claude Code session **cannot access MCP tools** due to environment variable loading issues. Production deployment **requires proper startup**.

```bash
# REQUIRED BEFORE ANY PRODUCTION TESTING
cd /Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows
./build/scripts/start-claude.sh
```

**Why This Is Critical**:
- Current session: ElevenLabs tools return 401 authentication errors
- API keys not loaded: Environment variables missing in MCP context
- Production blocked: Cannot synthesize audio without proper authentication
- Solution validated: `build/scripts/start-claude.sh` properly loads all required environment variables

## 🎯 POST-RESTART DEPLOYMENT PROTOCOL

### Phase 1: Environment Validation (First 5 Minutes)
```bash
# Test 1: Verify MCP Authentication
Direct API: api.check_subscription() using lib.elevenlabs_direct
# Expected: Subscription data returned (NOT 401 error)

# Test 2: Confirm Production Voice Access
Direct API: api.get_voice_info('ZF6FPAbjXT4488VcRRnw') using lib.elevenlabs_direct
# Expected: Voice metadata for Amelia production voice

# Test 3: Validate Agent MCP Inheritance
# Use Task tool with agent that requires MCP access
# Expected: Agent can access inherited MCP tools
```

### Phase 2: Production Validation Test (60-90 Minutes)
```bash
# Execute Complete Production Pipeline
/produce-episode-enhanced "Quantum Entanglement Basics - What Nobody Knows"

# Monitor Throughout Execution:
# - Phase-by-phase cost accumulation
# - Quality gate validation at each step
# - Brand voice alignment scoring
# - Audio synthesis quality
```

### Phase 3: Success Validation (15 Minutes)
```yaml
validation_checklist:
  functional_success:
    - Complete episode MP3 generated
    - All 6 production phases executed without errors
    - Episode duration: 47 minutes ±2 minutes
    - Audio quality: -16 LUFS professional standard

  cost_optimization:
    - Total cost ≤ $5.51 (target achievement)
    - Cost breakdown by phase documented
    - Enhanced tracking hooks captured all spending

  quality_assurance:
    - Brand voice alignment ≥85%
    - Three-evaluator consensus achieved
    - Intellectual humility philosophy preserved
    - Professional audio quality validated

  compliance_verification:
    - Zero CLAUDE.md protocol violations
    - Production voice configuration unchanged
    - DRY enforcement maintained
    - All quality gates passed
```

## 📁 DEPLOYMENT FILE STRUCTURE

### Required Files (All Present and Validated)
```
/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/
├── .env                          # API keys (51-53 char lengths validated)
├── build/scripts/start-claude.sh  # Environment loading script (executable)
├── .claude/
│   ├── settings.json            # MCP tool permissions (22 ElevenLabs tools)
│   ├── config/
│   │   └── production-voice.json # Locked voice configuration
│   ├── agents/                  # 18 specialized agents (all validated)
│   ├── commands/
│   │   └── produce-episode-enhanced.md # Complete production workflow
│   ├── hooks/
│   │   ├── enhanced-pre-tool-cost-validation.sh
│   │   └── enhanced-post-tool-cost-tracking.sh
│   └── tests/
│       └── test_system_readiness_comprehensive.sh # 21 tests (100% pass)
```

### Episode Output Structure (Will Be Created)
```
sessions/
└── ep_quantum_entanglement_YYYYMMDD_HHMMSS/
    ├── production/
    │   ├── episode_plan.json
    │   ├── script_final.md
    │   ├── quality_consensus_report.json
    │   └── audio_synthesis_results.json
    └── quantum_entanglement_episode.mp3  # Final professional audio
```

## 🔍 DEPLOYMENT MONITORING

### Real-Time Monitoring Points
1. **Cost Accumulation**: Enhanced hooks provide real-time spending updates
2. **Quality Scoring**: Three-evaluator consensus with confidence metrics
3. **Brand Alignment**: Intellectual humility consistency tracking
4. **Audio Quality**: Professional standards validation throughout synthesis
5. **Error Detection**: Immediate notification of any system failures

### Success Indicators During Execution
```yaml
phase_monitoring:
  phase_1_research:
    indicator: "Comprehensive research package generated"
    time_estimate: "15-20 minutes"
    cost_target: "≤ $2.50"

  phase_2_script:
    indicator: "Script with brand voice consistency ≥85%"
    time_estimate: "10-15 minutes"
    cost_target: "≤ $1.75"

  phase_3_quality:
    indicator: "Three-evaluator consensus achieved"
    time_estimate: "10-15 minutes"
    cost_target: "≤ $1.50"

  phase_4_audio:
    indicator: "Professional MP3 generated (-16 LUFS)"
    time_estimate: "15-25 minutes"
    cost_target: "≤ $7.25"
```

## ⚠️ TROUBLESHOOTING GUIDE

### If MCP Tools Still Return 401 Errors Post-Restart
1. **Verify Environment Loading**: Check that `source .env` executed successfully in startup script
2. **Validate API Keys**: Ensure keys are 50+ characters and properly formatted
3. **Check MCP Configuration**: Confirm `.claude/settings.json` has proper MCP permissions
4. **Test Outside Claude**: Use direct API calls to validate key functionality

### If Production Command Fails
1. **Agent Access**: Verify all 18 agents respond to Task tool invocations
2. **File Permissions**: Ensure all scripts are executable and accessible
3. **Directory Structure**: Confirm episode directories exist and are writable
4. **Resource Availability**: Check system resources and network connectivity

### If Cost Exceeds $5.51 Target
1. **Cost Analysis**: Review enhanced tracking hook outputs for cost breakdown
2. **Phase Optimization**: Identify which phases exceeded budget allocation
3. **Parameter Tuning**: Adjust complexity or quality parameters if necessary
4. **Retry Strategy**: Consider re-execution with optimized parameters

## 🎯 SUCCESS METRICS AND CERTIFICATION

### Production Deployment Success Criteria
- [x] **Infrastructure Ready**: 100% system validation complete
- [ ] **Runtime Validated**: MCP tools functional post-restart
- [ ] **Episode Generated**: Complete professional audio produced
- [ ] **Cost Optimized**: Production ≤ $5.51 achieved
- [ ] **Quality Maintained**: ≥85% brand voice alignment
- [ ] **Standards Met**: All professional audio and compliance requirements

### Post-Deployment Actions
1. **System Certification**: Document successful production capability
2. **Performance Analysis**: Analyze cost and quality optimization achieved
3. **Scaling Validation**: Prepare for multi-episode production testing
4. **Documentation Update**: Complete deployment records and lessons learned

This deployment protocol ensures systematic validation of the production-ready AI podcast system while maintaining all quality, cost, and compliance requirements.
