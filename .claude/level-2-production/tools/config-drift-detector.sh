#!/usr/bin/env bash

# Configuration Drift Detector - Runtime Validation System
# Detects configuration inconsistencies between master config and session data
# Prevents configuration drift that could cause production issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
MASTER_CONFIG="$BASE_DIR/config/production-config.yaml"
SESSIONS_DIR="$BASE_DIR/sessions"
DRIFT_LOG="$BASE_DIR/logs/config_drift.log"

# Ensure logs directory exists
mkdir -p "$(dirname "$DRIFT_LOG")"

# Load configuration utilities
source "$SCRIPT_DIR/config-loader.sh" --load 2>/dev/null || {
    echo -e "${RED}ERROR: Failed to load master configuration${NC}"
    exit 1
}

# Get master configuration hash
get_master_hash() {
    if [[ -f "$MASTER_CONFIG" ]]; then
        sha256sum "$MASTER_CONFIG" | cut -d' ' -f1
    else
        echo "MISSING"
    fi
}

# Extract configuration values from JSON checkpoint file
extract_checkpoint_config() {
    local checkpoint_file="$1"
    local temp_config=$(mktemp)

    # Extract relevant configuration values from checkpoint
    if [[ -f "$checkpoint_file" ]] && jq -e . "$checkpoint_file" >/dev/null 2>&1; then
        {
            # Episode duration
            jq -r '.script_results.estimated_duration // "MISSING"' "$checkpoint_file" | sed 's/ minutes//'

            # Character count (approximate from different checkpoint types)
            jq -r '
                if .script_results.character_count then .script_results.character_count
                elif .synthesis_results.character_count then .synthesis_results.character_count
                elif .tts_specifications.character_count_optimized then .tts_specifications.character_count_optimized
                else "MISSING"
                end
            ' "$checkpoint_file"

            # Cost values
            jq -r '.cost_invested // "MISSING"' "$checkpoint_file"

            # Model references
            jq -r '
                if .synthesis_results.model_used then .synthesis_results.model_used
                elif .tts_specifications.target_model then .tts_specifications.target_model
                else "MISSING"
                end
            ' "$checkpoint_file"

            # Voice references
            jq -r '
                if .synthesis_results.voice_used then .synthesis_results.voice_used
                elif .tts_specifications.target_voice then .tts_specifications.target_voice
                else "MISSING"
                end
            ' "$checkpoint_file"

        } > "$temp_config"

        echo "$temp_config"
    else
        echo "/dev/null"
    fi
}

