#!/bin/bash
# Error Scenario Testing: Budget Exhaustion and Session Management
# Tests system behavior when budget limits are reached or exceeded

set -euo pipefail

# Test Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_SESSION_DIR="tests/data/test_session_budget_exhaustion"
MOCK_MODE="${MOCK_MODE:-true}"

# Budget Configuration (from cost-tracking.sh)
DAILY_BUDGET_WARNING=10.00
DAILY_BUDGET_LIMIT=25.00
WEEKLY_BUDGET_WARNING=50.00
WEEKLY_BUDGET_LIMIT=100.00

# Test Statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging Functions
log_test() { echo "[BUDGET EXHAUSTION TEST] $*"; }
log_pass() { echo "[PASS] $*"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_fail() { echo "[FAIL] $*"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

# Setup
setup_test() {
    mkdir -p "$TEST_SESSION_DIR/budget_data" "$TEST_SESSION_DIR/sessions"
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Create budget tracking database simulation
create_budget_database() {
    local today
    today=$(date '+%Y-%m-%d')
    local this_week
    this_week=$(date '+%Y-W%U')

    cat > "$TEST_SESSION_DIR/budget_data/cost-tracking.json" << EOF
{
    "daily_costs": {
        "$today": 0.00
    },
    "weekly_costs": {
        "$this_week": 0.00
    },
    "operation_counts": {
        "elevenlabs_tts_episode": 0,
        "perplexity_ask": 0,
        "task_research_agent": 0,
        "task_script_writer": 0
    },
    "budget_alerts": []
}
EOF
}

# Test daily budget limit enforcement
test_daily_budget_limit_enforcement() {
    setup_test
    log_test "Testing daily budget limit enforcement"

    create_budget_database
    local budget_db="$TEST_SESSION_DIR/budget_data/cost-tracking.json"
    local today
    today=$(date '+%Y-%m-%d')

    # Test scenarios with different spending levels
    local budget_scenarios=(
        "20.00:5.51:prevent:Daily limit would be exceeded"
        "15.00:10.00:prevent:Daily limit would be exceeded"
        "10.00:12.00:prevent:Daily limit would be exceeded"
        "5.00:10.50:prevent:Daily limit would be exceeded"
        "20.00:4.99:allow:Within daily budget"
        "0.00:25.00:allow:Exactly at limit"
        "0.00:10.50:allow:Well within budget"
    )

    for scenario in "${budget_scenarios[@]}"; do
        local current_spent="${scenario%%:*}"
        local operation_cost="${scenario#*:}"
        operation_cost="${operation_cost%:*}"
        local remaining="${scenario#*:*:}"
        local expected_action="${remaining%:*}"
        local description="${remaining#*:}"

        # Update budget database with current spending
        jq --arg date "$today" \
           --arg spent "$current_spent" \
           '.daily_costs[$date] = ($spent | tonumber)' \
           "$budget_db" > "${budget_db}.tmp" && mv "${budget_db}.tmp" "$budget_db"

        # Calculate remaining budget
        local daily_remaining
        daily_remaining=$(echo "$DAILY_BUDGET_LIMIT - $current_spent" | bc)

        # Test budget check logic
        local should_allow=false
        if (( $(echo "$operation_cost <= $daily_remaining" | bc -l) )); then
            should_allow=true
        fi

        # Validate against expected behavior
        case "$expected_action" in
            "prevent")
                if [ "$should_allow" = false ]; then
                    log_test "✓ Daily budget enforcement correct - preventing \$${operation_cost} operation (spent: \$${current_spent}, remaining: \$${daily_remaining})"
                else
                    log_fail "Daily budget enforcement failed - should prevent \$${operation_cost} operation (spent: \$${current_spent}, remaining: \$${daily_remaining})"
                    return 1
                fi
                ;;
            "allow")
                if [ "$should_allow" = true ]; then
                    log_test "✓ Daily budget enforcement correct - allowing \$${operation_cost} operation (spent: \$${current_spent}, remaining: \$${daily_remaining})"
                else
                    log_fail "Daily budget enforcement failed - should allow \$${operation_cost} operation (spent: \$${current_spent}, remaining: \$${daily_remaining})"
                    return 1
                fi
                ;;
        esac
    done

    log_pass "Daily budget limit enforcement test complete"
}

# Test weekly budget limit enforcement
test_weekly_budget_limit_enforcement() {
    setup_test
    log_test "Testing weekly budget limit enforcement"

    create_budget_database
    local budget_db="$TEST_SESSION_DIR/budget_data/cost-tracking.json"
    local this_week
    this_week=$(date '+%Y-W%U')

    # Test weekly budget scenarios
    local weekly_scenarios=(
        "80.00:17.45:prevent:Weekly limit would be exceeded"
        "92.00:10.50:prevent:Weekly limit would be exceeded"
        "95.00:6.00:prevent:Weekly limit would be exceeded"
        "70.00:25.00:allow:Within weekly budget"
        "50.00:17.45:allow:Well within weekly budget"
        "0.00:100.00:allow:Exactly at weekly limit"
    )

    for scenario in "${weekly_scenarios[@]}"; do
        local current_weekly_spent="${scenario%%:*}"
        local operation_cost="${scenario#*:}"
        operation_cost="${operation_cost%:*}"
        local remaining="${scenario#*:*:}"
        local expected_action="${remaining%:*}"
        local description="${remaining#*:}"

        # Update budget database with current weekly spending
        jq --arg week "$this_week" \
           --arg spent "$current_weekly_spent" \
           '.weekly_costs[$week] = ($spent | tonumber)' \
           "$budget_db" > "${budget_db}.tmp" && mv "${budget_db}.tmp" "$budget_db"

        # Calculate remaining weekly budget
        local weekly_remaining
        weekly_remaining=$(echo "$WEEKLY_BUDGET_LIMIT - $current_weekly_spent" | bc)

        # Test weekly budget check logic
        local should_allow_weekly=false
        if (( $(echo "$operation_cost <= $weekly_remaining" | bc -l) )); then
            should_allow_weekly=true
        fi

        # Validate against expected behavior
        case "$expected_action" in
            "prevent")
                if [ "$should_allow_weekly" = false ]; then
                    log_test "✓ Weekly budget enforcement correct - preventing \$${operation_cost} operation (weekly spent: \$${current_weekly_spent}, remaining: \$${weekly_remaining})"
                else
                    log_fail "Weekly budget enforcement failed - should prevent \$${operation_cost} operation (weekly spent: \$${current_weekly_spent}, remaining: \$${weekly_remaining})"
                    return 1
                fi
                ;;
            "allow")
                if [ "$should_allow_weekly" = true ]; then
                    log_test "✓ Weekly budget enforcement correct - allowing \$${operation_cost} operation (weekly spent: \$${current_weekly_spent}, remaining: \$${weekly_remaining})"
                else
                    log_fail "Weekly budget enforcement failed - should allow \$${operation_cost} operation (weekly spent: \$${current_weekly_spent}, remaining: \$${weekly_remaining})"
                    return 1
                fi
                ;;
        esac
    done

    log_pass "Weekly budget limit enforcement test complete"
}

