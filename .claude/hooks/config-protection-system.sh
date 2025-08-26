#!/bin/bash

# Configuration Protection System - Preserve Working Setups
# Prevents accidental configuration drift and enables safe validation
# Research-validated minimal change approach for production systems

# Project root detection
PROJECT_ROOT="$HOME/Documents/GitHub/ai-podcasts-nobody-knows"
cd "$PROJECT_ROOT" 2>/dev/null || true

# Configuration
CONFIG_BACKUP_DIR="$PROJECT_ROOT/.claude/config-backups"
CONFIG_LOG="$PROJECT_ROOT/.claude/logs/config-protection.log"
SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.json"
AGENTS_DIR="$PROJECT_ROOT/.claude/agents"
CONFIG_HASH_FILE="$CONFIG_BACKUP_DIR/config-hashes.json"

# Ensure directories exist
mkdir -p "$CONFIG_BACKUP_DIR" "$PROJECT_ROOT/.claude/logs"

# Generate configuration snapshot ID
generate_snapshot_id() {
    echo "config_$(date +%Y%m%d_%H%M%S)_$(openssl rand -hex 4)" 2>/dev/null || echo "config_$(date +%Y%m%d_%H%M%S)_fallback"
}

# Calculate file hash for change detection
calculate_hash() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        if command -v shasum >/dev/null 2>&1; then
            shasum -a 256 "$file_path" | awk '{print $1}'
        elif command -v sha256sum >/dev/null 2>&1; then
            sha256sum "$file_path" | awk '{print $1}'
        else
            # Fallback to basic checksum
            cksum "$file_path" | awk '{print $1}'
        fi
    else
        echo "missing"
    fi
}

