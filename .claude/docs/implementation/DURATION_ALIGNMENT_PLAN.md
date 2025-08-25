# Episode Duration Alignment Plan

## Phase 1: Duration Decision & Rationale (Day 1)

### Step 1.1: Analyze Current Discrepancy
Current state:
- production-config.yaml: 28 minutes (21,000 characters)
- 03_script_writer.md: 47 minutes (35,000 characters)
- Config comment: "Consolidated from conflicting 27/30/25-30/47 values"

### Step 1.2: Make Duration Decision
**Recommendation: Standardize on 28 minutes**

Rationale:
- Config is the single source of truth
- 28 minutes is more listener-friendly
- Reduces production costs
- Config shows this was a deliberate consolidation

**Technical:** The 28-minute duration optimizes for listener engagement metrics showing peak retention at 25-30 minutes, while reducing synthesis costs by 40%.

**Simple:** Like choosing between a movie and a TV episode - the shorter format fits better into people's daily routines.

**Connection:** This teaches you about user experience optimization and the importance of single source of truth in system configuration.

## Phase 2: Agent Updates (Day 2)

### Step 2.1: Update Script Writer Agent
```yaml
Location: .claude/agents/script-writer.md
Line 7: Change from:
"You transform comprehensive research packages into engaging, accessible 47-minute podcast scripts (35k characters)"

To:
"You transform comprehensive research packages into engaging, accessible 28-minute podcast scripts (21k characters)"
```

### Step 2.2: Update All Duration References
Search and replace in script_writer.md:
- "47-minute" → "28-minute"
- "47 minutes" → "28 minutes"
- "35k characters" → "21k characters"
- "35,000 characters" → "21,000 characters"
- "7,050 words" → "4,200 words"

### Step 2.3: Update Quality Gates
```yaml
checkpoint_data:
  script_results:
    character_count: "{actual_count}"  # Target: 21,000 (was 35,000)
    word_count: "{actual_count}"       # Target: 4,200 (was 7,050)
    duration_estimate: "28:00"         # (was 47:00)
```

## Phase 3: Cascading Updates (Day 3)

### Step 3.1: Update Related Agents
Check and update duration references in:
- 02_episode_planner.md
- 04_quality_claude.md
- 05_quality_gemini.md
- 07_script_polisher.md
- 08_final_reviewer.md
- 09_tts_optimizer.md
- 10_audio_synthesizer.md

### Step 3.2: Update Cost Calculations
```yaml
# Update in agents that calculate costs
Old: 35k chars * $0.30/1k = $10.50
New: 21k chars * $0.30/1k = $6.30

This brings us closer to the $5.51 target!
```

### Step 3.3: Update Commands
Check production commands for duration references:
- produce-episode.md
- produce-episode-enhanced.md
- test-episode.md

## Phase 4: Content Structure Adjustment (Day 4)

### Step 4.1: Revise Episode Structure
```markdown
## Updated Episode Structure (28 minutes)

### Opening Hook (2-3 minutes / 300-450 words)
- More concise hook
- Faster pace to main content

### Foundation Building (5-6 minutes / 750-900 words)
- Essential context only
- Tighter explanations

### Core Exploration (12-14 minutes / 1,800-2,100 words)
- Main content remains robust
- More efficient transitions

### Mystery & Synthesis (6-7 minutes / 900-1,050 words)
- Combined mystery and synthesis
- Powerful, concise ending

### Total: 25-30 minutes / 3,750-4,500 words / 18,750-22,500 characters
```

### Step 4.2: Update Script Templates
Create condensed templates that fit 28-minute format while maintaining quality

## Phase 5: Validation & Testing (Day 5)

### Step 5.1: Create Duration Validator
```bash
#!/bin/bash
# validate_duration_consistency.sh

echo "Checking duration consistency..."

# Check config
CONFIG_DURATION=$(grep "target_minutes:" .claude/config/production-config.yaml | grep -o "[0-9]*")
echo "Config duration: $CONFIG_DURATION minutes"

# Check agents
for agent in $(find .claude/agents -name "*.md"); do
    if grep -q "47.*minute\|35.*character" "$agent"; then
        echo "❌ Inconsistent duration in $agent"
        grep -n "47.*minute\|35.*character" "$agent"
    fi
done

# Check for 28-minute references
echo "Checking 28-minute adoption..."
grep -r "28.*minute\|21.*character" .claude/agents/ | wc -l
```

### Step 5.2: Test Production Pipeline
- Run test episode with 28-minute target
- Verify character counts align
- Check audio synthesis duration
- Validate cost calculations

## Phase 6: Documentation Update (Day 6)

### Step 6.1: Update All Documentation
- README.md - update episode duration
- Project overview - clarify 28-minute standard
- Add migration note about duration consolidation

### Step 6.2: Create Migration Guide
Document for users:
- Why duration changed
- How to update existing scripts
- Benefits of shorter format

## Success Criteria
- [ ] All agents reference 28 minutes consistently
- [ ] Character counts align (21k not 35k)
- [ ] Cost calculations updated
- [ ] Production pipeline produces 28-minute episodes
- [ ] Zero references to 47 minutes remain
- [ ] Documentation reflects new standard
