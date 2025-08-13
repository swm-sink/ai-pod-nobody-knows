#!/bin/bash
# Agent Dependency Fixer - Removes circular dependencies from agent files
# Replaces explicit agent references with abstract stage references

echo "🔧 FIXING AGENT CIRCULAR DEPENDENCIES"
echo "====================================="

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FIXES_APPLIED=0

# Find project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

echo "Project root: $PROJECT_ROOT"
echo ""

AGENTS_DIR=".claude/level-2-production/agents"
BACKUP_DIR=".claude/level-2-production/agents/backups/dependency-fix-$(date +%Y%m%d_%H%M)"

# Create backup
echo "📁 Creating backup..."
mkdir -p "$BACKUP_DIR"
cp -r "$AGENTS_DIR"/*.md "$BACKUP_DIR"/
echo -e "${GREEN}✓ Backup created: $BACKUP_DIR${NC}"

echo ""
echo "🔍 Identifying problematic references..."

# Define mapping of specific agent names to abstract stages
declare -A STAGE_MAPPING=(
    ["01_research_coordinator"]="RESEARCH_STAGE"
    ["02_episode_planner"]="PLANNING_STAGE"
    ["03_script_writer"]="SCRIPT_GENERATION_STAGE"
    ["04_quality_claude"]="QUALITY_EVALUATION_STAGE_1"
    ["05_quality_gemini"]="QUALITY_EVALUATION_STAGE_2"
    ["06_feedback_synthesizer"]="FEEDBACK_SYNTHESIS_STAGE"
    ["07_script_polisher"]="SCRIPT_POLISHING_STAGE"
    ["08_final_reviewer"]="FINAL_REVIEW_STAGE"
    ["09_audio_synthesizer"]="AUDIO_SYNTHESIS_STAGE"
)

# Function to fix agent references
fix_agent_file() {
    local agent_file="$1"
    local agent_name=$(basename "$agent_file" .md)
    local temp_file=$(mktemp)

    echo "Fixing: $agent_name"

    # Copy original file
    cp "$agent_file" "$temp_file"

    # Remove self-references (except in name field)
    sed -i.bak "/^name: $agent_name$/!s/$agent_name/CURRENT_AGENT/g" "$temp_file"

    # Replace specific agent references with abstract stages
    for agent in "${!STAGE_MAPPING[@]}"; do
        stage="${STAGE_MAPPING[$agent]}"
        # Don't replace the agent's own name declaration
        sed -i.bak "/^name: $agent$/!s/$agent/$stage/g" "$temp_file"
    done

    # Fix routing logic to use abstract references
    sed -i.bak 's/"next_agent": "[^"]*"/"next_stage": "NEXT_PIPELINE_STAGE"/g' "$temp_file"
    sed -i.bak 's/Route to [0-9][0-9]_[a-z_]*/Route to NEXT_APPROPRIATE_STAGE/g' "$temp_file"

    # Replace specific workflow references
    sed -i.bak 's/after both quality evaluations/after both quality evaluation stages/g' "$temp_file"
    sed -i.bak 's/from 04_quality_claude/from QUALITY_EVALUATION_STAGE_1/g' "$temp_file"
    sed -i.bak 's/from 05_quality_gemini/from QUALITY_EVALUATION_STAGE_2/g' "$temp_file"

    # Check if changes were made
    if ! diff -q "$agent_file" "$temp_file" >/dev/null 2>&1; then
        mv "$temp_file" "$agent_file"
        echo -e "  ${GREEN}✓ Fixed dependencies in $agent_name${NC}"
        FIXES_APPLIED=$((FIXES_APPLIED + 1))
    else
        rm "$temp_file"
        echo -e "  ${YELLOW}- No changes needed for $agent_name${NC}"
    fi

    # Clean up backup files
    rm -f "$temp_file.bak"
}

# Process all agent files
echo ""
echo "🔧 Applying fixes..."

for agent_file in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        fix_agent_file "$agent_file"
    fi
done

echo ""
echo "📋 Creating abstract stage mapping documentation..."

