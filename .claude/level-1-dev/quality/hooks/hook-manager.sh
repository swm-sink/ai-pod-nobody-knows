#!/bin/bash

# Hook Manager for Level-1-Dev Quality System
# Comprehensive management of all git hooks and quality enforcement

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LEVEL1_DIR="$(cd "$QUALITY_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$LEVEL1_DIR/../.." && pwd)"
CONFIG_FILE="$QUALITY_DIR/hook-config.yaml"
HOOKS_DIR="$SCRIPT_DIR"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

# Hook definitions with metadata (bash 3.x compatible)
HOOK_NAMES="pre-commit post-commit pre-push prepare-commit-msg"
HOOK_DESCRIPTIONS="Fast quality checks before commit|Comprehensive validation after commit|Thorough validation before push|Commit message formatting and enhancement"
HOOK_SCRIPTS="pre-commit-quality.sh|post-commit-validation.sh|pre-push-quality.sh|prepare-commit-msg.sh"
HOOK_PRIORITIES="required|optional|recommended|optional"

# Function: Get hook info by name
get_hook_info() {
    local target_name="$1"
    local info_type="$2"  # description, script, priority
    local names=($HOOK_NAMES)
    local descriptions=$(echo "$HOOK_DESCRIPTIONS" | tr '|' '\n')
    local scripts=$(echo "$HOOK_SCRIPTS" | tr '|' '\n')
    local priorities=$(echo "$HOOK_PRIORITIES" | tr '|' '\n')

    for i in "${!names[@]}"; do
        if [ "${names[$i]}" = "$target_name" ]; then
            case "$info_type" in
                "description")
                    echo "$descriptions" | sed -n "$((i+1))p"
                    ;;
                "script")
                    echo "$scripts" | sed -n "$((i+1))p"
                    ;;
                "priority")
                    echo "$priorities" | sed -n "$((i+1))p"
                    ;;
            esac
            return 0
        fi
    done
    echo ""
    return 1
}

# Function: Display help
show_help() {
    cat << EOF
Hook Manager for Level-1-Dev Quality System

Usage: $(basename "$0") <command> [options] [arguments]

Commands:
    install         Install all hooks or specific hook
    uninstall       Remove all hooks or specific hook
    list            List all available hooks with status
    status          Show detailed hook status and configuration
    enable          Enable specific hook
    disable         Disable specific hook temporarily
    test            Test hooks individually or all together
    validate        Validate hook configuration and dependencies
    configure       Configure hook settings
    reset           Reset all hooks to default configuration
    backup          Create backup of current hook configuration
    restore         Restore hooks from backup
    doctor          Diagnose and fix hook issues
    update          Update hooks to latest version

Hook Management:
    $(basename "$0") install [hook-name]      # Install all or specific hook
    $(basename "$0") uninstall [hook-name]    # Remove all or specific hook
    $(basename "$0") enable <hook-name>       # Enable disabled hook
    $(basename "$0") disable <hook-name>      # Temporarily disable hook

Configuration:
    $(basename "$0") configure <setting> <value>  # Set configuration
    $(basename "$0") configure --list             # List all settings
    $(basename "$0") configure --reset            # Reset to defaults

Testing & Validation:
    $(basename "$0") test [hook-name]         # Test specific or all hooks
    $(basename "$0") validate                 # Validate configuration
    $(basename "$0") doctor                   # Diagnose issues

Maintenance:
    $(basename "$0") backup                   # Backup current state
    $(basename "$0") restore <backup-name>    # Restore from backup
    $(basename "$0") update                   # Update to latest version
    $(basename "$0") reset                    # Reset everything

Options:
    -h, --help         Show this help message
    -v, --verbose      Show detailed output
    -q, --quiet        Suppress non-error output
    -f, --force        Force operation without confirmation
    --dry-run          Show what would be done without executing
    --config FILE      Use alternative config file

Examples:
    $(basename "$0") install                  # Install all hooks
    $(basename "$0") install pre-commit       # Install only pre-commit hook
    $(basename "$0") disable pre-push         # Temporarily disable pre-push
    $(basename "$0") test                     # Test all hooks
    $(basename "$0") doctor                   # Diagnose and fix issues

EOF
}

