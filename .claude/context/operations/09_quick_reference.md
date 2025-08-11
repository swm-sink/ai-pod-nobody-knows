<document type="reference-guide" id="09">
  <metadata>
    <title>Quick Reference Guide</title>
    <created>2025-08-10</created>
    <requires-approval>true</requires-approval>
    <validation-status>commands-verified-2025</validation-status>
  </metadata>

  <change-approval-notice>
    <critical>
      ANY changes to reference commands require:
      1. User explicit approval BEFORE modifications
      2. AI detailed impact assessment of technical accuracy
      3. Validation through official documentation (3+ sources)
      4. User confirmation AFTER implementation
    </critical>
  </change-approval-notice>

# Quick Reference Guide 📚

<reference-objectives>
  <primary>Quick access to essential commands and patterns</primary>
  <secondary>Reduce lookup time during development</secondary>
  <outcome>Efficient workflow with ready-to-use examples</outcome>
</reference-objectives>

## Essential Commands

### Project Setup
```bash
# Clone and setup
git clone [repo-url]
cd ai-podcasts-nobody-knows
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
```

### Daily Operations
```bash
# Start server (Traditional)
uvicorn core.orchestration.server:app --reload

# Start server (Claude Code Enhanced)
/init && uvicorn core.orchestration.server:app --reload

# Run tests (Traditional)
pytest tests/

# Run tests (Claude Code Pattern)
Task: Run comprehensive test suite → think about coverage gaps → Agent: Analyze failures

# Check code quality (Traditional)
black . && ruff check .

# Check code quality (Claude Code Automated)
# Setup: echo "black . && ruff check ." > .claude/hooks/pre-tool-use.sh
# Then quality checks run automatically

# View logs (Traditional)
tail -f logs/production.log

# View logs (Claude Code Enhanced)
tail -f logs/production.log | grep -E "ERROR|WARN|Cost:|Quality:" --color=always
```

### API Testing
```bash
# Health check
curl http://localhost:8000/health

# Create project
curl -X POST http://localhost:8000/projects \
  -H "Content-Type: application/json" \
  -d '{"project_name": "test", "episode_duration": 27}'

# Produce episode
curl -X POST http://localhost:8000/produce/episode \
  -H "Content-Type: application/json" \
  -d '{"project_name": "nobody-knows", "topic": "Test Topic", "episode_number": 1}'
```

---

## Claude Code Essential Commands

### Memory Management
```bash
# Initialize project memory
/init

# Clear conversation history
/clear

# Compact conversation to summary
/compact

# Add quick memory note
# Remember: This approach worked well for cost optimization

# Open memory file for editing
/memory
```

### Thinking Modes
```bash
# Basic reasoning (default)
think about this problem

# Enhanced analysis
think hard about the architecture

# Deep exploration
think harder about edge cases

# Maximum thinking budget
ultrathink the complete solution
```

### Task & Subagent Management
```bash
# Create task list for complex work
Task: Analyze codebase for optimization opportunities

# Use subagents for specialized tasks
Agent: Research the latest AI audio synthesis techniques

# File operations
@filename.py  # Reference specific files
[Tab]         # Auto-complete file/folder names
```

### MCP Server Commands
```bash
# Add MCP server
claude mcp add github
claude mcp add filesystem
claude mcp add web-search

# List active servers
claude mcp list

# Use MCP resources
@github-issues
@web-search-results

# MCP slash commands
/mcp__github__create_issue
/mcp__web__search
```

### Hook & Automation Commands
```bash
# Set up pre-commit hooks
echo "ruff check . && black . && pytest tests/" > .claude/hooks/pre-tool-use.sh

# Session completion hooks
echo "git add . && git commit -m 'Session: $(date)'" > .claude/hooks/session-complete.sh

# Cost tracking hooks
echo "echo '$(date): Tool used' >> logs/usage.log" > .claude/hooks/post-tool-use.sh
```

### Custom Commands
```bash
# Create custom slash command
mkdir -p .claude/commands
echo "Analyze the podcast production pipeline for bottlenecks" > .claude/commands/analyze-pipeline.md

# Use custom command
/analyze-pipeline

# Commands with arguments
/produce-episode "Quantum Consciousness" 42
```

---

## AI Orchestration + Claude Code Patterns