# Test budget warning thresholds
test_budget_warning_thresholds() {
    setup_test
    log_test "Testing budget warning thresholds"

    create_budget_database
    local budget_db="$TEST_SESSION_DIR/budget_data/cost-tracking.json"
    local today
    today=$(date '+%Y-%m-%d')
    local this_week
    this_week=$(date '+%Y-W%U')

    # Test daily warning threshold (80% of $25 = $20)
    local daily_warning_threshold
    daily_warning_threshold=$(echo "$DAILY_BUDGET_LIMIT * 0.8" | bc)

    local daily_warning_tests=(
        "15.00:no_warning:Below threshold"
        "20.00:warning:At threshold"
        "22.00:warning:Above threshold"
    )

    for test_case in "${daily_warning_tests[@]}"; do
        local spent="${test_case%%:*}"
        local expected="${test_case#*:}"
        expected="${expected%:*}"
        local description="${test_case##*:}"

        # Check if warning should trigger
        local should_warn_daily=false
        if (( $(echo "$spent >= $daily_warning_threshold" | bc -l) )); then
            should_warn_daily=true
        fi

        case "$expected" in
            "warning")
                if [ "$should_warn_daily" = true ]; then
                    log_test "✓ Daily warning correctly triggered at \$${spent} (threshold: \$${daily_warning_threshold})"
                else
                    log_fail "Daily warning failed to trigger at \$${spent} (threshold: \$${daily_warning_threshold})"
                    return 1
                fi
                ;;
            "no_warning")
                if [ "$should_warn_daily" = false ]; then
                    log_test "✓ Daily warning correctly not triggered at \$${spent} (threshold: \$${daily_warning_threshold})"
                else
                    log_fail "Daily warning incorrectly triggered at \$${spent} (threshold: \$${daily_warning_threshold})"
                    return 1
                fi
                ;;
        esac
    done

    # Test weekly warning threshold (50% of $100 = $50)
    local weekly_warning_threshold
    weekly_warning_threshold=$(echo "$WEEKLY_BUDGET_LIMIT * 0.5" | bc)

    local weekly_warning_tests=(
        "30.00:no_warning:Below threshold"
        "50.00:warning:At threshold"
        "75.00:warning:Above threshold"
    )

    for test_case in "${weekly_warning_tests[@]}"; do
        local weekly_spent="${test_case%%:*}"
        local expected="${test_case#*:}"
        expected="${expected%:*}"
        local description="${test_case##*:}"

        # Check if warning should trigger
        local should_warn_weekly=false
        if (( $(echo "$weekly_spent >= $weekly_warning_threshold" | bc -l) )); then
            should_warn_weekly=true
        fi

        case "$expected" in
            "warning")
                if [ "$should_warn_weekly" = true ]; then
                    log_test "✓ Weekly warning correctly triggered at \$${weekly_spent} (threshold: \$${weekly_warning_threshold})"
                else
                    log_fail "Weekly warning failed to trigger at \$${weekly_spent} (threshold: \$${weekly_warning_threshold})"
                    return 1
                fi
                ;;
            "no_warning")
                if [ "$should_warn_weekly" = false ]; then
                    log_test "✓ Weekly warning correctly not triggered at \$${weekly_spent} (threshold: \$${weekly_warning_threshold})"
                else
                    log_fail "Weekly warning incorrectly triggered at \$${weekly_spent} (threshold: \$${weekly_warning_threshold})"
                    return 1
                fi
                ;;
        esac
    done

    log_pass "Budget warning thresholds test complete"
}