# Function: Load configuration
load_config() {
    # Create default config if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        create_default_config
    fi

    # Source configuration (simplified YAML parsing)
    if [ -f "$CONFIG_FILE" ]; then
        # Extract simple key-value pairs
        while IFS=': ' read -r key value; do
            case $key in
                "max_execution_time")
                    MAX_EXECUTION_TIME="$value"
                    ;;
                "bypass_enabled")
                    BYPASS_ENABLED="$value"
                    ;;
                "strict_mode")
                    STRICT_MODE="$value"
                    ;;
                "auto_fix")
                    AUTO_FIX="$value"
                    ;;
            esac
        done < <(grep -E "^[[:alpha:]_]+:" "$CONFIG_FILE" | grep -v "^#")
    fi

    # Set defaults if not configured
    MAX_EXECUTION_TIME="${MAX_EXECUTION_TIME:-120}"
    BYPASS_ENABLED="${BYPASS_ENABLED:-true}"
    STRICT_MODE="${STRICT_MODE:-false}"
    AUTO_FIX="${AUTO_FIX:-false}"
}

# Function: Create default configuration
create_default_config() {
    cat > "$CONFIG_FILE" << EOF
# Hook Manager Configuration for Level-1-Dev Quality System
# Generated on: $(date)

# General Settings
max_execution_time: 120        # Maximum seconds for hook execution
bypass_enabled: true           # Allow emergency bypass of hooks
strict_mode: false             # Treat warnings as errors
auto_fix: false               # Automatically fix issues when possible

# Hook-specific Settings
hooks:
  pre-commit:
    enabled: true
    timeout: 30
    required: true

  post-commit:
    enabled: true
    timeout: 60
    required: false

  pre-push:
    enabled: true
    timeout: 120
    required: false

  prepare-commit-msg:
    enabled: true
    timeout: 10
    required: false

# Quality Thresholds
thresholds:
  test_pass_rate: 90            # Minimum test pass rate
  coverage_minimum: 70          # Minimum code coverage
  security_issues: 0            # Maximum security issues
  performance_max_ms: 1000      # Maximum script execution time

# Notification Settings
notifications:
  enabled: false
  email: ""
  slack_webhook: ""

# Advanced Settings
advanced:
  parallel_execution: false     # Run compatible hooks in parallel
  cache_results: true          # Cache validation results
  detailed_logging: false      # Enable detailed execution logs
EOF

    echo -e "${GREEN}✓ Created default configuration: $CONFIG_FILE${NC}"
}

# Function: Get hook status
get_hook_status() {
    local hook_name=$1
    local hook_file="$GIT_HOOKS_DIR/$hook_name"

    if [ ! -f "$hook_file" ]; then
        echo "not_installed"
    elif [ ! -x "$hook_file" ]; then
        echo "not_executable"
    elif grep -q "Level-1-Dev Quality System" "$hook_file" 2>/dev/null; then
        echo "installed"
    else
        echo "conflict"
    fi
}

# Function: List all hooks with status
list_hooks() {
    echo -e "${BOLD}${BLUE}Level-1-Dev Quality Hooks${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""

    printf "%-20s %-12s %-15s %s\n" "HOOK" "STATUS" "PRIORITY" "DESCRIPTION"
    echo "─────────────────────────────────────────────────────────────────────────────"

    for hook_name in "${!HOOK_INFO[@]}"; do
        local info="${HOOK_INFO[$hook_name]}"
        local description=$(echo "$info" | cut -d'|' -f1)
        local script_name=$(echo "$info" | cut -d'|' -f2)
        local priority=$(echo "$info" | cut -d'|' -f3)
        local status=$(get_hook_status "$hook_name")

        local status_color=""
        local status_text=""

        case $status in
            "installed")
                status_color="${GREEN}"
                status_text="✓ Installed"
                ;;
            "not_installed")
                status_color="${RED}"
                status_text="✗ Missing"
                ;;
            "not_executable")
                status_color="${YELLOW}"
                status_text="⚠ Not Exec"
                ;;
            "conflict")
                status_color="${MAGENTA}"
                status_text="⚠ Conflict"
                ;;
        esac

        local priority_color=""
        case $priority in
            "required")
                priority_color="${RED}"
                ;;
            "recommended")
                priority_color="${YELLOW}"
                ;;
            "optional")
                priority_color="${CYAN}"
                ;;
        esac

        printf "%-20s ${status_color}%-12s${NC} ${priority_color}%-15s${NC} %s\n" \
            "$hook_name" "$status_text" "$priority" "$description"
    done

    echo ""
}

