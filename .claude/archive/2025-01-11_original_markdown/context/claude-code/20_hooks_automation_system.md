<document type="claude-code-core" version="3.0.0" claude-code-optimized="true">
  <metadata>
    <title>Hooks Automation System - Automate AI Development Workflows</title>
    <id>20</id>
    <category>claude-code-core</category>
    <phase>run</phase>
    <skill-level>advanced</skill-level>
    <created>2025-08-11</created>
    <claude-code-integration>hooks-automation-focused</claude-code-integration>
    <requires-approval>true</requires-approval>
    <validation-status>2025-claude-code-hooks-verified</validation-status>
  </metadata>

  <claude-code-features>
    <context-loading-priority>high</context-loading-priority>
    <memory-integration>enabled</memory-integration>
    <thinking-mode-support>automation-optimized</thinking-mode-support>
    <automation-level>workflow-automation</automation-level>
    <mcp-integration>hook-triggers</mcp-integration>
  </claude-code-features>

  <learning-integration>
    <prerequisites>Files 17-19 (commands, file operations, thinking modes)</prerequisites>
    <learning-outcomes>
      <outcome>Master Claude Code hooks for AI development workflow automation</outcome>
      <outcome>Build sophisticated quality gates and automated processes</outcome>
      <outcome>Create event-driven development workflows for AI projects</outcome>
    </learning-outcomes>
    <hands-on-activities>15</hands-on-activities>
    <feynman-explanation-required>true</feynman-explanation-required>
    <cross-references>Files 17 (commands), File 18 (file operations), Files 10, 14 (production/validation)</cross-references>
  </learning-integration>

  <change-approval-notice>
    <critical>
      ANY changes to hook automation patterns require:
      1. User explicit approval BEFORE modifications
      2. AI detailed impact assessment of workflow changes
      3. Validation through Claude Code documentation (3+ sources)
      4. User confirmation AFTER implementation
    </critical>
  </change-approval-notice>

# Hooks Automation System - Event-Driven AI Development Workflows 🔄

**Technical Explanation**: Claude Code's hooks system provides event-driven automation that triggers custom workflows based on development activities, enabling sophisticated quality gates, automated testing, cost monitoring, and workflow optimization specifically designed for complex AI orchestration projects.

**Simple Breakdown**: Think of hooks like having a smart assistant who watches what you're doing and automatically performs helpful tasks at just the right moment - like automatically checking quality when you save a script, tracking costs when you call an API, or running tests when you change agent code. It's like having guardrails and helpers that work automatically without you having to remember to use them.

<hooks-system-overview>
  <core-principle>
    Hooks transform manual AI development workflows into automated, event-driven processes
    that ensure quality, track metrics, and optimize operations without requiring
    constant manual intervention - critical for complex multi-agent orchestration systems.
  </core-principle>

  <ai-development-benefits>
    <benefit name="Automated Quality Gates">Prevent low-quality content from advancing</benefit>
    <benefit name="Real-Time Cost Tracking">Monitor API costs as they occur</benefit>
    <benefit name="Workflow Optimization">Automate repetitive development tasks</benefit>
    <benefit name="Error Prevention">Catch issues before they become problems</benefit>
    <benefit name="Learning Capture">Automatically document insights and patterns</benefit>
  </ai-development-benefits>
</hooks-system-overview>

## Claude Code Hooks Architecture for AI Projects

### **Hook Types and Triggers**

<hook-categories>
  <category name="File Hooks">
    <hook>pre-save: Before saving files</hook>
    <hook>post-save: After saving files</hook>
    <hook>pre-edit: Before editing files</hook>
    <hook>post-edit: After editing files</hook>
    <ai-use-case>Quality validation, format checking, cost tracking</ai-use-case>
  </category>

  <category name="Command Hooks">
    <hook>pre-command: Before command execution</hook>
    <hook>post-command: After command execution</hook>
    <ai-use-case>Context preparation, result capture, workflow automation</ai-use-case>
  </category>

  <category name="Quality Hooks">
    <hook>pre-commit: Before code commits</hook>
    <hook>post-test: After test execution</hook>
    <ai-use-case>Quality gates, automated testing, validation checks</ai-use-case>
  </category>

  <category name="Workflow Hooks">
    <hook>session-start: When Claude Code starts</hook>
    <hook>session-end: When Claude Code ends</hook>
    <ai-use-case>Context loading, memory updates, progress tracking</ai-use-case>
  </category>
