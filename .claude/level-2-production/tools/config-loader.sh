#!/usr/bin/env bash

# Configuration Loader - Runtime Configuration Loading System
# Loads master configuration and exports as environment variables
# Used by ALL agents, tools, and commands for consistent configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration paths - handle sourcing vs direct execution
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced, use current working directory approach
    if [[ "$(basename "$PWD")" == "level-2-production" ]]; then
        BASE_DIR="$PWD"
        SCRIPT_DIR="$PWD/tools"
    else
        # Try to find level-2-production directory
        BASE_DIR="$(find . -name "level-2-production" -type d 2>/dev/null | head -1)"
        if [[ -z "$BASE_DIR" ]]; then
            BASE_DIR="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.claude/level-2-production"
        fi
        SCRIPT_DIR="$BASE_DIR/tools"
    fi
else
    # Script is being executed directly
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BASE_DIR="$(dirname "$SCRIPT_DIR")"
fi

MASTER_CONFIG="${BASE_DIR}/config/production-config.yaml"
CONFIG_CACHE="/tmp/claude_config_cache"
CONFIG_LOCK="/tmp/claude_config_lock"

# Check if yq is available, fallback to Python processor
YQ_CMD=""
if command -v yq &> /dev/null; then
    YQ_CMD="yq eval"
elif [[ -f "$SCRIPT_DIR/yaml-processor.py" ]] && command -v python3 &> /dev/null; then
    YQ_CMD="python3 $SCRIPT_DIR/yaml-processor.py"
    echo -e "${YELLOW}Note: Using Python YAML processor (yq not found)${NC}" >&2
else
    echo -e "${RED}ERROR: Neither yq nor Python YAML processor available${NC}" >&2
    echo "Install yq with: brew install yq" >&2
    echo "Or ensure Python3 with PyYAML is available" >&2
    exit 1
fi

# YAML query function
yq_eval() {
    local query="$1"
    local file="$2"

    if [[ "$YQ_CMD" == "yq eval" ]]; then
        yq eval "$query" "$file"
    else
        # Use Python processor
        python3 "$SCRIPT_DIR/yaml-processor.py" "$query" "$file"
    fi
}

# Lock mechanism to prevent concurrent loading
acquire_lock() {
    local timeout=30
    local count=0

    while [[ -f "$CONFIG_LOCK" ]] && [[ $count -lt $timeout ]]; do
        sleep 1
        ((count++))
    done

    if [[ -f "$CONFIG_LOCK" ]]; then
        echo -e "${YELLOW}WARNING: Config lock timeout, forcing reload${NC}" >&2
        rm -f "$CONFIG_LOCK"
    fi

    touch "$CONFIG_LOCK"
}

# Release lock
release_lock() {
    rm -f "$CONFIG_LOCK"
}

# Ensure cleanup on exit
trap 'release_lock' EXIT

# Validate master config exists and is readable
validate_master_config() {
    if [[ ! -f "$MASTER_CONFIG" ]]; then
        echo -e "${RED}CRITICAL: Master configuration not found: $MASTER_CONFIG${NC}" >&2
        echo "The production system requires master configuration to operate" >&2
        echo "Expected location: .claude/level-2-production/config/production-config.yaml" >&2
        exit 1
    fi

    if [[ ! -r "$MASTER_CONFIG" ]]; then
        echo -e "${RED}CRITICAL: Master configuration not readable: $MASTER_CONFIG${NC}" >&2
        exit 1
    fi

    # Validate YAML syntax
    if ! yq_eval '.' "$MASTER_CONFIG" >/dev/null 2>&1; then
        echo -e "${RED}CRITICAL: Master configuration has invalid YAML syntax${NC}" >&2
        echo "File: $MASTER_CONFIG" >&2
        exit 1
    fi

    # Validate required top-level sections
    local required_sections=("episode" "apis" "costs" "quality" "paths")
    for section in "${required_sections[@]}"; do
        if ! yq_eval "has(\"$section\")" "$MASTER_CONFIG" | grep -q "true"; then
            echo -e "${RED}CRITICAL: Master config missing required section: $section${NC}" >&2
            exit 1
        fi
    done
}

# Generate configuration hash for drift detection
generate_config_hash() {
    sha256sum "$MASTER_CONFIG" | cut -d' ' -f1
}

