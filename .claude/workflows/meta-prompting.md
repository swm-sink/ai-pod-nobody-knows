# Meta-Prompting Workflow

## 🔄 MANDATORY 10-STEP META-PROMPTING PROTOCOL

### Scope
Applies to ALL development tasks, code generation, system modifications, problem-solving, and analysis activities. NO EXCEPTIONS.

### Critical Mandate
EVERY TASK MUST FOLLOW THE 10-STEP SEQUENCE IN EXACT ORDER
FAILURE TO COMPLETE ANY STEP BEFORE PROCEEDING INVALIDATES ALL WORK
NO BYPASS OPTIONS - NO SHORTCUTS - NO ASSUMPTIONS ALLOWED

### Available Commands

- `/explore` - Problem domain investigation (Step 1)
- `/research` - Deep knowledge research (Step 2-3)
- `/plan` - Strategic implementation planning (Step 4)
- `/decompose` - Task decomposition and sequencing (Step 5)
- `/implement-tdd` - Test-driven development implementation (Step 6)
- `/refactor-tdd` - Test-driven refactoring (Step 6 continued)
- `/assess` - Comprehensive quality assessment (Step 7)
- `/validate` - Integration and production validation (Step 8)
- `/commit` - Production deployment and change management (Step 9)
- `/retrospect` - Learning capture and process improvement (Step 10)

**Command Reference:** @commands/meta-prompting/ directory contains detailed specifications
**Template Reference:** @prompts/meta_prompts/ directory contains structured templates

### Protocol Steps

#### Step 1: EXPLORE (MANDATORY)
**Command:** `/explore`
**Requirement:** Deep analysis of current state and requirements
**Action:** Examine problem space, constraints, and objectives comprehensively
**Validation:** Must demonstrate thorough understanding before proceeding
**Blocking Condition:** NO analysis = NO progression

#### Step 2-3: RESEARCH (MANDATORY)
**Command:** `/research`
**Requirement:** Use research tools for knowledge gaps and validation
**Action:** Validate assumptions, gather authoritative sources, verify claims
**Validation:** Must mark any unverified information as UNVERIFIED
**Blocking Condition:** NO verification = NO progression

#### Step 4: PLAN (MANDATORY)
**Command:** `/plan`
**Requirement:** Create detailed implementation plan BEFORE any code
**Action:** Design approach, sequence, validation criteria, rollback plan
**Validation:** Must have complete plan with success criteria defined
**Blocking Condition:** NO PLAN = NO CODE - ZERO TOLERANCE
**Critical Note:** THIS STEP IS THE PRIMARY ENFORCEMENT GATE

#### Step 5: DECOMPOSE (MANDATORY)
**Command:** `/decompose`
**Requirement:** Break complex tasks into atomic, manageable components
**Action:** Create sequential, independent sub-tasks with clear boundaries
**Validation:** Must demonstrate task atomicity and dependency mapping
**Blocking Condition:** NO decomposition = NO complex task execution

#### Step 6: IMPLEMENT_TDD (MANDATORY)
**Command:** `/implement-tdd` and `/refactor-tdd`
**Requirement:** Follow RED-GREEN-REFACTOR cycle for all implementations
**Action:** Test first, implement to pass, refactor for elegance
**Validation:** Must show TDD cycle completion for each component
**Blocking Condition:** NO TDD = NO implementation acceptance

#### Step 7: ASSESS (MANDATORY)
**Command:** `/assess`
**Requirement:** Comprehensive quality assessment before any commits
**Action:** Validate against requirements, test edge cases, verify standards
**Validation:** Must pass all quality gates and acceptance criteria
**Blocking Condition:** NO quality assessment = NO commits allowed

#### Step 8: VALIDATE (MANDATORY)
**Command:** `/validate`
**Requirement:** Ensure production readiness and system integration
**Action:** Test integration points, verify compatibility, validate performance
**Validation:** Must demonstrate full system compatibility
**Blocking Condition:** NO integration validation = NO production deployment

#### Step 9: COMMIT (MANDATORY)
**Command:** `/commit`
**Requirement:** Use structured commit messages following established patterns
**Action:** Commit with clear descriptions, proper attribution, version tracking
**Validation:** Must follow commit message standards and include evidence
**Blocking Condition:** NO structured commits = NO change acceptance

#### Step 10: RETROSPECT (MANDATORY)
**Command:** `/retrospect`
**Requirement:** Capture insights, lessons learned, and improvement opportunities
**Action:** Document what worked, what didn't, and what to optimize next time
**Validation:** Must produce actionable insights for future optimization
**Blocking Condition:** NO retrospection = NO learning captured = INCOMPLETE CYCLE

### Enforcement Mechanisms

**Rule: Command Usage** - Each step must use corresponding /command for execution
**Rule: Step Sequence** - Steps must be completed in exact numerical order 1→10
**Rule: Step Validation** - Each step requires explicit validation before progression
**Rule: No Skipping** - Skipping any step immediately invalidates entire workflow
**Rule: Plan Gate** - Step 4 (/plan) is the primary enforcement gate - NO CODE WITHOUT PLAN
**Rule: Quality Gate** - Step 7 (/assess) blocks all commits until quality verified
**Rule: Learning Capture** - Step 10 (/retrospect) must produce transferable insights

### Integration Requirements

#### Existing Protocols
- Must work harmoniously with Anti-Hallucination Protocol
- Must preserve Chain-of-Thought Mandate requirements
- Must respect Change Control Protocol approval gates
- Must maintain LLM Anti-Pattern Enforcement standards

#### Educational Alignment
- Each step must provide Technical/Simple/Connection explanations
- Must demonstrate learning value at every checkpoint
- Must preserve intellectual humility philosophy

### Violation Consequences
- **Immediate stop:** Any step bypass triggers immediate workflow termination
- **Work invalidation:** All work performed without proper step completion is invalid
- **Restart required:** Must restart from Step 1 after any protocol violation
- **No exceptions:** NO emergency bypasses, NO special cases, NO "just this once" allowed

### Success Criteria
- All 10 steps completed in sequence with validation evidence
- Each step demonstrates clear value and learning capture
- Final output meets quality standards and integration requirements
- Retrospective insights captured for continuous improvement