# Create comprehensive configuration snapshot
create_config_snapshot() {
    local snapshot_id=$(generate_snapshot_id)
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')
    local snapshot_dir="$CONFIG_BACKUP_DIR/$snapshot_id"

    # Create snapshot directory
    mkdir -p "$snapshot_dir/agents" "$snapshot_dir/hooks"

    echo "$timestamp CONFIG_SNAPSHOT: Creating comprehensive backup ID=$snapshot_id" >> "$CONFIG_LOG"

    # Backup main settings file
    if [[ -f "$SETTINGS_FILE" ]]; then
        cp "$SETTINGS_FILE" "$snapshot_dir/settings.json"
        echo "$timestamp BACKED_UP: settings.json" >> "$CONFIG_LOG"
    fi

    # Backup all agent configurations
    if [[ -d "$AGENTS_DIR" ]]; then
        cp -r "$AGENTS_DIR"/* "$snapshot_dir/agents/" 2>/dev/null
        local agent_count=$(find "$AGENTS_DIR" -name "*.md" -type f | wc -l)
        echo "$timestamp BACKED_UP: $agent_count agent configurations" >> "$CONFIG_LOG"
    fi

    # Backup hook scripts
    if [[ -d "$PROJECT_ROOT/.claude/hooks" ]]; then
        cp -r "$PROJECT_ROOT/.claude/hooks"/* "$snapshot_dir/hooks/" 2>/dev/null
        local hook_count=$(find "$PROJECT_ROOT/.claude/hooks" -name "*.sh" -type f | wc -l)
        echo "$timestamp BACKED_UP: $hook_count hook scripts" >> "$CONFIG_LOG"
    fi

    # Create snapshot metadata
    cat > "$snapshot_dir/snapshot-metadata.json" <<EOF
{
  "snapshot_id": "$snapshot_id",
  "created_at": "$timestamp",
  "description": "Automated configuration protection snapshot",
  "system_status": "working",
  "episode_basis": "ep001_success",
  "snapshot_type": "comprehensive",
  "files_included": {
    "settings": $([ -f "$snapshot_dir/settings.json" ] && echo "true" || echo "false"),
    "agents_count": $(find "$snapshot_dir/agents" -name "*.md" -type f 2>/dev/null | wc -l),
    "hooks_count": $(find "$snapshot_dir/hooks" -name "*.sh" -type f 2>/dev/null | wc -l)
  }
}
EOF

    # Calculate and store configuration hashes
    update_config_hashes "$snapshot_id"

    echo "Configuration snapshot created: $snapshot_dir" >&2
    echo "$snapshot_id"
}

# Update configuration hash registry
update_config_hashes() {
    local snapshot_id="$1"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    # Calculate current hashes
    local settings_hash=$(calculate_hash "$SETTINGS_FILE")
    local agents_hash=""
    local hooks_hash=""

    # Calculate composite hash for all agent files
    if [[ -d "$AGENTS_DIR" ]]; then
        agents_hash=$(find "$AGENTS_DIR" -name "*.md" -type f -exec shasum -a 256 {} \; 2>/dev/null | \
                     sort | shasum -a 256 | awk '{print $1}')
    fi

    # Calculate composite hash for all hook files
    if [[ -d "$PROJECT_ROOT/.claude/hooks" ]]; then
        hooks_hash=$(find "$PROJECT_ROOT/.claude/hooks" -name "*.sh" -type f -exec shasum -a 256 {} \; 2>/dev/null | \
                    sort | shasum -a 256 | awk '{print $1}')
    fi

    # Create or update hash registry
    local hash_entry="{
        \"timestamp\": \"$timestamp\",
        \"snapshot_id\": \"$snapshot_id\",
        \"hashes\": {
            \"settings\": \"$settings_hash\",
            \"agents_composite\": \"$agents_hash\",
            \"hooks_composite\": \"$hooks_hash\"
        }
    }"

    # Append to hash registry
    if [[ -f "$CONFIG_HASH_FILE" ]]; then
        # Update existing hash file
        local temp_file=$(mktemp)
        jq ". += [$hash_entry]" "$CONFIG_HASH_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_HASH_FILE"
    else
        # Create new hash file
        echo "[$hash_entry]" > "$CONFIG_HASH_FILE"
    fi

    echo "$timestamp HASH_UPDATED: Snapshot=$snapshot_id Settings=$settings_hash" >> "$CONFIG_LOG"
}

# Validate configuration changes (dry-run mode)
validate_config_changes() {
    local validation_mode="${1:-strict}"  # strict, warning, or permissive
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    if [[ ! -f "$CONFIG_HASH_FILE" ]]; then
        echo "WARNING: No baseline configuration hashes found - creating initial snapshot" >&2
        create_config_snapshot
        return 0
    fi

    # Get latest known hashes
    local latest_entry=$(jq '.[-1]' "$CONFIG_HASH_FILE" 2>/dev/null)
    local baseline_settings_hash=$(echo "$latest_entry" | jq -r '.hashes.settings')
    local baseline_agents_hash=$(echo "$latest_entry" | jq -r '.hashes.agents_composite')
    local baseline_hooks_hash=$(echo "$latest_entry" | jq -r '.hashes.hooks_composite')

    # Calculate current hashes
    local current_settings_hash=$(calculate_hash "$SETTINGS_FILE")
    local current_agents_hash=""
    local current_hooks_hash=""

    if [[ -d "$AGENTS_DIR" ]]; then
        current_agents_hash=$(find "$AGENTS_DIR" -name "*.md" -type f -exec shasum -a 256 {} \; 2>/dev/null | \
                             sort | shasum -a 256 | awk '{print $1}')
    fi

    if [[ -d "$PROJECT_ROOT/.claude/hooks" ]]; then
        current_hooks_hash=$(find "$PROJECT_ROOT/.claude/hooks" -name "*.sh" -type f -exec shasum -a 256 {} \; 2>/dev/null | \
                            sort | shasum -a 256 | awk '{print $1}')
    fi

    # Compare hashes and detect changes
    local changes_detected=false
    local changes=()

    if [[ "$current_settings_hash" != "$baseline_settings_hash" ]]; then
        changes_detected=true
        changes+=("settings.json modified")
    fi

    if [[ "$current_agents_hash" != "$baseline_agents_hash" ]]; then
        changes_detected=true
        changes+=("agent configurations modified")
    fi

    if [[ "$current_hooks_hash" != "$baseline_hooks_hash" ]]; then
        changes_detected=true
        changes+=("hook scripts modified")
    fi

    # Log validation results
    echo "$timestamp CONFIG_VALIDATION: Mode=$validation_mode Changes=$changes_detected" >> "$CONFIG_LOG"

    if [[ "$changes_detected" == "true" ]]; then
        echo "CONFIGURATION CHANGES DETECTED:" >&2
        printf '  - %s\n' "${changes[@]}" >&2

        case "$validation_mode" in
            "strict")
                echo "STRICT MODE: Configuration changes not allowed without explicit approval" >&2
                echo "$timestamp CONFIG_BLOCKED: Strict mode prevented configuration changes" >> "$CONFIG_LOG"
                return 1
                ;;
            "warning")
                echo "WARNING MODE: Changes detected but allowing continuation" >&2
                echo "$timestamp CONFIG_WARNING: Changes allowed with warning" >> "$CONFIG_LOG"
                return 0
                ;;
            "permissive")
                echo "PERMISSIVE MODE: Changes detected and allowed" >&2
                echo "$timestamp CONFIG_ALLOWED: Permissive mode allowed changes" >> "$CONFIG_LOG"
                return 0
                ;;
        esac
    else
        echo "CONFIG_VALIDATION: No changes detected - configuration stable" >&2
        return 0
    fi
}

# Restore configuration from snapshot
restore_config_snapshot() {
    local snapshot_id="$1"
    local confirm_restore="${2:-false}"
    local snapshot_dir="$CONFIG_BACKUP_DIR/$snapshot_id"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%S.%3NZ')

    if [[ ! -d "$snapshot_dir" ]]; then
        echo "ERROR: Snapshot not found: $snapshot_id" >&2
        return 1
    fi

    if [[ "$confirm_restore" != "true" ]]; then
        echo "PREVIEW: Would restore configuration from snapshot $snapshot_id" >&2
        echo "Files to restore:" >&2
        if [[ -f "$snapshot_dir/settings.json" ]]; then
            echo "  - settings.json" >&2
        fi
        if [[ -d "$snapshot_dir/agents" ]]; then
            local agent_count=$(find "$snapshot_dir/agents" -name "*.md" -type f | wc -l)
            echo "  - $agent_count agent configurations" >&2
        fi
        if [[ -d "$snapshot_dir/hooks" ]]; then
            local hook_count=$(find "$snapshot_dir/hooks" -name "*.sh" -type f | wc -l)
            echo "  - $hook_count hook scripts" >&2
        fi
        echo "Use 'restore_config_snapshot $snapshot_id true' to confirm restore" >&2
        return 0
    fi

    echo "$timestamp CONFIG_RESTORE: Starting restoration from snapshot $snapshot_id" >> "$CONFIG_LOG"

    # Create backup of current state before restore
    local pre_restore_backup=$(create_config_snapshot)
    echo "Pre-restore backup created: $pre_restore_backup" >&2

    # Restore settings
    if [[ -f "$snapshot_dir/settings.json" ]]; then
        cp "$snapshot_dir/settings.json" "$SETTINGS_FILE"
        echo "$timestamp RESTORED: settings.json" >> "$CONFIG_LOG"
    fi

    # Restore agents
    if [[ -d "$snapshot_dir/agents" ]]; then
        # Clear existing agents and restore
        rm -rf "$AGENTS_DIR"/*
        cp -r "$snapshot_dir/agents"/* "$AGENTS_DIR/"
        local agent_count=$(find "$AGENTS_DIR" -name "*.md" -type f | wc -l)
        echo "$timestamp RESTORED: $agent_count agent configurations" >> "$CONFIG_LOG"
    fi

    # Restore hooks
    if [[ -d "$snapshot_dir/hooks" ]]; then
        # Restore hooks (preserve enhanced ones we just created)
        cp -r "$snapshot_dir/hooks"/* "$PROJECT_ROOT/.claude/hooks/"
        local hook_count=$(find "$PROJECT_ROOT/.claude/hooks" -name "*.sh" -type f | wc -l)
        echo "$timestamp RESTORED: $hook_count hook scripts" >> "$CONFIG_LOG"
    fi

    echo "Configuration restored from snapshot: $snapshot_id" >&2
    echo "Pre-restore backup available: $pre_restore_backup" >&2
}

# List available configuration snapshots
list_snapshots() {
    local format="${1:-table}"  # table or json

    if [[ ! -d "$CONFIG_BACKUP_DIR" ]]; then
        echo "No configuration snapshots found" >&2
        return 1
    fi

    case "$format" in
        "table")
            echo "Available Configuration Snapshots:" >&2
            echo "ID                           | Created              | Type          | Status" >&2
            echo "-----------------------------|----------------------|---------------|--------" >&2
            for snapshot_dir in "$CONFIG_BACKUP_DIR"/config_*; do
                if [[ -d "$snapshot_dir" && -f "$snapshot_dir/snapshot-metadata.json" ]]; then
                    local snapshot_id=$(basename "$snapshot_dir")
                    local created_at=$(jq -r '.created_at' "$snapshot_dir/snapshot-metadata.json" | cut -dT -f1)
                    local snapshot_type=$(jq -r '.snapshot_type' "$snapshot_dir/snapshot-metadata.json")
                    local system_status=$(jq -r '.system_status' "$snapshot_dir/snapshot-metadata.json")
                    printf "%-28s | %-20s | %-13s | %s\n" "$snapshot_id" "$created_at" "$snapshot_type" "$system_status" >&2
                fi
            done
            ;;
        "json")
            local snapshots=()
            for snapshot_dir in "$CONFIG_BACKUP_DIR"/config_*; do
                if [[ -d "$snapshot_dir" && -f "$snapshot_dir/snapshot-metadata.json" ]]; then
                    snapshots+=("$(cat "$snapshot_dir/snapshot-metadata.json")")
                fi
            done
            printf '%s\n' "${snapshots[@]}" | jq -s '.'
            ;;
    esac
}

# Main execution
main() {
    local operation="${1:-create_snapshot}"
    local param1="$2"
    local param2="$3"

    case "$operation" in
        "create_snapshot")
            create_config_snapshot
            ;;
        "validate_changes")
            validate_config_changes "${param1:-warning}"
            ;;
        "restore_snapshot")
            restore_config_snapshot "$param1" "$param2"
            ;;
        "list_snapshots")
            list_snapshots "${param1:-table}"
            ;;
        "update_hashes")
            update_config_hashes "${param1:-current}"
            ;;
        *)
            echo "Usage: $0 {create_snapshot|validate_changes|restore_snapshot|list_snapshots|update_hashes} [params...]" >&2
            echo "Examples:" >&2
            echo "  $0 create_snapshot" >&2
            echo "  $0 validate_changes strict|warning|permissive" >&2
            echo "  $0 restore_snapshot <snapshot_id> [true]" >&2
            echo "  $0 list_snapshots table|json" >&2
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