# Check if config cache is valid
is_cache_valid() {
    if [[ ! -f "$CONFIG_CACHE" ]]; then
        return 1
    fi

    # Check if cache is newer than config file
    if [[ "$MASTER_CONFIG" -nt "$CONFIG_CACHE" ]]; then
        return 1
    fi

    # Check if cache has required environment marker
    if ! grep -q "CONFIG_LOADED=true" "$CONFIG_CACHE" 2>/dev/null; then
        return 1
    fi

    return 0
}

# Load configuration and export environment variables
load_master_config() {
    acquire_lock

    echo -e "${BLUE}🔧 Loading Master Configuration${NC}"
    echo "Source: $MASTER_CONFIG"

    validate_master_config

    # Check cache validity
    if is_cache_valid && [[ "$1" != "--force" ]]; then
        echo -e "${GREEN}✅ Using cached configuration${NC}"
        source "$CONFIG_CACHE"
        release_lock
        return 0
    fi

    echo -e "${BLUE}📖 Parsing configuration from master source${NC}"

    # Create temporary file for environment variables
    local temp_env=$(mktemp)

    # Export configuration marker
    echo "export CONFIG_LOADED=true" >> "$temp_env"
    echo "export CONFIG_VERSION=$(yq_eval '.metadata.version' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_HASH=$(generate_config_hash)" >> "$temp_env"
    echo "export CONFIG_LAST_LOADED=$(date -Iseconds)" >> "$temp_env"

    # Episode specifications
    echo "export CONFIG_EPISODE_DURATION_TARGET=$(yq_eval '.episode.duration.target_minutes' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_EPISODE_DURATION_MIN=$(yq_eval '.episode.duration.min_minutes' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_EPISODE_DURATION_MAX=$(yq_eval '.episode.duration.max_minutes' "$MASTER_CONFIG")" >> "$temp_env"

    echo "export CONFIG_EPISODE_WORDS_TARGET=$(yq_eval '.episode.content.words.target' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_EPISODE_WORDS_MIN=$(yq_eval '.episode.content.words.min' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_EPISODE_WORDS_MAX=$(yq_eval '.episode.content.words.max' "$MASTER_CONFIG")" >> "$temp_env"

    echo "export CONFIG_EPISODE_CHARS_TARGET=$(yq_eval '.episode.content.characters.target' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_EPISODE_CHARS_MIN=$(yq_eval '.episode.content.characters.min' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_EPISODE_CHARS_MAX=$(yq_eval '.episode.content.characters.max' "$MASTER_CONFIG")" >> "$temp_env"

    # API configurations
    echo "export CONFIG_ELEVENLABS_MODEL_ID=\"$(yq_eval '.apis.elevenlabs.model.id' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_MODEL_NAME=\"$(yq_eval '.apis.elevenlabs.model.name' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_VOICE_NAME=\"$(yq_eval '.apis.elevenlabs.voice.primary.name' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_VOICE_ID=\"$(yq_eval '.apis.elevenlabs.voice.primary.id' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_PRICING_RATE=$(yq_eval '.apis.elevenlabs.pricing.rate' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_ESTIMATED_COST=$(yq_eval '.apis.elevenlabs.pricing.estimated_episode_cost' "$MASTER_CONFIG")" >> "$temp_env"

    echo "export CONFIG_ELEVENLABS_STABILITY=$(yq_eval '.apis.elevenlabs.settings.stability' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_SIMILARITY_BOOST=$(yq_eval '.apis.elevenlabs.settings.similarity_boost' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_STYLE=$(yq_eval '.apis.elevenlabs.settings.style' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_SPEAKER_BOOST=$(yq_eval '.apis.elevenlabs.settings.use_speaker_boost' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_ELEVENLABS_SSML_PARSING=$(yq_eval '.apis.elevenlabs.settings.enable_ssml_parsing' "$MASTER_CONFIG")" >> "$temp_env"

    # Cost controls
    echo "export CONFIG_COST_PER_EPISODE_TARGET=$(yq_eval '.costs.per_episode.target' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_COST_PER_EPISODE_MAXIMUM=$(yq_eval '.costs.per_episode.maximum' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_COST_ALERT_THRESHOLD=$(yq_eval '.costs.per_episode.alert_threshold' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_COST_CHECKPOINT_SAVINGS=$(yq_eval '.costs.checkpoint_savings.per_checkpoint' "$MASTER_CONFIG")" >> "$temp_env"

    # Quality thresholds
    echo "export CONFIG_QUALITY_COMPREHENSION_MIN=$(yq_eval '.quality.thresholds.comprehension.minimum' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_COMPREHENSION_TARGET=$(yq_eval '.quality.thresholds.comprehension.target' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_BRAND_MIN=$(yq_eval '.quality.thresholds.brand_consistency.minimum' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_BRAND_TARGET=$(yq_eval '.quality.thresholds.brand_consistency.target' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_ENGAGEMENT_MIN=$(yq_eval '.quality.thresholds.engagement.minimum' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_ENGAGEMENT_TARGET=$(yq_eval '.quality.thresholds.engagement.target' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_TECHNICAL_MIN=$(yq_eval '.quality.thresholds.technical_accuracy.minimum' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_TECHNICAL_TARGET=$(yq_eval '.quality.thresholds.technical_accuracy.target' "$MASTER_CONFIG")" >> "$temp_env"

    # Quality evaluation settings
    echo "export CONFIG_QUALITY_CLAUDE_WEIGHT=$(yq_eval '.quality.evaluation.models.claude' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_GEMINI_WEIGHT=$(yq_eval '.quality.evaluation.models.gemini' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_AGREEMENT_THRESHOLD=$(yq_eval '.quality.evaluation.consensus.max_difference' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_MINOR_REVISION_GAP=$(yq_eval '.quality.evaluation.consensus.minor_revision_gap' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_QUALITY_MAJOR_REVISION_GAP=$(yq_eval '.quality.evaluation.consensus.major_revision_gap' "$MASTER_CONFIG")" >> "$temp_env"

    # Brand voice settings
    echo "export CONFIG_BRAND_HUMILITY_MIN=$(yq_eval '.quality.brand_voice.intellectual_humility.minimum_instances' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_BRAND_HUMILITY_TARGET=$(yq_eval '.quality.brand_voice.intellectual_humility.target_instances' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_BRAND_QUESTIONS_MIN=$(yq_eval '.quality.brand_voice.question_density.minimum_per_1000' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_BRAND_QUESTIONS_TARGET=$(yq_eval '.quality.brand_voice.question_density.per_1000_words' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_BRAND_ANALOGIES_MIN=$(yq_eval '.quality.brand_voice.feynman_analogies.minimum_per_episode' "$MASTER_CONFIG")" >> "$temp_env"
    echo "export CONFIG_BRAND_ANALOGIES_TARGET=$(yq_eval '.quality.brand_voice.feynman_analogies.target_per_episode' "$MASTER_CONFIG")" >> "$temp_env"

    # Paths
    echo "export CONFIG_SESSIONS_DIR=\"$(yq_eval '.paths.directories.sessions' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_AGENTS_DIR=\"$(yq_eval '.paths.directories.agents' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_AUDIO_OUTPUT_DIR=\"$(yq_eval '.paths.directories.audio_output' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_TOOLS_DIR=\"$(yq_eval '.paths.directories.tools' "$MASTER_CONFIG")\"" >> "$temp_env"

    # Model configurations
    echo "export CONFIG_CLAUDE_PRIMARY=\"$(yq_eval '.apis.claude.models.primary' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_CLAUDE_FALLBACK=\"$(yq_eval '.apis.claude.models.fallback' "$MASTER_CONFIG")\"" >> "$temp_env"
    echo "export CONFIG_PERPLEXITY_MODEL=\"$(yq_eval '.apis.perplexity.model.primary' "$MASTER_CONFIG")\"" >> "$temp_env"

    # Validation successful, move to cache and source
    mv "$temp_env" "$CONFIG_CACHE"
    source "$CONFIG_CACHE"

    echo -e "${GREEN}✅ Master configuration loaded successfully${NC}"
    echo "    Version: $CONFIG_VERSION"
    echo "    Hash: ${CONFIG_HASH:0:8}..."
    echo "    Episode Target: ${CONFIG_EPISODE_DURATION_TARGET} minutes"
    echo "    TTS Model: $CONFIG_ELEVENLABS_MODEL_NAME"
    echo "    Estimated Cost: \$${CONFIG_ELEVENLABS_ESTIMATED_COST}"

    release_lock
}

