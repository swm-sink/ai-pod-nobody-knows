<document type="development-requirements" version="1.0.0">
  <metadata>
    <created>2025-08-10</created>
    <purpose>Define mandatory Test-Driven Development requirements</purpose>
    <requires-approval>true</requires-approval>
    <validation-status>industry-standards-2025</validation-status>
  </metadata>

  <critical-notice>
    <requirement level="MANDATORY">
      NO production code without a failing test first.
      This is non-negotiable. TDD is the only accepted development method.
    </requirement>
  </critical-notice>

# Test-Driven Development Requirements Specification

<tdd-mandate>
  <core-principle>
    The test drives the design. The design drives the implementation.
    Never write production code to make a test pass until you have a failing test.
  </core-principle>
</tdd-mandate>

## The Sacred TDD Cycle

<tdd-cycle>
  <phase number="1" name="RED">
    <description>Write a failing test</description>
    <rules>
      - Test must fail for the right reason
      - Test must be minimal (test one thing)
      - Test must be clear about what it expects
      - Run test to ensure it fails
    </rules>
    <duration>5-10 minutes maximum</duration>
  </phase>

  <phase number="2" name="GREEN">
    <description>Write minimal code to pass</description>
    <rules>
      - Write ONLY enough code to make test pass
      - Do not optimize
      - Do not add features
      - Do not refactor
      - Just make it pass
    </rules>
    <duration>5-10 minutes maximum</duration>
  </phase>

  <phase number="3" name="REFACTOR">
    <description>Improve code quality</description>
    <rules>
      - Clean up duplication
      - Improve naming
      - Extract methods/classes
      - Ensure all tests still pass
      - Do not add functionality
    </rules>
    <duration>10-15 minutes maximum</duration>
  </phase>
</tdd-cycle>

## Project Test Structure

<test-structure>
  <directory-layout>
    ```
    tests/
    ├── unit/                    # 50% of tests
    │   ├── test_agents/
    │   │   ├── test_base_agent.py
    │   │   ├── test_research_agent.py
    │   │   ├── test_script_agent.py
    │   │   └── test_quality_agent.py
    │   ├── test_memory/
    │   │   └── test_memory_manager.py
    │   └── test_utils/
    │       └── test_helpers.py
    │
    ├── integration/             # 30% of tests
    │   ├── test_api/
    │   │   ├── test_endpoints.py
    │   │   └── test_workflows.py
    │   └── test_agent_coordination/
    │       └── test_pipeline.py
    │
    ├── e2e/                     # 20% of tests
    │   └── test_full_episode_production.py
    │
    ├── conftest.py              # Shared fixtures
    └── pytest.ini               # Configuration
    ```
  </directory-layout>

  <testing-pyramid>
    <level name="Unit Tests" percentage="50">
      <description>Test individual functions/methods in isolation</description>
      <characteristics>
        - Fast (milliseconds)
        - Isolated (no external dependencies)
        - Deterministic (same result every time)
        - Focused (one behavior per test)
      </characteristics>
    </level>

    <level name="Integration Tests" percentage="30">
      <description>Test component interactions</description>
      <characteristics>
        - Moderate speed (seconds)
        - Test boundaries between components
        - May use test databases
        - Verify contracts between modules
      </characteristics>
    </level>

    <level name="E2E Tests" percentage="20">
      <description>Test complete workflows</description>
      <characteristics>
        - Slower (seconds to minutes)
        - Test full user scenarios
        - Use real configurations
        - Verify system behavior
      </characteristics>
    </level>
  </testing-pyramid>
</test-structure>

## Test Requirements by Component

