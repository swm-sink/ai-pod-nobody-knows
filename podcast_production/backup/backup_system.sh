#!/bin/bash
# Automated backup script for AI Podcast Production System
# Generated: 2025-09-01T09:49:35.555717+00:00

BACKUP_DIR="backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Configuration backup
cp -r config/ "$BACKUP_DIR/config/"

# Episode data backup  
cp -r output/ "$BACKUP_DIR/output/"
cp -r research_data/ "$BACKUP_DIR/research_data/"
cp -r audio_output/ "$BACKUP_DIR/audio_output/"

# Redis backup (if running)
if redis-cli ping > /dev/null 2>&1; then
    redis-cli BGSAVE
    cp dump.rdb "$BACKUP_DIR/redis_dump.rdb"
fi

# Logs backup
cp -r logs/ "$BACKUP_DIR/logs/"

# Compress backup
tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

echo "Backup completed: $BACKUP_DIR.tar.gz"
