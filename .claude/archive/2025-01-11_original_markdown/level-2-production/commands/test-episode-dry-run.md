# Test Episode Dry Run Command

**Purpose**: Test the complete podcast production pipeline using mock data without any API calls or costs.

## Command Overview

You are the Dry Run Test Orchestrator for "Nobody Knows" podcast. Execute a complete production simulation using mock data to validate workflows before real API usage.

## Configuration
- **Mock Data Location**: `.claude/test-data/`
- **Cost**: $0.00 (no API calls)
- **Duration**: ~5 minutes (no actual processing)
- **Purpose**: Workflow validation and testing

## Dry Run Process

### Step 1: Initialize Test Session
```yaml
session_id: "test_ep_{number}_{YYYYMMDD}_{HHMM}"
episode_number: {provided or 999}
topic: {provided or "Test Topic"}
mode: "DRY_RUN"
status: "initialized"
```

Save to: `projects/nobody-knows/output/sessions/test_ep{number}_session_{date}.json`

### Step 2: Simulate Research Phase

**Instead of calling Perplexity MCP**:
```python
# Load mock research data
mock_research = Read(".claude/test-data/mock-research.md")

# Simulate API call
print("🔍 [DRY RUN] Simulating Perplexity research...")
print("   - Would call: perplexity_ask")
print("   - Estimated cost: $2.50")
print("   - Estimated time: 20 minutes")

# Use mock data
research_output = mock_research
```

**Output**: Copy mock-research.md to output directory with proper naming

### Step 3: Simulate Script Writing

**Instead of using Claude native**:
```python
# Load mock script
mock_script = Read(".claude/test-data/mock-script.md")

# Simulate processing
print("✍️ [DRY RUN] Simulating script generation...")
print("   - Would use: Claude native processing")
print("   - Estimated cost: $1.00")
print("   - Estimated time: 15 minutes")

# Use mock data
script_output = mock_script
```

**Output**: Copy mock-script.md to output directory

### Step 4: Simulate Quality Evaluation

**Instead of quality evaluation**:
```python
# Load mock quality data
mock_quality = Read(".claude/test-data/mock-quality.json")

# Simulate evaluation
print("✅ [DRY RUN] Simulating quality evaluation...")
print("   - Would use: Claude native evaluation")
print("   - Estimated cost: $0.50")
print("   - Estimated time: 5 minutes")

# Use mock data
quality_output = mock_quality
```

**Output**: Copy mock-quality.json to output directory

### Step 5: Simulate Audio Synthesis

**Instead of calling ElevenLabs MCP**:
```python
# Simulate audio generation
print("🎙️ [DRY RUN] Simulating audio synthesis...")
print("   - Would call: text_to_speech")
print("   - Voice: Rachel")
print("   - Estimated cost: $1.75")
print("   - Estimated time: 10 minutes")
print("   - Output: ep{number}_{topic}_audio.mp3")

# Create placeholder file
placeholder_content = "This is a placeholder for audio file\nActual audio would be ~25MB MP3"
Write("projects/nobody-knows/output/audio/ep{number}_DRYRUN.txt", placeholder_content)
```

**Output**: Create placeholder file indicating where audio would be

### Step 6: Generate Dry Run Report

```json
{
  "mode": "DRY_RUN",
  "status": "SUCCESS",
  "episode_number": 999,
  "topic": "Test Topic",

  "simulated_outputs": {
    "research": "projects/nobody-knows/output/research/test_research.md",
    "script": "projects/nobody-knows/output/scripts/test_script.md",
    "quality": "projects/nobody-knows/output/quality/test_quality.json",
    "audio": "projects/nobody-knows/output/audio/test_audio_placeholder.txt"
  },

  "simulated_metrics": {
    "total_time_minutes": 50,
    "total_cost": 5.75,
    "quality_score": 0.88,
    "workflow_validated": true
  },

  "api_calls_that_would_be_made": [
    {
      "tool": "perplexity_ask",
      "count": 4,
      "estimated_cost": 2.50
    },
    {
      "tool": "text_to_speech",
      "count": 1,
      "estimated_cost": 1.75
    }
  ],

  "validation_results": {
    "research_agent": "✓ Ready",
    "script_writer": "✓ Ready",
    "quality_evaluator": "✓ Ready",
    "audio_synthesizer": "✓ Ready",
    "workflow_chain": "✓ Valid"
  }
}
```

## Usage Examples

### Basic Dry Run
```bash
Command: test-episode-dry-run
Result: Full simulation with default test topic
```

### Specific Topic Dry Run
```bash
Command: test-episode-dry-run --topic "quantum computing" --episode 42
Result: Simulation with specified topic and episode number
```

### Validate Specific Agent
```bash
Command: test-episode-dry-run --agent research-only
Result: Test only research phase
```

## Success Indicators

### Green Flags ✅
- All agents load successfully
- Mock data flows through pipeline
- Output directories are accessible
- Session tracking works
- File naming is correct

### Red Flags ❌
- Missing dependencies
- Permission errors
- Incorrect file paths
- Agent configuration issues
- Workflow breaks

## Dry Run Benefits

1. **Zero Cost Testing**: Validate everything without spending money
2. **Fast Iteration**: 5-minute tests vs 50-minute production
3. **Error Detection**: Find issues before they cost API credits
4. **Workflow Validation**: Ensure all pieces connect properly
5. **Learning Tool**: Understand the pipeline without risk

## Output Example

```
🚀 Starting DRY RUN for Episode 999: "Test Topic"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/5] 🔍 Research Phase (DRY RUN)
   ✓ Mock research loaded
   ✓ Would cost: $2.50
   ✓ Output: test_research.md

[2/5] ✍️ Script Writing (DRY RUN)
   ✓ Mock script loaded
   ✓ Would cost: $1.00
   ✓ Output: test_script.md

[3/5] ✅ Quality Check (DRY RUN)
   ✓ Mock quality data loaded
   ✓ Score: 0.88 (PASS)
   ✓ Output: test_quality.json

[4/5] 🎙️ Audio Synthesis (DRY RUN)
   ✓ Audio simulation complete
   ✓ Would cost: $1.75
   ✓ Placeholder: test_audio_placeholder.txt

[5/5] 📊 Summary
   ✓ All phases validated
   ✓ Estimated total cost: $5.75
   ✓ Estimated total time: 50 minutes
   ✓ Ready for production!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ DRY RUN COMPLETE - System ready for production
```

## Next Steps After Successful Dry Run

1. Review the generated test outputs
2. Verify file paths and naming conventions
3. Check session data structure
4. Confirm workflow sequence
5. Proceed to real episode production with confidence!
