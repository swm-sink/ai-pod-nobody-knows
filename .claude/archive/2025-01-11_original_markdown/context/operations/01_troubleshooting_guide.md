<document type="reference-guide" id="08">
  <metadata>
    <title>Troubleshooting Guide - When Things Go Wrong</title>
    <created>2025-08-10</created>
    <requires-approval>true</requires-approval>
    <validation-status>troubleshooting-verified-2025</validation-status>
    <enhanced-version>claude-code-debug-integrated</enhanced-version>
  </metadata>

  <change-approval-notice>
    <critical>
      ANY changes to troubleshooting procedures require:
      1. User explicit approval BEFORE modifications
      2. AI detailed impact assessment of technical accuracy
      3. Validation through technical documentation (3+ sources)
      4. User confirmation AFTER implementation
    </critical>
  </change-approval-notice>

# Troubleshooting Guide - When Things Go Wrong (They Will!)

<reference-objectives>
  <primary>Provide solutions for common problems</primary>
  <secondary>Build confidence in problem-solving</secondary>
  <outcome>Ability to diagnose and fix issues independently</outcome>
</reference-objectives>

## Common Problems and Solutions

### 🔴 Installation Issues

#### Problem: "pip install fails"
```bash
ERROR: Could not find a version that satisfies the requirement...
```

**Solutions:**
1. Update pip: `python -m pip install --upgrade pip`
2. Use Python 3.11+: `python --version`
3. Try one package at a time:
   ```bash
   pip install fastapi
   pip install chromadb
   pip install openai
   ```
4. Use `--no-cache-dir`: `pip install --no-cache-dir -r requirements.txt`

#### Problem: "Module not found"
```python
ModuleNotFoundError: No module named 'fastapi'
```

**Solutions:**
1. Check virtual environment is activated:
   ```bash
   which python  # Should show venv path
   source venv/bin/activate  # Reactivate
   ```
2. Reinstall in correct environment:
   ```bash
   pip install fastapi
   ```

---

### 🟡 Server Issues

#### Problem: "Port already in use"
```
ERROR: [Errno 48] Address already in use
```

**Solutions:**
1. Find and kill process:
   ```bash
   lsof -i :8000  # Find process
   kill -9 [PID]  # Kill it
   ```
2. Use different port:
   ```bash
   uvicorn core.orchestration.server:app --port 8001
   ```

#### Problem: "Server won't start"
```
ImportError: cannot import name 'app' from 'core.orchestration.server'
```

**Solutions:**
1. Check file exists: `ls core/orchestration/server.py`
2. Check Python path: `export PYTHONPATH=$PYTHONPATH:.`
3. Run from project root: `cd ai-podcasts-nobody-knows`

---

### 🟠 API Issues

#### Problem: "Invalid API key"
```
openai.error.AuthenticationError: Invalid API key
```

**Solutions:**
1. Check .env file:
   ```bash
   cat .env | grep API_KEY
   ```
2. No spaces in keys:
   ```
   GOOD: OPENAI_API_KEY=sk-abc123
   BAD:  OPENAI_API_KEY = sk-abc123
   ```
3. Load environment:
   ```python
   from dotenv import load_dotenv
   load_dotenv()
   ```

#### Problem: "Rate limit exceeded"
```
Error: Rate limit reached. Please wait...
```

**Solutions:**
1. Add delays:
   ```python
   import time
   time.sleep(2)  # Wait 2 seconds between calls
   ```
2. Implement exponential backoff:
   ```python
   wait_time = 2 ** attempt  # 2, 4, 8, 16 seconds
   ```
3. Use free tier wisely - spread across days

**Claude Code Enhanced Solutions:**
4. **Intelligent Rate Limiting**:
   ```python
   # MCP-based rate limit monitoring
   /mcp__apis__monitor-limits --all-services --auto-adjust

   # Hook-based request spacing
   /hook create rate-limiter "Automatically space API calls to avoid limits"
   ```
5. **Adaptive Request Management**:
   ```python
   # Subagent for request optimization
   /subagent create request-optimizer "Balance speed vs rate limits"

   # Thinking mode analysis
   think about optimal request patterns to minimize rate limiting
   ```

#### Problem: "API timeout"
```
TimeoutError: Request timed out after 30 seconds
```