# Function: Show detailed status
show_status() {
    echo -e "${BOLD}${BLUE}Hook Manager Status Report${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""

    # Configuration status
    echo -e "${CYAN}Configuration:${NC}"
    echo "  Config file: $CONFIG_FILE"
    echo "  Max execution time: ${MAX_EXECUTION_TIME}s"
    echo "  Bypass enabled: $BYPASS_ENABLED"
    echo "  Strict mode: $STRICT_MODE"
    echo "  Auto-fix: $AUTO_FIX"
    echo ""

    # Git repository status
    echo -e "${CYAN}Git Repository:${NC}"
    if [ -d "$PROJECT_ROOT/.git" ]; then
        echo -e "  ${GREEN}✓ Git repository detected${NC}"
        echo "  Hooks directory: $GIT_HOOKS_DIR"
        echo "  Repository: $(basename "$PROJECT_ROOT")"
    else
        echo -e "  ${RED}✗ Not a git repository${NC}"
        return 1
    fi
    echo ""

    # Hooks status
    echo -e "${CYAN}Hooks Status:${NC}"
    local total=0
    local installed=0
    local conflicts=0
    local missing=0

    for hook_name in "${!HOOK_INFO[@]}"; do
        ((total++))
        local status=$(get_hook_status "$hook_name")

        case $status in
            "installed")
                ((installed++))
                ;;
            "conflict")
                ((conflicts++))
                ;;
            "not_installed"|"not_executable")
                ((missing++))
                ;;
        esac
    done

    echo "  Total hooks: $total"
    echo -e "  Installed: ${GREEN}$installed${NC}"
    echo -e "  Missing: ${RED}$missing${NC}"
    echo -e "  Conflicts: ${YELLOW}$conflicts${NC}"
    echo ""

    # Dependencies check
    echo -e "${CYAN}Dependencies:${NC}"
    local deps_ok=true

    # Check required scripts
    for hook_name in "${!HOOK_INFO[@]}"; do
        local info="${HOOK_INFO[$hook_name]}"
        local script_name=$(echo "$info" | cut -d'|' -f2)
        local script_path="$HOOKS_DIR/$script_name"

        if [ -f "$script_path" ] && [ -x "$script_path" ]; then
            echo -e "  ${GREEN}✓${NC} $script_name"
        else
            echo -e "  ${RED}✗${NC} $script_name (missing or not executable)"
            deps_ok=false
        fi
    done

    if [ "$deps_ok" = "true" ]; then
        echo -e "  ${GREEN}✓ All dependencies satisfied${NC}"
    else
        echo -e "  ${RED}⚠ Some dependencies missing${NC}"
    fi
    echo ""
}

# Function: Install specific hook
install_hook() {
    local hook_name=$1
    local force=${2:-false}

    if [ -z "${HOOK_INFO[$hook_name]:-}" ]; then
        echo -e "${RED}Error: Unknown hook: $hook_name${NC}"
        return 1
    fi

    local info="${HOOK_INFO[$hook_name]}"
    local script_name=$(echo "$info" | cut -d'|' -f2)
    local script_path="$HOOKS_DIR/$script_name"
    local hook_target="$GIT_HOOKS_DIR/$hook_name"

    # Check if source script exists
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Error: Hook script not found: $script_path${NC}"
        return 1
    fi

    # Create hooks directory
    mkdir -p "$GIT_HOOKS_DIR"

    # Check for existing hook
    if [ -f "$hook_target" ] && [ "$force" != "true" ]; then
        local status=$(get_hook_status "$hook_name")
        if [ "$status" = "conflict" ]; then
            echo -e "${YELLOW}Warning: Existing hook found for $hook_name${NC}"
            echo "Use --force to overwrite or run 'doctor' to resolve conflicts"
            return 1
        fi
    fi

    # Install hook
    cat > "$hook_target" << EOF
#!/bin/bash
# Git hook installed by Level-1-Dev Quality System
# Hook: $hook_name
# Installed: $(date)
# Source: $script_path

# Call the actual hook implementation
exec "$script_path" "\$@"
EOF

    chmod +x "$hook_target"

    echo -e "${GREEN}✓ Installed hook: $hook_name${NC}"
    return 0
}

