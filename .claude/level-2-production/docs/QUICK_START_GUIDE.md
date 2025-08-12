# 🚀 Quick Start Guide - Nobody Knows Podcast

**Technical:** Step-by-step production system initialization and episode generation workflow  
**Simple:** Like a recipe to make your first podcast - follow the steps and you'll have an episode  
**Connection:** This teaches systematic project setup and production pipeline execution

## Prerequisites

### Environment Requirements
- **Python 3.8+** (for dependency management)
- **Git** (for version control and atomic commits)
- **1GB+ free disk space** (for episode outputs and sessions)
- **Text editor** (for configuration edits)

### API Keys Setup
1. Copy environment template:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your API keys:
   ```bash
   # Required for research
   PERPLEXITY_API_KEY=your_key_here

   # Optional for audio synthesis
   ELEVENLABS_API_KEY=your_key_here
   ```

**Technical:** Environment separation prevents API key exposure and enables configuration flexibility  
**Simple:** Like keeping your house keys separate from work keys - each has its purpose  
**Connection:** This teaches secure credential management and environment configuration

## Quick Start (5 minutes)

### Step 1: Validate System Readiness
```bash
# Run comprehensive validation
.claude/level-2-production/tests/test-all-scripts.sh

# Expected: Pass rate >50% (some failures expected without API keys)
```

### Step 2: Test MCP Connectivity
```bash
# Test Perplexity connection
claude mcp add perplexity

# Verify research capability
echo "Test research query" | claude research "AI podcast topics"
```

### Step 3: Run Pre-Production Check
```bash
# Validate production readiness
.claude/hooks/pre-production.sh

# Fix any issues reported before continuing
```

### Step 4: Test Episode Production
```bash
# Run dry run test
.claude/level-2-production/commands/test-episode-dry-run.md

# Monitor session state in:
# .claude/level-2-production/sessions/active/
```

## Production Workflow

### Episode Production Steps
1. **Initialize Episode Session**
   ```bash
   # Create episode session
   episode_id="ep_001_$(date +%Y%m%d_%H%M)"
   mkdir -p .claude/level-2-production/sessions/active/$episode_id
   ```

2. **Configure Episode Parameters**
   ```bash
   # Edit episode configuration
   cp .claude/level-2-production/config/episode-config.yaml \
      .claude/level-2-production/sessions/active/$episode_id/config.yaml
   
   # Customize complexity level, topic, length
   ```

3. **Execute Production Pipeline**
   ```bash
   # Run full 9-agent pipeline
   .claude/level-2-production/commands/produce-episode.md $episode_id
   
   # Monitor progress:
   tail -f .claude/level-2-production/sessions/active/$episode_id/state.json
   ```

4. **Quality Validation**
   ```bash
   # Check quality gates passed
   .claude/level-2-production/tools/brand-detector.sh \
     .claude/level-2-production/sessions/active/$episode_id/final_script.md
   
   # Scores should be >8% intellectual humility
   ```

5. **Session Completion**
   ```bash
   # Auto-triggered session summary
   .claude/hooks/session-complete.sh
   
   # Review summary in:
   # .claude/sessions/summaries/session_${timestamp}_summary.md
   ```

**Technical:** Pipeline orchestration with state management and quality gates ensures reliable production  
**Simple:** Like an assembly line with quality checkpoints - each step validates before moving forward  
**Connection:** This teaches production system design and automated quality assurance

## Cost Management

### Monitor Episode Costs
```bash
# Check current costs
.claude/level-2-production/tools/analyze_sessions.py --cost-summary

# Target: <$5 per episode
# Alert: >$5 indicates optimization needed
```

### Cost Optimization
```bash
# Review token usage patterns
.claude/level-2-production/tools/export_metrics.py --tokens

# Optimize prompts if costs exceed thresholds
```

## Troubleshooting

### Common Issues

#### "MCP Connection Failed"
```bash
# Check API key configuration
echo $PERPLEXITY_API_KEY | cut -c1-10  # Should show key prefix

# Restart MCP server
claude mcp restart perplexity
```

#### "Tests Failing"
```bash
# Run individual test components
.claude/level-2-production/tools/brand-detector.sh test_script.md
.claude/level-2-production/tools/error-detector.sh

# Check logs for specific errors
```

#### "Session Recovery"
```bash
# Recover failed session
.claude/level-2-production/tools/recovery-helper.sh $episode_id

# Review recovery options and continue from checkpoint
```

#### "Git Issues"
```bash
# Check repo status
git status

# Use git recovery reference
.claude/level-2-production/docs/GIT_RECOVERY_COMMANDS.md
```

## Quality Gates Reference

### Brand Voice Requirements
- **Intellectual Humility**: >8% of text
- **Question Density**: >3 questions per 1000 words
- **Overconfidence**: <2 absolute statements
- **Wonder Expressions**: "I wonder", "Perhaps", "What if"

### Technical Quality Thresholds
- **Comprehension**: >0.85 (general audience understanding)
- **Brand Consistency**: >0.90 (intellectual humility alignment)  
- **Engagement**: >0.80 (audience interest maintenance)
- **Technical Accuracy**: >0.85 (factual correctness)

**Technical:** Quantified quality metrics enable automated decision making and consistent standards  
**Simple:** Like having a grading rubric - you know exactly what makes a good episode  
**Connection:** This teaches quality assurance methodology and automated validation systems

## File Structure Reference

```
.claude/level-2-production/
├── agents/           # 9-agent pipeline definitions
├── commands/         # Production workflow commands
├── config/           # System configuration files
├── sessions/         # Episode production sessions
│   ├── active/       # Current productions
│   ├── completed/    # Finished episodes
│   └── failed/       # Error recovery
├── tools/            # Utility scripts and analyzers
├── tests/            # Validation and testing suite
└── docs/             # Documentation (this file)

.claude/hooks/        # Automated validation hooks
├── pre-production.sh    # System readiness check
├── session-complete.sh  # Auto-commit and summary
└── pre-commit-quality.sh # Quality validation

projects/nobody-knows/
├── output/           # Final episode outputs
└── config/           # Episode-specific configs
```

## Next Steps

### After First Episode
1. **Review Cost Analysis** - Optimize if >$5
2. **Quality Assessment** - Review brand voice scores  
3. **Batch Production** - Scale to multiple episodes
4. **Advanced Features** - Explore custom prompts and voices

### Advanced Usage
- **Custom Agents**: Modify `.claude/level-2-production/agents/`
- **Quality Tuning**: Adjust `.claude/level-2-production/config/quality-thresholds.yaml`
- **Batch Processing**: Use `.claude/level-2-production/commands/batch-produce.md`
- **Season Planning**: Configure episode series in `projects/nobody-knows/`

**Technical:** Progressive complexity introduction enables skill development and system mastery  
**Simple:** Like learning to drive - start in parking lot, then streets, then highway  
**Connection:** This teaches incremental learning and capability building

## Support

- **Documentation**: `@context/operations/01_troubleshooting_guide.xml`
- **Quality Issues**: `@context/quality/ENFORCEMENT_STANDARDS.xml`  
- **Git Problems**: `.claude/level-2-production/docs/GIT_WORKFLOW_GUIDE.md`
- **System Issues**: Run `.claude/level-2-production/tests/test-all-scripts.sh`

---

**Version**: Phase 3 Production Ready | **Updated**: 2025-08-12 | **Pass Rate**: 52%+ expected