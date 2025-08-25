# Simplified Hook Architecture

## Overview
Reduced from 30+ hooks to 5 essential hooks that provide core functionality without over-engineering.

## Essential Hooks (5)

### 1. Pre-Tool Cost Validation (`pre-tool-cost-validation.sh`)
- **Purpose**: Prevent budget overruns before expensive operations
- **Event**: PreToolUse
- **Key Features**:
  - Validates estimated cost against budget limit ($33.25)
  - Blocks operations that would exceed budget
  - Simple cost estimation based on tool type

### 2. Post-Tool Cost Tracking (`post-tool-cost-tracking.sh`)
- **Purpose**: Track actual costs after operations complete
- **Event**: PostToolUse
- **Key Features**:
  - Records actual token usage and costs
  - Updates daily cost summary
  - Warns when approaching budget limits

### 3. Session Cleanup (`session-cleanup.sh`)
- **Purpose**: Clean up and summarize when session ends
- **Event**: Stop
- **Key Features**:
  - Generates session cost summary
  - Archives session data
  - Cleans up old logs (7+ days)

### 4. Error Recovery Handler (`error-recovery-handler.sh`)
- **Purpose**: Handle failures gracefully
- **Event**: Error
- **Key Features**:
  - Logs error details
  - Suggests recovery actions
  - Creates recovery checkpoints

### 5. User Prompt Submit (`user-prompt-submit.sh`)
- **Purpose**: Basic input validation and cost estimation
- **Event**: UserPromptSubmit
- **Key Features**:
  - Analyzes prompt for cost implications
  - Warns about high-cost operations
  - Simple risk assessment

## Key Improvements

### Simplified Architecture
- **Before**: 30+ hooks with overlapping functionality
- **After**: 5 focused hooks with clear responsibilities
- **Benefit**: 83% reduction in complexity

### Robust Path Handling
All hooks use absolute paths with hardcoded project root:
```bash
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true
```

### Arithmetic Without bc
Replaced bc with awk for arithmetic to avoid JSON parsing errors:
```bash
# Old (causes errors)
cost=$(echo "$tokens * 0.001" | bc -l)

# New (works reliably)
cost=$(awk "BEGIN {print $tokens * 0.001}")
```

### Minimal Dependencies
- No jq required (basic text processing only)
- No complex state management
- No redundant JSON processing

## Archived Hooks (25+)
Moved to `.claude/hooks_archive/` - includes:
- Redundant cost tracking variations
- Overly complex JSON validators
- Unnecessary monitoring hooks
- Duplicate quality checkers
- Enterprise-level features not needed

## Settings Configuration
Updated `.claude/settings.json` to reference only essential hooks:
```json
{
  "hooks": {
    "PreToolUse": [{"command": ".claude/hooks/pre-tool-cost-validation.sh"}],
    "PostToolUse": [{"command": ".claude/hooks/post-tool-cost-tracking.sh"}],
    "UserPromptSubmit": [{"command": ".claude/hooks/user-prompt-submit.sh"}],
    "Stop": [{"command": ".claude/hooks/session-cleanup.sh"}],
    "Error": [{"command": ".claude/hooks/error-recovery-handler.sh"}]
  }
}
```

## Testing Results
✅ All 5 hooks pass syntax validation
✅ Hooks work from any directory
✅ No permission errors
✅ No getcwd errors
✅ Clean JSON output

## Maintenance Guidelines
1. **Keep it simple**: Resist adding complexity
2. **Test from different directories**: Ensure absolute paths work
3. **Avoid bc for arithmetic**: Use awk instead
4. **Log sparingly**: Only essential information
5. **No feature creep**: Maintain the 5-hook limit

## Cost Savings
- **Development time**: Reduced from hours to minutes for hook issues
- **Debugging time**: Clear, simple hooks are easy to fix
- **Maintenance burden**: 83% less code to maintain
- **Cognitive load**: Easy to understand entire system

## Conclusion
The simplified 5-hook system provides all essential functionality while eliminating the complexity that was causing persistent errors. This follows the "Nobody Knows" philosophy: elegant simplicity over enterprise complexity.