<component-testing>
  <component name="Agents">
    <unit-tests>
      - Test initialization
      - Test configuration validation
      - Test error handling
      - Test retry logic
      - Test cost tracking
    </unit-tests>
    <integration-tests>
      - Test agent coordination
      - Test data passing between agents
      - Test memory integration
    </integration-tests>
  </component>

  <component name="API">
    <unit-tests>
      - Test request validation
      - Test response formatting
      - Test error responses
    </unit-tests>
    <integration-tests>
      - Test endpoint behavior
      - Test authentication
      - Test database operations
    </integration-tests>
  </component>

  <component name="Memory">
    <unit-tests>
      - Test storage operations
      - Test retrieval logic
      - Test similarity calculations
    </unit-tests>
    <integration-tests>
      - Test ChromaDB integration
      - Test persistence
      - Test cleanup operations
    </integration-tests>
  </component>
</component-testing>

## Test Naming Conventions

<naming-conventions>
  <pattern>test_[unit]_[should]_[expected_behavior]_[when]_[condition]</pattern>

  <examples>
    <good>
      - test_research_agent_should_return_error_when_api_unavailable()
      - test_script_writer_should_generate_4000_words_when_given_valid_research()
      - test_quality_evaluator_should_fail_when_score_below_threshold()
    </good>

    <bad>
      - test_agent()  # Too vague
      - test_1()      # Meaningless
      - test_works()  # Not specific
    </bad>
  </examples>
</naming-conventions>

## Test Quality Requirements

<quality-requirements>
  <requirement name="Independence">
    <description>Tests must not depend on other tests</description>
    <implementation>
      - No shared state between tests
      - Each test sets up its own data
      - Tests can run in any order
      - Tests can run in parallel
    </implementation>
  </requirement>

  <requirement name="Repeatability">
    <description>Tests must produce same results every time</description>
    <implementation>
      - Mock external dependencies
      - Use fixed seeds for randomness
      - Control time-dependent behavior
      - Avoid network calls in unit tests
    </implementation>
  </requirement>

  <requirement name="Clarity">
    <description>Tests must clearly show intent</description>
    <implementation>
      - Arrange-Act-Assert pattern
      - Descriptive variable names
      - One assertion per test (ideally)
      - Clear failure messages
    </implementation>
  </requirement>

  <requirement name="Speed">
    <description>Tests must run quickly</description>
    <targets>
      - Unit tests: &lt; 100ms each
      - Integration tests: &lt; 1 second each
      - E2E tests: &lt; 10 seconds each
      - Full suite: &lt; 5 minutes
    </targets>
  </requirement>
</quality-requirements>

## Testing Tools and Frameworks

<testing-stack>
  <tool name="pytest" version="8.0+">
    <purpose>Test framework</purpose>
    <features>
      - Fixture management
      - Parametrized tests
      - Parallel execution
      - Detailed reporting
    </features>
  </tool>

  <tool name="pytest-cov" version="5.0+">
    <purpose>Coverage reporting</purpose>
    <requirements>
      - Minimum 80% coverage
      - 100% coverage for critical paths
      - Coverage reports in CI/CD
    </requirements>
  </tool>

  <tool name="pytest-mock" version="3.14+">
    <purpose>Mocking and patching</purpose>
    <use-cases>
      - Mock external APIs
      - Patch time-dependent functions
      - Stub database calls
    </use-cases>
  </tool>

  <tool name="hypothesis" version="6.100+">
    <purpose>Property-based testing</purpose>
    <use-cases>
      - Generate test data
      - Find edge cases
      - Test invariants
    </use-cases>
  </tool>
</testing-stack>

## Test Implementation Patterns

<patterns>
  <pattern name="Arrange-Act-Assert">
    ```python
    def test_agent_should_retry_on_failure():
        # Arrange
        agent = ResearchAgent(max_retries=3)
        mock_api = Mock(side_effect=[Exception, Exception, "success"])

        # Act
        result = agent.execute_with_retry(mock_api)

        # Assert
        assert result == "success"
        assert mock_api.call_count == 3
    ```
  </pattern>

  <pattern name="Given-When-Then">
    ```python
    def test_episode_production():
        # Given a valid research result
        research = create_valid_research()

        # When script is generated
        script = script_writer.generate(research)

        # Then script meets requirements
        assert len(script.split()) >= 4000
        assert "intellectual humility" in script.lower()
    ```
  </pattern>

  <pattern name="Test Fixtures">
    ```python
    @pytest.fixture
    def mock_agent():
        """Provides configured test agent."""
        return Agent(test_mode=True)

    def test_with_fixture(mock_agent):
        result = mock_agent.execute()
        assert result.success
    ```
  </pattern>
