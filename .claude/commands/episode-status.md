---
name: episode-status
description: Check status of specific episodes or show overview
---

# Episode Status - Check Episode Progress

## 🚨 ENHANCED WITH EMPIRICAL VALIDATION - Episode 1 Calibrated

**Date**: August 25, 2025
**Source**: Episode 1 empirical validation - duration, cost, and quality thresholds
**Impact**: All status checks now validate against Episode 1 proven benchmarks

Display episode status with clear indicators for production episodes, including empirical duration validation, cost tracking, and quality threshold verification.

## Usage

```bash
/episode-status              # Show overall status
/episode-status 1           # Show status of episode 1
/episode-status 1-5         # Show status of episodes 1-5
/episode-status test        # Show test episodes status
```

## Implementation

Check if jq is available first:

```bash
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required for episode status checking"
    echo "Install with: brew install jq"
    exit 1
fi
```

### Overall Status Display

```bash
#!/bin/bash
EPISODES_DIR="episodes"

if [ $# -eq 0 ]; then
    echo "🎙️ Nobody Knows Podcast - Episode Status Overview"
    echo "=================================================="
    echo

    # Production episodes overview
    echo "📊 Production Episodes (125 total):"
    TOTAL_DIRS=$(find $EPISODES_DIR/production -name "ep*" -type d | wc -l)

    # Count by status
    NOT_STARTED=$(find $EPISODES_DIR/production -name "status.json" -exec grep -l "not_started" {} \; | wc -l)
    RESEARCHING=$(find $EPISODES_DIR/production -name "status.json" -exec grep -l "researching" {} \; | wc -l)
    RESEARCHED=$(find $EPISODES_DIR/production -name "status.json" -exec grep -l "researched" {} \; | wc -l)
    PRODUCING=$(find $EPISODES_DIR/production -name "status.json" -exec grep -l "producing" {} \; | wc -l)
    COMPLETE=$(find $EPISODES_DIR/production -name "status.json" -exec grep -l "complete" {} \; | wc -l)
    FAILED=$(find $EPISODES_DIR/production -name "status.json" -exec grep -l "failed" {} \; | wc -l)

    echo "  ⚪ Not Started: $NOT_STARTED"
    echo "  🔵 Researching: $RESEARCHING"
    echo "  🟡 Researched: $RESEARCHED"
    echo "  🟠 Producing: $PRODUCING"
    echo "  🟢 Complete: $COMPLETE"
    echo "  🔴 Failed: $FAILED"
    echo

    # Add empirical cost projections
    echo "💰 Cost Analysis (Episode 1 Validated):"
    if [ "$COMPLETE" -gt 0 ]; then
        PROJECTED_TOTAL_COST=$(echo "$COMPLETE * 2.77" | bc -l)
        SERIES_PROJECTED=$(echo "125 * 2.77" | bc -l)
        printf "  Current episodes cost: $%.2f ($COMPLETE × $2.77)\n" $PROJECTED_TOTAL_COST
        printf "  Full series projection: $%.2f (125 × $2.77 - Episode 1 validated)\n" $SERIES_PROJECTED
    else
        echo "  Episode 1 empirical cost: $2.77 per episode validated"
        echo "  Full series projection: $346.25 (125 × $2.77)"
    fi
    echo

    # Test episodes
    echo "🧪 Test Episodes:"
    if [ -f "$EPISODES_DIR/state.json" ]; then
        jq -r '.episodes.test | to_entries[] | "  ✅ " + .key + ": " + .value.status' $EPISODES_DIR/state.json
    fi
    echo

    # Progress bars
    RESEARCHED_PCT=$((($RESEARCHED * 100) / 125))
    COMPLETE_PCT=$((($COMPLETE * 100) / 125))

    echo "📈 Progress:"
    printf "  Research: ["
    for i in $(seq 1 20); do
        if [ $((i * 5)) -le $RESEARCHED_PCT ]; then
            printf "█"
        else
            printf "░"
        fi
    done
    printf "] %d%%\n" $RESEARCHED_PCT

    printf "  Complete: ["
    for i in $(seq 1 20); do
        if [ $((i * 5)) -le $COMPLETE_PCT ]; then
            printf "█"
        else
            printf "░"
        fi
    done
    printf "] %d%% (Target: 125 episodes @ $2.77 each = $346.25)\n" $COMPLETE_PCT

    exit 0
fi
```

### Specific Episode Status