# Compare checkpoint values with master configuration
validate_checkpoint_consistency() {
    local checkpoint_file="$1"
    local session_path="$2"
    local violations=0
    local warnings=0

    echo "  Validating: $(basename "$checkpoint_file")"

    if [[ ! -f "$checkpoint_file" ]]; then
        return 0
    fi

    # Check if checkpoint is valid JSON
    if ! jq -e . "$checkpoint_file" >/dev/null 2>&1; then
        echo "    ⚠️  Invalid JSON format"
        ((warnings++))
        return $warnings
    fi

    # Extract and compare values
    local config_file=$(extract_checkpoint_config "$checkpoint_file")
    if [[ "$config_file" == "/dev/null" ]]; then
        return 0
    fi

    # Duration validation
    local checkpoint_duration=$(sed -n '1p' "$config_file")
    if [[ "$checkpoint_duration" != "MISSING" ]] && [[ "$checkpoint_duration" =~ ^[0-9]+$ ]]; then
        if [[ $checkpoint_duration -lt $CONFIG_EPISODE_DURATION_MIN ]] || [[ $checkpoint_duration -gt $CONFIG_EPISODE_DURATION_MAX ]]; then
            echo "    ❌ Duration drift: ${checkpoint_duration}min (expected: ${CONFIG_EPISODE_DURATION_MIN}-${CONFIG_EPISODE_DURATION_MAX}min)"
            ((violations++))
        fi
    fi

    # Character count validation
    local checkpoint_chars=$(sed -n '2p' "$config_file")
    if [[ "$checkpoint_chars" != "MISSING" ]] && [[ "$checkpoint_chars" =~ ^[0-9]+$ ]]; then
        if [[ $checkpoint_chars -lt $CONFIG_EPISODE_CHARS_MIN ]] || [[ $checkpoint_chars -gt $CONFIG_EPISODE_CHARS_MAX ]]; then
            echo "    ❌ Character drift: ${checkpoint_chars} chars (expected: ${CONFIG_EPISODE_CHARS_MIN}-${CONFIG_EPISODE_CHARS_MAX})"
            ((violations++))
        fi
    fi

    # Model validation
    local checkpoint_model=$(sed -n '4p' "$config_file")
    if [[ "$checkpoint_model" != "MISSING" ]] && [[ "$checkpoint_model" != "$CONFIG_ELEVENLABS_MODEL_ID" ]]; then
        echo "    ❌ Model drift: $checkpoint_model (expected: $CONFIG_ELEVENLABS_MODEL_ID)"
        ((violations++))
    fi

    # Cost validation (approximate)
    local checkpoint_cost=$(sed -n '3p' "$config_file")
    if [[ "$checkpoint_cost" != "MISSING" ]] && [[ "$checkpoint_cost" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        local cost_diff=$(echo "$checkpoint_cost - $CONFIG_COST_PER_EPISODE_TARGET" | bc -l 2>/dev/null || echo "0")
        local abs_diff=$(echo "$cost_diff" | sed 's/-//')
        if (( $(echo "$abs_diff > 2.0" | bc -l 2>/dev/null || echo 0) )); then
            echo "    ⚠️  Cost variance: \$${checkpoint_cost} (expected: ~\$${CONFIG_COST_PER_EPISODE_TARGET})"
            ((warnings++))
        fi
    fi

    rm -f "$config_file"
    return $((violations + warnings))
}

# Scan single session for configuration drift
scan_session() {
    local session_path="$1"
    local session_id=$(basename "$session_path")
    local violations=0
    local warnings=0

    if [[ ! -d "$session_path" ]]; then
        return 0
    fi

    echo "📁 Session: $session_id"

    # Check for session configuration hash file
    local session_hash_file="$session_path/config_hash.txt"
    local master_hash=$(get_master_hash)

    if [[ -f "$session_hash_file" ]]; then
        local session_hash=$(cat "$session_hash_file")
        if [[ "$session_hash" != "$master_hash" ]]; then
            echo "  ⚠️  Configuration hash mismatch"
            echo "    Session: ${session_hash:0:8}..."
            echo "    Master:  ${master_hash:0:8}..."
            ((warnings++))
        fi
    else
        # Create hash file for future checks
        echo "$master_hash" > "$session_hash_file"
        echo "  ℹ️  Created configuration hash reference"
    fi

    # Scan checkpoint files
    local checkpoint_files=$(find "$session_path" -name "*_complete.json" 2>/dev/null | sort)

    if [[ -z "$checkpoint_files" ]]; then
        echo "  ℹ️  No checkpoint files found"
        return 0
    fi

    while IFS= read -r checkpoint_file; do
        [[ -z "$checkpoint_file" ]] && continue
        validate_checkpoint_consistency "$checkpoint_file" "$session_path"
        local result=$?
        ((violations += result))
    done <<< "$checkpoint_files"

    if [[ $violations -eq 0 ]]; then
        echo "  ✅ Configuration consistent"
    else
        echo "  ❌ $violations configuration issues found"
    fi

    echo ""
    return $violations
}

# Full system drift scan
scan_all_sessions() {
    echo -e "${BLUE}🔍 Configuration Drift Detection - Full System Scan${NC}"
    echo "Master Config: $MASTER_CONFIG"
    echo "Sessions Directory: $SESSIONS_DIR"
    echo "Scan Time: $(date)"
    echo ""

    if [[ ! -d "$SESSIONS_DIR" ]]; then
        echo -e "${YELLOW}No sessions directory found: $SESSIONS_DIR${NC}"
        return 0
    fi

    local total_violations=0
    local total_warnings=0
    local sessions_scanned=0

    # Scan each session directory
    local sessions=$(find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

    if [[ -z "$sessions" ]]; then
        echo -e "${YELLOW}No session directories found${NC}"
        return 0
    fi

    while IFS= read -r session_path; do
        [[ -z "$session_path" ]] && continue
        ((sessions_scanned++))

        scan_session "$session_path"
        local session_result=$?
        ((total_violations += session_result))

    done <<< "$sessions"

    # Log results
    local log_entry="$(date -Iseconds) | Scanned: $sessions_scanned | Violations: $total_violations | Hash: $(get_master_hash | cut -c1-8)"
    echo "$log_entry" >> "$DRIFT_LOG"

    echo "=== DRIFT DETECTION SUMMARY ==="
    echo "Sessions scanned: $sessions_scanned"
    echo "Total violations: $total_violations"
    echo "Master config hash: $(get_master_hash | cut -c1-8)..."
    echo ""

    if [[ $total_violations -gt 0 ]]; then
        echo -e "${RED}❌ CONFIGURATION DRIFT DETECTED${NC}"
        echo ""
        echo -e "${YELLOW}Recommended actions:${NC}"
        echo "1. Review sessions with violations above"
        echo "2. Consider session regeneration for major drift"
        echo "3. Update session checkpoints if master config changed"
        echo "4. Run: tools/session-migrator.sh (when available)"
        return 1
    else
        echo -e "${GREEN}✅ NO CONFIGURATION DRIFT DETECTED${NC}"
        echo "All sessions are consistent with master configuration"
        return 0
    fi
}

# Quick drift check for specific session
quick_session_check() {
    local session_id="$1"
    local session_path="$SESSIONS_DIR/$session_id"

    if [[ -z "$session_id" ]]; then
        echo -e "${RED}ERROR: Session ID required${NC}"
        echo "Usage: $0 check <session_id>"
        return 1
    fi

    if [[ ! -d "$session_path" ]]; then
        echo -e "${RED}ERROR: Session not found: $session_path${NC}"
        return 1
    fi

    echo -e "${BLUE}🔍 Quick Configuration Check${NC}"
    echo "Session: $session_id"
    echo ""

    scan_session "$session_path"
}

# Show drift detection log
show_drift_log() {
    if [[ ! -f "$DRIFT_LOG" ]]; then
        echo -e "${YELLOW}No drift detection log found${NC}"
        return 0
    fi

    echo -e "${BLUE}📊 Configuration Drift History${NC}"
    echo ""
    tail -20 "$DRIFT_LOG" | while IFS= read -r line; do
        if [[ "$line" == *"Violations: 0"* ]]; then
            echo -e "${GREEN}✅ $line${NC}"
        else
            echo -e "${YELLOW}⚠️  $line${NC}"
        fi
    done
}

# Generate session health report
generate_health_report() {
    local report_file="$BASE_DIR/analysis/session_health_report.txt"
    mkdir -p "$(dirname "$report_file")"

    echo -e "${BLUE}📊 Generating Session Health Report${NC}"

    {
        echo "Session Health Report - $(date)"
        echo "========================================"
        echo ""
        echo "Master Configuration:"
        echo "  File: $MASTER_CONFIG"
        echo "  Hash: $(get_master_hash)"
        echo "  Version: $CONFIG_VERSION"
        echo ""
        echo "Session Analysis:"
        echo ""

        # Scan and report on each session
        local sessions=$(find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
        local healthy=0
        local problematic=0

        while IFS= read -r session_path; do
            [[ -z "$session_path" ]] && continue

            local session_id=$(basename "$session_path")
            local checkpoint_count=$(find "$session_path" -name "*_complete.json" | wc -l)
            local session_hash_file="$session_path/config_hash.txt"
            local config_status="MISSING"

            if [[ -f "$session_hash_file" ]]; then
                local session_hash=$(cat "$session_hash_file")
                local master_hash=$(get_master_hash)
                if [[ "$session_hash" == "$master_hash" ]]; then
                    config_status="CURRENT"
                    ((healthy++))
                else
                    config_status="DRIFT"
                    ((problematic++))
                fi
            else
                ((problematic++))
            fi

            echo "Session: $session_id"
            echo "  Checkpoints: $checkpoint_count"
            echo "  Config Status: $config_status"
            echo ""

        done <<< "$sessions"

        echo "========================================"
        echo "Health Summary:"
        echo "  Healthy sessions: $healthy"
        echo "  Problematic sessions: $problematic"
        echo "  Total sessions: $((healthy + problematic))"
        echo ""
        echo "Report generated: $(date)"

    } | tee "$report_file"

    echo ""
    echo "Health report saved to: $report_file"
}

# Main execution
main() {
    local command="${1:-scan}"

    case "$command" in
        "scan"|"--scan")
            scan_all_sessions
            ;;
        "check"|"--check")
            quick_session_check "$2"
            ;;
        "log"|"--log")
            show_drift_log
            ;;
        "report"|"--report")
            generate_health_report
            ;;
        "help"|"--help")
            echo "Configuration Drift Detector - Runtime Validation System"
            echo ""
            echo "Usage: $0 [command] [args]"
            echo ""
            echo "Commands:"
            echo "  scan              Full system drift scan (default)"
            echo "  check <session>   Quick check for specific session"
            echo "  log               Show drift detection history"
            echo "  report            Generate session health report"
            echo "  help              Show this help"
            echo ""
            echo "What it detects:"
            echo "  - Episode duration outside configured range"
            echo "  - Character counts outside target range"
            echo "  - Wrong TTS models in checkpoints"
            echo "  - Configuration hash mismatches"
            echo "  - Cost variances beyond reasonable limits"
            echo ""
            echo "Example usage:"
            echo "  $0 scan                    # Scan all sessions"
            echo "  $0 check ep_001_20250814   # Check specific session"
            echo "  $0 log                     # View detection history"
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"