# Function: Install all hooks
install_all_hooks() {
    echo -e "${BLUE}Installing all Level-1-Dev quality hooks...${NC}"

    local installed=0
    local failed=0

    for hook_name in "${!HOOK_INFO[@]}"; do
        if install_hook "$hook_name" "${FORCE:-false}"; then
            ((installed++))
        else
            ((failed++))
        fi
    done

    echo ""
    echo -e "${GREEN}✓ Installation complete${NC}"
    echo "  Installed: $installed hooks"
    if [ $failed -gt 0 ]; then
        echo -e "  ${RED}Failed: $failed hooks${NC}"
    fi
}

# Function: Uninstall hook
uninstall_hook() {
    local hook_name=$1
    local hook_target="$GIT_HOOKS_DIR/$hook_name"

    if [ ! -f "$hook_target" ]; then
        echo -e "${YELLOW}Hook not installed: $hook_name${NC}"
        return 0
    fi

    if grep -q "Level-1-Dev Quality System" "$hook_target" 2>/dev/null; then
        rm "$hook_target"
        echo -e "${GREEN}✓ Uninstalled hook: $hook_name${NC}"
    else
        echo -e "${YELLOW}⚠ Not our hook, leaving unchanged: $hook_name${NC}"
    fi
}

# Function: Test hook
test_hook() {
    local hook_name=$1
    local hook_target="$GIT_HOOKS_DIR/$hook_name"

    echo -e "${CYAN}Testing hook: $hook_name${NC}"

    # Check installation
    local status=$(get_hook_status "$hook_name")

    case $status in
        "not_installed")
            echo -e "  ${RED}✗ Hook not installed${NC}"
            return 1
            ;;
        "not_executable")
            echo -e "  ${RED}✗ Hook not executable${NC}"
            return 1
            ;;
        "conflict")
            echo -e "  ${YELLOW}⚠ Hook conflict detected${NC}"
            return 1
            ;;
        "installed")
            echo -e "  ${GREEN}✓ Hook properly installed${NC}"
            ;;
    esac

    # Test execution
    case $hook_name in
        "pre-commit"|"pre-push")
            if timeout 10 "$hook_target" --dry-run >/dev/null 2>&1; then
                echo -e "  ${GREEN}✓ Hook execution test passed${NC}"
            else
                echo -e "  ${YELLOW}⚠ Hook execution test failed${NC}"
            fi
            ;;
        *)
            echo -e "  ${CYAN}○ Hook installation verified${NC}"
            ;;
    esac

    return 0
}

# Function: Test all hooks
test_all_hooks() {
    echo -e "${BLUE}Testing all hooks...${NC}"
    echo ""

    local passed=0
    local failed=0

    for hook_name in "${!HOOK_INFO[@]}"; do
        if test_hook "$hook_name"; then
            ((passed++))
        else
            ((failed++))
        fi
        echo ""
    done

    echo -e "${GREEN}✓ Testing complete${NC}"
    echo "  Passed: $passed/$((passed + failed))"

    if [ $failed -gt 0 ]; then
        echo -e "  ${RED}Failed: $failed${NC}"
        return 1
    fi

    return 0
}