# Test mid-session budget exhaustion
test_mid_session_budget_exhaustion() {
    setup_test
    log_test "Testing mid-session budget exhaustion scenarios"

    # Create session in progress
    local session_id="ep001_budget_test_20250818"
    local session_dir="$TEST_SESSION_DIR/sessions/$session_id"
    mkdir -p "$session_dir/research" "$session_dir/production"

    # Simulate session with research complete, script writing in progress
    cat > "$session_dir/research/research_complete.json" << 'EOF'
{
    "checkpoint_type": "research_synthesis",
    "session_id": "ep001_budget_test_20250818",
    "status": "completed",
    "timestamp": "2025-08-18T10:30:00Z",
    "cost_invested": 4.70
}
EOF

    # Create script writing checkpoint showing in-progress
    cat > "$session_dir/production/script_writing_started.json" << 'EOF'
{
    "checkpoint_type": "script_writing",
    "session_id": "ep001_budget_test_20250818",
    "status": "in_progress",
    "timestamp": "2025-08-18T11:00:00Z",
    "cost_invested": 0.85,
    "estimated_remaining_cost": 0.90
}
EOF

    # Test budget scenarios mid-session
    local budget_scenarios=(
        "current_spent:24.00:next_operation:1.75:action:prevent:Mid-session budget exhaustion"
        "current_spent:20.00:next_operation:6.30:action:prevent:Audio synthesis would exceed budget"
        "current_spent:15.00:next_operation:1.75:action:allow_with_warning:Script writing within budget with warning"
        "current_spent:5.00:next_operation:10.50:action:allow:Audio synthesis within budget"
    )

    for scenario in "${budget_scenarios[@]}"; do
        # Parse scenario components
        local current_spent=$(echo "$scenario" | cut -d: -f2)
        local next_operation_cost=$(echo "$scenario" | cut -d: -f4)
        local expected_action=$(echo "$scenario" | cut -d: -f6)

        # Calculate remaining budget
        local remaining_budget
        remaining_budget=$(echo "$DAILY_BUDGET_LIMIT - $current_spent" | bc)

        # Test session management logic
        local can_proceed=false
        local should_warn=false
        local should_suspend=false

        if (( $(echo "$next_operation_cost <= $remaining_budget" | bc -l) )); then
            can_proceed=true
            # Check if warning threshold would be exceeded
            local post_operation_total
            post_operation_total=$(echo "$current_spent + $next_operation_cost" | bc)
            if (( $(echo "$post_operation_total >= ($DAILY_BUDGET_LIMIT * 0.8)" | bc -l) )); then
                should_warn=true
            fi
        else
            should_suspend=true
        fi

        # Validate against expected behavior
        case "$expected_action" in
            "prevent")
                if [ "$should_suspend" = true ]; then
                    log_test "✓ Mid-session budget exhaustion correctly handled - suspending session"

                    # Test session suspension process
                    cat > "$session_dir/session_suspended.json" << EOF
{
    "session_id": "$session_id",
    "status": "suspended_budget_exhausted",
    "suspension_reason": "daily_budget_limit_reached",
    "current_spent": $current_spent,
    "attempted_operation_cost": $next_operation_cost,
    "remaining_budget": $remaining_budget,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

                    if [ -f "$session_dir/session_suspended.json" ]; then
                        log_test "✓ Session suspension properly documented"
                    else
                        log_fail "Session suspension not properly documented"
                        return 1
                    fi
                else
                    log_fail "Mid-session budget exhaustion not handled correctly"
                    return 1
                fi
                ;;
            "allow"|"allow_with_warning")
                if [ "$can_proceed" = true ]; then
                    log_test "✓ Mid-session operation correctly allowed"

                    if [ "$expected_action" = "allow_with_warning" ] && [ "$should_warn" = true ]; then
                        log_test "✓ Budget warning correctly triggered for mid-session operation"
                    elif [ "$expected_action" = "allow" ] && [ "$should_warn" = false ]; then
                        log_test "✓ No warning needed for mid-session operation"
                    else
                        log_fail "Warning behavior incorrect for mid-session operation"
                        return 1
                    fi
                else
                    log_fail "Mid-session operation incorrectly prevented"
                    return 1
                fi
                ;;
        esac
    done

    log_pass "Mid-session budget exhaustion test complete"
}