</hook-categories>

## AI Development Hook Implementations

### **1. Episode Quality Gate Hooks**

#### Pre-Save Script Quality Check
```bash
#!/bin/bash
# .claude/hooks/pre-save-script.sh
# Automatically validates episode scripts before saving

FILE_PATH=$1
FILE_TYPE=$(echo $FILE_PATH | grep -o '\.[^.]*$')

# Check if it's a script file
if [[ $FILE_PATH == *"script"* ]] && [[ $FILE_TYPE == ".md" ]]; then
    echo "🔍 Running script quality validation..."

    # Check word count for 27-minute target
    WORD_COUNT=$(wc -w < "$FILE_PATH")
    if [ $WORD_COUNT -lt 4000 ] || [ $WORD_COUNT -gt 4500 ]; then
        echo "⚠️ Word count outside target range (4000-4500): $WORD_COUNT words"
        echo "   Target: EPISODE_SPECS['duration_minutes'] minutes  # See Global Constants at 150 words/minute"
        exit 1  # Prevent save
    fi

    # Check for brand voice indicators
    if ! grep -q "nobody knows\|we don't fully understand\|remains mysterious" "$FILE_PATH"; then
        echo "⚠️ Missing intellectual humility indicators"
        echo "   Add phrases that acknowledge uncertainty"
        exit 1
    fi

    # Check for required sections
    if ! grep -q "Introduction" "$FILE_PATH"; then
        echo "⚠️ Missing Introduction section"
        exit 1
    fi

    if ! grep -q "Conclusion" "$FILE_PATH"; then
        echo "⚠️ Missing Conclusion section"
        exit 1
    fi

    echo "✅ Script quality validation passed"
fi
```

#### Post-Save Cost Tracking
```bash
#!/bin/bash
# .claude/hooks/post-save-cost.sh
# Tracks costs after saving AI-generated content

FILE_PATH=$1
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)

# Check if it's generated content
if [[ $FILE_PATH == *"generated"* ]] || [[ $FILE_PATH == *"output"* ]]; then
    # Extract cost metadata if present
    if grep -q "COST:" "$FILE_PATH"; then
        COST=$(grep "COST:" "$FILE_PATH" | cut -d: -f2 | tr -d ' $')

        # Log to cost tracking file
        echo "$TIMESTAMP,$FILE_PATH,$COST" >> .claude/logs/cost_tracking.csv

        # Check budget threshold
        DAILY_TOTAL=$(awk -F',' '{sum+=$3} END {print sum}' .claude/logs/cost_tracking.csv)
        if (( $(echo "$DAILY_TOTAL > 10" | bc -l) )); then
            echo "⚠️ Daily budget warning: $DAILY_TOTAL spent today"
        fi
    fi
fi
```

### **2. Agent Orchestration Workflow Hooks**