**Solutions:**
1. Increase timeout:
   ```python
   response = await client.chat.completions.create(
       timeout=60  # 60 seconds instead of 30
   )
   ```
2. Retry with smaller request
3. Check internet connection

---

### 🔵 Agent Issues

#### Problem: "Agent returns empty response"
```python
result = agent.execute(data)
# result.data is {}
```

**Solutions:**
1. Add debug logging:
   ```python
   import logging
   logging.basicConfig(level=logging.DEBUG)
   logger.debug(f"Input: {data}")
   ```
2. Check prompt:
   ```python
   print(f"Prompt being sent: {prompt}")
   ```
3. Test with mock data first

#### Problem: "Script too short/long"
```
Generated script is 2000 words (need 4000)
```

**Solutions:**
1. Be explicit in prompt:
   ```python
   prompt = "Generate EXACTLY 4000-4500 words..."
   ```
2. Add word counter:
   ```python
   word_count = len(script.split())
   if word_count < 4000:
       # Request more content
   ```

#### Problem: "Quality check fails"
```
Quality score: 0.65 (minimum: 0.85)
```

**Solutions:**
1. Review evaluation criteria
2. Improve prompts:
   ```python
   "MUST include intellectual humility phrases"
   "MUST have engaging introduction"
   ```
3. Add pre-checks before synthesis

**Claude Code Enhanced Solutions:**
4. **Intelligent Quality Analysis**:
   ```python
   # Deep quality pattern analysis
   ultrathink the relationship between prompt structure and quality scores

   # Subagent quality investigation
   /subagent create quality-analyst "Compare successful vs failed episodes"
   ```
5. **Automated Quality Improvement**:
   ```python
   # Hook-based quality gates
   /hook create quality-gate "Block synthesis if quality prediction < 0.8"

   # Iterative improvement with thinking modes
   think hard about specific improvements needed for this episode
   ```

---

### 🟣 ChromaDB Issues

#### Problem: "Cannot connect to ChromaDB"
```
Failed to connect to ChromaDB
```

**Solutions:**
1. Use persistent client:
   ```python
   import chromadb
   client = chromadb.PersistentClient(path="./chroma_db")
   ```
2. Check directory permissions:
   ```bash
   ls -la chroma_db/
   chmod 755 chroma_db/
   ```

#### Problem: "Collection already exists"
```
ValueError: Collection my_collection already exists
```

**Solutions:**
1. Get or create:
   ```python
   try:
       collection = client.create_collection("episodes")
   except:
       collection = client.get_collection("episodes")
   ```
2. Delete and recreate:
   ```python
   client.delete_collection("episodes")
   collection = client.create_collection("episodes")
   ```

---

### ⚫ Cost Issues

#### Problem: "Costs too high"
```
Episode cost: $45.00 (target: $8.00)
```

**Solutions:**
1. Analyze cost breakdown:
   ```python
   print(f"Research: ${research_cost}")
   print(f"Script: ${script_cost}")
   print(f"Audio: ${audio_cost}")
   ```
2. Optimize highest cost component
3. Use caching more aggressively
4. Reduce prompt sizes

**Claude Code Enhanced Solutions:**
5. **Automated Cost Analysis**:
   ```python
   # Use thinking modes for deep cost analysis
   think harder about cost optimization opportunities in current workflow

   # Subagent-based cost optimization
   /subagent create cost-optimizer "Analyze and suggest cost reduction strategies"
   ```
6. **Real-time Cost Monitoring**:
   ```python
   # Hook-based cost tracking
   /hook create cost-tracker "Log all API costs in real-time"

   # MCP integration for cost alerts
   /mcp__costs__set-alerts --threshold="$10" --episode-limit="$8"
   ```

#### Problem: "Unexpected charges"
```
API bill: $200 (expected: $50)
```

**Solutions:**
1. Set up usage alerts
2. Add cost limits:
   ```python
   if total_cost > MAX_COST:
       raise Exception("Cost limit exceeded!")
   ```
3. Log every API call:
   ```python
   logger.info(f"API call to {service}: ${cost}")
   ```

---

## 🚀 Claude Code Advanced Debugging

