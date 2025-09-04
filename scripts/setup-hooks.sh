#!/bin/bash
# Setup script for Git hooks - installs both pre-commit and pre-push hooks
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔧 Git Hooks Setup for Secret Detection${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# 1. Check and install dependencies
echo -e "\n${YELLOW}📦 Checking dependencies...${NC}"

# Check for Python
if ! command_exists python3; then
    echo -e "${RED}❌ Python 3 is required but not installed${NC}"
    exit 1
fi

# Check/install gitleaks
echo -e "\n${YELLOW}🔍 Checking Gitleaks...${NC}"
if ! command_exists gitleaks; then
    echo -e "${YELLOW}Gitleaks not found. Installing...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command_exists brew; then
            brew install gitleaks
        else
            echo -e "${YELLOW}Please install gitleaks manually:${NC}"
            echo -e "  brew install gitleaks"
            echo -e "  or visit: https://github.com/gitleaks/gitleaks#installing"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${YELLOW}Installing gitleaks for Linux...${NC}"
        curl -sSfL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks-linux-amd64 -o /tmp/gitleaks
        chmod +x /tmp/gitleaks
        sudo mv /tmp/gitleaks /usr/local/bin/
    else
        echo -e "${YELLOW}Please install gitleaks manually:${NC}"
        echo -e "  https://github.com/gitleaks/gitleaks#installing"
    fi
else
    echo -e "${GREEN}✅ Gitleaks is installed ($(gitleaks version 2>/dev/null | head -1))${NC}"
fi

# Check/install detect-secrets
echo -e "\n${YELLOW}🔍 Checking detect-secrets...${NC}"
if ! command_exists detect-secrets; then
    echo -e "${YELLOW}detect-secrets not found. Installing...${NC}"
    pip3 install detect-secrets
else
    echo -e "${GREEN}✅ detect-secrets is installed${NC}"
fi

# Check/install pre-commit
echo -e "\n${YELLOW}🔍 Checking pre-commit framework...${NC}"
if ! command_exists pre-commit; then
    echo -e "${YELLOW}pre-commit not found. Installing...${NC}"
    pip3 install pre-commit
else
    echo -e "${GREEN}✅ pre-commit is installed${NC}"
fi

# 2. Set up pre-commit hooks
echo -e "\n${YELLOW}📝 Setting up pre-commit hooks...${NC}"
cd "$PROJECT_ROOT"

# Install pre-commit hooks
if [ -f "config/.pre-commit-config.yaml" ] || [ -f ".pre-commit-config.yaml" ]; then
    if [ -f "config/.pre-commit-config.yaml" ]; then
        pre-commit install -c config/.pre-commit-config.yaml
    else
        pre-commit install
    fi
    echo -e "${GREEN}✅ Pre-commit hooks installed${NC}"
else
    echo -e "${YELLOW}⚠️  No .pre-commit-config.yaml found${NC}"
fi

# 3. Set up pre-push hook
echo -e "\n${YELLOW}🔐 Setting up pre-push hook...${NC}"
HOOK_FILE="$PROJECT_ROOT/.git/hooks/pre-push"

if [ -f "$SCRIPT_DIR/hooks/pre-push.sh" ]; then
    cp "$SCRIPT_DIR/hooks/pre-push.sh" "$HOOK_FILE"
    chmod +x "$HOOK_FILE"
    echo -e "${GREEN}✅ Pre-push hook installed${NC}"
else
    echo -e "${RED}❌ pre-push.sh not found in $SCRIPT_DIR/hooks/${NC}"
fi

# 4. Initialize detect-secrets baseline
echo -e "\n${YELLOW}📊 Checking secrets baseline...${NC}"
BASELINE_FILE="$PROJECT_ROOT/config/.secrets.baseline"

if [ ! -f "$BASELINE_FILE" ]; then
    echo -e "${YELLOW}Creating secrets baseline...${NC}"
    mkdir -p "$PROJECT_ROOT/config"
    detect-secrets scan --baseline "$BASELINE_FILE"
    echo -e "${GREEN}✅ Secrets baseline created${NC}"
else
    echo -e "${GREEN}✅ Secrets baseline exists${NC}"
    echo -e "${YELLOW}  To update: detect-secrets scan --update $BASELINE_FILE${NC}"
fi

# 5. Check for gitleaks configuration
echo -e "\n${YELLOW}⚙️  Checking gitleaks configuration...${NC}"
if [ -f "$PROJECT_ROOT/.gitleaks.toml" ]; then
    echo -e "${GREEN}✅ Gitleaks configuration exists${NC}"
else
    echo -e "${YELLOW}⚠️  No .gitleaks.toml found. Using default rules${NC}"
fi

# 6. Run initial security scan
echo -e "\n${YELLOW}🔍 Running initial security scan...${NC}"
echo -e "${CYAN}This may take a moment...${NC}"

# Run gitleaks scan
if command_exists gitleaks; then
    echo -e "\n${YELLOW}Running Gitleaks scan...${NC}"
    if gitleaks detect --source "$PROJECT_ROOT" --config "$PROJECT_ROOT/.gitleaks.toml" --verbose --no-banner 2>&1 | grep -q "no leaks found"; then
        echo -e "${GREEN}✅ No secrets detected by Gitleaks${NC}"
    else
        echo -e "${YELLOW}⚠️  Potential issues found. Run 'gitleaks detect --verbose' for details${NC}"
    fi
fi

# 7. Summary
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Git hooks successfully configured!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${GREEN}🛡️  Protection enabled:${NC}"
echo -e "  ${CYAN}•${NC} Pre-commit: detect-secrets, file checks, format validation"
echo -e "  ${CYAN}•${NC} Pre-push: gitleaks deep scan, comprehensive secret detection"

echo -e "\n${GREEN}📖 Usage:${NC}"
echo -e "  ${CYAN}•${NC} Normal push: ${YELLOW}git push${NC} (hooks run automatically)"
echo -e "  ${CYAN}•${NC} Skip hooks (EMERGENCY): ${YELLOW}git push --no-verify${NC}"
echo -e "  ${CYAN}•${NC} Update baseline: ${YELLOW}detect-secrets scan --update config/.secrets.baseline${NC}"
echo -e "  ${CYAN}•${NC} Manual scan: ${YELLOW}gitleaks detect --source . --verbose${NC}"
echo -e "  ${CYAN}•${NC} Scan git history: ${YELLOW}gitleaks detect --source . --log-opts=\"--all\"${NC}"

echo -e "\n${YELLOW}⚠️  Important:${NC}"
echo -e "  ${CYAN}•${NC} Always review detected secrets before pushing"
echo -e "  ${CYAN}•${NC} Never use --no-verify unless absolutely necessary"
echo -e "  ${CYAN}•${NC} Rotate any accidentally exposed credentials immediately"

echo -e "\n${GREEN}✅ Setup complete!${NC}"