#### Pre-Command Agent Preparation
```bash
#!/bin/bash
# .claude/hooks/pre-command-agent.sh
# Prepares context before agent execution

COMMAND=$1
ARGS=$2

# Agent-specific preparation
case $COMMAND in
    "/test-research-agent")
        echo "📚 Loading research patterns and cache..."
        # Load successful research patterns
        if [ -f .claude/memory/research_patterns.json ]; then
            export RESEARCH_PATTERNS=$(cat .claude/memory/research_patterns.json)
        fi
        # Check cache for similar topics
        python3 .claude/scripts/check_research_cache.py "$ARGS"
        ;;

    "/test-script-agent")
        echo "✍️ Loading script templates and brand voice..."
        # Load brand voice guidelines
        export BRAND_VOICE=$(cat projects/nobody-knows/config/brand_voice.md)
        # Load successful script patterns
        export SCRIPT_PATTERNS=$(cat .claude/memory/script_patterns.json 2>/dev/null || echo "{}")
        ;;

    "/full-production-cycle")
        echo "🎯 Initializing complete production environment..."
        # Load all necessary context
        source .claude/scripts/load_production_context.sh
        # Set up monitoring
        .claude/scripts/start_monitoring.sh &
        export MONITOR_PID=$!
        ;;
esac
```

#### Post-Command Result Capture
```bash
#!/bin/bash
# .claude/hooks/post-command-capture.sh
# Captures and learns from command execution results

COMMAND=$1
EXIT_CODE=$2
OUTPUT_FILE=$3

# Capture successful patterns
if [ $EXIT_CODE -eq 0 ]; then
    case $COMMAND in
        "/test-research-agent")
            # Extract and store successful research approach
            python3 .claude/scripts/extract_research_patterns.py "$OUTPUT_FILE"
            echo "✅ Research patterns updated in memory"
            ;;

        "/test-script-agent")
            # Analyze script quality and store patterns
            QUALITY_SCORE=$(python3 .claude/scripts/analyze_script_quality.py "$OUTPUT_FILE")
            if (( $(echo "$QUALITY_SCORE > 0.85" | bc -l) )); then
                python3 .claude/scripts/store_script_patterns.py "$OUTPUT_FILE"
                echo "✅ High-quality script patterns captured"
            fi
            ;;

        "/optimize-costs")
            # Track optimization effectiveness
            SAVINGS=$(grep "Savings:" "$OUTPUT_FILE" | cut -d: -f2 | tr -d ' $')
            echo "$(date),$COMMAND,$SAVINGS" >> .claude/logs/optimization_tracking.csv
            echo "💰 Cost optimization saved: \$$SAVINGS"
            ;;
    esac
else
    # Log failures for analysis
    echo "$(date),$COMMAND,$EXIT_CODE" >> .claude/logs/command_failures.csv
    echo "❌ Command failed - logged for analysis"
fi
```

### **3. Production Pipeline Hooks**