```bash
# Handle specific episode or range
EPISODE_ARG="$1"

if [ "$EPISODE_ARG" = "test" ]; then
    echo "🧪 Test Episodes Status"
    echo "======================"
    if [ -f "$EPISODES_DIR/state.json" ]; then
        jq -r '.episodes.test | to_entries[] | "\(.key):\n  Status: \(.value.status)\n  Description: \(.value.description // "N/A")\n"' $EPISODES_DIR/state.json
    else
        echo "❌ No state.json file found"
    fi
    exit 0
fi

# Handle single episode or range
if [[ "$EPISODE_ARG" == *-* ]]; then
    # Range like "1-5"
    START=$(echo $EPISODE_ARG | cut -d'-' -f1)
    END=$(echo $EPISODE_ARG | cut -d'-' -f2)

    echo "📋 Episodes $START-$END Status"
    echo "============================"

    for i in $(seq $START $END); do
        EP_NUM=$(printf "%03d" $i)
        EP_DIR="$EPISODES_DIR/production/ep$EP_NUM"

        if [ -d "$EP_DIR" ]; then
            if [ -f "$EP_DIR/status.json" ]; then
                STATUS=$(jq -r '.status' $EP_DIR/status.json)
                case $STATUS in
                    "not_started") ICON="⚪" ;;
                    "researching") ICON="🔵" ;;
                    "researched") ICON="🟡" ;;
                    "producing") ICON="🟠" ;;
                    "validating") ICON="🟣" ;;
                    "complete") ICON="🟢" ;;
                    "failed") ICON="🔴" ;;
                    *) ICON="❓" ;;
                esac
                echo "  $ICON ep$EP_NUM: $STATUS"
            else
                echo "  ❓ ep$EP_NUM: no status file"
            fi
        else
            echo "  ❌ ep$EP_NUM: directory not found"
        fi
    done
else
    # Single episode
    EP_NUM=$(printf "%03d" $1)
    EP_DIR="$EPISODES_DIR/production/ep$EP_NUM"

    echo "📄 Episode $1 (ep$EP_NUM) Detailed Status"
    echo "========================================"

    if [ -d "$EP_DIR" ]; then
        if [ -f "$EP_DIR/status.json" ]; then
            echo "📊 Status Information:"
            jq '.' $EP_DIR/status.json
            echo
        fi

        echo "📁 Directory Contents:"
        echo "  Research files: $(find $EP_DIR/research -type f | wc -l)"
        echo "  Production files: $(find $EP_DIR/production -type f | wc -l)"

        if [ -f "$EP_DIR/metrics.json" ]; then
            echo
            echo "💰 Metrics & Empirical Validation:"
            jq '.' $EP_DIR/metrics.json

            # Add empirical validation checks
            COST=$(jq -r '.cost // 0' $EP_DIR/metrics.json)
            if [ "$COST" != "0" ]; then
                if (( $(echo "$COST <= 2.80" | bc -l) )); then
                    echo "  ✅ Cost: $COST (within $2.80 target - Episode 1: $2.77)"
                else
                    echo "  ⚠️ Cost: $COST (above $2.80 target - Episode 1 validated)"
                fi
            fi
        fi

        # Duration validation for complete episodes
        if [ -f "$EP_DIR/production/episode_audio.mp3" ]; then
            echo
            echo "🎧 Audio Validation (Episode 1 Calibrated):"

            # Check if ffprobe is available for duration check
            if command -v ffprobe &> /dev/null; then
                DURATION_SEC=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$EP_DIR/production/episode_audio.mp3" 2>/dev/null | cut -d'.' -f1)
                if [ -n "$DURATION_SEC" ]; then
                    DURATION_MIN=$((DURATION_SEC / 60))
                    REMAINDER_SEC=$((DURATION_SEC % 60))
                    if [ "$DURATION_SEC" -ge 1500 ] && [ "$DURATION_SEC" -le 1800 ]; then
                        echo "  ✅ Duration: ${DURATION_MIN}m ${REMAINDER_SEC}s (25-30 min target achieved)"
                    else
                        echo "  ⚠️ Duration: ${DURATION_MIN}m ${REMAINDER_SEC}s (outside 25-30 min target)"
                    fi
                else
                    echo "  ❓ Duration: Unable to determine audio duration"
                fi
            else
                echo "  📎 Install ffprobe for audio duration validation: brew install ffmpeg"
            fi
        fi

        # Script validation for word count
        if [ -f "$EP_DIR/production/script_final.md" ]; then
            WORD_COUNT=$(wc -w < "$EP_DIR/production/script_final.md")
            echo
            echo "📝 Script Validation (Episode 1 Calibrated):"
            if [ "$WORD_COUNT" -ge 3200 ] && [ "$WORD_COUNT" -le 3600 ]; then
                echo "  ✅ Word Count: $WORD_COUNT (3,200-3,600 target for 25-30 min @ 206 WPM)"
            else
                echo "  ⚠️ Word Count: $WORD_COUNT (outside 3,200-3,600 target range)"
            fi
        fi

        # Show from master state if available
        if [ -f "$EPISODES_DIR/state.json" ]; then
            EP_STATE=$(jq ".episodes.production.ep$EP_NUM // null" $EPISODES_DIR/state.json)
            if [ "$EP_STATE" != "null" ]; then
                echo
                echo "🏛️ Master State:"
                echo $EP_STATE | jq '.'
            fi
        fi
    else
        echo "❌ Episode directory not found: $EP_DIR"
        exit 1
    fi
fi
```

## Examples

Check overall status:
```bash
/episode-status
```

Check specific episode:
```bash
/episode-status 1
```

Check episode range:
```bash
/episode-status 1-10
```

Check test episodes:
```bash
/episode-status test
```
