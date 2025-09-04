#!/bin/bash

# Enhanced Pre-Push Git Hook with Security Check
# Version: 2.0
# Purpose: API key detection + 50-step validation enforcement
# Author: Claude Code Security & Validation System

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}    ENHANCED PRE-PUSH VALIDATION${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Get git root and current branch
GIT_ROOT=$(git rev-parse --show-toplevel)
current_branch=$(git branch --show-current)

# Step 1: Run Security Check
echo -e "${BLUE}[1/2] Running API Key Security Check...${NC}"
echo ""

# Check if security check script exists
SECURITY_CHECK="${GIT_ROOT}/.git/hooks/pre-push-security-check.sh"
if [ -f "$SECURITY_CHECK" ]; then
    if ! "$SECURITY_CHECK"; then
        echo -e "${RED}❌ Security check failed - push aborted${NC}"
        echo -e "${YELLOW}Fix the security issues before pushing${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Security check script not found${NC}"
    echo -e "${YELLOW}   Expected at: $SECURITY_CHECK${NC}"
    echo -e "${YELLOW}   Installing security check...${NC}"
    
    # Try to install from .claude/security if available
    if [ -f "${GIT_ROOT}/.claude/security/pre-push-security-check.sh" ]; then
        cp "${GIT_ROOT}/.claude/security/pre-push-security-check.sh" "$SECURITY_CHECK"
        chmod +x "$SECURITY_CHECK"
        echo -e "${GREEN}   ✓ Security check installed${NC}"
        
        # Run it now
        if ! "$SECURITY_CHECK"; then
            echo -e "${RED}❌ Security check failed - push aborted${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}   Security check not available - continuing...${NC}"
    fi
fi

echo ""
echo -e "${BLUE}[2/2] Running Validation Check...${NC}"
echo ""

# Step 2: Original Validation Logic (for protected branches)
# Only enforce on main/production branches
if [[ "$current_branch" == "main" || "$current_branch" == "production" ]]; then
    echo -e "${YELLOW}Pushing to protected branch: $current_branch${NC}"
    echo -e "${YELLOW}50-step validation required!${NC}"
    
    # Look for recent validation report
    VALIDATION_DIR="${GIT_ROOT}/.claude/validation/reports"
    if [ -d "$VALIDATION_DIR" ]; then
        # Find validation reports from last 24 hours
        recent_validations=$(find "$VALIDATION_DIR" -name "validation_*.md" -mtime -1 2>/dev/null || true)
        
        if [ -n "$recent_validations" ]; then
            echo -e "${GREEN}Found recent validation report(s):${NC}"
            echo "$recent_validations"
            
            # Check if validation was successful
            latest_report=$(echo "$recent_validations" | head -1)
            if grep -q "VALIDATION SUCCESSFUL" "$latest_report" 2>/dev/null; then
                echo -e "${GREEN}✅ Validation completed successfully${NC}"
                echo ""
                echo -e "${CYAN}============================================${NC}"
                echo -e "${GREEN}     🎉 ALL CHECKS PASSED - PUSH APPROVED 🎉${NC}"
                echo -e "${CYAN}============================================${NC}"
                exit 0
            else
                echo -e "${RED}❌ Latest validation did not complete successfully${NC}"
            fi
        else
            echo -e "${RED}❌ No recent validation reports found${NC}"
        fi
    else
        echo -e "${RED}❌ Validation directory not found${NC}"
    fi
    
    echo -e "\n${RED}PUSH REJECTED${NC}"
    echo -e "${YELLOW}Required: Complete 50-step validation before pushing to $current_branch${NC}"
    echo -e "\n${BLUE}How to proceed:${NC}"
    echo "1. Run: /run-validation"
    echo "2. Complete all 50 validation steps"
    echo "3. Ensure validation report shows SUCCESS"
    echo "4. Retry your push"
    echo -e "\n${BLUE}Or run automated checks only:${NC}"
    echo "./scripts/validate_pre_push.sh"
    echo -e "\n${YELLOW}Note: This hook protects production quality${NC}"
    echo -e "${YELLOW}All pushes to main/production must be validated${NC}"
    
    exit 1
else
    echo -e "${GREEN}Pushing to development branch: $current_branch${NC}"
    echo -e "${GREEN}Validation enforcement skipped${NC}"
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${GREEN}     🎉 ALL CHECKS PASSED - PUSH APPROVED 🎉${NC}"
    echo -e "${CYAN}============================================${NC}"
    exit 0
fi