</patterns>

## Continuous Testing Requirements

<continuous-testing>
  <requirement name="Pre-commit">
    <description>Tests run before code commit</description>
    <checks>
      - All unit tests must pass
      - Coverage must not decrease
      - No skipped tests without justification
    </checks>
  </requirement>

  <requirement name="Pull Request">
    <description>Tests run on PR creation/update</description>
    <checks>
      - Full test suite must pass
      - Coverage report generated
      - Performance benchmarks checked
    </checks>
  </requirement>

  <requirement name="Main Branch">
    <description>Tests run on main branch</description>
    <checks>
      - All tests including E2E
      - Coverage badge updated
      - Test report archived
    </checks>
  </requirement>
</continuous-testing>

## TDD Workflow Commands

<workflow-commands>
  <command purpose="Run all tests">
    pytest tests/ -v
  </command>

  <command purpose="Run with coverage">
    pytest tests/ --cov=core --cov-report=html
  </command>

  <command purpose="Run only unit tests">
    pytest tests/unit/ -v
  </command>

  <command purpose="Run tests in watch mode">
    pytest-watch tests/ --clear
  </command>

  <command purpose="Run failed tests only">
    pytest tests/ --lf
  </command>

  <command purpose="Run tests in parallel">
    pytest tests/ -n auto
  </command>
</workflow-commands>

## Common TDD Mistakes to Avoid

<mistakes-to-avoid>
  <mistake name="Writing code first">
    <description>Writing implementation before test</description>
    <consequence>Untestable design, missing edge cases</consequence>
    <solution>Always write failing test first</solution>
  </mistake>

  <mistake name="Testing implementation">
    <description>Testing HOW instead of WHAT</description>
    <consequence>Brittle tests that break on refactor</consequence>
    <solution>Test behavior, not implementation</solution>
  </mistake>

  <mistake name="Large tests">
    <description>Testing multiple behaviors at once</description>
    <consequence>Hard to diagnose failures</consequence>
    <solution>One behavior per test</solution>
  </mistake>

  <mistake name="Ignoring failures">
    <description>Skipping or commenting out failing tests</description>
    <consequence>Regression, technical debt</consequence>
    <solution>Fix immediately or delete</solution>
  </mistake>
</mistakes-to-avoid>

## Claude Code Automation Enhancements

