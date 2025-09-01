#!/bin/bash
# Docker Deployment Script for AI Podcast Production System

set -euo pipefail

# Configuration
COMPOSE_FILE="production/docker/docker-compose.yml"
ENV_FILE=".env.production"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker not found. Please install Docker."
    fi

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        error "Docker Compose not found. Please install Docker Compose."
    fi

    # Check environment file
    if [[ ! -f "$ENV_FILE" ]]; then
        error "Environment file $ENV_FILE not found. Copy .env.production.template and configure it."
    fi

    success "Prerequisites check passed"
}

# Deploy with Docker
deploy() {
    info "Starting Docker deployment..."

    # Build images
    docker-compose -f "$COMPOSE_FILE" build --no-cache
    success "Images built successfully"

    # Start services
    docker-compose -f "$COMPOSE_FILE" up -d
    success "Services started"

    # Wait for services to be healthy
    info "Waiting for services to be healthy..."
    sleep 30

    # Check service status
    docker-compose -f "$COMPOSE_FILE" ps

    # Run health check
    if docker-compose -f "$COMPOSE_FILE" exec -T podcast-app python3 production/health/health_check.py; then
        success "Deployment health check passed"
    else
        error "Deployment health check failed"
    fi

    success "Docker deployment completed successfully!"
}

# Stop services
stop() {
    info "Stopping services..."
    docker-compose -f "$COMPOSE_FILE" down
    success "Services stopped"
}

# Show logs
logs() {
    docker-compose -f "$COMPOSE_FILE" logs -f "${2:-}"
}

# Show status
status() {
    docker-compose -f "$COMPOSE_FILE" ps
}

# Usage
usage() {
    echo "Docker Deployment Script for AI Podcast Production System"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy  - Deploy the application with Docker"
    echo "  stop    - Stop all services"
    echo "  logs    - Show logs for all services"
    echo "  status  - Show service status"
    echo "  help    - Show this help"
}

# Command handling
case "${1:-deploy}" in
    "deploy")
        check_prerequisites
        deploy
        ;;
    "stop")
        stop
        ;;
    "logs")
        logs
        ;;
    "status")
        status
        ;;
    "help"|"-h"|"--help")
        usage
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
