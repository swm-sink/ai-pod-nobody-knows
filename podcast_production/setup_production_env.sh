#!/bin/bash
# Production Environment Configuration Script
# AI Podcast Production System
# Date: August 31, 2025

set -e  # Exit on any error

echo "🚀 AI Podcast Production System - Environment Setup"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if .env already exists
if [[ -f ".env" ]]; then
    print_warning ".env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
    print_info "Existing .env backed up"
fi

# Copy config.example to .env
if [[ -f "config.example" ]]; then
    cp config.example .env
    print_status "Created .env from config.example"
else
    print_error "config.example not found!"
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs
mkdir -p monitoring  
mkdir -p backup
mkdir -p logs/health_checks

print_status "Created required directories"

# Set proper permissions
chmod 600 .env  # Only owner can read/write
chmod +x production_setup.py
chmod +x setup_production_env.sh

print_status "Set appropriate file permissions"

# Display instructions
echo
echo "🔧 NEXT STEPS:"
echo "============="
echo
echo "1. Edit .env file with your actual API keys:"
echo "   ${BLUE}nano .env${NC}"
echo
echo "2. Required API keys to configure:"
echo "   - OPENAI_API_KEY"
echo "   - ANTHROPIC_API_KEY"  
echo "   - ELEVENLABS_API_KEY"
echo "   - PERPLEXITY_API_KEY"
echo "   - OPENROUTER_API_KEY"
echo "   - LANGFUSE_PUBLIC_KEY"
echo "   - LANGFUSE_SECRET_KEY"
echo
echo "3. Run production setup validation:"
echo "   ${BLUE}python production_setup.py${NC}"
echo
echo "4. Run health check:"
echo "   ${BLUE}python health_check.py${NC}"
echo
echo "5. Start first production episode:"
echo "   ${BLUE}python main.py --topic \"Your Topic Here\"${NC}"
echo

print_info "Environment setup completed successfully!"
print_warning "Remember to never commit .env to version control!"

# Check if git is initialized and add .env to gitignore
if [[ -d ".git" ]]; then
    if ! grep -q "^.env$" .gitignore 2>/dev/null; then
        echo ".env" >> .gitignore
        print_status "Added .env to .gitignore"
    fi
fi

echo
echo "🎉 Ready for production deployment!"