<claude-code-debugging>
  <philosophy>
    **Technical Explanation**: Claude Code provides advanced AI development tools including thinking modes, subagents, MCP servers, and hooks that enable sophisticated debugging workflows for AI orchestration systems.

    **Simple Breakdown**: Think of Claude Code as your AI debugging assistant. Instead of just writing code, you can ask it to "think harder" about problems, break complex issues into smaller pieces with helper agents, and automatically catch problems before they happen.

    **Learning Value**: This teaches you how modern AI development environments enhance human problem-solving capabilities through intelligent tooling.
  </philosophy>
</claude-code-debugging>

### 🧠 Using Thinking Modes for Problem Diagnosis

#### Problem: "Complex issue needs deeper analysis"
```
Quality issues with multiple interconnected causes
```

**Claude Code Solutions:**
1. **Progressive Thinking Analysis**:
   ```bash
   # Basic analysis
   think about this API timeout issue

   # Enhanced analysis
   think hard about the relationship between API timeouts and cost optimization

   # Deep exploration
   think harder about all potential causes of intermittent API failures

   # Maximum analysis
   ultrathink the complete system behavior under different load conditions
   ```

2. **Systematic Diagnosis Workflow**:
   ```python
   # Let Claude Code analyze step-by-step
   /debug-analysis "Episode generation failing at random points"

   # Expected output:
   # 1. Thinking through potential causes...
   # 2. Analyzing system logs and patterns...
   # 3. Identifying root cause candidates...
   # 4. Proposing systematic testing approach...
   ```

### 🤖 Leveraging Subagents for Systematic Troubleshooting

#### Problem: "Need to check multiple system components"
```
Issue could be in API, database, file system, or network
```

**Claude Code Solutions:**
1. **Parallel Component Checking**:
   ```python
   # Create specialized debugging subagents
   /subagent create api-checker "Test all API connections and responses"
   /subagent create db-checker "Validate database operations and integrity"
   /subagent create file-checker "Verify file permissions and operations"
   /subagent create network-checker "Test network connectivity and timeouts"

   # Run all checks simultaneously
   /subagent execute-all --parallel
   ```

2. **Coordinated Investigation**:
   ```python
   # Main agent coordinates specialized debugging
   coordinator = SubagentCoordinator([
       "system-health-checker",
       "performance-analyzer",
       "error-pattern-detector",
       "cost-impact-assessor"
   ])

   results = await coordinator.investigate_issue(problem_description)
   ```

### 🔌 MCP Server Integration for External System Debugging

#### Problem: "Need to check external services and integrations"
```
OpenAI API working but ElevenLabs failing intermittently
```

**Claude Code Solutions:**
1. **Health Monitoring with MCP**:
   ```python
   # Set up automated health checks
   /mcp-setup health-monitor

   # Monitor external services
   /mcp__health__check-apis --services="openai,elevenlabs,chromadb"

   # Get detailed service status
   /mcp__health__detailed-status --include-latency --include-costs
   ```

2. **Cross-Service Debugging**:
   ```python
   # Use MCP to coordinate external service testing
   mcp_results = {
       "github": await mcp.github.check_repo_status(),
       "openai": await mcp.openai.test_connection(),
       "filesystem": await mcp.filesystem.validate_permissions()
   }
   ```

### ⚙️ Hooks for Automated Error Detection and Recovery

#### Problem: "Errors happen but aren't caught early enough"
```
Issues only discovered after expensive API calls complete
```

**Claude Code Solutions:**
1. **Pre-execution Validation Hooks**:
   ```python
   # .claude/hooks/pre-tool-use.py
   def pre_api_call_validation(context):
       """Validate before expensive operations"""
       if context.estimated_cost > 5.0:
           # Run cheaper validation first
           validate_inputs(context.inputs)
           test_with_mock_data(context.params)
       return context

   # Hook automatically runs before any API call
   ```

2. **Automated Recovery Hooks**:
   ```python
   # .claude/hooks/post-tool-use.py
   def post_execution_recovery(result):
       """Handle failures gracefully"""
       if result.status == "failed":
           # Log detailed error information
           log_error_context(result)

           # Attempt automatic recovery
           if result.error_type == "rate_limit":
               schedule_retry(result.operation, delay=60)
           elif result.error_type == "timeout":
               retry_with_smaller_batch(result.operation)

       return result
   ```

### 📊 File Operation Analysis for Content Quality Issues

#### Problem: "Generated content quality is inconsistent"
```
Some episodes have great scripts, others are poor quality
```