<claude-code-automation>
  <hooks-automated-testing>
    <pre-code-hooks>
      <test-first-enforcement-hook>
        <purpose>Ensure no production code without failing test</purpose>
        <activation>Before any production code modification</activation>
        <implementation>
          #!/bin/bash
          # .claude/hooks/pre-code-test-enforcement.sh
          FILE_PATH=$1
          FILE_TYPE=$(echo $FILE_PATH | grep -o '\.[^.]*$')

          # Check if it's production code
          if [[ $FILE_PATH == *"core/"* ]] && [[ $FILE_TYPE == ".py" ]]; then
              echo "🧪 Checking TDD compliance for: $FILE_PATH"

              # Extract function/class names being modified
              NEW_FUNCTIONS=$(git diff --cached $FILE_PATH | grep "^+.*def " | sed 's/^+.*def //g' | cut -d'(' -f1)

              if [ ! -z "$NEW_FUNCTIONS" ]; then
                  echo "New functions detected: $NEW_FUNCTIONS"

                  # Check for corresponding tests
                  TEST_FILE=$(echo $FILE_PATH | sed 's/core/tests\/unit/' | sed 's/\.py/_test.py/')

                  if [ ! -f "$TEST_FILE" ]; then
                      echo "❌ TDD Violation: No test file found for $FILE_PATH"
                      echo "Expected test file: $TEST_FILE"
                      exit 1
                  fi

                  # Delegate test validation to subagent
                  claude task create --type="tdd_compliance_check" \
                    --thinking-mode="think" \
                    --context="$FILE_PATH,$TEST_FILE" \
                    --instructions="Verify failing tests exist for new production code" \
                    --success-criteria="Failing tests found for all new functions" \
                    --output="tdd_compliance_$(basename $FILE_PATH).json"
              fi
          fi
        </implementation>
      </test-first-enforcement-hook>

      <test-generation-hook>
        <purpose>Auto-generate test templates for new functions</purpose>
        <activation>When new production functions detected</activation>
        <subagent-delegation>test_generation_specialist</subagent-delegation>
        <implementation>
          # Generate test templates using specialized subagent
          claude task create --type="test_template_generation" \
            --specialization="test_generation_expert" \
            --thinking-mode="think" \
            --input="{new_function_signatures}" \
            --instructions="Generate comprehensive test templates following TDD patterns" \
            --success-criteria="Complete test templates with arrange-act-assert pattern" \
            --output="generated_test_templates.py"
        </implementation>
      </test-generation-hook>
    </pre-code-hooks>

    <post-code-hooks>
      <test-execution-hook>
        <purpose>Run tests automatically after code changes</purpose>
        <activation>After any code modification</activation>
        <parallel-execution>Enabled for test suite optimization</parallel-execution>
        <implementation>
          #!/bin/bash
          # .claude/hooks/post-code-test-execution.sh
          CHANGED_FILE=$1

          echo "🏃 Running automated test suite..."

          # Determine test scope based on changes
          if [[ $CHANGED_FILE == *"core/agents/"* ]]; then
              TEST_PATTERN="tests/unit/test_agents/"
          elif [[ $CHANGED_FILE == *"core/memory/"* ]]; then
              TEST_PATTERN="tests/unit/test_memory/"
          else
              TEST_PATTERN="tests/unit/"
          fi

          # Run focused tests with coverage
          pytest $TEST_PATTERN -v --cov=core --cov-report=json --cov-fail-under=80
          TEST_RESULT=$?

          # Update test metrics
          @podcast-analytics track_test_metrics \
            --test-file="$TEST_PATTERN" \
            --coverage-report="coverage.json" \
            --execution-time="$(date +%s)"

          if [ $TEST_RESULT -ne 0 ]; then
              echo "❌ Tests failed - commit blocked"
              exit 1
          fi
        </implementation>
      </test-execution-hook>

      <coverage-monitoring-hook>
        <purpose>Monitor and enforce test coverage requirements</purpose>
        <activation>After test execution</activation>
        <mcp-integration>podcast-analytics</mcp-integration>
        <implementation>
          # Track coverage trends
          @podcast-analytics track_coverage_trend \
            --current-coverage="$(coverage report --format=json | jq '.totals.percent_covered')" \
            --alert-on-decrease=true \
            --minimum-threshold=80

          # Generate coverage improvement suggestions
          claude task create --type="coverage_improvement" \
            --thinking-mode="think" \
            --input="coverage.json" \
            --instructions="Identify areas needing test coverage improvement" \
            --output="coverage_improvement_suggestions.json"
        </implementation>
      </coverage-monitoring-hook>
    </post-code-hooks>
  </hooks-automated-testing>

  <thinking-modes-test-design>
    <test-case-design-thinking>
      <simple-functions>
        <thinking-mode>Default</thinking-mode>
        <test-requirements>Basic happy path and error cases</test-requirements>
        <example-functions>Utility functions, simple getters/setters</example-functions>
      </simple-functions>

      <complex-functions>
        <thinking-mode>/think</thinking-mode>
        <test-requirements>Edge cases, boundary conditions, interaction testing</test-requirements>
        <example-functions>Agent coordination, data processing, API integrations</example-functions>
      </complex-functions>

      <critical-functions>
        <thinking-mode>/think hard</thinking-mode>
        <test-requirements>Comprehensive scenario testing, security testing, performance testing</test-requirements>
        <example-functions>Cost calculation, quality evaluation, security validation</example-functions>
      </critical-functions>

      <system-integration>
        <thinking-mode>/ultrathink</thinking-mode>
        <test-requirements>Full system testing, multi-component integration, failure mode analysis</test-requirements>
        <example-functions>End-to-end workflows, multi-agent orchestration, external system integration</example-functions>
      </system-integration>
    </test-case-design-thinking>

    <automated-thinking-mode-selection>
      <complexity-analysis>
        def select_test_thinking_mode(function_complexity, integration_level, criticality):
            """
            Auto-select appropriate thinking mode for test case design
            """
            complexity_score = {
                "simple": 1,
                "moderate": 2,
                "complex": 3,
                "very_complex": 4
            }[function_complexity]

            integration_score = {
                "isolated": 1,
                "few_dependencies": 2,
                "many_dependencies": 3,
                "system_wide": 4
            }[integration_level]

            criticality_score = {
                "low": 1,
                "medium": 2,
                "high": 3,
                "critical": 4
            }[criticality]

            total_score = complexity_score + integration_score + criticality_score

            if total_score >= 10:
                return "ultrathink"
            elif total_score >= 8:
                return "think hard"
            elif total_score >= 5:
                return "think"
            else:
                return "default"
      </complexity-analysis>
    </automated-thinking-mode-selection>
  </thinking-modes-test-design>

  <subagent-test-generation>
    <test-generation-specialist>
      <specialization>Comprehensive test case generation and TDD implementation</specialization>
      <parallel-processing>Enabled for multiple test file generation</parallel-processing>
      <task-template>
        SUBAGENT TASK: Test Generation Specialist
        SPECIALIZATION: TDD Test Case Design and Implementation
        THINKING MODE: [Auto-selected based on function complexity]
        PARALLEL PROCESSING: Enabled for multiple functions

        CONTEXT: Generate comprehensive test cases for production functions
        FUNCTIONS TO TEST: {function_specifications}

        TEST GENERATION REQUIREMENTS:
        1. TDD COMPLIANCE:
           - Generate failing tests first
           - Follow Red-Green-Refactor cycle
           - Ensure tests drive implementation design
           - Create minimal failing test cases

        2. COMPREHENSIVE COVERAGE:
           - Happy path scenarios
           - Edge cases and boundary conditions
           - Error handling and exception cases
           - Integration scenarios where applicable

        3. TEST QUALITY STANDARDS:
           - Clear arrange-act-assert structure
           - Descriptive test names following convention
           - Independent and repeatable tests
           - Fast execution (&lt; 100ms per test)

        4. ADVANCED TESTING PATTERNS:
           - Parameterized tests for data variations
           - Mock usage for external dependencies
           - Property-based testing for complex scenarios
           - Performance assertions where relevant

        SUCCESS CRITERIA:
        - Complete test suite generated for all functions
        - Tests initially fail (Red phase)
        - Test coverage targets met (≥80%)
        - All tests follow naming conventions
        - Performance requirements satisfied

        OUTPUT: comprehensive_test_suite.py
      </task-template>
    </test-generation-specialist>

    <test-quality-analyzer>
      <specialization>Test suite quality analysis and improvement</specialization>
      <task-template>
        SUBAGENT TASK: Test Quality Analysis
        SPECIALIZATION: Test Suite Quality Assurance and Optimization
        THINKING MODE: think hard

        CONTEXT: Analyze and improve existing test suite quality
        TEST SUITE: {test_files_to_analyze}

        QUALITY ANALYSIS DIMENSIONS:
        1. COVERAGE ANALYSIS:
           - Line coverage completeness
           - Branch coverage analysis
           - Function coverage verification
           - Missing coverage identification

        2. TEST DESIGN QUALITY:
           - Arrange-Act-Assert pattern adherence
           - Test independence verification
           - Test naming convention compliance
           - Test performance analysis

        3. TDD COMPLIANCE:
           - Red-Green-Refactor cycle evidence
           - Test-first development verification
           - Implementation-driven vs test-driven analysis
           - Refactoring safety assessment

        4. MAINTAINABILITY ASSESSMENT:
           - Test duplication identification
           - Test brittleness analysis
           - Fixture and helper usage optimization
           - Test documentation quality

        IMPROVEMENT RECOMMENDATIONS:
        - Specific test cases to add
        - Refactoring opportunities
        - Performance optimizations
        - Coverage gap remediation

        OUTPUT: test_quality_analysis_report.json
      </task-template>
    </test-quality-analyzer>

    <parallel-test-execution-coordinator>
      <specialization>Parallel test execution optimization</specialization>
      <task-template>
        SUBAGENT TASK: Parallel Test Execution Optimization
        SPECIALIZATION: Test Suite Performance and Parallelization
        THINKING MODE: think
        PARALLEL PROCESSING: Test execution coordination

        CONTEXT: Optimize test suite for parallel execution and performance

        PARALLEL EXECUTION STRATEGY:
        1. TEST CATEGORIZATION:
           - Unit tests (fast, isolated) - highest parallelization
           - Integration tests (moderate speed) - limited parallelization
           - End-to-end tests (slow) - sequential execution
           - Performance tests (resource intensive) - isolated execution

        2. RESOURCE OPTIMIZATION:
           - CPU core utilization analysis
           - Memory usage optimization
           - Database connection pooling
           - Test data isolation strategies

        3. EXECUTION SCHEDULING:
           - Fast test prioritization
           - Dependency-aware scheduling
           - Resource conflict resolution
           - Failure cascade prevention

        OPTIMIZATION TARGETS:
        - Total execution time &lt; 5 minutes
        - 90%+ parallel execution efficiency
        - Zero test interference
        - Consistent execution times

        OUTPUT: parallel_test_execution_plan.json
      </task-template>
    </parallel-test-execution-coordinator>
  </subagent-test-generation>

  <automated-test-coverage-monitoring>
    <coverage-tracking-integration>
      <mcp-server>podcast-analytics</mcp-server>
      <automated-coverage-workflow>
        # Track coverage metrics after each test run
        track_coverage_metrics() {
            @podcast-analytics record_coverage \
              --timestamp="$(date -Iseconds)" \
              --coverage-percentage="$(coverage report --format=json | jq '.totals.percent_covered')" \
              --lines-covered="$(coverage report --format=json | jq '.totals.covered_lines')" \
              --lines-total="$(coverage report --format=json | jq '.totals.num_statements')"
        }

        # Generate coverage trend analysis
        analyze_coverage_trends() {
            @podcast-analytics analyze_coverage_trends \
              --timeframe="last-30-days" \
              --alert-on-decrease=true \
              --target-coverage=90 \
              --output="coverage_trend_analysis.json"
        }

        # Identify coverage gaps
        identify_coverage_gaps() {
            claude task create --type="coverage_gap_analysis" \
              --thinking-mode="think" \
              --input="coverage.json" \
              --instructions="Identify critical functions lacking test coverage" \
              --output="coverage_gaps.json"
        }
      </automated-coverage-workflow>
    </coverage-tracking-integration>

    <github-integration>
      <mcp-server>github</mcp-server>
      <test-status-tracking>
        # Create GitHub issue for coverage drops
        @github create_issue "Test Coverage Decrease Detected" \
          --body="Coverage dropped below {threshold}% in {component}" \
          --labels="testing,coverage,needs-attention" \
          --assign="test-maintainer"

        # Update pull requests with test status
        @github add_pr_comment {pr_number} \
          --comment="Test Results: {pass_count} passed, {fail_count} failed. Coverage: {coverage_percentage}%"

        # Track test metrics in repository
        @github create_repository_metric "test_coverage" \
          --value="{coverage_percentage}" \
          --timestamp="$(date -Iseconds)"
      </test-status-tracking>
    </github-integration>
  </automated-test-coverage-monitoring>