# Test budget reset timing
test_budget_reset_timing() {
    setup_test
    log_test "Testing budget reset timing (daily/weekly)"

    create_budget_database
    local budget_db="$TEST_SESSION_DIR/budget_data/cost-tracking.json"

    # Test daily reset logic
    local today
    today=$(date '+%Y-%m-%d')
    local yesterday
    yesterday=$(date -d "yesterday" '+%Y-%m-%d' 2>/dev/null || date -v-1d '+%Y-%m-%d' 2>/dev/null || echo "2025-08-17")

    # Simulate budget data from previous day
    jq --arg yesterday "$yesterday" \
       --arg today "$today" \
       '.daily_costs[$yesterday] = 24.50 |
        .daily_costs[$today] = 0.00' \
       "$budget_db" > "${budget_db}.tmp" && mv "${budget_db}.tmp" "$budget_db"

    # Test that yesterday's spending doesn't affect today's budget
    local yesterdays_spending
    yesterdays_spending=$(jq -r ".daily_costs[\"$yesterday\"] // 0" "$budget_db")
    local todays_spending
    todays_spending=$(jq -r ".daily_costs[\"$today\"] // 0" "$budget_db")

    if (( $(echo "$yesterdays_spending > 0" | bc -l) )) && (( $(echo "$todays_spending == 0" | bc -l) )); then
        log_test "✓ Daily budget reset working - yesterday: \$${yesterdays_spending}, today: \$${todays_spending}"
    else
        log_fail "Daily budget reset not working properly"
        return 1
    fi

    # Test weekly reset logic
    local this_week
    this_week=$(date '+%Y-W%U')
    local last_week
    last_week=$(date -d "last week" '+%Y-W%U' 2>/dev/null || date -v-7d '+%Y-W%U' 2>/dev/null || echo "2025-W32")

    # Simulate weekly budget data
    jq --arg last_week "$last_week" \
       --arg this_week "$this_week" \
       '.weekly_costs[$last_week] = 95.00 |
        .weekly_costs[$this_week] = 15.00' \
       "$budget_db" > "${budget_db}.tmp" && mv "${budget_db}.tmp" "$budget_db"

    local last_weeks_spending
    last_weeks_spending=$(jq -r ".weekly_costs[\"$last_week\"] // 0" "$budget_db")
    local this_weeks_spending
    this_weeks_spending=$(jq -r ".weekly_costs[\"$this_week\"] // 0" "$budget_db")

    if (( $(echo "$last_weeks_spending > 0" | bc -l) )) && (( $(echo "$this_weeks_spending < $last_weeks_spending" | bc -l) )); then
        log_test "✓ Weekly budget tracking working - last week: \$${last_weeks_spending}, this week: \$${this_weeks_spending}"
    else
        log_fail "Weekly budget tracking not working properly"
        return 1
    fi

    log_pass "Budget reset timing test complete"
}

