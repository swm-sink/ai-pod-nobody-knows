#!/bin/bash
# Production Database Setup Script

set -e

echo "🏭 Setting up PostgreSQL for AI Podcast Production System..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker to continue."
    exit 1
fi

# Start PostgreSQL with Docker Compose
echo "🐳 Starting PostgreSQL container..."
docker-compose up -d postgres

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 10

# Test connection
echo "🔍 Testing database connection..."
docker-compose exec postgres pg_isready -U podcast_app -d podcast_production

if [ $? -eq 0 ]; then
    echo "✅ PostgreSQL is ready!"
    echo "📊 Database URL: postgresql://podcast_app:dev_password_change_in_production@localhost:5432/podcast_production"
    echo "🔧 To start pgAdmin (optional): docker-compose --profile admin up -d pgadmin"
    echo "🌐 pgAdmin will be available at: http://localhost:8080"
    echo "📝 Remember to update your .env.production file with production credentials"
else
    echo "❌ PostgreSQL connection failed"
    exit 1
fi