# Function to validate current configuration against master
validate_config_consistency() {
    if [[ ! -f "$CONFIG_CACHE" ]]; then
        echo -e "${YELLOW}WARNING: No cached configuration found${NC}"
        return 1
    fi

    local current_hash=$(generate_config_hash)
    if [[ "$CONFIG_HASH" != "$current_hash" ]]; then
        echo -e "${YELLOW}WARNING: Configuration drift detected${NC}"
        echo "Cached hash: $CONFIG_HASH"
        echo "Current hash: $current_hash"
        echo "Recommend reloading configuration with: source config-loader.sh --force"
        return 1
    fi

    return 0
}

# Function to display current configuration values
show_config() {
    if [[ "$CONFIG_LOADED" != "true" ]]; then
        echo -e "${RED}Configuration not loaded. Run: source config-loader.sh${NC}"
        return 1
    fi

    echo -e "${BLUE}📋 Current Configuration${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Version: $CONFIG_VERSION"
    echo "Loaded: $CONFIG_LAST_LOADED"
    echo "Hash: $CONFIG_HASH"
    echo ""
    echo "Episode Specifications:"
    echo "  Duration: ${CONFIG_EPISODE_DURATION_MIN}-${CONFIG_EPISODE_DURATION_MAX} min (target: ${CONFIG_EPISODE_DURATION_TARGET})"
    echo "  Words: ${CONFIG_EPISODE_WORDS_MIN}-${CONFIG_EPISODE_WORDS_MAX} (target: ${CONFIG_EPISODE_WORDS_TARGET})"
    echo "  Characters: ${CONFIG_EPISODE_CHARS_MIN}-${CONFIG_EPISODE_CHARS_MAX} (target: ${CONFIG_EPISODE_CHARS_TARGET})"
    echo ""
    echo "TTS Configuration:"
    echo "  Model: $CONFIG_ELEVENLABS_MODEL_NAME ($CONFIG_ELEVENLABS_MODEL_ID)"
    echo "  Voice: $CONFIG_ELEVENLABS_VOICE_NAME ($CONFIG_ELEVENLABS_VOICE_ID)"
    echo "  Rate: \$${CONFIG_ELEVENLABS_PRICING_RATE}/1k chars"
    echo "  Estimated Cost: \$${CONFIG_ELEVENLABS_ESTIMATED_COST}"
    echo ""
    echo "Cost Controls:"
    echo "  Target: \$${CONFIG_COST_PER_EPISODE_TARGET}"
    echo "  Maximum: \$${CONFIG_COST_PER_EPISODE_MAXIMUM}"
    echo "  Alert: \$${CONFIG_COST_ALERT_THRESHOLD}"
    echo ""
    echo "Quality Thresholds:"
    echo "  Comprehension: ${CONFIG_QUALITY_COMPREHENSION_MIN} (target: ${CONFIG_QUALITY_COMPREHENSION_TARGET})"
    echo "  Brand: ${CONFIG_QUALITY_BRAND_MIN} (target: ${CONFIG_QUALITY_BRAND_TARGET})"
    echo "  Engagement: ${CONFIG_QUALITY_ENGAGEMENT_MIN}"
    echo "  Technical: ${CONFIG_QUALITY_TECHNICAL_MIN}"
}