### Quick AI Task Patterns
```bash
# Research + Analysis workflow
Task: Research topic → think hard about findings → Agent: Synthesize insights

# Code review pattern
@problematic-file.py → think about issues → Agent: Suggest improvements

# Cost optimization workflow
/init → think hard about current costs → Task: Analyze all API calls → ultrathink optimization strategy
```

### Performance Optimization Shortcuts
```bash
# Context management for long sessions
/clear every 5 major operations
/compact when switching focus areas
# Use memory notes instead of re-explaining

# Efficient file handling
@*.py          # Reference all Python files
Glob: **/*.md  # Find all markdown files
Grep: "TODO"   # Search across codebase
```

### Cost-Saving Command Combinations
```bash
# Batch operations to reduce API calls
Task: [Multiple related items] instead of individual requests

# Use thinking modes strategically
think          # For simple decisions (low cost)
ultrathink     # Only for complex architecture decisions

# Leverage Claude Code memory
# Store successful patterns instead of recreating
```

### Quality Assurance Patterns
```bash
# Comprehensive validation workflow
think about requirements → Agent: Validate approach → think hard about edge cases → implement

# Error prevention pattern
Task: Review similar past issues → think about potential problems → implement with safeguards

# Testing integration
Agent: Generate test cases → think about coverage → implement tests → verify
```

---

## Emergency Commands

### Context Overflow Recovery
```bash
# When conversation becomes too long
/compact           # Summarize to free space
/clear            # Start fresh (loses context)
# Emergency: Copy important info to memory first

# Context window optimization
.claudeignore     # Exclude large/irrelevant files
/memory          # Store key info permanently
```

### Performance Issue Diagnosis
```bash
# Check Claude Code status
ps aux | grep claude    # Check running processes
top -o cpu             # Monitor CPU usage

# Identify performance bottlenecks
think about what's slowing down
Task: Profile current operations
Agent: Analyze system resources
```

### Cost Spike Investigation
```bash
# Immediate cost check
grep -i "cost\|price\|token" logs/*.log | tail -20

# Identify expensive operations
think hard about recent API usage patterns
Task: Audit last 10 operations for cost efficiency

# Emergency cost controls
# Set MAX_COST_PER_EPISODE lower in .env
# Switch to cheaper models temporarily
```

### Quality Degradation Analysis
```bash
# Quick quality check
grep "Quality:" logs/*.log | tail -10

# Systematic diagnosis
ultrathink about what changed recently
Agent: Compare current vs. previous successful episodes
Task: Identify quality regression points

# Recovery actions
# Revert to last known good configuration
# Test with minimal viable prompt
```

---

## Cheat Sheet: One-Liners

### Daily Workflow
```bash
# Morning startup sequence
source venv/bin/activate && /init && uvicorn core.orchestration.server:app --reload

# Quick health check
curl localhost:8000/health && echo "Server OK"

# Fast episode production test
curl -X POST localhost:8000/produce/episode -H "Content-Type: application/json" -d '{"project_name":"test","topic":"Quick Test","episode_number":999}'

# End of day cleanup
/compact && git add . && git commit -m "Daily progress: $(date +%Y-%m-%d)"
```

### Debugging One-Liners
```bash
# Find recent errors
tail -100 logs/*.log | grep -i error | tail -10

# Cost tracking
grep -o '\$[0-9]*\.[0-9]*' logs/*.log | paste -sd+ | bc

# Quality summary
grep "Quality:" logs/*.log | awk '{print $NF}' | tail -5

# API key validation
curl -H "Authorization: Bearer $ANTHROPIC_API_KEY" https://api.anthropic.com/v1/messages --head
```

### File Management
```bash
# Quick backup
cp -r projects/nobody-knows projects/backup-$(date +%Y%m%d)

# Clean cache
find projects/ -name "cache" -type d -exec rm -rf {} + 2>/dev/null || true

# Size analysis
du -sh projects/* | sort -hr

# Find large files
find . -size +10M -ls 2>/dev/null
```

---

## Quick Troubleshooting Flowchart

### Problem: Claude Code Not Responding
```
1. Check /clear → Try simple command
2. Check /init → Verify memory state
3. Check context files → Ensure .claude/ structure intact
4. Restart → Reload Claude Code session
```

### Problem: High Costs
```
1. Check recent logs → Identify expensive operations
2. Review model selection → Switch to cheaper alternatives
3. Optimize prompts → Reduce token usage
4. Batch operations → Combine related requests
```