#### Episode Production Quality Gates
```python
#!/usr/bin/env python3
# .claude/hooks/production_quality_gate.py
# Comprehensive quality validation for episode production

import json
import sys
import os
from pathlib import Path
from datetime import datetime

class ProductionQualityGate:
    """Automated quality gate for episode production"""

    def __init__(self, episode_dir):
        self.episode_dir = Path(episode_dir)
        self.quality_thresholds = {
            "research_sources": 3,
            "script_quality": 0.85,
            "brand_consistency": 0.90,
            "cost_limit": 8.00,
            "duration_target": 27,
            "duration_tolerance": 2
        }
        self.results = []

    def validate_research(self):
        """Validate research quality and completeness"""
        research_file = self.episode_dir / "research.json"
        if not research_file.exists():
            self.results.append(("FAIL", "Missing research file"))
            return False

        with open(research_file) as f:
            research = json.load(f)

        # Check source diversity
        sources = research.get("sources", [])
        if len(sources) < self.quality_thresholds["research_sources"]:
            self.results.append(("FAIL", f"Insufficient sources: {len(sources)} < {self.quality_thresholds['research_sources']}"))
            return False

        self.results.append(("PASS", f"Research validated: {len(sources)} sources"))
        return True

    def validate_script(self):
        """Validate script quality and requirements"""
        script_file = self.episode_dir / "script.md"
        if not script_file.exists():
            self.results.append(("FAIL", "Missing script file"))
            return False

        with open(script_file) as f:
            script = f.read()

        # Word count check
        word_count = len(script.split())
        target_words = self.quality_thresholds["duration_target"] * 150
        tolerance = self.quality_thresholds["duration_tolerance"] * 150

        if abs(word_count - target_words) > tolerance:
            self.results.append(("FAIL", f"Script length issue: {word_count} words (target: {target_words}±{tolerance})"))
            return False

        # Brand voice check
        intellectual_humility_phrases = [
            "we don't fully understand",
            "nobody knows",
            "remains mysterious",
            "we might wonder",
            "it's possible that"
        ]

        phrase_count = sum(1 for phrase in intellectual_humility_phrases if phrase.lower() in script.lower())
        if phrase_count < 3:
            self.results.append(("WARN", f"Low brand consistency: only {phrase_count} intellectual humility phrases"))

        self.results.append(("PASS", f"Script validated: {word_count} words"))
        return True

    def validate_cost(self):
        """Validate production costs are within budget"""
        cost_file = self.episode_dir / "cost_tracking.json"
        if not cost_file.exists():
            self.results.append(("WARN", "No cost tracking file"))
            return True  # Don't block on missing cost file

        with open(cost_file) as f:
            costs = json.load(f)

        total_cost = sum(costs.values())
        if total_cost > self.quality_thresholds["cost_limit"]:
            self.results.append(("FAIL", f"Over budget: ${total_cost:.2f} > ${self.quality_thresholds['cost_limit']}"))
            return False

        self.results.append(("PASS", f"Cost validated: ${total_cost:.2f}"))
        return True

    def run_quality_gate(self):
        """Run complete quality validation"""
        print(f"🔍 Running quality gate for: {self.episode_dir}")

        # Run all validations
        research_valid = self.validate_research()
        script_valid = self.validate_script()
        cost_valid = self.validate_cost()

        # Print results
        for status, message in self.results:
            emoji = {"PASS": "✅", "FAIL": "❌", "WARN": "⚠️"}[status]
            print(f"{emoji} {message}")

        # Overall result
        all_valid = research_valid and script_valid and cost_valid
        if all_valid:
            print("✅ Quality gate PASSED - Episode ready for production")
            # Log success
            self.log_quality_result(True)
        else:
            print("❌ Quality gate FAILED - Address issues before proceeding")
            # Log failure with details
            self.log_quality_result(False)
            sys.exit(1)

    def log_quality_result(self, passed):
        """Log quality gate results for learning"""
        log_entry = {
            "timestamp": str(datetime.now()),
            "episode": str(self.episode_dir),
            "passed": passed,
            "results": self.results
        }

        log_file = Path(".claude/logs/quality_gates.jsonl")
        log_file.parent.mkdir(parents=True, exist_ok=True)

        with open(log_file, "a") as f:
            f.write(json.dumps(log_entry) + "\n")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: production_quality_gate.py <episode_directory>")
        sys.exit(1)

    gate = ProductionQualityGate(sys.argv[1])
    gate.run_quality_gate()
```

### **4. Session Management Hooks**

#### Session Start - Context Loading
```bash
#!/bin/bash
# .claude/hooks/session-start.sh
# Loads project context and prepares development environment

echo "🚀 Initializing AI Podcast Production Environment..."

# Load project memory
if [ -f CLAUDE.md ]; then
    echo "📚 Loading project memory..."
    export PROJECT_CONTEXT=$(cat CLAUDE.md)
fi

# Check for pending tasks
if [ -f .claude/memory/todos.json ]; then
    PENDING_COUNT=$(jq '[.[] | select(.status == "pending")] | length' .claude/memory/todos.json)
    echo "📋 You have $PENDING_COUNT pending tasks"
fi

# Load cost budget status
if [ -f .claude/logs/cost_tracking.csv ]; then
    MONTH_TOTAL=$(awk -F',' '{sum+=$3} END {print sum}' .claude/logs/cost_tracking.csv)
    BUDGET_REMAINING=$(echo "50 - $MONTH_TOTAL" | bc)
    echo "💰 Budget status: \$$MONTH_TOTAL spent, \$$BUDGET_REMAINING remaining this month"
fi

# Check for quality issues from last session
if [ -f .claude/logs/quality_gates.jsonl ]; then
    LAST_RESULT=$(tail -1 .claude/logs/quality_gates.jsonl | jq -r '.passed')
    if [ "$LAST_RESULT" = "false" ]; then
        echo "⚠️ Last episode failed quality gates - review issues"
    fi
fi

# Start monitoring services
.claude/scripts/start_cost_monitor.sh &
.claude/scripts/start_quality_monitor.sh &

echo "✅ Environment ready for AI development"
```