</claude-code-automation>

## Enforcement and Compliance

<enforcement>
  <non-negotiable-rules>
    1. NO production code without failing test
    2. NO commits with failing tests
    3. NO merges with decreased coverage
    4. NO skipped tests without documentation
    5. NO test deletion without approval

    <claude-code-automated-enforcement>
      <rule-1-enforcement>
        # Pre-commit hook automatically blocks production code without tests
        enforce_test_first() {
            if production_code_changes && ! failing_tests_exist; then
                echo "❌ BLOCKED: Production code requires failing test first"
                trigger_test_generation_subagent
                exit 1
            fi
        }
      </rule-1-enforcement>

      <rule-2-enforcement>
        # Post-test hook blocks commits with failing tests
        enforce_passing_tests() {
            pytest tests/ --tb=short
            if [ $? -ne 0 ]; then
                echo "❌ BLOCKED: All tests must pass before commit"
                exit 1
            fi
        }
      </rule-2-enforcement>

      <rule-3-enforcement>
        # Coverage hook blocks decreased coverage
        enforce_coverage_maintenance() {
            PREVIOUS_COVERAGE=$(git show HEAD~1:coverage.json | jq '.totals.percent_covered')
            CURRENT_COVERAGE=$(coverage report --format=json | jq '.totals.percent_covered')

            if (( $(echo "$CURRENT_COVERAGE &lt; $PREVIOUS_COVERAGE" | bc -l) )); then
                echo "❌ BLOCKED: Coverage decreased from $PREVIOUS_COVERAGE% to $CURRENT_COVERAGE%"
                exit 1
            fi
        }
      </rule-3-enforcement>
    </claude-code-automated-enforcement>
  </non-negotiable-rules>

  <metrics>
    - Test coverage: Minimum 80%, target 90%
    - Test execution time: &lt; 5 minutes for full suite
    - Test reliability: 100% (no flaky tests)
    - Test documentation: Every test has clear purpose

    <claude-code-metrics-automation>
      <automated-metrics-collection>
        # Collect metrics after each test run
        collect_test_metrics() {
            @podcast-analytics record_test_metrics \
              --coverage="$(coverage report --format=json | jq '.totals.percent_covered')" \
              --execution-time="$(pytest --collect-only -q | grep -o '[0-9]\+\.[0-9]\+s' | tail -1)" \
              --test-count="$(pytest --collect-only -q | grep -o '[0-9]\+ items')" \
              --reliability-score="$(calculate_reliability_score)"
        }

        # Generate metrics dashboard
        generate_metrics_dashboard() {
            claude task create --type="test_metrics_dashboard" \
              --thinking-mode="think" \
              --aggregation-period="weekly" \
              --alert-on-degradation=true \
              --output="test_metrics_dashboard.json"
        }
      </automated-metrics-collection>
    </claude-code-metrics-automation>
  </metrics>