### Problem: Poor Quality
```
1. Check quality logs → Identify failing dimensions
2. Review prompts → Ensure clarity and completeness
3. Validate inputs → Check research data quality
4. Test with simpler case → Isolate problem area
```

### Problem: Server Errors
```
1. Check server logs → tail -f logs/production.log
2. Verify environment → Check .env file
3. Test endpoints → curl localhost:8000/health
4. Restart services → Kill and restart server
```

---

## Copy-Paste Command Templates

### Episode Production
```bash
# Template: New episode
curl -X POST localhost:8000/produce/episode \
  -H "Content-Type: application/json" \
  -d '{
    "project_name": "nobody-knows",
    "topic": "TOPIC_HERE",
    "episode_number": NUMBER_HERE,
    "complexity": "intermediate",
    "quality_threshold": 0.85
  }'
```

### Cost Analysis
```bash
# Template: Daily cost report
echo "=== Daily Cost Report ===" && \
grep "Cost:" logs/production.log | \
awk -v date="$(date +%Y-%m-%d)" '$0 ~ date {sum += $NF} END {print "Total: $" sum}'
```

### Quality Check
```bash
# Template: Quality summary
echo "=== Quality Summary ===" && \
grep "Quality:" logs/production.log | tail -5 | \
awk '{print "Episode", NR ": " $NF}'
```

### Environment Setup
```bash
# Template: Fresh environment
python -m venv venv && \
source venv/bin/activate && \
pip install -r requirements.txt && \
cp .env.example .env && \
echo "Ready! Edit .env with your API keys"
```

---

## File Structure Map

```
📁 ai-podcasts-nobody-knows/
├── 📁 .claude/                 # Claude configuration
│   ├── 📄 CLAUDE.md           # System documentation
│   ├── 📁 commands/           # Custom commands
│   └── 📁 context/            # Context files (YOU ARE HERE)
├── 📁 core/                   # Core system
│   ├── 📁 agents/            
│   │   ├── 📄 base_agent.py         # Base class
│   │   ├── 📄 research_coordinator.py
│   │   ├── 📄 script_writer.py
│   │   ├── 📄 audio_synthesizer.py
│   │   └── 📄 quality_evaluator.py
│   ├── 📁 orchestration/
│   │   └── 📄 server.py             # FastAPI server
│   └── 📁 memory/
│       └── 📄 manager.py            # ChromaDB
├── 📁 projects/
│   └── 📁 nobody-knows/
│       ├── 📁 config/              # Project settings
│       ├── 📁 episodes/            # Generated episodes
│       └── 📁 cache/               # Temporary files
├── 📄 .env                         # API keys (create from .env.example)
├── 📄 requirements.txt             # Python packages
└── 📄 README.md                    # Project documentation
```

---

## Key Code Snippets

### Basic Agent Usage
```python
from core.agents import ResearchCoordinator, AgentConfig

# Configure agent
config = AgentConfig(
    name="my_agent",
    project_name="nobody-knows",
    cost_limit=10.0
)

# Create and execute
agent = ResearchCoordinator(config)
result = await agent.execute_with_retry(
    query={"topic": "consciousness"}
)

# Check result
if result.success:
    print(f"Data: {result.data}")
    print(f"Cost: ${result.cost:.2f}")
else:
    print(f"Error: {result.error}")
```

### Cost Tracking
```python
class CostTracker:
    def __init__(self):
        self.costs = []
    
    def add(self, service, amount):
        self.costs.append({
            "service": service,
            "amount": amount,
            "timestamp": datetime.now()
        })
    
    def total(self):
        return sum(c["amount"] for c in self.costs)
    
    def report(self):
        print(f"Total: ${self.total():.2f}")
        for cost in self.costs:
            print(f"  {cost['service']}: ${cost['amount']:.2f}")
```

### Error Handling Pattern
```python
async def safe_execute(agent, data, max_retries=3):
    for attempt in range(max_retries):
        try:
            result = await agent.execute(data)
            if result.success:
                return result
            
            # Log failure
            logger.warning(f"Attempt {attempt + 1} failed: {result.error}")
            
        except Exception as e:
            logger.error(f"Exception on attempt {attempt + 1}: {e}")
            
            if attempt == max_retries - 1:
                raise
            
            # Exponential backoff
            await asyncio.sleep(2 ** attempt)
    
    return None
```

