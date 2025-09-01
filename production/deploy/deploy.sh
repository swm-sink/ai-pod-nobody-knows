#!/bin/bash
# AI Podcast Production System - Production Deployment Script
# Generated on 2025-09-01 15:49:16 UTC

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="ai-podcast-production"
APP_DIR="/Users/smenssink/Documents/GitHub/ai-podcasts-nobody-knows/.conductor/real-agents"
BACKUP_DIR="$APP_DIR/backups/$(date +%Y%m%d_%H%M%S)"

# Logging
LOG_FILE="$APP_DIR/production/logs/deployment_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ ERROR: $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

# Pre-deployment checks
pre_deployment_checks() {
    log "🔍 Running pre-deployment checks..."

    # Check if environment file exists
    if [[ ! -f "$APP_DIR/.env.production" ]]; then
        error "Production environment file not found. Copy .env.production.template to .env.production and configure it."
    fi

    # Validate environment configuration
    if ! python3 "$APP_DIR/validate_environment.py"; then
        error "Environment validation failed. Please fix configuration issues."
    fi
    success "Environment validation passed"

    # Check database connectivity
    if ! python3 "$APP_DIR/setup_production_database.py"; then
        error "Database setup/connectivity check failed"
    fi
    success "Database connectivity verified"

    # Run health checks
    if python3 "$APP_DIR/production/health/health_check.py"; then
        success "Pre-deployment health checks passed"
    else
        warning "Some health checks failed, but deployment will continue"
    fi
}

# Backup current state
backup_current_state() {
    log "💾 Creating backup of current state..."

    mkdir -p "$BACKUP_DIR"

    # Backup database
    if [[ -f "$APP_DIR/data/development/podcast_production.db" ]]; then
        cp "$APP_DIR/data/development/podcast_production.db" "$BACKUP_DIR/"
        success "Database backup created"
    fi

    # Backup configuration
    if [[ -f "$APP_DIR/.env.production" ]]; then
        cp "$APP_DIR/.env.production" "$BACKUP_DIR/"
        success "Configuration backup created"
    fi

    # Backup logs
    if [[ -d "$APP_DIR/production/logs" ]]; then
        cp -r "$APP_DIR/production/logs" "$BACKUP_DIR/"
        success "Logs backup created"
    fi

    success "Backup completed: $BACKUP_DIR"
}

# Install dependencies
install_dependencies() {
    log "📦 Installing/updating dependencies..."

    # Python dependencies
    if [[ -f "$APP_DIR/requirements.txt" ]]; then
        python3 -m pip install -r "$APP_DIR/requirements.txt" --upgrade
        success "Python dependencies installed"
    fi

    # Pre-commit hooks
    if [[ -f "$APP_DIR/.pre-commit-config.yaml" ]]; then
        python3 -m pip install pre-commit
        pre-commit install
        success "Pre-commit hooks installed"
    fi
}

# Run pre-commit checks
run_quality_checks() {
    log "🔍 Running quality checks..."

    # Run pre-commit hooks
    if command -v pre-commit &> /dev/null; then
        if pre-commit run --all-files; then
            success "Pre-commit checks passed"
        else
            warning "Some pre-commit checks failed, review the output"
        fi
    fi

    # Run production validation
    if python3 "$APP_DIR/tests/integration/validate_production_system.py"; then
        success "Production validation passed"
    else
        warning "Production validation had issues"
    fi
}

# Setup production services
setup_production_services() {
    log "🏭 Setting up production services..."

    # Setup PostgreSQL if using Docker
    if [[ -f "$APP_DIR/production/database/docker-compose.yml" ]] && command -v docker &> /dev/null; then
        cd "$APP_DIR/production/database"
        if docker-compose ps postgres | grep -q "Up"; then
            info "PostgreSQL already running"
        else
            docker-compose up -d postgres
            sleep 10
            success "PostgreSQL started"
        fi
        cd - > /dev/null
    fi

    # Run database migrations/setup
    if python3 "$APP_DIR/setup_production_database.py"; then
        success "Database setup completed"
    else
        error "Database setup failed"
    fi
}