</enforcement>

## Claude Code Integration Commands

<claude-code-tdd-commands>
  <test-generation-commands>
    <command purpose="Generate test template for function">
      claude /generate-tests --function="{function_name}" --thinking-mode="think" --pattern="arrange-act-assert"
    </command>

    <command purpose="Create failing test first">
      claude task create --type="failing_test_generation" --target="{function_signature}" --tdd-cycle="red"
    </command>

    <command purpose="Analyze test coverage gaps">
      claude /analyze-coverage --file="{source_file}" --thinking-mode="think" --output="coverage_analysis.json"
    </command>

    <command purpose="Optimize test performance">
      claude task create --type="test_optimization" --parallel=true --target-time="5min"
    </command>

    <command purpose="Validate TDD compliance">
      claude /validate-tdd --code-changes="{git_diff}" --enforce-test-first=true
    </command>
  </test-generation-commands>

  <automated-tdd-workflow-commands>
    <command purpose="Run TDD cycle automation">
      claude /tdd-cycle --phase="{red|green|refactor}" --target="{function_name}"
    </command>

    <command purpose="Track test metrics">
      @podcast-analytics record_tdd_metrics --coverage="{coverage}" --execution-time="{time}"
    </command>

    <command purpose="Generate test quality report">
      claude task create --type="test_quality_analysis" --thinking-mode="think hard" --comprehensive=true
    </command>

    <command purpose="Setup parallel test execution">
      claude /setup-parallel-tests --max-workers="auto" --optimize-grouping=true
    </command>
  </automated-tdd-workflow-commands>