# Main execution logic
main() {
    local command="${1:-load}"

    case "$command" in
        "load"|"--load")
            load_master_config
            ;;
        "--force")
            echo -e "${YELLOW}🔄 Forcing configuration reload${NC}"
            rm -f "$CONFIG_CACHE"
            load_master_config --force
            ;;
        "validate"|"--validate")
            validate_config_consistency
            ;;
        "show"|"--show")
            show_config
            ;;
        "hash"|"--hash")
            echo "$(generate_config_hash)"
            ;;
        "help"|"--help")
            echo "Configuration Loader - Master Configuration System"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  load (default)  Load master configuration"
            echo "  --force         Force reload configuration"
            echo "  validate        Check configuration consistency"
            echo "  show            Display current configuration"
            echo "  hash            Show configuration hash"
            echo "  help            Show this help"
            echo ""
            echo "Example usage in scripts:"
            echo "  source $0                    # Load config"
            echo "  source $0 --force           # Force reload"
            echo "  echo \$CONFIG_EPISODE_DURATION_TARGET  # Use config value"
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Auto-load configuration if script is sourced without arguments
if [[ "${BASH_SOURCE[0]}" != "${0}" ]] && [[ $# -eq 0 ]]; then
    # Script is being sourced, auto-load config
    load_master_config
else
    # Script is being executed directly, use command
    main "$@"
fi
