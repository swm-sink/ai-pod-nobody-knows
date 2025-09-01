# AI Podcast Production System - Production Dockerfile
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash podcast && \
    chown -R podcast:podcast /app
USER podcast

# Create necessary directories
RUN mkdir -p /app/data/production /app/production/logs /app/production/metrics

# Health check
HEALTHCHECK --interval=5m --timeout=30s --start-period=60s --retries=3 \
    CMD python3 production/health/health_check.py || exit 1

# Expose port
EXPOSE 8000

# Default command
CMD ["python3", "production/server/app.py"]