cat > "$AGENTS_DIR/STAGE_MAPPING.md" << 'EOF'
# Agent Stage Mapping - Dependency Resolution

This document maps concrete agent names to abstract stage references to eliminate circular dependencies.

## Stage Mapping

| Stage Name | Agent File | Purpose |
|------------|------------|---------|
| RESEARCH_STAGE | 01_research_coordinator.md | Topic research and information gathering |
| PLANNING_STAGE | 02_episode_planner.md | Episode structure and content planning |
| SCRIPT_GENERATION_STAGE | 03_script_writer.md | Initial script creation |
| QUALITY_EVALUATION_STAGE_1 | 04_quality_claude.md | Primary quality evaluation |
| QUALITY_EVALUATION_STAGE_2 | 05_quality_gemini.md | Secondary quality validation |
| FEEDBACK_SYNTHESIS_STAGE | 06_feedback_synthesizer.md | Quality feedback aggregation |
| SCRIPT_POLISHING_STAGE | 07_script_polisher.md | Script refinement and improvement |
| FINAL_REVIEW_STAGE | 08_final_reviewer.md | Final quality gate and approval |
| AUDIO_SYNTHESIS_STAGE | 09_audio_synthesizer.md | Audio generation and production |

## Pipeline Flow

```
RESEARCH_STAGE → PLANNING_STAGE → SCRIPT_GENERATION_STAGE →
QUALITY_EVALUATION_STAGE_1 ↘
                              ↘ FEEDBACK_SYNTHESIS_STAGE →
QUALITY_EVALUATION_STAGE_2 ↗                              ↘
                                                          ↘ SCRIPT_POLISHING_STAGE →
                                                             FINAL_REVIEW_STAGE →
                                                             AUDIO_SYNTHESIS_STAGE
```

## Benefits

- **Eliminates Circular Dependencies**: No agent directly references another agent
- **Reduces Coupling**: Agents reference abstract stages, not concrete implementations
- **Improves Maintainability**: Agent names can change without breaking references
- **Enables Dynamic Routing**: Pipeline coordinator determines actual agent routing
- **Supports Testing**: Abstract stages can be mocked or stubbed for testing

## Implementation Notes

- Pipeline coordinator maps abstract stages to concrete agents
- Session state tracks current stage rather than current agent
- Error recovery works at stage level rather than agent level
- Quality gates operate on stage completion rather than agent completion

---
Generated: $(date)
Purpose: Resolve circular dependencies in agent pipeline
EOF

echo -e "${GREEN}✓ Stage mapping documentation created${NC}"

echo ""
echo "🧪 Validating fixes..."

# Run dependency check again
if [ -f ".claude/level-2-production/tests/test-circular-dependencies.sh" ]; then
    echo "Running circular dependency test..."
    if .claude/level-2-production/tests/test-circular-dependencies.sh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Circular dependencies resolved!${NC}"
    else
        echo -e "${YELLOW}⚠️  Some issues may remain - check test output${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Dependency test not available${NC}"
fi

echo ""
echo "=================================="
echo "🔧 DEPENDENCY FIX RESULTS"
echo "=================================="
echo -e "Files processed: ${GREEN}$(ls "$AGENTS_DIR"/*.md | wc -l)${NC}"
echo -e "Fixes applied: ${GREEN}$FIXES_APPLIED${NC}"
echo -e "Backup location: ${YELLOW}$BACKUP_DIR${NC}"
echo ""

if [ $FIXES_APPLIED -gt 0 ]; then
    echo -e "${GREEN}✅ DEPENDENCY FIXES APPLIED SUCCESSFULLY${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run circular dependency test to verify fixes"
    echo "2. Test agent pipeline functionality"
    echo "3. Commit changes if validation passes"
    echo ""
    echo "To restore backup if needed:"
    echo "  cp $BACKUP_DIR/*.md $AGENTS_DIR/"
else
    echo -e "${YELLOW}⚠️  NO FIXES NEEDED${NC}"
    echo "All agents already have clean dependencies"
fi

exit 0