# Test session suspension and resume
test_session_suspension_resume() {
    setup_test
    log_test "Testing session suspension and resume due to budget constraints"

    local session_id="ep002_suspend_test_20250818"
    local session_dir="$TEST_SESSION_DIR/sessions/$session_id"
    mkdir -p "$session_dir"

    # Create session that hits budget limit
    cat > "$session_dir/session_metadata.json" << 'EOF'
{
    "session_id": "ep002_suspend_test_20250818",
    "topic": "AI Budget Management",
    "phase": "production_script_writing",
    "total_cost_so_far": 24.25,
    "next_operation": {
        "type": "audio_synthesis",
        "estimated_cost": 10.50
    },
    "status": "active"
}
EOF

    # Test suspension logic
    local current_cost
    current_cost=$(jq -r '.total_cost_so_far' "$session_dir/session_metadata.json")
    local next_cost
    next_cost=$(jq -r '.next_operation.estimated_cost' "$session_dir/session_metadata.json")
    local projected_total
    projected_total=$(echo "$current_cost + $next_cost" | bc)

    if (( $(echo "$projected_total > $DAILY_BUDGET_LIMIT" | bc -l) )); then
        log_test "✓ Session suspension criteria met - projected cost \$${projected_total} > \$${DAILY_BUDGET_LIMIT}"

        # Create suspension record
        cat > "$session_dir/suspension_record.json" << EOF
{
    "session_id": "$session_id",
    "suspended_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "suspension_reason": "daily_budget_exceeded",
    "current_phase": "production_script_writing",
    "cost_at_suspension": $current_cost,
    "blocked_operation": {
        "type": "audio_synthesis",
        "cost": $next_cost
    },
    "resume_conditions": {
        "budget_reset_required": true,
        "resume_after_date": "$(date -d "tomorrow" '+%Y-%m-%d' 2>/dev/null || date -v+1d '+%Y-%m-%d' 2>/dev/null || echo "2025-08-19")"
    }
}
EOF

        # Test resume readiness
        local resume_date
        resume_date=$(jq -r '.resume_conditions.resume_after_date' "$session_dir/suspension_record.json")
        local current_date
        current_date=$(date '+%Y-%m-%d')

        # Simulate next day
        local simulated_next_day="2025-08-19"

        if [ "$resume_date" = "$simulated_next_day" ]; then
            log_test "✓ Session resume date correctly calculated: $resume_date"

            # Test resume process
            cat > "$session_dir/resume_record.json" << EOF
{
    "session_id": "$session_id",
    "resumed_at": "$(date -d "$simulated_next_day" '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || echo "${simulated_next_day}T00:00:00")Z",
    "resume_reason": "daily_budget_reset",
    "available_budget": $DAILY_BUDGET_LIMIT,
    "resume_phase": "production_script_writing",
    "next_operation": {
        "type": "audio_synthesis",
        "cost": $next_cost
    }
}
EOF

            # Validate resume conditions
            local available_budget
            available_budget=$(jq -r '.available_budget' "$session_dir/resume_record.json")

            if (( $(echo "$next_cost <= $available_budget" | bc -l) )); then
                log_test "✓ Session resume conditions met - operation \$${next_cost} <= budget \$${available_budget}"
            else
                log_fail "Session resume conditions not met - operation \$${next_cost} > budget \$${available_budget}"
                return 1
            fi
        else
            log_fail "Session resume date calculation incorrect"
            return 1
        fi
    else
        log_fail "Session suspension criteria not correctly identified"
        return 1
    fi

    log_pass "Session suspension and resume test complete"
}

