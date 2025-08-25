# Educational Compliance Implementation Plan

## Phase 1: Agent Template Update (Day 1)

### Step 1.1: Update Agent Template
```yaml
Location: .claude/shared/agent-template.md
Action: Add educational explanation sections to template

Add after line 25 (# [Agent Name] - [Primary Role]):
```

```markdown
## Educational Context

**Technical:** [Professional explanation of what this agent does and why it matters in the system architecture]

**Simple:** [Everyday analogy that makes the agent's purpose immediately understandable]

**Connection:** [How understanding this agent teaches broader software engineering principles]
```

### Step 1.2: Create Example Implementation
```yaml
Example for Research Orchestrator:

## Educational Context

**Technical:** This agent implements the Observer pattern to coordinate multiple specialized research agents, managing state transitions and data flow between asynchronous operations while maintaining transactional integrity.

**Simple:** Think of it like a project manager at a research firm - they don't do the research themselves, but they assign tasks to specialists, track progress, and ensure all pieces come together into a complete report.

**Connection:** This teaches you distributed system coordination, state management, and the importance of separation of concerns in complex workflows.
```

## Phase 2: Research Stream Agents (Day 2-3)

### Step 2.1: Update 01_research_orchestrator.md
- Add educational context after line 7
- Add explanations for each orchestration step
- Include learning outcomes for session management

### Step 2.2: Update 02_deep_research_agent.md
- Explain Perplexity integration patterns
- Add dual explanations for search strategies
- Document learning value of multi-round research

### Step 2.3: Update 03_question_generator.md
- Explain question generation methodology
- Add educational value of systematic inquiry
- Connect to research methodology principles

### Step 2.4: Update 04_research_synthesizer.md
- Explain knowledge structuring patterns
- Add educational context for synthesis techniques
- Connect to information architecture principles

## Phase 3: Production Stream Agents (Day 4-6)

### Step 3.1-3.10: Update Each Production Agent
For each agent in production stream:
1. Add educational context section
2. Explain key decisions with dual explanations
3. Add learning connections for each major process
4. Document transferable skills gained

Priority order:
1. 03_script_writer.md (most complex)
2. 01_production_orchestrator.md (coordination patterns)
3. 04_quality_claude.md & 05_quality_gemini.md (evaluation patterns)
4. Remaining agents in sequence

## Phase 4: Validation & Testing (Day 7)

### Step 4.1: Create Compliance Validator
```bash
#!/bin/bash
# validate_educational_compliance.sh

echo "Checking educational compliance in agents..."

for agent in $(find .claude/agents -name "*.md"); do
    echo "Checking $agent..."

    # Check for Technical: explanation
    if ! grep -q "Technical:" "$agent"; then
        echo "❌ Missing Technical explanation in $agent"
    fi

    # Check for Simple: explanation
    if ! grep -q "Simple:" "$agent"; then
        echo "❌ Missing Simple explanation in $agent"
    fi

    # Check for Connection: explanation
    if ! grep -q "Connection:" "$agent"; then
        echo "❌ Missing Connection explanation in $agent"
    fi
done
```

### Step 4.2: Run Validation
- Execute validator script
- Document any missing explanations
- Iterate until 100% compliance

## Phase 5: Integration Testing (Day 8)

### Step 5.1: Test with Production Commands
- Run `/produce-research` with monitoring for educational output
- Verify agents provide explanations during execution
- Check that learning value is clear

### Step 5.2: Update Documentation
- Update .claude/README.md with educational compliance
- Add examples to NAVIGATION_INDEX.md
- Update contribution guidelines

## Success Criteria
- [ ] All 14 primary agents have educational context sections
- [ ] Each agent has 3+ dual explanations in process steps
- [ ] Validation script shows 100% compliance
- [ ] Production runs demonstrate educational value
- [ ] Documentation updated with examples