</claude-code-tdd-commands>

<automated-tdd-workflows>
  <complete-tdd-cycle-automation>
    # Automated Red-Green-Refactor cycle
    run_tdd_cycle() {
        # RED: Generate failing test
        claude task create --type="failing_test_generation" \
          --thinking-mode="think" \
          --function-spec="{function_specification}" \
          --output="failing_test.py"

        # Verify test fails
        pytest failing_test.py
        if [ $? -eq 0 ]; then
            echo "❌ Test should fail in RED phase"
            exit 1
        fi

        # GREEN: Implement minimal code to pass
        claude task create --type="minimal_implementation" \
          --thinking-mode="default" \
          --test-file="failing_test.py" \
          --instructions="Write minimal code to make test pass" \
          --output="implementation.py"

        # Verify test passes
        pytest failing_test.py
        if [ $? -ne 0 ]; then
            echo "❌ Test should pass in GREEN phase"
            exit 1
        fi

        # REFACTOR: Improve code quality
        claude task create --type="code_refactoring" \
          --thinking-mode="think" \
          --code-file="implementation.py" \
          --test-file="failing_test.py" \
          --instructions="Refactor while maintaining passing tests" \
          --output="refactored_implementation.py"
    }
  </complete-tdd-cycle-automation>

  <test-suite-maintenance-automation>
    # Automated test suite health monitoring
    maintain_test_suite() {
        # Check for flaky tests
        claude task create --type="flaky_test_detection" \
          --parallel=true \
          --runs-per-test=10 \
          --thinking-mode="think" \
          --output="flaky_test_report.json"

        # Optimize slow tests
        claude task create --type="test_performance_optimization" \
          --thinking-mode="think hard" \
          --target-time="100ms" \
          --output="test_optimization_plan.json"

        # Update test documentation
        claude task create --type="test_documentation_update" \
          --thinking-mode="think" \
          --scan-all-tests=true \
          --output="updated_test_docs.md"
    }
  </test-suite-maintenance-automation>