**Claude Code Solutions:**
1. **Content Quality Validation**:
   ```python
   # Use Claude Code to analyze file patterns
   /analyze-files "projects/*/scripts/*.txt" --quality-metrics

   # Deep content analysis
   ultrathink the patterns in successful vs failed episode scripts

   # Automated quality gates
   /hook create quality-gate "Validate script quality before audio synthesis"
   ```

2. **Pattern Recognition Analysis**:
   ```python
   # Let Claude Code find patterns in successful content
   quality_patterns = await analyze_content_quality(
       successful_episodes=["episode_001.txt", "episode_005.txt"],
       failed_episodes=["episode_003.txt", "episode_007.txt"],
       analysis_depth="ultrathink"
   )
   ```

---

## 🔧 Claude Code-Specific Issue Resolution

### Memory and Context Management Problems

#### Problem: "Claude Code losing context or giving inconsistent responses"
```
Responses change dramatically during long sessions
```

**Solutions:**
1. **Context Window Management**:
   ```bash
   # Clear context regularly
   /clear

   # Check context usage
   /context-status

   # Compact conversation history
   /compact

   # Reset with key information preserved
   /reset --preserve-project-memory
   ```

2. **Memory Optimization**:
   ```bash
   # Update project memory with key learnings
   # This is my current learning progress

   # Initialize structured memory
   /init --enhanced-memory

   # Check memory file
   /memory
   ```

### Subagent Orchestration Failures

#### Problem: "Subagents not coordinating properly"
```
Subagents giving conflicting results or not communicating
```

**Solutions:**
1. **Subagent Debugging**:
   ```python
   # Check subagent status
   /subagent list --detailed

   # Debug specific subagent
   /subagent debug script-writer --verbose

   # Reset problematic subagent
   /subagent reset quality-evaluator --preserve-learning
   ```

2. **Coordination Fixes**:
   ```python
   # Explicit coordination protocol
   /subagent coordinate --protocol="sequential" --validation="strict"

   # Test subagent communication
   /subagent test-communication --all-pairs
   ```

### MCP Server Connectivity Problems

#### Problem: "MCP servers not responding or giving errors"
```
MCP server connection failed or timeout errors
Failed to connect to elevenlabs
Failed to connect to perplexity
```

**Solutions:**
1. **MCP Diagnostics**:
   ```bash
   # Check MCP server status (use /mcp for shorthand)
   claude mcp list
   /mcp

   # Test if API keys are in environment
   echo "Perplexity key exists: $(if [ -n "$PERPLEXITY_API_KEY" ]; then echo 'Yes'; else echo 'No'; fi)"
   echo "ElevenLabs key exists: $(if [ -n "$ELEVENLABS_API_KEY" ]; then echo 'Yes'; else echo 'No'; fi)"
   ```

2. **API Key Configuration Issues** (MOST COMMON):

   **Technical Explanation**: MCP servers run as subprocesses and need API keys in their execution environment. Claude Code doesn't automatically load .env files for MCP servers.

   **Simple Breakdown**: It's like giving someone a locked box but forgetting to give them the key - the MCP servers need the API keys when they start, not after.

   **Step-by-Step Fix**:
   ```bash
   # 1. Create .env file with your API keys
   cat > .env << 'EOF'
   PERPLEXITY_API_KEY=pplx-your-actual-key-here
   ELEVENLABS_API_KEY=sk_your-actual-key-here
   EOF

   # 2. Load the API keys into your current shell
   source .env

   # 3. Verify keys are loaded
   echo "Perplexity: ${PERPLEXITY_API_KEY:0:10}..."
   echo "ElevenLabs: ${ELEVENLABS_API_KEY:0:10}..."

   # 4. Remove old MCP configurations
   claude mcp remove elevenlabs
   claude mcp remove perplexity

   # 5. Re-add with environment variables
   claude mcp add-json elevenlabs '{
     "command": "python3",
     "args": ["-m", "elevenlabs_mcp"],
     "env": {"ELEVENLABS_API_KEY": "'$ELEVENLABS_API_KEY'"}
   }'

   claude mcp add-json perplexity '{
     "command": "node",
     "args": ["/full/path/to/perplexity-mcp/dist/index.js"],
     "env": {"PERPLEXITY_API_KEY": "'$PERPLEXITY_API_KEY'"}
   }'

   # 6. Check status
   claude mcp list
   ```

   **Permanent Solution - Create Startup Script**:
   ```bash
   # Create start-claude.sh
   cat > start-claude.sh << 'EOF'
   #!/bin/bash
   # Load API keys and start Claude Code

   if [ -f .env ]; then
       source .env
       echo "✓ API keys loaded from .env"
   else
       echo "✗ .env file not found!"
       exit 1
   fi

   # Start Claude Code with environment
   claude
   EOF

   chmod +x start-claude.sh

   # Always start Claude with:
   ./start-claude.sh
   ```