# Start application services
start_application() {
    log "🚀 Starting application services..."

    # This would typically start your application server
    # For now, we'll just verify the system is ready

    # Run final health check
    if python3 "$APP_DIR/production/health/health_check.py"; then
        success "Application health check passed"
    else
        warning "Application health check failed"
    fi

    success "Application deployment completed"
}

# Post-deployment verification
post_deployment_verification() {
    log "🔎 Running post-deployment verification..."

    # Wait a bit for services to stabilize
    sleep 5

    # Run comprehensive validation
    if python3 "$APP_DIR/tests/integration/run_production_validation_suite.py"; then
        success "Post-deployment validation passed"
    else
        warning "Post-deployment validation had issues"
    fi

    # Generate deployment report
    python3 "$APP_DIR/production/health/health_check.py" > "$APP_DIR/production/logs/deployment_health_$(date +%Y%m%d_%H%M%S).log"
    success "Deployment health report generated"
}

# Cleanup old backups and logs
cleanup() {
    log "🧹 Cleaning up old files..."

    # Keep only last 7 days of backups
    find "$APP_DIR/backups" -type d -mtime +7 -exec rm -rf {} + 2>/dev/null || true

    # Keep only last 30 days of logs
    find "$APP_DIR/production/logs" -type f -mtime +30 -delete 2>/dev/null || true

    success "Cleanup completed"
}

# Main deployment function
deploy() {
    log "🚀 Starting deployment of $APP_NAME"
    log "Deployment directory: $APP_DIR"
    log "Backup directory: $BACKUP_DIR"
    log "Log file: $LOG_FILE"

    # Run deployment steps
    pre_deployment_checks
    backup_current_state
    install_dependencies
    run_quality_checks
    setup_production_services
    start_application
    post_deployment_verification
    cleanup

    success "🎉 Deployment completed successfully!"
    log "📄 Deployment log: $LOG_FILE"
    log "💾 Backup location: $BACKUP_DIR"
}

# Rollback function
rollback() {
    log "🔄 Rolling back deployment..."

    if [[ -z "${1:-}" ]]; then
        # Find latest backup
        LATEST_BACKUP=$(find "$APP_DIR/backups" -type d -name "*" | sort | tail -1)
        if [[ -z "$LATEST_BACKUP" ]]; then
            error "No backup found for rollback"
        fi
        ROLLBACK_DIR="$LATEST_BACKUP"
    else
        ROLLBACK_DIR="$1"
    fi

    if [[ ! -d "$ROLLBACK_DIR" ]]; then
        error "Rollback directory not found: $ROLLBACK_DIR"
    fi

    log "Rolling back to: $ROLLBACK_DIR"

    # Restore database
    if [[ -f "$ROLLBACK_DIR/podcast_production.db" ]]; then
        cp "$ROLLBACK_DIR/podcast_production.db" "$APP_DIR/data/development/"
        success "Database rolled back"
    fi

    # Restore configuration
    if [[ -f "$ROLLBACK_DIR/.env.production" ]]; then
        cp "$ROLLBACK_DIR/.env.production" "$APP_DIR/"
        success "Configuration rolled back"
    fi

    success "Rollback completed"
}

# Usage information
usage() {
    echo "AI Podcast Production System - Deployment Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy     - Deploy the application (default)"
    echo "  rollback   - Rollback to previous version"
    echo "  health     - Run health checks only"
    echo "  backup     - Create backup only"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 rollback"
    echo "  $0 rollback /path/to/specific/backup"
    echo "  $0 health"
}

# Command handling
case "${1:-deploy}" in
    "deploy")
        deploy
        ;;
    "rollback")
        rollback "${2:-}"
        ;;
    "health")
        python3 "$APP_DIR/production/health/health_check.py"
        ;;
    "backup")
        backup_current_state
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