</automated-tdd-workflows>

## Remember

<tdd-philosophy>
  <principles>
    - The test is the first user of your code
    - If it's hard to test, it's hard to use
    - Tests are documentation
    - Tests enable refactoring
    - Tests prevent regression
    - Automation amplifies TDD benefits without replacing discipline
    - Claude Code subagents accelerate test generation while maintaining quality
    - Thinking modes ensure appropriate test design depth
  </principles>

  <mantras>
    - Red, Green, Refactor
    - Test first, code second
    - Make it work, make it right, make it fast
    - When in doubt, write a test
    - Automate the tedious, focus on the creative
    - Let subagents handle test generation, you focus on test design
  </mantras>
</tdd-philosophy>

<final-word>
  TDD is not optional. It is the foundation of quality.
  Every line of production code must be driven by a test.
  This is how we build reliable, maintainable software.

  <claude-code-tdd-enhancement>
    Claude Code automation enhances TDD by:
    - Automatically enforcing test-first discipline through hooks
    - Generating comprehensive test templates with subagents
    - Optimizing test execution with parallel processing
    - Monitoring test quality and coverage trends
    - Integrating TDD metrics with project analytics

    The fundamentals remain unchanged: Red, Green, Refactor.
    Automation simply makes the cycle faster, more comprehensive, and more reliable.
  </claude-code-tdd-enhancement>
</final-word>

</document>