3. **Common MCP Issues and Fixes**:
   ```bash
   # Issue: Empty environment variable (exists but no value)
   # Check: echo "Length: ${#PERPLEXITY_API_KEY}"
   # Fix: Make sure .env has actual values, not empty strings

   # Issue: MCP server path incorrect
   # Fix: Use absolute paths in MCP configuration
   find ~ -name "perplexity-mcp" -type d 2>/dev/null

   # Issue: Python/Node not found
   # Fix: Ensure correct executables
   which python3
   which node
   ```

### Hook Execution Errors

#### Problem: "Hooks failing or causing unexpected behavior"
```
Pre-tool-use hook throwing errors and blocking operations
```

**Solutions:**
1. **Hook Debugging**:
   ```bash
   # List all active hooks
   /hooks list --status

   # Test hook in isolation
   /hooks test pre-tool-use --dry-run

   # Disable problematic hook temporarily
   /hooks disable quality-gate --temporary
   ```

2. **Hook Recovery**:
   ```python
   # Safe mode - disable all hooks
   /hooks safe-mode --duration="1hour"

   # Gradually re-enable hooks
   /hooks enable pre-tool-use --test-first
   ```

---

## 🎯 Advanced Debugging Workflows

### Comprehensive System Health Check

**Technical Explanation**: A systematic approach using Claude Code's advanced features to diagnose complex AI orchestration issues by leveraging thinking modes, subagents, and automated tooling.

**Simple Breakdown**: Like taking your car to a mechanic who can check everything at once - engine, brakes, electrical system - Claude Code can check all parts of your AI system simultaneously and give you a complete health report.

```python
# Complete system diagnostic workflow
/diagnostic-workflow start

# Step 1: Thinking mode analysis
ultrathink the current system state and potential issues

# Step 2: Subagent-based component checking
/subagent create-diagnostic-team

# Step 3: MCP server validation
/mcp__health__comprehensive-check

# Step 4: Hook-based automated testing
/hooks run-diagnostic-suite

# Step 5: Generate comprehensive report
/generate-health-report --include-recommendations
```

### Cost Spike Investigation

When your episode costs suddenly jump from $5 to $50:

```python
# Automated cost analysis using thinking modes
think harder about the cost differences between recent episodes

# Subagent-based cost breakdown
/subagent create cost-analyzer "Compare last 5 episodes for cost differences"

# MCP integration for external cost tracking
/mcp__costs__analyze-spike --date-range="last-week"

# Hook-based prevention
/hook create cost-guard "Block operations if projected cost > $10"
```

### Quality Degradation Analysis

When episode quality suddenly drops:

```python
# Deep quality analysis with thinking modes
ultrathink the patterns in quality metrics across all episodes

# Subagent quality investigation
/subagent create quality-detective "Find root cause of quality issues"

# Content analysis with file operations
/analyze-quality-trends --episodes="all" --metrics="comprehension,engagement,brand"

# Automated quality recovery
/hook create quality-recovery "Auto-regenerate if quality < 0.8"
```

---

## 🔍 Performance Optimization Debugging

### Slow Episode Generation

#### Problem: "Episodes taking 2+ hours to generate"
```
Expected: 15-30 minutes per episode
Actual: 2-3 hours per episode
```

**Claude Code Solutions:**
1. **Performance Profiling**:
   ```python
   # Use thinking modes for bottleneck analysis
   think harder about the performance bottlenecks in episode generation

   # Profile with subagents
   /subagent create performance-profiler "Identify slowest operations"

   # Automated timing analysis
   /hooks enable performance-tracker --detailed-timing
   ```

2. **Optimization Workflow**:
   ```python
   # Step-by-step optimization
   optimization_plan = await generate_optimization_plan(
       current_performance=get_current_metrics(),
       target_performance="15-30 minutes",
       thinking_mode="ultrathink"
   )
   ```