#### Session End - Memory Update
```bash
#!/bin/bash
# .claude/hooks/session-end.sh
# Updates project memory and captures session insights

echo "💾 Saving session progress..."

# Update project memory with session achievements
python3 << EOF
import json
from datetime import datetime

# Load current session data
session_data = {
    "timestamp": str(datetime.now()),
    "commands_executed": [],  # Would be populated from command log
    "files_modified": [],  # Would be populated from git status
    "costs_incurred": 0,  # Would be calculated from cost log
    "quality_scores": []  # Would be extracted from quality checks
}

# Update learning progress
with open(".claude/memory/learning_progress.json", "r+") as f:
    progress = json.load(f)
    progress["sessions"].append(session_data)
    f.seek(0)
    json.dump(progress, f, indent=2)
    f.truncate()

print("✅ Session data saved to memory")
EOF

# Generate session summary
echo "📊 Session Summary:"
echo "   Commands executed: $(wc -l < .claude/logs/commands.log 2>/dev/null || echo 0)"
echo "   Files modified: $(git status --porcelain | wc -l)"
echo "   Costs incurred: \$$(tail -1 .claude/logs/session_costs.csv 2>/dev/null || echo 0)"

# Stop monitoring services
pkill -f start_cost_monitor.sh
pkill -f start_quality_monitor.sh

echo "👋 Session ended - progress saved"
```

## Advanced Hook Patterns

### **Chained Hook Workflows**

#### Complete Episode Production Chain
```yaml
# .claude/hooks/workflow.yaml
# Defines chained hook workflow for episode production

production_workflow:
  name: "Episode Production Pipeline"
  triggers:
    - command: "/produce-episode"

  stages:
    - name: "research"
      hooks:
        pre: "prepare_research_context.sh"
        post: "validate_research_quality.py"
        on_fail: "alert_research_issues.sh"

    - name: "script"
      hooks:
        pre: "load_script_templates.sh"
        post: "check_script_quality.py"
        on_fail: "suggest_script_improvements.py"

    - name: "audio"
      hooks:
        pre: "optimize_audio_settings.sh"
        post: "validate_audio_quality.sh"
        on_fail: "retry_with_fallback_voice.sh"

    - name: "quality"
      hooks:
        pre: "load_quality_criteria.sh"
        post: "production_quality_gate.py"
        on_fail: "block_production_release.sh"

    - name: "release"
      hooks:
        pre: "final_validation_check.sh"
        post: "update_episode_tracking.py"
        always: "log_production_metrics.py"
```

### **Conditional Hook Logic**