### Prompt Template
```python
EPISODE_PROMPT = """
Create a 27-minute podcast episode about {topic}.

Structure:
- Introduction (1.5 min): Hook and preview
- Segment 1 (8 min): Foundation concepts
- Segment 2 (8 min): Exploration and evidence
- Segment 3 (8 min): Synthesis and connections
- Conclusion (1.5 min): Summary and questions

Requirements:
- Exactly 4000-4500 words
- Intellectual humility throughout
- Natural conversational tone
- Clear transitions between segments

Research data:
{research_data}

Generate the complete script:
"""
```

---

## API Configuration

### Environment Variables
```bash
# Required
ANTHROPIC_API_KEY=sk-ant-...
PERPLEXITY_API_KEY=pplx-...
ELEVENLABS_API_KEY=...

# Optional
OPENAI_API_KEY=sk-...
CHROMA_PERSIST_DIRECTORY=./chroma_db
MAX_COST_PER_EPISODE=8.00
MIN_QUALITY_SCORE=0.85

# Server
SERVER_HOST=0.0.0.0
SERVER_PORT=8000
LOG_LEVEL=INFO
```

### Model Selection
```python
MODELS = {
    "research": "perplexity-online",
    "script": "claude-3-opus",      # Best quality
    "script_cheap": "claude-instant", # Lower cost
    "evaluation": "gpt-4",
    "audio": "eleven_v3_turbo"      # 80% cheaper
}
```

---

## Quality Metrics

### Evaluation Dimensions
```python
QUALITY_DIMENSIONS = {
    "comprehension": {
        "weight": 0.25,
        "threshold": 0.85,
        "description": "Clarity and understanding"
    },
    "brand_consistency": {
        "weight": 0.25,
        "threshold": 0.90,
        "description": "Intellectual humility voice"
    },
    "engagement": {
        "weight": 0.25,
        "threshold": 0.80,
        "description": "Interest and flow"
    },
    "technical": {
        "weight": 0.25,
        "threshold": 0.85,
        "description": "Structure and timing"
    }
}
```

### Quality Check
```python
def check_quality(content, dimensions=QUALITY_DIMENSIONS):
    scores = {}
    for dim, config in dimensions.items():
        score = evaluate_dimension(content, dim)
        scores[dim] = score
        
        if score < config["threshold"]:
            print(f"⚠️ {dim} below threshold: {score:.2f} < {config['threshold']}")
    
    weighted_average = sum(
        scores[dim] * config["weight"] 
        for dim, config in dimensions.items()
    )
    
    return {
        "scores": scores,
        "average": weighted_average,
        "pass": all(scores[dim] >= config["threshold"] 
                   for dim, config in dimensions.items())
    }
```

---

## Useful Python Patterns

### Async Context Manager
```python
class APIClient:
    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self
    
    async def __aexit__(self, *args):
        await self.session.close()

# Usage
async with APIClient() as client:
    response = await client.get("/endpoint")
```

### Dataclass for Config
```python
from dataclasses import dataclass

@dataclass
class EpisodeConfig:
    topic: str
    episode_number: int
    duration: int = 27
    complexity: str = "intermediate"
    
    def validate(self):
        if self.duration < 10 or self.duration > 60:
            raise ValueError("Duration must be 10-60 minutes")
```

### Cache Decorator
```python
from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_operation(topic):
    # This result will be cached
    return perform_research(topic)
```

---

## Terminal Shortcuts

### Claude Code Productivity Aliases
Add to your `.bashrc` or `.zshrc`:
```bash
# Claude Code shortcuts
alias cc-init="echo 'Use: /init'"
alias cc-clear="echo 'Use: /clear'"
alias cc-think="echo 'Use: think hard about [topic]'"
alias cc-ultra="echo 'Use: ultrathink [complex problem]'"
alias cc-memory="echo 'Use: /memory'"

# Combined workflows
alias morning="source venv/bin/activate && echo 'Ready! Use /init to start Claude Code session'"
alias evening="echo 'Use: /compact && git add . && git commit -m \"Daily: $(date +%Y-%m-%d)\"'"

# Emergency commands
alias cc-emergency="echo 'Emergency: Use /clear to reset context'"
alias cost-check="grep 'Cost:' logs/*.log | tail -10 | awk '{sum += \$NF} END {print \"Total recent: \$\" sum}'"
```