### Memory Usage Issues

#### Problem: "High memory usage causing crashes"
```
Python process growing to 8GB+ memory usage
```

**Solutions:**
1. **Memory Analysis with Claude Code**:
   ```python
   # Analyze memory patterns
   ultrathink the memory usage patterns in our agent orchestration

   # Subagent-based memory monitoring
   /subagent create memory-monitor "Track memory usage across all operations"

   # Automated memory management
   /hook create memory-guard "Clean up large objects after operations"
   ```

---

## 💡 Intelligent Error Recovery

### Self-Healing System Design

**Technical Explanation**: Using Claude Code's automation capabilities to create systems that can diagnose, fix, and learn from their own errors without human intervention.

**Simple Breakdown**: Like a car that can detect when it's having trouble, pull over safely, fix the problem, and then continue driving - but for your AI podcast system.

```python
# Self-healing workflow
/create-healing-system --components="all" --auto-recovery="true"

# Components:
# 1. Error detection (hooks)
# 2. Diagnosis (thinking modes + subagents)
# 3. Recovery attempt (automated fixes)
# 4. Learning (memory updates)
# 5. Prevention (improved prompts/validation)
```

### Adaptive Quality Control

```python
# Quality system that learns and improves
/adaptive-quality-system create \
  --learning-rate="moderate" \
  --auto-tune="true" \
  --feedback-integration="enabled"

# System automatically:
# 1. Detects quality patterns (subagents)
# 2. Adjusts prompts (thinking modes)
# 3. Updates validation rules (hooks)
# 4. Learns from successful episodes (memory)
```

---

## 📚 Cross-Reference Links

<cross-references>
  <memory-issues>@16_memory_management_system.md for detailed memory optimization</memory-issues>
  <command-problems>@17_command_reference_guide.md for command troubleshooting</command-problems>
  <thinking-modes>@19_thinking_modes_guide.md for diagnostic analysis techniques</thinking-modes>
  <hooks-issues>@20_hooks_automation_system.md for hook debugging</hooks-issues>
  <mcp-problems>@21_mcp_integration_guide.md for MCP server troubleshooting</mcp-problems>
  <subagent-coordination>@22_subagents_guide.md for orchestration debugging</subagent-coordination>
  <navigation-help>@NAVIGATION.md for domain navigation, @../NAVIGATION_INDEX.md for master navigation</navigation-help>
</cross-references>

---

## Debug Mode Setup

### Create debug.py - Enhanced with Claude Code
```python
import logging
import os
from dotenv import load_dotenv

def setup_debug():
    # Enable all logging
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )

    # Load environment
    load_dotenv()

    # Print configuration
    print("=== DEBUG MODE ===")
    print(f"Python Path: {os.sys.path}")
    print(f"Working Dir: {os.getcwd()}")
    print(f"ENV Loaded: {bool(os.getenv('OPENAI_API_KEY'))}")
    print("==================")

if __name__ == "__main__":
    setup_debug()

    # Test imports
    try:
        from core.agents import ResearchCoordinator
        print("✅ Agents import successful")
    except Exception as e:
        print(f"❌ Agents import failed: {e}")

    try:
        from core.orchestration.server import app
        print("✅ Server import successful")
    except Exception as e:
        print(f"❌ Server import failed: {e}")
```

### Claude Code Enhanced Debug Workflow

**Technical Explanation**: Combines traditional debugging with Claude Code's AI-powered analysis capabilities for comprehensive system diagnosis.

**Simple Breakdown**: Like having a debugging buddy who's really smart and can check multiple things at once while you focus on the main problem.

```python
# Enhanced debug workflow using Claude Code
/debug-workflow start

# Step 1: System health check
/diagnostic-workflow start --comprehensive

# Step 2: Thinking mode problem analysis
ultrathink the current system state and all potential failure points

# Step 3: Subagent-based component testing
/subagent create-debug-team --components="api,database,filesystem,network"

# Step 4: MCP integration testing
/mcp__health__test-all-connections --verbose

# Step 5: Hook validation
/hooks test-all --dry-run --report-failures

# Step 6: Generate debug report
/generate-debug-report --include-recommendations --include-fixes
```

### Quick Debug Commands

