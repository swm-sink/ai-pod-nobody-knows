# Session Coordination Framework



## Overview
Framework Overview
This framework ensures seamless coordination between agents through shared session state,
enabling the podcast production pipeline to maintain context, track progress, and handle failures gracefully.

## Session structure
Session Structure
Session Identification
ep_{number}_{YYYYMMDD}_{HHMM}
1
consciousness_hard_problem
3
general
2024-08-11T14:30:00Z
in_progress
Session State Management
INITIALIZED → RESEARCHING → WRITING → EVALUATING → SYNTHESIZING → COMPLETE
Each stage can transition to FAILED → RETRY
projects/nobody-knows/output/sessions/
ep{number}_session_{date}.json
Session State Schema
ep_001_20240811_1430
1
The Hard Problem of Consciousness
3
27
writing
["research"]
["evaluation", "synthesis"]
0
0
complete
projects/nobody-knows/output/research/ep001_research_consciousness_20240811.md
1680
0.00
0.92
in_progress
2024-08-11T14:58:00Z
2024-08-11T15:18:00Z
pending
not_implemented
0.92
null
null
null
0.00
0.00
0.00
0.00
0.00
9.00
true
2024-08-11T14:30:00Z
2024-08-11T14:58:00Z
2024-08-11T14:58:00Z
2024-08-11T14:58:00Z

## Coordination protocol
Agent Coordination Protocol
Session Initialization
episode_number
topic
complexity_level

- 
            Generate session ID

- 
            Create session structure

- 
            Initialize pipeline state

- 
            Save session state

- 
            Return session ID
Agent Handoff Protocols
path/to/research.md
3
["list", "of", "narratives"]
{...}
true
true
true
path/to/script.md
4000
27.5
3
true
true
true
path/to/script.md
path/to/quality.json
PASS
true
true
true
State Update Mechanism
session_id
agent_name
update

- 
            Load current session state

- 
            Update agent-specific data

- 
            Update pipeline state if complete

- 
            Update timestamps

- 
            Update cost tracking

- 
            Save updated session state

## Error handling
Error Handling
Failure Recovery
session_id
agent_name
error

- 
            Record failure status and error

- 
            Increment failed attempts counter

- 
            Determine retry strategy (max 3 retries)

- 
            Either retry agent or escalate failure

- 
            Save updated session state
Quality Gate Failures
session_id
quality_report

- 
            Analyze failure type from quality report

- 
            Route back to appropriate stage with feedback

- 
            Set specific adjustments needed

- 
            Update pipeline state accordingly
Return to script_writer with feedback
Return to script_writer for duration adjustment

## Monitoring
Session Monitoring
Progress Tracking
Calculated from completed stages
Current pipeline stage
Time estimate
Running total
Current metrics
Session Dashboard
List of in-progress sessions
Count of finished episodes
Count of failures
Minutes per episode
Dollars per episode
Average quality score

## Agent implementation
Implementation in Agents
Standard Agent Pattern

- 
          Load session state

- 
          Validate ready for stage

- 
          Update session progress to "in_progress"

- 
          Update session state with results

- 
          Include output file path

- 
          Record actual cost

- 
          Include quality metrics

- 
          Call handle_agent_failure with error details
```


## Session commands
Session Commands
claude-code session init --episode 1 --topic "consciousness" --complexity 3
Initialize new session
claude-code session status ep_001_20240811_1430
Check session status
claude-code session resume ep_001_20240811_1430
Resume failed session
claude-code session dashboard
View session dashboard
Production Pipeline
Multi-Agent Orchestration
Cost Optimization

---

*Converted from XML to Markdown for elegant simplicity*
*Original: session-coordination.xml*
*Conversion: Mon Aug 18 00:01:18 EDT 2025*