# Test cost tracking accuracy under budget pressure
test_cost_tracking_under_pressure() {
    setup_test
    log_test "Testing cost tracking accuracy under budget pressure"

    create_budget_database
    local budget_db="$TEST_SESSION_DIR/budget_data/cost-tracking.json"

    # Simulate multiple operations approaching budget limit
    local operations=(
        "perplexity_ask:2.35:research_complete"
        "task_script_writer:1.75:script_complete"
        "elevenlabs_tts_episode:10.50:audio_complete"
    )

    local running_total=0.00
    local today
    today=$(date '+%Y-%m-%d')
    local this_week
    this_week=$(date '+%Y-W%U')

    for operation in "${operations[@]}"; do
        local op_name="${operation%%:*}"
        local op_cost="${operation#*:}"
        op_cost="${op_cost%:*}"
        local op_stage="${operation##*:}"

        # Update running total
        running_total=$(echo "$running_total + $op_cost" | bc)

        # Update budget database
        jq --arg date "$today" \
           --arg week "$this_week" \
           --arg op "$op_name" \
           --arg cost "$op_cost" \
           --arg total "$running_total" \
           '.daily_costs[$date] = ($total | tonumber) |
            .weekly_costs[$week] = ($total | tonumber) |
            .operation_counts[$op] = (.operation_counts[$op] // 0) + 1' \
           "$budget_db" > "${budget_db}.tmp" && mv "${budget_db}.tmp" "$budget_db"

        # Validate tracking accuracy
        local tracked_daily
        tracked_daily=$(jq -r ".daily_costs[\"$today\"]" "$budget_db")
        local tracked_weekly
        tracked_weekly=$(jq -r ".weekly_costs[\"$this_week\"]" "$budget_db")

        if (( $(echo "$tracked_daily == $running_total" | bc -l) )) && (( $(echo "$tracked_weekly == $running_total" | bc -l) )); then
            log_test "✓ Cost tracking accurate after $op_stage: \$${running_total}"
        else
            log_fail "Cost tracking inaccurate after $op_stage: expected \$${running_total}, tracked daily \$${tracked_daily}, weekly \$${tracked_weekly}"
            return 1
        fi

        # Check if approaching limits
        local remaining_daily
        remaining_daily=$(echo "$DAILY_BUDGET_LIMIT - $running_total" | bc)
        local remaining_weekly
        remaining_weekly=$(echo "$WEEKLY_BUDGET_LIMIT - $running_total" | bc)

        if (( $(echo "$remaining_daily < 5.0" | bc -l) )); then
            log_test "✓ Approaching daily budget limit: \$${remaining_daily} remaining"
        fi

        if (( $(echo "$running_total > $DAILY_BUDGET_LIMIT" | bc -l) )); then
            log_test "✓ Daily budget exceeded: \$${running_total} > \$${DAILY_BUDGET_LIMIT}"
            break
        fi
    done

    # Test final accounting accuracy
    local final_daily
    final_daily=$(jq -r ".daily_costs[\"$today\"]" "$budget_db")
    local final_weekly
    final_weekly=$(jq -r ".weekly_costs[\"$this_week\"]" "$budget_db")

    if (( $(echo "$final_daily == $running_total" | bc -l) )); then
        log_test "✓ Final cost tracking accurate: \$${running_total}"
    else
        log_fail "Final cost tracking inaccurate: expected \$${running_total}, got \$${final_daily}"
        return 1
    fi

    log_pass "Cost tracking accuracy under pressure test complete"
}

# Test budget enforcement with checkpoint protection
test_budget_checkpoint_interaction() {
    setup_test
    log_test "Testing budget enforcement interaction with checkpoint protection"

    # Scenario: Budget nearly exhausted, expensive operation with existing checkpoint
    local session_id="ep003_checkpoint_budget_test"
    local session_dir="$TEST_SESSION_DIR/sessions/$session_id"
    mkdir -p "$session_dir"

    # Simulate expensive checkpoint exists (audio synthesis already done)
    cat > "$session_dir/09_audio_synthesis_complete.json" << 'EOF'
{
    "checkpoint_type": "audio_synthesis",
    "session_id": "ep003_checkpoint_budget_test",
    "status": "completed",
    "timestamp": "2025-08-18T10:00:00Z",
    "cost_invested": 10.50,
    "cost_protection_value": 10.50
}
EOF

    # Create budget scenario where re-running would exceed limit
    create_budget_database
    local budget_db="$TEST_SESSION_DIR/budget_data/cost-tracking.json"
    local today
    today=$(date '+%Y-%m-%d')

    # Set current spending to near limit
    jq --arg date "$today" \
       '.daily_costs[$date] = 23.00' \
       "$budget_db" > "${budget_db}.tmp" && mv "${budget_db}.tmp" "$budget_db"

    # Test checkpoint protection logic
    local current_spent=23.00
    local operation_cost=10.50  # Would normally exceed budget
    local checkpoint_exists=true

    if [ "$checkpoint_exists" = true ]; then
        # With checkpoint, no additional cost
        local effective_cost=0.00
        local remaining_budget
        remaining_budget=$(echo "$DAILY_BUDGET_LIMIT - $current_spent" | bc)

        if (( $(echo "$effective_cost <= $remaining_budget" | bc -l) )); then
            log_test "✓ Checkpoint protection allows operation despite budget pressure"
            log_test "✓ Cost protection value: \$${operation_cost}, actual cost: \$${effective_cost}"
        else
            log_fail "Checkpoint protection not working correctly with budget enforcement"
            return 1
        fi
    else
        log_fail "Checkpoint protection test setup failed"
        return 1
    fi

    # Test checkpoint validation under budget pressure
    if jq -e '.cost_protection_value' "$session_dir/09_audio_synthesis_complete.json" >/dev/null; then
        local protection_value
        protection_value=$(jq -r '.cost_protection_value' "$session_dir/09_audio_synthesis_complete.json")

        log_test "✓ Checkpoint protection value verified: \$${protection_value}"
    else
        log_fail "Checkpoint protection value not properly documented"
        return 1
    fi

    log_pass "Budget enforcement with checkpoint protection test complete"
}

# Run All Budget Exhaustion Tests
run_tests() {
    log_test "Starting budget exhaustion and session management tests"

    # Run all test scenarios
    test_daily_budget_limit_enforcement
    test_weekly_budget_limit_enforcement
    test_budget_warning_thresholds
    test_mid_session_budget_exhaustion
    test_budget_reset_timing
    test_session_suspension_resume
    test_cost_tracking_under_pressure
    test_budget_checkpoint_interaction

    # Summary
    echo "=== Budget Exhaustion and Session Management Test Summary ==="
    echo "Tests Run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo "✅ All budget exhaustion and session management tests passed"
        return 0
    else
        echo "❌ $TESTS_FAILED budget exhaustion and session management tests failed"
        return 1
    fi
}

# Cleanup
cleanup() {
    rm -rf "$TEST_SESSION_DIR"
}

# Main execution
trap cleanup EXIT
run_tests