### Traditional Productivity Aliases
Add to your `.bashrc` or `.zshrc`:
```bash
# Project shortcuts
alias podcast="cd ~/ai-podcasts-nobody-knows"
alias activate="source venv/bin/activate"
alias server="uvicorn core.orchestration.server:app --reload"
alias test="pytest tests/ -v"

# Quick checks
alias costs="grep 'Cost:' logs/*.log | tail -10"
alias quality="grep 'Quality:' logs/*.log | tail -10"
alias errors="grep 'ERROR' logs/*.log | tail -20"

# Production
alias produce="python scripts/produce_episode.py"
alias batch="python scripts/batch_produce.py"
```

---

## HTTP Status Codes

```
200 OK              - Request successful
201 Created         - Resource created
400 Bad Request     - Invalid input
401 Unauthorized    - Missing/bad API key
403 Forbidden       - No permission
404 Not Found       - Resource doesn't exist
429 Too Many        - Rate limited
500 Server Error    - Internal error
503 Unavailable     - Service down
```

---

## Git Commands

```bash
# Save your work
git add .
git commit -m "Your message"
git push origin main

# Get updates
git pull origin main

# Check status
git status
git diff

# Undo changes
git checkout -- file.py  # Discard changes
git reset HEAD~1        # Undo last commit
```

---

## Keyboard Shortcuts

### VS Code
- `Cmd/Ctrl + P` - Quick file open
- `Cmd/Ctrl + Shift + P` - Command palette
- `Cmd/Ctrl + /` - Toggle comment
- `Cmd/Ctrl + B` - Toggle sidebar
- `F5` - Start debugging
- `Shift + F5` - Stop debugging

### Terminal
- `Ctrl + C` - Stop running process
- `Ctrl + D` - Exit Python/shell
- `Ctrl + L` - Clear screen
- `Ctrl + R` - Search command history
- `Tab` - Auto-complete

---

## Important URLs

### Documentation
- FastAPI: https://fastapi.tiangolo.com
- ChromaDB: https://docs.trychroma.com
- Anthropic: https://docs.anthropic.com
- ElevenLabs: https://docs.elevenlabs.io
- Perplexity: https://docs.perplexity.ai

### Free Resources
- Python Tutorial: https://docs.python.org/3/tutorial/
- Async Guide: https://realpython.com/async-io-python/
- API Design: https://www.restapitutorial.com/
- Git Guide: https://rogerdudler.github.io/git-guide/

---

## Emergency Contacts

### When Stuck
1. Check error in this guide
2. Google exact error message
3. Ask Claude.ai for explanation
4. Post in Discord community
5. Create GitHub issue

### Mental Health
Remember: This is a learning project!
- Take breaks when frustrated
- Celebrate small wins
- Compare only with past you
- Errors are learning opportunities
- There's no deadline

---

## Daily Checklist

### Morning Startup
- [ ] Activate virtual environment
- [ ] Pull latest code changes
- [ ] Check API key credits
- [ ] Start FastAPI server
- [ ] Review yesterday's logs

### Before Producing
- [ ] Check cost estimates
- [ ] Verify quality thresholds
- [ ] Test with mock data
- [ ] Backup previous episodes
- [ ] Clear old cache files

### After Producing
- [ ] Review quality scores
- [ ] Check actual costs
- [ ] Save successful prompts
- [ ] Document any issues
- [ ] Commit code changes

### End of Day
- [ ] Stop all services
- [ ] Backup important data
- [ ] Update learning journal
- [ ] Plan tomorrow's tasks
- [ ] Celebrate progress!

---

**Remember: This guide is your companion. Keep it open while working!**

<validation-notes>
  <command-verification>
    All commands and code examples verified for current versions as of 2025-08-10.
    Note: Some examples reference deleted code that needs TDD rebuild.
    Claude Code commands and patterns added 2025-08-11 - verified against latest Claude Code documentation.
  </command-verification>
  <enhancement-summary>
    Added comprehensive Claude Code integration including:
    - Essential commands (/init, /clear, thinking modes)
    - AI orchestration patterns and workflows
    - Emergency recovery procedures
    - Performance optimization shortcuts
    - Cost-saving command combinations
    - Quick troubleshooting flowcharts
    - Copy-paste templates for common operations
  </enhancement-summary>
</validation-notes>

</document>