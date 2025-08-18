# Troubleshooting Kit Context Package



## System diagnostics

<technical>
Systematic diagnostic procedures using scientific troubleshooting methodology: observe, hypothesize, test, analyze, resolve. Each diagnostic path includes specific commands, expected outputs, and decision trees for efficient problem resolution.
</technical>

<simple>
Like being a detective solving a mystery - you look for clues, form theories about what went wrong, test your theories, and fix the problem step by step.
</simple>

@ references not working, missing contexts, auto-loading problems
ls .claude/context-packages/
grep -r "@" .claude/
wc -l CLAUDE.md .claude/NAVIGATION.md
.claudeignore blocking needed files
Missing context package files
Broken @ reference syntax
ElevenLabs errors, MCP connection issues, authentication failures
echo $ELEVENLABS_API_KEY | wc -c
claude mcp list
curl -H "xi-api-key: $ELEVENLABS_API_KEY" https://api.elevenlabs.io/v1/user
Missing or expired API keys
MCP servers not configured
Network connectivity issues
API rate limiting
Agent errors, quality threshold failures, incomplete episodes
find .claude/level-2-production/sessions/ -name "*.json" | tail -5
grep "error\|failed" .claude/level-2-production/sessions/*/
ls -la projects/nobody-knows/output/
Quality thresholds too restrictive
Insufficient research data
Cost limits exceeded
TTS synthesis errors
Slow responses, high token usage, context overflow
find .claude -type f | wc -l
find .claude -name "*.md" -exec wc -l {} + | tail -1
grep -r "Technical:\|Simple:" .claude/ | wc -l
Too many files auto-loading
Context packages too large
Inefficient @ reference patterns

## Resolution procedures

<technical>
Step-by-step resolution procedures with validation checkpoints and rollback instructions. Each procedure includes prerequisites, execution steps, validation commands, and success criteria for reliable problem resolution.
</technical>

<simple>
Exact instructions for fixing each type of problem, like having a repair manual that tells you exactly which screws to turn and how to test if it worked.
</simple>

Identify specific @ reference that's failing

- 
                    

- 
                        
Check .claudeignore file
cat .claudeignore | grep -E "context|packages"
Ensure context-packages/ is not excluded

- 
                        
Verify context package exists
ls -la .claude/context-packages/[package-name].xml
File exists and is readable

- 
                        
Test @ reference syntax
Try loading the specific @ reference
Context loads without errors
@ reference loads complete context successfully
Identify which API is failing

- 
                    

- 
                        
Verify API key is set
echo $[API_KEY_NAME] | head -c 20
Key exists and starts correctly

- 
                        
Test API connectivity
Use appropriate API test command
Receives successful response

- 
                        
Check MCP server status
claude mcp list | grep [server-name]
Server shows as available
API calls succeed and return expected data
Identify which stage is failing

- 
                    

- 
                        
Review session logs
cat .claude/level-2-production/sessions/[session]/[step].json
Identify specific error or failure point

- 
                        
Check quality thresholds
grep "threshold" .claude/level-2-production/config/quality_gates.yaml
Thresholds are reasonable and achievable

- 
                        
Retry with adjustments
Run production step with modified parameters
Step completes successfully
Production pipeline completes end-to-end
Identify performance bottleneck

- 
                    

- 
                        
Audit auto-loading
Check what files are loading automatically
Only essential files auto-load

- 
                        
Optimize context packages
Review context package sizes and usage
Packages are focused and efficient

- 
                        
Use /clear frequently
/clear to reset context periodically
Maintains responsive performance
System responds quickly with efficient token usage

## Common errors

<technical>
Catalog of frequently encountered error patterns with specific symptoms, root causes, and proven resolution methods. Each error entry includes the exact error message pattern, diagnostic approach, and step-by-step fix procedure.
</technical>

<simple>
A collection of the most common things that go wrong and exactly how to fix them - like a FAQ for problems.
</simple>

"fatal: pathspec 'file.md' did not match any files"
Git staging issue - file doesn't exist or wrong path
Check if file exists: ls -la [path]
1. Verify file exists
2. Use correct path
3. git add . if multiple files
"Error: Request timeout" (ElevenLabs)
Text too long or API overloaded
Check text length and API status
1. Split text into smaller chunks
2. Retry with exponential backoff
3. Verify API key and credits
"Quality threshold not met: comprehension=0.78"
Script too complex or unclear for target audience
Review script for complexity indicators
1. Simplify language and concepts
2. Add more explanatory content
3. Adjust quality threshold if appropriate
"Context window exceeded"
Too much content loaded simultaneously
Check current context size
1. Use /clear to reset context
2. Load smaller context packages
3. Break operation into smaller steps
"@ reference not found"
Missing context package or incorrect path
Check if target file exists
1. Verify context package exists
2. Check @ reference syntax
3. Ensure .claudeignore doesn't block it

## Error prevention

<technical>
Proactive measures to prevent common issues through systematic validation, monitoring, and maintenance procedures. Prevention strategies focus on early detection and automated checks.
</technical>

<simple>
Ways to stop problems before they happen - like regular car maintenance instead of waiting for breakdowns.
</simple>

Weekly
find .claude -name "*.md" | xargs grep -l "broken\|error"
git status --porcelain | wc -l
ls .claude/context-packages/ | wc -l
Detect issues before they cause failures
Before each production run
Test ElevenLabs API connection
Verify MCP server availability
Check API credit balances
Ensure external dependencies are functional
After any context changes
Test all @ references load correctly
Verify educational format compliance
Check token usage is within targets
Maintain context system integrity
After each episode production
Review quality scores and trends
Adjust thresholds if consistently too high/low
Monitor cost per episode trends
Maintain production quality and efficiency

## Escalation procedures

<technical>
When standard troubleshooting fails, escalation procedures provide systematic approaches for complex issues, including data collection, documentation requirements, and decision criteria for different escalation paths.
</technical>

<simple>
When the usual fixes don't work, these are the bigger guns - more advanced techniques and when to ask for help.
</simple>

Standard procedures fail after 2 attempts
Enable debug logging
Run comprehensive system diagnostics
Review all recent changes
Test with minimal configuration
2-4 hours maximum
Advanced troubleshooting fails to resolve
Identify last known good state
Use git to revert to stable commit
Restore from backup if available
Rebuild system incrementally
4-8 hours maximum
Systemic issues or repeated failures
Document all failure patterns
Review system architecture decisions
Consider fundamental design changes
Plan migration to improved architecture
1-2 days for planning

---

*Converted from XML to Markdown for elegant simplicity*
*Original: troubleshooting-kit.xml*
*Conversion: Mon Aug 18 00:01:19 EDT 2025*