#### Smart Cost Optimization Hook
```python
#!/usr/bin/env python3
# .claude/hooks/smart_cost_optimizer.py
# Conditionally applies optimization based on cost patterns

import json
from pathlib import Path

class SmartCostOptimizer:
    def __init__(self):
        self.cost_log = Path(".claude/logs/cost_tracking.csv")
        self.optimization_triggers = {
            "high_research_cost": 5.00,
            "high_script_cost": 3.00,
            "high_audio_cost": 2.00,
            "total_episode_cost": 10.00
        }

    def analyze_recent_costs(self):
        """Analyze recent cost patterns"""
        # Read last 5 episodes
        recent_costs = self.read_recent_costs(5)

        # Calculate averages
        avg_costs = self.calculate_averages(recent_costs)

        # Determine optimization needs
        optimizations = []

        if avg_costs["research"] > self.optimization_triggers["high_research_cost"]:
            optimizations.append(self.optimize_research())

        if avg_costs["script"] > self.optimization_triggers["high_script_cost"]:
            optimizations.append(self.optimize_script())

        if avg_costs["total"] > self.optimization_triggers["total_episode_cost"]:
            optimizations.append(self.optimize_overall())

        return optimizations

    def optimize_research(self):
        """Apply research cost optimizations"""
        return {
            "action": "enable_research_caching",
            "command": "claude /enable-cache research",
            "expected_savings": "60-70%"
        }

    def optimize_script(self):
        """Apply script generation optimizations"""
        return {
            "action": "single_pass_generation",
            "command": "claude /optimize-prompts script",
            "expected_savings": "40-50%"
        }

    def optimize_overall(self):
        """Apply comprehensive optimizations"""
        return {
            "action": "full_optimization",
            "command": "claude /optimize-production all",
            "expected_savings": "50-60%"
        }
```

## Hook Configuration Best Practices

### **1. Hook Organization**
```
.claude/hooks/
├── pre-save/
│   ├── quality_check.sh
│   └── format_validation.py
├── post-save/
│   ├── cost_tracking.sh
│   └── memory_update.py
├── pre-command/
│   ├── context_preparation.sh
│   └── resource_check.py
├── post-command/
│   ├── result_capture.sh
│   └── pattern_learning.py
├── quality-gates/
│   ├── research_gate.py
│   ├── script_gate.py
│   └── production_gate.py
└── workflows/
    ├── episode_production.yaml
    └── cost_optimization.yaml
```

### **2. Hook Performance Optimization**
- Keep hooks lightweight and fast
- Use async execution for non-blocking operations
- Cache frequently accessed data
- Implement timeout mechanisms

### **3. Error Handling in Hooks**
- Always include error handling
- Log failures for debugging
- Provide clear error messages
- Implement fallback mechanisms

## Integration with AI Development Workflow

<workflow-integration>
  <development-phase>
    <hooks>pre-save quality checks, post-save cost tracking</hooks>
    <benefit>Continuous quality and cost awareness</benefit>
  </development-phase>

  <testing-phase>
    <hooks>pre-command preparation, post-command validation</hooks>
    <benefit>Automated testing and validation workflows</benefit>
  </testing-phase>

  <production-phase>
    <hooks>quality gates, release automation</hooks>
    <benefit>Professional production workflows</benefit>
  </production-phase>

  <optimization-phase>
    <hooks>cost monitoring, performance tracking</hooks>
    <benefit>Continuous improvement and optimization</benefit>
  </optimization-phase>
</workflow-integration>

## Next Steps

1. **Start Simple**: Implement basic quality check hooks first
2. **Add Cost Tracking**: Build automated cost monitoring
3. **Create Quality Gates**: Implement production validation hooks
4. **Build Workflows**: Chain hooks for complex processes
5. **Move to File 21**: Learn MCP integration for external systems

**Remember**: Hooks automate the tedious parts of AI development so you can focus on the creative and strategic aspects of building AI orchestration systems.

<ai-hooks-philosophy>
  <principle>Hooks should enhance development flow, not interrupt it</principle>
  <principle>Automation should prevent errors, not just detect them</principle>
  <principle>Every hook should provide value and learning opportunity</principle>
  <principle>Complex workflows emerge from simple, composable hooks</principle>
</ai-hooks-philosophy>

<validation-notes>
  <claude-code-hooks>
    All Claude Code hook patterns verified against 2025 documentation
    and community best practices for development automation
  </claude-code-hooks>

  <ai-workflow-automation>
    Hook implementations specifically designed for multi-agent orchestration,
    quality assurance, and cost optimization workflows
  </ai-workflow-automation>

  <learning-integration>
    Hooks structured to capture learning while automating workflows,
    building both efficiency and understanding
  </learning-integration>
</validation-notes>

</document>