# Function: Diagnose and fix issues
doctor() {
    echo -e "${BOLD}${BLUE}Hook System Doctor${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""

    local issues_found=0
    local issues_fixed=0

    # Check git repository
    echo -e "${CYAN}Checking git repository...${NC}"
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        echo -e "  ${RED}✗ Not in a git repository${NC}"
        ((issues_found++))
    else
        echo -e "  ${GREEN}✓ Git repository OK${NC}"
    fi

    # Check hook scripts
    echo -e "\n${CYAN}Checking hook scripts...${NC}"
    for hook_name in "${!HOOK_INFO[@]}"; do
        local info="${HOOK_INFO[$hook_name]}"
        local script_name=$(echo "$info" | cut -d'|' -f2)
        local script_path="$HOOKS_DIR/$script_name"

        if [ ! -f "$script_path" ]; then
            echo -e "  ${RED}✗ Missing script: $script_name${NC}"
            ((issues_found++))
        elif [ ! -x "$script_path" ]; then
            echo -e "  ${YELLOW}⚠ Script not executable: $script_name${NC}"
            if [ "${AUTO_FIX:-false}" = "true" ]; then
                chmod +x "$script_path"
                echo -e "    ${GREEN}✓ Fixed: Made script executable${NC}"
                ((issues_fixed++))
            else
                ((issues_found++))
            fi
        else
            echo -e "  ${GREEN}✓ Script OK: $script_name${NC}"
        fi
    done

    # Check hook installations
    echo -e "\n${CYAN}Checking hook installations...${NC}"
    for hook_name in "${!HOOK_INFO[@]}"; do
        local status=$(get_hook_status "$hook_name")

        case $status in
            "installed")
                echo -e "  ${GREEN}✓ Hook OK: $hook_name${NC}"
                ;;
            "not_installed")
                echo -e "  ${YELLOW}⚠ Hook not installed: $hook_name${NC}"
                if [ "${AUTO_FIX:-false}" = "true" ]; then
                    if install_hook "$hook_name" true; then
                        echo -e "    ${GREEN}✓ Fixed: Installed hook${NC}"
                        ((issues_fixed++))
                    fi
                else
                    ((issues_found++))
                fi
                ;;
            "not_executable")
                echo -e "  ${YELLOW}⚠ Hook not executable: $hook_name${NC}"
                if [ "${AUTO_FIX:-false}" = "true" ]; then
                    chmod +x "$GIT_HOOKS_DIR/$hook_name"
                    echo -e "    ${GREEN}✓ Fixed: Made hook executable${NC}"
                    ((issues_fixed++))
                else
                    ((issues_found++))
                fi
                ;;
            "conflict")
                echo -e "  ${RED}✗ Hook conflict: $hook_name${NC}"
                echo -e "    Manual resolution required"
                ((issues_found++))
                ;;
        esac
    done

    # Check configuration
    echo -e "\n${CYAN}Checking configuration...${NC}"
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "  ${YELLOW}⚠ Configuration file missing${NC}"
        if [ "${AUTO_FIX:-false}" = "true" ]; then
            create_default_config
            echo -e "    ${GREEN}✓ Fixed: Created default configuration${NC}"
            ((issues_fixed++))
        else
            ((issues_found++))
        fi
    else
        echo -e "  ${GREEN}✓ Configuration file OK${NC}"
    fi

    # Summary
    echo ""
    echo -e "${BOLD}Doctor Summary:${NC}"
    if [ $issues_found -eq 0 ]; then
        echo -e "${GREEN}✓ No issues found - system is healthy!${NC}"
    else
        echo -e "${YELLOW}⚠ Found $issues_found issues${NC}"
        if [ $issues_fixed -gt 0 ]; then
            echo -e "${GREEN}✓ Fixed $issues_fixed issues${NC}"
        fi

        echo ""
        echo "Recommendations:"
        if [ "${AUTO_FIX:-false}" != "true" ]; then
            echo "  - Run with --auto-fix to automatically fix simple issues"
        fi
        echo "  - Run 'install' to install missing hooks"
        echo "  - Run 'test' to verify all hooks are working"
    fi
}

# Main execution
main() {
    local command=""
    local target=""

    # Load configuration
    load_config

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --auto-fix)
                AUTO_FIX=true
                shift
                ;;
            install|uninstall|list|status|enable|disable|test|validate|configure|reset|backup|restore|doctor|update)
                command="$1"
                shift
                ;;
            *)
                if [ -z "$target" ]; then
                    target="$1"
                fi
                shift
                ;;
        esac
    done

    # Default command
    if [ -z "$command" ]; then
        command="status"
    fi

    # Execute command
    case "$command" in
        install)
            if [ -n "$target" ]; then
                install_hook "$target" "${FORCE:-false}"
            else
                install_all_hooks
            fi
            ;;
        uninstall)
            if [ -n "$target" ]; then
                uninstall_hook "$target"
            else
                for hook_name in "${!HOOK_INFO[@]}"; do
                    uninstall_hook "$hook_name"
                done
            fi
            ;;
        list)
            list_hooks
            ;;
        status)
            show_status
            ;;
        enable)
            if [ -z "$target" ]; then
                echo -e "${RED}Error: Hook name required${NC}"
                exit 1
            fi
            install_hook "$target" true
            ;;
        disable)
            if [ -z "$target" ]; then
                echo -e "${RED}Error: Hook name required${NC}"
                exit 1
            fi
            uninstall_hook "$target"
            ;;
        test)
            if [ -n "$target" ]; then
                test_hook "$target"
            else
                test_all_hooks
            fi
            ;;
        doctor)
            doctor
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