```bash
# Instant system status
/system-status --detailed

# Check all integrations
/integration-health-check

# Test thinking modes
think about the current system issues

# Validate subagent coordination
/subagent test-coordination --all

# MCP connectivity test
/mcp test-all --timeout=30

# Hook system validation
/hooks validate-all --safe-mode
```

---

## Common Error Messages Decoded

### "Connection refused"
**Means**: Service isn't running or wrong port
**Fix**: Start the service or check port number

### "Permission denied"
**Means**: Don't have rights to file/directory
**Fix**: `chmod` or run with correct user

### "No such file or directory"
**Means**: Path is wrong or file doesn't exist
**Fix**: Check path, create file if needed

### "JSON decode error"
**Means**: API returned invalid JSON
**Fix**: Print raw response, check format

### "Timeout error"
**Means**: Request took too long
**Fix**: Increase timeout or simplify request

### "Out of memory"
**Means**: Too much data in memory
**Fix**: Process in smaller batches

---

## 🆘 Claude Code Troubleshooting Scenarios

### Scenario 1: Thinking Modes Not Working Effectively

#### Problem: "Claude Code thinking modes giving shallow analysis"
```
Using 'ultrathink' but responses are still superficial
```

**Diagnosis and Solutions:**
```python
# Check context window usage
/context-status --detailed

# Clear context if too full
/clear

# Try progressive thinking escalation
think about this issue
think hard about this issue
think harder about this issue
ultrathink this issue with maximum depth

# Validate with subagent analysis
/subagent create deep-analyst "Provide comprehensive analysis of this issue"
```

### Scenario 2: Subagent Coordination Breakdown

#### Problem: "Subagents giving conflicting recommendations"
```
Research agent says use GPT-4, Script agent says use Claude
```

**Diagnosis and Solutions:**
```python
# Check subagent coordination settings
/subagent list --coordination-status

# Reset coordination protocol
/subagent coordinate --protocol="consensus-required" --conflict-resolution="majority"

# Create supervisor subagent
/subagent create supervisor "Resolve conflicts between other subagents"

# Manual coordination override
/subagent coordinate --manual-override --decision="use-gpt-4-for-research"
```

### Scenario 3: MCP Server Integration Failures

#### Problem: "MCP servers connecting but not providing useful data"
```
GitHub MCP connects but can't access repository information
```

**Diagnosis and Solutions:**
```python
# Validate MCP server permissions
/mcp validate-permissions github --detailed

# Test MCP server with simple requests
/mcp__github__test-basic-access

# Reconfigure MCP server with fresh authentication
/mcp reconfigure github --force-refresh --permissions="full"

# Create fallback workflow without MCP
/workflow create-fallback --no-mcp-dependencies
```

### Scenario 4: Hooks Causing System Instability

#### Problem: "System becomes unreliable after adding hooks"
```
Pre-tool-use hook taking too long, blocking all operations
```

**Diagnosis and Solutions:**
```python
# Identify problematic hooks
/hooks analyze-performance --show-slowest

# Run hooks in safe mode
/hooks safe-mode --disable-slowest --timeout=5

# Test hooks individually
/hooks test pre-tool-use --isolated --timeout=10

# Create lightweight hook alternatives
/hooks create-minimal-version pre-tool-use --essential-only
```

### Scenario 5: Memory Management Problems

#### Problem: "Claude Code forgetting important project context"
```
System doesn't remember previous solutions or patterns
```

**Diagnosis and Solutions:**
```python
# Check memory file status
/memory --validate --show-corruption

# Rebuild memory from session history
/memory rebuild --from-history --include-learnings

# Create explicit memory checkpoints
# Key learning: Cost optimization works best with batch processing

# Initialize enhanced memory system
/init --memory-enhanced --checkpoint-frequency="high"
```

### Scenario 6: File Operations Not Working Correctly

#### Problem: "Claude Code can't read or modify project files consistently"
```
File operations succeed but changes aren't persistent
```

**Diagnosis and Solutions:**
```python
# Validate file system permissions
/filesystem-check --permissions --write-test

# Test file operations in isolation
/test-file-ops --create --modify --delete --verify

# Check for file system conflicts
/hooks list --file-system-hooks --conflicts

# Use MCP filesystem integration
/mcp__filesystem__diagnostic-check --comprehensive
```

### Scenario 7: Context Window Optimization Issues

#### Problem: "Running out of context space quickly"
```
Context limit reached with minimal conversation history
```

**Diagnosis and Solutions:**
```python
# Analyze context usage patterns
/context analyze --show-usage-patterns --recommend-optimization

# Implement aggressive context management
/context optimize --aggressive --preserve-essential

# Create context-efficient workflows
/workflow create-minimal-context --essential-only

# Use subagents to process in smaller chunks
/subagent create context-saver "Process tasks with minimal context usage"
```

### Scenario 8: Performance Degradation Over Time

#### Problem: "System slows down during long development sessions"
```
Response times increasing from 30 seconds to 5+ minutes
```

**Diagnosis and Solutions:**
```python
# Performance analysis with thinking modes
think harder about performance degradation patterns in this session

# Subagent performance monitoring
/subagent create performance-monitor "Track system performance metrics"

# Clean up accumulated state
/cleanup --memory --temporary-files --cached-data

# Restart with preserved state
/restart --preserve-project-memory --preserve-learnings
```

---

## Emergency Recovery Steps

### When Everything Is Broken:

1. **Stop Everything**
   ```bash
   # Kill all Python processes
   pkill python
   ```

2. **Clean State**
   ```bash
   # Remove cache and temp files
   rm -rf __pycache__
   rm -rf .pytest_cache
   rm -rf chroma_db
   ```

3. **Fresh Environment**
   ```bash
   # Rebuild virtual environment
   rm -rf venv
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

4. **Test Basics**
   ```python
   # test_basic.py
   print("Python works")
   import fastapi
   print("FastAPI works")
   import chromadb
   print("ChromaDB works")
   ```

5. **Start Simple**
   - Run server without agents
   - Test one endpoint
   - Add complexity gradually

---

## Learning From Errors

### Keep an Error Journal
```markdown
## Error Log Entry

**Date**: 2024-XX-XX
**Error**: [Error message]
**Context**: What I was trying to do
**Solution**: How I fixed it
**Lesson**: What I learned
**Prevention**: How to avoid next time
```

### Common Beginner Mistakes

1. **Not activating virtual environment**
   - Always check: `which python`

2. **Wrong directory**
   - Always run from project root

3. **Missing environment variables**
   - Always check: `echo $OPENAI_API_KEY`

4. **Forgetting await with async**
   ```python
   # BAD: result = agent.execute()
   # GOOD: result = await agent.execute()
   ```

5. **Not handling errors**
   ```python
   try:
       result = risky_operation()
   except Exception as e:
       print(f"Error: {e}")
       # Handle gracefully
   ```

---

## Getting Help

### Before Asking for Help:
1. Read the error message carefully
2. Google the exact error
3. Check this guide
4. Try the debug script
5. Isolate the problem

### How to Ask for Help:
```markdown
**Problem**: [One sentence description]
**Error Message**: [Full error]
**What I Tried**: [List of attempts]
**Code**: [Minimal example]
**Environment**: Python version, OS
```

### Where to Get Help:
1. GitHub Issues (for code problems)
2. Discord communities (for quick questions)
3. Stack Overflow (for common errors)
4. Reddit r/learnpython (for beginners)
5. Claude.ai (for explanations)

---

## Remember

**Every error is a learning opportunity!**

The difference between a beginner and an expert is that the expert has seen more errors and knows how to fix them.

Don't get discouraged - debugging is a core skill that you're developing alongside everything else.

**Your error-fixing skills are just as valuable as your coding skills!**

<validation-notes>
  <troubleshooting-methods>
    Troubleshooting methods validated from software engineering
    best practices and technical support methodologies (2025-08-10)
  </troubleshooting-methods>
  <claude-code-enhancements>
    Claude Code debugging capabilities validated from:
    - Anthropic Claude Code documentation (2025 release)
    - AI development environment best practices
    - Advanced debugging workflows for AI orchestration systems
    - Thinking modes, subagents, MCP servers, and hooks integration patterns
  </claude-code-enhancements>
  <scenarios-coverage>
    Added 8 new Claude Code-specific troubleshooting scenarios covering:
    thinking modes, subagent coordination, MCP integration, hooks management,
    memory systems, file operations, context optimization, performance issues
  </scenarios-coverage>
</validation-notes>

</document>
